#!/usr/bin/env ruby
# frozen_string_literal: true
#
# reorg_make_blocks.rb — sort the make-keyed curation files alphabetically,
# preserving each block's comments verbatim.
#
# WHY. Two maintainers append to these files in parallel. Append-at-the-end
# guarantees a merge conflict on every simultaneous PR and, worse, invites a
# second `Honda:` block (YAML silently keeps the last — see lint_curation.rb).
# Alphabetical order gives each make ONE canonical home that both sides compute
# the same way, so concurrent edits land in different places and merge cleanly.
#
# Deliberately NOT per-maintainer fenced sections: fences and alphabetical order
# are mutually exclusive, and ownership is metadata (OWNERSHIP.yml + lint),
# not layout. A reader looking for Honda should find it under H.
#
# SAFETY: the script refuses to write unless the parsed YAML is byte-identical
# in content before and after (key order is the only permitted change).
#
# Run: ruby scripts/reorg_make_blocks.rb [--check]

require "yaml"

ROOT  = File.expand_path("..", __dir__)
FILES = %w[overrides/models/renames.yml overrides/models/aliases.yml].freeze
CHECK = ARGV.include?("--check")

# A top-level key line: `Mercedes-Benz:` / `"Gas Gas":` / `SEAT:` at column 0.
TOP_KEY = /\A(?<key>"[^"]+"|[^\s#][^:]*):\s*(?<trailing>#.*)?\z/

def split_blocks(lines)
  header = []
  blocks = []       # [{key:, lines: [...]}]
  pending = []      # comment/blank lines not yet attached to a block
  current = nil

  lines.each do |line|
    if (m = line.match(TOP_KEY))
      # Attach pending comments to THIS block, except a trailing run of blanks.
      lead = pending
      lead.pop while lead.last&.strip&.empty?
      spacer = pending[lead.size..] || []
      if current
        current[:lines].concat(spacer)
      else
        header.concat(spacer)
      end
      pending = []
      current = { key: m[:key].delete('"'), lines: lead + [line] }
      blocks << current
    elsif current.nil?
      # Before the first block: either file header, or comments belonging to
      # the first block. Buffer them and decide when the block appears.
      if line.strip.start_with?("#") || line.strip.empty?
        pending << line
      else
        header.concat(pending)
        pending = []
        header << line
      end
    elsif line.strip.start_with?("#") || line.strip.empty?
      pending << line
    else
      current[:lines].concat(pending)
      pending = []
      current[:lines] << line
    end
  end
  if current
    current[:lines].concat(pending)
  else
    header.concat(pending)
  end
  [header, blocks]
end

# Section banners (`# ==== ES-brand audit ... ====`) are dropped: they group by
# WHEN a line was written, which fights alphabetical order, and every line
# already carries its own `#` reason. Agreed in NEGOTIATION.md Turn 6 §5.
BANNER = /\A\s*#\s*(={3,}|-{3,})/

changed = []
FILES.each do |rel|
  path = File.join(ROOT, rel)
  original = File.read(path)
  before = YAML.safe_load(original, permitted_classes: [], aliases: false)

  header, blocks = split_blocks(original.lines)
  sorted = blocks.sort_by { |b| [b[:key].downcase, b[:key]] }

  body = sorted.map do |b|
    kept = b[:lines].reject { |l| l.match?(BANNER) }
    # Collapse any blank run left at the block's head, then end with exactly one.
    kept.shift while kept.first&.strip&.empty?
    kept.pop while kept.last&.strip&.empty?
    kept + ["\n"]
  end.flatten

  out = (header + body).join
  out = out.sub(/\n{3,}\z/, "\n")
  after = YAML.safe_load(out, permitted_classes: [], aliases: false)

  # The safety property: reordering must not change a single mapping.
  unless before == after
    warn "#{rel}: REFUSING to write — parsed content differs after reorder"
    (before.keys - after.keys).each { |k| warn "  lost key: #{k}" }
    (after.keys - before.keys).each { |k| warn "  new key: #{k}" }
    before.each { |k, v| warn "  changed: #{k}" if after[k] != v }
    exit 1
  end

  next if out == original
  changed << rel
  File.write(path, out) unless CHECK
end

if changed.empty?
  puts "make blocks already alphabetical: #{FILES.join(', ')}"
elsif CHECK
  puts "would reorder: #{changed.join(', ')} (run without --check)"
  exit 1
else
  puts "reordered (content verified identical): #{changed.join(', ')}"
end
