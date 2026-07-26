# PRD-QUALITY — the VehiclesDB Data-Quality, Canonicality & Completeness Program

**Status:** ACTIVE — the operating document for all quality work on this dataset.
**Audience:** the two current maintainer sessions (S4W, S2W), every future agent,
and every agent swarm deployed against this dataset. Written to be executed cold:
it assumes you have the repos and **nothing else** — no conversation history, no
memory of the 2026-07-25 correction pass, no access to anyone who was there.
**Prime directive:** make VehiclesDB the most complete, most correct, most
canonical vehicle dataset on the internet — open skeleton *and* closed depth —
without ever again destroying real data in the name of cleaning it.

Read order for this document's prerequisites:
`README.md` → `SCHEMA.md` → `DECISIONS.md` → `SOURCES.md` → `NAMING.md` →
`AGENTS.md` → the two correction-pass briefs linked from AGENTS.md →
`CORRECTION-PASS-2026-07-LOG.md` (the raw 40-turn log; contains the *wrong* turns
as well as the right ones, deliberately). This PRD does not repeat their content;
it builds on it and cites it.

---

## 1. MISSION AND THE QUALITY BAR

### 1.1 What "p99.999+ quality" means here, operationally

Percentile talk is meaningless on an ~18,000-record dataset unless converted into
a defect budget. The binding definition:

> **At every publish, the number of KNOWN defective records in `dist/` is ZERO,
> and every defect class in the taxonomy (§4) has an automated detector wired
> into CI or the build gates.** 99.999% of 18,133 records allows 0.18 defective
> records — i.e. the budget is zero, and the claim we can honestly make is
> "zero known defects, with detection coverage for every defect class we have
> ever seen, and dual-agent verification coverage of X% of records" where X is
> the ledger coverage metric (§5) and the target is 100%.

Three numbers define the bar, all CI-checkable:

| metric | definition | target |
|---|---|---|
| **`debt`** | records matching a defect shape, acknowledged, unfixed (`data/name_shapes.yml` debt section; may only decrease) | **0** |
| **`unexplained`** | records matching a defect shape with no `legit`/`debt` entry (`scripts/lint_dataset.rb`) | **0** |
| **`coverage`** | records with a dual-signed verdict in the verification ledger (§5) / published records, per owner | **100%** |

Completeness has its own bar (§13): every kind, every region with an eligible
open source ingested, candidate-queue depth tracked and bounded.

### 1.2 Why the bar is framed as "known defects zero" and not "defects zero"

Because the 2026-07-25 pass proved that **confident cleanup destroys data**: the
single largest data-loss event in this repo's history was a *curation* PR deleting
SEAT's entire current German lineup as "junk type-codes" (`si[468..474]` = ATECA,
BORN, FORMENTOR, IBIZA, LEON, TAVASCAN, TERRAMAR). A quality program that rewards
"suspects removed" will do that again. This program rewards **verified verdicts**
— including the verdict "this weird-looking record is correct, leave it alone,
here is the proof."

### 1.3 The two-layer product this program serves

- **Open skeleton (this repo, CC-BY 4.0 forever):** ids, names, taxonomy, kinds,
  body types, aliases, availability evidence, popularity deciles, regions,
  year ranges, **generations and variants** (reserved open shapes per
  `SCHEMA.md` — populating them is open-layer work and in scope here), TAN
  crosswalks, `former_ids`.
- **Depth layer (private, funds the project):** per-config specs (engine, power,
  dimensions, drivetrain, per-model-year), absolute counts and time series,
  images, freshness SLAs. Keyed by the SAME ids — which is why open-layer id
  quality is the foundation of the commercial product. Depth-layer specifics
  live in the private pipeline repo (`PRD-DEPTH-ENRICHMENT.md` there); this
  document governs everything id-shaped.

**Every dollar of future depth-layer value depends on the open ids being stable,
canonical and deduplicated. Id quality IS the business asset.**

---

## 2. CURRENT STATE (verified 2026-07-25, end of the correction pass)

### 2.1 What is true right now

```
PUBLISHED (dist/, what consumers hold):   2026.07.3, built 2026-07-05
  18,133 records · 860 makes · PRE-DATES the entire correction pass

MERGED-BUT-UNPUBLISHED (next build):      validate run, ALL GATES GREEN
  17,038 records · 849 makes
  car 7,397 · motorcycle 5,885 · moped 1,270 · van 1,072 · truck 1,034 · bus 380

Override layer on main:
  renames 1,195 entries / 148 makes · moves 75 · former_ids 1,081
  spotchecks 126 · drops 90+ · kind_maps 3 sources
Tooling on main:
  lint_overrides · lint_curation · lint_dataset (+ name_shapes legit/debt)
  reorg_make_blocks · gen_ownership · find_duplicate_spellings ·
  propose_former_ids · pipeline: verify_source_landing + 67 tests / 4 files
Measured improvements (validate build vs published):
  word-glued 2W names 967→0 · de-only numeric artifacts 148→1 ·
  records with de evidence 216→393 (+82%) · make-as-model 88→9 ·
  placeholders 8→2 · duplicate-spelling groups (4W) 632→~140
```

**Nothing publishes until the day-12 cron (2026-08-12) or a manual
`workflow_dispatch` with `publish: true`. No scheduled publish has EVER
succeeded — the autopilot's publish path is unproven, not merely once-broken.**

### 2.2 GAP REGISTER — everything currently known to need fixing or refining

This is the authoritative backlog. Every item carries enough context to act
without archaeology. Owner key: S4W = car/van/truck/bus maintainer, S2W =
motorcycle/moped maintainer, JOINT = needs both, OWNER = needs the human owner.

**G1 — Three missing validate gates** (S4W; specs in §15.1). (a) `former_ids`
completeness: fail when a `moves.yml`/rename entry changed an id with no alias —
the gap only manifests at publish time, so nothing surfaces it in the window
where it is cheap to fix. (b) Move-split detection: fail when a move relocates
one register's spelling of a nameplate while a badge-free twin stays behind —
this silently deleted 17 Vespa nameplates (every gate stayed green; the records
went into the candidate queue, which is exactly where legitimately-thin records
live). (c) `former_ids` may never name a live id in the same kind.

**G2 — The no-vanish build-diff gate** (S4W; §15.2). The single most important
missing control. Three separate incidents (Vespa split, kind-migration attempt
deleting 35 microcars, threshold interactions) shared one shape: *records
vanished silently because relocated evidence fell below publication thresholds*
(car 1000 · motorcycle/moped/van 300 · truck 150 · bus 50, single-source).
Nothing currently compares consecutive builds id-by-id.

**G3 — Kind migration (L6e/L7e quadricycles → `car` + `body_types:
["quadricycle"]`)** (JOINT, decision made, implementation blocked). Full history
in `PROPOSAL-kind-boundary.md`. The gating item after three wrong estimates is
now evidenced: **a Spanish national-code → EU-category mapping** (DGT `*02`…`*17`
codes carry no L6e signal, so every ES-evidenced L6e splits across kinds and
vanishes below both thresholds — `silence/s04` is the proven casualty). This is a
research task against DGT's code list, not plumbing. Everything else is small: 6
map entries across es_dgt/fi_traficom/lu_snca, the nl_rdw kind_map, a body-type
derivation (built, works — 76 records got `quadricycle`), and per-id threshold
verification. S2W's Turn-38 acceptance criteria are the template: **no record may
vanish, verified per id, revert on miss.**

