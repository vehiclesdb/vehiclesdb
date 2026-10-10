#!/usr/bin/env ruby
# frozen_string_literal: true
#
# gen_readme_stats.rb — write the release numbers into README.md and llms.txt
# from the release's own files, so no count in either is ever typed by hand.
#
#   ruby scripts/gen_readme_stats.rb            # rewrite the generated blocks in place
#   ruby scripts/gen_readme_stats.rb --check    # exit 1 if any block is stale (prints a diff hint)
#   ruby scripts/gen_readme_stats.rb --print    # print the blocks to stdout, touch nothing
#   VDB_DATA_ROOT=<dir> ruby scripts/gen_readme_stats.rb ...   # read/write another checkout
#
# WHY. The README carried a per-kind table (4,949 cars …) and "14 countries"
# two releases after both stopped being true, and llms.txt still said
# 18,556 models / 2026.07.0. People — and assistants — copy these numbers
# (OPEN-DATA-CONSUMERS 2026-10-10: three different model counts in circulation).
#
# WHAT IT READS (and nothing else):
#   manifest.json                 version, built_at, kinds{models,makes}, countries, sources[]
#   catalog/<kind>/makes.json     distinct make ids across kinds (the "makes" headline)
#   catalog/<kind>/models.json    per-country counts: a model counts in country C when its
#                                 availability[] has an entry with country C. manifest.json
#                                 carries no per-country counts, so they are counted here,
#                                 from the files manifest.json itself points at.
#
# WHAT IT WRITES: only the text between
#   <!-- BEGIN GENERATED: <name> (scripts/gen_readme_stats.rb) -->
#   <!-- END GENERATED: <name> -->
# in README.md (blocks: stats, load-postgres, cite), and the summary blockquote
# directly under llms.txt's title (no markers there; see splice_llms_summary). Everything
# outside the markers is hand-written prose and is left byte-for-byte alone. A
# missing marker pair is an error, not a silent skip.
#
# Stdlib only (json). Read-only on catalog/, dist/, manifest.json.

require "json"

ROOT = File.expand_path(ENV["VDB_DATA_ROOT"] || File.join(__dir__, ".."))

KIND_LABEL = {
  "car" => "car", "motorcycle" => "motorcycle", "moped" => "moped",
  "van" => "van", "truck" => "truck", "bus" => "bus"
}.freeze

# ISO 3166-1 alpha-2 (+ gb, which the catalog uses for the United Kingdom).
# Unknown codes fall back to the upper-cased code, so a new country never
# breaks the build — it just renders as "XX" until a name is added here.
COUNTRY_NAME = {
  "ar" => "Argentina", "at" => "Austria", "au" => "Australia", "be" => "Belgium",
  "br" => "Brazil", "ca" => "Canada", "ch" => "Switzerland", "cl" => "Chile",
  "co" => "Colombia", "cz" => "Czechia", "de" => "Germany", "dk" => "Denmark",
  "es" => "Spain", "fi" => "Finland", "fr" => "France", "gb" => "United Kingdom",
  "ie" => "Ireland", "il" => "Israel", "in" => "India", "it" => "Italy",
  "jp" => "Japan", "lu" => "Luxembourg", "ma" => "Morocco", "mx" => "Mexico",
  "my" => "Malaysia", "ng" => "Nigeria", "nl" => "Netherlands", "no" => "Norway",
  "nz" => "New Zealand", "pl" => "Poland", "pt" => "Portugal", "py" => "Paraguay",
  "ro" => "Romania", "se" => "Sweden", "sg" => "Singapore", "th" => "Thailand",
  "tr" => "Turkey", "ua" => "Ukraine", "us" => "United States", "za" => "South Africa"
}.freeze

def fmt(n) = n.to_s.reverse.scan(/\d{1,3}/).join(",").reverse

def read_json(rel)
  JSON.parse(File.read(File.join(ROOT, rel)))
