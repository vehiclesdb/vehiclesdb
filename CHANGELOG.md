# Changelog

Dataset releases. Versioned `YYYY.MM.PATCH`; each release is a git tag.

## [2026.08.2] - 2026-08-02 — the false-green release

**13,809 models across 859 makes (14,069 → 13,809, −260). The count fell and no
evidence was lost: 384 migration entries carry every retired id forward.** This
release retires nameplates that were never nameplates — horsepower ratings, door
counts, power codes, body words and trim strings that registers had filed as if
they were models. Every retirement is an alias or a removal manifest, so a
consumer resolving an old id still lands on the right record. Registrations are
conserved exactly: the Lancia fold, to take one measured example, moved 79
vehicles between ids with a whole-corpus total of 72,127,507 before and after.

Built on a **frozen source cache**: this is a correctness release, so the data
axis was deliberately held still and the entire diff is attributable to curation
and pipeline fixes rather than upstream drift.

| kind | 2026.08.1 | 2026.08.2 | Δ |
|---|---:|---:|---:|
| car | 4,949 | 4,895 | −54 |
| van | 616 | 618 | +2 |
| motorcycle | 5,901 | 5,744 | −157 |
| moped | 1,299 | 1,306 | +7 |
| truck | 914 | 867 | −47 |
| bus | 390 | 379 | −11 |

### The type-approval crosswalk was losing a quarter of itself, silently

`reconciler.rb` capped each record at 25 EU type approvals. The cap **refused**
rather than evicted, so output was byte-identical build after build and nothing
— no id diff, no count change, no lint — could see it. 185 records sat at
exactly 25 and only **12 actually had 25**; the other **173 were truncated,
losing 5,754 approvals on every build** (`car/volkswagen/golf` kept 25 of 379,
`car/bmw/3-series` 25 of 328). The cap was an arbitrary constant, never
revisited since the initial v2 commit, and PRD-3 §61 argues the opposite: the
TAN⇄id crosswalk is a flagship asset.

Approval entries **16,243 → 21,997 (+35%)**. Nothing replaces the cap, because
truncation cannot be silent if truncation does not happen; two loud things that
never drop a row take its place — a tripwire that fails the build with the data
intact, and a per-build line reporting TAN-join coverage (`pipeline#155`).

It surfaced because a new gate caught the sliver of it that coincided with a
fold: the DAF XF lineage was delisting 19 approvals into a successor already at
the cap (`pipeline#147`). Both are in this release; the gate stays.

### Nameplates that were never nameplates

- **Body words** — 59 ids retired (`hardtop`, `roadster`, `cabriolet` and
  kin), with the 21 real nameplates in the same shape proved untouched (#209)
- **Horsepower ratings** — DAF XF/XG/XD, 19 ids fold onto 3 (#176); the LF and
  CF power suffixes, 26 ids onto 2 (#199)
- **Door counts** — 1,011 rename keys covering 11,169 vehicles, folding onto
  397 already-published records with zero new nameplates (#179)
- **Power codes** — Land Rover, 9 candidate ids onto 2 live records (#193)
- **Type codes** — Suzuki §A, 30 records onto their type-code nameplates (#192)
- **Sub-brand pooling** — Mercedes-AMG's 57,573-vehicle GB residue decomposed
  onto 19 already-live records via a Model-column whitelist, **zero ids minted
  and zero strings unresolvable** (#206); the bus O-number boundary and the
  Marco Polo truncation, 12 ids (#204)
- **Marque waves** — Lexus (#194), MINI (#200), Bentley's GTC ladder (#178),
  VW's New Beetle family folded onto `beetle` rather than minting a
  `new-beetle` (#195), the XJ re-cut (#196), BYD's tail wave (#210)

### Retroactive UK fleet history — a decade, at parse cost

DfT's VEH0120 extract ships **47 quarterly columns and the adapter read one**.
The other 46 (`2025-Q4 … 2014-Q3`) are now filed as 184,092 dated
(record, quarter) observations — same file, same licence, **no additional
fetch, not one extra cache byte**. The public catalog is byte-identical as a
result: identity is still decided by the newest quarter alone and the history
rides as a passenger (`pipeline#148`).

### Powertrains, Phase 1 — private

Propulsion derived from eight registers (ES, LU, DE, FI, MY, UA, US, CA) into a
closed 9-code vocabulary, reaching **8,984 of 13,869 records (64.8%)**. Evidence
unions across sources exactly as `availability` does — never majority-wins — so
a nameplate offered as both BEV and diesel carries both. **Nothing publishes in
this release**; the open field is Phase 3 (`pipeline#153`). The three registers
that cannot answer the question are documented rather than left as a silent gap
(#212).

### Instruments

Several checks that were believed to bind did not, and this release fixes the
checks as well as the data:

- The **licence gate** no longer passes on unverified pins — a frozen cache
  used to make all 14 pinned licence texts look fresh and the gate
  short-circuited having compared nothing (#177)
- The **corpus vintage pin** was gating structural claims that any vintage can
  answer, leaving the Model-column router's mint guard inert on every CI run;
  counts stay pinned and exact, set membership now runs always (`pipeline#152`)
- An **inert-key detector** reports dead override keys — 110 of 7,946 (1.38%),
  ablation-proved in both directions (`pipeline#151`)
- An **alias/name collision detector**, report-only (#201), and 11 class-A
  collisions dispositioned — 2 retired, 9 documented as correct (#202)
- **Rename-value liveness** filed as a silent-failure class: a surviving rename
  whose value names a retired id resurrects it (#197)
- `report:junk_drops` documented blind to rows that die before the rename
  lookup (#189), and the reachability test's two blind spots filed (#180)

### Also

Zenodo DOI rollout with `CITATION.cff` (concept DOI `10.5281/zenodo.21744943`),
the release archive boundary fixed so the internal process layer stops leaking
into Zenodo archives while `data/licenses/` stays for provenance, the release
channel fan-out re-keyed to the release event rather than its creator (#172),
and `OWNERSHIP.yml` regenerated.

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
