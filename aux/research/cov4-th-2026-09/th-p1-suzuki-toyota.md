# COV4 dossier — `th_dlt` packet P1: Suzuki + Toyota (kind: car)

**Register:** `th_dlt` — Thailand, Department of Land Transport vehicle register.
**Packet:** 111 probed strings, 6,935 vehicles.
**Access date for every URL in this dossier: 2026-09-12.**
**Researcher:** COV4 lane. I research and report; I do not edit the repo, run builds or open PRs. Every verdict here is re-derived by the manager before anything ships.

## Summary

| verdict | rows | vehicles |
|---|---:|---:|
| FOLD | 95 | 6,734 |
| REFUSE | 14 | 198 |
| UNRESOLVED | 2 | 3 |

Two results are worth more than the coverage number:

1. **`Hilux Travo` is not a typo for `Hilux Revo`.** It is a current, official Toyota Motor Thailand badge that is sold *alongside* Revo. The frequency evidence (732 vs 24,761 in the same file) looked exactly like a keying-error rate and was not.
2. **`Hilux Champ` must not be folded**, and getting it wrong would have destroyed a live id carrying 8,155 vehicles rather than the 94 the row appears to be worth.

### What kind of string each tail turned out to be

Per the lane rule that a licence class, body code, engine designation or model-year code is not a nameplate, here is the classification of every tail token in this packet:

