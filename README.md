# VehiclesDB — open vehicle data for builders

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21744943.svg)](https://doi.org/10.5281/zenodo.21744943)

**The makes and models that official vehicle registers and type-approval
catalogues agree on, with one stable id per nameplate, per-country evidence and popularity — as one CC BY 4.0 dataset
you can load into your own database in five minutes.** Builders use it for
parts catalogues with a compatibility filter, marketplaces, garage and booking
forms, fleet and plate apps — above all in markets that have no clean local
vehicle catalogue.

## What's inside

All numbers below are generated from this release's `manifest.json` and
`catalog/` by `scripts/gen_readme_stats.rb`. Nobody types them by hand.

<!-- BEGIN GENERATED: stats (scripts/gen_readme_stats.rb) -->
**Dataset `2026.10.3`** (built 2026-10-10) — **15,068 models · 934 makes · 6 kinds · 18 countries**

| kind | models | makes |
|---|---:|---:|
| car | 5,541 | 315 |
| motorcycle | 6,033 | 266 |
| moped | 1,399 | 315 |
| van | 739 | 130 |
| truck | 947 | 95 |
| bus | 409 | 94 |
| **all** | **15,068** | **934** distinct |

Models with evidence in each country (a model counts once per country it is found in, so the column does not sum to the total):

| country | official source | licence | evidence | models | car | motorcycle | moped | van | truck | bus |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|
| Netherlands (`nl`) | [Dutch vehicle register (RDW Open Data)](https://opendata.rdw.nl/Voertuigen/Open-Data-RDW-Gekentekende_voertuigen/m9d7-ebf2) | [CC0-1.0](https://data.overheid.nl/dataset/11441-open-data-rdw--gekentekende-voertuigen) | registration | 12,919 | 4,714 | 5,201 | 1,267 | 654 | 859 | 224 |
| Finland (`fi`) | [Finnish vehicle register open data (Traficom)](https://tieto.traficom.fi/en/datatraficom/open-data) | [CC-BY-4.0](https://tieto.traficom.fi/en/datatraficom/open-data) | registration | 7,849 | 3,149 | 2,650 | 557 | 473 | 802 | 218 |
| New Zealand (`nz`) | [New Zealand Motor Vehicle Register (Waka Kotahi NZTA open data)](https://opendata-nzta.opendata.arcgis.com/datasets/NZTA::motor-vehicle-register/about) | [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/legalcode.en) | registration | 6,145 | 3,156 | 2,426 | 434 | — | — | 129 |
| United Kingdom (`gb`) | [UK vehicle licensing statistics (DfT/DVLA table VEH0120)](https://www.gov.uk/government/statistical-data-sets/vehicle-licensing-statistics-data-files) | [OGL-UK-3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) | registration | 4,073 | 1,651 | 1,814 | 116 | 275 | 121 | 96 |
| Switzerland (`ch`) | [Strassenverkehrsamt Kanton Thurgau — Fahrzeugbestand Kanton Thurgau am 01.01.2026](https://data.tg.ch/explore/dataset/djs-stv-7/) | [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/) | registration | 3,885 | 1,573 | 1,810 | 121 | 201 | 143 | 37 |
| Ukraine (`ua`) | [Ukrainian vehicle registration operations (MVS/HSC open data)](https://data.gov.ua/dataset/06779371-308f-42d7-895e-5a39833375f0) | [CC-BY-4.0](https://data.gov.ua/dataset/06779371-308f-42d7-895e-5a39833375f0) | registration | 3,416 | 1,704 | 1,439 | 100 | — | — | 173 |
| Norway (`no`) | [Statens vegvesen — Periodisk kjøretøykontroll (PKK)](https://dataut.vegvesen.no/dataset/periodisk-kjoretoy-kontroll) | [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/deed.no) | registration | 2,907 | 1,983 | — | — | 286 | 477 | 161 |
| Spain (`es`) | [Spanish vehicle registrations (DGT microdata, MATRABA)](https://www.dgt.es/menusecundario/dgt-en-cifras/matraba-listados/matriculaciones-automoviles-mensual.html) | [Ley-37/2007](https://datos.gob.es/es/aviso-legal) | registration | 2,690 | 1,222 | 906 | 121 | 192 | 193 | 56 |
| Australia (`au`) | [Australian registered road vehicles by make and model (BITRE Road Vehicles Australia)](https://data.gov.au/data/dataset/road-vehicles-australia-january-2025) | [CC-BY-3.0-AU](https://creativecommons.org/licenses/by/3.0/au/) | registration | 2,499 | 1,347 | 852 | — | 132 | 110 | 58 |
| Luxembourg (`lu`) | [Luxembourg vehicle register operations (SNCA)](https://data.public.lu/en/datasets/operations-delta-des-vehicules-au-luxembourg/) | [CC0-1.0](https://data.public.lu/en/datasets/operations-delta-des-vehicules-au-luxembourg/) | registration | 2,412 | 1,121 | 967 | 50 | 154 | 97 | 23 |
| Israel (`il`) | [Israel Ministry of Transport — vehicle register (data.gov.il)](https://data.gov.il/dataset/degem-rechev-wltp) | [facts-credit-data.gov.il-terms-of-use](https://data.gov.il/he/terms-of-use) | registration | 1,495 | 784 | 392 | 14 | 98 | 171 | 36 |
| United States (`us`) | [US EPA/DOE fuel economy vehicle catalog (fueleconomy.gov)](https://www.fueleconomy.gov/feg/download.shtml) | [US-PD](https://www.energy.gov/web-policies) | approval | 1,212 | 1,212 | — | — | — | — | — |
| Canada (`ca`) | [Canadian fuel consumption ratings (Natural Resources Canada)](https://open.canada.ca/data/en/dataset/98f1a129-f628-4ce4-b24d-6f16bf24dd64) | [OGL-Canada-2.0](https://open.canada.ca/en/open-government-licence-canada) | approval | 984 | 984 | — | — | — | — | — |
| Thailand (`th`) | [Thai new vehicle registrations by brand and model (DLT)](https://gdcatalog.dlt.go.th/dataset/59a045dc-3ec4-4908-b035-ba789101b7f5) | [TH-OpenDataCommon](https://gdcatalog.dlt.go.th/dataset/59a045dc-3ec4-4908-b035-ba789101b7f5) | registration | 803 | 355 | 431 | — | 17 | — | — |
| Malaysia (`my`) | [Malaysian car registration transactions (JPJ via data.gov.my)](https://data.gov.my/data-catalogue/registration_transactions_car) | [CC-BY-4.0](https://data.gov.my/data-catalogue/registration_transactions_car) | registration | 536 | 536 | — | — | — | — | — |
| Germany (`de`) | [German new car registrations by make and model series (KBA FZ10)](https://www.kba.de/DE/Statistik/Produktkatalog/produkte/Fahrzeuge/fz10/fz10_gentab.html) | [DL-DE-BY-2.0](https://www.govdata.de/dl-de/by-2-0) | registration | 408 | 378 | — | — | 30 | — | — |
| Ireland (`ie`) | [Irish new private car licensing statistics (CSO table TEM20)](https://data.cso.ie/table/TEM20) | [CC-BY-4.0](https://www.cso.ie/en/aboutus/whoweare/copyrightpolicy/) | registration | 238 | 238 | — | — | — | — | — |
| Argentina (`ar`) | [Argentine initial car registrations (DNRPA microdata)](https://datos.jus.gob.ar/dataset/inscripciones-iniciales-de-autos) | [CC-BY-4.0](https://datos.gob.ar/acerca/seccion/marco-legal) | registration | 208 | 208 | — | — | — | — | — |

`registration` = the vehicle is on that country's register; `approval` = type-approved or certified for sale there. Full per-source notes: [SOURCES.md](SOURCES.md).
<!-- END GENERATED: stats -->

A model ships when **two independent official sources agree**, or when one
source shows a fleet count no typo could produce. You get the Golf and the
Corolla, and also the Perodua Myvi, the Honda Wave 125i and the Bogdan A092,
without the register noise: parser artefacts, duplicates, trims posing as
nameplates and non-vehicles are reconciled away before anything publishes.

## Load it into your database in 5 minutes

Pick the file for the job. Every file below is in this repo and on jsDelivr.
The `dist/` files, `manifest.json` and `ATTRIBUTION.md` are also assets of each
[GitHub release](https://github.com/vehiclesdb/vehiclesdb/releases), and the CSV,
Parquet, JSON and SQLite files are mirrored on
[Hugging Face](https://huggingface.co/datasets/vehiclesdb/vehiclesdb).

| you want | use | shape |
|---|---|---|
| a make → model picker, loaded at runtime | `dist/vehicles.min.json` | nested make → models, array-packed (smallest) |
| your own Postgres / MySQL / SQL Server | `dist/vehicles.csv` | one row per model |
| SQL right now, no server | `dist/catalog.sqlite` | `makes`, `models`, `availability`, `popularity`, `meta` |
| pandas, polars, DuckDB, Spark | `dist/vehicles.parquet` | the CSV table as Parquet |
| everything we know about each record | `catalog/<kind>/models.json` | per-country ranks, evidence, sources, type-approval xrefs |
| Ruby / Rails | the [`vehicles`](https://github.com/vehiclesdb/vehicles) gem | bundled offline snapshot + helpers + MCP server |

Where to fetch them:

```bash
# Pinned release asset (reproducible; recommended for seeds and CI)
https://github.com/vehiclesdb/vehiclesdb/releases/download/v<version>/<file>
# Always the newest release
https://github.com/vehiclesdb/vehiclesdb/releases/latest/download/<file>
# CDN (jsDelivr), pinned or latest; paths as in this repo (dist/…, catalog/…)
https://cdn.jsdelivr.net/gh/vehiclesdb/vehiclesdb@v<version>/dist/vehicles.min.json
https://cdn.jsdelivr.net/gh/vehiclesdb/vehiclesdb@latest/dist/vehicles.min.json
```

Release assets are the top-level files (`vehicles.csv`, `catalog.sqlite`,
`vehicles.parquet`, `vehicles.json`, `vehicles.min.json`, `manifest.json`,
`ATTRIBUTION.md`); the full-fidelity `catalog/` tree is on the CDN and in git.

### Postgres

<!-- BEGIN GENERATED: load-postgres (scripts/gen_readme_stats.rb) -->
```bash
curl -sSLO https://github.com/vehiclesdb/vehiclesdb/releases/download/v2026.10.3/vehicles.csv
psql "$DATABASE_URL" <<'SQL'
CREATE TABLE vehiclesdb_models (
  kind                     text NOT NULL,
  make_slug                text NOT NULL,
  make_name                text NOT NULL,
  model_slug               text NOT NULL,
  model_name               text NOT NULL,
  body_types               text,
  countries                text,
  regions                  text,
  global_popularity_decile smallint,
  aliases                  text,
  former_ids               text,
  mass_popularity_decile   smallint,
  PRIMARY KEY (kind, make_slug, model_slug)
);
\copy vehiclesdb_models FROM 'vehicles.csv' WITH (FORMAT csv, HEADER true)
SQL
```

The column list above is generated from `v2026.10.3`'s CSV header. Since 2026.07.2, columns
are only ever appended between releases, never renamed or reordered; when you upgrade, `ALTER TABLE …
ADD COLUMN` the new ones (see CHANGELOG.md) and reload. `countries`, `regions`,
`body_types`, `aliases` and `former_ids` are `|`-separated lists
(`string_to_array(countries, '|')`).
<!-- END GENERATED: load-postgres -->

Key your own tables (parts, listings, prices) on `(kind, make_slug,
model_slug)`. That triple is the VehiclesDB id, and ids are stable forever.

**Prisma / TypeORM.** Create the table with the SQL above, then let the ORM
read it rather than hand-writing a model. With Prisma, `npx prisma db pull`
generates the `vehiclesdb_models` model with its composite
`@@id([kind, make_slug, model_slug])`. With TypeORM, map
`@Entity("vehiclesdb_models")` with three `@PrimaryColumn()`s (`kind`,
`make_slug`, `model_slug`), `text` columns for the rest and `smallint` for
`*_decile`. Load the data with the `\copy` above from `psql` (`\copy` is a psql
command, not SQL, so `prisma db execute` or `queryRunner.query` cannot run it),
or with your Postgres driver's `COPY … FROM STDIN` support. Avoid inserting row
by row.

### SQLite

```bash
curl -sSLO https://github.com/vehiclesdb/vehiclesdb/releases/latest/download/catalog.sqlite
# Ukraine's 20 most registered car models: sort by the per-country rank
# (the deciles on `models` are global, never a per-country order)
sqlite3 catalog.sqlite "
  SELECT p.rank, mk.name, m.name
  FROM popularity p
  JOIN models m  ON m.id = p.model_id  AND m.kind = p.kind
  JOIN makes mk  ON mk.id = m.make_id  AND mk.kind = m.kind
  WHERE p.kind = 'car' AND p.country = 'ua'
  ORDER BY p.rank
  LIMIT 20"
```

Copy the file into your app as is, or `.dump` it into another database.
Table definitions: [SCHEMA.md](SCHEMA.md).

### DuckDB, pandas, polars

```bash
duckdb -c "SELECT kind, count(*) FROM 'https://github.com/vehiclesdb/vehiclesdb/releases/latest/download/vehicles.parquet' GROUP BY kind"
```

```python
import pandas as pd
df = pd.read_parquet("vehicles.parquet")   # or pd.read_csv("vehicles.csv")
```

### At runtime, from the CDN

```js
const res = await fetch("https://cdn.jsdelivr.net/gh/vehiclesdb/vehiclesdb@latest/dist/vehicles.json");
const { makes } = await res.json();   // [{ name, slug, kinds, models: [{ name, slug, kind, … }] }]
```

Pin a version (`@v<version>`) when you need the list not to change under you,
and cache the response. Data releases are versioned `YYYY.MM.PATCH`: usually
one a month, plus patch releases when a fix can't wait.

### Ruby / Rails

```ruby
gem "vehicles"            # data ships inside the gem; works offline
Vehicles.models("VW")     # alias-aware: "VW" → Volkswagen's model names
```

### Keeping your copy current

- **Ids never change meaning.** When a record is renamed or merged, its old
  id is listed in the surviving record's `former_ids` (CSV column
  `former_ids`, kind-prefixed, e.g. `car/alfa-romeo/alfa147`). On upgrade,
  repoint any row you stored under a former id, then upsert on
  `(kind, make_slug, model_slug)`.
- **Columns and fields are only ever appended** (since 2026.07.2). A new release never renames
  or reorders a CSV column, and absent JSON keys mean *not catalogued yet*.
- **What changed** is in each release's [CHANGELOG.md](CHANGELOG.md) section.
  Watch this repo with *Custom → Releases* to be notified of each release.

## The files

```
manifest.json              index: version, kinds, counts, countries, sources, files
catalog/<kind>/            THE database: full records
  makes.json               [{ id, slug, name }]
  models.json              [{ id, make_id, slug, name, kind, body_types?,
                              availability, popularity?, sources, xrefs? }]
dist/                      projections for the common cases
  vehicles.json            nested make→models (what the gem bundles)
  vehicles.min.json        the same, array-packed (pickers)
  vehicles.csv             flat table, one row per model
  vehicles.parquet         the same table as Parquet
  catalog.sqlite           SQL access to everything above
ATTRIBUTION.md             generated per release: the required CC BY notices
SCHEMA.md                  shapes + the growth/versioning contract
SOURCES.md                 every source: licence, cadence, measured gotchas
CHANGELOG.md               what each release added, retired and why
overrides/  spotchecks.yml the human-curated inputs (see "Send corrections back")
```

Ids are stable forever (kind + make + model slugs, e.g. `volkswagen/golf`
within `catalog/car/`). Renames alias, nothing is silently deleted, and
absent optional keys mean *not catalogued yet*, never a schema change.
Details: [SCHEMA.md](SCHEMA.md).

## What this data means (read this once)

A model's presence means we found evidence of it in at least one covered
market's official sources (registration, type approval, or verified sales
reporting) — see each record's `sources` and `availability.evidence`. Absence
means *we haven't catalogued it yet*, not that it doesn't exist.
`availability` is evidence of presence, **not** proof a vehicle was officially
marketed there (grey imports count — they're real vehicles on real roads).
Year ranges from registration data are accurate to ±1 year by construction.
Nameplate granularity: one model covers its trims unless `variants` says
otherwise; two-wheelers keep displacement granularity (`Wave110i` and
`Wave125i` are how riders and registers both speak). Popularity deciles are
measured from real registration/fleet counts where `confidence: "measured"`
and proxied from public-attention signals where `confidence: "proxy"` — the
biases of each are documented in SCHEMA.md.

**Wrong users:** if you need VIN decoding (use [NHTSA vPIC](https://vpic.nhtsa.dot.gov/api/)),
valuations, vehicle history, or insurance rating data, this is not your
dataset.

## Built with VehiclesDB

Public projects that use the open data and name VehiclesDB in their code or
docs. Listed by repository.

| project | what it is | how it loads the data |
|---|---|---|
| [Kolben](https://kolben.store) ([#308](https://github.com/vehiclesdb/vehiclesdb/issues/308)) | auto-parts catalogue for Paraguay with a brand → model compatibility filter | uses Argentina's availability as a regional proxy (per #308); make/model list served from its own backend |
| [Parca-avcisi](https://github.com/zamansepeti43/Parca-avcisi) | Turkish auto-parts marketplace (Parça Avcısı), brand → model → year → version filter | VehiclesDB as the base catalogue, extended locally for Turkey |
| [carplates-v2](https://github.com/Krak86/carplates-v2) | Ukrainian licence-plate and VIN lookup app | ingests into Postgres; uses availability, popularity and aliases |
| [VIN-matrix](https://github.com/Denys9Ri/VIN-matrix) | CRM for auto-service and parts workflows | make/model combobox over the car, van and truck catalogues |
| [parts-ai](https://github.com/Mirkl213/parts-ai) | Telegram parts bot: VIN (WMI) decoding and OEM cross-references | listed as a data source |
| [MotorAtlas](https://github.com/axionaut/MotorAtlas) | vehicle comparison and evidence app | seed catalogue built from VehiclesDB at build time |
| [AutoTech-Europe](https://github.com/multiservismalaga-cpu/AutoTech-Europe) | European vehicle identification with source traceability | model base from VehiclesDB |
| [dealnbuy-vehicle-data](https://github.com/Arjunarunachalan/dealnbuy-vehicle-data) | vehicle-marketplace data package for a web and a React Native app | bundled JSON snapshot, no runtime dependency |
| [Flexride-web](https://github.com/Delightsheriff/Flexride-web) | car-rental marketplace | seed script pulls the taxonomy |
| [lrs-motors-mini-app](https://github.com/lrgroup-bot/lrs-motors-mini-app) | Telegram Mini App for dealership management | proxies `dist/vehicles.json` from jsDelivr |
| [otiodojoca](https://github.com/jaaaneves-art/otiodojoca) | Portuguese rural-culture portal (O Tio do Joca) whose marketplace syncs a car catalogue | fetches `catalog/car/makes.json` and `models.json` from jsDelivr into Supabase |
| [RideSeat-Backend](https://github.com/timileyin42/RideSeat-Backend) | ride-sharing / seat-booking backend | fetches `catalog/<kind>/makes.json` at runtime |
| [plates.quest](https://github.com/theaquarium/plates.quest) | licence-plate spotting site | uses the `plates/` dataset (plate colours) |

Built something on VehiclesDB? Open a PR adding one row here. Listed and
would rather not be? Open an issue and we will remove the row.

## Send corrections back

You know your market better than any register does. Fixes made upstream
reach every builder in your country, and every next release.

- **A wrong name, a junk model, a missing alias or spelling** → edit
  `overrides/` (every line carries a `#` comment saying why, with a source
  URL for anything non-obvious; `ruby scripts/lint_overrides.rb` checks it in
  seconds).
- **A model that should never disappear** → add a row to `spotchecks.yml`.
- **Models you added locally.** Example:
  [Parça Avcısı](https://github.com/zamansepeti43/Parca-avcisi) started from
  VehiclesDB and extended it for the Turkish market. That is exactly what we
  want upstream. Open an issue listing the makes and models you added, the
  spellings you mapped, and, for each, the official source that shows it: a
  register, a type-approval list, or the manufacturer's own page. Spellings
  and aliases go straight into `overrides/`. A new model publishes once it
  meets the publish rule (two independent official sources, or one official
  count no typo could produce); until then it is filed in
  [DEBT.md](https://github.com/vehiclesdb/vehiclesdb/blob/main/DEBT.md) with your evidence, and your list tells us which
  country's register to ingest next.
- **An official open source we're missing**, especially outside Europe →
  open an issue with the URL and its licence text. That is the
  highest-leverage contribution there is.

The build outputs (`catalog/`, `dist/`, `manifest.json`, `ATTRIBUTION.md`)
are generated; don't PR them. House rules:
[AGENTS.md](https://github.com/vehiclesdb/vehiclesdb/blob/main/AGENTS.md)
(repo only, not shipped in release archives) · Why things are the way they
are: [DECISIONS.md](DECISIONS.md)

## The Open Contract

1. **The skeleton is open forever.** Ids, names, taxonomy structure, body
   types, year ranges, availability evidence, popularity deciles, and the
   type-approval crosswalks are CC-BY 4.0 in perpetuity. We will never
   paywall them, relicense them restrictively, or delete them. (This niche
   has seen four documented free-tier rug-pulls; this contract is the
   antidote, in writing.)
2. **What funds the project:** depth (full specs and configurations, images
   beyond the free silhouettes, absolute popularity counts and time series),
   freshness SLAs, a hosted API, redistribution licenses with indemnity, and
   support. Paid never means crippling open. Commercial inquiries:
   `commercial@vehiclesdb.com`.
3. **Trademark:** "VehiclesDB" is the project's mark; forks must rename (the
   OpenStreetMap precedent — data open, brand protected). Some company and
   product names in this dataset may be trademarks or registered trademarks
   of individual companies and are respectfully acknowledged; they appear as
   plain-text facts, with no logos and no implied endorsement.
4. **Provenance promise:** every record carries its sources; every source's
   license text is pinned in-repo (`data/licenses/`); the build fails rather
   than ship on license drift.

## Where the data comes from

Official, openly-licensed sources only: vehicle registers, type-approval
catalogues, and government statistics. The per-country table in
[What's inside](#whats-inside) lists every source in this release with its
licence. Each source's update cadence and measured quirks:
[SOURCES.md](SOURCES.md). The exact attribution notices each licence
prescribes: [ATTRIBUTION.md](ATTRIBUTION.md). ShareAlike, NC, and scraped
sources never enter this dataset, by build gate, not by promise.

Fresh data lands monthly (`YYYY.MM.PATCH` versions: the version *is* the
freshness), with weekly automated validation against upstream drift in
between.

## License & attribution (required)

Data: [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/), free for
any use, including commercial. The licence condition, as
[ATTRIBUTION.md](ATTRIBUTION.md) states it:

> Attribution is a CONDITION of the CC-BY 4.0 license (§3(a)) — every
> public use of this data must visibly credit VehiclesDB with a link.
> The form we request:
>
> > Vehicle data by [VehiclesDB](https://vehiclesdb.com)
>
> - **Website**: a visible, followable link — e.g. in your footer:
>   `<a href="https://vehiclesdb.com">Vehicle data by VehiclesDB</a>`
> - **App / no website**: name us in the app description or an
>   about/credits screen: "Vehicle data by VehiclesDB (vehiclesdb.com)".
> - **Papers / datasets**: cite the repo URL and the version you used.
>
> The upstream notices below are UNCONDITIONAL: they discharge the
> source registers' own license terms (OGL v3, CC-BY, dl-de/by-2-0)
> and apply to every consumer of this data, under every VehiclesDB
> license, commercial included.

The upstream notices it refers to are in [ATTRIBUTION.md](ATTRIBUTION.md).

Where it fits, link the specific make/model page you used (e.g.
`https://vehiclesdb.com/cars/seat/leon`) instead of the homepage: more
useful for your readers, and for us.

**Copy-paste kit:** [ATTRIBUTION-KIT.md](ATTRIBUTION-KIT.md) has the line
in 12 languages (en es fr de pt it ro tr pl uk hu nl), an SVG badge and a
machine-readable `footers.json`. More forms (BibTeX, API consumers):
[vehiclesdb.com/attribution](https://vehiclesdb.com/attribution).

Prefer not to credit **VehiclesDB**, or need the enriched private layer
(production runs, exact per-country registration counts, historic
series)? That is the **commercial license** →
[vehiclesdb.com](https://vehiclesdb.com). Note: it waives only OUR
credit — the upstream register notices in
[ATTRIBUTION.md](ATTRIBUTION.md) apply under every license, commercial
included (they are the registers' own terms, not ours to waive).

### Citing this dataset

Use GitHub's "Cite this repository" button (powered by [CITATION.cff](CITATION.cff)), or:

<!-- BEGIN GENERATED: cite (scripts/gen_readme_stats.rb) -->
> VehiclesDB. (2026). *VehiclesDB: The open source vehicle database*
> (Version 2026.10.3) [Data set]. Zenodo.
> https://doi.org/10.5281/zenodo.21744943

```bibtex
@misc{vehiclesdb,
  title        = {{VehiclesDB}: the open source vehicle database},
  author       = {{VehiclesDB}},
  year         = {2026},
  howpublished = {\url{https://github.com/vehiclesdb/vehiclesdb}},
  doi          = {10.5281/zenodo.21744943},
  note         = {Open dataset, CC BY 4.0, version 2026.10.3}
}
```

Replace the version with the one you actually used (`manifest.json` → `version`).
<!-- END GENERATED: cite -->
