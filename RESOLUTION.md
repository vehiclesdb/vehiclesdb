# RESOLUTION — one contract for turning a typed vehicle name into a record

**Status:** binding for every VehiclesDB surface that matches a make or model
string: the `vehicles` Ruby gem, `POST /api/v1/resolve`, the catalog API
endpoints, the `make-model-dropdown` widget, the JS and Python SDKs, and any
future port. Added 2026-11-09.

**Why this file exists.** Dogfooding VehiclesDB inside CarHey (a Spanish
ride-sharing app) showed 41 distinct make/model pairs its drivers typed that
no surface could resolve — "2008 Allure", "Tucson IX35", "Nuevo Citroën C3
Aircr", "Insigna", "Toureg", "Marco". Thirty-six were *already curated in this
dataset* (`overrides/models/renames.yml`) and never left the build. An
inventory of the surfaces then found six independent matchers that disagreed:
the widget did not fold diacritics ("citroen" missed "Citroën"), the gem
ignored published model aliases, the API had no spacing fold ("Kia XCeed"),
the SDKs had no typo tolerance, and the "method" labels used three
vocabularies. A consumer must get the same answer whichever door it uses.
This file is the single source of truth; `conformance/resolve.json` is its
executable form.

## 1. Data the contract reads (all in `dist/vehicles.json`)

| field | level | meaning |
|---|---|---|
| make `name`, `slug` | make | canonical identity |
| make `aliases` | make | published alternate names (nicknames, initialisms, scripts) — `overrides/makes/search_aliases.yml` |
| model `name`, `slug`, `kind` | model | canonical identity |
| model `aliases` | model | published alternate names — `overrides/models/aliases.yml` |
| model `forms` | model | curated registry/user spellings that fold into the record, **make-scoped** — projected from `overrides/models/renames.yml` (SCHEMA.md) |
| model `former_ids` | model | ids this record replaced |

**Only published data counts.** An implementation never carries a private
alias table of its own (the gem's historical built-in make aliases are now all
published here). Knowledge lives in the dataset or it does not exist; that is
what keeps the languages in agreement.

## 2. Normalization — exactly one function

```
norm(s) = NFKD(s) → drop combining marks (\p{Mn}) → lowercase
          → every run of non-[a-z0-9] becomes one space → trim
```

"Škoda" → `skoda`, "Mercedes-Benz" → `mercedes benz`, "C3 Aircross" →
`c3 aircross`, "Lynk & Co" → `lynk co`. **Spacing-blind** comparison is
`norm(s)` with spaces removed (`xceed` = "X Ceed", `a 5` = "A5", `v ette` =
the alias "Vette"); it applies to names, aliases and forms alike, each at its
own rung, and is only accepted when it lands on exactly one record. Every surface — including
the widget's client-side filter — uses this function.

## 3. The ladder

Two entry points, same rungs:

- **pair** — `make` and `model` arrive separately (forms, CRMs, CarHey).
- **text** — one string ("vw golf", "MERCEDES-BENZ | SPRINTER"). The make is
  taken as the **longest** leading token run that resolves as a make; the rest
  is the model. Rungs 1, 2 and 6 below may answer a whole text without a make.

Make resolution: canonical `slug` / `name` → published make `aliases` (all by
`norm`) → **make typo** (bounded edit distance, §4). Model resolution inside
the resolved make, strongest first; **the first rung that answers wins, and an
ambiguous rung stops the ladder** (no weaker rung may override it):

| # | rung | `method` | confidence | notes |
|---|---|---|---|---|
| 1 | canonical id, verbatim (`car/volkswagen/golf`) | `exact` | 1.00 | text only |
| 2 | a published `former_ids` value | `former_id` | 0.98 | text only |
| 3 | model `name` or `slug`, by `norm`, then spacing-blind, then BMW-style "Serie N" → "N Series" | `fold` | 0.97 | |
| 4 | a published model `alias` within the make | `alias` | 0.93 | |
| 5 | a `form` within the make | `form` | 0.92 | |
| 6 | the **whole text** is one model's published alias, unambiguous across all makes, and no other record is *named* that | `alias` | 0.90 | text only, no make needed |
| 7 | **cleanup**, then retry 3–5: strip an anchored, *complete* make name / slug / alias echoed at the start of the model ("Citroën C3", "Lynk And Co 01" — `&` reads as `and`) and leading "new" fillers (`nuevo nueva new neu neue nouveau nouvelle nuovo nuova novo nova`); never strip a token that is itself a model name of that make; an empty remainder is **no match** (Honda + "Honda") | `cleaned` | 0.90 | |
| 8 | **model typo**, §4 | `fuzzy` | 0.80 | |

