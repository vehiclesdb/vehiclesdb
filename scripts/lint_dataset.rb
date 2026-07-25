#!/usr/bin/env ruby
# frozen_string_literal: true
#
# lint_dataset.rb — name-shape audit of the PUBLISHED catalog.
#
# WHY THIS EXISTS. overrides/ can only name strings that already exist. Every
# fresh ingest invents new ones, so a curation layer alone can never keep the
# dataset clean — the same junk shapes come back under new spellings. This
# script encodes the SHAPES instead of the strings, so next month's garbage
# shows up as a diff instead of as a rank-1 model.
#
# It was written after two incidents in one day (2026-07-25):
#   * a leaky xlsx regex published Germany's model names as shared-string
#     indices — 148 records, `volkswagen/552` was the Golf;
#   * a curation pass then proposed deleting those records as "junk type-codes",
#     and an earlier merged pass had already deleted SEAT's German lineup that way.
# Both were shape problems visible from the catalog alone. Nothing was watching.
#
# TWO BUCKETS, and the distinction is the whole point (NEGOTIATION.md Turn 7 §1):
#
#   legit — the shape is CORRECT and permanent. `MAZDA3` really is the nameplate.
#           Entries must be shape-general (a pattern, not four spellings) and
#           carry evidence, exactly like an override line.
#   debt  — the shape is WRONG and not fixed yet. Tracked with a count that may
#           only ever go DOWN. "Spotless" means `debt` is empty.
#
# One bucket would let us reach zero by relabelling junk as legitimate, which is
# how allowlists become landfills.
#
# Usage:
#   ruby scripts/lint_dataset.rb            # fail if unexplained suspects or debt grew
#   ruby scripts/lint_dataset.rb --report   # print the full report, always exit 0
#   ruby scripts/lint_dataset.rb --owner=s4w  # only my makes (see OWNERSHIP.yml)

require "json"
require "yaml"
require "set"

ROOT   = File.expand_path("..", __dir__)
# G13: the lint's baseline and its subject must be the SAME build. catalog/
# in the repo is the last RELEASE, which lags merged overrides by up to a
# month — so "re-measure after the build" was a wait. VDB_CATALOG points the
# audit at a fresh build/out (e.g. VDB_CATALOG=~/…/pipeline/build/out/catalog)
# and turns it into a flag.
CATALOG_DIR = ENV["VDB_CATALOG"] ? File.expand_path(ENV["VDB_CATALOG"]) : File.join(ROOT, "catalog")
KINDS  = %w[car van motorcycle moped truck bus].freeze
REPORT = ARGV.include?("--report")
OWNER  = ARGV.find { |a| a.start_with?("--owner=") }&.split("=", 2)&.last
SHAPES_PATH = File.join(ROOT, "data", "name_shapes.yml")

def slugify(str)
  str.to_s.downcase.unicode_normalize(:nfkd).gsub(/\p{Mn}+/, "")
     .gsub(/[^a-z0-9]+/, "-").gsub(/(\A-|-\z)/, "")
end

# ── the shape detectors ──────────────────────────────────────────────────────
#
# Each returns a reason string when the name matches its shape, else nil. Order
# matters only for reporting: the first match wins so a record is counted once.
PLACEHOLDER = /\A(n\.?\s?a\.?|n\/a|nil|none|unknown|onbekend|inconnu|desconocido|xxx?|\?+|-+|tbd|test)\z/i
ARTIFACT    = /\b(insgesamt|zusammen|sonstige|übrige|uebrige|andere|total|totaal|overige|divers(e)?|others?|otros|varios|autres|summe|misc)\b/i
SPEC_TOKEN  = /\b(kwh|kw|ps|eur[o]?\s?[456]|euro[456]|abs|tdi|tdci|dci|hdi|cdi|tsi|tfsi|crdi|4wd|awd|4x4|2wd|automatic|automaat|manual|dsg|cvt|hev|phev|bev|mhev|plug-?in)\b/i
CODE_STRING = /\A[A-Z]{2,}[\s.-]?\d{2,4}[A-Z0-9-]{0,8}\z/i

DETECTORS = {
  "placeholder" => ->(name, _make) { "registry placeholder string, not a nameplate" if name.match?(PLACEHOLDER) },
  "table_artifact" => ->(name, _make) { "statistical table artifact (total/other/sum row parsed as a model)" if name.match?(ARTIFACT) },
  "make_as_model" => lambda do |name, make|
    "the model name is just the make name (registry wrote the make into the model column)" \
      if make && slugify(name) == slugify(make)
  end,
  "embedded_make" => lambda do |name, make|
    next nil unless make && slugify(make).length >= 3
    n = slugify(name).delete("-")
    m = slugify(make).delete("-")
    "model name repeats its own make prefix (prefix strip missed)" if n != m && n.start_with?(m)
  end,
  "numeric_only" => ->(name, _make) { "bare integer where a nameplate belongs — PARSER suspect before data suspect" if name.match?(/\A\d{1,4}\z/) },
  "spec_token" => ->(name, _make) { "powertrain/spec token left in the nameplate" if name.match?(SPEC_TOKEN) },
  "code_string" => ->(name, _make) { "registry code string (letters glued to digits), not a human nameplate" if name.match?(CODE_STRING) }
}.freeze

