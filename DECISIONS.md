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

**Passenger versions of van-based MPVs publish in kind `car` (2026-11-09).**
A Berlingo, a Caddy Life, a Rifter or a Tourneo Courier bought as a family car
is registered as EU category **M1** — and until this date it was findable only
under `kind: van`, or, for Spain, nowhere at all. `drop_patterns.yml` dropped
every van nameplate from the car build on the premise "they belong to kind
van, whose build ingests them via kind_maps", but the ES van build ingests N1
only, so Spain's M1 rows reached no kind: 756 Tourneo Courier, 441 Tourneo
Custom and 191 Tourneo Connect registrations in Jul–Sep 2026 alone, with zero
`es` on any Tourneo record. Measured across the registers (research
passenger-vans.md, 2026-11-09): ES DGT M1 share Caddy 67.8%, Rifter 52.5%,
Vito 50.1%, Berlingo 43.0%, Kangoo 31.6%; UK Rifter 100% Cars, NL 99.7%
Personenauto, FI 98.8% M1.

Three rulings already decided this; the drop list was an implementation
shortcut that never consulted them:

- **NAMING.md §3:** "`kind` is a dimension, not a guess. The same nameplate may
  exist in several kinds; each kind's files stand alone."
- **The V-Class precedent:** `car/mercedes-benz/v-class` publishes beside
  `van/mercedes-benz/v-class` (and `car/peugeot/traveller`,
  `car/citroen/spacetourer`, `car/opel/zafira-life` beside their van twins)
  because the V-Class was simply never on the drop list.
- **PROPOSAL-kind-boundary.md, Q1 (decided 2026-07-25):** `kind` is the LEGAL
  axis — "derive `kind` from the EU category; treat the register's own word as a
  hint, never as truth."

**Mechanism — evidence decides, not a hand list.** `overrides/models/
passenger_variants.yml` lifts ONE drop pattern for ONE make, with a closed
`publish:` list of the nameplates the lifted rows may become. Whether the car
record then publishes is decided at build time by the registers themselves
(pipeline `Reconciler.passenger_gate!`): in at least one register whose car/van
line IS the M1/N1 category at row level (es, fi, gb, lu, nl — not nz, whose
"PASSENGER CAR/VAN" is one class, and not car-only sources, which read 100%
"car" by construction), the car record must hold ≥ 100 vehicles and ≥ 25% of
that country's car+van total. Every verdict is logged. First run: 34 lifted
ids examined, 22 pass, 1 held (`t-class`, already published), 11 pruned — Jumpy,
Expert, Trafic, Vivaro, Scudo, Talento, NV200, Express and the UK Vauxhall
twins fail on share (their passenger versions are already their own
nameplates: SpaceTourer, Traveller, Zafira Life, Ulysse, or simply rare).

**What stays out:** the camper/ambulance CONVERSION bases — Sprinter, Crafter,
Ducato, Master, Boxer, Jumper, Movano, Daily, TGE, the big Transit, Transporter.
Their M1 rows are motorhomes (ES RD 2822 code 32 "autocaravana": 86 of 109 M1
Ducatos) and a 1-4% share of the nameplate. They are not lifted, and the Ford
`\bTRANSIT\b` lift publishes Transit Custom only — the big Transit resolves
outside `publish:` and stays dropped (spotcheck `car/ford/transit exists: false`).

**What it costs, and why it is still additive:** no id changes meaning and no
`van/...` id is removed — lifted pairs are exempt from the 97% cross-kind
dominance prune, which would otherwise have pruned `van/peugeot/rifter` the
moment its 100%-passenger car twin appeared. Germany's KBA FZ 10.1 is an
all-M1 table, so `de_kba_fz10.yml` now routes the M1 rows of the 11 nameplates
whose car twin publishes to `car`; the van twins keep their ids but no longer
carry `de` from that table. That is an availability MOVE under the rule below
— the evidence lands on the car twin, asserted by `spotchecks.yml`
(`opel/combo` kind car `de`).

