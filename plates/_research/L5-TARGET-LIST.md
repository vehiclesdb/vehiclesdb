# L5 target list — every jurisdiction with no `plates/<code>.yml`

*Produced by S4W/PLT, 2026-09-05, during the owner-token stretch. Researched by
an Opus researcher; the mechanical core (coverage set, seed check, insular-area
status, naming convention) was RE-DERIVED INDEPENDENTLY by the manager before
publication — see §0. The fleet/penetration figures were NOT independently
re-derived: they are the researcher's, at the tier stated in §2, and a verifier
pass is still owed. Do not treat the numbers as certified; treat the ORDERING as
a defensible working plan and the COVERAGE SET as certified.*

**Status: WIP branch only. Nothing here is merged to main.**

## 0 · Manager-verified facts (re-derived from the repo, not from the report)

Verified by the manager against `plates/*.yml` in the release worktree:

- **124 files = 47 sovereign + 8 `au-*` + 13 `ca-*` + 56 `us-*`.** Zero other
  hyphenated codes.
- **Naming convention is FLAT**: `plates/<code>.yml` for sovereign states,
  `plates/<country>-<subdiv>.yml` for the three federations. There is **no**
  `plates/us/<suffix>.yml` directory — **PRD-PLATES §2.1 is stale on this point**
  and should be amended. No `us.yml` / `ca.yml` / `au.yml` parent files exist.
- **All 35 of the owner's seed jurisdictions are genuinely missing** — not one of
  `tr eg ng sa ae pk id vn ph ke ma dz ir iq il co pe cl ve ec kz uz ge am az lk
  bd np mm kh la tw hk mo sg` has a file.
- **All five US insular areas are already covered** (`us-pr us-gu us-vi us-as
  us-mp`) — they must NOT be re-added as `pr`/`gu`/`vi`/`as`/`mp`.
- **`va` (Vatican) is covered; `ps` (Palestine) is not** — so of the two UN
  observer states, only Palestine is missing.

Covered sovereign codes (47):
`ad ar at be br ch cn cy cz de dk ee es fi fr gb gr hr hu ie in is it jp kr li
lt lu lv mc mt mx my nl no nz pl pt ro se si sk sm th ua va za`

## 1 · Size of the gap

| bucket | count |
|---|---|
| UN member states missing | 144 |
| UN observer states missing | 1 (`ps`) |
| ISO-coded dependencies / special-status missing | 44 |
| non-ISO de-facto entities (need a ruling before any file lands) | 7 |
| **total addressable to close L5** | **~196 files** |

Reaching the stretch target of 180+ jurisdictions needs ~56 new files; closing
L5 completely needs ~196.

## 2 · Method behind the ranking (state it when citing these numbers)

- **Fleet** = total registered motor vehicles with year, from the cross-national
  table at <https://en.wikipedia.org/wiki/List_of_countries_by_vehicles_per_capita>
  (one consistent basis, national-registry cited per row). Where absent —
  most dependencies — **population is used and marked `pop-proxy`**. Unsourced
  values are marked `unknown` and were **not invented**.
- **Audience proxy** = population × ITU internet-penetration, banded
  H (>80%) / M (40–80%) / L (<40%) rather than given a spurious precision.
- **Expected value** = fleet × online-population band, per the owner's power law.
- ⚠ **Known distortion:** the fleet column counts four-wheelers only in several
  Asian states. Vietnam's 4.18M and Indonesia's 23.05M badly understate
  plate-bearing stock (VN has ~65M registered motorcycles + ~6.8M cars). Both are
  ranked on true plated stock, not the table figure. Any future re-rank must
  keep this correction or it will mis-order Southeast Asia.

## 3 · HEAD — ranks 1–35 (the owner's seeds, validated and re-ordered by mass)

