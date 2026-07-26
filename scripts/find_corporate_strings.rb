# frozen_string_literal: true
#
# find_corporate_strings.rb — model names that are actually COMPANY NAMES.
#
# WHY THIS EXISTS. Registers have a model field and a make field, and clerks put
# the wrong thing in them. Three separate batches have now hit the same shape
# from different angles:
#
#   * B-001: `spyder-wheelz/rent-group-nederland-bv` — a rental operator's
#     corporate name in the MODEL column, 6,435 rows.
#   * B-001: `go-tulip-b-v` — a registrant's legal entity in the MAKE column
#     (the marque, SELANA, was in the model column). Moved.
#   * G23 sweep: `zundapp/werke` — raw `ZUENDAPP | ZUNDAPP WERKE`, i.e. the
#     manufacturer's own legal name. strip_make_prefix removed "ZUNDAPP" and
#     published the residue "Werke" as a nameplate.
#
# The third one is what motivated this script: while chasing it I found
# `BMW | BAYER.MOT.WERKE-BMW` and `FORD | FORD WERKE AG KOLN` in the same
# registers. Nobody had looked for the class, so nobody had found it.
#
# WHAT IT DOES. Scans published model names for corporate-form tokens — the
# legal-entity suffixes and words that appear in company names and essentially
# never in nameplates. Deliberately narrow: matching "Motors" or "Company"
# would drag in real nameplates, so the list is restricted to forms that are
# legally load-bearing (GmbH, AG, B.V., Ltd) or unambiguous in context (Werke,
# Fabrik, Industrie).
#
# WORKED FALSE POSITIVE, left in the output on purpose so the next reader sees
# what one looks like: `nissan/Nv` (bus AND truck). N.V. is the Dutch
# corporate form, but the raws are NV200 / NV400 — Nissan-s real commercial
# van line. Verified against the register before concluding, which is the
# whole point of the NEXT STEP note at the foot of the output.
# (Separately, that record publishes as "Nv" and should be "NV" — a
# model-column acronym-casing defect, a different worklist.)
#
# IT NOMINATES, IT DOES NOT DECIDE — the standing rule for this family of tools.
# A real counterexample already exists: Alfa Romeo's full name is "Anonima
# Lombarda Fabbrica Automobili" and a marque could legitimately badge something
# with a corporate word. Check each hit against the raws before acting; the
# published name tells you where to look, only the register tells you what to do.
#
# Usage:  ruby scripts/find_corporate_strings.rb
#         VDB_CATALOG=/path/to/catalog   (default: ../vehiclesdb-pipeline/build/out/catalog)
require "json"

CATALOG = ENV["VDB_CATALOG"] ||
          File.expand_path("../vehiclesdb-pipeline/build/out/catalog", __dir__ + "/..")
KINDS = %w[car van motorcycle moped truck bus].freeze

# Legal-entity forms and corporate words. Anchored to token boundaries so
# "Bv" inside a word cannot match. Kept SHORT on purpose — every addition
# trades recall for false positives, and this class is small and high-value.
# DELIBERATELY EXCLUDES `limited`, `ltd`, `inc`, `corp`, `plc`. Those are the
# obvious corporate forms and they are USELESS here, because they are also
# extremely common REAL nameplate words:
#   * "Limited" is a standard American trim level — Explorer Limited, Grand
#     Cherokee Limited, RAV4 Limited, Cruze Limited. 20+ genuine records.
#   * The Ford LTD is a real model, giving "Ltd Crown Victoria", "Ltd Landau",
#     "Ltd Wagon".
# A first cut of this script included them and they were ~35 of 66 hits, all
# false. Precision matters more than recall for a nominating tool: a list that
# is mostly noise does not get read, and this class is small enough that
# missing one is cheaper than burying it.
CORPORATE = %r{
  (?:\A|[\s.\-/])
  (?: gmbh | \bag\b | b\.?v\.? | n\.?v\.? | s\.?a\.?r\.?l
    | ohg | \bkg\b | a\.?g\.?
    | werke? | fabrik | industrie | maatschappij | handel
  )
  (?:\z|[\s.\-/])
}xi

records = []
KINDS.each do |k|
  path = File.join(CATALOG, k, "models.json")
  next warn("skip #{k}: no #{path}") unless File.exist?(path)
  JSON.parse(File.read(path)).each { |m| records << m.merge("_kind" => k) }
end
abort "no records — check VDB_CATALOG=#{CATALOG}" if records.empty?

hits = records.select { |r| r["name"].to_s.match?(CORPORATE) }
puts "scanned #{records.size} published records"
puts "model names carrying a corporate-form token: #{hits.size}\n\n"

hits.sort_by { |r| [r["_kind"], r["make_id"], r["name"]] }.each do |r|
  n = (r["availability"] || []).size
  puts format("  %-10s %-22s %-34s (%d registration source%s)",
              r["_kind"], r["make_id"], r["name"].inspect, n, n == 1 ? "" : "s")
end

puts <<~TAIL

  NEXT STEP FOR EACH HIT — do not skip it:
    grep the raw register strings for that make. The three known cases each
    needed a DIFFERENT disposition, and only the raw told you which:
      * marque in the model column  -> cross-make MOVE (go-tulip -> SELANA)
      * operator/registrant name    -> DEBT, no nameplate recoverable
                                       (spyder-wheelz)
      * maker's own legal name      -> REMOVAL, it is not a vehicle
                                       (zundapp: raw "ZUENDAPP | ZUNDAPP WERKE")
TAIL
