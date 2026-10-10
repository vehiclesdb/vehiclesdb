#!/usr/bin/env ruby
# frozen_string_literal: true
#
# release_diff_by_country.rb — what a release changed, PER COUNTRY and PER KIND,
# in the words a builder in that country needs ("Norway: +2,900 models, new
# source"). Companion to release_diff.rb (which is the per-kind §16 publish
# review); this one writes the CHANGELOG's per-country section.
#
#   # two published releases (git refs in this repo: tags, branches, SHAs)
#   ruby scripts/release_diff_by_country.rb --from v2026.09.1 --to v2026.10.0
#   # the last release vs a fresh build output (a dir holding manifest.json + catalog/)
#   ruby scripts/release_diff_by_country.rb --from v2026.10.0 --to-dir <pipeline>/build/out
#   # options
#     --from REF | --from-dir DIR     the older release      (default: the newest v* tag)
#     --to REF   | --to-dir DIR       the newer release      (default: the working tree, i.e. --to-dir .)
#     --format md|json|tsv            md = CHANGELOG-ready section (default)
#     --ids N                         md only: list up to N ids per country and category (default 0)
#
# DEFINITIONS (a model "is in" country C when its availability[] has an entry
# with country C; ids are compared as "<kind>/<id>", so a kind move counts):
#   new       id absent from FROM, present in TO, and not the successor of a
#             renamed id                                  -> counted in TO's countries
#   renamed   id present in FROM, absent from TO, and listed in some TO record's
#             former_ids (the release's own migration alias) -> counted in FROM's
#             countries; its successor is not also counted as new
#   renamed_in  the NEW id a renamed id now lives under      -> TO's countries
#             (a rename onto a fresh slug: one renamed out, one renamed in)
#   retired   id present in FROM, absent from TO, no alias  -> FROM's countries
#   gained    id in both, C in TO's availability but not FROM's
#   lost      id in both, C in FROM's availability but not TO's
#   before / after / delta   number of models in C in FROM / TO
#   delta = new + gained − lost − renamed + renamed_in − retired — checked for
#           every (country, kind); the script exits 2 if it does not hold.
#   new source  a source id in TO's manifest that FROM's manifest lacks (its
#               country is flagged); a dropped source is flagged the same way.
#
# READ-ONLY. Stdlib only. Exit 0 on success, 2 on an internal inconsistency,
# 1 on bad arguments or missing files.

require "json"
require "open3"
require "optparse"
require "pathname"
require "shellwords"

ROOT = File.expand_path("..", __dir__)

# ISO 3166-1 alpha-2 (+ gb). Same table as scripts/gen_readme_stats.rb; unknown
# codes render upper-cased, so a new country never breaks the script.
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

CATEGORIES = %i[new gained lost renamed renamed_in retired].freeze

def fmt(n) = n.to_s.reverse.scan(/\d{1,3}/).join(",").reverse
def signed(n) = n.zero? ? "0" : (n.positive? ? "+#{fmt(n)}" : "−#{fmt(-n)}")
def n_of(n, one) = "#{fmt(n)} #{n == 1 ? one : "#{one}s"}"
def country_name(cc) = COUNTRY_NAME.fetch(cc, cc.upcase)

# ── release trees ───────────────────────────────────────────────────────────

# A release as published: manifest.json + the catalog files it indexes.
class Tree
  attr_reader :label, :flag, :arg # arg = the ref, or the dir relative to the repo root, for the replay command

  def manifest = @manifest ||= JSON.parse(read("manifest.json"))
  def version = manifest.fetch("version")

  # { "<kind>/<id>" => record }
  def models
    @models ||= manifest.fetch("catalog").each_with_object({}) do |(kind, paths), h|
      JSON.parse(read(paths.fetch("models"))).each { |m| h["#{kind}/#{m.fetch('id')}"] = m }
    end
  end
end

class GitTree < Tree
  def initialize(ref)
    @ref = ref
    @label = ref
    @arg = ref
    @flag = ""
    _, st = Open3.capture2e("git", "-C", ROOT, "rev-parse", "--verify", "--quiet", "#{ref}^{commit}")
    abort "release_diff_by_country: unknown git ref #{ref.inspect}" unless st.success?
  end

  def read(path)
    out, err, st = Open3.capture3("git", "-C", ROOT, "show", "#{@ref}:#{path}")
    abort "release_diff_by_country: #{@ref}:#{path} — #{err.strip}" unless st.success?
    out
  end