rescue Errno::ENOENT
  abort "gen_readme_stats: missing #{rel} under #{ROOT}"
end

# ── facts ──────────────────────────────────────────────────────────────────

def facts
  m = read_json("manifest.json")
  kinds = m.fetch("kinds").keys
  catalog = m.fetch("catalog")

  make_ids = {}
  per_country = Hash.new { |h, k| h[k] = Hash.new(0) }
  models_total = 0
  kinds.each do |kind|
    kind_makes = read_json(catalog.dig(kind, "makes"))
    kind_makes.each { |mk| make_ids[mk.fetch("id")] = true }
    models = read_json(catalog.dig(kind, "models"))
    models_total += models.size
    want = m["kinds"][kind]
    if want["models"] != models.size || want["makes"] != kind_makes.size
      abort "gen_readme_stats: manifest.json kinds.#{kind} says #{want['models']} models / #{want['makes']} makes " \
            "but catalog/ holds #{models.size} / #{kind_makes.size} — refusing to write numbers from it"
    end
    models.each do |rec|
      (rec["availability"] || []).map { |a| a["country"] }.uniq.each { |cc| per_country[cc][kind] += 1 }
    end
  end

  stray = per_country.keys - m.fetch("countries")
  abort "gen_readme_stats: availability names countries absent from manifest.json countries: #{stray.sort.join(', ')}" if stray.any?

  manifest_total = m["kinds"].values.sum { |v| v.fetch("models") }
  if manifest_total != models_total
    abort "gen_readme_stats: manifest.json says #{manifest_total} models but catalog/ holds " \
          "#{models_total} — the tree is not one release; refusing to write numbers from it"
  end

  csv_rel = m.dig("dist", "vehicles_csv") or abort "gen_readme_stats: manifest.json has no dist.vehicles_csv"
  csv_header = File.open(File.join(ROOT, csv_rel), &:gets).to_s.strip.split(",")
  abort "gen_readme_stats: #{csv_rel} has no header" if csv_header.empty?

  {
    csv_header: csv_header,
    version: m.fetch("version"),
    built: m.fetch("built_at")[0, 10],
    year: m.fetch("built_at")[0, 4],
    kinds: kinds,
    kind_counts: m["kinds"],
    models: models_total,
    makes: make_ids.size,
    countries: m.fetch("countries"),
    sources: m.fetch("sources"),
    per_country: per_country
  }
end

# ── renderers ──────────────────────────────────────────────────────────────

def country_name(cc) = COUNTRY_NAME.fetch(cc, cc.upcase)

def headline(f)
  "**Dataset `#{f[:version]}`** (built #{f[:built]}) — **#{fmt(f[:models])} models · " \
    "#{fmt(f[:makes])} makes · #{f[:kinds].size} kinds · #{f[:countries].size} countries**"
end

def render_stats(f)
  out = []
  out << headline(f)
  out << ""
  out << "| kind | models | makes |"
  out << "|---|---:|---:|"
  f[:kinds].each do |k|
    out << "| #{KIND_LABEL.fetch(k, k)} | #{fmt(f[:kind_counts][k]['models'])} | #{fmt(f[:kind_counts][k]['makes'])} |"
  end
  out << "| **all** | **#{fmt(f[:models])}** | **#{fmt(f[:makes])}** distinct |"
  out << ""
  out << "Models with evidence in each country (a model counts once per country it is found in, " \
         "so the column does not sum to the total):"
  out << ""
  out << "| country | official source | licence | evidence | models | #{f[:kinds].join(' | ')} |"
  out << "|---|---|---|---|---:|#{'---:|' * f[:kinds].size}"
  by_cc = f[:sources].group_by { |s| s["country"] }
  rows = f[:countries].map { |cc| [cc, f[:per_country][cc].values.sum] }
  rows.sort_by { |cc, n| [-n, cc] }.each do |cc, n|
    srcs = by_cc.fetch(cc, [])
    src  = srcs.map { |s| "[#{s['name']}](#{s['url']})" }.join("<br>")
    lic  = srcs.map { |s| s["license_url"] ? "[#{s['license']}](#{s['license_url']})" : s["license"].to_s }.uniq.join("<br>")
    ev   = srcs.map { |s| s["evidence"] }.uniq.join(", ")
    cells = f[:kinds].map { |k| (v = f[:per_country][cc][k]).zero? ? "—" : fmt(v) }
    out << "| #{country_name(cc)} (`#{cc}`) | #{src} | #{lic} | #{ev} | #{fmt(n)} | #{cells.join(' | ')} |"
  end
  out << ""
  out << "`registration` = the vehicle is on that country's register; `approval` = type-approved " \
         "or certified for sale there. Full per-source notes: [SOURCES.md](SOURCES.md)."
  out.join("\n")
