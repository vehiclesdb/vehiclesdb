# NAMING.md — the canon

How VehiclesDB decides what a vehicle is *called*, and what counts as evidence
for that decision. `DECISIONS.md` records **what** was decided and why;
this file is the operational rulebook you apply when curating a specific record.

Binding on humans and agents alike. Where a rule is enforced by a script, the
script is named — prose that isn't executable drifts, so enforcement is the
point.

> **Sections marked `[S2W]` are owned by the motorcycle/moped maintainer** and
> are theirs to write and change. Sections marked `[S4W]` are owned by the
> car/van/truck/bus maintainer. Ownership means "may edit without asking"; both
> sides must follow all of it. See `OWNERSHIP.yml`.

---

## 1. Identity: what a record IS `[S4W]`

**A model record is a NAMEPLATE**, at the altitude a registration register can
support honestly (`DECISIONS.md` § Taxonomy & identity). One record covers a
nameplate's trims, engines and bodies unless `variants` says otherwise.

**The make is the marque, not the registrant.** Registers routinely put
something else in the make column:

| What the register wrote | What it means | Rule |
|---|---|---|
| `SCANIA IRIZAR` | chassis maker + bodybuilder | in `bus`, the **bodybuilder** is the make (Plaxton/Caetano precedent) |
| `FACTORY BUILT` + model `Yutong` | builder in the make column, marque in the model column | the marque wins; needs a cross-make move |
| `SEAT` + model `Formentor` | national register files a sub-brand under its parent | the **marque** wins (`Cupra`), via `moves.yml` |
| `HYUNDAI` + model `GV60` | ditto (Genesis under Hyundai) | ditto |
| `EIGENBOUW`, `FACTORY BUILT` | not a marque at all | drop for that kind |

**One make = one owner, across all six kinds.** Generated into `OWNERSHIP.yml`
by `scripts/gen_ownership.rb`; the owner is the side owning the make's dominant
kind by record count. Ties are pinned explicitly in that script — never
computed, because Hash order from the catalog JSON could flip a make's owner
between releases and two people would silently edit one block (and YAML keeps
only the last duplicate key — `scripts/lint_curation.rb` guards this).

**Ids are append-only** (`SCHEMA.md`). A rename produces an alias; nothing is
ever silently deleted. A "cleanup" that removes an id is a breaking change to
every consumer that stored it.

## 2. Evidence standards `[S4W]`

Ranked. Use the strongest available, and say which one you used in the override
comment.

1. **Type-approval (TAN) overlap** — two records sharing an EU whole-vehicle
   type-approval number are the same approved vehicle. The strongest duplicate
   proof available (`xrefs.tan`).
2. **Live registry measurement** — query the open register and cite the date
   (e.g. RDW SODA: `https://opendata.rdw.nl/resource/m9d7-ebf2.json?merk=…`).
   Beats any secondary source about what a register *contains*.
3. **The manufacturer's own current material** — model pages, press kits. The
   authority on how a name is *written* (casing, spacing, accents).
4. **Corroboration across independent registers** — ≥2 sources in ≥2 countries
   agreeing. This is the dataset's publish rule (`DECISIONS.md`), and it doubles
   as a shape test: two registers do not invent the same odd string by accident.
   Used by `scripts/lint_dataset.rb` to separate real nameplates from artifacts.
5. **Encyclopaedic sources** — fine for history and model years, never for
   "what the register says".

**Availability subset check before any drop.** A duplicate may only be nulled
once you have verified the canonical carries every country the dropped row had.
If it doesn't, you are deleting evidence: say so explicitly in the PR, per row.

### 2.1 The parser-before-data rule (learned the hard way, twice in one day)

> **A model name that is a bare integer, single-source, is a PARSER suspect
> before it is a DATA suspect. Resolve it against that source's raw snapshot
> before proposing any drop. Consecutive integers under one make are
> presumptively a shared-string/index leak — i.e. evidence the records are
> REAL.**
>
> **Recover the true name by RE-PARSING THE ROW, never by resolving the integer
> as a table index: shared-string tables are workbook-wide and will hand you a
> confident wrong answer from another sheet.**

Both halves of that rule are paid for in real damage:

- `XlsxLite` let an empty cell swallow the next cell's `<v>`, so KBA FZ10
  published shared-string **indices** as model names. 148 records, 29 makes.
  `volkswagen/552` was the **Golf** — Germany's best-selling car — while
  `volkswagen/golf` carried twelve countries and no `de`.
- The integers looked exactly like registry type-codes. One cleanup pass
  proposed deleting all 148; an earlier merged pass had already deleted SEAT's
  German lineup on that theory (`si[468..474]` = ATECA, BORN, FORMENTOR, IBIZA,
  LEON, TAVASCAN, TERRAMAR).
- The index-resolution shortcut then produced three confident wrong answers:
  `si[350]="ACTROS"` (a truck, in a cars-only sheet), `si[500]="SUZUKI"` (a
  make), `si[100]="Q6"` (while Audi 100 is also a real nameplate).

**Structural corroboration is a cheap triage filter, not proof.** A contiguous
run bracketed by structure — make header, alphabetical order, `ZUSAMMEN`
terminator — is good reason to go re-parse. It is never a reason to conclude.

