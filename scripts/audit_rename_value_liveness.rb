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

# BOTH ROOTS WERE HARDCODED to one session's worktrees:
#
#     D = "/Users/javi/GitHub/.vdb-worktrees/s2w-data"
#     P = "/Users/javi/GitHub/.vdb-worktrees/s2w-pipeline"
#
# so the sweep read those files no matter which checkout you ran it from. Run
# against a branch that ADDS two rename keys and it still printed
# "renames scanned: 7546" — the same number as main, because it never opened
# the branch's file. It exits 0 and prints a plausible summary either way, and
# that is the whole failure: a null result and a clean result are
# indistinguishable unless you make the tool say what it read.
D = File.expand_path(ENV["VDB_DATA_REPO"] || File.join(__dir__, ".."))
# P is deliberately NOT derived from D. The data repo under audit is often a
# worktree (that is the whole point of pointing VDB_DATA_REPO at a branch), and
# worktrees carry no build/out — so `D/../vehiclesdb-pipeline` would abort on
# exactly the case this tool exists for. Default to the pipeline beside the
# canonical checkout this script lives in.
P = File.expand_path(ENV["VDB_PIPELINE_REPO"] || File.join(__dir__, "..", "..", "vehiclesdb-pipeline"))

def slug(s) = s.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")

live = {}      # "make/slug" => [kinds]
catalog_files = Dir["#{P}/build/out/catalog/*/models.json"].sort
# An EMPTY glob is the dangerous case, not a harmless one: `live` stays {} and
# then EVERY rename value looks like it names no record, so the sweep reports
# maximal risk with total confidence. Refuse to run rather than answer wrongly.
if catalog_files.empty?
  abort "audit_rename_value_liveness: no build catalog under #{P}/build/out/catalog/*/models.json — " \
        "every rename value would falsely read as dead. Build the pipeline first, or point " \
        "VDB_PIPELINE_REPO at a checkout that has build/out (VDB_DATA_REPO sets the data repo)."
end
catalog_files.each do |f|
  kind = File.basename(File.dirname(f))
  d = JSON.parse(File.read(f)); r = d.is_a?(Hash) ? (d["models"] || d.values.first) : d
  r.each { |x| (live[x["id"]] ||= []) << kind }
end

renames = YAML.load_file("#{D}/overrides/models/renames.yml")
former  = YAML.load_file("#{D}/overrides/models/former_ids.yml")
retired = former.keys.map { |k| k.split("/", 2).last }.to_set rescue
          (require("set"); former.keys.map { |k| k.split("/", 2).last }.to_set)

risky = []
declined_null = 0     # values that are not strings — deliberate drops
declined_block = 0    # top-level entries that are not make blocks
renames.each do |make, block|
  unless block.is_a?(Hash)
    declined_block += 1
    next
  end
  mk = slug(make)
  block.each do |key, val|
    unless val.is_a?(String)               # nulls are deliberate drops
      declined_null += 1
      next
    end
    target = "#{mk}/#{slug(val)}"
    next if live.key?(target)              # value names a live record — fine
    # value has no live record. Two sub-cases:
    #   RESURRECTION: the value's id is a RETIRED id (has a former_ids arm)
    #   DEAD-VALUE  : the value names nothing at all
    kind = retired.include?(slug(val)) || former.keys.any? { |k| k.end_with?("/#{target}") }
    risky << [make, key, val, kind ? "RESURRECTION (value is a retired id)" : "DEAD VALUE (names no record)"]
  end
end

# WHAT WAS EXAMINED, printed before what was found. The counts above are only
# meaningful against a stated corpus: "34 resurrection risks" from a stale or
# foreign build looks exactly like 34 from this branch's build.
puts "  data repo:     #{D}#{ENV['VDB_DATA_REPO'] ? ' (VDB_DATA_REPO)' : ''}"
puts "  build catalog: #{P}/build/out/catalog#{ENV['VDB_PIPELINE_REPO'] ? ' (VDB_PIPELINE_REPO)' : ''}"
puts "                 #{catalog_files.size} kind(s): #{catalog_files.map { |f| File.basename(File.dirname(f)) }.join(', ')}"
puts "                 #{live.size} live records, built #{File.mtime(catalog_files.first).strftime('%Y-%m-%d %H:%M')}"
puts "  former_ids:    #{former.size} arms over #{retired.size} distinct retired slugs"
# AND WHAT IT DECLINED TO EXAMINE. A denominator alone is the cure for "ran and
# found nothing"; it is no cure at all for "ran, found some, and said less than
# it knew" — for that the tool has to state its PREDICATE, because a silence
# inside the scope and a silence outside it look identical from the outside.
puts "  predicate:     a rename VALUE is checked against `<this make>/<slug(value)>` — SAME MAKE BLOCK ONLY."
puts "                 A cross-make rename is OUT OF SCOPE and is not reported either way."
puts "                 declined: #{declined_null} non-String value(s) (deliberate drops)" \
     "#{declined_block.positive? ? ", #{declined_block} non-block top-level entr(y/ies)" : ''}"
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
