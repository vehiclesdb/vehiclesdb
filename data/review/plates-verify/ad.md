# §5.3 verification dossier — `ad` (Andorra)

**Gate** L1 (microstates group) · **Loop** QA-LOOP-2 · **Date** 2026-08-08
**Role of this session** RESEARCHER ONLY. Under I-11 the author never certifies
their own work, so `plates/ad.yml` ships `verification.status:
awaiting_verification` and `verification.verifier: null`. Everything below is a
claim awaiting a second signer — including the corrections.

**Subject** `plates/ad.yml`, 16 series, previously headed *"DRAFT for
verification"*. This is the first §5.3 pass on any L1 jurisdiction; PRD-PLATES
§7.2 records the human verification pass as outstanding for both waves.

---

## 0. Why `ad`, and what "the deterministic list" was

The unit was defined as index 0 of the sorted list of L1-wave jurisdiction files
lacking a §5.3 dossier. Computed from the data itself rather than from prose,
since every jurisdiction file declares its gate in its first line:

```
$ grep -l "gate L1" plates/*.yml | xargs -n1 basename | sort
ad at be ch cy cz dk ee fi fr gb gr hr hu ie is it li lt lu lv mc mt no
pl pt ro se si sk sm va          → 32 files
```

(`de`, `es`, `nl`, `us-fl` declare gate L0 — the pilot — and are excluded; the
US/CA files declare L2 and the rest L3.)

No §5.3 verification dossier exists anywhere in either repo — the eight
`dossier-l1-*.md` files in `vehiclesdb-pipeline/aux/research/plates-2026-07/`
are the **researcher** half from wave 1 (at be ch fi fr gb it se) and cover
neither the wave-2 microstates nor the verification pass. So the list of L1
files lacking a §5.3 dossier is all 32, and **index 0 is `ad`** on either
reading — whether "lacking a dossier" means lacking any dossier or lacking a
verified one.

**Location convention — arrived at independently, and that is the useful part.**
This dossier was written to `data/review/plates-verify/ad.md` before I knew that a
sibling QA-LOOP-2 session was concurrently landing
`plates/_verification/README.md` + `be.md` in PR #293. Two sessions reached the
same directory, the same `<code>.md` naming and the same reason for Markdown
over YAML (`lint_plates.rb` globs `plates/*.yml` **and** `plates/*/*.yml` and
would lint a `.yml` here as a 125th jurisdiction; `.md` is invisible to it).
**PR #293's README is the convention of record** — this file defers to it and
should be read against its seven-section shape.

**One tension with that README, stated rather than papered over.** Its §6 says
*"The verifier changes no data."* This pass **did** change data: two regexes,
three publication dates, one retracted discrepancy, and a set of notes. The
reconciliation is I-11's own logic — this session is not a pure verifier. It
re-derived (verifier work) and then *originated corrections*, which are new
claims, and new claims are researcher output. So the corrections ship
`awaiting_verification` / `verifier: null` exactly as a researcher's would, and
nothing here is signed. Where a change would have *created or moved a series*
rather than corrected a demonstrably wrong value, this pass stopped and wrote a
recommendation instead — see §6. The maintainer may prefer the stricter reading
in which even the two regex corrections wait for a second signer; that is a
one-command revert of `ad.yml` and loses nothing, because the dossier carries
the full evidence either way.

---

## 1. Method

Every period boundary, format regex, class and colour was re-derived from the
**primary instrument already pinned in the file**, plus **one independent
route**. Two method notes matter for anyone repeating this:

1. **The gazette text was read raw, not through a summariser.** The BOPA blob
   store serves UTF-16LE HTML. Each document was fetched, decoded, tag-stripped
   and read locally, so every Catalan quotation in `ad.yml` and below is a
   byte-for-byte extract. This was not fussiness: an initial summariser pass
   over the same URL returned art. 15's range correctly but paraphrased arts.
   7.1–7.3 into a summary that hid art. 7.5 — the provision that turns out to be
   the only statutory basis for the motorcycle series' `regex_strict`.
2. **A finding was withdrawn during the pass.** I recorded that the 2011
   instrument's "images on the retroreflective ground" clause had been repealed
   in 2022, because it is absent from arts. 6, 7 and 15 of the new Reglament. It
   was not repealed — it was consolidated into art. 5.2 and scoped to white
   retroreflective grounds. It is not reported below. Noted here because a
   verification pass that reports only its successes is not evidence of anything.

