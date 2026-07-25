# Release 2026.07.2 — supervised-publish sign-off (§16)

The first post-correction publish. Everything below is DONE except the two
owner steps at the bottom.

## The delta (full diff: RELEASE-2026.07.2-diff.md, regenerable via scripts/release_diff.rb)

**18,133 → 16,948 records** (+1,645 / −2,830) · 322 display renames.
Every one of the 2,830 removals carries a migration path: **2,257 former_ids
aliases** (consumers holding old ids resolve forever) + **573 removals.yml
manifest entries** (parser fabrications, placeholders, kind-drops — documented
404s) + **0 orphans** (machine-checked by release_diff.rb AND the id-contract
gate; the diff generator exits 1 on any orphan).

What the delta contains, at a glance: the entire 2026-07 correction program —
duplicate-spelling collision resolution (2W: 165→0; 4W: 146→106), the
direction-war purge (27 circular rename pairs), the KBA shared-string-leak
healing, factory-built and MC LAREN pseudo-make dissolutions, the M-B
null-policy reversal (200 D / 300 D / 280 SE restored with 5-6-registry
corroboration), lu_snca 3-month accumulation (kills the rotation churn that
made 156 records flicker), IVA pilot fixes, B-001 Benzhou move.

## §16 checklist state

| step | state |
|---|---|
| validate green | ✅ every merge gated on a full build; final RC build exit 0, all gates |
| full dist-diff reviewed | ✅ artifact committed; **owner: read the D1 EXIT lines** — every "GONE" entry is alias-or-manifest covered, the "demoted" entries are popularity recomputation |
| no-vanish green | ✅ gate 7 active on every build since it landed |
| former_ids complete vs real diff | ✅ 0 orphans, machine-checked |
| rollback documented | ✅ previous dist is the rollback artifact; `@latest` heals on re-publish (§16.2) |
| **owner sign-off** | ⬜ **← YOU ARE HERE** |
| publish dispatch | ⬜ after sign-off: `gh workflow run "Build & publish data" --repo vehiclesdb/vehiclesdb --ref main -f publish=true` (or locally: `VDB_DATA_REPO=~/GitHub/vehiclesdb ruby pipeline/run.rb --publish`, then the printed human-gated commit/tag commands) |
| post-publish | S4W runs: jsDelivr/HF propagation check, gem snapshot, lint re-baseline (G13), OWNERSHIP regen (17 orphan makes incl. vanster), tag review baseline |

## Freeze rule

Between sign-off and dispatch, NO curation merges (a mid-window merge makes
this reviewed diff stale). The freeze window gets posted in NEGOTIATION.md
when sign-off lands; S2W acked the protocol in advance.
