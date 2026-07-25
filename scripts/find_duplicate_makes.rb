#!/usr/bin/env ruby
# frozen_string_literal: true
#
# find_duplicate_makes.rb — the same MARQUE published under two make ids.
#
#     truck/man    "MAN"     28 models
#     truck/m-a-n  "M.A.N"    2 models   <- the same manufacturer
#
# WHY THIS EXISTS AS A SEPARATE SCRIPT. `find_duplicate_spellings.rb` groups
# records *within* one make and finds duplicate MODEL spellings. It is blind by
# construction to two makes that are the same marque: those records never share
# a group key. `m-a-n` sat next to `man` in the truck kind through the entire
# 2026-07 correction pass and no gate, lint or detector mentioned it — it was
# found by accident while auditing cross-kind drop leakage.
#
# The damage is the same as the model-level case but worse: a duplicate make
# splits a marque's evidence across two ids, so BOTH look thinner than the
# marque is, both may fall under the publication thresholds, and a consumer
# iterating makes sees the marque twice.
#
# THE FOLD. Same transliteration fold the pipeline's make_dropped? uses
# (normalizer.rb) — NFKD, strip combining marks, then oe/ue/ae/ss digraphs,
# then drop every non-alphanumeric. Punctuation removal is what makes "M.A.N"
# and "MAN" collide; the digraph rules are what make "PÖSSL"/"POESSL" collide.
# Keep the two folds in sync: a divergence here means the detector reports
# collisions the pipeline cannot act on, or misses ones it can.
#
# IT PROPOSES; IT DOES NOT WRITE. And "same fold" is NOT "same marque" —
# verify before merging. Real counterexamples to expect:
#   * genuinely distinct marques whose names fold together (short initialisms
#     are the risk: check the countries and eras before merging);
#   * a marque and a MODEL of that marque published as a make (mgb is a UK
#     two-wheeler badge, NOT MG's B — that one cost a research detour);
#   * a registry placeholder that is not a marque at all ("Eigenbouw" = Dutch
#     for self-built; "Factory Built" is an NZTA origin flag). Those need a
#     drop or a move, never a merge — and see the warning below.
#
# THE TRAP, stated plainly because it has bitten this dataset before: when the
# junk make holds REAL manufacturer names in its MODEL slot, dropping the make
# deletes real data. `bus/factory-built` has models "Geely", "Yutong",
# "Zhongtong" — three genuine bus manufacturers parsed into the wrong column.
# The fix is a MOVE to the real make, never a drop.
#
# Usage:
#   VDB_CATALOG=~/GitHub/.vdb-worktrees/s2w-pipeline/build/out/catalog \
#     ruby scripts/find_duplicate_makes.rb
#
# Env: VDB_DATA_REPO (OWNERSHIP.yml), VDB_CATALOG (defaults to $VDB_DATA_REPO/catalog
# — which is the LAST RELEASE, so point it at a fresh build to see current state).
require "json"
require "yaml"
require "set"

ROOT = File.expand_path(ENV["VDB_DATA_REPO"] || "..", ENV["VDB_DATA_REPO"] ? "/" : __dir__)
CATALOG = File.expand_path(ENV["VDB_CATALOG"] || File.join(ROOT, "catalog"))
KINDS = %w[car van motorcycle moped truck bus].freeze

own = YAML.safe_load_file(File.join(ROOT, "OWNERSHIP.yml"))
SIDE = {}
(own["s2w"] || []).each { |m| SIDE[m] = "S2W" }
(own["s4w"] || []).each { |m| SIDE[m] = "S4W" }

def fold(s)
  s.downcase.unicode_normalize(:nfkd).gsub(/\p{Mn}+/, "")
   .gsub("oe", "o").gsub("ue", "u").gsub("ae", "a").gsub("ss", "s")
   .gsub(/[^a-z0-9]+/, "")
end

makes = {}   # [kind, id] => name
counts = Hash.new(0)
KINDS.each do |k|
  JSON.parse(File.read(File.join(CATALOG, k, "makes.json"))).each { |m| makes[[k, m["id"]]] = m["name"] }
  JSON.parse(File.read(File.join(CATALOG, k, "models.json"))).each { |m| counts[[k, m["make_id"]]] += 1 }
end

# Group by fold. Deliberately ACROSS kinds as well as within: a marque split
# between `man` (truck) and `m-a-n` (truck) is the common case, but a marque
# split across kinds by a spelling difference hides the same way.
groups = makes.group_by { |(_k, _id), name| fold(name) }
              .select { |_f, entries| entries.map { |(_k, id), _n| id }.uniq.size > 1 }

