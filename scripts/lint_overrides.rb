#!/usr/bin/env ruby
# frozen_string_literal: true
#
# lint_overrides.rb — fast, stdlib-only PR feedback for the curated data files
# (overrides/**, spotchecks.yml). The authoritative validation still happens
# inside every pipeline build; this lint exists so contributors get feedback
# in seconds, not after a full build (the OpenASN lint pattern).
#
# Rules enforced:
#   1. Every overrides YAML parses and has the expected shape.
#   2. drop lists / alias keys are UPPERCASE raw strings (that's the contract).
#   3. Regex pattern files actually compile as Ruby regexes.
#   4. Every DROP entry and every non-obvious alias/rename carries a
#      same-line `#` comment saying WHY (source URL encouraged) — curation
#      without provenance rots.
#   5. spotchecks.yml rows have a `reason` and a known assertion vocabulary.
#
# Run: ruby scripts/lint_overrides.rb   (exit 1 on any failure)

require "yaml"

ROOT = File.expand_path("..", __dir__)
FAILURES = []

def fail!(msg) = FAILURES << msg

def load_yaml(rel)
  YAML.safe_load_file(File.join(ROOT, rel), permitted_classes: [], aliases: false)
rescue => e
  fail! "#{rel}: does not parse — #{e.message}"
  nil
end

# --- 1/2: makes ---------------------------------------------------------------
if (aliases = load_yaml("overrides/makes/aliases.yml"))
  aliases.each_key do |k|
    fail! "aliases.yml: key #{k.inspect} must be the UPPERCASE raw string" unless k == k.upcase
  end
end

if (drops = load_yaml("overrides/makes/drop.yml"))
  raw = File.read(File.join(ROOT, "overrides/makes/drop.yml"))
  drops.each do |kind, list|
    (list || []).each do |entry|
      fail! "drop.yml(#{kind}): #{entry.inspect} must be UPPERCASE" unless entry == entry.upcase
    end
  end
  # Rule 4 (soft-shape): every drop line should carry or follow a comment.
  raw.each_line.with_index(1) do |line, i|
    next unless line =~ /^\s+-\s+\S/
    next if line.include?("#")
    prev = raw.lines[i - 2].to_s
    fail! "drop.yml:#{i}: drop entry without a same-line or preceding comment (say why!)" unless prev.strip.start_with?("#")
  end
end

# --- 3: regex files -----------------------------------------------------------
if (pats = load_yaml("overrides/models/drop_patterns.yml"))
  pats.each do |kind, list|
    (list || []).each do |p|
      Regexp.new(p)
    rescue RegexpError => e
      fail! "drop_patterns.yml(#{kind}): #{p.inspect} does not compile — #{e.message}"
    end
  end
end

if (body = load_yaml("overrides/body_types/body_types.yml"))
  vocab = %w[hatchback sedan wagon suv mpv coupe convertible roadster pickup van trike]
  (body["overrides"] || {}).each do |k, v|
    fail! "body_types.yml overrides: #{k} → #{v} not in vocabulary" unless vocab.include?(v.to_s)
    fail! "body_types.yml overrides: key #{k.inspect} must be 'Make|Model'" unless k.include?("|")
  end
  (body["keywords"] || []).each do |t, re|
    fail! "body_types.yml keywords: #{t} not in vocabulary" unless vocab.include?(t.to_s)
    begin
      Regexp.new(re)
    rescue RegexpError => e
      fail! "body_types.yml keywords: #{re.inspect} — #{e.message}"
    end
  end
end

load_yaml("overrides/models/renames.yml")
load_yaml("overrides/styling.yml")
Dir[File.join(ROOT, "overrides/kind_maps/*.yml")].each { |f| load_yaml(f.sub("#{ROOT}/", "")) }

# --- 5: spotchecks ------------------------------------------------------------
if (spot = load_yaml("spotchecks.yml"))
  known = %w[id make kind exists body_types_include availability_includes global_decile_max skip_if_kind_absent reason]
  (spot["checks"] || []).each_with_index do |c, i|
    fail! "spotchecks.yml row #{i + 1}: missing `reason` (the panel is reviewable or it is nothing)" unless c["reason"]
    fail! "spotchecks.yml row #{i + 1}: needs `id` or `make`" unless c["id"] || c["make"]
    (c.keys - known).each { |k| fail! "spotchecks.yml row #{i + 1}: unknown key #{k}" }
  end
end

if FAILURES.any?
  FAILURES.each { |f| puts "LINT FAIL: #{f}" }
  exit 1
else
  puts "overrides lint: OK"
end
