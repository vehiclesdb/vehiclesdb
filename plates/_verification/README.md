# `plates/_verification/` — the PRD-PLATES § 5.3 dossier shelf

One Markdown dossier per jurisdiction, named `<code>.md`, sitting beside the
`plates/<code>.yml` it verifies.

## Why this directory exists, and why Markdown

PRD-PLATES § 5.3 defines a three-role protocol: **researcher** builds the
series list with per-claim citations, an **independent verifier** re-derives
period boundaries and formats from primary sources, and the **maintainer**
applies. The researcher half of that protocol already had a home — the
private archive at `vehiclesdb-pipeline/aux/research/plates-2026-07/`
(`dossier-l1-<code>.md`, per PRD-PLATES § 8). The verifier half had none, and
PRD-PLATES § 7.2 records the consequence: "the § 5.3 HUMAN verification pass
is outstanding for both waves". A verification that lives only in a PR body
cannot be re-read by the next pass, so it lands here, in the open repo, next
to the data whose claims it tests.

**Markdown, not YAML, and that is load-bearing.** `scripts/lint_plates.rb`
enumerates `plates/*.yml` **and `plates/*/*.yml`**, and treats every hit that
is not under `_meta/`, `_decode/` or `_art/` as a jurisdiction file carrying
series. A `plates/_verification/<code>.yml` would therefore be linted as a
124th-plus jurisdiction and fail the gate. A `.md` file is invisible to that
glob, so the dossier shelf cannot perturb the `124 files, 1381 series` count.

## The shape

Ported from the five-nines verifier ledgers
(`data/review/audit-v2026.07.5/ledger/verifier-*.yml`), which are the
"established shape" § 5.3 refers to:

1. **Header** — jurisdiction, gate, protocol, researcher, verifier, status.
2. **METHOD / independence** — which routes were read, in which order, and
   what was deliberately *not* read before re-deriving.
3. **The instrument chain** — every period boundary in the file traced to the
   entry-into-force article that fixes it, quoted.
4. **Per-series verdicts** — period, format, class, colours, one row per
   series, verdict CONFIRMED / DISAGREEMENT / UNVERIFIABLE.
5. **Disagreements, verbatim** — both readings preserved side by side.
6. **Recommendations** — for the maintainer. The verifier changes no data.
7. **Gate proof** — the lint output before and after.

## The two rules that bind every dossier here

- **MAJORITY IS NOT AUTHORITY; the authority is the authority.** Where sources
  disagree the disagreement is recorded verbatim and both readings are kept.
  Dates are never averaged, split, or resolved by counting sources. The
  Spanish 2000 cutover and the French SIV rollout are the named precedents.
- **I-11: researcher ≠ verifier.** A single session never signs both roles.
  A dossier whose findings originate new claims ships
  `status: awaiting_verification` with `verifier: null`.

## Invariant for anyone acting on a dossier's recommendations

Series ids are **append-only** and are never deleted. Where a recommendation
corrects a `period.start` on a series whose id embeds the old year, the fix is
to the `period` field only — **the id does not change**.
