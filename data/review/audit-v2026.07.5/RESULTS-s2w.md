# A2 baseline audit — S2W half (motorcycle + moped)

*PRD-FIVE-NINES Workstream A2, tag `v2026.07.5`, n=400 stratified sample.
Researcher pass by four independent agents; every batch re-derived by a separate
verifier agent (invariant I-11). Ledger under `ledger/`. 2026-07-26.*

---

## The number, and how to read it

**Conservative clean rate: 2,063 / 2,559 claims = 80.6%**, with every
`unverifiable` counted against, as `audit-PROTOCOL.md` requires.

**Do not quote that figure without the row below it.** It is dominated by one
claim type whose coverage is 40%, and it mixes an unbiased measurement with a
biased one. The per-claim table is the result; the aggregate is a bound.

| claim | correct | defective | unverifiable | total | defect rate | basis |
|---|---:|---:|---:|---:|---:|---|
| **id-canonical** | 280 | **100** | 20 | 400 | **25.0%** | unbiased, full sample |
| name-marque-true | 50 | 108 | 242 | 400 | *see below* | **biased, 40% coverage** |
| make-correct | 381 | 5 | 14 | 400 | 1.3% | unbiased, full sample |
| kind-correct | 396 | 3 | 1 | 400 | 0.8% | unbiased, full sample |
| availability | 952 | 1 | 0 | 953 | **0.1%** | unbiased, first-hand from raw |
| enrichment | 4 | 1 | 1 | 6 | — | n too small |

### The headline is identity, not naming

**One in four sampled records carries an id-canonical defect.** Two days of work
before this audit went into naming; identity was the larger problem throughout
and no detector reported it. `find_duplicate_spellings` returns **zero groups for
this entire half** — it folds to `[A-Z0-9]` and tests equality, so it is
structurally blind to duplicates differing by token *presence* or *order*.

The population is concentrated: Harley-Davidson, Honda, Yamaha, Suzuki,
Kawasaki. Worked examples that need no external source — BSA carries **twelve
live ids for two motorcycles** (Thunderbolt ×5, Lightning ×7), documented only in
an `enrich/bsa.yml` comment and in no ledger; `honda/sd02` publishes 475 Dutch
rows as a bare type code while the Finnish register writes `VARADERO-SD02D/996`
in a single cell, so the code→nameplate join is already inside our own corpus.

### The name row must not be used as an estimate

158 of 400 name claims carry an actual verdict; **242 were never attempted**.
Coverage is *not* stratum-uniform — every batch that reported its method said it
spent its budget where a source would settle a suspicion, so **the covered subset
skews toward records that already looked wrong and its defect rate is biased
upward.** Batch 3 declared this in its own proposal and its verifier preserved
the declaration.

The 242 split into a genuine **source-gap** floor and simple **not-attempted**
work. Those mean opposite things — one is a fact about the domain and feeds the
source-gap queue, the other is a fact about us and feeds effort planning — and
`unverifiable` currently does both jobs. Amendment proposed in §Protocol below.

### Availability is the one layer that survived everything

**952 of 953**, re-derived from raw registers by four researchers and then again
by four verifiers with independently written flatteners — 5,147,216 Finnish rows
counted identically by two implementations that never saw each other's code.

The single defect is `husqvarna/sm510` gb: all 77 UK rows are `SM 510 R`, which
belongs to the live `sm510r`. It was found only by checking DVLA's finer **Model**
column, which no researcher used.

Two structural qualifications, both from agents correcting their own work:
- the researchers' method verified *that a row exists for the make/model*, which
  by construction **cannot** distinguish a row that named the model from a row a
  rename resolved into it;
- a targeted census of that exposure (`ledger/census-rename-availability.yml`)
  found **3 fabricated country-claims out of 17,553 catalog-wide — 0.017%**, one
  already documented in its own rename comment. Of the 12 records the class
  touches, one was sampled, and it was **refuted**.

---

## Known limitations of this round

**1. It is not reproducible at its own tag.** The sample is pinned to
`v2026.07.5`; every batch measured a build stamped `2026.07.6`. Three population
figures exist and none agree:

    sample manifest       7,073
    current main build    7,083
    rebuild at the tag    7,087  (+ 4 gate failures)

The tag cannot be rebuilt cleanly with today's pipeline, because `v2026.07.5`
data against a post-`pipeline#36` tokenizer is exactly the coupled breakage that
change was made to fix. Materially the exposure is confined — id churn since the
tag is ~1 record, so id/make/kind/availability are essentially unaffected — but
**~100 display names were corrected between the tag and the build**, so name
verdicts were taken against post-fix names and the name rate is biased
*optimistically* on top of its coverage bias.