## 3. Kind hygiene `[S4W]`

**`kind` is a dimension, not a guess.** The same nameplate may exist in several
kinds; each kind's files stand alone.

- **Passenger-car registers contain non-cars.** Camper and kombi conversions are
  registered as M1 in NL/DE/LU, so motorhome coachbuilders (Bürstner, Pössl,
  Niesmann+Bischoff, Moncayo…) appear as "car makes". Drop them **per kind** in
  `overrides/makes/drop.yml`. Deterministic test: RDW `inrichting=kampeerwagen`
  for ~100% of the make's rows.
- **Heavy trucks appear in German passenger-car tables** for the same reason —
  motorhomes on Actros/Arocs/FH chassis. Drop from `car`; they are correct in
  `truck`.
- **Drops are kind-scoped, and they fail silently.** `scripts/lint_dataset.rb`
  asserts that no published make matches any drop entry, under **either**
  transliteration convention (`ü→u` and `ü→ue`) — the gap that let `PÖSSL`
  coexist with a published `poessl` for a month. Entries newer than the last
  commit touching `dist/` are reported as *pending*, not failures, because
  `catalog/` is a monthly build output and lags the override layer.
- **Renames are make-scoped but kind-blind.** A key written for one kind fires
  in every kind of that make. Say so in the comment and add a spotcheck
  tripwire for the other kind.

## 4. Choosing a mechanism `[S4W]`

In pipeline order, because order decides what is even possible:

```
make aliases/drops → model drop_patterns → normalization (family rules,
prefix strip) → CASING (styling.yml) → RENAMES (renames.yml) → moves.yml
→ body types, aliases, popularity
```

1. **`makes/aliases.yml`** — raw make string → canonical marque. Also the
   identity-casing mechanism (`MITT: MITT`). Keys are UPPERCASE raws.
2. **`makes/drop.yml`** — the make does not belong in that kind at all.
3. **`models/drop_patterns.yml`** — a *class* of model strings leaking into a
   kind (regex, per kind).
4. **`styling.yml` `stylings:`** — whole-string display pin. Blast radius 1.
   **Prefer this.**
5. **`styling.yml` `acronyms:`** — a token cased everywhere, catalog-wide. Only
   with a full-catalog blast-radius sweep pasted into the PR, because **the
   caser runs BEFORE renames**: adding a token silently re-cases other records'
   rename keys and orphans them. Never land a token in the same PR as rename
   keys that depend on it.
6. **`models/renames.yml`** — fold a trim/variant into its nameplate, or `null`
   to drop. Keys are the **post-cased** name and the block key must be the
   make's canonical **display name** (`scripts/lint_curation.rb` enforces both).
7. **`models/moves.yml`** — cross-make move, when the register files a model
   under the wrong marque. Use instead of `null` whenever a correct home exists:
   nulling loses the evidence, moving keeps it.

**Rule-first.** If a defect class has more than ~20 instances, it is a pipeline
rule, not N override lines. Override lines that paper over a normalizer gap hide
it *and* reproduce it on the next ingest. Interim lines are allowed when
something is published wrong today, but they carry
`# INTERIM — superseded by <issue>` and count as `debt` in `data/name_shapes.yml`.

## 5. What "clean" means, and how it is measured `[S4W]`

`scripts/lint_dataset.rb` classifies every published record by name **shape** and
requires each flagged record to be explained in `data/name_shapes.yml`:

- `legit` — the shape is correct and permanent (`MAZDA3` is the nameplate).
  Entries must be shape-general and evidenced.
- `debt` — the shape is wrong and unfixed, with a `count` that may only go down.

**Spotless ≡ the `debt` section is empty and there are no unexplained suspects.**
Two buckets, not one: with a single bucket you reach zero by relabelling junk as
legitimate, which is how allowlists become landfills.

Definition of done is per **make-set**, never per kind-set: one make = one owner
across all kinds, so each maintainer holds records inside the other's kinds
(measured: 427 four-wheel records under two-wheel-owned makes, 81 the other way).

---

## 6. Granularity: trims, displacement, generations `[S2W]`

_To be written by the motorcycle/moped maintainer._ Expected content: the
trims-fold / displacement-stays rule, generation policy, and the altitude test
for two-wheeler families.

## 7. Code strings and display form `[S2W]`

_To be written by the motorcycle/moped maintainer._ Expected content: the
identity-vs-display split (a collapsed join key must never become the published
name), respacing rules, and the verdict split whereby a bare number is a
legitimate type designation in `truck`/`bus` (Mercedes 1824, Scania 143) and a
suspect in `car`.

## 8. Placeholders and embedded brands `[S2W]`

_To be written by the motorcycle/moped maintainer._ Expected content: what to do
with `N/A`-style rows (rename to the honest family rather than drop where a drop
would erase the make — the Sherco precedent), and make-prefix stripping.

## 9. Styling-token ownership table `[S2W]`

_To be written by the motorcycle/moped maintainer._ The measured list of
consonant-only tokens appearing in both halves' records, with the majority owner
who decides each and the minority holding a veto.
