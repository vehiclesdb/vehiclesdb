# SOURCES.md — where the data comes from

Operational notes for every source in the composite: what it provides, under
which license, how often it updates, and the quirks we've measured the hard
way. The build pins every license text by SHA-256 (`data/licenses/pins.json`)
and fails on drift, so this table can't silently rot.

Evidence vocabulary — `registration`: vehicles actually registered/on the
road; `approval`: type-approved/certified for sale; `sales`: verified sales
reporting. Counts marked ✓ feed the popularity deciles ("measured" tier).

| id | Country | What | License | Cadence | Counts |
|---|---|---|---|---|---|
| `nl_rdw` | 🇳🇱 NL | Full vehicle register (Socrata API, per-kind aggregates) | [CC0 / public](https://opendata.rdw.nl/) | daily | ✓ fleet |
| `uk_dft` | 🇬🇧 UK | Licensed-vehicles table VEH0120 (all kinds, by body type) | [OGL v3](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) | quarterly | ✓ fleet |
| `es_dgt` | 🇪🇸 ES | Monthly registration microdata (fixed-width, all kinds) | [DGT open data](https://www.dgt.es/menusecundario/dgt-en-cifras/matraba/) | monthly | ✓ new reg. |
| `fi_traficom` | 🇫🇮 FI | Full open register, 5.1M vehicles (all kinds) | [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/) | ~monthly | ✓ fleet |
| `lu_snca` | 🇱🇺 LU | Registered-vehicle inventory (XML via CKAN) | [CC0](https://data.public.lu/) | monthly | ✓ fleet |
| `ie_cso` | 🇮🇪 IE | New private car registrations by make/model (PxStat) | [CC-BY 4.0](https://www.cso.ie/en/aboutus/lgdp/csodatapolicies/dataforresearchers/rdmpolicy/) | monthly | ✓ new reg. |
| `de_kba_fz10` | 🇩🇪 DE | New car registrations by make + model series (FZ 10) | [DL-DE/BY-2.0](https://www.govdata.de/dl-de/by-2-0) | monthly | ✓ new reg. |
| `us_fueleconomy` | 🇺🇸 US | EPA fuel-economy vehicle catalog, MY1984→ | [US Gov public domain](https://www.fueleconomy.gov/feg/download.shtml) | ~monthly | — approval |
| `ca_nrcan` | 🇨🇦 CA | NRCan fuel-consumption ratings catalog (incl. EV files) | [OGL-Canada 2.0](https://open.canada.ca/en/open-government-licence-canada) | yearly+ | — approval |
| `nz_nzta` | 🇳🇿 NZ | Motor Vehicle Register fleet (ArcGIS aggregates) | [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/) | monthly | ✓ fleet |
| `my_jpj` | 🇲🇾 MY | JPJ registrations by maker/model (data.gov.my) | [Malaysia open data](https://data.gov.my/) | monthly | ✓ new reg. |
| `th_dlt` | 🇹🇭 TH | DLT first registrations by brand/model (incl. motorcycles) | [TH gov open data](https://gdcatalog.dlt.go.th/) | yearly file | ✓ new reg. |
| `ua_mvs` | 🇺🇦 UA | Registration operations register (the CIS spine) | [CC-BY](https://data.gov.ua/dataset/06779371-308f-42d7-895e-5a39833375f0) | ~monthly | ✓ new reg. |
| `ar_dnrpa` | 🇦🇷 AR | DNRPA vehicle registrations (LatAm spine) | [CC-BY 4.0 (datos.gob.ar)](https://datos.gob.ar/) | monthly | ✓ new reg. |
| `il_mot` | 🇮🇱 IL | MoT active-vehicle roll-up (car/van) + motorcycle and heavy registers, via the datastore API | [data.gov.il Licence of Use](https://data.gov.il/he/terms-of-use) (`other-open`) | daily | ✓ fleet (active) — **attach-only** |

Exact dataset URLs, resolution mechanics, and each license's prescribed
attribution wording: see `ATTRIBUTION.md` (generated per release) and
`data/licenses/` (pinned texts).

## Which sources can say what a vehicle RUNS ON

Not all of them, and the gaps are not evenly spread. Ten of the fourteen carry
a propulsion column at model granularity; four cannot, and one of those four is
the largest source in the catalog. The per-source detail is in the gotchas
below; this is the summary a consumer should read before drawing a conclusion
about coverage.

| id | propulsion column | what it can produce |
|---|---|---|
| `de_kba_fz10` | FZ 10.1's four propulsion blocks | diesel · hybrid · plug-in hybrid · BEV — **never petrol** (no petrol column exists; petrol is a residual fused with LPG/CNG) |
| `es_dgt` | electrification flag | BEV · PHEV · HEV · FCEV — **never an ICE code** (blank means petrol *or* diesel *or* LPG/CNG) |
| `fi_traficom` | `kayttovoima` | petrol · diesel · BEV (other codes await Traficom's separately-published code list) |
| `lu_snca` | `CODCRB` | the full vocabulary, incl. bifuel pairs — the cleanest of any source |
| `my_jpj` | `fuel` | petrol · diesel · BEV · hybrid |
| `ua_mvs` | `FUEL` | petrol · diesel · BEV · LPG · bifuel pairs · hydrogen |
| `il_mot` | car/van: the approval catalogue's `technologiat_hanaa_nm` (+ `delek_nm`); 2W/truck/bus: register `sug_delek_nm` | car/van: BEV · PHEV · **HEV** (the only Israeli field that separates a regular hybrid from a plug-in) · petrol · diesel · LPG; 2W/heavy: petrol · diesel · BEV · LPG · CNG — the register's electric+petrol value maps to neither hybrid code |
| `us_fueleconomy` | `atvType` | the full vocabulary, as **approval** evidence (certified configurations, not vehicles) |
| `ca_nrcan` | `Fuel type` + resource split | same, as approval evidence |
| `uk_dft` | `Fuel` (present, **not yet read**) | blocked — see the gotcha below |
| `nz_nzta` | `MOTIVE_POWER` (present, **not yet read**) | blocked — see the gotcha below |
| `nl_rdw` `ie_cso` `th_dlt` `ar_dnrpa` | none | nothing, permanently or for now |

**The Netherlands can never contribute, and that is worth stating plainly**
because `nl_rdw` is the largest single source in the catalog. Probed
2026-08-02 against the live API: the registered-vehicles dataset (`m9d7-ebf2`)
carries make and model but no fuel value — its `api_gekentekende_voertuigen_brandstof`
column is a constant link, identical on every row. RDW's fuel data lives in a
sibling dataset (`8ys7-d773`) whose entire column list is
`kenteken, brandstof_volgnummer, brandstof_omschrijving, emissiecode_omschrijving,
uitlaatemissieniveau` — **no make, no model**, joinable only on the licence-plate
key. That key is a forbidden field under our own GDPR boundary (naming it in an
adapter fails a build gate outright), and a catalog search of the RDW open-data
domain found no third dataset carrying make, model and fuel together. So this
is a **permanent limitation under our own rules**, not a to-do: any Dutch
propulsion coverage would require RDW to publish a combined view.

## Per-source gotchas (measured, not hypothetical)

- **nl_rdw** — the register carries 11,403 raw make strings; only reconciled
  aggregates ship. RDW's bijsluiter *prohibits* implying RDW endorsement, so
  attribution uses neutral phrasing (see DECISIONS.md).
- **uk_dft** — asset URLs rotate on every quarterly release; the pipeline
  re-resolves the download link from the landing page each build instead of
  pinning it. ~22 malformed CSV lines per file are skipped loudly.
  Motorcycles and mopeds arrive merged ("Motorcycles") — mapped to
  `motorcycle` with the merge documented.
  **Fuel: the column is on disk and is deliberately NOT read.** VEH0120 is a
  six-key cross-tab whose `Fuel` column sits at *trim* altitude while the
  adapter aggregates at `GenModel`, and that gap makes reading it produce
  WRONG data rather than missing data — the bucket's whole fuel mix would be
  attributed to whichever nameplate the bucket is named after. The measured
  case: `BYD SEAL DESIGN EV` is 50,601 GB vehicles spanning three nameplates
  and splitting 23,678 battery-electric against 26,923 plug-in hybrid; and
  `VAUXHALL ASTRA` covers 764 distinct `Model` strings across 8 fuel types,
  fuel-cell included. A count threshold cannot catch a 50,601-vehicle false
  positive. The `Model`-column split has landed as a reviewed **whitelist**,
  not a general rule, so the hazard stands for every GenModel not on it.
- **es_dgt** — fixed-width layout (MARCA at byte 17, MODELO at 47, EU
  category at 426); files appear with ~1 month lag so the build walks up to
  3 months back. Legacy Spanish "star codes" (`*02`–`*17`) predate EU
  L-categories and are mapped moped/motorcycle per DGT's code table.
- **fi_traficom** — one 190 MB zip, streamed (never fully unpacked). The
  register includes decommissioned vehicles; counts are fleet-wide.
- **lu_snca** — XML, resolved through data.public.lu's CKAN API because the
  direct file URL changes per month. Carries EU type-approval numbers.
- **ie_cso** — PxStat labels are `"MAKE MODEL"` concatenated; the pipeline
  splits by longest-known-make prefix and logs the (few) unsplittable
  leftovers rather than guessing.
- **il_mot** — Israel's Ministry of Transport registers on data.gov.il,
  measured 2026-10-02. **Only the CKAN API works**: every bulk route (the
  `/download/*.csv` links, `/datastore/dump`, the `e.data.gov.il` resource
  URLs) answers a CloudFront WAF challenge, a 403 or a Google sign-in, so the
  adapter pages `datastore_search` 100,000 rows at a time and proves each read
  contiguous (`_id` 1..N, N = the server total).
  - **Identifiers are never requested.** Three of the four datasets are
    per-vehicle and carry the plate, the chassis number and the engine number;
    the API projects `fields=`, so only an allow-list of non-identifier
    columns ever leaves the server. Car and van come from the Ministry's own
    roll-up (`5e87a7a1`, active count by make, model code, year and commercial
    name), which has no per-vehicle row at all. Model cells of nothing but 7–8
    digits — an Israeli plate's shape — are dropped and counted (13 vehicles).
  - **Stock = ACTIVE vehicles**: licence valid or lapsed ≤13 months,
    deregistrations excluded; the car/van roll-up starts at manufacture year
    1996/1998. Basis `stock-active`. No `by_year` series: `shnat_yitzur` is
    the MANUFACTURE year, and the on-road date beside it is not an Israel
    first-registration date (used imports show gap 0 in 100% of 21,834 rows).
  - **Makes are written in Hebrew only.** The map is curation, in
    `overrides/makes/aliases.yml` (145 keys, 98.75% of active mass);
    `ג'אקו` is **Jaecoo**, not JAC (`ג'אק`). Multi-marque register labels
    (`דיימלר קרייזלר`, `קרייזלר` — filed on Ram trucks too — `רובר`) stay
    unmapped and are dropped with their mass logged.
  - **The motorcycle register's L1/L2/L3 are LICENCE TIERS, not EU
    categories** (A2 ≤14.6 hp / A1 ≤47 hp / A): L1 is mostly 125 cm³
    scooters. Moped is decided by the EU L1e bound — ≤50 cm³, or ≤4 kW
    electric (`hespek` is horsepower). The heavy register's `tkina_EU` IS a
    real EU category: N2/N3 truck, M2/M3 bus; trailers, tractors and its
    M1/N1 rows are declared skips (`overrides/kind_maps/il_mot.yml`).
  - **ATTACH-ONLY.** Allowed to mint (control vs treatment on a frozen
    corpus, adapter the only variable), Israel published **+821 ids** (car
    159 · van 37 · truck 178 · bus 61 · motorcycle 372 · moped 14) and **12
    new gate failures** (alias-liveness resurrections like `van/mazda/bt-50`;
    no-vanish via cross-kind dominance like `car/fiat/250`, displaced by
    Israel's Fiat "250" trucks). The head was junk: tails fused into
    commercial names (`toyota/corolla-hsd-sdn` 33,309, `hyundai/elantra-hev`)
    and, on 2W/truck/bus, TYPE CODES rather than names (`honda/nf13`,
    `ktm/gsa20`, `chevrolet/ck`). As shipped: **+0 ids, 0 renames, gate
    failures identical to control; `il` on 1,483 published ids** (car 772 ·
    van 98 · truck 170 · bus 34 · motorcycle 394 · moped 15) carrying
    3,638,204 of 4,507,113 ingested active vehicles (80.7%; car 85.6%,
    motorcycle 6.0% — the type-code cells rarely meet a catalog name).
  - **Licence.** Every package read is `other-open` with no text; the site
    licence (https://data.gov.il/he/terms-of-use) governs and permits copy,
    distribution, derivatives and commercial use. Its prohibitions pass
    through to users of the Israeli-derived part (no misleading use, no
    unlawful use, **no use that harms a person's privacy, including by
    cross-referencing**). The terms page is WAF-blocked to the pipeline, so
    the pin guards the CKAN licence fields and the text is quoted in the
    adapter; re-read it by hand with a browser on each release.
- **de_kba_fz10** — Germany's per-vehicle register is closed by statute
  (§39 StVG); FZ 10 is the open model-level signal and is already
  series-normalized by KBA. The site answers missing months with HTTP 200 +
  an HTML 404 page — the pipeline verifies zip magic and walks back a month.
- **us_fueleconomy** — catalog (approval evidence), no counts: it proves a
  model was certified for the US market, not how many are on the road.
- **ca_nrcan** — CSVs are Windows-1252 encoded (French column headers) and
  EVs live in separate files from conventional vehicles; both handled.
- **nz_nzta** — the ArcGIS service is renamed every month (`MVR_Mar26`-style)
  and re-resolved per build; group-by responses cap at ~2000 rows so queries
  chunk by make first-letter. `GOODS VAN/TRUCK/UTILITY` is skipped: it fuses
  vans, trucks and utes with no split column (mapping it would misclassify
  two kinds to fill one). NZ's JDM grey imports add models no EU/US register
  has — that's a feature, and exactly what `availability` evidence records.
  **Motive power: the field EXISTS but is not read yet.** Probed 2026-08-02 —
  layer 0 carries `MOTIVE_POWER` and `ALTERNATIVE_MOTIVE_POWER`, and the
  vocabulary is clean and fully mappable (`PETROL` 3,185,874 · `DIESEL`
  1,232,248 · `PETROL HYBRID` 414,314 · `ELECTRIC` 105,234 · `PLUGIN PETROL
  HYBRID` 48,791 · `DIESEL HYBRID` 14,549 · `PETROL ELECTRIC HYBRID` 11,174 ·
  `LPG` 3,529 · `ELECTRIC [PETROL EXTENDED]` 839 · `CNG` 141 · fuel-cell
  variants · 881,713 null). The blocker is the paging cap above, not the data:
  two cached responses (`nz_passenger-car-van_C` and `_M`) already sit at
  exactly 2,000 features with `exceededTransferLimit: true`, i.e. **the
  existing make/model query is already silently truncating at those letters**,
  and adding a third group field would multiply the group rows and make that
  much worse without the adapter noticing. Detecting `exceededTransferLimit`
  comes first.
- **my_jpj** — clean per-model CSVs; Malaysian market adds Perodua/Proton
  models absent everywhere else.
- **th_dlt** — years are Buddhist Era (2568 = 2025). The portals reject
  datacenter IPs and default curl user agents (HTTP/2 resets); the pipeline
  fetches browser-like over HTTP/1.1 and keeps the last good snapshot for CI
  runs. Thailand is the best open motorcycle-model source in the Global
  South (89 brands / 879 model strings measured).
- **ua_mvs** — per-operation records: one vehicle can appear multiple times,
  so the pipeline dedupes on the vehicle identifier in-stream and then
  discards it (the identifier never leaves the parser; CI lints for that).
  Freight (`ВАНТАЖНИЙ`) is skipped — it merges vans and heavy trucks with no
  category column to split them honestly. The same honesty rule applies to
  35,485 propulsion rows: the register's "X **or** electric" values
  (`ЕЛЕКТРО АБО БЕНЗИН` and siblings) mean *electrified, plug unknown* — they
  could be a full hybrid or a plug-in and the register does not say — so they
  produce no propulsion evidence at all. Calling them all "hybrid" would put
  the same token on them as on the 3.01M cleanly-classified British hybrids,
  which is worse than an honest gap.
- **ar_dnrpa** — resource files resolved via CKAN; model strings are messy
  uppercase (`descripcion` concatenations), so AR contributes mostly
  corroboration and LatAm-only nameplates rather than primary spellings.

## Watch-list (evaluated, not yet merged — with the blocker)

| Source | Blocker |
|---|---|
| 🇨🇭 CH ASTRA / opendata.swiss | in progress — next spine addition |
| 🇧🇪 BE FPS Mobility | yearly XLS only, no license statement on the file — needs clearance |
| 🇨🇿 CZ vehicle register | bulk dump paused upstream; privacy review pending |
| 🇵🇱 PL CEPiK | bulk exports frozen upstream |
| 🇰🇷 KR KOTSA API | API key + per-request quota; planned |
| 🇯🇵 JP MLIT | model-level stats behind per-prefecture PDFs; e-Stat customs data planned as origin-mix proxy instead |
| 🇪🇪 EE register | CC-BY-**SA** — quarantined by rule R2 (ShareAlike never merges) |
| Wikidata | CC0, planned as xref layer (QIDs), never as a primary fact source |

If you know an official, openly-licensed make/model-level source we're
missing — especially outside Europe — please open an issue with the URL and
its license text. That's the single highest-leverage contribution.