| # | code | jurisdiction | fleet / proxy | net |
|---|---|---|---|---|
| 1 | tr | Türkiye | 33,612,656 (2025) | H |
| 2 | id | Indonesia | 23.05M 4-wheel; far higher with motorcycles | M |
| 3 | pk | Pakistan | 30,000,000 (2023) | M |
| 4 | ir | Iran | 15,963,000 (2020) | H |
| 5 | ph | Philippines | 20,465,515 (2024) | M |
| 6 | ng | Nigeria | 13,500,000 (2021) | M |
| 7 | co | Colombia | 13,477,996 (2017) | M |
| 8 | eg | Egypt | 9,950,000 (2023) | M |
| 9 | vn | Vietnam | ~70M plated (6.8M cars + ~65M motorcycles) | H |
| 10 | lk | Sri Lanka | 8,352,213 (2022) | M |
| 11 | dz | Algeria | 7,731,664 (2020) | M |
| 12 | mm | Myanmar | 7,138,410 (2022) | M |
| 13 | sa | Saudi Arabia | 6,895,799 (2016) | H |
| 14 | cl | Chile | 6,100,000 (2022) | H |
| 15 | bd | Bangladesh | 5,982,765 (2024) | M |
| 16 | pe | Peru | 5,604,789 (2016) | H |
| 17 | kz | Kazakhstan | 5,085,400 (2023) | H |
| 18 | iq | Iraq | 4,715,000 (2020) | H |
| 19 | ve | Venezuela | 4,235,000 (2020) | M |
| 20 | ma | Morocco | 4,120,000 (2020) | H |
| 21 | il | Israel | 4,000,000 (2022) | H |
| 22 | ae | UAE | ~3.5M on road (2024) | H |
| 23 | uz | Uzbekistan | 3,051,734 (2022) | H |
| 24 | ke | Kenya | 2,979,910 (2016) | L |
| 25 | ec | Ecuador | 2,535,853 (2021) | M |
| 26 | np | Nepal | 2,339,169 (2015) | H |
| 27 | ge | Georgia | 1,680,400 (2024) | H |
| 28 | az | Azerbaijan | 1,738,940 (2023) | H |
| 29 | tw | Taiwan | 23,353,315 (2025) — non-UN, ISO `tw` | H |
| 30 | la | Laos | 3,116,550 (2022) | M |
| 31 | am | Armenia | 900,692 (2024) | H |
| 32 | sg | Singapore | 996,732 (2023) | H |
| 33 | hk | Hong Kong | 925,171 (2022) — SAR | H |
| 34 | kh | Cambodia | 370,000 (2023) | M |
| 35 | mo | Macau | 251,867 (2023) — SAR | H |

**Seed-order deltas worth the owner's attention:** `ir` (16.0M), `co` (13.5M) and
`lk` (8.35M) are larger fleets than several seeds ranked above them in the
original brief; `id`/`vn` outrank `ng`/`sa` once motorcycles count. `tw` is the
single largest un-covered fleet after `tr` and arguably belongs at rank 2–3.

## 4 · MID — ranks 36–80 (remaining UN members with material fleets)

`ru`(53.0M, sanctions/sourcing risk) `sy`(9.81M) `do`(5.81M) `ly`(3.26M)
`gt`(3.25M) `bg`(3.01M) `cr`(2.60M) `rs`(2.57M) `kw`(2.52M) `af`(2.34M, L)
`tz`(2.16M) `bf`(2.11M) `gh`(2.07M) `tn`(2.02M) `jo`(2.00M) `lb`(1.87M)
`bo`(1.71M) `om`(1.70M) `hn`(1.69M) `ug`(1.59M) `zw`(1.47M) `qa`(1.33M)
`kg`(1.30M) `pa`(1.29M) `sd`(1.25M) `et`(1.20M) `mn`(1.19M) `td`(1.12M)
`lr`(1.09M) `sv`(1.01M) `md`(0.98M) `ba`(0.98M) `ci`(0.91M) `al`(0.87M)
`zm`(0.85M) `tt`(0.83M) `cm`(0.76M) `bh`(0.75M) `mz`(0.70M) `bw`(0.65M)
`cu`(0.63M) `jm`(0.58M) `mk`(0.48M) `bn`(0.48M)

## 5 · TAIL — remaining UN members

`bj sn ne tj na ml sl rw gn sr mg gm mv fj gy bt bb bi pg er cv tg gw so bz ag dj
cf lc km st kp gd ws kn sc dm to sb ki nr bs me` (fleet sourced), then, with
population proxy only and fleet `unknown`:
`by ao ye cd mw ss py ni tm cg uy mr ht tl ls mu sz ga gq vu vc mh fm pw tv`