puts "#{groups.size} make-name collision groups (distinct ids folding to one name)\n\n"
rows = groups.map do |f, entries|
  by_id = entries.group_by { |(_k, id), _n| id }
  detail = by_id.map do |id, es|
    { id: id,
      name: es.first[1],
      kinds: es.map { |(k, _), _| k }.sort,
      records: es.sum { |(k, i), _| counts[[k, i]] },
      side: SIDE[id] || "?" }
  end.sort_by { |d| -d[:records] }
  { fold: f, ids: detail, total: detail.sum { |d| d[:records] } }
end.sort_by { |g| -g[:total] }

rows.each do |g|
  owners = g[:ids].map { |d| d[:side] }.uniq
  tag = owners.size > 1 ? "  << CROSS-OWNER: coordinate before merging (I-8) " : ""
  puts "#{g[:fold]}#{tag}"
  g[:ids].each do |d|
    puts format("    %-4s %-26s %-22s %4d models  [%s]", d[:side], d[:id], d[:name].inspect, d[:records], d[:kinds].join("+"))
  end
end

puts "\nNothing was written. Each group needs a verdict: MERGE (same marque —"
puts "makes/aliases.yml maps the raw string to the surviving display name),"
puts "DISTINCT (different marques that happen to fold together — record why),"
puts "or MOVE/DROP (one side is a registry placeholder, not a marque — and read"
puts "the trap note at the top of this file before dropping anything)."

# ---------------------------------------------------------------------------
# PASS 2 — legal-entity and conflated make ids.
#
# The fold above only catches ids that differ by punctuation/diacritics. It is
# blind to the much commoner shape: a registry filing the marque under its LEGAL
# ENTITY ("Fantic Motor" for Fantic, "Grecav Spa" for Grecav, "Winora-Staiger
# Gmbh" for Winora) or joining two marques into one string ("Opel-Vauxhall").
#
# READ THIS BEFORE ACTING ON THE OUTPUT — the suffix is NOT the verdict:
#   * `club-car` — Club Car IS the brand (golf carts). Stripping "-car" is wrong.
#   * `renault-trucks` — Renault Trucks is a distinct legal manufacturer under
#     Volvo Group with its own type approvals; for the truck kind it is arguably
#     the CORRECT make, not a suffix to strip.
#   * `iveco-bus`, `heuliez-bus`, `volta-trucks` — same question, per marque.
#   * `leyland-daf`, `austin-morris`, `steyr-puch`, `vdl-bova`, `tadano-faun`
#     were all REAL marques/companies. A joined name is not automatically a
#     conflation — several of these are the historically correct badge.
#   * `chevrolet-gmc` and `opel-vauxhall` most likely ARE registry conflations.
# Establishing which is which is approval-holder research (§7), not string work.
CORP = /-(motors?|motor-?(company|corp\w*)|vehicles?|automobiles?|automotive|cars?|gmbh|ag|kg|bv|nv|sa|spa|srl|ltd|limited|plc|inc|co|company|corp\w*|group|holding|industries|fahrzeugbau|carrosserie|coachwork|trucks?|bus(es)?|international)\z/
ids = makes.keys.map { |(_k, id)| id }.to_set
by_id = {}
makes.each { |(k, id), name| (by_id[id] ||= [name, Set.new])[1] << k }

suspects = by_id.filter_map do |id, (name, kinds)|
  recs = kinds.sum { |k| counts[[k, id]] }
  base = id.sub(CORP, "")
  parts = id.split("-")
  cls =
    if base != id && ids.include?(base)                                    then [:suffix_of_existing, base]
    elsif parts.size == 2 && parts.all? { |p| p.size > 2 && ids.include?(p) } then [:two_makes_joined, parts.join(" + ")]
    elsif id.match?(CORP)                                                  then [:corporate_suffix, nil]
    end
  next unless cls
  { cls: cls[0], id: id, name: name, hint: cls[1], records: recs, kinds: kinds.to_a.sort, side: SIDE[id] || "?" }
end

puts "\n\n#{suspects.size} legal-entity / conflated make ids (#{suspects.sum { |s| s[:records] }} records)\n"
suspects.group_by { |s| s[:cls] }.each do |cls, ss|
  puts "\n=== #{cls} (#{ss.size}) ==="
  ss.sort_by { |s| -s[:records] }.each do |s|
    puts format("  %-4s %-26s %-24s %-22s %3d models [%s]",
                s[:side], s[:id], s[:name].inspect, s[:hint] ? "-> #{s[:hint]}" : "", s[:records], s[:kinds].join("+"))
  end
end
puts "\nA `?` owner means the make is absent from OWNERSHIP.yml — it appeared in a"
puts "build after the split was cut, so NOBODY is assigned to it. Assign it before"
puts "working it, or two sides will both (or neither) pick it up."
