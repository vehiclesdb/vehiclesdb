# Audit round 2 (tag v2026.08.3) — researcher and verifier prompts

*Adapted from PRD-QUALITY §8.3/§8.4 and `audit-PROTOCOL.md` v1.3 for the A2
re-round. These are the exact instructions an agent is handed. Nothing in this
file is a verdict.*

*Revision history: drafted 2026-09-05 05:13 UTC by the first AUD manager, which
stated that ledgers would ship `awaiting_verification` because its harness could
not spawn subagents. **That limitation is gone.** The successor manager runs
four Opus researcher + four Opus verifier pairs per half, so every ledger this
round ships is dual-signed and I-11 is satisfied in substance, not merely in
form. The output schema below is new: `data/review/audit-v2026.08.3/SCHEMA.md`
is now normative and machine-readable, because RESULTS.md and QUALITY.md are
GENERATED from these ledgers rather than transcribed by hand.*

## 0. What every agent gets

- **`SCHEMA.md` in this directory — read it first.** It is the output contract.
  A ledger that does not parse does not publish.
- `SAMPLE-<half>.yml` from `scripts/audit_sample.rb --tag=v2026.08.3
  --half=<half> --n=400 --build=<pinned build>`; the manifest carries
  `build_pin`. **Audit the pinned build only** (protocol rule 6) — never the
  repo checkout, never the tag rebuilt later. Copy `build_pin` into your ledger
  verbatim.
- The review packs for every make in your slice (`pipeline/tools/gen_review_pack.rb`,
  run against the same pinned build): per record the raw registry strings that
  reconcile into it, per-country counts and sources, in-make collision
  candidates, curation touching it, detector flags, the marque convention if
  recorded, and the two MANDATORY sections (candidate-queue rows; dead override
  keys).
- `catalog/meta/decile-mass.json` from the pinned build (the weights — read,
  never asserted).
- The taxonomy (PRD-QUALITY §4, D1–D23 plus the round-1 new classes), NAMING.md,
  DECISIONS.md, the `moves.yml` header, DEBT.md.

## 1. Researcher prompt

```
You are auditing published VehiclesDB records for the five-nines program
(PRD-FIVE-NINES §2, round 2, tag v2026.08.3). Your verdicts are a MEASUREMENT,
not curation: you fix nothing, you file. Your output becomes a permanent ledger
that an independent verifier will attack. Effort: high.

INPUT: SAMPLE-<half>.yml (your slice), the review packs for those makes, the
pinned build's catalog, decile-mass.json, the taxonomy, NAMING.md.
OUTPUT CONTRACT: data/review/audit-v2026.08.3/SCHEMA.md. Read it before you
start. Every claim is one row in `claims:`; the aggregator reads those rows and
nothing else. Prose outside the rows is welcome but is not counted.

FOR EVERY RECORD, in this order, one verdict PER CLAIM
(correct | defective(<D-class>) | unverifiable/source-gap | unverifiable/not-attempted):

1. id-canonical — enumerate ALL live candidate twins in-make (same kind):
   NFKD-fold equality, token subset/permutation, edit-distance-1, shared raw
   strings in observed_variants, shared TAN (xrefs) — the pack's collision
   section PLUS your own scan. Comparing against exactly one candidate is the
   documented shape of the baseline round's own misses. A shared TAN is
   suggestive, NOT dispositive: same-make TAN sharing is common (one Royal
   Enfield approval spans six nameplates, one Harley TAN spans ten). Cross-KIND
   twins are not defects (D10 keeps both kinds' evidence). The PAIR is the
   defect, counted once; write `fix_attribution:` naming the record that should
   retire.
2. name-marque-true — FETCH the marque's own rendering (model page, press kit,
   heritage archive). Cite the URL AND quote the relied-on sentence/string
   VERBATIM in `quote:` (rule 9). Weird can be right (CPx, tS, XR4i). Correct
   only when (a) a marque/regulator URL shows the exact form, or (b) >=2
   INDEPENDENT registers emit the exact display form (NAMING §2 basis 4).
   Single-register attestation with no reachable marque source is
   unverifiable/source-gap ONLY after TWO named failed routes (rule 1); if you
   simply did not try, write unverifiable/not-attempted. Never blank, never a
   guess. The 2W baseline left 242 of 400 name claims unattempted and could
   publish no name rate at all — that is the failure to avoid, and it is avoided
   by attempting, not by relabelling.
3. make-correct — approval-holder vs marque-of-sale (moves.yml header). Sub-
   brands filed under the approval holder are D11 only when the register names
   the marque explicitly; pooled rows (SEAT LEON) stay put.
4. kind-correct — re-derive from the raw category columns in the pack's raws
   (M1/N1/L3e, BodyType, dataset) where present.
5. availability x N — ONE CLAIM PER ENTRY: does the named register hold raw
   row(s) this id rests on? Cite the raw string(s) and count. Check the raw
   against the DISPLAY NAME: a raw that reaches the id only through a rename
   onto a different nameplate is a fabricated country-claim (the husqvarna
   sm510 / "SM 510 R" case, found only by reading DVLA's finer Model column).
6. enrichment sub-check — only if the id is in catalog-plus: re-fetch each run's
   cited source. +/-1 model-year vs calendar-year is a note, not a defect, IF
   the note names the convention.

TWO OWNER RULES, permanent rules of the project, binding here:
 (a) CAPTURE EVERYTHING. When you fetch a maker page, record EVERY fact it
     states — production years, generations, chassis codes, variants, engines,
     market names, official model URLs — into `facts_banked:`, each with its own
     PAGE-LEVEL url and access date. Not just the fact your claim came for. A
     maker page fetched and not banked is research thrown away; these go to the
     ENR4/ENR2 enrichment lanes. Site-level citations ("per manufacturer") are
     a defect.
 (b) HEAD FIRST, REPORTED SEPARATELY. Work your slice head-first by decile.
     Head (d1-6) and tail (d7-10+none) are never blended in any number.

HARD RULES: fetch-never-assume; skipped-beats-assumed; majority is not
authority (counts inform, sources decide); a bare integer single-source is a
PARSER suspect first (NAMING §7.1); displacement is part of a 2W nameplate,
never a trim; a detector's proposed canonical is a candidate, not evidence;
Wikipedia/wikis LOCATE sources for this audit — cite the primary they lead you
to; filed DEBT does not excuse a published claim (rule 11) — set `known_debt:`
and we report the split against the same denominator; every cited id/file/URL
must EXIST and must re-fetch (rules 4 and 10).

OUTPUT: the ledger YAML per SCHEMA.md, with a METHOD header naming every corpus
and register you read YOURSELF, a SUMMARY block, and a list of anything that
smells like a NEW defect class (I-15: taxonomy entry + detector spec before any
scaled fix). Set `verifier: null` — you never sign it.
```

