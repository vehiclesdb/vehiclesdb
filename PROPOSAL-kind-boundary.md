# PROPOSAL — the `kind` boundary is drawn on the wrong axis

**Status:** joint proposal for the repo owner. §2 (two-wheel evidence) written by
S2W; §3 (four-wheel evidence) stubbed for S4W; §1 and §4 drafted jointly.
**Nothing here changes data.** A kind split is schema-level — `kind` is in every
published id (`moped/aixam/a400`) — so it needs an owner's decision, not a
maintainer's.

---

## 1. The defect, in one sentence

**Registers classify vehicles by LEGAL CATEGORY; we publish `kind` as a MARKETING
CATEGORY; and we derive one from the other via each register's own vehicle-type
word, which is a third thing again.** Both maintainers hit this independently, in
opposite kinds, on the same day — which is why we think it is structural rather
than two bugs.

The mapping today runs `voertuigsoort`/`BodyType`/`Pkw` → `kind`
(`overrides/kind_maps/*.yml`). Those source words are *administrative* labels. The
EU category (`L1e`…`L7e`, `M1`, `N1`…) is the *legal* fact, and it is the thing
that actually predicts what the vehicle is.

---

## 2. Two-wheel evidence — `kind: moped` is two different vehicles `[S2W]`

`overrides/kind_maps/nl_rdw.yml` maps `Bromfiets: moped`. Measured live against
the RDW register (CC0, https://opendata.rdw.nl/resource/m9d7-ebf2.json,
2026-07-25), `Bromfiets` decomposes as:

| EU category | registrations | what it actually is |
|---|---|---|
| **L1e** | 1,327,208 | genuine mopeds — correct |
| **L6e** | **40,090** | **light quadricycles: enclosed 4-wheel microcars** |
| L2e | 5,844 | three-wheel mopeds |

**L6e is not a moped by any reading.** EU 168/2013 defines it as a *light
quadricycle*: four wheels, ≤ 425 kg unladen, ≤ 45 km/h, ≤ 6 kW. These are small
cars with doors, a roof, seatbelts and a windscreen. The makes carrying those
40,090 registrations:

```
AIXAM 9,385   LIGIER 5,804   MICROCAR 5,320   OPEL 4,350   STINT 3,142
ESTRIMA 1,950  FIAT 1,912    CITROEN 1,207    JIAYUAN 800   JDM 736
CHATENET 544   MEGA 299      CASALINI 283     BELLIER 229
```

Two things stand out:

- **Opel, Fiat and Citroën appear** — those are the **Opel Rocks-e**, **Fiat
  Topolino** and **Citroën Ami**, all homologated L6e. So the defect is not
  confined to obscure marques; three mainstream car brands currently have
  microcars published as mopeds.
- **STINT (3,142)** is a Dutch electric cargo platform, not a moped either.

**Published impact today: 62 records** under makes that build nothing but
microcars — `ligier` 19, `microcar` 13, `aixam` 12, `chatenet` 8, `casalini` 5,
`bellier` 3, `estrima` 2 — plus the Rocks-e/Topolino/Ami rows under their car
marques.

By contrast `Motorfiets` → `motorcycle` is **clean**: L3e only, 895,339
registrations, no mixing. So this is specifically a moped-kind problem, which is
useful — it means the fix is bounded.

### What the 2W side recommends

1. **Do not split `motorcycle`.** It is a faithful L3e.
2. **`moped` should mean L1e (+L2e).** L2e is a three-wheel *moped* and belongs
   with it — consistent with DECISIONS.md folding three-wheelers by capability
   rather than wheel count.
3. **L6e/L7e need a home.** Two options, and the 2W side has no strong preference
   because both are honest:
   - a reserved kind (`quadricycle`) activated the way `moped` was — DECISIONS.md
     already keeps `train`/`plane`/`ship`/`agricultural` reserved for exactly this;
   - or `car` with a `body_types: ["microcar"]` secondary, which matches how a
     buyer thinks about an Ami and keeps the kind count down.
4. **Whichever is chosen, the routing must key on EU category, not on
   `voertuigsoort`** — otherwise the next register with a different administrative
   word reintroduces the mix.
5. **`former_ids` covers the migration.** 62+ ids would change
   (`moped/aixam/a400` → `<newkind>/aixam/a400`); the mechanism shipped on
   2026-07-25 exists precisely for this and makes it an additive release.

### Why this was invisible until now

`kind_maps` are per-source and keyed on the source's own word, so nobody ever had
to look at the EU category column — and the aggregate the pipeline fetches for
`Bromfiets` does not even request it (only `merk`, `handelsbenaming`, `count`).
The evidence was one SODA parameter away and nothing pointed at it.

---

## 3. Four-wheel evidence — `Pkw`/M1 has no mass ceiling `[S4W]`

*Stub for S4W.* Expected content, from NEGOTIATION.md Turn 18: M1 is defined by
seat count with no mass limit, so Germany's `Personenkraftwagen` table
legitimately contains M1 van variants and motorhomes up to 26 t
(`SA/Wohnmobil`, 71,575 units = 2.5% of German Pkw in 2025); 79,534 registrations
recovered by routing 30 nameplates to `van`; and FZ 11.1's segment cut as the
cross-check that made it rigorous (399/399 Modellreihen reconcile;
`UTILITIES` is KBA's own car/van boundary).

---

## 4. What we are asking the owner to decide

1. **Is `kind` a legal-category axis or a marketing axis?** Everything else
   follows. Our shared recommendation: **derive `kind` from the EU category**, and
   treat the register's own vehicle-type word as a hint, not a source of truth.
2. **Where do L6e/L7e go** — new reserved kind, or `car` + `microcar` body type?
3. **Is a coordinated kind migration acceptable in one release**, given
   `former_ids` makes it additive rather than breaking?

Neither maintainer will act on this unilaterally. Both halves are otherwise
complete and green; this is the one open question that spans them.
