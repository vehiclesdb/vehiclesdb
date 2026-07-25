# PROPOSAL — the `kind` boundary is drawn on the wrong axis

**Status:** joint proposal for the repo owner. §2 (two-wheel evidence) written by
S2W; §3 (four-wheel evidence) stubbed for S4W; §1 and §4 drafted jointly.
**Nothing here changes data.** A kind split is schema-level — `kind` is in every
published id (`moped/aixam/a400`) — so it needs an owner's decision, not a
maintainer's.

---

## 1. The defect, in one sentence

**Registers classify vehicles by LEGAL CATEGORY; we publish `kind` as a MARKETING
CATEGORY; and we derive one from the other via each register's own vehicle-type
word, which is a third thing again.** Both maintainers hit this independently, in
opposite kinds, on the same day — which is why we think it is structural rather
than two bugs.

The mapping today runs `voertuigsoort`/`BodyType`/`Pkw` → `kind`
(`overrides/kind_maps/*.yml`). Those source words are *administrative* labels. The
EU category (`L1e`…`L7e`, `M1`, `N1`…) is the *legal* fact, and it is the thing
that actually predicts what the vehicle is.

---

## 2. Two-wheel evidence — `kind: moped` is two different vehicles `[S2W]`

`overrides/kind_maps/nl_rdw.yml` maps `Bromfiets: moped`. Measured live against
the RDW register (CC0, https://opendata.rdw.nl/resource/m9d7-ebf2.json,
2026-07-25), `Bromfiets` decomposes as:

| EU category | registrations | what it actually is |
|---|---|---|
| **L1e** | 1,327,208 | genuine mopeds — correct |
| **L6e** | **40,090** | **light quadricycles: enclosed 4-wheel microcars** |
| L2e | 5,844 | three-wheel mopeds |

**L6e is not a moped by any reading.** EU 168/2013 defines it as a *light
quadricycle*: four wheels, ≤ 425 kg unladen, ≤ 45 km/h, ≤ 6 kW. These are small
cars with doors, a roof, seatbelts and a windscreen. The makes carrying those
40,090 registrations:

```
AIXAM 9,385   LIGIER 5,804   MICROCAR 5,320   OPEL 4,350   STINT 3,142
ESTRIMA 1,950  FIAT 1,912    CITROEN 1,207    JIAYUAN 800   JDM 736
CHATENET 544   MEGA 299      CASALINI 283     BELLIER 229
```

Two things stand out:

- **Opel, Fiat and Citroën appear** — those are the **Opel Rocks-e**, **Fiat
  Topolino** and **Citroën Ami**, all homologated L6e. So the defect is not
  confined to obscure marques; three mainstream car brands currently have
  microcars published as mopeds.
- **STINT (3,142)** is a Dutch electric cargo platform, not a moped either.

**Published impact today: 62 records** under makes that build nothing but
microcars — `ligier` 19, `microcar` 13, `aixam` 12, `chatenet` 8, `casalini` 5,
`bellier` 3, `estrima` 2 — plus the Rocks-e/Topolino/Ami rows under their car
marques.

By contrast `Motorfiets` → `motorcycle` is **clean**: L3e only, 895,339
registrations, no mixing. So this is specifically a moped-kind problem, which is
useful — it means the fix is bounded.

### What the 2W side recommends

1. **Do not split `motorcycle`.** It is a faithful L3e.
2. **`moped` should mean L1e (+L2e).** L2e is a three-wheel *moped* and belongs
   with it — consistent with DECISIONS.md folding three-wheelers by capability
   rather than wheel count.
3. **L6e/L7e need a home.** Two options, and the 2W side has no strong preference
   because both are honest:
   - a reserved kind (`quadricycle`) activated the way `moped` was — DECISIONS.md
     already keeps `train`/`plane`/`ship`/`agricultural` reserved for exactly this;
   - or `car` with a `body_types: ["microcar"]` secondary, which matches how a
     buyer thinks about an Ami and keeps the kind count down.
