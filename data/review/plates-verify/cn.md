---
jurisdiction: cn
data_files: [plates/cn.yml, plates/_decode/cn-provinces.yml, plates/_decode/cn-issuing-offices.yml]
gate: L3
researcher: first-wave plates research (2026-08-02)
verifier: cn verification pass (2026-11-26), independent of the first wave
verified_at: 2026-11-26
base: 0727100
---

# China (cn) plates — PRD-PLATES §5.3 verification dossier

- Date: 2026-11-26   Agent: cn-verify (Opus)   Wave: plates verification, six-largest-markets programme
- Tool: web (see the source index at the end, S1-S18)
- Status: COMPLETE for series and both decode tables; open questions at the end
- Feeds: vehiclesdb `plates/cn.yml`, `plates/_decode/cn-provinces.yml`, `plates/_decode/cn-issuing-offices.yml`; gem bundle; zh/en China plate pages
- Branch: vehiclesdb `plates/cn-verification` 

## 0. The finding that changes everything

The first wave (2026-08-02) believed the current standard's text was withheld and built the file on GA 36-2007. **GA 36-2018 is readable in full** — Wikimedia Commons carries the published edition (File:GA_36-2018.pdf, 60 pages, text layer, credited to the "一带一路" standards platform), along with GA 36-1992, GA 36-2007 and GA 36-2014. Both amendments to GA 36-2018 were also found and read. So every series could be re-derived from the edition in force.

### What was read, and how

| Instrument | Read | Via |
|---|---|---|
| GA 36-2018 (in force, 实施 2018-05-01) | **in full**, text and every figure | Wikimedia Commons republication (S1); the Ministry portal (S5) refuses text |
| 第1号修改单 (2022-07-29 / in force 2023-01-01) | **in full**, text and figures | Ministry notice + amendment as attachments republished by 邵阳市公安局交警支队, via the Internet Archive (S2) |
| 第2号修改单 (2026-02-28, 公安行标公告〔2026〕2号) | **in full** (2 pages) | **only** a non-government republisher, gzparking.com (S3); metadata corroborated by xinbiaocha.com (S4) |
| GA 36-92 (实施 1992-07-01) | **in part**, as page images | Commons (S7) |
| GA 36-2014 | foreword, serial rules, Annex A, three figure pages | Commons (S8) |
| GA 36-2007 | in full (first wave, 巩义 copy S10); foreword, Annex A and figure p. 8 re-read from Commons (S9) | |
| 公安部令第164号, 第174号 (警车), 第90号, 国办发〔2018〕114号 | in full | gov.cn (S11-S14) |
| GA 666, NY 345.1, 外发〔2017〕10号 | **not read** (not located) | — |

## 1. Findings (applied in the PR)

