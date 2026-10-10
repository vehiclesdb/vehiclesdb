# VehiclesDB {{VERSION}} — relational package (Parquet)

The open VehiclesDB catalog (CC BY 4.0), normalised into one table per entity.
Built {{BUILT_AT}} from the release's own `catalog/` tree by
`scripts/package_release.sh`; the same tables ship as `vehiclesdb-{{VERSION}}.sqlite`.
`schema.sql` holds the DDL (SQLite dialect; it also documents every Parquet column).

| table | one row per |
|---|---|
| `meta` | release fact (version, built_at, licence, attribution text) |
| `sources` | official source (licence, evidence type, count window) |
| `countries` | country in this release |
| `makes` | (kind, make) |
| `make_aliases`, `make_countries` | make × alias, make × country |
| `models` | (kind, model) with `global_decile` and `mass_decile` |
| `model_body_types` | model × body type (`position` 0 = primary) |
| `model_regions` | model × region |
| `availability` | model × country × source (the evidence) |
| `popularity` | model × country (rank, decile, confidence) |
| `model_sources`, `model_aliases` | model × source, model × alias |
| `former_ids` | retired id → its live successor |
| `xrefs` | model × scheme × value (e.g. `tan`, EU type approval) |

Model ids are unique within a kind: join on `(kind, model_id)`.

```sql
-- DuckDB: car models on the Ukrainian register, by popularity there
SELECT mk.name AS make, m.name AS model, p.rank
FROM 'models.parquet' m
JOIN 'makes.parquet' mk ON mk.kind = m.kind AND mk.id = m.make_id
JOIN 'popularity.parquet' p ON p.kind = m.kind AND p.model_id = m.id AND p.country = 'ua'
WHERE m.kind = 'car' ORDER BY p.rank LIMIT 20;
```

```python
import pandas as pd
models = pd.read_parquet("models.parquet")
```

**Attribution is required** (CC BY 4.0 §3(a)): "Vehicle data by VehiclesDB" with a link to
https://vehiclesdb.com. The upstream register notices in ATTRIBUTION.md apply to every use.
See `meta` (`attribution_text`, `attribution_note`) and https://github.com/vehiclesdb/vehiclesdb.
