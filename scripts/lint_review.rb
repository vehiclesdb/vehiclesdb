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

    is_live = live[kind]&.include?(rest)
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

baseline_path = File.join(ROOT, "data/review/_coverage.yml")
baseline = (YAML.safe_load_file(baseline_path) rescue nil) || {}
coverage.each do |o, pct|
  prev = baseline[o].to_f
  if pct < prev
    fail! "coverage for #{o} DECREASED: #{prev}% → #{pct}% — verdicts may go stale (re-review) " \
          "but coverage on main may never silently drop (PRD §5.3)"
  end
end
if ARGV.include?("--update") && FAILURES.empty?
  File.write(baseline_path, "# GENERATED by lint_review.rb --update — the coverage floor (monotonicity baseline).\n" + coverage.to_yaml)
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