| # | Where | The file said | The source says | Changed to | Source |
|---|---|---|---|---|---|
| F-1 | header, `instrument` | GA 36-2018 text is not public; every claim rests on GA 36-2007 | Full text on Commons; the edition is amended twice | Rebuilt on GA 36-2018 + 修改单 1 and 2; each "how read" stated | S1-S5 |
| F-2 | `cn-nev-small-2016` | letter position NOT sourced (folklore F-7); only D/F; no dimensions | 表 6: "第一位是英文字母 D…" ; BEV D A B C E, non-BEV F G H J K (2018) + P Q R S T / L M N (修改单 2, 2026-02-28); second position letter or digit; 表 1 row 5 "480×140 … 2" | `regex_strict` `\A[A-Z][- ]?[DABCEPQRSTFGHJKLMN][0-9A-HJ-NP-Z]\d{4}\z`; pattern `LL99999`; plate 480×140, 2 plates; layout | S1 表 1/表 6/图 7; S3 |
| F-3 | `cn-nev-large-2016` | position not sourced; no dimensions | 表 5: "第六位是英文字母 D…"; D A B C E / F G H J K; 480×140 front (图 7) and rear (图 8) | `regex_strict` `\A[A-Z][- ]?\d{5}[DABCEFGHJK]\z`; pattern `L99999L`; dims | S1 |
| F-4 | `cn-motorcycle-1992`, `cn-moped-1992`, `cn-driving-school-motorcycle-1992` | two plates: 220×95 front + 220×140 rear ("named verifier target") | GA 36-2014 前言: "修改了摩托车号牌数量,取消前号牌" / "删除了外廓尺寸为 220 mm×95 mm 的摩托车前号牌"; 2018 表 1 rows 11-15 count 1 | one 220×140 rear plate; front recorded as history to 2014 | S8, S1 |
| F-5 | `cn-embassy-car-1992` | printed `<digits>使`, 4-6 digits, grammar unknown (recall-only) | GA 36-92 § 3.3, 2007 图 2, 2014 图 2: **使014·578** — 使 first, 3-digit 使馆编号, separator, 3-digit 注册编号 | strict `\A\d{3}[- ]?\d{3}\z`, 使 leading; **ended 2018** | S7, S8, S9 |
| F-6 | (new) `cn-embassy-car-2018` | — | GA 36-2018 图 2: **224·578使** (驻华外交机构编号 · 序号 + 使); 表 3 "3位 … 每一位都使用阿拉伯数字"; colour 黑底白字,白框线 (no red) | new series | S1 |
| F-7 | `cn-consulate-car-1992`, `-motorcycle-1992` | province + office letter + 4/5 serial, recall-only, current | 1992 津A·F023领 (4 positions); GA 36-2018 前言 "增加了领馆汽车号牌式样" — 2018 form is **沪224·78领**, no office letter | strict 4 positions; **ended 2018**; new `cn-consulate-car-2018` (`\A\d{3}[- ]?\d[0-9A-HJ-NP-Z]\z`), `cn-consulate-motorcycle-2018` (沪·领 / 22478) | S7, S1 表 3 "2位" |
| F-8 | 4/5-position `regex_strict` (small car, large car) | GA 36-2007 表 3: eleven combinations | GA 36-2018 表 4: sixteen (2014 added five) = every placement of ≤2 letters | 16-alternative `regex_strict` | S1 表 4; S8 前言 |
| F-9 | serial widths, all recall-only metal series | width unknown (Annex C not reproduced) | 图 9/19 (5), Annex B.2/B.9/B.15/B.8 and 图 4/5/12 (4 + 挂/学/警/港澳) | trailer, driving-school ×2, police ×2, HK/Macau → strict 4; motorcycle, moped, low-speed → strict 5 | S1 |
| F-10 | `cn-police-car-2007` | separator between letter and serial | 图 4 京·A0006警 — separator after the province; rear 图 5 / B.10 b) a **dash** | regex `\A[A-Z][A-Z0-9]{4}\z`; front/rear separator difference recorded | S1 |
| F-11 | `cn-large-car-1992` scope | "半挂牵引车；电车" (trolleybuses) | 2018 表 1 row 1: "…;有轨电车" (trams), no 半挂牵引车 | scope corrected | S1 |
| F-12 | `cn-temporary-travel-1992` | blue within / brown across jurisdictions; one plate; 125 g card | 修改单 1 (2023-01-01): three classes; "十、删除B.19" (cross-jurisdiction brown gone); 2 plates for passenger cars; 2018 § 6.1.1.2.2 "120g/m² 以上的胶版印刷纸" | variants rewritten with dates; count; paper | S2, S1 |
| F-13 | `cn-temporary-entry-car-1992`, `-motorcycle-1992` | design 220×140 / 88×60 from 1992 | GA 36-92 表 1 rows 20-21: 300×165 and 220×120; 2007 "修改了临时入境车辆号牌式样" | `period.start` 1992 → 2007 (ids kept); serial 5, strict | S7, S9 |
| F-14 | `common.serial.recycling_rule` | "6个月后可重新使用" | 2018 § 5.9.2 b): "12 个月后应重新启用" | 12 months | S1 |
| F-15 | `cn-trailer-1992` source | 《机动车登记规定》第九条 | the trailer sentence is in **第十三条** (第九条 is e-signatures) | citation corrected | S11 |
| F-16 | `cn-provinces` 使 | added 2007; position leading (always) | GA 36-92 § 3.3 prints 使; 2018 moves it to the end | 1992 start; position by era | S7, S1 |
| F-17 | `cn-issuing-offices` | 2007 snapshot, nothing dated later | 2014: −巢湖 Q, −西藏 H/J, 襄阳; 2018: +成都 G, +儋州 F, Shandong O+W; 修改单 2: twelve changes | rows dated by `editions`, `status`, `evidence`; 14 rows added, 5 withdrawn | S1, S3, S8 |
| F-18 | `common.materials` | steel allowed; service-life ≥4 years | 2018 § 6.1.1.1 "应使用铝质材料…铝含量应不小于 99.60%"; no service-life clause found in 2018 | updated | S1 |
| F-19 | `instrument.lineage` | GA 36-1992 undated | GA 36-92 p. 1: "1992-04-25批准 1992-07-01实施" | dated | S7 |
| F-20 | header, O | "every further claim about O is folklore" | 2014/2018 Annex A footnote g defines O's use (public-security service vehicles) | footnote quoted in decode file | S1, S8 |

