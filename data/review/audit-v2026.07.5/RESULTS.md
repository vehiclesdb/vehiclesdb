# Baseline audit round — 4W half, v2026.07.5 (gate A2, PRD-FIVE-NINES §2)

*Round completed 2026-07-26. Sample: 400 records (seeded stratified draw,
`SAMPLE-s4w.yml`), 2,624 claims. Four researcher agents (100 records each),
four INDEPENDENT verifier agents (researcher ≠ verifier; every defective
verdict re-derived evidence-blind; all unverifiables retried; 25 corrects
spot-checked per slice). Ledgers + verification files beside this document.
Unverifiable counts AGAINST the clean rate throughout (conservative bound).*

## The number

**Claim-level clean rate: 83.23%** — 2,184 correct / 412 defective /
28 unverifiable of 2,624 claims. **Defect+unverifiable rate 16.77%,
95% CI 15.39%–18.25%** (Wilson). Per slice (verifier-adjusted):
84.15% · 88.45% · 80.31% · 79.42% — four independent researcher/verifier
pairs landing in one band is itself evidence the instrument measures
something real.

| claim type | clean rate | note |
|---|---|---|
| availability (1,024 claims) | **≈99.5%** | verified against the registers themselves (streamed full FI/UA/ES pulls, live RDW, all cached artifacts); slice 4's only defect OVERTURNED on re-derivation |
| kind | ~97% | source-forced-kind class found (below) |
| make | ~96% | converter/coachbuilder class dominates |
| name | ~62–75% by slice | the damage: truncation stubs, casing, marque-truth |
| id-canonical | ~55–65% by slice | the damage: family stubs shadowing siblings, trim-ids, spelling twins outside detector fold-scope |

## What adversarial verification did to the numbers

- **Defect verdicts held: ~96% confirmed** (399 of ~415 reviewed confirmed
  or reclassified-still-defective; 4 overturned to correct, 5 to
  unverifiable). The verdicts were right; some evidence lines were not
  (two citations named things that don't exist — evidence hygiene is now a
  protocol rule).
- **Classification did NOT hold: 44 class labels moved** (13/2/13/16 per
  slice). D6 "duplicate" was a catch-all absorbing what is really D8
  (trim-of-nameplate) and D5/D11 shapes. **A fix program driven off
  researcher labels would apply the wrong remedy ~1 time in 9.** RESULTS
  therefore reports class-as-verified; the taxonomy gets the new classes
  below and the audit protocol now requires the verifier to confirm CLASS,
  not just defectiveness.
- **Researcher miss rate on sampled corrects: 7/100 = 7%** (per-slice 1/25,
  1/25, 4/25, 1/25; pooled 95% CI ≈ 2.9%–13.9%). The audit's own error
  rate — published, per §5.2's certified-but-defective discipline. The
  misses share one shape: comparing against ONE candidate twin when
  several are live.
- **22 of 26 unverifiables fell to exactly one more route** (a different
  domain, another language wiki, a file already on disk). The conservative
  bound was over-paid. Protocol v1.1: `unverifiable` requires TWO distinct
  failed routes, named.
- **One protocol ambiguity moved verdicts**: whether id-canonicality is
  symmetric (both members of a duplicate pair defective) or lands on the
  non-canonical member. v1.1: the DEFECT is symmetric (the pair is the
  defect); the FIX-attribution column names the record that should retire.
  RESULTS counts pairs once.

## Defective-at-tag, fixed-pending-publish

23 sampled-adjacent ids are defective in the v2026.07.5 artifact and
already fixed in merged overrides (the release is one curation cycle behind
its own repo — the pending-publish window, verified against a fresh build:
all 23 dead there). They are counted DEFECTIVE here — the .5 consumer sees
them — with the fix status recorded. The next release cures them at zero
additional cost.

## New defect classes (entering PRD-QUALITY §4 with detector specs — I-15)

1. **Truncation/family stubs** (the single largest generator): a numbered
   nameplate truncated at its first space or by VARIANT_SUFFIXES/series
   collapse publishes as a stub that shadows properly-catalogued siblings —
   `bus/setra/s` (96 raw strings pooled), `car/bmw/z-reihe` (7,143
   registrations on a register GROUP label), `car/bmw/i`, `bus/volvo/b`,
   `truck/ford/f` (which swallowed raw "F MAX"), `truck/scania-vabis/l`.
   Detector: single-token/single-letter ids whose token prefixes ≥2 live
   sibling ids in-make. The structural cure is the DEBT.md normalizer item.
2. **Connector-merged dual-market cells**: `JUMPER ODER RELAY`, `ou`, `/`,
   and bare-space joins — D13 was comma-only. Confirmed on 4 exemplars +
   the make axis (`Iveco / Igloocar`).
3. **Converter/coachbuilder brand-or-style as nameplate** (D5b): one model
   string under ≥2 unrelated chassis makes — `fiat/burstner`,
   `peugeot/bailey`, `Atego` under five truck makes.
4. **TAN poisoning**: `xrefs.tan` holds the literal `- (FMVSS)` on 35
   records across 3 kinds (source: fi_traficom's TAN column); and TAN
   overlap is NOT duplicate proof (platform sharing, framework
   generations) — NAMING §2's ranking needs the caveat. Conversely the
   clean TANs are a free duplicate oracle nothing consumes (it settled
   fiorino-qubo/qubo and CLEARED kgm/actyon-vs-ssangyong).
5. **Source-forced kind**: `us_fueleconomy.rb`/`ca_nrcan.rb` hardcode
   `kinds=[:car]` while shipping an unused class column — Suzuki Equator
   (a pickup) sits in car. Pipeline fix, one file each.
6. **Typo-splits invisible to NFKD folding**: `Transit Costum`/`Custom`,
   live `Spinter`/`Spriner`/`Srinter` beside Sprinter. Detector:
   edit-distance-1 sibling names in-make.
7. **Raw-layer folds** the published-name detector cannot see (Scania
   R142/R142H colliding in raws only).

## The headline record-level findings

`car/tesla/model-y` (decile 1, 13 countries) is shadowed by live
`car/tesla/y` — and verification made it STRONGER: RDW wheelbase clustering
positively identifies the bare-Y vehicles as Model Ys (289cm cluster,
n=55,598). The fix retires `tesla/y`. Head records are not presumed clean —
which is exactly why D1a certification exists.

## What this means for the five-nines program (the honest read)

The baseline is **not close to the target — as expected for a first honest
measurement**, and the texture is the good news: ~99.5% of availability
claims and ~96%+ of make/kind claims are already clean; the defect mass
concentrates in TWO structural generators (truncation stubs; trim/granularity
ids) plus casing families — all fixable at the generator, not per-record.
Sequencing consequence, adopted into the program: **D1a head certification
becomes fix-then-certify** — the Workstream B duplicate harvests and the
truncation-stub cure land first, then certification sweeps what remains.
Usage-weighted computation is deliberately deferred to the next round: this
round is the baseline that directs the fixes, not the claim.

## Protocol v1.1 amendments (applied to audit-PROTOCOL.md in this PR)

Two-route minimum before `unverifiable` · symmetric pair-defects with
fix-attribution · verifier confirms CLASS, not just defectiveness ·
evidence lines must name live artifacts (a cited id/file must exist) ·
multi-twin rule: canonicality checks enumerate ALL live candidate twins.