4. **Whichever is chosen, the routing must key on EU category, not on
   `voertuigsoort`** — otherwise the next register with a different administrative
   word reintroduces the mix.
5. **`former_ids` covers the migration.** 62+ ids would change
   (`moped/aixam/a400` → `<newkind>/aixam/a400`); the mechanism shipped on
   2026-07-25 exists precisely for this and makes it an additive release.

### Why this was invisible until now

`kind_maps` are per-source and keyed on the source's own word, so nobody ever had
to look at the EU category column — and the aggregate the pipeline fetches for
`Bromfiets` does not even request it (only `merk`, `handelsbenaming`, `count`).
The evidence was one SODA parameter away and nothing pointed at it.

---

## 3. Four-wheel evidence — `Pkw`/M1 has no mass ceiling `[S4W]`

*Stub for S4W.* Expected content, from NEGOTIATION.md Turn 18: M1 is defined by
seat count with no mass limit, so Germany's `Personenkraftwagen` table
legitimately contains M1 van variants and motorhomes up to 26 t
(`SA/Wohnmobil`, 71,575 units = 2.5% of German Pkw in 2025); 79,534 registrations
recovered by routing 30 nameplates to `van`; and FZ 11.1's segment cut as the
cross-check that made it rigorous (399/399 Modellreihen reconcile;
`UTILITIES` is KBA's own car/van boundary).

---

## 4. What we are asking the owner to decide

1. **Is `kind` a legal-category axis or a marketing axis?** Everything else
   follows. Our shared recommendation: **derive `kind` from the EU category**, and
   treat the register's own vehicle-type word as a hint, not a source of truth.
2. **Where do L6e/L7e go** — new reserved kind, or `car` + `microcar` body type?
3. **Is a coordinated kind migration acceptable in one release**, given
   `former_ids` makes it additive rather than breaking?

Neither maintainer will act on this unilaterally. Both halves are otherwise
complete and green; this is the one open question that spans them.

---

# DECISION (2026-07-25) — made on the owner's instruction, with research

The owner asked for these three questions to be researched and decided rather
than escalated. Answers, evidence, and what is actually implementable.

## Q1. Is `kind` a legal-category axis or a marketing axis? → **LEGAL.**

Not a judgement call — the current approach is demonstrably incoherent. **The
same vehicle is published in three kinds at once:**

```
car         renault/twizy   ar|gb|my|ua
motorcycle  renault/twizy   nl
moped       renault/twizy   es|fi|nz
```

Citroën Ami spans car + moped + van; Aixam spans car(9) + moped(5) + van(1).
Registers disagree with each other about the same vehicle because each one's
vehicle-type word is an *administrative* label. The EU category is the legal
fact and the only axis on which the six sources agree.

**Decided: derive `kind` from the EU category; treat the register's own word as
a hint, never as truth.** This is already the pattern for `Bedrijfsauto`
(N1→van, N2/N3→truck) — it just was never applied to `Bromfiets`.

## Q2. Where do L6e/L7e go? → **`car`, with `body_types: ["quadricycle"]`.**

**Not a new kind.** The deciding factor is binding internal precedent —
DECISIONS.md line 23:

> *"Three-wheelers fold into `motorcycle` with `body_types: ["trike"]` — no kind
> explosion."*

L5e is an EU category in its own right and it was folded into the kind it
physically resembles, with the legal category preserved as a body type. L6e/L7e
are four-wheeled, enclosed, steering-wheel, side-by-side-seat vehicles, so by
parity the kind they physically resemble is `car`.

Supporting evidence, and the one thing that argues the other way:

* EU 168/2013: L6e = 4 wheels, ≤425 kg, ≤45 km/h, ≤6 kW; L7e ≤15 kW, up to
  ~90 km/h. Both are quadricycles, distinct from L1e mopeds AND from M1 cars.
* **Against:** Citroën explicitly markets the Ami as *"technically not a car"*,
  an "urban mobility object", and L6e is drivable on an **AM (moped) licence** —
  age 14 in France, 16 in the UK. L7e needs B1/full car licence, age 17.
* **Why `car` still wins:** the licence axis splits L6e from L7e, so honouring it
  would mean L6e→moped and L7e→car — which would put an enclosed four-wheel Ami
  in with Vespas and split the Aixam range across two kinds. The trike precedent
  resolves this: fold by physical form, record the legal category in the body
  type. `body_types: ["quadricycle"]` keeps the AM-licence information
  recoverable by filtering, which is all a consumer needs.
* It also *unifies* makes currently split three ways (aixam, renault/twizy).

`quadricycle` over `microcar`: it maps 1:1 to the legal category, whereas
"microcar" also covers M1 cars (Isetta, Smart Fortwo).

## Q3. Migration in one release? → **Yes, additive — but NOT yet implementable.**

`former_ids` makes the id changes additive, and adding a `body_types` vocabulary
value is additive per SCHEMA.md's growth contract. So the release shape is fine.

**I attempted the implementation and it is not a one-file change. Scoped by
trial, then reverted rather than half-shipped:**

1. `nl_rdw` was straightforward — `by_eu_category` already existed for
   `Bedrijfsauto`, so `Bromfiets` needed the same treatment. It worked.
2. **But only `nl_rdw` plumbs `eu_category` into a `Row`.** `es_dgt`,
   `fi_traficom`, `lu_snca`, `ua_mvs` and `nz_nzta` also feed `moped` and do
   not. So routing one source produced exactly the incoherence it was meant to
   fix: aixam car(9)/moped(5), ligier car(1)/moped(3).
3. Records fell off entirely: `silence/s04` (the S04 **Nanocar**, an L6e) and
   `opel/rocks-e` vanished — moved into `car` but failed the car-kind
   publication threshold on their remaining evidence.
4. The moved rows got `hatchback`/`convertible` from the car body rules, not
   `quadricycle` — `body_rows` only fetches the body signal for `Personenauto`.

### The implementable plan, in dependency order

1. **Plumb `eu_category` into `Row` for every source that has it** — es_dgt,
   fi_traficom, lu_snca, ua_mvs, nz_nzta. This is the real prerequisite and it
   is per-source work, not a curation change.
2. Add `by_eu_category` to each source's `kind_map` (data, reviewable).
3. Derive `body_types: ["quadricycle"]` from `eu_category` at reconcile time so
   it does not depend on a per-source body signal.
4. Re-check the publication threshold for the moved records before shipping —
   an L6e with only NL+ES evidence must not silently vanish from `car`.
5. Generate `former_ids` for every moved id (the generator reads intent from
   the override layer, so it needs the kind_map change to be visible to it —
   currently it only reads renames/moves, so this needs extending).

**Recommendation: do it as its own release, not bundled.** It touches five
sources, both maintainers' kinds, the body-type vocabulary and ~40k
registrations of evidence. The current state is *known*-wrong and tripwired; a
half-migration would be *unknown*-wrong.

---

## Q3, THIRD REVISION (2026-07-25, after building it) — the gating blocker is Spain

I estimated this work three times and was wrong three times. All three are recorded
so the next attempt does not repeat the sequence:

| estimate | claim | why it was wrong |
|---|---|---|
| 1st | "plumb `eu_category` into `Row` for 5 sources" | 3 of the 5 already route on the EU category |
| 2nd | "~6 map entries across 3 sources" | ignored what happens to records that SPLIT |
| 3rd | **a Spanish national-code → EU-category mapping** | evidenced by building it and measuring |

### What actually happens if you flip the maps today

Built end to end (source maps + `nl_rdw` kind_map + `eu_cats` on the reconciler
entity + a `quadricycle` body-type derivation + the validator vocabulary), then
measured against the pre-change build:

```
body_types ["quadricycle"] derived correctly     76 records — the mechanism WORKS
make/model pairs that VANISHED ENTIRELY          35
    citroen/my-ami-buggy · fiat/topolino-dolcevita · chatenet/ch28 · ch28hdi
    casalini/m12 · estrima/biro-van · aixam/k2 · aixam/s10-2
    garia/club-car-urban-l7e-s · cpi/je50 · e-ton/viper-st-50 · flistar/ym2000 …
```

### Root cause — in `es_dgt.rb`'s own comment, which I read past twice

> *"Spanish NATIONAL codes (asterisk series) — the bulk of ES two-wheelers arrives
> under these, not EU categories"*

`es_dgt` HAS an `EUCAT` field, but most Spanish two-wheelers arrive under `*02`,
`*03`, `*05`… national codes carrying no L6e signal. So Spain cannot route L6e to
`car`, and any L6e with Spanish evidence splits:

```
nl_rdw  L6  -> car    290 vehicles · single source · car threshold 1000   -> candidate
es_dgt  *NN -> moped  single source               · moped threshold 300   -> candidate
```

Split across two kinds, single-source in each, clears neither threshold,
**disappears from the catalog**. `silence/s04` — the S04 Nanocar, an L6e — was
published `es|nl` and ends up in neither kind. Same shape as the Piaggio→Vespa
split (relocating one register's rows while another's stay behind strands both
below the bar), a lesson that was already written down when I did this.

### Dependency-ordered plan, corrected

1. **GATING: map DGT's national asterisk codes to EU categories** (`*02`…`*17` →
   L1e/L3e/L6e). Research on DGT's published code list, not plumbing. Without it
   Spain cannot participate and every ES-evidenced L6e is lost.
