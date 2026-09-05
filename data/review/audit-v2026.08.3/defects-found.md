# Defects found — audit round 2 preparation

*The audit FINDS; it does not fix (invariant I-15: a new class needs a taxonomy
entry and a detector spec before any scaled fixing). Everything below was found
while proving the instrument end-to-end on 2026-09-05, **before** any record was
audited. **There are no data verdicts here** — the round has not been run. These
are defects in the measuring apparatus and its documentation, which is exactly
what a dry run is for.*

| # | class | severity | owning lane |
|---|---|---|---|
| 1 | tooling/docs — `--build=` path shape | note | AUD (fixed by documenting) |
| 2 | gate blind spot — `lint_review` cannot see audit ledgers | **should-fix** | REL (#292 CI wiring) |
| 3 | spec staleness — §1.3.1's tail sizing does not reproduce | **owner call** | owner / S4W |
| 4 | release mechanics — tag string is clock-derived | **blocking for AUD** | REL |
| 5 | method blind spot — frozen builds cannot see xref-window expiry | should-fix | REL (runbook) + all lanes |

---

**1. `audit_sample.rb --build=` takes the directory that CONTAINS `catalog/`.**
Passing `build/` (the natural reading, and what the flag's own help text
suggests) aborts with `missing …/build/catalog/car/models.json`. The correct
argument is `build/out`. Evidence: both halves aborted on `--build=<dir>` and
succeeded on `--build=<dir>/out`. No code change proposed — the flag's
behaviour is defensible — but every BUILD PINNED line should name the
`build/out` path, and the runbook now says so.

**2. `scripts/lint_review.rb` cannot see an audit ledger at all.**
It globs `data/review/*.yml` — top level only — and additionally rejects
basenames starting with `_` and `batches.yml`. Audit ledgers live one directory
down, in `data/review/audit-<tag>/`. Measured on a current checkout: **73
per-make ledgers matched, zero files from `audit-v2026.07.5/`**. So "the audit
ledger passes `lint_review`" has been **vacuously true since the baseline
round** — the baseline's eight ledger/verify files were never validated by it,
and a round-2 ledger would be equally invisible.
*Consequence for REL's #292:* wiring `lint_review` into CI as-is gates the
per-make ledgers and nothing an audit round produces. *Not fixed here:* it is a
change to a CI-gating script during a release window, and it is REL's call
whether it rides #292 or a separate PR. Round 2's ledgers are instead validated
against the §5.1 schema by `scripts/audit_aggregate.rb`, which asserts I-11
(researcher ≠ verifier, verifier signed) and refuses to publish a rate without
it.

**3. PRD-FIVE-NINES §1.3.1's `n ≈ 3,100` no longer follows from the published
weights.** §1.3.1 resolves the program's sizing decision by measurement —
"certify through decile 6 ⇒ `w_tail` = 0.51% ⇒ n ≈ 3,100" — reading
`d1-6 = 99.49%` from the first emission of `catalog/meta/decile-mass.json`
(pipeline #40, 2026-07-26). Re-read from three artifacts:

| artifact | d1-3 | d1-6 | w_tail | implied tail n |
|---|---:|---:|---:|---:|
| §1.3.1 as written | 82.98% | 99.49% | 0.515% | 3,100 |
| main's committed artifact (2026.08.2) | 79.60% | 96.49% | 3.514% | 21,086 |
| a build from main, 2026-09-05 | 79.48% | 97.48% | 2.521% | 15,127 |

All three sum to 1.000000 and are self-consistent; this is not a parse error.
The mechanism is legible: the fold programme took the catalog 16,829 → ~13,936
records and `global_decile` is a *mean of per-country rank deciles*, so band
membership churns under record churn — the instability the Turn 137 ruling
documented when it forbade `global_decile` as a per-record certification
filter. **The target (§1.2) is owner-set and is not in question; the sizing line
under it is stale by ~5×.** Two honest options: (a) re-run §1.3.1's arithmetic
against each round's own artifact and accept the larger n, or (b) certify deeper
than d6 until `w_tail` falls back under ~0.5%. Filed, not decided.

**4. The release version is derived from the clock, so the tag AUD must seed
with is currently ambiguous.** `pipeline/run.rb:40` `next_free_version` =
`Time.now.utc.strftime("%Y.%m")` + first free patch. A build cut on 2026-09-05
without `VDB_VERSION` stamps **`2026.09.0`**; the owner's order (Aug 21) said
"cut 2026.08.3". This is blocking for this lane rather than cosmetic: **the
audit sampler's seed is `sha256(tag)`**, so the tag string decides which 400
records are drawn, and a round seeded `v2026.08.3` against a build tagged
`v2026.09.0` is not reproducible from its own tag — which is precisely the
baseline round's limitation 1, repeated. REL must name the exact tag string.

**5. A frozen build is structurally blind to the rolling-window expiry class.**
A full frozen build on current main (data `002f3dc`, pipeline `8c0dcb3`)
reported `validate: ALL GATES GREEN` and `13/13 pins verified`, including the
three kawasaki `id-contract (xref-loss)` gates that main's CI reports as
FAILING. This is **not** evidence that main is green: the folds are applied in
both (`kawasaki/z650abs`, `zx-12r`, `zx-6r` absent; `z650`, `ninja-zx-12r`,
`ninja-zx-6r` live), and the gate does not fire locally only because a frozen
cache still holds the type approvals that `lu_snca`'s rolling window has since
expired. The gate class is fresh-fetch-dependent by construction.
*Consequence:* the plan directs every lane to judge work by a frozen
control-vs-treatment build, and that method **cannot see this defect class at
all**. "My frozen build is green" is not evidence about it. Worth one line in
RELEASE-RUNBOOK.md and in any lane's PR that leans on a frozen control.

---

## Addendum — adversarial verification of the aggregator itself (2026-09-05)

*An independent Opus verifier (researcher ≠ verifier, applied to the instrument
rather than to data) attacked `scripts/audit_aggregate.rb`. It re-implemented
Clopper-Pearson and Wilson from scratch and compared on 79 (k,n) pairs. Findings
6–13 below are its; all blocking ones are FIXED in this branch, each with a
regression test that was mutation-checked (reverting the fix fails the suite).*

**Cleared.** The statistics are correct: max disagreement vs an independent
implementation **7.6e-15** (CP) and **4.7e-14** (Wilson); the interval's
defining property holds to 1e-13. And the composition question I flagged as
unresolved in the handoff is **answered YES** — `w_head·r_head_hi +
w_tail·r_tail_hi` IS a valid 95% bound, because each `cp_hi` is a *one-sided
97.5%* limit and two of them compose by the union bound to ≥95% (Monte Carlo
coverage 0.985). Composing two one-sided *95%* bounds would have guaranteed only
90% — the code's alpha choice was already the Bonferroni-correct one.

**6. BLOCKING (fixed) — the round's own prompt used a verdict vocabulary the
parser rejected.** `PROMPTS.md` told every researcher to write
`defective(<D-class>)` and `unverifiable/source-gap`. `tally` matched only the
bare words, so such a row incremented the denominator and **no bucket**: a slice
of genuine D6 defects would have published a **0.00% defect rate**, and the
`clean + defect == 1` identity this file's header calls "the point, not a
rounding coincidence" would silently break. Anti-conservative. *Fixed:*
`VERDICTS`/`CLAIM_TYPES`/`SUBTYPES` were dead constants and are now enforced on
load; unknown verdicts, missing `defect_class`, missing `unverifiable_subtype`,
and a `source-gap` without its two named failed routes are all hard errors.
`PROMPTS.md` now spells the three-field YAML form explicitly.

**7. BLOCKING (fixed) — the audit's own error rate was diluted ~5×.**
`audit_error_rates` put every verifier row over a researcher `correct` in the
denominator, including rows with a blank `final_verdict` — i.e. claims the
verifier never re-derived. A true 1-of-2 miss rate published as 1-of-10. This is
the number PRD §5.2 exists to keep honest. *Fixed:* the denominator is now
"claims the verifier actually re-derived", and `verifier_rows_blank` is reported
so silent under-filling is visible.

**8. BLOCKING (fixed) — an unsampled stratum published as defect-free.**
`clopper_pearson(0, 0)` returned upper bound `0.0`; with no samples the 95%
upper bound is `1.0`. A tail nobody sampled therefore contributed **zero** to
the weighted bound. Exactly the silent-truncation class §1.3.3 exists to
prevent. *Fixed* in both CP and Wilson.

**9. (fixed) — `claim_key` collisions silently discarded claims.** Joined on
`"|"`, so an id containing a pipe collided with a different (id, claim) pair;
`nil` and `""` country merged; and two enrichment runs on one record — which the
protocol explicitly requires re-deriving separately — collapsed to one. Worse,
a **cross-batch contradiction** (the same claim called `defective` by one slice
and `correct` by another) was resolved silently by filename sort order, when
RESULTS-s2w committed in writing that such disagreements are "NOT silently
resolved". *Fixed:* `\x00` separator, blank-country normalisation, a `run` field
in the key, and contradictions are now collected and reported.

**10. (fixed) — orphan verifier rows became phantom extra claims.** A one-letter
typo in a verifier row's id/claim/country made it match no researcher row, so it
became its *own* resolved claim — double-counting the underlying claim while
hiding the genuine overturn. *Fixed:* orphans are reported as problems.

**11. (fixed) — the published bound is now RECORD-level.** Two reasons. Units:
`w_head`/`w_tail` are registration-*mass* shares and mass attaches to records,
while PRD §1.2's target and §1.3.1's whole budget are per-record. Independence:
Clopper-Pearson assumes independent trials, but **claims cluster inside a
record** — a truncation stub fails `id` and drags `name`; a stale register pull
fails every availability claim at once. Simulated coverage of a nominal
one-sided 97.5% *claim-level* bound under realistic clustering is **78–86%**,
while the same construction on records (the actual sampling unit) holds its
level. *Fixed:* the bound is computed on `records_defective / records`; the
claim-level figure is retained beside it, explicitly labelled a diagnostic and
not a valid bound.

**12. (fixed) — every build-pin failure degraded silently.** Slices disagreeing
about `build_pin`, a pin not on disk, and ids absent from the pinned build all
produced `exit 0` with no bound and no complaint — reproducing the very
condition protocol v1.2 rule 6 was written for. *Fixed:* all three are reported.

**13. NOTE (open, for whoever publishes a catalog-wide figure) — the cross-half
alpha budget is unallocated.** A per-half bound already spends α=0.05 across two
strata; combining both halves is a **four-term** composition, which by the union
bound guarantees only 90%. CP's conservatism absorbs it empirically (measured
0.991) but that is slack, not a guarantee. Allocate α across all four terms
(`clopper_pearson(..., alpha: 0.025)` — the keyword exists) before publishing a
catalog-wide number.

**14. NOTE — RESULTS-s2w.md's per-claim "defect rate" column is `defective/n`,
while its own headline and this aggregator use the conservative
`(defective+unverifiable)/n`.** So id-canonical reads 25.0% there and would read
30.0% here. The aggregator matches the protocol; the discrepancy is in the
published document. Round 2's round-over-round comparison must say so, or the
rates will appear to move for reasons unrelated to data. (The 2W aggregate,
496/2559 = 19.38%, CP [17.87%, 20.97%], is now a second reproduction anchor in
the self-test.)
