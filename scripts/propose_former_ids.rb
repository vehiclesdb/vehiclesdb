#!/usr/bin/env ruby
# frozen_string_literal: true
#
# propose_former_ids.rb — propose overrides/models/former_ids.yml entries.
#
#   ruby scripts/propose_former_ids.rb <old dist/vehicles.csv> <new dist/vehicles.csv>
#
# ─── WHY THIS READS THE OVERRIDE LAYER AND NOT JUST AN ID DIFF ────────────────
#
# The first version inferred mappings from an id diff: take ids that vanished,
# look for a NEW id with a similar slug. That models a RENAME (old id disappears,
# new id appears) and is BLIND to a MERGE, where the old id folds into a target
# that ALREADY EXISTED in both builds — the target is never in the "added" set, so
# nothing is proposed.
#
# Merges are the common case. Real examples from the 2026-07-25 curation:
#
#   car/volvo/244     → car/volvo/240     (240 existed; 242/245 fold in too)
#   car/lexus/rx-450h → car/lexus/rx      (rx existed; 162 variants fold in)
#   car/jaguar/xjs    → car/jaguar/xj-s   (11 spellings fold to one)
#   car/mazda/3       → car/mazda/mazda3  (mazda3 existed)
#
# Slug-similarity compounded it: norm("244") != norm("240"), so even with the
# target in scope the old test rejected the pair. Net effect: a consumer holding
# volvo/244 gets a silent 404 — the exact failure former_ids exists to prevent —
# while the migration path sits one file away in renames.yml.
#
# So INTENT now comes from the override layer (every renames.yml / moves.yml entry
# is an explicit "this id becomes that id", authored with a reason and a source)
# and the id diff is demoted to VERIFIER. That inverts the failure mode: instead
# of silently under-covering, we loudly report intent that did NOT take effect —
# which is a dead override key, the same bug that
# pipeline/tests/test_override_key_reachability.rb hunts from the other side.
#
# Credit: gap found by adversarial cross-review (NEGOTIATION.md Turn 23).
#
# ─── SAFETY RULES (validate.rb re-asserts these at build time) ────────────────
#   1. Only alias an id that was ACTUALLY PUBLISHED (present in the old build). A
#      long-standing rename whose old id never shipped needs no alias.
#   2. Never alias an id that is STILL LIVE in the new build. car/audi/89 survives
#      (NL registers the B3 Audi 80 as "89") and merely lost bogus DE evidence to
#      car/audi/a3 — claiming it as a former id of the A3 would tell every
#      consumer that a live id is an alias of a different car.
#   3. The target must exist in the new build, or the override pointed at nothing.
#   4. Successor countries should be a SUPERSET of the old id's. Where a loss is
#      deliberate the authored entry carries `accepted_loss:`, so strictness stays
#      the default and the exception stays visible. PR #1 accepted three:
#      scania/irizar loses ua, iveco/wing ua, iveco/sunrise nl — the bodybuilder
#      canonicals do not carry those countries yet.
#
# ─── ACCUMULATION ────────────────────────────────────────────────────────────
# Output is a proposal to APPEND. former_ids.yml must accumulate across releases:
# a record corrected twice keeps BOTH old ids or the migration path decays after
# one month. NEVER overwrite the file with this script's output.

require "csv"
require "yaml"
require "set"

old_csv, new_csv = ARGV[0], ARGV[1]
abort "usage: propose_former_ids.rb <old dist/vehicles.csv> <new dist/vehicles.csv>" unless new_csv

ROOT = File.expand_path("..", __dir__)

# Must match VDB::Support.slugify exactly, or proposed ids won't be the ids the
# pipeline mints. Kept as a copy rather than a require because this script runs
# in the data repo, which has no dependency on the pipeline.
def slugify(str)
  str.to_s.downcase.unicode_normalize(:nfkd).gsub(/\p{Mn}+/, "")
     .gsub(/[^a-z0-9]+/, "-").gsub(/(\A-|-\z)/, "")
end

def load_build(path)
  CSV.read(path, headers: true).map(&:to_h).to_h { |r|
    ["#{r['kind']}/#{r['make_slug']}/#{r['model_slug']}",
     { countries: r["countries"].to_s.split("|").sort, name: r["model_name"],
       kind: r["kind"], make: r["make_slug"] }]
  }
end

def yaml_or_empty(rel)
  path = File.join(ROOT, rel)
  File.exist?(path) ? (YAML.safe_load_file(path, permitted_classes: [], aliases: false) || {}) : {}
end

old = load_build(old_csv)
new = load_build(new_csv)
existing = yaml_or_empty("overrides/models/former_ids.yml")

