#!/usr/bin/env ruby
# frozen_string_literal: true
#
# corpus_check_nl.rb — the plates dataset's REALITY gate for the Netherlands
# (PRD-PLATES §5: verification against registry truth). The RDW publishes the
# entire Dutch vehicle register as open data — real serials with real
# registration dates — which makes plate precision a MEASURED number instead
# of an asserted one. For a sample of real vehicles this script checks:
#
#   1. REGEX truth   — the serial (separator-less, as RDW publishes it)
#                      matches at least one nl series; strict where possible.
#   2. PERIOD truth  — at least one matching series' period contains the
#                      year the plate was plausibly issued. Both RDW dates
#                      are consulted (datum_eerste_toelating = first
#                      admission anywhere; datum_eerste_tenaamstelling_in_
#                      nederland = first NL registration, which is when an
#                      import receives its NL plate), with ±1y slack for
#                      year-boundary issuance. A row passes if EITHER date
#                      lands inside a matching series' period — imports make
#                      first-admission alone the wrong ruler.
#
# Failures are not necessarily data bugs (personalized/GAIK retentions and
# re-registrations exist) — they are a TRIAGE LIST, written to
# corpus-failures-nl.json. The self-correction loop: run → triage the
# failure classes → research agents draft evidence-backed fix PRs → this
# gate re-measures. Thresholds below fail the run loudly when precision
# drops; network trouble exits 2 (inconclusive), never green.
#
# Usage: ruby scripts/corpus_check_nl.rb [sample_size_per_page] [pages]
#   Defaults: 500 × 8 offsets = 4,000 real vehicles per run.

require "yaml"
require "json"
require "net/http"
require "uri"

ROOT = File.expand_path("..", __dir__)
SEPARATORS = /[\s\-–—·.]+/

# Separator stripping, ported verbatim from the vehicles gem
# (Vehicles::Plates::Series.strip_separators, 0.6.x): removes separator
# LITERALS respecting character classes; a class composed only of
# separators goes; a dangling quantifier goes with its separator.
SEPARATOR_TOKENS = [ " ", "-", "·", ".", '\s', '\-', '\.', '\ ' ].freeze
def strip_separators(src)
  out = +""
  chars = src.chars
  i = 0
  while i < chars.size
    ch = chars[i]
    if ch == "\\" && i + 1 < chars.size
      nxt = chars[i + 1]
      if [ "s", "-", ".", " " ].include?(nxt)
        i += 2
        i += 1 if [ "?", "*" ].include?(chars[i])
      else
        out << ch << nxt
        i += 2
      end
      next
    end
    if ch == "["
      closing = i + 1
      closing += 1 while closing < chars.size && chars[closing] != "]"
      content = chars[(i + 1)...closing].join
      tokens = content.scan(/\\.|./m)
      if tokens.any? && tokens.all? { |t| SEPARATOR_TOKENS.include?(t) }
        i = closing + 1
        i += 1 if [ "?", "*" ].include?(chars[i])
      else
        out << chars[i..closing].join
        i = closing + 1
      end
      next
    end
    if [ "-", " ", "·" ].include?(ch)
      i += 1
      i += 1 if [ "?", "*" ].include?(chars[i])
    else
      out << ch
      i += 1
    end
  end
  out
end

# --- load the nl series (same file lint gates) ------------------------------
doc = YAML.safe_load_file(File.join(ROOT, "plates", "nl.yml"))
SERIES = doc["series"].filter_map do |s|
  src = s.dig("format", "regex_strict") || s.dig("format", "regex")
  next nil unless src
  begin
    { id: s["id"], strict: !s.dig("format", "regex_strict").nil?,
      re: Regexp.new(strip_separators(src)),
      start: s.dig("period", "start"), end: s.dig("period", "end") }
  rescue RegexpError
    nil
  end
end
abort("no usable nl series") if SERIES.empty?

# --- pull the sample from RDW ----------------------------------------------
PER_PAGE = (ARGV[0] || 500).to_i
PAGES    = (ARGV[1] || 8).to_i
BASE = "https://opendata.rdw.nl/resource/m9d7-ebf2.json"
FIELDS = "kenteken,datum_eerste_toelating,datum_eerste_tenaamstelling_in_nederland"

rows = []
PAGES.times do |page|
  offset = page * 1_700_000 / [ PAGES - 1, 1 ].max # spread across ~14M rows
  uri = URI("#{BASE}?$select=#{FIELDS}&$order=:id&$limit=#{PER_PAGE}&$offset=#{offset}")
  res = begin
    Net::HTTP.get_response(uri)
  rescue StandardError => e
    warn "RDW fetch failed (#{e.class}: #{e.message}) — inconclusive"
    exit 2
  end
  unless res.is_a?(Net::HTTPSuccess)
    warn "RDW HTTP #{res.code} — inconclusive"
    exit 2
  end
  rows.concat(JSON.parse(res.body))
  sleep 0.5
end

# --- the two truths, row by row --------------------------------------------
def year(value)
  value.to_s[/\A(\d{4})/, 1]&.to_i
end

total = 0
regex_pass = 0
strict_pass = 0
period_pass = 0
failures = []

rows.each do |row|
  serial = row["kenteken"].to_s.upcase.gsub(SEPARATORS, "")
  next if serial.empty?
  total += 1

  hits = SERIES.select { |s| s[:re].match?(serial) }
  if hits.empty?
    failures << { serial: serial, kind: "no-series-matches", row: row }
    next
  end
  regex_pass += 1
  strict_pass += 1 if hits.any? { |h| h[:strict] }

  years = [ year(row["datum_eerste_toelating"]),
            year(row["datum_eerste_tenaamstelling_in_nederland"]) ].compact
  if years.empty?
    period_pass += 1 # nothing to check against — regex truth stands alone
    next
  end

  in_period = hits.any? do |h|
    lo = (h[:start] || 0) - 1
    hi = (h[:end] || Time.now.year) + 1
    years.any? { |y| y.between?(lo, hi) }
  end
  if in_period
    period_pass += 1
  else
    failures << { serial: serial, kind: "no-series-period-covers-issuance",
                  series: hits.map { |h| "#{h[:id]} #{h[:start]}-#{h[:end] || 'open'}" },
                  years: years, row: row }
  end
end

# --- report + thresholds ----------------------------------------------------
pct = ->(n) { total.zero? ? 0.0 : (100.0 * n / total).round(3) }
puts "nl corpus: #{total} real vehicles sampled from the RDW register"
puts "nl corpus: regex truth   #{regex_pass}/#{total} (#{pct.call(regex_pass)}%) — strict #{pct.call(strict_pass)}%"
puts "nl corpus: period truth  #{period_pass}/#{total} (#{pct.call(period_pass)}%)"

if failures.any?
  out = File.join(ROOT, "corpus-failures-nl.json")
  File.write(out, JSON.pretty_generate(failures.first(200)))
  puts "nl corpus: #{failures.size} failures written to corpus-failures-nl.json (triage list, first 200)"
end

REGEX_FLOOR  = 99.5
PERIOD_FLOOR = 99.0
if pct.call(regex_pass) < REGEX_FLOOR || pct.call(period_pass) < PERIOD_FLOOR
  puts "nl corpus: FAIL — precision under floor (regex >= #{REGEX_FLOOR}%, period >= #{PERIOD_FLOOR}%)"
  exit 1
end
puts "nl corpus: OK"