**Owner rulings on the passenger gate (2026-11-09).**
- **Threshold kept at ≥ 100 vehicles / ≥ 25% car share** in one of es, fi, gb, lu and nl. The owner accepted the threshold that best fits the production data: it admits every factory passenger version measured (Proace City passes at es 25.6%) and keeps out the commercial-first nameplates whose passenger twin already has its own name (Jumpy/SpaceTourer, Expert/Traveller, Vivaro/Zafira Life). Stock registers vote alongside flow (Doblo gb 26.7%, Dokker nl 31.3%, Partner fi 42.8%).
- **Transit Custom publishes in kind car.** Its M1 Kombi is a factory 9-seat passenger vehicle (es 39% M1). Germany's "TRANSIT CUSTOM" FZ 10.1 row, which KBA also uses for the Tourneo Custom, routes there too.

**Attested admission: a source-backed entry can publish a real nameplate below the floor (owner ruling 2026-11-09).**

*Why.* The publication rule (≥ 2 minting sources, or one source above the per-kind floor: car 1,000, van/motorcycle/moped 300, truck 150, bus 50) keeps register noise out. It also keeps out real nameplates that the evidence simply cannot carry:
- a single-market brand. Ebro S800 and S900 have 666 and 504 Spanish M1 registrations in the 3-month DGT window, and only DGT carries Ebro;
- a car of which only a handful survive. The Alfa Romeo 8C 2300 has 5 in the Dutch register.

Both kinds of record are true, both are useful to a consumer resolving what is on the road, and neither will ever clear the floor.

*Mechanism.* `overrides/models/attested.yml`, keyed kind → canonical make → published nameplate → source URL:
- **Every entry needs both:**
  - at least one MINTING register vehicle, named in the comment. Attach-only rows (au, ch, il, no) cannot attest, the same rule as minting;
  - a tier-1 (manufacturer, including its heritage site) or tier-2 (trade press, auction house, official body) source, with the tier and access date in the same-line comment. Wikipedia (tier 3) cannot attest.
- **It never conjures a record.** The pipeline (`Reconciler#attested?`) admits the id only when a register row reaches it through the normal classify path, so drop/kind rules still apply.
- **It never revives an id curation retired.** A `former_ids` alias source stays dead.
- **An inert entry fails the build** (validate gate `attested`). `scripts/lint_overrides.rb` checks the shape, the URL, the tier, the date and the register citation. With `VDB_BUILD_DIR` set, it also checks that each target exists in that build.
- **It is general:** any kind, any market.
- **First users:** Ebro S800 / S900, the nine pre-war Alfa Romeo 6C/8C nameplates on the Dutch register, and Kia K2700 / K2900 (kind van; nl rows, with the AU fleet attached).

*Why the floor is not simply lowered:* it is the only thing between the catalog and tens of thousands of register spellings. Each attestation is reviewed, cited and grounded in a register; a lower floor is none of those.

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

**Germany N1 (KBA FZ 2.8 / FZ 4.8; later FZ 2.2 and the bus column) is ATTACH-ONLY and PRESENCE-ONLY** (source
`de_kba_nfz`, 2026-11). Until then Germany's only source was FZ 10, a
passenger-car (EU M1) table, so a van record carried `de` only when its
nameplate also had an M1 version: Citroën Jumper, Peugeot Partner, Toyota Hilux,
Ford Ranger, VW Amarok, the Nissan NV range and ~80 more had no German evidence
although Germany registers them by the tens of thousands. KBA publishes no
monthly Lkw-by-model table; its only model-level Lkw tables are annual — FZ 2.8
(stock at 1 January, column *Lastkraftwagen*) and FZ 4.8 (new registrations in
the year, column *Deutschland*), both DL-DE/BY-2.0 like FZ 10. Both are read: FZ
4.8 carries nameplates too new for an FZ 2.8 row (Kia PV5, INEOS Grenadier, Maxus
T60, KGM Musso EV…).

