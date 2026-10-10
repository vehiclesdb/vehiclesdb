#!/usr/bin/env bash
# package_release.sh — the relational release package: one SQLite file and one
# Parquet file per entity, built from the SAME catalog/ tree the release ships.
#
#   scripts/package_release.sh [DATA_ROOT] [OUT_DIR]
#     DATA_ROOT  a tree holding manifest.json + catalog/ (default: this repo;
#                in the release workflow: the data checkout right after emit,
#                or the pipeline's build/out)
#     OUT_DIR    where to write (default: ${TMPDIR:-/tmp}/vehiclesdb-package; created).
#                Never inside the data checkout in CI: the publish step runs `git add -A`.
#
# Writes, for the manifest's <version>:
#   OUT_DIR/vehiclesdb-<version>.sqlite              all tables, keys + indexes (schema.sql)
#   OUT_DIR/vehiclesdb-<version>-parquet/<table>.parquet   one file per table (zstd)
#   OUT_DIR/vehiclesdb-<version>-parquet/schema.sql  the DDL (also documents the Parquet columns)
#   OUT_DIR/vehiclesdb-<version>-parquet/README.md   what each table is, how to load it
#   OUT_DIR/vehiclesdb-<version>-parquet/ATTRIBUTION.md   the upstream register notices (when DATA_ROOT has it)
#   OUT_DIR/vehiclesdb-<version>-parquet.zip         the directory above, for a release asset
#   OUT_DIR/SHA256SUMS
#
# Requires: duckdb CLI (with the sqlite extension; INSTALL runs once if missing),
# sqlite3, zip, and sha256sum or shasum. Read-only on DATA_ROOT.
#
# Reproducible: rows are written in primary-key order and file mtimes are pinned
# to manifest.json's built_at, so two runs over the same tree with the same
# duckdb + sqlite3 versions give byte-identical .sqlite, .parquet and .zip files,
# and any toolchain gives identical CONTENT (asserted, with a JSON-side recount of
# every table, by scripts/package_release/check.rb).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_ROOT="$(cd "${1:-$HERE/..}" && pwd)"
OUT_DIR="${2:-${TMPDIR:-/tmp}/vehiclesdb-package}"
SCHEMA="$HERE/package_release/schema.sql"
README_TPL="$HERE/package_release/README.md"

die() { echo "package_release: $*" >&2; exit 1; }
[ -f "$DATA_ROOT/manifest.json" ] || die "no manifest.json in $DATA_ROOT"
command -v duckdb >/dev/null || die "duckdb CLI not found (brew install duckdb / see monthly-build.yml)"
command -v zip >/dev/null || die "zip not found"
if command -v sha256sum >/dev/null; then SHA="sha256sum"; else SHA="shasum -a 256"; fi

q() { duckdb -noheader -list -c "$1"; }   # one-value query helper
# manifest.json read as TEXT and parsed with json functions — no type inference
# (read_json_auto would turn built_at into a TIMESTAMP and lose its ISO form).
MJ="(SELECT CAST(content AS JSON) AS j FROM read_text('manifest.json'))"
CATALOG_PATHS="SELECT k, json_extract_string(j, '\$.catalog.\"' || k || '\".makes') AS makes, json_extract_string(j, '\$.catalog.\"' || k || '\".models') AS models FROM (SELECT j, unnest(json_keys(j, '\$.catalog')) AS k FROM $MJ)"
cd "$DATA_ROOT"
VERSION="$(q "SELECT json_extract_string(j, '\$.version') FROM $MJ")"
BUILT_AT="$(q "SELECT json_extract_string(j, '\$.built_at') FROM $MJ")"
[ -n "$VERSION" ] || die "manifest.json has no version"
for f in $(q "SELECT unnest([makes, models]) FROM ($CATALOG_PATHS)"); do
  [ -f "$f" ] || die "manifest.json lists $f but it is missing — not a complete release tree"
done

