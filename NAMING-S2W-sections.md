# NAMING.md §6–9 — S2W-owned sections

**Status:** drop-in replacement for the `[S2W]` stubs in `NAMING.md` (PR #0).
Kept as a separate file only because PR #0 had not merged when these were
written; merge verbatim into `NAMING.md` and delete this file.

---

## 6. Granularity: trims, displacement, generations `[S2W]`

**The altitude is the nameplate** (DECISIONS.md: "Model = nameplate"). What
follows is how that resolves for two-wheelers, where registry free text is far
noisier than in the car kind.

**Trims, editions and equipment levels FOLD.** `125 SE-R` → `125 SE` (R =
Racing trim), `Brinco C` → `Brinco` (C/S/R are same-output equipment trims),
`Terramar America's Cup Edition` → `Terramar`. A trim is a variant of a
nameplate, and registration data cannot support trim-level accuracy honestly.

**Displacement does NOT fold — it is part of the nameplate.** `Senda 50` and
`Senda 125` are two motorcycles, not one; `Cota 4RT`, `Cota 4RT 260` and
`Cota 4RT 301RR` are 249/259/298cc and stay separate
(https://montesa.com/en/montesa-range/). This is the single most important
difference from the car kind, where engine size is a spec and gets collapsed.
Test: if two records differ only by a number that is a **capacity**, keep both;
if they differ by a number that is a **battery size or power figure**, fold
(`Leaf 40KWH` → `Leaf` is the car-kind precedent, and `S01LS` → `S01` the 2W one
— LS is an L1e speed class, which `kind` already encodes).

**A decimal in a two-wheeler name is part of the nameplate, never a
displacement.** Bikes are sized in cc, so litres cannot appear. Measured in the
RDW `handelsbenaming` aggregate (CC0,
https://opendata.rdw.nl/resource/m9d7-ebf2.json, 2026-07-25): 326 distinct 2W
values carry a decimal and **309 are ≥ 2.5**, impossible as a bike capacity —
LUQI `HL6.0S` (1,049 registrations), Aprilia `MOTO 6.5` (228, a 650cc single
marketed as 6.5), Specialized `TURBO VADO 6.0`, Govecs `GO! S1.2`. `junk?`'s
litre-displacement rule is therefore scoped to car/van; do not "simplify" that
scoping away.

**Numbered generations stay separate for two-wheelers.** `Nerva EXE II`,
`KTM Duke II`, `SYM Fiddle II` are distinct products in a way that a car's Mk2
is not — precedent set in PR #1 and unchanged. Car-kind roman numerals still
collapse (`VARIANT_SUFFIXES` strips them).

**Kind carries the legal class, so the class never enters the name.** L1e vs L3e
is `kind: moped` vs `kind: motorcycle`. `S02LS` folds into `S02` because "LS" is
the 45 km/h class marker (RDW writes both strings for the same scooter: 681
`S02LS` rows vs 104 `S02`).

---

## 7. Code strings and display form `[S2W]`

### 7.1 A bare integer is a PARSER suspect before it is a DATA suspect

> A model name that is a bare integer, single-source, is a **parser** suspect
> before it is a **data** suspect. Resolve it against that source's raw snapshot
> before proposing any drop. Consecutive integers under one make are
> presumptively a shared-string/index leak — i.e. evidence the records are REAL.
>
> **Recover the true name by re-parsing the row, never by resolving the integer
> as a table index: shared-string tables are workbook-wide and will hand you a
> confident wrong answer from another sheet.**

This rule exists because the class was misdiagnosed twice in one day, and both
remedies would have destroyed real data. `seat/468`–`474` were dropped as "KBA
numeric type-codes"; they were ATECA, BORN, FORMENTOR, IBIZA, LEON, TAVASCAN,
TERRAMAR — SEAT's entire German lineup. `volkswagen/550`–`566` were CADDY…
TRANSPORTER, including the Golf. The counter-examples for the second clause:
`si[350]` = "ACTROS" (a truck, in a cars-only file) and `si[500]` = "SUZUKI" (a
make). Structural corroboration — a contiguous run bracketed by a make header
and a `ZUSAMMEN` total — is fine for *triage*; only a row re-parse is proof.

### 7.2 Numeric legitimacy is KIND-DEPENDENT

The same shape gets opposite verdicts by kind, so never write a catalog-wide
rule for it:

| kind | bare numbers are | examples |
|---|---|---|
| truck, bus | **legitimate** type designations | Mercedes-Benz 1824, Scania 143 |
| car | usually chassis/registry codes | W123-era `200 D`, KBA index leaks |
| motorcycle, moped | **legitimate** capacity umbrellas | Sherco `250`/`300`/`450` (UK class strings) |

### 7.3 Type codes stay closed; words stay open

Makers write short type codes **closed** and real words **open**. The pipeline
encodes this as a ≥4-letter test at each letter/digit boundary
(`normalizer.rb#two_wheeler_spacing`):

- closed: Honda `CB750`/`CB1000R` (https://www.honda.co.uk/motorcycles.html),
  Suzuki `GSX1300R`, Yamaha `MT09`, BMW `R1250GS`, Honda `ST1300`
- open: Aprilia `Atlantic 500`/`Shiver 750`/`Pegaso 650`
  (https://www.aprilia.com), Kymco `Agility 50` (https://www.kymco.com),
  Ducati `1299 Superleggera` (https://www.ducati.com), Suzuki `Burgman 400`
  (https://www.suzukicycles.com), Kawasaki `Concours 14`, Triumph `Bonneville`

**Identity and display are two different jobs.** Registries spell one bike both
ways (`AGILITY 50` 32 rows vs `AGILITY50` 14; `1199 PANIGALE` 46 vs 9), so the
pipeline collapses every boundary to get a canonical **join key**, then re-opens
word boundaries to get a readable **display name**. Before that second pass
existed, the collapsed key WAS the display name and 821 of 967 word-glued 2W
records published strings found in no source (`AN 400 BURGMAN` →
`AN400BURGMAN`). It also silently defeated the caser: `case_token` returns any
digit-bearing token unchanged, so glued names stayed SHOUTING while every car
nameplate was Title Case.

### 7.4 Comma-joined cells are SOURCE-SPECIFIC — never generalise one rule

A single cell holding two names means different things per register, and getting
it backwards silently publishes the wrong half:

| source | joins | keep | evidence |
|---|---|---|---|
| KBA FZ10 (DE) | predecessor **+ successor** | the **later** model | `"GLK, GLC"` → GLC; `"ML-KLASSE, GLE"` → GLE |
| RDW (NL), Talaria | type code **+ commercial name** | the **name** | `"TL3000, STING"` n=53 → Sting; `"TL2500, XXX"` → XXX |
| RDW (NL), general | trim spellings | the **first** | `"SX4, SUZUKI SX4, S"` → SX4 |

`normalizer.rb` keeps the first element by default, which is right for the third
row and wrong for the first two — so those need explicit renames. Check the raw
distribution before assuming.

### 7.5 Registry type codes must be RESOLVED, not guessed

`SDR`, `AB`, `CG`, `TG`, `TR1`, `HU05W`, `XS50QT` are manufacturer or registry
type codes, not nameplates. Resolve them by querying the register for the
approval number and capacity that accompany the code (PR #1 did this for
Derbi/Gas Gas/TRS via live RDW queries), or leave them alone. A code mapped by
resemblance is a fabrication with a comment attached.

---

## 8. Placeholders and embedded brands `[S2W]`

### 8.1 Placeholders: drop only after checking the block is homogeneous

`N/A`, `N.A.`, `Xxx`, `MODEL MISSING`, `INSGESAMT`, `SONSTIGE`, `ZUSAMMEN` are
not nameplates. But **check what the block actually contains before dropping**,
because two very different situations look identical from the catalog:

- **Homogeneous placeholder block → RENAME to an honest family.** Sherco's ~806
  RDW `N/A` rows are all 50cc, so they became a `50` family rather than being
  deleted — they were Spain's #3 moped and dropping them would have destroyed
  real evidence.
- **Mixed or unidentifiable block → DROP.** Askoll's 179 NL registrations are
  100% literal `N/A` (164 `N/A` + 8 `N.A` + 7 `N.A.`) with no real name anywhere,
  so there is nothing honest to rename to. That drop **erases the make**, which
  is the correct outcome and is documented in the override comment: a make whose
  only record is a placeholder carries no information at model altitude.
- **Placeholder beside real models → drop only the placeholder.** Segway has
  6,725 placeholder registrations sitting next to E110S (2,673), E110SE (2,272)
  and E150S (994); all three survive.

**And verify it IS a placeholder.** `talaria/Xxx` looks exactly like junk and is
the **Talaria XXX**, a real e-motorbike — raw `"TL2500, XXX"`. It needed a
styling pin, not a drop. This is §7.1's rule in mirror image: a string that looks
like garbage may be a real name that the caser mangled.

### 8.2 Embedded brands

**Make prefix in the model column** is registry noise and gets stripped
(`"SUZUKI AN 400"` → `AN 400`). The strip runs against the raw make, the
canonical make, and the raw make's first token, which covers
`"MERCEDES-BENZ"` on `"MERCEDES SPRINTER"`. It fails when the badge differs from
the resolved make — `TRRS One` under make `TRS`, `Gasgas ES700` under `Gas Gas`
— and those need explicit renames.

**A sub-brand in the make column is a MOVE, not a drop.** Where a register
derives the make from a type-approval holder, a marque with no approval of its
own is filed under its parent: KBA assigns `Marke` from the HSN, Cupra has no
HSN so every Cupra is HSN 7593 "SEAT", and Genesis rides Hyundai's 8252
(https://www.kba.de/DE/Statistik/Fahrzeuge/Marken_Hersteller/markenHersteller_node.html).
Renaming cannot reach a different make and dropping destroys evidence — use
`moves.yml`.

**The corollary for two-wheelers, and it is a trap:** an apparent duplicate make
may be an approval holder rather than a duplicate. Husqvarna and GasGas ride
KTM's approvals; Vespa, Aprilia, Moto Guzzi and Derbi ride Piaggio's. **Verify
against approval data before merging any 2W make** — merging an approval holder
into a marque is the same class of error as the Cupra nulls.

---

## 9. Styling-token ownership table `[S2W]`

`styling.yml` is the one namespace both maintainers share, because an `acronyms`
token re-cases **every record in the catalog** and can orphan the other side's
rename keys.

**Rules.** Prefer a whole-string `stylings` pin (blast radius 1). An `acronyms`
token needs a full-catalog sweep pasted into the PR, including the other half's
kinds. A token whose affected records span both halves is owned by the side with
the **majority** of them; the minority holds a veto. **No acronym token ships in
the same PR as rename keys that depend on it** — the caser runs before renames,
so a combined PR is unreviewable and a mismatch orphans the key silently.

**Ownership is by records touched, not by marque.** `BMW` as a *token* is
4W-owned (2 records in 2W vs 9 in 4W — its 4W hits are Alpina's brand-prefix
bleed, `Alpina Bmw Alpina B3`) even though the *make* BMW is 2W-owned. **Ties go
to a joint decision, never to sort order.**

Measured 2026-07-25: 709 consonant-only Title-case tokens exist; **102 appear in
both halves' records** — 28 2W-owned, 74 4W-owned.

| owner | tokens |
|---|---|
| **2W** | `SR` `GSX` `ZX` `MT` `ST` `RR` `TR` `GTS` `FTR` `SP` `CL` `SJ` `FLH` `MC` `XLS` `CG` `XM` `CB` `RD` `FLD` `TG` `NG` `FR` `PL` `GTR` `YB` `SM` `FX` |
| **4W** | `MK` `UP` `LT` `GL` `ES` `ID` `XJ` `SRT` `SS` `TC` `PV` `CJ` `SC` `TL` `XT` `GTV` `BMW` `CS` `SX` `AC` `LR` `TS` `DL` `MB` `AM` `EL` `XR` `TF` `KR` `LTD` `RT` `SD` `SV` `XB` `TX` `CT` `RC` `CD` `SRX` `RL` `ZT` `TRX` `XV` `FJ` `MR` `LP` `DT` `BT` `AX` `DX` `SK` `ET` `AB` `CM` `XJR` `SKY` `NP` `WW` `AL` `XP` `BR` `NT` `FS` `WF` `FLT` `VS` `UK` `GTP` `VB` `SXL` `UBS` `CP` `TSX` `NSX` |

Regenerate with `ruby scripts/propose_styling_tokens.rb` (reads `dist/` and
`OWNERSHIP.yml`); re-run after any release that adds makes.
