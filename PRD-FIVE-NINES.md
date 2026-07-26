# PRD-FIVE-NINES — the p99.999+ quality program

*Version 1.0, 2026-07-26. Written at the owner's direction as the complete,
self-contained technical plan for pushing BOTH datasets — the public catalog
(this repo) and the private catalog-plus (pipeline repo → vehiclesdb-web) —
to p99.999+ quality. Companions: PRD-QUALITY.md (the quality machine this
program extends; its §20 records the 2026-07-26 stretch this plan builds on),
PRD-DEPTH-ENRICHMENT.md (pipeline — enrichment sourcing), PRD-PAID.md (web —
what quality is FOR commercially), DEBT.md (the finite open-work ledger).
Amend by PR to this file. Assume the reader has nothing but the repos.*

---

## 0. The one idea this whole program rests on

Every quality mechanism built so far checks the catalog **against itself**
(collision detection, casing contradictions, direction wars, gates). That
well is empty: every self-consistency class is at zero (PRD-QUALITY §20.3).
The remaining defect classes — same car under two ids, uniformly-wrong
names, phantom granularity, missing models — are invisible to
self-comparison **by construction** ("zero contradictions is not zero
defects"). The next order of magnitude comes from three sources only:

1. **External anchoring** — checking identity against entities, not strings
   (Workstream B: Wikidata QIDs).
2. **Measurement** — a defect rate with error bars, not a feeling
   (Workstream A: the audit instrument).
3. **Prevention** — defects stopped at ingest, not swept after publication
   (Workstream C: convention enforcement + quarantine).

Certification (D) and the private layer (E) sit on top of those three.

## 1. What "p99.999" MEANS here — definitions and the honest math

### 1.1 The quality unit

A **claim** is one assertable fact on a published record. The identity claims
per record: (a) the id is canonical (no other id denotes the same vehicle),
(b) the display name is marque-true, (c) make attribution is correct, (d)
kind is correct, (e) each availability entry reflects real register evidence.
A **record is defective** iff any identity claim fails. Enrichment claims
(runs, era, links, variants — private layer) are counted separately (§6).

### 1.2 The target is USAGE-WEIGHTED

Uniform p99.999 over 16,825 records means proving ≤0.17 expected defective
records — statistically undemonstrable (§1.3) and economically wrong (it
gold-plates one-row 1950s tail records nobody queries). The target is:

> **P(defective | a record a consumer actually touches) ≤ 1e-5**,
> weighted by resolution traffic.

Until the resolver is live (PRD-PAID P-1), the traffic proxy is registration
mass (sum of per-country counts), which concentrates in the head deciles the
same way queries will. When `/v1/resolve` ships, its query log replaces the
proxy (§5.3) — the weights become measured, not modeled.

### 1.3 Why you cannot sample your way to five nines — and the construction that gets there

The rule of three: demonstrating defect rate ≤ r at 95% confidence with zero
observed defects needs n ≈ 3/r clean samples. For r = 1e-5 that is
**300,000 verified records** — 18× the catalog. Sampling alone cannot do it.
The achievable construction is a **weighted sum of three different kinds of
guarantee**:

The construction is a **weighted sum over a two-stratum PARTITION**, with
detector coverage acting as a multiplier inside each stratum rather than as a
stratum of its own:

```
weighted_defect_rate ≤ w_head · r_head  +  w_tail · r_tail       (w_head + w_tail = 1)

STRATUM 1 — the certified head (deciles 1–3: 2,648 records, 15.7% of
  records, ≥90% of registration mass — see §1.3.2 on publishing that weight):
  EXHAUSTIVELY verified, record by record, under the ledger protocol.
  r_head is not a sample estimate — it is a deterministic audit result.
  Residual risk = regression between certifications, bounded by gate
  coverage + the recertification triggers (§5.2).

STRATUM 2 — the residual tail (deciles 4–10 plus the no-decile records of
  §1.3.3): sampled. n clean stratified samples ⇒ r_tail ≤ 3/n at 95%
  (rule of three).

DETECTOR COVERAGE is NOT a stratum. Every defect class with a detector
  (collisions, contradictions, corporate strings, name defects, gates 1–7,
  hysteresis exclusions) is checked over the WHOLE catalog at every build,
  so for those classes r = 0 deterministically in BOTH strata. It reduces
  r_head and r_tail; it carries no weight of its own. Treating it as a
  third stratum makes the weights sum past 1, since it spans all deciles.
```

Head certified + enumerable classes at deterministic zero + tail bounded and
down-weighted ⇒ **usage-weighted p99.999 is an achievable, falsifiable,
maintainable claim** — but only at the sizes derived in §1.3.1, which are larger
than a first pass suggests.

### 1.3.1 Sizing: the budget must be SPLIT, and the tail weight decides n

Two corrections to the first version of this section, both arithmetic. **Neither
changes the target in §1.2** — the target is owner-set. They change what it costs
to demonstrate it, and that is a scope decision for the owner and S4W, not
something this amendment picks.

**(a) The tail weight was internally inconsistent, and the sizing is 5× off.**
Stratum 1 was described as *"≥95%+ of expected resolver traffic"*, which makes
`w_tail ≤ 5%`. The sizing then used `w_tail ≤ 1%`:

```
as written:   0.01 × 1e-3 = 1e-5     exactly the whole budget
as implied:   0.05 × 1e-3 = 5e-5     5× the whole budget, from the tail alone
```

Both cannot hold. `n = 3,000` bounds `r_tail ≤ 1e-3`, and at `w_tail = 5%` that
contributes `5e-5`.

**(b) The budget left ZERO for the head.** Even at `w_tail = 1%` the tail
consumed the entire `1e-5`, forcing `r_head = 0` exactly rather than *"held at
~0"*. The measured consequence is stark: **one** defective head record is
`1/2648 = 3.8e-4`, contributing `≈3.6e-4` — **~36× the entire program budget**.
A design in which a single record breaks the claim by 36× has no margin, and
§5.2's recertification triggers are then not a maintenance detail but the only
margin that exists.

So the budget is split explicitly. Taking an even split as the default:

```
head allowance:  w_head · r_head ≤ 5e-6     ⇒ at w_head=0.95, r_head ≤ 5.3e-6
                                             ⇒ over 2,648 records: ≤0.014 expected
                                             defective. Still effectively "zero
                                             defects permitted" — but now STATED,
                                             and now with a nonzero allowance the
                                             gates are measured against.
tail allowance:  w_tail · r_tail ≤ 5e-6     ⇒ r_tail ≤ 5e-6 / w_tail
                                             ⇒ n ≥ 3 / r_tail = 3·w_tail / 5e-6
```

Which gives three honest options. **This is the decision to make:**

| resolution | requires | tail sample n |
|---|---|---|
| **(i)** certify deeper than d1–3 until `w_tail ≤ 0.5%` | more certification | **3,000** |
| **(ii)** accept `w_tail = 5%` as stated | nothing new | **30,000** (1.8× the catalog) |
| **(iii)** show `w_head ≥ 99.5%` from measured weights | §1.3.2 artifact first | **3,000** |

Option (ii) is self-defeating: sampling 30,000 of 16,829 records means auditing
everything with replacement, at which point exhaustive certification is cheaper
and yields a deterministic result instead of a 95% bound. **(i) and (iii) are the
real candidates**, and they are the same move from opposite ends — (iii) tests
whether the head already carries the weight, (i) extends it until it does. So
§1.3.2 is a prerequisite for choosing, not an independent nicety.

**RESOLVED 2026-07-26, same day, by measurement** (S4W; the artifact §1.3.2
demanded was built first — pipeline #40 — precisely so this choice would be
read, not asserted). First published measurement, catalog/meta/decile-mass.json:

```
d1-3 = 82.98% of registration mass     d1-5 = 95.28%
d1-6 = 99.49%                          d7-10 = 0.515%   none-band = 0.0000%
```

- **(iii) is measurably dead**: the d1-3 head carries 82.98%, nowhere near
  99.5%. The original "≥90% of mass / ≥95% of traffic" claims were WRONG —
  the review was right to refuse them unmeasured.
- **(i) resolves concretely to: certify through decile 6.** At d1-6,
  w_tail = 0.51%; with the split budget, r_tail ≤ 5e-6/0.0051 = 9.8e-4
  ⇒ **n ≈ 3,100** clean tail samples. Certifying to d1-5 does NOT close
  (w_tail = 4.72% ⇒ n ≈ 28,000 — the option-(ii) trap by another door).
- Scope consequence, stated plainly for the owner: certification grows from
  2,648 records (d1-3) to **≈9,340 (d1-6, ~55% of the catalog)** — roughly
  3.5× the first estimate. That is the honest price of the target at the
  measured mass distribution; the alternative is a smaller claim, not a
  cheaper proof. Phasing in §5.1: D1a locks d1-3 (83% of mass) first, D1b
  extends to d4-6.
- The "none" band carries 0.0000% mass: those 288 records need SAMPLING
  coverage (§1.3.3), never certification.
- **`global_decile` is never used as a per-record certification filter**
  (ruled NEGOTIATION Turn 137, from the 2W round's measurement).
  `global_decile` is a mean of per-country RANK deciles: it
  variance-collapses broad multi-country records toward the middle bands
  and inflates thin single-country ones (measured on 2W: 30.2% of
  1-country records at d1; 7-country records 0% at d1, 44.6% inside
  d4–7). The head boundary stays MASS-defined — d1–6 is chosen because
  the published decile-mass shares put 99.49% there, and per-band mass is
  invariant to intra-band rank distortion; mid-collapsed broad records
  land INSIDE the certified head, and the sampled tail covers d7–10+none
  regardless. A population-weighted decile blend is filed in DEBT.md as a
  reconciler improvement, not a v1 blocker.

Note also that the composed claim inherits the tail's confidence level: with a
rule-of-three bound on stratum 2, the published figure is a **95% upper bound**,
not a point estimate, and should be worded that way in §6.5 and `QUALITY.md`.

### 1.3.2 The weights must be PUBLISHED or the auditability claim is false

This section claims *"anyone auditing us can recompute it."* As of the merge of
this PRD they cannot, and the gap is load-bearing rather than cosmetic.

Checked across every published artifact: the catalog carries
`popularity.global_decile` and per-country **`rank`** values. There are **no
registration counts anywhere** — not in `catalog/`, not in `catalog-plus/`
(which adds only `production_runs` and `era`), not in `makes-plus.json`.
**Deciles are rank bands, not mass.** So `≥90% of registration mass` and
`≥95% of traffic` — the weights the entire usage-weighted target rests on —
exist only in a local measurement that ships nowhere.

Since §6.5 sells the recomputable arithmetic as a product feature, and since
§1.3.1 shows the sample size swings 10× on `w_tail`, this is a required
deliverable and not a footnote:

> **A1-bis (new acceptance gate):** the build emits a per-decile
> mass-share table (records, summed registration mass, share of total, and
> cumulative share) as a versioned artifact, regenerated every build.
> `w_head` and `w_tail` in §1.3.1 are read from it, not asserted.

**A1-bis: DELIVERED** (pipeline #40, merged 2026-07-26): the build emits
`catalog/meta/decile-mass.json` (schema decile-mass/1) — aggregate shares per
kind × decile including the none band, manifest-registered, regenerated every
build. Aggregate SHARES only: raw counts remain private by reconciler policy,
and shares reveal nothing per-record. The §1.3.1 resolution above reads its
numbers from the first emission.

### 1.3.3 288 records have no decile and no stratum

`popularity` is `nil` on **288 published records**. The §2.1 stratification is
`kind × decile-band × make-size`, which has no bucket for them — a seeded
sampler would exclude them silently, which is exactly the silent-truncation
class this program exists to eliminate.

They are folded into stratum 2 above and need an explicit `decile-band = none`
value in §2.1, with the usual rule that a stratum which cannot be sampled is
reported rather than dropped. Scope note, measured: **all 288 are on the S4W
half** (car/van/truck/bus); the S2W half (motorcycle/moped) has zero.

### 1.3.4 A record-level rate is not the same quantity in both strata

§1.1 counts a record defective if any identity claim fails, and claim (e) is
**per availability entry**. A record present in six countries therefore carries
ten claims; a single-country record carries five. Head records have
systematically more countries than tail records, so **head records carry more
claims and are structurally more defect-prone per record** — which works directly
against §1.3.1(b)'s requirement that `r_head` be ~0.

Two consequences worth stating rather than discovering: the head allowance in
§1.3.1 is tighter than it looks, and a record-level rate measured in the tail
cannot be compared like-for-like with one measured in the head. Either normalise
to per-claim rates in §2.2's outputs, or report claim-count distribution per
stratum alongside the rate so the bias is visible.

### 1.4 What we will NOT claim

Not uniform per-record five nines; not correctness of upstream registers
(availability claims assert *what the register said*, verified against the
register); not completeness (a missing model is a coverage gap tracked in
§13's candidate program, not a defect in a published record — the two
metrics are reported separately and never blended).

## 2. Workstream A — the audit instrument (MEASURE FIRST)

*Everything else in this program is prioritized by what A finds. Build it
first; run it quarterly forever.*

### 2.1 Design

- **Population**: all published records at a pinned release tag.
- **Stratification**: kind × decile-band (1–3 / 4–6 / 7–10 / **none**) ×
  make-size band (≥100 records / 10–99 / <10). 72 strata; allocate by
  Neyman-ish compromise: minimum 8 per non-empty stratum, remainder
  proportional to registration mass. **Baseline round: n = 400 per ownership
  half** (S4W: car/van/truck/bus; S2W: motorcycle/moped).
  The `none` band exists because `popularity` is `nil` on 288 published
  records (§1.3.3) — without it a seeded sampler drops them with no report,
  which is the silent-truncation class this program exists to remove. All 288
  are on the S4W half. A stratum that cannot be sampled is REPORTED as such,
  never omitted.
  Note that "remainder proportional to registration mass" is not computable
  from any published artifact today; it depends on the A1-bis table (§1.3.2).
- **Sampling**: seeded PRNG (seed = release tag string) so the sample is
  reproducible and cannot be cherry-picked. `scripts/audit_sample.rb`
  (to build — §9 gate A1) emits the sample manifest.
- **Per-record protocol**: exactly PRD-QUALITY §7 (the per-record checklist)
  PLUS the entity check once Workstream B covers the make (id ↔ QID
  agreement). Every record audited by a researcher agent, verdicts verified
  by an INDEPENDENT verifier agent (I-11: researcher ≠ verifier), results in
  a ledger file under `data/review/audit-<tag>/` with the standard schema.
- **Verdicts per claim**: `correct | defective(class) | unverifiable(reason)`.
  Unverifiable is counted AGAINST the clean rate for bounding purposes
  (conservative) and feeds the source-gap queue.

### 2.2 Outputs (per round)

1. `data/review/audit-<tag>/RESULTS.md`: defect rate per class per stratum
   with 95% Clopper-Pearson intervals; the usage-weighted aggregate (§1.3).
2. New defect classes found → PRD-QUALITY §4 taxonomy entries + detector
   spec BEFORE scaled fixing (invariant I-15 already requires this).
3. Reprioritized DEBT.md.
4. `QUALITY.md` at repo root (§8): the public dashboard, updated per round.

### 2.3 Acceptance

- A1: sampler script merged, seeded, stratification unit-tested — including a
  test that the `none` decile band is populated and reported (§1.3.3).
- **A1-bis: the per-decile mass-share artifact ships** (§1.3.2) — records,
  summed registration mass, share, cumulative share; regenerated every build.
  `w_head`/`w_tail` are READ from it. This gates the choice between the three
  sizing resolutions in §1.3.1, so it precedes A2 rather than following it:
  the tail sample size swings 10× on the number it produces, and allocation
  within A1 is already specified proportional to mass.
- A2: baseline round complete both halves; results published; every found
  defect either fixed (with its class detector) or filed in DEBT.md.
- A3: quarterly cadence entered into the release protocol (§16 of
  PRD-QUALITY): a release in a quarter with no audit round is blocked.

## 3. Workstream B — entity anchoring (the identity backbone)

*The centerpiece. Converts string-identity (lintable only) into
entity-identity (verifiable). Absorbs and supersedes G26c.*

### 3.1 The map

New overrides family, public (QIDs are CC0; identity is the OPEN layer per
PRODUCT-SHAPE — publishing the map adds open value and hardens the moat,
since the resolver corpus behind it stays ours):

```yaml
# overrides/identity/<make>.yml       (make-aligned, same lint regime)
car/alfa-romeo/gtv:
  wikidata: Q286789            # one QID = one model entity
  status: verified             # verified | proposed | no-entity | ambiguous
  note: optional, same-line citations per curation rules
car/alfa-romeo/gtv-2000:
  wikidata: Q286789            # SHARED QID = the ids are one entity → §3.4
  status: proposed
```

`status` semantics: `verified` = human/agent-confirmed via I-11;
`proposed` = matcher output awaiting verification; `no-entity` = checked,
Wikidata has no entity (NOT a defect — tail models are underdocumented;
this is the B-002 axis again); `ambiguous` = candidates recorded in note.

### 3.2 The per-marque pipeline (tooling to build — §9 gates B1–B3)

1. **Inventory pull** (`pipeline/tools/wikidata_inventory.rb`): SPARQL per
   marque QID — entities with P31/P279* ⊆ {automobile model, motorcycle
   model, …} and P176 (manufacturer) in the marque's corporate tree; pull
   labels, aliases (all languages), P571/P2669 (inception/discontinued),
   P155/P156 (predecessor/successor). Cache + archive per the fetch layer;
   licensing: CC0, statement pinned once in data/licenses.
2. **Matcher** (`pipeline/tools/align_identity.rb`): ladder per catalog id —
   exact label (post-normalization both sides) → alias → year-constrained
   token match (runs data, where enriched) → UNMATCHED. Emits
   `identity/<make>.yml` with `status: proposed` + a dossier-style report:
   proposed matches with evidence, shared-QID nominations, no-entity list,
   Wikidata-only entities (→ candidate queue).
3. **Verification**: swarm pass per marque, the established shape —
   researcher builds the report, an independent verifier re-derives a
   weighted sample (all shared-QID and ambiguous cases at 100%, spot-check
   the rest), maintainer applies. Statuses flip to `verified`/`no-entity`.

### 3.3 THE BINDING RULE: alignment NOMINATES, never merges

A shared QID is a *nomination* for the duplicate queue — it is never an
automatic fold. Rationale, learned twice over: granularity is OURS, not
Wikidata's (their entity model may lump generations we split — Tucson/ix35
is ONE Wikidata entity but our two-id question needed a raw-evidence
decision); and matching errors must not become silent merges (the LE/480-ES
class at entity scale). Every fold still goes through the full disposition
pair (rename fold + former_ids alias) with raw-corpus evidence.

### 3.4 The three defect harvests + one coverage harvest

| signal | meaning | route |
|---|---|---|
| two ids → one QID, SAME make and kind | duplicate nomination | duplicate queue → dossier → fold+alias |
| two ids → one QID, DIFFERENT make | REBADGE relation, never a fold (measured: 33 toyota ids match another marque's entity — toyota/harrier → Q660273 Lexus RX via alias; B1 pilot) | recorded as a cross-reference; candidate paid-layer field |
| two ids → one QID, different kind | kind-boundary artifact (275 id strings live in both car/ and van/) | kind-boundary proposal queue, not a fold |
| id → no entity after verified search | phantom nomination OR underdocumented-real | raw-corpus check: real rows = keep (`no-entity`), artifact = removal/fold |
| id whose matched entity belongs to ANOTHER marque in our catalog | **make-boundary** — the id is filed under the wrong make (B2 measured 10 across toyota+austin, both ids attached each time) | make-boundary queue → moves.yml dossier, never a silent re-file |
| QID (in-scope marque model) → no id | coverage gap — counted at **NAMEPLATE level only** (B2: 182 of toyota's 348 "Wikidata-only" entities are concepts, racers and generations; entity-level counting overstates the queue 3×) | candidate queue (PRD-QUALITY §13), NOT a defect stat |
| our runs vs P571/P2669 disagree | enrichment discrepancy | discrepancy queue (§6.3); curation wins, disagreement recorded |

B2 operational note, binding for B3 planning: **rung 3 (year-constrained
match) cannot fire where `enrich/` has no runs for the marque** — at B2 it
was zero rows for both pilot marques and 134 ids sat blocked with a
candidate waiting. Sequence enrich coverage (or accept the ~60%/38%
match-rate ceiling B2 measured) before projecting B3 wave yields.

### 3.5 Rollout

Order by registration mass: top-50 makes ≈ 80%+ of records. **Pilot first
(gate B2): one large live make (toyota) + one defunct make (austin)** to
prove match-rate, false-nomination rate, and per-marque cost before scaling.
Scale via swarm waves (PRD-QUALITY §8 topology, Opus researchers), ~5 makes
per wave, verifier-merges-only. S2W runs the same tooling on 2W marques.
Tail makes (<10 records): batch by country-of-origin; `no-entity` will
dominate — that is expected and fine (stratum-3 sampling covers them).

### 3.6 Holding it: the identity gate

Once a make is `verified`, its identity file becomes a build input:
- new id appearing in a verified make without an identity row → candidates
  quarantine (§4.3), not silent publication;
- two ids sharing a QID with neither in the duplicate queue → lint failure;
- an id with a `verified` QID vanishing → the existing no-vanish machinery
  (alias/manifest) plus the identity row moves with the alias.

## 4. Workstream C — prevention: conventions enforced at ingest

### 4.1 Machine-readable per-make conventions

Today every marque decision lives in rename-line comments and NAMING.md
prose; enforcement is the sweep-after-the-fact. Formalize:

```yaml
# overrides/conventions/<make>.yml
tokens:                       # per-make token casings (make-scoped by design
  GTV: caps                   #  — the LE/tS lesson forbids global rules)
  Mk: title                   # British Mk; roman numerals fused (MkII)
separators:
  badge_join: closed          # MGB not "M G B"; cite the dossier
families:
  - pattern: '^\d{3} GT'      # optional regexes for family-specific rules
    rule: caps_suffix
sources:
  - https://…                 # the citations the rules rest on
```

Generated initially FROM the existing corpus (the renames/styling decisions
+ dossier verdicts encode ~200 marque rulings already) by
`scripts/gen_conventions.rb`, then human-curated. A new lint stage
(`lint_conventions.rb`) checks every PUBLISHED name in a covered make
against its rules — violations fail CI exactly like contradictions do.

### 4.2 The regression-gate registry

Every closed class keeps its detector in CI permanently. Formal list (the
"quality gate" = all of these at zero-or-acked on every build):
`find_duplicate_spellings` · `find_casing_contradictions` ·
`find_corporate_strings` · `find_published_name_defects` (with recorded
verdicts honored — the ë- precedent) · `lint_conventions` (new) ·
`lint_curation` (direction wars, chains, shapes) · reachability suite ·
gates 1–7 + hysteresis exclusions · `lint_enrich` (incl. the three-state
insurance sweep). A class without a detector may not be scale-fixed (I-15).

### 4.3 New-record quarantine

A (make, slug) never published before, entering a build: if its make has
conventions/identity coverage, it must pass both or it lands in
`build/candidates/` flagged `first-seen` for the weekly review batch instead
of publishing. If its make is uncovered, it publishes (today's behavior) but
is tagged `first-seen` in the release diff so the audit stratifier
oversamples it. This closes the gap where a fresh clerk typo ships and waits
for the next sweep. (Implementation: reconciler check against the previous
release catalog + candidates index; ~1 day.)

### 4.4 The pipeline-change law (already learned, now binding)

Any change to the casing pipeline (styling pin, normalizer edit) ships in
the same commit as the rekey of EVERY affected rename key, enumerated by
control build — never by the reachability test alone (it is necessary, not
sufficient: the Fxe/f case). Cross-repo coupled changes merge
pipeline-first, minutes apart, never spanning a scheduled build.

## 5. Workstream D — decile-weighted certification

### 5.1 Certification ledger

Extend the §5 ledger: each certified record carries
`{certified_at: <release>, verifier: <session>, claims: {...}}` in
`data/review/certification/<kind>.yml` (compact, one line per record).
Certification = the full §7 protocol + entity check. Targets:

| stratum | records | target | method |
|---|---|---|---|
| deciles 1–3 (D1a) | 2,648 | **100% certified** — locks 82.98% of mass | swarm waves, ~150/agent-block |
| deciles 4–6 (D1b) | ≈6,690 | **100% certified** — takes the head to 99.49% of mass (the §1.3.1 resolution: the construction does not close shallower) | phased after D1a |
| deciles 7–10 + none-band | ≈7,490 | audit sampling (A, n≈3,100) + resolver demand (§5.3) | statistical only |

### 5.2 Recertification triggers (staleness is a defect vector)

A certified record loses `certified` on: display-name change, any merge
touching it, make/kind move, identity-status change, or its make's
convention file changing. The release diff computes the decertification
list mechanically; recertification rides the next wave. Quarterly audit
rounds (A) sample certified records too — certified-but-defective is the
program's own error rate and is REPORTED (it bounds stratum-1 residual risk
honestly).

### 5.3 The demand flywheel

When `/v1/resolve` ships (PRD-PAID P-1): every unresolved input and every
low-confidence resolution is logged (consent-flagged), triaged weekly into
(a) alias/corpus additions, (b) certification demand for touched records,
(c) candidate-queue entries. Usage weights in §1.3 switch from registration
proxy to measured query mass. The paying customers literally direct the
quality spend to where it is felt — that is the flywheel PRD-PAID §4
promised, now with a defined loop.

## 6. Workstream E — the private (paid) dataset at the same bar

The paid layer inherits everything above (identity claims are shared — the
public catalog IS the paid catalog's spine). Additional, enrichment-specific:

### 6.1 Claim standards (already binding, restated as gates)
Every catalog-plus fact: same-line source citation (lint-enforced); run
shapes through the `ended:`/`year_end_min:` schema with the symmetric
evidence rule; researcher ≠ verifier on every landed tranche; the
three-state insurance sweep at PR time; `dissolved` = production cessation.

### 6.2 Enrichment audit stratum
Workstream A rounds include an enrichment sub-sample: 100 enriched ids per
round, verifier re-derives every run from its cited source (re-fetch, never
trust the note). Tolerance: year_start/year_end exact vs cited source; a
±1 model-year-vs-calendar-year discrepancy is recorded as `note`, not
counted defective, IF the note says which convention the source uses.

### 6.3 The Wikidata cross-check
Workstream B's inventory pull already carries P571/P2669. Auto-diff against
our runs per aligned id: agreement = silent corroboration (recorded in the
identity row); disagreement = discrepancy queue entry. **Curation wins,
always** — but an unexamined disagreement blocks `verified` status on the
enrichment claim, not on the identity row.

### 6.4 Plus-release gating
A `plus-<VERSION>` release ships only from a build where: the quality gate
(§4.2) is green, the release_diff has 0 orphans, and no discrepancy-queue
entry touches a shipped run without a recorded disposition. Version-lock to
the public release stays (DATA-CONTRACT).

### 6.5 Quality AS product
`QUALITY.md` (public dashboard, §8) + per-release audit results are
published. The paid pitch gains: "the only vehicle dataset that publishes
its measured defect rate, its audit protocol, and its certification
coverage — recompute it yourself." Nobody else in this market can say it;
saying it truthfully requires everything above, which is the moat.

## 7. Division of labor and protocol

S4W: car/van/truck/bus for A/B/D; owns B tooling (shared), C generation,
this PRD. S2W: motorcycle/moped mirrors every workstream with the same
tools; two-wheeler marque calls are theirs (the VITO/MGA rule: marque
knowledge decides). Coordination via NEGOTIATION.md as established;
verifier-merges-only; all swarm output → scratchpad files → PR-embedded
dossiers → aux/research/ graduation (the durability chain that held this
stretch). Model rule: Opus researchers, session verifies and applies.

## 8. Reporting: QUALITY.md (new, repo root, public)

Per release: usage-weighted defect bound with its three-strata breakdown
(§1.3), certification coverage by decile, detector-suite status, audit-round
summaries with links, enrichment claim coverage + discrepancy-queue size,
and the honest caveats (§1.4) verbatim. Generated by
`scripts/gen_quality_dashboard.rb` from the ledgers — never hand-edited.

## 9. Phases, gates, acceptance

| gate | deliverable | acceptance | est. effort |
|---|---|---|---|
| **F-0** | this PRD merged; DEBT.md current | — | done at merge |
| **A1** | audit sampler + protocol | seeded, stratified, unit-tested; dry run 20 records | 1 block |
| **A2** | baseline audit both halves | 800 records, ledgers published, RESULTS.md + first QUALITY.md | 3–4 blocks/half |
| **B1** | inventory + matcher tools | **DELIVERED (prototype)**: reproducible cached pulls (toyota 720 entities, austin 198); ontology measured — the road-vehicle LEAF set incl. Q59773381 automobile-model-series (a Q3231690-rooted query MISSES Corolla/Camry/Prius); P1716 brand beats P176 manufacturer as the marque key (P176=BMC over-collects 63%); WDQS throttling handled (429s + Retry-After, zero lost). Production tool graduates the prototype into pipeline/tools/ | 2 blocks |
| **B2** | pilot: toyota + austin | match/false-nomination rates measured; go/no-go + cost per marque | 2 blocks |
| **B3** | top-50 makes aligned | ≥80% of records in covered makes; harvests dispositioned per §3.4 | ~10 waves |
| **C1** | gen_conventions + lint | top-20 makes covered; CI-enforced; zero false failures on current catalog | 2 blocks |
| **C2** | first-seen quarantine | reconciler change + gate; measured on one release cycle | 1 block |
| **D1** | head certification | 2,644 records 100% certified, ledgered | ~6 waves/half |
| **D2** | recertification mechanics | decert list in release_diff; triggers tested | 1 block |
| **E1** | enrichment audit stratum + cross-check + plus gating | first round run | 2 blocks |
| **F-1** | **the claim**: first release shipping QUALITY.md with the p99.999 usage-weighted bound computed from real audit + certification data | the arithmetic holds without asterisks beyond §1.4 | = A2+B3+C*+D1 |

Order: A1→A2 immediately (everything else re-prioritizes on its findings);
B1→B2 in parallel; C after B2 informs convention shapes; D waves start once
A2 confirms the head defect profile; E rides along. No new release is
BLOCKED on this program except the quarterly-audit rule (A3) once adopted.

## 10. Risks, stated plainly

- **Wikidata coverage is thin exactly where we are weakest** (tail marques).
  Mitigated by design: `no-entity` is a recorded state, not a failure;
  stratum-3 sampling still bounds the tail; B-002 says this is the axis.
- **Matcher false nominations creating wrong merges** — the worst possible
  outcome (silent wrong folds at scale). Mitigation is structural: §3.3
  nominate-never-merge, 100% verification of shared-QID cases, and the
  disposition pair keeping every fold evidence-backed.
- **Certification rot** — certified-but-stale. Mitigated by §5.2 triggers +
  the audit sampling certified records and publishing the miss rate.
- **Program fatigue** — the failure mode of every quality program. The
  design defends: detectors hold zeros without human attention; quarantine
  prevents rather than sweeps; the audit is quarterly not continuous; and
  the dashboard makes drift visible to the owner in one file.
- **The claim being read as more than it is.** §1.4 ships verbatim in
  QUALITY.md. We publish the construction, not just the number.

## 11. Amendment

By PR to this file. The §1 definitions and §3.3 nominate-never-merge are
load-bearing: changing them requires an owner-visible PR, not a drive-by.