*Why attach-only, not minting.* The row identity is (Hersteller, Handelsname),
and neither is a marque or a model. Hersteller is the **type-approval holder**
("DAIMLER (D)" for Mercedes-Benz vans; "PEUGEOT (F)" for the Fiat Scudo and Opel
Vivaro twins it approves; "STELLANTIS (F)" for four brands in one row).
Handelsname is free text **cut at 25 characters** ("Doblo,Partner,Rifter,Berl"),
often a list of every brand's twin, sometimes a type code ("MKD**-L-I"). That is
the shape that made Norway's PKK publish trims and type codes as models when it
was allowed to mint (pipeline#199): minting here would have published
`daimler/sprinter`, `peugeot/vivaro`, `stellantis/doblo`. Attach-only bounds the
worst case to adding `de` to an id that publishes anyway, and the curated map
(`overrides/kind_maps/de_kba_nfz.yml`: holder → marque, explicit twin targets,
`[]` for type codes, the truck routes) keeps even that to the listed names. The
cost is nil: every N1 nameplate worth a record already publishes from NL, FI,
GB, ES and the other registers.

*Why presence-only, not counts.* Germany's `de` count is FZ 10's monthly Pkw
FLOW with a derived window (year-to-date). FZ 2.8 is a STOCK and FZ 4.8 a FLOW
over a different, whole year. Adding either into the same per-country number
would put three measures and two periods behind one `count_window` — the error
COUNT_BASIS exists to stop — so the source decides `availability` and nothing
else: no rank, no decile, no mass, no snapshot. A record that only this source
places in Germany therefore has `de` in `availability` and no `de` in
`popularity.by_country`. Publishing N1 popularity needs a per-source count split
in emit (one basis and window per source, not per country) and is an open owner
decision.

*What a name in the cell is taken to mean.* KBA lists the trade names of the
approval, so every listed name is a nameplate registered in Germany as a Lkw
under it — with three exclusions applied by the adapter: the truncated last name
of a 25-character cell (a prefix can resolve to the wrong record), the part after
"oder"/"ou"/"od." (another market's badge for the same van: Relay, Dispatch,
Ranch), and later parts without two letters ("LT 26,28,32" — variants of the
first name). The kind is `van` unless the nameplate is routed to `truck` by name
(Actros, Atego, TGL…): the Lkw tables are N1+N2+N3 with no class column, and the
heavy-kind series fold is too coarse to offer every van name to the truck kind
("Transit Custom" would land on truck `ford/transit`).

*Extended the same day (coordinator ruling, owner completeness directive) to
buses and the car fleet*, same adapter, same pin, same two properties:
- **FZ 2.8 column *Kraftomnibusse*** → bus kind. EvoBus / Daimler Buses build
  Setra and Mercedes-Benz on one holder; Setra is the holder default and the
  Mercedes names (Citaro, Tourismo, Intouro, Travego) are routed by name.
- **FZ 2.2 *Bestand an Personenkraftwagen*** (stock at 1 January) → car kind.
  FZ 10 only sees cars first registered in the last twelve months, so a
  Mercedes 280 SL, a Saab 9-3 or a Fiat Punto on German roads had no `de`.
  Motorhomes are M1 Pkw too (1,046,383 of 49.5M), so the motorhome column is
  subtracted, and a trade name that is ≥50% motorhomes is dropped whole (camper
  bases and their body names are not cars on German roads).
- FZ 2.2 holders build several marques far more often than the Lkw holders, so
  the map adds three small tiers: `name_marques` (a leading marque word wins —
  "ALFA GIULIETTA" under FCA Italy), `marque_by_name` (a nameplate word unique
  to one marque — MINI's Cooper/One on the BMW holder), and `ignore_names`
  (trims, body words and the four high-volume alternate-market badges —
  Kauai, Morning, Sedona, Montero; the general "keep shared cells" ruling
  stands for the rest).

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
