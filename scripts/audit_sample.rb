#!/usr/bin/env ruby
# frozen_string_literal: true
#
# audit_sample.rb — the five-nines audit sampler (PRD-FIVE-NINES §2, gate A1).
#
# Draws a SEEDED, STRATIFIED, REPRODUCIBLE sample of published records for a
# per-record audit round. Design decisions, each load-bearing:
#
#   * SEED = the release tag string (via SHA256 → integer). Same tag, same
#     sample, byte-for-byte — the sample cannot be cherry-picked, and anyone
#     with the repo can regenerate it (the §1.3.2 auditability posture).
#   * STRATA = kind × decile-band(1-3 | 4-6 | 7-10 | none) × make-size
#     (large ≥100 records | mid 10-99 | small <10). The `none` band exists
#     because 288 records carry no popularity and a stratifier without a
#     bucket for them SILENTLY TRUNCATES (S2W review finding A5 — measured,
#     all 288 on the 4W half). 72 possible strata; empties are skipped.
#   * ALLOCATION = minimum floor per non-empty stratum (default 8; the none
#     band gets a raised floor of 15 per non-empty stratum because it is
#     exactly the shelf where unrankable oddballs live), remainder
#     proportional to stratum RECORD count. Mass weighting deliberately does
#     NOT happen here: it happens at analysis time against the published
#     catalog/meta/decile-mass.json (pipeline #40) — the sampler measures,
#     the artifact weighs, and the two are separately auditable.
#   * --half=s4w|s2w filters kinds (s4w: car/van/truck/bus; s2w:
#     motorcycle/moped) — ownership halves audit their own records.
#
# Usage:
#   ruby scripts/audit_sample.rb --tag=v2026.07.5 --half=s4w --n=400
#   ruby scripts/audit_sample.rb --tag=v2026.07.5 --half=s2w --n=400 \
#        [--deciles=7-10,none]      # tail-bound rounds (§1.3.1: n≈3,100)
#   ruby scripts/audit_sample.rb --self-test
#
# Output: data/review/audit-<tag>/SAMPLE-<half>.yml + an allocation table on
# stdout. The per-record protocol the sample feeds is
# data/review/audit-PROTOCOL.md.

require "json"
require "yaml"
require "digest"

ROOT = File.expand_path("..", __dir__)
HALVES = { "s4w" => %w[car van truck bus], "s2w" => %w[motorcycle moped] }.freeze
BANDS = { "1-3" => (1..3), "4-6" => (4..6), "7-10" => (7..10) }.freeze
FLOOR = 8
NONE_FLOOR = 15

def band_of(decile)
  return "none" if decile.nil?
  BANDS.each { |name, r| return name if r.cover?(decile) }
  "none"
end

def size_band(n) = n >= 100 ? "large" : (n >= 10 ? "mid" : "small")

def load_records(catalog_dir, kinds)
  make_sizes = Hash.new(0)
  records = []
  kinds.each do |kind|
    path = File.join(catalog_dir, kind, "models.json")
    abort "missing #{path} — run against a catalog checkout" unless File.exist?(path)
    JSON.parse(File.read(path)).each do |m|
      make_sizes["#{kind}/#{m["make_id"]}"] += 1
      records << { "kind" => kind, "id" => m["id"],
                   "decile" => m.dig("popularity", "global_decile") }
    end
  end
  records.each { |r| r["make_size"] = size_band(make_sizes["#{r["kind"]}/#{r["id"].split("/").first}"]) }
  records
end

def stratify(records)
  records.group_by { |r| [r["kind"], band_of(r["decile"]), r["make_size"]].join("|") }
end

# Floors first, then largest-remainder proportional allocation of what's left.
# A stratum never receives more than it contains. When the requested n is
# BELOW the floor total (dry runs), floors scale down proportionally —
# deterministically — with a loud warning; a real round should use n at or
# above the printed floor total.
def largest_remainder(quotas, strata, budget)
  alloc = quotas.transform_values(&:floor)
  leftover = budget - alloc.values.sum
  quotas.sort_by { |k, q| [-(q - q.floor), k] }.each do |k, _|
    break if leftover <= 0
    next if alloc[k] >= strata[k].size
    alloc[k] += 1
    leftover -= 1
  end
  alloc
end

def allocate(strata, n)
  floors = strata.to_h { |k, v| [k, [k.include?("|none|") ? NONE_FLOOR : FLOOR, v.size].min] }
  if floors.values.sum >= n
    total = floors.values.sum.to_f
    warn "NOTE: n=#{n} is below the stratum-floor total (#{total.to_i}) — " \
         "floors scaled down proportionally; a full round wants n ≥ #{total.to_i}"
    return largest_remainder(floors.to_h { |k, f| [k, n * f / total] }, strata, n)
  end
  alloc = floors
  remaining = n - alloc.values.sum
  return alloc if remaining <= 0
  total = strata.sum { |_, v| v.size }
  quotas = strata.to_h { |k, v| [k, remaining * v.size / total.to_f] }
  quotas.transform_values(&:floor).each { |k, add| alloc[k] = [alloc[k] + add, strata[k].size].min }
  # Top-up: repeat passes (deterministic order) until the leftover is placed
  # or every stratum is at population — one pass is not enough when capped
  # strata bounce their share.
  order = quotas.sort_by { |k, q| [-(q - q.floor), k] }.map(&:first)
  loop do
    leftover = n - alloc.values.sum
    break if leftover <= 0
    progressed = false
    order.each do |k|
      break if leftover <= 0
      next if alloc[k] >= strata[k].size
      alloc[k] += 1
      leftover -= 1
      progressed = true
    end
    break unless progressed # population exhausted below n
  end
  alloc
