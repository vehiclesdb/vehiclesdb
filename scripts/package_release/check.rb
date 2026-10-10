#!/usr/bin/env ruby
# frozen_string_literal: true
#
# check.rb — prove the relational package is (1) lossless and (2) reproducible.
#
#   ruby scripts/package_release/check.rb [DATA_ROOT]
#
# 1. Runs scripts/package_release.sh twice over DATA_ROOT into two temp dirs and
#    requires identical SHA256SUMS (same machine, same toolchain).
# 2. Recounts every table from the JSON side (catalog/<kind>/{makes,models}.json
#    + manifest.json, Ruby stdlib only — no DuckDB involved) and requires the
#    SQLite and Parquet row counts to equal it.
# 3. Spot-checks values: for 50 deterministic sample models, the SQLite rows for
#    availability / popularity / former_ids / global+mass decile equal the JSON record's.
# 4. Fails on any make/model/popularity/availability key the package has no home
#    for (read_json(columns = …) and from_json would drop it silently).
# 5. Requires meta.attribution_notices to equal DATA_ROOT/ATTRIBUTION.md byte for byte,
#    in the SQLite file and in meta.parquet (the standalone .sqlite carries the notices).
#
# Exit 0 = all hold. Needs the same tools as package_release.sh.

require "json"
require "open3"
require "tmpdir"

HERE = __dir__
ROOT = File.expand_path(ARGV[0] || File.join(HERE, "..", ".."))
PKG  = File.join(HERE, "..", "package_release.sh")

def sh!(*cmd)
  out, err, st = Open3.capture3(*cmd)
  abort "check: #{cmd.join(' ')} failed:\n#{err}#{out}" unless st.success?
  out
end

def sqlite(db, sql) = sh!("sqlite3", "-separator", "\t", db, sql)
def fail!(msg) = (warn "check: FAIL — #{msg}"; exit 1)

# Every key the package stores or derives. read_json(columns = …) and from_json drop
# any other key SILENTLY, so a field added to the catalog must fail here first.
MODEL_KEYS = %w[id make_id slug name kind body_types regions sources aliases former_ids availability popularity xrefs].freeze
MAKE_KEYS  = %w[id slug name aliases countries kinds].freeze # kinds == [file kind]: makes.kind
POP_KEYS   = %w[global_decile mass_decile by_country].freeze
CELL_KEYS  = %w[rank decile confidence].freeze
AVAIL_KEYS = %w[country evidence source].freeze
def unpackaged!(where, keys, known)
  extra = keys - known
  fail!("#{where}: field(s) #{extra.join(', ')} have no home in the package (add them to schema.sql + package_release.sh)") unless extra.empty?
end

manifest = JSON.parse(File.read(File.join(ROOT, "manifest.json")))
version = manifest.fetch("version")

