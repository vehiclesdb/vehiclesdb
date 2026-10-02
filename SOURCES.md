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
| `it_aci` | 🇮🇹 IT | ACI Autoritratto — car fleet by make × model × series (Pubblico Registro Automobilistico, national sheet) | [CC-BY 4.0](https://aci.gov.it/attivita-e-progetti/studi-e-ricerche/open-data/) (+ [Note legali](https://aci.gov.it/informazioni-per-la-navigazione/note-legali/) — caveat below) | yearly | ✓ fleet (31/12) |

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
| `us_fueleconomy` | `atvType` | the full vocabulary, as **approval** evidence (certified configurations, not vehicles) |
| `ca_nrcan` | `Fuel type` + resource split | same, as approval evidence |
| `uk_dft` | `Fuel` (present, **not yet read**) | blocked — see the gotcha below |
| `nz_nzta` | `MOTIVE_POWER` (present, **not yet read**) | blocked — see the gotcha below |
| `nl_rdw` `ie_cso` `th_dlt` `ar_dnrpa` `it_aci` | none | nothing, permanently or for now |

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

- **it_aci** — **ACI Autoritratto, "Circolante FTS Autovetture", sheet `1
  Riepilogo Nazionale`**: Italy's car fleet at 31/12 of the edition year, by
  `Fabbrica | Tipo | Serie | Totale Veicoli`. Aggregates only; no identifier
  column exists. The 2025 edition (the file is dated 2026-06-23) carries 9,591
  data rows summing to 41,795,962 cars, which **equals the sheet's own
  `TOTALE NAZIONALE` row** — the adapter re-asserts that every build and
  raises on drift. Series are summed per (Fabbrica, Tipo): 1,493 pairs,
  41,401,925 cars kept (99.06%). Basis `stock-circulating-pra`; the snapshot
  date is read from the sheet title, never from the file name.
  - **Licence caveat (manager decision 2026-10-02, pending an independent
    licence verifier).** The Open Data page's CC-BY sentence covers its own
    `*-OD.zip` files (ODS, 2024 and older). The 2025 xlsx is linked from the
    Autoritratto page, which has no dataset sentence, so it rests on the site
    **Note legali** ("Tutti i contenuti testuali e documentali sono disponibili
    con licenza d'uso Creative Commons CC BY 4.0"). That page also forbids AI
    manipulation that alters the content's meaning and harms ACI's image. The
    recorded basis for ACCEPT-WITH-CAVEAT: that clause is an integrity
    restriction, which CC BY 4.0 §2(b)(1) leaves unlicensed anyway, and
    aggregating counts neither alters meaning nor harms ACI. **Two pins**
    (`it_aci`, `it_aci_note_legali`, phrases mode) guard both pages. The AI
    clause is pinned verbatim, so any edit to it reddens gate 1. The phrases
    are in the pages' raw entity form (`&rsquo;`, `&Egrave;`), because the
    gate decodes no entities.
  - **The file URL rotates every year** (`/app/uploads/YYYY/MM/`) and so does
    its name: `Autoritratto2025_Parco_veicolare.zip`,
    `Autoritratto-2024-Parco-Veicolare.zip`. The adapter reads the link from
    the Autoritratto page, takes the newest year, and raises if none matches.
    The sibling `…_UTILIZZATORE.zip` is a different table and is excluded.
  - **Residual buckets are not models** and are skipped with a logged census.
    2025 figures: `Fabbrica = NON DEFINITO` 30 rows / 290,735 cars (its Tipo
    values T03, 5, 7, GRENADIER… have no make). `ALTRI TIPI` 121 / 72,927.
    Blank Tipo 21 / 16,231. `ALTRE FABBRICHE` 2 / 8,432. **`ALTRI` + Serie
    `TIPI`** 19 / 5,712: this is the same bucket split across two cells, which
    is why the test is not simply "ALTRI TIPI". `Serie = ALTRE SERIE` is kept,
    because it is a real model's series below the floor. Every series row is at
    least 100 cars (ACI's floor).
  - **Tipo is cut at about 12 characters**, and the cut drops the marque word.
    237 values are exactly 12 characters: `COROLLA VERS`, `DS7 CROSSBAC`,
    `TOURNEO COUR`, `DISCOVERY SP`, `RANGE EVOQUE`, `CONTINEN. GT`. Without the
    pipeline's Land Rover rule extension, `DISCOVERY SP` published 26,883
    Discovery Sports as the Discovery. Every value also carries a trailing
    space, which the adapter strips.
  - **Italian range words**: `CLASSE A` (Mercedes, 963k cars across classes,
    handled by the normalizer's Mercedes rule, which also covers Spain's
    `CLASE A`), `SERIE 3` / `SERIE 4 GC` / `SERIE 3 GT` (BMW, renames),
    `SERIE 200` (Rover, renames), `SERIE W123` (Mercedes chassis families).
    Drivetrain markers are their own Tipo: `JUKE 2WD` alone is 140,904 cars.
  - **EXCEL DATE CORRUPTION in ACI's own file**: three Tipo cells hold date
    serials. Saab `46090` (= 9-3, read as 9 March), `46151` (= 9-5) and Morgan
    `46116` (= 4-4) are rescued by rename keys. **The serials are specific to
    this edition**: a new file will carry new numbers, so re-check the next
    edition for bare 5-digit Tipo values.
  - **Brand quirks**: `MERCEDES` (already aliased), `AUSTINHEALEY`,
    `TATA ENG`. ACI files Daewoo-era cars under `CHEVROLET` (Lanos, Nexia,
    Espero), Haval H2 under `GREAT WALL`, and the Alpine A110/A290 under
    `RENAULT` (moves.yml). DR, EVO, EMC, Sportequipe and Tiger are Italian
    rebadgers that no other register carries. The DR/EVO model names repeat
    the make (`DR 5.0`, `EVO 5`), so prefix-stripping leaves `5.0`/`5`, which
    junk? kills; rename keys rescue them. Sportequipe `6`/`7`/`8` (3,628 cars)
    are still dropped.
  - **Vans are in the car table** (M1 people-carriers: Doblò, Kangoo, Caddy,
    Transit/Tourneo, Vito…). The existing car-kind `drop_patterns` exclude
    them; they are most of the 548,489 Italian cars (139 rows) that classify drops in 2025. ACI's other kind sheets are make-only, so
    Italy contributes to `car` only.
  - **No powertrain.** There is no fuel column. `Serie` free text is not mapped:
    an absent token does not mean petrol, and FIAT's `1.0 HYBRID` (493,791
    Pandas) is a mild hybrid, which the closed vocabulary deliberately cannot
    express.

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
