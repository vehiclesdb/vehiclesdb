# Changelog

Dataset releases. Versioned `YYYY.MM.PATCH`; each release is a git tag.

## [Unreleased] — model lifecycle (lane LIFE)

- **New optional `lifecycle` object** on every model where it is catalogued. It holds `status` (`announced`, `in_production`, `ending`, `ended`, `cancelled`), `year_start`, `year_end`, `year_start_planned`, `year_end_planned` and `announced`.
  - It appears in `catalog/`, in `dist/vehicles.json`, as five appended CSV/parquet columns and as five appended `catalog.sqlite` `models` columns.
  - It is additive, so schema versions do not move. SCHEMA.md *Lifecycle* has the details.
- **Records without a register.** `overrides/models/attested.yml` has a `manufacturer` form, for officially announced production vehicles that no register carries yet. Such records have no availability or popularity, and `manifest.json` `kinds.<kind>.announced` counts them. DECISIONS.md *Lifecycle* has the admission bar and the review rule.
- **Tesla.** Every record now carries its lifecycle, sourced to Tesla's filings and quarterly updates:
  - Model S 2012–2026 ended
  - Model X 2015–2026 ended
  - Model 3 2017–now
  - Model Y 2020–now
  - Cybertruck 2023–2027 (ending; stated by Elon Musk on X, 2026-11-11)
  - Roadster 2008–2012, next generation announced for 2028
  - new: `car/tesla/cybercab` (in production since 2026) and `truck/tesla/semi` (since 2022)

  The Cybertruck's body type is corrected from `hatchback` to `pickup`.

## [2026.11.6] - 2026-11-10 — commercial-variant gate, register artefacts cleaned, Israeli GM order codes, Kyburz as one make

**16,327 models across 966 makes (16,355 → 16,327; 47 added, 75 retired: 59 aliased to a live successor, 16 removed with a removals.yml entry).**

Same frozen register snapshots as 2026.11.2–11.5. All registers: 95.16% → 95.36% of vehicles land on a published record (+210,019). Fewer, cleaner records: register artefacts (legal-form suffixes, converter compounds, company names written as models) no longer mint their own makes and models.

### Coverage (11.5 → 11.6)

| | 2026.11.5 | 2026.11.6 |
|---|---:|---:|
| Israel truck | 79.39% | 91.47% |
| Argentina car | 96.67% | 98.32% |
| Spain van | 97.83% | 99.34% |
| Finland car | 96.62% | 97.63% |
| UK van | 93.86% | 94.85% |
| Netherlands van | 91.84% | 93.07% |
| Norway car / van | 97.30% / 94.79% | 97.78% / 95.50% |
| Luxembourg van | 96.33% | 97.98% |
| Netherlands moped | 76.57% | 76.13% |
| all registers | 95.16% | 95.36% |

Netherlands moped falls because 6,422 rental scooters were registered with the rental company's name as their model. They are no longer attributed to a made-up model.

| kind | 2026.11.5 | 2026.11.6 | Δ |
|---|---:|---:|---:|
| car | 6,088 | 6,072 | −16 |
| motorcycle | 6,316 | 6,318 | +2 |
| moped | 1,481 | 1,481 | +0 |
| van | 813 | 806 | −7 |
| truck | 1,220 | 1,214 | −6 |
| bus | 437 | 436 | −1 |

### Commercial-variant gate and cross-kind attach
- **Gate.** The passenger-variant gate is now symmetric: a car nameplate also publishes a **van** record when one register with a row-level M1/N1 split (Spain, Finland, UK, Luxembourg, Netherlands) shows at least 100 N1 rows and at least a 25% N1 share.
- **New van records:** Austin Maestro, Jeep CJ-7, Land Rover Freelander, Mitsubishi Pajero Sport.
- **Attach.** Below the threshold, a car or van row whose nameplate has no record in its own kind counts on the published record of the other kind, without minting a thin record:
  - 118,495 van-class vehicles now count on car records (e.g. Ford Fiesta vans);
  - 75,982 car-class vehicles count on van records (e.g. Renault Trafic passenger versions).
- Country rankings and make country lists are recomputed after attach.

### Israel
GM order codes in the heavy-vehicle register (e.g. Chevrolet CK20743) resolve where a code decodes to exactly one nameplate: Silverado, Express, Suburban, Sierra. About 17.9k trucks. The evidence is partial-VIN decodes (maker and model-code positions only). Codes that span two models or change with the model year stay unresolved.

### Makes and identity
- **Kyburz is one make.** `moped/kyburz-switzerland/*` aliases to `moped/kyburz/*`. Both `moped/kyburz/dxp` (European registers) and `motorcycle/kyburz/dxp` (Australia, registered as a motor tricycle) are kept. An attested record now always survives the cross-kind prune.
- **Register-artefact cleanup:**
  - company names merge into their brands (e.g. Riese & Müller, Grecav, Caterham);
  - parent-make echoes are stripped (Alpina "BMW ALPINA …");
  - body-converter compounds are re-homed onto the base vehicle, but only where the register names the base (an Igloocar conversion with no base type stays unattributed).
- **Corrected ids keep their publication history,** so identity corrections (e.g. Alpina B3 GT) stay published instead of being demoted.
- **Correction to 2026.11.5:** `car/holden/hsv` was listed as retired but was still published. Bare "HOLDEN | HSV" rows name only the marque, so they are no longer attributed, and the record is now retired.

### Checks
- Frozen build: ALL GATES GREEN.
- Lints, id-history against the built dist, and gem 0.9.1 conformance 170/170.
- Codex Astra review, two rounds; every finding is fixed.

## [2026.11.5] - 2026-11-10 — all-register residual curation, HSV as a make, Australian utes on their car records

**16,355 models across 991 makes (16,225 → 16,355; 132 added, 2 retired, every retirement aliased to a live successor).**

