# Belgium — PRD-PLATES § 5.3 verification dossier

|                |                                                                     |
|----------------|---------------------------------------------------------------------|
| jurisdiction   | `be` — `plates/be.yml`, 33 series                                    |
| gate           | L1 (EU/EEA + UK + CH), wave 1 — landed as `data#218–#225`             |
| protocol       | PRD-PLATES § 5.3; claims model § 5.1; lint gate § 5.2                 |
| researcher     | L1 wave-1 agent, 2026-08-02 (`pipeline aux/research/plates-2026-07/dossier-l1-be.md`) |
| verifier       | this pass — QA-LOOP-2, 2026-08-08                                    |
| **status**     | **`awaiting_verification`** — see *I-11 posture* below                |
| second signer  | `null`                                                                |
| data changed   | **none.** The verifier re-derives and records; the maintainer applies. |

## Why Belgium, and not some other jurisdiction

The unit was selected deterministically, not chosen. The L1 slice is
PRD-PLATES § 7's "EU/EEA + UK + CH … ~35 jurisdictions", which resolves
against `plates/` to exactly 35 files (Bulgaria has no `bg.yml`; the count
matches the 35 that `PLATES-PROGRAM-STATE.md` reports as "EU/EEA complete").
No § 5.3 verification dossier existed for any of them — § 7.2 states the
position outright: "the § 5.3 HUMAN verification pass is outstanding for both
waves" — so the list of L1 files lacking a dossier is all 35, sorted:

```
ad at be ch cy cz de dk ee es fi fr gb gr hr hu ie is it li lt lu lv
mc mt nl no pl pt ro se si sk sm va
```

