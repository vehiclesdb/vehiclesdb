#!/usr/bin/env ruby
# frozen_string_literal: true
#
# find_structural_defects.rb — three detectors from the baseline audit's new
# defect classes (data/review/audit-v2026.07.5/RESULTS.md, I-15: every class
# gets a detector before scaled fixing). ALL THREE NOMINATE, NONE DECIDES —
# check the raws before acting; the standing rule for this tool family.
#
# WHAT THIS FILE CANNOT SEE (limits stated per the detector convention):
#  * stub-prefix: only PREFIX relationships — a stub named differently from
#    its series (z-reihe vs z4) needs the identity layer, not string prefix.
#  * typo-split: edit distance 1 only; two-char typos and transpositions at
#    distance 2 (Sirocco/Scirocco) stay invisible — extend deliberately, not
#    by default (distance 2 drowns in real sibling pairs like 306/307).
#  * connector-merge: the connector WORDLIST is enumerable but open — new
#    registry languages bring new connectors ("oder" was found in 2026-07;
#    check the newest register's habits before trusting a clean run).
#
# Usage: VDB_CATALOG=… ruby scripts/find_structural_defects.rb [kinds…]

require "json"

CATALOG = ENV["VDB_CATALOG"] || File.expand_path("../catalog", __dir__)
KINDS = (ARGV.empty? ? %w[car van truck bus motorcycle moped] : ARGV)

records = {}
KINDS.each do |k|
  path = File.join(CATALOG, k, "models.json")
  next unless File.exist?(path)
  JSON.parse(File.read(path)).each { |m| (records[[k, m["make_id"]]] ||= []) << m }
end

puts "== 1. STUB-PREFIX: short ids whose slug prefixes >=2 live in-make siblings =="
stub_total = 0
records.sort.each do |(kind, make), ms|
  slugs = ms.map { |m| m["slug"] }
  ms.each do |m|
    s = m["slug"]
    next unless s.length <= 2 || (s.length <= 4 && s !~ /\d/)
    kids = slugs.select { |o| o != s && (o.start_with?(s) || o.start_with?("#{s}-")) }
    next if kids.size < 2
    stub_total += 1
    puts format("  %-5s %-18s %-8s prefixes %d siblings: %s%s",
                kind, make, s.inspect, kids.size, kids.first(5).join(", "), kids.size > 5 ? ", …" : "")
  end
end
puts "  (#{stub_total} nominations)\n\n"

puts "== 2. TYPO-SPLIT: edit-distance-1 sibling names in-make (NFKD-fold blind spot) =="
def dist1?(a, b)
  return false if (a.length - b.length).abs > 1
  return false if a == b
  # substitution
  if a.length == b.length
    diff = 0
    a.chars.zip(b.chars) { |x, y| diff += 1 if x != y; return false if diff > 1 }
    return diff == 1
  end
  s, l = a.length < b.length ? [a, b] : [b, a]
  i = 0
  i += 1 while i < s.length && s[i] == l[i]
  s[i..] == l[i + 1..]
end
typo_total = 0
records.sort.each do |(kind, make), ms|
  names = ms.map { |m| [m["slug"], m["name"]] }
  names.combination(2) do |(s1, n1), (s2, n2)|
    a = n1.downcase.gsub(/[^a-z0-9]/, "")
    b = n2.downcase.gsub(/[^a-z0-9]/, "")
    next unless a.length > 3 && dist1?(a, b)
    typo_total += 1
    puts format("  %-5s %-18s %s <-> %s  (%s / %s)", kind, make, n1.inspect, n2.inspect, s1, s2)
  end
end
puts "  (#{typo_total} nominations — REAL siblings differ by one char too (306/307): check the raws)\n\n"

puts "== 3. CONNECTOR-MERGE: dual-market/pooled cells joined by a connector =="
CONNECTORS = /\b(oder|ou|or)\b|\s\/\s|,/i
conn_total = 0
records.sort.each do |(kind, make), ms|
  ms.each do |m|
    n = m["name"]
    next unless n =~ CONNECTORS || n.count("/") >= 1 && n =~ %r{[a-z]{3,}/[a-z]{3,}}i
    conn_total += 1
    puts format("  %-5s %-18s %s", kind, make, n.inspect)
  end
end
puts "  (#{conn_total} nominations — slash SERIES designations (X1/9, RT/10) are FINE; word/word joins are the class)"
