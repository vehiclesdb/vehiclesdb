#!/usr/bin/env ruby
# frozen_string_literal: true
#
# lint_curation.rb — structural guards for the curated data files that
# lint_overrides.rb does not cover. Runs in the same CI step; stdlib only.
#
# WHY THIS EXISTS. Two maintainers now edit overrides/ in parallel, and the
# failure modes that matter are all SILENT:
#
#   1. DUPLICATE YAML KEYS. `YAML.safe_load` keeps the LAST duplicate and says
#      nothing:
#
#         YAML.safe_load("Honda:\n  A: X\nHonda:\n  B: Y\n")  # => {"Honda"=>{"B"=>"Y"}}
#
#      So if two people append a `Honda:` block, one block silently disappears:
#      lint green, build green, and because renames fail silently by design
#      (a key that matches nothing is simply inert), nobody ever learns. This is
#      the single highest-value check in this file.
#
#   2. UNKNOWN MAKE KEYS. A rename block keyed `Mercedes Benz:` (no hyphen) or
#      `Cupra :` matches nothing forever. Same silence.
#
#   3. UNCOMMENTED CURATION. AGENTS.md requires every override line to say WHY.
#      That rule was unenforced on exactly the three files carrying the most
#      decisions (renames.yml, models/aliases.yml, styling.yml were parse-only).
#
# The provenance rule (3) runs against ADDED lines only, computed from
# `git diff`, so it holds new work to the standard without demanding a mass
# retrofit of lines whose reason is self-evident (`EQA: EQA` is a casing pin
# that explains itself). Structural rules (1, 2) always run on whole files.
#
# Run: ruby scripts/lint_curation.rb [--base=origin/main]

require "psych"
require "yaml"
require "set"

ROOT = File.expand_path("..", __dir__)
FAILURES = []
NOTES = []

def fail!(msg) = FAILURES << msg
def note!(msg) = NOTES << msg

CURATION_GLOBS = ["overrides/**/*.yml", "spotchecks.yml"].freeze

# Files where every hand-written mapping is a decision that needs a reason.
# styling.yml is deliberately absent: a pure casing pin (`EQA: EQA`) explains
# itself, and `acronyms:` entries are covered by the changed-lines rule below.
PROVENANCE_FILES = %w[overrides/models/renames.yml overrides/models/aliases.yml
                      overrides/styling.yml overrides/makes/search_aliases.yml].freeze

# ── 1. duplicate keys, at every nesting level ────────────────────────────────
#
# Psych's AST is the only way to see duplicates: by the time safe_load returns a
# Hash the loser has already been discarded.
def duplicate_keys(path)
  doc = Psych.parse_file(path)
  return [] unless doc

  dups = []
  walk = lambda do |node, trail|
    case node
    when Psych::Nodes::Mapping
      seen = {}
      node.children.each_slice(2) do |k, v|
        key = k.respond_to?(:value) ? k.value : k.to_s
        if (first = seen[key])
          dups << { path: (trail + [key]).join(" → "), first: first, again: k.start_line + 1 }
        else
          seen[key] = k.start_line + 1
        end
        walk.call(v, trail + [key]) if v
      end
    when Psych::Nodes::Stream, Psych::Nodes::Document, Psych::Nodes::Sequence
      node.children.each { |c| walk.call(c, trail) }
    end
  end
  walk.call(doc, [])
  dups
rescue Psych::SyntaxError => e
  fail! "#{path}: does not parse — #{e.message}"
  []
end

curation_files = CURATION_GLOBS.flat_map { |g| Dir[File.join(ROOT, g)] }.sort
curation_files.each do |abs|
  rel = abs.sub("#{ROOT}/", "")
  duplicate_keys(abs).each do |d|
    fail! "#{rel}:#{d[:again]}: DUPLICATE KEY #{d[:path].inspect} (first defined at line #{d[:first]}). " \
          "YAML keeps only the LAST one — the earlier block would be silently discarded."
  end
end