**G4 — FZ 11.1 as a source** (S4W; highest-leverage single item). Same publisher
and licence as FZ 10 (DL-DE/BY-2.0), reconciles 399/399 Modellreihen with FZ 10.1.
Unlocks: the `WOHNMOBILE` segment filter (proves truck-in-car-table rows are
motorhomes), the `UTILITIES` segment (KBA's own car/van boundary, free), and the
`volvo/60` resolution. Converts the hand-enumerated
`overrides/kind_maps/de_kba_fz10.yml` `by_model:` list into a principled join.

**G5 — `car/volvo/60` is a statistical bucket published as a nameplate** (S4W,
blocked on G4). It is S60+V60 (NOT the 60-series platform — XC60 is its own row),
single-sourced, `body_types: ["hatchback"]` (wrong), and sits in dropdowns beside
genuine bare-number nameplates (`audi/90`, `rover/60`) with nothing to
distinguish it. Also breaks id stability: its referent drifted from {S60,V60,
V60CC} to ~{V60}. `volvo/90` is NOT published purely because 988 units missed the
1,000 threshold while `60`'s 4,211 cleared it — that inconsistency is the
argument for an explicit rule.

**G6 — `be_fps` licence pin guards nothing** (S4W). Pinned but not ingested, and
its page contains no licence text at all (22,607 chars of JS shell — "licence",
"Creative Commons", "CC0" all absent). A green gate there is not evidence Belgian
terms were ever checked. Re-point before Belgium is ingested. General rule: **a
pin must guard actual licence text, verified by reading the pinned artifact.**

**G7 — `mercedes-benz/atego` and `mercedes-benz/unimog` in the car kind** (S4W).
Motorhome-base leakage arriving via AR/FI/NL/NZ (not KBA), proving the count
threshold is not a sufficient guard against the M1-has-no-mass-ceiling mechanism.

**G8 — ~140 residual duplicate-spelling groups, 4W** (S4W) + **the equivalent
sweep has never been run on the 2W half** (S2W). Detector:
`scripts/find_duplicate_spellings.rb`. Remember it reads the PUBLISHED catalog —
counts do not move until a build.

**G9 — Six sole-model make-as-model rows** (S2W, documented) — SPLIT per Turn
42: `paxster`/`cyclemaster`/`veeley` are marques whose product name IS the
brand — mark `legit` with that reasoning, nothing to research, a debt entry
would imply someone should fix them; `ebretti`/`nicom` are genuinely unresolved
and stay debt. Plus `van/uaz/uaz` (S4W): UAZ's convention
is numeric type designations, identity unrecoverable from an aggregate row —
tracked as debt, not guessed. Plus `ebretti`/`nicom` marque research (S2W) and 2
ambiguous Piaggio rows.

**G10 — Pooled rows cannot be split** (JOINT, needs normalizer work). KBA's
`SEAT/LEON` and `SEAT/ATECA` pool SEAT and Cupra versions of one nameplate; RDW
post-strip Vespa rows are indistinguishable from genuine Piaggios. Splitting
requires the prefix strip to *preserve what it removed* (or moves to run before
the strip). Until then these are documented keeps.

**G11 — `former_ids` merge-class coverage** (S4W). The generator models renames
(old id gone, new id appeared). The 2026-07 pass was dominated by MERGES into
pre-existing ids (`volvo/244→240`, `lexus/rx-450h→rx`, 390 spelling merges) —
those aliases must be generated from `renames.yml`+`moves.yml` intent at the
next build diff, or every merged id 404s at publish. Also: an `accepted_loss:`
escape for the three documented evidence losses (`scania/irizar` ua,
`iveco/wing` ua, `iveco/sunrise` nl) that a countries-superset rule rejects
forever.

**G12 — Six empty make blocks in `renames.yml`** (S4W, trivial): `Bsa`, `I-Coco`,
`Iva`, `Matchless`, `NSU`, `Yamaha` parse as `nil` (left by the ownership-
boundary revert). Harmless to the pipeline but crashes naive iteration
(`.values.map(&:size)`) — clean up and add a lint for empty blocks.

**G13 — `data/name_shapes.yml` debt is stale-dated** (JOINT) — post-build
numbers now measured (Turn 42): `poessl`/`buerstner` GONE (68 records healed by
the drop-fold); `niesmann-bischoff` survives only via the G18 kind-scoping gap.
The structural fix: `lint_dataset` gains a `VDB_CATALOG` env so its baseline
and its subject are the same build, turning "re-measure after the build" into
a flag rather than a wait. Entries
`de-kba-shared-string-leak=171` and `normalizer-space-collapse-display-names=269`
describe defects whose fixes are merged; the counters heal to ~0 at the next
build. After the first post-correction build, re-measure and rewrite the debt
section against reality; `spec-token-4w=53` and `embedded-make-prefix-4w=22`
remain genuine backlog.

**G14 — The publish path is unproven** (OWNER + JOINT; §16). First publish after
the correction pass must be supervised: validate-diff reviewed, no-vanish gate
green, `former_ids` complete, rollback plan written BEFORE dispatch.

**G15 — Verification ledger does not exist yet** (JOINT; §5). Until it does,
"manually reviewed" is a claim without a receipt. This is Phase 1's core
deliverable and gates all swarm work.

**G16 — Region and category coverage** (§13): no source for JP, KR, CN, IN, BR,
MX, AU, ZA, IL, SG, most of non-covered Europe; body types absent for
van/truck/bus; `generations`/`variants`/`year_start`/`year_end` unpopulated;
reserved kinds (agricultural, etc.) unshipped.

**G17 — Enrichment plumbing does not exist** (JOINT; §14). There is no override
surface or emit support for years/generations/variants. Must be built before
enrichment swarms deploy, or their output has nowhere to land.

**G18 — Drop kind-scoping leaks** (S4W). All 85 `drop.yml` entries are
effectively car-scoped; 11 records across 6 makes leak into kinds the drop
does not cover: `niesmann-bischoff` (truck 2), `hymer` (truck 2, van 1),
`mobilvetta` (truck 1), `auto-trail` (van 1), `chausson` (van 1) — motorhome
coachbuilders, same class as G7 — plus `m-a-n` (truck 2), which is a MERGE
(`M.A.N.` → MAN), not a drop. The Scania/Iveco/DAF/MAN car-only drops are
correct by design (411 truck records behaving as intended) — extend per kind
with evidence, never blanket.

**G19 — Ownership orphans** (S4W). `OWNERSHIP.yml` is a static snapshot;
every build can mint makes belonging to nobody (17 in the fresh build:
`m-a-n`, `karsan`, `kia-motors`, `opel-vauxhall`, `quadro-vehicles`,
`westfalia-mobil-gmbh`, `unu`, `ebroh`, `xinri`…). Over 45–60 batches this
compounds silently. Fix: `gen_ownership.rb --assign-new` (dominant-kind rule,
ties to TIEBREAK) + a lint that fails on unowned published makes.

**G20 — Acronym-make casings, D23 backlog** (SPLIT). Shortlist of 76
candidate makes / 1,270 records (47 s2w — `Ktm` 152 and `Bsa` 91 are the two
biggest single wins in either half — and 29 s4w). Research per marque; fix
via `makes/aliases.yml`; the shortlist knowingly under-reports two-vowel
initialisms (IVA, IFA, AWO, EVT) and carries deliberate false positives
(Ford, Puch, Nash, Ram) — it is a research queue, not a verdict list.

**G21 — Duplicate MAKES, pass 2** (SPLIT by ownership). `scripts/
find_duplicate_makes.rb` (S2W-built): fold pass caught `man`/`m-a-n` and
`e-max`/`emax`; legal-entity pass flags 32 makes / 71 records — and its own
header leads with counterexamples because the obvious rule is wrong in both
directions (Club Car IS the brand; Renault Trucks is a distinct legal
manufacturer with its own approvals; Leyland DAF / Austin-Morris /
Steyr-Puch / VDL Bova were real marques; `chevrolet-gmc` / `opel-vauxhall`
probably are conflations). Approval-holder research, not string work.

**G22 — `bus/factory-built` holds three real manufacturers as models**
(S4W; the LIVE §8.3 example). `"Geely"`, `"Yutong"`, `"Zhongtong"` parsed
into the model column by an NZTA origin flag; single-source nz. The obvious
drop deletes three manufacturers; a clean move is impossible (there is no
model to move TO — the model column holds only the make). Least-bad
candidates: move to `<Make>|<Make>` as honest make-as-model debt rows under
the right makes (`bus/geely` already exists), or debt in place. Decide
against the NZTA raws; never the drop.
**RESOLVED 2026-07-25 (data#20)**: moved to make-as-model rows with
cross-make former_ids (legal — the pseudo-make left the build entirely);
~600 sub-threshold candidate rows remain under factory-built for per-row
moves as batches reach them.

**G23 — Classic/vintage/discontinued program** (BOTH halves; owner directive
2026-07-25). Production years (`year_start`/`year_end`) per id + emit-time
DERIVED era tags (`discontinued`/`classic`/`vintage` — 30-year H-Kennzeichen
line, pre-1931 vintage line). Full spec §14.4; implementation order G23a-d
there. Store facts, derive labels; capture years at zero marginal cost during
§7 review batches.

**G26 — THE CAPTURE DOCTRINE** (owner directive, 2026-07-26: "we want ALL
information we can get on EVERY single model — trims, model by year, years
of production, metadata like maker website + model website, technical
specs"). Principle: **nothing the pipeline sees is discarded unrecorded.**
The folds stay (they are correct for id dedup) but every folded-away
string is captured. Slices:
(a) DONE — observed_variants.json: every raw model string whose fold lost
tokens, per id (45,529 ids measured on first run; ford/focus alone carries
22: RS, Electric, generation and engine codes). The seed corpus for (b).
(b) `variants:` storage in overrides/enrich (name + type:
performance/trim/edition/body + source) → additive `variants` field on
records → gem/dist exposure. Curated FROM (a), never bulk-imported (a raw
variant string is evidence of existence, not of the official variant name).
(c) `links:` in enrich — maker_url (make-level), model_url (id-level),
sourced — the metadata the owner named; additive emit.
(d) MODEL-YEAR facts: fueleconomy.gov is per-year-per-trim WITH technical
specs and is US-government open data — the first legitimate OPEN spec
source; NRCan and JPJ carry per-year too. Capture paths spec'd per source
before import (licence rules §13.2 apply as always).
Open/closed boundary unchanged: depth-grade specs stay PRD-DEPTH; but
capture-never-discard applies on BOTH sides of it.
### 2.3 What must NOT be re-litigated (settled, with evidence)

The kind axis decision (legal categories; quadricycles → car, on the trike
precedent), the make-ownership split and its tie pins, one-make-one-owner,
NAMING.md's evidence ranking, the moves mechanism and its precedence rules, the
`legit`/`debt` two-bucket design, and every per-marque convention already
verified against a marque archive (Mercedes/Volvo/Jaguar/Lexus — §11.2). If you
believe one is wrong, bring *new evidence* and write it in the correction log;
do not silently diverge.

---

## 3. NON-NEGOTIABLE INVARIANTS

Violating any of these is an incident regardless of intent. Each earned its
place by being violated once.

**Legal / licensing**
- I-1. Only openly-licensed or statutorily-public sources enter the open
  dataset. **ShareAlike (CC-BY-SA, ODbL), NonCommercial, and scraped sources
  never enter — no exceptions, including "just to fill a gap."** One SA
  ingredient infects the whole CC-BY composite.
- I-2. **Wikipedia and every wiki are CC-BY-SA.** They may be used to *locate*
  primary sources and to sanity-check a fact you then verify elsewhere; their
  content, lists and tables may never be imported. Same for other vehicle
  databases (Edmunds, CarQuery-descendants, GitHub make/model lists — an MIT
  licence on a repo does not sanitize the list inside it, and EU database right
  applies to extraction regardless of copyright).
- I-3. Facts are not copyrightable; *compilations* are protected. An agent may
  state "the W111 220 SEb was built 1959–1965" after verifying it against
  Mercedes' archive; an agent may not bulk-copy a third-party spec table.
- I-4. Every upstream licence text is pinned; **a pin must guard actual licence
  text** (the `be_fps` lesson). No per-vehicle data ever (VINs, plates); no
  logos, no imagery in the open layer.

**The id contract**
- I-5. Ids are append-only. A correction produces a `former_ids` alias; nothing
  is silently deleted. **A cleanup that removes an id without an alias or a
  CHANGELOG entry is a breaking change**, not a cleanup.
- I-6. **No record may vanish.** Any change that relocates evidence (move, kind
  change, rename-split) must be verified **per id** against a build before
  merge. Aggregate counts hide single-record deletions; three incidents proved
  it. Revert rather than ship a miss.

**Evidence**
- I-7. **A bare integer, single-source, is a PARSER suspect before it is a data
  suspect.** Consecutive integers under one make are presumptively an index
  leak — evidence the records are REAL. Recover true names by re-parsing the
  row, never by resolving the integer as a table index (shared-string tables
  are workbook-wide: `si[350]="ACTROS"` in a cars-only sheet).
- I-8. **Registers file sub-brands under the type-approval holder** (KBA HSN:
  Cupra→SEAT, Genesis→Hyundai; RDW: 130 Vespa names under `merk=PIAGGIO`). A
  "duplicate make" may be an approval holder; merging it is the SEAT-deletion
  class of error. Check the approval relationship before any make merge.
- I-9. Corroboration (≥2 sources, ≥2 countries) proves a record is REAL, not
  that its name is CANONICAL — and it proves nothing at all for make-as-model
  and embedded-make classes, because registers share the same fallback habits.
- I-10. Availability-subset check before any drop; popularity counts ride the
  row, so a `null` where a move is possible discards real signal.

**Process**
- I-11. **The author never certifies their own work.** Every batch verdict is
  dual-signed by a distinct verifier agent (§8). In the correction pass, not
  one of the five major wrong conclusions was caught by its author.
- I-12. **The test is the derived artifact; the pipeline is the fact.** A
  checker contradicting a direct observation is suspect until re-derived
  (the reachability harness reported all 48 correct moves as dead).
- I-13. **Build, don't reason.** Three consecutive effort estimates for the kind
  migration were wrong; each correction came from running a build, never from
  thinking harder. Any claim about pipeline behaviour must be demonstrated
  with a command whose output is pasted.
- I-14. Corrections are written into the pass log *by the person who was
  wrong*, plainly, with the mechanism. The log deliberately preserves wrong
  turns — future agents learn more from those than from the fixes.
- I-15. Rule-first: a defect class with >20 instances gets a normalizer rule or
  a generated fix, not N hand-written lines. Interim override lines carry
  `# INTERIM — superseded by <issue>` and count as debt.

---

## 4. DEFECT TAXONOMY

Complete list of every defect class ever observed here, with detector and
remedy. A swarm reviewer classifies every finding into exactly one of these; a
finding that fits none is a NEW class and must be added here (with detector)
before it is fixed at scale.

| # | class | example | detector | remedy |
|---|---|---|---|---|
| D1 | parser artifact — fabricated name | `volkswagen/552` (= Golf, xlsx index leak) | `lint_dataset` numeric_only + single-source; source `audit!` gates | fix parser; records HEAL, never delete |
| D2 | statistical-table artifact | `zeekr/neuzulassungen-insgesamt` | table-artifact wordlist | source-level skip |
| D3 | placeholder name | `N.a.`, `Xxx` | placeholder regex | rename to honest family if identifiable; else debt (never erase a make silently) |
| D4 | make-as-model | `audi/audi` | name==make | drop; if sole model, resolve or debt (Sherco/Nimbus precedent) |
| D5 | embedded make/brand prefix | `JAECOO5 EV`, `PIAGGIO VESPA…` | prefix test | rename; if cross-make badge → move (D13) |
| D6 | duplicate spelling, same make+kind | `280 Se` vs `280SE` | `find_duplicate_spellings` (NFKD fold!) | merge to canonical; new-string canonicals need marque-archive proof |
| D7 | non-canonical form (casing/spacing/accents) | `Xj-S`, `RX450H`, `MULHACEN125` | ledger review vs marque convention | rename + styling pin |
| D8 | wrong altitude — trim/edition/body/engine published as model | `Polestar 2 Dual Motor`, `Leon Sc` | trim tokens; ledger review | fold into nameplate; record as variant (open shape) where meaningful |
| D9 | registry/type/homologation code as model | `Cg`, `TR1 300`, `SDR` | code-string shape + single-source | resolve via raw + approval data; else debt |
| D10 | wrong kind | campers in car; Atego in car; L6e in moped | kind_maps + segment joins (FZ 11.1) + kampeerwagen test | per-kind drop or kind_map route; NEVER lose the other kind's evidence |
| D11 | wrong make — approval holder | Cupra under SEAT; Vespa under Piaggio | HSN/approval research; badge-in-model | `moves.yml` (check D14 first) |
| D12 | make near-dupe / corporate string | `e-max`/`emax`, `moto-s-p-a` | containment scan + approval check (I-8) | make alias merge, with model-overlap evidence |
| D13 | temporal merge cell | `"GLK, GLC"` | comma-cell warn in source | source-level `COMMA_MERGED` map |
| D14 | move-split (twin left behind) | `vespa/et4-150` vanished | G1b gate; candidate-queue diff | co-move all spellings; union evidence |
| D15 | threshold vanish | `silence/s04` in kind migration | G2 no-vanish gate | verify per id; hold change until evidence reunites |
| D16 | body_types wrong / poisoned | `SEAT|600: suv` via unscoped `600` | body override audit; make-scoped rules | scoped override + tripwire |
| D17 | case-only false merge / false split | `S-type` vs `S-TYPE`; `ë-C3`→`c3` | case-sensitive dedupe; NFKD-fold (not delete) | per NAMING; skew test for case pairs (§10.4) |
| D18 | id 404 (rename/merge without alias) | `volvo/244` post-merge | G1a + G11 gates | `former_ids` from override intent |
| D19 | availability/evidence loss on merge | `scania/irizar` ua | subset check | document `accepted_loss` or hold |
| D20 | stale source payload | KBA served March for May | source month/title assertion | per-source freshness assertion |
| D21 | licence-pin false signal | `my_jpj` monthly break; `be_fps` empty | pin-content review | phrase pins guarding real text |
| D22 | curation-layer YAML hazards | dup keys, flow style, `244: 240` Integer, null-vs-move, dead keys, empty blocks (G12) | `lint_curation` + reachability test | mechanical; lint blocks merge |
| D23 | acronym MAKE name title-cased | `Ktm` (152 recs), `Bsa` (91), `Tvr`, `Ldv` | single Titlecase token ≤4 chars ≤1 vowel (shortlist, NOT a verdict — `Iva` may genuinely be Iva) | `makes/aliases.yml` identity pin ONLY (§6.2 rule 3 corollary) — never a styling token. `smart_case` consults stylings/acronyms curated for MODEL names, so initialism makes fall through to `.capitalize` (normalizer.rb:86) |

---

## 5. THE VERIFICATION LEDGER (the receipt for "manually reviewed")

### 5.1 Files and schema

One file per make: `data/review/<make_id>.yml`. Make-aligned (ownership,
alphabetical order, merge-friendly — the same properties that made the override
layer survivable under two writers).

```yaml
# data/review/volvo.yml
make: volvo
owner: s4w
batch: B-004
raw_fingerprint: "sha256:…"   # of the sorted raw (source, make, model) strings
                              # for this make across all cached snapshots —
                              # emitted by the review-pack generator. When a
                              # register starts emitting new spellings, the
                              # fingerprint changes and verdicts go STALE.
reviewed_at: 2026-08-02
researcher: "opus5/swarm-B004-r1"     # who proposed the verdicts
verifier:  "opus5/swarm-B004-v1"      # who adversarially confirmed — MUST differ
records:
  - id: car/volvo/240
    verdict: canonical        # see 5.2
    evidence: "https://www.media.volvocars.com/global/en-gb/media/pressreleases/194064/  (manufacturer archive; MY1983 badge consolidation)"
  - id: car/volvo/60
    verdict: debt
    note: "statistical bucket (S60+V60), resolution blocked on FZ 11.1 — G5"
    evidence: "in-data: XC60 is its own row in the same table; segment MITTELKLASSE"
```

### 5.2 Verdict vocabulary (closed set — the lint rejects others)

| verdict | meaning | requirements |
|---|---|---|
| `canonical` | record verified correct as published: name form, altitude, kind, make, no duplicate | evidence citation |
| `fixed` | a defect was found AND the fix is merged (rename/move/drop/body/alias) | evidence + the override line or PR |
| `debt` | defect confirmed, fix blocked or unresolvable — tracked, never guessed | note naming the blocker; entry in `name_shapes.yml` debt if shape-detectable |
| `removed` | record verifiably not a vehicle/nameplate; dropped with alias or CHANGELOG entry | evidence + I-5 compliance |
| `moved` | evidence relocated (make or kind) with former_ids alias | evidence + no-vanish proof |
| `stale` | (machine-set) raw fingerprint changed since review | re-review queued |

**COVERAGE IS NOT QUALITY** (S2W, Turn 80 — quoted because it is exactly
right): *"A documented marque gives you something to be WRONG AGAINST.
Register-only records cannot be caught being misspelled — there is nothing to
compare them to. So the makes with the cleanest ledgers are the ones nobody
can check."* Always quote the register-only count next to the coverage
number; the two move in opposite directions for the same underlying reason.

**Rules.** A verdict without an evidence citation is invalid (the lint enforces).
`researcher` ≠ `verifier` always (I-11). A `canonical` verdict on a record that a
detector flags requires the evidence to address the flag specifically ("looks
like D9 but is Rieju's official model name, per rieju.com/…"). Verdicts are per
**id**; a make is done when every published id under it has a non-stale verdict.

**Two-phase state (amended after the B4 pilot, Turn 55 finding 1 — BLOCKING).**
A researched-but-unverified ledger is a legitimate intermediate: the researcher
ships with `status: awaiting_verification` + `verifier: null`. The lint
tolerates exactly this pair (a signed verifier with awaiting status fails, and
vice versa), and the make's verdicts are EXCLUDED from the coverage numerator
until a verifier signs. Anything else would force single sessions to sign both
fields — the letter of I-11 with none of its substance, which is how a
verification ledger's central claim becomes unfalsifiable.

**Evidence classes (amended after the B4 pilot, Turn 55 finding 3).** For
long-tail makes the register IS the totality of available evidence — RA9015-
class models have no manufacturer page, no press release, no archive, and
Tranche C is ~400 makes of this. Forcing a URL there pushes researchers toward
laundering retailer listings into "evidence", which is strictly worse than an
honest ceiling statement. Sanctioned substitute:

```yaml
  - id: moped/iva/ra9015
    verdict: fixed
    evidence_class: register-only   # asserts: the pack's registry rows are the
                                    # totality of evidence, corroborated across
                                    # the raw spellings listed there
```

`register-only` verdicts count toward coverage (they are verified against the
ceiling of what exists) but are tallied on their OWN coverage line so the split
stays visible — the number stays honest instead of the verdicts getting
optimistic. The class list is closed (the lint rejects others); propose new
classes here first, with the failure mode they prevent.

### 5.3 Coverage metric and CI wiring

`scripts/lint_review.rb` (to build, Phase 1):
- validates schema + closed vocabulary + researcher≠verifier + evidence present;
- computes coverage per owner and in total; **coverage may never decrease** on
  main (same monotonicity contract as `debt`);
- marks records `stale` on fingerprint mismatch and fails if a "done" make has
  stale records older than one release;
- cross-checks: every `fixed`/`moved`/`removed` verdict must correspond to an
  actual override line / former_ids alias / CHANGELOG entry — a verdict claiming
  a fix that does not exist is exactly the silent-loss class this repo specializes
  in producing.

### 5.4 Review packs (what makes a review take minutes, not hours)

`pipeline/tools/gen_review_pack.rb <make>` (to build, Phase 1) emits one pack
per make containing, per record: current id/name/kind, **all raw source
strings** that reconcile into it (from pipeline cached snapshots — reviewing
the published name without the raws is how the SEAT deletion happened),
per-country counts and sources, collision candidates within the make
(NFKD-folded), any moves/renames already touching it, detector flags with the
D-class, the marque convention (§11.2) if recorded, and the raw fingerprint.

**Two sections are MANDATORY, because their absence is what hid the expensive
failures** (Turn 42 review):

1. **Candidate-queue rows** for the batch's makes (`build/candidates/*.jsonl`)
   — a vanished record is absent from a per-published-record pack BY
   DEFINITION; the queue is the only place a vanish is visible.
2. **Dead override keys** — every renames/moves/drops key targeting these
   makes that matched ZERO rows in the current build. A silent miss becomes a
   visible line.

**Implementation constraint:** the pack's curation lookup MUST be built on the
pipeline's own fold/normalization by REQUIRING the pipeline code — never a
reimplementation. A pack that resolves curation with plain string matching
while the pipeline folds will report "no curation touches this record" for
precisely the records whose curation silently failed — it does not merely omit
the evidence, it asserts the opposite.

Requires `VDB_DATA_REPO` + `VDB_CACHE_DIR`; must run offline from snapshots.
The pack is the ONLY input a research agent needs besides the internet.


---

## 6. BATCHING & PARALLELIZATION

### 6.1 The batch is a make-set, never a kind or a defect class

Kind-batching puts two swarms inside one `Honda:` YAML block (duplicate-key
destruction); defect-batching makes every make a merge conflict. Make-batching is
what the whole override layer is keyed for.

### 6.2 Co-batching constraints (MANDATORY — violating these recreates incidents)

1. **Approval-holder clusters ship as ONE batch** (I-8; a move authored without
   its counterpart make in scope caused the 17-nameplate Vespa split):
   `{Piaggio, Vespa, Aprilia, Moto Guzzi, Derbi, Gilera}` ·
   `{KTM, Husqvarna, GasGas}` · `{SEAT, Cupra}` · `{Hyundai, Genesis, Kia?}` ·
   `{BMW, Alpina, BMW-Alpina}` · `{Renault, Alpine, Renault-Alpine,
   Renault-Trucks}` · `{Chevrolet, Chevrolet-GMC, GMC, Daewoo, GM-Daewoo}` ·
   `{Austin, Austin-Morris, Morris, Leyland*, BMC-era}` · `{Jawa, Jawa-CZ, CZ}` ·
   `{Zero, Zero-Motorcycles}` · `{E-max, Emax}` · `{Solex, E-Solex}` ·
   `{Iveco, Iveco-Bus}` · `{VDL-Bova, Bova}` · `{Daimler, DaimlerChrysler,
   Chrysler}` · `{Toyota, Lexus}` · `{Fiat, Abarth}` · `{Volvo, Polestar}` ·
   `{Honda, Montesa}` (Montesa Honda S.A. ~88% Honda; co-badged, registries
   file either way) · `{Silence, Scutum}` (legal-entity rebrand — the cluster
   exists to stop a batch UN-merging the existing alias) · `{Vmoto, Super
   Soco}` · `{Peugeot, Peugeot Motocycles}` (**cross-half**: Peugeot is s4w,
   its mopeds are s2w; majority-Mahindra since 2015 but registries file the
   scooters under PEUGEOT).
   Discovering a new holder relationship mid-batch → STOP, extend the batch,
   note it here.

   **The rule that defines membership — approvals, not equity.** A cluster
   follows TYPE APPROVALS, not ownership headlines: MV Agusta is
   majority-Pierer since 2024 and is NOT in the KTM cluster, because it
   retains its own approvals. Equity news is exactly what tempts a researcher
   to over-merge; the question is always "whose approval do the registered
   vehicles carry?"

   **Why Vespa is in the Piaggio cluster — the precise mechanism, because it
   is what caused the split:** RDW files Vespa rows under `merk=PIAGGIO` with
   the badge stripped, so one nameplate exists in one register as
   `VESPA ET4 150` and in another as bare `ET4 150`. Moving one spelling
   without its twin leaves both single-source below threshold and both vanish.
   A cluster is not "these brands are related" — it is **"these brands share
   nameplate strings with and without a prefix."**
2. **A batch owns its makes across ALL SIX KINDS** (renames are kind-blind; the
   26 arbitrated makes especially).
3. **No batch may add `styling.yml` acronym tokens.** Tokens re-case the entire
   catalog and orphan other batches' rename keys. Whole-string pins are
   unrestricted; token requests go to the integrator queue (§8.4) with a
   full-catalog blast-radius sweep attached.
   **Corollary — acronym MAKE names (D23) are fixed in `makes/aliases.yml`,
   never via styling tokens**: an alias entry is scoped to the make name and
   cannot blast another batch; a token re-cases every model string containing
   it catalog-wide. Precedent: `d3642f5` fixed MV Agusta/GMC/NSU/TGB this way.
   "How do I fix KTM then?" has exactly one right answer and it is this one.
4. **No batch edits shared pipeline files** (`normalizer.rb`, `reconciler.rb`,
   `emit.rb`, multi-kind sources). Batches produce override lines, ledger
   verdicts and ISSUES; pipeline changes go through the two maintainer sessions.
5. Batches touching the same file region are impossible by construction
   (alphabetical make blocks + disjoint make-sets + `lint_curation` dup-key
   check) — but batches still rebase before opening a PR and never reorder
   lines they do not own.

### 6.3 Batch manifest

`data/review/batches.yml` — the dispatch board. Append-only status transitions.

```yaml
- id: B-004
  tranche: A
  makes: [volvo, polestar]          # co-batch: approval/corporate cluster
  records: 348                       # published ids in scope at cut time
  status: verified                   # queued → researching → verifying →
                                     # applying → gated → merged | reverted
  branch: swarm/B-004-volvo
  researcher: opus5/…                # filled as work proceeds
  verifier: opus5/…
  notes: "volvo/60 → debt (G5)"
```

### 6.4 Sizing and tranches

- Batch size: **150–450 published records** (one big make, or one cluster, or
  10–30 long-tail makes). Below 150 the fixed cost dominates; above ~500 the
  verifier loses the ability to actually re-derive.
- **Tranche A** — global_decile 1–3 records (~5,400) across the ~50 largest
  makes: what consumers actually query. ~18–22 batches.
- **Tranche B** — remaining records of curated makes + the residual duplicate
  groups (G8). ~15 batches.
- **Tranche C** — the long tail: 400+ makes with ≤5 records. Different mode:
  the question is *existence* (real marque? approval holder? coachbuilder?
  corporate string? registry junk?), and it is where drop/merge decisions
  concentrate and the approval-holder trap bites hardest. Batches of 20–40
  makes. ~15 batches.
- Estimated total: **45–60 batches.** Marque-archive research is proven at ~4
  major marques per research pass (the Mercedes/Volvo/Jaguar/Lexus pass was one).

### 6.5 What a batch may and may not conclude alone

MAY: rename within its makes; merge duplicates within its makes; drop with
alias/CHANGELOG within its makes; author moves WITHIN its co-batch cluster;
body_types overrides scoped `Make|Model`; aliases; ledger verdicts; open-layer
enrichment rows once plumbing exists (§14).
MAY NOT: make merges across cluster boundaries; kind changes (file to G3
process); acronym tokens; threshold or schema changes; anything in `catalog/`
or `dist/` (build outputs — hand edits are silently overwritten and hide
normalizer bugs); publishing.

---

## 7. THE PER-RECORD REVIEW PROTOCOL (the checklist)

For every record in the pack, in order. Skipping a step invalidates the verdict.

1. **REALITY** — do the raw strings support a real vehicle? (I-7 first: if the
   name is a bare number or code, suspect the parser/source before the data;
   check the pack's raw strings and, if numeric-run-shaped, demand the row-level
   re-parse evidence before anything else.)
2. **MAKE** — is the make the true marque? (I-8: approval-holder check. Does the
   model string carry another marque's badge? Is the make a corporate string, a
   coachbuilder, an entity name?)
3. **ALTITUDE** — is this a nameplate, or a trim/edition/body/engine/registry
   code of one? Two-wheelers: displacement stays separate (`Senda 50` ≠
   `Senda 125`); trims fold. Meaningful sub-models are recorded as `variants`
   (open shape), not separate ids.
4. **DUPLICATES** — NFKD-fold within make+kind; check collision candidates in
   the pack; check the co-batch cluster for cross-make twins; case-only pairs
   get the skew test (§10.4).
5. **NAME FORM** — casing/spacing/accents against the marque's own convention
   (§11); if the marque has no convention entry yet, this record's research
   CREATES it (with sources) — that is the compounding asset.
6. **KIND** — right kind per the legal-category logic; camper/commercial
   leakage; remember M1 has no mass ceiling.
7. **BODY TYPES** (cars + trikes/quadricycles) — plausible, not poisoned by an
   unscoped rule (D16).
8. **AVAILABILITY & POPULARITY sanity** — countries plausible for the marque and
   era (grey imports are a feature, not an error — NZ JDM); rank outliers
   explained.
9. **ALIASES** — genuine market names/nicknames/native scripts only, with a
   which-world comment; never SEO stuffing.
10. **ENRICHMENT capture** (once plumbing exists): year_start/year_end,
    generation codes, notable variants — recorded with per-fact citations.
11. **VERDICT + EVIDENCE** per §5.2, filed in the ledger draft; every fix
    expressed as an override line carrying its own `#` why + source.

**Citation format:** URL + one clause saying what it evidences and its class per
NAMING.md's ranking (TAN > live registry > manufacturer material > corroboration
> encyclopaedic). For defunct marques with no manufacturer material,
encyclopaedic is acceptable — say so rather than dressing it up.

---

## 8. SWARM TOPOLOGY, MODELS, AND PROMPTS

### 8.1 Model requirement

**Every swarm agent — researcher, verifier, applier, auditor — runs
`claude-opus-5` (Agent-tool `model: "opus"`). Not Fable, not Sonnet, not Haiku.**
This is an owner directive. Reasoning effort: researchers `high`; verifiers
`xhigh` (the verifier is the last line before the ledger, and the correction
pass showed the failure mode is *confident plausibility* — exactly what maximum-
effort adversarial reading exists to catch).

### 8.2 Roles per batch

```
ORCHESTRATOR (the maintainer session): cuts the batch, generates packs, spawns
  agents, owns the branch, runs gates, merges. Never authors verdicts itself.
RESEARCHER (1–3 per batch, parallel by make): works the §7 checklist from the
  pack + internet; produces draft verdicts + proposed override lines + a marque
  convention note. Web access required; obeys §12.
VERIFIER (exactly 1, distinct instance): adversarial. Re-derives a mandatory
  sample (≥20% of records, 100% of fixed/removed/moved verdicts) from raw
  evidence WITHOUT reading the researcher's reasoning first — then reconciles.
  Explicit brief: try to REFUTE. Confirms, revises, or rejects each verdict.
APPLIER (may be the orchestrator): mechanically applies confirmed verdicts —
  override lines via the alphabetical-insert pattern, ledger file, spotcheck
  rows for every new invariant. Runs ALL lints + pipeline tests +
  verify_source_landing + (once built) the no-vanish diff.
```

### 8.3 Researcher prompt template (adapt per batch; keep the skeleton)

```
You are reviewing vehicle records for VehiclesDB, an open CC-BY dataset built
from official registers. Your output becomes permanent curation, so every claim
needs a source.

INPUTS: the attached review pack for make(s) {MAKES} ({N} records). It contains,
per record: the published id/name/kind, the RAW registry strings that produced
it, per-country counts, collision candidates, detector flags (D-classes), and
any existing curation touching it.

TASK: for every record, execute this checklist in order: reality → make →
altitude → duplicates → name form → kind → body types → availability sanity →
aliases → enrichment capture. Then emit a verdict (canonical | fixed | debt |
removed | moved) with an evidence URL and a one-clause justification.

HARD RULES YOU MUST NOT VIOLATE:
- A bare-integer or code-like name, single-source, is a PARSER suspect before a
  data suspect. If the raw strings look like an index run, verdict=debt with
  "needs row-level re-parse", never removed.
- Registers file sub-brands under the type-approval holder. Before concluding
  "wrong make" or "duplicate make", establish who holds the approval.
- Wikipedia/wikis/other vehicle databases: use only to LOCATE primary sources.
  Never import their content or lists (they are ShareAlike; this dataset is
  CC-BY). Manufacturer sites, press releases, heritage archives, regulator
  documents are your sources of record. When NONE of those exist for a model —
  discontinued OEM-code long-tail, the RA9015 class — do NOT launder a retailer
  listing into an "evidence" URL and do NOT park two-thirds of a make in debt
  to look compliant: write `evidence_class: register-only` (§5.2), which
  asserts the pack's registry rows are the totality of evidence. Honest ceiling
  beats optimistic verdict, always.
- Corroboration proves a record is REAL, not that its name is canonical — and
  proves nothing for make-as-model / embedded-make records.
- Trims, editions, body styles and engine variants FOLD into the nameplate;
  two-wheeler displacement stays separate. Record meaningful sub-models as
  `variants` proposals, not new ids.
- If the marque changed its own convention mid-history (XJ-S→XJS), pick per
  NAMING.md and record the change point with its source.
- When you cannot resolve something, verdict=debt with the blocker named.
  A wrong confident answer is worse than a tracked unknown — this dataset once
  deleted a marque's entire national lineup on a confident wrong answer.
Also produce: a MARQUE CONVENTION note (naming pattern, casing rules, suffix
semantics, source URLs) for each marque you researched — even when you found no
defects. Fetch note: some archives 403 default clients but serve a browser
User-Agent (Mercedes marsClassic); never hammer registries; th_dlt and
fi_traficom are hostile to repeated automated requests.
OUTPUT: YAML per §5.1 + proposed override lines (each with same-line `# why +
source`) + the convention note + a list of anything that smells like a NEW
defect class.
```

### 8.4 Verifier prompt template (v2 — amended after S2W's structural review, Turn 42)

```
You are the adversarial verifier for batch {ID}. Your job is to REFUTE.

Independence first: for {sample = all fixed/removed/moved verdicts + a ≥20%
random sample of canonical}, re-derive the verdict from the pack's RAW strings
and your own research BEFORE reading the researcher's evidence. Then compare.

MANDATORY NON-SAMPLED SECTION (100%, every batch — three of the five failure
shapes are OMISSIONS, which no sample of authored verdicts can find):
  * the pack's candidate-queue section: every candidate row for this batch's
    makes — is any of them a record that was published before this batch's
    changes? That is a vanish in progress.
  * the pack's dead-key section: every override key targeting these makes that
    matched ZERO rows — each one is curation silently doing nothing.

For each divergence: determine which side is wrong and WHY (bad source, altitude
error, approval-holder miss, harness/tooling artifact…). For each agreement on
fixed/removed/moved: independently confirm (a) the evidence URL actually says
what is claimed, (b) the override line is reachable — post-cased key, correct
display-name block, string values quoted, AND the key survives the same fold
the pipeline applies (diacritics, oe/ue/ae/ss digraphs, punctuation: BÜRSTNER
in a drop list never matched the folded make, and the key was correctly cased,
correctly placed, correctly quoted, and still dead), (c) former_ids covers
every id change. Record-level vanish-proofing is the G2 GATE's job, not yours —
your job is the two visibility sections above, which let a human see it coming.

A canonical form emitted by a DETECTOR is a candidate, not evidence — the
tooling's `canonical:` column has been measured at 86-91% wrong on alphanumeric
type designations. Cite the marque archive or return debt; never confirm a
canonical because the tooling proposed it.

You are specifically hunting the five historical failure shapes: confident
deletion of real data (live example: bus/factory-built holds models "Geely",
"Yutong", "Zhongtong" — three real manufacturers parsed into the model column;
the "obvious" drop deletes them); the approval-holder trap; the badge-twin
split; the threshold vanish; and canonical forms invented by rule rather than
proven by archive. Output: per-record CONFIRMED / REVISED(with correction) /
REJECTED(with proof), plus anything the researcher missed entirely. If >10% of
your sample is REVISED/REJECTED, halt and return the batch — do not patch it.
```

### 8.5 Batch flow, mechanically

1. Orchestrator: cut batch in `batches.yml` → branch `swarm/<id>-<slug>` in a
   dedicated worktree → `gen_review_pack` per make.
2. Spawn researchers (parallel, one per make-group) → collect drafts.
3. Spawn verifier (xhigh) → reconcile; >10% rejection returns the batch.
4. Applier: overrides + ledger + spotchecks; run `lint_overrides`,
   `lint_curation`, `reorg_make_blocks --check`, `lint_dataset`, `lint_review`,
   pipeline `rake test`, `verify_source_landing` (if the batch touches a
   source's makes), the no-vanish diff.
5. PR with: verdict counts, defect counts per D-class, evidence-loss list
   (should be empty or explicitly accepted), pack + verdicts attached. The
   orchestrator of ANOTHER batch (or the other maintainer) reviews — never the
   batch's own agents (I-11).
6. Merge → update `batches.yml` → append batch summary to the pass log.

Concurrency: batches are independent by construction; run as many in parallel
as review capacity allows, but **stagger merges** (rebase-before-merge is cheap;
simultaneous merges to the same override file are what the union-merge incidents
came from). One integrator serializes merges per repo per hour.

---

## 9. CONCURRENT-SESSION WORKING PROTOCOL

Battle-tested across 40 turns of two-session work; adopt verbatim.

1. **Primary clones are read-only** (`~/GitHub/vehiclesdb`,
   `~/GitHub/vehiclesdb-pipeline`): the place to read merged state, never to
   work. Every session/swarm works in its own `git worktree`
   (`~/GitHub/.vdb-worktrees/<session>-<repo>`) on prefixed branches
   (`s4w/…`, `s2w/…`, `swarm/B-…`). One `git checkout` in a shared tree
   changes another session's files mid-edit — this nearly happened.
2. **No force-push anywhere**, including main. Rebase before opening a PR;
   never rebase a branch another session has reviewed.
3. **Announce-before-edit files** (post intent in the pass log first):
   `pipeline/lib/normalizer.rb`, `reconciler.rb`, `emit.rb`, multi-kind
   sources (`nl_rdw`, `uk_dft`, `es_dgt`, `fi_traficom`, `nz_nzta`, `ua_mvs`),
   `.github/workflows/*`, `SCHEMA.md`, this file's invariants.
4. **The pass log** is the coordination channel: an untracked
   `NEGOTIATION.md`-style file in the primary data clone, append-only
   (`cat >>`), single turn counter — **committed as a
   `CORRECTION-PASS-<date>-LOG.md` snapshot when the pass ends** (the Turn-40
   seam rule: the working file and the committed log must be re-synced at pass
   end, or the archive silently truncates).
5. **Cross-boundary findings are FILED, never fixed by the finder** — the
   handoff ledger discipline. A whole-file script without an ownership filter
   is a boundary violation even when its rule is correct (this shipped 64
   wrong-convention entries once).
6. **Escalate to the human owner, always:** publishing; schema versions;
   anything touching the Open Contract or licences; kind/id-vocabulary
   decisions; deleting a make; spending against paid sources; and any case
   where both sessions disagree after one full evidence exchange.

---

## 10. DEDUPLICATION SPECIFICATION

### 10.1 The four duplicate classes

| class | detector | resolution |
|---|---|---|
| spelling collision (same make+kind) | NFKD-fold equality | merge into canonical (existing variant if one is correct; else marque-archive-proven new string) |
| cross-make (approval holder / corporate) | badge-in-model, containment scan, holder research | `moves.yml` (model-level) or make alias (make-level); NEVER before the holder check |
| cross-kind | same id in car+van/truck | usually legitimate (Transporter van + camper car); only a defect when one side is leakage (campers, M1 vans) — resolve by kind hygiene, not merge |
| case-only | case-insensitive equality, case-sensitive difference | skew test (§10.4) |

### 10.2 Merge mechanics (every merge, no exceptions)

(a) canonical target chosen per §11; (b) all non-canonical spellings renamed in
`overrides/models/renames.yml` (post-cased keys, display-name block, quoted
numeric strings); (c) **every register's spelling co-moved** — enumerate the raw
strings from the pack and confirm each maps (the badge-twin rule); (d)
`former_ids` alias for every id that ceases to exist; (e) availability-subset
verified, losses documented; (f) spotcheck presence row for the canonical with
its unioned evidence; (g) no-vanish diff green.

### 10.3 The threshold interaction (why merges and moves are dangerous)

Publication requires ≥2 sources or a single-source count above
`car 1000 / motorcycle 300 / moped 300 / van 300 / truck 150 / bus 50`.
**Relocating half a nameplate's evidence strands both halves below the bar and
the record silently joins the candidate queue** — indistinguishable from
legitimately-thin records. This deleted `vespa/et4-150` and 34 microcars in two
separate incidents. Hence I-6 and the G2 gate: per-id verification, not
aggregate counts.

### 10.4 The case-pair skew test

Registry case-inconsistency is heavily SKEWED (one form dominant 10–100×,
because one data-entry convention prevails). Two genuinely different products
sharing a case-folded name show **comparable volumes and disjoint year ranges**
(`S-type` 1963 vs `S-TYPE` 1999). Measure before collapsing; all 515 case-only
pairs measured on the 2W side were skewed (collapse-correct), but the one
counterexample is exactly one id-destroying mistake.

---

## 11. CANONICALITY SPECIFICATION

### 11.1 NAMING.md is normative

This section adds process, not policy. The evidence ranking, the
parser-before-data rule, kind hygiene and mechanism choice live there.

### 11.2 Marque convention dossiers — the compounding asset

Every batch MUST produce/extend a convention entry for each marque it touches,
even with zero defects found. Store as a `convention:` block at the top of
`data/review/<make>.yml`: the naming pattern, casing/spacing/suffix semantics,
convention-change points with dates, and source URLs. Verified so far (do not
re-derive; cite): **Mercedes-Benz** `<number> <UPPERCASE letters>` with
lowercase series letters (`220 SEb`) and hyphenated valve counts (`300 CE-24`);
trucks invert (`L 312`); marsClassic archive is authoritative (403s default
fetchers, serves browser UA); "S = Sonderklasse" is a back-formation — do not
assert it. **Lexus** `<CODE> <NUM><suffix>`: powertrain suffixes lowercase
(`450h`), body uppercase (`250C`); space before the code-number, never before
the suffix; JDM closes the space, everyone else spaces; the nameplate is the
LINE. **Volvo** dropped the P (`1800E`); PV-series letters are production years,
not trims; `240` absorbed 242/244/245 (MY1983 consolidation); `262C` distinct.
**Jaguar** `XJ-S` (launch form; hyphen left the badge 1991, VIN 179733);
`XJ6`/`XK8` closed; `E-type` lowercase t; ALL-CAPS moderns are official and
case-distinctive. **smart** models carry the hash (`#1`); marque officially
lowercase. **DS** mid-migration to `N°` names (`DS N°4`, `DS N°8`); DS 3/DS 7
still current. **Cupra/Genesis/GWM(Ora/Wey product lines)/Omoda/Jaecoo(own
marques, no Chery row)/NIO(EL6/EL8 in Europe)/Toyota bZ4X/Mazda
CX-6e-is-real**: see the correction-pass briefs.

### 11.3 Styling governance

Whole-string `stylings:` pins — unrestricted, blast radius 1, prefer always.
`acronyms:` tokens — integrator-only, full-catalog sweep attached, **never in
the same PR as rename keys that depend on the token** (caser runs before
renames). Case-distinctive marques (Jaguar S-type/S-TYPE) are the reason the
dedupe key must never be case-folded without the skew test.

---

## 12. INTERNET RESEARCH RULES (for every swarm)

1. **Sources of record**, in order: type-approval/TAN data → live official
   registers (RDW SODA CC0 is the workhorse; cite query + date) → manufacturer
   current + heritage material → national regulator documents → period press /
   marque clubs (naming/history only) → encyclopaedic (last resort, label it).
2. **Never import** from wikis (SA), other vehicle databases, forums-as-data,
   or any list whose licence you have not read. Verify-then-restate facts;
   never copy compilations (I-1/2/3).
3. **Cite everything**: URL + what it evidences. An uncited verdict is invalid.
4. **Fetch etiquette**: browser UA where needed (marsClassic); NEVER hammer
   government portals (th_dlt/fi_traficom documented hostile; one-IP
   coordination: announce live-fetch windows in the pass log; prefer cached
   snapshots — packs are built from them for exactly this reason).
5. **Language**: read sources in their own language (KBA methodology is German,
   DGT is Spanish; both bit us). Translate the evidence clause in the citation.
6. **Dead marques**: heritage archives > club registries > period road tests.
   Say which you used.
7. **Anything that looks like a new SOURCE candidate** (an open national
   register we do not ingest) → file to §13 with the licence text located.
   Never ingest ad hoc.

---

## 13. COMPLETENESS PROGRAM (regions, categories, the candidate queue)

### 13.1 The completeness bar

Every kind non-empty and honest; every region with an eligible open register
ingested or explicitly rejected with the licence reason on file; candidate-queue
depth per kind tracked as a moat metric (unbounded growth = tripwire).

### 13.2 Source expansion targets (investigate LICENCE FIRST — the be_fps rule)

Priority order balances market value, licence likelihood, and reconciliation
lift (a new register corroborates thin records catalog-wide, promoting
candidates):

| tier | candidates | notes |
|---|---|---|
| 1 | **IL** data.gov.il vehicle register (open, famously complete); **SG** LTA DataMall (open licence); **AU** BITRE/state registration stats; **BR** SENATRAN frota por marca/modelo (dados.gov.br); **NO** (NLOD), **SE**, **DK**, **AT** national stats | high-quality open portals; check each licence text and pin phrases |
| 2 | **FR** SIV extracts (Licence Ouverte), **IT**, **PT**, **PL**, **CZ**, **RO**, **GR**; **BE** (blocked on G6) | EU — mind national quirks; Slovenia withdrew (precedent) |
| 3 | **JP** (MLIT/AIRIA aggregates), **KR** MOLIT, **TW**, **IN** VAHAN dashboard, **ID**, **PH**, **VN**, **MX** INEGI, **CL**, **CO**, **ZA** eNaTIS, **TR** | licence and format research heavier; JDM/India/LatAm close the biggest coverage biases documented in SCHEMA.md |

Each investigation produces: dataset URL, licence text + proposed pin phrases,
format/cadence, per-source gotchas, kind coverage, expected new-make yield —
filed as an issue; ingestion is a maintainer-session task, never a swarm task.

### 13.3 The candidate queue is a completeness asset

`build/candidates/<kind>.jsonl` holds every reconciled entity below the publish
bar. Rules: (a) after any change that relocates evidence, DIFF the queue — new
arrivals that were published before are incidents (D14/D15); (b) periodically
mine it for real long-tail models promotable via curation once verified (that is
its design purpose); (c) queue depth per kind is reported at every build.

### 13.4 Kind-taxonomy extension policy (G24 — owner directive, 2026-07-26)

The owner's framing: the dataset should eventually make ROOM for vehicles
beyond the six road kinds — bicycles, trains, planes, and whatever else we
encounter — "nicely categorized and clustered", WITHOUT launching research
teams for them now. This section is that room, made structural:

**The id namespace already supports it.** Ids are `<kind>/<make>/<slug>`, so a
new kind is a new namespace — it can never collide with or pollute existing
ids. Kinds therefore extend ADDITIVELY (minor schema bump), and the risk is
never mechanical; it is taxonomic (a sloppy kind boundary poisons every record
inside it, which is why the vocabulary stays CLOSED and extension is a
procedure, not an edit).

**Extension procedure — a new kind lands only with ALL of:**
1. a coherent legal/technical definition with non-overlap stated against every
   existing kind (the quadricycle precedent: L6e/L7e were ADJUDICATED into
   existing kinds rather than minted, because the boundary work is the hard
   part);
2. at least one licence-cleared source actually emitting the category
   (§13.2 rules apply — licence first);
3. a publication threshold (KIND_THRESHOLDS entry) argued from that source's
   volume;
4. an OWNERSHIP assignment for the new kind's makes;
5. a PRD amendment recording 1-4. No speculative empty kinds.

**The `domain` grouping (the "clustered" half).** When a second domain lands,
records gain a DERIVED `domain` field — `road` today; `rail`, `air`, `water`,
`human-powered` reserved — computed from kind at emit time, never stored
(the §14.4 store-facts-derive-labels rule). Zero cost until needed.

**The encountered-category inventory (measured 2026-07-26).** Sources already
emit categories we drop, each logged per build — this is the "come across"
list the policy exists for, with current dispositions:

| category | volume | disposition |
|---|---|---|
| trailers/semi-trailers (ua ПРИЧІП/НАПІВПРИЧІП, es O2/O4) | ~37k rows/build | drop + log. Weak make/model semantics; first candidate IF a consumer appears |
| quads/trikes (ua КВАДРОЦИКЛ/ТРИЦИКЛ, th 3-wheelers) | ~2.7k rows | L-category adjudication per G3 — existing kinds, S2W's call per row-class |
| agricultural tractors (es T2A/T3B) | ~2.8k rows | reserved kind `agricultural`; drop + log until procedure runs |
| e-bikes/speed-pedelecs with type approval (L1e-A) | already ingested | land in `moped` correctly (QWIC precedent) — unregistered bicycles have NO register and thus no source; a future `bicycle` kind would need catalog-type sources, different evidence rules |
| ua ВАНТАЖНИЙ freight (66,956 rows) | NOT a taxonomy gap | existing kinds (van/truck) blocked on the BODY-column split — documented backlog in ua_mvs.rb, tracked as G25 |
| trains / aircraft / vessels | 0 rows (no ingested source) | reserved kinds; aviation/rail registers are public and rich — future domains when a consumer exists |

Body types: quadricycle vocabulary lands with G3; van/truck/bus body vocabulary
only when derivable honestly from registers (absence rule — never guess).

---

## 14. ENRICHMENT PROGRAM

### 14.1 Open-layer enrichment (in scope for swarms once G17 plumbing lands)

Targets, all additive per SCHEMA.md: `aliases` (models + makes),
`year_start`/`year_end`, `generations` (chassis codes: `suzuki/jimny/jb74`),
`variants` (M2, GTI — type: performance/trim/body/edition), body_types where
kind-appropriate, `regions` (automatic). Plumbing to build first:
`overrides/enrich/<make>.yml` (make-aligned, same lint regime: per-line
citation, alphabetical, dup-key-checked) + pipeline emit support
(announce-before-edit files; maintainer sessions implement, swarms populate).
**Every enrichment fact carries its own citation in the override comment** —
enrichment without provenance is how open datasets rot.

### 14.2 Depth-layer enrichment (private)

Full spec sheets, configurations, engines/power/dimensions, absolute counts,
time series, images. Governed by `PRD-DEPTH-ENRICHMENT.md` in the private
pipeline repo (licensing posture, storage schema, prioritization by commercial
value). The open/closed boundary is the Open Contract: **nothing that is open
today ever moves behind the paywall**; depth only adds. Swarms doing open-layer
review SHOULD capture depth-grade facts they encounter (a press release stating
power figures) as pointers in the batch notes — captured, not published.

### 14.3 Enrichment quality rules

Unit normalization declared (kW vs PS vs hp; mm; kg); every numeric spec carries
source + model-year applicability; range checks (a 50cc moped with 150 kW fails
loudly); conflicting sources recorded as conflicts, not averaged.

### 14.4 CLASSIC / VINTAGE / DISCONTINUED program (owner directive, 2026-07-25)

The owner's framing: production-era data is "CANDY for classic collectors" —
the catalogs already carry thousands of still-registered classics (Triumph
TR2s, Volvo P1800s, W111 Mercedes, BMW airheads, a 1929 Harley DL) with no way
to find them. This is a first-class program item, gap-registered as **G23**.

**Design principle: store FACTS, derive LABELS.** The dataset stores
`year_start`/`year_end` (production years, per id, sourced). Era tags are
DERIVED at emit time, never hand-curated — derived labels cannot rot or drift:

| derived tag | rule | rationale |
|---|---|---|
| `discontinued` | `year_end` present and in the past | plain fact |
| `classic` | `year_end ≤ build_year − 30` | the 30-year line is the dominant legal/insurance convention (Germany's H-Kennzeichen §2 Nr. 22 FZV; most collector-insurance definitions) |
| `vintage` | `year_end ≤ 1930` | pre-1931 — and NOT car-centric: the VMCC and FIVA class structures use the same line for motorcycles (Veteran pre-1905, Vintage 1905-1930, Post-Vintage 1931-45). Main competing convention for `classic`: the UK rolling 40-year historic exemption — noted so nobody "fixes" the 30-year line without reading this |

Rules are configurable constants in the emitter with the source for each
boundary in a comment; a record with no `year_end` gets NO era tag (unknown is
not current).

**Storage** (rides the §14.1 plumbing): `overrides/enrich/<make>.yml`, keys are
ids, values a list of production RUNS, per-line citation mandatory:

```yaml
motorcycle/triumph/bonneville:
  runs:
    - {year_start: 1959, year_end: 1983, note: Meriden}
    - {year_start: 2001}                 # open run = in production
```

**Why runs, not a scalar pair (S2W's §14.4 review, Turn 66 — adopted whole):**
marques revive heritage names AS A BUSINESS MODEL, concentrated in 2W but not
confined to it (Speed Twin 1938→2018, Scout 1920→2015, Bonneville, Commando,
Dax, Monkey, Fiat 500, Mini, Defender, Bronco — 18 published multi-source
examples measured in the 2W half alone). A scalar `year_end` makes
`discontinued`-then-`classic` fire on bikes currently in showrooms — and
revived nameplates are PRECISELY what collectors search, so mislabeling them
is worse than no tag. Derivation: `discontinued` iff EVERY run is closed;
`classic` iff every run closed AND latest `year_end ≤ build_year − 30`. The
scalar pair is the one-run case; nothing is lost. Per-generation years belong
to `generations` entries when those land.

**Registration cross-check (same review):** the registers we already ingest
are a free CONTRADICTION DETECTOR — never a source for production years
(lag, grey imports), but a curated closed `year_end: 1983` on a nameplate
with 2024 registrations must FAIL the enrich lint, not publish.

**Sourcing hierarchy** (same bar as §12): manufacturer heritage archives
(media.volvocars.com press library, mercedes-benz-publicarchive.com,
Honda/BMW/Ducati heritage pages) → marque registries/clubs (volvoclub.org.uk
already precedent-cited in-repo) → period regulator documents. Wikipedia
locates, never sources (CC-BY-SA — invariant).

**FULL capture (G26b, owner directive)**: the §7 researcher is already ON
the page — capture EVERYTHING it states, structurally, into the PRIVATE
repo (vehiclesdb-pipeline `enrich/<make>.yml`): production `runs:`,
`links:` (model_url/maker page), `variants:` (the model lines the page
lists), and make-level facts (`make/<id>`: founded/dissolved/country/
parent/website). Verdicts and evidence citations stay in the PUBLIC
ledger; the captured facts are the paid layer's inventory. Prose-only
capture (facts established in comments and discarded) is the failure mode
this rule exists to kill — it burned real research in the KMZ/Saxonette/
B-002 passes. Wikipedia remains locator-only in BOTH layers (CC-BY-SA);
Wikidata (CC0) is the sanctioned bulk-structured source (G26c, pipeline
program); manufacturer pages are fact sources with per-entry citations.

**Not in the open layer**: valuations, survival counts, auction data,
collector-market signals — depth-layer material (§14.2, PRD-DEPTH).

**Implementation order** (G23a-d): (a) pipeline emit support for
`year_start`/`year_end` + derived `era` on the record (additive, minor schema
bump); (b) `overrides/enrich/` loader + lint (dup-keys, id-liveness,
year sanity: 1885 ≤ start ≤ end ≤ build year+1); (c) researcher-prompt
amendment (capture rule above); (d) backfill sweep scoped by **SOURCE
AVAILABILITY, not trading status** — B-002 settled this empirically
(Turn 80): huatian, hanway and kove's type codes are multi-source,
multi-country, TRADING marques that still land at register-only, because a
working OEM that documents nothing yields no source of record. "Defunct"
was a proxy; the axis is "does a source of record exist". The 31
wholly-defunct 2W marques (416 records; VMCC / BSA OC / VJMC archives)
remain the FIRST tranche because their sources exist and one source covers
a whole marque — not because they are defunct. 4W first tranche by the
same rule: mercedes-benz, volvo, triumph, ford, bmw (press libraries
already on file in this repo).

---

## 15. GATES & AUTOMATION TO BUILD (with acceptance criteria)

### 15.1 Three validate gates (G1 — S4W, in `pipeline/lib/validate.rb`)

- **former_ids-completeness**: for every override-layer id-changing intent
  (rename whose source differs from target post-slug, every move), assert an
  alias exists once the build shows the id changed. Fails listing the naked ids.
- **move-split**: after reconcile, for every move key, assert no candidate
  exists whose (source, make, folded-model) equals the key's model minus the
  target-make badge — i.e. no register twin left behind. Would have caught all
  17 Vespa splits; skips clean moves by construction.
- **former_ids-liveness**: no alias may name an id present in the same kind's
  current build output.

### 15.2 The no-vanish gate (G2 — S4W, `pipeline/tools/assert_no_vanish.rb`)

Input: previous build's id set (or published `dist/` at first run), current
build's id set, `former_ids`. Every id in prev∖curr must be (a) aliased to a
live id, or (b) listed in an explicit, PR-reviewed removal manifest. Output on
failure: the naked ids with their last-known evidence. Runs in every build;
consulted in every batch PR. **This gate converts the program's worst historical
failure mode from silent to impossible.**

### 15.3 Monitoring (weekly validate + every PR)

`lint_dataset` debt/unexplained trend (non-increase enforced), `lint_review`
coverage (non-decrease), candidate-queue depth per kind, drop-list
effectiveness, licence-pin drift, source freshness assertions (D20), per-source
row-count deltas >±20% flagged.

---

## 16. RELEASE & PUBLISH PROTOCOL

1. **The first post-correction publish (target window 2026-08-12) is
   supervised**: run validate; review the full dist-diff (ids added/removed/
   renamed, per-country availability deltas, popularity movements of decile-1
   records); no-vanish green; former_ids complete (G11 executed against the
   real diff); owner sign-off; then publish dispatch; then verify jsDelivr/HF
   propagation and gem snapshot; then tag the review baseline.
2. Rollback plan before dispatch: the previous dist is the rollback artifact;
   `@latest` consumers heal on re-publish; document the procedure once, in the
   pipeline repo.
3. Post-publish: re-run `lint_dataset` and `find_duplicate_spellings` against
   the new catalog (expect the step drop), re-baseline `name_shapes.yml` debt
   (G13), regenerate `OWNERSHIP.yml` (make count changed 860→849 — review the
   diff for owner flips; ties must go through the TIEBREAK pin).
4. Swarm batches NEVER publish. Merging curation is always publish-inert.

---

## 17. PROGRAM PHASES

| phase | content | exit criteria |
|---|---|---|
| **P0 — stabilize** (maintainers) | G1 gates, G2 no-vanish, G11 former_ids diff-run, G12/G13 hygiene, supervised publish (§16) | publish succeeds; 404-free migration verified; baselines re-cut |
| **P1 — harness** (maintainers) | ledger schema + `lint_review` + `gen_review_pack` + `batches.yml`; **pilot batch: `moped/iva`** (16 records, 4 defect classes in one tiny make — small enough to fully resolve, dense enough to shake the tooling; run by S2W, the harness NON-author, per I-11) | pilot merged with dual-signed ledger; tooling docs in this file amended from pilot findings |
| **P2 — Tranche A swarms** | ~20 batches, decile 1–3, co-batch clusters | coverage ≥ 60% of decile-1..3 records; zero gate regressions |
| **P3 — Tranche B + C swarms** | remaining curated makes; long-tail existence sweep | coverage 100%; debt register complete |
| **P4 — structural** (parallel w/ P2–3, maintainers) | G3 kind migration (post Spain-code research), G4 FZ11.1, G5, G6, G7 | quadricycles landed no-vanish-clean; volvo/60 resolved |
| **P5 — completeness** | §13 tier-1 source investigations → ingestions (own releases) | ≥3 new regions live; candidate promotions from new corroboration |
| **P6 — enrichment** | G17 plumbing → open-layer enrichment batches; depth per private PRD | years/generations/variants populated for decile-1 records with citations |

Phases 2/3/5/6 are swarm-parallel; P0/P1 are strictly first — **deploying
swarms before the ledger and the no-vanish gate exist would industrialize
exactly the failure modes this pass spent a day un-doing.**

---

## 18. RISK REGISTER

| risk | likelihood | mitigation |
|---|---|---|
| Swarm confidently deletes real data | proven | I-6/I-7 + G2 gate + verifier brief + "removed" requires alias/CHANGELOG |
| Approval-holder mis-merge | proven | co-batch clusters (§6.2), I-8, holder check in template |
| Badge-twin split on moves | proven | G1b gate + §10.2c |
| Threshold vanish | proven | G2 + per-id verification (I-6) |
| Licence contamination (SA import) | high w/ internet swarms | §12 rules in every prompt; verifier checks citations' licences; build gate on source list unchanged |
| Ledger gamed (verdicts without verification) | medium | dual-sign enforced by lint; cross-batch review; sample re-audits by maintainers |
| Merge-serialization breaks under many batches | medium | integrator role; alphabetical blocks; dup-key lint; stagger merges |
| Publish path fails at first real use | high (never succeeded) | supervised publish, rollback plan (§16) |
| Convention drift between batches | medium | §11.2 dossiers mandatory; NAMING.md normative; integrator reviews convention notes |
| Correction-log rot | medium | per-pass log committed at pass end (the Turn-40 seam rule) |

---

## 19. AMENDING THIS DOCUMENT

This PRD is living. Amendments follow the correction culture: state what was
wrong or missing, the evidence, and the change — in a PR touching this file,
cross-referenced in the pass log. New defect classes REQUIRE a taxonomy entry +
detector before scaled fixing (I-15). The one thing that may never be amended
away is I-5/I-6: the id contract survives every future re-organization, because
it is the thing consumers — and the business — stand on.

---

## 20. STRETCH ADDENDUM 2026-07-26 — what changed while this document slept

*Everything below is LANDED and verified, not planned. Each item names its PR;
the PR bodies carry the full dossiers and evidence. Sections above are amended
in place only where they stated something now false; this section is the delta
narrative so a future agent can reconcile the two.*

### 20.1 Publication semantics changed: HYSTERESIS (pipeline #32)

§15's gates assumed the publish partition was memoryless (2 sources OR
count ≥ threshold). That flapped: ids at a threshold edge vanished on normal
upstream churn (measured: epure at 298/300 after a DfT quarterly; classic cars
whose last NZ example deregistered), and the no-vanish gate fired on noise —
which meant it was being skimmed. Now: an id in the PUBLISHED catalog stays
published while (single-source-published) any source shows ≥ threshold/3, or
(multi-source-published) ANY residual vehicle — corroboration did the
anti-garbage work at entry. Excluded from the grace, because curation already
decided they die: `overrides/models/demotions.yml` entries (corrections that
strip fabricated evidence — the file is OPTIONAL, loader defaults empty) and
former_ids ALIAS SOURCES (a residual raw once resurrected mg/m-g-b into its
own alias). Result: 31 gate failures → 11 true disappearances, all
dispositioned; fresh builds on any cache state are gate-clean.

### 20.2 The disposition PAIR rule (learned on #67, now binding)

A retirement is only complete as a PAIR: the former_ids ALIAS (where consumers
go) + the rename/move FOLD (which makes the source id dead in EVERY cache
state). An alias alone races the cache: CI's pre-drift snapshot still evidences
the id → "alias names a live id". A fold alone loses consumers. Ship both in
one commit, and check kind-blindness (the Caddymaxi car-leak needed a
drop_patterns guard because the cross-kind prune has a ≥100 floor).

### 20.3 The collision program is COMPLETE; the detector suite replaced it

§2's "146 collision groups" is history: 146 → 0 across seven batches
(#57/#58/#61/#62/#63/#66/#72), every group source-decided — the detector's
canonical column was wrong in 45/55 then 15/15 and is officially a
hint-about-pairings, never an answer. Quality work now flows from detectors,
each with its limits stated in its own header:
- `find_duplicate_spellings.rb` — collision groups (at zero, reruns catch new upstream forms)
- `find_casing_contradictions.rb` (#74) — one make, one token, two spellings; MAJORITY IS NOT AUTHORITY (VITO×4 lost to Vito×1; Mga×4 lost to MGA×1); structurally blind to uniformly-wrong makes (#79 closed the known instances under the two-halves rule: cross-make attestation AND marque styling)
- `find_corporate_strings.rb` (#59) — company names as nameplates (3 cases, 3 different dispositions: move/debt/removal)
- `find_published_name_defects.rb` — catalog-wide candidates needing adjudication (the citroën ë- pairs are a RECORDED false positive: `data/review/citroen-e-prefix-verdict.md`)

### 20.4 Casing-pipeline changes stale rename keys — the control build is the only complete check

`renames.yml` is keyed on the casing pipeline's OUTPUT. Any styling pin or
normalizer change (smart_case slash fix, pipeline #36) stales every key
describing the old output — including keys written by another session after
your branch was cut (the ZX/`280 Zx` cross-half catch). The reachability test
is necessary but NOT sufficient (it misses keys whose records have longer raws
that collapse differently — the Fxe/f case beat two detectors). Binding
habits: never guess post-change produced forms (hold work back for a real
build); a pin PR enumerates and rekeys every affected key in the same commit;
judge by control build, not by test suite alone.

### 20.5 Release protocol notes (§16 amendments in practice)

v2026.07.4 and v2026.07.5 both shipped through §16 with 0 orphans. Learned:
local RC diffs and the CI publish differ by cache-state (~37 records at .5) —
the publish run's own gates are the authority; the §16 artifact is kept beside
NEGOTIATION.md per release. At each release, prune rename keys and enrich
twins whose producing raws/ids died (the #70/#33 cleanups; the enrich half is
now caught at PR time by pipeline #34's three-state insurance lint). The
private `plus-<VERSION>` release ships in the same cycle (first: plus-2026.07.5,
469 enriched records — DATA-CONTRACT flow now LIVE).

### 20.6 The open-work ledger moved to DEBT.md

Scattered U-items, dossier §UNCERTAINs and PR-body follow-ups are consolidated
in `DEBT.md` (one line each, owner + source-of-record + resolution). Take an
item → delete its line in the same PR. §17's phase table should be read
through it.

### 20.7 The program's continuation lives in PRD-FIVE-NINES.md

With every self-consistency class at zero, the path to p99.999+ is external
anchoring + measurement + prevention. The complete technical plan — the
usage-weighted target and its honest math, the audit instrument, Wikidata
entity anchoring (nominate-never-merge), convention enforcement at ingest,
decile-weighted certification, and the paid-layer bar — is PRD-FIVE-NINES.md.
This document remains the operating manual for the mechanisms; that one owns
the program.
