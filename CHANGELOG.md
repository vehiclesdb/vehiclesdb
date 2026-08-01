# Changelog

Dataset releases. Versioned `YYYY.MM.PATCH`; each release is a git tag.

## [2026.08.1] - 2026-08-01 — the fold release

**15,626 → 14,069 model ids** (car 6,238→4,949 · truck 1,224→914 · van
742→616 · bus 409→390 · motorcycle 5,767→5,901 · moped 1,246→1,299). The
drop is not data loss: it is trim levels, body styles, axle codes and
misspellings that had been publishing as if they were separate nameplates,
folded onto the nameplate they belong to. **Ids change in this release** —
see *Migration*.

Where the count went **up** (motorcycle, moped), it is registrations that
were being pooled on a stub or deleted outright now reaching a real record.

### ~25 makes de-duplicated

Each wave measured availability per fold and shipped only where **no
(country, source) evidence was lost**:

- Chevrolet 393→219 (#137) · Volvo 428→157 (#135) · Jaguar/Rover/Land Rover
  348→168 (#136) · Scania+DAF 420→313 (#139) · MG+Austin 281→131 (#140) ·
  Italian marques 304→233 (#145) · Iveco+Dodge (#134) · Mitsubishi+Mazda
  211→149 (#143) · Kia+Škoda 151→96 (#148) · Cadillac+Chrysler+Buick 97→45
  (#150) · Vauxhall+Subaru+Jeep 109→41 (#153) · Saab+Porsche+Bentley 210→73
  (#155) · Pontiac+Aston Martin+BYD 183→104 (#157).
- Harley-Davidson designation clusters: FLSTC 13→1 (#144), FLHT/FLHTK 11→2
  (#149), and Harley's own "Softtail" misspelling folded onto "Softail"
  (#142). Honda CB600/CBR900 8→2 (#133).

### Real nameplates that were being deleted, restored

A curation predicate (`junk?`) was discarding rows **before** they could
become records — a defect class invisible from the catalog side, because a
dropped row leaves nothing to inspect.

- **8 nameplates un-deleted, 115,809 vehicles measured** (#141) — Saab 9-3
  and 9-5 alone accounted for 90,597.
- **13 `New <nameplate>` strings** were being read as noise (#151).
- **20,298 Thai BYD vehicles** rescued from a pooled GenModel (#157).
- Kia+Škoda gained **29,565 GB vehicles** (#148); `truck/daf/lf` **+12,495
  gb** (#139).

### UK two-wheeler designations un-pooled

DfT publishes a family GenModel ("YAMAHA MT") where a nameplate belongs. The
parser read `MT-07` as family `MT-` + capacity 7, failed the capacity range
and dropped every row onto a bare gb-only stub. Both halves are fixed
(#129, #165): the rows now land on `mt-09` (11,474 gb), `mt-07` (9,194),
`mt-10` (5,038), `mt-03` (1,775) and `mt-01` (490), and the same shape is
retired for the XP and XSR families.

### BMW M

`M3`/`M5` and the rest are nameplates, not trims of the N-Series — they no
longer fold into `3`/`5` (#163).

### Migration

- **1,989 new aliases** in `overrides/models/former_ids.yml` (5,782 total,
  covering 2,806 live records). Every retired id resolves to its successor.
- **121 ids manifested** in `overrides/models/removals.yml`, each with a
  reason and a measurement — used where no single alias target exists (a
  pooled stub whose rows split across several real nameplates).
- Nothing disappears silently: the id-contract gate fails the build on any
  retired id that is neither aliased nor manifested.

### Also

- Zenodo metadata + `CITATION.cff`, so releases archive with a DOI.
- 2,112 new curation keys in `overrides/models/renames.yml`, each carrying a
  `#` comment with its source.

## [2026.08.0] - 2026-08-01 — the correction release

All 14 sources refreshed to their mid-2026 snapshots. This release also
completes the **second demotion wave** the hysteresis design defers by one
release (94 ids across kinds: 4 car, 50 motorcycle, 6 moped, 28 truck, 6 bus —
ids that had been surviving on multi-source grace fell below the single-source
threshold after the Irish rank correction and related fixes).

This release corrects identity errors rather than adding data. Two parser bugs
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