# ── load catalog + allowlist ─────────────────────────────────────────────────
models = []
makes  = {}
KINDS.each do |kind|
  mk_path = File.join(CATALOG_DIR, kind, "makes.json")
  md_path = File.join(CATALOG_DIR, kind, "models.json")
  next unless File.exist?(md_path)
  JSON.parse(File.read(mk_path)).each { |m| makes[[kind, m["id"]]] = m["name"] }
  JSON.parse(File.read(md_path)).each { |m| models << m.merge("_kind" => kind) }
end
abort "lint_dataset: no catalog found under #{ROOT}/catalog" if models.empty?

shapes = File.exist?(SHAPES_PATH) ? (YAML.safe_load_file(SHAPES_PATH, permitted_classes: [], aliases: false) || {}) : {}
legit  = shapes["legit"] || []
debt   = shapes["debt"] || []

own = File.exist?(File.join(ROOT, "OWNERSHIP.yml")) ? YAML.safe_load_file(File.join(ROOT, "OWNERSHIP.yml"), permitted_classes: [], aliases: false) : {}
owner_of = ((own["s4w"] || []).to_h { |m| [m, "s4w"] }).merge((own["s2w"] || []).to_h { |m| [m, "s2w"] })

def entry_matches?(entry, rec)
  return false if entry["make"] && entry["make"] != rec[:make_id]
  return false if entry["kind"] && entry["kind"] != rec[:kind]
  return false if entry["category"] && entry["category"] != rec[:category]
  return false if entry["owner"] && entry["owner"] != rec[:owner]
  # Corroboration conditions. The dataset's own publish rule is "≥2 independent
  # sources agree" (DECISIONS.md § Sources & evidence); the same standard tells
  # a real oddly-shaped nameplate from a parser artifact. Measured on the 4W
  # half: of 1,061 bare-integer names, 890 are corroborated (Peugeot 208,
  # Abarth 595, Mercedes 1824 trucks…) and 171 are thin — and the thin set is
  # almost exactly the KBA shared-string leak (audi/91, byd/131…).
  return false if entry["min_sources"] && rec[:sources].size < entry["min_sources"]
  return false if entry["min_countries"] && rec[:countries].size < entry["min_countries"]
  return false if entry["max_sources"] && rec[:sources].size > entry["max_sources"]
  if (pat = entry["pattern"])
    return Regexp.new(pat, Regexp::IGNORECASE).match?(rec[:name])
  end
  return entry["id_list"].include?(rec[:id]) if entry["id_list"]
  # No pattern and no id_list: the make/kind/category/corroboration conditions
  # above are the whole rule.
  %w[make kind category owner min_sources max_sources min_countries].any? { |k| entry.key?(k) }
end

# ── classify every record ────────────────────────────────────────────────────
suspects = []
models.each do |m|
  make_name = makes[[m["_kind"], m["make_id"]]]
  next if OWNER && owner_of[m["make_id"]] != OWNER
  DETECTORS.each do |category, detector|
    reason = detector.call(m["name"].to_s, make_name)
    next unless reason
    suspects << { id: m["id"], kind: m["_kind"], make_id: m["make_id"], name: m["name"],
                  category: category, reason: reason,
                  owner: owner_of[m["make_id"]] || "?",
                  countries: (m["availability"] || []).map { |a| a["country"] }.uniq,
                  sources: m["sources"] || [] }
    break
  end
end

explained_legit = []
explained_debt  = []
unexplained     = []
suspects.each do |s|
  if (e = legit.find { |entry| entry_matches?(entry, s) })
    explained_legit << s.merge(entry: e["id"])
  elsif (e = debt.find { |entry| entry_matches?(entry, s) })
    explained_debt << s.merge(entry: e["id"])
  else
    unexplained << s
  end
end

# ── drop-list effectiveness ──────────────────────────────────────────────────
#
# A `drop:` entry that silently fails leaves the make published. This replaces
# ~69 hand-written absence spotchecks with one rule that covers every entry,
# including ones nobody has written yet (NEGOTIATION.md Turn 7 §3).
#
# THE PENDING PROBLEM: catalog/ is a build output and the build is monthly, so a
# drop merged today is legitimately still published. We therefore only FAIL for
# entries that are older than the published catalog, using the commit that last
# touched dist/ as the cutoff (git, not "last green run" — a validate-only run
# publishes nothing; NEGOTIATION.md Turn 8 §1).
def transliterations(raw)
  a = raw.downcase
  plain  = a.tr("äöüàáâãåèéêëìíîïòóôõùúûñç", "aouaaaaaeeeeiiiiooooouuunc")
  german = a.gsub("ä", "ae").gsub("ö", "oe").gsub("ü", "ue").gsub("ß", "ss")
  [plain, german].map { |s| s.gsub(/[^a-z0-9]+/, "-").gsub(/(\A-|-\z)/, "") }.uniq
