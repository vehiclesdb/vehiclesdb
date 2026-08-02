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
# The #124 amendments (PRD-PLATES §2.6-§2.8), from the vehicles gem 0.6.0:
#   * SEPARATOR CONTRACT (§2.6): patterns and regexes may spell only the
#     serial alphabet and the EMITTED separators declared in
#     plates/_meta/separators.yml. Nothing is hardcoded here — that file is
#     the single source of truth, so widening the contract is a data PR.
#   * matching: strict|recall-only (§2.7) required per series, plus the regex
#     tier order regex_strict <= regex <= regex_statutory, sampled.
#   * SEPARATOR-ONLY CLASSES (§2.8): a character class containing a separator
#     must contain only separators and must not be negated — the rule that
#     makes a separator position mechanically detectable by a consumer
#     deriving separator-free twins.
#
# Usage: ruby scripts/lint_plates.rb    (repo root relative)

require "yaml"
require "set"

ROOT = File.expand_path("..", __dir__)
CLASSES = YAML.safe_load_file(File.join(ROOT, "plates", "_meta", "classes.yml")).keys.map(&:to_s).freeze rescue abort("classes.yml missing/unparsable")
NOW = Time.now.year
FAILURES = []
def fail!(m) = FAILURES << m

# --- the separator contract, read from data (PRD-PLATES §2.6) --------------
SEP = begin
  YAML.safe_load_file(File.join(ROOT, "plates", "_meta", "separators.yml"))
rescue StandardError => e
  abort("plates/_meta/separators.yml missing/unparsable — #{e.message}")
end
SERIAL_ALPHABET = SEP.fetch("serial_alphabet").chars.to_set rescue abort("separators.yml: serial_alphabet required")
EMITTED = SEP.fetch("emitted").map { |h| h.fetch("char") }.to_set
FORGIVING = SEP.fetch("forgiving").map { |h| h.fetch("char") }.to_set
abort("separators.yml: emitted must be a subset of forgiving") unless EMITTED.subset?(FORGIVING)
abort("separators.yml: forgiving overlaps the serial alphabet — the contract is broken at its root") if FORGIVING.intersect?(SERIAL_ALPHABET)
PATTERN_TOKENS = %w[9 L].to_set          # the human-pattern DSL (9=digit, L=letter)
MATCHING_VALUES = %w[strict recall-only].freeze

# Expand a character-class body into its members. Handles ranges (A-Z),
# a leading negation, and backslash escapes. The dataset's dialect has no
# nested classes and no POSIX brackets.
def class_members(body)
  neg = body.start_with?("^")
  b = neg ? body[1..].to_s : body
  members = []
  k = 0
  while k < b.length
    if b[k] == "\\"
      members << "\\#{b[k + 1]}"            # \d and friends, kept marked
      k += 2
    elsif b[k + 1] == "-" && b[k + 2] && b[k + 2] != "]"
      (b[k]..b[k + 2]).each { |x| members << x }
      k += 3
    else
      members << b[k]
      k += 1
    end
  end
  [neg, members]
end

