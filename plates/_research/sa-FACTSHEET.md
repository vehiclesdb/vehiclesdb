# `sa` Saudi Arabia — researcher fact sheet, NOT APPLIED

**Status: WIP branch only. `plates/sa.yml` does not exist.** Produced by an Opus
researcher for S4W/PLT on 2026-09-12 and reviewed by the manager, but the lane
was stopped on a token budget before the YAML was authored. **Nothing here is
verified** — a researcher never certifies their own work (I-11). Access date for
every URL: 2026-09-12.

Method note worth keeping: the session `WebSearch` budget was exhausted 200/200
before the first call, and `laws.boe.gov.sa`, `moi.gov.sa`, `my.gov.sa`,
`absher.sa` and `saudi.gov.sa` are all unreachable from this egress. Everything
below came from canonical-URL retrieval over `curl` plus Wayback CDX
enumeration and `web.archive.org/web/<ts>id_/` retrieval. **Retrieval beat
discovery, again.**

## THE HEADLINE — same shape as `eg` and `ng`

**The Saudi instruments REGULATE plates in detail and NEVER PRINT THE SERIAL
MASK, THE LETTER SET, THE COLOURS, OR THE DIMENSIONS.** Law art. 7 final
sentence: «وتحدد **اللائحة** فئات هذه اللوحات ومواصفاتها» — the Regulation shall
determine the categories and their specifications. And the Regulation's own
specification article delegates *again*:

- **Reg. 7/2/2** (as amended by Ministerial Decision 18 of 19/5/1442H):
  plates are «لوحات عادية، لوحات طويلة، لوحات قصيرة» (ordinary / long / short)
  and **«وللإدارة العامة للمرور تحديد مقاسات تلك اللوحات»** — the GDT determines
  the dimensions. **No millimetre appears in any instrument.**
- **Reg. 7/2/3**: the plate shall indicate the vehicle's registration type
  **«وفق ما تحدده الإدارة العامة للمرور»** — as the GDT determines. This is the
  delegation under which the colour-coding exists. **The colour scheme is GDT
  administrative practice, not a published instrument.**

So mask, alphabet, colours and dimensions are ALL recall-only / lower-tier for
Saudi Arabia. **Ship no hex. Ship no mm.** This is the third jurisdiction in a
row (ng, eg, sa) where the instrument regulates everything except the grammar.

## A. Authority and legal frame

- **Authority:** الإدارة العامة للمرور — General Department of Traffic (GDT),
  within الأمن العام, وزارة الداخلية. Law art. 1 §36 defines it as «الإدارة
  المختصة ... وصرف اللوحات».
