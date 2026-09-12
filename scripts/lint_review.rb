#!/usr/bin/env ruby
# frozen_string_literal: true
#
# lint_review.rb — validates the VERIFICATION LEDGER (data/review/<make>.yml)
# and computes review coverage. PRD-QUALITY §5 is the spec; this file is the
# enforcement.
#
# The ledger is the receipt behind the claim "manually reviewed model-per-
# model". A verdict that cannot be trusted mechanically is worse than no
# verdict — it converts an unreviewed record into a falsely-reviewed one. So
# this lint is strict where it counts:
#
#   * closed verdict vocabulary; unknown verdicts fail
#   * EVERY verdict carries an evidence citation (a verdict without evidence is
#     an opinion) — OR `evidence_class: register-only` when the register is the
#     totality of available evidence (B4 pilot finding 3; tallied separately)
#   * researcher != verifier, always (I-11: the author never certifies their
#     own work — in the correction pass, not one of five major wrong
#     conclusions was caught by its author). The two-phase intermediate is
#     `status: awaiting_verification` + `verifier: null` — tolerated, excluded
#     from coverage (B4 pilot finding 1)
#   * verdicts must point at reality: `canonical`/`debt` need the id LIVE in
#     the catalog; `removed`/`moved` need the id GONE and covered by
#     former_ids/removals — a verdict claiming a fix that does not exist is
#     the silent-loss class this repo specializes in producing
#   * staleness: each ledger file records the raw fingerprint it was reviewed
#     against; when the pack generator reports a different fingerprint, the
#     make's verdicts are STALE and count as unreviewed until re-verified
#
# Coverage = dual-signed, non-stale verdicts / published records, per owner.
# The number may never decrease on main once nonzero (monotonicity is checked
# against data/review/_coverage.yml, updated by this script with --update).
#
# Usage:
#   ruby scripts/lint_review.rb              # validate + report coverage
#   ruby scripts/lint_review.rb --update     # also write _coverage.yml baseline
#   VDB_CATALOG=…/build/out/catalog …        # measure against a fresh build

require "yaml"
require "json"
require "set"
require "date"

ROOT = File.expand_path("..", __dir__)
CATALOG_DIR = ENV["VDB_CATALOG"] ? File.expand_path(ENV["VDB_CATALOG"]) : File.join(ROOT, "catalog")
KINDS = %w[car van motorcycle moped truck bus].freeze
VERDICTS = %w[canonical fixed debt removed moved stale].freeze
FAILURES = []
def fail!(msg) = FAILURES << msg

# ── load reality ─────────────────────────────────────────────────────────────
live = {}        # kind => Set of "make/slug"
by_make = Hash.new(0) # make_id => published record count (all kinds)
KINDS.each do |k|
  path = File.join(CATALOG_DIR, k, "models.json")
  next unless File.exist?(path)
  ids = JSON.parse(File.read(path)).map { |m| m["id"] }
  live[k] = ids.to_set
  ids.each { |id| by_make[id.split("/").first] += 1 }
end
former = (YAML.safe_load_file(File.join(ROOT, "overrides/models/former_ids.yml")) rescue nil) || {}
# former_ids has TWO authored shapes (flat string / nested {to:, accepted_loss:})
# — normalize at the boundary exactly like the pipeline gate does (pipeline#10
# fixed the same crash there; same lesson, same shape).
former = former.transform_values { |v| v.is_a?(Hash) ? v["to"] : v }.compact
# Alias TARGETS are ids guaranteed live in the NEXT build (the pipeline
# liveness gate enforces it) but possibly absent from the PUBLISHED catalog
# this lint measures between releases. A `fixed` verdict on a merge target
# is exactly that state — the fix is merged, the publish is pending (§16).
# Found by the B4 pilot verification: venti-50/ra9011/e-go-s4-new failed
# the live check against the repo catalog while being fully correct.
pending_publish = former.values.to_set
removals = (YAML.safe_load_file(File.join(ROOT, "overrides/models/removals.yml")) rescue nil) || {}
own = (YAML.safe_load_file(File.join(ROOT, "OWNERSHIP.yml")) rescue nil) || {}
owner_of = ((own["s4w"] || []).to_h { |m| [m, "s4w"] }).merge((own["s2w"] || []).to_h { |m| [m, "s2w"] })

