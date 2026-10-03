# Audit round 2 — `v2026.09.1`

*This directory is the round. The instrument was built on 2026-09-05 and
deliberately not run, because a five-nines round may only measure a **pinned
build** (protocol v1.2 rule 6) and `v2026.08.3` was never cut. `v2026.09.1` was
released 2026-09-12T13:58:38Z, so the round runs against it.*

## The pin — and why it is the released bytes, not a rebuild

```
tag           v2026.09.1
data SHA      a480b99   (the release commit; the tag)
pipeline SHA  96a798b   (what the publish run checked out — from its own log)
publish run   34696429435 / 34696893184 failed on a push race; 34697443600 landed
build_pin     a git worktree detached at v2026.09.1
              -> its catalog/ IS the released artifact, 16,046,485 bytes
weights       catalog/meta/decile-mass.json, committed at the tag
```

**The pin is content-addressed even though `build_pin` is a local path.** Anyone
can reproduce it exactly:

```sh
git worktree add --detach /some/dir v2026.09.1     # this is the pin
```

`git diff --name-only ab7fe03 a480b99` is **outputs only** — `VERSION`,
`catalog/**`, `dist/**`, `manifest.json`, zero override files — so "data at the
tag" and "data the publish run built from" are the same build inputs.

**Why not a local rebuild?** Because it does not reproduce the release, and that
is measured, not assumed. Built frozen from the same data SHA and pipeline SHA
with the fleet-standard frozen cache (`slices/cmp_catalog.rb`):

| | released | frozen rebuild |
|---|---:|---:|
| records | 14,886 | 14,864 |
| only in the release | — | **23** |
| only in the rebuild | **1** | — |
| common records differing on ≥1 field | **13,876 (93.2%)** | |

`popularity` is a rank and churns catalog-wide from any count change; `xrefs`
carries rolling-window type approvals; `availability` follows the corpus. None
of that is a bug — it is why **a release is verified by reading the shipped
bytes, not by rebuilding it.** See `defects-found-round.md` A1.

## The sample

Seed is `sha256(tag)`, so the draw is a command, not a file.

```sh
ruby scripts/audit_sample.rb --tag=v2026.09.1 --half=s4w --n=400 --build=<the pin>
ruby scripts/audit_sample.rb --tag=v2026.09.1 --half=s2w --n=400 --build=<the pin>
```

- **`SAMPLE-<half>.yml` is the registered n=400 stratified draw** — strata are
  `kind × decile-band(1-3|4-6|7-10|none) × make-size`, floors honoured exactly
  at this n.
- **`slices/SAMPLE-<half>-200.yml` is the audited n=200 draw**, and the round
  audits it first.

**The extension 200 → 400 is honest by construction, and that was pre-registered
and then measured.** The sampler seeds each stratum's RNG from
`sha256(tag)|stratum` and takes `.first(alloc)` of one fixed shuffle, so `n`
changes only the allocation. Measured on both halves: **`subset=true`, zero
strata shrank** — the n=200 draw is a per-stratum *prefix* of the n=400 draw. So
the second 200 are the records the same seed had already ranked next, not a
fresh draw taken after looking at the first.

One caveat the runbook did not previously state, recorded because it is real:
at n=200 the **s4w** half is below the sampler's stratum-floor total (279), so
floors scale down proportionally and the draw is *less* proportional to
population than the n=400 draw. The s2w half at n=200 is above its floor total
and unaffected. Allocation tables for all four draws are in `slices/alloc-*.txt`.

## Slicing

`slices/slice-<half>-b<N>.yml`, four per half, ~50 records each,
**make-coherent** and head-first ordered.

Make-coherence is not a nicety: the id-canonical check must enumerate ALL live
twins in-make, so a make split across two slices recreates the single-twin
comparison that produced the baseline round's own misses. The slicer's atom is
therefore the `(kind, make)` group, never the record.

`slices/slice-<half>-b<N>-records.json` carries, per sampled id, **the released
record itself** read from the pin — the claim under audit. The review packs
(`build/packs/<make>.md`, generated from the frozen rebuild) are *evidence*: raw
registry rows, in-make collision candidates, curation lookups, the
candidate-queue and dead-override-key sections. Where the two disagree, the pin
wins and the disagreement is itself recorded.

