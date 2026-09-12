# Audit round 2 — round-specific brief (tag `v2026.09.1`)

Read this ON TOP OF the two normative files, which you must also read:

- `~/GitHub/.vdb-worktrees/aud-data/data/review/audit-v2026.09.1/SCHEMA.md` — the OUTPUT CONTRACT. A ledger that does not parse does not publish.
- `~/GitHub/.vdb-worktrees/aud-data/data/review/audit-PROTOCOL.md` — the rules (v1.3).
- `~/GitHub/.vdb-worktrees/aud-data/data/review/audit-v2026.09.1/PROMPTS.md` — §1 researcher / §2 verifier. Your role's section is your instructions.

## 0 · THE PIN — and the one trap specific to this round

```
tag          v2026.09.1        (released 2026-09-12T13:58:38Z, run 34697443600)
build_pin    /Users/javi/GitHub/.vdb-worktrees/aud-tag
             ^ this is a git worktree detached at tag v2026.09.1. Its `catalog/`
               is the RELEASED BYTES — not a rebuild of them. Copy this path
               into your ledger's `build_pin:` VERBATIM.
pipeline SHA 96a798b           (what the publish run checked out)
data SHA     a480b99           (the release commit; the tag)
```

**⚠ THE TRAP. The review packs were generated from a LOCAL FROZEN BUILD that
does NOT reproduce the release.** Measured by the manager before this round
started, on the full catalog:

| | |
|---|---|
| records in the release, absent from the frozen build | **23** |
| records in the frozen build, absent from the release | **1** |
| common records differing on ≥1 field | **13,876 of 14,886 (93.2%)** |
| dominant differing fields | `popularity` (rank churn), `xrefs`, `availability`/`sources`, and **33 car `name`s** |

So:

- **The record under audit is in `slice-<half>-b<N>-records.json`** (given to you
  below). Those are the released bytes, read from the pin. **Every verdict is
  about THAT text.**
- **The pack (`build/packs/<make>.md`) is EVIDENCE, not the claim.** Its raw
  registry strings, collision candidates, curation lookups, candidate-queue rows
  and dead-override-key sections are all still exactly what you need — they come
  from the register corpus. But if the pack's copy of a published record
  disagrees with `…-records.json`, **`…-records.json` wins, and SAY SO in a
  note**: a pack/pin disagreement is itself a finding worth recording.
- Do not "fix" a claim by pointing at the frozen build. Auditing a build nobody
  shipped is the exact failure protocol v1.2 rule 6 exists to prevent.

## 1 · Your inputs

```
SLICE     /private/tmp/.../scratchpad/slices/slice-<half>-b<N>.yml            <- makes, head-first id order, deciles
RECORDS   /private/tmp/.../scratchpad/slices/slice-<half>-b<N>-records.json   <- THE CLAIM UNDER AUDIT (released bytes)
PACKS     ~/GitHub/.vdb-worktrees/aud-pipeline/build/packs/<make>.md          <- evidence, one per make in your slice
PIN       ~/GitHub/.vdb-worktrees/aud-tag/catalog/                            <- the released catalog
WEIGHTS   ~/GitHub/.vdb-worktrees/aud-tag/catalog/meta/decile-mass.json       <- read, never assert
TAXONOMY  ~/GitHub/.vdb-worktrees/aud-data/PRD-QUALITY.md §4 (D1–D23 + round-1 classes)
NAMING    ~/GitHub/.vdb-worktrees/aud-data/NAMING.md, DECISIONS.md, DEBT.md
MOVES     ~/GitHub/.vdb-worktrees/aud-data/overrides/moves.yml  (read its HEADER — the approval-holder traps)
```

## 2 · Re-deriving availability WITHOUT trusting the pack

The cached raw registers are flat files in `~/GitHub/vehiclesdb-pipeline/cache/`
— **READ-ONLY, never write there, never re-fetch into it.** They are named
`<source>_<dataset>.<ext>`, e.g. `nl_rdw_personenauto*.json`,
`de_fz10_2026*.xlsx`, `ar_autos_*.csv`. `grep`/`ruby -rjson` them yourself; the
protocol wants you to write your own flatteners rather than read someone else's.

`nl_rdw` is also **queryable live** (CC0):
`https://opendata.rdw.nl/resource/m9d7-ebf2.json?$select=merk,handelsbenaming,count(*)&$group=merk,handelsbenaming&$where=merk='YAMAHA'`
Use it when the cache is the only other route — two independent routes is what
rule 1 requires before you may write `unverifiable/source-gap`.

**A cache that lacks a row is NOT proof the register lacks it.** The cache is a
frozen snapshot and it is measurably behind what the release was built from.
"Absent from my cached copy" is ONE failed route, not a verdict.

## 3 · Web tools, and the budget wall

First call: `ToolSearch` with `select:WebFetch,WebSearch`.

**`WebSearch` may be exhausted for this session** (another lane hit 200/200
earlier today). If searches fail, that blocks DISCOVERY, not RETRIEVAL —
`WebFetch` on a direct URL still works. Go straight at known manufacturer URL
shapes (`https://www.<marque>.com/...`, press/heritage subdomains, regulator
portals). **A failed search is not a source gap**: record which routes you
actually tried, by name, and if you did not reach a marque source, the honest
verdict is `unverifiable/not-attempted`, not a guess and not a fabricated
`source-gap`.

## 4 · The two OWNER RULES (permanent project rules — they bind you)

1. **`facts_banked` is MANDATORY.** Every maker page you fetch states production
   years, generation/chassis codes, variants, engines, market names, official
   model URLs. **Record every fact it states**, each with its own **page-level**
   URL and access date — not just the fact your claim came for. These are handed
   to the ENR2/ENR4 enrichment lanes. A maker page fetched and not banked is
   research thrown away. A site-level citation ("per manufacturer") is a defect.
2. **HEAD FIRST, reported separately.** `ids_head_first` in your slice file is
   already ordered for you. Head (deciles 1–6) and tail (7–10 + none) are never
   blended. If you run out of budget, you run out **in the tail**, and those
   claims are recorded `unverifiable/not-attempted` — honestly, with a note.

## 5 · Output

Write ONE file, valid YAML, exactly per `SCHEMA.md`:

```
~/GitHub/.vdb-worktrees/aud-data/data/review/audit-v2026.09.1/ledger/<role>-<half>-b<N>.yml
```

Three separate fields, never one combined string:

```yaml
verdict: correct | defective | unverifiable     # the bare word, nothing else
defect_class: D6                                 # iff defective
unverifiable_subtype: source-gap | not-attempted # iff unverifiable
```

`verdict: defective(D6)` or `verdict: unverifiable/source-gap` is a **parse
failure** — the aggregator rejects the ledger. (It used to count such a row in
the denominator and in no bucket, publishing real defects as a 0.00% rate.)

Validate before you finish:

```sh
cd ~/GitHub/.vdb-worktrees/aud-data && ruby -ryaml -e 'y=YAML.load_file(ARGV[0]); \
  raise "claims_total mismatch" unless y["SUMMARY"]["claims_total"]==y["claims"].size; \
  puts "OK #{y["claims"].size} claims"' data/review/audit-v2026.09.1/ledger/<your file>
```

**You fix nothing.** No override edits, no curation, no commits. A defect goes
in the ledger. Fixes ride other lanes' PRs (I-15).
