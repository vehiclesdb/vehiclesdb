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

## From the baseline audit (2026-07-26 — see data/review/audit-v2026.07.5/RESULTS.md)

| item | source of record | what resolves it |
|---|---|---|
| **Truncation/family stubs** — the largest measured defect generator (setra/s, bmw/z-reihe 7,143 regs, bmw/i, volvo/b, ford/f, scania-vabis/l) | RESULTS §New-1 | detector (single-token id prefixing ≥2 live siblings) + the VARIANT_SUFFIXES/series-collapse normalizer cure above; folds with the disposition pair |
| tesla/y → model-y retirement (headline; wheelbase-proven) | RESULTS + verify-3 | fold+alias, one PR |
| Connector-merge detector (oder/ou/slash/space + make axis) | RESULTS §New-2 | extend D13's detector wordlist + make-axis pass |
| Converter-brand-as-nameplate (D5b) detector | RESULTS §New-3 | one-model-string-under-≥2-chassis-makes scan |
| TAN hygiene: strip `- (FMVSS)` literals (35 records, fi TAN column) + TAN-overlap caveat in NAMING §2 + a TAN-oracle duplicate detector | RESULTS §New-4 | pipeline fi_traficom fix + NAMING amendment + new detector |
| Source-forced kind: us_fueleconomy/ca_nrcan hardcode kinds=[:car] with unused class columns | RESULTS §New-5 | pipeline: map the class columns |
| Typo-split detector (edit-distance-1 in-make siblings) | RESULTS §New-6 | new detector; Spinter/Spriner/Srinter exemplars |
| Raw-layer fold detector (collisions in raws invisible in published names) | RESULTS §New-7 | detector over observed_variants |
| NISMO casing family + the 11 title-cased model-name initialisms (Atf/Dt/Sk/…) | verify-2, ledger-4 | per-make passes under the two-halves evidence rule |
| global_decile is an unweighted rank MEAN — variance-collapses broad records to mid-bands, inflates thin single-country ones (2W measured: 30.2% of 1-country records at d1; 7-country 0% at d1) | NEGOTIATION T129/T133/T137; PRD-FIVE-NINES §1.3.1 | reconciler: weight each country's decile by its model population; never a per-record certification filter meanwhile |
| Verdict-note consistency lint for audit ledgers (protocol v1.3 rule 12; the brixton case) | RESULTS-s2w §amendments | grep-able verdict-vs-note contradiction classes over data/review |
| us_fueleconomy `baseModel` column (col 66, never read) — a regulator's own model-vs-trim oracle, 340 Ford triples alone | Ford trim dossier §0 | pipeline: read it into a granularity oracle for trim-fold adjudication |
| Three pre-existing dead rename keys, surfaced by propose_former_ids in three independent wave-3 applies: chrysler `Town&country Touring`, hyundai `Atos-Prime`, jaguar `Xj-Sc` (yamaha `Mt  09SP` handed to S2W, Turn 156) | wave-3 apply PR bodies (#106/#108/#112) | per-key raw check → re-key to produced form or delete-with-comment |
| Hygiene-2 normalizer queue (freeze lifted 2026-07-27): AMG stub 74,727 regs w/ EPA targets · comma-decimal + 2.0T junk rules · hyundai family regex (\d0)(?!\d) · make-fragment strips LAND/MICRO/HD · per-kind rename scope (5 attestations) · single-digit junk rule · RDW decimal-comma · SPORT TOURER suffix · TRAFFIC/MASCOTT drops · Tesla quote-char · series_collapse multi-word first-token · 814D D-exemption | wave-3 dossiers, aux/research/trims-2026-07/ | one measured control build EACH; tight batching; folds keyed on today's strings are the fragile side |
| The #42 remainder: bare-letter pooling from HYPHENATED/pre-fused/slashed natives (stem rule `\A([A-Z]{2,})-?\d`) — 15 of #117's Group B are live pooling stubs; triage queue = 327 bare 1-2-letter candidates with ≥2 natives (true size 15<n<327: real pooling vs REAL two-letter nameplates (bmw/ix, lexus/lx) vs spelling seams — the shape cannot discriminate, per-id review required). Cheapest repro: truck/scania/lt, 23 vehicles | NEGOTIATION 182-183 | hygiene-2: per-id triage w/ G-5-style discipline, never a regex |
| **ROOT CAUSE FOUND** for the filed "make-fragment strips LAND/MICRO/HD" line: `overrides.rb:53` merges `overrides/makes/search_aliases.yml` — *published marketing nicknames* — into the ingest alias map, and `series_collapse` derives its known-make word set from that merged map. All 46 nicknames become token-eaters in truck/bus: `Chevy`, `VW`, `Vdub`, `Beemer`, `Merc`, `Benz`, `MB`, `Alfa`, `Lambo`, **`HD`**, `Harley`. Measured symptom: both decile-1 Chevrolet truck records are Finnish type codes published as nameplates (`20-Starcraft-3.9T-FG25F`, 613 regs) because CHEVY and VAN are both eaten | Chevrolet wave-4 dossier §pipeline-findings | one-line fix (derive the word set from ingest aliases only, not search aliases) + a measured control build; it changes produced strings, so it must NOT ship while fold waves keyed on today's strings are in flight |
| Increment 3's store is LOCAL-ONLY and unbacked: it writes to `archive/registrations/`, and `archive/` is gitignored as the raw-dump never-in-git zone (568 MB of register dumps, excluded for licensing under R3/R6). An asset whose whole premise is "history no one can recreate" currently survives exactly one `rm -rf` | pipeline#92 review, 2026-08-01 | OWNER DECISION: where the durable copy lives. Derived aggregate counts are already sold in the private layer, so committing them to the PRIVATE pipeline repo under a path outside the raw-dump rule looks consistent with existing posture — but it is a licensing call, not an engineering one. CI persistence is a second step (builds run in the data repo's CI against an ephemeral pipeline checkout) |
| `ca`/`us` publish `"ca": 0` / `"us": 0` in the private layer for 1,231 and 1,412 car records — a catalog adapter's `nil` becomes 0 via `counts[cc] += row.count.to_i`, so "not measured" renders as "zero vehicles" | pipeline#92 guard, first run | cosmetic in the private layer today and excluded from the archive on its declared basis; fix the nil-to-zero coercion at the source and let a catalog country that starts producing real counts fail the build (that guard already exists) |
| `df_VEH0120_UK.csv` carries ~45 quarterly columns back to 2015 Q1 and `uk_dft` reads only the newest — a genuine RETROACTIVE `gb` backfill sitting in a file we already download | pipeline#92 §free-finding | its own increment: parse cost only, no new network calls, and it would give the time series a decade of real history on day one |
