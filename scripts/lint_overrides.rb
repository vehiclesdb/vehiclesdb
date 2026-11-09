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
      # TWO AUTHORED SHAPES since data#314: a bare pattern string, and a hash
      # {make:, pattern:} that scopes the drop to one marque (the car-kind
      # Sprinter leak is unwritable without it). This lint only knew the first,
      # so it crashed on the second -- Regexp.new(Hash) -- and took mains lint
      # red on 2026-08-21. The pipeline was taught the new shape in
      # pipeline#177; the data repos lint was not. A coupled-change gap.
      src = p.is_a?(Hash) ? p["pattern"] : p
      if p.is_a?(Hash)
        fail! "drop_patterns.yml(" + kind.to_s + "): scoped entry " + p.inspect + " has no `pattern:`" unless p.key?("pattern")
        fail! "drop_patterns.yml(" + kind.to_s + "): scoped entry " + p.inspect + " has no `make:` -- an unscoped hash is just a slower string" unless p.key?("make")
        unknown = p.keys - %w[make pattern]
        fail! "drop_patterns.yml(" + kind.to_s + "): scoped entry has unknown key(s) " + unknown.inspect + " -- the shape is {make:, pattern:}; a typod key would silently widen the drop" unless unknown.empty?
      end
      next unless src.is_a?(String)
      begin
        Regexp.new(src)
      rescue RegexpError => e
        fail! "drop_patterns.yml(" + kind.to_s + "): " + src.inspect + " does not compile -- " + e.message
      end
    end
  end
end

# --- 3b: passenger_variants.yml (data/es-completeness, 2026-11-09) ---------------
# Mirrors the pipeline loader (overrides.rb#load_passenger_variants!), which
# RAISES on the same shapes — this lint gives the same answer in seconds.
# A `lift:` that is not VERBATIM a drop_patterns.yml entry of the same kind is
# silently inert, and an inert lift reads exactly like the evidence gate saying
# "no"; so is a typo'd key. Every entry needs a same-line `#` evidence comment.
pv_path = "overrides/models/passenger_variants.yml"
if File.exist?(File.join(ROOT, pv_path)) && (pv = load_yaml(pv_path))
  gate = pv["gate"] || {}
  fail! "#{pv_path}: gate.min_car_count must be a positive integer" unless gate["min_car_count"].is_a?(Integer) && gate["min_car_count"].positive?
  fail! "#{pv_path}: gate.min_car_share must be in (0, 1]" unless gate["min_car_share"].is_a?(Numeric) && gate["min_car_share"].positive? && gate["min_car_share"] <= 1
  fail! "#{pv_path}: gate.split_countries must be a non-empty list of ISO codes" unless gate["split_countries"].is_a?(Array) && !gate["split_countries"].empty? && gate["split_countries"].all? { |c| c.to_s.match?(/\A[a-z]{2}\z/) }
  bad = pv.keys - %w[gate car]
  fail! "#{pv_path}: only `car:` lifts exist (the gate measures car share against van); got #{bad.inspect}" unless bad.empty?
  plain_by_kind = (pats || {}).transform_values { |l| (l || []).select { |p| p.is_a?(String) } }
  pv_lines = File.readlines(File.join(ROOT, pv_path))
  pv.each do |kind, entries|
    next if kind == "gate"
    (entries || []).each do |e|
      unknown = e.keys - %w[make lift publish]
      fail! "#{pv_path}(#{kind}): unknown key(s) #{unknown.inspect} in #{e.inspect}" unless unknown.empty?
      fail! "#{pv_path}(#{kind}): #{e.inspect} needs make, lift and a non-empty publish list" unless e["make"] && e["lift"] && Array(e["publish"]).any?
      unless (plain_by_kind[kind] || []).include?(e["lift"])
        fail! "#{pv_path}(#{kind}): lift #{e['lift'].inspect} (#{e['make']}) is not verbatim a drop_patterns.yml #{kind}: entry — it would lift nothing"
      end
      line = pv_lines.find { |l| l.include?("lift: '#{e['lift']}'") && l.include?("make: #{e['make']},") }
      fail! "#{pv_path}(#{kind}): #{e['make']} #{e['lift']} has no same-line `#` evidence comment (say why, with the register numbers)" unless line&.match?(/\}\s+#\s*\S/)
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

load_yaml("overrides/makes/search_aliases.yml")
load_yaml("overrides/models/aliases.yml")
load_yaml("overrides/models/renames.yml")
load_yaml("overrides/styling.yml")
Dir[File.join(ROOT, "overrides/kind_maps/*.yml")].each { |f| load_yaml(f.sub("#{ROOT}/", "")) }

# --- 4: empty make blocks -----------------------------------------------------
# A bare `Yamaha:` with nothing under it parses as nil, not {}. The pipeline
# tolerates it (`renames&.key?`), but any consumer that iterates values crashes:
# `.values.map(&:size)` → NoMethodError on nil. Six of these accumulated in
# renames.yml when a bulk PR generated make blocks and then had its entries
# removed at the ownership boundary, leaving the keys behind — the block is a
# fossil of work that did NOT happen, so it also misleads a reader into thinking
# the make was curated. Fail on them; deleting the key is always the fix.
{
  "overrides/models/renames.yml" => nil,
  "overrides/models/aliases.yml" => nil,
  "overrides/makes/aliases.yml" => nil,
}.each_key do |rel|
  next unless (y = load_yaml(rel)).is_a?(Hash)
  y.each do |k, v|
    next unless v.nil? || (v.respond_to?(:empty?) && v.empty?)
    fail! "#{rel}: make block #{k.inspect} is empty — delete the key (an empty block reads as 'curated' but holds nothing)"
  end
end

# --- 5: spotchecks ------------------------------------------------------------
if (spot = load_yaml("spotchecks.yml"))
  # CLOSED vocabulary on purpose — a typo'd assertion key would otherwise be a
  # silently inert spotcheck row. It must be kept in step with validate.rb's
  # gate_spotchecks (pipeline repo); a word added here that the gate does not
  # read is a row that asserts nothing.
  known = %w[id make kind exists body_types_include availability_includes availability_excludes
             global_decile_max skip_if_kind_absent reason]
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
