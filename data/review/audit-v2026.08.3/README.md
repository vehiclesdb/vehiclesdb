# Audit round 2 — RUNBOOK (prepared; the round has NOT been run)

*Status as of 2026-09-05 15:45 UTC: the **instrument is built and proven
end-to-end**; the **round was not started** because v2026.08.3 had not been
released and a five-nines round may only measure a pinned build (protocol
v1.2 — auditing a moving target produced three disagreeing population figures
in the baseline round). Everything below is the state a successor needs. No
verdicts exist yet; nothing in this directory is a measurement.*

## What is ready

| artifact | what it is |
|---|---|
| `SCHEMA.md` | the ledger contract — machine-readable claim rows, so RESULTS/QUALITY are generated, not transcribed |
| `PROMPTS.md` | the exact researcher and verifier prompts, protocol v1.3, owner rules bound in |
| `defects-found.md` | what the dry run found (instrument defects — no data verdicts) |
| `../../../scripts/audit_aggregate.rb` | ledgers → claim rates, Clopper-Pearson intervals, three-strata bound, the audit's own error rates |
| `../../../scripts/gen_quality_dashboard.rb` | those numbers → `QUALITY.md`, generated and never hand-edited |

Both scripts self-test: `ruby scripts/audit_aggregate.rb --self-test` and
`ruby scripts/gen_quality_dashboard.rb --self-test`.

Deliberately NOT committed: `SAMPLE-*.yml` and the per-slice files. They were
drawn during preparation, but their `build_pin` points at a session-scoped
scratch path and the sample must be redrawn against the RELEASED build anyway.
A seeded sampler exists precisely so a sample is a command, not a file.

## Running the round, once "BUILD PINNED" exists

REL's BUILD PINNED line must carry: **pipeline SHA · data SHA · the `build/out`
path · whether `catalog/meta/decile-mass.json` is in it · the exact tag string**.

```sh
S=<scratch dir>;  BUILD=<the build/out path from BUILD PINNED>;  TAG=<the exact tag>

# 0. Sanity: --build= wants the dir CONTAINING catalog/, i.e. build/out, not build/
ls $BUILD/catalog/car/models.json $BUILD/catalog/meta/decile-mass.json

# 1. Draw the sample (seed = sha256(TAG); a tag typo silently draws a different sample)
cd ~/GitHub/.vdb-worktrees/aud-data
for h in s4w s2w; do ruby scripts/audit_sample.rb --tag=$TAG --half=$h --n=400 --build=$BUILD; done

# 2. Review packs for every sampled make, ONE invocation (corpus load amortises;
#    ~4 min for 5 makes, dominated by the load, ~271 makes for a 400/half round)
cd ~/GitHub/.vdb-worktrees/aud-pipeline
VDB_DATA_REPO=~/GitHub/.vdb-worktrees/aud-data \
VDB_CACHE_DIR=~/GitHub/vehiclesdb-pipeline/cache \
VDB_BUILD_DIR=$(dirname $BUILD) \
  ruby pipeline/tools/gen_review_pack.rb <every make in both SAMPLE files>

# 3. Slice MAKE-COHERENTLY into 4 batches per half, ~100 records each.
#    Make-coherent is not a nicety: the id-canonical check must enumerate ALL
#    live twins in-make, so splitting a make across slices breaks the multi-twin
#    rule that the baseline round's own misses came from violating.

# 4. Eight Opus agents: 4 researchers (effort high) + 4 verifiers (xhigh) per half.
#    researcher != verifier on every slice (I-11). Prompts: PROMPTS.md §1 and §2.
#    Agents must load web tools first: ToolSearch "select:WebFetch,WebSearch".
#    Tell every researcher to work HEAD FIRST (deciles 1-6 = 97.5% of mass);
#    unfinished work then lands in the tail, where it costs the bound ~nothing,
#    and is recorded honestly as unverifiable/not-attempted.

# 5. Aggregate and publish
ruby scripts/audit_aggregate.rb --tag=$TAG --half=s4w
ruby scripts/audit_aggregate.rb --tag=$TAG --half=s2w
ruby scripts/gen_quality_dashboard.rb --tag=$TAG --results=s4w   # numeric block for RESULTS.md
ruby scripts/gen_quality_dashboard.rb --tag=$TAG --results=s2w   # -> RESULTS-s2w.md
ruby scripts/gen_quality_dashboard.rb --tag=$TAG                 # rewrites QUALITY.md
ruby scripts/lint_review.rb                                      # see defects-found.md #2
```

## Sizing measured during preparation (regenerate; do not quote these)

A 400/half draw against a build from main on 2026-09-05 produced 2,763 claims
(s4w) and 2,556 (s2w) over 271 makes — the same order as the baseline round's
2,624 / 2,559, so the batch sizing in PROMPTS.md is calibrated.

## The one number a successor must re-read, not inherit

`PRD-FIVE-NINES §1.3.1` sizes the tail sample at **n ≈ 3,100** from
`d1-6 = 99.49%` of registration mass. That does not reproduce: three separate
artifacts (main's committed 2026.08.2, an Aug-18 build, and a build from main
on 2026-09-05) put `w_tail` at 3.51% / 2.52% / 2.52% — never 0.515% — which
implies **n ≈ 15,000**, ~5×. The protocol already says weights are read and
never asserted, so **read them from the audited build** and print the
arithmetic. See `defects-found.md` #3; it is an owner/S4W sizing call, not
something this lane should decide.
