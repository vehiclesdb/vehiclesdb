# VehiclesDB — open vehicle data

**The open catalogue of what vehicles exist**: makes, models, kinds, body
types, popularity, and where in the world each model is actually found —
reconciled from **official registers of 14 countries on 4 continents**,
versioned, and free forever under CC-BY 4.0.

> **Dataset `2026.07.0`** — 19,282 models · 933 makes · 6 kinds · 14 countries
>
> | kind | models | makes | | kind | models | makes |
> |---|---:|---:|---|---|---:|---:|
> | 🚗 car | 8,901 | 316 | | 🚐 van | 1,617 | 147 |
> | 🏍️ motorcycle | 5,934 | 262 | | 🚚 truck | 1,082 | 97 |
> | 🛵 moped | 1,330 | 288 | | 🚌 bus | 418 | 97 |

Every record is corroborated: a model ships when **two independent official
sources agree** (or one shows a fleet count no typo could produce), so you get
the Golf and the Corolla — and the Perodua Myvi, the Honda Wave 125i, the
Bogdan A092 — without the registry noise (we reconcile ~76,000 raw car name
variants down to what's real).

## Use it

**Grab a file** (CDN, always the latest release):

```bash
curl -sL https://cdn.jsdelivr.net/gh/vehiclesdb/vehiclesdb@latest/dist/vehicles.json
```

**Rails / Ruby** — use the [`vehicles`](https://github.com/rameerez/vehicles)
gem: bundled offline snapshot, dropdown helpers, validators, popularity and
availability accessors, plus a built-in MCP server (`vehicles-mcp`) for agents.

**SQL** — `dist/catalog.sqlite` is the full catalog as a single-file database:

```bash
sqlite3 catalog.sqlite "SELECT name FROM models WHERE kind='car'
                        ORDER BY global_popularity_decile LIMIT 10"
```

**Spreadsheets / pandas** — `dist/vehicles.csv`, one row per model.

**Everything else** — `catalog/<kind>/models.json` is the full-fidelity
taxonomy (per-country popularity ranks, availability evidence, source ids,
type-approval crosswalks where measured).

## The files

```
manifest.json              index: version, kinds, counts, countries, files
catalog/<kind>/            THE database — full records
  makes.json               [{ id, slug, name }]
  models.json              [{ id, make_id, slug, name, kind, body_types?,
                              availability, popularity?, sources, xrefs? }]
dist/                      projections for the common cases
  vehicles.json            nested make→models (what the gem bundles)
  vehicles.min.json        the same, array-packed (~60% smaller — pickers)
  vehicles.csv             flat table
  catalog.sqlite           SQL access to everything above
ATTRIBUTION.md             generated per release — the required CC-BY notices
SCHEMA.md                  shapes + the growth/versioning contract
SOURCES.md                 every source: license, cadence, measured gotchas
overrides/  spotchecks.yml the human-curated inputs (see Contributing)
```

Ids are stable forever (kind + make + model slugs, e.g. `volkswagen/golf`
within `catalog/car/`). Renames alias, nothing is silently deleted, and
absent optional keys mean *not catalogued yet* — never a schema change.
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

Official, openly-licensed sources only — vehicle registers, type-approval
catalogs, and government statistics from NL, GB, ES, FI, LU, IE, DE, US, CA,
NZ, MY, TH, UA, AR. Every source, its license, its update cadence, and its
measured quirks: [SOURCES.md](SOURCES.md). The exact attribution notices each
license prescribes: [ATTRIBUTION.md](ATTRIBUTION.md). ShareAlike, NC, and
scraped sources never enter this dataset — by build gate, not by promise.

Fresh data lands monthly (`YYYY.MM.PATCH` versions — the version *is* the
freshness), with weekly automated validation against upstream drift in
between.

## Contributing

The build outputs (`catalog/`, `dist/`, `manifest.json`) are generated —
don't PR them. What we love PRs and issues for:

- **A wrong name, a junk model, a missing alias** → edit `overrides/`
  (every line carries a `#` comment saying why; CI lints in seconds:
  `ruby scripts/lint_overrides.rb`).
- **A model that should never disappear** → add a row to `spotchecks.yml`.
- **An official open source we're missing** — especially outside Europe —
  → open an issue with the URL and its license text. Highest-leverage
  contribution there is.

House rules: [AGENTS.md](AGENTS.md) · Why things are the way they are:
[DECISIONS.md](DECISIONS.md)

## License

Data: [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/) — free for
any use, including commercial, with attribution:

> Vehicle data by [VehiclesDB](https://vehiclesdb.com) (CC-BY 4.0), built
> from official public registers — see ATTRIBUTION.md for source notices.