## 2. Per series

Status: **V** verified unchanged · **C** corrected · **A** added · **P** partly verified.

| Series | Status | Settling quote |
|---|---|---|
| cn-small-car-1992 | C (regex_strict, dates, layout added) | 表 1 row 4 "小型汽车号牌 440×140 蓝底白字,白框线 2"; 表 4 rows 1-16 five-position √ |
| cn-large-car-1992 | C (scope, regex_strict, rear layout) | 表 1 row 1 "前:440×140 后:440×220 黄底黑字,黑框线 … 有轨电车" |
| cn-trailer-1992 | C (strict, 4; citation) | 表 1 row 2 "挂车号牌 440×220 … 1"; B.2 京·A F023挂 |
| cn-motorcycle-1992 | C (one plate, strict 5) | 表 1 row 11 "220×140 … 1"; 2014 前言 "取消前号牌" |
| cn-moped-1992 | C (same) | 表 1 row 12 "蓝底白字,白框线 1" |
| cn-lowspeed-1992 | C (two lines, strict 5; 1992 name) | 表 1 row 17 "300×165 黄底黑字,黑框线 2"; 图 19 |
| cn-driving-school-car-1992 | C (strict 4) | B.9 京A·F023学 |
| cn-driving-school-motorcycle-1992 | C (one plate, strict 4) | B.15 津·A A006学 |
| cn-police-car-2007 | C (strict 4, separator) | 图 4 京·A0006警; 图 5 dash |
| cn-police-motorcycle-2007 | C (strict 4) | 图 12 京·A 0006警 |
| cn-embassy-car-1992 | C (grammar, 使 leading, ended 2018) | GA 36-92 § 3.3 使014·578 |
| cn-embassy-motorcycle-1992 | C (使 top line, 5 digits, ended 2018) | GA 36-2014 图 7 使 / 00062 |
| cn-consulate-car-1992 | C (strict 4, ended 2018) | GA 36-92 § 3.4 津A·F023领 |
| cn-consulate-motorcycle-1992 | C (strict 4, ended 2018) | GA 36-92 figure 津 A / A006领 |
| cn-hkmacau-crossborder-2007 | C (strict 4) | B.8 粤Z·F023港; footnote h |
| cn-nev-small-2016 | C (position, letters, size) | 表 6 (修改单 2); 表 1 row 5 480×140 |
| cn-nev-large-2016 | C (position, size) | 表 5; 图 7/8 |
| cn-temporary-travel-1992 | C (修改单 1) | 修改单 1 表 1 rows 18-20; "删除B.19" |
| cn-temporary-entry-car-1992 | C (start 2007, strict 5) | GA 36-92 row 20 300×165; 2018 图 13/15 |
| cn-temporary-entry-motorcycle-1992 | C (start 2007, strict 5) | GA 36-92 row 21 220×120; 2018 图 20/21 |
| cn-emergency-rescue-car-2018 | V | 国办发〔2018〕114号 附件 一（一）, 二, 三 — every quoted clause matches the gov.cn text |
| cn-emergency-rescue-motorcycle-2018 | V (example labelled as constructed) | 附件 一（二） |
| cn-embassy-car-2018 | A | 图 2, 表 3 3位 |
| cn-embassy-motorcycle-2018 | A | 图 10 |
| cn-consulate-car-2018 | A | 图 3, 表 3 2位 |
| cn-consulate-motorcycle-2018 | A | 图 11 |
| cn-tractor-2005 | A, recall-only (informative drawings only) | 表 1 row 21 "按 NY345.1 执行"; B.26/B.27 |
| cn-foreign-car-1992 | A, ended 2007 | GA 36-92 表 1 row 6, § 3.6 |
| cn-overseas-car-1992 | A, ended 2007 | GA 36-92 表 1 row 5, § 3.5 京A·F023境 |
| cn-test-car-1992 | A, ended 2007 | GA 36-92 表 1 row 18 |