# ── validate every ledger file ───────────────────────────────────────────────
reviewed = Hash.new(0) # owner => count of valid, non-stale, VERIFIED verdicts
reg_only = Hash.new(0) # owner => subset of `reviewed` whose evidence is register-only
awaiting_count = 0     # ledgers parked in awaiting_verification (visible, not counted)
# Everything in data/review/*.yml is a per-make ledger EXCEPT the dispatch
# board (batches.yml) and generated files (_-prefixed). Skip by name, don't
# pattern-guess — a make genuinely named "batches" cannot exist (no registry
# emits it), so the carve-out is safe.
ledgers = Dir[File.join(ROOT, "data/review", "*.yml")]
          .reject { |f| File.basename(f).start_with?("_") || File.basename(f) == "batches.yml" }
# LOUD SKIP (S2W Turn 72, after a silent no-op cost a wrong measurement): an
# unset VDB_PACKS makes the staleness check a no-op that reads IDENTICALLY to
# "nothing is stale" — say so, every run, so absence of STALE lines can never
# be mistaken for a staleness verdict.
puts "staleness check SKIPPED (VDB_PACKS unset) — fingerprints NOT compared" unless ENV["VDB_PACKS"]
ledgers.sort.each do |abs|
  rel = abs.sub("#{ROOT}/", "")
  doc = begin
    # Date is permitted because `reviewed_at: 2026-07-25` (unquoted) is the
    # natural way every ledger writes it, and Psych types a bare ISO date as
    # Date — without the permit the lint CRASHES on well-formed input instead
    # of linting it (found by the fixture self-test, first run).
    YAML.safe_load_file(abs, permitted_classes: [Date], aliases: false)
  rescue Psych::SyntaxError, Psych::DisallowedClass => e
    fail! "#{rel}: does not parse — #{e.message}"
    next
  end
  make = doc["make"].to_s
  if make.empty? || "#{make}.yml" != File.basename(abs)
    # Say WHICH form is wanted: "make" means the DISPLAY name everywhere else
    # in overrides/ (renames blocks are display-keyed), so a researcher writes
    # "IVA" here on reflex — the B4 pilot did exactly that (Turn 55 finding 2).
    fail! "#{rel}: `make` missing or mismatched with filename — expected the SLUG " \
          "(#{File.basename(abs, '.yml').inspect}), not the display name"
  end

  # Two-phase workflow (B4 pilot finding 1, the blocking one): a researched-
  # but-unverified ledger is a legitimate intermediate state — the researcher
  # MUST be able to ship without signing the verifier field themselves, or
  # I-11 becomes a fiction (single sessions would sign both). The contract:
  #   status: awaiting_verification  +  verifier: null   → tolerated by lint,
  #   but the make's verdicts are EXCLUDED from the coverage numerator (they
  #   are not verified, so they must not count — same treatment as stale).
  # Any other status with a missing verifier still fails.
  awaiting = doc["status"].to_s == "awaiting_verification"
  awaiting_count += 1 if awaiting
  required = awaiting ? %w[researcher reviewed_at raw_fingerprint] : %w[researcher verifier reviewed_at raw_fingerprint]
  required.each do |k|
    fail! "#{rel}: `#{k}` missing" if doc[k].to_s.empty?
  end
  if awaiting && !doc["verifier"].to_s.empty?
    fail! "#{rel}: status awaiting_verification but `verifier` is signed — pick one: a signed " \
          "ledger is past awaiting, an awaiting ledger must leave verifier null"
  end
  if doc["researcher"].to_s == doc["verifier"].to_s && !doc["researcher"].to_s.empty?
    fail! "#{rel}: researcher == verifier (#{doc['researcher'].inspect}) — the author never certifies " \
          "their own work (I-11). A second, independent agent must sign."
  end

  # Staleness (PRD §5.3): when pack fingerprints from a FRESH build are on
  # hand (VDB_PACKS=…/build/packs, written by pipeline/tools/gen_review_pack.rb),
  # a ledger whose raw_fingerprint no longer matches is STALE — the registry
  # started emitting different raw spellings after the review. Stale is NOT a
  # lint failure (nobody did anything wrong); the make's verdicts simply stop
  # counting toward coverage until re-verified. Without VDB_PACKS this check
  # is skipped — plain repo runs can't know the current raw surface.
  stale_make = false
  if ENV["VDB_PACKS"]
    fp_path = File.join(File.expand_path(ENV["VDB_PACKS"]), "#{make}.fingerprint")
    if File.exist?(fp_path) && File.read(fp_path).strip != doc["raw_fingerprint"].to_s.strip
      stale_make = true
      puts "STALE: #{rel} — raw fingerprint changed since review; verdicts excluded from coverage until re-verified"
    end
  end

  seen_ids = Set.new
  (doc["records"] || []).each do |r|
    id = r["id"].to_s
    verdict = r["verdict"].to_s
    label = "#{rel} → #{id}"
    fail! "#{label}: duplicate record entry" unless seen_ids.add?(id)
    kind, rest = id.split("/", 2)
    unless KINDS.include?(kind) && rest.to_s.include?("/")
      fail! "#{label}: id must be <kind>/<make>/<slug>"
      next
    end
    fail! "#{label}: unknown verdict #{verdict.inspect} (allowed: #{VERDICTS.join(', ')})" unless VERDICTS.include?(verdict)
    # Evidence classes (B4 pilot finding 3): for long-tail makes the register
    # IS the only evidence there is — RA9015-class models have no manufacturer
    # page, no press release, no archive. Forcing a URL there pushes the
    # researcher toward laundering a retailer listing into an "evidence" link,
    # which is worse than an honest statement of the ceiling. So
    #   evidence_class: register-only
    # is a sanctioned substitute for `evidence:` — it asserts "the registry
    # rows in the pack are the totality of available evidence, corroborated
    # across the raw spellings listed there". It gets its own coverage line
    # below so the honesty is visible, not buried.
    register_only = r["evidence_class"].to_s == "register-only"
    if r["evidence_class"] && !register_only
      fail! "#{label}: unknown evidence_class #{r['evidence_class'].inspect} (allowed: register-only)"
    end
    if r["evidence"].to_s.strip.empty? && !register_only && verdict != "stale"
      fail! "#{label}: verdict without an evidence citation is an opinion — add `evidence:` " \
            "(or `evidence_class: register-only` when the register is the totality of evidence)"
    end
    if %w[debt removed moved].include?(verdict) && r["note"].to_s.strip.empty?
      fail! "#{label}: #{verdict} requires a `note:` naming the blocker/mechanism"
    end

    is_live = live[kind]&.include?(rest) || pending_publish.include?(id)
    case verdict
    when "canonical", "fixed", "debt"
      fail! "#{label}: verdict #{verdict} but the id is NOT live in the catalog being measured — " \
            "either the record vanished since review (re-review) or the id is mistyped" unless is_live
    when "removed"
      fail! "#{label}: verdict removed but the id is STILL LIVE — the removal did not happen" if is_live
      unless removals.key?(id) || former.key?(id)
        fail! "#{label}: removed without a removals.yml entry or former_ids alias — a consumer holding " \
              "this id gets an undocumented 404 (I-5)"
      end
    when "moved"
      fail! "#{label}: verdict moved but the id is STILL LIVE" if is_live
      fail! "#{label}: moved without a former_ids alias — the migration path is missing" unless former.key?(id)
    when "stale"
      # ── THE MONOTONICITY RULE (owner ruling on data#292) ──────────────────
      #
      # `stale` is the ONE verdict that drops a record OUT of the coverage
      # numerator while leaving its row in place, so it is the only way to make
      # coverage fall without deleting anything. Whether that is legitimate
      # turns on exactly one fact: is the record still in the catalog?
      #
      #   id NOT live — the certified id LEFT the catalog. That decrements the
      #                 numerator AND the denominator, so it is a no-op against
      #                 the floor, not a regression. Firing here is what forced
      #                 the two dishonest moves #292 refused: delete the review
      #                 evidence, or re-certify a record nobody re-reviewed.
      #
      #   id IS live  — a certified verdict on a LIVE record was downgraded.
      #                 THAT is the loss this gate exists to catch, because the
      #                 alternative is coverage walked down one row at a time
      #                 with no trace.
      #
      # The escape hatch is an ADJUDICATED ACK — the same shape the delta gate
      # uses for its accepted losses. State the cause on the row and it passes;
      # a silent downgrade does not.
      if is_live && r["stale_ack"].to_s.strip.empty?
        fail! "#{label}: verdict downgraded to `stale` while the id is STILL LIVE — a numerator " \
              "loss NOT explained by catalog departure, which is precisely what the coverage " \
              "gate exists to catch. If the raw evidence genuinely changed and this record is " \
              "queued for re-review, say so on the row: `stale_ack: <cause + date>`. If the " \
              "record was demoted and has since RETURNED, reinstate the preserved verdict."
      end
    end

    # Only VALID, non-stale, VERIFIED verdicts count toward coverage — an
    # unknown verdict, a stale make, or an awaiting_verification ledger must
    # not inflate the number this lint exists to gate. Register-only evidence
    # counts (the verdict is verified against the ceiling of what exists) but
    # is tallied separately so the split stays visible.
    make_id = rest.split("/").first
    if VERDICTS.include?(verdict) && verdict != "stale" && !stale_make && !awaiting
      reviewed[owner_of[make_id] || "?"] += 1
      reg_only[owner_of[make_id] || "?"] += 1 if register_only
    end
  end