# ── 1b. block style only: no inline flow mappings ────────────────────────────
#
# `Honda: { Honda: null }   # comment` is valid YAML and parses identically to a
# block mapping — but it hides the entry from every line-based tool we have, and
# both maintainers write line-based tools (alphabetizer, provenance checker,
# collision merger, union merger).
#
# This cost 21 entries once: a batch of make-as-model drops was written in flow
# style, a union merge could not see them, and they vanished from a branch with
# no conflict and no lint failure — the exact silent-loss class this file exists
# to prevent. One entry per line, with its own `#` reason, is the contract.
FLOW_MAPPING = /\A\s*("[^"]+"|[^\s#][^:]*):\s*\{/
%w[overrides/models/renames.yml overrides/models/aliases.yml overrides/models/moves.yml
   overrides/makes/aliases.yml overrides/makes/search_aliases.yml].each do |rel|
  abs = File.join(ROOT, rel)
  next unless File.exist?(abs)
  File.readlines(abs).each_with_index do |line, i|
    next unless line.match?(FLOW_MAPPING)
    fail! "#{rel}:#{i + 1}: inline flow mapping — write one entry per line in block style. " \
          "Flow style is invisible to line-based tooling (it silently ate 21 entries once) " \
          "and leaves no room for a per-line reason. Line: #{line.strip}"
  end
end

# ── 1c. rename/move values must be strings (or null) ─────────────────────────
#
# `244: 240` is valid YAML and parses the value as an INTEGER. The pipeline then
# calls Support.slugify on it, which calls .downcase, and the whole build dies
# with "undefined method 'downcase' for an instance of Integer" — a crash, not a
# data error, from a line that looks perfectly reasonable.
#
# It cost a red build. Any all-digit nameplate must be quoted on BOTH sides.
%w[overrides/models/renames.yml overrides/models/moves.yml].each do |rel|
  abs = File.join(ROOT, rel)
  next unless File.exist?(abs)
  (YAML.safe_load_file(abs, permitted_classes: [], aliases: false) || {}).each do |make, entries|
    entries = { make => entries } unless entries.is_a?(Hash)
    entries.each do |key, value|
      next if value.nil? || value.is_a?(String)
      fail! "#{rel}: #{make} #{key.inspect} → #{value.inspect} is a #{value.class}, not a string. " \
            "Quote it (\"#{value}\"): the pipeline slugifies rename targets and a bare integer " \
            "crashes the build with \"undefined method 'downcase' for an instance of Integer\"."
    end
  end
end

# ── 1d. a null rename must not contradict a move ─────────────────────────────
#
# A `null` rename BEATS a move by design (an explicit drop is a stronger
# statement than a routing rule). So if renames.yml drops "SEAT|Formentor" while
# moves.yml routes it to Cupra, the move is dead and NOTHING says so: the record
# just quietly disappears instead of moving.
#
# This is not hypothetical — it happened three times, because a union merge
# cannot tell a deliberate DELETION from an entry the other side simply lacks, so
# every merge from main resurrected the retired null and silently re-killed the
# Cupra move. Contradiction is now a lint failure rather than a silent one.
moves_path = File.join(ROOT, "overrides/models/moves.yml")
if File.exist?(moves_path)
  moves = YAML.safe_load_file(moves_path, permitted_classes: [], aliases: false) || {}
  renames = YAML.safe_load_file(File.join(ROOT, "overrides/models/renames.yml"),
                                permitted_classes: [], aliases: false) || {}
  moves.each_key do |from|
    make, model = from.to_s.split("|", 2).map(&:strip)
    next unless make && model
    next unless renames[make]&.key?(model)
    next unless renames[make][model].nil?
    fail! "overrides/models/renames.yml: #{make.inspect} #{model.inspect} is dropped (null) while " \
          "moves.yml routes it to #{moves[from].inspect}. A null rename BEATS a move, so the move is " \
          "dead and the record vanishes instead of moving. Retire the null, or delete the move."
  end
end