- **ACT:** نظام المرور, Royal Decree **م/85 of 26/10/1428H**, which the Bureau of
  Experts gives as **07/11/2007** Gregorian (the source's own conversion).
  `https://laws.boe.gov.sa/BoeLaws/Laws/LawDetails/85364e57-c01e-41ba-8def-a9a700f183e9/1`
  (Arabic) and `/2` (English), retrieved via
  `https://web.archive.org/web/20250211143628id_/<url>`. Tier `statute`.
- **Plate-article amendments:** Royal Decree **م/115 of 5/12/1439H** (amended
  art. 7; added the historic-vehicle row to the annexed fee table); Royal Decree
  **م/207 of 28/9/1445H** (amended art. 5; added item **(9) لوحات المقطورة
  ونصف المقطورة**).
- **REGULATION:** اللائحة التنفيذية لنظام المرور, **Ministerial Decision 2249 of
  10/3/1441H**. Established by the Umm al-Qura text at
  `https://www.uqn.gov.sa/decisions-and-regulations/4001172`. Consolidated
  Law+Regulation PDF (the source for every `n/m` citation here):
  `https://www.moi.gov.sa/wps/wcm/connect/c94c6e10-677f-4d7a-8c12-300c38908b52/Traffic+Sys.pdf?MOD=AJPERES&CVID=obeJVVy`
  via `https://web.archive.org/web/2024id_/<url>`.
  ⚠ The PDF's Arabic text layer **drops ك/ي/ه glyphs frequently** — a verifier
  re-reading it should expect reconstructions.
- **Regulation amendments touching plates:** Ministerial Decision **18 of
  19/5/1442H** (amended 7/2/2 sizes and 7/3/1 affixing); Ministerial Decision
  **11488 of 30/7/1443H** (**added new art. 7/5**, distinctive emblems).
- **Binding: VEHICLE**, with the document tied to the owner. Reg. 3/1: the
  special number is the number of the plate issued **to the vehicle**. Reg. 3/2:
  the registration licence carries the plate number and **is linked to the
  owner's identity**. Law art. 3(b) makes the number mutable. Reg. 7/4 lets the
  GDT **auction** plate numbers — numbers are tradeable.
- **Issuance: NATIONAL**, not provincial. Law art. 6; Reg. 4/1 «الصادرة من
  الإدارة العامة للمرور». **Expressly not the UAE emirate model.**
- **Live change inside 3 years — AND IT IS UNREAD:** Ministerial Decision
  **5330 of 16/12/1447H**, gazetted in Umm al-Qura 26/12/1447H = **12 June
  2026**, "إضافة فقرات على مواد اللائحة التنفيذية لنظام المرور", effective on
  publication. **The amending text («الصيغة المرافقة») is NOT reproduced on the
  gazette page.** Whether it touches art. 7 is unknown. This is the freshest
  instrument in the file and the highest-priority dig.

## B. The class list — this part IS statute-tier

**Law art. 7** enumerates: (1) اللوحات الخاصة — private / private-transport /
private-bus; (2) اللوحات العامة — public transport / public bus / taxi;
(3) الدبلوماسية والقنصلية; (4) المؤقتة; (5) مركبات الأشغال العامة;
(6) التصدير; (7) الدراجات الآلية; plus **(9) المقطورة ونصف المقطورة** added by
م/207.

⚠ **Numbering discrepancy, a real finding:** the BoE consolidated display of
art. 7 shows only items 1–7, yet م/207 adds an item expressly numbered **(9)**
and م/115 separately added a historic-vehicle category. **Do not treat BoE's
rendering of art. 7 as complete.**

**Reg. 7/1** resolves sub-categories with thresholds: private ≤ 8 persons;
light/heavy goods split at **GVW 3500 kg**; small/large bus split at **15
passengers**; taxi ≤ 8 persons with a Public Transport Authority licence;
diplomatic on **written approval of the Ministry of Foreign Affairs** and
**may not be fitted to any other vehicle** (7/1/3/3); temporary with a document
stating period and purpose; export valid **only toward the exit port** and only
for a period matching the distance (7/1/6/1–2); public works incl. tracked and
agricultural equipment; **7/1/8 لوحات اقتناء المركبات التاريخية القديمة**
(historic).

**The Law's annexed fee table** (amendable only by Royal Decree, hence
`statute`) is the most complete authoritative enumeration found — 14 rows.
Notable: temporary **300 SAR for thirty days only**; historic **3000 SAR** once
at issue; **لوحة شعار مميز** (distinctive-emblem plate) **800 SAR** once at
issue.

**Mounting:** art. 4 — two plates, front and rear, except motorcycle, trailer
and semi-trailer. Art. 5 (as amended by م/207) — motorcycle one rear plate;
trailer/semi-trailer carries the tractor's number if its size obscures that
plate, **and** its own plate. Reg. 7/3/1 — **short plates may be fitted in any
position at the front.**

## C. The dual-script serial

### Alphabet — 17 letters, `secondary-wikipedia`, NO instrument

Codepoints dumped through `iconv -t UTF-32BE` rather than transcribed by eye.

| Arabic | Codepoint | Latin code | true translit |
|---|---|---|---|
| ا | U+0627 ALEF | **A** | a |
| ب | U+0628 BEH | **B** | b |
| ح | U+062D HAH | **J** | ḥ |
| د | U+062F DAL | **D** | d |
| ر | U+0631 REH | **R** | r |
| س | U+0633 SEEN | **S** | s |
| ص | U+0635 SAD | **X** | ṣ |
| ط | U+0637 TAH | **T** | ṭ |
| ع | U+0639 AIN | **E** | ʿ |
| ق | U+0642 QAF | **G** | q |
| ك | U+0643 KAF | **K** | k |
| ل | U+0644 LAM | **L** | l |
| م | U+0645 MEEM | **Z** | m |
| ن | U+0646 NOON | **N** | n |
| هـ | U+0647 HEH **+ U+0640 TATWEEL** | **H** | h |
| و | U+0648 WAW | **U** | u |
| ى | U+0649 ALEF MAKSURA | **V** | á |