end

# ── coverage + monotonicity ──────────────────────────────────────────────────
published = Hash.new(0)
by_make.each { |mk, n| published[owner_of[mk] || "?"] += n }
coverage = {}
%w[s4w s2w].each do |o|
  coverage[o] = published[o].zero? ? 0.0 : (100.0 * reviewed[o] / published[o]).round(2)
end
total_pub = published.values.sum
total_rev = reviewed.values.sum
coverage["total"] = total_pub.zero? ? 0.0 : (100.0 * total_rev / total_pub).round(2)

# ── the floor: RECORDED, and no longer the thing that fires ──────────────────
#
# This used to `fail!` whenever a coverage RATIO fell. The owner's ruling on
# data#292 retired that rule, and the reasoning generalises past this file:
#
#   the floor asserted that a ratio may never fall, but the DENOMINATOR is the
#   catalog and the catalog legitimately moves.
#
# Four certified mutt ids were retired by correct curation and the ratio fell.
# Nothing had regressed: no verdict was withdrawn, no record lost a verdict
# without a reason. The only ways to get the number green again were to delete
# review evidence or to re-certify records nobody had re-reviewed — so a gate
# meant to protect honesty was manufacturing dishonesty.
#
# The gate now lives where the loss actually is, one screen up: a verdict
# downgraded to `stale` on a LIVE id fails, `removed`/`moved` on a live id
# already failed, and an id that left the catalog is a no-op. That is the
# owner's rule — NUMERATOR LOSS NOT EXPLAINED BY CATALOG DEPARTURE — enforced
# per record, where the explanation is actually available.
#
# The ratio is still computed, recorded and REPORTED when it moves, because
# "coverage fell and here is why" is information. It is not a gate.
baseline_path = File.join(ROOT, "data/review/_coverage.yml")
baseline = (YAML.safe_load_file(baseline_path) rescue nil) || {}
coverage.each do |o, pct|
  prev_entry = baseline[o]
  prev = prev_entry.is_a?(Hash) ? prev_entry["pct"].to_f : prev_entry.to_f
  next unless pct < prev
  prev_rev = prev_entry.is_a?(Hash) ? prev_entry["reviewed"] : nil
  prev_pub = prev_entry.is_a?(Hash) ? prev_entry["published"] : nil
  now_rev = (o == "total") ? total_rev : reviewed[o]
  now_pub = (o == "total") ? total_pub : published[o]
  detail =
    if prev_rev && prev_pub
      format("numerator %d → %d (%+d), denominator %d → %d (%+d)",
             prev_rev, now_rev, now_rev - prev_rev, prev_pub, now_pub, now_pub - prev_pub)
    else
      format("numerator now %d, denominator now %d (the recorded floor predates numerator tracking)",
             now_rev, now_pub)
    end
  puts "NOTE: coverage for #{o} fell #{prev}% → #{pct}% — #{detail}. NOT a failure: a ratio whose " \
       "denominator moved is not a regression. A numerator loss on a LIVE record fails per record " \
       "above. Run with --update to rebaseline once the cause is stated."
