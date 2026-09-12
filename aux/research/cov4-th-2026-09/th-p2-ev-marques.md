# TH P2 — Chinese-EV marques and the Thai grade tail (`th_dlt`, kind `car`)

**Researcher:** COV4 lane researcher. **Access date for every URL below: 2026-09-12.**
**Packet:** 44 strings / 6,002 vehicles, plus 5 rows added mid-batch by the manager
(4× Jaecoo, 1× Deepal `L07 S`) and 3 Omoda rows handed over as an open question.

Nothing here was written to the repo. The manager re-derives every line.

---

## 0. The source that carried this batch, and exactly how it was read

Thailand turned out to have a first-class regulator source that I had not expected,
and it carries almost every string in this packet **verbatim**.

**The Thai Excise Department's ECO Sticker register** (`ecosticker.go.th` /
`car.ecosticker.go.th`) is the mandatory pre-sale certification register for every
passenger car sold in Thailand. Its `model` field is the *certified commercial model
designation*, and it matches the DLT register strings in this packet character for
character in many rows — e.g. the register's `BRZ 2.4 RWD EyeSight 6AT`,
`WRX Wagon 2.4 EyeSight AWD CVT`, `FORESTER 2.5i-S AWD CVT`,
`OUTBACK 2.5i-T EyeSight AWD CVT`, `G6 RWD Long Range`, `S05 REEV MAX`, `S07 L`,
`V23 2WD PLAY`, `H6 HEV ULTRA`, `C10 EV`, `B10 Design BEV`, `Eletre S`, `EMEYA R`
are all *exactly* the strings the DLT column contains. That is very strong evidence
that the DLT model column for new registrations is populated from the same
certification record, which makes this register the correct upstream authority for
this packet rather than a secondary source.

**How I read it — stated precisely, because ~35 citations below rest on it.**
The site is a client-rendered single-page app. Each certified vehicle has a
human-facing page at `https://car.ecosticker.go.th/detail/<id>` (I confirmed these
return HTTP 200), but curl cannot render the SPA, so **I did not render those pages
in a browser.** What I did open directly is the register's own public, unauthenticated
JSON API on the same origin, which is the store those pages render:

- listing — `GET https://api-car.ecosticker.go.th/api/v2/landing-page/cars?brand=<brand>&page=<n>&limit=50`
- free-text — `GET https://api-car.ecosticker.go.th/api/v2/landing-page/cars?search=<text>`
- full record — `POST https://api-car.ecosticker.go.th/api/v2/landing-page/compare` with body `{"id":["<id>", …]}` (max 4 ids per call)

Where I write "ECO Sticker #NNNNNN" below, that is the register's own
`eco_sticker_id`, and the per-record page is `https://car.ecosticker.go.th/detail/<id>`
with the `id` given in the evidence blocks.

Two numeric caveats I will not paper over:
- the register's `battery_capacity` field is **amp-hours, not kWh** (it is published
  next to `nominal_voltage`; e.g. Aion UT 500 = 141 Ah × 424.3 V ≈ 60 kWh, which
  matches that car's known pack). I quote it as Ah and never silently convert.
- `driving_range` is the Thai homologation figure. The register does not name the
  test cycle, so I do not assert NEDC/WLTP/CLTC for it.

**Evidence tiers used below**
- **T1** — national regulator (Thai Excise Department ECO Sticker certification register).
- **T2** — the manufacturer's own market website, page-level.
- **T3** — official national distributor / importer website, page-level.
- **T4** — dealer site. Used only as corroboration, never alone.

**Sites that do not exist / could not be opened** (recording these so nobody repeats the work):
`bydauto.co.th`, `gacaion.co.th`, `deepalthailand.com`, `cheryautomobile.co.th`,
`leapmotor.co.th`, `subaru.co.th`, `maxus.co.th` **all return NXDOMAIN** — they are not
live domains, not blocks. `www.leapmotor.com` and `leapmotor-international.com` return
403 to every fetch I tried. `gacaion.com` is a parked GoDaddy for-sale page. The real
addresses I found and used instead are `byd.com/en-th`, `subaru.asia/th/`,
`changan.co.th/th/deepal/*`, `omodajaecoo.co.th`, `gwm.co.th`, `xpeng.co.th`.

---

## 1. Verdict table

`veh` is the packet's vehicle count. `target published name` is the catalog record's
own display name, copied exactly. "how verified" says whether I opened the page itself
or read the regulator API described in §0.

### 1a. Original packet — head (rows 1–14, ≈5,100 vehicles)

| probed_key | veh | verdict | target published name | source URL | tier | how verified |
|---|---:|---|---|---|---|---|
| `X9 Long Range` | 973 | FOLD | X9 | https://xpeng.co.th/x9/ | T2 | opened directly |
| `Ut 500 Premium` | 947 | FOLD | Ut | https://car.ecosticker.go.th/detail/08c2a0e6-b0e0-42bf-ae1a-4eea399db94c | T1 | regulator API (§0) |
| `Seal 5` | 650 | **REFUSE** | — (stays `byd/seal-5`) | https://www.byd.com/en-th/car/seal5dmi | T2 | opened directly |
| `S05 Reev Max` | 602 | FOLD | S05 | https://www.changan.co.th/th/deepal/s05-reev-th/ | T3 | opened directly |
| `V23 2WD Plus` | 321 | FOLD | V23 | https://car.ecosticker.go.th/detail/016949d2-1c24-498f-b260-770868d75e7b | T1 | regulator API (§0) |
| `S07 L` | 319 | FOLD | S07 | https://www.changan.co.th/th/deepal/s07-th/ | T3 | opened directly |
| `H6 HEV Ultra` | 304 | FOLD | H6 | https://www.gwm.co.th/en/models/haval-h6 | T2 | opened directly |
| `X9 Standard Range` | 275 | FOLD | X9 | https://xpeng.co.th/x9/ | T2 | opened directly |
| `G6 Rwd Long Range` | 263 | FOLD | G6 | https://car.ecosticker.go.th/detail/6ec43a69-a117-42e0-8ff6-f888228f04a5 | T1 | regulator API (§0) |
| `Forester 2.0I-S Es` | 248 | FOLD | Forester | https://car.ecosticker.go.th/detail/9337be4e-fe81-4ced-95e3-864beb1426e2 | T1 | regulator API (§0) |
| `Xv 2.0I-P Es` | 189 | FOLD | Xv | https://www.subaru.asia/th/en/xv/ | T2 | opened directly |
| `S05 Plus` | 177 | FOLD | S05 | https://www.changan.co.th/th/deepal/s05-th/ | T3 | opened directly |
| `Y Plus 490 Premium` | 154 | FOLD | Y Plus | https://car.ecosticker.go.th/detail/2558d4e8-a7d2-4f99-b513-baf08070c26f | T1 | regulator API (§0) |
| `V23 2WD Play` | 136 | FOLD | V23 | https://car.ecosticker.go.th/detail/9c332876-c63b-4692-b812-d888e85d4cd8 | T1 | regulator API (§0) |

### 1b. Rows added mid-batch by the manager (1,982 vehicles)

| probed_key | make | veh | verdict | target published name | source URL | tier | how verified |
|---|---|---:|---|---|---|---|---|
| `C5 EV Long Range Ultimate` | Omoda | 976 | FOLD (see §6 caveat) | Omoda E5 | https://omodaauto.co.uk/omoda-5/?model=e5-electric | T2 | opened directly |
| `6 EV Long Range 2WD Pro` | Jaecoo | 577 | FOLD | Jaecoo 6 | https://www.omodajaecoo.co.th/en/model/jaecoo-6-ev | T3 | opened directly |
| `6 EV Long Range 2WD` | Jaecoo | 371 | FOLD | Jaecoo 6 | https://www.omodajaecoo.co.th/en/model/jaecoo-6-ev | T3 | opened directly |
| `7 Shs Max` | Jaecoo | 352 | FOLD | Jaecoo 7 | https://www.omodajaecoo.co.th/th/model/jaecoo-7-shs | T3 | opened directly |
| `C5 EV Long Range Plus` | Omoda | 115 | FOLD (see §6 caveat) | Omoda E5 | https://omodaauto.co.uk/omoda-5/?model=e5-electric | T2 | opened directly |
| `5 EV Long Range Dynamic` | Jaecoo | 105 | FOLD | Jaecoo 5 | https://www.omodajaecoo.co.th/en/model/jaecoo-5-ev | T3 | opened directly |
| `C5 EV Long Range Dynamic` | Omoda | 33 | FOLD (see §6 caveat) | Omoda E5 | https://omodaauto.co.uk/omoda-5/?model=e5-electric | T2 | opened directly |
| `L07 S` | Deepal | — | FOLD | L07 | https://car.ecosticker.go.th/detail/76117c9d-4828-4503-9a09-4771db05d68e | T1 | regulator API (§0) |

### 1c. Original packet — tail (rows 15–44)