# ── INTENT: every override that turns one id into another ─────────────────────
# renames.yml is make-scoped and KIND-BLIND, so one entry can imply a mapping in
# several kinds. Enumerate the kinds the make actually appears in and let the
# verification stage discard the mappings that did not happen.
kinds_by_make = {}
old.merge(new).each_value { |v| (kinds_by_make[v[:make]] ||= []) << v[:kind] }
kinds_by_make.each_value(&:uniq!)

intents = []
yaml_or_empty("overrides/models/renames.yml").each do |make, map|
  next unless map.is_a?(Hash)
  mk = slugify(make)
  map.each do |from, to|
    next if to.nil?   # a drop has no successor — correctly gets no alias
    (kinds_by_make[mk] || []).each do |kind|
      intents << ["#{kind}/#{mk}/#{slugify(from)}", "#{kind}/#{mk}/#{slugify(to)}",
                  "renames.yml #{make}: #{from} -> #{to}", to.to_s]
    end
  end
end
yaml_or_empty("overrides/models/moves.yml").each do |from, to|
  f_make, f_model = from.to_s.split("|", 2)
  t_make, t_model = to.to_s.split("|", 2)
  next if f_model.nil? || t_model.nil?
  (kinds_by_make[slugify(f_make)] || []).each do |kind|
    intents << ["#{kind}/#{slugify(f_make)}/#{slugify(f_model)}",
                "#{kind}/#{slugify(t_make)}/#{slugify(t_model)}",
                "moves.yml #{from} -> #{to}", t_model.to_s]
  end
end
intents.uniq!

# ── VERIFY each intent against the two builds ────────────────────────────────
emit, dead, problems = [], [], []
intents.each do |from, to, why, target_name|
  next unless old.key?(from)      # rule 1
  if new.key?(from)
    # The old id is still here. Two very different situations, and conflating them
    # produces false bug reports — it did, 3 of the first 9:
    #
    #   (a) the rename APPLIED but the slug did not change, because the fix was
    #       cosmetic. "Wagon-R" → "Wagon R", "Mulhacen 125" → "Mulhacén 125" and
    #       "Vespà GTS250" → "Vespa GTS250" all slugify identically. Nothing is
    #       wrong, the display name was the point, and no alias is needed.
    #   (b) the rename NEVER applied — the published name is still something the
    #       key does not match. THAT is a dead key.
    #
    # Distinguish on the published NAME, never on the id alone.
    published = new[from][:name].to_s
    dead << [from, to, why, published] unless published == target_name
    next
  end
  next unless new.key?(to)        # rule 3
  lost = old[from][:countries] - new[to][:countries]
  if lost.empty?                  # rule 4
    emit << [from, to, why, new[to]]
  else
    problems << [from, to, "evidence lost #{lost.join(',')} — author with " \
                           "accepted_loss: [#{lost.join(', ')}] if deliberate"]
  end
end

explained = intents.map(&:first).to_set
# Exclude ids ALREADY covered in former_ids.yml, or the signal drowns: a
# normalizer-driven correction (e.g. the 1,050 two-wheeler respacings) is not
# explained by any override entry, so it would be reported as "unexplained"
# forever even after it has been authored.
orphans = (old.keys - new.keys)
            .reject { |i| explained.include?(i) || existing.key?(i) }
new_entries = emit.reject { |from, _, _, _| existing.key?(from) }

puts "# ---- PROPOSED (#{new_entries.size} new; #{emit.size - new_entries.size} already in former_ids.yml) ----"
new_entries.sort.each do |from, to, why, tgt|
  puts format('%-46s %-46s # %s  [%s]', "\"#{from}\":", "\"#{to}\"", why, tgt[:countries].join(","))
end

unless dead.empty?
  puts "\n# ---- !! DEAD OVERRIDE KEYS (#{dead.size}) — the id did NOT change, so the"
  puts "# ---- curated fix is silently doing nothing. FIX THE KEY; do not alias it."
  dead.sort.each { |from, _, why, pub| puts "#   #{from}  published as #{pub.inspect}  <- #{why}" }
end
unless problems.empty?
  puts "\n# ---- NEEDS AUTHORING — evidence loss (#{problems.size}) ----"
  problems.sort.each { |from, to, why| puts "#   #{from} -> #{to}: #{why}" }
end
unless orphans.empty?
  puts "\n# ---- UNEXPLAINED DISAPPEARANCES (#{orphans.size}) — a normalizer change or"
  puts "# ---- an upstream deletion; the only cases needing human authoring."
  orphans.sort.first(30).each { |i| puts "#   #{i}   (was #{old[i][:name].inspect})" }
  puts "#   ... +#{orphans.size - 30} more" if orphans.size > 30
end

warn "intents=#{intents.size} proposed=#{new_entries.size} dead_keys=#{dead.size} " \
     "evidence_loss=#{problems.size} unexplained=#{orphans.size}"