Not minted as series (recorded under `common.history`): the 86 pattern (secondary-wikipedia only) and the 2002 personalised trial (contemporaneous state-press dates, no primary grammar).

## 3. Decode tables

**cn-provinces.yml** — 31/31 rows **verified** against GA 36-2018 表 2 by machine parse of the text layer (`row`, `地区名称`, `简称` all equal) — evidence `instrument-in-force`. GA 36-92 表 2: 30 rows, same characters, 渝 absent (read as image). Classification characters: 12 rows (9 from § 5.10, 应急, and ended 境, 临); 使 corrected (F-16).

**cn-issuing-offices.yml** — authoritative source: GA 36 **normative** Annex A (§ 5.8.1 "发牌机关代号见附录 A"), as amended by 修改单. Method: Annex A of 2007, 2014 and 2018 parsed from the text layers and diffed row by row (`sources/annexA-2014.json`, `annexA-2018.json`), then eyeballed where the parse was unsure (two-line rows 垦区, 琼北) and on page images (固原).

| Tier | Rows |
|---|---|
| instrument-in-force (printed in GA 36-2018 Annex A) | 363 (incl. the 4 municipal A-Z rows and the national O and Z rows) |
| instrument-amendment-republished (修改单 2 via gzparking) | 10 |
| instrument-superseded (2007 only, or overridden by a later printing) | 4 — 巢湖 Q, 西藏 H (驻四川双流), 西藏 J (驻青海格尔木), 固原 D |
| **total** | **377** (was 363; 14 added; 5 marked `status: withdrawn`; none deleted) |

Row-level findings: withdrawn 2014 — 巢湖 Q, 西藏 H, 西藏 J; withdrawn 2026 — 莱芜 S, Shandong provincial W; renamed — 襄樊→襄阳 (F); printed oddities kept as notes — 固原 printed C in 2014/2018 (duplicate of 吴忠 C; 2007 D kept), 双鸭市/双鸭山市; added — 成都 G, 儋州 F (2018), Shandong provincial W (2018, withdrawn 2026), 冀X 雄安, 苏U, 浙M, 浙N, 鲁S 济南, 鲁W 临沂, 豫V 郑州, 鄂W 武汉, 陕U 西安, 陕U 西咸新区 (修改单 2). The amendment as republished gives U to both 西安 and 西咸新区; recorded as printed.

## 4. Render facts now in the data (from GA 36-2018 figures, mm)

- Outline: 440×140, 440×220, 480×140, 220×140, 300×165, 220×140 paper, 88×60 paper — all sourced.
- Character boxes: 45×90 (440×140 plates), 45/43×90 with 9 mm gaps (480×140), 80×60 over 65×110 (440×220 rear), 50×50 over 30×60 (220×140), 55×45 over 45×90 (300×165), 35×48 two rows (2018 embassy moto).
- Separator: 10 mm dot with 12 mm gaps (civil); 14 mm dot front / 16 mm dash rear (police); 49 mm mark gap (NEV).
- Corners R10 (R8 on 220×140); slot and hole positions; tolerances ±0.5%/±0.5 mm, characters ±1%.
- Colours: named in 表 1; numbered only red R03, PB09, YR06 (GB/T 3181). Reflective colours → GA 666, not read; all hex `observed`.
- Typeface: no glyph drawings since 2014; GA 36-92 附录 C and GA 36-2007 附录 B print them (images on Commons).