2. Flip `L6E`/`L7E` to `:car` in `es_dgt`, `fi_traficom`, `lu_snca` (2 lines each).
3. `nl_rdw`: `Bromfiets` under both `car` and `moped`, plus a `by_eu_category`
   block in its kind_map. **Guard `is_a?(Hash)` before `dig`** —
   `kind_map["kinds"][soort]` is a String for simple mappings and `Hash#dig` raises
   `TypeError` on a String intermediate; without the guard nl_rdw silently
   contributes ZERO rows for every simply-mapped soort (car 8,363→4,392, and only
   the delta gate notices).
4. Reconciler: `eu_cats` on the entity + a `quadricycle` short-circuit BEFORE the
   car body rules (built, working — no registry body signal ever says
   "quadricycle", so `body_type_for` would label a Citroën Ami a hatchback).
5. `quadricycle` into `CANONICAL_BODY_TYPES` (validate.rb) and SCHEMA.md.
6. **Verify no record vanishes, per id, not in aggregate** — then `former_ids` for
   every moved id, and rekey the `silence/s04` spotcheck to `kind: car`.

### Do not attempt this without step 1

Steps 2-6 are about a day. Step 1 is the whole risk, and skipping it deletes ~35
real microcars while every gate stays green.

---

## B3 RESOLVED (2026-07-25) — the Spanish blocker was my own misreading