end

def render_cite(f)
  <<~MD.chomp
    > VehiclesDB. (#{f[:year]}). *VehiclesDB: The open source vehicle database*
    > (Version #{f[:version]}) [Data set]. Zenodo.
    > https://doi.org/10.5281/zenodo.21744943

    ```bibtex
    @misc{vehiclesdb,
      title        = {{VehiclesDB}: the open source vehicle database},
      author       = {{VehiclesDB}},
      year         = {#{f[:year]}},
      howpublished = {\\url{https://github.com/vehiclesdb/vehiclesdb}},
      doi          = {10.5281/zenodo.21744943},
      note         = {Open dataset, CC BY 4.0, version #{f[:version]}}
    }
    ```

    Replace the version with the one you actually used (`manifest.json` → `version`).
  MD
end

# The Postgres quick start is generated from the release's own CSV header, so
# the CREATE TABLE always has exactly the columns `\copy` will meet (the CSV
# only ever APPENDS columns — SCHEMA.md's growth contract — but COPY needs the
# count to match, so a hand-written column list breaks on the first append).
def pg_type(col) = col.end_with?("_decile") ? "smallint" : "text"

def render_postgres(f)
  cols = f[:csv_header]
  width = cols.map(&:size).max
  defs = cols.map { |c| "  #{c.ljust(width)} #{pg_type(c)}#{%w[kind make_slug model_slug make_name model_name].include?(c) ? ' NOT NULL' : ''}" }
  defs << "  PRIMARY KEY (kind, make_slug, model_slug)"
  v = f[:version]
  <<~MD.chomp
    ```bash
    curl -sSLO https://github.com/vehiclesdb/vehiclesdb/releases/download/v#{v}/vehicles.csv
    psql "$DATABASE_URL" <<'SQL'
    CREATE TABLE vehiclesdb_models (
    #{defs.join(",\n")}
    );
    \\copy vehiclesdb_models FROM 'vehicles.csv' WITH (FORMAT csv, HEADER true)
    SQL
    ```

    The column list above is generated from `v#{v}`'s CSV header. Since 2026.07.2, columns
    are only ever appended between releases, never renamed or reordered; when you upgrade, `ALTER TABLE …
    ADD COLUMN` the new ones (see CHANGELOG.md) and reload. `countries`, `regions`,
    `body_types`, `aliases` and `former_ids` are `|`-separated lists
    (`string_to_array(countries, '|')`).
  MD
end

def wrap_quote(text, width = 78)
  lines = [+""]
  text.split(/\s+/).each do |w|
    lines << +"" if !lines.last.empty? && lines.last.size + 1 + w.size > width
    lines.last << (lines.last.empty? ? w : " #{w}")
  end
  lines.map { |l| "> #{l}" }.join("\n")
end

# llms.txt has a fixed shape (H1, then ONE blockquote summary, then sections),
# and llms.txt readers look for the blockquote directly under the H1 — so this
# block takes no HTML-comment markers. It is the first `> ` paragraph after
# the first `# ` line; see splice_llms_summary.
def render_llms_stats(f)
  kinds = f[:kinds].map { |k| "#{k} #{fmt(f[:kind_counts][k]['models'])}" }.join(", ")
  names = f[:countries].map { |cc| country_name(cc) }.sort.join(", ")
  wrap_quote(
    "Open, CC-BY 4.0 vehicle taxonomy: #{fmt(f[:models])} models across #{fmt(f[:makes])} makes and " \
    "#{f[:kinds].size} kinds (#{kinds}), reconciled from official vehicle registers and type-approval " \
    "catalogues of #{f[:countries].size} countries (#{names}). Stable ids, per-country availability " \
    "evidence, measured popularity deciles. Versioned releases, usually monthly (current: #{f[:version]}, built #{f[:built]}). " \
    "A model is published only when two independent official sources corroborate it or one shows a " \
    "decisive registration count."
  )
end

BLOCKS = {
  "README.md" => { "stats" => :render_stats, "load-postgres" => :render_postgres, "cite" => :render_cite },
  "llms.txt" => { :llms_summary => :render_llms_stats }
}.freeze

def begin_marker(name) = "<!-- BEGIN GENERATED: #{name} (scripts/gen_readme_stats.rb) -->"
def end_marker(name) = "<!-- END GENERATED: #{name} -->"

def splice_llms_summary(text, body, file)
  lines = text.lines
  h1 = lines.index { |l| l.start_with?("# ") } or abort "gen_readme_stats: #{file} has no `# ` title line"
  first = (h1 + 1...lines.size).find { |i| lines[i].start_with?(">") }
  abort "gen_readme_stats: #{file} has no `> ` summary under its title" unless first
  between = lines[h1 + 1...first]
  abort "gen_readme_stats: #{file}: only blank lines may sit between the title and the summary" unless between.all? { |l| l.strip.empty? }
  last = first
  last += 1 while last + 1 < lines.size && lines[last + 1].start_with?(">")
  (lines[0...first] + [body + "\n"] + lines[(last + 1)..]).join
end

def splice(text, name, body, file)
  return splice_llms_summary(text, body, file) if name == :llms_summary

  b = begin_marker(name)
  e = end_marker(name)
  i = text.index(b) or abort "gen_readme_stats: #{file} has no `#{b}` marker"
  j = text.index(e, i) or abort "gen_readme_stats: #{file} has no `#{e}` marker after its BEGIN"
  abort "gen_readme_stats: #{file} has two `#{b}` markers" if text.index(b, i + 1)
  text[0, i + b.size] + "\n" + body + "\n" + text[j..]
end

def main(argv)
  bad = argv - %w[--check --print]
  abort "gen_readme_stats: unknown argument(s) #{bad.join(' ')} (use --check or --print)" if bad.any?
  mode = argv.include?("--check") ? :check : argv.include?("--print") ? :print : :write
  f = facts
  stale = []
  BLOCKS.each do |file, blocks|
    if mode == :print
      blocks.each { |name, fn| puts "## #{file} :: #{name}", send(fn, f), "" }
      next
    end
    path = File.join(ROOT, file)
    old = File.read(path)
    new = blocks.reduce(old) { |t, (name, fn)| splice(t, name, send(fn, f), file) }
    case mode
    when :check
      stale << file if new != old
    when :write
      File.write(path, new) if new != old
      puts "#{file}: #{new == old ? 'unchanged' : 'updated'} (#{f[:version]})"
    end
  end
  return 0 unless mode == :check

  if stale.empty?
    puts "gen_readme_stats: OK — #{BLOCKS.keys.join(', ')} match #{f[:version]}"
    0
  else
    puts "gen_readme_stats: STALE — #{stale.join(', ')} do not match manifest.json #{f[:version]}; " \
         "run `ruby scripts/gen_readme_stats.rb` and commit"
    1
  end
end

exit main(ARGV) if $PROGRAM_NAME == __FILE__
