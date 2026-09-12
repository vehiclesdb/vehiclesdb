# COV4 researcher rules — single-source-country coverage sweeps, 4W

Rebuilt 2026-09-12 (the predecessor's copy was lost with the shared scratchpad).
Binding on every researcher in this lane. The manager re-derives every batch
before it ships (I-11: you never certify your own work).

## What you are doing

A register writes a nameplate with a trim tail, a market suffix, a model-year
code or a local spelling. The pipeline normalizes it, fails to recognise it, and
the vehicles either land as their own junk slug in `build/candidates/` or are
dropped by `junk?`. Either way the catalog silently loses a country on a
nameplate **it already publishes**. Your job is to prove, string by string, that
a candidate string denotes an already-published nameplate — or to refuse.

## The one output per string

For each string in your packet, return exactly one of:

- **FOLD** — `probed_key` → `target_name`, with a **page-level URL** on the
  maker's or the regulator's own site that shows the string is a spelling /
  trim / parenthetical / market variant **of that nameplate**, plus the access
  date and the evidence tier, plus how you verified it (**opened directly** or
  **verified through the search index** — say which; never claim a page you
  could not open).
- **REFUSE** — with the reason and the same quality of citation. A refusal with
  evidence is worth more than a fold without it.
- **UNRESOLVED** — you could not find a page-level source. Say so. Do not guess.

`target_name` is the **published record's own display name**, copied exactly.
You are not inventing a spelling.

## The refusals that are mandatory

1. **A separate model page means a separate nameplate.** The DECISIONS fold
   safeguard is binding: a published record that contradicts the fold beats any
   pattern rule, however tidy. The model is the **Onix / Onix Plus** refusal —
   Chevrolet Argentina publishes two model pages (4.16 m/303 l vs 4.47 m/500 l),
   so they are two nameplates of 731 and 384 vehicles, **not** one of 1,115 that
   would have cleared the publication threshold. The threshold is not a target
   to be reached by merging two real nameplates.
   The same trap, already found in this lane: **`BYD Seal 5` is not a `byd/seal`
   trim**, it is a distinct nameplate.
2. **Never null a real nameplate.** A rename to `nil` deletes evidence. If a
   string is a real machine we do not publish, it is UNRESOLVED or a
   below-threshold candidate — never a null.
3. **Never mint an id from one source below the kind threshold** (cars: 1,000
   vehicles). A sub-threshold LatAm/JDM nameplate still gets folded to the
   *correct* nameplate and is left in `candidates/` for a second register to
   corroborate. That is the mechanism working, not a loss.
4. **A cross-make relocation is a MOVE, not a rename.** Report it; do not write
   it. Moves are `overrides/models/moves.yml` and are adjudicated separately.
5. **A licence class, a body code, an engine designation or a model-year code is
   not a nameplate.** Measured examples from this lane: Peugeot `T200` = the 1.0
   turbo 120 CV engine; `AM26` = *année-modèle*; Vespa `25KM/UUR` = a Dutch
   licence class. Say which one it is in the dossier.
6. **A grade/trim code you cannot source is UNRESOLVED**, however obvious it
   looks. NZ's register is full of JDM grade codes; an unsourced guess about one
   is exactly the defect this lane exists to prevent.

## The key you write

The packet gives you `probed_key` — the string the build **actually looks up**
at `@o.model_renames[make]` (normalizer.rb, after `family_nameplate` and both
`collapse_variant` passes, smart-cased). Copy it byte for byte. It is not the
raw register string and it is not the string you would have guessed. A key on
anything else is inert, and the manager will catch it.

Write the **full** probed string, never a shortened prefix: the reachability
test is kind-blind and a short prefix can reach another kind's catalog.

## Evidence quality

- Page-level URLs only. A maker's home page or a search results page is not a
  citation.
- Every fact the page states that we could store — body style, engine, power,
  years, market, generation, dimensions — goes in the dossier even if this batch
  does not write it. This lane's doctrine is COMPLETENESS: the page was opened
  once; harvest it once.
- Manufacturer sites in some markets hard-block automated fetch (measured in AR:
  ford/peugeot/toyota return 403 to WebFetch *and* curl with a browser UA).
  Regulator pages, official press libraries and manufacturer PDF spec sheets are
  the fallback, and are often better sources anyway.
- Wikipedia is corroboration, never the only source, and is tagged as such.

## What you never do

You never edit the repo, never run a build, never open a PR, never merge. You
return a report. The manager writes the YAML, runs the control-vs-treatment
build, and only then does anything ship.
