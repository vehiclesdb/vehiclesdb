#!/usr/bin/env ruby
# Cut a SAMPLE-<half>.yml into N make-coherent slices, head-first.
#
# MAKE-COHERENT IS NOT A NICETY (audit-PROTOCOL v1.1 rule 5): the id-canonical
# check must enumerate ALL live twins in-make, so a make split across two slices
# recreates the single-twin comparison that produced the baseline round's own
# misses. So the atom here is the (kind, make) group, never the record.
require "yaml"
require "json"

sample_path, pin, nslices, out_dir = ARGV[0], ARGV[1], ARGV[2].to_i, ARGV[3]
s = YAML.load_file(sample_path)
half = s["half"]

# decile per id, from the PINNED build — the same artifact the aggregator bands on.
decile = {}
%w[car van truck bus motorcycle moped].each do |k|
  f = File.join(pin, "catalog", k, "models.json")
  next unless File.exist?(f)
  JSON.parse(File.read(f)).each { |m| decile["#{k}/#{m['id']}"] = m.dig("popularity", "global_decile") }
end

ids = s["strata"].values.flatten.uniq
missing = ids.reject { |i| decile.key?(i) }
abort "#{missing.size} sampled ids absent from the pin: #{missing.first(5)}" unless missing.empty?

groups = ids.group_by { |i| i.split("/")[0, 2].join("/") } # kind/make

# Head-first: a group's priority is its BEST (lowest) decile; nil sorts last.
# Greedy longest-processing-time packing into fixed bins keeps slices even in
# record count while never splitting a group.
ranked = groups.map { |g, v|
  best = v.map { |i| decile[i] || 99 }.min
  [g, v, best]
}.sort_by { |g, v, best| [best, -v.size, g] }

bins = Array.new(nslices) { { ids: [], n: 0, best: 99 } }
ranked.each do |g, v, best|
  b = bins.min_by { |x| [x[:n], bins.index(x)] }
  b[:ids].concat(v)
  b[:n] += v.size
  b[:best] = [b[:best], best].min
end

bins.each_with_index do |b, i|
  n = i + 1
  by_make = b[:ids].group_by { |x| x.split("/")[0, 2].join("/") }
  head = b[:ids].count { |x| (decile[x] || 99) <= 6 }
  File.write(File.join(out_dir, "slice-#{half}-b#{n}.yml"), {
    "half" => half, "slice" => n, "tag" => s["tag"], "build_pin" => s["build_pin"],
    "records" => b[:ids].size, "head_records" => head, "tail_records" => b[:ids].size - head,
    "makes" => by_make.keys.sort,
    "ids_head_first" => b[:ids].sort_by { |x| [decile[x] || 99, x] },
    "decile" => b[:ids].to_h { |x| [x, decile[x]] }
  }.to_yaml)
  puts format("slice-%s-b%d: %3d records  %3d head  %3d tail  %3d makes", half, n, b[:ids].size, head, b[:ids].size - head, by_make.size)
end
puts "  #{half}: #{ids.size} records, #{groups.size} kind/make groups"
