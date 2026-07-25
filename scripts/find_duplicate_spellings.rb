#!/usr/bin/env ruby
# frozen_string_literal: true
#
# find_duplicate_spellings.rb — the same car published twice under different
# spellings, because the spellings slug differently.
#
#     mercedes-benz/280-se  "280 Se"   4 sources
#     mercedes-benz/280se   "280SE"    4 sources   <- the same W108
#
# Each such pair splits a model's own evidence across two ids, so both look
# weaker than the car actually is and a consumer picking one gets half the
# countries. 632 groups / 1,283 records existed in the four-wheel half when this
# was first run; it is down to ~140 and this script is how the rest get found.
#
# READS THE PUBLISHED CATALOG, not the override layer. catalog/ is a monthly
# build output, so merges you just authored do NOT reduce this count until a
# build runs — expect the number to stay flat after a curation PR and drop in
# one step at the next release. Simulate the pending state by applying
# overrides/models/renames.yml yourself if you need the post-build figure.
#
# Usage:  ruby scripts/find_duplicate_spellings.rb [--make=volvo]
#
# It PROPOSES; it does not write. Two risk classes come out of it:
#   * canonical already exists as one of the variants -> a safe merge
#   * canonical is a NEW string ("280 SE" — neither variant is right) -> verify
#     against the marque's own archive before minting an id (NAMING.md §2)
#
# GOTCHA that cost real damage: normalize with NFKD accent FOLDING, never by
# deleting non-ASCII. Stripping accents made "ë-C3" (Citroën's ELECTRIC C3, a
# distinct model) normalize to "c3" and merge into the petrol C3.
#
# A "collision" is two or more records under one make+kind whose names are
# identical once case and punctuation are removed: "280 Se" vs "280SE" vs
# "280 SE". They are the same car, but they slug differently, so they publish as
# separate ids and split their own evidence.
#
# CANONICAL FORM (conservative, evidence-led):
#   * split letter-runs from digit-runs with a single space, UNLESS every
#     variant that has a separator there uses a hyphen (CX-5 stays CX-5);
#   * a letter token is UPPERCASE if any variant writes it fully uppercase and
#     it is <= 4 chars (SE, GT, TDI); otherwise Title Case;
#   * a variant that already equals the computed form is preferred as-is.
#
# Output: a review table + a YAML fragment of renames. Nothing is written to the
# repo — this is a proposal for human review, and groups where the rule is not
# confident are flagged rather than guessed.
require "json"
require "yaml"
require "set"

ROOT = File.expand_path("~/GitHub/.vdb-worktrees/s4w-data")
KINDS = %w[car van motorcycle moped truck bus]
own = YAML.safe_load_file(File.join(ROOT, "OWNERSHIP.yml"))
MINE = Set.new(own["s4w"] || [])
ONLY = ARGV.find { |a| a.start_with?("--make=") }&.split("=", 2)&.last

makes = {}
records = []
KINDS.each do |k|
  JSON.parse(File.read(File.join(ROOT, "catalog", k, "makes.json"))).each { |m| makes[[k, m["id"]]] = m["name"] }
  JSON.parse(File.read(File.join(ROOT, "catalog", k, "models.json"))).each { |m| records << m.merge("_kind" => k) }
end

def tokens(name)
  name.scan(/\d+|[A-Za-z]+|[^\sA-Za-z0-9]+/)
end

