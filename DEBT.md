# DEBT — the consolidated open-work ledger (4W half)

> The p99.999 program (PRD-FIVE-NINES.md) re-prioritizes this ledger after
> each audit round; enrichment/coverage items below feed its workstreams.

*Created 2026-07-26 at the end of the owner-AFK stretch. One line per item,
with owner, source-of-record, and what resolves it. Items here are FILED, not
forgotten — each was deliberately deferred with a reason. When you take one,
delete its line in the same PR. S2W's half keeps its own ledger in
`data/name_shapes.yml` (`debt:` entries) and their NEGOTIATION turns.*

## Curation passes (renames/folds, per-family)

| item | source of record | what resolves it |
|---|---|---|
| Chevrolet `Lt`/`Ltz` family (9 records, uniformly wrong) | #78 dossier §6.4 | marque styling check (chevrolet.com trim pages) + one family pass; the `Hhr Lt` line was deliberately half-done to avoid a new contradiction |
| Chevrolet `Trail Blazer` vs `TrailBlazer` direction | #78 dossier §6.5 | GM styles it TrailBlazer; repointing the settled spaced lines is a direction change — needs its own reviewed pass |
| Chevrolet SS acronym family + S-10 family | #63 dossier (american tail) | the S-10 pass needs a live GM citation (brochure archive is gone); SS records now fixed per-record, the styling-pin question stays closed (blast radius) |
| Ferrari `Gta` residue (post-#36) | #78 dossier §6.1 | one key (`456 GT/Gta`) once the GTA badge is sourced |
| Nissan `Sr` (4 records, uniformly wrong) | #78 dossier §6.2 | marque check; interacts with the aprilia/yamaha SR fixes (#79) — per-record, no pin |
| Volvo `Se` residue (4 records) | #78 dossier §6.3 | the SE pin (below) or four per-record lines |
| **`SE` styling pin** — the one pin worth doing | #78 dossier §7 | 63 records / 22 makes, all officially caps; costs 18 rekeys, all enumerated in the dossier; S4W-owned; ship as its own PR with every rekey in the same commit (the #71 lesson) |
| Jaguar Mk split family (`Mki`/`Mk 1` = one car at two live ids; `Mk 5/7/10` contradict source) | #63 dossier U1 | per-model split rule (Mark 1/2 arabic, VII–X Roman), needs its own pass |
| Daimler V8-250 inversion (source spells the car V8-250; five ids for one car) | #63 dossier U2, ready inversion block in-dossier | maintainer decision to reverse the settled line; inversion block is paste-ready |
| Morris `mini-mk-2` dangling (Austin and Morris now spell the same car differently) | #63 dossier U6 | would mint `morris/mini-mkii`; take it with the next Morris touch |
| Austin-Healey Mk family (~10 records: `3000-mk1`, `3000-mk`, `sprite-mk*`, `healy-mk3` typo) | #72 dossier §6 | one dedicated family pass; the `AUSTIN HEALEY` aliases fix (#72) already protects es rows |
| Mazda RX7-stem family (~8 raws: `RX7 GT-X`, `RX7 TURBO`…) | #63 dossier (mazda §13 adjacent) | one family pass in the settled RX-7 direction |
| Chrysler `300C: "300 C"` (settled line contradicts source; nl_rdw `300C` ×968) | #72 dossier §7 | 9-country repoint — needs its own reviewed pass |
| Datsun spaced Z-cars (`240Z: 240 Z` etc., generated boilerplate vs fused source) | #72 dossier §8 | re-source the five lines; `280ZX` (fixed) sits beside `280 Z` until then |
| Kia `ceed-1` / `ed-ceed` noise ids; `BX 1` truncated-displacement id | #78 dossier §1/§8 | raw-row evidence passes |
| FAW/Hongqi make attribution (`E-HS9` is a Hongqi) | #72 dossier §9 | `moves.yml` decision (`FAW\|E-HS9 → Hongqi\|E-HS9`), plus the hongqi-ehs7 sibling |
| VW alias-merge cluster (`beatle`/`bug`/`toureg`/`tranporter`…) | pipeline #30 PR body | wants MERGING not enriching; one dossier pass |
| Nissan 350Z/370Z lane-A (shipped keys are detector space-inserting artifacts) | #61 dossier | its own reviewed pass — do not drive-by reverse |
| ~40 unverified uniformly-wrong candidates (vespa GTS/GTV, ural CT, verge TS, triumph SD, yamaha CJ/NS/DA…) | #79 PR body | per-marque styling checks; the two-halves evidence rule is binding (cross-make attestation AND marque styling) |

## Structural / pipeline

| item | source of record | what resolves it |
|---|---|---|
| U7 variant-strip Roman collapse (spaced Roman numerals stripped pre-rename → unresolvable truncated ids: `austin/healey-3000-mk`, `jaguar/mk` 5-country…) | #63 dossier U7 | normalizer change with its own blast-radius measurement |
| `VARIANT_SUFFIXES` `.*` tails destroy model info (`VW KOMBI 1500` ≠ `VW VARIANT 1600`) | #78 dossier §3 | normalizer design question, not curation |
| Post-release fold-key cleanup habit | #70 precedent (double-space keys), pipeline #31/#33 | at each release: prune rename keys and enrich twins whose producing raws/ids died — the insurance lint (#34) now catches the enrich half at PR time |
| Kind-boundary proposal (van/411 is a car; t2–t6/lt/vanagon in car kind) | `PROPOSAL-kind-boundary.md` + pipeline #30 PR body | owner review of the proposal |

## Enrichment (the big lever)

| item | source of record | what resolves it |
|---|---|---|
| **G26c Wikidata bulk import** — the next major enrichment program | PRD-QUALITY §14, PRD-PAID §2 | CC0 bulk source; staging + graduation through lint_enrich; conflicts lose to curation. Unbuilt. |
| G26d fueleconomy.gov per-year-per-trim specs | PRD-PAID §2 | spec'd, unbuilt; feeds catalog-plus |
| Coverage: 4W enrich sweep beyond the ~30 makes done | pipeline enrich/ (39 files, 506 ids) | continue the swarm pattern (research → verify → land) per marque |
