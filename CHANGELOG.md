# Changelog

Dataset releases. Versioned `YYYY.MM.PATCH`; each release is a git tag.

## [Unreleased] — the correction release

The next build corrects identity errors rather than adding data. Two parser bugs
had been fabricating model names, and a curation pass had begun deleting the
real records those bugs produced. **Ids change in this release** — see
*Migration* below.

### Germany: 148 records were shared-string indices, not model names

`XlsxLite`'s cell regex let an empty XLSX cell swallow the next cell's `<v>`, so
KBA FZ 10 published shared-string **indices** where model names belong, across
29 makes. `volkswagen/552` **was the Golf** — Germany's best-selling car — while
`volkswagen/golf` carried twelve countries and no `de`. Every German popularity
figure for the country's best sellers sat on a garbage id, and the real
nameplates were ranked as if Germany did not exist.

The integers looked exactly like registry type-codes, and the previous release
had already deleted SEAT's entire current German lineup on that reading:
`seat/468`–`474` were ATECA, BORN, FORMENTOR, IBIZA, LEON, TAVASCAN, TERRAMAR.
Those drops are retired here. The rule that came out of it is in
[NAMING.md](NAMING.md) §2.1: *a bare integer, single-source, is a parser suspect
before it is a data suspect*.

### Also corrected

- **Cross-make moves** (`overrides/models/moves.yml`, new): registers file
  sub-brands under the type-approval holder, so every Cupra arrives as a SEAT
  and every Genesis as a Hyundai. ~26,500 German registrations now reach the
  right marque instead of being dropped.
- **KBA temporal merges**: `"GLK, GLC"` and friends splice a nameplate to its
  renamed successor in one cell; 22k registrations were landing on nameplates
  dead since 2015.
- **390 duplicate spellings merged**: `280 Se` and `280SE` were separate ids for
  the same W108, each with four sources.
- **161 non-vehicles removed** from the car kind: 14 motorhome builders (measured
  against RDW's CC0 register), 49 rows where a register wrote the make into the
  model column, and assorted junk strings.

### Migration

Ids that changed carry `former_ids` (a new optional field — additive, so not a
breaking change under [SCHEMA.md](SCHEMA.md)). Look a missing id up there before
assuming a model was removed.

**97 ids were removed with no successor.** They are motorhome floorplan codes
(Bürstner, Pössl, Niesmann+Bischoff) that were never cars; they have no alias
because there is nothing to alias them to.

## [2026.07.0] - 2026-07-05

The multi-source, multi-kind, multi-continent release: **456 → 18,556 models**.

- **14 official sources, 14 countries, 4 continents**: NL RDW · UK DfT
  VEH0120 · ES DGT microdata · FI Traficom · LU SNCA · IE CSO · DE KBA FZ 10 ·
  US fueleconomy.gov · CA NRCan · NZ Waka Kotahi MVR · MY JPJ · TH DLT ·
  UA MVS/HSC · AR DNRPA. Every license pinned by SHA-256 (`data/licenses/`);
  per-source notes and measured gotchas in the new [SOURCES.md](SOURCES.md).
- **Six kinds shipped**: car 8,785 · motorcycle 5,916 · van 1,119 · moped
  1,304 · truck 1,043 · bus 389 (mopeds first-class, separate from
  motorcycles; trikes fold into motorcycles as `body_types: ["trike"]`).
- **Reconciliation, not aggregation**: a model publishes when ≥2 independent
  sources corroborate it or one source shows a fleet count no typo could
  produce. ~76,000 raw car name-variants reconciled; the long tail waits in
  a private candidate queue instead of polluting the dataset.
- **Cross-kind dominance prune**: registries miscategorize (tax-scheme "grey
  license plate" registrations put passenger cars in the van class; data-entry
  slips put an Audi A3 in two countries' motorcycle tables) — when ≥97% of a
  model's observed count sits in one kind, minority-kind echoes are dropped
  (662 removed this release, incl. every tax-scheme Audi 'van'). Legit multi-kind nameplates (Toyota Hilux,
  Aixam's microcars) survive on real shares.
- **New open fields** (catalog `schema_version` 2 → 3, additive):
  `availability` (per-country evidence: registration/approval/sales + source
  id), `popularity` (per-country rank + decile from real counts, plus
  `global_decile`), `sources`, `xrefs.tan` (EU type-approval numbers where
  measured).
- **New dist formats**: `vehicles.min.json` (array-packed picker feed),
  `catalog.sqlite` (the full catalog as one SQL file). `dist/vehicles.json`
  gains optional `global_decile` + `availability` per model (schema v2,
  additive — existing consumers unaffected), `region` is now `"global"`.
- **Governance, OpenASN-grade**: generated `ATTRIBUTION.md`, license-drift
  gate, GDPR ingest lint, ±20% delta tripwires, `spotchecks.yml` assertion
  panel, curated `overrides/` with per-line provenance comments + CI lint,
  weekly validate-only + monthly publish workflows, AGENTS.md / DECISIONS.md.
- **Removed**: the two `generations`/`variants` demo records (Suzuki Jimny
  JB74/JB43, BMW M2) — the layers stay reserved in SCHEMA.md and return with
  the depth work; demo data doesn't belong in a corroborated dataset.
- Body types are now kind-aware: cars carry the familiar vocabulary;
  non-car kinds ship none until an honest vocabulary exists for them
  (absent = not catalogued, per the SCHEMA.md absence rule).

## [2026.06.0] - 2026-06-23

Initial public dataset, in the growth architecture.

- **Catalogue** (`catalog/car/`): normalized taxonomy — `makes.json` (47) +
  `models.json` (456), with stable hierarchical ids (`bmw/2-series`).
- **Generations + variants** layers live in the schema and demonstrated on real
  records: Suzuki Jimny `JB74`/`JB43` (generations), BMW `M2` (variant).
- **`dist/vehicles.json`**: flat make→model projection (schema v2) — the stable
  contract the `vehicles` gem consumes. Also published as **`dist/vehicles.csv`**.
- **`manifest.json`**: machine-readable index of kinds, regions, files, counts.
- EU cars derived from RDW Open Data (CC0). Data CC-BY 4.0.

See [SCHEMA.md](SCHEMA.md) for the full shape and the open-vs-API boundary.
