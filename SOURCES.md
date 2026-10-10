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
| `no_svv_pkk` | 🇳🇴 NO | Periodic roadworthiness inspections (PKK), per-vehicle rows with make + model | [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.no) | quarterly | ✓ inspections — **not a fleet; attach-only** |
| `ch_tg` | 🇨🇭 CH | Kanton Thurgau registered-vehicle stock (Strassenverkehrsamt TG, via data.tg.ch), aggregated server-side to make × model × class × fuel | [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/) | yearly (stock at 1 Jan) | presence only — **one canton (3.9% of CH); attach-only; count nil** |
| `au_bitre` | 🇦🇺 AU | BITRE *Road Vehicles Australia* — national fleet census, type × year of manufacture × motive power × make/model | [CC-BY 3.0 AU](https://creativecommons.org/licenses/by/3.0/au/) | yearly (ref. 31 Jan, published ~Oct) | ✓ fleet — **attach-only** |
| `it_aci` | 🇮🇹 IT | ACI *Autoritratto* **Open Data** edition — national car fleet by make × model × series (Pubblico Registro Automobilistico), `Circolante_FTS_Autovetture_<YEAR>.ods` | [CC-BY 4.0](https://aci.gov.it/attivita-e-progetti/studi-e-ricerche/open-data/) (Open Data section; + a disclosed site term, below) | yearly (stock at 31 Dec, published ~June) | ✓ fleet — **cars only** |
| `il_mot` | 🇮🇱 IL | MoT active-vehicle roll-up (car/van) + motorcycle and heavy registers, via the datastore API | Facts with credit to data.gov.il, under the [data.gov.il Terms of Use](https://data.gov.il/he/terms-of-use) (`other-open`) — **not relicensed CC BY** | daily | ✓ fleet (active) — **attach-only** |

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
| `no_svv_pkk` | `Drivstofftype` | petrol · diesel · BEV · CNG · LPG · ethanol · FCEV — **never a hybrid code**: the column has none, so plug-in hybrids are filed under their combustion fuel and NO can evidence neither `hev` nor `phev`. `Gass` fuses LPG+CNG and maps to neither |
| `ch_tg` | `treibstoff_code` + `hybridcode` | petrol · diesel · BEV · CNG · LPG · FCEV, and `hev`/`phev` from `hybridcode` (NOVC-HEV / OVC-HEV). Petrol/diesel-electric vehicles with no hybridcode contribute nothing (electrified, plug unknown). **One canton**, so presence of a code, never a Swiss share |
| `il_mot` | car/van: the approval catalogue's `technologiat_hanaa_nm` (+ `delek_nm`); 2W/truck/bus: register `sug_delek_nm` | car/van: BEV · PHEV · **HEV** (the only Israeli field that separates a regular hybrid from a plug-in) · petrol · diesel · LPG; 2W/heavy: petrol · diesel · BEV · LPG · CNG — the register's electric+petrol value maps to neither hybrid code |
| `us_fueleconomy` | `atvType` | the full vocabulary, as **approval** evidence (certified configurations, not vehicles) |
| `ca_nrcan` | `Fuel type` + resource split | same, as approval evidence |
| `uk_dft` | `Fuel` (present, **not yet read**) | blocked — see the gotcha below |
| `nz_nzta` | `MOTIVE_POWER` (present, **not yet read**) | blocked — see the gotcha below |
| `nl_rdw` `ie_cso` `th_dlt` `ar_dnrpa` `it_aci` | none | nothing, permanently or for now (`it_aci`: no fuel column; `Serie` text is not mapped — see its gotcha) |

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
- **ch_tg** — **one canton of twenty-six, read presence-only and
  attach-only.** Kanton Thurgau's *Fahrzeugbestand am 01.01.2026* (280,363
  vehicles; 254,616 motor vehicles = 3.9% of Switzerland's 6.6 M per BFS).
  A count would publish a canton's rank as Switzerland's popularity
  (`by_country.ch`, confidence "measured"), so `count` is nil and
  `COUNT_BASIS["ch"]` starts `catalog-` (= contributes no counts); availability,
  powertrain and EU category still attach.
  - **Nothing per-vehicle is downloaded.** The export is per vehicle (62
    columns), but Opendatasoft's export endpoint takes `select=` and
    `group_by=`: the canton returns one row per (Fahrzeugart, Fahrzeugklasse,
    Marke, Typ1, Typ2, Treibstoff, Hybridcode) with `count(*)` — 51,484 groups,
    summing exactly to `records_count`, re-checked every build. Stammnummer,
    Kontrollschild and chassis fields are in the GDPR lint's forbidden list.
  - **`typ2` is EMPTY in 2026** (it held the split model on 227,100 of
    227,181 rows in 2021). The model comes from `typ1`, which carries trims
    ("Golf VII 1.4TSI 5"); car/van models are cut at the first litre token, as
    the normalizer would otherwise junk the whole string.
  - **TAN declined:** `typengenehmigungs_nr` is a SWISS type-approval number
    ("1SC842"; `X` and `IVI` = individual import are common), not the EU
    e-number `xrefs.tan` is defined as. **Body declined:** `karosserieform`
    "Limousine" means *closed car*, not sedan (Golf: 5,107 Limousine).
    Both refute the 2026-09 dossier, which sold Thurgau as a second TAN and
    body-type source.
  - **No other canton publishes an equivalent**, and ASTRA's national
    per-vehicle file (the canton's own upstream) carries no licence text
    anywhere — UNRESOLVED, not ingested.
  - Measured build (S4W/FINISH 2026-10-04, offline, control = the AU pair):
    ids +0/−0 in every kind; 3,876 ids gain `ch` availability (car 1,570 ·
    van 201 · truck 143 · bus 37 · motorcycle 1,805 · moped 120); pairs lost 0,
    renamed 0, orphans 0; FAIL set identical; licence gate 16/16.
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
  fleet is 18.5% pure electric in the 2025 Q4 file (12.7% corpus-wide, 14.3%
  of periodic rows), which is why the source was proposed as the
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
    declared skips.
  - **ATTACH-ONLY: Norway enriches what publishes and decides nothing.**
    `Kjøretøy Modell` is free text typed at registration. Measured
    2026-10-02 (frozen corpus, control vs treatment, adapter the only
    variable): allowed to mint, Norway published **+2,602 ids** (car 1,573 ·
    van 439 · truck 484 · bus 106), **2,534 of them only as the second source**
    beside a 1–6 vehicle NL/FI/NZ tail — `chevrolet/tahoe-lt`,
    `mitsubishi/pajero-gls`, `toyota/ra4a`, `nissan/qashqai-nissannenv`,
    `citroen/berl-92fap-plus`, `toyota/lexus` — and made six ids vanish by
    shifting cross-kind dominance. So `no_svv_pkk` declares
    `Source#attach_only?`: its evidence never counts toward publishing,
    corroboration, cross-kind dominance or the hysteresis entry class. As
    shipped: **+0 ids in every kind; `no` availability on 2,897 published ids
    (car 1,979 · van 282 · truck 476 · bus 160), carrying 3,980,040 of
    4,341,199 periodic inspections (91.7%)**; gate failures identical to
    control. Lifting attach-only needs a curation pass that keys the tail.
  - **Motorhomes (`CAMPINGBIL`) map to `car`, by precedent** (coordinator
    ruling 4, 2026-10-02: a coachbuilder is not promoted to a make by one
    register). PKK carries the coachbuilder as make (`HYMER`, `DETHLEFFS`…)
    exactly like FI and ES, whose coachbuilder makes `overrides/makes/drop.yml`
    already drops from `car`; chassis-make rows (`VOLKSWAGEN|CALIFORNIA`,
    `FIAT|DUCATO`) land under the chassis make. 49,189 periodic rows / 9,887
    keys / 232 raw makes (FIAT 4,995 · HYMER 4,844 · BURSTNER 4,654 ·
    DETHLEFFS 3,967 · CAPRON 3,871 · CHALLENGER 2,831 · VOLKSWAGEN 2,689 ·
    RAPIDO 2,392 · ADRIA 1,983 · KNAUS 1,663 · HOBBY 1,366 · CARTHAGO 1,055 ·
    MERCEDES-BENZ 1,052 · EURA MOBIL 926 · PILOTE 923 · LMC 865 · WEINSBERG 598
    · BENIMAR 589 · POESSL 559 · FORD 479). Attach-only means none of it can
    mint. Ambulances, hearses and patient-transport vans stay declared skips
    (2,852 periodic rows): their model cells describe the conversion
    (`CRAFTER 2,0 TDI 4X4 AMBULANSE`), not a nameplate.
  - **Chassis numbers are typed into the make and model cells.** No
    identifier COLUMN exists, but real 17-character VINs appear as free text
    (a Scania WMI in a truck model cell, a Renault WMI in a bus model cell,
    Fiat WMIs as motorhome makes, more among trailers). The adapter drops any
    row whose make or model carries a VIN-shaped token (15 rows in the build)
    and logs the count. The normalizer's VIN-ish filter only catches strings
    that START with digits, so it does not see these.
  - **Two first-registration dates, and they differ for 8% of the fleet.**
    `Første gang registrert` is first registration ANYWHERE;
    `Første gang registrert i Norge` is first registration IN NORWAY. They
    differ on 348,454 of 4,341,199 periodic rows (8.0%, the used imports; gap
    1 year on 139,758). A Norway-market curve must use the second. Neither is
    emitted: the inspection deferral makes the recent end an artefact.
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
    `ktm/gsa20`, `chevrolet/ck`). As shipped (re-cut measured 2026-10-10 on
    the 2026-10-09 load, frozen control vs treatment against main
    c3297c2/181cfea, vehiclesdb-pipeline#254): **+0 ids, 0 renames, gate failures identical
    to control; `il` on 1,495 published ids** (car 784 · van 98 · truck 171 ·
    bus 36 · motorcycle 392 · moped 14) carrying 3,642,612 of 4,506,115
    ingested active vehicles (80.8%; car 85.8%, motorcycle 6.0% — the
    type-code cells rarely meet a catalog name).
  - **Make splits.** Three Hebrew labels file a second marque: `ב מ וו`
    (BMW) carries MINI (7,256 active), `ניסאן` (Nissan) carries Infiniti
    (2,880, plus 365 prefix-less QX/Q cells) and `פיאט` (Fiat) carries Abarth (670)
    and the Jeep Renegade (464); `ב מ וו` also carries the MINI Aceman. Without a split they
    attached to `car/bmw/cooper*`, `car/nissan/infiniti` and
    `car/fiat/*-abarth` (found by the I-11 verifier on #254). The rules
    live in `overrides/kind_maps/il_mot.yml` `make_splits`, are applied by
    `il_mot` only, and land the vehicles on `car/mini/cooper` (5,788),
    `car/mini/countryman` (1,096), `car/abarth/500` (631),
    `car/infiniti/q50` (561) and so on. A bare `INFINITI` cell (825) names no
    nameplate and is dropped and logged.
  - **Licence — coordinator ruling R1 (2026-10-10, owner-delegated):
    ACCEPT on path (b): facts with credit, never relabelled CC BY.** Every
    package read is `other-open` with no text; the site licence governs
    (https://data.gov.il/he/terms-of-use, read 2026-10-10 with a browser UA:
    HTTP 200, 39,416 B, sha256 `4aa08bee…7eff6b`, "updated 30/08/2025"). It
    permits copying, distribution, derivatives and commercial use, but it is
    not CC BY:
    - **Pass-through clause (value-added products), verbatim:** «זכויות יוצרים
      במוצרי ערך מוסף יהיו שייכות לך או למי שאתה מייעד אותן. אולם, זכויות
      היוצרים במידע שבו נעשה שימוש לפי רישיון זה, הכלול במוצר ערך מוסף, ככל
      שהן קיימות, יהיו שייכות למדינת ישראל, כאשר השימוש במידע יהיה בכפוף
      לרישיון שימוש זה.» ("Copyright in value-added products belongs to you.
      However, copyright in the Information used under this licence that is
      included in a value-added product, to the extent it exists, belongs to
      the State of Israel, and use of the Information remains subject to this
      licence.") There is no sublicensing grant, so the State's Information
      cannot be relicensed CC BY 4.0 inside our product.
    - **The basis we publish on — the facts carve-out, verbatim:** «רישיון זה
      אינו גורע משימושים המותרים על פי חוק, לרבות הגנת השימוש ההוגן ולרבות
      שימוש בעובדות ובנתונים לכשעצמם, בדרך שאינה מפרה את ההגנה על בחירת
      הנתונים, הסדר והארגון שלהם.» ("This licence does not derogate from uses
      permitted by law, including fair use and the use of facts and data
      themselves, in a way that does not infringe the protection of the
      selection, order and arrangement of the data.") VehiclesDB publishes
      only aggregate make/model/kind facts re-keyed to its own ids — neither
      the Ministry's selection nor its arrangement — so `il_mot`'s manifest
      `license` is `facts-credit-data.gov.il-terms-of-use` and its
      ATTRIBUTION line reads "published as facts, with credit to data.gov.il,
      under the data.gov.il Terms of Use … not relicensed under CC BY 4.0".
    - **Prohibited uses** that still bind us as users (not relicensed, so
      stated here for downstream readers): no misleading presentation or
      false representation, no alteration that distorts the information, no
      harm to the dignity or name of the copyright holder, **no use that
      harms a person's privacy, including by cross-referencing**, no unlawful
      use. Breach terminates the licence; exclusive Jerusalem jurisdiction.
      Argument and counter-argument: vehiclesdb-pipeline#210.
    - **Pin.** The terms page is WAF-blocked to the pipeline's UA, so the pin
      guards the CKAN licence fields (`other-open`, isopen true) of
      `degem-rechev-wltp` and the text is quoted in the adapter; re-read it by
      hand with a browser on each release.
    - **Scope exclusion.** The licence does not cover information «שהושג שלא
      כדין ו/או שלא ברשות, לרבות תוך עקיפת אמצעים טכנולוגיים» (obtained
      unlawfully or without permission, including by circumventing technological
      measures). The adapter reads only the published CKAN API with the
      pipeline's own User-Agent; it never works around the WAF that blocks the
      bulk routes.
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
- **au_bitre** — **ATTACH-ONLY** (pipeline DECISIONS.md, measured
  2026-10-03 on the frozen 48q corpus, adapter the only variable). Allowed to
  mint: +919 ids / −23 (+30 gate FAILs); classified 605 clean (65.8%), 127
  kind twins of live ids (mostly LCV→van ute twins), 109 near-prefixes of live
  ids, 62 registry classes (`harley-davidson/*-series`, `holden/utility`), 16
  spelling variants of live ids — headed by `toyota/landcruiser-prado`
  (356,514) against the live `toyota/land-cruiser-prado`. Shipped: **+0 ids;
  `au` availability on 2,498 published ids (car 1,347 · van 131 · truck 110 ·
  bus 58 · motorcycle 852), carrying 19,484,646 of 21,983,634 vehicles
  (88.6%)**; gate failures identical to control. Ruling 3 (LCV → `van`) is in
  the kind map; its 24-id kind migration only happens when AU mints, so none
  is written. Licence: CC BY **3.0 AU** (not 4.0) — see the pipeline PR for
  the compatibility reading. The census date is parsed strictly
  (`strptime`), after fuzzy `Date.parse` turned "31 Smarch 2025" into today's
  month on 2026-10-03.
- **au_bitre** (data facts) — one national file, and deliberately not a union of states:
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
  **(5) `Light commercial vehicles` → `van` — RULED (coordinator ruling 3,
  2026-10-02).** 4,195,963 vehicles; consistent with `uk_dft`'s "Light goods
  vehicles" → van, though the class is dominated by utes. Under attach-only it
  moves no id (see the attach-only paragraph above); its car→van migration is
  deferred to the PR that lifts attach-only.

- **it_aci** — **ACI *Autoritratto*, Open Data edition**: the 2025 archive
  [`Autoritratto-2025-OD.rar`](https://aci.gov.it//app/uploads/2026/06/Autoritratto-2025-OD.rar)
  (12,552,608 B, sha256 `1e93f155…`, fetched 2026-10-10), member
  `Circolante_FTS_Autovetture_2025.ods`, sheet `1_Riepilogo_Nazionale` —
  "PARCO VEICOLARE AUTOVETTURE PER FABBRICA TIPO SERIE - 31/12/2025", columns
  `Fabbrica | Tipo | Serie | Totale Veicoli`. Italy's car fleet on the PRA at
  31/12 of the edition year, aggregates only (no identifier column exists).
  9,591 data rows summing to **41,795,962** cars, which **equals the sheet's own
  `TOTALE NAZIONALE` row** — the adapter re-asserts that every build and raises
  on drift. Series are summed per (Fabbrica, Tipo): 1,493 pairs, 41,401,925
  cars kept. Basis `stock-circulating-pra`; the snapshot date is read from the
  sheet title, never from the file name. Measured 2026-10-10 on a frozen
  control-vs-treatment build: **+76 car ids** (each one is checked by an
  independent corroboration pass before it ships — coordinator ruling R2), −1
  (`car/mercedes-benz/clase`, a pooled-junk record; see `removals.yml`), `it`
  availability gained on 1,053 already-published car ids, and **40,824,412
  Italian cars (97.68% of the national total) on published ids**.
  - **Licence — the Open Data section, verbatim** (https://aci.gov.it/attivita-e-progetti/studi-e-ricerche/open-data/,
    fetched 2026-10-10, pinned as `it_aci`): «I dati statistici della presente
    sezione sono liberamente fruibili da chiunque nel rispetto dei termini
    previsti dalla licenza di utilizzo Creative Commons CC-BY 4.0 (cfr.
    https://creativecommons.org/licenses/by/4.0/).» The archive is linked from
    that section, so this sentence is the grant for the file we ingest.
  - **Why the Open Data archive and NOT the Autoritratto page's zip** (the
    endpoint switch required by ruling R2). The same table also ships as
    `Autoritratto2025_Parco_veicolare.zip` (xlsx) on the *Autoritratto* report
    page, which has no dataset licence sentence. ACI's own access regulation —
    *Regolamento di accesso telematico ai dati e servizi contenuti nel sito
    istituzionale dell'ACI*, linked from the Open Data page
    (https://aci.gov.it//app/uploads/2024/06/REGOLAMENTO_accesso_telematico_2017.pdf,
    71,369 B, sha256 `077ed431…`, fetched 2026-10-10) — splits the licence by
    where a thing is published, art. 3: c.1 «I dati statistici, desunti
    dall'archivio del PRA e pubblicati sul sito istituzionale nella sezione
    "Dati statistici/Open Data", sono liberamente fruibili da chiunque nel
    rispetto dei termini previsti dalla licenza di utilizzo Creative Commons 4.0
    (CC-BY 4.0).»; c.2 «I rapporti statistici e le opere dell'ingegno saranno
    aperti al solo riutilizzo nel rispetto dei termini previsti dalla licenza
    di utilizzo Creative Commons 4.0 (CC-BY-ND 4.0) …». A table shipped as part
    of the *report* could be read under c.2 — **NoDerivatives, which this
    dataset can never ingest** — so we read the Open Data copy, which sits
    squarely under c.1. The data did not change: the OD `.ods` and the report's
    `.xlsx` are cell-identical on all 27 data sheets (same rows, same
    whitespace, same total; compared 2026-10-10).
  - **The site's AI clause, verbatim, and our disclosure.** ACI's
    [Note legali](https://aci.gov.it/informazioni-per-la-navigazione/note-legali/)
    (fetched 2026-10-10, page dated 17 July 2026, pinned as
    `it_aci_note_legali`) put the site under CC BY 4.0 «a condizione che sia
    citata la fonte e – dove possibile – riportato l'indirizzo web della
    pagina originale» and add: «È vietata da parte dell'utente la
    manipolazione tramite IA delle informazioni testuali, degli elementi
    multimediali e del patrimonio conoscitivo presenti su questo sito web che
    vadano ad alterarne il senso e a ledere l'immagine e le finalità
    istituzionali dell'Ente.» ("The user may not use AI to manipulate the
    site's texts, media and knowledge in ways that alter their meaning and harm
    the image and institutional purposes of the Entity.") The clause is pinned
    verbatim, so any change to it fails the licence gate. It binds *us* as the
    site's user and is conjunctive (meaning altered **and** ACI harmed); it
    does not pass to recipients of this CC BY dataset. **Disclosure: VehiclesDB's
    normalisation of this table is partly AI-agent-assisted** — the adapter and
    the override lines below are written with AI coding agents and reviewed by
    humans and by independent verifier passes. Everything it does to ACI's
    numbers is listed, never silent:
    - **Folds and renames** (every one is a line in `overrides/` with its reason,
      source URL and evidence tier): 100 model renames in `models/renames.yml`
      (98 nameplate folds — Italian range labels, 2WD/4X2 Tipo, 12-character
      cuts, typos, Excel date serials — and 2 display-only casings, Citroën `LN`
      and Infiniti `FX`), 4 make aliases (`AUSTINHEALEY`, `TATA ENG`, `EMC`,
      `EVO`; `MERCEDES` was already aliased), 3 cross-make moves (`GREAT WALL |
      HAVAL H2` → Haval, `RENAULT | A110/A290` → Alpine), 5 car-kind drop
      patterns (Fiat `35`, VW `TRANSPORTE`, Opel `2000|2300|CARAVAN`, Renault
      `R`, Ford `SCORPION` — van rows or no nameplate), 1 van-kind containment pattern (Citroën `2CV`, so the car-kind 2CV rescue cannot mint a mis-named van record), and 2 pipeline family
      rules (Mercedes `CLASSE`/`SERIE` words; Land Rover's 12-character cuts).
    - **What does not reach a published id, by count** (2025 edition, 41,795,962
      cars): **394,037 (0.94%) in ACI's own residual buckets**, which name no
      model and are skipped — `Fabbrica = NON DEFINITO` 30 rows / 290,735;
      `Tipo = ALTRI TIPI` 121 / 72,927; blank `Tipo` 21 / 16,231; `ALTRE
      FABBRICHE` 2 / 8,432; `Tipo = ALTRI` + `Serie = TIPI` (the same bucket
      split across two cells) 19 / 5,712. Then **548,489 (1.31%) dropped by the
      normalizer**, 139 rows, almost all M1-registered vans that the car kind
      excludes everywhere (Doblò 86,593, Kangoo 49,953, Berlingo 37,157, Caddy
      27,422, Tourneo Courier 25,217, Tourneo Custom 18,879, Scudo 18,358, …),
      plus Mercedes `200` (17,876 — a pre-existing `null` rename: bare W123/W124
      engine code) and Sportequipe `6`/`7`/`8`. Then **29,024 (0.07%) on 86
      model strings that classify but do not publish** (below the car threshold
      without a second register, or pruned as another kind — `fiat/topolino`,
      `mitsubishi/l200`, `piaggio/porter`, `nissan/pick-up`).
  - **RAR5, read with `bsdtar` only.** The 2025 archive is RAR v5. libarchive's
    `bsdtar` extracts it; p7zip 17.05 lists it and then writes every member as
    a **0-byte file** ("Unsupported Method") — so there is no 7z fallback, and
    the build workflow installs `libarchive-tools` (ubuntu-latest does not ship
    it). Older editions are `.zip` and go through the same path.
  - **The file is `.ods`, not xlsx**, read by the pipeline's own stdlib ODS
    reader. ACI writes every trailing space as `<text:s/>` and every count as a
    float cell whose display text is Italian-formatted (`1.172.439`); the
    reader returns the cell value, never the display.
  - **The archive URL rotates every year** (`/app/uploads/YYYY/MM/`) and so do
    the name and the format (`Autoritratto-2025-OD.rar`,
    `Autoritratto-2024-OD.zip`, `Autoritratto_2022_OD-1.zip`). The adapter reads
    the link from the Open Data page, takes the newest edition, raises if none
    matches or if one edition has two archives, and never falls back to a
    hard-coded URL.
  - **Tipo is cut at about 12 characters**, and the cut drops the marque word:
    `COROLLA VERS`, `DS7 CROSSBAC`, `TOURNEO COUR`, `DISCOVERY SP`, `RANGE
    EVOQUE`. Without the Land Rover rule extension, `DISCOVERY SP` published
    26,883 Discovery Sports as the Discovery. Every value also carries a
    trailing space, which the adapter strips.
  - **Italian range words**: `CLASSE A` (Mercedes, 944,487 cars across the
    classes — the normalizer's Mercedes rule, which also fixes Spain's `CLASE
    A`), `SERIE 3` / `SERIE 4 GC` / `SERIE 3 GT` (BMW, renames), `SERIE 200`
    (Rover, renames), `SERIE W123` (Mercedes chassis families). Drivetrain
    markers are their own Tipo: `JUKE 2WD` alone is 140,904 cars.
  - **EXCEL DATE CORRUPTION in ACI's own data**: three Tipo cells hold date
    serials — Saab `46090` (= "9-3", read as 9 March; 12,772 cars), `46151` (=
    "9-5"; 1,905) and Morgan `46116` (= "4-4"; 402). The `.ods` carries the
    same numbers the xlsx did (float cells, display "46090"), and no other Tipo
    or Serie cell in the national sheet is a date-shaped number (checked
    2026-10-10). They are rescued by rename keys. **The serials are specific to
    this edition**: a new file can carry new numbers, so re-check the next
    edition for bare 5-digit Tipo values.
  - **Brand quirks**: `MERCEDES` (already aliased), `AUSTINHEALEY`, `TATA ENG`.
    ACI files Daewoo-era cars under `CHEVROLET` (Lanos, Nexia), Haval H2 under
    `GREAT WALL`, and the Alpine A110/A290 under `RENAULT` (moves.yml). DR, EVO,
    EMC, Sportequipe and Tiger are Italian rebadgers that no other register
    carries in volume; DR/EVO model names repeat the make (`DR 5.0`, `EVO 5`),
    so prefix-stripping leaves `5.0`/`5`, which junk? kills — rename keys
    rescue them. Sportequipe `6`/`7`/`8` (3,628 cars) are still dropped.
  - **Cars only, and no vote on kind.** ACI's other kind sheets are make-only,
    so Italy contributes to `car` only — and for that reason it has **no vote in
    the cross-kind dominance prune** (`Source#kind_dominance_vote?`): measured on
    the first build (2026-10-02), Italy's car-only volume alone pruned 22 van
    ids (`suzuki/jimny`, `mitsubishi/pajero`, …). Its counts still drive
    publication, popularity and availability.
  - **No powertrain.** There is no fuel column. `Serie` free text is not mapped:
    an absent token does not mean petrol, and FIAT's `1.0 HYBRID` (493,791
    Pandas) is a mild hybrid, which the closed vocabulary deliberately cannot
    express. No history either (no year column).

## Watch-list (evaluated, not yet merged — with the blocker)

| Source | Blocker |
|---|---|
| 🇨🇭 CH ASTRA national per-vehicle file (`opendata.astra.admin.ch/ivzod/`, BEST.txt) | **UNRESOLVED (licence)** — 'Lizenz', 'licence', 'Creative Commons', 'CC BY', 'CC0' occur ZERO times on every ASTRA page and in its overview PDF ('frei verfügbar (Open Data)' is not a licence). Federal BFS tables are make-only. Switzerland ships one canton via `ch_tg` (presence-only) meanwhile. |
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
