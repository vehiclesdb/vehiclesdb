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
| `au_bitre` | 🇦🇺 AU | BITRE *Road Vehicles Australia* — national fleet census, type × year of manufacture × motive power × make/model | [CC-BY 3.0 AU](https://creativecommons.org/licenses/by/3.0/au/) | yearly (ref. 31 Jan, published ~Oct) | ✓ fleet |

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
| `au_bitre` | `motive_power` | petrol · diesel · hybrid · BEV (**fused with FCEV upstream — one `Battery/Fuel-cell electric` bucket, 259,762 vehicles, not splittable**) · bifuel petrol+LPG. `Other` (52,060) maps to nothing, so these never sum to the fleet |
| `ua_mvs` | `FUEL` | petrol · diesel · BEV · LPG · bifuel pairs · hydrogen |
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
- **au_bitre** — one national file, and deliberately not a union of states:
  BITRE already aggregates every state and territory via NEVDIS, so unioning
  the state portals on top would double-count 100% of the overlap. (The
  Victorian `Whole Fleet … by Model` set is also space-padded to six
  characters and renders Hyundai as `HYNDAI`; do not ingest it.) Five things
  to know before reading an AU number:
  **(1) Counts are confidentialised.** BITRE suppresses cells under 3 units
  and perturbs secondary cells, and states that interior estimates "may not
  sum to the totals reported" — so **no validator may assert that AU rows sum
  to the national total**, and a `no_vehicles` of 0 means *withheld*, not
  *absent* (19,218 such cells, kept as corroborating evidence that can never
  mint).
  **(2) `history` is MANUFACTURE year, not first registration** — the only
  source where this is true, which is why it carries its own
  `stock-manufacture-year` basis. An import built in 2007 and first registered
  in Australia in 2015 sits in the 2007 bucket here and would sit in 2015 in
  Finland; the two curves must not be aligned year-for-year.
  **(3) No moped.** `Motorcycles` is not subdivided and engine capacity is
  never crossed with make+model in any of the 18 resources, so Australia
  contributes 981,893 vehicles to `motorcycle` and zero to `moped`. There is
  no cc column to split on.
  **(4) The resource is resolved by NAME PREFIX through `package_show`, never
  by URL or index** — both UUIDs rotate annually, and the name itself has
  moved three ways across editions (2021-24 "Registered *motor* vehicles … 
  motive power, year of manufacture"; 2025 "Registered *road* vehicles … year
  of manufacture, motive power …, 31 January 2025"). The package id is pinned
  to one edition on purpose so the licence pin and the ingested bytes always
  describe the same thing; **advancing it is a deliberate act that must move
  the pin too** — per-edition licence drift is real, the January 2024 edition
  being CC-BY **2.5** AU rather than 3.0.
  **(5) `Light commercial vehicles` → `van` is an OPEN RULING.** 4,195,963
  vehicles; consistent with `uk_dft`'s "Light goods vehicles" → van, but the
  Australian class is dominated by utes and a ute is not a panel van.

## Watch-list (evaluated, not yet merged — with the blocker)

| Source | Blocker |
|---|---|
| 🇨🇭 CH ASTRA / BFS (federal) | **not a licence problem — a granularity one.** Measured 2026-09-05: `Fahrzeugmodell` returns 0 datasets; the federal vehicle statistics stop at `…nach Marke` (make), one level above where our schema starts, so they cannot produce a `Row`. The licence is fine (`#terms_by`, attribution-only). The live Swiss route is **cantonal**, not federal — see below. (The portal also 403s default curl and needs a browser UA; that is a User-Agent block, not geo-gating.) |
| 🇨🇭 CH Thurgau cantonal register | evaluating — and **"cantonal registers" is a plural that does not exist: it is ONE canton.** Enumerated 2026-09-12 across opendata.swiss plus direct probes of `data.tg.ch`/`data.bs.ch`/`data.bl.ch`/`daten.sg.ch`: only **Thurgau** publishes a per-vehicle register with make and model (`djs-stv-7`, 280,363 records at 01.01.2026, **CC BY 4.0 / `terms_by`**, 11 dated editions back to 2016). Basel-Landschaft has no make/model; Zürich and Zug are make-level; the Geneva `immatriculation` hits are cadastral false positives; "Amt für Statistik" is **Liechtenstein**, not a canton. It feeds eight `Row` fields including **`tan` and `body_raw`**, the two supplied today by exactly one source each (LU and NL). **The blocker is not licence or coverage — it is the model column.** Thurgau stopped populating the pre-split `typ2` between the 2024 and 2025 editions (filled 273,807 → **0**); the live model string is `typ1`, a make+model+engine+drivetrain concatenation (`"OctaviaC RS D 4x4"`, `"Golf VII 1.4TSI 5"`), so CH needs a trim-collapse normalizer stage before it can be ingested without shattering the Octavia into five ids. Licence tiers, from opendata.swiss's own terms page: `terms_open`/`terms_by` pass, `terms_ask`/`terms_by_ask` are instant rejects (and do occur on Swiss vehicle data); `terms_ny` is not a real tier. Note the underlying data is **federal (ASTRA)** republished by the canton — the right long-term ask is ASTRA, not twenty-five more cantons. |
| 🇳🇴 NO Statens vegvesen PKK | evaluating, **ahead of CH** — periodic roadworthiness inspections, per-vehicle, **CC-BY-4.0** asserted twice (publisher CKAN + data.norge.no DCAT), 13 zips / 175.5 MB on `raw.githubusercontent.com`, no key and no UA needed, **zero identifier columns with publisher-applied k-anonymity and odometer rounding**. Measured through the real normalizer: **420 candidate promotions**, 1,351 keys landing on published records, **0 mintable** — so it corroborates and adds availability, and cannot mint. Two things to know: it is the **inspected** fleet, not the registered one (so counts would be presence-only for a first cut), and the cadence is **annual, not quarterly** — the publisher dumps a whole year every January, so the newest data is 2025 Q4 and 2026 Q1 will not appear until ~January 2027. Unrelated and still live: `data.norge.no` advertises nine CC-BY-4.0 distributions of *Teknisk kjøretøyinformasjon* whose every URL points at `hotell.difi.no`, **still NXDOMAIN** — a licence assertion and a reachable file are two different facts. |
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
