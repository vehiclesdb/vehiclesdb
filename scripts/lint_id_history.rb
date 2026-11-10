#!/usr/bin/env ruby
# frozen_string_literal: true
#
# lint_id_history.rb — every id a PUBLISHED vehicles-gem release ever shipped
# must still resolve: live in dist/vehicles.json, aliased in
# overrides/models/former_ids.yml, or manifested in overrides/models/removals.yml.
#
# WHY. The pipeline's no-vanish gate only compares a build with the PREVIOUS
# published catalog, so ids retired before that gate existed (2026-07) were
# never checked: CarHey (2026-11-09) still held gem ids such as
# car/lynk-co/lynk-and-co-01 and car/ford/mustang-mach that resolved nowhere.
# data/gem_history_ids.txt is the union of the ids in gem data 0.1.0, 0.1.1,
# 0.4.0, 0.7.9 and 0.8.0 (extracted from the released .gem files); append the
# ids of any future gem data release to it.
#
# Also checks overrides/models/display.yml: every pinned key is a live id.
#
# Run: ruby scripts/lint_id_history.rb [--dist=dist/vehicles.json]
require "json"
require "yaml"

ROOT = File.expand_path("..", __dir__)
dist = ARGV.find { |a| a.start_with?("--dist=") }&.split("=", 2)&.last || File.join(ROOT, "dist/vehicles.json")
live = {}
JSON.parse(File.read(dist))["makes"].each { |mk| mk["models"].each { |m| live["#{m['kind']}/#{mk['slug']}/#{m['slug']}"] = true } }
fid = YAML.safe_load_file(File.join(ROOT, "overrides/models/former_ids.yml")) || {}
rem = YAML.safe_load_file(File.join(ROOT, "overrides/models/removals.yml")) || {}
fails = []
File.foreach(File.join(ROOT, "data/gem_history_ids.txt"), chomp: true) do |id|
  next if id.empty? || id.start_with?("#")
  fails << "#{id}: shipped by a published gem release but neither live, aliased (former_ids.yml) nor manifested (removals.yml)" unless live[id] || fid[id] || rem[id]
end
pins_path = File.join(ROOT, "overrides/models/display.yml")
if File.exist?(pins_path)
  (YAML.safe_load_file(pins_path) || {}).each_key do |id|
    fails << "display.yml: #{id} is not a live id — a display pin must name an existing record" unless live[id]
  end
end
fails.each { |f| puts "LINT FAIL: #{f}" }
puts fails.empty? ? "id-history lint: OK (gem history + display pins)" : "\n#{fails.size} failure(s)."
exit(fails.empty? ? 0 : 1)
