# PRD-PLATES — the license-plate & registration-mark dataset

*Version 1.0, 2026-07-26. Written at the owner's direction: VehiclesDB will
manufacture the most comprehensive, most accurate license-plate dataset on
the internet — designs, formats, regex, colors, classes, and their validity
periods, across ALL territories, ALL years, and (eventually) ALL vehicle
types — built 80/20: the highest-return slices first, long tails after,
never the reverse. Companions: PRD-QUALITY.md (the quality machine this
program inherits wholesale), PRD-FIVE-NINES.md (plates enter its claim model
at gate L2), PRD-PAID.md (web, private — the monetized capabilities),
SCHEMA.md (catalog contracts this extends). Amend by PR to this file.
Assume the reader has nothing but the repos.*

---

## 0. Why this belongs in VehiclesDB, and what "win" means

A plate is the one vehicle fact every human sees daily and almost no dataset
models properly. The facts are scattered across government PDFs, one
excellent-but-unstructured Wikipedia corpus, and enthusiast sites with no
schema, no validity periods, and no machine-readable formats. **Win =** the
single source where a machine can ask: *"is `M-1234-XY` a plausible Spanish
plate, from when, issued where, on what class of vehicle — and what did it
look like?"* — and get a schema'd, cited, versioned answer. Nobody has that.
The audiences stack: developers (validation + display), the Geoguessr/
plate-spotting community (the encyclopedia section — high-share, high-link
traffic), insurers/marketplaces (parse + validate at scale), and our own
resolver (a plate is a country+era signal that sharpens vehicle resolution).

## 1. The open/paid split (decided here, per the standing delegation)

**OPEN (this repo, CC-BY-4.0): the complete FACTS layer.** Jurisdictions,
series, validity periods, human patterns + regexes, colors, classes,
region-encoding tables, physical dimensions, authority links. Rationale:
facts are uncopyrightable, so a closed facts layer defends nothing; open
facts maximize adoption of the gem and feed the encyclopedia section, which
is the funnel; and this is the identity-layer philosophy (PRODUCT-SHAPE)
applied to a new domain.

**PAID (pipeline private layer → vehiclesdb-web):**
1. **`/v1/plates/parse`** — plate string in → ranked candidate
   interpretations out (jurisdiction, series, era, class, region decode,
   confidence + the audit trail) — the resolver-shaped capability; the fold
   corpus equivalent here is the validated regex+period+precedence machine,
   which is the labor, which is the moat.
2. **The render bundle** — production-grade parametric SVG templates, layout
   coordinates, font metrics, per-series render specs; versioned, licensed.
   (The site shows renders freely — funnel; the machine-consumable bundle is
   the product.)
3. **Validation-as-a-service** with SLA + freshness (new series land in the
   paid feed at merge, in the open release monthly).
4. Bulk licensed exports with per-fact provenance, as elsewhere.

## 2. Domain model — the schema

### 2.1 Files and keys

```
plates/                          # NEW top-level dataset dir, this repo
  <iso3166-1-alpha2>.yml         # one country file (nl.yml, es.yml, de.yml)
  us/<iso3166-2-suffix>.yml      # federated systems subdivide (us/fl.yml);
                                 #   us.yml holds the federation-level frame
  _meta/classes.yml              # the controlled vocabulary of plate classes
  _meta/schema-version.yml
```

Jurisdiction codes are ISO 3166-1/-2. A **series** is the unit of record —
one issuance system with one format+design over one validity period — with a
**stable, append-only id** (`nl-sidecode-4`, `es-provincial-1971`,
`us-fl-standard-2003`): the id contract (PRD-QUALITY I-5/I-6) extends to
plates verbatim, including former-id aliases when curation re-cuts series
boundaries. Consumers will hang UI and validation logic off series ids; they
get the same no-vanish guarantee the catalog gives.

### 2.2 The series record (the whole point — read every comment)