# ── 2. kind_maps shape ───────────────────────────────────────────────────────
#
# These files are SOURCE-keyed, not kind-keyed, so both maintainers' kinds live
# inside one `kinds:` map. Appending a second top-level `kinds:` block is the
# most likely way to trip check 1 here, so the shape is pinned explicitly.
Dir[File.join(ROOT, "overrides/kind_maps/*.yml")].sort.each do |abs|
  rel = abs.sub("#{ROOT}/", "")
  doc = YAML.safe_load_file(abs, permitted_classes: [], aliases: false) || {}
  # `by_model` routes individual nameplates to a kind, for sources whose file has
  # no vehicle-class column at all. Germany's KBA FZ 10.1 is the case: every row
  # is EU class M1 by construction, and M1 includes the passenger versions of
  # vans, so the kind has to come from the nameplate.
  unknown = doc.keys - %w[kinds body_types by_model notes]
  fail! "#{rel}: unexpected top-level key(s) #{unknown.inspect} (expected kinds/body_types/by_model/notes)" unless unknown.empty?
  fail! "#{rel}: missing the `kinds:` map" unless doc.key?("kinds")
  (doc["by_model"] || {}).each do |model, kind|
    next if %w[car van motorcycle moped truck bus].include?(kind.to_s)
    fail! "#{rel}: by_model #{model.inspect} → #{kind.inspect} is not a known kind"
  end
end

# ── 3. make keys must resolve to a real make ─────────────────────────────────
#
# OWNERSHIP.yml is generated from the catalog (scripts/gen_ownership.rb) and is
# the single source of truth for "which makes exist and who curates them".
def slugify(str)
  str.to_s.downcase.unicode_normalize(:nfkd).gsub(/\p{Mn}+/, "")
     .gsub(/[^a-z0-9]+/, "-").gsub(/(\A-|-\z)/, "")
end

ownership_path = File.join(ROOT, "OWNERSHIP.yml")
own = File.exist?(ownership_path) ? (YAML.safe_load_file(ownership_path, permitted_classes: [], aliases: false) || {}) : {}
owner_of = ((own["s4w"] || []).to_h { |m| [m, "s4w"] }).merge((own["s2w"] || []).to_h { |m| [m, "s2w"] })

# CRITICAL: the pipeline looks renames up by the make's canonical DISPLAY NAME
# (`@o.model_renames[make]` in normalizer.rb, where `make` is the post-alias
# display string) — NOT by slug. So "Mercedes Benz:" is inert even though it
# slugifies to the correct `mercedes-benz`, and "SEAT:" is required over
# "Seat:". Compare against catalog display names, exactly.
#
# IMPORTANT — the catalog LAGS the override layer. `catalog/` is a build output
# and the build only runs monthly, so a make renamed by an alias merged today
# still shows its old display name in catalog/*/makes.json for weeks. PR #1
# added identity casing pins (`MITT: MITT`, `TRS: TRS`, `EBRO: EBRO`,
# `UNVI: UNVI`) plus rename blocks keyed by the NEW names; against the current
# catalog those keys look inert, but they are merely pending a build.
#
# So the valid key set is: catalog display names ∪ makes/aliases.yml values.
display_names = {} # display name => slug (or "pending" for alias-only names)
%w[car van motorcycle moped truck bus].each do |kind|
  path = File.join(ROOT, "catalog", kind, "makes.json")
  next unless File.exist?(path)
  require "json"
  JSON.parse(File.read(path)).each { |m| display_names[m["name"]] = m["id"] }
end
(YAML.safe_load_file(File.join(ROOT, "overrides/makes/aliases.yml"),
                     permitted_classes: [], aliases: false) || {}).each_value do |canonical|
  display_names[canonical] ||= slugify(canonical)
end

if display_names.empty?
  note! "no catalog/*/makes.json found — skipping make-key validation"
