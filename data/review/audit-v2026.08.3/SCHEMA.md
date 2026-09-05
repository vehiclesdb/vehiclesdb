# Round-2 ledger schema (audit-v2026.08.3)

*The baseline round wrote its verdicts as prose lists and computed the
aggregate by hand. RESULTS-s2w.md said why that was the honest choice at the
time and also what it cost: "Merging them by hand would mean transcribing ~400
records' worth of prose corrections into a single file — exactly the silent-
transcription-error class this program exists to remove." Round 2 keeps the
researcher and verifier files **separate and unmerged** — that part was right —
and makes the claim rows **machine-readable**, so `scripts/audit_aggregate.rb`
derives every published number and nobody transcribes anything.*

**Every number in `RESULTS.md`, `RESULTS-s2w.md` and `QUALITY.md` is generated
from these files.** A ledger that does not parse does not publish.

## Files

```
data/review/audit-v2026.08.3/
  SAMPLE-s4w.yml            # sampler output, carries build_pin
  SAMPLE-s2w.yml
  ledger/
    researcher-s4w-b1.yml … researcher-s4w-b4.yml
    verifier-s4w-b1.yml   … verifier-s4w-b4.yml
    researcher-s2w-b1.yml … researcher-s2w-b4.yml
    verifier-s2w-b1.yml   … verifier-s2w-b4.yml
  defects-found.md          # what the round found; FILED, never fixed here
  RESULTS.md  RESULTS-s2w.md
```

`researcher-<half>-b<N>` and `verifier-<half>-b<N>` are **different agents**,
always (I-11). The verifier of slice N may not be the researcher of slice N.

## Researcher ledger

```yaml
round: v2026.08.3
half: s4w
slice: 1
role: researcher
researcher: "opus5/aud-r-s4w-b1"     # your agent id — be specific
verifier: null                        # you NEVER sign this field
tag: v2026.08.3
build_pin: "/abs/path/to/build/out"   # copy from SAMPLE-<half>.yml, verbatim
protocol: data/review/audit-PROTOCOL.md
reviewed_at: 2026-09-05

METHOD:
  corpora_read: ["…every file you opened yourself…"]
  registers_queried_directly: ["…name the file, its size, and the columns you used…"]
  decision_rules_i_bound_myself_to: ["…state them BEFORE the verdicts, so a verifier can hold you to them…"]

SUMMARY:
  records_audited: 100
  claims_total: 0        # must equal the number of rows in `claims:`
  verdict_counts: { correct: 0, defective: 0, source_gap: 0, not_attempted: 0 }

claims:
  - id: car/tesla/model-y          # <kind>/<make>/<slug>, exactly as published
    claim: id                      # id | name | make | kind | availability | enrichment
    country: null                  # REQUIRED and non-null for availability; null otherwise
    verdict: defective             # correct | defective | unverifiable
    defect_class: D6               # REQUIRED iff defective — a D-class from PRD-QUALITY §4
    unverifiable_subtype: null     # REQUIRED iff unverifiable: source-gap | not-attempted
    routes_failed: []              # REQUIRED (>= 2, named) iff source-gap (protocol rule 1)
    fix_attribution: car/tesla/y   # for symmetric pair defects: which record should retire
    known_debt: false              # is this already filed in DEBT.md? (rule 11 — report the
                                   # split; filed debt does NOT excuse a published claim)
    evidence:
      - url: "https://www.tesla.com/modely"
        quote: "Model Y"           # the RELIED-ON string/sentence, VERBATIM (rule 9)
        accessed: 2026-09-05
        tier: manufacturer         # manufacturer | regulator | register | wikipedia | other
      - raw: "TESLA | MODEL Y"
        source: nl_rdw
        count: 55598
    facts_banked:                  # OWNER RULE — see below. Not optional.
      - fact: "Model Y production began 2020"
        url: "https://…/exact/page"
        accessed: 2026-09-05
    note: "…"
```

## Verifier ledger