**Estimate 4, and this one is measured end to end rather than reasoned about.**
The three earlier estimates are above; this section supersedes the third,
including its central claim.

### What I got wrong in estimate 3

> *"GATING: map DGT's national asterisk codes to EU categories (`*02`…`*17` →
> L1e/L3e/L6e). Research on DGT's published code list, not plumbing. Without it
> Spain cannot participate and every ES-evidenced L6e is lost."*

Both halves of that are wrong.

1. **The codes that carry quadricycles are `*19/*20/*21/*26/*27`, not
   `*02`…`*17`.** `*02`–`*17` are mopeds and motorcycles and were never
   relevant.
2. **`es_dgt.rb` already maps all five of them** — to `:moped`, with a dated
   sampling comment naming Aixam, Microlino and Silence. There was no missing
   mapping to research. I read that comment twice and still described the file
   as lacking the signal.

**The real mechanism behind `silence/s04` vanishing:** `L6E` and `*21` both map
to `:moped` today. My migration flipped `L6E` to `:car` and left `*21` at
`:moped`. The S04 has **153 rows under `*21`** and 0 under `L6E`, so the flip
moved its Dutch evidence to `car` while its Spanish evidence stayed in `moped`,
and each half fell under its own threshold. A two-line omission, not a missing
research artifact. The lesson is the one already written down after the Vespa
split — **relocate a nameplate's evidence together or not at all** — and I
reproduced it in a different register.