`slices/slice-<half>-b<N>-enriched.txt` names the ids that get the §6.2
enrichment sub-check — **43 of the 400**. Limitation, stated: there is no
released plus artifact for this tag (latest is `plus-2026.08.1`, 2026-08-01,
three public releases back — `PIPELINE_RELEASE_TOKEN` is still missing), so the
enrichment sub-check measures a **locally built** `catalog-plus`.

## Running it

```sh
# packs, ONE invocation (corpus load amortises across the batch)
cd ~/GitHub/.vdb-worktrees/aud-pipeline
VDB_DATA_REPO=<the pin> VDB_CACHE_DIR=~/GitHub/vehiclesdb-pipeline/cache \
VDB_BUILD_DIR=$PWD/build ruby pipeline/tools/gen_review_pack.rb <every make>

# researcher / verifier pairs, I-11: researcher != verifier on every slice
#   prompts: PROMPTS.md §1 and §2, plus ROUND-BRIEF.md (round-specific)

# aggregate and publish
ruby scripts/audit_aggregate.rb --tag=v2026.09.1 --half=s4w          # per-half: 2 terms, alpha 0.05
ruby scripts/audit_aggregate.rb --tag=v2026.09.1 --half=s2w
ruby scripts/gen_quality_dashboard.rb --tag=v2026.09.1 --results=s4w # -> RESULTS.md numeric block
ruby scripts/gen_quality_dashboard.rb --tag=v2026.09.1 --results=s2w # -> RESULTS-s2w.md
ruby scripts/gen_quality_dashboard.rb --tag=v2026.09.1               # -> QUALITY.md, alpha 0.025
```

**The alpha budget, now enforced rather than described.** A per-half bound
composes two one-sided stratum limits and takes `--alpha=0.05`. `QUALITY.md`
renders both halves — a **four-term** union composition — and therefore defaults
to `--alpha=0.025` (4 × 0.0125 = 0.05 ⇒ ≥95%); at the old default four terms
guaranteed only 90%. `alpha:` was a keyword argument nothing ever passed; it is
now threaded through `rates` → `stratified` → `run` and through **both** quantile
families (`z_for()` by bisection on `Math.erf`, so Wilson cannot keep its
hardcoded 1.96 while Clopper-Pearson moves), with a regression test against the
failure mode of a flag that is accepted, printed, and never reaches the
quantile.

## The weights, read and not asserted

From `catalog/meta/decile-mass.json` at the tag (shares sum to `1.00000000`
over 14,886 records):

| | d1-3 | d1-6 | `w_tail` | implied tail n |
|---|---:|---:|---:|---:|
| PRD-FIVE-NINES §1.3.1 as written | 82.98% | 99.49% | 0.515% | 3,100 |
| **released `v2026.09.1`** | **80.56%** | **98.94%** | **1.064%** | **6,387** |

| half | share of catalog mass | `w_head` | `w_tail` |
|---|---:|---:|---:|
| s4w | 91.839% | 0.991029 | 0.008971 |
| s2w | 8.161% | 0.970516 | 0.029484 |

`w_tail` moved 2.521% → 1.064% in seven days. It is a **moving** quantity, not a
stale constant, so the sizing belongs in the round as arithmetic
(`n ≥ 3·w_tail / 5e-6`) rather than as a number in the PRD. See
`defects-found-round.md` A4.

## Files

| file | what it is |
|---|---|
| `SCHEMA.md` | the ledger contract — machine-readable, normative |
| `PROMPTS.md` | the exact researcher (§1) and verifier (§2) prompts |
| `ROUND-BRIEF.md` | round-specific instructions handed to every agent |
| `SAMPLE-<half>.yml` | the registered n=400 draw |
| `slices/` | the audited n=200 prefix, make-coherent slices, the tooling, the allocation tables |
| `ledger/` | `researcher-<half>-b<N>.yml` + `verifier-<half>-b<N>.yml`, separate and unmerged |
| `RESULTS.md`, `RESULTS-s2w.md` | generated from the ledgers — never transcribed |
| `defects-found-round.md` | what THIS round found (Part A pre-round, Part B per-record) |
| `defects-found.md` | what the 2026-09-05 dry run found (history; status table in Part C) |