Index 2 (zero-based, the program's convention) is **`be`**. The choice is
stable under the narrower reading that excludes the L0 pilot (`nl es de`):
that list begins `ad at be …` and index 2 is `be` either way.

## I-11 posture

Invariant I-11 forbids one session signing both roles. This pass is the
**independent verifier** against a researcher dossier that already exists and
that I did not write. Where a finding below merely *tests* a researcher claim,
the verification is complete. Where a finding **originates** a claim the
researcher did not make — F-1's resolution of the entry-into-force question is
the only one — it ships as researcher-only: `verifier: null`,
`status: awaiting_verification`, and it must be signed by a second party
before any data moves on it.

---

## METHOD — independence

I re-derived the period spine and the inscription grammar from the statutory
text **before** reading the researcher's dossier prose, then compared. The
comparison changed nothing in my verdicts and is not padded to look as though
it did.

### Routes read

| # | route | what it is | why it is independent |
|---|---|---|---|
| R1 | `ejustice.just.fgov.be` Justel, **French** consolidated | the state's own consolidation — the route already pinned in `be.yml` | the primary. Not independent of the file; it is the file's own source |
| R2 | `ejustice.just.fgov.be` Justel, **Dutch** consolidated | the co-equal authentic text | Belgian instruments are authentic in both languages. A claim that survives both is not a translation or OCR artefact of one |
| R3 | `etaamb.openjustice.be` | independent republisher of the *Moniteur belge* **as published** | carries the ORIGINAL text, not the consolidation — the only route that can show what an article said before it was amended |
| R4 | `mobilit.belgium.be` (DIV) | the **issuing authority's** own public pages | administrative, not legislative. Confirms what is actually issued rather than what is permitted |
| R5 | local re-implementation | `verify_be.rb`, written from the PRD, not from `scripts/lint_plates.rb` | a second implementation of the regex-tier, RAL/hex and cross-series-ambiguity checks |

R3 is the route that broke the case open. R1 alone cannot answer an
entry-into-force question, because Justel's *header* field is not recomputed
when the entry-into-force *article* is later amended — see F-1.

### Rules binding me

- **Fetch, never assume.** Every date below is quoted from an instrument.
- **MAJORITY IS NOT AUTHORITY.** Three routes carrying one date does not beat
  one instrument carrying another.
- **Never average.** Where two dates are both primary, both are recorded and
  neither is split.
- **The fact stays OUT.** Where the statute imposes no constraint, I do not
  invent one to make the model tidier — see F-4.
- I wrote nothing into `plates/be.yml`.

---

## PART 1 — the instrument chain, re-derived

Every period boundary in `be.yml` traces to one of five dates. All five were
re-derived from the entry-into-force article of the instrument that fixes
them, not from a summary.

| boundary | instrument | entry-into-force article, verbatim | verdict |
|---|---|---|---|
| **01-10-2001** | AR 20-07-2001, NUMAC 2001014153, M.B. 08-08-2001 p. 27022 | art. 37 — Justel header "Entrée en vigueur : 1 octobre 2001" | CONFIRMED |
| **15-11-2010** | AR 06-11-2010 **and** AM 08-11-2010, NUMAC 2010014234, M.B. 12-11-2010 | AM art. 16: *"Le présent arrêté entre en vigueur le 15 novembre 2010."* | CONFIRMED — stated twice, in identical words, by the royal and the ministerial instrument |
| **31-03-2014** | AM 23-03-2014 (moped chapter) and AM 28-03-2014, NUMAC 2014014171, M.B. 07-04-2014 | AM 28-03-2014 art. 9: *"Le présent arrêté entre en vigueur le 31 mars 2014"* | CONFIRMED |
| **01-01-2021** | AM 15-12-2019, NUMAC 2020040939, M.B. 15-05-2020 | **contested — see F-1** | DISAGREEMENT |
| **01-01-2023** | AM 21-10-2022, NUMAC 2022033709, M.B. 22-12-2022 | in force 1 January 2023 | CONFIRMED |

The 2001, 2010, 2014 and 2023 boundaries are clean on every route. The file's
own header claim — that the 2010 date is corroborated twice — is true, and I
verified both limbs rather than taking the pair on trust.

---

## PART 2 — per-series verdicts

33 series × four claim axes (period, format, class, colours). Colours were
verified per-article against the RAL code the statute names, and the RAL→hex
mapping was checked for consistency across the whole file (R5, check 3):
`RAL 3003 → #9B111E`, `RAL 3020 → #CC0605`, `RAL 6005 → #114232`,
`RAL 6029 → #007243` — each RAL code maps to exactly one hex everywhere it
appears. No inconsistency.

| # | series id | class | period | period | format | colours |
|---|---|---|---|---|---|---|
| 0 | `be-standard-2010` | standard | 2010–open | ✔ | ✔ | ✔ |
| 1 | `be-trailer-q-2021` | trailer | 2021–open | ✔ | ✔ | ✔ |
| 2 | `be-taxi-t-2021` | taxi | 2021–open | ✔ | ✔ **exemplary** | ✔ |
| 3 | `be-historic-o-2021` | historic | 2021–open | ✔ | ✔ (F-4) | ✔ |
| 4 | `be-historic-o-moto-2021` | historic | 2021–open | ✔ | ✔ (F-4) | ✔ |
| 5 | `be-motorcycle-m-2021` | motorcycle | 2021–open | ✔ | ✔ | ✔ |
| 6 | `be-moped-s-2014` | moped | 2014–open | ✔ | ✔ | ✔ |
| 7 | `be-agricultural-g-2020` | agricultural | **2020**–open | **F-1** | ✔ | ✔ |
| 8 | `be-national-u-2021` | temporary | 2021–open | ✔ | ✔ | ✔ |
| 9 | `be-dealer-marchand-z-2021` | dealer | 2021–open | ✔ | ✔ (F-3) | ✔ |
| 10 | `be-dealer-essai-y-2021` | dealer | 2021–open | ✔ | ✔ (F-3) | ✔ |
| 11 | `be-dealer-professionnelle-v-2021` | dealer | 2021–open | ✔ | ✔ (F-3) | ✔ |
| 12 | `be-temporary-w-2021` | temporary | 2021–open | ✔ | ✔ (F-3) | ✔ |
| 13 | `be-export-x-2021` | export | 2021–open | ✔ | ✔ (F-3) | ✔ |
| 14 | `be-international-2021` | temporary | 2021–open | ✔ | ✔ (F-2) | ✔ |
| 15 | `be-diplomatic-cd-2010` | diplomatic | 2010–open | ✔ | ✔ | ✔ |
| 16 | `be-supplementary-court` | government | 2001–open | ✔ | ✔ | ✔ |
| 17 | `be-supplementary-aep` | government | 2001–open | ✔ | ✔ | ✔ |
| 18 | `be-personalized-2014` | personalized | 2014–open | ✔ | ✔ recall-only | ✔ |
| 19 | `be-motorcycle-2010` | motorcycle | 2010–2020 | ✔ | ✔ | ✔ |
| 20 | `be-historic-2010` | historic | 2014–2020 | ✔ | ✔ | ✔ |
| 21 | `be-trailer-2010` | trailer | 2014–2020 | ✔ | ✔ | ✔ |
| 22 | `be-taxi-2010` | taxi | 2010–2020 | ✔ | ✔ | ✔ |
| 23 | `be-commercial-2010` | dealer | 2010–2020 | ✔ | ✔ | ✔ RAL 6029 |
| 24 | `be-temporary-2010` | temporary | 2010–2020 | ✔ | ✔ | ✔ |
| 25 | `be-international-2010` | temporary | 2010–2020 | ✔ | ✔ | ✔ |
| 26 | `be-standard-2001` | standard | 2001–2010 | ✔ | ✔ | ✔ |
| 27 | `be-trailer-2001` | trailer | 2001–2010 | ✔ | ✔ | ✔ |
| 28 | `be-motorcycle-2001` | motorcycle | 2001–2010 | ✔ | ✔ | ✔ |
| 29 | `be-historic-2001` | historic | 2001–2010 | ✔ | ✔ | ✔ |
| 30 | `be-diplomatic-2001` | diplomatic | 2001–2010 | ✔ | ✔ | ✔ two-colour |
| 31 | `be-commercial-2001` | dealer | 2001–2010 | ✔ | ✔ | ✔ |
| 32 | `be-temporary-2001` | temporary | 2001–2010 | ✔ | ✔ | ✔ |

**Totals: 132 claims tested. 131 CONFIRMED, 1 DISAGREEMENT (F-1). Zero
unverifiable. Class: all 33 in the `_meta/classes.yml` vocabulary; the two
class caveats the researcher flagged (`be-national-u-2021` temporary-vs-dealer,
`be-agricultural-g-2020`'s fiscal rather than agronomic criterion) are both
correctly reasoned and I uphold them as recorded.**

### Format grammar re-derived verbatim

Quoted from R1 and cross-read on R2. These are the statutory sentences the
regexes must encode; every one matches what `be.yml` carries.

- **art. 4 § 1** — *"La marque d'immatriculation ordinaire a un fond blanc.
  L'inscription et le liseré sont de couleur rouge rubis (RAL 3003)."*
- **art. 4 § 2** (composition) — *"…d'une lettre ou d'un chiffre (index) suivi
  d'un tiret de séparation situé sur la ligne médiane horizontale de la marque
  d'immatriculation et d'une combinaison de soit trois lettres suivies de
  trois chiffres ou soit trois chiffres suivis de trois lettres."*
  NL: *"een (index)letter of -cijfer, gevolgd door een scheidingsstreepje ter
  hoogte van de horizontale middellijn"*.
- **exhaustion rule** — *"En cas d'épuisement de ces séries, la lettre ou le
  chiffre (index) est placé(e) derrière."* NL: *"In geval van uitputting van
  deze reeksen wordt de (index)letter of het (index)cijfer achteraan
  geplaatst."* Correctly carried in `regex_statutory` and correctly **kept out
  of `regex`**, because it is not issued.
- **art. 4 § 4** (taxi) — *"Pour ce qui est de la catégorie 'service de taxi
  autorisé', le groupe de lettres commence par un 'X' et pour la catégorie
  'location avec chauffeur', le groupe de lettres commence par un 'L'."*
- **art. 5 § 1** — *"Les marques d'immatriculation temporaires de courte durée
  ont un fond rouge signalisation (RAL 3020). L'inscription et le liseré sont
  blancs."*
- **art. 5 § 4** (W / X) — *"la première lettre 'W' est suivie d'une deuxième
  lettre à l'exclusion des lettres 'M', 'Q' et 'S'; … la première lettre 'X'
  est suivie d'une deuxième lettre à l'exclusion des lettres 'M', 'Q' et
  'S'."*
- **art. 8 § 3** (Y / Z / V) — *"la plaque essai : la première lettre 'Y' est
  suivie d'une combinaison de trois lettres dont la première lettre ne doit
  pas être la lettre 'M' et 'S'; la plaque marchand : la première lettre 'Z'
  … ; la plaque professionnelle : la première lettre 'V' …"*
- **art. 9 § 2** (G) — *"la lettre 'G' est suivie d'un tiret …, de la lettre
  'L'"*.
- **art. 10 § 1 / § 3** (U) — *"L'inscription et le liseré sont de couleur
  vert mousse (RAL 6005)."* / *"la première lettre est la lettre 'U' suivie
  d'une deuxième lettre."*
- **art. 12 § 3** (historic motorcycle) — *"Les séries de lettres commencent
  par un 'M'."*
- **art. 19 § 3** (historic moped) — *"Pour les cyclomoteurs, les séries de
  lettres commencent avec la lettre 'S'."*
- **dimensions** — 520 × 110, 340 × 210, 210 × 140, 100 × 120 mm, confirmed on
  R1, R2 **and** R4 (DIV: *"Plaque rectangulaire (52 x 11 cm)"*, *"Plaque de
  format carré (34 x 21 cm)"*, *"Plaque de format moto (21x14 cm)"*, *"Plaque
  format cyclo (10x12 cm)"* — and DIV adds *"Ce format est obligatoire pour
  les cyclomoteurs, speed-pedelecs et quadricycles légers"*).

### Mechanical re-derivation (R5)

Run against `plates/be.yml`, 33 series:

```
1. regex compile/anchor/round-trip:              OK
2. tier order strict <= regex <= statutory:      OK
3. RAL -> hex mapping:                           1:1 for all four RAL codes
5. cross-series ambiguity among 19 OPEN series:  20 pairs (18 = recall-only, by design; 2 real — F-2, F-4)
6. class vocabulary / sources / period_evidence: 33/33 present and valid
```

---

## PART 3 — disagreements, recorded verbatim and NOT averaged

### F-1 — the 2019 instrument's entry into force. **Two primary dates. The file uses both.**

This is the Belgian analogue of the Spanish 2000 cutover, and it is a live
defect rather than a curiosity, because `be.yml` applies **two different dates
drawn from one instrument**.

Thirteen series in the file derive from the **arrêté ministériel du 15
décembre 2019** (NUMAC 2020040939, M.B. 15-05-2020), which replaced articles
1–18 of the 2001 arrêté ministériel wholesale and created the whole G3
letter-index regime (O, Q, T, M, S, G, U, V, Y, Z, W, X).

**Reading A — the text as published (route R3, etaamb):**

> art. 5: *"Le présent arrêté entre en vigueur le 1er octobre 2020."*

**Reading B — the text as consolidated (route R1, Justel):**

> art. 5: *"Le présent arrêté entre en vigueur le [1 1er janvier 2021]1"*
> footnote: *"(1)<AM 2020-10-12/05, art. 1, 002; En vigueur : 16-10-2020>"*

The amending instrument, read directly, settles what happened but not which
date is operative:

> **AM 12 octobre 2020**, NUMAC 2020043081, M.B. 16-10-2020, art. 1, verbatim:
> *"A l'article 5 de l'arrêté ministériel du 15 décembre 2019 modifiant
> l'arrêté ministériel du 23 juillet 2001 relatif à l'immatriculation de
> véhicules, les mots « 1er octobre 2020 » sont remplacés par les mots
> « 1er janvier 2021 »."*
> art. 2: *"Le présent arrêté entre en vigueur le jour de sa publication au
> Moniteur belge."* — i.e. **16 October 2020**.

**The irreducible problem, stated and not resolved:** the postponement took
effect on 16 October 2020, *fifteen days after* the date it postponed. On its
face the 2019 arrêté was in force from 1 to 15 October 2020, and was then
sent forward to 1 January 2021. Both of the following are defensible on
primary text alone:

- **A.** The G3 formats were legally issuable from **01-10-2020**. `period.start`
  = 2020 for all thirteen G3 series.
- **B.** The consolidated text — the state's own current statement of the law —
  reads 1 January 2021, and that is the operative date. `period.start` = 2021
  for all thirteen.

**Not averaged, not split, and not resolved here.** What *is* dispositive is
narrower and does not require choosing: **the file cannot hold both.** It
currently gives `be-agricultural-g-2020` `period.start: 2020` while its twelve
siblings from the identical instrument carry 2021.

**Root cause, identified.** The `be-agricultural-g-2020` source line reads
"art. 2 of the 2019 instrument, which the Justel footnote dates in force
01-10-2020". That date is not from a footnote and not from any article — it is
Justel's **header** field, `Entrée en vigueur : 01-10-2020`, which still shows
the original date because Justel does not recompute the header when the
entry-into-force *article* is itself amended. It is a database artefact, and
it is the only place in `be.yml` where a period claim rests on one.

**Third route.** R4 (DIV) describes the current regime without dating its
commencement, so it neither supports nor refutes either reading. Recorded as
silent rather than as agreement.

### F-2 — `be-international-2021` is not distinguishable from `be-standard-2010`. CONFIRMED AS TRUE.

R5 flagged `7-WFF-619` as accepted by both. This is not a modelling error: art.
6 alinéa 2 makes the long-duration temporary plate take the ordinary
inscription — *"les dispositions de l'article 4, § 1er, points 1° et 2° de cet
arrêté sont d'application"* — and the researcher recorded exactly that, as a
negative finding, in the series notes. **Upheld.** The 2010–2020 predecessor
was distinguishable (index digit 8, AM 08-11-2010 art. 5), and the file
correctly models the loss of that capability on 01-01-2021. This is a
capability regression in Belgian law, faithfully represented.

### F-3 — five sourced letter constraints are documented in prose but not expressed in `regex_strict`. Completeness gap, not an error.

| series | statutory constraint (verified verbatim) | `regex_strict` |
|---|---|---|
| `be-dealer-essai-y-2021` | art. 8 § 3, 1° — group's first letter ≠ M, ≠ S | absent |
| `be-dealer-marchand-z-2021` | art. 8 § 3, 2° — same | absent |
| `be-dealer-professionnelle-v-2021` | art. 8 § 3, 3° — same | absent |
| `be-temporary-w-2021` | art. 5 § 4 — second letter excludes M, Q, S | absent |
| `be-export-x-2021` | art. 5 § 4 — second letter excludes M, Q, S | absent |

Each constraint *is* recorded, accurately and with the quotation, in
`format.charset.notes`. Nothing is wrong; the narrowing is simply not machine
-readable, so a consumer using the tier ladder gets a looser bound than the
statute supports. `be-taxi-t-2021` shows the house style done right —
`\AT-[XL][A-Z]{2}-\d{3}\z` — as do `be-historic-o-moto-2021`
(`\AO-M[A-Z]{2}[- ]\d{3}\z`), `be-moped-s-2014` and `be-agricultural-g-2020`.
Recommendation only; § 2.7's tier order is respected either way and I verified
the ladder holds on every series that has one (R5, check 2).

### F-4 — `O-Mxx-999` is genuinely ambiguous in Belgian law. The fact stays OUT.

R5 flagged `be-historic-o-2021` and `be-historic-o-moto-2021` as both
accepting `O-IFP-670`. The tempting fix — exclude `M` from the car series'
letter group — would be **fabrication**. I read art. 4 § 2 in full on both R1
and R2 for exactly this question:

> *"Sauf lorsqu'une marque d'immatriculation a été réservée conformément à
> l'article 23 de l'arrêté royal du 20 juillet 2001 …, les marques
> d'immatriculation avec lettre (index) 'O' peuvent être délivrées lors de
> l'immatriculation ou de la réimmatriculation des véhicules automobiles mis
> en circulation depuis plus de trente ans."*

There is no letter-group constraint. Art. 12 § 3 constrains the *motorcycle*
series to `M` and art. 19 § 3 the *moped* series to `S`, but neither reserves
those letters against the car series. An `O-M__-___` string is therefore
lawfully either, and the two are separated only by the physical plate —
520 × 110 mm versus 210 × 140 mm stacked. The data is correct as it stands;
what is missing is only that the file says so for F-2 and does not say so
here.

---

## PART 4 — recommendations to the maintainer

The verifier changes no data. In § 5.3 order of severity:

1. **F-1 — resolve the 2019 entry-into-force date to ONE value across all
   thirteen G3 series, and record the losing reading in `notes` rather than
   deleting it.** On the evidence I would take Reading B (the consolidated
   text, 01-01-2021): it is the state's current statement of its own law, it
   is what the other twelve series already use, and the 2020 outlier rests on
   a Justel header artefact rather than on an article. **That preference is
   not a finding and must not be applied on my signature alone — I-11.**
   **Whichever way it goes, the id `be-agricultural-g-2020` does not change:
   series ids are append-only and are never deleted. Only `period.start`
   moves.** The current source line should also stop attributing the date to
   "the Justel footnote", which is not where it came from.
2. **F-3 — lift the five sourced letter constraints into `regex_strict`,** in
   the style `be-taxi-t-2021` already uses. Pure tightening; the § 2.7 ladder
   is preserved.
3. **F-4 — add one sentence to `be-historic-o-2021` notes** recording that the
   O index is shared with the motorcycle series and that the statute imposes no
   letter-group exclusion, so the two are distinguishable only by plate format.
   `be-international-2021` already carries the equivalent sentence for F-2;
   this is consistency, not new information.
4. **Nothing else.** The pre-2001 history is correctly withheld as folklore,
   the 1973 lead is correctly pinned without being claimed, the RAL-vs-sRGB
   caveat is correctly stated, and the A/E/P DIV-versus-statute discrepancy is
   explicitly "recorded, not averaged" — which is the § 5.3 discipline applied
   by the researcher without being asked.

## PART 5 — gate proof

Unchanged before and after this dossier lands; the dossier is Markdown and is
not reachable by the `plates/*.yml` + `plates/*/*.yml` glob.

```
plates lint: 124 files, 1381 series
plates lint: matching recall-only=286 strict=1095 | twins regex_statutory=106 regex_strict=427 | separators emitted "-"," " forgiving 18
plates lint: _art ledger 6060 rows (excluded=5355 open=412 site_only=293), 412 open assets verified
plates lint: OK

curation lint: OK (109 files, duplicate-key + shape + make-key + provenance)
```

## Sources, with exact URLs

Primary — Justel consolidated (R1, French) and its Dutch counterpart (R2):

- AM 23-07-2001 (FR) — https://www.ejustice.just.fgov.be/cgi_loi/article.pl?language=fr&lg_txt=f&numac_search=2001014154&caller=SUM&view_numac=2001014154f
- AM 23-07-2001 (NL) — https://www.ejustice.just.fgov.be/cgi_loi/article.pl?language=nl&lg_txt=n&numac_search=2001014154&caller=SUM&view_numac=2001014154n
- AR 20-07-2001 (FR) — https://www.ejustice.just.fgov.be/cgi_loi/article.pl?language=fr&lg_txt=f&numac_search=2001014153&caller=SUM&view_numac=2001014153f
- AM 15-12-2019 — https://www.ejustice.just.fgov.be/cgi_loi/change_lg.pl?language=fr&la=F&cn=2019121519&table_name=loi
- **AM 12-10-2020** (the postponing instrument; NUMAC 2020043081) — https://www.ejustice.just.fgov.be/cgi_loi/change_lg.pl?language=fr&la=F&cn=2020101205&table_name=loi
- AM 08-11-2010 — https://www.ejustice.just.fgov.be/cgi_loi/change_lg.pl?language=fr&la=F&cn=2010110801&table_name=loi
- AM 28-03-2014 — https://www.ejustice.just.fgov.be/cgi_loi/change_lg.pl?language=fr&la=F&cn=2014032807&table_name=loi
- AM 21-10-2022 — https://www.ejustice.just.fgov.be/cgi_loi/change_lg.pl?language=fr&la=F&cn=2022102106&table_name=loi

Independent republisher of the *Moniteur belge* as published (R3):

- AM 15-12-2019, original text of art. 5 — https://etaamb.openjustice.be/fr/arrete-ministeriel-du-15-decembre-2019_n2020040939.html
- AM 23-07-2001, amendment table — https://etaamb.openjustice.be/fr/2001014154.html

Issuing authority (R4):

- DIV plate formats — https://mobilit.belgium.be/fr/route/immatriculer-et-radier/plaques-et-certificats-dimmatriculation/format-de-plaque

All routes accessed 2026-08-08. Licence posture: Belgian statutory texts on
ejustice are official state publications consulted and **cited**, never
redistributed — PRD-PLATES § 6's "cite, never embed" rule. No ShareAlike, no
NonCommercial, no scraped corpus, no artwork.