| probed_key | veh | verdict | target published name | source URL | tier | how verified |
|---|---:|---|---|---|---|---|
| `C10 EV` | 96 | FOLD | C10 | https://car.ecosticker.go.th/detail/26a828cb-5bf0-4c3f-b8b3-1d94d2548478 | T1 | regulator API (§0) |
| `Forester 2.0I-L Es` | 90 | FOLD | Forester | https://car.ecosticker.go.th/detail/22d882e7-6178-4849-a8fb-34e40c33dd4e | T1 | regulator API (§0) |
| `Xm 50E Rhd` | 72 | FOLD | XM | https://car.ecosticker.go.th/detail/4ca15955-33e6-4432-9b6c-c06d098fa07c | T1 | regulator API (§0) |
| `Eletre S` | 53 | FOLD | Eletre | https://car.ecosticker.go.th/detail/dfd41df4-1181-4113-b916-a777e3ee8e49 | T1 | regulator API (§0) |
| `Eletre R` | 32 | FOLD | Eletre | https://car.ecosticker.go.th/detail/bc1ae94b-6db1-4644-96dd-fba2214c3229 | T1 | regulator API (§0) |
| `B10 Design Bev` | 25 | FOLD | B10 | https://car.ecosticker.go.th/detail/442a7226-8a53-4597-9c63-cca82a61301d | T1 | regulator API (§0) |
| `H6 HEV Pro` | 18 | FOLD | H6 | https://www.gwm.co.th/en/models/haval-h6 | T2 | opened directly |
| `Forester 2.5I-S` | 9 | FOLD | Forester | https://www.subaru.asia/th/th/how-to-buy/pricing-and-finance.php | T2 | opened directly |
| `Emeya R` | 6 | FOLD | Emeya | https://car.ecosticker.go.th/detail/d7af9040-28dc-4d70-a793-ccbcdccd9c58 | T1 | regulator API (§0) |
| `Outback 2.5I-T Eyesight` | 6 | FOLD | Outback | https://car.ecosticker.go.th/detail/9f177938-dd8e-4faa-bf38-fc0a67a0e519 | T1 | regulator API (§0) |
| `Xv 2.0I-P` | 5 | FOLD | Xv | https://car.ecosticker.go.th/detail/81f7acd1fad441eaaf1d9082c4150171 | T1 | regulator API (§0) |
| `Brz 2.4 Rwd Eyesight 6AT` | 4 | FOLD | Brz | https://car.ecosticker.go.th/detail/73dfb128-4d2b-4db9-90db-fac75c1d473e | T1 | regulator API (§0) |
| `Wrx Wagon 2.4 Eyesight` | 3 | FOLD | Wrx | https://car.ecosticker.go.th/detail/5f60b86f-d47f-4fac-b770-0ef00026e37b | T1 | regulator API (§0) |
| `Brz 2.4 Eyesight Rwd 6AT` | 3 | FOLD | Brz | https://car.ecosticker.go.th/detail/c5719ab7-36e1-4972-977e-60dc0580ad0d | T1 | regulator API (§0) |
| `Wrx 4D 2.4 Eyesight` | 3 | FOLD | Wrx | https://car.ecosticker.go.th/detail/bb4b866b-4b35-4c5d-af68-8d7768886ef0 | T1 | regulator API (§0) |
| `Brz 2.4 Eyesight Rwd 6MT` | 2 | FOLD | Brz | https://car.ecosticker.go.th/detail/05e705aa-ca1f-4192-87e8-3d08d9895abc | T1 | regulator API (§0) |
| `Wrx 4D 2.4` | 2 | FOLD | Wrx | https://car.ecosticker.go.th/detail/9ecb54cc-4720-4418-8682-9369c3053b32 | T1 | regulator API (§0) |
| `Xm Label Rhd` | 2 | FOLD | XM | https://car.ecosticker.go.th/detail/c5c43185-7560-49a5-bdde-104f8e128319 | T1 | regulator API (§0) |
| `Xm Rhd` | 2 | FOLD | XM | https://car.ecosticker.go.th/detail/b18e6b26-7106-4afd-b1ec-a777422c97e5 | T1 | regulator API (§0) |
| `Wrx Sti S207` | 1 | **UNRESOLVED** | — | — | — | see §7 |
| `Wrx Sti S208NBR Challenge` | 1 | **UNRESOLVED** | — | — | — | see §7 |
| `Emira V6 First Edition` | 1 | FOLD | Emira | https://www.lotuscars.com/en-GB/emira | T2 | opened directly |
| `Brz 2.4 Rwd 6MT` | 1 | FOLD | Brz | https://car.ecosticker.go.th/detail/23173ac3-85ef-49e7-8fe1-432865249f92 | T1 | regulator API (§0) |
| `Brz Cup Car Basic` | 1 | **UNRESOLVED** | — | — | — | see §7 |
| `Forester 2.0I-S` | 1 | FOLD | Forester | https://car.ecosticker.go.th/detail/9337be4e-fe81-4ced-95e3-864beb1426e2 | T1 | regulator API (§0) |
| `Wrx S4 Sti Sport R EX` | 1 | FOLD | Wrx | https://www.subaru.jp/wrx/s4/ | T2 | opened directly |
| `Emira I4 First Edition` | 1 | FOLD | Emira | https://www.lotuscars.com/en-GB/emira | T2 | opened directly |
| `T03 400` | 1 | **UNRESOLVED** | — | — | — | see §7 |
| `T03 300` | 1 | **UNRESOLVED** | — | — | — | see §7 |
| `B10 Life Bev` | 1 | FOLD | B10 | https://car.ecosticker.go.th/detail/aecfc824-acdb-4025-8f8d-f0d5cc7711d9 | T1 | regulator API (§0) |

**Totals:** 40 FOLD (7,317 vehicles), 1 REFUSE (650), 5 UNRESOLVED (5).

### What each tail actually is

Per the rule that a licence class / body code / engine designation / model-year code is
not a nameplate, here is the classification for every tail in this packet:

| tail | what it is |
|---|---|
| `500`, `490`, `420`, `410` (Aion) | **battery-range badge, in km** — proven equal to the regulator's own `driving_range` field, §3 |
| `Long Range`, `Standard Range` (XPeng), `Long Range` (Jaecoo/Omoda), `L` (Deepal S07) | **battery-capacity variant** of one nameplate |
| `REEV` (Deepal), `SHS` (Jaecoo), `HEV`/`PHEV` (Haval), `EV`/`BEV` (Leapmotor, Jaecoo, Omoda), `DM-i` (BYD) | **powertrain designation** |
| `2WD`, `4WD`, `RWD`, `AWD` | **drivetrain** |
| `RHD` (BMW) | **drive orientation** — a pure DLT register artifact; never appears in BMW's or the regulator's model name |
| `50e` (BMW) | **powertrain/output designation** |
| `2.0i-S`, `2.0i-L`, `2.0i-P`, `2.5i-S`, `2.5i-T` (Subaru) | **displacement + grade letter** |
| `ES` / `EyeSight` (Subaru) | **driver-assistance package**, §4 |
| `6MT`, `6AT`, `CVT`, `4D`, `Wagon` (Subaru) | **transmission / body code** |
| `V6`, `I4` (Lotus Emira) | **engine designation** |
| `Premium`, `Dynamic`, `Standard`, `Plus`, `Max`, `Lite`, `Ultra`, `Pro`, `Play`, `Peak`, `Style`, `Design`, `Life`, `Ultimate`, `Executive`, `Luxury`, `S`, `R`, `First Edition`, `Label` | **trim / grade** |

---

## 2. XPeng — X9 and G6 (1,511 vehicles)

**Maker pages, opened directly.** XPeng Thailand publishes exactly three model pages
(`https://www.xpeng.co.th/`): **G6**, **X9** and **L03**. There is one X9 page and one
G6 page — no separate "X9 Long Range" or "G6 Long Range" model.

- `https://xpeng.co.th/x9/` — `<title>X9 Ultra Coupe MPV | XPENG Thailand</title>`.
  The page describes the X9 as the "Ultra Smart Coupe MPV", 7 seats, three rows,
  2,554 L maximum luggage volume, 5.4 m turning radius / 10.8 m minimum turning
  diameter, 90 mm adjustable dual-chamber air suspension, active rear-wheel steering,
  21.4″ infotainment display, an 800 V silicon-carbide platform, 330 kW peak charging
  and a 10–80 % charge in 20 minutes. It quotes "up to 702 km (NEDC) or 590 km (WLTP)",
  16.2 kWh/100 km, 235 kW maximum power, 450 N·m maximum torque, 0–100 km/h in 7.7 s.
  The page does **not** print variant names.
- `https://xpeng.co.th/g6/` — `<title>XPENG NEW G6 — Ultra Smart Coupé Electric SUV</title>`.
  Describes the G6 as an "Ultra Smart Coupé Electric SUV": up to 600 km (NEDC),
  0–100 km/h in 4.13 s (AWD), 10–80 % SOC in 12 minutes, 800 V SiC platform,
  5C ultra-fast-charge battery, 2,890 mm wheelbase, 571 L boot (1,374 L seats folded),
  15.6″ touchscreen, 10.25″ driver cluster, 12-way Nappa seats.

**Regulator variant list (T1).** Because the maker pages omit variant names, the
certified variants come from the ECO Sticker register. Every X9 record shares one body
and every G6 record shares one body; only battery, drive and trim move. All records are
certified to **X MOBILITY (THAILAND) CO., LTD.**, built by **Zhaoqing Xiaopeng
Investment of New Energy Co., Ltd.**