NAME="vehiclesdb-$VERSION"
PQ="$OUT_DIR/$NAME-parquet"
DB="$OUT_DIR/$NAME.sqlite"
mkdir -p "$OUT_DIR"
rm -rf "$PQ" "$DB" "$OUT_DIR/$NAME-parquet.zip" "$OUT_DIR/SHA256SUMS"
mkdir -p "$PQ"

# The model and make files, exactly as manifest.json indexes them.
MODEL_FILES="$(q "SELECT string_agg('''' || models || '''', ',' ORDER BY k) FROM ($CATALOG_PATHS)")"
MAKE_FILES="$(q "SELECT string_agg('''' || makes || '''', ',' ORDER BY k) FROM ($CATALOG_PATHS)")"

TABLES="meta sources countries makes make_aliases make_countries models model_body_types model_regions availability popularity model_sources model_aliases former_ids xrefs"

SQL="$(mktemp -t vdbpkg.XXXXXX)"
trap 'rm -f "$SQL"' EXIT
cat > "$SQL" <<SQLEOF
-- Explicit column types: an optional key absent from every record of a release
-- (e.g. popularity.mass_decile before 2026.10.1) must still read as NULL, never
-- as a missing column.
CREATE TEMP TABLE raw_models AS
SELECT * FROM read_json([$MODEL_FILES], format = 'array', maximum_object_size = 104857600, columns = {
  id: 'VARCHAR', make_id: 'VARCHAR', slug: 'VARCHAR', name: 'VARCHAR', kind: 'VARCHAR',
  body_types: 'VARCHAR[]', regions: 'VARCHAR[]', sources: 'VARCHAR[]', aliases: 'VARCHAR[]',
  former_ids: 'VARCHAR[]', availability: 'JSON', popularity: 'JSON', xrefs: 'JSON'});

CREATE TEMP TABLE raw_makes AS
SELECT regexp_extract(filename, 'catalog/([^/]+)/makes\.json\$', 1) AS kind, *
FROM read_json([$MAKE_FILES], format = 'array', filename = true, columns = {
  id: 'VARCHAR', slug: 'VARCHAR', name: 'VARCHAR', aliases: 'VARCHAR[]', countries: 'VARCHAR[]'});

CREATE TEMP TABLE m AS SELECT CAST(content AS JSON) AS j FROM read_text('manifest.json');

CREATE TABLE meta AS
SELECT * FROM (VALUES
  ('version',             (SELECT json_extract_string(j, '\$.version') FROM m)),
  ('edition',             (SELECT json_extract_string(j, '\$.edition') FROM m)),
  ('built_at',            (SELECT json_extract_string(j, '\$.built_at') FROM m)),
  ('schema_version',      (SELECT json_extract_string(j, '\$.schema_version') FROM m)),
  ('dist_schema_version', (SELECT json_extract_string(j, '\$.dist_schema_version') FROM m)),
  ('package_schema',      'vehiclesdb-package/1'),
  ('license',             (SELECT json_extract_string(j, '\$.license') FROM m)),
  ('homepage',            (SELECT json_extract_string(j, '\$.homepage') FROM m)),
  ('attribution_text',    (SELECT json_extract_string(j, '\$.attribution.text') FROM m)),
  ('attribution_url',     (SELECT json_extract_string(j, '\$.attribution.url') FROM m)),
  ('attribution_note',    (SELECT json_extract_string(j, '\$.attribution.note') FROM m))
) t(key, value) ORDER BY key;

CREATE TABLE sources AS
SELECT json_extract_string(s, '\$.id')          AS id,
       json_extract_string(s, '\$.country')     AS country,
       json_extract_string(s, '\$.name')        AS name,
       json_extract_string(s, '\$.url')         AS url,
       json_extract_string(s, '\$.license')     AS license,
       json_extract_string(s, '\$.license_url') AS license_url,
       json_extract_string(s, '\$.evidence')    AS evidence,
       json_extract_string(s, '\$.count_window.measure') AS count_window_measure,
       json_extract_string(s, '\$.count_window.from')    AS count_window_from,
       json_extract_string(s, '\$.count_window.to')      AS count_window_to,
       CAST(json_extract(s, '\$.count_window.months') AS INTEGER) AS count_window_months
FROM (SELECT unnest(from_json(json_extract(j, '\$.sources'), '["JSON"]')) AS s FROM m) ORDER BY id;

CREATE TABLE countries AS SELECT unnest(from_json(json_extract(j, '\$.countries'), '["VARCHAR"]')) AS code FROM m ORDER BY code;

CREATE TABLE makes AS SELECT kind, id, slug, name FROM raw_makes ORDER BY kind, id;
CREATE TABLE make_aliases AS
  SELECT DISTINCT kind, id AS make_id, unnest(aliases) AS alias FROM raw_makes WHERE aliases IS NOT NULL ORDER BY ALL;
CREATE TABLE make_countries AS
  SELECT DISTINCT kind, id AS make_id, unnest(countries) AS country FROM raw_makes WHERE countries IS NOT NULL ORDER BY ALL;

CREATE TABLE models AS
SELECT kind, id, make_id, slug, name,
       CAST(json_extract(popularity, '\$.global_decile') AS INTEGER) AS global_decile,
       CAST(json_extract(popularity, '\$.mass_decile')   AS INTEGER) AS mass_decile
FROM raw_models ORDER BY kind, id;

CREATE TABLE model_body_types AS
SELECT kind, id AS model_id, CAST(i - 1 AS INTEGER) AS position, body_types[i] AS body_type
FROM (SELECT kind, id, body_types, generate_subscripts(body_types, 1) AS i FROM raw_models WHERE body_types IS NOT NULL)
ORDER BY kind, model_id, position;

CREATE TABLE model_regions AS
  SELECT DISTINCT kind, id AS model_id, unnest(regions) AS region FROM raw_models WHERE regions IS NOT NULL ORDER BY ALL;

CREATE TABLE availability AS
SELECT kind, model_id, a.country AS country, a.evidence AS evidence, a.source AS source FROM (
  SELECT kind, id AS model_id,
         unnest(from_json(availability, '[{"country":"VARCHAR","evidence":"VARCHAR","source":"VARCHAR"}]')) AS a
  FROM raw_models WHERE availability IS NOT NULL)
ORDER BY kind, model_id, country, source;

CREATE TABLE popularity AS
SELECT kind, model_id, country,
       CAST(json_extract(p, '\$.rank') AS INTEGER) AS rank,
       CAST(json_extract(p, '\$.decile') AS INTEGER) AS decile,
       json_extract_string(p, '\$.confidence') AS confidence
FROM (
  SELECT kind, id AS model_id, unnest(json_keys(popularity, '\$.by_country')) AS country,
         popularity -> '\$.by_country' AS bc
  FROM raw_models WHERE json_extract(popularity, '\$.by_country') IS NOT NULL),
  LATERAL (SELECT bc -> ('\$."' || country || '"') AS p)
ORDER BY kind, model_id, country;

CREATE TABLE model_sources AS
  SELECT DISTINCT kind, id AS model_id, unnest(sources) AS source FROM raw_models WHERE sources IS NOT NULL ORDER BY ALL;
CREATE TABLE model_aliases AS
  SELECT DISTINCT kind, id AS model_id, unnest(aliases) AS alias FROM raw_models WHERE aliases IS NOT NULL ORDER BY ALL;
CREATE TABLE former_ids AS
  SELECT kind, id AS model_id, unnest(former_ids) AS former_id FROM raw_models WHERE former_ids IS NOT NULL ORDER BY former_id;

CREATE TABLE xrefs AS
SELECT kind, model_id, scheme, value FROM (
  SELECT kind, id AS model_id, scheme,
         unnest(from_json(xrefs -> ('\$."' || scheme || '"'), '["VARCHAR"]')) AS value
  FROM (SELECT kind, id, xrefs, unnest(json_keys(xrefs)) AS scheme FROM raw_models WHERE xrefs IS NOT NULL))
ORDER BY kind, model_id, scheme, value;

-- Parquet: one file per table.
$(for t in $TABLES; do echo "COPY $t TO '$PQ/$t.parquet' (FORMAT parquet, COMPRESSION zstd);"; done)

-- SQLite: the tables are created by schema.sql (keys, NOT NULL, indexes), then filled.
ATTACH '$DB' AS lite (TYPE sqlite);
$(for t in $TABLES; do echo "INSERT INTO lite.$t SELECT * FROM $t;"; done)
DETACH lite;
SQLEOF

# Create the SQLite schema first so it carries the real keys and indexes.
duckdb -c "INSTALL sqlite; LOAD sqlite;" >/dev/null 2>&1 || true
command -v sqlite3 >/dev/null || die "sqlite3 CLI not found"
sqlite3 "$DB" < "$SCHEMA"
{ echo "LOAD sqlite;"; cat "$SQL"; } | duckdb >/dev/null

# Integrity: the package must hold exactly the catalog's records.
CAT_MODELS="$(q "SELECT count(*) FROM read_json([$MODEL_FILES], format='array', maximum_object_size=104857600, columns={id:'VARCHAR'})")"
MAN_MODELS="$(q "SELECT sum(CAST(json_extract(j, '\$.kinds.\"' || k || '\".models') AS INTEGER)) FROM (SELECT j, unnest(json_keys(j, '\$.kinds')) AS k FROM $MJ)")"
LITE_MODELS="$(sqlite3 "$DB" 'SELECT count(*) FROM models')"
PQ_MODELS="$(q "SELECT count(*) FROM '$PQ/models.parquet'")"
if [ "$CAT_MODELS" != "$MAN_MODELS" ] || [ "$LITE_MODELS" != "$MAN_MODELS" ] || [ "$PQ_MODELS" != "$MAN_MODELS" ]; then
  die "model count mismatch: manifest $MAN_MODELS, catalog $CAT_MODELS, sqlite $LITE_MODELS, parquet $PQ_MODELS"
fi
[ "$(sqlite3 "$DB" 'PRAGMA integrity_check')" = "ok" ] || die "sqlite integrity_check failed"
sqlite3 "$DB" 'VACUUM'

cp "$SCHEMA" "$PQ/schema.sql"
# The upstream register statements must travel with the data (some licences require it).
if [ -f "$DATA_ROOT/ATTRIBUTION.md" ]; then cp "$DATA_ROOT/ATTRIBUTION.md" "$PQ/ATTRIBUTION.md"; fi
sed -e "s/{{VERSION}}/$VERSION/g" -e "s/{{BUILT_AT}}/$BUILT_AT/g" "$README_TPL" > "$PQ/README.md"

# Pin mtimes to the release's build time so the zip is reproducible.
STAMP="$(echo "$BUILT_AT" | sed -E 's/^([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2}).*/\1\2\3\4\5.\6/')"
TZ=UTC touch -t "$STAMP" "$PQ"/* "$PQ" "$DB"
# Sorted entry list: zip -r would store readdir order, which differs between filesystems.
( cd "$OUT_DIR" && find "$NAME-parquet" -type f | LC_ALL=C sort | TZ=UTC zip -q -X -D "$NAME-parquet.zip" -@ )
TZ=UTC touch -t "$STAMP" "$OUT_DIR/$NAME-parquet.zip"
( cd "$OUT_DIR" && $SHA "$NAME.sqlite" "$NAME-parquet.zip" "$NAME-parquet"/* > SHA256SUMS )

echo "package_release: $VERSION — $MAN_MODELS models"
for t in $TABLES; do printf '  %-17s %s rows\n' "$t" "$(sqlite3 "$DB" "SELECT count(*) FROM $t")"; done
echo "  -> $DB ($(wc -c < "$DB" | tr -d ' ') B)"
echo "  -> $OUT_DIR/$NAME-parquet.zip ($(wc -c < "$OUT_DIR/$NAME-parquet.zip" | tr -d ' ') B)"
