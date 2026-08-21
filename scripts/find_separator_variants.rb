# SEPARATOR-VARIANT SWEEP — the class that produced eight of nine 4-wheel gate
# failures in the 2026-08-21 refresh.
#
# THE DEFECT. A rename key is a STRING; an id is a SLUG; and slugify collapses
# every run of non-alphanumerics to one hyphen. So "A-Model", "A Model" and
# "A.Model" are THREE DISTINCT KEYS that all slug to `a-model`. Key one of them
# and the register writes another, and the key is inert: the produced name never
# matches, the fold never fires, and the id the fold was meant to retire gets
# minted instead — under a former_ids arm that then names a live record.
#
# Measured instances, all the same shape:
#   data#300  "Focus C-Max"        keyed  /  "Focus C Max"        produced
#   data#310  "A-Model"            keyed  /  "A Model"            produced
#             "1500-Karmann Ghia"  keyed  /  "1500 Karmann Ghia"  produced
#             "D-150"              keyed  /  "D 150"              produced
#             "Pick-Up", "Pickup"  keyed  /  "Pick Up"            produced
#             "King Cab"           keyed  /  "King-Cab"           produced   (mirror)
#
# WHAT THIS REPORTS. For every rename key K in a make block, it asks whether the
# BUILD produced a different string P under the same make where slug(P) ==
# slug(K). That P is a spelling the register actually writes and no key covers —
# a live inert-key gap, not a hypothetical one. Corpus-driven by construction:
# it never invents a variant that nobody writes.
#
# It is deliberately NOT a gate. It reports exposure so the gaps can be keyed
# before a gate fires on the id they mint.
require "json"
require "yaml"
require "set"

# Roots resolve the same way scripts/audit_rename_value_liveness.rb resolves
# them, and for the same reason: a sweep that reads one session's worktree from
# every checkout reports that worktree's answer and looks identical doing it
# (data#306). P is NOT derived from D — the data repo under audit is usually a
# worktree, and worktrees carry no build/out.
D = File.expand_path(ENV["VDB_DATA_REPO"] || File.join(__dir__, ".."))
P = File.expand_path(ENV["VDB_PIPELINE_REPO"] || File.join(__dir__, "..", "..", "vehiclesdb-pipeline"))
BUILD = File.expand_path(ENV["VDB_BUILD"] || File.join(P, "build"))

def slug(s)
  s.to_s.downcase.unicode_normalize(:nfkd).gsub(/\p{Mn}+/, "")
   .gsub(/[^a-z0-9]+/, "-").gsub(/(\A-|-\z)/, "")
end

# ── the corpus: every name the build actually produced, per make ──────────────
# Published records AND candidates. Candidates matter more than published ones
# here: a spelling below threshold today is exactly the one that mints an id
# when the next refresh pushes it over.
produced = Hash.new { |h, k| h[k] = Set.new }   # make_id => Set[name]
sources  = { published: 0, candidates: 0 }

catalog_files = Dir[File.join(BUILD, "out", "catalog", "*", "models.json")].sort
cand_files    = Dir[File.join(BUILD, "candidates", "*.jsonl")].sort

if catalog_files.empty? && cand_files.empty?
  abort "find_separator_variants: no build corpus under #{BUILD} " \
        "(expected out/catalog/*/models.json and/or candidates/*.jsonl). " \
        "Without it EVERY key would read as un-shadowed and the sweep would " \
        "report a clean bill it never earned. Point VDB_BUILD at a build, or " \
        "VDB_PIPELINE_REPO at a checkout that has one."
end

catalog_files.each do |f|
  JSON.parse(File.read(f)).each do |m|
    next unless m["make_id"] && m["name"]
    produced[m["make_id"]] << m["name"]
    sources[:published] += 1
  end
end

cand_files.each do |f|
  File.foreach(f) do |line|
    m = JSON.parse(line) rescue next
    id = m["id"].to_s
    next if id.empty?
    make_id = id.split("/", 2).first
    # candidates carry the raw `native` but not always a display name; derive
    # the produced name from the id's slug half only when a name is absent.
    name = m["name"] || (m["native"]&.first&.split("|", 2)&.last&.strip)
    next unless name
    produced[make_id] << name
    sources[:candidates] += 1
  end