**Fix for the next round: the sampler must pin the BUILD it measures, not only
the release tag.** They are not the same object.

**2. `catalog/meta/decile-mass.json` was absent from the build.** The protocol
requires the usage-weighted aggregate to read it. It landed in `pipeline#40`
after these builds were made, so **no usage-weighted figure is published here** —
only the unweighted per-claim rates above.

**3. Verification moved every batch in the same direction.** All four proposals
were *optimistic*, not conservative:

    b1  85.1% → 84.0%     b2  78.4% → 78.1%
    b3  81.7% → 80.8%     b4  87.8% → 87.3%

**22 additional defects were found among claims the researchers called
`correct`, and all 22 were id-canonical.** The first verifier diagnosed the cause
— criteria applied inconsistently within a batch — and wrote the fix; the third
verifier found the fix had not been adopted and warned that if the under-call is
systematic the id rate is low by roughly a third. It is now corrected in the
table above, but the mechanism should be assumed live for future rounds.

**4. Cross-batch contradictions exist in the ledger and are NOT silently
resolved.** `honda/nt650v-deauville` and `harley-davidson/flhtcui-ultra-classic`
were each called `correct` by one batch and `defective` by another batch's
verifier. Both are recorded as-is. A ledger that hid the disagreement would be
worse than one that carries it.

---

## Defect classes for the taxonomy

Per invariant I-15 a class needs a taxonomy entry and a detector spec **before**
any scaled fixing. Nothing here has been fixed.

| class | status | measured | note |
|---|---|---|---|
| token-subset / permutation duplicates | real, novel detector | 312 groups / 765 records | `find_token_duplicates.rb`; **worklist, never verdict** |
| code ⟷ nameplate pairs | real, **size unknown** | see below | in-corpus join available for many |
| descriptor-as-model | real, novel | 16–58 by lexicon | ~40–50% false-positive rate; co-discovered by two batches |
| token-boundary shift | real, novel | 9 H-D + 5 current products | corrupts the **slug**, not just display |
| kind from source vocabulary | real | 258 gb-only, 18 twins, Twizy in 3 kinds | second nl route not in the kind-boundary plan |
| placeholder-keyed rename | real, novel | 1 live | cannot be scoped by kind |

**A number that was reported and does not reproduce:** batch 2's "262 code⊂code+name
pairs". Its verifier implemented the same spec across every reading of its
ambiguities and got 207 / 246 / 292 / 323 — never 262 — while the batch's
*companion* figure reproduced exactly. **The class is real; the size is not
established.** It is recorded here rather than published as a measurement.

**A detector that was built and then refuted, deliberately kept:** same-make
shared type-approval number is **not** a duplicate signal. 572 groups / 1,061 ids
share TANs; one Royal Enfield approval spans six nameplates and one Harley TAN
spans ten. Curation consequence: `renames.yml` cites TAN 38 times, and one line
(`Ab: Senda 50`, load-bearing for 317 rows) rests on **TAN alone** with no
name-family argument — and that TAN is not even make-exclusive. Four other lines
that look TAN-primary pair it with a measured displacement or class constraint
and are sound.

---

## Protocol amendments this round earns

1. **Sub-type `unverifiable`** into `source-gap` and `not-attempted`. Both
   correctly count against the clean rate, so the conservative bound is
   unchanged — but blending them means a hard domain limit cannot be told from
   unfinished work, and the source-gap queue silently fills with records nobody
   tried.
2. **Quote the relied-on sentence at write time.** Two batches cited a page that
   does not contain the claim.
3. **Cited URLs must be re-fetchable.** Six failed as written in one batch; two
   were the sole support for defective verdicts and both verdicts fell.
4. **Filed debt does not excuse a published claim.** A debt entry changes nothing
   for a consumer, and excluding filed-debt records would make the metric
   improvable by writing documentation. Report the known-debt/novel split against
   the same denominator instead. *(Both verifiers that considered it agreed.)*
5. **The sampler pins a build, not a tag** (limitation 1).

## Ledger

`ledger/researcher-b{1..4}.yml` — per-record verdicts, four independent agents.
`ledger/verifier-b{1..4}.yml` — independent re-derivation of each, I-11.
`ledger/census-rename-availability.yml` — the rename-propagation census.

Researcher and verifier records are kept **separate and unmerged on purpose**.
Merging them by hand would mean transcribing ~400 records' worth of prose
corrections into a single file — exactly the silent-transcription-error class
this program exists to remove. The corrected aggregate in this document is
computed from the verifiers' tallies; the disagreements remain readable.
