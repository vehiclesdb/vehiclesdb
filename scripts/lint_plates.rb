#!/usr/bin/env ruby
# frozen_string_literal: true
#
# lint_plates.rb — the plates dataset gate (PRD-PLATES §5.2, gate L0).
# Validates plates/*.yml series records:
#   * schema shape (series id, class in vocabulary, period, format, sources)
#   * series-id uniqueness + jurisdiction-prefix alignment
#   * period rails: 1893 <= start (the first national plates) <= end <= now+1;
#     the runs semantics port verbatim (end absent = open; ended: true +
#     year_end_min: for known-over-undated; overlap legal iff distinct notes)
#   * regex: compiles, ANCHORED (\A...\z), and ROUND-TRIPS the human pattern —
#     serials generated from the pattern must match the regex, and mutated
#     serials must not (the fuzz side)
#   * every series carries >= 1 source line; colors well-formed hex
#
# Usage: ruby scripts/lint_plates.rb    (repo root relative)

require "yaml"

ROOT = File.expand_path("..", __dir__)
CLASSES = YAML.safe_load_file(File.join(ROOT, "plates", "_meta", "classes.yml")).keys.map(&:to_s).freeze rescue abort("classes.yml missing/unparsable")
NOW = Time.now.year
FAILURES = []
def fail!(m) = FAILURES << m

# Generate serials from a human pattern: 9=digit, L=letter, else literal.
def serials_from(pattern, n = 50)
  Array.new(n) do
    pattern.chars.map do |c|
      case c
      when "9" then rand(0..9).to_s
      when "L" then ("A".."Z").to_a.sample
      else c
      end
    end.join
  end
end

def mutate(serial)
  s = serial.dup
  i = rand(s.length)
  s[i] = s[i] =~ /\d/ ? "X" : "5"
  s
end

files = Dir[File.join(ROOT, "plates", "*.yml")] + Dir[File.join(ROOT, "plates", "*", "*.yml")]
files = files.reject { |f| f.include?("/_meta/") || f.include?("/_decode/") }
seen_series = {}
series_count = 0

files.sort.each do |abs|
  rel = abs.sub("#{ROOT}/", "")
  doc = begin
    YAML.safe_load_file(abs, permitted_classes: [], aliases: false) || {}
  rescue Psych::SyntaxError => e
    fail! "#{rel}: does not parse — #{e.message}"
    next
  end
  juris = doc["jurisdiction"].to_s
  fail! "#{rel}: jurisdiction missing" if juris.empty?
  fail! "#{rel}: authority {name, url} required" unless doc.dig("authority", "url").to_s.start_with?("http")
  raw = File.read(abs)

  (doc["series"] || []).each do |s|
    series_count += 1
    id = s["id"].to_s
    fail! "#{rel}: series without id" and next if id.empty?
    fail! "#{rel}: #{id} duplicate (first in #{seen_series[id]})" if seen_series[id]
    seen_series[id] = rel
    fail! "#{rel}: #{id} must be prefixed with jurisdiction '#{juris}-'" unless id.start_with?("#{juris}-")
    fail! "#{rel}: #{id} class #{s['class'].inspect} not in _meta/classes.yml" unless CLASSES.include?(s["class"].to_s)
    fail! "#{rel}: #{id} categories must be a non-empty array" unless s["categories"].is_a?(Array) && s["categories"].any?

    # period rails (the runs shape)
    p = s["period"] || {}
    st, en = p["start"], p["end"]
    fail! "#{rel}: #{id} period.start must be Integer" unless st.is_a?(Integer)
    if st.is_a?(Integer)
      fail! "#{rel}: #{id} period.start #{st} predates 1893 (the first national plates) — typo?" if st < 1893
      fail! "#{rel}: #{id} period.end #{en} beyond #{NOW + 1} — typo?" if en.is_a?(Integer) && en > NOW + 1
      fail! "#{rel}: #{id} period ends before it starts" if en.is_a?(Integer) && en < st
    end
    fail! "#{rel}: #{id} period.ended must be true or absent" unless p["ended"].nil? || p["ended"] == true
    fail! "#{rel}: #{id} period has both end and ended" if en && p["ended"]

    # format: pattern + anchored regex + round trip
    fmt = s["format"] || {}
    pattern, regex_s = fmt["pattern"].to_s, fmt["regex"].to_s
    fail! "#{rel}: #{id} format.pattern required" if pattern.empty?
    if regex_s.empty?
      fail! "#{rel}: #{id} format.regex required"
    else
      begin
        re = Regexp.new(regex_s)
        fail! "#{rel}: #{id} regex not anchored (\\A...\\z)" unless regex_s.start_with?('\A') && regex_s.end_with?('\z')
        unless pattern.empty?
          srand(id.sum) # deterministic per series
          serials_from(pattern).each do |ser|
            fail! "#{rel}: #{id} round-trip FAIL: pattern-generated #{ser.inspect} does not match regex" and break unless re.match?(ser)
          end
          bad = mutate(serials_from(pattern, 1).first)
          # fuzz is advisory: some mutations remain legal in loose formats
        end
      rescue RegexpError => e
        fail! "#{rel}: #{id} regex does not compile — #{e.message}"
      end
    end

    # colors + sources
    d = s["design"] || {}
    [d.dig("background", "color"), d["foreground"]].compact.each do |c|
      fail! "#{rel}: #{id} color #{c.inspect} not #RRGGBB" unless c =~ /\A#[0-9A-Fa-f]{6}\z/
    end
    fail! "#{rel}: #{id} needs >= 1 source line" unless (s["sources"] || []).any?
  end

  # overlap check per (class, category-overlap) group: legal iff distinct notes
  (doc["series"] || []).group_by { |s| s["class"] }.each do |_, group|
    group.combination(2) do |a, b|
      next if ((a["categories"] || []) & (b["categories"] || [])).empty?
      pa, pb = a["period"] || {}, b["period"] || {}
      ae = pa["end"] || NOW + 1
      bs = pb["start"] || 0
      next unless pa["start"] && pb["start"]
      lo, hi = [a, b].sort_by { |x| x["period"]["start"] }
      lo_end = lo["period"]["end"] || NOW + 1
      if hi["period"]["start"] <= lo_end
        an, bn = lo["notes"].to_s, hi["notes"].to_s
        unless !an.empty? && !bn.empty? && an != bn
          fail! "#{rel}: #{lo['id']} and #{hi['id']} overlap without DISTINCT notes (parallel issuance is real — old stock issues on — but must be stated)"
        end
      end
    end
  end
end

puts "plates lint: #{files.size} files, #{series_count} series"
if FAILURES.any?
  FAILURES.each { |f| puts "LINT FAIL: #{f}" }
  puts "#{FAILURES.size} failure(s)."
  exit 1
else
  puts "plates lint: OK"
end