Dir.mktmpdir("vdbpkg-check") do |tmp|
  a = File.join(tmp, "a")
  b = File.join(tmp, "b")
  sh!("bash", PKG, ROOT, a)
  sh!("bash", PKG, ROOT, b)
  sa = File.read(File.join(a, "SHA256SUMS"))
  sb = File.read(File.join(b, "SHA256SUMS"))
  fail!("two runs differ:\n#{sa}\n---\n#{sb}") unless sa == sb
  puts "reproducible: #{sa.lines.size} files byte-identical across two runs"

  # ── JSON-side counts ─────────────────────────────────────────────────────
  want = Hash.new(0)
  models = {}
  manifest.fetch("catalog").each do |kind, paths|
    JSON.parse(File.read(File.join(ROOT, paths.fetch("makes")))).each do |mk|
      unpackaged!("make #{kind}/#{mk['id']}", mk.keys, MAKE_KEYS)
      want["makes"] += 1
      want["make_aliases"] += (mk["aliases"] || []).uniq.size
      want["make_countries"] += (mk["countries"] || []).uniq.size
    end
    JSON.parse(File.read(File.join(ROOT, paths.fetch("models")))).each do |m|
      models["#{kind}\t#{m['id']}"] = m
      unpackaged!("model #{kind}/#{m['id']}", m.keys, MODEL_KEYS)
      unpackaged!("model #{kind}/#{m['id']} popularity", (m["popularity"] || {}).keys, POP_KEYS)
      (m.dig("popularity", "by_country") || {}).each_value { |c| unpackaged!("model #{kind}/#{m['id']} by_country", c.keys, CELL_KEYS) }
      m["availability"].each { |x| unpackaged!("model #{kind}/#{m['id']} availability", x.keys, AVAIL_KEYS) }
      want["models"] += 1
      want["availability"] += m["availability"].size
      want["popularity"] += (m.dig("popularity", "by_country") || {}).size
      want["model_body_types"] += (m["body_types"] || []).size
      want["model_regions"] += (m["regions"] || []).uniq.size
      want["model_sources"] += (m["sources"] || []).uniq.size
      want["model_aliases"] += (m["aliases"] || []).uniq.size
      want["former_ids"] += (m["former_ids"] || []).size
      want["xrefs"] += (m["xrefs"] || {}).values.sum { |v| v.uniq.size }
    end
  end
  want["meta"] = 12 # 11 manifest facts + attribution_notices (ATTRIBUTION.md verbatim)
  want["sources"] = manifest["sources"].size
  want["countries"] = manifest["countries"].size
  fail!("manifest kinds total != catalog records") unless manifest["kinds"].values.sum { |v| v["models"] } == want["models"]

  db = File.join(a, "vehiclesdb-#{version}.sqlite")
  pq = File.join(a, "vehiclesdb-#{version}-parquet")
  want.sort.each do |table, n|
    got_l = sqlite(db, "SELECT count(*) FROM #{table}").to_i
    got_p = sh!("duckdb", "-noheader", "-list", "-c", "SELECT count(*) FROM '#{pq}/#{table}.parquet'").to_i
    fail!("#{table}: json #{n}, sqlite #{got_l}, parquet #{got_p}") unless got_l == n && got_p == n
    puts format("  %-17s %8d rows  json = sqlite = parquet", table, n)
  end

  # ── the upstream notices travel inside each format, byte for byte ──────
  notices = File.binread(File.join(ROOT, "ATTRIBUTION.md"))
  lite_hex = sqlite(db, "SELECT hex(CAST(value AS BLOB)) FROM meta WHERE key = 'attribution_notices'").strip
  fail!("sqlite meta.attribution_notices != ATTRIBUTION.md") unless lite_hex == notices.unpack1("H*").upcase
  pq_hex = sh!("duckdb", "-noheader", "-list", "-c",
               "SELECT hex(encode(value)) FROM '#{pq}/meta.parquet' WHERE key = 'attribution_notices'").strip
  fail!("parquet meta.attribution_notices != ATTRIBUTION.md") unless pq_hex == notices.unpack1("H*").upcase
  puts "notices: meta.attribution_notices == ATTRIBUTION.md (#{notices.bytesize} B) in sqlite and parquet"

  # ── value spot-check ────────────────────────────────────────────────────
  keys = models.keys.sort
  sample = (0...50).map { |i| keys[(i * keys.size) / 50] }
  sample.each do |key|
    kind, id = key.split("\t")
    m = models[key]
    esc = id.gsub("'", "''")
    where = "kind = '#{kind}' AND model_id = '#{esc}'"
    av = sqlite(db, "SELECT country, evidence, source FROM availability WHERE #{where} ORDER BY 1, 3").lines.map(&:chomp)
    exp = m["availability"].map { |x| [x["country"], x["evidence"], x["source"]].join("\t") }.sort_by { |l| l.split("\t").values_at(0, 2) }
    fail!("availability differs for #{kind}/#{id}") unless av == exp
    pop = sqlite(db, "SELECT country, rank, decile, confidence FROM popularity WHERE #{where} ORDER BY 1").lines.map(&:chomp)
    expp = (m.dig("popularity", "by_country") || {}).sort.map { |cc, p| [cc, p["rank"], p["decile"], p["confidence"]].join("\t") }
    fail!("popularity differs for #{kind}/#{id}") unless pop == expp
    fi = sqlite(db, "SELECT former_id FROM former_ids WHERE #{where} ORDER BY 1").lines.map(&:chomp)
    fail!("former_ids differ for #{kind}/#{id}") unless fi == (m["former_ids"] || []).sort
    md = sqlite(db, "SELECT coalesce(global_decile, ''), coalesce(mass_decile, '') FROM models WHERE kind = '#{kind}' AND id = '#{esc}'").chomp
    expd = [m.dig("popularity", "global_decile"), m.dig("popularity", "mass_decile")].map { |v| v.to_s }.join("\t")
    fail!("deciles differ for #{kind}/#{id}: #{md.inspect} vs #{expd.inspect}") unless md == expd
  end
  puts "values: 50 sample models match JSON (availability, popularity, former_ids, deciles)"
  fail!("sqlite integrity") unless sqlite(db, "PRAGMA integrity_check").strip == "ok"
  puts "check: OK — #{version}"
end
