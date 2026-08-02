# RENAME-VALUE LIVENESS SWEEP (the class honda-a identified).
#
# renames.yml maps display name -> display name and is applied in ONE PASS.
# lint_curation checks KEY shape; nothing checks that a line's VALUE names a
# record that still exists. So when a fold retires an id, a PRE-EXISTING rename
# whose VALUE is that retired display name still fires, resolves to the dead
# display, is never re-mapped onto the survivor — and RESURRECTS the retired id
# under a live key. Green lint, green build, duplicate back in the catalog.
#
# This sweeps the WHOLE repo, not just tonight's folds: for every rename VALUE,
# does a live record exist for it? A value with no live record is either a
# resurrection risk or an already-dead line.
require "json"
require "yaml"
D = "/Users/javi/GitHub/.vdb-worktrees/s2w-data"
P = "/Users/javi/GitHub/.vdb-worktrees/s2w-pipeline"

def slug(s) = s.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")

live = {}      # "make/slug" => [kinds]
Dir["#{P}/build/out/catalog/*/models.json"].each do |f|
  kind = File.basename(File.dirname(f))
  d = JSON.parse(File.read(f)); r = d.is_a?(Hash) ? (d["models"] || d.values.first) : d
  r.each { |x| (live[x["id"]] ||= []) << kind }
end

renames = YAML.load_file("#{D}/overrides/models/renames.yml")
former  = YAML.load_file("#{D}/overrides/models/former_ids.yml")
retired = former.keys.map { |k| k.split("/", 2).last }.to_set rescue
          (require("set"); former.keys.map { |k| k.split("/", 2).last }.to_set)

risky = []
renames.each do |make, block|
  next unless block.is_a?(Hash)
  mk = slug(make)
  block.each do |key, val|
    next unless val.is_a?(String)          # nulls are deliberate drops
    target = "#{mk}/#{slug(val)}"
    next if live.key?(target)              # value names a live record — fine
    # value has no live record. Two sub-cases:
    #   RESURRECTION: the value's id is a RETIRED id (has a former_ids arm)
    #   DEAD-VALUE  : the value names nothing at all
    kind = retired.include?(slug(val)) || former.keys.any? { |k| k.end_with?("/#{target}") }
    risky << [make, key, val, kind ? "RESURRECTION (value is a retired id)" : "DEAD VALUE (names no record)"]
  end
end

puts "  renames scanned: #{renames.sum { |_, b| b.is_a?(Hash) ? b.count { |_, v| v.is_a?(String) } : 0 }}"
puts "  values with NO live record: #{risky.size}\n\n"
res = risky.select { |r| r[3].start_with?("RESURRECTION") }
puts "  ── RESURRECTION RISK (#{res.size}) — a live key resolving to a RETIRED id ──"
res.first(25).each { |mk, k, v, _| puts format("      %-16s %-30s -> %s", mk, k.inspect, v.inspect) }
puts "      … #{res.size - 25} more" if res.size > 25
dead = risky - res
puts "\n  ── DEAD VALUE (#{dead.size}) — names no record in any kind ──"
dead.first(20).each { |mk, k, v, _| puts format("      %-16s %-30s -> %s", mk, k.inspect, v.inspect) }
puts "      … #{dead.size - 20} more" if dead.size > 20
