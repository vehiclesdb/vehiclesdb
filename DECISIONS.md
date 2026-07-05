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

## Cadence

**Monthly releases, weekly validate-only runs, human-gated publish.** The
spine sources update monthly (ES/DE/MY/TH/AR/UA) or quarterly (UK); nightly
would be theater. The weekly validate run exists to catch upstream drift
(license pins, URL rotations, format changes) within days instead of at
release time. Versioning is `YYYY.MM.PATCH` — the version tells you the
freshness.
