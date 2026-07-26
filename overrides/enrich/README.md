# overrides/enrich/ — open-layer enrichment facts (G23a+)

One file per make, keys are full ids, first fact class: **production runs**.
Spec: **PRD-QUALITY.md §14.4** (store facts, derive labels). The pipeline
derives `era` (`discontinued` / `classic` at the 30-year H-Kennzeichen line /
`vintage` pre-1931 FIVA line) at emit time — never write an era by hand.

```yaml
"motorcycle/triumph/bonneville":
  runs:
    - {year_start: 1959, year_end: 1983, note: Meriden}  # source URL on the line — MANDATORY
    - {year_start: 2001}                                 # open run = in production, suppresses all tags
```

Rules (all lint-enforced by `scripts/lint_enrich.rb`, wired into CI):
- id must be live in the catalog (pending-publish alias targets tolerated);
- make-aligned files; cross-file duplicate ids fail (the loader last-write-wins silently);
- `1885 ≤ year_start`; `year_end ≤ current+1`; runs sorted, non-overlapping —
  **source conflicts go in the `note`, never encoded as overlapping data**;
- every id entry carries a citation comment (§14.1: enrichment without
  provenance is how open datasets rot). Sources per §12 hierarchy: heritage
  archives → marque clubs → period regulator documents. Wikipedia locates,
  never sources.

Capture rule (§7): review-batch researchers already inside heritage pages
record runs **when the source in hand states them** — zero marginal cost.
