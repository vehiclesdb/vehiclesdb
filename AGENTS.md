# AGENTS.md — rules for AI agents and humans working on this repo

Read this before changing anything. These are hard rules, not suggestions;
they encode legal constraints and data-quality invariants that are cheap to
break and expensive to discover broken. (Pattern from OpenASN's AGENTS.md.)

## Read order

1. `README.md` — what this dataset is and the Open Contract
2. `SCHEMA.md` — the shapes and the growth/versioning contract
3. `DECISIONS.md` — why things are the way they are (do not re-litigate)
4. `SOURCES.md` — per-source operational notes and gotchas
5. `NAMING.md` — the naming canon and evidence standards (what to call things)
6. **The 2026-07 correction-pass briefs** — the long-form context that does not
   fit in a rules file: how the parser bugs happened, why two "obvious" cleanups
   destroyed real data, the verified per-marque naming conventions with sources,
   and the open items. Written to be read cold, assuming nothing.
   - **Curation, canon, incidents, open items** —
     https://github.com/vehiclesdb/vehiclesdb/pull/4#issuecomment-5079545135
   - **Code contracts (xlsx reader, KBA source, moves, test seams, licence pins)** —
     https://github.com/vehiclesdb/vehiclesdb-pipeline/pull/1#issuecomment-5079564588
   - **Two-wheelers, build triage, cross-make moves, former_ids, the `kind`
     decision, and the full silent-failure catalogue** —
     https://github.com/vehiclesdb/vehiclesdb-pipeline/pull/2#issuecomment-5079726629

   If you are about to delete records whose names look like registry junk, read
   the first one before you do. That exact reasoning deleted SEAT’s entire
   current German lineup once, and nearly deleted 148 more records including the
   best-selling car in Germany.
7. `PRD-QUALITY.md` — **the operating document for all quality work**: the
   defect taxonomy, the verification ledger, batch/swarm orchestration, dedup
   and canonicality specs, the gates still to build, and the program phases.
   If you are here to review, fix, dedupe, enrich or extend the data, this is
   your work order. It also carries the gap register — the authoritative
   list of everything currently known to need fixing.
8. `CORRECTION-PASS-2026-07-LOG.md` — the verbatim 40-turn working log behind those
   briefs. Read it when you need to know WHY a decision went the way it did, or want
   the raw measurement behind a claim. It deliberately contains the wrong turns as
   well as the right ones: several of the most expensive lessons here only make
   sense alongside the mistake that produced them.
9. This file

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

## Standing owner directives (permanent — 2026-09-05)

The owner's rules for every research, curation and enrichment pass, in any
repo of this project. They rank with the invariants above; a pass that
violates them is not done.

- **Save as much information as possible.** Every pass captures EVERYTHING
  it learns about an entity, not only the fact it came for: production runs,
  variants, generations, links (maker page, model page), make facts, specs,
  powertrains, aliases in every script, plate facts. Facts go into
  structured storage (`overrides/` for the open layer; the pipeline's
  `enrich/` and depth layer for the private one), never into prose alone —
  a fact established in a PR comment and then discarded is the failure mode
  the G26 capture doctrine exists to kill. Richness IS the product.
- **Always save the sources, with exact URLs.** Every stored fact carries
  its own citation: the precise URL (a page, not a site), the access date
  where the page can change, and its evidence tier (manufacturer/regulator
  > archive/club/registry > Wikipedia). Enrichment without provenance is how
  datasets rot, and provenance is what the paid layer sells.
- **Power laws apply — work the head first.** The top ~20% of entities by
  registration mass produce 80%+ of every result: consumer queries, API
  calls, defects that matter, enrichment value, SEO. Order every queue by
  MEASURED mass (the pipeline's `aux/popularity-queue-*.md`,
  `catalog/meta/decile-mass.json`, per-country ranks), finish the head
  completely (100% of decile 1, then 2, then 3) before touching the tail,
  and size swarms by mass, not by record count. "Done" for a make means its
  head is complete and cited; the tail is filed in DEBT, not chased.

## Standing owner directives (permanent — 2026-09-05)

The owner's rules for every research, curation and enrichment pass, in any
repo of this project. They rank with the invariants above; a pass that
violates them is not done.

- **Save as much information as possible.** Every pass captures EVERYTHING
  it learns about an entity, not only the fact it came for: production runs,
  variants, generations, links (maker page, model page), make facts, specs,
  powertrains, aliases in every script, plate facts. Facts go into
  structured storage (`overrides/` for the open layer; the pipeline's
  `enrich/` and depth layer for the private one), never into prose alone —
  a fact established in a PR comment and then discarded is the failure mode
  the G26 capture doctrine exists to kill. Richness IS the product.
- **Always save the sources, with exact URLs.** Every stored fact carries
  its own citation: the precise URL (a page, not a site), the access date
  where the page can change, and its evidence tier (manufacturer/regulator
  > archive/club/registry > Wikipedia). Enrichment without provenance is how
  datasets rot, and provenance is what the paid layer sells.
- **Power laws apply — work the head first.** The top ~20% of entities by
  registration mass produce 80%+ of every result: consumer queries, API
  calls, defects that matter, enrichment value, SEO. Order every queue by
  MEASURED mass (the pipeline's `aux/popularity-queue-*.md`,
  `catalog/meta/decile-mass.json`, per-country ranks), finish the head
  completely (100% of decile 1, then 2, then 3) before touching the tail,
  and size swarms by mass, not by record count. "Done" for a make means its
  head is complete and cited; the tail is filed in DEBT, not chased.

## Two maintainers, one dataset (read before you edit anything)

Curation is split by MAKE, not by kind: **one make = one owner, across all six
kinds and all defect classes.** The owner is the side that owns the make's
dominant kind by record count. The map is generated into `OWNERSHIP.yml` by
`scripts/gen_ownership.rb` — 860 makes, zero overlap, with the 26 makes that
span both kind groups listed explicitly.

- **s4w** — car, van, truck, bus (427 makes)
- **s2w** — motorcycle, moped (433 makes)

Consequence worth internalising: each owner curates their makes **in every
kind**, so each side holds records inside the other's kinds (measured: 427
four-wheel records under two-wheel-owned makes, 81 the other way). "Done" is
therefore defined per make-set, never per kind-set.