end

def draw(strata, alloc, seed_int)
  strata.sort.to_h do |key, members|
    rng = Random.new(Digest::SHA256.hexdigest("#{seed_int}|#{key}").to_i(16) % (2**62))
    # Sort by id first: the draw depends only on stratum membership, never on
    # catalog file order (which can differ across regenerated checkouts).
    picked = members.sort_by { |r| r["id"] }.shuffle(random: rng).first(alloc[key] || 0)
    [key, picked.map { |r| "#{r["kind"]}/#{r["id"]}" }.sort]
  end
end

def self_test!
  fake = []
  %w[car van].each do |kind|
    120.times { |i| fake << { "kind" => kind, "id" => "bigmake/m#{i}", "decile" => (i % 10) + 1 } }
    12.times  { |i| fake << { "kind" => kind, "id" => "midmake/m#{i}", "decile" => nil } }
    3.times   { |i| fake << { "kind" => kind, "id" => "tinymake/m#{i}", "decile" => 7 } }
  end
  sizes = Hash.new(0)
  fake.each { |r| sizes["#{r["kind"]}/#{r["id"].split("/").first}"] += 1 }
  fake.each { |r| r["make_size"] = size_band(sizes["#{r["kind"]}/#{r["id"].split("/").first}"]) }
  strata = stratify(fake)

  # 1. The none band exists and is not truncated (finding A5).
  raise "A5: none band missing" unless strata.keys.any? { |k| k.include?("|none|") }
  alloc = allocate(strata, 200) # above the floor total: floors honored exactly
  none_total = alloc.select { |k, _| k.include?("|none|") }.values.sum
  raise "A5: none floor not honored (#{none_total})" if none_total < 2 * [NONE_FLOOR, 12].min
  raise "full-round allocation sum #{alloc.values.sum} != 200" unless alloc.values.sum == 200

  # 1b. Below-floor n scales down deterministically and still sums to n.
  alloc = allocate(strata, 60)

  # 2. Determinism: same seed → identical draw; different seed → different.
  a = draw(strata, alloc, 42)
  b = draw(strata, alloc, 42)
  c = draw(strata, alloc, 43)
  raise "seed determinism broken" unless a == b
  raise "seed not effective" if a == c

  # 3. Allocation sums to n (when population permits) and never overdraws.
  raise "allocation sum #{alloc.values.sum} != 60" unless alloc.values.sum == 60
  alloc.each { |k, v| raise "overdraw in #{k}" if v > strata[k].size }

  # 4. File-order independence: shuffled input, same sample.
  strata2 = stratify(fake.shuffle(random: Random.new(7)))
  raise "file-order dependence" unless draw(strata2, allocate(strata2, 60), 42) == a

  puts "self-test: OK (#{strata.size} strata exercised, none-band floor honored, deterministic, order-independent)"
end

# ── main ────────────────────────────────────────────────────────────────────
opts = { "n" => "400" }
ARGV.each do |a|
  case a
  when "--self-test" then self_test!; exit 0
  when /\A--tag=(.+)/ then opts["tag"] = $1
  when /\A--half=(s4w|s2w)\z/ then opts["half"] = $1
  when /\A--n=(\d+)\z/ then opts["n"] = $1
  when /\A--deciles=(.+)/ then opts["deciles"] = $1.split(",")
  when /\A--catalog=(.+)/ then opts["catalog"] = $1
  when /\A--build=(.+)/ then opts["catalog"] = File.join($1, "catalog"); opts["build_pin"] = $1
  else abort "unknown arg #{a}"
  end
end
abort "need --tag=<release tag> and --half=s4w|s2w (or --self-test)" unless opts["tag"] && opts["half"]

catalog = opts["catalog"] || File.join(ROOT, "catalog")
records = load_records(catalog, HALVES.fetch(opts["half"]))
if opts["deciles"]
  keep = opts["deciles"].flat_map { |d| d == "none" ? ["none"] : [d] }
  records.select! { |r| keep.include?(band_of(r["decile"])) }
end
strata = stratify(records)
n = opts["n"].to_i
alloc = allocate(strata, n)
seed_int = Digest::SHA256.hexdigest(opts["tag"]).to_i(16) % (2**62)
sample = draw(strata, alloc, seed_int)

puts format("%-28s %8s %8s", "stratum", "pop", "drawn")
strata.sort.each { |k, v| puts format("%-28s %8d %8d", k, v.size, alloc[k] || 0) }
puts format("%-28s %8d %8d", "TOTAL", records.size, sample.values.sum(&:size))

dir = File.join(ROOT, "data", "review", "audit-#{opts["tag"]}")
Dir.mkdir(dir) unless Dir.exist?(dir)
out = File.join(dir, "SAMPLE-#{opts["half"]}.yml")
File.write(out, {
  "tag" => opts["tag"], "half" => opts["half"], "requested_n" => n,
  "drawn_n" => sample.values.sum(&:size),
  "seed" => "sha256(tag) — regenerate with scripts/audit_sample.rb",
  "decile_filter" => opts["deciles"],
  "build_pin" => opts["build_pin"],  # v1.2: pin the BUILD, not just the tag — the 2W round measured a moving target (three population figures; RESULTS-s2w)
  "protocol" => "data/review/audit-PROTOCOL.md",
  "strata" => sample,
}.to_yaml)
puts "wrote #{out}"
