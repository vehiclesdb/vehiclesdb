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
- **The passenger gate also judges below-floor car candidates (owner ruling 2026-11-10: "Passenger-gate symmetry: YES").** A lifted nameplate's car record that is too small to publish on its own (for example a single register under the 1,000 car floor) is now judged on the same evidence test, with the same thresholds and voting registers (≥ 100 vehicles / ≥ 25% car share in one of es, fi, gb, lu and nl). This mirrors the commercial gate below. If the record passes, the gate's evidence replaces the floor, the record publishes, and its rows no longer attach to the van twin. Below the test its rows attach to the van twin as before. Retired (former_ids) and demoted ids are never promoted. Pipeline: `Reconciler.passenger_gate!` (`promote:`). Frozen-cache replay against 2026.11.6: 1 below-floor lifted car candidate judged, 0 promoted, 0 vehicles moved off attach. All 34 other lifted ids already publish, so the rule only changes future builds.

**Commercial versions of car nameplates, and cross-kind attach (owner ruling 2026-11-10, "Nordic kind policy (NO/FI)").**
The owner's words: "Make the passenger-variant gate symmetric. Add a 'commercial-variant gate': a car nameplate also publishes a van record (e.g. van/volkswagen/touran) when one register shows at least 100 N1 rows AND at least a 25% N1 share. Same thresholds and evidence discipline as the passenger gate. … Below the threshold, cross-kind rows ATTACH to the existing record of the other kind, so they count as recognised without minting a thin record. The same applies to car rows of van nameplates (Trafic, Vivaro) that don't pass the passenger gate."

*Why.* Norway and Finland register car nameplates as vans (EU N1: a Touran or a Fiesta with a cargo floor, sold in a van tax class). Those rows reached the van build. There they either minted a thin van record or, much more often, were removed by the 97% cross-kind dominance prune or sat below the floor, so they counted nowhere. The mirror case: the car rows of van nameplates whose passenger lift fails the gate (Trafic, Vivaro, Jumpy, Expert) were pruned and vanished.

*Mechanism.* The rules live in `overrides/models/commercial_variants.yml`, next to `passenger_variants.yml`.
- **Gate** (pipeline `Reconciler.commercial_gate!`). It judges a van record whose car twin publishes in the same build and outweighs it. The record publishes only if, in one of es, fi, gb, lu or nl, it holds at least 100 vehicles and at least 25% of that country's car+van total.
  - It uses the passenger gate's thresholds and voting registers. The pipeline and the lint fail if the two files diverge.
  - Only minting counts are used. Every verdict is logged.
  - An id already published in kind van is held, never removed.
  - A passing pair's car and van halves are never pruned by the dominance prune. Unlike a passenger lift, the pair does not vote as one mass. When it did, the first replay pruned five published bus and truck ids.