### Working rules

- **Never work in the primary clones.** `~/GitHub/vehiclesdb` and
  `~/GitHub/vehiclesdb-pipeline` are read-only, for reading merged state. Each
  maintainer works in their own `git worktree` (`s4w/…` / `s2w/…` branches), so
  a `checkout` on one side cannot change the other's tree mid-edit.
- **Append-only inside your own region; never reorder another's lines.** Make
  blocks are kept alphabetical (`scripts/reorg_make_blocks.rb`) so concurrent
  edits land in different places and merge cleanly.
- **Duplicate YAML keys destroy work silently.** `YAML.safe_load` keeps the
  LAST duplicate: two `Honda:` blocks means one block vanishes with lint green,
  build green, and renames failing silently by design.
  `scripts/lint_curation.rb` is the guard. Run it.
- **No force-push anywhere**, including `main` in either repo.
- Pipeline repo is partitioned by FILE, not by make — see NEGOTIATION.md.

## The curation scripts

| script | what it catches |
|---|---|
| `lint_overrides.rb` | shape/vocabulary of the override files (pre-existing) |
| `lint_curation.rb` | duplicate YAML keys, make keys that match no display name (inert forever), curation added without a stated reason |
| `lint_dataset.rb` | name-SHAPE defects in the published catalog + drop-list effectiveness; `legit`/`debt` buckets in `data/name_shapes.yml` |
| `reorg_make_blocks.rb` | keeps make blocks alphabetical (`--check` in CI) |
| `gen_ownership.rb` | regenerates `OWNERSHIP.yml` from the catalog |

All five run in CI on every PR (`.github/workflows/lint.yml`) and in seconds
locally. `lint_dataset.rb` is report-only until the `debt` section is empty.

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
  → SDKs (vehiclesdb/vehicles gem, …) bundle dist/ snapshots
```

A monthly scheduled workflow builds and releases; a weekly one validates
without publishing. A failed scheduled build opens/updates a
`pipeline-failure` issue — if you see one open, that's the highest-priority
thing in the repo.