A make reached through the make-typo path caps the answer at 0.80 and labels
it `fuzzy`, and rung 8 never runs on top of it (no stacked guesses).

Confidences are **fixed rung labels**, not probabilities. `via` (the audit
trail) lists every transformation: `make_alias:vw→volkswagen`,
`make_typo:marcedes→mercedes-benz`, `filler:nuevo`, `make_echo:citroen`,
`form:2008 allure→2008`, `model_typo:insigna→insignia`, `kind_hint:van`.

**Strict vs lenient.** Rungs 1–6 are curated data — every surface applies them
by default (`Vehicles.model`, `/resolve`, SDK `resolve`, widget preselection).
Rungs 7–8 are heuristics, exposed where the caller asked for best effort
(`Vehicles.match_model`, `/resolve`, SDK `resolve`). **Validators stay
strict** (name/slug only): a picker value is either a real record name or it
is not.

**Nothing resolves without a make** except rungs 1, 2 and 6: `resolve("golf")`
and `resolve("Rabbit")` are null (SDK adjudication 2026-07-27).

**Kind collisions are not ambiguity.** "Iveco Daily" as van and truck is the
dataset working. Pass `kind` to choose; without it the gem's `Vehicles.model`
keeps its historical car preference and the API/SDKs use the tie-break
(lowest `global_decile` → wider availability → kind order → id). Conformance
cases with a kind collision always pass `kind`.

## 4. Typo tolerance — two rule sets, on purpose

Distance is **optimal string alignment** (Levenshtein + adjacent transposition
counts 1: "telsa" is one edit from "tesla"). Only human-shaped input is ever
fuzzed: anything containing `/ _ + \`, a leading/trailing/double hyphen, or a
single-case hyphenated token (`marcedes-benz`, `MARCEDES-BENZ`) is machine input
and resolves exactly or not at all. The check runs on the **raw** input before
normalization, per whitespace-separated token: in **text** entry, one
machine-shaped token anywhere disables both typo rungs for the whole string
(`"marcedes-benz gla"` is null, exactly like the pair `marcedes-benz` + `GLA`).

**Make typo** (shipped in the gem since 0.7.8; the reference):
- query ≥ 4 characters; budget **1 edit for 4–5 characters, 2 from 6**;
- candidates are make names, slugs and published aliases (normalized); skip any
  whose length differs by more than the budget;
- a candidate may never have **fewer words** than the query;
- first letters agree **word for word** when word counts match, otherwise only
  the first letter of the whole string;
- the closest make must be **unique**; a tie means **no make** (null, not
  ambiguous) — "acra" is one edit from Acura and Acma.

**Model typo** (rung 8; stricter, because model names are short, numerous and
full of near-identical codes):
- whole cleaned model ≥ 4 characters; compared **word by word**, same number of
  words on both sides (spacing slips are rung 3's job);
- a word that differs must keep its first letter, contain **no digit** on either
  side ("2008"≠"208", "308"≠"3008", "TRX250R"≠"TLR250R"), and be ≥ 4 letters on
  both sides ("Passat GT" is not "Passat GL"; "Cdi", "Xgt" are nothing);
- 1 edit per differing word, 2 from 9 letters; total within the make budget;
- candidates: the make's model names, aliases and forms; the closest **model
  record** must be unique — a tie is **ambiguous** (Toyota "Corola": Corolla
  and Corona).

## 5. Results

`{ match: {id, name, make:{id,name}, kind, confidence, method} | null,
alternates: [...], resolved_via: [...] }` (the API's shape; libraries return
the same facts as objects). **Ambiguity** = `match: null` with the competing
records as alternates — distinct from "nothing matched" (empty alternates or
below-floor suggestions only).

## 6. Conformance

`conformance/resolve.json` holds the cases: entry point (`pair`/`text`),
input, optional `kind`, expected id (or `null`, or `"ambiguous"`), expected
`method`, and the minimum dataset version. **Every implementation runs it in
its own test suite against the dataset version it ships**, and a release that
changes an expected answer updates the case in the same PR with the reason.
Adding a case is how a dogfooding finding becomes permanent: the CarHey 41 are
in there.

## 7. Not in this contract (API-only, by design)

`/resolve` may add **private** rungs between 6 and 7 — the register-grade
normalizer and the observed raw-forms index built from official registers
(PRD-PAID "Engine architecture"). They can only turn a dataset-tier `null`
into an answer; they never change a dataset-tier answer. That keeps the open
contract honest while the paid engine stays deeper.