end

class DirTree < Tree
  def initialize(dir, label: File.basename(File.expand_path(dir)))
    @dir = File.expand_path(dir)
    @label = label
    # Relative to the repo root, where the replay command runs: replayable, and never a
    # machine-local absolute path in a public CHANGELOG (I-11 R3 + codex r3 P3).
    @arg = Pathname.new(@dir).relative_path_from(Pathname.new(ROOT)).to_s
    @flag = "-dir"
    abort "release_diff_by_country: no manifest.json in #{@dir}" unless File.file?(File.join(@dir, "manifest.json"))
  end

  def read(path) = File.read(File.join(@dir, path))
end

def newest_tag
  out, st = Open3.capture2("git", "-C", ROOT, "tag", "--list", "v*", "--sort=-v:refname")
  abort "release_diff_by_country: cannot list tags" unless st.success?
  out.lines.first&.strip or abort "release_diff_by_country: no v* tag; pass --from"
end

# ── diff ────────────────────────────────────────────────────────────────────

def countries_of(rec) = (rec["availability"] || []).map { |a| a["country"] }.uniq

def diff(from, to)
  fm = from.models
  tm = to.models
  successor = {} # old "<kind>/<id>" -> new "<kind>/<id>"
  tm.each do |key, rec|
    (rec["former_ids"] || []).each do |old|
      warn "release_diff_by_country: #{old} is aliased by both #{successor[old]} and #{key}" if successor.key?(old) && successor[old] != key
      successor[old] = key
    end
  end

  removed = fm.keys - tm.keys
  added = tm.keys - fm.keys
  renamed = removed.select { |k| successor.key?(k) }
  retired = removed - renamed
  # Successors that are NEW ids (a rename onto a fresh slug). A rename that folds
  # into a SURVIVING id is not a successor here: that id is counted by gained/lost.
  successors = renamed.map { |k| successor[k] }.reject { |k| fm.key?(k) }.to_h { |k| [k, true] }
  fresh = added.reject { |k| successors.key?(k) }

  # cell[cc][kind][category] = [ids]
  cell = Hash.new { |h, cc| h[cc] = Hash.new { |h2, k| h2[k] = Hash.new { |h3, c| h3[c] = [] } } }
  kind_of = ->(key) { key.split("/", 2).first }

  fresh.each { |k| countries_of(tm[k]).each { |cc| cell[cc][kind_of[k]][:new] << k } }
  retired.each { |k| countries_of(fm[k]).each { |cc| cell[cc][kind_of[k]][:retired] << k } }
  renamed.each { |k| countries_of(fm[k]).each { |cc| cell[cc][kind_of[k]][:renamed] << "#{k} → #{successor[k]}" } }
  (fm.keys & tm.keys).each do |k|
    a = countries_of(fm[k])
    b = countries_of(tm[k])
    (b - a).each { |cc| cell[cc][kind_of[k]][:gained] << k }
    (a - b).each { |cc| cell[cc][kind_of[k]][:lost] << k }
  end

  count = lambda do |models|
    h = Hash.new { |x, cc| x[cc] = Hash.new(0) }
    models.each { |key, rec| countries_of(rec).each { |cc| h[cc][kind_of[key]] += 1 } }
    h
  end
  before = count[fm]
  after = count[tm]

  successors.each_key { |k| countries_of(tm[k]).each { |cc| cell[cc][kind_of[k]][:renamed_in] << k } }

  kinds = (from.manifest["kinds"].keys | to.manifest["kinds"].keys)
  src_from = from.manifest.fetch("sources").to_h { |s| [s["id"], s] }
  src_to = to.manifest.fetch("sources").to_h { |s| [s["id"], s] }
  # A source added or dropped in a country with no models on either side still gets its row.
  src_ccs = (src_to.keys - src_from.keys).map { |id| src_to[id]["country"] } |
            (src_from.keys - src_to.keys).map { |id| src_from[id]["country"] }
  ccs = (before.keys | after.keys | cell.keys | src_ccs.compact).sort

  rows = ccs.map do |cc|
    per_kind = kinds.to_h do |kind|
      c = cell[cc][kind]
      b = before[cc][kind]
      a = after[cc][kind]
      expect = c[:new].size + c[:gained].size - c[:lost].size - c[:retired].size - c[:renamed].size + c[:renamed_in].size
      if a - b != expect
        warn "release_diff_by_country: identity broken for #{cc}/#{kind}: before #{b} after #{a} but categories give #{expect}"
        exit 2
      end
      [kind, { before: b, after: a, delta: a - b }.merge(CATEGORIES.to_h { |cat| [cat, c[cat].size] })]
    end
    total = %i[before after delta].to_h { |f| [f, per_kind.values.sum { |v| v[f] }] }
    CATEGORIES.each { |cat| total[cat] = per_kind.values.sum { |v| v[cat] } }
    new_src = (src_to.keys - src_from.keys).select { |id| src_to[id]["country"] == cc }
    gone_src = (src_from.keys - src_to.keys).select { |id| src_from[id]["country"] == cc }
    { country: cc, name: country_name(cc), total: total, kinds: per_kind,
      new_sources: new_src.map { |id| { id: id, name: src_to[id]["name"], license: src_to[id]["license"] } },
      dropped_sources: gone_src.map { |id| { id: id, name: src_from[id]["name"] } },
      ids: CATEGORIES.to_h { |cat| [cat, kinds.flat_map { |k| cell[cc][k][cat] }.sort] } }
  end

  { from: { label: from.label, flag: from.flag, arg: from.arg, version: from.version, models: fm.size },
    to: { label: to.label, flag: to.flag, arg: to.arg, version: to.version, models: tm.size },
    kinds: kinds,
    totals: { new: fresh.size, renamed: renamed.size, renamed_in: successors.size, retired: retired.size },
    countries: rows }
