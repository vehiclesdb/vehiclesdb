# Changelog

Dataset releases. Versioned `YYYY.MM.PATCH`; each release is a git tag.

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