```yaml
# plates/nl.yml
jurisdiction: nl
authority: { name: RDW, url: "https://www.rdw.nl/..." }   # cited, fetched
series:
  - id: nl-sidecode-8
    class: standard              # from _meta/classes.yml (§2.3)
    categories: [car, van, truck, bus]   # OUR kinds vocabulary — extensible
                                 # to boat/aircraft/rail (G24) without schema
                                 # change; a series may scope narrower than
                                 # its jurisdiction default
    period: { start: 2011, end: 2015 }   # THE RUNS SHAPE, reused verbatim
                                 # from enrich: integer years; end: null =
                                 # open (currently issued); `ended: true` +
                                 # `year_end_min:` for known-over-undated
                                 # (the Turn 97 schema earned its keep once —
                                 # historic series will need it constantly).
                                 # Overlap legal iff distinct notes (parallel
                                 # series are REAL: old stock issues on).
    format:
      pattern: "9-LLL-99"        # human pattern: 9=digit L=letter, literal
                                 # separators as printed
      regex: "\\A\\d{1}-[A-Z]{3}-\\d{2}\\z"   # anchored; MUST pass the lint
                                 # round-trip (regex generates→pattern
                                 # matches) and the sample tests (§5.2)
      charset: { excluded: [...] }  # letters the authority never issues
                                 # (profanity/lookalike exclusions) — cited
      progression: note          # how serials advance, when known (fills
                                 # the parse API's era-inference)
    design:
      plate: { w: 520, h: 110, unit: mm }     # + variants (motorcycle/moped
                                              #   sizes as sub-entries)
      background: { color: "#F9B700", finish: retroreflective }  # hex is a
                                 # FACT claim — cited to spec where one
                                 # exists, else marked observed
      foreground: "#000000"
      band: { side: left, color: "#003399", content: eu-stars+NL }
      font: { name: ..., license: ... }       # §6 licensing law applies
      rear_differs: false        # UK-style front/rear asymmetry when true
    region_encoding: none        # or the decode table/reference (§2.4)
    sources:                     # per-CLAIM same-line citations in the file
      - "https://…  # period + format"
      - "https://…  # colors"
    notes: free text for the messy truth (transition windows, old-stock
           validity, re-registration rules)
```