### Sources, with exact URLs

| # | Instrument / route | URL |
|---|---|---|
| S1 | Decret 456/2022, del 9-11-2022 — the plate Reglament IN FORCE | https://bopadocuments.blob.core.windows.net/bopa-documents/034135/html/GR20221110_09_12_43.html |
| S2 | Decret del 23-02-2011 — the repealed Reglament | https://bopadocuments.blob.core.windows.net/bopa-documents/023014/html/6BEF6.html |
| S3 | Llei 12/2021, del 13 de maig, Codi de la circulació | https://bopadocuments.blob.core.windows.net/bopa-documents/033062/html/CGL20210528_13_01_20.html |
| S4 | Llei del Codi de la circulació, de 10-6-99 (repealed) | https://bopadocuments.blob.core.windows.net/bopa-documents/011040/html/199A6.html |
| S5 | Llei 24/2014, del 30 d'octubre, plaques personalitzades | https://bopadocuments.blob.core.windows.net/bopa-documents/026067/html/lo26067002.html |
| S6 | Correcció d'errata del 30-11-2022 (BOPA 142/2022) | https://bopadocuments.blob.core.windows.net/bopa-documents/034142/html/GD20221201_12_12_06.html |
| S7 | Correcció d'errata de l'1-3-2023 (BOPA 33/2023) | https://bopadocuments.blob.core.windows.net/bopa-documents/035033/html/GV20230303_12_27_52.html |
| S8 | BOPA sumari núm. 135, any 2022 (gazette date + the title erratum) | https://bopadocuments.blob.core.windows.net/bopa-documents/sumaris/034/034135.pdf |
| S9 | BOPA sumari núm. 142, any 2022 (indexes S6) | https://bopadocuments.blob.core.windows.net/bopa-documents/sumaris/034/034142.pdf |
| S10 | BOPA sumari núm. 62, any 2021 (gazette date of S3) | https://bopadocuments.blob.core.windows.net/bopa-documents/sumaris/033/033062.pdf |
| S11 | BOPA sumari núm. 67, any 2014 (gazette date of S5) | https://bopadocuments.blob.core.windows.net/bopa-documents/sumaris/026/026067.pdf |
| S12 | Annex 1 to the 2011 Reglament — the statutory drawings (cited, never embedded, per PRD-PLATES §6) | https://bopadocuments.blob.core.windows.net/bopa-documents/annexos/023014_plaques.pdf |
| S13 | Automòbil Club d'Andorra — plate concession page | https://aca.ad/serveis/plaques-de-matricula |
| S14 | leslleis.com — independent legal database copy of the decree | https://leslleis.com/DR20221109C |
| S15 | Annex to Decret 456/2022 — advertised path, **404 BlobNotFound** | https://bopadocuments.blob.core.windows.net/bopa-documents/034135/Documents/Plaques%202021_GR20221110_09_12_43.pdf |

---

## 2. Per-series verdicts

`period` = start/end boundary · `format` = pattern + regex · `class` · `colour`.
Verdict vocabulary per PR #293's README §4, with one addition this pass needed:

- **CONFIRMED** (shown `OK` in the grid) — re-derived from the primary
  instrument and matches.
- **DISAGREEMENT** (shown `FLAGGED`) — sources conflict, or the file's value is
  right for part of the period only. Both readings kept verbatim; nothing
  averaged; needs a decision above researcher level.
- **CORRECTED** — the file's value was contradicted outright by the instrument
  it cites, and the data was changed. New claims, so `awaiting_verification`.
- **UNVERIFIABLE** — not reached in this jurisdiction: every claim in `ad.yml`
  resolved to one of the three above.

