#!/usr/bin/env ruby
# Compare a local build's catalog/ against the RELEASED catalog/ at the tag.
# Reports, per kind: byte equality, record-set diff, and field-level diff on the
# intersection. Nothing is assumed equal; everything printed is measured.
require "json"
require "digest"

a = ARGV[0] # released (tag worktree)
b = ARGV[1] # local build/out
kinds = %w[car van truck bus motorcycle moped]

tot_only_a = 0
tot_only_b = 0
tot_changed = 0
puts format("%-11s %8s %8s  %-6s %8s %8s %9s", "kind", "released", "built", "bytes", "only_rel", "only_bld", "differing")
kinds.each do |k|
  fa = File.join(a, "catalog", k, "models.json")
  fb = File.join(b, "catalog", k, "models.json")
  unless File.exist?(fa) && File.exist?(fb)
    puts format("%-11s  MISSING (%s / %s)", k, File.exist?(fa), File.exist?(fb))
    next
  end
  ba = File.read(fa)
  bb = File.read(fb)
  ja = JSON.parse(ba).to_h { |m| [m["id"], m] }
  jb = JSON.parse(bb).to_h { |m| [m["id"], m] }
  only_a = ja.keys - jb.keys
  only_b = jb.keys - ja.keys
  common = ja.keys & jb.keys
  changed = common.reject { |id| ja[id] == jb[id] }
  tot_only_a += only_a.size
  tot_only_b += only_b.size
  tot_changed += changed.size
  puts format("%-11s %8d %8d  %-6s %8d %8d %9d", k, ja.size, jb.size,
              (ba == bb ? "SAME" : "DIFF"), only_a.size, only_b.size, changed.size)
  File.write("#{ARGV[2]}/diff-#{k}.txt",
             "ONLY_IN_RELEASE:\n#{only_a.sort.join("\n")}\n\nONLY_IN_BUILD:\n#{only_b.sort.join("\n")}\n\n" \
             "DIFFERING_FIELDS (first 40):\n" +
             changed.first(40).map { |id|
               fields = (ja[id].keys | jb[id].keys).reject { |f| ja[id][f] == jb[id][f] }
               "#{id}: #{fields.join(', ')}"
             }.join("\n"))
end
puts
puts "TOTAL only_in_release=#{tot_only_a}  only_in_build=#{tot_only_b}  differing_on_common=#{tot_changed}"

# decile-mass.json: the weights the bound reads.
%w[meta/decile-mass.json].each do |rel|
  fa = File.join(a, "catalog", rel)
  fb = File.join(b, "catalog", rel)
  next unless File.exist?(fa) && File.exist?(fb)
  same = File.read(fa) == File.read(fb)
  puts "#{rel}: #{same ? 'BYTE-IDENTICAL' : 'DIFFERS'}"
  unless same
    ja = JSON.parse(File.read(fa))
    jb = JSON.parse(File.read(fb))
    puts "  top-level keys equal: #{ja.keys == jb.keys}"
  end
end