- Latin set (17): `A B D E G H J K L N R S T U V X Z`. Excluded (9):
  `C F I M O P Q W Y`. 17 + 9 = 26. **The map is INJECTIVE.**
- **THE LATIN LETTER IS A CODE, NOT A TRANSLITERATION.** ح→J, ص→X, ع→E, ق→G,
  م→Z, ى→V. **Seven of seventeen do not match their phonetic value.** Any
  pipeline that "romanises" the Arabic produces the wrong Latin string.
- **Three storage traps, each a silent-corruption risk:**
  - هـ is **U+0647 + U+0640 TATWEEL** in the source. The tatweel is
    presentational. **The letter is U+0647.**
  - **U+0627 bare ALEF, not U+0623 ALEF WITH HAMZA.** A dataset keyed on أ
    rejects real Saudi plates. **Note this DIFFERS from Egypt, which uses
    U+0623** — the two files must not share an alphabet.
  - **U+0649 ALEF MAKSURA, not U+064A YEH.** Near-identical in isolated form.
    **Egypt uses U+064A.** Again, different.
- Digits: **Arabic-Indic U+0660–U+0669**, verified against photographs (zeros
  print as dots), **not** Extended Arabic-Indic U+06F0–U+06F9.
- *That the code was chosen to avoid glyph confusion is* **FOLKLORE, not
  asserted** — no source states a rationale.

### Reading order — resolved photographically, SAME REVERSAL AS EGYPT

Digit block is physically **left**, letter block **right**; Arabic line on top,
Latin below. So the Latin line read LTR is **digits then letters**; the Arabic
line read RTL is **letters then digits**.

**The Arabic letter glyphs sit in the same left-to-right slots as their Latin
counterparts, so the Arabic letter sequence read RTL is the exact REVERSE of the
Latin sequence read LTR.** Verified on three plates. **Digits are NOT mirrored**
— numerals are most-significant-first in both scripts.

> This is independently the same structural fact the Egypt researcher
> established. Two researchers, two jurisdictions, one conclusion, both
> photographic. **A dual-script Arabic file must pin which rendering it stores
> and say so on the face of the series, or consumers comparing against an
> Arabic-order OCR get a reversed string.**

### Mask — GO WIDE, the grammar is unsourced

- en.wikipedia: "three letters and up to four numbers"; claims standard plates
  **always** have four numbers, zero-padded.
- ar.wikipedia: «من حرف إلى ثلاثة حروف ورقم إلى أربعة أرقام» — **1–3 letters,
  1–4 digits**.
- **A photograph refutes the zero-padding claim**: a current in-service plate
  (EXIF 2025-01-25) carries a **single digit, unpadded**, with three letters.
- Widest defensible, Latin rendering: **1–4 digits + 1–3 letters**.
- **Motorcycle is distinct**: Arabic-only, **2 letters + up to 3 digits**, no
  Latin line.
- No printed separator — the groups sit in separate recessed cells or either
  side of the country strip.

### Colours — words only, NO HEX

Instrument gives only: reflective, heat-stamped, colour may not be altered
(Reg. 6/1, 7/3/3), and must indicate registration type as the GDT determines.

Observed (`photographic`): private car — black on white, **white** country panel
with a solid black **circle ●**; private transport — **blue** panel with a black
**downward triangle ▼**.

Reported (`secondary-wikipedia`, both editions) — the **strip**, not the whole
plate: private white/circle · public transport and taxi **yellow**/triangle up ·
trucks **blue**/triangle down · temporary **silver**/triangle left · diplomatic
**green**, emblem in a white rectangle, no symbol. Police use standard plates.
⚠ Olavsplates labels the blue class "Private transport", matching the statute's
«لوحات مركبات النقل الخاص» better than Wikipedia's "Commercial" — **label
conflict, flagged**.