| series | period | format | class | colour | net |
|---|---|---|---|---|---|
| `ad-standard-letter` | OK | OK | OK | OK | agency-stated 2011 upheld (§3.1) |
| `ad-standard-numeric` | OK | OK | OK | OK | quote truncation fixed (§3.7) |
| `ad-motorcycle` | OK | OK | OK | OK | `regex_strict` now sourced; coverage gap FLAGGED (§3.8) |
| `ad-moped` | OK | OK | OK | **FLAGGED** | legend was black pre-2022 (§3.9) |
| `ad-diplomatic-cmd` | OK | OK | OK | OK | — |
| `ad-diplomatic-cd` | OK | OK | OK | OK | — |
| `ad-consular-cc` | OK | **FLAGGED** | OK | OK | 2 digits pre-2022, 3 from 2022 (§3.5) |
| `ad-diplomatic-staff-a` | OK | OK | OK | OK | Pantone 299 vs 2945 split upheld |
| `ad-temporary-mt` | OK | **FLAGGED** | OK | OK | MT serial-vs-legend dissent (§4.1) |
| `ad-dealer-prova` | OK | **CORRECTED** | OK | OK | `\d{1,3}` → `\d{3}` (§3.3) |
| `ad-historic-failed-itv` | OK | OK | OK | **FLAGGED** | legend was VEHICLE ANTIC pre-2022 (§3.9) |
| `ad-historic-passed-itv` | **FLAGGED** | **CORRECTED** | OK | OK | the headline catch (§3.2) |
| `ad-special-vehicle` | OK | OK | OK | OK | both draft corrections upheld (§5) |
| `ad-snow-vehicle` | OK | OK | OK | OK | — |
| `ad-giny-mecanic` | OK | OK | OK | OK | — |
| `ad-personalized` | **CORRECTED** | **FLAGGED** | OK | OK | 3 missing constraints (§3.6), law-vs-decree (§4.2) |

No series was added, removed or renamed. `plates lint` holds at **124 files,
1381 series** with the `_art` gate green.

---

## 3. Findings

### 3.1 UPHELD — the file's central finding survives, and gets stronger

The draft's most important claim is that the 2011 Decret did **not** create the
lettered format, so `ad-standard-letter` must be dated `agency-stated-date` from
ACA and not `instrument-in-force` from the Decret whose year happens to match.
Re-derivation confirms it on every leg:

- S2 art. 3.2 and S1 art. 6.2 both describe one continuous scheme advancing on
  **exhaustion**, never on a date.
- S2's exposició de motius lists that instrument's actual innovations — the
  reduced plate, plastic/rubber enduro-trial plates, images on the reflective
  ground, and the AND mark. The lettered serial is not among them.
- S13 carries the year, verbatim and still live: *"Des de l'any 2011, les plaques
  de matrícula dels vehicles d'Andorra estan formades per quatre xifres de color
  negre precedides per una lletra sobre fons de color blanc."*

One correction improves it. The draft printed the **2011** wording under a
**2022** attribution and called the re-enactment "verbatim". It is not verbatim,
and the difference runs the file's way: S1 art. 6.2 says *"un grup de cinc
caràcters **numèrics**"* where S2 art. 3.2 said only *"un grup de 5 caràcters"*.
The word the five-digit base-stage claim depends on is in the current instrument
and absent from the old one. Both texts are now carried separately.

### 3.2 CORRECTED — `ad-historic-passed-itv`: a value that matches neither instrument

The headline catch, and the one the §5.3 protocol is written for.