end

# ── output ──────────────────────────────────────────────────────────────────

def headline(r)
  t = r[:total]
  parts = [] # "+1,204 models"
  parts << "#{signed(t[:delta])} #{t[:delta].abs == 1 ? "model" : "models"} (#{fmt(t[:before])} → #{fmt(t[:after])})"
  why = []
  why << "new source: #{r[:new_sources].map { |s| s[:name] }.join(', ')}" if r[:new_sources].any?
  why << "source dropped: #{r[:dropped_sources].map { |s| s[:name] }.join(', ')}" if r[:dropped_sources].any?
  why << "#{n_of(t[:new], "new id")} seen here" if t[:new].positive?
  why << "#{n_of(t[:gained], "existing id")} newly seen here" if t[:gained].positive?
  why << "#{fmt(t[:lost])} no longer seen here" if t[:lost].positive?
  why << "#{fmt(t[:renamed])} renamed (aliased)" if t[:renamed].positive?
  why << "#{n_of(t[:renamed_in], "renamed id")} now under a new id here" if t[:renamed_in].positive?
  why << "#{fmt(t[:retired])} retired" if t[:retired].positive?
  "- **#{r[:name]}** (`#{r[:country]}`): #{parts.join}#{why.any? ? " — #{why.join('; ')}" : ''}"
end

