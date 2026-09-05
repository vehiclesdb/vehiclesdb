# WIP — Yamaha bare type codes: the census, the register oracle, and what is NOT yet folded

**Author:** S4W/COV2 (continuing S2W's queue), 2026-09-05. **Status: WIP, NOTHING
APPLIED.** No rename key, no `former_ids` line and no build in this branch. It
is a measurement and an evidence route, parked so the next session starts from
a map instead of from `catalog/`.

Measured on a frozen control build, `--kinds=motorcycle,moped`, **pipeline
`8c0dcb3`, data `217f2ea`** — not on `catalog/`, which is release 2026.08.2
output and is stale by every key merged since (that mistake cost me twenty
minutes: `mws125` reads LIVE in `catalog/` and is GONE on the build, because
the key that folds it landed after the release).

## 1 · The census

597 Yamaha two-wheel records (513 motorcycle, 80 moped), **33 in decile 1**.
Three defect classes, and only the first is mine to curate:

| class | size | decile-1 | who owns it |
|---|---|---|---|
| **A — bare internal type code** (`RN04`, `RJ05`, `VM03`, `4TX`) | **65 live** + 426 candidate strings | **14** | COV2 curation |
| **B — bare 1–3 letter series stub** (`R`, `X`, `TT`, `WR`, `XJR`) | 40 live | 3 | **NORM + a ruling** — see §4 |
| **C — Traficom type-code tail** (`FJR1300A-RP115/1298`) | see §4 | — | **NORM** |

Class A is the whole reason the make reads badly: RDW's *handelsbenaming*
column carries Yamaha's internal model code, so the pipeline publishes a record
literally named `RN04` and the real nameplate never accumulates that evidence.
S2W's §A fold (`data#263`, 2026-08-01) already folded 98 such codes onto 39
nameplates; these 65 are the residue it did not reach.

## 2 · The register oracle — RDW writes the mapping itself

The single most useful finding, and it costs nothing to exploit: **37 Yamaha raw
strings in our own corpus carry the answer in a parenthetical.** That is
regulator-tier corroboration already inside the dataset. Full list in
`$SCRATCH/cov2/rdw-parentheticals.tsv`; the load-bearing ones:

| raw string | code → nameplate | n | live target? |
|---|---|---|---|
| `YAMAHA \| RJ09  (R6)` | RJ09 → YZF-R6 | 289 nl | `yzf-r6` **live** d2 |
| `YAMAHA \| YZFR6 (RJ03)` | RJ03 → YZF-R6 | 21 nl | `rj03` is **live d3** — folds away |
| `YAMAHA \| RJ032 (YZF-R6)` | RJ032 → YZF-R6 | 8 | `yzf-r6` |
| `YAMAHA \| (VM02) XVS 650 CLASSIC` | VM02 → XVS650 Classic | 2 | `vm02` is **live d2**; target needs a ruling (see §3) |
| `YAMAHA \| 2 LT (V-MAX)` | 2LT → VMAX | 192 nl | `vmax` **live** d3 |
| `YAMAHA \| 4 TV (YZF 600)` | 4TV → YZF600 | 174 nl | `yzf600` **live** d5 |
| `YAMAHA \| GPD150-A (NMAX155)` | GPD150-A → NMAX 155 | 184 nl | `nmax-155` **live** d9 — but see §3 |
| `YAMAHA \| C V 50 (JOG)` + `CV 50 JOG` | CV50 → Jog | **372 nz** | `jog` **live** |
| `YAMAHA \| 4 NK (ROYAL STAR)` | 4NK → Royal Star | 36 | `royal-star` **live** d6 |
| `YAMAHA \| 4 BR (XJ 600 S)` | 4BR → XJ600S | 6 | `xj600s` **live** d2 |
| `YAMAHA \| 2J4 (SR500)` | 2J4 → SR500 | 7 | `sr500` **live** d5 |
| `YAMAHA \| 3SK (FJ1200)` | 3SK → FJ1200 | 1 | `fj1200` **live** d6 |
| `YAMAHA \| XV 700 (VIRAGO)` | XV700 → Virago | 14 | `virago` **live** d4 |
| `YAMAHA \| VM01  (XVS650C)` | VM01 → XVS650C | 20 | no live `xvs650c` — NO LIVE TARGET |
| `YAMAHA \| 4SV (YZF1000)` | 4SV → YZF1000 | 8 | see the §3 warning |
| `YAMAHA \| XSR 900 ABARTH (MTM 850)` | MTM850 → XSR900 | 1 | key already exists |

**This is corroboration, not the source.** Every row still needs a Yamaha or
reference-grade page before it becomes a key — that is the standard the existing
111 Yamaha keys were held to, and the parentheticals are typed by clerks.

## 3 · Three traps found before folding anything — do not fold these blind

1. **`"YZF1000": "YZF-R1"` (an EXISTING key) looks wrong.** `4SV (YZF1000)` is
   the YZF1000R **Thunderace** (1996-2003), which is *not* the YZF-R1. If that
   reading holds, a shipped key is pooling two different motorcycles, and
   folding `4SV` onto it would compound the error. **Verify before extending;
   report as a naming finding either way.** Do not drive-by reverse it — the
   Nissan 350Z DEBT row exists because someone did.
2. **`GPD150-A` disagrees with a shipped key.** RDW writes `GPD150-A (NMAX155)`
   while `renames.yml` ships `"GPD150A": "NMAX 150"`, and BOTH `nmax-150` and
   `nmax-155` histories exist. A displacement conflict, not a spelling one, and
   2W displacement granularity is binding — resolve with Yamaha's own material.
3. **`VM02` folds to a name that does not exist yet.** The raw says
   `XVS 650 CLASSIC`; there is no live `XVS650 Classic`, only `xvs650` (d4).
   Folding it to `XVS650` merges a trim into its base; minting the Classic is a
   new id. Neither is free — it is the D-4 range-label/trim question, and it
   wants the ruling, not a coin-toss.

## 4 · What is NOT COV2's, filed so nobody curates around it

- **Class B, the bare series stubs** (`R` d2 gb, `X` d2 gb, `TT`/`WR`/`XJR` d1
  nz). Two known mechanisms already on file: the DEBT row *"UK 2W nameplates
  whose numeral is a SINGLE DIGIT fall through to the bare series stub — 22,805
  gb vehicles"*, and the **D-4 range-label** question S2W deferred on honda's
  Shadow (A-2W-8). A rule fix plus a ruling; a curation key would paper over
  both. **→ NORM.**
- **Class C, Traficom's tail.** `fi_traficom` appends `-<typecode>/<cc>` to the
  model string: `FJR1300A-RP115/1298`, `FZ6S-RJ071/600`, `XP500 TMAX-SJ011/499`.
  `data#326` folds one instance as a one-off; **the general form is a parser
  rule and belongs in the pipeline.** → NORM.
- **NZ `LA` is the LAMS suffix**, and it is Yamaha-and-NZ-only in this corpus:
  `MT03LA` (d1), `MT07LA` (d1) live, `YZF-R7LA` (293 nz) and `MTM660LA` (117 nz)
  in candidates. Yamaha AU/NZ sell a genuinely smaller 655 cm³ CP2 as
  **"MT-07LA" / "MT-07 LAMS"** — same nameplate, a licence restriction, exactly
  the class the S-1 unwind settled for `-U` (35 kW). Note the counter-example
  that stops this becoming a pattern: `honda/crf250la` and `crf300la` are REAL
  Honda nameplates (L + A for ABS), so an `LA$` rule would be wrong.
  **Folding these gains `nz` on `yzf-r7` (which lacks it) and dedups two
  decile-1 records — the cheapest real win left in this make.**

## 5 · Next step, in order

1. `MT03LA`/`MT07LA`/`YZF-R7LA`/`MTM660LA` → the base nameplates (one Yamaha NZ
   page sources all four).
2. The RN/RJ/RP block: RN01/04/09/12 are the YZF-R1 generations (1998-99 /
   2000-01 / 2002-03 / 2004-06) on several independent citations, but **RN06,
   RN08, RN11, RJ01, RJ02, RP02, RP04, RP05, RP06, RP08, RP10, RP11 are
   unsourced** and are the ones likeliest to surprise.
3. The parenthetical rows in §2 that have a live target, each with a
   manufacturer citation added.
4. Then suzuki (304,745 mass, never touched by any wave).

**Yamaha's Owner's Manual Library (`library.ymcapps.net`) — the oracle the
existing keys cite — is behind Incapsula from this machine (403).** The working
manufacturer route is the manual CDN:
`https://cdn2.yamaha-motor.eu/prod/owner-manuals/Motorcycles/P<manualcode>E.PDF`
returns 200 for valid codes (verified: `PBS228199E0E.PDF`, 7.4 MB).

Inputs to reuse: `$SCRATCH/cov2/yamaha-LIVE-IDS.tsv` (597 rows, the only legal
fold targets), `yamaha-CANDIDATES.tsv` (3,305 rows ranked by vehicle count with
raw strings), `rdw-parentheticals.tsv` (37), `ctrl/` (the control snapshot:
gate FAILSET, per-record availability, per-country totals),
`COV2-RESEARCHER-RULES.md`.