### The mapping (measured, 3 months of DGT microdata: 2026-04/05/06)

Flip these to `:car`, together, in one change:

```
L6E  L7E  *19  *20  *21  *26  *27
```

Everything else in `es_dgt.rb` stays exactly as it is.

### Why these five codes are L6e/L7e — verified two independent ways, in-file

I could not find a citable official table for the asterisk series, and I am
recording that as an unknown rather than papering over it. **RD 2822/1998 Anexo
II §B actively contradicts a naive reading** — there, `21` is *"Capitoné:
vehículo destinado al transporte de mercancías en un receptáculo totalmente
cerrado, acolchado"* (a padded furniture van), `20` is *"Caja cerrada"*, `27` is
*"Cisterna"*, `02` is *"Bicicleta"*
(https://www.iberley.es/legislacion/anexo-2-reglamento-general-vehiculos).
None of that matches the rows. Per DGT's own interface document the Anexo II
code lives in a **different field** (#53 `CLASIFICACIÓN_REGLAMENTO_VEHICULOS_ITV`)
while these values appear in #48 `CATEGORÍA_HOMOLOGACIÓN_EUROPEA_ITV`
(https://sedeapl.dgt.gob.es/IEST_INTER/pdfs/disenoRegistro/vehiculos/matriculaciones/MATRICULACIONES_MATRABA.pdf,
Tabla 1). **Treat any published gloss of "`*21`" as unverified.**

So the claim is verified from the data instead, and the evidence is stronger
than a code table would have been:

**(a) The EU-categorised rows and the asterisk rows carry the SAME RD 2822
code.** Field #53 is in the file, so the two vocabularies can be cross-joined:

| #48 value | rows | unladen mass p10/med/p90 | #53 (RD 2822 Anexo II) |
|---|---|---|---|
| `*19` | 47 | 267 / 407 / **425** | `0300` ×47 |
| `*20` | 17 | 342 / 425 / **425** | `0320` `0300` `0311` |
| `*21` | 813 | 406 / 425 / **425** | `0300` ×809 |
| **`L6E`** | 6 | 350 / 420 / 480 | **`0300` `0320` `0311`** |
| `*26` | 34 | 481 / 587 / 600 | `0617` `0600` `0611` |
| `*27` | 120 | 435 / 439 / **450** | `0600` ×120 |
| **`L7E`** | 16 | 200 / 450 / 645 | **`0600` `0611`** |
| *control* `*05` | 35,647 | 117 / 136 / 167 | `0400` (motorcycles) |
| *control* `M1` | 404,018 | 1210 / 1485 / 2010 | `1000` (turismos) |

`L6E` lands on `0300/0311/0320` — the identical code set as `*19/*20/*21`.
`L7E` lands on `0600/0611` — the identical set as `*26/*27`. The register is
telling us, in its own second vocabulary, that these are the same vehicles.

**(b) The mass distributions sit exactly on the regulatory limits.** Reg. (EU)
168/2013 Annex I sets L6e unladen mass at **≤425 kg** and L7e at **≤450 kg**.
`*21`'s p90 is **425**. `*27`'s p90 is **450**. Codes that were something else
would not pile up on those two numbers.

### Split risk — measured per nameplate, which is the check that was missing

Every (make, model) in three months of microdata, asked whether it appears under
BOTH a flipped code and a code that stays:

```
nameplates carrying ONLY flipped codes (whole nameplate moves cleanly):  75
nameplates carrying BOTH flipped and staying codes (SPLIT RISK):          1
```

The one: **`BOMBARDIER CAN-AM`** — `*17`:1 and `L7E`:1, two registrations total.
Can-Am's Spyder/Ryker are three-wheelers, which DECISIONS.md line 23 keeps in
`motorcycle` on the trike precedent, so the right handling is to leave `*17`
alone and accept one row moving. Verify it against the no-vanish gate like
everything else; do not special-case it in advance.

The 75 clean movers, largest first: `SILENCE S04` (206) · `LIGIER JS50` (182) ·
`AIXAM S10` (155) · `AIXAM S10-2` (63) · `FIAT TOPOLINO` (62) ·
`CITROEN AMI AMI` (55) · `LIGIER MYLI` (49) · `MOBILIZE DUO 45` (28) ·
`BENTU STEED` (24) · `CITROEN MY AMI AMI` (21) · `MICRO MICROLINO` (16) ·
`ZYCAR Z2L` (14) · `AIXAM M12RS` (12) · `ARES J3` (11) · `RUNHORSE TEV` (11) …

Note `LIGIER JS50` already spans `*21`+`*27`+`L6E` and `MICRO MICROLINO` spans
`*27`+`L6E`: they are only safe **because all three codes flip together.** Flip
a subset and these split too. That is the whole reason the set is atomic.

### Revised plan

1. ~~Research DGT's code list~~ **— done, and it was not the blocker.**
2. In `es_dgt.rb`, move `L6E L7E *19 *20 *21 *26 *27` to `:car`. One hash, seven
   entries, and they must move in the same commit.
3. `fi_traficom`, `lu_snca`: `L6E`/`L7E` → `:car` (2 lines each).
4. `nl_rdw`: `Bromfiets` under both `car` and `moped` + a `by_eu_category`
   block. **Guard `is_a?(Hash)` before `dig`** — `kind_map["kinds"][soort]` is a
   String for simple mappings and `Hash#dig` raises `TypeError` on a String
   intermediate; without the guard nl_rdw silently contributes ZERO rows (car
   8,363→4,392) and only the delta gate notices.
5. Reconciler: `eu_cats` on the entity + a `quadricycle` short-circuit BEFORE
   the car body rules (built, works — 76 records got `quadricycle`).
6. `quadricycle` into `CANONICAL_BODY_TYPES` (validate.rb) and SCHEMA.md.
7. **Per-id no-vanish verification against a build, then `former_ids` for every
   moved id**, and rekey the `silence/s04` spotcheck to `kind: car`.

Step 1 is closed. Steps 2–7 are the day of work the third estimate described,
and the gating item is now S4W's G2 gate rather than any research.

### One real bug found while measuring, worth fixing on the way past

`es_dgt.rb` reads `EUCAT = [426, 3]`. DGT declares field #48 as **CHAR(4)**.
Measured across 586,765 rows the truncation bites **19 rows** — `L3E-` ×14,
`M1SC` ×3, `N3SG` ×1, `L1E-` ×1 — of which `L3E`/`L1E` still map correctly by
luck and 4 rows are silently dropped as unmapped. Negligible today, but Reg.
168/2013 subcategories (`L6e-B`, `L3e-A1`) are 4+ characters, so this becomes a
real loss the moment Spain starts emitting them. Change to `[426, 4]`; the
`.strip` already handles the trailing space.

The offset arithmetic is worth recording since nothing in the repo documents it:
field #48 starts at 426 by summing the declared `CHAR()` lengths of fields 1–47
in Tabla 1 of the interface document — and that it agrees with the offset
already in the source is the check that the sum is right. Same method gives
#46 `MASA_ORDEN_MARCHA` = 414, #47 `MASA_MÁXIMA` = 420, #49 `CARROCERIA` = 430,
**#53 `CLASIFICACIÓN_REGLAMENTO_VEHICULOS_ITV` = 449** — that last one is the
RD 2822 code used in the table above, and it is a genuinely useful second
opinion on kind for any future boundary question.
