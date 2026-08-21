# DECISIONS.md — why the dataset is the way it is

Decisions that shape the published data, each with the evidence that produced
it. **Do not revert any of these without new evidence** that outweighs what's
recorded here. The full research trail (with exact URLs and verbatim license
quotes) lives in the private pipeline repo; this file is the public,
load-bearing summary. Format borrowed from OpenASN's DECISIONS.md.

---

## Taxonomy & identity

**Kinds are a first-class, open-ended enum.** `car`, `van`, `motorcycle`,
`moped`, `truck`, `bus` are active; `train`, `plane`, `ship`, `agricultural`
are reserved (ids and schema accept them; nothing ships until there's a
consumer). Kind lives IN the id (`car/volkswagen/golf`) so ids never collide
across kinds and a client can subscribe to one kind's files only.

**Mopeds are separate from motorcycles.** The Dutch register alone holds
1,373,537 mopeds vs 893,465 motorcycles — the "smaller sibling" is the bigger
fleet. EU law (L1e/L2e vs L3e+) and every registry we ingest (NL/FI/ES/NZ)
separate them. Sources that merge them (UK VEH0120) get a documented
per-source mapping. Three-wheelers fold into `motorcycle` with
`body_types: ["trike"]` — no kind explosion.

**Ids are stable forever.** Once an id is published it never changes meaning
and never disappears silently. Renames produce an alias, breaking changes a
major schema bump. Absent optional keys mean "not catalogued yet", never a
schema change. See SCHEMA.md for the binding rules.

**Model = nameplate.** One record covers a nameplate's trims and engines
unless `variants` says otherwise. Registration data supports exactly this
altitude honestly; pretending to trim-level accuracy from it would be a lie.
Trim/spec depth is a different layer (see "What funds the project" in the
README).

**Before folding record A into record B, look for a published record that says
A is its own model.** Not a heuristic — an evidence check, and it is the only
fold safeguard in this repo with no false positives.

Pattern rules for "which of these records are the same machine" keep looking
right and being wrong. Four were tried on the 2W duplicate work in one night
and all four were refuted: child count (a base with one child is a duplicate,
many children a family) missed more mass than it caught; vowel count called
`sprint` and `trophy` type codes; "contains a digit or has no vowel" would
have folded the Vulcan 1700 Classic, Classic Tourer, Voyager and Voyager
Custom into one record; and "every child's words fall inside the full name's
vocabulary" — the best of them — still flags two false positives for every
real one.

What actually caught all three near-misses was a published record contradicting
the fold:

- `flht-classic` was about to fold into the Electra Glide **Standard** — but
  `flhtc-electra-glide-classic` exists, and FLHTC is the **Classic**. Two models.
- `kawasaki/vn1700`'s children looked like spellings — but sixteen existing
  `former_ids` aliases showed someone had already curated them as distinct
  models with their ABS variants folded in.
- `gl1500c` looked like a Gold Wing by slug — Honda lists the Valkyrie under
  `street/cruiser/`, away from the tourers, and markets it as "Gold Wing
  Valkyrie" so a NAME check agrees with the wrong answer.

The pattern rules are still useful as a filter for *where to look*. They are
never a licence to fold. A fold batch that cannot point at the evidence for
each cluster is a batch that has not been checked.

Corollary, learned the same night: **a heuristic's value depends on source
coverage, not on the make.** Disjoint availability identified exactly the two
Honda pairs that were genuinely different machines — and fired zero times on
Harley, where `nl_rdw` covers 622 of 633 records so every pair intersects.

## Sources & evidence