> **S2, art. 12.1 (2011, repealed):** "A les plaques de matrícula s'inscriu un
> grup de 5 caràcters que va des del **58001 final al 99999**."
> (*"final al"* is the instrument's own slip for *"fins al"*.)

> **S1, art. 15.1 (2022, in force):** "A les plaques de matrícula s'hi inscriu un
> grup de cinc caràcters numèrics que va des del **58001 fins al 58999**."

The draft recorded **"58001 to 59999"** with `regex: '\A5[89]\d{3}\z'` — a value
that sits between the two instruments and matches neither. Whatever produced it,
that is the shape PRD-PLATES §5.3 names: *the era boundaries are where sources
disagree … never average them.*

The regex over-accepted 1,001 strings (59000–59999, plus 58000). Corrected to
`'\A58\d{3}\z'`, which carries the block in force; 58000 remains as one string of
documented slack because the pattern DSL cannot express a lower bound.

**Left for the verifier:** the block *narrowed* at the 2022 commencement, so on
the §2.2 rule that a differing format is a differing series, the 2011–2022 wide
block deserves its own ended series and this one should start 2022. That is a
series **addition** — permitted by append-only, but not a call a researcher may
make alone. The period stays at 2011 and is knowingly wider than the format it
now carries, flagged rather than quietly re-cut.

### 3.3 CORRECTED — `ad-dealer-prova`: three characters, not one to three

> **S1, art. 16.1:** "A les plaques de matrícula s'hi inscriu un grup de **tres
> caràcters numèrics** que va des del 000 fins al 999."

`'\A\d{1,3}\z'` → `'\A\d{3}\z'`. The range is written with leading zeros, so
`000` and `007` are forms the block contains and `7` is not. Dated note: the
digit count is a 2022 addition — S2 art. 13.1 said only *"un grup de caràcters
numèrics que van des del 000 fins al 999"*.

### 3.4 CORRECTED — three gazette dates, all off by one, one of them a commencement

A **systematic** defect rather than three coincidences.

| instrument | draft | gazette | evidence |
|---|---|---|---|
| Decret 456/2022 | published 2022-11-15 | **2022-11-16** | S8 page headers (all 13 pages); S7 says "publicat al BOPA núm. 135, del 16 de novembre del 2022" |
| Llei 12/2021 | published 2021-06-01 | **2021-06-02** | S10 page headers ("Núm. 62 / 2 de juny del 2021") |
| Llei 24/2014 | published 2014-11-25 | **2014-11-26** | S11 ("67 Any 26 / 26.11.2014") |

The first one moves a commencement: S1's article únic commences the Reglament
*"l'endemà de ser publicat"*, so the plate regulation in force took effect on
**17 November 2022**, not 16 November.

**And it dissolves a recorded "disagreement".** The draft carried a
`recorded_discrepancy`: BOPA index metadata giving 1 June 2021 against Decret
456/2022's preamble saying *"publicada al BOPA del 2 de juny del 2021"* — "a
one-day disagreement between two official sources, recorded rather than
resolved". There is no disagreement. Both official sources say 2 June; only the
draft said 1 June. The entry is **retracted with evidence** rather than
preserved, because a spurious disagreement left in the record is a permanent
fake uncertainty — the mirror-image failure of averaging a real one.

Worth carrying to the other microstate files from the same wave: three
off-by-ones in one file is a process signal, not a typo.

### 3.5 FLAGGED — `ad-consular-cc` describes only half its own period

> **S2, art. 8 (the second one so numbered):** "el primer grup el formen les
> lletres CC; el segon grup el formen **dos caràcters numèrics** que van des del
> 00 fins al 99"

> **S1, art. 11.2:** "el primer grup el formen les lletres CC (cos consular); el
> segon grup el formen **tres caràcters numèrics** que van des del 000 fins al
> 999"

The series is dated from 2011 and carries the three-digit regex, so a CC plate
issued between 2011 and 16 November 2022 will not match it. Recorded, not
widened — the regex carries the instrument in force, and the clean fix is the
same §2.2 split proposed in §3.2.

*(Incidentally: S2 numbers two consecutive articles "Article 8" — A-staff then
consular — and then resumes at 9. The defect is in the as-published text, was
never fixed by the errata of 9-3-2011, and is now recorded in
`instrument.numbering_defect` so the next reader does not think they misread.)*

### 3.6 CORRECTED — `ad-personalized` was missing three statutory constraints

The draft listed S5 art. 7.1 (a)(b)(c)(g)(h)(i). It omitted:

- **(d)** *"No s'accepten combinacions que coincideixin o puguin coincidir amb
  la numeració de les matrícules ordinàries."* The regex accepts `A0000` —
  precisely the ordinary lettered grammar of S1 art. 6.2 — and `AA000`, its next
  stage. The single most over-accepting case, and forbidden in terms.
- **(f)** *"No s'accepten combinacions que continguin la menció 'AND' i altres
  pròpies de l'Estat o dels poders públics andorrans."*
- **(e)** and **(j)** — discretionary and registry-state rules, unexpressible in
  a regex by nature.

`matching: recall-only` was already correct; these make the declaration honest
about what it is recalling. Commencement also added: S5's disposició final
segona gives *"al cap d'un mes de ser publicada"* → **26 December 2014**, so the
2014 start rests on the last six days of that year.

### 3.7 CORRECTED — a quote truncated where it stopped helping

The draft cites S4 art. 147 for *"Aquest Codi inclou el catàleg de plaques de
matrícula vigents a Andorra."* The **attribution is correct** — I initially
filed this as a misattribution and was wrong; the sentence is the penultimate
paragraph of art. 147, which runs to the "Article 148" heading.

But the sentence does not end there:

> "…vigents a Andorra. **No obstant això, el Govern pot modificar o afegir altres
> modalitats de matrícula, d'acord amb la disposició addicional primera.**"

The omitted half is the **delegation**, and it is load-bearing: it is the
mechanism by which a 2011 Govern decree could lawfully add plate types while the
1999 Codi was in force, and S2's preamble relies on it by name — *"El legislador
… va atribuir al Govern mitjançant l'article 147 i la disposició addicional de
la llei, la capacitat de modificar les plaques de matrícula incloses en el
catàleg o afegir-hi altres modalitats."* The `instrument-in-force-upper-bound`
dating of every 2011 series in this file depends on that delegation being real,
so quoting only the first half understated the file's own foundation.

### 3.8 FLAGGED — a coverage gap: five-digit motorcycle plates match nothing

> **S1, art. 7.3:** "A la placa horitzontal s'hi inscriu un grup de cinc
> caràcters numèrics que va des del 00000 fins al 99999 i, a continuació, la
> primera xifra se substitueix per una lletra…"

Motorcycles run the same two-stage scheme as cars. `ad-motorcycle` models only
the lettered stage; `ad-standard-numeric` models the five-digit stage but lists
`categories: [car, van, truck, bus, trailer, semitrailer]` — motorcycle absent.
So a five-digit Andorran motorcycle plate is matched by **no series in this
file**: a jurisdiction-completeness miss under PRD-PLATES §5.1. Fix is one word
or one new ended series; both are claim changes, so both are proposed rather
than taken.

Also on this series: `regex_strict` carried the 23-letter alphabet with no source
of its own, and borrowing art. 6.3's would have been an inference — that
exclusion is drafted narrowly for the ordinary and reduced car plates and does
not mention motorcycles. It turns out motorcycles have **their own** exclusion,
S1 art. 7.5: *"Se suprimeixen les lletres I, O i Q del sistema de numeració de
les plaques horitzontal i vertical de matrícula ordinària per a motocicleta…"*
The twin is statutory after all; it is now cited as such.

### 3.9 FLAGGED — dated design drift (recorded, **not** edited)

Four design facts in the file are the *current* spec attached to a period that
starts in 2011. Colours and legends are the owner's visual lane, so these are
recorded in the YAML and listed here, and no `design:` block was touched.

| series | 2011 (S2) | 2022 (S1) | file carries |
|---|---|---|---|
| `ad-moped` | legend ANDORRA in **black** on yellow (art. 5.1) | **blue** on yellow (art. 8.1) | blue |
| `ad-historic-failed-itv` | legend **VEHICLE ANTIC** (art. 11.1) | **VEHICLE HISTÒRIC** (art. 14.1) | VEHICLE HISTÒRIC |
| `ad-special-vehicle` | **VEHICLES ESPECIALS** (art. 14.1) | **VEHICLE ESPECIAL** (art. 17.1) | singular |
| `ad-snow-vehicle` | **MOTOS DE NEU** (art. 15.1) | **MOTO DE NEU** (art. 18.1) | singular |

Also dated: the **plastic/rubber enduro-trial base** is historic. S2 art. 1 ¶2
allowed it; S1 art. 4 does not re-enact it (aluminium as norm, adhesive for art.
25 cases, nothing else). The file described it in the present tense.

### 3.10 NEW — the AND mark's scope, which predicts the whole catalogue

S2's preamble closes the AND paragraph: *"Aquesta modificació sols s'aplica a les
matrícules destinades a vehicles que són **aptes per a la circulació
internacional**."* That one sentence predicts exactly which series carry AND —
ordinary (art. 6.1), motorcycle (7.2, 7.4), the four diplomatic/consular series
(9–12) and MT (13) — and which do not: moped (8), both historic (14–15), PROVA
(16), special (17), snowmobile (18), giny mecànic (19). Every omission is a
vehicle that does not travel internationally. The design blocks already matched
this pattern; it was inferred there and is now sourced.

### 3.11 NEW — a sourced negative the draft missed

S1 art. 15.3: *"La placa de matrícula per als ciclomotors que es registrin com a
vehicles històrics és la mateixa que la placa de matrícula ordinària per als
ciclomotors."* A historic moped is in `ad-moped`, not in either historic series.
No new series warranted — the instrument says the plate is the same one.

### 3.12 NEW — Andorra claims property in the plate characters and state symbols

The finding with reach beyond this file.

> **S3, Llei 12/2021 art. 108(3):** "Els caràcters que figuren en les matrícules,
> així com els símbols d'Estat que han de portar els vehicles, són **propietat
> del Govern**, que cedeix en cada cas el dret a usar-los, d'acord amb les
> condicions que es determinin per la via reglamentària."

> **S1, Decret 456/2022 art. 3.5:** "Els caràcters que figuren en les matrícules,
> i els símbols d'Estat que han de portar els vehicles, són **propietat del
> Govern**, que cedeix en cada cas el dret a usar-los…"

Two instruments, one in a law and one in a decree. PRD-PLATES §6 records — from
the EU dossier, and expressly as a **sample** finding — that *"No surveyed
country claims copyright in the plate design itself."* Andorra is a
counter-example to that sample and should be carried back into §6 as one. It is
the same shape of fact that `artwork_risk:` exists to record for US states under
§7.1: an adverse statutory signal sitting beside an art route that looks clean
(`plates/_art/ad/` holds a PD-verified Commons coat of arms).

**Read narrowly.** These provisions assert ownership of the characters *as they
appear on matrícules* and of the state symbols vehicles must carry, and set up
case-by-case licensing. They are not a copyright registration, they say nothing
about the underlying historic coat of arms, and Andorran law was not searched
here for what *"propietat del Govern"* grants against a third party. What they do
establish is that the "no country claims the design" line cannot be repeated for
Andorra unqualified.

**Recorded and escalated, not acted on.** `common.emblem` and every `design:`
block are untouched — the emblem posture is the owner's visual lane and the
licensing question is counsel's, not a verifier's. The §3 placeholder default
ships either way, so nothing renders differently today.

### 3.13 The two errata, and a sourcing caveat with teeth

- **S6 (30-11-2022)** corrects arts. 3.6 and 4.2 from *"l'article 24 del
  Reglament"* to *"l'article 25"* — the adhesive-plate article is 25; 24 is
  Reserva de matrícula ordinària. No series affected.
- **S7 (1-3-2023)** is more interesting. The draft recorded that *"BOPA's own
  sumari mistypes this decree as 'Decret 456/2011, del 9-11-2022'"* and reasoned
  that *"the document header reads 456/2022"*. **It did not.** S7 quotes the
  published title under *"On hi diu:"* as **"Decret 456/2011, del 9-11-2022…"*
  and prescribes **"Decret 456/2022"** under *"Hi ha de dir:"*. The wrong year
  was in the instrument's own title; the sumari (S8, confirmed verbatim)
  reproduced it; and the citation is now settled **by an instrument** rather than
  by inference. Third-party databases still carry the uncorrected form — S14
  prints "Decret 456/2011, del 9 de novembre del 2022" today — which is the
  practical reason to keep the note.
- **Caveat with teeth:** the pinned URL (S1) serves the **as-published** text and
  therefore still prints the two errors S6 fixed. Anyone reading S1 alone is
  reading text the Govern has formally amended.

### 3.14 The annex gap — narrowed, not closed

- The **2011** annex is live: S12, a 1.83 MB 15-page PDF, figure pairs 1a/1b
  through 14a/14b (4 split 4.1/4.2), one pair per plate type. It is **pure vector
  graphics** — text extraction returns only running heads and captions — so the
  draft's characterisation is confirmed for content and corrected for
  availability. Cited, never embedded (PRD-PLATES §6).
- The **2022** annex is **not published at its own link**: S15 returns
  `BlobNotFound` / HTTP 404. A searched-for negative, with the exact URL tried.
- This matters more than a missing picture: S1 art. 21 makes the annex normative
  for the glyphs — *"Les especificacions de les plaques de matrícula i dels
  distintius…, els colors i els caràcters alfabètics i numèrics són els que
  s'indiquen en l'annex del Reglament."* The character shapes are in the
  unreachable annex, which is why `common.font.name` correctly stays `null` and
  the §6 schematic fallback correctly applies.

---

## 4. Disagreements recorded verbatim, resolved by nobody

Per PRD-PLATES §5.3. Neither is averaged; neither is silently picked.

### 4.1 Is "MT" part of the serial, or a legend?

**Route A — the plate regulation treats it as furniture.** S1 art. 13.1 puts MT
in a panel and states the serial separately: *"Al costat esquerre superior, sobre
fons vermell (fons Pantone 485), hi figuren els caràcters MT de color negre mat.
[…] A les plaques de matrícula s'hi inscriu un grup de quatre caràcters numèrics
que va des del 0000 fins al 9999."* That is the **same two-part shape** art. 16.1
uses for PROVA — legend in one sentence, *"un grup de N caràcters numèrics"* in
another — and this file reads art. 16 as making PROVA a legend. Applied
consistently, MT is a legend and the serial is four bare digits.

**Route B — the personalisation statute treats it as a prefix.** S5 art. 7.1(i)
forbids a personalised mark consisting of *"les lletres 'MT', 'CD', 'CMD', 'A',
'CC', seguides de xifres o la paraula 'PROVA'"* — grouping MT with the
unambiguous diplomatic prefixes and setting PROVA apart as *"la paraula"*. This
is the draft's basis and it is real.

**Data unchanged, and why.** Keeping MT in `regex` costs nothing under §2.7 (it
is narrower than the issuing grammar, never wider) and buys discrimination four
bare digits cannot: dropping it would collide this series with
`ad-special-vehicle`, `ad-snow-vehicle` and `ad-giny-mecanic`, all `'\A\d{4}\z'`.
The disagreement is a reading of two instruments, not a fact either states.

### 4.2 Which vehicles may carry a personalised plate?

**S5 art. 3.1 (the law)** admits four categories: *"a) Categoria 'L' […] amb
excepció dels de la categoria 'L1' (ciclomotors). b) Categoria 'M' […] c)
Categoria 'N' o la que correspongui a vehicles de motor destinats al transport de
mercaderies […] d) Categoria 'O' o la que correspongui a remolcs i
semiremolcs."* — motorcycles, cars, **goods vehicles and trailers**.

