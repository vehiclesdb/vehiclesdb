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

# data/ is included because the duplicate-key check below is the single
# highest-value rule here and it was NOT covering the files most likely to trip
# it. Confirmed the hard way 2026-07-25: appending a second `debt:` key to
# data/name_shapes.yml silently discarded the existing SIX debt entries — YAML
# keeps only the last — and this lint said OK, because name_shapes.yml was
# outside the globs. The ledger files under data/review/ have the same exposure.
CURATION_GLOBS = ["overrides/**/*.yml", "spotchecks.yml", "data/**/*.yml"].freeze

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

# ── 1a2. no EMPTY make blocks ────────────────────────────────────────────────
#
# A make block with no entries (`Yamaha:` followed by nothing) parses as nil.
# Harmless to the pipeline (nil block = no renames) but it crashes naive
# iteration (`.values.map(&:size)`) — which it did, twice, in maintainer
# tooling — and it reads as work someone forgot to finish. Six of them were
# left behind by an ownership-boundary revert; delete the header when you
# delete the last entry.
%w[overrides/models/renames.yml overrides/models/aliases.yml].each do |rel|
  doc = YAML.safe_load_file(File.join(ROOT, rel), permitted_classes: [], aliases: false) || {}
  doc.each { |mk, v| fail! "#{rel}: make block #{mk.inspect} is EMPTY (parses as nil) — delete the header or add entries" if v.nil? }
end

# ── 1a-bis. files with a fixed top-level shape must actually have it ─────────
#
# THE FAILURE THIS CATCHES, which cost a shipped PR: an entry written with a
# squiggly heredoc (`<<~`) loses its indentation, because <<~ strips the COMMON
# leading whitespace from every line. A key meant to sit under `batches: B-002:`
# lands at column 0 instead and becomes a SIBLING of `batches:`. The result is
# structurally valid YAML that means something entirely different — every other
# check here passed, the review lint passed, and the batch simply had no
# `progress` key while a stray top-level one sat below it.
#
# Same shape as the duplicate-key and flow-style classes: silently valid, wrong.
# Cheap to guard because these files have exactly one legal root key.
#
# styling.yml added 2026-07-26 after this check earned its keep a second time,
# on a file it did not yet cover. `XXX: XXX` (the Talaria XXX pin) had been
# sitting at column 0 since 2026-07-25 — a sibling of `stylings:` rather than an
# entry in it — so the loader, which reads only `styling["stylings"]` and
# `styling["acronyms"]`, never saw it. It was inert for a day.
#
# What made it nastier than the batches.yml case: THE OUTPUT WAS STILL CORRECT.
# A renames.yml entry (`Talaria: TL2500: XXX`) produces "XXX" verbatim, so the
# published name looked right and the dead pin's comment claimed credit for it.
# Nothing was broken — a trap was armed. Delete that rename believing the
# styling pin has your back and the name silently becomes "Xxx".
#
# The general lesson, and the reason this check is worth extending rather than
# fixing one file: an override that is inert is not detectable by looking at the
# OUTPUT. It is only detectable by looking at the SHAPE. Any file whose loader
# reads a fixed set of root keys should be in this table.
{
  "data/review/batches.yml" => %w[batches],
  "data/name_shapes.yml"    => %w[legit debt],
  "overrides/styling.yml"   => %w[stylings acronyms],
}.each do |rel, allowed|
  path = File.join(ROOT, rel)
  next unless File.exist?(path)
  doc = YAML.safe_load_file(path, permitted_classes: [Date], aliases: false) || {}
  stray = doc.keys - allowed
  next if stray.empty?
  fail! "#{rel}: unexpected TOP-LEVEL key(s) #{stray.inspect} (allowed: #{allowed.inspect}). " \
        "Almost always an indentation loss — a nested entry written with <<~ heredoc lands at " \
        "column 0 and silently becomes a sibling of the root key instead of a child of its batch/entry. " \
        "Re-indent it under the entry it belongs to; do not add it to the allow-list."
end

