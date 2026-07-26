#!/usr/bin/env ruby
# frozen_string_literal: true
#
# lint_enrich.rb — validates overrides/enrich/<make>.yml (production runs,
# G23a; PRD-QUALITY §14.4). The pipeline's loader guards shape hard enough to
# never emit garbage; THIS is the curation-quality gate:
#
#   * every id key must be LIVE in the catalog (or be a former_ids alias
#     TARGET — the pending-publish window, same tolerance as lint_review)
#   * id keys are full kind/make/slug and the file is make-aligned (a volvo
#     fact in bmw.yml is a merge accident waiting to be missed)
#   * year sanity: 1885 <= year_start (Benz Patent-Motorwagen — nothing we
#     catalog predates it) ; year_end <= current year + 1 (next-model-year
#     announcements are real; anything later is a typo)
#   * runs sorted, non-overlapping (overlapping runs mean two sources
#     disagree — record the conflict in the note, do not encode it as data)
#   * EVERY id entry carries a same-line `#` citation on at least one of its
#     lines (the standing provenance rule; enrichment without provenance is
#     how open datasets rot — §14.1)
#
# Usage: ruby scripts/lint_enrich.rb    [VDB_CATALOG=… for a fresh build]

require "yaml"
require "json"
require "set"

ROOT = File.expand_path("..", __dir__)
CATALOG_DIR = ENV["VDB_CATALOG"] ? File.expand_path(ENV["VDB_CATALOG"]) : File.join(ROOT, "catalog")
KINDS = %w[car van motorcycle moped truck bus].freeze
MAX_YEAR = Time.now.year + 1
FAILURES = []
def fail!(m) = FAILURES << m

live = {}
KINDS.each do |k|
  p = File.join(CATALOG_DIR, k, "models.json")
  live[k] = File.exist?(p) ? JSON.parse(File.read(p)).map { |m| m["id"] }.to_set : Set.new
end
former = (YAML.safe_load_file(File.join(ROOT, "overrides/models/former_ids.yml")) || {})
         .transform_values { |v| v.is_a?(Hash) ? v["to"] : v }.compact
pending = former.values.to_set

files = Dir[File.join(ROOT, "overrides/enrich", "*.yml")].sort
entries = 0
seen_ids = {} # id => first file (the pipeline loader last-write-wins across files)
files.each do |abs|
  rel = abs.sub("#{ROOT}/", "")
  make_of_file = File.basename(abs, ".yml")
  raw_lines = File.readlines(abs)
  doc = begin
    YAML.safe_load_file(abs, permitted_classes: [], aliases: false) || {}
  rescue Psych::SyntaxError => e
    fail! "#{rel}: does not parse — #{e.message}"
    next
  end
  doc.each do |id, entry|
    entries += 1
    if (first = seen_ids[id.to_s])
      fail! "#{rel}: #{id} already defined in #{first} — the loader keeps only ONE silently"
    else
      seen_ids[id.to_s] = rel
    end
    kind, make, slug = id.to_s.split("/", 3)
    unless KINDS.include?(kind) && make && slug
      fail! "#{rel}: #{id.inspect} is not kind/make/slug"
      next
    end
    fail! "#{rel}: #{id} belongs in overrides/enrich/#{make}.yml (make-aligned files)" unless make == make_of_file
    unless live[kind].include?("#{make}/#{slug}") || pending.include?(id.to_s)
      fail! "#{rel}: #{id} is not live in the catalog being measured (and is not a pending-publish alias target)"
    end
    runs = entry.is_a?(Hash) ? entry["runs"] : nil
    unless runs.is_a?(Array) && runs.any?
      fail! "#{rel}: #{id}: expected {runs: [...]}"
      next
    end
    prev_end = nil
    runs.each do |r|
      ys, ye = r["year_start"], r["year_end"]
      fail! "#{rel}: #{id}: year_start #{ys.inspect} not an Integer" unless ys.is_a?(Integer)
      next unless ys.is_a?(Integer)
      fail! "#{rel}: #{id}: year_start #{ys} predates the Benz Patent-Motorwagen (1885) — typo?" if ys < 1885
      fail! "#{rel}: #{id}: year_end #{ye} beyond #{MAX_YEAR} — typo?" if ye.is_a?(Integer) && ye > MAX_YEAR
      fail! "#{rel}: #{id}: run #{ys}..#{ye} ends before it starts" if ye.is_a?(Integer) && ye < ys
      fail! "#{rel}: #{id}: runs out of order or overlapping (#{prev_end} then #{ys}) — sort them; if sources genuinely disagree, record the conflict in the note" if prev_end && ys <= prev_end
      prev_end = ye || MAX_YEAR
    end
    # Citation: at least one line of this entry's block carries a `#` comment.
    id_line = raw_lines.index { |l| l.start_with?("\"#{id}\":", "#{id}:") }
    if id_line
      block = raw_lines[id_line..].take_while.with_index { |l, i| i.zero? || l =~ /\A\s/ }
      fail! "#{rel}: #{id}: no citation — every enrichment fact carries its source on the line (§14.1)" unless block.any? { |l| l.include?("#") }
    end
  end
end

puts "enrich lint: #{files.size} files, #{entries} ids"
if FAILURES.any?
  FAILURES.each { |f| puts "LINT FAIL: #{f}" }
  puts "#{FAILURES.size} failure(s)."
  exit 1
else
  puts "enrich lint: OK"
end
