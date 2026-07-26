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
| Latest round | **baseline, v2026.07.5, 4W half** — 400 records / 2,624 claims / 4 independent researcher+verifier pairs |

## Measured (baseline round, 2026-07-26)

- **Claim-level clean rate: 83.23%** (defect+unverifiable **16.77%**,
  95% CI **15.39%–18.25%**). Full breakdown, methods, and every ledger:
  `data/review/audit-v2026.07.5/RESULTS.md`.
- **Availability claims ≈99.5% clean** — verified against the registers
  themselves. Make ~96%, kind ~97%. The defect mass is names and
  id-canonicality, concentrated in two structural generators (truncation
  stubs; trim-granularity ids) now being fixed at the generator.
- **The audit's own error rates, published**: researcher miss rate on
  spot-checked corrects 7% (CI 2.9–13.9%); defect-verdict confirmation
  under adversarial re-derivation ~96%; classification labels moved in
  ~10% of defects (protocol amended — verifiers now confirm class).
- 2W half: sample pinned (`SAMPLE-s2w.yml`), round pending.

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