- **No make list.** The passenger lift needs a closed list because it brings back rows that `drop_patterns.yml` throws away, and it must keep the camper conversion bases out. Nothing drops a car nameplate's N1 rows, so the evidence test is the whole gate.
- **Attach** (pipeline `Reconciler.cross_kind_attach!`). A car or van row lands on the other kind's published record when its own kind has no record for it. That covers a passenger-gate fail, a commercial-gate fail, the dominance prune, or a row below the floor.
  - The count lands the way an attach-only register's does. The twin's registrations by_country, availability, sources, year histograms and powertrain grow. Its minting evidence does not, so attached rows never vote in a later gate, prune or hysteresis decision.
  - It never mints, and it never applies when the row's own kind has a record.
  - It applies only to the registers whose car/van line is the M1/N1 line at row level: es, fi, gb, lu, nl, and no (PKK's PERSONBIL/VAREBIL groups).
  - Australia is excluded. Its light-commercial class is routed nameplate by nameplate in `kind_maps/au_bitre.yml` `by_model`, and a generic rule was reverted there after review.
  - Car rows that `drop_patterns.yml` drops with no lift (the conversion bases) stay dropped.

*Measured* (frozen-cache replay against 2026.11.5, 2026-11-10; refreshed after the Astra round-1 fixes — candidates gated, popularity and make countries recomputed after attach, attested records exempt from the cross-kind prune):
- **Gate verdicts:** 443 van ids of car nameplates were examined. 39 passed, 103 were held (already published) and 301 were withheld. 715 below-floor van candidates were also judged and 2 promoted (Astra review: the gate evidence replaces the publish floor, as for the passenger gate). All 301 were records the dominance prune removed before this ruling, so none would have published.
- **Records created:** 4 new van records: `van/austin/maestro` (gb 282 N1, 37.3%) and `van/jeep/cj-7` (nl 261 N1, 27.5%), promoted from candidates, plus `van/land-rover/freelander` (nl 883 N1, 28.0%) and `van/mitsubishi/pajero-sport` (fi 144 N1, 55.8%). The dominance prune used to remove them. No published id is removed in any kind.
- **Recovered vehicles:** 194,477 vehicles now count on published records.
  - 118,495 van rows moved onto 1,142 car records: gb 60,682, fi 27,821, no 16,576, nl 13,329, es 51, lu 36. Top records: Ford Fiesta 33,936, Toyota Corolla 7,161, VW Touran 5,754.
  - 75,982 car rows moved onto 127 van records: gb 56,185, nl 13,584, no 4,231, fi 1,348, es 547, lu 87. Top records: Renault Trafic 20,042, Vauxhall Combo 16,358, Vauxhall Vivaro 11,861.

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

**Attested admission on attach-only evidence (owner ruling 2026-11-10).** The 2026-11-09 rule above required a MINTING register row, which left ~140 verified, sourced nameplates unpublishable because their only register evidence is in an attach-only register (Australia's BITRE census, Israel's MoT, Norway, Switzerland): Kenworth T409/T610/T909, Isuzu FRR/FTR/NPS, Hino 300, Mack Granite, Freightliner Columbia, LDV G10, Great Wall Cannon … The owner ruled that a real nameplate with a manufacturer or trade source is curated knowledge, not register noise, and may publish on attach-only evidence.
- **Shape — explicit and auditable.** The entry's value becomes a mapping: `T409: {url: https://…, evidence: attach_only}  # au_bitre 3,546; attach-only evidence … [tier 2]`. A plain URL entry keeps the strict minting rule; only the flagged form relaxes it, so `grep "evidence: attach_only" overrides/models/attested.yml` lists every such admission.
- **Still never conjures a record.** An attach-only register row must reach the id through the normal classify path (the build fails an entry no register row reaches at all), and a `former_ids` alias source stays dead.
- **Still curated, not automatic.** Attach-only registers themselves remain attach-only (they never mint on their own — DECISIONS "A new register is ATTACH-ONLY until its junk rate is measured"); only a reviewed attested.yml line, with a tier-1/2 URL fetched and confirmed, can publish on their evidence.
- `scripts/lint_overrides.rb` accepts the mapping only with `evidence: attach_only` and requires the comment to say "attach-only evidence"; the pipeline loader rejects any other `evidence` value.
- **Owner exclusions kept:** no van ids for Australian utes whose nameplate is a car record (Colorado, Falcon, Rodeo); family labels (Kenworth K/W-series, Mack CSMR/CMMT/CMMR) and the UD codes sourced only from a sales atlas are not nameplates.

*Why the floor is not simply lowered:* it is the only thing between the catalog and tens of thousands of register spellings. Each attestation is reviewed, cited and grounded in a register; a lower floor is none of those.

**Lifecycle: status and years from non-register evidence, and admission without a register (lane LIFE, 2026-11-11; owner request of the same day).** The owner asked that a newly announced model (the Tesla Next Gen Roadster, unveiled 2026-10-15) be listed although no register carries it, that the Cybertruck's stated end be recorded, and that a current model read "2016–now", not "2016–2026".
- **One model for the facts.** The private pipeline's production runs (`enrich/<make>.yml` `runs:`) stay the only place years are curated. Five additive run keys carry what is *stated* but has not happened: `year_start_planned` (a run not started), `year_end_planned` (the stated end of an open run), `planned_by` and `planned_on` (who said it, when — required with either planned year), `announced` (date), and `cancelled` (a planned run the manufacturer dropped). A CEO post or an earnings-call remark is a statement of intent: it becomes a *planned* year with its speaker and date, never an end year.
- **A plan says what it rests on.** Every planned year carries `planned_basis` — `company_filing`, `company_statement` or `executive_statement` — and the open object publishes it (`year_end_planned_basis`), so the Cybertruck's 2027 reads as the CEO's statement on X, not a company filing. The speaker, date, posts and quotes stay private.
- **Status is derived, never typed:** `announced` / `in_production` / `ending` / `ended` / `cancelled` (rules in SCHEMA.md *Lifecycle*). A planned run suppresses the private `discontinued` era badge, the same way an open run does.
- **Open vs private.** The open `lifecycle` object (catalog, vehicles.json, CSV, sqlite) carries only status and years — plain facts — and only when the runs' evidence tier is manufacturer, register, instrument, press or reference. Wikipedia-tier runs stay private (nothing derived from a ShareAlike source enters the open dataset). The citations, `planned_by`/`planned_on`, notes, variants and planned runs themselves stay in the paid catalog-plus feed, which carries the lifecycle for every tier.
- **Admission without a register: one mechanism.** `attested.yml` gains a third value form, `{url:, evidence: manufacturer, announced: "YYYY-MM-DD"}`. It is the only path that creates a record no register row reaches.
  - *Bar:* an official manufacturer announcement of a named production vehicle — a tier-1 URL (the manufacturer, its filings or its regulator file) and the announcement date. Concepts, design studies, rumours and "we plan to" without a named production vehicle are not admitted; the evidence is kept and the rejection recorded (Tesla Robovan, 2026-11-11: shown in 2024, in no Tesla capacity table).
  - *Shape:* the record has empty availability, regions and sources and no popularity, and must carry an open lifecycle (the build fails otherwise).
  - *Identity:* the key is the published nameplate under the canonical make, exactly as for any attested entry, so register rows that arrive later classify to the same key and the same id. A revival of an existing nameplate (the Next Gen Roadster) is a planned run on the existing record, not a new id.
  - *Counts:* no rank, decile or mass share moves; the records sit in the decile-mass `"none"` band; `manifest.json` `kinds.<kind>.unregistered` counts the records with no `registration` evidence anywhere — manufacturer admissions and approval/sales-only records alike ("models on the road" = models − unregistered) and `kinds.<kind>.announced` counts derived status `announced` (a registered nameplate with an announced new generation included) — two counts, each named for what it is (coordinator ruling 2026-11-11). Completeness gates measure register mass and are unaffected.
- **Review rule (vapourware guard).** Every build writes the private `lifecycle-review.json`: a planned start 2+ years past with no production run (`planned_start_overdue`), and a stated end year already past on a still-open run (`planned_end_passed`). Each row is re-sourced — started, delayed, or cancelled (`cancelled: true`, status `cancelled`; the id stays, ids are append-only).
- **Intake.** Non-register datapoints are recorded first as reviewed evidence records in the pipeline's `maker_watch/` (entity, fact, value, date, URL, access date, tier, quote, review state), then applied by a curator. The watch tooling never writes the catalog.
- **First users:** Tesla — Model S and Model X ended 2026, Model 3 and Model Y in production, Cybertruck ending (planned 2027, Elon Musk on X, 2026-11-11), Roadster announced (2008–2012 run; next generation planned 2028), and two records admitted on manufacturer evidence: `car/tesla/cybercab` (in production since 2026) and `truck/tesla/semi` (in production since 2022, volume from 2026).

**Country of origin per make is open; the current owner is not (owner ruling 2026-11-12).** The pipeline's private ownership layer (who owns every brand, as dated relations, with citations) raised two candidates for the open dataset: each make's country of origin and its current parent group. The owner approved publishing ("YES TURN EVERYTHING ON AND PUBLISH — make the decisions yourself"); the dataset lane decided, under that, to publish the **origin only**.
- *For publishing origin:* it is the field dataset users ask for first, and it unlocks "German / Japanese / Italian car brands" lists from open data (about 60,000 searches a month across five languages) and "where is X from" answers anywhere. It is stable: where a marque was founded does not change. It costs the paid layer little, because ownership history, stakes, timelines and every citation with its quote stay private. It earns backlinks and AI-citation value.
- *Against, and how each is handled:*
  - **One-way.** Under the Open Contract a published fact can never be withdrawn, so a wrong origin is permanent. Handled by a written definition (SCHEMA.md *Country of origin*), by publishing only on a manufacturer, regulator or archive source whose quote was re-fetched and found verbatim, and by `country_disputed` instead of a guess.
  - **Edge cases** (MG: British marque, Chinese owner; Volvo; Lotus; Mini; revived names). Handled by the definition: the country where the marque was founded, never the owner's, the plant's or the headquarters' country.
  - **It gives competitors the cheapest part of the ownership work.** Accepted: one code per make is the plain fact; the dated graph and the citations remain the product.
- *Why the current group stays private:* it goes stale between releases (brands are sold), it would have to be read "as of the dataset version", and a stale open fact cannot be withdrawn. It stays in the paid feed and on the website's group pages.
- **Definition** (binding; SCHEMA.md has the examples): the country where the marque was founded — the seat of the company or division that first put vehicles on sale under that name — as the present-day ISO 3166-1 alpha-2 code of that place. Sub-brands take the creating company's country; renamed or revived marques keep the original origin when they claim continuity; former states map to the present-day state that contains the founding seat (Austria-Hungary/Czechoslovakia → `cz`, USSR → the successor state of the seat, Yugoslavia → likewise, GDR/West Germany → `de`), with the source's own wording kept in the private citation; a marque whose founding spans two countries (a cross-border joint venture or merger that created the name) gets `country_disputed`; a marque founded in one country and continued in another keeps the founding country. Out of scope: ownership, headquarters, plants, markets.
- **Never withdrawn silently.** Once published, a make's origin can only be corrected (wrong value → right value), never dropped because a citation moved or a rule tightened: the pipeline's gate 2 fails a build that removes or changes a published origin unless `overrides/models/gate_acks.yml` carries an adjudicated `origin: {<make>: {from:, to:, why:}}` entry bound to that exact transition (an ack for an older correction exempts nothing), and the correction is noted in the CHANGELOG.
- **Shape:** `country` (lower case, like every country code here) + `country_tier` (`manufacturer` | `regulator` | `archive`), or `country_disputed` (2+ sorted codes). On `catalog/<kind>/makes.json`, the `dist/vehicles.json` make objects and three appended `catalog.sqlite` `makes` columns. Not in the per-model CSV/parquet or the array-packed `vehicles.min.json` (make-level, like `former_slugs`). Additive: no schema version moves.
- **One source of truth:** the value is emitted from the pipeline's ownership layer (the make's cited `country` in `enrich/<make>.yml`, for makes the ownership graph covers), never from a second list. The pipeline's gate 2 and `scripts/lint_schema_doc.rb` check the shape; the pipeline's `test_make_origin.rb` checks that every published value has a qualifying source.
- **Sources.** Manufacturer (the maker's or its group's history pages, annual reports, press kits, its own museum), regulator (official registers, securities and stock-exchange filings) or archive (a public archive, national museum or heritage trust holding the marque's records, such as the British Motor Museum; never an enthusiast club or a reference site). Press, reference works and Wikipedia never publish: Wikipedia may locate a source, never be one. A quote must state the origin itself (a founding place or a national identity); a headquarters address or an ownership sentence does not. A researcher's quote that could not be re-fetched and matched verbatim leaves the make without the field until it is re-sourced.
- **First release** (targeted at 2026.11.10): the 150 makes with the most registrations were researched in mass order, and every admitted quote was then re-read against the definition by an adversarial review (round 1 held or re-sourced 20 rows whose quotes stated a headquarters, a plant, an owner or an aspiration). **125 makes carry an origin: 124 a `country`, 1 a `country_disputed`** (Leyland DAF gb/nl, a cross-border merger). They hold **98.7% of the catalog's registration mass**; all of the top 50 makes are covered. By tier: 96 manufacturer, 22 regulator, 6 archive. 25 of the 150 have no origin yet, together 0.8% of the mass: 14 because no qualifying source could be fetched (LDV, Kenworth, Daewoo, Zontes, ORA, Voge, Baotian, Talbot and six Dutch moped brands), 5 held on the definition or the evidence (smart: a Swiss-founded joint venture with no qualifying source for the German side; Lynk & Co: no source states a two-country founding; Keeway, Western Star, Austin Morris), 3 because a quote could not be re-fetched (Tomos, ZNEN, CFMOTO) and 3 because the ownership graph does not cover the make yet (Puch, La Souris, Mahindra). The full list is in the pipeline PR.

## Sources & evidence

- **Known-held nameplates (owner rulings 2026-11-10, release 2026.11.4).** Accuracy first: when the evidence cannot name the model, the row stays unresolved rather than guessed. Revisit each only with the source named.
  - Australian UD / Nissan Diesel chassis codes (CWB, GWB and siblings, ~7.3k au_bitre vehicles): the codes span the pre-Quon CW/CK series and the Quon, so folding them onto Quon would be wrong for the 1990s trucks. Revisit if a source maps code → model by year.
  - Mercedes-Benz "96X" (au 574): the code covers both Actros and Arocs.
  - Hino FF / FB / GS: named only by classifieds.
  - Ford Trader and Daihatsu Delta (au): no tier-1/2 page names them (sales-database and brochure-scan pages only).
  - Spanish two-wheeler TYPE CODES with no proven commercial name (79 candidates, ~1.05k vehicles Jul–Sep 2026, e.g. MITT TY125T-*, Letbe HJ125T-5B): held until the importer's commercial name is sourced.
  - Isuzu NPR/NQR/NKR in Australia's light-commercial class: not routed to truck (van/isuzu/npr is a published N1 record elsewhere); needs its own ruling.
  - Israeli motorcycle TYPE CODES shared by more than one model (Yamaha MT-09 / XSR900 / Tracer 9 platform codes and the like, ~12k il_mot vehicles; owner ruling 2026-11-10): HELD for good. A row is never assigned to one model when its code is shared — `kind_maps/il_mot.yml type_codes` carries only codes whose RDW evidence names one model at ≥ 90%. Accuracy beats coverage.
  - Israeli GM ORDER CODES (heavy register, owner ruling 2026-11-10): each full code is mapped only where it decodes to exactly ONE nameplate over every row it carries — 120 codes, 18,075 vehicles (Chevrolet CK/CC → Silverado, CG → Express, x906 → Suburban; GMC TT/TK → Sierra, TT35743 → Hummer; kind_maps/il_mot.yml type_codes heavy). HELD: codes that change model with the model year (385 vehicles; the heavy allow-list carries no year column, so a year-conditioned mapping needs a pipeline change first), bus-only Express minibuses (no published Chevrolet bus record), Hebrew-text cells, and GMC Suburban/Tahoe stragglers (1,268).
- **Unattributable register rows set a coverage ceiling (owner ruling 2026-11-10).** Some register rows carry no model at all: Spain's DGT writes "N.A."/"N/A"/"---" in MODELO_ITV (Rieju and Beta mopeds, ~1,060 vehicles Jul–Sep 2026, whose records carry only maker and cc — no type-approval or variant field to recover a model from); the UK DfT VEH0120 writes "<MAKE> MODEL MISSING" (≈851k motorcycles, ≈647k trucks, ≈520k cars, ≈273k vans at 2026 Q2) and pools makes as "OTHER BRITISH/ITALIAN…". These rows are counted in the register's denominator and can never land on a model record, so a register's coverage reads against a ceiling below 100%. Release notes report coverage both raw and over ATTRIBUTABLE vehicles (rows with a model string and a named make). Nothing is guessed to lift the ceiling.
- **Converter makes and conversions (owner rulings 2026-11-10).** A body converter that is published as a make is still re-homed onto the base vehicle when its rows are conversions (overrides/makes/converters.yml, with the evidence per make); its own records retire with former_ids to the base. A genuine manufacturer with its own nameplates stays a make (Socage, the bus coachbuilders, the camper builders). A van conversion of a car whose base model has no van record lands on the existing car record rather than minting a van id (Zago "SANDERO VAN" → Dacia Sandero).
  - **A converter's rows are re-homed only where the register identifies the base vehicle** (DGT base-vehicle make/type, or a chassis field), onto that base record under the converter rule; otherwise they stay unattributed. A blanket fold of all a converter's rows onto one base model is not allowed when the converter builds on several bases (owner ruling 2026-11-10: the 47 RDW "IVECO/IGLOOCAR" vans were NOT folded onto the Iveco Daily; `van/iveco-igloocar/igloocar` retired via removals.yml).
- **Wrong-kind nameplates in a register class are routed by curated kind maps** (kind_maps/<source>.yml `by_model`, exact raw pair, evidence per line). Wrong kind is an accuracy bug; the class decides only when no route names the pair.
- **Coded heavy designations that are their own nameplates** stay whole (overrides/models/series_keep.yml: Sterling LT7500/LT9500/AT9500, Caterpillar CT610/CT630). Distinct real nameplates are separate records.


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