**S1 art. 26.1 (the decree)** is narrower: the personalised mark *"s'aplica a la
placa de matrícula ordinària i a la placa de matrícula ordinària reduïda dels
vehicles automòbils, així com a la placa de matrícula ordinària de les
motocicletes"* — cars and motorcycles only.

The series lists `[car, van, motorcycle]`, following the decree. A law outranks a
decree, so the wider list is probably right — but "probably" is not the standard,
the decree is the instrument the rest of this file is built on, and **majority is
not authority** cuts against quietly picking one. Left as-is, recorded in full.

---

## 5. What the pass upheld

Verification that only reports defects mis-states the file's quality. `ad.yml`
is a strong piece of work and most of it re-derives cleanly:

- **All four diplomatic/consular grammars exact** (S1 arts. 9–12): CMD + 1 digit,
  CD + 2, CC + 3, A + 2, each closing with the state letter assigned by the
  foreign ministry. The Pantone 2945 / 299 split by rank is real and statutory.
- **Both of the draft's corrections to the secondary record on
  `ad-special-vehicle` are upheld** on raw text: *"El fons de les plaques és
  retroreflector, de color blanc"* (white, not sky blue) and *"un grup de quatre
  caràcters numèrics"* (four digits, not three).
- **The absence of `regex_strict` on `ad-historic-failed-itv` is correct and
  deliberate** — S1 art. 14.2 says only *"sense utilitzar les lletres de
  l'alfabet que puguin crear confusió"* and, unlike arts. 6.3 and 7.5, never
  names I, O and Q. An enumerated twin there would be inference dressed as
  statute. The pass confirms the restraint rather than "fixing" it.
