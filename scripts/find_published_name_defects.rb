# frozen_string_literal: true
#
# find_published_name_defects.rb — two defect classes that live in the PUBLISHED
# model name, and which the existing duplicate-finders cannot see.
#
# WHY THIS EXISTS, i.e. what the other tools miss. find_duplicate_spellings.rb
# compares RAW register strings and asks "do these raws mean one nameplate?".
# That is the right question for registry noise, but it is blind to defects the
# PIPELINE introduces after normalisation. Two of those turned up in batch B-001
# and neither is register noise:
#
#   1. ACRONYM CASING IN THE MODEL COLUMN. smart_case (pipeline/lib/normalizer)
#      title-cases any pure-alpha token that is not in overrides/styling.yml's
#      `acronyms` list. That list is curated, so a type code nobody has noticed
#      yet becomes a word: "CL" -> "Cl", "KS Super" -> "Ks Super", "SC-153" ->
#      "Sc-153", "RA9015" -> "Ra-9015". Registers uppercase EVERYTHING, so the
#      raw cannot settle it and a raw-vs-raw diff sees nothing wrong.
#
#   2. THE SEPARATOR/CASING TWIN. The same nameplate published twice under two
#      ids — "GTV 6" and "GTV6", "Lt-018" and "LT018", "Gold Star" and
#      "Goldstar". These are invisible to a raw comparison because the raws
#      genuinely differ, and they are NOT caught by an exact-name dedupe because
#      the published names differ too. Note the interaction with defect 1: the
#      spaced form gets title-cased ("Gtv 6") while the glued form keeps its caps
#      ("GTV6"), because "GTV6" is alphanumeric and smart_case leaves it alone.
#      So one nameplate ends up differing in BOTH separator and casing, which is
#      why it reads as two different models to every other check.
#
# THIS SCRIPT NOMINATES; IT DOES NOT DECIDE. Both checks are deliberately
# evidence-based rather than heuristic, but neither is a verdict:
#
#   * Check 1 calls a token suspect only when the catalog ITSELF spells the same
#     letters in caps elsewhere. No vowel-counting, no curated word list — if
#     "GTV6" exists then "Gtv" is wrong, and if nothing ever spells "VAN" then
#     "Van" is left alone. Common words still leak through (MAX, PRO, LE, BOY,
#     BOB are real nameplate words that also appear capitalised somewhere), so
#     the output is a worklist of TOKENS to adjudicate, not records to rewrite.
#
#   * Check 2 groups by name-with-separators-removed. It found a genuine false
#     positive worth remembering: KTM "E-XC" vs "Exc" are DIFFERENT machines —
#     the Freeride E-XC is electric, the EXC is the enduro line. Merging on
#     string shape alone would have destroyed a real model.
#
# Usage:  ruby scripts/find_published_name_defects.rb [--kinds motorcycle,moped]
#         VDB_CATALOG=/path/to/catalog  (default: ../vehiclesdb-pipeline/build/out/catalog)
#
# Parameterised the same way as find_duplicate_spellings.rb so either session can
# run it over its own half without editing the file.
require "json"

CATALOG = ENV["VDB_CATALOG"] ||
          File.expand_path("../vehiclesdb-pipeline/build/out/catalog", __dir__ + "/..")
ALL_KINDS = %w[car van motorcycle moped truck bus].freeze
kinds = ARGV.find { |a| a.start_with?("--kinds=") }&.split("=", 2)&.last&.split(",") || ALL_KINDS
kinds -= ["--kinds"]

records = []
kinds.each do |k|
  path = File.join(CATALOG, k, "models.json")
  unless File.exist?(path)
    warn "skip #{k}: no #{path} (run the pipeline first)"
    next
  end
  JSON.parse(File.read(path)).each { |m| records << m.merge("_kind" => k) }
end
abort "no records — check VDB_CATALOG=#{CATALOG}" if records.empty?
puts "scanned #{records.size} published records across #{kinds.join(',')}\n\n"

# ── check 1 ───────────────────────────────────────────────────────────────────
# Evidence base: every 2-4 letter ALL-CAPS run appearing anywhere in a published
# name, whether standalone ("GTV 6") or glued to digits ("GTV6"). Scanning for
# runs rather than tokens is what makes the glued forms count as evidence.
caps = Hash.new(0)
records.each { |r| r["name"].to_s.scan(/[A-Z]{2,4}/) { |m| caps[m] += 1 } }

suspects = Hash.new { |h, k| h[k] = [] }
records.each do |r|
  r["name"].to_s.split(%r{[\s\-/]}).each do |tok|
    next unless tok =~ /\A[A-Z][a-z]{1,3}\z/
    up = tok.upcase
    next unless caps[up] >= 2
    suspects[up] << r
  end
end
total = suspects.values.sum(&:size)
puts "== 1. title-cased tokens the catalog itself spells in CAPS elsewhere"
puts "   #{suspects.size} distinct tokens over #{total} records — adjudicate PER TOKEN, then"
puts "   pin the real ones in overrides/styling.yml `acronyms` (fixes them everywhere at once)\n\n"
suspects.sort_by { |_, g| -g.size }.each do |up, g|
  ex = g.first(3).map { |r| "#{r['make_id']}/#{r['name']}" }.join(", ")
  puts format("  %-6s %4d records (caps attested x%-3d)  %s", up, g.size, caps[up], ex)
end

# ── check 2 ───────────────────────────────────────────────────────────────────
puts "\n== 2. published names identical once separators are removed"
puts "   same make + same kind = almost certainly one nameplate under two ids.\n"
puts "   VERIFY EACH: E-XC vs EXC are different KTMs. Fix via renames.yml (fold the"
puts "   loser into the winner) PLUS a former_ids alias, or the no-vanish gate fails.\n\n"
groups = records.group_by { |r| [r["make_id"], r["_kind"], r["name"].downcase.gsub(/[^a-z0-9]/, "")] }
                .select { |_, g| g.size > 1 }
groups.sort_by { |(mk, k, _), _| [k, mk] }.each do |(mk, k, _), g|
  flag = g.map { |r| r["name"].gsub(/[^A-Za-z0-9]/, "") }.uniq.size > 1 ? " [casing differs too]" : ""
  puts format("  %-11s %-16s %s%s", k, mk, g.map { |r| "#{r['name'].inspect} (#{r['id']})" }.join("  ==  "), flag)
end
puts "\n  #{groups.size} groups, #{groups.values.sum(&:size)} records"
