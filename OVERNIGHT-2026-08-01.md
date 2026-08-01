# Overnight run, 2026-08-01 — what happened

## The headline

**You were right about the noise, and it was worse than you thought.** Across
nine makes measured tonight, between 23% and 82% of records were not models —
they were trims, axle codes, payload classes, body words, engine markers and
misspellings. All of it is now folded onto real nameplates with **zero country
evidence lost**, verified per fold.

**And the bigger finding was the opposite problem: 115,809 vehicles were being
DELETED on every build**, before they ever reached a record.

## Merged (17 data PRs + 12 pipeline PRs, main green, build exit 0)

| slice | records | noise folded |
|---|---|---|
| Iveco + Dodge | 430 → 170 | **82%** / 37% |
| Volvo | 428 → 157 | **63%** |
| MG + Austin | 281 → 131 | **53%** |
| Jaguar / Rover / Land Rover | 348 → 168 | **53%** |
| Chevrolet | 393 → 219 | **45%** |
| Mitsubishi + Mazda | 211 → 149 | 35% |
| Scania + DAF | 420 → 313 | 23% net (+28 real models minted) |

4W catalog: **8,613 → 7,765 published ids**, and van *grew* (742 → 907) because
real models were recovered out of pooled axle codes.

## The three things worth your attention

**1. 115,809 vehicles recovered — Saab is 90,597 of them.** `junk?` has two
rules that eat real nameplates: "a bare numeral can't be a model" and a
platform-code rule written for `"8D Audi A4"`. Both fire *after* the make token
is stripped, so any marque whose nameplate is a number loses it. Saab `9-3`
(70,404 vehicles, 9 countries) and `9-5` (20,193) were deleted every build,
while their own `9-3 <trim>` records published fine off the same registers — the
trim word supplied the letter the nameplate lacked. Also Mazda `5` (17,158),
DS `5`/`9`, Alfa `4C`, Mazda `6E`, Zeekr `7X`.
**Why nothing caught it**: a dropped row leaves no record, so every detector we
have is structurally blind to it. We audit what we publish, never what we
discard. There is now a `rake report:junk_drops` and a regression test.

**2. The time-series archive is running, and it has a gap you should decide on.**
Increment 3 shipped: every source refresh's per-model counts now persist under
that source's own snapshot date, so the archive compounds instead of being
overwritten. 11 sources, accumulating from tonight. **But it writes into
`archive/`, which is gitignored as the raw-dump never-in-git zone — so the asset
currently survives exactly one `rm -rf`.** Where the durable copy lives is a
licensing call, not an engineering one. Filed in DEBT.

**3. Two owner adjudications I did not make.** The BMW `/^M(\d)\b/` rule folds
**115,585** M2/M3/M4/M5/M6/M8 vehicles into the N-Series ids, and an in-code
comment states the opposite intent. Opel's `-E` strip folds the entire electric
line (~42,800 registrations) into the ICE nameplates, contradicting the settled
Citroën ë- verdict. Both are large, both are reversible, neither is mine to
decide.

## What I got wrong

- **I left main red for ~20 minutes** by merging a coupled pair's pipeline half
  while its data half was blocked. Adopted the rule: one window or not at all.
- **I had the merge order backwards for enrich pairs** and told six agents so.
  Measured it: every one fails pipeline-first. Corrected to data-first.
- **I built a two-hypothesis diagnosis on a log line that was a negative test's
  output**, and handed it to the other session before checking. Retracted in
  full.
- I amended a commit mid-rebase and briefly lost my own work; the push failed on
  detached HEAD, which is the only reason it stayed harmless.

## Coordination

S2W finished **G-1** — the UK Model-column fix, ~981,664 vehicles / 34% of the
UK two-wheeler fleet freed from ids that fused whole displacement classes. I
verified it causally against a frozen cache, rebased it past a conflict I
caused, and merged it. They also fixed a coverage inversion: the five largest
2W makes (3,065 records) had no enrichment at all while 2-record makes did.

## Queued for you

`DEBT.md` has the full ledger. Highest value: the pooled-GenModel detector (the
UK `Model` column names six products hiding inside `MAXUS DELIVER`'s 25,660
vehicles — but a blanket read would shatter `FORD FOCUS`, so it needs a
detector, validated against the ~1,500 trim decisions this wave produced);
the `search_aliases` token-eater root cause; and the next audit round, since
QUALITY.md still publishes a baseline measured before any of tonight.