- **The `not_modelled` refusals all hold**, including the sourced negative on
  electric plates (S3 disposició final setena puts the ZERO/ECO classification on
  a windscreen sticker, quoted exactly) and the refusal to invent the pre-1999
  "AND + four digits" series.
- **The chain is confirmed by the repealing instrument itself.** S1's disposició
  derogatòria primera names the 2011 base decree, the errata of 9-3-2011, the
  Decret of 27-7-2011 *"pel qual s'aprova la modificació dels articles 12 i 17, i
  d'addició de l'article 19"* and the Decret of 10-12-2014 — matching the draft's
  `chain` exactly, including the parenthetical about arts. 12/17/19.
- **Every Llei 12/2021 quotation is verbatim-accurate**, including art. 108(1),
  disposició final novena and the ZERO/ECO passage.
- **`region_encoding: none` is right.** Nothing in any instrument encodes the
  seven parròquies.
- **The Vienna Convention lead is accurate** and the PRD-PLATES §4 caution
  stands: S2's preamble relies on Annex 3 point 3 in the 2006 consolidated
  version by name, which corroborates the amendment's existence without being it.

Two small additions to the chain and repeal record: S1's disposició derogatòria
**segona** also repeals the Decret of 24-11-2010 on mark reservation (added —
it is where the `binding` question moved from), and the Llei 12/2021 repeal of
the 1999 Codi is **not total**, carving out art. 209 until the pleasure-boat
reglament commences (not plate-related, but "repealed the 1999 Codi" is not the
whole sentence).