**A model is published when ≥2 independent sources agree, or when a single
source shows a fleet/registration count above a per-kind threshold.**
Everything else waits in the pipeline's candidate queue. Rationale: every raw
registry is full of typos, one-off imports and administrative junk (the Dutch
register alone contains 11,403 raw make strings; Spain's monthly file 3,391).
Corroboration is the only cure that scales.

**Only openly-licensed or statutorily-public sources enter the dataset.**
Aggregators and scrapes never qualify; a GitHub repo's MIT license does not
sanitize the vehicle list inside it. ShareAlike (CC-BY-SA/ODbL) and NC
sources are quarantined by a build gate keyed on per-source license metadata
— they never merge into this CC-BY composite.

**Every upstream license text is pinned by SHA-256** in
`data/licenses/pins.json`. The build fails on drift and opens an issue.
Licenses rot: MaxMind relicensed in 2019, Spain's DGT dropped a field in
2025-02, Slovenia withdrew its vehicle open data entirely. Pinning turns
"the terms changed under us" from a lawsuit into a build failure.

**Per-vehicle raw dumps are never republished.** Identifier columns (VIN,
plates, document numbers) are dropped at the ingest boundary — a CI lint
fails the build if an identifier-shaped field name reaches source code. Only
aggregated taxonomy + derived signals ship. Published data is anonymous
aggregate statistics under GDPR (C-319/22, WP29 Opinion 05/2014, Recital 26).

## Popularity & availability

**Popularity ships as ranks and deciles, not raw counts.** Deciles are
honest at the open layer's accuracy; absolute counts and time series are
depth-layer inventory. `confidence: "measured"` means real registration or
fleet counts from that market; `proxy` (future tier) means public-attention
signals. Biases are documented in SCHEMA.md — never hidden.

**Availability is evidence, not marketing history.** A country code appears
under `availability` because an official source (registration register, type
approval, sales reporting) shows the model there — each entry carries its
evidence type and source id. It does NOT assert the maker officially sold the
model there (NZ's JDM grey imports are the canonical counterexample, and
they're a feature: those models exist on real roads).

**Removing a country from a published record is a CORRECTION, not a loss —
and it has to be shown to be one.** `car/mini/aceman` shipped `ca` and `us`
until 2026-08. It should not have: a normalizer rule tested `/ACEMAN/` without
a word anchor, `"PACEMAN"` matches that at offset 1, and so every MINI Paceman
row — a 2012-2016 model, discontinued eight years before the Aceman existed —
was filed as an Aceman. The Canadian and US sources hold 16 and 24 Paceman
rows and **zero** Aceman rows, and the two cars' EU type-approval numbers
disagree on the framework directive itself (`e1*2007/46*0563*03` for the
Paceman, `e1*2018/858*00382*…` for the Aceman), so the North American evidence
was never the Aceman's to hold. It did not vanish: it **moved** to
`car/mini/paceman`, which the same change creates.

The rule this sets: an availability removal ships only when the evidence is
shown to belong somewhere else (or to nothing), and it ships with a
`spotchecks.yml` row asserting the absence — `availability_excludes` exists
for exactly this, because an `_includes` row cannot state "and it must never
come back."

## Licensing & brand

**Data CC-BY 4.0, forever.** The skeleton (ids, names, structure, body
types, availability evidence, popularity deciles) will never be paywalled,
relicensed restrictively, or deleted. Four documented free-tier rug-pulls in
this exact niche (Edmunds 2018, CarQuery, API Ninjas, a frozen OSS
predecessor) are the reason permanence is stated as a contract, not a mood.

**Attribution is generated, not hand-maintained.** `ATTRIBUTION.md` is
emitted by the build from per-source license metadata, carrying each
license's prescribed statement verbatim (OGL, NLOD, DL-DE and Licence
Ouverte all prescribe different wording). One quirk: the Dutch RDW's terms
*prohibit* implying RDW endorses derived data, so its line uses neutral
"contains public data from the Dutch vehicle register" phrasing.

**Vehicle marks appear as plain-text facts only.** No logos, no brand
typography, marks never in domains or subdomains. Word marks in a factual
database are nominative fair use; logos are a separate (image) trademark
question and stay out of every tier.

## Formats

**We publish: JSON (nested + array-packed), CSV, Parquet, SQLite — and
nothing else.** Each earns its place: `vehicles.json` is the SDK contract;
`vehicles.min.json` the payload-optimized picker feed; `vehicles.csv` the
spreadsheet/BI lingua franca; `vehicles.parquet` the data-science and
HuggingFace native (generated from the canonical CSV via DuckDB, so the two
can never disagree); `catalog.sqlite` the "real database in one file" for SQL
consumers. Explicitly rejected: a custom binary format (OpenASN ships .mmdb
because IP-range lookup demands a b-tree — a make/model taxonomy has no
lookup problem SQLite doesn't already solve) and XML/YAML (no audience that
the five above don't serve better).

## Cadence

**Monthly automated releases, weekly validate-only runs.** The spine sources
update monthly (ES/DE/MY/TH/AR/UA) or quarterly (UK); nightly would be
theater. The monthly scheduled run builds, validates through all six gates,
and — only when every gate is green AND the data actually changed — commits,
tags, and cuts the GitHub release itself. The weekly validate run catches
upstream drift (license pins, URL rotations, format changes) within days
instead of at release time; failures open a `pipeline-failure` issue.
Versioning is `YYYY.MM.PATCH` — the version tells you the freshness, and the
patch number auto-increments so intra-month re-releases can never collide.
(Chosen over OpenASN's rolling-`latest` + dated-pin scheme: for a monthly
dataset, a meaningful version beats a date, and jsDelivr's `@latest` already
provides the rolling pointer for free.)

## Gates & checks

**A check must report what it examined, not only what it found — and what it
declined to examine.** A check that prints only its findings cannot be
distinguished, from the outside, from a check that could not look. Both print
nothing and exit 0. Every instrument in this repo that has silently failed has
failed in that gap, and the cure is cheap: state the corpus and the scope beside
the verdict.

There are **two distinct failure modes** and they need different cures.

**Ran, found nothing — and "found nothing" is indistinguishable from "could not
look". Cure: report the DENOMINATOR.** `license gate: 13/13 pins verified` is the
model; the same gate used to pass while verifying nothing at all, and the count
is what makes the difference legible. Cases: a licence gate that passed without
checking any pin (rewritten in `pipeline#124`); `lint_plates` blind to the
`_meta`/`_decode`/`_art` sidecars it was meant to cover (`data#253`); the
build-failure reporter whose own first call failed silently so a red build filed
no issue for a week (`data#299`); a `TruncatedResult` swallowed into an empty
list, so a partial upstream answer read as a smaller build rather than a wrong
one (`pipeline#169`); a `0` failure count read off a build that was still
`in_progress`; and `scripts/audit_rename_value_liveness.rb`, which had both its
roots hardcoded to one session's worktree and so reported that worktree's numbers
from every checkout, unchanged even against a branch that added keys
(`data#306`).

**Ran, found some — and said less than it knew. Cure: report the SCOPE
PREDICATE.** A denominator does not help here; it would be truthful and useless.
The id-contract move-split gate fires only when BOTH halves of a badge pair fall
below threshold, so it reported two incidents while seven more split nameplates
published under two makes with every instrument green — "examined 47 moves" would
have been correct and would have hidden exactly the same thing. What was needed
was the predicate: *pairs where both halves fall below threshold*. A gate that
fires on a threshold reports a subset of its own defect class, and which subset
is an accident of where the mass fell. Silence inside the scope and silence
outside it look identical unless the tool says where its edge is.

**A ratio must state what moved — numerator or denominator.** The review-coverage
floor asserted that a ratio may never fall, but its denominator is the catalog
and the catalog legitimately moves: four certified ids retired by correct
curation decremented both sides, and the floor read that as regression. A metric
whose subject can leave has to distinguish loss from departure, or it forces the
two dishonest moves — withdraw the curation, or weaken the gate — that it exists
to prevent. Monotonicity now fires on numerator loss **not explained by catalog
departure**; a withdrawn or downgraded verdict on a LIVE record still fails.
Rebaselining is legitimate when the delta is itemized and attributed, and only
then: a rebaseline with a cited cause is not a weakened gate, an uncited one is.

`scripts/check_rulings.rb` is the working example of both halves — it prints the
tags it found in the diff *and* the fact that no ruling line mentions them —
which is why it caught a citation gap on its second outing rather than its
twentieth.
