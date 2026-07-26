# The audit protocol (PRD-FIVE-NINES §2 — what each sampled record gets)

*One file so audit agents are pointed at exactly one thing. The sample comes
from `scripts/audit_sample.rb` (seeded by release tag — regenerable, never
cherry-pickable). Results ledger under `data/review/audit-<tag>/`.*

## Per-record checks (CLAIM-LEVEL — S2W finding A6)

Rates are computed over CLAIMS, not records: a 6-country record carries more
claims than a 1-country record, and head records are structurally
claim-heavier. Verdicts per claim: `correct | defective(<taxonomy class>) |
unverifiable(<reason>)`. **Unverifiable counts AGAINST the clean rate**
(conservative bound) and feeds the source-gap queue.

Per sampled record, in order:

1. **id-canonical** — no other live id denotes the same vehicle. Check: the
   duplicate-spellings + contradiction detectors (should be silent — they run
   in CI), the make's raw corpus for uncovered forms, and where Workstream B
   covers the make, the identity map (shared QID = fail here).
2. **name-marque-true** — the display name matches the marque's own rendering
   (fetch, never assume; the CPx/tS/XR4i rule: weird can be right). Cite the
   URL in the ledger line.
3. **make-correct** — the record sits under the right marque (corporate-name,
   type-approval-holder, and marque-of-sale traps: see moves.yml header).
4. **kind-correct** — right vehicle category (the Caddymaxi/kind-noise class).
5. **availability×N** — one claim PER availability entry: the country's
   register really evidences this model (raw corpus or live register query;
   nl_rdw is queryable, others via cached pulls).
6. **enrichment sub-check** (only when the id is enriched, §6.2): re-derive
   each run from its cited source by re-fetching. ±1 model-year vs
   calendar-year is a note, not a defect, IF the note names the convention.

## Rules that bind the auditor

- **Researcher ≠ verifier** (I-11): every batch of verdicts is re-derived by
  an independent verifier agent before the ledger merges; verifier-merges-only.
- **Fetch-never-assume; skipped-beats-assumed.** An unverifiable claim is
  recorded as such — never resolved by analogy, majority, or memory.
- **Majority is not authority** (the VITO/MGA rule) — counts inform, sources
  decide.
- **New defect class found → taxonomy entry + detector spec BEFORE scaled
  fixing** (invariant I-15). The audit finds; it does not sweep.
- Fixes ride separate curation PRs, never the audit ledger PR.

## Ledger format (per record, one entry)

```yaml
"car/make/slug":
  verdicts: { id: correct, name: correct, make: correct, kind: correct,
              availability: { nl: correct, nz: "unverifiable(register pull predates id)" } }
  evidence: ["https://…  # name check", "raw: 'MAKE | MODEL' nl_rdw"]
  researcher: <session/agent>
  verifier: <session/agent>   # must differ
```

## Aggregation

`RESULTS.md` per round: per-class defect rates with 95% Clopper-Pearson
intervals, per stratum; the usage-weighted aggregate computed against the
PUBLISHED weights (`catalog/meta/decile-mass.json` at the audited tag — the
weights are read, never asserted); certified-stratum miss rate reported
separately (it is the program's own error rate, §5.2).

## v1.1 amendments (from the baseline round's adversarial verification)

1. **Two-route minimum**: `unverifiable` requires TWO distinct failed
   routes, both named (22/26 baseline unverifiables fell to one more route).
2. **Pair defects are symmetric, counted once**: the duplicate PAIR is the
   defect; a `fix_attribution:` line names the record that should retire.
3. **Verifiers confirm CLASS, not just defectiveness** (44 labels moved in
   the baseline; remedies differ by class, so labels are load-bearing).
4. **Evidence hygiene**: every cited id/file/URL in an evidence line must
   exist — a citation naming a nonexistent artifact voids the line.
5. **Multi-twin rule**: canonicality checks enumerate ALL live candidate
   twins in-make before any verdict (the baseline's spot-check misses all
   compared against exactly one).

## v1.2 amendments (from the 2W baseline round)

6. **Pin the BUILD, not the tag**: the sampler's `--build=<dir>` records the
   exact build the round measures (`build_pin` in the manifest); auditing a
   tag while overrides move produced three disagreeing population figures
   (RESULTS-s2w). Batches and verifiers read the pinned build only.
7. **Superseded passes use distinct keys** in verify files (the 4W round's
   corrected-in-place entries tripped the duplicate-key lint — YAML
   last-wins silently discards audit history).
