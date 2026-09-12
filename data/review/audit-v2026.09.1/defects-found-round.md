# Defects found — audit round 2, tag `v2026.09.1`

*The audit FINDS; it does not fix (invariant I-15: a new class needs a taxonomy
entry and a detector spec before any scaled fixing). Every entry below names an
owning lane. Nothing here is fixed in this PR.*

**Part A** is what the ROUND found before a single record was audited — three
defects in the release/verification machinery, all measured on the released
artifact itself. **Part B** is the per-record ledger's findings (researcher +
verifier). **Part C** carries forward the preparation dry run's instrument
defects (`defects-found.md`) with their current status.

---

## Part A — found by pinning the release (manager, pre-round)

| # | class | severity | owning lane |
|---|---|---|---|
| A1 | verification method — a frozen rebuild does not reproduce the release | **should-fix** | REL + all lanes |
| A2 | data — display-name separator/casing is corpus-determined, not stable | **should-fix** | COV/NORM (+ taxonomy: new class?) |
| A3 | reporting — the `reconcile <kind>: published:` log line is PRE-PRUNE | note | REL (runbook) |
| A4 | spec — §1.3.1's sizing gap is **half what my predecessor reported**, and moving | **owner call** | owner / S4W |

---

### A1. A frozen rebuild of the released tag does not reproduce the release — at all