---

## 6. Action list for the verifier and the maintainer

**Needs a second signer before it can be called verified (I-11):** everything
above, including the corrections.

**Needs a decision above researcher level:**

1. **§2.2 series splits** for `ad-historic-passed-itv` (block narrowed
   58001–99999 → 58001–58999 in 2022) and `ad-consular-cc` (CC + 2 digits →
   CC + 3 digits in 2022). Both are series *additions*; append-only permits
   them, I-11 forbids me from signing them.
2. **The five-digit motorcycle gap** (§3.8) — add `motorcycle` to
   `ad-standard-numeric.categories`, or open an ended series.
3. **`binding` at series scope.** PRD-PLATES §2.1 puts `binding` at file scope;
   Andorra needs both values. An Andorran personalised vehicle holds **two**
   marks — one bound to the vehicle (S1 art. 24.2: *"Queda totalment prohibit
   cedir una matrícula"*) and one bound to its owner (S5 art. 6.3: *"caràcter
   personal i intransferible… Únicament s'exceptua la transmissió de la matrícula
   per successió"*, with S1 art. 26.5 contemplating *"afectació a un altre
   vehicle"*). Proposal only.
4. **PRD-PLATES §6 amendment** — Andorra is a counter-example to the "no country
   claims the design" sample finding (§3.12). Also worth a counsel note.
5. **Sweep the other wave-2 microstates for the off-by-one gazette dates**
   (§3.4). Three in one file is a process signal.
6. **Design drift** (§3.9) — four legend/colour facts are current-spec attached
   to 2011-start periods. Owner's visual lane; untouched here.

---

## 7. Reproducing this

```bash
# the gazette serves UTF-16LE HTML; decode before reading, and never trust a
# summariser with a statutory number
curl -sSL -o d456.html \
  "https://bopadocuments.blob.core.windows.net/bopa-documents/034135/html/GR20221110_09_12_43.html"
ruby -rcgi -e 'raw=File.binread("d456.html")
  enc = raw[0,2]=="\xFF\xFE".b ? "UTF-16LE" : "UTF-8"
  t=raw.force_encoding(enc).encode("UTF-8",invalid: :replace,undef: :replace)
  t=t.gsub(%r{<(script|style)[^>]*>.*?</\1>}mi,"").gsub(%r{<br\s*/?>}i,"\n")
     .gsub(%r{</(p|div|tr|li|h[1-6])>}i,"\n").gsub(/<[^>]+>/,"")
  puts CGI.unescapeHTML(t).gsub(/ /," ").split("\n").map(&:strip).reject(&:empty?)'

# BOPA folder numbering is `any = year - 1988`; sumaris carry the gazette DATE
# in every page header, which is the only reliable source for it
curl -sSL -o s135.pdf \
  "https://bopadocuments.blob.core.windows.net/bopa-documents/sumaris/034/034135.pdf"
pdftotext -layout s135.pdf - | head -1
```

Gates, before and after — unchanged:

```
plates lint: 124 files, 1381 series
plates lint: matching recall-only=286 strict=1095 | twins regex_statutory=106 regex_strict=427 | separators emitted "-"," " forgiving 18
plates lint: _art ledger 6060 rows (excluded=5355 open=412 site_only=293), 412 open assets verified
plates lint: OK
curation lint: OK (109 files, duplicate-key + shape + make-key + provenance)
```
