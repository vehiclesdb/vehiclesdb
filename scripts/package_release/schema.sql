-- VehiclesDB relational release package — schema (vehiclesdb-package/1)
--
-- One table per entity, normalised from the published catalog/ tree
-- (catalog/<kind>/{makes,models}.json + manifest.json). Lossless for those
-- records: every field of the model and make files, and the manifest's release
-- facts, has a home here (makes.json "kinds" is always [file kind] = makes.kind).
-- Not carried: catalog/meta/decile-mass.json (aggregate mass shares, published
-- beside the catalog), manifest "dist" (asset paths), attribution.required.
-- check.rb fails on any model/make field this schema has no home for. Written by
-- scripts/package_release.sh into vehiclesdb-<version>.sqlite and, one
-- Parquet file per table, into vehiclesdb-<version>-parquet/.
--
-- Keys. A model id is unique WITHIN a kind ("volkswagen/golf" in car), so every
-- model-level table is keyed by (kind, model_id). former_ids values are
-- kind-prefixed ("car/alfa-romeo/alfa147") because a rename may cross kinds.
-- Multi-valued fields become child tables, never "|"-joined strings.
-- Growth contract (SCHEMA.md): tables and columns are only ever ADDED; a column
-- the release does not carry yet is NULL (e.g. models.mass_decile before 2026.10.1).

CREATE TABLE meta (
  key   TEXT PRIMARY KEY,           -- version, built_at, schema_version, license, attribution_text, …;
                                    -- attribution_notices = the release's ATTRIBUTION.md, verbatim
  value TEXT
);

CREATE TABLE sources (
  id                   TEXT PRIMARY KEY,   -- e.g. nl_rdw
  country              TEXT NOT NULL,      -- ISO 3166-1 alpha-2 (gb for the UK)
  name                 TEXT NOT NULL,
  url                  TEXT,
  license              TEXT,               -- licence id, e.g. CC-BY-4.0, OGL-UK-3.0
  license_url          TEXT,
  evidence             TEXT,               -- registration | approval | sales | import
  count_window_measure TEXT,
  count_window_from    TEXT,
  count_window_to      TEXT,
  count_window_months  INTEGER
);

CREATE TABLE countries (
  code TEXT PRIMARY KEY                    -- the release's countries (manifest.json)
);

CREATE TABLE makes (
  kind TEXT NOT NULL,                      -- car | motorcycle | moped | van | truck | bus
  id   TEXT NOT NULL,
  slug TEXT NOT NULL,
  name TEXT NOT NULL,
  PRIMARY KEY (kind, id)
);

CREATE TABLE make_aliases (
  kind    TEXT NOT NULL,
  make_id TEXT NOT NULL,
  alias   TEXT NOT NULL,
  PRIMARY KEY (kind, make_id, alias)
);

CREATE TABLE make_countries (
  kind    TEXT NOT NULL,
  make_id TEXT NOT NULL,
  country TEXT NOT NULL,
  PRIMARY KEY (kind, make_id, country)
);

CREATE TABLE models (
  kind          TEXT NOT NULL,
  id            TEXT NOT NULL,             -- "<make_id>/<slug>"
  make_id       TEXT NOT NULL,
  slug          TEXT NOT NULL,
  name          TEXT NOT NULL,
  global_decile INTEGER,                   -- popularity.global_decile (presence average; see SCHEMA.md)
  mass_decile   INTEGER,                   -- popularity.mass_decile (mass-ordered; NULL before 2026.10.1)
  PRIMARY KEY (kind, id)
);

CREATE TABLE model_body_types (
  kind      TEXT NOT NULL,
  model_id  TEXT NOT NULL,
  position  INTEGER NOT NULL,              -- 0 = primary body type
  body_type TEXT NOT NULL,
  PRIMARY KEY (kind, model_id, body_type)
);

CREATE TABLE model_regions (
  kind     TEXT NOT NULL,
  model_id TEXT NOT NULL,
  region   TEXT NOT NULL,
  PRIMARY KEY (kind, model_id, region)
);

CREATE TABLE availability (
  kind     TEXT NOT NULL,
  model_id TEXT NOT NULL,
  country  TEXT NOT NULL,
  evidence TEXT NOT NULL,
  source   TEXT NOT NULL,                  -- sources.id
  PRIMARY KEY (kind, model_id, country, source)
);

CREATE TABLE popularity (
  kind       TEXT NOT NULL,
  model_id   TEXT NOT NULL,
  country    TEXT NOT NULL,
  rank       INTEGER,
  decile     INTEGER,
  confidence TEXT,                         -- measured | proxy
  PRIMARY KEY (kind, model_id, country)
);

CREATE TABLE model_sources (
  kind     TEXT NOT NULL,
  model_id TEXT NOT NULL,
  source   TEXT NOT NULL,
  PRIMARY KEY (kind, model_id, source)
);

CREATE TABLE model_aliases (
  kind     TEXT NOT NULL,
  model_id TEXT NOT NULL,
  alias    TEXT NOT NULL,
  PRIMARY KEY (kind, model_id, alias)
);

CREATE TABLE former_ids (
  kind      TEXT NOT NULL,                 -- kind of the LIVE successor
  model_id  TEXT NOT NULL,                 -- the live successor's id
  former_id TEXT NOT NULL,                 -- "<kind>/<make>/<slug>" of the retired id
  PRIMARY KEY (former_id)
);

CREATE TABLE xrefs (
  kind     TEXT NOT NULL,
  model_id TEXT NOT NULL,
  scheme   TEXT NOT NULL,                  -- e.g. tan (EU type-approval number)
  value    TEXT NOT NULL,
  PRIMARY KEY (kind, model_id, scheme, value)
);

CREATE INDEX idx_models_make        ON models (kind, make_id);
CREATE INDEX idx_availability_cc    ON availability (country, kind);
CREATE INDEX idx_popularity_cc      ON popularity (country, kind, rank);
CREATE INDEX idx_model_aliases      ON model_aliases (alias);
CREATE INDEX idx_make_aliases       ON make_aliases (alias);