else
  { "overrides/models/renames.yml" => "rename block",
    "overrides/models/aliases.yml" => "alias block" }.each do |rel, what|
    doc = YAML.safe_load_file(File.join(ROOT, rel), permitted_classes: [], aliases: false) || {}
    doc.each_key do |make|
      if display_names.key?(make)
        note! "#{rel}: #{what} #{make.inspect} → #{display_names[make]} (owner: #{owner_of[display_names[make]] || '?'})"
        next
      end

      # Two very different situations, and only one is a bug:
      #
      #   NEAR-MISS — a make with the same SLUG but a different display form
      #   exists ("Mercedes Benz" vs "Mercedes-Benz", "smart" vs "Smart"). That
      #   is a typo, the block is inert forever, and it must fail.
      #
      #   ABSENT ENTIRELY — no make with that slug is published at all. That is
      #   a legitimate FORWARD-LOOKING block: curation written for a make that
      #   has not cleared the publish threshold yet (S2W's `Unu:` block is the
      #   live example — unu is measured in the RDW raws but not yet published).
      #   Inert today, correct tomorrow, so it gets a note rather than a failure.
      near = display_names.keys.select { |n| slugify(n) == slugify(make) }
      if near.empty?
        note! "#{rel}: #{what} #{make.inspect} matches no published make — inert until that make " \
              "publishes. Fine for forward-looking curation; check the spelling if it was meant to be live."
      else
        fail! "#{rel}: #{what} #{make.inspect} does not match any catalog make DISPLAY NAME — " \
              "the pipeline keys renames by display name, so this block is inert. " \
              "Did you mean #{near.first.inspect}?"
      end
    end
  end
end

# ── 4. every ADDED curation line carries a reason ────────────────────────────
#
# Changed-lines only: we hold new work to the standard without a mass retrofit.
# If git or the base ref is unavailable (a tarball, a detached CI checkout), the
# rule is skipped with a note rather than failing the build.
base = ARGV.find { |a| a.start_with?("--base=") }&.split("=", 2)&.last
base ||= %w[origin/main main].find { |ref| system("git", "-C", ROOT, "rev-parse", "--verify", "--quiet", ref, out: File::NULL) }

if base.nil?
  note! "no git base ref found — skipping the added-line provenance check"
else
  PROVENANCE_FILES.each do |rel|
    abs = File.join(ROOT, rel)
    next unless File.exist?(abs)

    # Diff the base against the WORKING TREE, not against HEAD: we report line
    # numbers from the file as it exists on disk, so the diff has to describe
    # that same file. Using `base...HEAD` made the two disagree the moment there
    # were uncommitted edits, and the lint then pointed at an innocent line.
    diff = `git -C #{ROOT.inspect} diff -U0 #{base} -- #{rel.inspect} 2>/dev/null`
    diff = `git -C #{ROOT.inspect} diff -U0 #{base}...HEAD -- #{rel.inspect} 2>/dev/null` if diff.strip.empty?
    next if diff.strip.empty?

    added = {} # line number in the new file => text
    line_no = nil
    diff.each_line do |l|
      if (m = l.match(/\A@@ -\d+(?:,\d+)? \+(\d+)/))
        line_no = m[1].to_i
      elsif l.start_with?("+++")
        next
      elsif l.start_with?("+")
        added[line_no] = l[1..].chomp
        line_no += 1
      elsif !l.start_with?("-") && line_no
        line_no += 1
      end
    end

    lines = File.readlines(abs)
    added.each do |n, text|
      # Only mapping/list entries are curation decisions. Top-level keys (make
      # block headers, `stylings:`, `acronyms:`) are structure, not decisions.
      next unless text.match?(/\A\s{2,}[^#\s].*:/) || text.match?(/\A\s*- \S/)
      next if text.include?("#")

      # Pure casing pins explain themselves: `EQA: EQA`, `UP: Up`, `ID.4: ID.4`.
      if (m = text.match(/\A\s+(?<k>[^:#]+):\s*(?<v>\S.*?)\s*\z/))
        next if m[:k].delete('"').strip.downcase == m[:v].delete('"').strip.downcase
      end

      prev = lines[n - 2].to_s.strip
      next if prev.start_with?("#")

      fail! "#{rel}:#{n}: curation line added without a reason — every override line needs a " \
            "same-line `#` comment (or a comment directly above) saying WHY, with a source URL " \
            "for anything non-obvious. Line: #{text.strip}"
    end
  end
end

# ── report ───────────────────────────────────────────────────────────────────
if ENV["VDB_LINT_VERBOSE"]
  NOTES.each { |n| puts "note: #{n}" }
end

if FAILURES.any?
  FAILURES.each { |f| puts "LINT FAIL: #{f}" }
  puts "\n#{FAILURES.size} failure(s)."
  exit 1
else
  puts "curation lint: OK (#{curation_files.size} files, duplicate-key + shape + make-key + provenance)"
end