X9 — body `MPV`, 7 seats, tyre 235/50R20:

| certified model | L×W×H (mm) | weight | battery | motor(s) | range | consumption | price THB | MY | ECO # | id |
|---|---|---|---|---|---|---|---|---|---|---|
| X9 PREMIUM | 5316×1988×1785 | 2850 | 139 Ah LFP, 683.0 V, CALB | PMSM | 620.0 km | 173 Wh/km | 2,399,000 | 2026 | 026632 | `95cea6bd-bfec-4b0e-a9a2-222c3a079a1d` |
| X9 EXECUTIVE | 5316×1988×1785 | 2795 | 166 Ah NCM, 663.5 V, CALB | PMSM | 715.0 km | 171 Wh/km | 2,599,000 | 2026 | 026633 | `f6ec3e76-718e-44c2-b882-15447903e145` |
| X9 LUXURY | 5293×1988×1785 | 2660 | 159 Ah NCM/graphite, 638.6 V, XPENG | PMSM | 690.0 km | 168 Wh/km | 2,749,000 | 2025 | 026227 | `b364080b-ecc4-42d0-8bbe-548037e5a5f6` |
| X9 LUXURY AWD | 5316×1988×1785 | 2845 | 166 Ah NCM, 663.5 V, CALB | front PMSM + rear AC async | 670.0 km | 182 Wh/km | 2,799,000 | 2026 | 026634 | `abc55c58-c14e-4c8d-b0e4-4bdbab8d131a` |

G6 — body classified `Station Wagon` by the Thai excise scheme (XPeng markets it as a
coupé SUV; both are recorded here), 5 seats, tyre 255/45R20:

| certified model | L×W×H (mm) | weight | battery | motor(s) | range | consumption | price THB | MY | ECO # | id |
|---|---|---|---|---|---|---|---|---|---|---|
| G6 RWD Standard Range | 4758×1920×1650 | 2140 | 139 Ah LFP, 492.9 V, CALB | PMSM | 540.0 km | 147 Wh/km | 1,189,000 | 2026 | 026631 | `40988a2a-0129-477a-a069-75b26b9de103` |
| G6 RWD Long Range | 4758×1920×1650 | 2190 | 139 Ah LFP, 581.4 V, CALB | PMSM | 600.0 km | 156 Wh/km | 1,349,000 | 2026 | 026630 | `6ec43a69-a117-42e0-8ff6-f888228f04a5` |
| G6 AWD Performance | 4758×1920×1650 | 2295 | 139 Ah LFP, 581.4 V, CALB | front AC async + rear PMSM | 575.0 km | 163 Wh/km | 1,489,000 | 2026 | 026629 | `a3cd3664-2618-48a5-99fa-011d6eb568f6` |
| G6 Standard Range | 4753×1920×1650 | 2025 | 129 Ah LFP, 512.0 V, XPENG | PMSM | 505.0 km | 162 Wh/km | 1,439,000 | 2024 | 021928 | `ec196398-f75a-4998-b7e5-8b26e8934945` |
| G6 Long Range | 4753×1920×1650 | 2025 | 159 Ah NMC, 550.5 V, XPENG | PMSM | 625.0 km | 162 Wh/km | 1,599,000 | 2024 | 021927 | `84398563-30a0-4901-8123-3cfc7785b4c5` |

**Conclusion.** `G6 Rwd Long Range` is the regulator's certified designation for the G6,
character for character — "RWD" is the drivetrain and "Long Range" is the larger-battery
variant of the same 4758×1920×1650 car. For the X9, "Standard Range" and "Long Range"
are the same kind of battery designation: within one 5316×1988×1785 seven-seat MPV the
packs run 139 Ah LFP (620 km) up to 166 Ah NCM (715 km). **FOLD all three onto X9 / G6.**
The DLT variants `X9 LONG RANGE(EXECUTIVE)` and `X9 LONG RANGE(LUXURY)` simply pair the
battery designation with the trim names EXECUTIVE and LUXURY that the regulator lists.

---

## 3. GAC Aion — the number *is* the range, and this is measurable

This is the cleanest proof in the packet, because the regulator publishes the homologated
range in a separate field and it **equals the badge exactly**.

| certified model | `driving_range` | body | L×W×H (mm) | weight | battery | consumption | price THB | MY | ECO # | id |
|---|---|---|---|---|---|---|---|---|---|---|
| AION UT 420 STANDARD | **420.0 km** | Hatchback (5-door) | 4270×1850×1575 | 1625 | 143 Ah LFP, 352.0 V, CALB | 133 Wh/km | 675,000 | 2025 | 026600 | `23567046-7bf9-4517-aaba-4e0ef8aa0947` |
| AION UT 500 PREMIUM | **500.0 km** | Hatchback (5-door) | 4270×1850×1575 | 1775 | 141 Ah LFP, 424.3 V, CALB | 140 Wh/km | 755,000 | 2025 | 026601 | `08c2a0e6-b0e0-42bf-ae1a-4eea399db94c` |
| AION Y Plus 410 Premium | **410.0 km** | Station Wagon | 4535×1870×1650 | 1690 | 172 Ah LFP, 294.4 V, EVE Power | 145 Wh/km | 859,900 | 2024 | 022691 | `9d818c38-a8c6-4bfb-b915-8c1de68264d1` |
| AION Y PLUS 490 PREMIUM | **490.0 km** | Station Wagon | 4535×1870×1650 | 1770 | 177 Ah LFP, 345.6 V, CALB; motor TZ180XS127 | 139 Wh/km | 995,900 | 2024 | 023044 | `2558d4e8-a7d2-4f99-b513-baf08070c26f` |
| AION Y PLUS (2023, no number) | 490 km | SUV | 4535×1870×1650 | 1750 | 169 Ah Li-ion, 374.4 V, EVE Power; motor TZ184XYA2001 | 139 Wh/km | 1,069,900 | 2023 | 019552 | `248f28a2-fbf1-44f8-80ac-e0b8802d33c7` |