```yaml
round: v2026.08.3
half: s4w
slice: 1
role: verifier
researcher: "opus5/aud-r-s4w-b1"   # who you are checking
verifier: "opus5/aud-v-s4w-b1"     # you — MUST differ from researcher
tag: v2026.08.3
build_pin: "/abs/path/to/build/out"
reviewed_at: 2026-09-05

METHOD:
  independence: ["…state that you re-derived BEFORE reading their evidence line…"]
  sources_i_read_myself: ["…"]
  places_i_corrected_myself: ["…keep these; they are the strongest evidence the check was real…"]

verdicts:
  - id: car/tesla/model-y
    claim: id
    country: null
    outcome: REVISED                    # CONFIRMED | REVISED | REJECTED
    final_verdict: defective            # correct | defective | unverifiable
    final_defect_class: D8              # confirm the CLASS, not just defectiveness (rule 3)
    final_unverifiable_subtype: null
    why: "D6 catch-all; the twin is a trim-of-nameplate, so the remedy differs — D8."
    evidence: [ … same shape as the researcher's … ]
```

**`final_verdict` is load-bearing.** The aggregator's resolution rule is: a
claim's final verdict is the **verifier's** where the verifier recorded one, and
the **researcher's** otherwise. So:

- Leave `final_verdict` set on every claim you re-derived, including the ones you
  CONFIRMED (write the same verdict back). A CONFIRMED row with an empty
  `final_verdict` silently falls back to the researcher — which is the same
  number, but it makes your confirmation invisible to the audit's own error rate.
- Never write a verdict row for a claim you did not actually re-derive.

## The two OWNER RULES, as they bind this round

*(NEGOTIATION, OWNER DIRECTIVE 2026-09-05, permanent rules of the project.)*

1. **Capture everything, structured — `facts_banked` is mandatory.** When you
   fetch a maker page to settle a name claim, that page states production years,
   generation codes, variants, engine facts, market names, official model URLs.
   **Record every fact it states**, each with its own **page-level** URL and
   access date, in `facts_banked` — not only the one fact your claim came for.
   Prose-only capture is a defect. A site-level citation ("per manufacturer") is
   a defect. These banked facts are handed to the ENR4/ENR2 enrichment lanes; a
   maker page fetched and not banked is research thrown away.
2. **Head first, by measured mass, and reported separately.** Head (deciles 1–6)
   and tail (7–10 + none) are **never blended** in any number this round
   publishes. The sample is stratified; the bound weights the two strata from
   `catalog/meta/decile-mass.json`; RESULTS prints them as separate rows.

## Hard rules restated (audit-PROTOCOL.md v1.3 — read the file, this is the summary)

- **Fetch-never-assume. Skipped-beats-assumed.** Never resolve a claim by
  analogy, majority or memory. `unverifiable/not-attempted` is an honourable
  verdict; a guess is not.
- **Unverifiable counts AGAINST** the clean rate, both sub-types. The two
  sub-types are mandatory and mean opposite things: `source-gap` is a fact about
  the domain (and needs TWO named failed routes), `not-attempted` is a fact about
  our effort.
- **Majority is not authority** — counts inform, sources decide.
- **The pair is the defect**, counted once, with `fix_attribution`.
- **Enumerate ALL live candidate twins in-make** before any canonicality verdict
  (the multi-twin rule; the baseline's misses all compared against exactly one).
- **Every cited id/file/URL must exist** and must re-fetch at verification time.
  A verdict whose sole support fails to fetch demotes to `not-attempted`.
- **A `correct` verdict whose own note documents contrary evidence is void**
  (rule 12 — verdict/note consistency).
- **Audit the pinned build only.** Never the repo checkout, never a later rebuild
  of the tag.
- **You fix nothing.** A defect goes in the ledger and in `defects-found.md`.
  Fixes ride separate curation PRs owned by other lanes (I-15: a new class needs
  a taxonomy entry and a detector spec before any scaled fixing).