def render_md(d, ids_cap)
  out = []
  out << "### Per-country changes (#{d[:from][:version]} → #{d[:to][:version]})"
  out << ""
  out << "Generated by `ruby scripts/release_diff_by_country.rb --from#{d[:from][:flag]} #{Shellwords.escape(d[:from][:arg])} " \
         "--to#{d[:to][:flag]} #{Shellwords.escape(d[:to][:arg])}`. " \
         "A model counts in a country when its record carries availability evidence there; " \
         "*new* = new id, *gained*/*lost* = an existing id started/stopped being seen there, " \
         "*renamed* = id retired with a `former_ids` alias to its successor, *renamed in* = that successor when it is a new id, *retired* = id removed without one. Each row adds up: before + new + gained − lost − renamed + renamed in − retired = after."
  out << ""
  tt = d[:totals]
  out << "Catalog: #{fmt(d[:from][:models])} → #{fmt(d[:to][:models])} models " \
         "(#{signed(d[:to][:models] - d[:from][:models])}): #{fmt(tt[:new])} new ids, " \
         "#{fmt(tt[:renamed_in])} new ids that succeed renamed ones, " \
         "#{fmt(tt[:renamed])} renamed with an alias, #{fmt(tt[:retired])} retired."
  out << ""
  changed = d[:countries].reject { |r| CATEGORIES.all? { |c| r[:total][c].zero? } && r[:total][:delta].zero? && r[:new_sources].empty? && r[:dropped_sources].empty? }
  changed.sort_by { |r| [-r[:total][:delta].abs, r[:country]] }.each { |r| out << headline(r) }
  out << "- No country changed." if changed.empty?
  out << ""
  out << "| country | before | after | Δ | new | gained | lost | renamed | renamed in | retired |"
  out << "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
  d[:countries].sort_by { |r| [-r[:total][:after], r[:country]] }.each do |r|
    t = r[:total]
    flag = r[:new_sources].any? ? " **new source**" : ""
    out << "| #{r[:name]} (`#{r[:country]}`)#{flag} | #{fmt(t[:before])} | #{fmt(t[:after])} | #{signed(t[:delta])} | " \
           "#{fmt(t[:new])} | #{fmt(t[:gained])} | #{fmt(t[:lost])} | #{fmt(t[:renamed])} | #{fmt(t[:renamed_in])} | #{fmt(t[:retired])} |"
  end
  out << ""
  out << "<details><summary>Δ per country and kind</summary>"
  out << ""
  out << "| country | #{d[:kinds].join(' | ')} |"
  out << "|---|#{'---:|' * d[:kinds].size}"
  d[:countries].sort_by { |r| [-r[:total][:after], r[:country]] }.each do |r|
    cells = d[:kinds].map do |k|
      v = r[:kinds][k]
      next "—" if v[:before].zero? && v[:after].zero?
      "#{signed(v[:delta])} (#{fmt(v[:after])})"
    end
    out << "| #{r[:name]} (`#{r[:country]}`) | #{cells.join(' | ')} |"
  end
  out << ""
  out << "Cell = Δ (models after). </details>"
  if ids_cap.positive?
    d[:countries].each do |r|
      next if CATEGORIES.all? { |c| r[:ids][c].empty? }

      out << ""
      out << "<details><summary>#{r[:name]} (`#{r[:country]}`) — ids</summary>"
      out << ""
      CATEGORIES.each do |c|
        list = r[:ids][c]
        next if list.empty?

        shown = list.first(ids_cap).map { |i| "`#{i}`" }.join(", ")
        more = list.size > ids_cap ? " … and #{fmt(list.size - ids_cap)} more" : ""
        out << "- #{c} (#{fmt(list.size)}): #{shown}#{more}"
      end
      out << ""
      out << "</details>"
    end
  end
  out.join("\n")
end

def render_tsv(d)
  lines = [(%w[country kind before after delta] + CATEGORIES.map(&:to_s)).join("\t")]
  d[:countries].each do |r|
    d[:kinds].each do |k|
      v = r[:kinds][k]
      next if v.values.all?(&:zero?)

      lines << [r[:country], k, v[:before], v[:after], v[:delta], *CATEGORIES.map { |c| v[c] }].join("\t")
    end
  end
  lines.join("\n")
end

# ── main ────────────────────────────────────────────────────────────────────

def main(argv)
  o = { format: "md", ids: 0 }
  OptionParser.new do |op|
    op.on("--from REF") { |v| o[:from] = GitTree.new(v) }
    op.on("--from-dir DIR") { |v| o[:from] = DirTree.new(v) }
    op.on("--to REF") { |v| o[:to] = GitTree.new(v) }
    op.on("--to-dir DIR") { |v| o[:to] = DirTree.new(v) }
    op.on("--format FMT", %w[md json tsv]) { |v| o[:format] = v }
    op.on("--ids N", Integer) { |v| o[:ids] = v }
  end.parse!(argv)
  o[:from] ||= GitTree.new(newest_tag)
  o[:to] ||= DirTree.new(ROOT, label: ".")

  d = diff(o[:from], o[:to])
  case o[:format]
  when "json" then puts JSON.pretty_generate(d)
  when "tsv" then puts render_tsv(d)
  else puts render_md(d, o[:ids])
  end
  0
rescue OptionParser::ParseError => e
  warn "release_diff_by_country: #{e.message}"
  1
end

exit main(ARGV) if $PROGRAM_NAME == __FILE__
