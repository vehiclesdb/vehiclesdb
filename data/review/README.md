# data/review/ — the verification ledger

This directory is the receipt behind the claim "manually reviewed,
model-per-model". Everything here is specified in **PRD-QUALITY.md §5–§7**
(repo root) — read that first; this file is only the map.

| File | What it is |
|---|---|
| `<make>.yml` | One ledger per make: a verdict + evidence for every published record of that make, dual-signed (researcher ≠ verifier). |
| `batches.yml` | The dispatch board — which makes are batched together, who claimed what, status. Claim before working. |
| `_coverage.yml` | Generated monotonic baseline (coverage may never drop on main). Written by `lint_review.rb --update`, never by hand. |

Tooling:

- `scripts/lint_review.rb` (this repo) — validates every ledger and computes
  coverage. Runs in CI. `VDB_CATALOG=…/build/out/catalog` measures against a
  fresh build; `VDB_PACKS=…/build/packs` enables fingerprint staleness.
- `pipeline/tools/gen_review_pack.rb` (pipeline repo, private) — generates the
  review pack for a make: published records with their raw registry rows, the
  candidate queue, dead override keys, dropped rows, and the
  `raw_fingerprint` the ledger must store.

Ledger shape (lint-enforced; see PRD §5.2 for field semantics):

```yaml
make: iva
researcher: s2w-r1        # who researched — an agent/session id
verifier: s2w-v1          # who verified — MUST differ from researcher (I-11)
reviewed_at: 2026-07-26
raw_fingerprint: sha256:…  # from the pack; verdicts go stale when it changes
records:
  - id: moped/iva/e-go-s2          # <kind>/<make>/<slug>, must be live
    verdict: canonical             # canonical|fixed|debt|removed|moved|stale
    evidence: https://…            # exact URL(s) — a verdict without evidence
                                   # is an opinion; mandatory
  - id: moped/iva/ra-9015
    verdict: removed               # id must be GONE + covered by removals.yml
    note: duplicate spelling of ra9015   # debt/removed/moved need a note
    evidence: https://…
```