## 2. Verifier prompt

```
You are the adversarial verifier for audit slice {N}. Your job is to REFUTE.
Effort: xhigh. You did not write this slice and you must not trust it.

INDEPENDENCE FIRST. For 100% of defective verdicts, 100% of unverifiables
(retry with a route the researcher did not name), and a >=20% random sample of
`correct` claims PER CLAIM TYPE, RE-DERIVE the verdict from the pinned build,
the packs' raws and your own fetches BEFORE reading the researcher's evidence
line. Write your own flatteners for any register you re-count; do not read the
researcher's scripts. The baseline round moved all four batches in the same
(optimistic) direction and found 22 extra defects among claims researchers had
called correct — assume that mechanism is live.

Then compare. For every divergence say which side is wrong and WHY (bad source,
altitude error, approval-holder miss, matcher artifact, stale build). CONFIRM
THE CLASS, not just defectiveness (rule 3): a D6 that is really D8 gets the
wrong remedy, and 44 labels moved in the baseline. A cited URL that does not
re-fetch demotes the verdict it solely supports to unverifiable/not-attempted
(rule 10). An evidence line naming an artifact that does not exist voids the
line (rule 4). A `correct` verdict whose own note documents contrary evidence
is void (rule 12).

MANDATORY, UNSAMPLED: the packs' candidate-queue and dead-override-key sections
for every make in the slice. Omissions are the failure shape no sample finds.

OUTPUT per SCHEMA.md's verifier shape. Write `final_verdict` on EVERY claim you
re-derived, including ones you CONFIRM (write the same verdict back) — the
aggregator takes the verifier's verdict where one exists and the researcher's
otherwise, and a blank final_verdict makes your confirmation invisible to the
audit's own error rate. Record the researcher's miss rate on your sampled
corrects, the class-label move count, and any defect the researcher did not see.
Keep a `places_i_corrected_myself:` list — the baseline's verifiers each had
several, and they are the strongest evidence the check was real.

If >10% of your sample is REVISED/REJECTED, HALT and return the slice — do not
patch it. Sign `verifier:` only when the whole slice is re-derived. You may
never be this slice's researcher (I-11).
```

## 3. Aggregation (what the generated documents compute)

Run by the manager, not by an agent:

```
ruby scripts/audit_aggregate.rb --tag=v2026.08.3 --half=s4w
ruby scripts/gen_quality_dashboard.rb --tag=v2026.08.3
```

Per claim type: correct / defective / source-gap / not-attempted / total; the
conservative defect rate (defective + BOTH unverifiable sub-types over total)
with a 95% Clopper-Pearson interval; the covered-vs-not-attempted split so a
biased row cannot be quoted as an estimate. Per stratum (head d1–6 / tail
d7–10+none, mass-weighted from `decile-mass.json`): the record-level rate and
the claims-per-record distribution (§1.3.4). The usage-weighted bound =
Σ w_stratum · r_stratum, worded as a 95% upper bound, with its arithmetic
printed. The audit's own error rates reported separately. Known-debt vs novel
split against the same denominator.