Data-only release (data#403), on the same frozen register snapshots as 2026.11.2–11.4. All registers: 94.34% → 95.16% of vehicles land on a published record (+907,555).

### Coverage (11.4 → 11.5)

| | 2026.11.4 | 2026.11.5 |
|---|---:|---:|
| Argentina car | 80.29% | 96.67% |
| Argentina truck | 49.59% | 79.17% |
| Australia car | 98.16% | 99.63% |
| Australia motorcycle | 72.41% | 80.65% |
| Australia bus | 50.11% | 89.47% |
| Australia van | 79.11% | 85.78% |
| Israel car | 96.35% | 99.00% |
| Israel van | 80.62% | 93.88% |
| Israel motorcycle | 27.41% | 38.24% |
| Israel truck | 70.48% | 79.39% |
| Ukraine motorcycle | 53.29% | 62.30% |
| Spain van | 96.65% | 97.83% |
| Spain truck | 95.54% | 95.92% |
| all registers | 94.34% | 95.16% |

**Reading these numbers.**
- Some register rows carry no model at all, and they can never land on a model record:
  - the UK DfT's "<MAKE> MODEL MISSING" covers ≈851k motorcycles, ≈647k trucks, ≈520k cars and ≈273k vans;
  - Spain's DGT writes "N.A." for ≈1,060 Rieju/Beta mopeds.
- So UK motorcycle (67.6%) and UK truck (19.4%) coverage reads against a ceiling, not a gap. Over *attributable* vehicles they are at ≈95.9% and ≈94.8%. See DECISIONS.md, "Unattributable register rows set a coverage ceiling".
- Australia car includes the utes that the owner ruling attaches to their car records (below). Their light-commercial rows leave the van denominator.

| kind | 2026.11.4 | 2026.11.5 | Δ |
|---|---:|---:|---:|
| car | 6,025 | 6,088 | +63 |
| motorcycle | 6,266 | 6,316 | +50 |
| moped | 1,482 | 1,481 | −1 |
| van | 806 | 813 | +7 |
| truck | 1,209 | 1,220 | +11 |
| bus | 437 | 437 | 0 |

### Owner rulings
- **HSV is its own make.** Holden Special Vehicles products filed under HOLDEN move to HSV: Clubsport, Senator, Maloo, GTO, Avalanche, Grange and Manta. `car/holden/maloo` aliases to `car/hsv/maloo`. GTS stays with Holden, because a bare "HOLDEN GTS" may be the Monaro GTS.
- **Electric names in the maker's spelling:** Abarth 600e, Mercedes-Benz EQT, Honda e / e:Ny1 / e:N1, Audi Q4 e-tron / Q6 e-tron.
- **Australian utes count on their car records:** Holden Colorado, Ford Falcon, Commodore and Crewman, by an explicit, cited list in `kind_maps/au_bitre.yml`. Nameplates whose light commercials include panel vans, or whose Australian code means another model (Mazda B3000 = BT-50), are not routed.
- **Israeli motorcycle type codes shared by several models stay unresolved.** Accuracy beats coverage.

### Curation
Every register was replayed through the real normalizer to separate unattributable rows, normalizer drops and unpublished candidates. The largest fixable buckets were then curated with fetched tier-1/2 sources:
- **Australia:** Subaru Liberty, Toyota Tarago, Mitsubishi Magna and 380, Holden Statesman / Caprice / Jackaroo / Viva / Adventra, MG ZST, LDV D90, Mahindra XUV700 (attach-only evidence). Harley-Davidson's FXD/XLH census codes fold onto Dyna/Sportster.
- **Israel:** Hyundai i25 / i35, Geely Geometry C, Chery FX / Arrizo 8. Ford W2B/W3B fold onto F-250/F-350, and Chevrolet CT onto the Silverado EV. The Ministry's Peugeot plants filed under Piaggio move to Peugeot.
- **Argentina:** Fiat Mobi / Argo / Pulse, Renault Kwid, Nissan Kait, Citroën Basalt, Ram Dakota, VW Constellation, Mercedes-Benz Accelo, plus grade and engine tails folded.
- **Elsewhere:** NZ Japanese-market names, Ukrainian brands, UK 125cc motorcycles, Spanish long-tail vans and trucks.
- **attested.yml grows from 612 to 745 entries** (207 attach-only).
- **`rename_kinds.yml`** scopes rename keys that are also published names in another kind (e.g. a UK "Corsa" van row → Corsavan, never the Corsa car).

### Checks
- Frozen build: ALL GATES GREEN.
- Lints, `lint_enrich`, and gem 0.9.1 conformance 170/170.
- Codex Astra review, two rounds; every finding is fixed:
  - a generic Australian light-commercial rule that also moved real vans was replaced by the explicit ute list;
  - per-vehicle VINs in citation URLs became partial-VIN queries;
  - Harley-Davidson FXS → Softail was held, because the code also covers 1977–82 Low Riders.

## [2026.11.4] - 2026-11-10 — register-native kinds, Israel type codes, Spain two-wheelers, Australian trucks, name cleanup

**16,225 models across 981 makes (16,032 → 16,225; 243 added, 50 retired, every retirement aliased to a live successor).**

Same frozen register snapshots as 2026.11.2 and 2026.11.3. The diff comes from curation (data#400) and pipeline changes (pipeline#280, #281) alone. All registers: 94.17% → 94.34% of vehicles land on a published record (+177,601).

### Coverage (share of each register's vehicles on a published record, 11.3 → 11.4)

| | 2026.11.3 | 2026.11.4 |
|---|---:|---:|
| Spain motorcycle | 92.41% | 97.46% |
| Spain moped | 62.06% | 70.60% |
| Spain van | 94.92% | 96.65% |
| Spain bus | 69.20% | 87.34% |
| Spain car | 97.99% | 98.06% |
| Spain truck | 95.57% | 95.54% |
| Israel motorcycle | 5.79% | 27.41% |
| Australia truck | 81.74% | 95.28% |
| Argentina car | 70.19% | 80.29% |
| Argentina van / truck / bus | (all in car before) | 87.28% / 49.59% / 100% |
| all registers | 94.17% | 94.34% |

Spain and Argentina denominators move slightly. Rows that had no kind now get one from the register's own type field, and Argentina's trailers leave the car denominator.

| kind | 2026.11.3 | 2026.11.4 | Δ |
|---|---:|---:|---:|
| car | 5,997 | 6,025 | +28 |
| motorcycle | 6,196 | 6,266 | +70 |
| moped | 1,459 | 1,482 | +23 |
| van | 795 | 806 | +11 |
| truck | 1,159 | 1,209 | +50 |
| bus | 426 | 437 | +11 |

### Register-native kinds (pipeline)
- **Spain (DGT):**
  - A row with a blank EU category takes its kind from COD_TIPO (the register's vehicle-type code), but only for codes that the categorised rows agree on at ≥ 99.7%. That covers 2,099 used imports over Jul–Sep 2026.
  - Bodybuilder re-homing (converter make → base-vehicle make) now covers plain-body cars (e.g. KG Mobility Rexton conversions, LPG Cupra Terramar) and minibuses (Sprinter, Transit and Master minibus conversions, Castrosua bodies on Scania).
  - A van conversion of a car with no van record (Zago "SANDERO VAN") lands on the car record.
- **Argentina (DNRPA):**
  - The "autos" file holds every non-motorcycle vehicle, and kind now comes from its body-type field.
  - Trailers, caravans and UTVs no longer count as cars. Vans, trucks and minibuses get their own kind.
  - Pick-ups follow the kind the catalog already publishes the nameplate in. Amarok is van; Hilux, Ranger, Toro and others stay car.
- **Australia (BITRE):** curated per-nameplate routes move cab-over light trucks filed as light commercials to truck: Isuzu NPS/Elf, Hyundai Mighty, Nissan Atlas, Mazda Titan.

### Israel motorcycles: type codes
The Israeli two-wheeler register names a machine by its manufacturer **type code** (Honda NF13, Yamaha SJ18), and the Ministry publishes no code-to-name table. The Dutch RDW register (CC0, already a source) pairs the same type codes with commercial names. 173 high-confidence codes (exact code, ≥ 5 RDW vehicles, ≥ 90% one name, target already published) now resolve **+39,115** Israeli motorcycles. Separately, the Hebrew make label read as SWM is SYM (Ministry plant countries, shared type codes, RDW).

### Curation
- **attested.yml grows from 395 to 612 entries (186 attach-only).** Every new entry carries a fetched tier-1/2 URL:
  - Spanish two-wheelers: Kove, Efun, Next, QJMotor, MITT, Morbidelli, Zontes, Letbe, Zairon, Hero, TVS and others;
  - Stellantis electric names: E-308, E-408, E-Traveller, ë-C5 Aircross, ë-Jumpy;
  - Spanish buses: King Long, Irizar, Unvi;
  - Australian trucks: Hino 500/700 codes, Kenworth T610/T909/T409/T659/T359/T360/T410/C509, Western Star, International T-Line, Sterling LT/AT, Caterpillar CT;
  - items verified from the held list: MG VS, Proton Compact, Mack Fleetliner, Mercedes-Benz LK, Dangel, Foton eTunland, Mazda B2200.
- **Owner rulings applied:**
  - SYM displacements are separate records where SYM markets them separately (ADX 125 / ADX 300, Symphony ST 125 / 200, Cruisym 125 / 300, Joymax Z 125 / 300).
  - About 40 junk motorcycle names (Euro-norm tails, fused ABS/kW, truncations) fold onto their clean records.
  - `great-wall/tank` folds into Tank 300. The NZ line pools Tank 300 and 500.
  - Electric names in the manufacturer spelling: ID. Buzz, ID. Polo, e-Golf, bZ4X Touring, RS / S e-tron GT, E-Doblò.
  - Converter makes Zago and Mebauto retire onto the base vehicle.
  - Mercedes Atego/Axor car ids (Argentine chassis rows) alias to their truck records.
- **New curation files:**
  - `overrides/models/series_keep.yml`: coded heavy designations that are their own nameplates.
  - `overrides/models/rename_kinds.yml`: a rename scoped to some kinds.
  - `overrides/makes/converters.yml`.
  - `type_codes` in `kind_maps/il_mot.yml` and `by_model` in `kind_maps/au_bitre.yml`.
- **Known-held items** are recorded in DECISIONS.md:
  - Australian UD chassis codes spanning generations;
  - Mercedes "96X";
  - Hino FF/FB/GS;
  - Ford Trader and Daihatsu Delta;
  - Spanish two-wheeler type codes with no proven commercial name;
  - Isuzu NPR/NQR/NKR in Australia's light-commercial class.

### Checks
- Frozen build: ALL GATES GREEN.
- Lints: overrides, curation (with new `type_codes` / `by_model` shape checks), id history, make-block order.
- Gem 0.9.1 conformance: 170/170. The 12 kind-collision cases wait for gem 0.9.2.
- Codex Astra review, two rounds; every finding is fixed.

## [2026.11.3] - 2026-11-10 — attach-only attestation, GWM sub-brands, Opel Electric records, and dataset fields for safe refresh

**16,032 models across 970 makes (15,845 → 16,032; 204 added, 17 retired, every retirement aliased to a live successor).**

Same frozen register snapshots as 2026.11.2. The diff is attributable to curation (data#398) and pipeline changes (pipeline#279) alone.

### New fields (additive; `schema_version` unchanged; see SCHEMA.md)
- **`former_slugs` on makes** (dist, catalog, sqlite `makes.former_slugs`).
  - These are make slugs merged or renamed into this make, so a client can follow a make rename without scanning every model's `former_ids`.
  - 11 makes carry them, e.g. renault ← renault-trucks, daewoo ← gm-daewoo, saxas ← saxas-nutzfahrzeuge-werdau, mg ← mg-roewe.
- **`manifest.json` → `dist_files`:** `sha256`, `bytes` and `records` for every dist file. Refreshers can verify a download before swapping it in.
- **`registration_years` `{first, last}` on model records.**
  - It is the earliest and latest first-registration year in the Finnish and Dutch registers, counting years with ≥ 2 vehicles.
  - It is a **hint**, registration not production, never a validation bound.
  - Present on 9,908 records.

### Curation
- **Attested admission on attach-only evidence** (owner ruling).
  - A sourced nameplate whose only register evidence is in an attach-only register (Australia, Israel, Norway, Switzerland) can now publish through an explicit `{url, evidence: attach_only}` entry.
  - 138 such admissions: Kenworth T409/T610/T909, Isuzu FRR/FTR/NPS/NKR, Hino 300, Mack Granite/Qantum, Freightliner Columbia/Century Class, International ACCO, LDV G10, GWM Cannon …
- **attested.yml grows from 206 to 395 entries.**
  - 18 Holden series codes (EH…WB), where the code is the name buyers used. VY Commodore is a form of Commodore.
  - 27 Spanish and Alfa Romeo heritage nameplates, verified this release: Macbor, Motorhispania, Keeway, Zontes, MITT, Evo, SWM, Tiger, Alfa 1900 / Junior Z / Giulietta SZ / Arna / Matta.
- **Electric variants are their own records, consistently.**
  - Spelled-out "… ELECTRIC" Opel/Vauxhall rows reach Frontera / Corsa / Astra / Grandland / Mokka / Combo / Vivaro / Movano Electric.
  - Renault "Mégane E-Tech Electric" (nl 9,493) reaches `renault/megane-e-tech`, and Fiat "500 Electric" reaches `fiat/500-e`.
  - The 2014–19 Corsa-E (an ICE generation letter) stays on the Corsa.
- **GWM sub-brands Ora, Tank and Wey get their own makes** (the #346 Haval/Jaecoo/Omoda rule). Ten `great-wall/*` ids alias to `ora/*`, `tank/*` and `wey/*`.
- **Make merge:** `saxas-nutzfahrzeuge-werdau` → `saxas`.
- **Mercedes forms:** "Clase/Classe/Klasse X" are now published forms, so "Clase A" resolves on every surface.
- **León aliases:** the duplicate "León" aliases on SEAT/Cupra Leon are retired; the spelling is the name since 2026.11.2.

| kind | 2026.11.2 | 2026.11.3 | Δ |
|---|---:|---:|---:|
| car | 5,961 | 5,997 | +36 |
| motorcycle | 6,179 | 6,196 | +17 |
| moped | 1,459 | 1,459 | 0 |
| van | 775 | 795 | +20 |
| truck | 1,046 | 1,159 | +113 |
| bus | 425 | 426 | +1 |

## [2026.11.2] - 2026-11-10 — completeness: Spain van/truck to 95%, 194 attested nameplates, manufacturer spellings, junk folded

**15,845 models across 965 makes (15,635 → 15,845; 291 added, 81 retired, every retirement with a migration path).**

**Inputs.** Frozen correctness release on the same register snapshots as 2026.11.1: fi 2026-09-30, es 2026-07…09, uk 2026-Q2, nz MVR_Mar26. The KBA FZ 2.2/2.8/4.8 workbooks are added for `de_kba_nfz` (#391).
- That source changes no ids; it adds `de` to 829 records, measured separately.
- The rest of the diff is attributable to curation (data#394) and pipeline changes (pipeline#277, #278).

**Coverage.** Share of each register's vehicles that now land on a published record, before → after:

| | before | after |
|---|---:|---:|
| Spain, all mapped DGT categories (Jul–Sep 2026) | 92.52% | 95.73% |
| Spain van (N1) | 78.27% | 94.92% |
| Spain truck (N2/N3) | 78.25% | 95.57% |
| Spain car (M1) | 96.54% | 97.95% |
| Spain motorcycle | 87.26% | 90.15% |
| Spain moped | 56.64% | 62.06% |
| Israel car | 86.59% | 96.26% |
| Australia car | 95.59% | 98.16% |
| Norway van | 85.61% | 93.99% |
| Netherlands van | 88.07% | 91.02% |
| Argentina car | 56.18% | 70.19% |
| all registers | 92.75% | 93.80% (+1.24 M vehicles) |

| kind | 2026.11.1 | 2026.11.2 | Δ |
|---|---:|---:|---:|
| car | 5,888 | 5,961 | +73 |
| motorcycle | 6,142 | 6,179 | +37 |
| moped | 1,429 | 1,459 | +30 |
| van | 772 | 775 | +3 |
| truck | 989 | 1,046 | +57 |
| bus | 415 | 425 | +10 |

### What changed
- **DGT bodybuilder rows** (pipeline#277).
  - Converter rows now take the base vehicle's make (`MARCA_VEHICULO_BASE`, DGT layout field 56, bytes 463–492) and drop the converter token, e.g. "ERKE | PARTNER ERKE" → Peugeot Partner.
  - A row is re-homed only when it lands on a published record.
  - Plain `L1`/`L3`/`L4` categories map to moped/motorcycle.
- **Folds onto published records only.** These never mint a new id:
  - litre tails such as "MOKKA GS 1.2 T XHT HYB" → Mokka;
  - Spanish trim words ("Nuevo", Allure, Talla M …);
  - spec suffixes on van/truck/bus (axle 4X2/6X2*4, power, L2H1);
  - Scania/Volvo `*` axle configs.
- **Make merges.**
  - `renault-trucks` → `renault` (owner directive) and `gm-daewoo` → `daewoo`. Old ids resolve through `former_ids`; "Renault Trucks" stays a make alias.
  - 26 entity or spelling make aliases (VOLKSWAGEN V W, AUDI AG, SSANG YONG, JAGUAR CARS, FORD (D) …) and 6 Hebrew respellings in the Israeli register.
- **Attested admission grows from 12 to 206 entries.** Every entry has a fetched tier-1/2 source and a minting register row.
  - Examples: Toyota Axio/Premio/Opa, Honda Orthia/Domani, Holden Belmont/Camira/Premier, Chevrolet Onix/Onix Plus/Montana, VW Nivus/Tera, Fiat Cronos/Toro, BYD Song L/Atto 1, Scania 110/164/G/T, Freightliner Argosy/Cascadia, Kenworth K100/T600, Isuzu NKR/FSR/Elf, MAN NL, Volvo B8RLE …
- **Electric variants are their own records,** following the e-208/ë-C3 precedent.
  - Spanish E-308/E-3008/E-408/E-5008, ë-C4 X, ë-C5 Aircross and ë-C3 Aircross trims fold onto the electric record, never onto the ICE one.
- **Manufacturer spellings (display only; ids unchanged).**
  - Accents and casing: SEAT/Cupra León, Fiat Doblò, Renault Mégane/Scénic/Mégane E-Tech, Lamborghini Huracán (EVO, STO, Tecnica, Sterrato, Spyder)/Murciélago, Citroën ë-Berlingo/ë-C3 Aircross/ë-C4 X.
  - `overrides/models/display.yml` pins fused codes without moving their id: 500X, 500e, 600e, XCeed, ProCeed.
  - Mark-less input ("leon", "500x") still resolves; there are new conformance cases for it.
- **Junk beside real records.**
  - 59 `<nameplate> + engine/body token` records fold onto their nameplate, with `former_ids` (Leon 1.9TDI, Leon Sporttourer, Civic 1.6VTI, 159 SW …).
  - `car/mercedes-benz/classe` (Italian "CLASSE C/E/B") now re-classifies to the real class.
  - 7 make-echo records (datsun/datsun, morris/morris …) are retired to `removals.yml`.
- **Historical gem ids.**
  - `data/gem_history_ids.txt` lists 21,530 ids shipped by gem data 0.1.0–0.8.0.
  - `scripts/lint_id_history.rb`, in CI, keeps every one of them live, aliased or manifested. Three that resolved nowhere now alias.
- **CI.** The source-cache namespace was bumped (#393); stale NZ chunks had caused false NZ vanishes.

### Migration surface
- 81 ids retired: 73 via `former_ids` (same vehicle), 8 manifested in `removals.yml`.
- Full list: RELEASE-DIFF-2026.11.2.md (post-release PR).

## [2026.11.1] - 2026-11-09 — the completeness release: passenger van variants, attested admission, Spain to 96.5%

**15,635 models across 953 makes in 18 countries (15,629 → 15,635; 37 added, 31 retired, every retirement with a migration path).**

Frozen correctness release on the same register snapshots as 2026.11.0: fi 2026-09-30, es 2026-07…09, de 2026-01…10, uk 2026-Q2, nz MVR_Mar26. The diff is attributable to curation and pipeline changes alone, and a control build of 2026.11.0's code and data on the same inputs reproduces 2026.11.0 exactly. `validate: ALL GATES GREEN`; licence pins **17/17**.

**Spain.** New M1 registrations (Jul–Sep 2026, 323,685) that land on a published car record:
- **90.17% → 96.54%** (+20,624);
- measured by replaying every DGT car-kind row through the real normalizer;
- models with Spanish evidence: 2,744 → 2,770 (car 1,275 → 1,301).

| kind | 2026.11.0 | 2026.11.1 | Δ |
|---|---:|---:|---:|
| car | 5,877 | 5,888 | +11 |
| motorcycle | 6,149 | 6,142 | −7 |
| moped | 1,430 | 1,429 | −1 |
| van | 769 | 772 | +3 |
| truck | 988 | 989 | +1 |
| bus | 416 | 415 | −1 |

The car count rises by only 11 because the 34 car records added are offset by 23 junk/misspelt car ids folded away. The motorcycle/moped/bus drops are typo twins and one bus minority folded into their real records; every retired id is aliased.

### Passenger versions of van-based MPVs now publish in kind `car` (data#389, pipeline#272)

**The gap.** A Berlingo, a Caddy Life, a Rifter or a Tourneo bought as a family car is registered M1, but it was findable only under `van`. In Spain it was findable nowhere: the ES van build ingests N1 only, so Spain's M1 rows reached no kind at all (Tourneo Courier/Custom/Connect: 1,388 M1 in 3 months).

**The mechanism.**
- `overrides/models/passenger_variants.yml` lifts single drop patterns per make, each with a closed list of names the lifted rows may publish as.
- A build-time evidence gate decides publication: ≥ 100 vehicles and ≥ 25% car share in one M1/N1 split register (es, fi, gb, lu, nl). Owner ruling: threshold kept.
- Outcome: 22 records publish, 11 are pruned.
- Conversion bases stay out (Sprinter, Ducato, Master, big Transit …).
- Van ids are untouched.

**New car records (22):**
- car/citroen/berlingo, car/citroen/e-berlingo
- car/dacia/dokker, car/dacia/lodgy
- car/fiat/doblo
- car/ford/tourneo-courier, car/ford/tourneo-custom, car/ford/tourneo-connect, car/ford/transit-custom
- car/mercedes-benz/vito, car/mercedes-benz/viano, car/mercedes-benz/citan
- car/nissan/townstar
- car/opel/combo
- car/peugeot/rifter, car/peugeot/e-rifter, car/peugeot/partner
- car/renault/kangoo
- car/toyota/proace, car/toyota/proace-city
- car/volkswagen/caddy

**Germany.** KBA FZ 10.1 is an all-M1 table, so it now routes those 11 nameplates' rows to the car twin (`de` moves from van to car).

### Attested admission, a new general mechanism (data#389, pipeline#272)
- **What it does:** `overrides/models/attested.yml` publishes a real nameplate that the per-kind floor holds back.
- **What an entry needs:** at least one minting register vehicle, plus a tier-1 (manufacturer) or tier-2 (trade/official) source.
- **Guarantees:** it never mints without register evidence, and the build fails on an entry no register row reaches.
- **First 12 entries:**
  - car/ebro/s800, car/ebro/s900 (Spain-only brand);
  - eight pre-war Alfa Romeo 6C/8C (car/alfa-romeo/6c-1500, 6c-1750, 6c-2300b, 6c-2500, 8c-2300, 8c-2600, 8c-2900b, 8c-monza; Museo Alfa Romeo);
  - van/kia/k2700, van/kia/k2900.

### Spain coverage curation (data#389)
- **VW Multivan:** car/volkswagen/multivan and van/volkswagen/multivan. A kind-blind `Multivan: null` had removed it from every kind (812 ES M1 in 3 months).
- **GWM Ora 5:** car/great-wall/ora-5 (es, de, ar, il converge).
- **Spanish 22-character truncated trim strings** now fold onto their nameplates: Opel Frontera, ë-C3, ë-C3 Aircross, e-2008, e-208, e-5008, 2008, 208, C3, C3 Aircross, Rifter, Combo, Berlingo, plus 51 "Nuevo/New …" filler spellings.
- **Mercedes "CLASE X":** DGT's Spanish class-first spellings ("CLASE V/GLC/C …") now resolve to the real class. The junk car/mercedes-benz/clase record (≈15 models pooled together) is retired via removals.yml.

### Retired ids, all aliased unless noted
- **ES junk/truncation stubs:**
  - car/citroen/nuevo-c3-aircross-hybr → c3-aircross
  - car/citroen/berlingoatalla-m-blueh → berlingo
  - car/citroen/c → 5-cv (the 1920s Type C)
  - car/citroen/c-3 → c3
  - car/volkswagen/t4-multivan → multivan
  - bus/ford/tourneo → car/ford/tourneo
  - car/mercedes-benz/clase (manifested, no single successor)
- **24 typo twins**, each source re-verified (e.g. Quashqai → Qashqai, Bonnevile → Bonneville, Intercepter → Interceptor, Ligth Bee → Light Bee).

### Trucks
- **New record:** truck/leyland-daf/65. The UK DfT FA pool now declares 60/65; 65 = 159 HGVs.
- **Fixes:**
  - "220 Se Automatic" → 220 SE;
  - "1841LS" → Actros;
  - BMW bare "CE" → null.
- **Moves and repoints:**
  - Jeep CJ-3B → Willys CJ-3B;
  - Sherco 500 SEF-R → the published sherco/500.

## [2026.11.0] - 2026-11-09 — the resolution release: curated `forms`, one contract for every surface, fresh registers

**15,629 models across 953 makes in 18 countries (15,068 → 15,629, +561).** November refresh from freshly fetched registers (fi snapshot 2026-09-30, de flow 2025-11…2026-10, es through 2026-09, uk 2026-Q2) plus the dogfooding work below; hand-cut locally (`validate: ALL GATES GREEN`, licence pins **17/17** verified; GitHub's scheduled publish is not relied on this month). 13 ids retired, **every one with a migration path** (former_ids alias or removals manifest).

| kind | 2026.10.4 | 2026.11.0 | Δ |
|---|---:|---:|---:|
| car | 5,541 | 5,877 | +336 |
| motorcycle | 6,033 | 6,149 | +116 |
| moped | 1,399 | 1,430 | +31 |
| van | 739 | 769 | +30 |
| truck | 947 | 988 | +41 |
| bus | 409 | 416 | +7 |

### Schema (additive)
- **`forms`** on `dist/vehicles.json` model entries: curated, make-scoped spellings that registers and people write for a record and that fold into it — the keys of `overrides/models/renames.yml`, projected onto the live record their target lands on, only on the kinds where the key actually fired this build. 7,574 spellings on 2,344 records ("Tucson IX35" → `hyundai/ix35`, "Focus C-Max" → `ford/c-max`, "Megane Conquest" → `renault/arkana`, "Marco" → `mercedes-benz/marco-polo`). See SCHEMA.md. Found by dogfooding: 36 of the 41 make/model strings CarHey drivers typed that no VehiclesDB surface could resolve were already curated here (pipeline#271).

### Contract
- **RESOLUTION.md** — one binding contract for turning a typed vehicle name into a record across the `vehicles` gem, `/api/v1/resolve`, the dropdown widget and the JS/Python SDKs (normalization, ladder, typo rules, ambiguity, "only published data counts"), and **`conformance/resolve.json`**, its executable form: 79 cases, passing in the gem, both SDKs and the web resolver on this release (#388).

### Curation
- "Landrover" is a published make alias (it was a Ruby-only built-in in the gem).
- Volkswagen "Sirocco" — a registry misspelling that had minted a junk twin record — folds into Scirocco (rename + former_ids; replaces its 2026-07 demotion manifest).
- `van/mitsubishi/pajero-sport` → `car/mitsubishi/pajero-sport` (no van rows left on today's registers; xref loss of 2 N1 type approvals signed off).

### Pipeline
- Attach-only residual hysteresis: a previously published id whose minting source decays stays while an attach-only register still shows its fleet at the hysteresis floor (never mints). Holds `car/holden/colorado` (NZ files Colorado utes as goods vehicles; Australia's attach-only register shows 8,323 passenger Colorados) (pipeline#271).

### Known
- New Zealand's GOODS VAN/TRUCK/UTILITY class (926k vehicles) is still not ingested; a per-nameplate kind split is needed.
- The CI build check on #388 ran on an older restored source cache and flagged the Pajero Sport alias as live; both local builds on current sources agree it is required.

## [2026.10.3] - 2026-10-10 — Israel joins (attach-only), and the specs layer ships in the paid feed

**15068 models across 934 makes in 18 countries.** The third cut of the owner-authorised stretch of 2026-10-10 (CI publish run 38070378780; `validate: ALL GATES GREEN`; licence pins **17/17** verified). Public ids and names are unchanged apart from the cache-state class noted in `RELEASE-DIFF-2026.10.3.md`; what changed is availability: **Israel (`il`, MoT / data.gov.il) joins as the 18th register, attach-only** (pipeline#254 + #364, ruling R1): ~1,494 published ids gain `il` availability from 3.64 M of 4.5 M Israeli vehicles, published as facts with credit to data.gov.il under its Terms of Use (not relicensed CC BY — see SOURCES.md and ATTRIBUTION.md). No new ids are minted from the Israeli register.

### Also in this release
- **Romania (`ro_drpciv`, DRPCIV Parc auto, OGL-ROU-1.0)** is wired in but ships **disabled** behind an expired `*.gov.ro` TLS certificate (pipeline#267 + data#378); its licence pin is `declared_absent`, the build is byte-identical with it off, and the enable procedure is in pipeline#267.
- Curation: "Mercedes" is a published search alias of Mercedes-Benz (#379); the Vespa GT125 co-move and the Romanian kind map (#378).
- Builder-facing docs and tools (PKG lane): attribution kit with a credit line in 12 languages, badge and footers (#372); the README for builders with generated per-country counts and `scripts/gen_readme_stats.rb` (#371); `scripts/release_diff_by_country.rb` (#374); `scripts/package_release.sh` relational SQLite + Parquet package script (#375; the release-channels step that would attach it is deferred, data#382).
- DEBT: the Civic NL 1920 junk cohort and the registration-year floor proposal (pipeline#268); the Traficom extract vintage.

### Depth (private layer)
- **Model-year specs (G26d)** from fueleconomy.gov + NRCan land in catalog-plus as a fenced `model-year-specs/1` layer (pipeline#185), beside the provenance and generations sidecars; ships in the hand-cut `plus-2026.10.3`. ENR4W Lexus/Daihatsu batch (pipeline#270).

### Known
- `plus-2026.10.3` hand-cut again (`PIPELINE_RELEASE_TOKEN` still unset).

## [2026.10.2] - 2026-10-10 — the provenance release (paid layer) and the developer-quality batch

**15,068 models across 934 makes in 17 countries (15,069 → 15,068, −1).** One id retired with a migration path (`car/volkswagen/2dsedan-1300-11-2400` → `car/volkswagen/beetle`; see Curation), 0 added, ORPHAN section empty (`RELEASE-DIFF-2026.10.2.md`). Second cut of the owner-authorised stretch of 2026-10-10, through the CI publish path (run 38040238666; `validate: ALL GATES GREEN`, licence pins 16/16; same windows as 2026.10.1).

### Schema (additive)
- `dist/vehicles.json` model entries gain an optional `country_ranks` object (the catalog's `popularity.by_country` rank, verbatim, per country code) so a flat-file consumer can rank by one country without loading `catalog/` (pipeline#261; documented in SCHEMA.md by #369). No schema version string moved.

### Curation (DEVQ developer-quality batch, each with an independent Opus I-11 verdict on the PR)
- **Resolver aliases** (#366): 63 alias strings on 35 car records so typed forms resolve on the first try — `Mazda3` / `Mazda 3`, `Octavia Combi`, `Cee'd`, `i30 Fastback`, … — every line with its source URL and tier; `ProCeed` lands on the live `car/kia/pro-ceed`.
- **Body types** (#367): 25 category errors in the top-300 cars by mass corrected with manufacturer sources (F-150, Ram 1500, CR-V and the `Max`-keyword victims were typed hatchback).
- **Make twins** (#368): SCANIA VABIS and POLSKI-FIAT pinned as spellings of Scania-Vabis / Polski Fiat, with the two folds the pin unlocks (L7650/L7642 → L76, LB80S dropped).
- **fi fused door+body prefix** (#376): the register string class `<2-5>D<BODY>…` ("2DSEDAN 1300-11/2400") can no longer publish — a `drop_patterns` class rule (1,399 car + 15 van sub-threshold candidates gone, 0 new) and the one published victim aliased to `beetle`.

### Depth (private layer)
- **Per-fact provenance and structured generations in catalog-plus** (pipeline#258, ruling R4; three Opus I-11 rounds, final MERGEABLE): every enrich fact carries its source rows (url, accessed, tier) in a `provenance[]` sidecar with stable row ids, and `generations[]` is a structured field derived only where the curated runs already state it. Public tree proven byte-unchanged. Ships in the hand-cut `plus-2026.10.2`.
- ENR4W enrichment tail continues: Citroën 14 ids / 132,757 vehicles (pipeline#264), Nissan 14 / 107,265 (#266), Fiat 11 / 77,255 (#265); enrich comment hygiene + a URL-liveness sweep of every cited URL (#262, 64 rot/moved rows filed in DEBT by #373).

### Known
- `plus-2026.10.2` hand-cut again (`PIPELINE_RELEASE_TOKEN` still unset).

## [2026.10.1] - 2026-10-10 — the mass-decile release (and the first owner-AFK autonomous cut)

**15,069 models across 934 makes in 17 countries (14,997 → 15,069, +72).** +82 ids added and −10 retired, **every retirement with a migration path**: 8 `former_ids` aliases and 2 `removals.yml` entries; the dist-diff ORPHAN section is empty in all six kinds (`RELEASE-DIFF-2026.10.1.md`). Cut by the owner-authorised stretch of 2026-10-10 through the CI publish path (run 38024625148; `validate: ALL GATES GREEN`, licence pins 16/16 verified; windows es 2026-06…08, uk 2026-Q2, my 2025-01…2026-08, lu 2026-07…09, fi snapshot 2026-06-30).

| kind | 2026.10.0 | 2026.10.1 | Δ |
|---|---:|---:|---:|
| car | 5,510 | 5,542 | +32 |
| van | 732 | 739 | +7 |
| motorcycle | 6,016 | 6,033 | +17 |
| moped | 1,393 | 1,399 | +6 |
| truck | 940 | 947 | +7 |
| bus | 406 | 409 | +3 |

### Schema (additive; no schema version string changes)
- **`popularity.mass_decile`** (pipeline ruling R3, pipeline#205): a mass-ordered companion to `global_decile`. It is the per-kind rank-decile of a record's registration counts summed across all measured countries (1 = top 10% of the kind's ranked records by mass). Present exactly when `popularity` is. **`global_decile` keeps its meaning** (a presence average of per-country deciles), and SCHEMA.md now says what that costs: on v2026.09.1, car decile 1 = 90 records / 14.0% of catalog mass (17.2% of car mass), against 29.7% (36.6%) for decile 2. The counts stay private and only the decile ships. SCHEMA.md *Popularity* documents both fields and the denominator caveat: stock and flow registers mix, and presence-only registers (`ch`) add 0.
- Flat projections: `dist/vehicles.json` models gain `mass_decile`. `dist/vehicles.csv` and `dist/vehicles.parquet` gain `mass_popularity_decile` as an **appended** last column. `dist/catalog.sqlite` `models` gains `mass_popularity_decile`.
- `catalog/meta/decile-mass.json` gains a sibling `kinds_by_mass_decile`, with the same `{records, mass_share}` bands keyed by `mass_decile`. `kinds` and `schema: "decile-mass/1"` are unchanged.

### Curation
- **Three published trim ids retired onto their nameplates** after the 2026-09 window rolls (data#370, independent Opus I-11 MERGEABLE): `car/acura/integra-type-s` → `car/acura/integra` (its one lu_snca op left with the 2026-06 data month; Acura: Type S is the Integra's top grade), `car/smart/1-brabus` → `car/smart/1` and `car/smart/3-brabus` → `car/smart/3` (ar_dnrpa 2026-09 carries no BRABUS rows; BRABUS is a version per ar.smart.com). Each with an authored `accepted_loss` and a paired `renames.yml` key so the alias source cannot republish. The `truck/mercedes-benz/esprinter` spotcheck pin follows lu out of the window (the fold alias is intact).
- Documentation carried from two closed PRs (data#363): pipeline#186's measured residual on the door-code/litre rescue, and data#337's finding that the detector-coverage premise of PRD-FIVE-NINES §1.3 is false in both parts (DEBT.md "Audit instrument: detector coverage"; QUALITY.md corrected).

### Depth (private layer; counts unchanged in the open data)
- ENR4W 4W enrichment tail, every batch Sonnet-researched and Opus-verified (FINAL APPROVE on each PR): heads-A 10 ids / 303,209 vehicles (pipeline#256), Audi tail 12 ids / 244,542 (#257), Ford tail 9 ids / 129,020 (#259), Mercedes-Benz tail 14 ids / 134,206 (#263), Toyota tail 14 ids / 179,868 (#260). s4w-owned 4W enrichment by registration mass (v2026.09.1 basis): 95.03% → ≈96.4% (each batch states its own measured before→after on its PR).

### Known
- `plus-2026.10.1` was not cut by CI (`PIPELINE_RELEASE_TOKEN` is still unset — owner action); it is hand-cut from a rebuild of the exact release inputs per RELEASE-RUNBOOK §5.5 and its coherence with the public catalog is stated on the plus release.
- A fresh fetch of Traficom's open-data endpoint from a residential client returned the 2026-03-31 extract while CI reads 2026-06-30 (DEBT.md); the release is built from CI's vintage.

## [2026.10.0] - 2026-10-03 — the UK re-file release (and Norway, attach-only)

**14,997 models across 925 makes in 15 countries (14,886 → 14,997, +111).** +218 ids added and −107 retired, **every retirement with a migration path**: 101 `former_ids` aliases and 6 `removals.yml` entries; the dist-diff ORPHAN section is empty in all six kinds (`RELEASE-DIFF-2026.10.0.md`).

| kind | 2026.09.1 | 2026.10.0 | Δ |
|---|---:|---:|---:|
| car | 5,455 | 5,510 | +55 |
| van | 720 | 732 | +12 |
| motorcycle | 6,015 | 6,016 | +1 |
| moped | 1,370 | 1,393 | +23 |
| truck | 923 | 940 | +17 |
| bus | 403 | 406 | +3 |

**Why it took three weeks.** The weekly build was red from 2026-09-21. The es_dgt 3-month window rolled, taking the last Spanish evidence of `motorcycle/motron-motorrad/revolver` and an `es` spotcheck pin on the 1980s Opel Kadett (#340, fixed in #341). Then, on 2026-10-02, the UK DfT republished VEH0120 with **2026 Q2**, and DVLA re-filed and re-spelled GenModels in the same release. That broke three pipeline tests (pipeline#203) and about 69 build gates (pipeline#215 + #341). Behind the gates it also **silently** stripped gb from 365 published ids. Two more passes restored the head (pipeline#220 `GENMODEL_REFILE` + #352; pipeline#225 CFMOTO 700). Every pass had an independent I-11 verifier.

### UK 2026-Q2 re-file — disclosed, because no gate sees it
- **227 published ids lost `gb`** (53,189 gb vehicles in the 2026-Q1 column; full list with decile and mass in `RELEASE-DIFF-2026.10.0.md`). None is decile 1–2 and none has ≥1,000 gb vehicles, **except three range/configuration labels**, which are a routing *improvement*: `motorcycle/bmw/r-series` (6,773; its R nineT / R 12 / R 18 rows now reach the live `r-ninet` 4,811 / `r12` 1,129 / `r18` 960), `truck/daf/ftg` (1,917) and `truck/daf/fad` (1,237) (DAF wheel-configuration prefixes; their rows now reach `daf/xf` 1,060 and `daf/cf` 2,077). Granted as a gate exception by the coordinator.
- Pass 2 restored gb on 72 of the 75 ids in scope (decile 1–2 or ≥1,000 gb): 314,746 gb vehicles, e.g. Suzuki SX4, Ford Mustang Mach-E, BMW R/S/F series, Triumph Street/Speed Triple, KTM Dukes. BYD Seal / Seal U / Seal 6 / Sealion 5 / Sealion 7 now each get their own British rows. Before, 50,601 sat on the bucket id `car/byd/seal-design-ev`, now retired to `car/byd/seal`.
- **Two uk_dft-only ids ship as known-imprecise**, with the fix named (see DEBT): `motorcycle/yamasaki/ty125-4e` (309; DVLA pools TY 125-4E 180 + TY 50 Q-2E 129, two models; needs a G-1 split) and `truck/alexander-dennis/ecollect` (150; the car is the Dennis Eagle eCollect, https://www.dennis-eagle.co.uk/products/ecollect/; `aliases.yml:169` maps make DENNIS → Alexander Dennis).
- **Four kind migrations, not new nameplates:** `ajs/modena-50`, `lexmoto/aspire-50`, `lexmoto/fmr50` and `lexmoto/scout-49` move motorcycle → moped. The re-filed GenModel no longer hides their ≤50 cc. Each old motorcycle id aliases to its moped id. Citations: aspire-50, manufacturer page https://www.lexmoto.com/models/TD50Q-2 ("Aspire 50 E4", same type code, accessed 2026-10-03). The other three rest on register type-code evidence (VEH0120 Model strings "MODENA 50", "FMR 50 WY 50 QT-58", "SCOUT 49"), **registry tier**: the AJS page exists only as an archived capture that could not be read (HTTP 429), and Lexmoto now sells the WY50QT-58 as the "Pulse Lightspeed 2 50".
- Two uk_dft-only new ids carry manufacturer citations: `lexmoto/xdv125` and `lexmoto/ls-z125` (lexmoto.com model pages).

### Norway (pipeline#199 + #338): the 15th country, attach-only
Statens vegvesen periodic-inspection (PKK) data, CC BY 4.0, 2023-01…2025-12. **Attach-only: 0 ids minted.** 2,899 published ids gain `no`. Licence gate 14/14 pins.

### Curation and coverage carried by this release
th_dlt coverage sweeps (#347, #343), ar_dnrpa sweep 2 (#345), auto-union → audi (#344), sub-brands under their own marques per NAMING §8 (#346: Jaecoo, Haval, Omoda …), Omoda 5 / E5 as two nameplates (#351, ruling 5), Vespa co-move 3 (#307), 2W head casing pins (#315), Honda Giorno D-10 (#304), Egypt plates (#348), plus everything merged after 2026.09.1 (#311, #318, #320 …). Pipeline: 30+ enrichment batches (private layer), the hysteresis sidecar (#189), lint_enrich citation counter (#195), coverage tools (#197).

Cut by CI run 37088690540: `validate: ALL GATES GREEN`, `license gate: 14/14 pins verified` (+1 declared absent, asserted not ingested), 7 release assets, archive boundary holds, CDN serving 2026.10.0, HuggingFace mirror ran. Windows: es_dgt 2026-06…08, my_jpj 2025-01…2026-08, uk_dft 2026-Q2, no_svv_pkk 2023-01…2025-12. **`plus-2026.10.0`** is cut by hand per RELEASE-RUNBOOK §5.5, because CI still has no `PIPELINE_RELEASE_TOKEN`. Its status is recorded in the plus release notes.

## [2026.09.1] - 2026-09-12 — the id-contract release

**14,886 models across 918 makes (14,856 → 14,886, +30).** Small by volume and
large by correctness. The 2026-09-07 weekly validate failed on **202** unique
gate failures, almost all of them id-contract LIVENESS: `former_ids` alias
targets that the fresh fetch had brought back to life, and *an alias may never
name a live id*. The fix was structural rather than curatorial — publication
hysteresis now reads each id's entry class from a sidecar the release cannot
destroy, so an edge id's grace no longer depends on a file the build overwrites.
That took the gate set **202 → 0**, and this release is the first build to pass
on that path.

| kind | 2026.09.0 | 2026.09.1 | Δ |
|---|---:|---:|---:|
| car | 5,438 | 5,455 | +17 |
| van | 718 | 720 | +2 |
| motorcycle | 6,011 | 6,015 | +4 |
| moped | 1,365 | 1,370 | +5 |
| truck | 921 | 923 | +2 |
| bus | 403 | 403 | ±0 |

**Nothing was retired.** +30 ids added, **0 removed**, so the dist-diff section
that must always be empty — ids removed with no migration path — is empty for
the trivial reason as well as the gated one. Hysteresis holds 210 edge ids
through upstream count churn (car 71 · motorcycle 76 · bus 17 · truck 17 ·
moped 16 · van 13).

Decile-1 movements, the records consumers actually look at: `car/bmw/5-series`,
`car/hyundai/tucson`, `car/toyota/yaris` and `motorcycle/vespa/sprint-tech-150`
entered decile 1; `motorcycle/aprilia/sm` and `moped/la-souris/trendy-retro`
left it and remain published. One display rename on a surviving id:
`car/changan/e-star` "E Star" → "E-Star".

Cut by CI run 34697443600 — `validate: ALL GATES GREEN`, `license gate: 13/13
pins verified` (+1 declared absent and asserted not ingested), all seven release
assets attached. **`plus-2026.09.1` was not cut:** the `PIPELINE_RELEASE_TOKEN`
secret is absent, so the private layer stays on its previous version until it is
cut by hand (RELEASE-RUNBOOK.md §5.5).

### A lint that was lying, and two PRs that would have shipped a live id

Worth recording because the failure mode generalises. `scripts/lint_curation.rb`
validated rename-block headings against `catalog/*/makes.json` display names.
The pipeline does not key renames that way — it keys them by the **post-alias
display string of the row being classified**, which is a function of the raw
register spelling. Two raw spellings that slugify the same land on one make id
and produce two live headings: raw `AUTO UNION` → `"Auto Union"` (which
`renames.yml` keys) and raw `AUTO-UNION` → `"Auto-Union"` (which the catalog
shows). The lint called the first one inert; it is not.

Both attempted fixes edited the data instead of the lint, and `renames.yml` is a
**build input**: each took the build from 202 gate failures to 203 by stopping a
load-bearing fold and minting `car/auto-union/1000s` live while `former_ids.yml`
still aliased it. The check now ports the pipeline's own reachability predicate,
and the catalog — a build output that lags the override layer — is no longer
treated as the authority on which keys the pipeline accepts.

## [2026.09.0] - 2026-09-05 — the fresh-data release

**14,856 models across 916 makes (13,809 → 14,856, +1,047). The first fresh
upstream data since 2026-08-02**, and the largest single release the catalogue
has had. 2026.08.2 was deliberately frozen — a correctness release that held the
data axis still so the identity axis could be measured — so a month of register
movement lands here all at once: +1,097 ids added, 50 retired, every retirement
carrying a migration path (93 new `former_ids` aliases, 6 removal manifests).

| kind | 2026.08.2 | 2026.09.0 | Δ |
|---|---:|---:|---:|
| car | 4,895 | 5,438 | +543 |
| van | 618 | 718 | +100 |
| motorcycle | 5,744 | 6,011 | +267 |
| moped | 1,306 | 1,365 | +59 |
| truck | 867 | 921 | +54 |
| bus | 379 | 403 | +24 |

Cut by CI run 33996838981 with all eight gates green and all seven release
assets attached.

### The plate corpus lands — 4 jurisdictions to 124

The registration-plate programme moved from a 4-file sketch to **124
jurisdiction files carrying 1,381 plate series**, plus **253 open-tier SVG
assets** with a normative licence ledger. Europe (L1/L2 waves), the United
States state by state, and an Asia/Americas/Oceania/Africa wave: Austria's
closed Anlage 5d district table, Poland's 380-row powiat annex, Germany re-dated
to its BGBl instruments, Spain re-dated to Decreto 2046/1971, Florida re-dated
to the Laws of Florida, South Korea's hangul use-syllable and authority-mark
decode tables. Two spec decisions came out of it: a pattern escape (`\9`, `\L`)
for plates that *print* a 9 or an L, and per-jurisdiction `serial_alphabet`
declared in exact codepoints. Several findings were settled **photographically**
rather than by inference — the Portuguese 2005-window separator is an embossed
square dot, and the 2020 national format genuinely has no separator.

### Dispositions: the id contract held under a month of drift

Every retirement in this release names its evidence. Kawasaki §A folded 41 ids
and *gained* 17 country claims while losing nothing (#297); the Vespa/Piaggio
co-move closed the last two gates holding main red (#305); `lancia/coupe` folded
onto `lancia/beta` as the third adjudicated body-word case; three published cars
whose evidence expired were disposed one fold and two demotions (#312), and the
Mercedes `cabriolet` rescue was **retracted after measurement refuted both
routes** rather than trimmed. Five alias resurrections turned out to share one
mechanism — a separator variant that slugifies to an existing id but is a
different rename key (#310). Seven type approvals expired out of Luxembourg's
rolling three-month window and were signed off with the measurement, not waved
through (#297, #325); those sign-offs are deliberately **not** precedent.

### Powertrains, evidence tiers, and what is deliberately absent

Powertrain coverage ships for all six kinds (car 76.8%, truck 88.8%, van 76.6%,
bus 71.2%, motorcycle 59.5%, moped 51.2%). Unmapped upstream fuel codes are
reported **loudly and left unmapped** rather than guessed — Traficom's
`kayttovoima` 13/38/40/48 (26,589 rows) produce no powertrain entry until the
koodisto is fetched and pinned, and Ukraine's 42,027 "X or electric" rows are
DECLINED by owner ruling rather than minted as a coarse `hybrid` umbrella.
Bentley's enrichment was re-sourced from Wikipedia to primaries (605 → 586
fields) under the evidence-tier rule.

### CI that can report its own failures

Three fixes, each for a silence rather than an error. The DuckDB CLI is pinned
to a release asset with a checksum — the install script 404'd on its own tarball
and **every gate step was skipped for two consecutive weekly runs**, so main's
real state was unknown for two weeks while the failure handler pointed at "the
gate that tripped" (#322). A failing scheduled build now uploads its artifacts:
the upload condition was narrower than its own step name, so the one case where
you most need `build/out` produced nothing. And the build-failure handler could
not file its own issue — three `gh` calls, no `--repo`.

**Known at publication:** the private `plus-2026.09.0` layer was NOT cut. The
release step reported success and produced nothing, because
`PIPELINE_RELEASE_TOKEN` is absent and the step exits 0 with a warning. Paid
consumers stay on `plus-2026.08.1` until it is cut by hand.

## [2026.08.2] - 2026-08-02 — the false-green release

**13,809 models across 859 makes (14,069 → 13,809, −260). The count fell and no
evidence was lost: 384 migration entries carry every retired id forward.** This
release retires nameplates that were never nameplates — horsepower ratings, door
counts, power codes, body words and trim strings that registers had filed as if
they were models. Every retirement is an alias or a removal manifest, so a
consumer resolving an old id still lands on the right record. Registrations are
conserved exactly: the Lancia fold, to take one measured example, moved 79
vehicles between ids with a whole-corpus total of 72,127,507 before and after.

Built on a **frozen source cache**: this is a correctness release, so the data
axis was deliberately held still and the entire diff is attributable to curation
and pipeline fixes rather than upstream drift.

| kind | 2026.08.1 | 2026.08.2 | Δ |
|---|---:|---:|---:|
| car | 4,949 | 4,895 | −54 |
| van | 616 | 618 | +2 |
| motorcycle | 5,901 | 5,744 | −157 |
| moped | 1,299 | 1,306 | +7 |
| truck | 914 | 867 | −47 |
| bus | 390 | 379 | −11 |

### The type-approval crosswalk was losing a quarter of itself, silently

`reconciler.rb` capped each record at 25 EU type approvals. The cap **refused**
rather than evicted, so output was byte-identical build after build and nothing
— no id diff, no count change, no lint — could see it. 185 records sat at
exactly 25 and only **12 actually had 25**; the other **173 were truncated,
losing 5,754 approvals on every build** (`car/volkswagen/golf` kept 25 of 379,
`car/bmw/3-series` 25 of 328). The cap was an arbitrary constant, never
revisited since the initial v2 commit, and PRD-3 §61 argues the opposite: the
TAN⇄id crosswalk is a flagship asset.

Approval entries **16,243 → 21,997 (+35%)**. Nothing replaces the cap, because
truncation cannot be silent if truncation does not happen; two loud things that
never drop a row take its place — a tripwire that fails the build with the data
intact, and a per-build line reporting TAN-join coverage (`pipeline#155`).

It surfaced because a new gate caught the sliver of it that coincided with a
fold: the DAF XF lineage was delisting 19 approvals into a successor already at
the cap (`pipeline#147`). Both are in this release; the gate stays.

### Nameplates that were never nameplates

- **Body words** — 59 ids retired (`hardtop`, `roadster`, `cabriolet` and
  kin), with the 21 real nameplates in the same shape proved untouched (#209)
- **Horsepower ratings** — DAF XF/XG/XD, 19 ids fold onto 3 (#176); the LF and
  CF power suffixes, 26 ids onto 2 (#199)
- **Door counts** — 1,011 rename keys covering 11,169 vehicles, folding onto
  397 already-published records with zero new nameplates (#179)
- **Power codes** — Land Rover, 9 candidate ids onto 2 live records (#193)
- **Type codes** — Suzuki §A, 30 records onto their type-code nameplates (#192)
- **Sub-brand pooling** — Mercedes-AMG's 57,573-vehicle GB residue decomposed
  onto 19 already-live records via a Model-column whitelist, **zero ids minted
  and zero strings unresolvable** (#206); the bus O-number boundary and the
  Marco Polo truncation, 12 ids (#204)
- **Marque waves** — Lexus (#194), MINI (#200), Bentley's GTC ladder (#178),
  VW's New Beetle family folded onto `beetle` rather than minting a
  `new-beetle` (#195), the XJ re-cut (#196), BYD's tail wave (#210)

### Retroactive UK fleet history — a decade, at parse cost

DfT's VEH0120 extract ships **47 quarterly columns and the adapter read one**.
The other 46 (`2025-Q4 … 2014-Q3`) are now filed as 184,092 dated
(record, quarter) observations — same file, same licence, **no additional
fetch, not one extra cache byte**. The public catalog is byte-identical as a
result: identity is still decided by the newest quarter alone and the history
rides as a passenger (`pipeline#148`).

### Powertrains, Phase 1 — private

Propulsion derived from eight registers (ES, LU, DE, FI, MY, UA, US, CA) into a
closed 9-code vocabulary, reaching **8,984 of 13,869 records (64.8%)**. Evidence
unions across sources exactly as `availability` does — never majority-wins — so
a nameplate offered as both BEV and diesel carries both. **Nothing publishes in
this release**; the open field is Phase 3 (`pipeline#153`). The three registers
that cannot answer the question are documented rather than left as a silent gap
(#212).

### Instruments

Several checks that were believed to bind did not, and this release fixes the
checks as well as the data:

- The **licence gate** no longer passes on unverified pins — a frozen cache
  used to make all 14 pinned licence texts look fresh and the gate
  short-circuited having compared nothing (#177)
- The **corpus vintage pin** was gating structural claims that any vintage can
  answer, leaving the Model-column router's mint guard inert on every CI run;
  counts stay pinned and exact, set membership now runs always (`pipeline#152`)
- An **inert-key detector** reports dead override keys — 110 of 7,946 (1.38%),
  ablation-proved in both directions (`pipeline#151`)
- An **alias/name collision detector**, report-only (#201), and 11 class-A
  collisions dispositioned — 2 retired, 9 documented as correct (#202)
- **Rename-value liveness** filed as a silent-failure class: a surviving rename
  whose value names a retired id resurrects it (#197)
- `report:junk_drops` documented blind to rows that die before the rename
  lookup (#189), and the reachability test's two blind spots filed (#180)

### Also

Zenodo DOI rollout with `CITATION.cff` (concept DOI `10.5281/zenodo.21744943`),
the release archive boundary fixed so the internal process layer stops leaking
into Zenodo archives while `data/licenses/` stays for provenance, the release
channel fan-out re-keyed to the release event rather than its creator (#172),
and `OWNERSHIP.yml` regenerated.

## [2026.08.1] - 2026-08-01 — the fold release

**15,626 → 14,069 model ids** (car 6,238→4,949 · truck 1,224→914 · van
742→616 · bus 409→390 · motorcycle 5,767→5,901 · moped 1,246→1,299). The
drop is not data loss: it is trim levels, body styles, axle codes and
misspellings that had been publishing as if they were separate nameplates,
folded onto the nameplate they belong to. **Ids change in this release** —
see *Migration*.

Where the count went **up** (motorcycle, moped), it is registrations that
were being pooled on a stub or deleted outright now reaching a real record.

### ~25 makes de-duplicated

Each wave measured availability per fold and shipped only where **no
(country, source) evidence was lost**:

- Chevrolet 393→219 (#137) · Volvo 428→157 (#135) · Jaguar/Rover/Land Rover
  348→168 (#136) · Scania+DAF 420→313 (#139) · MG+Austin 281→131 (#140) ·
  Italian marques 304→233 (#145) · Iveco+Dodge (#134) · Mitsubishi+Mazda
  211→149 (#143) · Kia+Škoda 151→96 (#148) · Cadillac+Chrysler+Buick 97→45
  (#150) · Vauxhall+Subaru+Jeep 109→41 (#153) · Saab+Porsche+Bentley 210→73
  (#155) · Pontiac+Aston Martin+BYD 183→104 (#157).
- Harley-Davidson designation clusters: FLSTC 13→1 (#144), FLHT/FLHTK 11→2
  (#149), and Harley's own "Softtail" misspelling folded onto "Softail"
  (#142). Honda CB600/CBR900 8→2 (#133).

### Real nameplates that were being deleted, restored

A curation predicate (`junk?`) was discarding rows **before** they could
become records — a defect class invisible from the catalog side, because a
dropped row leaves nothing to inspect.

- **8 nameplates un-deleted, 115,809 vehicles measured** (#141) — Saab 9-3
  and 9-5 alone accounted for 90,597.
- **13 `New <nameplate>` strings** were being read as noise (#151).
- **20,298 Thai BYD vehicles** rescued from a pooled GenModel (#157).
- Kia+Škoda gained **29,565 GB vehicles** (#148); `truck/daf/lf` **+12,495
  gb** (#139).

### UK two-wheeler designations un-pooled

DfT publishes a family GenModel ("YAMAHA MT") where a nameplate belongs. The
parser read `MT-07` as family `MT-` + capacity 7, failed the capacity range
and dropped every row onto a bare gb-only stub. Both halves are fixed
(#129, #165): the rows now land on `mt-09` (11,474 gb), `mt-07` (9,194),
`mt-10` (5,038), `mt-03` (1,775) and `mt-01` (490), and the same shape is
retired for the XP and XSR families.

### BMW M

`M3`/`M5` and the rest are nameplates, not trims of the N-Series — they no
longer fold into `3`/`5` (#163).

### Migration

- **1,989 new aliases** in `overrides/models/former_ids.yml` (5,782 total,
  covering 2,806 live records). Every retired id resolves to its successor.
- **121 ids manifested** in `overrides/models/removals.yml`, each with a
  reason and a measurement — used where no single alias target exists (a
  pooled stub whose rows split across several real nameplates).
- Nothing disappears silently: the id-contract gate fails the build on any
  retired id that is neither aliased nor manifested.

### Also

- Zenodo metadata + `CITATION.cff`, so releases archive with a DOI.
- 2,112 new curation keys in `overrides/models/renames.yml`, each carrying a
  `#` comment with its source.

## [2026.08.0] - 2026-08-01 — the correction release

All 14 sources refreshed to their mid-2026 snapshots. This release also
completes the **second demotion wave** the hysteresis design defers by one
release (94 ids across kinds: 4 car, 50 motorcycle, 6 moped, 28 truck, 6 bus —
ids that had been surviving on multi-source grace fell below the single-source
threshold after the Irish rank correction and related fixes).

This release corrects identity errors rather than adding data. Two parser bugs
had been fabricating model names, and a curation pass had begun deleting the
real records those bugs produced. **Ids change in this release** — see
*Migration* below.

### Germany: 148 records were shared-string indices, not model names

`XlsxLite`'s cell regex let an empty XLSX cell swallow the next cell's `<v>`, so
KBA FZ 10 published shared-string **indices** where model names belong, across
29 makes. `volkswagen/552` **was the Golf** — Germany's best-selling car — while
`volkswagen/golf` carried twelve countries and no `de`. Every German popularity
figure for the country's best sellers sat on a garbage id, and the real
nameplates were ranked as if Germany did not exist.

The integers looked exactly like registry type-codes, and the previous release
had already deleted SEAT's entire current German lineup on that reading:
`seat/468`–`474` were ATECA, BORN, FORMENTOR, IBIZA, LEON, TAVASCAN, TERRAMAR.
Those drops are retired here. The rule that came out of it is in
[NAMING.md](NAMING.md) §2.1: *a bare integer, single-source, is a parser suspect
before it is a data suspect*.

### Also corrected

- **Cross-make moves** (`overrides/models/moves.yml`, new): registers file
  sub-brands under the type-approval holder, so every Cupra arrives as a SEAT
  and every Genesis as a Hyundai. ~26,500 German registrations now reach the
  right marque instead of being dropped.
- **KBA temporal merges**: `"GLK, GLC"` and friends splice a nameplate to its
  renamed successor in one cell; 22k registrations were landing on nameplates
  dead since 2015.
- **390 duplicate spellings merged**: `280 Se` and `280SE` were separate ids for
  the same W108, each with four sources.
- **161 non-vehicles removed** from the car kind: 14 motorhome builders (measured
  against RDW's CC0 register), 49 rows where a register wrote the make into the
  model column, and assorted junk strings.

### Migration

Ids that changed carry `former_ids` (a new optional field — additive, so not a
breaking change under [SCHEMA.md](SCHEMA.md)). Look a missing id up there before
assuming a model was removed.

**97 ids were removed with no successor.** They are motorhome floorplan codes
(Bürstner, Pössl, Niesmann+Bischoff) that were never cars; they have no alias
because there is nothing to alias them to.

## [2026.07.0] - 2026-07-05

The multi-source, multi-kind, multi-continent release: **456 → 18,556 models**.

- **14 official sources, 14 countries, 4 continents**: NL RDW · UK DfT
  VEH0120 · ES DGT microdata · FI Traficom · LU SNCA · IE CSO · DE KBA FZ 10 ·
  US fueleconomy.gov · CA NRCan · NZ Waka Kotahi MVR · MY JPJ · TH DLT ·
  UA MVS/HSC · AR DNRPA. Every license pinned by SHA-256 (`data/licenses/`);
  per-source notes and measured gotchas in the new [SOURCES.md](SOURCES.md).
- **Six kinds shipped**: car 8,785 · motorcycle 5,916 · van 1,119 · moped
  1,304 · truck 1,043 · bus 389 (mopeds first-class, separate from
  motorcycles; trikes fold into motorcycles as `body_types: ["trike"]`).
- **Reconciliation, not aggregation**: a model publishes when ≥2 independent
  sources corroborate it or one source shows a fleet count no typo could
  produce. ~76,000 raw car name-variants reconciled; the long tail waits in
  a private candidate queue instead of polluting the dataset.
- **Cross-kind dominance prune**: registries miscategorize (tax-scheme "grey
  license plate" registrations put passenger cars in the van class; data-entry
  slips put an Audi A3 in two countries' motorcycle tables) — when ≥97% of a
  model's observed count sits in one kind, minority-kind echoes are dropped
  (662 removed this release, incl. every tax-scheme Audi 'van'). Legit multi-kind nameplates (Toyota Hilux,
  Aixam's microcars) survive on real shares.
- **New open fields** (catalog `schema_version` 2 → 3, additive):
  `availability` (per-country evidence: registration/approval/sales + source
  id), `popularity` (per-country rank + decile from real counts, plus
  `global_decile`), `sources`, `xrefs.tan` (EU type-approval numbers where
  measured).
- **New dist formats**: `vehicles.min.json` (array-packed picker feed),
  `catalog.sqlite` (the full catalog as one SQL file). `dist/vehicles.json`
  gains optional `global_decile` + `availability` per model (schema v2,
  additive — existing consumers unaffected), `region` is now `"global"`.
- **Governance, OpenASN-grade**: generated `ATTRIBUTION.md`, license-drift
  gate, GDPR ingest lint, ±20% delta tripwires, `spotchecks.yml` assertion
  panel, curated `overrides/` with per-line provenance comments + CI lint,
  weekly validate-only + monthly publish workflows, AGENTS.md / DECISIONS.md.
- **Removed**: the two `generations`/`variants` demo records (Suzuki Jimny
  JB74/JB43, BMW M2) — the layers stay reserved in SCHEMA.md and return with
  the depth work; demo data doesn't belong in a corroborated dataset.
- Body types are now kind-aware: cars carry the familiar vocabulary;
  non-car kinds ship none until an honest vocabulary exists for them
  (absent = not catalogued, per the SCHEMA.md absence rule).

## [2026.06.0] - 2026-06-23

Initial public dataset, in the growth architecture.

- **Catalogue** (`catalog/car/`): normalized taxonomy — `makes.json` (47) +
  `models.json` (456), with stable hierarchical ids (`bmw/2-series`).
- **Generations + variants** layers live in the schema and demonstrated on real
  records: Suzuki Jimny `JB74`/`JB43` (generations), BMW `M2` (variant).
- **`dist/vehicles.json`**: flat make→model projection (schema v2) — the stable
  contract the `vehicles` gem consumes. Also published as **`dist/vehicles.csv`**.
- **`manifest.json`**: machine-readable index of kinds, regions, files, counts.
- EU cars derived from RDW Open Data (CC0). Data CC-BY 4.0.

See [SCHEMA.md](SCHEMA.md) for the full shape and the open-vs-API boundary.