Corroborating the same habit on a third Aion nameplate, which rules out coincidence:
**AION V 500 PREMIUM** → `driving_range` **500.0 km** (4605×1854×1686, 214 Ah LFP,
301.4 V, 144 Wh/km, 869,900 THB, ECO #026766) and **AION V 602 LUXURY** →
`driving_range` **602.0 km** (4605×1876×1686, 214 Ah LFP, 351.7 V, 141 Wh/km,
1,029,900 THB, ECO #024300). A "602" badge is not a plausible generation or series
number; it is a range figure, and the regulator confirms it to the decimal.

All Aion records are certified to **AION AUTOMOBILE SALES (THAILAND) CO., LTD.**;
the UT, V and the 2024 Y Plus 490 are built at Aion's own Thai plant
(บริษัท ไอออน ออโตโมบิล แมนูแฟคเจอริ่ง (ประเทศไทย) จำกัด), while the Y Plus 410 and the
2023 Y Plus came from GAC Motor Co., Ltd. in China. Excise rate 2 % (BEV), CO₂ 0 g/km.

**Conclusion.** In `Ut 500 Premium` and `Y Plus 490 Premium`, the number is a
**battery-range badge in km** and `Premium` is a trim. Both fold. **FOLD → Ut, Y Plus.**

*Source limitation, stated honestly:* GAC Aion has no reachable official Thai brand site —
`gacaion.co.th` and `aionthailand.com` are NXDOMAIN and `gacaion.com` is a parked
for-sale page. `aionthai.com` exists but is a dealer/event site
(`https://www.aionthai.com/event-aion-ut-1/` is a test-drive event page, not a model
page) and I did not rely on it. The Aion verdicts rest on T1 regulator evidence alone —
which here is the stronger source anyway, because it is the one that publishes the
range figure the badge encodes.

---

## 4. Subaru — grade letters, EyeSight, and one perfect natural experiment

**Maker pages, opened directly.** Subaru Thailand is alive, but not where you would
look: `subaru.co.th` is NXDOMAIN. The distributor (Tan Chong's Motor Image) serves
Thailand from **`https://www.subaru.asia/th/th/`**, with model pages at
`/th/th/forester/`, `/th/th/forester-2025/`, `/th/th/crosstrek/`, `/th/th/brz/`,
`/th/th/outback/` and `/th/en/xv/`.

`https://www.subaru.asia/th/th/how-to-buy/pricing-and-finance.php` prints the current
Thai range with grade names verbatim:

- **All New Forester 2.5 i-S EyeSight** — ฿2,590,000
- **Crosstrek 2.0i-S EyeSight** — ฿2,350,000
- **WRX 2.4 MT** — ฿2,875,200 · **WRX 2.4 CVT EyeSight** — ฿2,975,200 · **WRX Wagon 2.4 CVT EyeSight** — ฿2,895,200
- **BRZ 2.4 RWD EyeSight 6MT** — ฿2,483,000 · **BRZ 2.4 RWD EyeSight 6AT** — ฿2,583,800

`https://www.subaru.asia/th/en/xv/` lists **"XV 2.0 iS EyeSight"** (฿1,299,000) and
**"XV 2.0 iS EyeSight GT Edition"** (฿1,389,000) — the XV's own model page, using the
same "2.0i-<letter> + EyeSight" grade scheme as the register's `XV 2.0i-P ES`.
`https://www.subaru.asia/my/en/forester/` lists **"Forester 2.0i-S EyeSight"** and
**"Forester 2.0i-S EyeSight GT Edition"**, which sources the `2.0i-S` grade directly.
`https://www.subaru.asia/th/en/forester/` describes EyeSight as
"Subaru's Latest EyeSight Technology", a driver-assistance system, alongside
Symmetrical All-Wheel Drive with X-MODE, 220 mm ground clearance, 18″ alloys,
11.6″ touchscreen with wireless CarPlay/Android Auto, 10-way power driver's seat.

**The natural experiment that settles `ES`.** The regulator holds the *same grade* of the
*same car* both with and without the suffix:

| certified model | year | L×W×H (mm) | weight | tyre | CO₂ | urban / ex-urban | price THB | ECO # | id |
|---|---|---|---|---|---|---|---|---|---|
| **XV 2.0i-P** | 2017 | 4465×1800×1615 | 1439 | 225/60R17 | 162 g/km | 9.2 / 5.7 | 990,000 | 009988 | `81f7acd1fad441eaaf1d9082c4150171` |
| **XV 2.0i-P ES** | 2021 | 4485×1800×1615 | 1440 | 225/60R17 | 172 g/km | 9.9 / 5.7 | 1,055,000 | 014031 | `9d1fdc40ccf54776b0fb1e8a9ee0c35b` |

Same nameplate, same 1,995 cc petrol boxer, same CVT, same grade letter `P`, same tyre.
The only difference in the certified model name is `ES` — and Subaru's own pages spell
that suffix out as **EyeSight** on the sibling grades. `ES` is a driver-assistance
package, not a nameplate. The same pairing appears on the Forester:

| certified model | L×W×H (mm) | weight | tyre | CO₂ | urban / ex-urban | price THB | ECO # | id |
|---|---|---|---|---|---|---|---|---|
| Forester **2.0i-L** ES | 4640×1815×1730 | 1538 | 225/60R17 | 181 g/km | 9.8 / 6.3 | 1,185,000 | 016504 | `22d882e7-6178-4849-a8fb-34e40c33dd4e` |
| Forester **2.0i-S** ES | 4640×1815×1730 | 1541 | 225/55R18 | 181 g/km | 9.8 / 6.3 | 1,285,000 | 016505 | `9337be4e-fe81-4ced-95e3-864beb1426e2` |

Identical body, identical engine, identical emissions — `L` and `S` differ only in wheel
size and equipment. These are grade letters. Both fold to **Forester**.

**The rest of the Subaru harvest** (all certified to TC Subaru (Thailand) Co., Ltd.
unless noted; the 2.0i-x cars were assembled by Tan Chong in Thailand or Malaysia,
everything current comes from Subaru Corporation's Gunma plants):

| certified model | body | L×W×H (mm) | weight | cc | gearbox | CO₂ | price THB | ECO # | id |
|---|---|---|---|---|---|---|---|---|---|
| FORESTER 2.5i-S AWD CVT | SUV | 4655×1830×1730 | 1668 | 2498 | CVT | — | 2,590,000 | 026210 | `b6d3da0a-2c80-42b7-b268-fa8420e87308` |
| OUTBACK 2.5i-T EyeSight AWD CVT | SUV | 4870×1875×1675 | 1682 | 2498 | CVT | — | 2,565,200 | 023953 | `9f177938-dd8e-4faa-bf38-fc0a67a0e519` |
| CROSSTREK 2.0i-S ES AWD CVT | SUV | 4480×1800×1600 | 1423 | 1995 | CVT | 170 g/km | 2,350,000 | 026477 | `b1da8d6f-7366-4a4d-be12-f47d2f98262f` |
| WRX 4D 2.4 EyeSight AWD CVT | Sedan | 4670×1825×1465 | 1581 | 2387 | CVT | 192 g/km | 2,975,200 | 026263 | `bb4b866b-4b35-4c5d-af68-8d7768886ef0` |
| WRX 4D 2.4 EyeSight AWD 6MT | Sedan | 4670×1825×1465 | 1513 | 2387 | 6MT | 225 g/km | 2,875,200 | 026262 | `3edea8ad-42b9-486c-9202-d5aa27a81566` |
| WRX 4D 2.4 AWD 6MT | Sedan | 4670×1825×1465 | 1513 | 2387 | 6MT | 225 g/km | 2,875,200 | 016717 | `9ecb54cc-4720-4418-8682-9369c3053b32` |
| WRX Wagon 2.4 EyeSight AWD CVT | Station Wagon | 4755×1795×1500 | 1614 | 2387 | CVT | 192 g/km | 2,895,200 | 026264 | `5f60b86f-d47f-4fac-b770-0ef00026e37b` |
| BRZ 2.4 EyeSight RWD 6AT | Coupe | 4265×1775×1310 | 1310 | 2387 | 6AT | — | 2,483,800 | 026308 | `c5719ab7-36e1-4972-977e-60dc0580ad0d` |
| BRZ 2.4 RWD EyeSight 6AT | Coupe | 4265×1775×1310 | 1310 | 2387 | 6AT | 201 g/km | 2,433,800 | 017200 | `73dfb128-4d2b-4db9-90db-fac75c1d473e` |
| BRZ 2.4 EyeSight RWD 6MT | Coupe | 4265×1775×1310 | 1289 | 2387 | 6MT | 217 g/km | 2,483,800 | 026265 | `05e705aa-ca1f-4192-87e8-3d08d9895abc` |
| BRZ 2.4 RWD 6MT | Coupe | 4265×1775×1310 | 1289 | 2387 | 6MT | 217 g/km | 2,283,800 | 017201 | `23173ac3-85ef-49e7-8fe1-432865249f92` |

Note that `BRZ 2.4 EyeSight RWD 6AT` and `BRZ 2.4 RWD EyeSight 6AT` are **the same car
with the word order swapped between two certifications** — which is exactly why the
pipeline sees them as two junk slugs. Every BRZ shares one 4265×1775×1310 coupe body;
every WRX sedan shares one 4670×1825×1465 body. The `4D` / `Wagon` tokens are body
codes and `6MT`/`6AT`/`CVT` are transmissions.

`Wrx S4 Sti Sport R EX` is sourced separately on **Subaru Japan's own WRX S4 page**,
`https://www.subaru.jp/wrx/s4/`, which lists the Japanese grades **GT-H EX**,
**STI Sport R EX**, **STI Sport R-Black Limited** and **STI Sport R-Black Limited Ⅱ**
(¥4,477,000 / ¥5,027,000 / ¥5,302,000 / ¥5,302,000), all 2.4 L direct-injection
turbo boxer, Subaru Performance Transmission, AWD, 10.7 km/L WLTC. **"STI Sport R EX"
is a grade of the WRX S4**, so the string folds to **Wrx**.

---

## 5. Deepal, Chery, Haval, Leapmotor, BMW, Lotus

### 5a. Deepal S05 / S07 / L07 — and the REEV trap, examined and dismissed

**The trap is real and I looked at it properly.** Changan Thailand publishes what look
like two S05 pages: `https://www.changan.co.th/th/deepal/s05-th/` and
`https://www.changan.co.th/th/deepal/s05-reev-th/`. Under the "separate model page =
separate nameplate" rule that is worth stopping for. It does **not** hold here, for two
reasons, both checked:

1. **Both pages name the car "Deepal S05".** I opened both. The BEV page's own copy
   uses the variant name **"DEEPAL S05 BEV Plus"** and **"S05 Max Long Range"**; the REEV
   page repeats "Deepal S05" throughout and adds "REEV". So the maker's own naming is
   `S05` + a powertrain token (`BEV` / `REEV`) + a trim — not two model names. The two
   URLs are powertrain landing pages within one nameplate.
2. **The regulator shows one physical car.** Every S05 record, BEV and REEV alike, is
   certified at **4620 × 1900 × 1600 mm, 5 seats, SUV**. That is the opposite of the
   Onix / Onix Plus situation, where the two model pages described cars of different
   length and boot volume.

All S05/S07/L07 records are certified to **CHANGAN AUTO SALES (THAILAND) CO., LTD.**

S05 — SUV, 4620×1900×1600, 5 seats:

| certified model | powertrain | cc | battery | range | consumption | CO₂ | weight | tyre | price THB | MY | ECO # | id |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| S05 LITE | BEV | — | 148 Ah LFP, 379.0 V | 470.0 km | 158 Wh/km | 0 | 1777 | 225/60R18 | 799,000 | 2025 | 023903 | `52035a1f-860a-4307-ba05-67cb4460a78f` |
| S05 PLUS | BEV | — | 148 Ah LFP, 379.0 V | 470.0 km | 150 Wh/km | 0 | 1770 | 225/60R18 | 849,000 | 2026 | 027001 | `d7af13d3-7893-4d99-9550-2e80cf66105e` |
| S05 MAX | BEV | — | 148 Ah LFP, 379.0 V | 470.0 km | 150 Wh/km | 0 | 1770 | 225/60R18 | 899,000 | 2026 | 027002 | `685670fd-8efe-42da-89a5-9feabdc6eb42` |
| S05 MAX LONG RANGE | BEV | — | 181 Ah LFP, 379.0 V | 560.0 km | 152 Wh/km | 0 | 1856 | 245/45R20 | 999,000 | 2026 | 026637 | `013a5796-a70b-4c75-8e5e-d2387df74c0d` |
| S05 REEV PLUS | PHEV/REEV | 1497 | 87 Ah Li-ion, 314.0 V | 180.0 km EV | 151 Wh/km | 14 g/km | 1847 | 225/60R18 | 949,000 | 2025 | 024243 | `a05ae9fe-e9ac-4609-b752-6066a1151085` |
| S05 REEV MAX | PHEV/REEV | 1497 | 87 Ah LFP (CATL), 314.0 V | 180 km EV | 151 Wh/km | 14 g/km | 1840 | 225/60R18 | 999,000 | 2026 | 026653 | `8c7ac610-7ae7-45a4-980e-aea86d46784b` |

The REEV cars are certified with a 1,497 cc petrol unit and a 3-speed automatic and are
classed `PHEV` by the regulator; combined fuel consumption 0.6 L/100 km on the REEV PLUS.
Both the BEV and REEV S05 are built in Thailand
(บริษัท ฉางอาน ออโต้ เซ้าท์อีส เอเชีย จำกัด).

S07 — 4750×1930×1625, 5 seats, tyre 255/45R20, all BEV, built by Chongqing Chang'an:

| certified model | battery | range | consumption | weight | price THB | year/MY | ECO # | id |
|---|---|---|---|---|---|---|---|---|
| S07 | 169 Ah NCM/graphite, 395 V | 485 km | 158 Wh/km | 1940 | 1,399,000 | 2023 | 019828 | `aaf8d8bd-5e11-4c2d-8a66-1368dc6c21d9` |
| **S07 L** | 227 Ah Li-ion, 352 V | 560 km | 163 Wh/km | 2025 | 1,499,000 | 2025 / MY2024 | 023218 | `afcb91d9-e74c-47d7-a1a6-a2e9db6c333f` |
| NEW S07 | 182 Ah Li-ion (CATL), 379 V | 485.0 km | 158 Wh/km | 2025 | 1,219,000 | 2025 | 026017 | `544599a5-89eb-4c0e-8e4c-1d27c49efa4d` |

`S07 L` is the long-range battery variant (227 Ah / 560 km vs 169 Ah / 485 km) of the
identical 4750×1930×1625 body. Changan Thailand's own S07 page writes it
**"Deepal S07 L"** and **"Deepal S07L"**. **FOLD → S07.**

L07 — 4820×1890×1480 **Sedan**, 5 seats, tyre 245/45R19, BEV, Chongqing Chang'an:

| certified model | battery | range | consumption | weight | price THB | year/MY | ECO # | id |
|---|---|---|---|---|---|---|---|---|
| L07 | 169 Ah NCM/graphite, 395 V | 540.0 km | 141 Wh/km | 1820 | 1,329,000 | 2023 | 019827 | `e67385c8-9bd3-4c15-a5d1-68ad62e801ee` |
| **L07 S** | 163 Ah Li-ion (CATL), 360 V | 475 km | 139 Wh/km | 1870 | 1,239,000 | 2025 / MY2024 | 023219 | `76117c9d-4828-4503-9a09-4771db05d68e` |

Identical body to the millimetre, identical seats and tyre. `S` is a grade with a
smaller pack (163 Ah / 475 km) at a lower price — a trim, not a model. **FOLD → L07.**

### 5b. Chery V23 (457 vehicles)

All three V23 records share one body: **SUV, 4220 × 1915 × 1845 mm, 4 seats**, certified
to **OMODA & JAECOO (THAILAND) CO., LTD.**, built by Chery Automobile Co., Ltd.

| certified model | drivetrain | battery | range | consumption | weight | tyre | price THB | ECO # | id |
|---|---|---|---|---|---|---|---|---|---|
| V23 2WD PLAY | 2WD | 164 Ah LFP, 366.5 V | 360.0 km | 200 Wh/km | 1710 | 255/55R19 | 699,900 | 024713 | `9c332876-c63b-4692-b812-d888e85d4cd8` |
| V23 2WD PLUS | 2WD | 164 Ah LFP, 366.5 V | 360.0 km | 200 Wh/km | 1710 | 255/55R19 | 769,900 | 026365 | `016949d2-1c24-498f-b260-770868d75e7b` |
| V23 4WD PEAK | 4WD | 237 Ah ternary Li-ion/graphite, 344.9 V | 430.0 km | 220 Wh/km | 1820 | 265/45R21 | 929,900 | 026757 | `32e97205-0266-49ab-80e6-393370dd7b3b` |

PLAY and PLUS are mechanically **identical** — same pack, same voltage, same range, same
weight, same tyre — and differ only in price and equipment. That is the definition of a
trim pair. PEAK adds four-wheel drive and a larger pack. Corroborated (T4) by the Thai
Chery retail site `https://www.cheryth.com/chery-v23`, which lists
**V23 PLAY / V23 PLUS / V23 PEAK** and 2WD/4WD on one V23 page.
**FOLD both → V23.** `2WD` is drivetrain; `Play` and `Plus` are trims.

### 5c. Haval H6 (322 vehicles)

**Maker page, opened directly:** `https://www.gwm.co.th/en/models/haval-h6` — one model
page for the "GWM Haval H6", billed as a "SMART SUV FOR THE MODERN JOURNEY". The page
**explicitly presents HEV and PHEV as powertrains of the same H6**, with trims listed as
**HEV Pro**, **PHEV Pro** and **PHEV Ultra**, from ฿899,000 (HEV, MSRP ฿969,000) and
฿959,000 (PHEV, MSRP ฿1,089,000).

Regulator corroboration — one body, 4683 × 1886 × 1730 mm, 5 seats, 1,499 cc, CVT,
all certified to and built by **GREAT WALL MOTOR MANUFACTURING (THAILAND) CO., LTD.**:

| certified model | type | fuel | battery | EV range | CO₂ | combined | weight | tyre | price THB | ECO # | id |
|---|---|---|---|---|---|---|---|---|---|---|---|
| H6 HEV PRO | HEV | petrol E20 | — | — | 120 g/km | 5.2 L/100 km | 1690 | 225/55R19 | 999,000 | 023575 | `9c4de1fd-5bf8-4901-91af-4f51d4d06ff9` |
| H6 HEV ULTRA | HEV | petrol | — | — | 120 g/km | 5.2 L/100 km | 1690 | 225/55R19 | 1,349,000 | 016689 | `ffc0a649-ce6c-4224-9bd3-a20697d3492c` |
| H6 PHEV ULTRA | PHEV | petrol | 110 Ah NCM/graphite, 309.1 V | 201.7 km | 12 g/km | — | 1881 | 235/55R19 | 1,699,000 | 016690 | `900c5944-58eb-45d2-a47d-481b0214c66e` |

`HEV` is a powertrain; `Pro` and `Ultra` are trims. **FOLD both → H6.**

### 5d. Leapmotor C10 and B10 (122 vehicles)

Certified to **PHRA NAKORN AUTOMOBILE COMPANY LIMITED**, built by Leapmotor Automobile
Co., Ltd. All SUV, 5 seats, BEV.

| certified model | L×W×H (mm) | weight | battery | range | consumption | tyre | price THB | MY | ECO # | id |
|---|---|---|---|---|---|---|---|---|---|---|
| C10 EV | 4739×1900×1680 | 2055 | 210 Ah LFP/graphite, 332.8 V | 477.0 km | 167 Wh/km | 245/45R20 | 1,098,000 | 2024 | 022801 | `26a828cb-5bf0-4c3f-b8b3-1d94d2548478` |
| C10 EV STYLE | 4739×1900×1680 | 2055 | 210 Ah LFP/graphite, 332.8 V | 477.0 km | 167 Wh/km | 235/55R18 | 978,000 | 2025 | 023912 | `e8acdff3-bce4-4a0e-b4a3-8377cd71787a` |
| B10 Life BEV | 4515×1885×1655 | 1855 | 139 Ah LFP/graphite, 404.4 V | 442.0 km | 140 Wh/km | — | 698,000 | 2025 | 024934 | `aecfc824-acdb-4025-8f8d-f0d5cc7711d9` |
| B10 Style BEV | 4515×1885×1655 | — | — | — | — | — | 758,000 | 2025 | — | `88af499b-6f47-4871-846f-c69fae0dde45` |
| B10 Design BEV | 4515×1885×1655 | 1920 | 166 Ah LFP/graphite, 404.4 V | 516.0 km | 141 Wh/km | — | 798,000 | 2025 | 024936 | `442a7226-8a53-4597-9c63-cca82a61301d` |

One C10 body and one B10 body. `Life` / `Style` / `Design` are a three-step trim ladder
on the B10. `EV` and `BEV` are powertrain tags — Leapmotor uses them to distinguish from
its REEV line, and only the BEV C10 is certified in Thailand. **FOLD → C10, B10.**

*Caveat, stated rather than glossed:* I could **not** open any Leapmotor page. All of
`leapmotor.co.th`, `leapmotorthailand.com` and the Thai importer's domains are NXDOMAIN,
and `www.leapmotor.com` / `leapmotor-international.com` return 403 to every fetch. The
claim that the C10 also exists as a REEV elsewhere is therefore **not sourced by me**;
the fold does not depend on it, because it rests on one C10 body carrying two certified
trims in the Thai register.

### 5e. BMW XM — and the RHD artifact (76 vehicles)

All three XM records share **one body: 5110 × 2005 × 1755 mm, 5 seats**, the **same
93 Ah / 316.8 V lithium-ion pack**, the same 8-speed automatic and the same plant
(**BMW MANUFACTURING CO., LLC**, Spartanburg), certified to **BMW (Thailand) Company Limited**:

| certified model | cc | type | EV range | consumption | CO₂ | weight | price THB | ECO # | id |
|---|---|---|---|---|---|---|---|---|---|
| XM 50e | 2998 | PHEV | 101.0 km | 252 Wh/km | 44 g/km | 2620 | 6,679,000 | 026093 | `4ca15955-33e6-4432-9b6c-c06d098fa07c` |
| XM | 4395 | PHEV | 98 km | 286 Wh/km | 54 g/km | 2710 | 14,649,000 | 017199 | `b18e6b26-7106-4afd-b1ec-a777422c97e5` |
| XM Label Red | 4395 | PHEV | 96.0 km | 263 Wh/km | 54 g/km | 2720 | 17,199,000 | 019752 | `c5c43185-7560-49a5-bdde-104f8e128319` |

`50e` is BMW's powertrain/output designation (the inline-six PHEV, against the V8 in the
plain XM and the Label). **`RHD` appears nowhere in BMW's or the regulator's model name.**
It is present only in the DLT column — a **drive-orientation artifact of the register**,
and by the standing rule a drive orientation is never part of a nameplate.
**FOLD all three → XM.**

*One honest ambiguity on `Xm Label Rhd` (2 vehicles):* the regulator's certified name is
**"XM Label Red"**, not "XM Label". The DLT string may be that name mis-transcribed, or
"XM Label" plus the RHD suffix. Either reading lands on the XM nameplate, so the fold is
safe, but the manager should know the token is not a clean match.

### 5f. Lotus — Eletre, Emeya, Emira (93 vehicles)

All Lotus records are certified to **Pacific Thai Motorsports co., ltd**.

**Eletre** — one body, SUV, 5103 × 2019 × 1630–1636 mm, 5 seats, 158 Ah / 718.1 V pack,
built by Zhejiang Geely Automobile Co., Ltd. (Wuhan Branch):

| certified model | weight | range | consumption | price THB | year/MY | ECO # | id |
|---|---|---|---|---|---|---|---|
| ELETRE 600 | 2565 | 600.0 km | 214 Wh/km | 5,365,000 | 2025/2026 | 024951 | `0f593118-4a97-43aa-acf4-64ccde4ba5f2` |
| **Eletre S** | 2645 | 490.0 km | 255 Wh/km | 6,425,000 | 2025/2024 | 023810 | `dfd41df4-1181-4113-b916-a777e3ee8e49` |
| **Eletre R** | 2725 | 410.0 km | 307 Wh/km | 7,460,000 | 2023/2024 | 023763 | `bc1ae94b-6db1-4644-96dd-fba2214c3229` |
| ELETRE 900 Sport | 2745 | 500.0 km | 254 Wh/km | 7,984,000 | 2025/2026 | 025368 | `67673f15-6061-43b7-a884-2b3ccd9bc3a0` |

**Emeya** — one body, Sedan, 5139 × 2005 × 1459 mm, 5 seats, 146 Ah / 705 V pack,
built by Zhejiang Geely Automobile Co., Ltd.:

| certified model | weight | range | consumption | price THB | ECO # | id |
|---|---|---|---|---|---|---|
| EMEYA 600 | 2555 | 610.0 km | 177 Wh/km | 5,114,000 | 026663 | `59706bc8-f0fa-4afc-874d-1e8ed942ed74` |
| EMEYA S | 2555 | 540 km | 204 Wh/km | 7,417,000 | 023478 | `bf526674-fb36-4f35-b6d4-ddc0af6f2c8d` |
| **EMEYA R** | 2650 | 464 km | 241 Wh/km | 7,790,000 | 023985 | `d7af9040-28dc-4d70-a793-ccbcdccd9c58` |

`S` and `R` are Lotus grade letters on one Eletre body and one Emeya body. Lotus's own
current UK pages (`https://www.lotuscars.com/en-GB/eletre`,
`https://www.lotuscars.com/en-GB/emeya`, both opened directly) show the **same single
model line under a renamed grade ladder** — "Eletre 600" (600+ bhp, up to 373 miles)
and "Eletre 900" (900+ bhp, up to 319 miles); "Emeya 600" (600+ hp, up to 379 miles) and
"Emeya 900" (900+ hp, 2-speed transmission) — explicitly described as variants of one
model distinguished by "power output, options and exclusivity". Thailand's register holds
both the older S/R naming and the newer 600/900 naming for the same cars, which is itself
proof they are grades. **FOLD → Eletre, Emeya.**

**Emira** — `https://www.lotuscars.com/en-GB/emira`, opened directly, states the Emira is
offered with a **"4-cylinder single twin scroll turbocharged engine with … 8-speed Dual
Clutch Transmission"** (Turbo / Turbo SE) **and** a **"supercharged 3.5-litre V6 engine
with the coveted 6-speed manual gearbox"** (V6 SE), plus an "Emira 420 Sport" with an
upgraded 2.0 L engine coming Summer 2026. So **`V6` and `I4` are engine designations of
one Emira nameplate.** The Thai register holds `EMIRA` (1,991 cc, 8-speed auto, Coupe,
4413×2092×1226, 2 seats, 1431 kg, 197 g/km CO₂, ฿11,000,000, ECO #022303) and
`EMIRA TURBO SE` (1,991 cc, 8-speed auto, 4413×1896×1235, 1442 kg, 197 g/km,
11.6/6.6 L/100 km urban/ex-urban, ฿11,990,000, ECO #027169). **FOLD → Emira.**

*Caveat:* I did **not** find "First Edition" printed on a Lotus page — that launch-edition
label is unsourced. It does not change the verdict, because both strings resolve to the
Emira nameplate plus a sourced engine designation, but I am not claiming a citation I do
not have.

---

## 6. Jaecoo and Omoda — the rows added mid-batch

**The distributor site, opened directly.** OMODA & JAECOO (THAILAND) CO., LTD. publishes
per-model pages at `https://www.omodajaecoo.co.th/`:
`/th/model/jaecoo-5-ev`, `/th/model/jaecoo-5-ev-ultra`, `/th/model/jaecoo-6-ev`,
`/th/model/jaecoo-6t-ev`, `/th/model/jaecoo-6t-reev`, `/th/model/jaecoo-7-shs`,
`/th/model/new-omoda-c5-ev`. This is the same corporate entity that certifies Chery's
V23, so it is the maker's Thai arm, not a dealer.

### 6a. `7 Shs Max` → Jaecoo 7 — SHS is a powertrain, confirmed on the page's own title

The decisive line is the page's own `<title>`:

> `JAECOO 7 SHS | Super Hybrid System SUV | Thailand | Omoda Jaecoo Thailand`

and its meta description, in Thai:

> `JAECOO 7 SHS ขับเคลื่อนด้วย Super Hybrid System อัจฉริยะ …` — "JAECOO 7 SHS is driven
> by the intelligent Super Hybrid System".

**SHS = Super Hybrid System, a powertrain badge**, exactly parallel to REEV / HEV / DM-i
elsewhere in this packet — not a model line. The page's trim naming is
**"JAECOO 7 SHS Max"**. Regulator corroboration: both Jaecoo 7 records share one body,
**SUV 4500 × 1865 × 1670 mm, 5 seats**, PHEV, 1,499 cc, 54 Ah LFP/graphite at 339.2 V,
106.0 km EV range, 159 Wh/km, 31 g/km CO₂, 1870 kg, 235/50R19, built by
**CHERY CORPORATE MALAYSIA SDN. BHD.** — `7 SHS DYNAMIC` ฿899,000 (ECO #023741,
`4f4da8b7-f514-4d17-80cc-20f27b34f864`) and `7 SHS MAX` ฿999,000 (ECO #023721,
`014eeba9-211d-41ee-ae0d-bd051fff2b2d`). **FOLD → Jaecoo 7.** This is the row that gains
Thailand as a new country on `jaecoo/jaecoo-7`.

### 6b. `6 EV Long Range 2WD Pro` and `6 EV Long Range 2WD` → Jaecoo 6

`https://www.omodajaecoo.co.th/en/model/jaecoo-6-ev` —
`<title>JAECOO 6 EV | 100% Electric Off-Road SUV | Thailand | Omoda Jaecoo Thailand</title>`.
The page's own variant names include **"JAECOO 6 EV 2WD MAX"** and
**"JAECOO 6 EV LONG RANGE 4WD"**. Regulator records, all SUV / 5 seats, certified to
OMODA & JAECOO (THAILAND) CO., LTD.:

| certified model | L×W×H (mm) | weight | battery | range | consumption | tyre | price THB | ECO # | id |
|---|---|---|---|---|---|---|---|---|---|
| 6 EV Long Range 2WD Pro | 4406×1910×1715 | 1850 | 189 Ah Li-ion, 347.0 V | 426.0 km | 185 Wh/km | 225/60R18 | 799,000 | 026895 | `a8426cc0-4b74-4f31-b9f7-6b900d73fd21` |
| 6 EV Long Range 2WD | 4406×1910×1715 | 1850 | 189 Ah Li-ion, 347.0 V | 426.0 km | 185 Wh/km | 225/60R18 | 1,099,000 | 022247 | `6d109de9-8d63-43b3-ba91-3597144dca19` |
| 6 EV 2WD MAX | 4342×1910×1715 | 1850 | 175 Ah LFP, 390.6 V | 455.0 km | 183 Wh/km | 225/60R18 | 859,000 | 026795 | `7c699707-29f2-452e-abba-67d321bd2c66` |
| 6 EV Long Range 4WD | 4406×1910×1715 | 1949 | 175 Ah LFP, 390.6 V | 418.0 km | 194 Wh/km | 225/55R19 | 1,249,000 | 026681 | `907bde4c-4a79-4ea1-b76f-f232b007d539` |

`EV` powertrain, `Long Range` battery variant, `2WD`/`4WD` drivetrain, `Pro`/`Max` trim.
**FOLD both → Jaecoo 6.**

> **Warning the manager should carry forward: the Jaecoo 6T is a DIFFERENT nameplate.**
> Jaecoo Thailand publishes `jaecoo-6t-ev` and `jaecoo-6t-reev` as **separate model
> pages** (`<title>JAECOO 6T EV | Tough Electric Off-Road SUV | Thailand …</title>`),
> and the regulator certifies the 6T at **4433 × 1916 × 1741 mm** against the 6's
> 4406 × 1910 × 1715 — a physically different car (`6T EV Long Range 4WD`, 192 Ah Li-ion
> at 363.0 V, 436.0 km, 1972 kg, 245/55R19, ฿1,099,000, ECO #026387,
> `b034991c-2d64-465a-8992-0a1feaa949ef`). Any `6T …` string must **not** be folded onto
> `jaecoo/jaecoo-6`. None of the four rows in my packet is a 6T, so nothing here is at
> risk — but a prefix rule on "6 " would hit it.

### 6c. `5 EV Long Range Dynamic` → Jaecoo 5

`https://www.omodajaecoo.co.th/en/model/jaecoo-5-ev` —
`<title>JAECOO 5 EV | Electric SUV for Every Lifestyle | Thailand …</title>`, with the
page's own variant names **"JAECOO 5 EV Long Range Max"**, **"JAECOO 5 EV MAX+"** and
**"JAECOO 5 EV ULTRA"**. Regulator, one body, SUV 4380 × 1860 × 1650, 5 seats, 235/55R18:

| certified model | weight | battery | range | consumption | price THB | ECO # | id |
|---|---|---|---|---|---|---|---|
| 5 EV Long Range Dynamic | 1715 | 163 Ah LFP, 360.2 V | 461.0 km | 139 Wh/km | 629,000 | 024621 | `d744d9f3-d393-4ac3-b441-17a022098fed` |
| 5 EV Long Range Max | 1715 | 163 Ah LFP, 360.2 V | 461.0 km | 139 Wh/km | 679,000 | 024629 | `b4529bb4-d813-416b-b272-430b123cc06c` |
| 5 EV MAX+ | 1645 | 138 Ah LFP, 365.9 V | 405.0 km | 138 Wh/km | 699,000 | 026920 | `98c1d7de-79db-4581-b332-69abe657a532` |

Dynamic and Max are mechanically identical and differ by ฿50,000 — a trim pair.
**FOLD → Jaecoo 5.**

### 6d. Omoda `C5 EV …` (1,124 vehicles) — answered: it IS the E5, with a caveat

**The answer: Thai "OMODA C5 EV" is the vehicle we publish as `omoda/omoda-e5`
("Omoda E5"). It is a FOLD onto a live record, not a mint.**

Two pages, both opened directly:

1. **Omoda Thailand** — `https://www.omodajaecoo.co.th/en/model/new-omoda-c5-ev`,
   `<title>The New OMODA C5 EV | Part of Your Tomorrow | Thailand | Omoda Jaecoo Thailand</title>`,
   description "The New OMODA C5 EV – bold design meets advanced EV technology." Its own
   variant names on the page are **"OMODA C5 EV MAX+"**, **"Long Range Max"** and
   **"OMODA C5 EV MAX+ LONG RANGE PLUS"**. So the Thai nameplate is **OMODA C5 EV** and
   Ultimate / Plus / Dynamic / Max / MAX+ are trims.
2. **Omoda's official UK site** — `https://omodaauto.co.uk/omoda-5/?model=e5-electric`.
   The page carries three powertrains, named on the page as **"OMODA 5 Petrol"**,
   **"OMODA E5 Electric"** and **"OMODA 5 SHS-H"**, and prints the dimensions
   **4424 / 1830 / 1588** with a **2630** mm wheelbase.

The Thai regulator certifies every OMODA C5 EV at **4424 × 1830 × 1588 mm**, SUV,
5 seats — an **exact three-way dimensional match** with the UK E5, both BEV, both built
by Chery Automobile Co., Ltd. That is the identity proof.

| certified model | weight | battery | range | consumption | tyre | price THB | MY | ECO # | id |
|---|---|---|---|---|---|---|---|---|---|
| C5 EV Long Range Dynamic | 1785 | 163 Ah LFP/graphite, 360.2 V | 505.0 km | 132 Wh/km | 215/55R18 | 649,000 | 2025 | 023826 | `b7a16f48-6a4d-4a06-b26a-e0604171924b` |
| C5 EV Long Range Max | 1785 | 163 Ah LFP/graphite, 360.2 V | 505.0 km | 132 Wh/km | 215/55R18 | 699,000 | 2025 | 023827 | `bcae3aec-1982-4758-a006-0a92356ba63d` |
| C5 EV Long Range Plus | 1785 | 165 Ah LFP/graphite, 370.0 V | 505.0 km | 129 Wh/km | 215/55R18 | 899,000 | 2024 | 022308 | `ad587ea7-dbd1-46ea-a2a5-8253e1bd2b2a` |
| C5 EV Long Range Ultimate | 1785 | 165 Ah LFP/graphite, 370.0 V | 505.0 km | 129 Wh/km | 215/55R18 | 949,000 | 2024 | 022309 | `c04497f3-ba14-4cba-ae36-3bd40f96ced5` |
| C5 EV MAX+ | — | — | — | — | — | 709,000 | — | — | `d91f0449-05b0-4a9a-8bc3-fe6abe79cfc5` |

(The Thai 505 km and the UK "267 miles WLTP" are different homologation cycles, not a
contradiction.)

Two further points the manager asked for:

- **Is Thai C5 petrol vs C5 EV one nameplate or two?** The question does not arise in
  Thailand: the Thai register contains **no petrol C5 at all** (a `search=C5` over the
  whole register returns only the five BEV rows above), and Omoda Thailand publishes only
  the `new-omoda-c5-ev` model page. So folding these rows onto `omoda/omoda-e5` cannot
  drag a petrol car into the BEV record.
- **This is NOT a mint.** The 1,124 vehicles clear the 1,000 threshold, but they belong
  to a nameplate we already publish, so minting a Thai-only `omoda/c5-ev` would be the
  Onix/Onix Plus error in reverse — splitting one real nameplate in two.

> ### ⚠️ Where my evidence and the catalog disagree — flagged, not resolved by me
> Omoda's **own** UK site does not give the E5 a model page of its own. It is
> `/omoda-5/?model=e5-electric` — one OMODA 5 model page carrying Petrol, E5 Electric and
> SHS-H as three powertrains, exactly the structure I treated as "one nameplate" for
> Deepal S05 BEV/REEV and Haval H6 HEV/PHEV in this same batch. Applied consistently,
> that maker evidence argues `omoda/omoda-5` and `omoda/omoda-e5` are **one** nameplate,
> not two. Our catalog publishes them as two.
>
> I am **not** resolving that, and I am **not** proposing any change to `omoda/omoda-e5`
> or `omoda/omoda-5`. Per the DECISIONS fold safeguard the published records win, and on
> that basis the Thai BEV rows belong on the published BEV record, `omoda/omoda-e5`. But
> the manager should know that the rule I applied everywhere else in this dossier points
> the other way here, and that the inconsistency is in the catalog, not in the register.

---

## 7. REFUSALS

### 7.1 `Seal 5` (650 vehicles) — REFUSE. It is not a trim of `byd/seal`.

**This refusal is the most valuable single result in the packet**, and it now has three
independent legs.

**Leg 1 — BYD Thailand's own site publishes two separate model pages.** I opened both:

| URL | page `<title>` |
|---|---|
| `https://www.byd.com/en-th/car/seal` | **`BYD SEAL \| BYD Thailand`** |
| `https://www.byd.com/en-th/car/seal5dmi` | **`BYD SEAL 5 DM-i \| BYD Thailand`** |

BYD Thailand's model index (`https://www.byd.com/en-th`) lists them as separate entries
alongside `/car/seal6`, `/car/sealion5`, `/car/sealion6`, `/car/sealion7`, `/car/atto1`,
`/car/atto2`, `/car/atto3`, `/car/dolphin`, `/car/m6`. **A separate model page on the
maker's own site means a separate nameplate.** This is the Chevrolet Onix / Onix Plus
precedent applied exactly as written.

**Leg 2 — they are different machines, per the regulator.**

| | **BYD SEAL** | **BYD SEAL 5 DM-i** |
|---|---|---|
| powertrain | **BEV** | **PHEV — 1,498 cc petrol engine + motor** |
| body | Sedan 4800×1875×1460 | Sedan **4780×1837×1495** |
| kerb/total weight | 1922–2185 kg | **1620 kg** |
| battery | 150 Ah Li-ion, 409.6–550.4 V | 41–54 Ah **LiFePO4**, 319.2–339.2 V |
| range | 510 / 580 / 650 km (full BEV) | **85 / 120 km EV-only**, 1.0 L/100 km combined |
| CO₂ | 0 g/km | 23 g/km (STANDARD/DYNAMIC), 17 g/km (PREMIUM) |
| price | ฿1,325,000 – ฿1,599,000 | **฿599,900 – ฿699,900** |
| excise rate | 2 % | 5 % |
| built by | BYD AUTO COMPANY LIMITED (China) | **บริษัท บีวายดี ออโต้ (ประเทศไทย) จำกัด (Rayong, Thailand)** |
| certified | Oct 2023, ECO #019541–019543 | Jan 2026, ECO #026143 / 026304 / 026305 |

Records: SEAL DYNAMIC `ce7e69a6-f933-40e5-a9e7-3153019588b1`, SEAL PREMIUM
`4257f771-e461-4122-8c25-f185c518a3c4`, SEAL PERFORMANCE AWD
`61f29335-1610-4302-9dae-e3cd4f6199d1`; SEAL 5 DM-i STANDARD
`a5e8c4aa-d567-49c1-a3aa-5a81a8b61b15`, SEAL 5 DM-i DYNAMIC
`2a827052-6486-4a6b-9373-bfcb60d1ca28`, SEAL 5 DM-i PREMIUM
`ef565672-0fa3-4aa1-9e86-ddce5bc70eba`.

A battery-electric ฿1.45 m sedan imported from China and a ฿700 k plug-in hybrid built in
Rayong, differing in length, width, height, weight, pack chemistry and tax class, are not
one nameplate. `DM-i` is BYD's plug-in-hybrid line, and the raw register string
`BYD SEAL 5 DM-i PREMIUM` carries it.

**Leg 3 — the catalog already agrees.** Per the manager's mid-batch correction,
`byd/seal-5` went **live in v2026.09.1 as its own published nameplate** carrying exactly
these 650 Thai vehicles, separately from `byd/seal` (live in de, es, fi, ie, lu, my, nl,
nz, th, ua). The fold under test would therefore have **deleted a live published id**,
not gained coverage.

**The general lesson for the PR body:** the 650 vehicles would have taken `byd/seal` past
a coverage milestone. That is not a reason to merge. The publication threshold is a floor
for minting, never a target to be reached by collapsing two real nameplates into one.

*Related near-miss worth recording:* BYD Thailand also sells a **SEALION 5 DM-i**
(Hatchback 4735×1860×1710, 54 Ah LFP, 110 km EV range, ฿759,900–799,900, ECO #026577),
a **third** distinct nameplate whose name contains "SEAL". Any substring or prefix rule on
"Seal" would swallow Seal 5, Seal 6, Sealion 5, Sealion 6 and Sealion 7. Five nameplates,
not one.

---

## 8. UNRESOLVED — exactly what I could not find

Five strings, 5 vehicles in total. In each case I name the specific evidence that is
missing, so the next researcher does not repeat the search.

1. **`Wrx Sti S207` (1 veh)** and 2. **`Wrx Sti S208NBR Challenge` (1 veh)** — these are
   Subaru Tecnica International limited-production "complete cars". I opened
   `https://sti.jp/` and `https://sti.jp/brand/portfolio/`; the portfolio section is
   STI's **motorsport** programme (SUPER GT, Nürburgring 24h, JRC, WRC, GR86/BRZ racing)
   and describes only the BRZ GT300 race car. I found **no STI page describing the S207
   or S208 as products**, and neither string appears anywhere in the Thai ECO Sticker
   register (`search=WRX STI` returns nothing). **Missing evidence:** an STI or Subaru
   page that names the S207/S208 and states the base model. Until then I will not assert
   whether these are WRX STI grades or STI-branded models in their own right — and at
   1 vehicle each the guess would buy nothing.
3. **`Brz Cup Car Basic` (1 veh)** — same situation. Not in the Thai register; no Subaru
   or STI page found that describes a "BRZ Cup Car Basic". The Thai register does hold a
   grey-import **`BRZ STI SPORTS`** (Coupe 4265×1775×1310, 2387 cc, 6MT, 1270 kg,
   188 g/km, ฿1,500,000, ECO #026594, importer RYUJIN IMPORT CO., LTD.) but that is a
   different string and does not source this one. **Missing evidence:** a Subaru/STI page
   naming the Cup Car Basic and its base model.
4. **`T03 400` (1 veh)** and 5. **`T03 300` (1 veh)** — I could not open **any** Leapmotor
   page. `leapmotor.co.th`, `leapmotorthailand.com`, `leapmotor-th.com`, `int.leapmotor.com`
   and the Thai importer's domains are all NXDOMAIN; `www.leapmotor.com`,
   `www.leapmotor.com/th/` and `leapmotor-international.com` return **403 Forbidden** to
   every fetch I attempted. The Thai ECO Sticker register contains **no T03 at all**
   (`search=T03` returns zero rows; the LEAPMOTOR brand holds only the five C10/B10 rows
   in §5d), so the regulator fallback is unavailable too. The pattern strongly suggests
   `300`/`400` are range badges in the Aion manner — **but that is a guess and I am not
   recording it as a finding.** **Missing evidence:** any Leapmotor page or Thai
   certification listing a T03 and its range designations.

Additionally, two **unsourced sub-claims inside otherwise-sourced folds**, flagged so
they are not mistaken for evidence:
- "First Edition" (rows 36, 41) — not printed on any Lotus page I opened. The folds rest
  on the sourced `Emira` nameplate plus the sourced `V6`/`I4` engine designations.
- The Leapmotor C10 REEV's existence (§5d) — asserted in my brief, not verified by me.

---

## 9. Notes the manager may want for other packets

- **`ecosticker.go.th` covers the whole Thai market**, not just this packet. Its brand
  list includes AION, AVATR, BAW, BYD, CHANGAN, CHERY, DEEPAL, DENZA, DFSK, EVEASY,
  FIREBRIGHT, firefly, FORTHING, FOTON, GAC, GEELY, GWM, GWM TANK, HAVAL, HONGQI,
  JAECOO, JUNEYAO, LEAPMOTOR, LEPAS, MAXUS, MINE Mobility, NEOMOR, NETA, OMODA, ORA,
  POER, RIDDARA, SERES, SOLARKY, THAINA, VIAUTO, VINFAST, VOLT, WULING, XPENG, ZEEKR,
  ZXAUTO alongside the legacy makes. For any future Thai sweep this is the source of
  record, and the three endpoints in §0 are all you need.
- **The brand field is case- and whitespace-dirty.** `SUBARU` and `Subaru` are two
  distinct brand values, as are `HAVAL ` (trailing space), `DENZA `, `Land Rover `,
  `LEPAS `; several model values have leading spaces (` BYD SEALION6 DM-i PREMIUM`,
  ` 6 EV Long Range 2WD Pro`). **A `brand=` filter silently under-returns** — I nearly
  missed `Forester 2.0i-L ES` and `XV 2.0i-P` that way and only caught them with
  `search=`. Use `search=` to confirm any negative result.
- **The register holds superseded naming alongside current naming** for the same car
  (Lotus `Eletre S`/`Eletre R` next to `ELETRE 600`/`ELETRE 900 Sport`; Deepal `S07` next
  to `NEW S07`; Aion `Y PLUS` next to `Y Plus 410`/`490`). That is a feature for this
  lane: it is direct evidence that two spellings denote one nameplate.
- **Word-order duplicates are real in the source**: `BRZ 2.4 EyeSight RWD 6AT` and
  `BRZ 2.4 RWD EyeSight 6AT` are two certifications of the same car. Any Thai packet will
  carry pairs like this, and each needs its own rename key.
- **Thailand renames models between markets.** Confirmed in this batch: Omoda **C5 EV**
  (TH) = Omoda **E5** (GB); Subaru **XV** (TH, to 2022) → **Crosstrek** (TH, current) —
  the register holds `XV 2.0i-P ES` and `CROSSTREK 2.0i-S ES AWD CVT` for successive
  generations of the same line. The Crosstrek/XV relationship is **not** in my packet and
  I make no recommendation on it, but it is the next thing a Thai sweep will hit.