## 5. Folklore list from the first wave, resolved

| First-wave F-n | Now |
|---|---|
| F-1 92-pattern trial 1992 / nationwide 1994 | GA 36-92 in force 1992-07-01 is primary; trial/rollout dates still secondary, not asserted |
| F-2 embassy 3+3 digits | **TRUE**, and primary (F-5, F-6) |
| F-3 "O 牌" police | footnote g is primary; nothing beyond it asserted |
| F-4 粤Z replaced 广东02/03 in 2001 | still no primary |
| F-5 NEV national date 2018-06-15 | still no primary |
| F-6 NEV 480×140 | **TRUE**, primary |
| F-7 NEV letter position | **TRUE** (first small / last large), primary, with more letters than D/F |

## 6. Open questions, ranked by what a reader of the public page would notice

1. **第2号修改单 has no government copy in hand.** It moves the small-NEV letters and twelve office letters. A ministry or provincial copy would upgrade 10 decode rows and the NEV strict regex from "republished" to primary.
2. **Reflective colours (GA 666)** — every hex is observed. A render that claims 1:1 colour needs GA 666's chromaticity coordinates.
3. **Glyphs.** The standard dimensions boxes, not glyphs, since 2014. GA 36-2007 附录 B is the last printed glyph set; whether the dies changed is unknown.
4. **西安 U vs 西咸新区 U** in 修改单 2 as republished — one is likely a typo in the source or in the republication.
5. **固原 C (2014/2018) vs D (2007).**
6. **Old diplomatic plates' end date**: the 外发〔2017〕10号 exchange completion date.
7. **Embassy mission numbers and consulate mission numbers**: no public table.
8. **Pre-2007 police plates** and **military / armed-police plates**: outside GA 36 (§ 1 scope); not public in this pass.
9. **NY 345.1 (tractor)**: read to make cn-tractor-2005 strict and dimensioned.
10. **2002 pattern grammar**: needs a primary (the 2002 MPS notice) before a series id is minted.
11. Class vocabulary requests stand: `low-speed`, `driving-school`, `cross-border`, `foreign-resident`.

## Skipped against the task

- GA 36-92 Annex A (office letters of 1992) not transcribed (image-only, 6 pages).
- 2007-2014 embassy motorcycle and pre-2007 temporary-plate grammars beyond what the figures show.
- No attempt to source per-province NEV letter adoption dates.

## Findings in one paragraph

