#!/usr/bin/env ruby
# frozen_string_literal: true
#
# lint_schema_doc.rb — the published make records, manifest.json and SCHEMA.md
# stay in step, and every make's country of origin has a valid shape.
#
#   1. Every key on a make object in catalog/<kind>/makes.json and in the make
#      objects of dist/vehicles.json (except the nested `models`) is a row of
#      SCHEMA.md's *Make* table. A field the build starts emitting fails here
#      until it is documented (the growth contract is only a contract if the
#      document names every field).
#   2. SCHEMA.md's "Current versions" line names manifest.json's
#      `schema_version` and `dist_schema_version` (additive fields never move
#      them; the vehicles gem refuses an unknown dist schema_version).
#   3. Country of origin (SCHEMA.md *Country of origin*): `country` is an
#      assigned ISO 3166-1 alpha-2 code in lower case and always comes with a
#      `country_tier` in its vocabulary; `country_disputed` is 2+ distinct,
#      sorted codes and never sits beside `country`; one make has ONE origin
#      in every kind file and in vehicles.json.
#
# Stdlib only; runs in CI on every PR (lint.yml). Exit 1 on any failure.
# Run: ruby scripts/lint_schema_doc.rb [DATA_ROOT]   (default: this repo)
require "json"
require "set"

ROOT = File.expand_path(ARGV[0] || File.join(__dir__, ".."))

# The officially ASSIGNED ISO 3166-1 alpha-2 codes (249). Withdrawn codes of
# former states (CS, SU, YU, DD) and UK are deliberately absent: a make
# founded in a former state carries the present-day state of its founding
# seat (SCHEMA.md *Country of origin*). Same list as the pipeline's
# pipeline/lib/iso3166.rb.
ISO = %w[
  AD AE AF AG AI AL AM AO AQ AR AS AT AU AW AX AZ BA BB BD BE BF BG BH BI BJ BL BM BN BO BQ BR BS BT BV BW BY BZ
  CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CW CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM FO FR
  GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT JE JM JO JP
  KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT
  MU MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY QA RE RO RS RU RW
  SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR SS ST SV SX SY SZ TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG
  UM US UY UZ VA VC VE VG VI VN VU WF WS YE YT ZA ZM ZW
].map(&:downcase).to_set.freeze
ORIGIN_TIERS = %w[manufacturer regulator archive].freeze

fails = []
schema = File.read(File.join(ROOT, "SCHEMA.md"))

# ── 1. the Make table names every published make key ─────────────────────
make_section = schema[/^## Make\n(.*?)^## /m, 1] or abort "lint_schema_doc: SCHEMA.md has no '## Make' section"
documented = make_section.scan(/^\| `([a-z_]+)` \|/).flatten.to_set
manifest = JSON.parse(File.read(File.join(ROOT, "manifest.json")))
makes_by_file = {}
manifest.fetch("catalog").each do |kind, paths|
  makes_by_file["catalog/#{kind}"] = JSON.parse(File.read(File.join(ROOT, paths.fetch("makes"))))
end
dist_path = File.join(ROOT, "dist/vehicles.json")
makes_by_file["dist"] = JSON.parse(File.read(dist_path))["makes"].map { |m| m.except("models").merge("id" => m["slug"]) } if File.exist?(dist_path)
keys = makes_by_file.values.flatten.flat_map(&:keys).to_set
(keys - documented).sort.each { |k| fails << "make key `#{k}` is published but has no row in SCHEMA.md's Make table" }

# ── 2. versions ──────────────────────────────────────────────────────────
want = "**catalog `schema_version: #{manifest['schema_version']}`** · **dist `schema_version: #{manifest['dist_schema_version']}`**"
fails << "SCHEMA.md 'Current versions' does not say #{want} (manifest.json)" unless schema.include?(want)

# ── 3. country of origin ─────────────────────────────────────────────────
origin = Hash.new { |h, k| h[k] = Set.new }
makes_by_file.each do |file, makes|
  makes.each do |mk|
    w = "#{file} make #{mk['id']}"
    c, t, d = mk.values_at("country", "country_tier", "country_disputed")
    if mk.key?("country")
      fails << "#{w}: country #{c.inspect} is not an assigned ISO 3166-1 alpha-2 code in lower case" unless c.is_a?(String) && c.match?(/\A[a-z]{2}\z/) && ISO.include?(c)
      fails << "#{w}: country_tier #{t.inspect} not in #{ORIGIN_TIERS.join('|')}" unless ORIGIN_TIERS.include?(t)
    elsif mk.key?("country_tier")
      fails << "#{w}: country_tier without a country"
    end
    if mk.key?("country_disputed")
      fails << "#{w}: country_disputed and country exclude each other" if mk.key?("country")
      ok = d.is_a?(Array) && d.size >= 2 && d.all? { |x| x.is_a?(String) && ISO.include?(x) } && d.uniq == d && d == d.sort
      fails << "#{w}: country_disputed #{d.inspect} must be 2+ distinct sorted lower-case ISO 3166-1 alpha-2 codes" unless ok
    end
    origin[mk["id"]] << [c, t, d]
  end
end
origin.each { |id, s| fails << "make #{id}: a different country of origin in different files" if s.size > 1 }

fails.each { |f| puts "LINT FAIL: #{f}" }
n = origin.count { |_, s| s.first.first }
puts fails.empty? ? "schema-doc lint: OK (#{keys.size} make keys documented; #{n} makes with a country of origin, " \
                    "#{origin.count { |_, s| s.first[2] }} disputed)" : "\n#{fails.size} failure(s)."
exit(fails.empty? ? 0 : 1)
