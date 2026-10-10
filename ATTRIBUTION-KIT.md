# Attribution kit — credit VehiclesDB in one paste

You are using the open VehiclesDB dataset. Thank you. This page gives you the
canonical credit line, ready to paste, in 12 languages, plus a badge.

## The requirement (stated once)

As [ATTRIBUTION.md](ATTRIBUTION.md) puts it: *"Attribution is a CONDITION of
the CC-BY 4.0 license (§3(a)) — every public use of this data must visibly
credit VehiclesDB with a link."*

In practice: wherever people can see data that came from VehiclesDB, show the
line below with a working link to `https://vehiclesdb.com`. That is all.

Two notes, also from the files that govern this:

- The **upstream register notices** in [ATTRIBUTION.md](ATTRIBUTION.md) (KBA,
  DVLA, Traficom and the others) apply to every consumer under every
  VehiclesDB licence. The simplest way to honour them is to link
  ATTRIBUTION.md from your credits or about page, or to ship it beside the
  data if you redistribute the files.
- A commercial license (vehiclesdb.com) waives only the VehiclesDB credit;
  upstream register notices (ATTRIBUTION.md) always apply.

## Website footer (HTML)

```html
<a href="https://vehiclesdb.com">Vehicle data by VehiclesDB</a>
```

Better still, link the page you actually used, e.g. on a SEAT León page:
`<a href="https://vehiclesdb.com/cars/seat/leon">SEAT León — VehiclesDB</a>`.

## The same line in 12 languages

Use the one that matches your page. The English line is the form
ATTRIBUTION.md requests; the others are translations of it. Machine-readable
copy (text, HTML, Markdown and app form for every language):
[`assets/attribution/footers.json`](assets/attribution/footers.json).

| code | language | text | HTML |
|---|---|---|---|
| `en` | English | Vehicle data by VehiclesDB | `<a href="https://vehiclesdb.com">Vehicle data by VehiclesDB</a>` |
| `es` | Español | Datos de vehículos por VehiclesDB | `<a href="https://vehiclesdb.com">Datos de vehículos por VehiclesDB</a>` |
| `fr` | Français | Données véhicules fournies par VehiclesDB | `<a href="https://vehiclesdb.com">Données véhicules fournies par VehiclesDB</a>` |
| `de` | Deutsch | Fahrzeugdaten von VehiclesDB | `<a href="https://vehiclesdb.com">Fahrzeugdaten von VehiclesDB</a>` |
| `pt` | Português | Dados de veículos por VehiclesDB | `<a href="https://vehiclesdb.com">Dados de veículos por VehiclesDB</a>` |
| `it` | Italiano | Dati sui veicoli forniti da VehiclesDB | `<a href="https://vehiclesdb.com">Dati sui veicoli forniti da VehiclesDB</a>` |
| `ro` | Română | Date despre vehicule furnizate de VehiclesDB | `<a href="https://vehiclesdb.com">Date despre vehicule furnizate de VehiclesDB</a>` |
| `tr` | Türkçe | Araç verileri: VehiclesDB | `<a href="https://vehiclesdb.com">Araç verileri: VehiclesDB</a>` |
| `pl` | Polski | Dane o pojazdach: VehiclesDB | `<a href="https://vehiclesdb.com">Dane o pojazdach: VehiclesDB</a>` |
| `uk` | Українська | Дані про транспортні засоби: VehiclesDB | `<a href="https://vehiclesdb.com">Дані про транспортні засоби: VehiclesDB</a>` |
| `hu` | Magyar | Járműadatok: VehiclesDB | `<a href="https://vehiclesdb.com">Járműadatok: VehiclesDB</a>` |
| `nl` | Nederlands | Voertuiggegevens van VehiclesDB | `<a href="https://vehiclesdb.com">Voertuiggegevens van VehiclesDB</a>` |

Multilingual site? Pick the line by the page's language, for example
(JavaScript, using the JSON above):

```js
const footers = await (await fetch("/vendor/vehiclesdb/footers.json")).json();
const lang = (document.documentElement.lang || "en").slice(0, 2);
const f = footers.languages[lang] || footers.languages.en;
document.querySelector("#vehicle-credit").innerHTML = f.html;
```

## Markdown (READMEs, docs, blogs)

```markdown
Vehicle data by [VehiclesDB](https://vehiclesdb.com) (CC BY 4.0)
```

## Badge

![Vehicle data by VehiclesDB](assets/attribution/badge.svg)

A static SVG (`assets/attribution/badge.svg`, about 1 KB). Copy it into your
own assets and link it:

```html
<a href="https://vehiclesdb.com"><img src="/img/vehiclesdb-badge.svg" alt="Vehicle data by VehiclesDB" width="168" height="20"></a>
```

For a GitHub README, either use the same file from the CDN:

```markdown
[![Vehicle data by VehiclesDB](https://cdn.jsdelivr.net/gh/vehiclesdb/vehiclesdb@main/assets/attribution/badge.svg)](https://vehiclesdb.com)
```

or the shields.io badge the attribution page offers:

```markdown
[![Vehicle data: VehiclesDB](https://img.shields.io/badge/vehicle%20data-VehiclesDB-blue)](https://vehiclesdb.com)
```

The badge does not replace the link: it must sit inside `<a href="https://vehiclesdb.com">`.

## Apps and anything without a website

Name us visibly in the app description or an about/credits screen, in your
app's language (the `app` field of `footers.json`):

```
Vehicle data by VehiclesDB (vehiclesdb.com)
```

## Papers, datasets, journalism

Cite the repository and the dataset version you used (`manifest.json` →
`version`). GitHub's "Cite this repository" button (from
[CITATION.cff](CITATION.cff)) gives APA and BibTeX; the README's *Citing this
dataset* section has both, filled in for the current release.

## Already crediting us?

Thank you. If your public repository or site credits VehiclesDB, open a PR
adding one row to *Built with VehiclesDB* in the [README](README.md).

More detail, including API consumers:
[vehiclesdb.com/attribution](https://vehiclesdb.com/attribution).