My predecessor filed (`defects-found.md` #5) that *a frozen build is structurally
blind to the rolling-window expiry class*. That is true and it is the smaller
half of the problem. Measured on this release:

I built **frozen** from the exact inputs the publish run used — data at
`v2026.09.1` (whose release commit changes **outputs only**: `git diff
--name-only ab7fe03 a480b99` is `VERSION`, `catalog/**`, `dist/**`,
`manifest.json`, **zero override files**), pipeline `96a798b` (from the publish
run's own checkout log), `VDB_CACHE_DIR=~/GitHub/vehiclesdb-pipeline/cache`
frozen per the fleet procedure. Then compared `build/out/catalog` against the
released `catalog/` committed at the tag (`scripts/../slices/cmp_catalog.rb`,
committed so this is checkable):

| kind | released | frozen rebuild | only in release | only in rebuild | differing on common |
|---|---:|---:|---:|---:|---:|
| car | 5,455 | 5,439 | 16 | 0 | 5,229 |
| van | 720 | 718 | 2 | 0 | 623 |
| truck | 923 | 923 | 0 | 0 | 866 |
| bus | 403 | 403 | 0 | 0 | 320 |
| motorcycle | 6,015 | 6,013 | 3 | 1 | 5,578 |
| moped | 1,370 | 1,368 | 2 | 0 | 1,260 |
| **TOTAL** | **14,886** | **14,864** | **23** | **1** | **13,876 (93.2%)** |

`catalog/meta/decile-mass.json` — **the artifact the usage-weighted bound reads
its weights from** — also differs.

Field frequency on the car half of the divergence: `popularity` 5,229 ·
`xrefs` 1,246 · `availability` 1,056 · `sources` 1,056 · `regions` 176 ·
`name` 33 · `body_types` 16. So the mechanism is legible and is not a bug:
the cache is a snapshot, the registers have moved, `popularity` is a **rank**
and therefore churns catalog-wide from any count change, and `xrefs` carries
the rolling-window type approvals.

**Why this is a finding and not a shrug.** The plan directs every lane to judge
its work by a frozen control-vs-treatment build. That method is sound for
*differential* questions (did my override change what I intended?) and it is
**not evidence about the released artifact** for any absolute question. Three
consequences worth writing down:

1. **A release cannot be verified locally by rebuilding it.** If a lane wants to
   check what shipped, it must read the shipped bytes — which this repo makes
   easy, because `catalog/` is committed at the tag. That is what this round
   pins.
2. The 23 records present in the release and absent from a frozen rebuild are
   exactly the shape of a *phantom* regression report: a lane rebuilding locally
   will see them "vanish" and may file or fix a non-problem. Named, so nobody
   has to rediscover them:

   ```
   car/cadillac/xlr-v            car/chevrolet/corvette-stingray-targa
   car/chery/tiggo-cross         car/chevrolet/k1500-suburban
   car/eagle/premier             car/ferrari/monza-sp2
   car/ford-hymer/hv562          car/forthing/u-tour
   car/gmc/sierra-ev-std-range   car/jaguar/f-pace-20d
   car/jaguar/xjl-portfolio      car/leapmotor/b03x
   car/maserati/grancabrio-modena car/subaru/wrx-sti-type-ra
   car/toyota/supra-turbo        car/volvo/b12
   van/mercedes-benz/vaneo       van/opel/expert
   motorcycle/ktm/690r           motorcycle/mv-agusta/f3-competizione
   motorcycle/suzuki/street-magic
   moped/niu/fqix-150            moped/segway/ekickscooter-ninebot-max-g3
   ```

   and the one record that goes the **other** way — present in the frozen
   rebuild, absent from the release — which is the rolling-window direction:
   the cache still holds a row the fresh fetch no longer returns:

   ```
   motorcycle/daelim/vt125
   ```

   My frozen build reports `FAIL id-contract gate (no-vanish)` on 22 of these.
   Every one of those failures is an artefact of the cache, not of the data.
3. The build I ran reports `FAIL id-contract gate (no-vanish)` on 22 ids purely
   because of this divergence. **A red local gate is not automatically a red
   release**, and the converse (my predecessor's point) also holds.

**Recommendation (REL, one line in `RELEASE-RUNBOOK.md`):** to verify a release,
diff against the tag's committed `catalog/`; a local rebuild answers a different
question. **Do not quote a frozen build as evidence about a published artifact.**

### A2. The display name's separator and casing are decided by the corpus, not by curation

Across all six kinds, **64 records change `name` between two builds of the same
data SHA and the same pipeline SHA**, differing only in how fresh the register
corpus is. Classified mechanically:

| class | n |
|---|---:|
| separator + casing | 62 |
| separator/punctuation only | 2 |
| **token change** | **0** |

Zero token changes is the important half of that table: no record gains or loses
a word. What moves is punctuation and case, and it moves *by itself*:

| id | released | frozen rebuild |
|---|---|---|
| `car/jaguar/e-type` | `E Type` | `E-Type` |
| `car/jaguar/xjr-s` | `XJR-S` | `Xjr-S` |
| `car/de-lorean/dmc-12` | `Dmc-12` | `Dmc 12` |
| `car/audi/100av-quat` | `100AV.-Quat` | `100AV.QUAT` |
| `car/fiat/230-rotec-590` | `230 Rotec 590` | `230/ROTEC 590` |
| `car/carbodies/taxi-hire-car` | `Taxi/Hire Car` | `Taxi / Hire Car` |

The id is stable (it is slugged), so **this is invisible to every id-contract
gate** — a consumer joining on `id` never notices, and a consumer *displaying*
`name` sees it change between releases for no curated reason.

**Why it matters to this program specifically:** `name-marque-true` is one of the
six audited claim types, and NAMING §2 basis 4 lets a display form be justified
by *"≥2 independent registers emit the exact display form"*. For these 64, which
exact form the registers emit is a function of which months are in the corpus.
A name certified `correct` in one round can be a different string in the next
release without anything being fixed or broken.

**And it is not only a laboratory effect — it reached production.** I checked the
two *released* catalogs against each other, `v2026.09.0` → `v2026.09.1`, on ids
common to both:

| | n |
|---|---:|
| name changes between the two releases | **1** |
| of which separator/casing | 1 |
| of which token changes | 0 |

The one record is **`car/changan/e-star`: `"E Star"` → `"E-Star"`**. I then
checked whether anyone curated it. `git diff v2026.09.0..v2026.09.1 --
overrides/` is **one line in `renames.yml`**, and it is a Geely `Starray` entry
with nothing to do with Changan; no override in the tree mentions this
nameplate. **So a published display name changed between two releases with no
curation change behind it.** That is the class, confirmed on the artifact
consumers actually receive.

Two numbers, and they mean different things — quoting either alone would
mislead:

- **64 (0.43% of records)** is the *sensitivity*: how many names move when the
  corpus is perturbed (frozen cache vs the release's fresh fetch). It is an
  upper bound on what could flip, and itself a lower bound on the truly
  unstable set, since two builds only reveal instability that happened to
  differ between them.
- **1** is the *incidence*: how many actually moved in one release cycle
  (one week, 13,809 → 14,886 records).

The gap between them is the point. The exposure is two orders of magnitude
larger than the observed rate, so this is cheap to ignore right up until a
corpus shift makes it not.

**Owning lanes:** COV/NORM own the rule; the round proposes this as a **candidate
new taxonomy class** (I-15 requires a taxonomy entry + detector spec before any
scaled fixing — the detector here is cheap and already written in effect:
re-emit names under a perturbed corpus and diff). It also gives `data#316`
(separator-variant sweep) and S2W's `#315` (casing pins) a measured population
rather than an anecdotal one.

### A3. `reconcile <kind>: published:` is a PRE-PRUNE count — do not quote it as the catalog size

The publish run's log prints, per kind, `reconcile <kind>: {… published: N …}`
and then, several seconds later, `cross-kind prune <kind>: -M`. The published
catalog is `N - M`. Every one of the six checks out exactly against the released
`models.json`:

| kind | `reconcile … published:` | `cross-kind prune` | released |
|---|---:|---:|---:|
| car | 5,489 | −34 | 5,455 |
| motorcycle | 6,042 | −27 | 6,015 |
| moped | 1,390 | −20 | 1,370 |
| **van** | **1,015** | **−295** | **720** |
| truck | 937 | −14 | 923 |
| bus | 422 | −19 | 403 |
| **TOTAL** | **15,295** | **−409** | **14,886** |

`S4W/REL-3`'s HANDOFF reports *"Published moves 15,122 → 15,295 (car 5,489 ·
motorcycle 6,042 · moped 1,390 · van 1,015 · truck 937 · bus 422)"* — that is the
pre-prune row, overstating the catalog by **409 records (2.7%)** and van by
**41%**. No harm reached the artifact: **`manifest.json` at the tag carries the
correct post-prune counts** (car 5,455 · van 720 · …), and so does the log's own
`emit: PRIVATE dist-plus … 14886 with registrations` line. The defect is in what
the log makes *easy to quote*.

**Remedy (REL, cheap):** quote `manifest.json`, not the reconcile line — or emit
one post-prune `published:` line per kind so the obvious number is the true one.
This matters beyond a NEGOTIATION turn because `data#330` is about to write
README counts from a release, and §3.4 counts are public.

### A4. The tail weight is not a stale constant — it is a MOVING one, and it has halved

My predecessor filed §1.3.1's `n ≈ 3,100` as *"stale by ~5×"*, replicated on
three artifacts. Re-read from **this release's own published weights**
(`catalog/meta/decile-mass.json` at `v2026.09.1`, shares summing to
`1.00000000` exactly over 14,886 records):

| artifact | d1-3 | d1-6 | `w_tail` | implied tail n |
|---|---:|---:|---:|---:|
| PRD-FIVE-NINES §1.3.1 as written | 82.98% | 99.49% | 0.515% | 3,100 |
| main's committed artifact (2026.08.2) | 79.60% | 96.49% | 3.514% | 21,086 |
| a build from main, 2026-09-05 | 79.48% | 97.48% | 2.521% | 15,127 |
| **released `v2026.09.1`** | **80.56%** | **98.94%** | **1.064%** | **6,387** |

**The gap is ~2×, not ~5×** — and the direction is toward the PRD, not away
from it. `w_tail` moved 2.521% → 1.064% in seven days, while the catalog moved
~13,936 → 14,886 records.

So the honest restatement of the predecessor's finding is stronger than the
original and less alarming: **`w_tail` is not a constant that went stale, it is
a quantity that moves every time the fold and coverage programmes move records
between rank bands.** Any sizing line written as a fixed `n` will be wrong
again within weeks, in one direction or the other. The remedy is not to patch
`3,100` to `6,387` — it is to state the sizing as the *arithmetic*
(`n ≥ 3·w_tail / 5e-6`, weights read from the audited build) and let each round
print its own number. This round does exactly that.

Per-half weights at this tag, for the record, since the bound renormalises
within a half:

| half | share of catalog mass | `w_head` | `w_tail` |
|---|---:|---:|---:|
| s4w (car/van/truck/bus) | 91.839% | 0.991029 | 0.008971 |
| s2w (motorcycle/moped) | 8.161% | 0.970516 | 0.029484 |

Still an owner/S4W call, still not re-litigating the target. Filed with better
numbers than it was filed with last week.

---

## Part B — per-record findings from the ledger

*Filled from the researcher + verifier ledgers when the round completes. Each
row carries the id, the claim, the final verdict and class, the evidence URL,
and the owning lane.*

## Part C — preparation dry-run defects, carried forward

See `defects-found.md` (unchanged, and still the record of what the dry run
found). Status at this round:

| # | status |
|---|---|
| 1 `--build=` wants the dir containing `catalog/` | **closed by documentation**; this round's pin is a tag worktree, which has exactly that shape |
| 2 `lint_review.rb` cannot see an audit ledger | **STILL OPEN** — REL's call whether it rides `#292` |
| 3 §1.3.1's tail sizing does not reproduce | **STILL OPEN** — owner/S4W; this round reads the weights from the pin and prints the arithmetic |
| 4 the tag string is clock-derived | **closed for this round**: the pin is published in full (tag, data SHA, pipeline SHA, build path) in the CLAIM turn and in every ledger's `build_pin` |
| 5 frozen builds are blind to xref-window expiry | **superseded and enlarged by A1** |
| — the cross-half alpha budget was unallocated | **closed in code**: `--alpha=`, threaded through both quantile families, regression-tested |