Historic: before the current series the **whole plate** carried the colour.

### Dimensions — DELEGATED, ship nothing

Reg. 7/2/2 creates عادية / طويلة / قصيرة and hands measurements to the GDT.
**Wikipedia is internally contradictory**: the en infobox says `520 x 110 mm`
while the body of the same article says `550x110mm` and `335x155 mm`. **520 vs
550 is an unreconciled conflict inside one article. Ship no dimension.**

### Country marking

Emblem + «السعودية» + **KSA**. Stacked **vertically** on the square plate,
**horizontal** on the long plate. ⚠ **This corrects Wikipedia**, which
attributes the change to the year 2014: the photographs show it tracks the
**plate format**, not the year — a 2025 square plate still prints KSA
vertically.

## D. The one clean instrument date — the emblem plate

**لوحة شعار مميز**, Reg. **7/5, added by Ministerial Decision 11488 of
30/7/1443H (≈March 2022)**. 7/5/1 GDT proposes designs and may receive
proposals; 7/5/2 the emblem must not affect the plate's data, must not offend
Sharia or public morals or be **tribal or racist**, must not violate IP; 7/5/3
**the Minister of Interior approves the design**; 7/5/5 a replacement carries
the same emblem. **Fee 800 SAR once at issue — the statutory fee table's row 14
independently matches the secondary reports, a clean cross-tier confirmation.**
Five approved emblems (`secondary-wikipedia`): رؤية المملكة 2030 · السيفان
والنخلة (colour and black) · مدائن صالح · الدرعية.

→ `period.start: 2022`, `period_evidence: enabling-instrument`. Olavsplates
independently captions this style "2022 onwards".

## E. The era year — `marked-unverified`

| claim | source | tier |
|---|---|---|
| current plates introduced **2006** | en+ar wikipedia, identical wording | `secondary-wikipedia` |
| normal series **since 2007** | olavsplates | folklore |
| Law м/85 dated 26/10/1428H = 07/11/2007 | BoE | `statute` |

**The Traffic Law is NOT the enabling instrument for the design** — it delegates
onward to a Regulation that delegates onward to the GDT. The commonly-cited
"2005–2008 reform" has **no instrument behind it**. Recommend `period.start:
2006`, `marked-unverified`, with an explicit note that 2007 competes and that
the year is **neither** an enabling-instrument date **nor** a confirmed
first-issue date.

## F. Geography — REFUTED for the current series

No geography in the current serial: no instrument mentions region or city in
connection with plates; issuance is single-national; Reg. 3/1 ties the number to
**registration type**; Reg. 7/1 differentiates by use class and weight/capacity.
**Nuance:** geography *was* encoded historically — the pre-1996 six-digit series
is described as area-coded (Riyadh central area) and ar.wikipedia says 1955-era
plates carried «اسم المدينة». Neither is instrument-sourced. **Historic
area-code decode table: NOT sourced — V-item.**

## G. Banned combinations — do NOT encode

Some letter combinations banned from **2009** for their Arabic or Latin reading;
~90,000 in-use combinations withdrawn. BBC News 12 Apr 2009,
`http://news.bbc.co.uk/2/hi/7995865.stm` (archived
`https://web.archive.org/web/20191230075722/`). **The ban list is unpublished, so
a validating regex must NOT attempt exclusions.**

## H. Closed series (all `photographic` + weak secondary, from olavsplates)

- **c.1978–1996**: six digits, no letters. Caption asserts an area code.
- **1996–2007**: Arabic-only, **3 digits + 3 Arabic letters**, «السعودية» above,
  black on white. Still valid per the site.
- **Motorcycle since 1996**: Arabic-only, 2 letters, up to three numerals.

## I. GAPS, in priority order

1. **No instrument for the alphabet or the Arabic→Latin code.** Highest-value
   dig: the GDT's **plate-auction rules under Reg. 7/4** — a bidder must choose
   a letter combination, so that instrument almost certainly enumerates the
   alphabet. `my.gov.sa/ar/services/538556` is 403 live and 404 in Wayback;
   `lp.moi.gov.sa` does not resolve.