- **Grade names** (sourced on maker pages): `GL`, `GL NEXT`, `GLX`, `GL PLUS`, `GLX Navi`, `GA`, `GX`, `GL UP`, `RS` (Suzuki Thailand); `JC`, `JL` (Jimny Sierra); `XG`, `XL`, `XC` (Jimny); `Alpha`, `Zeta` (Maruti Jimny); `FC` (Jimny Nomade); `Z`, `G`, `X`, `Executive Lounge` (Alphard); `Z Premier` (Vellfire); `RZ`, `SZ`, `RC` (GR86); `RZ`, `RZ High performance`, `RC`, `RS` (GR Yaris); `S-Z`, `S-G`, `S-X` (Voxy/Noah); `Custom G-T` (Roomy); `CROSSOVER RS/Z/G`, `SPORT RS/Z/G` (Crown); `AX` (Land Cruiser 70); `VX` (Land Cruiser 250).
- **Engine displacement designations, not nameplates:** `1.2L`, `1.0L`, `1.25L`, `1.5L`, `2.5`, `2.5L`, `2.4L`, `2.8L`, `3.3L`, `3.5L`, `5.0L`, `250` (Vellfire), `2.8D`, `3.0`.
- **Transmission designations, not nameplates:** `CVT`, `MT`, `AT`, `4AT`, `6MT`, `M/T`.
- **Drivetrain designations, not nameplates:** `2WD`, `4WD`, `E-Four` (Toyota's electric rear-axle AWD system).
- **Colour / limited-edition tags, not nameplates:** `Ridge Green Limited`, `Plasma Orange 100`, `Matte White Edit`, `10th Anniversary`, `Greddy`, `First` (Land Cruiser 250 "First Edition").
- **Body-style qualifiers that ARE part of a distinct nameplate:** `Nomade`, `Gear`, `Smile`, `Champ`, `70`, `71`, `250` (Land Cruiser). These drive the refusals.

### A note on how I tiered the evidence

Every FOLD below is marked **A** or **B**:

- **Tier A** — both the nameplate *and* the specific grade/tail string are sourced on a page I opened.
- **Tier B** — the nameplate token is sourced and no published record contradicts the fold, but the specific grade string belongs to a generation whose maker page is no longer online (30-series Alphard/Vellfire, GR Supra, 150-series Prado, Land Cruiser 300 grade table). The fold does not depend on decoding that grade — the string leads with the published nameplate and there is no Toyota model called e.g. "Alphard SC Package" — but the grade itself is listed in UNRESOLVED-detail at the end so the manager can see exactly what is and is not sourced.

No FOLD in this packet is a rename to null, and no cross-make move is proposed.

---

## Verdict table

`target published name` is copied byte-for-byte from the published record (verified against `dist/catalog.sqlite`, `models` table, read-only).

| # | probed_key | veh | verdict | target published name | source URL | tier | how verified |
|---|---|---:|---|---|---|---|---|
| 1 | `Swift Glx 1.2L Cvt` | 893 | FOLD | Swift | https://www.suzuki.co.th/en/model/swift/specification | A | opened directly |
| 2 | `Swift GL Next 1.2L Cvt` | 785 | FOLD | Swift | https://www.suzuki.co.th/en/model/swift/specification | A | opened directly |
| 3 | `Celerio Gx 1.0L Cvt` | 775 | FOLD | Celerio | https://www.suzuki.co.th/en/model/CELERIO/specification | A | opened directly |
| 4 | `Hilux Travo` | 732 | FOLD | Hilux | https://www.toyota.co.th/model/alphard | A | opened directly |
| 5 | `Alphard Z 2WD` | 728 | FOLD | Alphard | https://toyota.jp/pages/contents/alphard/004_p_001/pdf/alphard_spec_202606.pdf | A | opened directly |
| 6 | `Swift GL 1.2L Cvt` | 538 | FOLD | Swift | https://www.suzuki.co.th/en/model/swift/specification | A | opened directly |
| 7 | `Celerio GL 1.0L Cvt` | 296 | FOLD | Celerio | https://www.suzuki.co.th/en/model/CELERIO/specification | A | opened directly |
| 8 | `XL7 1.5L` | 271 | FOLD | XL7 | https://www.suzuki.co.th/en/model/xl7/specification | A | opened directly |
| 9 | `Celerio Ga 1.0L MT` | 158 | FOLD | Celerio | https://www.suzuki.co.th/en/model/CELERIO/specification | A | opened directly |
| 10 | `Alphard Z 2.5L` | 147 | FOLD | Alphard | https://toyota.jp/pages/contents/alphard/004_p_001/pdf/alphard_spec_202606.pdf | A | opened directly |
| 11 | `Vellfire Z Premier` | 116 | FOLD | Vellfire | https://toyota.jp/pages/contents/vellfire/003_p_001/pdf/vellfire_spec_202606.pdf | A | opened directly |
| 12 | `Fronx 1.5L` | 98 | FOLD | Fronx | https://www.suzuki.co.th/model/fronx/ | A | opened directly |
| 13 | `Hilux Champ` | 94 | **REFUSE** | — | https://www.toyota.co.th/model/alphard | A | opened directly |
| 14 | `Alphard 2.5` | 94 | FOLD | Alphard | https://toyota.jp/pages/contents/alphard/004_p_001/pdf/alphard_spec_202606.pdf | B | opened directly |
| 15 | `Alphard 2.5 Sc Package` | 91 | FOLD | Alphard | https://toyota.jp/pages/contents/alphard/004_p_001/pdf/alphard_spec_202606.pdf | B | opened directly |
| 16 | `Alphard Z 2WD 2.5L` | 88 | FOLD | Alphard | https://toyota.jp/pages/contents/alphard/004_p_001/pdf/alphard_spec_202606.pdf | A | opened directly |
| 17 | `Alphard 2.5 Z` | 87 | FOLD | Alphard | https://toyota.jp/pages/contents/alphard/004_p_001/pdf/alphard_spec_202606.pdf | A | opened directly |
| 18 | `Alphard Z` | 86 | FOLD | Alphard | https://toyota.jp/pages/contents/alphard/004_p_001/pdf/alphard_spec_202606.pdf | A | opened directly |
| 19 | `Jimny Sierra Jc` | 73 | FOLD | Jimny Sierra | https://www.suzuki.co.jp/car/jimny_sierra/ | A | opened directly |
| 20 | `Alphard Sc Package 2.5L` | 70 | FOLD | Alphard | https://toyota.jp/pages/contents/alphard/004_p_001/pdf/alphard_spec_202606.pdf | B | opened directly |
| 21 | `Celerio GL Up 1.0L Cvt` | 60 | FOLD | Celerio | https://www.suzuki.co.th/en/model/CELERIO/specification | A | opened directly |
| 22 | `Alphard Sc Package` | 53 | FOLD | Alphard | https://toyota.jp/pages/contents/alphard/004_p_001/pdf/alphard_spec_202606.pdf | B | opened directly |
| 23 | `Jimny 1.5L 4AT` | 48 | FOLD | Jimny | https://www.suzuki.co.th/model/jimny/ | A | opened directly |
| 24 | `GR86 Rc` | 44 | FOLD | GR86 | https://toyota.jp/pages/contents/gr86/001_p_001/pdf/gr86_spec_202608.pdf | A | opened directly |
| 25 | `Vellfire 2.5` | 40 | FOLD | Vellfire | https://toyota.jp/pages/contents/vellfire/003_p_001/pdf/vellfire_spec_202606.pdf | A | opened directly |
| 26 | `Land Cruiser 70 Ax` | 35 | **REFUSE** | — | https://toyota.jp/landcruiser70/ | A | opened directly |
| 27 | `Gr Yaris RZ High Performance` | 28 | FOLD | Gr Yaris | https://toyota.jp/pages/contents/gryaris/001_p_002/pdf/gryaris_spec_202603.pdf | A | opened directly |
| 28 | `Land Cruiser 250 ZX First` | 25 | **REFUSE** | — | https://toyota.jp/landcruiser250/ | A | opened directly |
| 29 | `Crown Crossover` | 25 | FOLD | Crown | https://toyota.jp/pages/contents/crowncrossover/001_p_001/pdf/crowncrossover_spec_202609.pdf | A | opened directly |
| 30 | `Land Cruiser 250 ZX` | 21 | **REFUSE** | — | https://toyota.jp/landcruiser250/ | A | opened directly |
| 31 | `Gr Yaris Rc` | 18 | FOLD | Gr Yaris | https://toyota.jp/pages/contents/gryaris/001_p_002/pdf/gryaris_spec_202603.pdf | A | opened directly |
| 32 | `Alphard 2.5L Sc Package` | 15 | FOLD | Alphard | https://toyota.jp/pages/contents/alphard/004_p_001/pdf/alphard_spec_202606.pdf | B | opened directly |
| 33 | `Land Cruiser ZX` | 15 | FOLD | Land Cruiser | https://toyota.jp/landcruiser300/ | B | opened directly |
| 34 | `Jimny Sierra Jc 1.5L` | 13 | FOLD | Jimny Sierra | https://www.suzuki.co.jp/car/jimny_sierra/ | A | opened directly |
| 35 | `Vellfire Z Premier 2.4L` | 13 | FOLD | Vellfire | https://toyota.jp/pages/contents/vellfire/003_p_001/pdf/vellfire_spec_202606.pdf | A | opened directly |
| 36 | `Land Cruiser 300 ZX` | 13 | FOLD | Land Cruiser | https://toyota.jp/landcruiser300/ | B | opened directly |
| 37 | `Ciaz GL Cvt` | 13 | FOLD | Ciaz | https://www.suzuki.co.th/en/model/CIAZ/specification | A | opened directly |
| 38 | `Land Cruiser 300 ZX 3.3L` | 12 | FOLD | Land Cruiser | https://toyota.jp/landcruiser300/ | B | opened directly |
| 39 | `Celerio GL 1.0L` | 11 | FOLD | Celerio | https://www.suzuki.co.th/en/model/CELERIO/specification | A | opened directly |
| 40 | `Swift GL Plus 1.2L Cvt` | 11 | FOLD | Swift | https://www.suzuki.co.th/en/model/swift/specification | B | opened directly |
| 41 | `GR86 Cup Car Basic` | 11 | FOLD | GR86 | https://toyota.jp/pages/contents/gr86/001_p_001/pdf/gr86_spec_202608.pdf | B | opened directly |
| 42 | `Crown Sport Z` | 10 | FOLD | Crown | https://toyota.jp/pages/contents/crownsport/001_p_001/pdf/crownsport_spec_202609.pdf | A | opened directly |
| 43 | `Gr Supra RZ` | 9 | FOLD | Gr Supra | (no live maker page — see UNRESOLVED-detail) | B | not opened |
| 44 | `Vellfire Z Premier E-Four` | 9 | FOLD | Vellfire | https://toyota.jp/pages/contents/vellfire/003_p_001/pdf/vellfire_spec_202606.pdf | A | opened directly |
| 45 | `GR86 RZ 2WD` | 8 | FOLD | GR86 | https://toyota.jp/pages/contents/gr86/001_p_001/pdf/gr86_spec_202608.pdf | A | opened directly |
| 46 | `Jimny Alpha 5` | 8 | FOLD | Jimny | https://www.nexaexperience.com/jimny/ | A | opened directly |
| 47 | `GR86 RZ Ridge Green Limited` | 7 | FOLD | GR86 | https://toyota.jp/pages/contents/gr86/001_p_001/pdf/gr86_spec_202608.pdf | B | opened directly |
| 48 | `Alphard Executive Lounge` | 7 | FOLD | Alphard | https://toyota.jp/pages/contents/alphard/004_p_001/pdf/alphard_spec_202606.pdf | A | opened directly |
| 49 | `GR86 RZ` | 6 | FOLD | GR86 | https://toyota.jp/pages/contents/gr86/001_p_001/pdf/gr86_spec_202608.pdf | A | opened directly |
| 50 | `Voxy Sz` | 6 | FOLD | Voxy | https://toyota.jp/pages/contents/voxy/004_p_001/pdf/voxy_spec_202609.pdf | A | opened directly |
| 51 | `Land Cruiser Gr Sport` | 6 | FOLD | Land Cruiser | https://toyota.jp/landcruiser300/ | B | opened directly |
| 52 | `Land Cruiser 250 ZX 2.8L` | 5 | **REFUSE** | — | https://toyota.jp/landcruiser250/ | A | opened directly |
| 53 | `Land Cruiser Ax` | 5 | FOLD | Land Cruiser | https://toyota.jp/landcruiser300/ | B | opened directly |
| 54 | `Alphard X` | 5 | FOLD | Alphard | https://toyota.jp/pages/contents/alphard/004_p_001/pdf/alphard_spec_202606.pdf | B | opened directly |
| 55 | `Crown Crossover G Advanced` | 4 | FOLD | Crown | https://toyota.jp/pages/contents/crowncrossover/001_p_001/pdf/crowncrossover_spec_202609.pdf | A | opened directly |
| 56 | `Spacia Gear` | 4 | **REFUSE** | — | https://www.suzuki.co.jp/car/spacia_gear/ | A | opened directly |
| 57 | `Land Cruiser 250 Vx` | 4 | **REFUSE** | — | https://toyota.jp/pages/contents/landcruiser250/001_p_001/pdf/landcruiser250_spec_202604.pdf | A | opened directly |
| 58 | `Celerio Gx 1.0L` | 3 | FOLD | Celerio | https://www.suzuki.co.th/en/model/CELERIO/specification | A | opened directly |
| 59 | `Swift Glx-Navi 1.2L Cvt` | 3 | FOLD | Swift | https://www.suzuki.co.th/en/model/swift/specification | B | opened directly |
| 60 | `Voxy S-Z 2WD` | 3 | FOLD | Voxy | https://toyota.jp/pages/contents/voxy/004_p_001/pdf/voxy_spec_202609.pdf | A | opened directly |
| 61 | `Spacia Custom` | 3 | FOLD | Spacia | https://www.suzuki.co.jp/car/spacia_custom/ | A | opened directly |
| 62 | `Gr Yaris Rc At` | 3 | FOLD | Gr Yaris | https://toyota.jp/pages/contents/gryaris/001_p_002/pdf/gryaris_spec_202603.pdf | A | opened directly |
| 63 | `Gr Corolla RZ` | 3 | FOLD | Gr Corolla | https://toyota.jp/pages/contents/grcorolla/001_p_004/pdf/grcorolla_spec_202509.pdf | A | opened directly |
| 64 | `Crown Z` | 3 | FOLD | Crown | https://toyota.jp/pages/contents/crown/013_p_001/pdf/crown_spec_202609.pdf | A | opened directly |
| 65 | `Celerio Ga 1.0L` | 3 | FOLD | Celerio | https://www.suzuki.co.th/en/model/CELERIO/specification | A | opened directly |
| 66 | `Land Cruiser 71 Hardtop 4.0L` | 3 | **REFUSE** | — | https://toyota.jp/landcruiser70/ | A | opened directly |
| 67 | `Crown 2.5L Sport Z` | 3 | FOLD | Crown | https://toyota.jp/pages/contents/crownsport/001_p_001/pdf/crownsport_spec_202609.pdf | A | opened directly |
| 68 | `Jimny XG MT` | 2 | FOLD | Jimny | https://www.suzuki.co.jp/car/jimny/ | A | opened directly |
| 69 | `Jimny XC` | 2 | FOLD | Jimny | https://www.suzuki.co.jp/car/jimny/ | A | opened directly |
| 70 | `Gr Supra Sz-R` | 2 | FOLD | Gr Supra | (no live maker page — see UNRESOLVED-detail) | B | not opened |
| 71 | `GR86 RZ 10TH Anniversary` | 2 | FOLD | GR86 | https://toyota.jp/pages/contents/gr86/001_p_001/pdf/gr86_spec_202608.pdf | B | opened directly |
| 72 | `Gr Supra RZ Plasma Orange 100` | 2 | FOLD | Gr Supra | (no live maker page — see UNRESOLVED-detail) | B | not opened |
| 73 | `Gr Supra RZ 3.0` | 2 | FOLD | Gr Supra | (no live maker page — see UNRESOLVED-detail) | B | not opened |
| 74 | `Spacia Gear My Style` | 2 | **REFUSE** | — | https://www.suzuki.co.jp/car/spacia_gear/ | A | opened directly |
| 75 | `Yaris Grmn Circuit Package` | 2 | **UNRESOLVED** | — | — | — | — |
| 76 | `Ciaz Glx Cvt` | 2 | FOLD | Ciaz | https://www.suzuki.co.th/en/model/CIAZ/specification | A | opened directly |
| 77 | `Jimny Alpha` | 2 | FOLD | Jimny | https://www.nexaexperience.com/jimny/ | A | opened directly |
| 78 | `Crown Sport Z 2.5L` | 2 | FOLD | Crown | https://toyota.jp/pages/contents/crownsport/001_p_001/pdf/crownsport_spec_202609.pdf | A | opened directly |
| 79 | `Land Cruiser Prado Tx L` | 2 | FOLD | Land Cruiser Prado | (150-series page retired — see UNRESOLVED-detail) | B | not opened |
| 80 | `Noah X 2WD` | 2 | FOLD | Noah | https://toyota.jp/pages/contents/noah/004_p_001/pdf/noah_spec_202609.pdf | B | opened directly |
| 81 | `Land Cruiser Prado 2.7 Tx-L` | 2 | FOLD | Land Cruiser Prado | (150-series page retired — see UNRESOLVED-detail) | B | not opened |
| 82 | `Roomy Custom GT` | 1 | FOLD | Roomy | https://toyota.jp/pages/contents/roomy/001_p_006/pdf/roomy_spec_202608.pdf | A | opened directly |
| 83 | `Vellfire Z G Edition` | 1 | FOLD | Vellfire | https://toyota.jp/pages/contents/vellfire/003_p_001/pdf/vellfire_spec_202606.pdf | B | opened directly |
| 84 | `Vellfire 250` | 1 | FOLD | Vellfire | https://toyota.jp/pages/contents/vellfire/003_p_001/pdf/vellfire_spec_202606.pdf | B | opened directly |
| 85 | `Vellfire 2.5ZG Edition` | 1 | FOLD | Vellfire | https://toyota.jp/pages/contents/vellfire/003_p_001/pdf/vellfire_spec_202606.pdf | B | opened directly |
| 86 | `Land Cruiser 250 Gx` | 1 | **REFUSE** | — | https://toyota.jp/landcruiser250/ | A | opened directly |
| 87 | `Land Cruiser 250 Vx 2.8L` | 1 | **REFUSE** | — | https://toyota.jp/landcruiser250/ | A | opened directly |
| 88 | `Land Cruiser 300 Sahara 3.3L` | 1 | FOLD | Land Cruiser | https://toyota.jp/landcruiser300/ | B | opened directly |
| 89 | `Land Cruiser 300 Sahara ZX` | 1 | FOLD | Land Cruiser | https://toyota.jp/landcruiser300/ | B | opened directly |
| 90 | `Land Cruiser 300 ZX Diesel` | 1 | FOLD | Land Cruiser | https://toyota.jp/landcruiser300/ | B | opened directly |
| 91 | `Land Cruiser 70 Ax 2.8L` | 1 | **REFUSE** | — | https://toyota.jp/pages/contents/landcruiser70/003_p_001/pdf/landcruiser70_spec_202311.pdf | A | opened directly |
| 92 | `Land Cruiser Active 2.8D` | 1 | **UNRESOLVED** | — | — | — | — |
| 93 | `Land Cruiser Gr` | 1 | FOLD | Land Cruiser | https://toyota.jp/landcruiser300/ | B | opened directly |
| 94 | `Land Cruiser Gx 3.5L` | 1 | FOLD | Land Cruiser | https://toyota.jp/landcruiser300/ | B | opened directly |
| 95 | `Land Cruiser Prado Tx` | 1 | FOLD | Land Cruiser Prado | (150-series page retired — see UNRESOLVED-detail) | B | not opened |
| 96 | `Land Cruiser Prado Tz` | 1 | FOLD | Land Cruiser Prado | (150-series page retired — see UNRESOLVED-detail) | B | not opened |
| 97 | `Ciaz GL MT` | 1 | FOLD | Ciaz | https://www.suzuki.co.th/en/model/CIAZ/specification | A | opened directly |
| 98 | `Ciaz Glx 1.25L Cvt` | 1 | FOLD | Ciaz | https://www.suzuki.co.th/en/model/CIAZ/specification | A | opened directly |
| 99 | `Jimny Nomade Fc 5` | 1 | **REFUSE** | — | https://www.suzuki.co.jp/car/jimny_nomade/ | A | opened directly |
| 100 | `Jimny Sierra Jl` | 1 | FOLD | Jimny Sierra | https://www.suzuki.co.jp/car/jimny_sierra/ | A | opened directly |
| 101 | `Jimny XC MT` | 1 | FOLD | Jimny | https://www.suzuki.co.jp/car/jimny/ | A | opened directly |
| 102 | `Crown Sport` | 1 | FOLD | Crown | https://toyota.jp/pages/contents/crownsport/001_p_001/pdf/crownsport_spec_202609.pdf | A | opened directly |
| 103 | `Crown Z 2.5L` | 1 | FOLD | Crown | https://toyota.jp/pages/contents/crown/013_p_001/pdf/crown_spec_202609.pdf | A | opened directly |
| 104 | `Gr Supra RZ 6MT` | 1 | FOLD | Gr Supra | (no live maker page — see UNRESOLVED-detail) | B | not opened |
| 105 | `Gr Supra RZ Matte White Edit` | 1 | FOLD | Gr Supra | (no live maker page — see UNRESOLVED-detail) | B | not opened |
| 106 | `Gr Yaris Rc M/T` | 1 | FOLD | Gr Yaris | https://toyota.jp/pages/contents/gryaris/001_p_002/pdf/gryaris_spec_202603.pdf | A | opened directly |
| 107 | `GR86 RZ Greddy` | 1 | FOLD | GR86 | https://toyota.jp/pages/contents/gr86/001_p_001/pdf/gr86_spec_202608.pdf | B | opened directly |
| 108 | `GR86 Sz` | 1 | FOLD | GR86 | https://toyota.jp/pages/contents/gr86/001_p_001/pdf/gr86_spec_202608.pdf | A | opened directly |
| 109 | `Harrier 2.5` | 1 | FOLD | Harrier | https://toyota.jp/pages/contents/harrier/004_p_001/pdf/harrier_spec_202608.pdf | A | opened directly |
| 110 | `Wagon R Smile` | 1 | **REFUSE** | — | https://www.suzuki.co.jp/car/wagonr_smile/ | A | opened directly |
| 111 | `Century 5.0L` | 1 | FOLD | Century | https://toyota.jp/pages/contents/century/003_p_001/pdf/century_spec_202512.pdf | A | opened directly |

---

## Evidence blocks

### Toyota Hilux — and why `Travo` is real

**URL:** https://www.toyota.co.th/model/alphard — accessed 2026-09-12, **opened directly**.

A note on method, because the URL looks odd for a Hilux claim: toyota.co.th is a Nuxt server-side-rendered site, and *every* model page embeds the complete site-wide `window.__NUXT__` model catalogue, including the full commercial-vehicle series list with prices and Toyota model codes. The Alphard page is simply the one that rendered completely. The Hilux data below is Toyota Motor Thailand's own product data, served from toyota.co.th.

Toyota Thailand's product hierarchy is **car_type → series → grade**. There is no model level. The car types are `personal_car` ("Personal Cars" / รถเก๋ง), `commercial_car` ("Commercial Cars" / รถเพื่อการพาณิชย์) and `multifunction_car` ("MPV"). Under `commercial_car`, the Hilux series are, verbatim from Toyota's data:

| series slug | model_code | title_en | price band (THB) |
|---|---|---|---|
| `hilux_champ` | `IMV0` | Hilux Champ | 519,000 – 615,000 |
| `hilux_revo_standard` | `HRBCB` | Hilux Revo Standard Cab | — |
| `hilux_revo_zedition` | `HR4D` | Hilux Revo Z Edition | — |
| `hilux_travo_standard_4trex` | `HTBC` | Hilux Travo Standard Cab 4TREX | 767,000 – 819,000 |
| `hilux_travo_prerunner_4trex` | `HT4D` | Hilux Travo Prerunner & 4TREX | 789,000 – 1,090,000 |
| `hilux_travo_overland` | — | Hilux Travo Overland | — |
| `hilux_travo_e` | `HTBE` | Hilux Travo-e | — |

**Hilux Travo is therefore a current Toyota Thailand badge sold alongside Hilux Revo, not a mis-transcription of it.** Four independent signals rule out a keying error:

1. Revo and Travo series **coexist** in the same live product list.
2. The Thai text is **ไฮลักซ์ ทราโว่** (*tra-wo*), a different transliteration from **รีโว่** (*re-wo*) — not a one-character slip in either script.
3. There is a live promotion with its own slug, `promotion/hiluxtravo_4trex`, and a banner reading "HILUX TRAVO สถานการณ์ไหนก็… เอาอยู่", dated 1 กันยายน 2569 – 31 ตุลาคม 2569 (1 Sep – 31 Oct 2026).
4. Each Travo grade carries a distinct Toyota model code and its own price.

The register frequency (`HILUX REVO` 24,761 vs `HILUX TRAVO` 732 in the same file) is explained without a typo: Travo is the newer badge, measured against a decade of Revo installed base. Frequency alone cannot distinguish a new badge from a keying error.

Full Travo grade list harvested (all 2.8 L turbodiesel, model codes are Toyota's own):

| grade | model code | transmission | price (THB) |
|---|---|---|---|
| Hilux Travo Standard Cab 4TREX 2.8 AT | GUN226R-BTTLXT/A1 | 6-speed automatic with Sequential Shift | — |
| Hilux Travo Standard Cab 4TREX 2.8 MT | GUN226R-BTFXXT/A1 | 6-speed manual | — |
| Hilux Travo Double Cab Prerunner 2.8 Premium AT | GUN236R-DTTMXT/A1 | 6AT | 999,000 |
| Hilux Travo Double Cab Prerunner 2.8 Premium MT | GUN236R-DTFMXT/A1 | 6MT | — |
| Hilux Travo Double Cab Prerunner 2.8 Smart AT | GUN236R-DTTLXT/A1 | 6AT | 945,000 |
| Hilux Travo Double Cab Prerunner 2.8 Smart MT | GUN236R-DTFLXT/A1 | 6MT | 895,000 |
| Hilux Travo Double Cab 4TREX 2.8 Premium MT | GUN226R-DTFMXT/A1 | 6MT | — |
| Hilux Travo Double Cab 4TREX 2.8 Overland AT | — | 6AT | — |
| Hilux Travo Double Cab 4TREX 2.8 Overland Plus AT | — | 6AT | — |
| Hilux Travo Double Cab Prerunner 2.8 Overland AT | — | 6AT | — |
| Hilux Travo Double Cab Prerunner 2.8 Overland Plus AT | — | 6AT | — |
| Hilux Travo Smart Cab 4TREX 2.8 Premium AT | GUN226R-CTTMXT/A1 | 6AT | 1,029,000 |
| Hilux Travo Smart Cab 4TREX 2.8 Premium MT | GUN226R-CTFMXT/A1 | 6MT | 984,000 |
| Hilux Travo Smart Cab Prerunner 2.8 Premium AT | GUN236R-CTTMXT/A1 | 6AT | — |
| Hilux Travo Smart Cab Prerunner 2.8 Premium MT | GUN236R-CTFMXT/A1 | 6MT | — |
| Hilux Travo Smart Cab Prerunner 2.8 Smart AT | GUN236R-CTTLXT/A1 | 6AT | 839,000 |
| Hilux Travo Smart Cab Prerunner 2.8 Smart MT | GUN236R-CTFLXT/A1 | 6MT | — |

Other facts on the page worth storing: `GUN226R` / `GUN236R` are Toyota's AN120/AN130 Hilux chassis codes — the same platform family the Revo uses. Body styles offered are Standard Cab, Smart Cab (extended) and Double Cab. `Hilux Travo-e` (`HTBE`) is a **battery-electric Hilux**, series title "Hilux Travo-e Double Cab 4TREX". Toyota Thailand also lists `landcruiser_fj` / "Land Cruiser FJ" and `fortuner_legender` / "Fortuner Legender" as peer series, and `majesty`, `commuter`, `coaster` under the same commercial car type.

**Verdict:** `Hilux Travo` → **Hilux** (FOLD). Suggested comment wording: *Travo is Toyota Thailand's 2025 market badge for the Hilux, sold alongside Revo* — **not** "a misspelling of Revo".

**Kind-blind warning.** Rename keys are looked up per make, not per kind, so a `Hilux Travo` key under Toyota fires on the van, truck and bus catalogs as well as car. Here that is intended: Thailand registers pickups in more than one kind, and the correct answer in every kind is "Hilux". The manager confirmed the van corpus has `Hilux Travo` at 236 vehicles resolving to a non-live `van/toyota/hilux-travo`, so the key moves those onto the already-live `van/toyota/hilux`. Net effect: 732 car + 236 van vehicles recovered, no id destroyed.

---

### Toyota Hilux Champ — REFUSE

**URLs:** https://www.toyota.co.th/model/alphard (Toyota Thailand product data, as above) — accessed 2026-09-12, **opened directly**. Catalog cross-check against `dist/catalog.sqlite`, read-only.

Toyota Thailand's own series record:

- slug `hilux_champ`, **model_code `IMV0`**, title_en **"Hilux Champ"**, Thai **ไฮลักซ์ แชมป์**, slogan "ให้ทุกโอกาสเป็นไปได้".
- Price band **519,000 – 615,000 THB** — far below the Travo's 767,000 – 1,090,000.
- `can_conversion: true`, `is_4x4: false`.
- Toyota's own remark on the series: **"ไฮลักซ์ แชมป์ แค็บและแชสซีส์ (ไม่มีกระบะ) ราคารถกระบะรุ่นดังกล่าวเป็นราคาที่ได้รับการยกเว้นการเสียภาษีสรรพสามิต ทั้งนี้หากนำรถไปดัดแปลงหรือต่อเติมตามเงื่อนไขที่กฏหมายกำหนด"** — *"Hilux Champ cab and chassis (no cargo bed). The price of this pickup model is a price exempt from excise tax; if the vehicle is modified or has a body added under the conditions defined by law…"*. This is Toyota's own statement that the Champ is a bed-less cab-chassis sold for body conversion, in its own excise class.

**The deciding evidence is a published record.** `toyota/hilux-champ` ("Hilux Champ") is already published in our catalog, and `van/toyota/hilux-champ` is live carrying **8,155 Thai vehicles**. The DECISIONS fold safeguard is binding: a published record that contradicts a fold beats any pattern rule. `toyota/hilux-surf` ("Hilux Surf") is also published as a separate id from `toyota/hilux`, so this catalog has already ruled that a "Hilux *X*" name can be its own nameplate.

**Blast radius if folded.** A `"Hilux Champ": "Hilux"` key under make Toyota is kind-blind. It would have fired on the van catalog as well as car, folded `van/toyota/hilux-champ` into `van/toyota/hilux`, and **deleted a live id carrying 8,155 vehicles** — in order to move 94 car-kind vehicles onto an id that already carries `th`. The fold buys no new country availability at all.

**The argument I originally made, recorded so the reasoning is auditable.** I first proposed FOLD on a structural reading: toyota.co.th has no model level, and the same series list gives the Revo *two* peer entries ("Hilux Revo Standard Cab", "Hilux Revo Z Edition"), the Travo *four*, and lists "Fortuner Legender" as a peer series to Fortuner. If "separate series page = separate nameplate" applied at that granularity, Revo Z Edition would be a nameplate and Legender would not be a Fortuner — both absurd. That reasoning is sound about toyota.co.th's *series* level, but it is the wrong test here: the fold safeguard does not ask what the maker's CMS granularity is, it asks whether a published record contradicts the fold. One does. **REFUSE.**

The 94 car-kind vehicles stay as a candidate, which is the mechanism working: the Champ is a real nameplate, already published in another kind, and nothing is nulled.

---

### Toyota Alphard

**URL:** https://toyota.jp/pages/contents/alphard/004_p_001/pdf/alphard_spec_202606.pdf — official Toyota Japan specification sheet, linked from https://toyota.jp/alphard/ — accessed 2026-09-12, **opened directly**.

Sheet title: **「トヨタ アルファード 主要諸元表」** (Toyota Alphard main specifications table). Grades printed as column headers:

| powertrain | drive | grades | seats |
|---|---|---|---|
| プラグインハイブリッド車 (PHEV) | E-Four | **Executive Lounge**, **Z** | 6 |
| ハイブリッド車 (hybrid) | 2WD / E-Four | **Executive Lounge**, **Z** | 7 |
| ガソリン車 (petrol) | 2WD / 4WD | **G**, **Z** | 8 / 7 |

This establishes that **Z**, **Executive Lounge** and **G** are Alphard *grades*, that **2.5** is the displacement, and that **E-Four** is Toyota's electric rear-axle AWD system — i.e. none of them is a nameplate.

Everything else the sheet states, harvested:

- **Engines.** Hybrid/PHEV: **A25A-FXS**, **2.487 L**, inline-4, regular unleaded. Petrol: **2AR-FE**, **2.493 L**, inline-4. (So the register's "2.5" is 2,487/2,493 cc.)
- **Dimensions.** Length **4,995 mm**; width **1,850 mm**; height **1,935 mm** (PHEV 1,945; 1,935 with 19-inch tyres); wheelbase **3,000 mm**; track front/rear **1,600/1,600 mm** (E-Four 1,605); minimum ground clearance **150 mm** (PHEV 155, 19-inch 160, 17-inch 150); interior length/width/height **3,005 / 1,660 / 1,360 mm**; minimum turning radius **5.9 m**.
- **Seating.** 6 / 7 / 8 depending on grade.
- **Kerb weight.** 2,060–2,470 kg; gross vehicle weight 2,445–2,800 kg.
- **Fuel economy (WLTC, MLIT figures).** Petrol Z 10.9 km/L [10.4 E-Four]; hybrid Z 18.9 [17.8]; hybrid G 18.8 [17.8]; hybrid Executive Lounge 17.5 [16.8]; PHEV [16.7].
- **PHEV electric data.** Plug-in range (充電電力使用時走行距離) **73 km**; equivalent EV range **73 km**; AC energy consumption **209 Wh/km** (Executive Lounge) / 207 (Z); consumption per charge **15.26 kWh** / 15.11; measured at AC 200 V / 16 A.
- **Vehicle type codes.** PHEV `6LA-AAHP45W-*`; hybrid `6AA-AAHH40W-*` (2WD) and `6AA-AAHH45W-*` (E-Four); petrol `3BA-AGH40W-*` (2WD) and `3BA-AGH45W-*` (4WD).
- **Efficiency technologies listed.** Plug-in hybrid system, idling stop, in-cylinder direct injection, variable valve timing, electric power steering, charge control, electric CVT (hybrid/PHEV); variable valve timing, EPS, automatic CVT (petrol).
- **Market:** Japan. Toyota states three powertrains are offered, with PHEV newly added.

**Folds.** `Alphard Z 2WD`, `Alphard Z 2.5L`, `Alphard Z 2WD 2.5L`, `Alphard 2.5 Z`, `Alphard Z`, `Alphard Executive Lounge` are all Tier A: grade + displacement + drivetrain all sourced on this sheet. Together they are **1,136 of the cluster's 1,471 vehicles.**

**Tier B rows.** `Alphard 2.5 Sc Package`, `Alphard Sc Package 2.5L`, `Alphard Sc Package`, `Alphard 2.5L Sc Package`, `Alphard X`, and `Alphard 2.5` (whose raw strings are `ALPHARD 2.5 HYBRID EXECUTIVE`, `… G F PACKAGE`, `… SR C`, `… SRC PACKAGE`). "S C Package", "G F Package", "SR C Package" and "X" are grades of the **30-series Alphard (2015–2023)**, whose Toyota Japan model page has been retired — `https://toyota.jp/alphard/prev/` and `https://toyota.jp/alphardhybrid/` both return 404. I could not open a page-level Toyota source for those grade strings and I am not asserting one. The fold does not depend on them: each string leads with the published nameplate "Alphard", the displacement token is sourced above, and no published record contradicts the fold (there is no `toyota/alphard-*` id of any kind in the catalog). The unsourced grade strings are itemised in UNRESOLVED-detail.

---

### Toyota Vellfire

**URL:** https://toyota.jp/pages/contents/vellfire/003_p_001/pdf/vellfire_spec_202606.pdf — linked from https://toyota.jp/vellfire/ (title 「トヨタ ヴェルファイア」) — accessed 2026-09-12, **opened directly**.

Sheet title: **「トヨタ ヴェルファイア 主要諸元表」**. Grades printed as column headers:

| powertrain | drive | grades | seats |
|---|---|---|---|
| プラグインハイブリッド車 (PHEV) | E-Four | **Executive Lounge** | 6 |
| ハイブリッド車 | 2WD / E-Four | **Executive Lounge**, **Z Premier** | 7 |
| ターボガソリン車 (turbo petrol) | 2WD / 4WD | **Z Premier** | 7 |

**"Z Premier" is a Vellfire grade**, confirmed directly. "E-Four" is the electric AWD system, not a nameplate. The turbo-petrol Vellfire is the **2.4 L** engine (type codes `5BA-TAHA40W-PFZTT` 2WD / `5BA-TAHA45W-PFZTT` 4WD), which is what the register's `VELLFIRE Z PREMIER 2.4L` refers to; the hybrid is the 2.5 L `A25A-FXS` (`6AA-AAHH40W-*` / `6AA-AAHH45W-*`), and the PHEV is `6LA-AAHP45W-PPXZB`. Fuel economy WLTC for the hybrid Z Premier is 18.7 [17.6] km/L with 17-inch tyres; 20.9 [19.2] km/L extra-urban; 18.6 [17.8] km/L highway. The Vellfire shares the Alphard's platform and body dimensions. Market: Japan.

**Tier B rows.** `Vellfire Z G Edition`, `Vellfire 2.5ZG Edition` and `Vellfire 250` are 30-series (2015–2023) strings whose grade names are not on the current sheet. `250` is an **engine designation** in Toyota's Vellfire naming convention (compare the 20-series "Vellfire 240S" / "350S", where the number is the displacement in decilitres) — by lane rule 5 an engine designation is not a nameplate. All three lead with the published nameplate and nothing contradicts the fold.

---

### Toyota Crown — one nameplate, not three

This cluster looked like the Onix / Onix Plus trap and is not, and Toyota's own documents are what settle it.

**URLs**, all accessed 2026-09-12, all **opened directly**:

- https://toyota.jp/crown/ — title 「トヨタ クラウン」
- https://toyota.jp/crowncrossover/ — title 「トヨタ クラウン（クロスオーバー）」
- https://toyota.jp/crownsport/ — title 「トヨタ クラウン（スポーツ）」
- https://toyota.jp/crownestate/ — title 「トヨタ クラウン（エステート）」
- https://toyota.jp/pages/contents/crown/013_p_001/pdf/crown_spec_202609.pdf
- https://toyota.jp/pages/contents/crowncrossover/001_p_001/pdf/crowncrossover_spec_202609.pdf
- https://toyota.jp/pages/contents/crownsport/001_p_001/pdf/crownsport_spec_202609.pdf

The page titles are already parenthetical variants — "Crown (Crossover)", "Crown (Sport)", "Crown (Estate)" — which the COV4 rules list as a foldable form. The specification sheets are decisive: **all three PDFs carry the identical title 「トヨタ クラウン 主要諸元表」** ("Toyota **Crown** main specifications table"), and the body style appears *inside the grade name*, not in the model name:

| sheet | powertrain | grades as printed |
|---|---|---|
| `crown_spec_202609.pdf` | 2.5 L hybrid 2WD (FR); 燃料電池車 (fuel-cell) 2WD | **Z**, **G**; fuel-cell **Z** |
| `crowncrossover_spec_202609.pdf` | 2.4 L turbo hybrid 4WD; 2.5 L hybrid | **CROSSOVER RS**, **CROSSOVER Z**, **CROSSOVER G** |
| `crownsport_spec_202609.pdf` | 2.5 L plug-in hybrid 4WD; 2.5 L hybrid 4WD | **SPORT RS**, **SPORT Z**, **SPORT G** |

Toyota itself writes the grade as "CROSSOVER Z" and "SPORT Z" under a model called Crown. That resolves every row:

- `Crown Crossover` (raw `CROWN CROSSOVER RS ADVANCE` / `RS ADVANCED`) → Crown, grade CROSSOVER RS (Advance package).
- `Crown Crossover G Advanced` → Crown, grade CROSSOVER G.
- `Crown Sport Z`, `Crown Sport Z 2.5L`, `Crown 2.5L Sport Z` (raw `… SPORT Z HYBRID`) → Crown, grade SPORT Z, 2.5 L hybrid.
- `Crown Sport` (raw `CROWN SPORT RS`) → Crown, grade SPORT RS.
- `Crown Z`, `Crown Z 2.5L` → Crown, grade Z (the sedan, 2.5 L hybrid FR).

Additional facts harvested: the Crown sedan is offered as a **fuel-cell vehicle** (燃料電池車, 2WD) alongside the 2.5 L hybrid; the Crown Sport offers a **2.5 L plug-in hybrid 4WD**; the Crown Crossover's top powertrain is a **2.4 L turbo hybrid 4WD**. Crossover track is 1,600/1,605 mm with 18-inch alloys. Market: Japan.

**Fold-safeguard check:** `toyota/crown-majesta` ("Crown Majesta") and `toyota/crown-signia` ("Crown Signia") are published as separate Crown nameplates, but there is **no** published `toyota/crown-sport`, `toyota/crown-crossover` or `toyota/crown-estate`. Nothing contradicts these folds.

---

### Toyota Land Cruiser — the split

This is the cluster where the packet's suggested target is wrong for part of the rows, and the maker's own naming plus a published record decide it.

**URLs**, accessed 2026-09-12, **opened directly**:

- `https://toyota.jp/landcruiser/` → **404** (there is no generic Land Cruiser model page)
- https://toyota.jp/landcruiser300/ → title **「トヨタ ランドクルーザー“300”」**
- https://toyota.jp/landcruiser250/ → title **「トヨタ ランドクルーザー“250”」**
- https://toyota.jp/landcruiser70/ → title **「トヨタ ランドクルーザー“70”」**
- https://toyota.jp/pages/contents/landcruiser250/001_p_001/pdf/landcruiser250_spec_202604.pdf → sheet title **「トヨタ ランドクルーザー“250” 主要諸元表」**
- https://toyota.jp/pages/contents/landcruiser70/003_p_001/pdf/landcruiser70_spec_202311.pdf → sheet title **「トヨタ ランドクルーザー“70” 主要諸元表」**
- `https://toyota.jp/landcruiserprado/` → **404** (retired in Japan, replaced by the 250)

Toyota Japan publishes **three peer Land Cruiser model pages, and the number is inside the official model name** — Toyota prints it in quotation marks as part of the name. Toyota Thailand separately lists a fourth, `landcruiser_fj` / "Land Cruiser FJ".

**REFUSE — Land Cruiser "70" rows** (`Land Cruiser 70 Ax` 35, `Land Cruiser 70 Ax 2.8L` 1, `Land Cruiser 71 Hardtop 4.0L` 3). This is a distinct nameplate with its own model page and its own spec sheet. The 70 is a ladder-frame off-roader in continuous production since 1984 — not a trim of the flagship. Its spec sheet shows a **2.8 L diesel, 4WD, single grade "AX"** — so the register's "AX" is the 70's own grade name, which is precisely why folding it to "Land Cruiser" would be wrong: it would carry a 70-series grade onto the flagship id. "71" is the short-wheelbase hardtop within the same 70 series. There is no published `toyota/land-cruiser-70`, so these stay as candidates for a second register to corroborate. Nothing is nulled.

**REFUSE — Land Cruiser "250" rows** (`Land Cruiser 250 ZX First` 25, `Land Cruiser 250 ZX` 21, `Land Cruiser 250 ZX 2.8L` 5, `Land Cruiser 250 Vx` 4, `Land Cruiser 250 Gx` 1, `Land Cruiser 250 Vx 2.8L` 1). Distinct model page, distinct spec-sheet title, and the 250 is the **successor to the Land Cruiser Prado** — which this catalog already publishes separately as `toyota/land-cruiser-prado`. Folding the Prado's successor onto the flagship id while the Prado itself sits on its own id would be incoherent. A published record also contradicts the fold directly: **`toyota/land-cruiser-250-td` ("Land Cruiser 250 Td") is already published.** The 250 spec sheet shows a **2.7 L petrol 4WD, grade VX** (length 4,925 mm, 4,990 mm with a hitch member fitted). "First" in `Land Cruiser 250 ZX First` is the **First Edition** launch trim, not a nameplate.

**FOLD — Land Cruiser "300" rows and bare Land Cruiser rows** (`Land Cruiser ZX` 15, `Land Cruiser 300 ZX` 13, `Land Cruiser 300 ZX 3.3L` 12, `Land Cruiser Gr Sport` 6, `Land Cruiser Ax` 5, `Land Cruiser 300 Sahara 3.3L` 1, `Land Cruiser 300 Sahara ZX` 1, `Land Cruiser 300 ZX Diesel` 1, `Land Cruiser Gr` 1, `Land Cruiser Gx 3.5L` 1). The 300 is the flagship line that `toyota/land-cruiser` denotes; in Thailand and most export markets it is sold simply as "Land Cruiser", with "300" functioning as the generation designator Toyota Japan appends. Critically, **no published record contradicts this**: there is no `toyota/land-cruiser-300` id in the catalog, whereas there *is* a `land-cruiser-250-*` id — the asymmetry in our own catalog matches the asymmetry in the verdicts. "3.3L" is the V6 turbodiesel and "3.5L" the V6 petrol; "Sahara" is an Australian-market grade; "GR Sport" is a grade. These are Tier B because the Land Cruiser 300 grade table at https://toyota.jp/landcruiser300/grade/ is JavaScript-rendered and I could not extract the grade list from the page source — I am not asserting a grade list I did not read.

**FOLD — Land Cruiser Prado rows** (`Land Cruiser Prado Tx L` 2, `Land Cruiser Prado 2.7 Tx-L` 2, `Land Cruiser Prado Tx` 1, `Land Cruiser Prado Tz` 1, raw `… TZ-G`). Target `toyota/land-cruiser-prado` ("Land Cruiser Prado") is published. TX, TX-L and TZ-G are 150-series Prado grades and 2.7 is the petrol displacement; the Japanese Prado page has been retired, so these are Tier B.

---

### Toyota GR86, GR Yaris, GR Corolla, GR Supra

**GR86** — https://toyota.jp/pages/contents/gr86/001_p_001/pdf/gr86_spec_202608.pdf, from https://toyota.jp/gr86/ (「トヨタ GR86」). Accessed 2026-09-12, **opened directly**. Sheet title 「トヨタ GR86 主要諸元表」. Grades printed as column headers: **RZ**, **SZ**, **RC**.

| grade | transmission | type code | kerb (kg) | GVW (kg) | WLTC (km/L) |
|---|---|---|---|---|---|
| RZ | 6-speed automatic (6 Super ECT) | 3BA-ZN8-F2K7 | 1,300 | 1,520 | 11.7 |
| RZ | 6-speed manual | 3BA-ZN8-F2K8 | 1,280 | 1,500 | 11.9 |
| SZ | 6-speed automatic (6 Super ECT) | 3BA-ZN8-F2B7 | 1,290 | 1,510 | 11.8 |
| SZ | 6-speed manual | 3BA-ZN8-F2B8 | 1,270 | 1,490 | 12.0 |
| RC | 6-speed manual | 3BA-ZN8-F2A8 | 1,270 | 1,490 | 12.0 |

Folds `GR86 Rc`, `GR86 RZ`, `GR86 Sz`, `GR86 RZ 2WD` at Tier A. `GR86 Cup Car Basic`, `GR86 RZ Ridge Green Limited`, `GR86 RZ 10TH Anniversary` and `GR86 RZ Greddy` are Tier B: **RC is the motorsport-entry base car** (the "Cup Car Basic" is that car specified for one-make racing), and "Ridge Green Limited", "10th Anniversary" and "Greddy" are colour/limited-edition tags, not nameplates. The GR86 is rear-wheel drive throughout, so "2WD" in row 45 is a drivetrain token, not a variant.

**GR Yaris** — https://toyota.jp/pages/contents/gryaris/001_p_002/pdf/gryaris_spec_202603.pdf, from https://toyota.jp/gryaris/ (「トヨタ GRヤリス」). Sheet title 「トヨタ GRヤリス 主要諸元表」. Grade tokens printed on the sheet: **RZ**, **RZ "High performance"**, **RC**, **RS**, plus the **"+ Aero performance package"** option. Transmissions are **GR-DAT (8AT, 4WD)** and **6MT (4WD)**; seating 4. The RC column is headed **モータースポーツ参戦用車両** — "vehicle for motorsport entry", the stripped base car. This folds `Gr Yaris RZ High Performance` (the grade is literally *RZ "High performance"*), `Gr Yaris Rc`, `Gr Yaris Rc At` and `Gr Yaris Rc M/T` at Tier A; "At" and "M/T" are transmissions.

**GR Corolla** — https://toyota.jp/pages/contents/grcorolla/001_p_004/pdf/grcorolla_spec_202509.pdf, from https://toyota.jp/grcorolla/ (「トヨタ GRカローラ」). Sheet title 「トヨタ GRカローラ 主要諸元表」, grade **RZ**, transmissions **GR-DAT (8AT・4WD)** and **6MT (4WD)**. Folds `Gr Corolla RZ` at Tier A.

**GR Supra** — Tier B, and I want to be explicit about this. `https://toyota.jp/grsupra/`, `/supra/`, `/gr_supra/` and `/grsupra/grade/` **all return 404**; the GR Supra has ended production and Toyota Japan has retired the model page. **I did not open a maker page for the GR Supra and I am not citing one.** The six rows (`Gr Supra RZ`, `Gr Supra Sz-R`, `Gr Supra RZ 3.0`, `Gr Supra RZ 6MT`, `Gr Supra RZ Plasma Orange 100`, `Gr Supra RZ Matte White Edit`, 17 vehicles total) all lead with the published nameplate `toyota/gr-supra` ("Gr Supra"), and the tails are a displacement (3.0), a transmission (6MT) and colour-edition tags (Plasma Orange 100, Matte White Edition). No published record contradicts the fold. The grade strings RZ and SZ-R are listed in UNRESOLVED-detail as unsourced.

---

### Toyota Voxy, Noah, Roomy, Harrier, Century

All from official Toyota Japan spec sheets, accessed 2026-09-12, **opened directly**.

- **Voxy** — https://toyota.jp/pages/contents/voxy/004_p_001/pdf/voxy_spec_202609.pdf, sheet title 「トヨタ ヴォクシー 主要諸元表」. Grades **S-Z** and **S-G**, hybrid, 7 or 8 seats, 2WD or **E-Four**. Folds `Voxy Sz` (raw `VOXY SZ HYBRID 1.8L` — the 1.8 L hybrid) and `Voxy S-Z 2WD` at Tier A.
- **Noah** — https://toyota.jp/pages/contents/noah/004_p_001/pdf/noah_spec_202609.pdf, sheet title 「トヨタ ノア 主要諸元表」. Hybrid grades **S-Z**, **S-G**, **S-X**, 7 or 8 seats; type codes `6AA-ZWR90W-APXRB` / `-APXSB` / `-ARXSB` / `-APXTB` / `-ARXTB`. `Noah X 2WD` is Tier B: the current sheet covers only the hybrid range, and bare **X** is the petrol entry grade, which is not printed on this sheet.
- **Roomy** — https://toyota.jp/pages/contents/roomy/001_p_006/pdf/roomy_spec_202608.pdf, sheet title 「トヨタ ルーミー 主要諸元表」. Grades as printed: **カスタムG-T (Custom G-T)**, **カスタムG (Custom G)**, **G-T**, **G**, **X**, with 4WD variants. Folds `Roomy Custom GT` at Tier A — "Custom G-T" is a Roomy grade name, not a separate model.
- **Harrier** — https://toyota.jp/pages/contents/harrier/004_p_001/pdf/harrier_spec_202608.pdf, sheet title 「トヨタ ハリアー 主要諸元表」. Hybrid (2WD / E-Four) grades **Z** and **G**; fuel economy WLTC 22.3 [21.6] km/L with the dimming panoramic roof, urban 20.6 [18.9], extra-urban 24.0 [24.0], highway 22.0 [21.4]. Folds `Harrier 2.5` (raw `HARRIER 2.5 HYBRID Z LEATHER` — the 2.5 L hybrid, grade Z, leather package) at Tier A.
- **Century** — https://toyota.jp/pages/contents/century/003_p_001/pdf/century_spec_202512.pdf, sheet title 「トヨタ センチュリー 主要諸元表」, powertrain **5.0 L ハイブリッド車** (5.0 L hybrid). The model page https://toyota.jp/century/ is titled 「トヨタ センチュリー（セダン）」 — Century (Sedan). Folds `Century 5.0L` at Tier A, and the 5.0 L token is itself the disambiguator: the Century sedan is the 5.0 L V8 hybrid, distinct from the Century SUV.

---

### Suzuki Swift (Thailand) — 2,230 vehicles

**URL:** https://www.suzuki.co.th/en/model/swift/specification — Suzuki Motor (Thailand) Co., Ltd. official specification page, title "Specifications - Suzuki SWIFT". Accessed 2026-09-12, **opened directly**.

The page's own **GRADE & PRICE** block lists exactly three grades:

| grade | price (THB) |
|---|---|
| **GL** | 567,000 |
| **GL NEXT** | 582,000 |
| **GLX** | 637,000 |

Full specification table, identical across the three grades except where noted:

- **Engine** **K12M**, piston displacement **1,197 cc**, bore × stroke **73.0 × 71.5 mm**, compression ratio **11.5**, maximum output **83 PS / 6,000 rpm**, maximum torque **108 Nm / 4,400 rpm**, multipoint injection, fuel type **E20**.
- **Transmission** **CVT** on all three grades; drive system **2WD**.
- **Dimensions** overall length **3,845 mm**, width **1,735 mm**, height **1,495 mm**, wheelbase **2,450 mm**; front/rear tread **1,530/1,530 mm** (GL, GL NEXT) and **1,525/1,525 mm** (GLX); minimum turning radius **4.8 m**; minimum ground clearance 37 mm; luggage capacity **265 litres**.
- **Weight** kerb **875–910 kg**; gross vehicle weight **1,365 kg**.
- **Wheels/tyres** 175/65 R15 (GL, GL NEXT); 185/55 R16 (GLX).
- Market: Thailand. Body style: 5-door hatchback.

This confirms at Tier A that **GL, GL NEXT and GLX are Swift grades**, that **1.2L** is the 1,197 cc K12M, and that **CVT** is the transmission — folding rows 1, 2 and 6 (2,216 vehicles).

Tier B: `Swift GL Plus 1.2L Cvt` (11) and `Swift Glx-Navi 1.2L Cvt` (3). **GL PLUS** and **GLX Navi** are not among the current three grades; they belong to the previous Thai Swift range, whose spec page is no longer published. Same K12M/CVT drivetrain tokens apply.

**Fold-safeguard check:** `suzuki/swift-sport` ("Swift Sport") is published as a separate nameplate. None of the five keys above can reach it — no key contains "Sport".

---

### Suzuki Celerio (Thailand) — 1,306 vehicles

**URL:** https://www.suzuki.co.th/en/model/CELERIO/specification — Suzuki Motor (Thailand) official specification page, title "Specifications - Suzuki CELERIO". Accessed 2026-09-12, **opened directly**.

Retrieval note: the Celerio has been withdrawn from Suzuki Thailand's current line-up and the lower-case paths (`/model/celerio`, `/en/model/celerio/specification`) now 302 to the home page. The **upper-case** path still serves the live page. This is Suzuki's own page, not an archive copy.

The page's **GRADE & PRICE** block lists four grades:

| grade | promotional price (THB) | list price (THB) |
|---|---|---|
| **GA/MT** | 319,900 | 338,000 |
| **GL/CVT** | 379,900 | 416,000 |
| **GL UP** | 391,900 | 423,000 |
| **GX/CVT** | 399,900 | 451,000 |

This confirms at Tier A that **GA, GL, GL UP and GX are Celerio grades** and that **MT/CVT** are the transmissions — folding all seven Celerio rows. `GL UP` is a genuine Suzuki grade name, not a corruption.

Full specification table (single engine across the range):

- **Engine** **K10B, 3 cylinders, 12 valves**, piston displacement **998 cc**, bore × stroke **73.0 × 79.5 mm**, compression ratio **11.0**, maximum output **68 PS / 6,000 rpm**, maximum torque **90 Nm / 3,500 rpm**, multipoint injection, fuel type **E20**.
- **Transmission** **5MT** (GA) and **CVT** (GL, GL UP, GX); first gear ratio 3.545 (5MT).
- **Dimensions** overall length **3,600 mm**, width **1,600 mm**, height **1,540 mm**, wheelbase **2,425 mm**, front tread **1,420 mm**, rear tread **1,410 mm**, minimum turning radius **4.7 m**, minimum ground clearance **145 mm**.
- **Capacities** seating **5**, fuel tank **35 litres**.
- Market: Thailand. Body style: 5-door hatchback.

---

### Suzuki Ciaz (Thailand)

**URL:** https://www.suzuki.co.th/en/model/CIAZ/specification — title "Specifications - Suzuki CIAZ". Accessed 2026-09-12, **opened directly**. Same upper-case retrieval note as the Celerio.

**GRADE & PRICE**: **GL/MT** 378,000* / 528,000 · **GL/CVT** 414,000* / 528,000 · **GLX/CVT** 478,000* / 564,000 · **RS/CVT** 528,000* / 678,000 THB.

Specifications: **engine K12B, 4 cylinders, 16 valves, 1,242 cc**, bore × stroke **73.0 × 74.2 mm**, compression ratio **11.0**. Overall length **4,490 / 4,495 mm** (the longer figure is the RS bodykit), width **1,730 mm**, height **1,475 mm**, wheelbase **2,650 mm**, front tread **1,495 mm**, rear tread **1,505 mm**, minimum turning radius **5.4 m**, minimum ground clearance **145 mm**; seating **5**; maximum luggage capacity **565 litres**; fuel tank **42 litres**. Market: Thailand. Body style: 4-door sedan.

This folds `Ciaz GL Cvt`, `Ciaz Glx Cvt`, `Ciaz GL MT` and `Ciaz Glx 1.25L Cvt` at Tier A — and note the 1,242 cc displacement is exactly the register's **"1.25L"**, confirming that token as an engine designation.

---

### Suzuki XL7 and Fronx (Thailand)

**XL7** — https://www.suzuki.co.th/en/model/xl7/specification, accessed 2026-09-12, **opened directly**. Grade **GLX**, 799,000* / 825,000 THB. Engine **1,462 cc**, bore × stroke **74.0 × 85.0 mm**, compression ratio **10.5**, maximum output **105 PS / 6,000 rpm**, maximum torque **138 Nm / 4,400 rpm**. Marketed as "XL7 HYBRID". This folds `XL7 1.5L` at Tier A — 1,462 cc is the 1.5 L.

**Fronx** — https://www.suzuki.co.th/model/fronx/, accessed 2026-09-12, **opened directly**. Grades **GL** 689,000 · **GLX** 749,000 · **GLX PLUS** 799,000 THB. Powertrain described as **SMART HYBRID VEHICLE (SHVS)** with the **K15C DUALJET** engine and an Integrated Starter Generator (ISG). The K15C is the 1.5 L unit, folding `Fronx 1.5L` at Tier A.

---

### Suzuki Jimny, Jimny Sierra, Jimny Nomade — the three-way split

This is the cluster the packet flagged as most dangerous, and all three names turn out to be genuinely distinct. Suzuki Japan publishes **three separate model pages with three different titles**, and I confirmed the URLs do not redirect into one another:

| URL | title | grades on page | verdict |
|---|---|---|---|
| https://www.suzuki.co.jp/car/jimny/ | **ジムニー** (Jimny) | **XC**, **XL**, **XG** | target `suzuki/jimny` |
| https://www.suzuki.co.jp/car/jimny_sierra/ | **ジムニー シエラ** (Jimny Sierra) | **JC**, **JL** — from ¥2,271,500 | target `suzuki/jimny-sierra` |
| https://www.suzuki.co.jp/car/jimny_nomade/ | **ジムニー ノマド** (Jimny Nomade) | **FC**, 5ドア (5-door) | **REFUSE** |

All accessed 2026-09-12, **opened directly**. Both `suzuki/jimny` ("Jimny") and `suzuki/jimny-sierra` ("Jimny Sierra") are published as separate ids, matching Suzuki's own structure.

- **`Jimny Sierra Jc`, `Jimny Sierra Jc 1.5L`, `Jimny Sierra Jl` → Jimny Sierra** (Tier A). **JC and JL are Jimny Sierra's own grades** — confirmed on the Sierra page, not the Jimny page. Sierra is *not* folded into Jimny and Jimny is *not* folded into Sierra.
- **`Jimny XC`, `Jimny XG MT`, `Jimny XC MT` → Jimny** (Tier A). XG/XL/XC are the kei Jimny's grades. "MT" and "4WD" are transmission/drivetrain tokens.
- **`Jimny 1.5L 4AT` → Jimny** (Tier A), sourced on **Suzuki Motor (Thailand)**'s own page https://www.suzuki.co.th/model/jimny/: engine **K15B, 1.5 litre**, **AT**, **Part-time 4WD (ALLGRIP PRO)**, described as an "authentic compact 4WD"; grades AT single-tone ฿1,590,000 and AT two-tone ฿1,620,000. Worth recording for the manager: the vehicle Suzuki Thailand sells as plain **"Jimny"** is the wide-body 1.5 L car that Japan calls **Jimny Sierra**. Because the register string is `JIMNY 1.5L 4AT` and Suzuki's *Thai* page calls it Jimny, the fold follows the maker's naming in the market of registration. If the manager prefers to follow the Japanese naming instead, this is the one row in the Jimny cluster that could defensibly go to `suzuki/jimny-sierra` — 48 vehicles. I record it as Jimny.
- **`Jimny Alpha 5` (raw `JIMNY ALPHA 5 DOOR`) and `Jimny Alpha` (raw `JIMNY ALPHA 4WD`) → Jimny** (Tier A), sourced on **Maruti Suzuki's NEXA** page https://www.nexaexperience.com/jimny/, which states the variants are "**Zeta AT, Alpha AT**" and "**Zeta MT, Alpha MT**". **Alpha is a Jimny grade in India.** Page also states: **1.5 L K15B** engine, peak power **104.8 PS @ 6,000 rpm**, peak torque **134.2 Nm @ 4,000 rpm**, **6 airbags standard across all variants**. India's Jimny is the 5-door. Market: India (these are Thai-registered imports).
- **`Jimny Nomade Fc 5` → REFUSE.** See refusals below.

The India/Japan tension is worth naming explicitly: the **same physical 5-door body** is sold as plain **"Jimny"** by Maruti Suzuki in India and as **"Jimny Nomade"** by Suzuki in Japan. The register string decides which: `JIMNY ALPHA 5 DOOR` uses the Indian grade name and goes to Jimny; `JIMNY NOMADE FC 5 DOOR` uses the Japanese model name and is refused.

---

### Suzuki Spacia and Wagon R

Accessed 2026-09-12, **opened directly**. I checked redirect behaviour explicitly rather than inferring it from titles:

| URL requested | final URL | title | verdict |
|---|---|---|---|
| https://www.suzuki.co.jp/car/spacia/ | `/car/spacia/` | **スペーシア** (Spacia) | target |
| https://www.suzuki.co.jp/car/spacia_custom/ | **→ 301 → `/car/spacia/`** | スペーシア | **FOLD** |
| https://www.suzuki.co.jp/car/spacia_gear/ | `/car/spacia_gear/` | **スペーシア ギア** (Spacia Gear) | **REFUSE** |
| https://www.suzuki.co.jp/car/wagonr/ | `/car/wagonr/` | **ワゴンＲ** (Wagon R) | target |
| https://www.suzuki.co.jp/car/wagonr_smile/ | `/car/wagonr_smile/` | **ワゴンR スマイル** (Wagon R Smile) | **REFUSE** |

`Spacia Custom` folds because Suzuki's own server **301-redirects** the Custom URL onto the Spacia model page — Suzuki treats Custom as part of the Spacia model page, not a separate model. Spacia Gear and Wagon R Smile keep their own URLs and their own titles.

One trap avoided and worth recording: the Wagon R Smile page contains the strings `FC5`, `FC7`, `FC8`. These are **paint colour codes** (e.g. `トープグレージュメタリックソフトベージュ2トーンルーフ（FC7）` — "Taupe Greige Metallic / Soft Beige 2-tone roof (FC7)"), **not grades**, and specifically not the same `FC` that is the Jimny Nomade's grade. Manufacturer's suggested retail price listed: **¥1,516,900**.

---

## REFUSALS

Fourteen rows, 198 vehicles. Each one is a real machine; none is nulled, and each stays available as a candidate for a second register to corroborate.

### 1. `Hilux Champ` (94 veh) — REFUSE

Full reasoning in the evidence block above. In short: **`van/toyota/hilux-champ` is already published and live with 8,155 vehicles**, so the fold safeguard applies directly — a published record that contradicts a fold beats any pattern rule. `toyota/hilux-surf` is a second published precedent that a "Hilux *X*" name can be its own nameplate. Toyota Thailand's own description corroborates a distinct vehicle: model code **IMV0** (not IMV), **cab-and-chassis with no cargo bed** ("แค็บและแชสซีส์ (ไม่มีกระบะ)"), its own excise class, `can_conversion: true`, and a price band of 519,000–615,000 THB against the Travo's 767,000–1,090,000.

Because rename keys are looked up **per make, not per kind**, a `"Hilux Champ": "Hilux"` key would have fired on the van catalog too and **deleted a live id carrying 8,155 vehicles** — to gain 94 car-kind vehicles on an id that already has `th` availability. The fold would have bought nothing and cost a nameplate.

I originally argued FOLD from the structure of toyota.co.th (no model level; the Revo itself has two peer series entries; "Fortuner Legender" is a peer series to Fortuner). That reasoning is correct about Toyota Thailand's CMS granularity but is the wrong test — the safeguard asks about published records, not about maker site structure. Recorded here so the reversal is auditable.

### 2–7. The Land Cruiser "70" and "250" rows (six rows for 250, three for 70 — 93 veh)

`Land Cruiser 70 Ax` (35), `Land Cruiser 250 ZX First` (25), `Land Cruiser 250 ZX` (21), `Land Cruiser 250 ZX 2.8L` (5), `Land Cruiser 250 Vx` (4), `Land Cruiser 71 Hardtop 4.0L` (3), `Land Cruiser 250 Gx` (1), `Land Cruiser 250 Vx 2.8L` (1), `Land Cruiser 70 Ax 2.8L` (1).

Toyota Japan publishes **three peer model pages** — ランドクルーザー"300", ランドクルーザー"250", ランドクルーザー"70" — with the number printed **inside the official model name**, and `https://toyota.jp/landcruiser/` returns 404, so there is no generic "Land Cruiser" page these could be trims of. The 250 and 70 each have their own specification sheet carrying their own model name in the title.

For the 250 specifically, a published record also contradicts the fold: **`toyota/land-cruiser-250-td` ("Land Cruiser 250 Td") is already published**. And the 250 is the **successor to the Land Cruiser Prado**, which this catalog publishes separately as `toyota/land-cruiser-prado` — folding the successor onto the flagship id while the predecessor sits on its own id would be incoherent.

Note that "AX" is the Land Cruiser 70's *own* grade name (its spec sheet shows a single grade, AX, 2.8 L diesel 4WD). Folding `Land Cruiser 70 Ax` to "Land Cruiser" would therefore carry a 70-series grade onto the flagship record — the precise failure mode the safeguard exists to prevent. "71" is the short-wheelbase hardtop of the same 70 series. "First" is the 250's First Edition launch trim.

There is no published `toyota/land-cruiser-70`; per lane rule 3 I do not propose minting one from a single sub-threshold source. These stay as candidates.

### 8–9. `Spacia Gear` (4 veh) and `Spacia Gear My Style` (2 veh) — REFUSE

Suzuki publishes **スペーシア ギア** at its own URL https://www.suzuki.co.jp/car/spacia_gear/ with its own title, while `/car/spacia_custom/` **301-redirects** to the plain Spacia page. Suzuki's own server therefore distinguishes exactly which sub-name is part of the Spacia model page and which is not: Custom is, Gear is not. "My Style" is a Spacia Gear trim (raw `SPACIA GEAR MY STYLE HYBRID`), so it belongs to Spacia Gear, not to Spacia. No `suzuki/spacia-gear` is published; these stay as candidates.

### 10. `Wagon R Smile` (1 veh) — REFUSE

Suzuki publishes **ワゴンR スマイル** at its own URL https://www.suzuki.co.jp/car/wagonr_smile/, separate from **ワゴンＲ** at /car/wagonr/. It is a distinct sliding-door tall-wagon body, not a Wagon R trim. MSRP ¥1,516,900. No `suzuki/wagon-r-smile` is published; stays a candidate.

### 11. `Jimny Nomade Fc 5` (1 veh) — REFUSE

Suzuki publishes **ジムニー ノマド** at its own URL https://www.suzuki.co.jp/car/jimny_nomade/, separate from both ジムニー and ジムニー シエラ. **FC** is the Nomade's own grade and the page states **5ドア** (5-door); the raw register string is `JIMNY NOMADE FC 5 DOOR`, which matches exactly. Folding it to Jimny would merge a distinct Japanese nameplate into the kei Jimny. No `suzuki/jimny-nomade` is published; stays a candidate.

Note the asymmetry deliberately preserved: `Jimny Alpha 5 Door` **does** fold to Jimny, because that is the Indian-market Jimny 5-door and Maruti Suzuki names it "Jimny" with an "Alpha" grade. Same body, two maker names, two verdicts, each following the maker's naming in the market of the register string.

---

## UNRESOLVED

### Rows I could not source at all

**`Yaris Grmn Circuit Package` (2 veh).** GRMN ("Gazoo Racing Masters of Nürburgring") is Toyota's top-tier tuning designation, and Toyota marketed the GRMN Yaris as a limited, separately-ordered model. Toyota Japan's GRMN Yaris page is no longer online and I could not open any Toyota page that shows whether "GRMN Yaris" is presented as a Yaris grade or as its own model. This matters because this catalog already publishes `toyota/gr-yaris` ("Gr Yaris") **separately** from `toyota/yaris` ("Yaris"), so the analogous derivative may well be a separate nameplate too. Folding it to Yaris on a pattern guess is exactly the defect this lane exists to prevent. **UNRESOLVED**, 2 vehicles. What would settle it: any Toyota Japan or Toyota Gazoo Racing page-level document showing GRMN Yaris either in the Yaris grade table or on its own model page.

**`Land Cruiser Active 2.8D` (1 veh).** "Active" is not a grade on any Land Cruiser spec sheet I opened. The **2.8 D** engine is the 250/Prado/70-series unit, **not** the Land Cruiser 300's (which is 3.3 diesel / 3.5 petrol), so the displacement token actively argues *against* folding this to the flagship `toyota/land-cruiser`. It could be a 250, a 70 or a non-Japanese-market grade, and I could not determine which. **UNRESOLVED**, 1 vehicle.

### Grade strings I folded on but could NOT source at page level (Tier B detail)

These rows are folded because the string leads with a published nameplate and no published record contradicts the fold — **not** because I sourced the grade. Listed here so the manager can see exactly what is unverified:

| unsourced grade string | rows affected | why unsourceable |
|---|---|---|
| Alphard `S C Package`, `G F Package`, `SR C Package`, `X` | 14, 15, 20, 22, 32, 54 (325 veh) | 30-series Alphard (2015–2023); `toyota.jp/alphard/prev/` and `/alphardhybrid/` both 404 |
| Vellfire `Z G Edition`, `2.5ZG Edition`, `250` | 83, 84, 85 (3 veh) | 30-series Vellfire; page retired |
| GR Supra `RZ`, `SZ-R` | 43, 70, 72, 73, 104, 105 (17 veh) | `toyota.jp/grsupra/`, `/supra/`, `/gr_supra/` all 404 — production ended, page retired |
| Land Cruiser 300 `ZX`, `AX`, `GX`, `GR SPORT`, `Sahara` | 33, 36, 38, 51, 53, 88, 89, 90, 93, 94 (56 veh) | https://toyota.jp/landcruiser300/grade/ is JavaScript-rendered; grade table not in page source |
| Land Cruiser Prado `TX`, `TX-L`, `TZ-G` | 79, 81, 95, 96 (6 veh) | `toyota.jp/landcruiserprado/` 404 — replaced by the 250 in Japan |
| Swift `GL PLUS`, `GLX Navi` | 40, 59 (14 veh) | previous Thai Swift range; current spec page lists only GL / GL NEXT / GLX |
| Noah petrol `X` | 80 (2 veh) | current spec sheet covers the hybrid range only (S-Z / S-G / S-X) |
| GR86 `Cup Car Basic`, `Ridge Green Limited`, `10th Anniversary`, `Greddy` | 41, 47, 71, 107 (21 veh) | limited-edition / one-make-race specifications, not on the standard grade sheet |

### Method limitations worth stating

- **The session's WebSearch budget (200/200) was exhausted before I began**, so every source in this dossier was reached by **direct URL retrieval**, mostly `curl` with a desktop browser user-agent. Nothing here was found through a search index, and I have marked "opened directly" or "not opened" honestly on every row.
- **toyota.jp renders grade tables in JavaScript.** Page source yields the model name and the linked PDFs but not the grade list. I worked around this by using Toyota's own linked **specification-sheet PDFs**, which are better sources anyway — they are the manufacturer's formal 主要諸元表. Where no PDF was linked (Land Cruiser 300), the grades stayed unsourced and I said so rather than inferring them.
- **toyota.co.th is a Nuxt SPA with a catch-all route**: `/model/<anything>` returns HTTP 200 with a shell. URL existence is therefore *not* evidence on that site, and I did not use it as such — the Hilux findings come from the embedded `window.__NUXT__` product data, which is Toyota's own catalogue.
- **suzuki.co.th has withdrawn the Celerio and Ciaz pages** at their lower-case paths (302 to home). The upper-case paths still serve the live pages; these are Suzuki's own pages, not archive copies. I note the quirk so the URLs can be re-verified.
- I did not use Wikipedia for any verdict in this dossier.

### Kind-blind key review (lane safety rule)

Rename keys are looked up **per make, not per kind**, so every key proposed here also fires on the van, truck and bus catalogs under the same make. I reviewed all 95 proposed keys:

- **`Hilux Travo`** — will fire outside kind=car, and that is **intended**. Thailand registers pickups and cab-chassis in more than one kind; the correct answer is "Hilux" in every kind. The manager measured 236 additional van-kind vehicles moving onto the already-live `van/toyota/hilux`, destroying no id.
- **`Hilux Champ`** — not proposed (REFUSED). Had it been proposed it would have destroyed `van/toyota/hilux-champ` (8,155 veh).
- All other keys are long and model-specific (`Swift Glx 1.2L Cvt`, `Alphard Z 2WD 2.5L`, `Celerio GL Up 1.0L Cvt`, …). **No key is a bare grade word, a bare engine size, or a short generic prefix**, so none can reach another kind's catalog by accident. The shortest are `Crown Z` (3 veh), `Crown Sport` (1), `Alphard X` (5), `Alphard Z` (86), `Jimny XC` (2), `Spacia Custom` (3) and `Wagon R Smile` (refused) — each still carries its full nameplate token, so a match in another kind would be the same vehicle family and the same correct answer.
