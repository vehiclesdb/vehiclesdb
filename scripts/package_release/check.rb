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
#    availability / popularity / former_ids / xrefs equal the JSON record's.
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
      want["makes"] += 1
      want["make_aliases"] += (mk["aliases"] || []).uniq.size
      want["make_countries"] += (mk["countries"] || []).uniq.size
    end
    JSON.parse(File.read(File.join(ROOT, paths.fetch("models")))).each do |m|
      models["#{kind}\t#{m['id']}"] = m
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
  want["meta"] = 11
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