## 6 · Dependencies, SARs, special-status (44, ISO-coded)

`ps`(268,365) `xk`(460,105 — **non-ISO**, de-facto code) `im`(167,716)
`je`(127,911) `gg`(88,532) `re`(~475k) `nc`(369,823) `mq`(222,735)
`gp` `aw` `cw` `pf` `gf` `yt` (pop-proxy) `bm`(~49k) `ky`(42,728)
`ax`(52,197) `tc` `gi` `vg` `sx` (pop-proxy) `fo`(28,562) `gl`(7,054)
`mf` `ai` `ck` `bl` `wf` `bq` `pm` `ms` `sh` `fk` `sj` `tk` `nf` `nu` `cx`
`cc` `pn` `eh` (pop-proxy / unknown)

## 7 · Non-ISO de-facto entities — DO NOT create a file before a PLT/owner ruling

`xk` Kosovo (lowest risk, de-facto standard code) · Northern Cyprus (`xn` /
`cy-trnc`) · Transnistria (`xt` / `md-pmr`) · Abkhazia (`xa` / `ge-ab`) ·
South Ossetia (`xs` / `ge-so`) · Somaliland (`xl` / `so-sl`) · Sovereign
Military Order of Malta (`x-smom`, issues genuine `SMOM` plates) · Akrotiri &
Dhekelia (`gb-sba`). The repo has **no `x-` precedent**; a code convention must
be decided before any of these lands. Nagorno-Karabakh/Artsakh is **excluded** —
the entity dissolved in January 2024; do not create it.

## 8 · Proposed batches (4 jurisdictions each, one legal language / regulator family per batch)

| batch | codes | coherence |
|---|---|---|
| B01 | `tr ge am az` | Turkey + South Caucasus; post-Soviet grammars, recent reformats |
| B02 | `eg ma dz tn` | Arabic-script Maghreb + Egypt; French secondary sources |
| B03 | `sa ae qa kw` | GCC; bilingual plates, near-identical regulator structure |
| B04 | `id ph vn sg` | SE Asia core; `my`/`th` already covered, LTA docs anchor in English |
| B05 | `pk bd lk np` | South Asia; `in` covered as template, shared zone-code grammar |
| B06 | `ir iq il ps` | Middle East core; **`il`+`ps` must be sourced together, do not split** |
| B07 | `co pe ec ve` | Andean bloc; Spanish, shared format lineage |
| B08 | `cl uy py bo` | Southern Cone; Mercosur plate, `ar`/`br` covered as reference |
| B09 | `kz uz kg tj` | Central Asia; Russian + Turkic, GOST-derived lineage |
| B10 | `tw hk mo kh` | East/SE Asia specials; CJK sourcing, colonial registration heritage |

Next tranche: B11 `bh om jo lb` · B12 `ng gh ke tz` · B13 `ru by md xk` ·
B14 `rs ba mk me al` · B15 `im je gg gi` · B16 `re mq gp gf yt` (French DOMs,
`fr` as template) · B17 `nc pf wf pm` · B18 `aw cw sx bq` (`nl` as template) ·
B19 `fo gl ax sj` · B20 `bm ky vg tc`.

## 9 · Structural rulings PLT owes before batch 15

Four cases where "one jurisdiction = one file" breaks and there is no precedent:

1. **`bq` Caribbean Netherlands** — one ISO code, **three separate plate systems**
   (Bonaire, Sint Eustatius, Saba). The `au-*`/`ca-*`/`us-*` precedent argues for
   `bq-bo` / `bq-se` / `bq-sa`.
2. **`sh` St Helena, Ascension & Tristan da Cunha** — three separate series under
   one code. Same question.
3. **`gg` Guernsey** — Alderney issues its own `AY` series; Sark is car-free.
4. **`eh` Western Sahara** — two issuing authorities (MA-administered areas on MA
   plates; SADR issues its own). Needs explicit dual-authority representation or
   a documented decision to cover one.

Also: `us-*`/`ca-*`/`au-*` exist but no country-level rollup file does, so a
consumer asking for "US plates" gets nothing. A federation-level frame is a
separate ~3-file task, outside this gap list. (PRD-PLATES §2.1 anticipated
`us.yml` "holds the federation-level frame" — it was never created.)