2. **No instrument for the colour scheme.** Two classes photographic, five
   Wikipedia. **No photograph at all of yellow, silver or green.**
3. **No dimensions anywhere.** Wikipedia self-contradicts.
4. **Era year unresolved** (2006 vs 2007).
5. **Ministerial Decision 5330 (12 June 2026) is UNREAD** — see §A.
6. Art. 7's item numbering is internally inconsistent across BoE / م/115 / م/207.
7. The 2009 banned-combination list is unpublished.
8. Letter-count ceiling unverified: 3 (en) vs 1–3 (ar); all photos show 3 on
   cars, 2 on the motorcycle.
9. Historic area-code table not sourced.
10. Manufacturer contradicted between wikis (en: Government Printing Press,
    Riyadh; ar: Utsch AG). Irrelevant to format, but a symptom of thin sourcing.
11. **Trailer/semi-trailer (class 9) and historic (class 13) have no observed
    specimen. Format unknown.**
12. MoI's own specimen gallery survives in Wayback but **its five plate JPEGs
    are 404**. If the live host becomes reachable it is the best official
    specimen source.

## J. Verification corpus — redacted shapes only, NO real serial

All from `http://www.olavsplates.com/saudi_arabia.html` (page states "Last
updated 26.4.2026"). Dates are **EXIF DateTimeOriginal read off the downloaded
file**, not site prose.

| # | file | dated | panel | shape |
|---|---|---|---|---|
| 1 | `foto_k/ksa_2020vjr_close.jpg` | 2024-09-09 | square, white, ● | Latin `9999 LLL`; Arabic zeros print as dots |
| 2 | `foto_k/ksa_4464hxb_close.jpg` | 2015-06-13 | long, white, ●, KSA horizontal | Arabic digits identical L→R to Latin |
| 3 | `foto_k/ksa_1axs_close.jpg` | 2025-01-25 | square, blue, ▼, KSA vertical | **`9 LLL` — ONE digit, unpadded** |
| 4 | `foto_k/ksa_7833vtb_close.jpg` | 2025-07-21 | square, blue, ▼ | `9999 LLL` |
| 5 | `foto_k/ksa_1811lkr_close.jpg` | 2025-08-27 | long, decorative emblem | Reg. 7/5 emblem specimen |
| 6 | `foto_k/ksa_165xg_close.jpg` | 2024-04-21 | **motorcycle**, Arabic-only | `LL 999`, no Latin line |
| 7 | `foto_k/ksa_387daa_close.jpg` | no EXIF, 1996–2007 | Arabic-only | `LLL 999` |
| 8 | `foto_k/ksa_297497.jpg` | no EXIF, c.1978–96, obsolete | Arabic-only | `999999` |

**Acceptance targets:** the current standard series must accept 4 digits + 3
letters (#1,#2,#4,#5) **and** 1 digit + 3 letters (#3). Motorcycle (#6) needs
its own 2-letter rule. **Any regex demanding exactly four digits, or three
letters universally, fails against this corpus.**

**A verifier must independently re-derive the slot alignment on #1**, since the
reverse-reading conclusion is the load-bearing claim here and rests on one
researcher's reading of images.

## K. What the manager would have written, had there been clock

`plates/sa.yml`, ~10 series, every one `matching: recall-only` for the §B
reason. `serial_alphabet:` as the **union** of Latin A-Z + 0-9 + the 17 Arabic
letters + U+0660–U+0669 — never the Arabic alone, because
`scripts/lint_plates.rb` generates the `L` token from a hardcoded `("A".."Z")`
and expands `[A-Z]` to 26 Latin letters each checked against the declared
alphabet, so an Arabic-only declaration fails every regex in the file. `script:`
block on the `ua.yml` precedent carrying the injective map, the **code-not-
transliteration** warning, and the letter-order reversal. No hex. No mm. No
decode table. See `plates/eg.yml` on branch `s4w/plt-l5-arabic` (PR #339) for
the worked shape.