def canonical(variants)
  # Work from the variant with the most tokens so nothing is lost.
  base = variants.max_by { |v| [tokens(v).size, v.length] }
  toks = tokens(base)
  out = []
  toks.each_with_index do |t, i|
    if t.match?(/\A[A-Za-z]+\z/)
      upper = variants.any? { |v| v.match?(/(\A|[^A-Za-z])#{Regexp.escape(t.upcase)}([^A-Za-z]|\z)/) } && t.length <= 4
      out << (upper ? t.upcase : t.capitalize)
    elsif t.match?(/\A\d+\z/)
      out << t
    else
      out << t # punctuation, kept in place
    end
  end
  # Join: hyphen if the majority of variants hyphenate that boundary, else space.
  s = +""
  out.each_with_index do |t, i|
    if i.zero? || t.match?(/\A[^\sA-Za-z0-9]+\z/) || out[i - 1].match?(/\A[^\sA-Za-z0-9]+\z/)
      s << t
    else
      hyphenated = variants.count { |v| v.match?(/#{Regexp.escape(out[i - 1])}-#{Regexp.escape(t)}/i) }
      s << (hyphenated > variants.size / 2.0 ? "-" : " ") << t
    end
  end
  s.strip
end

groups = []
records.group_by { |m| [m["_kind"], m["make_id"]] }.each do |(kind, make_id), ms|
  next unless MINE.include?(make_id)
  next if ONLY && make_id != ONLY
  ms.group_by { |m| m["name"].downcase.unicode_normalize(:nfkd).gsub(/\p{Mn}+/, "").gsub(/[^a-z0-9]/, "") }.each do |_, dupes|
    next if dupes.size < 2
    variants = dupes.map { |d| d["name"] }
    canon = canonical(variants)
    groups << { kind: kind, make: make_id, make_name: makes[[kind, make_id]],
                variants: variants, canonical: canon,
                records: dupes,
                sources: dupes.to_h { |d| [d["name"], (d["sources"] || []).size] },
                countries: dupes.flat_map { |d| (d["availability"] || []).map { |a| a["country"] } }.uniq.sort }
  end
end

puts "#{groups.size} collision groups in the s4w half, #{groups.sum { |g| g[:records].size }} records"
puts

by_make = groups.group_by { |g| g[:make] }.sort_by { |_, v| -v.sum { |g| g[:records].size } }
puts "=== top makes by affected records ==="
by_make.first(20).each { |mk, gs| puts format("  %-18s %3d groups %4d records", mk, gs.size, gs.sum { |g| g[:records].size }) }

puts
puts "=== proposed canonical forms (first 60 groups, biggest makes first) ==="
shown = 0
by_make.each do |_, gs|
  gs.sort_by { |g| -g[:records].size }.each do |g|
    break if shown >= 60
    shown += 1
    others = g[:variants] - [g[:canonical]]
    flag = g[:variants].include?(g[:canonical]) ? " " : "*"
    puts format("%s %-11s %-16s %-24s ← %s", flag, g[:kind], g[:make], g[:canonical].inspect,
                others.map(&:inspect).join(" + "))
  end
end
puts
puts "* = the canonical form is NEW (no existing variant spells it correctly)"

# YAML fragment
frag = Hash.new { |h, k| h[k] = {} }
groups.each do |g|
  (g[:variants] - [g[:canonical]]).each { |v| frag[g[:make_name]][v] = g[:canonical] }
end
File.write("/tmp/collision_renames.yml", frag.to_h.transform_values { |v| v.sort.to_h }.to_yaml)
puts "\nwrote /tmp/collision_renames.yml — #{frag.values.sum(&:size)} rename entries across #{frag.size} makes"

# --- split by risk class for review ---
existing = groups.select { |g| g[:variants].include?(g[:canonical]) }
brandnew = groups - existing
puts "\nSAFE (canonical already exists as a variant — pure merge): #{existing.size} groups / #{existing.sum { |g| g[:records].size }} records"
puts "NEW  (canonical is a new string — mints an id):             #{brandnew.size} groups / #{brandnew.sum { |g| g[:records].size }} records"
puts "NEW-class by make: " + brandnew.group_by { |g| g[:make] }.sort_by { |_, v| -v.size }.first(10).map { |mk, gs| "#{mk}:#{gs.size}" }.join(" ")
File.write("/tmp/safe_groups.json", JSON.pretty_generate(existing.map { |g| { kind: g[:kind], make: g[:make_name], canonical: g[:canonical], others: g[:variants] - [g[:canonical]] } }))
File.write("/tmp/new_groups.json", JSON.pretty_generate(brandnew.map { |g| { kind: g[:kind], make: g[:make_name], canonical: g[:canonical], variants: g[:variants] } }))
