#!/usr/bin/env ruby
# Emit, per slice, the FULL published record for every sampled id — read from
# the PINNED build (the released catalog at the tag), never from a rebuild.
#
# This exists because the review packs are generated from a local frozen build
# that does NOT reproduce the release byte-for-byte (measured: 23 records in the
# release are absent from it, 1 present that the release lacks, and 13,876 of
# 14,886 common records differ on at least one field — overwhelmingly
# popularity/xrefs/availability, and 33 car names). The pack is EVIDENCE; this
# file is the CLAIM UNDER AUDIT. A researcher who verifies the pack's copy of a
# record instead of this one is auditing a build nobody shipped.
require "json"
require "yaml"

pin, slice_dir, out_dir = ARGV[0], ARGV[1], ARGV[2]

cat = {}
%w[car van truck bus motorcycle moped].each do |k|
  f = File.join(pin, "catalog", k, "models.json")
  next unless File.exist?(f)
  JSON.parse(File.read(f)).each { |m| cat["#{k}/#{m['id']}"] = m }
end

Dir[File.join(slice_dir, "slice-*.yml")].sort.each do |f|
  s = YAML.load_file(f)
  recs = s["ids_head_first"].map do |id|
    r = cat.fetch(id)
    { "audit_id" => id, "decile" => s["decile"][id],
      "stratum" => (s["decile"][id].nil? || s["decile"][id] > 6) ? "tail" : "head",
      "published_record" => r }
  end
  name = File.basename(f, ".yml")
  File.write(File.join(out_dir, "#{name}-records.json"), JSON.pretty_generate({
    "tag" => s["tag"], "half" => s["half"], "slice" => s["slice"],
    "build_pin" => s["build_pin"],
    "source" => "#{pin}/catalog/<kind>/models.json — the RELEASED bytes at the tag",
    "records" => recs.size,
    "head_records" => s["head_records"], "tail_records" => s["tail_records"],
    "makes" => s["makes"],
    "claims_expected" => recs.sum { |r|
      # id, name, make, kind = 4; availability = one per country entry.
      4 + (r["published_record"]["availability"] || []).size
    },
    "audit" => recs
  }))
  puts format("%-18s %3d records  %4d claims expected  %3d makes", name, recs.size,
              recs.sum { |r| 4 + (r["published_record"]["availability"] || []).size }, s["makes"].size)
end