end

drops = YAML.safe_load_file(File.join(ROOT, "overrides/makes/drop.yml"), permitted_classes: [], aliases: false) || {}
published_cutoff = `git -C #{ROOT.inspect} log -1 --format=%ct -- dist/vehicles.csv 2>/dev/null`.to_i
blame = {}
if published_cutoff.positive?
  `git -C #{ROOT.inspect} blame --line-porcelain overrides/makes/drop.yml 2>/dev/null`.each_line do |l|
    @ts = l.split.last.to_i if l.start_with?("author-time ")
    next unless l.start_with?("\t")
    # Key by the ENTRY itself, not the whole line: matching by substring made
    # a fresh `- SEA` entry look old because an existing comment mentioned
    # "(SEA group)", so a pending drop was reported as a silent failure.
    entry = l.sub(/\A\t/, "").strip[/\A-\s*(.+?)\s*(#.*)?\z/, 1]
    blame[entry] = @ts if entry
  end
end

escapes = []
drops.each do |kind, list|
  (list || []).each do |raw|
    transliterations(raw).each do |slug|
      next unless makes.key?([kind, slug])
      n = models.count { |m| m["_kind"] == kind && m["make_id"] == slug }
      added = blame[raw]
      pending = published_cutoff.positive? && added && added > published_cutoff
      escapes << { kind: kind, raw: raw, slug: slug, models: n, pending: pending,
                   owner: owner_of[slug] || "?" }
    end
  end
end

# ── report ───────────────────────────────────────────────────────────────────
puts "=" * 78
puts "DATASET NAME-SHAPE AUDIT#{OWNER ? " (owner: #{OWNER})" : ''} — #{models.size} records, #{makes.size} make/kind pairs"
puts "=" * 78
puts format("  suspects: %d total → %d legit (allowlisted), %d tracked debt, %d UNEXPLAINED",
            suspects.size, explained_legit.size, explained_debt.size, unexplained.size)

by_cat = unexplained.group_by { |s| s[:category] }
by_cat.sort_by { |_, v| -v.size }.each do |cat, list|
  puts "\n── #{cat} (#{list.size}) ─ #{DETECTORS[cat].call(list.first[:name], 'x') || list.first[:reason]}"
  list.sort_by { |s| [s[:owner], s[:id]] }.first(REPORT ? 1000 : 15).each do |s|
    puts format("   %-4s %-11s %-34s %-22s %s", s[:owner], s[:kind], s[:id], s[:name][0, 22], s[:countries].join(","))
  end
  puts "   … #{list.size - 15} more (use --report)" if !REPORT && list.size > 15
end

unless explained_debt.empty?
  puts "\n── tracked debt by entry ─────────────────────────────────────────────"
  explained_debt.group_by { |s| s[:entry] }.sort_by { |_, v| -v.size }.each do |id, list|
    entry = debt.find { |e| e["id"] == id }
    declared = entry["count"]
    flag = declared && list.size > declared ? "  ← GREW (declared #{declared})" : ""
    puts format("   %-34s %5d records%s", id, list.size, flag)
  end
end

puts "\n── drop-list effectiveness (#{escapes.size} entries still published) ──"
if escapes.empty?
  puts "   every drop entry took effect"
else
  escapes.sort_by { |e| [e[:pending] ? 1 : 0, -e[:models]] }.each do |e|
    puts format("   %-4s %-5s %-24s → %-22s %3d models  %s",
                e[:owner], e[:kind], e[:raw], e[:slug], e[:models],
                e[:pending] ? "(pending a build — not a failure)" : "*** SILENT DROP FAILURE ***")
  end
end

# ── exit status ──────────────────────────────────────────────────────────────
real_escapes = escapes.reject { |e| e[:pending] }
grew = explained_debt.group_by { |s| s[:entry] }.select do |id, list|
  d = debt.find { |e| e["id"] == id }
  d && d["count"] && list.size > d["count"]
end

puts
if REPORT
  puts "report mode — exit 0 regardless. Unexplained: #{unexplained.size}, debt: #{explained_debt.size}, escapes: #{real_escapes.size}"
  exit 0
end

problems = []
problems << "#{unexplained.size} unexplained name-shape suspects (allowlist them as `legit` with evidence, record them as `debt`, or fix them)" unless unexplained.empty?
problems << "#{real_escapes.size} drop entries silently failed (make still published although the catalog postdates the entry)" unless real_escapes.empty?
problems << "debt grew for: #{grew.keys.join(', ')}" unless grew.empty?

if problems.empty?
  puts "dataset lint: OK — no unexplained shapes, no silent drop failures, debt did not grow"
  exit 0
else
  problems.each { |p| puts "LINT FAIL: #{p}" }
  exit 1
end
