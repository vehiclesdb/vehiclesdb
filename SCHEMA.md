# Schema

This repo is the **open VehiclesDB taxonomy** — the catalogue of *what vehicles
exist and how they're organized*. It's designed to grow into **every kind of
vehicle** and to **deepen** (generations, variants, configs) without ever
breaking what's already published. This document is the source of truth for the
shape.

## The two things we publish

| Artifact | What | Who reads it |
|---|---|---|
| **`catalog/`** | The normalized taxonomy — the database. Per **kind** (`catalog/car/…`), split into `makes.json` + `models.json`. Models may carry optional `generations` and `variants`. | Anyone who wants the structured data; the pipeline; future tooling |
| **`dist/vehicles.json`** | A flat **projection** of the catalogue for dropdowns: make → model with `kind` + `body_type`. Small, stable, the contract the [`vehicles`](https://github.com/rameerez/vehicles) gem consumes. | The `vehicles` gem, CDN/curl users, anything that just needs a picker |

`dist/` is generated from `catalog/`. Most consumers want `dist/vehicles.json`;
the catalogue is for when you need the full tree.

## The hierarchy

Everything hangs off a stable, hierarchical, path-style **id** so any layer can
be referenced and deepened independently. Adding a layer to a record is purely
additive — never a breaking change.

```
Kind            car · motorcycle · van · truck · bus · train · plane · boat · …   (a dimension)
└─ Make         bmw                                  id: "bmw"
   └─ Model     bmw 2 Series                         id: "bmw/2-series"
      ├─ Generation   (optional)  chassis/platform   id: "bmw/2-series/g87"     e.g. Jimny "JB74"
      └─ Variant      (optional)  submodel/trim      id: "bmw/2-series/m2"      e.g. "M2", "GTI"
         └─ Config/Spec  ← PAID (the API), keyed by these ids: engine, power, drivetrain,
                            transmission, body, dimensions, fuel/emissions, per model-year …
```

**Open vs. paid (the moat).** This repo is the **taxonomy** — identity and
structure (names, slugs, codes, body types, year ranges, aliases). The deep,
per-config **specs, configurations, and media (images)** are the
[VehiclesDB API](https://vehiclesdb.com), keyed by these same ids. Open data is
the skeleton; the API is the flesh.

**What's populated today (MVP):** `kind`, `make`, `model` for EU cars. The
`generation` and `variant` layers are live in the schema and demonstrated on two
real records (see below); the rest gain depth over time. Your code never changes
when they do — absent optional keys simply mean "not catalogued yet."

## Make

`catalog/<kind>/makes.json` — array of:

| Field | Type | Notes |
|---|---|---|
| `id` | string | stable, e.g. `"bmw"` |
| `slug` | string | lowercase ASCII |
| `name` | string | `"BMW"` |
| `kinds` | string[] | kinds this make builds, e.g. `["car", "motorcycle"]` |
| `country` | string? | ISO-3166 alpha-2 of origin *(optional, future)* |
| `aliases` | string[]? | alternate spellings *(optional, future)* |

## Model (nameplate)

`catalog/<kind>/models.json` — array of:

| Field | Type | Notes |
|---|---|---|
| `id` | string | `"<make>/<model>"`, e.g. `"bmw/2-series"` |
| `make_id` | string | `"bmw"` |
| `slug` | string | bare model slug, e.g. `"2-series"` |
| `name` | string | `"2 Series"` |
| `kind` | string | `car` (and later `motorcycle`, `van`, …) |
| `body_types` | string[] | a nameplate can span bodies, e.g. `["coupe", "convertible"]` |
| `year_start` / `year_end` | int? | nameplate lifespan *(optional)* |
| `aliases` | string[]? | *(optional)* |
| `generations` | object[]? | deeper layer — see below *(optional)* |
| `variants` | object[]? | deeper layer — see below *(optional)* |

## Generation (optional) — captures platform/chassis and major model drift

How we track **Suzuki Jimny JB74**: a generation under `suzuki/jimny`.

```json
{ "id": "suzuki/jimny/jb74", "slug": "jb74", "code": "JB74",
  "name": "4th generation", "year_start": 2018, "year_end": null }
```

| Field | Type | Notes |
|---|---|---|
| `id` | string | `"<make>/<model>/<gen>"` |
| `slug` | string | e.g. `"jb74"`, `"mk8"` |
| `code` | string? | manufacturer chassis/platform code (`JB74`, `G87`, …) |
| `name` | string? | human label (`"4th generation"`) |
| `year_start` / `year_end` | int? | generation lifespan |

## Variant / submodel (optional) — performance versions, trims, body submodels

How we track **BMW M2**: a `performance` variant of `bmw/2-series` (optionally
scoped to a generation via `generation`).

```json
{ "id": "bmw/2-series/m2", "slug": "m2", "name": "M2", "type": "performance" }
```

| Field | Type | Notes |
|---|---|---|
| `id` | string | `"<make>/<model>/<variant>"` |
| `slug` | string | e.g. `"m2"`, `"gti"` |
| `name` | string | `"M2"` |
| `type` | string | `performance` · `trim` · `body` · `edition` |
| `generation` | string? | generation slug it belongs to, if specific *(optional)* |

> Submodels people *call* a model (M2, Golf GTI) live here as variants — so you
> can surface them in a deep picker without polluting the nameplate list. Whether
> something is a model vs. a variant is a curation call; the ids make either
> resolvable.

## `dist/vehicles.json` (the gem projection)

The lean, gem-facing contract — **do not break this shape** (`schema_version` 2):

```json
{
  "version": "2026.06.0", "schema_version": 2, "region": "EU", "kinds": ["car"],
  "makes": [
    { "name": "BMW", "slug": "bmw", "kinds": ["car"],
      "models": [ { "name": "2 Series", "slug": "2-series", "kind": "car", "body_type": "coupe" } ] }
  ]
}
```

It is a projection: one `body_type` (the primary), no generations/variants — just
what a make → model dropdown needs.

## Versioning

`version` is date-based (`YYYY.MM.patch`), one git **tag** per release. Adding
kinds, makes, models, or optional layers is a normal release. Removing/renaming a
published `id`, or changing `dist`'s `schema_version`, is the only thing that
counts as breaking — and is avoided.
