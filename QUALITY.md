# QUALITY — the public dashboard (PRD-FIVE-NINES §8)

*Updated per audit round and per release. Generated context: this file
states measured numbers with their intervals and the program's honest
status. It never states more than the measurement supports — the caveats
are part of the product.*

## Status: INSTRUMENTED · BASELINE MEASURED · FIX PROGRAM DIRECTED

| | |
|---|---|
| Program | PRD-FIVE-NINES.md (target: usage-weighted P(defective\|touched) ≤ 1e-5) |
| Instrument | seeded stratified audit (`scripts/audit_sample.rb`), researcher≠verifier, unverifiable-counts-against |
| Latest round | **baseline, v2026.07.5, BOTH halves** — 400 records / half, 4 independent researcher+verifier pairs each |

## Measured — 4W half (car/van/truck/bus), baseline round, 2026-07-26

- **Claim-level clean rate: 83.23%** (defect+unverifiable **16.77%**,
  95% CI **15.39%–18.25%**). Full breakdown, methods, and every ledger:
  `data/review/audit-v2026.07.5/RESULTS.md`.
- **Availability claims ≈99.5% clean** — verified against the registers
  themselves. Make ~96%, kind ~97%. The defect mass is names and
  id-canonicality, concentrated in two structural generators (truncation
  stubs; trim-granularity ids) now being fixed at the generator.
- **Both generators have since been attacked at scale (2026-07-26,
  post-baseline)**: the truncation-stub fix retired 36 stubs and
  recovered ~370 real models; the trim-granularity fold wave measured
  seven common makes (35–53% of their ids were trims/codes, not models —
  per-make dossiers in the pipeline repo, `aux/research/trims-2026-07/`)
  and folded ~690 records onto their real nameplates with **zero
  availability evidence lost** (verified per fold, source drift
  adjudicated against pristine builds) and every retired string preserved
  as alias + typed variant. These fixes land AFTER the baseline above —
  the next audit round measures their effect; this dashboard does not
  claim it in advance.
- **The audit's own error rates, published**: researcher miss rate on
  spot-checked corrects 7% (CI 2.9–13.9%); defect-verdict confirmation
  under adversarial re-derivation ~96%; classification labels moved in
  ~10% of defects (protocol amended — verifiers now confirm class).
## Measured — 2W half (motorcycle/moped), baseline round, 2026-07-26

- **Conservative clean rate: 80.6%** (2,063/2,559 claims, every
  `unverifiable` counted against). **Do not quote the aggregate without
  its per-claim table** — it blends an unbiased measurement with a biased
  one: `data/review/audit-v2026.07.5/RESULTS-s2w.md`.
- **The headline is identity, not naming: 25.0% id-canonical defect rate**
  (100/400, unbiased, full sample). The existing duplicate detector
  returns zero groups for this half — it is structurally blind to
  token-presence/order duplicates. A new detector class (token-subset /
  permutation, 312 groups) entered the taxonomy as a worklist.
- **The name row is a bound, not an estimate**: only 158/400 name claims
  were attempted, and coverage skews toward records that already looked
  wrong. No name defect rate is published for this half.
- **Availability: 952/953 ≈99.9% clean** — re-derived from raw registers
  twice by independent implementations. A targeted census of the one
  structural exposure (rename-resolved rows) found 3 fabricated
  country-claims in 17,553 catalog-wide (0.017%).
- **Known limitation, both halves**: this round measured a build newer
  than its tag (~100 display names differ); the sampler now pins the
  build (`--build=`, protocol v1.2). No usage-weighted figure is
  published for either half until a round runs against a build carrying
  `catalog/meta/decile-mass.json`.

## What we will not claim (verbatim from the PRD)

Not uniform per-record five nines; not correctness of upstream registers
(availability claims assert what the register said, verified against the
register); not completeness (coverage is tracked separately and never
blended into defect rates). The five-nines figure, when published, will be
a 95% upper bound built from an exhaustively certified head + detector-held
zeros + a bounded sampled tail — the construction is in PRD-FIVE-NINES §1.3
and every number in it is recomputable from published artifacts
(`catalog/meta/decile-mass.json` + the audit ledgers).

## Detector suite (held at zero in CI, every build)

duplicate-spellings · casing-contradictions · corporate-strings ·
published-name-defects (with recorded verdicts) · curation lint (direction
wars, chains, shapes) · reachability · id-contract gates 1–7 + publication
hysteresis · enrich lint (incl. duplicate-insurance sweep). Seven NEW
classes from the baseline round are entering the taxonomy with detector
specs (RESULTS.md §New-classes; DEBT.md carries the build list).
