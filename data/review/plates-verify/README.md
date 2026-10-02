# data/review/plates-verify/ — the PRD-PLATES §5.3 verification dossiers

One file per jurisdiction, `<code>.yml`, matching `plates/<code>.yml`.

This directory is the receipt behind PRD-PLATES §5.3. That section defines the
protocol but not the artifact, and until this file no §5.3 dossier existed
anywhere in the repo — the L1/L2/L3 waves shipped RESEARCH dossiers to the
private program dir (`vehiclesdb-pipeline/aux/research/plates-2026-07/`), and
PRD-PLATES §7.2 records the consequence in terms: *"the §5.3 HUMAN verification
pass is outstanding for both waves."* The research dossier says what the
researcher found. This one says what an independent reader found when they went
back to the statute without taking the researcher's word for anything.

## Why here and not under `plates/`

`scripts/lint_plates.rb` globs `plates/*.yml` **and** `plates/*/*.yml`, and
treats everything that is not under `_meta/`, `_decode/` or `_art/` as a
jurisdiction file. A dossier at `plates/_verify/at.yml` would therefore be
counted as a 125th jurisdiction and fail the gate. `data/review/` is already
the repo's declared verification-ledger home (`data/review/README.md`: *"the
verification ledger"*), so the dossiers live beside the catalog ledgers and the
five-nines audit ledgers, under the same researcher≠verifier discipline.

## The shape

```yaml
jurisdiction: at              # matches plates/<code>.yml
data_file: plates/at.yml
gate: L1                      # the PRD-PLATES §7 gate whose acceptance this feeds
researcher: <who built the data>      # NOT the signer of this file
verifier: <who re-derived it>         # MUST differ from researcher (I-11)
verified_at: 2026-08-08
base: <sha of origin/main the re-derivation ran against>

method:                       # how independence was preserved, in prose
routes:                       # every source actually opened, with exact URLs
claims:                       # one entry per series × claim family
findings:                     # disagreements, each with both readings verbatim
```

## The rules that bind a §5.3 verifier

- **Two routes minimum per claim family.** The PRIMARY statutory source already
  pinned in the data file, re-fetched and re-read; plus one route the data file
  does not use. A second reading of the same consolidated page is not a route.
- **MAJORITY IS NOT AUTHORITY.** Counts inform, the authority decides. Where
  sources disagree the dossier records BOTH readings verbatim and resolves on
  evidence weight, or resolves neither. Averaging is forbidden — the Spanish
  2000 cutover and the French SIV rollout are the named precedent cases.
- **Quote the relied-on sentence.** An evidence line carries the sentence it
  relies on, in the original language, not a paraphrase of it.
- **The verifier records; the maintainer applies.** A disagreement is appended
  to the data file as a dated verifier note that leaves the researcher's
  original text standing and visible — never a silent rewrite. The convention
  is the one set by `plates/pt.yml` at commit `151f727` (`SETTLED <date>: …`).
- **I-11.** The dossier's `verifier:` signs the re-derivation of the
  researcher's claims. Any NEW factual claim the verifier introduces is itself
  unverified research: it ships `status: awaiting_verification` with
  `countersigner: null`, and it does not silently become data.

## Verdict vocabulary

| verdict | meaning |
|---|---|
| `confirmed` | re-derived from the primary source and agreed, on two routes |
| `confirmed-upgraded` | agreed, and the verifier's route is stronger evidence than the one pinned (recorded so the maintainer can upgrade the pin) |
| `disagreement` | the data and the primary source do not agree; both readings recorded verbatim |
| `imprecise` | the claim is right but its stated basis is not |
| `unverifiable/source-gap` | two named routes failed |
| `unverifiable/not-attempted` | out of this pass's scope, named as such |

## Two shapes, one shelf (amended 2026-09-05, S4W/PLT)

Two dossier PRs shipped the same week with different homes — `plates/
_verification/<code>.md` (Belgium, Andorra) and this directory (Austria).
Both arguments for the location were the same (`lint_plates.rb` globs
`plates/*.yml` and `plates/*/*.yml`, so a `.yml` under `plates/` is a
phantom jurisdiction), and `data/review/` is the declared ledger home, so
this is the one shelf. Both SHAPES are accepted:

- `<code>.yml` — the claim ledger above (Austria is the exemplar).
- `<code>.md` — a prose dossier with the same seven parts (header, method/
  independence, instrument chain, per-series verdicts, disagreements
  verbatim, recommendations, gate proof); Belgium and Andorra are the
  exemplars.

Either way the rules in this README bind, and the data file carries a
dated note pointing at the dossier. Ids never change on a verification —
`period` moves, the id embedding the old year stays (append-only).