# ── 1a-ter. a make block may not spell one token two ways in its VALUES ──────
#
# THE CLASS, and it is the fifth distinct silent failure this file has produced
# (after duplicate keys, empty blocks, flow style and heredoc indentation):
# a rename VALUE that contradicts another value in the same make block.
#
# Measured instance, fixed in the same commit as this check: Kawasaki carried
#   "Ninja ZX-6R Abs": Ninja Zx-6R     <- lowercase x
#   Zx-6R:             ZX-6R           <- 31 lines below, asserting the caps form
# and styling.yml pins ZX. One make block, one designation, two spellings.
#
# WHY NOTHING ELSE CATCHES IT. A rename value is only a display CANDIDATE — the
# reconciler picks among candidates by row count. The correct form outvoted this
# one, so the published name was right BY LUCK; had the ABS rows been the
# majority, the wrong display would have shipped. So:
#   * find_casing_contradictions.rb reads PUBLISHED names — sees nothing
#   * the id-contract gate reads ids — sees nothing
#   * test_override_key_reachability reads KEYS — the key is perfectly
#     reachable; it is the VALUE that is wrong
# A wrong value is a landmine, not a defect, and only reading the file against
# itself finds it.
#
# WHAT I DELIBERATELY DID NOT LINT, because I measured it and it does not hold:
# the sibling idea — "a value whose token contradicts a styling.yml acronym pin"
# — produces 4 hits catalog-wide and ALL FOUR ARE FALSE POSITIVES: Mercedes
# "170 Sb" / "220 Sb", where the lowercase series letter is the marque's own
# convention (cf. 220 SEb) while SB is pinned for aprilia/ariel. That is the
# LE/Le-Mans collision again — a global pin cannot know a marque's lowercase
# convention — so it is a worklist at best and is not implemented here.
#
# Tokens INCLUDE digit-bearing forms. My first pass excluded them and therefore
# missed the very defect that motivated the check ("Zx-6R" has a digit).
renames_path = File.join(ROOT, "overrides/models/renames.yml")
if File.exist?(renames_path)
  (YAML.safe_load_file(renames_path, permitted_classes: [], aliases: false) || {}).each do |mk, entries|
    next unless entries.is_a?(Hash)
    forms = {}
    entries.each_value do |v|
      next unless v.is_a?(String)
      v.split(%r{[\s/]+}).each do |tok|
        next unless tok.match?(/\A[A-Za-z][A-Za-z0-9-]{1,8}\z/)
        (forms[tok.upcase] ||= Set.new) << tok
      end
    end
    forms.each do |upper, spellings|
      next if spellings.size < 2
      fail! "overrides/models/renames.yml: make block #{mk.inspect} spells #{upper.inspect} " \
            "#{spellings.size} different ways in its VALUES — #{spellings.to_a.sort.inspect}. " \
            "One of them is wrong, and because a rename value is only a display CANDIDATE the " \
            "published name may still look correct (whichever spelling has more rows wins). " \
            "Pick the marque's own rendering and use it in every value in this block."
    end
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

  # ── 1e. a move TARGET must already be canonical ────────────────────────────
  #
  # RENAMES RUN BEFORE MOVES, so a move's target nameplate is NOT re-normalized
  # against the destination make. If moves.yml routes to "Vespa|Seigiorni" while
  # renames.yml has `Vespa: Seigiorni -> Sei Giorni`, the rename never fires for
  # those rows — at rename time the make is still the SOURCE make (Piaggio), so
  # the Vespa block is never consulted — and the move publishes a second,
  # non-canonical record beside the canonical one, forever.
  #
  # Found the hard way: it was the last surviving duplicate-spelling group in
  # the two-wheel half after 163 others had been resolved, and it survived a
  # full batch precisely because the rename LOOKED correct in isolation
  # (classify("VESPA","SEIGIORNI") returns "Sei Giorni" — it is only rows
  # arriving as PIAGGIO that miss).
  moves.each do |from, to|
    next unless to.is_a?(String)
    t_make, t_model = to.split("|", 2).map { |s| s&.strip }
    next unless t_make && t_model
    next unless renames[t_make]&.key?(t_model)
    canon = renames[t_make][t_model]
    next if canon.nil? # a null target is check 1d's problem, not this one
    fail! "overrides/models/moves.yml: #{from.inspect} targets #{to.inspect}, but #{t_make.inspect} " \
          "renames #{t_model.inspect} -> #{canon.inspect}. Renames run BEFORE moves, so the move target " \
          "is NOT re-normalized and this publishes a non-canonical record beside the canonical one. " \
          "Write the canonical form directly in the move target."
  end
end

# ── 1f. former_ids must not chain or cycle ───────────────────────────────────
#
# An alias whose TARGET is itself an alias key sends a consumer to an id that is
# also dead — one redirect short of useful at best, and an infinite loop at
# worst. Two shapes, both seen for real:
#
#   CHAIN  a -> b -> c, because a later batch relocated b after a was written.
#          Three of these existed at once after the tail batch moved Vespa's
#          "Seigiorni" and Aprilia's "Capo Nord".
#   CYCLE  a -> b AND b -> a. This is the DIRECTION WAR that S4W found in
#          renames.yml (NEGOTIATION Turn 56), in the alias file instead: an
#          auto-generated de-hyphenation alias (gsx-r -> gsxr) met a later batch
#          that reversed the canonical (Gsxr -> GSX-R), and the pair published
#          two live records pointing at each other. Keys are unique so the
#          duplicate-key check cannot see it, and both halves look right alone.
fi_path = File.join(ROOT, "overrides/models/former_ids.yml")
if File.exist?(fi_path)
  fi = YAML.safe_load_file(fi_path, permitted_classes: [], aliases: false) || {}
  target = ->(v) { v.is_a?(Hash) ? v["to"] : v }
  fi.each do |old_id, v|
    tgt = target.call(v)
    next unless fi.key?(tgt)
    if target.call(fi[tgt]) == old_id
      fail! "overrides/models/former_ids.yml: DIRECTION WAR — #{old_id.inspect} -> #{tgt.inspect} and " \
            "#{tgt.inspect} -> #{old_id.inspect}. Each alias names the other's key, so both ids are " \
            "'former' and a consumer holding either is sent to a dead id. Pick one canonical and delete " \
            "the reverse."
    else
      fail! "overrides/models/former_ids.yml: CHAIN — #{old_id.inspect} -> #{tgt.inspect}, but " \
            "#{tgt.inspect} is itself an alias for #{target.call(fi[tgt]).inspect}. Point the first one " \
            "straight at the final target: a consumer following one redirect lands on another dead id."
    end
  end