Schema stressors measured by the US/world dossier, accommodated by design:
**Japan needs a `fields[]` composition** (kanji office name + class code +
color-conditional hiragana + serial — a single pattern string cannot carry
it; `format.fields:` is the extension point); **non-rectangular plates
exist** (Canada's NT polar-bear plate → optional `design.shape:`);
**variable-width serials** (Delaware) mean regexes quantify rather than
fix width; **rollouts need three dates** (Mercosur: announced 2014 /
first-issue / full-coverage diverged per country → `period.rollout:`
sub-keys when they differ). Jurisdictions where the plate binds to the
OWNER not the vehicle (CH) carry `binding: owner`.

### 2.3 Plate classes (controlled vocabulary, `_meta/classes.yml`)

`standard · motorcycle · moped · trailer · diplomatic · consular ·
temporary · export · transit · dealer/trade · historic/vintage · taxi ·
government · military · police · electric · seasonal · agricultural ·
personalized/vanity · specialty-program` — each with a one-line definition
and the rule for when a jurisdiction's variant is its own SERIES vs a
class-flag on an existing one (own series iff format OR design OR period
differs; a color-only variant of the same format+period is a sub-entry).
The vocabulary grows by PR with a definition — never ad hoc in data files.

### 2.4 Region encoding — the Geoguessr gold and the parse API's teeth

Where a plate encodes geography or time (German city prefixes, Spanish
pre-2000 province codes, Italian province suffixes, French department
markers, Dutch sidecode→era inference, Japanese office names), the series
carries either an inline table (small) or a reference to
`plates/_decode/<jurisdiction>-<topic>.yml` (large — the German prefix
table is ~700 rows). Decode tables are first-class cited data with the same
period discipline (province codes changed over time).

Measured decode traps (EU dossier): the German district list is NOT in
the FZV — §9 FZV delegates it to BMDV publications in the Bundesanzeiger
(the primary source to pin per code); FZV Anlage 1 is the serial GRAMMAR
(five verbatim patterns — a directly citable regex source). France's SIV
département band is OWNER-CHOSEN, not geographic — only the pre-2009 FNI
decodes reliably, and the decode table must say so or the parse API will
lie. Swiss plates attach to the OWNER, not the vehicle — jurisdictions
where the plate-to-vehicle binding differs carry an explicit `binding:`
field so vehicle-keyed consumers cannot misread them.

### 2.5 What is deliberately NOT modeled in v1

Serial-allocation minutiae below era-inference usefulness; manufacturing/
supplier detail; pricing/fees; the full specialty-design catalog of every US
state (L2 indexes the programs with official links + counts; individual
specialty DESIGNS are L4); plate FONTS as font files (we record name +
licensing status; embedding decisions per §6).

## 3. Rendering — our own SVGs, spec-driven, licensing-clean

A pipeline tool (`pipeline/tools/render_plate.rb`, gate L1) renders every
series deterministically FROM ITS DATA: dimensions → viewBox, colors, band,
font (only fonts whose licensing §6 clears — else a metrically-similar free
fallback with the substitution recorded in the render manifest), sample
serial from the format. No photographs, no copied images, no traced
artwork. Jurisdiction emblems ON plates (state seals, FL's orange, coats of
arms) are the one hazard: v1 renders a NEUTRAL placeholder glyph in the
emblem slot with `emblem: {present: true, rendered: placeholder}` — exact
artwork only where its license is affirmatively clean (per-emblem, cited).
This keeps the entire render layer ours, at the cost of stylization —
which the encyclopedia section states honestly ("schematic renders, not
photographs").

## 4. Sourcing law (extends the standing table in PRD-PAID §2)

| source class | rule |
|---|---|
| Government/authority pages, statutes, gazettes (RDW, DVLA, BOE, EUR-Lex, UNECE, state DMVs) | PRIMARY. Facts extractable; cite the page per claim; archive the fetch |
| EU/intl law (Reg. 2411/98, Vienna Convention annexes) | normative for what they mandate — quote articles, not summaries. MEASURED CAUTIONS (EU dossier): 2411/98 is a MUTUAL-RECOGNITION instrument, not a design standard — its annex is a scanned bitmap with no geometry and no per-country code list; Euroband millimetres come from NATIONAL law (ES Anexo XVIII, DE FZV Anlage 4). The 1968 Vienna Convention AS ADOPTED forbids incorporating the distinguishing sign in the plate (Annex 3 §3, UNTS 1042); the amendment permitting it is UNVERIFIED (UNECE 403s) — never state the amended rule as sourced until pinned |
| Wikipedia (the plates corpus is genuinely excellent) | LOCATOR ONLY, per the standing rule — chase its citations to primaries; facts individually verified; never systematic text/table extraction |
| Enthusiast references (worldlicenseplates, olavsplates, plateshack, europlate...) | facts-uncopyrightable applies; no text copying; treat as corroboration + gap-finders, cite what was actually used; their PHOTOS are never copied |
| Wikimedia Commons plate images | NOT copied into the dataset. License texture recorded per §6; our renders are generated, not derived |
| US standards chain (SAE J686 → AAMVA License Plate Standard Ed.3 → voluntary state adoption; NO federal mandate) | AAMVA Ed.3 (Sept 2025) is fetched and text-extracted — renderable geometry (character heights, stroke widths, layout) and the 7–10-year replacement-cycle recommendation come from it; **SAE J686's own text is UNPINNED** (paywalled) — never quote J686 dimensions except via AAMVA until purchased |
| US state law + DMV pages | per-state IP posture VARIES and is recorded per jurisdiction as `artwork_risk:` — FL broadly PD ({PD-FLGov}, Microdecisions 2004) and is the pilot state deliberately; AZ asserts copyright; NY/PA/WA adverse. EDICTS OF GOVERNMENT are PD at every level → always prefer the statute/administrative-code spec over brochures. State SEALS carry protection independent of copyright — unresearched, flagged, placeholder rule applies |
| Registry open data carrying real plate numbers (RDW kenteken fields!) | usable as REGEX VALIDATION CORPORA where the source license allows — millions of real plates to test formats against; never republished as plate lists |

Two research dossiers with pinned URLs (EU/international framework + fonts;
US/world + design-IP + prior art) are archived in the pipeline repo's
`aux/research/plates-2026-07/` and constitute this PRD's source appendix —
every jurisdiction pass starts from them.

Folklore caution (measured): the famous "1956 AMA standardization
agreement" is UNCITED in its Wikipedia source (a `citation needed` since
2017, copied verbatim across articles — circular). It appears here as
"commonly repeated, unsourced" until a primary lands. And the Commons
finding cuts cleanly: CC tags on plate photographs are the
PHOTOGRAPHER'S license on the photo — the uploader had no standing over
the design — which is one more affirmative argument for the own-SVG rule:
we never touch the photo, so its obligations never attach.

**Prior art (why "most comprehensive" is winnable):** openalpr's config
corpus is broadest (~161 jurisdictions) but AGPL-3.0, a lossy DSL rather
than regex, and unmaintained since 2024-01; validator.js has the best
regexes but 13 locales and zero metadata. **No existing dataset cites a
source per pattern, none carries validity periods, and Wikidata has no
plate-format property at all — the niche is structurally unclaimed.**
Sourced-per-claim + period-disciplined + corpus-tested is the moat.

## 5. Quality — the same machine, extended

### 5.1 Claims model (five-nines integration, gate L2)

Per series, the claims: format-correct (regex matches what the authority
issues), period-correct (start/end years), color-correct, class-correct,
jurisdiction-complete (no missing current series for a covered
jurisdiction). Plates enter PRD-FIVE-NINES's audit strata once L1 ships —
same ledger, same researcher≠verifier, same published intervals.

### 5.2 Lint + tests (gate L0, before ANY data lands)

`scripts/lint_plates.rb`: schema shape; series-id uniqueness + append-only
against the previous release; period rails (1893 ≤ start — the first
national plates — end ≤ current+1); overlap-legal-iff-distinct-notes;
regex COMPILES, is anchored, and round-trips the human pattern (generate
100 serials from the pattern → all must match the regex, and vice-versa
fuzzing); every series carries ≥1 source line; class ∈ vocabulary; hex
colors well-formed; jurisdiction files match ISO codes.
`test_plates_corpora.rb` (pipeline): where a validation corpus exists
(nl kenteken), the CURRENT series' regexes must jointly match ≥99.9% of
real current plates — a regression net no competitor has.

### 5.3 Verification protocol

Per-jurisdiction dossiers, the established shape: researcher builds the
series list with per-claim citations; independent verifier re-derives
period boundaries and formats from primary sources (the era boundaries are
where sources disagree — Spanish 2000 cutover, French SIV rollout — record
disagreements in notes, never average them); maintainer applies. MAJORITY
IS NOT AUTHORITY; the authority is the authority.

## 6. Fonts & design IP (walked, from the EU dossier — primary sources pinned there)

- **No surveyed country mandates a licensable font.** UK regulations
  prescribe the "prescribed font" by statutory DRAWING, not a named
  typeface; DE and ES likewise publish statutory Schriftmuster.
  Consequence: the render layer derives glyphs FROM THE STATUTORY
  DRAWINGS — never from third-party TTFs (EuroPlate-style fonts carry
  unstated licences).
- **The real IP exposure is the standards documents themselves** (BS AU
  145e, DIN 74069): building TO them is fine; redistributing their text
  or drawings is not. Cite, never embed.
- **Commons plate photographs are dominantly CC BY-SA** (measured via the
  API on sampled files) — share-alike would propagate into the dataset;
  this vindicates the own-SVG rule absolutely. Germany is affirmatively
  favourable (PD-VzKat / §5(1) UrhG: designs published inside statutory
  instruments are public domain). No surveyed country claims copyright in
  the plate design itself — a SAMPLE finding, not an exhaustive survey;
  recorded as such.
- Emblem rule from §3 stands: neutral placeholder unless affirmatively
  clean per emblem.
- **Binding default: when licensing is unclear, render the schematic
  fallback and record why.** No render tool ships with an unresolved font
  posture (L0 acceptance).

## 7. Roadmap — 80/20 enforced by gate

| gate | scope | why this order | acceptance |
|---|---|---|---|
| **L0** | Schema + `lint_plates` + render skeleton + **pilot: NL, ES, DE, US-FL** | the pilot spans the four hardest axes: sidecode eras (NL), provincial→national history (ES), region-prefix decode at scale (DE), federated + specialty-programs (US-FL) | lint green; pilot renders; regex round-trip + NL kenteken corpus test passing; §6 resolved from dossiers |
| **L1** | EU/EEA + UK + CH: every CURRENT series, all core classes (standard/motorcycle/diplomatic/temporary/historic) + one series back | the semi-standardized, highest-trivia-value, best-sourced slice; ~35 jurisdictions | per-jurisdiction dossiers verified; render gallery live on the site (funnel) |
| **L2** | US: 50 states + DC + territories, current standard-issue + specialty-program INDEX; CA provinces; plates enter the five-nines audit | the design-variety showcase; the encyclopedia's biggest draw | parse API alpha on L0+L1+L2 data (PRD-PAID P-2 alignment) |
| **L3** | Our-evidence countries completed (nz ua th my ar lu ie...) + JP BR MX AU KR CN IN ZA | synergy: registries we already ingest; JP/BR systems are decode-rich | corpus tests where registries allow |
| **L4** | Historical depth (the pre-2000 world), diplomatic decode tables, specialty-design depth | now the encyclopedia becomes THE reference | five-nines claims coverage |
| **L5** | Rest of world: every UN member + dependent territories, current series | "all territories" honestly reached | jurisdiction-completeness detector at zero |
| **L6** | Other registration domains: boats, aircraft (N-numbers), rail | the G24 growth path, schema already category-ready | separate mini-PRDs per domain |

Sequencing rule: **a gate does not open until the previous gate's
jurisdictions pass verification** — depth before breadth inside each slice,
breadth before depth across slices. Same swarm economics as the catalog
programs (Opus researchers, session verifies and applies, dossiers embedded
in PRs, graduated to aux/).

## 8. Deliverables map

| piece | repo | layer |
|---|---|---|
| `plates/` dataset + `_meta` + `_decode` | data (public) | open |
| `lint_plates.rb`, corpus tests | data scripts + pipeline tests | open |
| `render_plate.rb` + schematic SVG output in builds | pipeline | renders open on site; BUNDLE paid |
| plate-parse engine + API | pipeline private → web | paid |
| Encyclopedia section ("Plates of the world") | web | open pages, paid API |
| Gem: `Vehicles::Plates.validate/lookup` | vehicles gem | open |
| Research dossiers + this PRD's source appendix | pipeline `aux/research/plates-2026-07/` | private archive |

## 9. Risks, stated plainly

- **Era boundaries are folklore-prone.** Transition years get repeated
  wrong across the enthusiast web. Mitigation: primary-source-or-marked,
  disagreements recorded in notes, the audit samples period claims hardest.
- **Emblem/font IP.** §3/§6 defaults keep us clean at the cost of render
  fidelity; never invert that trade silently.
- **Scope gravity.** Specialty plates and prefixes are bottomless;
  the gates + the §2.5 exclusions are the discipline. The encyclopedia
  can be the best without being infinite.
- **Region-decode tables rot** (provinces merge, offices close). Period
  discipline on decode rows + the quarterly audit inherit the fix.
- **Real-plate corpora and privacy.** Registry plate numbers are used only
  as in-CI validation corpora under the source's own license, never
  republished; the dataset contains FORMATS, not plates.

## 10. Ownership & next actions

Program lead: S4W (this document). Jurisdiction slices assign at L1 kickoff
(S2W's registries knowledge maps to their evidence countries; plates are
jurisdiction-keyed, not kind-keyed, so the halves negotiate slices in
NEGOTIATION.md as usual). Immediate next: (1) integrate the two research
dossiers' pin-lists into the source appendix + complete §6; (2) gate L0
schema/lint/pilot as its own PR series; (3) PRD-PAID amendment for
plate-parse (private repo). Nothing in this program blocks the five-nines
workstreams; it runs as its own track.
