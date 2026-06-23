# VehiclesDB — open vehicle data

Free, open, versioned data for **every kind of vehicle** — the catalogue of what
vehicles exist and how they're organized. Cars today; vans, motorcycles, trucks,
buses, trains, and more as they land. This is the open core of
[VehiclesDB](https://vehiclesdb.com), published as flat files so anyone can use it.

> **Status:** EU cars — 47 makes, 456 model nameplates (dataset `2026.06.0`).
> The schema already models the full universe (kinds, makes, models, generations,
> variants) and grows **without breaking changes**. See [SCHEMA.md](SCHEMA.md).

## What's here

```
manifest.json            index: version, kinds, regions, files, counts
catalog/                 the normalized taxonomy — THE database
  car/
    makes.json           [{ id, slug, name, kinds }]
    models.json          [{ id, make_id, slug, name, kind, body_types, generations?, variants? }]
dist/
    vehicles.json        flat make→model projection for dropdowns (what the gem reads)
    vehicles.csv         the same projection as CSV (spreadsheets / BI / humans)
SCHEMA.md  CHANGELOG.md  VERSION  LICENSE
```

Two layers, on purpose: **`catalog/`** is the structured database (grows in
breadth — more kinds — and depth — generations, variants); **`dist/vehicles.json`**
is a small, stable projection for the common case (a make/model picker).

## Use it

Most apps want the projection:

```bash
curl -sL https://cdn.jsdelivr.net/gh/vehiclesdb/vehiclesdb@latest/dist/vehicles.json   # or vehicles.csv
```

In Ruby/Rails, don't fetch it yourself — use the
[`vehicles`](https://github.com/rameerez/vehicles) gem (bundled offline + refresh).
Prefer a spreadsheet? Grab `dist/vehicles.csv`. Want the full tree (generations,
variants)? Read `catalog/car/*.json`.

## How deep does it go?

The schema is built to hold the whole vehicle universe. A few real examples
already carry depth:

- **Suzuki Jimny → `JB74`** is a *generation* (chassis code `JB74`, 2018–) under
  `suzuki/jimny`. Older `JB43` sits alongside it.
- **BMW M2** is a `performance` *variant* of `bmw/2-series` (`bmw/2-series/m2`).

Per-config **specs, configurations, and images** (engine, drivetrain, power,
year-accurate photos…) are the paid [VehiclesDB API](https://vehiclesdb.com),
keyed to these same ids. The open repo is the taxonomy; the API is the detail.

## Versioning & licensing

Date-based `YYYY.MM.patch`, one git tag per release; new kinds/makes/models and
optional layers ship without breaking consumers (see [SCHEMA.md](SCHEMA.md)).

Data is **CC-BY 4.0**. Today's data derives from [RDW Open Data](https://opendata.rdw.nl/) (CC0).
Attribution: *"Vehicle data from VehiclesDB (CC-BY 4.0)."*