The current standard GA 36-2018 and both its amendments were found and read; the file had been built on the 2007 edition. Twenty findings were applied: the NEV letter rules and sizes (the file's top open question) are now primary and encoded; the motorcycle front plate was withdrawn in 2014; the embassy and consulate plates changed form in 2018 and the old forms were mis-described; serial widths are pinned for every metal class, turning nine recall-only series strict; the temporary plates follow the 2023 amendment; the office-letter table is dated row by row through three editions and the 2026 amendment. Ten series were added (four 2018 diplomatic forms, tractor, three 1992 classes abolished in 2007). No id was renamed or removed.

## NEW BRANCHES

- Commons also hosts GA 36-92/2007/2014 as PDFs: the same route probably exists for other Chinese GA/GB vehicle standards (GA 369 registration certificate, GB 15741 plate mounting), useful for the depth layer.
- The 2018 standard's Annex B effect drawings are the natural reference for the zh page family's "how to read a plate" visuals (schematic renders, not copies).


## Source index

| # | Instrument / page | Exact URL | Fetched | Read how | What it proves |
|---|---|---|---|---|---|
| S1 | GA 36-2018 《中华人民共和国机动车号牌》 full text (60 pp.) | https://upload.wikimedia.org/wikipedia/commons/0/00/GA_36-2018.pdf (file page https://commons.wikimedia.org/wiki/File:GA_36-2018.pdf; uploaded 2023-08-31; credit "一带一路共建国家标准信息平台"; sha1 7ee996fb…) | 2026-11-26 | IN FULL: text layer (`GA36-2018.fulltext-layout.txt`) + every figure page rendered and read (`raw/pages/p-NN.png`) | Everything current: 表 1 (classes, sizes, colours, counts, scope), 图 1-21 (layouts in mm), 表 2, § 5.8, 表 3-6, § 5.10, § 5.11, § 6 (materials, marks, dimensions tolerance, colours), § 10, § 12, 附录 A (letters + footnotes a-i), 附录 B (effect drawings incl. tractor) |
| S2 | GA 36-2018 第1号修改单 + MPS notice | http://web.archive.org/web/20250424051601/http://jjzd.shaoyang.gov.cn/syjjzd/wjjd/202302/34518ad409114b38add936270698e843/files/63c872cf26ac429792ca0787c48c5029.docx ; notice http://web.archive.org/web/20250424051014/http://jjzd.shaoyang.gov.cn/syjjzd/wjjd/202302/34518ad409114b38add936270698e843/files/980bb2a6655d49aaad4e83b1a9cc9f73.doc ; page http://web.archive.org/web/20250424050224/http://jjzd.shaoyang.gov.cn/syjjzd/wjjd/202302/34518ad409114b38add936270698e843.shtml | 2026-11-26 | IN FULL (text + 10 figures in `raw/xgd1-media/`) | Approved 2022-07-29, in force 2023-01-01; new 表 1 (temporary split into three classes; cross-jurisdiction brown deleted; diplomatic scope); 6.6.2 c) d); 10.2 c); 13.4; B.18-B.21 |
| S3 | GA 36-2018 第2号修改单 | http://www.gzparking.com/webfile/upload/2026/04-29/11-14-4404851036837864.pdf | 2026-11-26 | IN FULL (2 pages) — non-government republisher (a Guangzhou parking operator) | Approved and in force 2026-02-28; new 表 6 (small-NEV letters D A B C E P Q R S T / F G H J K L M N); 12 Annex A changes |
| S4 | Standards index entry for 第2号修改单 | https://www.xinbiaocha.com/index/tiaomuview/id/630088 (also sim.xinbiaocha.com) | 2026-11-26 | metadata page | "发文字号 公安行标公告[2026]2号", 发布/实施 2026-02-28, 代替 GA 36-2018+第1号修改单 |
| S5 | MPS standards portal, GA 36-2018 | https://ywtb.mps.gov.cn/gabzh/portal/stdDetail/315218 | 2026-11-26 | page + its JS | Status 现行, dates, plan no. 201650124, drafting staff; full-text button = "该标准暂不提供文本阅读" (FAILURE: no text) |
| S6 | MPS portal search "GA 36" | https://ywtb.mps.gov.cn/gabzh/portal/xxcx/std?key=GA%2036 | 2026-11-26 | page | GA 36-2018 现行; GA 36-2014 2014-01-24 废止 |
| S7 | GA 36-92 (scan, 35 pp.) | https://upload.wikimedia.org/wikipedia/commons/7/76/GA_36-1992.pdf | 2026-11-26 | IN PART as page images (pp. 1-5, 20-21 at readable size; all pages as a contact sheet `raw/p1992/sheet.png`) | 批准 1992-04-25, 实施 1992-07-01; 22-row 表 1 (incl. 境外/外籍/试验/农用运输车/拖拉机); 使014·578; 津A·F023领; 京A·F023境; 京A·F0236 (外籍); trailer F023挂; 表 2 (30 rows); § 3.24 + 表 3 (leading letter only, 24 letters) |
| S8 | GA 36-2014 | https://upload.wikimedia.org/wikipedia/commons/c/cb/GA_36-2014.pdf | 2026-11-26 | text layer searched (`GA36-2014.fulltext-layout.txt`) + figure pages 8, 10-11 as images | Foreword change list (motorcycle front plate removed; 5 serial combos added; 巢湖 Q, 西藏 H/J deleted; 襄阳; O footnote); embassy 使014·578; embassy moto 使/00062; Annex A |
| S9 | GA 36-2007 (Commons copy) | https://upload.wikimedia.org/wikipedia/commons/3/3d/GA_36-2007.pdf | 2026-11-26 | text layer searched + p. 8 image | Foreword (verbatim in dossier); embassy 使014·578; 固原 D; 双鸭市 J |
| S10 | GA 36-2007 (巩义市人民政府 republication) | https://web.archive.org/web/20150701102419/http://www.hngy.gov.cn/sitepublish/site1/wsbs/lyfwzl/jtfw/jdc/jdcfw/content_25106.html | 2026-08-02 (first wave) | in full (first wave) | the first wave's base |
| S11 | 《机动车登记规定》 公安部令第164号 | https://www.gov.cn/gongbao/content/2022/content_5682413.htm | 2026-11-26 | in full (`MPS-order-164-2021.txt`) | 第十三条 (tractor/trailer — not 第九条), 第四十三-五十条, 第八十五条, 第九十三条 |
| S12 | 《警车管理规定》 as amended by 公安部令第174号 | https://www.gov.cn/gongbao/2026/issue_12586/202602/content_7059934.html | 2026-11-26 | in full | 施行 2025-12-29; 第七条, 第十条, 第十一条 |
| S13 | 国办发〔2018〕114号 | https://www.gov.cn/zhengce/zhengceku/2018-12/11/content_5347765.htm | 2026-11-26 | in full | every emergency-plate quote in cn.yml verified |
| S14 | 公安部令第90号 | http://www.gov.cn/gongbao/content/2007/content_772748.htm | 2026-11-26 | in full | 第三, 五, 六, 七, 二十一, 二十二条 |
| S15 | 中新网 2002-08-22 (2002式 suspended) | http://web.archive.org/web/20170321084838/https://www.chinanews.com/2002-08-22/26/214418.html | 2026-11-26 | in full | dates of the 2002 trial and suspension; "北京共发放新式号牌万余副" |
| S16 | 人民网 2002 personalised-plates topic page | http://web.archive.org/web/20160304050534/http://www.people.com.cn/GB/jinji/222/8786/8787/index.html | 2026-11-26 | index page only | headlines dated 2002-08-15 to 08-23 (corroboration) |
| S17 | zh Wikipedia 中华人民共和国民用机动车号牌 | https://zh.wikipedia.org/wiki/中华人民共和国民用机动车号牌 (API, revid 95587350) | 2026-11-26 | wikitext of the history section | 86式 description (secondary-wikipedia tag in cn.yml); its citations led to S15/S16 |
| S18 | Commons file metadata for S1 | https://commons.wikimedia.org/w/api.php?action=query&titles=File:GA_36-2018.pdf&prop=imageinfo%7Crevisions (saved `raw/commons-GA36-2018-fileinfo.json`) | 2026-11-26 | API | uploader, date, licence tag PD-PRC-GB mandatory standard, "other versions" (1992/2007/2014) |

## Failures (exact)

- `ywtb.mps.gov.cn` GA 36-2018 full text: JS tip "该标准暂不提供文本阅读" (2026-11-26).
- `hbba.sacinfo.org.cn` GA 36-2018: "您所查询的标准在本系统尚未公开，不公开理由如下：无" (first wave, 2026-08-02; not retried).
- `www.xinshao.gov.cn/...7b1b17991f80473fa8559cb5f8f74e6b.shtml` (amendment 1, 新邵县): HTTP 502, twice; no Wayback snapshot.
- `jjzd.shaoyang.gov.cn/...` live: HTTP 502; Wayback copy used.
- `shiguyanjiu.com/content/?84-105-298.html=` (a GA 36-2018 republication): "Connection reset by peer".
- `ywtb.mps.gov.cn/gabzh/portal/tzgg` notices list: no 2026 announcement for 第2号修改单 listed (only 2019/2020 announcements shown).
- No government copy of 第2号修改单 was found; GA 666 (colours) and NY 345.1 (tractor) texts not located; 外发〔2017〕10号 not located.