end

# ── DIRECTION WAR: a rename whose TARGET is also a KEY in the same block ─────
#
# Found in the Volvo collision batch (data#22): one block held BOTH
# `C70: C-70` (mechanical) and `C-70: C70` (sourced) — every raw spelling
# renamed to the OTHER form, so BOTH records published forever. Invisible to
# every other check: keys are unique, each key individually reachable, build
# green throughout. Renames apply ONCE (the value is final, never re-looked-up),
# so `A: B` alongside `B: C` means raws producing A land on B while raws
# producing B land on C — two different finals for one nameplate family, a
# guaranteed latent split even when it isn't a 2-cycle. Generalized per S2W's
# Turn 57 request: flag ANY value that is also a key in its own block.
# (Cross-make targets are moves.yml business and out of scope here.)
renames_all = YAML.safe_load_file(File.join(ROOT, "overrides/models/renames.yml"),
                                  permitted_classes: [], aliases: false) || {}
renames_all.each do |make, map|
  next unless map.is_a?(Hash)
  map.each do |key, value|
    next if value.nil? # drops have no target to war with
    next unless map.key?(value.to_s) && value.to_s != key.to_s
    onward = map[value.to_s]
    # A CONVERGED IDENTITY TARGET is not a war: `R4: "4"` beside `"4": "4"`
    # sends every spelling to the SAME final ("4"), because the target key is
    # an IDENTITY rename — the junk?-override rescue class (normalizer ORDER
    # FIX 2026-07-25: an explicit rename entry beats the single-digit junk
    # heuristic). Renault "4"/"5"/"8"/"9" are the first identity-FORM rescues:
    # the marque's canonical form IS the bare numeral (renault.co.uk badges
    # the current cars "Renault 4"/"Renault 5"), unlike Mazda's "3": MAZDA3
    # where the canonical embeds the marque word. The war this check hunts is
    # two spellings landing on DIFFERENT finals; a fixed-point target cannot
    # produce that — flagging it would make every rescue key unusable as a
    # fold target. (Renault+Dacia trim-fold batch, 2026-07-26.)
    next if onward == value
    fail! "overrides/models/renames.yml: DIRECTION WAR in #{make.inspect} — #{key.inspect} → " \
          "#{value.inspect}, but #{value.to_s.inspect} is itself a key (→ #{onward.inspect}). " \
          "Renames apply once, so these raws land on DIFFERENT finals and both records publish. " \
          "Pick ONE canonical (the sourced one) and point every spelling at it."
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

# Display names the OVERRIDE LAYER declares, which may not be in the catalog
# yet. `makes/aliases.yml` maps raw UPPERCASE registry strings to display names,
# so its VALUES are exactly the set of names the next build can produce.
pending_display_names = begin
  (YAML.safe_load_file(File.join(ROOT, "overrides/makes/aliases.yml"), permitted_classes: [], aliases: false) || {})
    .values.compact.map(&:to_s).to_set
rescue
  Set.new
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
      #   PENDING AN ALIAS — the near-miss is the display name the CATALOG still
      #   carries, but makes/aliases.yml already declares the new one. This lint
      #   reads catalog/, which is the LAST RELEASE, so during the release that
      #   renames a make the correct block name looks like a typo and the stale
      #   one looks right. Exactly backwards.
      #
      #   This is not hypothetical: it is why this lint stayed green while the
      #   `Emax:` block went inert under the E-Max merge (2026-07-25). The block
      #   matched the stale catalog perfectly. A rename block is only safe if it
      #   matches what the pipeline WILL produce, so consult the override layer's
      #   own declared display names too. The pipeline-side hermetic version of
      #   this check is `test_rename_make_blocks_are_reachable`; the two are
      #   complementary — that one computes the name from the override layer,
      #   this one sees the built reality.
      if pending_display_names.include?(make)
        note! "#{rel}: #{what} #{make.inspect} matches a makes/aliases.yml display name not yet in the " \
              "catalog — correct for the build that lands the rename; verify it after the next build."
        next
      end

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
