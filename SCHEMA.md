# Schema

This repo is the **open VehiclesDB taxonomy** — the catalogue of *what
vehicles exist, how they're organized, how popular they are, and where they're
found*. It's designed to grow into **every kind of vehicle** and to **deepen**
(generations, variants, configs) without ever breaking what's already
published. This document is the source of truth for the shape.

Current versions: **catalog `schema_version: 3`** · **dist `schema_version: 2`**
(see `manifest.json`).

## The two things we publish

| Artifact | What | Who reads it |
|---|---|---|
| **`catalog/`** | The normalized taxonomy — the database. Per **kind** (`catalog/car/…`), split into `makes.json` + `models.json`, with availability, popularity, sources, and crosswalks. | Anyone who wants the structured data; analytics; tooling |
| **`dist/`** | Flat **projections**: `vehicles.json` (nested, the [`vehicles`](https://github.com/vehiclesdb/vehicles) gem contract), `vehicles.min.json` (array-packed), `vehicles.csv`, `vehicles.parquet`, `catalog.sqlite`. | Pickers, spreadsheets, SQL, the gem, CDN users |

`dist/` is generated from `catalog/`. Most consumers want `dist/`; the
catalogue is for when you need everything.

## The hierarchy

Everything hangs off a stable, hierarchical, path-style **id** so any layer
can be referenced and deepened independently. Adding a layer to a record is
purely additive — never a breaking change.

```
Kind            car · motorcycle · moped · van · truck · bus     (active)
                train · plane · ship · agricultural              (reserved)
└─ Make         bmw                                  id: "bmw"
   └─ Model     BMW 2 Series                         id: "bmw/2-series"
      ├─ Generation   (optional)  chassis/platform   id: "bmw/2-series/g87"
      └─ Variant      (optional)  submodel/trim      id: "bmw/2-series/m2"
         └─ Config/Spec  ← DEPTH (the paid layer), keyed by these ids:
                            engine, power, drivetrain, dimensions, per model-year …
```

Kind is a *dimension*, not a field to guess from: the same nameplate can
exist in several kinds (`volkswagen/transporter` the van, and its camper
sibling in cars) — each kind's files stand alone.

**Open vs. paid.** This repo is the **skeleton** — identity, structure,
availability evidence, popularity deciles — CC-BY 4.0 forever (see the README
Open Contract). Per-config **specs and media** are the future
[VehiclesDB API](https://vehiclesdb.com), keyed by these same ids. The
`generations`/`variants` layers are part of the *open* schema (reserved,
shapes below) and fill in over time.

## Make

`catalog/<kind>/makes.json` — array of:

| Field | Type | Notes |
|---|---|---|
| `id` | string | stable, e.g. `"bmw"` |
| `slug` | string | lowercase ASCII (NFKD-folded — `škoda` → `skoda`) |
| `name` | string | `"BMW"` |
| `country` | string? | ISO-3166 alpha-2 of origin *(optional, future)* |
| `aliases` | string[]? | alternate spellings *(optional, future)* |

## Model (nameplate)

`catalog/<kind>/models.json` — array of:

| Field | Type | Notes |
|---|---|---|
| `id` | string | `"<make>/<model>"`, e.g. `"bmw/2-series"` (kind-scoped by file) |
| `make_id` | string | `"bmw"` |
| `slug` | string | bare model slug, e.g. `"2-series"` |
| `name` | string | `"2 Series"` |
| `kind` | string | `car` · `motorcycle` · `moped` · `van` · `truck` · `bus` |
| `body_types` | string[]? | see *Body types* below — **absent = not catalogued** |
| `availability` | object[] | where the model is evidenced — see below |
| `popularity` | object? | measured popularity — see below; absent = no counts yet |
| `sources` | string[] | ids of the sources that evidence this record (see SOURCES.md) |
| `xrefs` | object? | crosswalks; today `{"tan": [...]}` EU type-approval numbers where measured |
| `year_start` / `year_end` | int? | nameplate lifespan *(optional, future)* |
| `generations` | object[]? | reserved layer — shape below |
| `variants` | object[]? | reserved layer — shape below |

**The absence rule (binding):** absent optional keys mean **"not catalogued
yet"** — never "no" and never a schema change. Code against presence, not
against versions.

### Body types

Vocabulary: `hatchback sedan wagon suv mpv coupe convertible roadster pickup
van trike`. A nameplate can span bodies (`volkswagen/golf` →
`["hatchback", "wagon"]` — the estate folds into the nameplate).

Body types are **kind-aware**: cars always carry them; two-wheelers only for
`trike`; vans/trucks/buses don't yet (no honest vocabulary derivable from
registers — absent, per the absence rule, until one exists).

### Availability

```json
"availability": [
  { "country": "nl", "evidence": "registration", "source": "nl_rdw" },
  { "country": "us", "evidence": "approval",     "source": "us_fueleconomy" }
]
```

| `evidence` | Means |
|---|---|
| `registration` | vehicles of this model are registered / on the road there |
| `approval` | type-approved / certified for sale there (catalog evidence) |
| `sales` | verified sales reporting |

Availability is **evidence of presence, not marketing history**: New
Zealand's grey-imported JDM models are correctly listed as available in `nz`.

### Popularity

```json
"popularity": {
  "global_decile": 2,
  "by_country": {
    "nl": { "rank": 1, "decile": 1, "confidence": "measured" },
    "th": { "rank": 305, "decile": 9, "confidence": "measured" }
  }
}
```

- `rank` — position among all models of that kind in that country, from real
  registration/fleet counts. `decile` — 1 (top 10%) … 10.
- `global_decile` — the mean of the model's per-country deciles, equal
  country weight, rounded to a decile.
- `confidence` — `"measured"` = derived from official counts we hold;
  `"proxy"` (future tier) = public-attention signals calibrated on measured
  markets.

**Documented biases (read before ranking things):**

1. *Coverage bias:* "global" means "across the covered countries" (see
   `manifest.json.countries`). Europe is over-represented today; a
   Europe-dominant model scores better than a China-dominant one until more
   registers land.
2. *Equal country weight:* Luxembourg's deciles count as much as the UK's.
   This is deliberate (fleet-weighting would just re-derive "Europe"), but it
   means `global_decile` answers "is this model popular in many places?", not
   "how many exist?".
3. *Fleet vs. new-registration mix:* some sources count the whole fleet
   (NL/FI/NZ — vintage models rank), others only recent registrations
   (ES/DE/IE — recency-biased). Per-country semantics: SOURCES.md.
4. *Absolute counts are not open:* deciles/ranks are honest at this layer's
   accuracy; exact counts and time series are the depth layer.

## Generation / Variant (reserved open layers)

```json
{ "id": "suzuki/jimny/jb74", "slug": "jb74", "code": "JB74",
  "name": "4th generation", "year_start": 2018, "year_end": null }

{ "id": "bmw/2-series/m2", "slug": "m2", "name": "M2", "type": "performance" }
```

Generations capture platform/chassis drift (`code` = manufacturer chassis
code); variants capture submodels people *call* a model (M2, Golf GTI) —
`type`: `performance` · `trim` · `body` · `edition`, optionally scoped via
`generation`. Both layers are currently unpopulated (they return with the
depth work); the shapes are binding so consumers can code against them today.

## `dist/vehicles.json` (the gem projection)

The lean contract — **shape never breaks** (`schema_version: 2`; new keys are
optional and additive):

```json
{
  "version": "2026.07.0", "schema_version": 2, "region": "global",
  "kinds": ["bus", "car", "moped", "motorcycle", "truck", "van"],
  "makes": [
    { "name": "Volkswagen", "slug": "volkswagen", "kinds": ["car", "van"],
      "models": [
        { "name": "Golf", "slug": "golf", "kind": "car",
          "body_type": "hatchback", "global_decile": 2,
          "availability": ["ca", "es", "fi", "gb", "…"] }
      ] }
  ]
}
```

Per-model: `body_type` (primary only; absent where the catalog has none),
`global_decile` (absent when unranked), `availability` (bare country codes —
the evidence detail lives in `catalog/`).

## `dist/catalog.sqlite`

Tables: `meta` (key/value), `makes (id, kind, name)`, `models (id, kind,
make_id, slug, name, body_types, global_popularity_decile)`, `availability
(model_id, kind, country, evidence, source)`, `popularity (model_id, kind,
country, rank, decile, confidence)`. Ids match the JSON ids exactly.

## Versioning

`version` is date-based (`YYYY.MM.PATCH`), one git **tag** per release —
the version *is* the freshness. Adding kinds, makes, models, countries, or
optional fields is a normal release. Removing or renaming a published `id`,
or changing a `schema_version`, is the only thing that counts as breaking —
it requires a major schema bump plus a migration alias, and is avoided.