end

# ── the keys ─────────────────────────────────────────────────────────────────
renames = YAML.safe_load_file(File.join(D, "overrides/models/renames.yml"),
                              permitted_classes: [], aliases: false) || {}

# make BLOCK name ("Mercedes-Benz") -> make_id ("mercedes-benz"). The build
# indexes by make_id; renames.yml is keyed by the display make.
findings = []
keys_examined = 0
blocks_skipped = 0

renames.each do |make, block|
  unless block.is_a?(Hash)
    blocks_skipped += 1
    next
  end
  mid = slug(make)
  corpus = produced[mid]
  next if corpus.empty?

  # slug -> the keys authored for it, and the strings the build produced for it
  by_slug_keys = Hash.new { |h, k| h[k] = [] }
  block.each_key { |k| by_slug_keys[slug(k)] << k.to_s; keys_examined += 1 }

  by_slug_prod = Hash.new { |h, k| h[k] = [] }
  corpus.each { |n| by_slug_prod[slug(n)] << n }

  by_slug_keys.each do |sl, keys|
    prods = by_slug_prod[sl]
    next if prods.empty?
    # A produced string that is not itself an authored key, on a slug that HAS
    # an authored key, is the gap: the key exists and cannot fire on this row.
    gaps = prods.reject { |p| keys.include?(p) }
    next if gaps.empty?
    # If the produced string is the key's own VALUE it is the fold TARGET, not a
    # gap — "Pick Up" produced where "Pickup" -> "Pick Up" is correct.
    #
    # Compared CASE-INSENSITIVELY on purpose. Govecs keys "GO!S1.2" -> "GO! S1.2"
    # while the build publishes "Go! S1.2": the fold is working and only the
    # display casing differs, which is styling.yml's business, not an inert key.
    # Reporting it here would put a styling question in a list people read as
    # "folds that cannot fire" — the wrong list is as bad as no list.
    values = keys.map { |k| block[k].to_s.downcase }
    gaps = gaps.reject { |p| values.include?(p.downcase) }
    next if gaps.empty?
    findings << [make, sl, keys, gaps, keys.map { |k| block[k] }.compact.uniq]
  end
end

# ── report: what was examined and what the predicate is, before what was found
puts "  data repo:     #{D}#{ENV['VDB_DATA_REPO'] ? ' (VDB_DATA_REPO)' : ''}"
puts "  build corpus:  #{BUILD}#{ENV['VDB_BUILD'] ? ' (VDB_BUILD)' : ''}"
puts "                 #{catalog_files.size} catalog file(s), #{cand_files.size} candidate file(s)"
puts "                 #{sources[:published]} published + #{sources[:candidates]} candidate name(s) over #{produced.size} makes"
puts "  keys examined: #{keys_examined} rename key(s) in #{renames.size - blocks_skipped} make block(s)"
puts "  predicate:     a key K is REPORTED when the build produced a different"
puts "                 string P under the SAME MAKE with slug(P) == slug(K)."
puts "                 DECLINED: makes absent from the build (#{produced.empty? ? 0 : renames.count { |mk, b| b.is_a?(Hash) && produced[slug(mk)].empty? }}), non-block entries (#{blocks_skipped}),"
puts "                 and produced strings equal (case-insensitively) to the key's own VALUE — fold targets and styling differences, not inert keys."
puts
puts "  ── INERT-KEY GAPS (#{findings.size}) — a key that cannot fire on a spelling the build produces ──"
findings.sort_by { |f| [-f[3].size, f[0].to_s] }.first(40).each do |make, sl, keys, gaps, vals|
  puts format("      %-16s slug %-24s", make, sl)
  puts format("          keyed:    %s -> %s", keys.map(&:inspect).join(", "), vals.map(&:inspect).join(", "))
  puts format("          PRODUCED: %s   <- unkeyed", gaps.map(&:inspect).join(", "))
end
puts "      … #{findings.size - 40} more" if findings.size > 40
puts
puts "  Nothing to do — no authored key is shadowed by a different produced spelling." if findings.empty?