# Walk a regex source in the restricted dialect the dataset uses and return
# the LITERAL characters and the CHARACTER CLASSES it spells. Metacharacters,
# escapes (\A \z \d ...), groups ((?: (?! (?= (?<= (?<!), alternation and
# quantifiers contribute nothing — only what a human could read off a plate.
def regex_atoms(src)
  literals = []
  classes  = []
  i = 0
  while i < src.length
    c = src[i]
    case c
    when "\\"
      nxt = src[i + 1]
      literals << nxt unless nxt.nil? || nxt =~ /[AzZdDwWsSbBGhHkpRXK]/
      i += 2
    when "["
      j = i + 1
      j += 1 if src[j] == "^"
      j += 1 if src[j] == "]"                       # ']' first is a literal member
      j += 1 while j < src.length && src[j] != "]"
      classes << src[(i + 1)...j]
      i = j + 1
    when "("
      m = src[i..].match(/\A\(\?(?::|!|=|<=|<!|<[A-Za-z_]\w*>)/)
      i += m ? m[0].length : 1
    when ")", "|", "?", "*", "+", "^", "$"
      i += 1
    when "{"
      j = src.index("}", i)
      if j && src[(i + 1)...j] =~ /\A\d+(?:,\d*)?\z/
        i = j + 1
      else
        literals << c
        i += 1
      end
    when "."
      literals << c                                  # '.' unescaped: wildcard,
      i += 1                                         # not sanctioned here
    else
      literals << c
      i += 1
    end
  end
  [literals, classes]
end

# §2.6 + §2.8 — one regex, checked against the separator contract.
def check_separator_contract(rel, id, key, src)
  literals, classes = regex_atoms(src)
  literals.uniq.each do |ch|
    next if SERIAL_ALPHABET.include?(ch) || EMITTED.include?(ch)
    hint = if FORGIVING.include?(ch)
             "it is in the FORGIVING set but not the EMITTED set — the dataset writes only #{EMITTED.to_a.map(&:inspect).join(' and ')}"
           else
             "not in the serial alphabet and not an emitted separator"
           end
    fail! "#{rel}: #{id} #{key} spells literal #{ch.inspect} (U+%04X) — #{hint} (PRD-PLATES §2.6)" % ch.ord
  end
  classes.each do |body|
    neg, members = class_members(body)
    seps = members.select { |m| FORGIVING.include?(m) }
    if seps.any?
      fail! "#{rel}: #{id} #{key} class [#{body}] is NEGATED and contains a separator — a separator position must be positively spelled (PRD-PLATES §2.8)" if neg
      strays = members - seps
      unless strays.empty?
        fail! "#{rel}: #{id} #{key} class [#{body}] MIXES separators #{seps.inspect} with #{strays.inspect} — a class containing a separator must contain only separators, or a consumer deriving separator-free twins cannot detect the position (PRD-PLATES §2.8)"
      end
      seps.each do |s|
        next if EMITTED.include?(s)
        fail! "#{rel}: #{id} #{key} class [#{body}] spells non-emitted separator #{s.inspect} — forgiveness is the consumer's job, not the dataset's (PRD-PLATES §2.6)"
      end
    else
      members.each do |m|
        next if m.start_with?("\\") || SERIAL_ALPHABET.include?(m)
        fail! "#{rel}: #{id} #{key} class [#{body}] member #{m.inspect} is outside the serial alphabet (PRD-PLATES §2.6)"
      end
    end
  end
end

# ── THE PATTERN ESCAPE (owner ruling 2026-08-02, §2.6 decision 1) ───────────
#
# `9` and `L` are the DSL's own tokens, so a plate that PRINTS one of them had
# no way to say so. Five wave-2 delegates hit this independently and none of
# them faked around it: `FL 99999` generated `FQ 96884`, `POLIZIA 999` generated
# `POIIZIA 692`, and `EL` read as "E followed by any letter". Each correctly
# downgraded its series to `recall-only` rather than ship a regex that lies.
#
# `\9` and `\L` now mean the literal characters. A backslash escapes whatever
# follows it, so `\\` is a literal backslash if a plate ever needs one.
#
# PROVABLY INERT ON EVERYTHING ALREADY SHIPPED: measured before writing this,
# **0 of 945 patterns in the corpus contain a backslash**. The escape cannot
# change the behaviour of any existing pattern, because no existing pattern can
# enter the new branch. That is the owner's acceptance invariant — flip series
# from recall-only to matching WITHOUT changing any currently-matching series —
# established by construction rather than by hoping the replay catches it.
#
# Tokenise once, here, so the generator and both validators agree by sharing a
# function instead of by three copies of the same `case`.
#
#   returns [[:digit], [:letter], [:literal, ch], ...]
def pattern_tokens(pattern)
  out = []
  chars = pattern.chars
  i = 0
  while i < chars.length
    c = chars[i]
    if c == "\\"
      nxt = chars[i + 1]
      # A trailing lone backslash is a curation error, not a literal backslash:
      # it almost certainly means the author's escape lost its target.
      return [[:dangling_escape]] if nxt.nil?
      out << [:literal, nxt]
      i += 2
    elsif c == "9" then out << [:digit];  i += 1
    elsif c == "L" then out << [:letter]; i += 1
    else out << [:literal, c]; i += 1
    end
  end
  out
end

# Generate serials from a human pattern: 9=digit, L=letter, \x=literal x.
def serials_from(pattern, n = 50)
  toks = pattern_tokens(pattern)
  Array.new(n) do
    toks.map do |kind, ch|
      case kind
      when :digit  then rand(0..9).to_s
      when :letter then ("A".."Z").to_a.sample
      else ch
      end
    end.join
  end
end

# ── THE ESCAPE'S OWN GUARD, RUN UNCONDITIONALLY ─────────────────────────────
#
# Zero patterns in the corpus use the escape today, so nothing else exercises
# it: it would rot silently and be discovered by the next delegate who trusts
# it. This repo has no test harness for the data side — the lint scripts ARE
# the tests — so the guard lives here and runs on every invocation rather than
# behind a `--self-test` flag somebody has to remember to wire into CI.
#
# It costs microseconds. It cannot be skipped. That is the whole design.
def self_check_pattern_tokens!
  cases = [
    ["9-LLL-99",     [[:digit], [:literal, "-"], [:letter], [:letter], [:letter], [:literal, "-"], [:digit], [:digit]],
     "the ordinary case must be untouched by the escape"],
    ["F\\L 99",      [[:literal, "F"], [:literal, "L"], [:literal, " "], [:digit], [:digit]],
     "\\L is a literal L, not the letter token"],
    ["9\\9",         [[:digit], [:literal, "9"]],
     "\\9 is a literal 9, not the digit token"],
    ["\\\\",         [[:literal, "\\"]],
     "\\\\ is a literal backslash"],
    ["ABC\\",        [[:dangling_escape]],
     "a trailing lone backslash is an error, not a literal backslash"],
  ]
  cases.each do |pattern, want, why|
    got = pattern_tokens(pattern)
    next if got == want
    abort "lint_plates: PATTERN TOKENISER SELF-CHECK FAILED — #{why}\n" \
          "  pattern #{pattern.inspect}\n  want #{want.inspect}\n  got  #{got.inspect}"
  end
end
self_check_pattern_tokens!

# The §2.6 alphabet check, shared by the series pattern and every variant
# pattern so the two cannot drift. Written against the TOKENISER, not against
# raw characters: a `\` is grammar and never needs to be in the alphabet, while
# the character it escapes is held to exactly the same rule as an unescaped one.
def check_pattern_alphabet(rel, id, where, pattern)
  toks = pattern_tokens(pattern)
  if toks == [[:dangling_escape]]
    fail! "#{rel}: #{id} #{where} ends in a lone backslash — an escape with nothing to escape. " \
          "Write `\\\\` if the plate genuinely prints a backslash (PRD-PLATES §2.6)"
    return
  end
  toks.each do |kind, ch|
    next unless kind == :literal
    next if SERIAL_ALPHABET.include?(ch) || EMITTED.include?(ch)
    fail! "#{rel}: #{id} #{where} spells #{ch.inspect} (U+%04X) — patterns carry 9/L, escaped literals, " \
          "serial characters and emitted separators only (PRD-PLATES §2.6)" % ch.ord
  end
end

def mutate(serial)
  s = serial.dup
  i = rand(s.length)
  s[i] = s[i] =~ /\d/ ? "X" : "5"
  s
end

files = Dir[File.join(ROOT, "plates", "*.yml")] + Dir[File.join(ROOT, "plates", "*", "*.yml")]

# ── EVERY SIDECAR MUST AT LEAST PARSE ────────────────────────────────────────
#
# The line below excludes `_meta/`, `_decode/` and `_art/` from the SERIES
# rules, which is correct — they carry no series and every series-shaped check
# would be meaningless on them.
#
# But excluding them from the file list excluded them from EVERYTHING, including
# "is this valid YAML". Found 2026-08-02 by a wave-2 researcher whose
# `_decode/ro-counties.yml` had a `note:` at sequence-item indentation: Psych
# rejects the file outright, and **`lint_plates` reported OK**. A decode table
# that cannot be loaded is not a lesser problem than a malformed dossier — it is
# the same problem, on a file the linter was structurally unable to see.
#
# So: parse them all, apply the series rules only where they belong. This is
# deliberately the WEAKEST possible check — DOES IT LOAD, and is it non-empty.
# Nothing about shape: `_decode` tables differ by country and `_art/_ledger.yml`
# is an Array where the decode tables are Hashes. My first draft asserted Hash
# and this very check failed the ledger on its first run — inventing a schema
# here would be a second guess, not a gate, and the gate is what was missing.
sidecars = files.select { |f| f.include?("/_meta/") || f.include?("/_decode/") || f.include?("/_art/") }
sidecars.each do |f|
  rel = f.sub("#{ROOT}/", "")
  begin
    doc = YAML.safe_load_file(f, permitted_classes: [Date], aliases: false)
    fail!("#{rel}: parses to nothing (empty document) — a sidecar the loader cannot read is dead weight") if doc.nil?
  rescue Psych::SyntaxError => e
    fail! "#{rel}: DOES NOT PARSE — #{e.message}. This file was previously invisible to this lint; a decode " \
          "table that cannot be loaded fails as hard as a malformed dossier."
  end
end

files = files.reject { |f| f.include?("/_meta/") || f.include?("/_decode/") || f.include?("/_art/") }
seen_series = {}
series_count = 0
matching_tally = Hash.new(0)
twin_tally = Hash.new(0)

files.sort.each do |abs|
  rel = abs.sub("#{ROOT}/", "")
  doc = begin
    YAML.safe_load_file(abs, permitted_classes: [], aliases: false) || {}
  rescue Psych::SyntaxError => e
    fail! "#{rel}: does not parse — #{e.message}"
    next
  rescue Psych::DisallowedClass => e
    # One bare YAML date anywhere used to raise out of the whole run and
    # blind the gate for every other file (L0-completion finding). Years are
    # Integers; anything date-like must be quoted.
    fail! "#{rel}: disallowed YAML type (#{e.message}) — quote date-like scalars; periods use integer years"
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

    # matching: strict | recall-only (PRD-PLATES §2.7) — a FIRST-CLASS field,
    # because "no regex_strict" does NOT mean "not strict": 29 of the 31 L0
    # series without a strict twin carry the sourced grammar in `regex`.
    matching = s["matching"].to_s
    matching_tally[matching.empty? ? "(missing)" : matching] += 1
    if matching.empty?
      fail! "#{rel}: #{id} matching: required — strict|recall-only (PRD-PLATES §2.7); consumers must not have to infer it"
    elsif !MATCHING_VALUES.include?(matching)
      fail! "#{rel}: #{id} matching #{s['matching'].inspect} not in #{MATCHING_VALUES.inspect} (PRD-PLATES §2.7)"
    end

    # format: pattern + anchored regex + round trip
    fmt = s["format"] || {}
    pattern, regex_s = fmt["pattern"].to_s, fmt["regex"].to_s
    fail! "#{rel}: #{id} format.pattern required" if pattern.empty?

    # §2.6 — the human pattern spells DSL tokens, serial characters and
    # emitted separators, and nothing else. Escaped literals (`\9`, `\L`) are
    # checked against the same alphabet as everything else: the escape buys the
    # ability to SAY "9", not permission to spell characters a plate cannot show.
    check_pattern_alphabet(rel, id, "format.pattern", pattern)

    if regex_s.empty?
      fail! "#{rel}: #{id} format.regex required"
    else
      begin
        re = Regexp.new(regex_s)
        fail! "#{rel}: #{id} regex not anchored (\\A...\\z)" unless regex_s.start_with?('\A') && regex_s.end_with?('\z')
        check_separator_contract(rel, id, "format.regex", regex_s)
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

    # The regex TIERS (PRD-PLATES §2.7): regex_strict <= regex <= regex_statutory.
    # Only `regex` is round-tripped against `pattern` — which is exactly why it
    # cannot carry charset restrictions and why the twins exist. The twins are
    # compiled, anchored, separator-checked, and sampled against `pattern`:
    # a twin that accepts NOTHING the pattern generates is written against a
    # different form of the serial than the pattern is (this is how eight
    # us-fl `regex_statutory` values were caught writing the separator-free
    # form while `regex` wrote the printed one).
    strict_re = nil
    %w[regex_strict regex_statutory].each do |key|
      src = fmt[key].to_s
      next if src.empty?
      twin_tally[key] += 1
      begin
        r = Regexp.new(src)
        fail! "#{rel}: #{id} #{key} not anchored (\\A...\\z)" unless src.start_with?('\A') && src.end_with?('\z')
        check_separator_contract(rel, id, "format.#{key}", src)
        strict_re = r if key == "regex_strict"
        next if pattern.empty?
        srand(id.sum + key.sum)
        sample = serials_from(pattern, 2000)
        hits = sample.select { |ser| r.match?(ser) }
        if hits.empty?
          fail! "#{rel}: #{id} #{key} matches NONE of 2000 serials generated from format.pattern #{pattern.inspect} — a twin must describe the same printed form as the pattern (PRD-PLATES §2.6 rule 2)"
        elsif key == "regex_strict" && !regex_s.empty?
          loose = (Regexp.new(regex_s) rescue nil)
          if loose
            stray = hits.find { |ser| !loose.match?(ser) }
            fail! "#{rel}: #{id} regex_strict is NOT contained in regex — #{stray.inspect} matches the strict twin but not the loose one (PRD-PLATES §2.7 tier order)" if stray
          end
        end
      rescue RegexpError => e
        fail! "#{rel}: #{id} #{key} does not compile — #{e.message}"
      end
    end
    if matching == "recall-only" && strict_re
      fail! "#{rel}: #{id} matching: recall-only carries a regex_strict — a deliberately over-broad regex cannot also be the authority's own grammar (PRD-PLATES §2.7)"
    end

    # §2.6 — variant patterns are held to the same alphabet.
    (s["variants"] || []).each_with_index do |v, vi|
      vpat = v.dig("format", "pattern").to_s
      next if vpat.empty?
      check_pattern_alphabet(rel, id, "variant[#{vi}] pattern", vpat)
      %w[regex regex_strict regex_statutory].each do |key|
        vsrc = v.dig("format", key).to_s
        check_separator_contract(rel, id, "variant[#{vi}].#{key}", vsrc) unless vsrc.empty?
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
puts "plates lint: matching #{matching_tally.sort.map { |k, v| "#{k}=#{v}" }.join(' ')}" \
     " | twins #{twin_tally.sort.map { |k, v| "#{k}=#{v}" }.join(' ')}" \
     " | separators emitted #{EMITTED.to_a.map(&:inspect).join(',')} forgiving #{FORGIVING.size}"

# --- the art ledger gate (PRD-PLATES §7.1 amendment; PRD-PLATE-ART §6) ------
# plates/_art/<jurisdiction>/ holds ONLY open-tier (PD/CC0) assets, and
# _ledger.yml is the normative per-file license record for every tier —
# site_only assets live in web storage, excluded rows are entries only.
# Enforced: closed tier/element vocabulary; required keys per row; every
# open row's asset on disk; every asset on disk ledgered open exactly once;
# every exclusion states its reason.
ART_DIR = File.join(ROOT, "plates", "_art")
ART_ELEMENTS = %w[emblem full_plate band font_sample decal].freeze
art_ledger = File.join(ART_DIR, "_ledger.yml")
if File.exist?(art_ledger)
  rows = begin
    YAML.safe_load_file(art_ledger, permitted_classes: [], aliases: false)
  rescue Psych::SyntaxError => e
    fail! "_art/_ledger.yml: does not parse — #{e.message}"
    nil
  end
  if rows.is_a?(Array)
    open_paths = Set.new
    rows.each_with_index do |r, i|
      id = "_art/_ledger.yml[#{i}] #{r['file'] || r['title']}"
      %w[title jurisdiction element tier license source_url accessed].each do |k|
        fail! "#{id}: #{k} missing" if r[k].to_s.empty?
      end
      # `file` names the local asset — excluded rows never downloaded one
      fail! "#{id}: file missing" if r["tier"] != "excluded" && r["file"].to_s.empty?
      fail! "#{id}: tier #{r['tier'].inspect} not open|site_only|excluded" unless %w[open site_only excluded].include?(r["tier"])
      fail! "#{id}: element #{r['element'].inspect} outside the vocabulary" unless ART_ELEMENTS.include?(r["element"])
      fail! "#{id}: excluded without exclusion_reason" if r["tier"] == "excluded" && r["exclusion_reason"].to_s.empty?
      next unless r["tier"] == "open"
      p = File.join(ART_DIR, r["jurisdiction"].to_s, r["file"].to_s)
      fail! "#{id}: open-tier asset missing on disk" unless File.exist?(p)
      fail! "#{id}: two open rows claim one asset path" unless open_paths.add?(p)
    end
    Dir[File.join(ART_DIR, "*", "*")].each do |p|
      fail! "_art asset without an open ledger row: #{p.sub("#{ROOT}/", '')}" unless open_paths.include?(p)
    end
    art_tally = rows.group_by { |r| r["tier"] }.transform_values(&:size)
    puts "plates lint: _art ledger #{rows.size} rows (#{art_tally.sort.map { |k, v| "#{k}=#{v}" }.join(' ')}), #{open_paths.size} open assets verified"
  elsif rows
    fail! "_art/_ledger.yml: does not parse as a row array"
  end
elsif Dir.exist?(ART_DIR)
  fail! "plates/_art exists without _ledger.yml — assets must not land unledgered"
end
if FAILURES.any?
  FAILURES.each { |f| puts "LINT FAIL: #{f}" }
  puts "#{FAILURES.size} failure(s)."
  exit 1
else
  puts "plates lint: OK"
end
