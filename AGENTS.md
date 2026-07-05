# AGENTS.md — rules for AI agents and humans working on this repo

Read this before changing anything. These are hard rules, not suggestions;
they encode legal constraints and data-quality invariants that are cheap to
break and expensive to discover broken. (Pattern from OpenASN's AGENTS.md.)

## Read order

1. `README.md` — what this dataset is and the Open Contract
2. `SCHEMA.md` — the shapes and the growth/versioning contract
3. `DECISIONS.md` — why things are the way they are (do not re-litigate)
4. `SOURCES.md` — per-source operational notes and gotchas
5. This file

## Invariants (never break)

- **Never edit `catalog/`, `dist/`, `manifest.json`, `ATTRIBUTION.md` or
  `VERSION` by hand.** They are build outputs, regenerated on every release
  from the private pipeline. Hand edits will be silently overwritten — and a
  hand edit that "fixes" data hides a normalizer bug that will reproduce it.
- **Fix data by editing `overrides/`** — that's the human-curation input
  layer, and it's the ONLY one. Every override line must carry a `#` comment
  saying why (with a source URL for anything non-obvious). CI lints this.
- **Never add a source here.** Sources live in the private pipeline with
  license verification and pinning. If you know a good open source, open an
  issue with the URL and its license text.
- **Never commit anything derived from a ShareAlike (CC-BY-SA/ODbL),
  NonCommercial, or scraped source.** This composite is CC-BY 4.0; one
  ShareAlike ingredient infects the whole dataset. No exceptions, including
  "just to fill a gap".
- **No per-vehicle data.** No VINs, plates, registration documents, or
  anything traceable to an individual vehicle or owner — in data, examples,
  tests, or issue reports.
- **No logos, no vehicle imagery.** Word marks as plain-text facts only.
- **Ids are append-only.** Never rename or delete a published id; renames
  happen through the pipeline's alias mechanism.

## Safe things to do here

- Add/fix `overrides/` entries (aliases, drops, renames, body types,
  stylings) — with source comments.
- Add rows to `spotchecks.yml` (tripwire assertions the build must satisfy);
  every row needs a `reason`.
- Improve docs.
- Run `ruby scripts/lint_overrides.rb` before pushing — it's the same check
  PR CI runs, in seconds.

## How data flows (so you don't fight it)

```
official registers (14+ countries)
  → private pipeline: fetch (cached, snapshotted) → parse → normalize
     → reconcile (≥2 sources or count threshold) → validate (6 gates)
  → THIS repo: catalog/ + dist/ + manifest.json + ATTRIBUTION.md   (build outputs)
     with overrides/ + spotchecks.yml as the curated INPUT the pipeline reads
  → SDKs (rameerez/vehicles gem, …) bundle dist/ snapshots
```

A monthly scheduled workflow builds and releases; a weekly one validates
without publishing. A failed scheduled build opens/updates a
`pipeline-failure` issue — if you see one open, that's the highest-priority
thing in the repo.