end

# The record carries the numerator and denominator, not just the ratio. A bare
# percentage cannot distinguish "four certified ids left the catalog" from "four
# verdicts were withdrawn", which is the distinction the whole ruling turns on.
if ARGV.include?("--update") && FAILURES.empty?
  stamped = coverage.to_h do |o, pct|
    [o, { "pct" => pct,
          "reviewed"  => ((o == "total") ? total_rev : reviewed[o]),
          "published" => ((o == "total") ? total_pub : published[o]) }]
  end
  File.write(baseline_path,
             "# GENERATED by lint_review.rb --update — the coverage RECORD.\n" \
             "# NOT a gate: see the monotonicity comment in scripts/lint_review.rb. The gate is\n" \
             "# per-record — a verdict downgraded on a LIVE id fails; an id that left the catalog\n" \
             "# is a no-op. `reviewed`/`published` are recorded so that a fall can be ATTRIBUTED.\n" +
             stamped.to_yaml)
end

puts format("review coverage: total %s%% (%d/%d) · s4w %s%% (%d/%d) · s2w %s%% (%d/%d) · " \
            "register-only %d · awaiting %d · ledgers %d",
            coverage["total"], total_rev, total_pub,
            coverage["s4w"], reviewed["s4w"], published["s4w"],
            coverage["s2w"], reviewed["s2w"], published["s2w"],
            reg_only.values.sum, awaiting_count, ledgers.size)

if FAILURES.any?
  FAILURES.each { |f| puts "LINT FAIL: #{f}" }
  exit 1
else
  puts "review lint: OK"
end
