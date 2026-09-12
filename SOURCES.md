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
| `no_svv_pkk` | 🇳🇴 NO | Periodic roadworthiness inspections (PKK), per-vehicle rows with make + model | [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.no) | quarterly | ✓ inspections — **not a fleet** |

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
| `no_svv_pkk` | `Drivstofftype` | petrol · diesel · BEV · CNG · LPG · ethanol · FCEV — **never a hybrid code**: the column has none, so plug-in hybrids are filed under their combustion fuel and NO can evidence neither `hev` nor `phev`. `Gass` fuses LPG+CNG and maps to neither |
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
- **no_svv_pkk** — **this is an INSPECTION register, not a fleet, and the
  distinction is not pedantic.** Norway defers a vehicle's first PKK to its
  *fourth year* and then inspects light vehicles every second year (heavy
  vehicles and buses every year). Measured on 2025 Q4, the first-registration
  histogram of the inspected population peaks at **2021 (53,265)** and
  collapses through 2022 (12,342) to 2025 (554). So: recent cohorts are
  essentially absent, any single year is one side of a cohort-parity
  sawtooth, and over any window long enough to catch every light vehicle once
  the heavy ones are counted twice. There is **no identifier column at all**,
  so deduplicating to distinct vehicles is impossible in principle. Counts
  are therefore `flow-roadworthiness-inspections` and Norway never enters
  `total_stock_observed`.
  **This also undercuts the obvious reason to want Norway.** The inspected
  fleet is 18.5% pure electric, which is why the source was proposed as the
  EV gap-filler — but the 2022-2025 EV wave is exactly the part the deferral
  hides, so a BEV share read off this register *understates* the real one.
  - **Mixed quoting.** The file is *not* a plain quoted CSV: strings are
    quoted and numerics are bare. A `split('","')` fast path parses the
    all-quoted header correctly and then mis-parses **448,406 of 448,406**
    data rows. ISO-8859-1 with CRLF; `Kjøretøymerke` in the header is the
    canary for a decoding mistake.
  - **203 columns, one layout, three years.** Proven byte-identical across all
    12 quarterly files, which is what makes positional addressing safe; the
    adapter re-asserts it per file and raises on drift.
  - **`Etterkontroll` is 34.1% of rows** (2,250,087 of 6,591,286) and is
    excluded — it is a *re*-inspection of a vehicle already present as a
    `Periodisk` row, so counting it would inflate every number by half again
    *and do it in proportion to how often a model FAILS*.
  - **Identical rows are different vehicles.** With no identifier and
    k-anonymity applied upstream, two same-model/year/fuel/county vehicles
    inspected in the same month with no faults produce byte-identical rows —
    72,873 July-2024 rows carry only 68,932 distinct fingerprints. Never
    deduplicate by content; 3,941 real vehicles would vanish.
  - **47 vehicle-group values corpus-wide, only 42 in any one quarter.**
    Re-deriving `overrides/kind_maps/no_svv_pkk.yml` from a single file will
    silently drop five. Trailers (O1–O4), tractors (T1/T5) and cranes are
    declared skips; motorhomes, ambulances and hearses are skipped pending an
    owner ruling, because PKK carries the *coachbuilder* as the make
    (`HYMER`, `DETHLEFFS`…) while the catalog already files those as models
    under the chassis make (`fiat/hymer`, `citroen/burstner`) — and files
    them inconsistently, across car, van, truck and even moped.
  - **`KOMBINERT BIL` is not a car.** The research dossier recorded it as M1;
    measured, it is N1-dominant (13,122 of 15,483) and is split on EU
    category into van/truck.
  - **No motorcycles or mopeds, ever.** Norway does not subject two-wheelers
    to PKK; there is no motorcycle group among the 47 values.
  - **The licence is not in the bytes.** The GitHub repository that serves the
    CSVs returns `"license": null` and has no LICENSE file. CC BY 4.0 is
    asserted by the publisher's own CKAN record (which is what is pinned) and
    mirrored by data.norge.no. Do not read the GitHub repo as evidence of
    terms. Three neighbouring Statens vegvesen packages are `notspecified`,
    so the portal genuinely mixes licences and this one is licensed.
  - **Publication has stalled.** The newest file is 2025 Q4 and the repo's
    last commit is 2026-01-21, so as of 2026-09-12 the publisher is two
    quarters behind its own quarterly cadence. The zips are immutable once
    published; the adapter re-reads only the small contents listing often.
  - **Filenames rotate case** (`PKK-2023-…` upper, `pkk-2025-…` lower), so the
    file list is read from the GitHub contents API and never templated.
  - **`N/A` is a literal model string** (ISUZU ships it), not a blank.
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
| 🇳🇴 NO SSB (Statistics Norway) | **REJECTED on granularity, not licence — do not re-research.** Every vehicle table stops at MAKE: the finest identity axis in the whole catalogue is `merke`/`bilmerke` (2,569 values in table 07832, 531 in 07847). `?query=bilmodell` returns 0 results and `?query=modell` returns exactly one non-vehicle table. A make-only source cannot produce a Row. Norway ships via `no_svv_pkk` instead. |
| 🇳🇴 NO "Teknisk kjøretøyinformasjon" | Advertises nine CC-BY-4.0 CSV distributions incl. a bulk vehicle-data file and a make-code lookup — **every `accessURL` points at `hotell.difi.no`, which is NXDOMAIN.** A national-portal record asserting an open licence over a decommissioned host; recorded as a live example of the hazard the `be_fps` rule guards against. |
| Wikidata | CC0, planned as xref layer (QIDs), never as a primary fact source |

If you know an official, openly-licensed make/model-level source we're
missing — especially outside Europe — please open an issue with the URL and
its license text. That's the single highest-leverage contribution.
