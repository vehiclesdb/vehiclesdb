#!/usr/bin/env ruby
# frozen_string_literal: true
#
# find_casing_contradictions.rb — find tokens that ONE MAKE spells two different
# ways in the published catalog ("FLH Electra Glide" alongside "Flh Duo Glide").
#
# WHY THIS DETECTOR IS DIFFERENT FROM THE OTHER TWO
#
# scripts/find_published_name_defects.rb asks "is this token spelled in caps
# somewhere in the catalog?" — a catalog-wide question that needs a judgement
# call about whether the token is an initialism at all. Its check-1 output is a
# list of *candidates*, and most of the work is deciding which are real words
# (Fat BOY, Super CUB, Piaggio APE would all be wrong).
#
# This one asks a narrower question with no judgement in it: **does one make
# spell the same token both ways?** If Harley publishes both `FXS Low Rider`
# and `Fxs Blackline`, one of them is wrong no matter what FXS stands for. No
# dictionary, no word list, no external source, no opinion about acronyms — the
# dataset contradicts itself and that is the whole finding.
#
# Scoped PER MAKE deliberately. Type codes are marque-scoped facts: Honda's CBR
# says nothing about whether Kawasaki should capitalise the same three letters,
# and a catalog-wide comparison manufactures collisions across marques that have
# no relationship. (This is the same reasoning that kept `LE` out of the global
# acronym pins — moto-guzzi wants the French article, indian wants Limited
# Edition. Cross-make evidence is not evidence.)
#
# IT FINDS THE DISAGREEMENT. IT DOES NOT RESOLVE IT.
#
# The majority spelling is NOT automatically right, and the counts are printed
# so you can see that for yourself rather than trusting a heuristic:
#
#   mercedes-benz VITO   VITOx4 / Vitox1   <- the SINGLE record is correct.
#                                             "Vito" is a Mercedes nameplate
#                                             word, not an initialism; the four
#                                             all-caps ones are the defect.
#   mg            MGA    MGAx1 / Mgax4     <- the opposite: MGA is right and
#                                             the four Title-cased ones are the
#                                             defect. Same shape, inverse answer.
#
# Two records, opposite resolutions, identical detector output. Anything that
# auto-applied "majority wins" would get one of them wrong every time. Read the
# marque, then decide.
#
# HOW TO FIX ONE
#   * whole token wrong across a make, and the token is never a word anywhere
#     -> a pin in overrides/styling.yml `acronyms:` (global; read the warning
#        in that file about rename keys before you do this)
#   * one or two records, or the token IS a word in some other marque
#     -> per-record keys in overrides/models/renames.yml
#     -> and if the slug moves, an overrides/models/former_ids.yml alias, or
#        the id-contract gate will fail the build
#
# Usage:
#   ruby scripts/find_casing_contradictions.rb                # published catalog
#   VDB_CATALOG=../s2w-pipeline/build/out/catalog ruby scripts/find_casing_contradictions.rb
#   ruby scripts/find_casing_contradictions.rb motorcycle moped   # limit to kinds

require "json"

ROOT = File.expand_path("..", __dir__)
CATALOG = ENV["VDB_CATALOG"] ? File.expand_path(ENV["VDB_CATALOG"]) : File.join(ROOT, "catalog")
ALL_KINDS = %w[car van motorcycle moped truck bus].freeze
kinds = ARGV.empty? ? ALL_KINDS : (ARGV & ALL_KINDS)
abort "no valid kinds in #{ARGV.inspect} (want any of #{ALL_KINDS.join(" ")})" if kinds.empty?

records = kinds.flat_map do |k|
  path = File.join(CATALOG, k, "models.json")
  File.exist?(path) ? JSON.parse(File.read(path)).map { |m| m.merge("kind" => k) } : []
end
abort "no models found under #{CATALOG} — build first, or set VDB_CATALOG" if records.empty?

# Split on whitespace and slashes only. NOT on hyphens: "ZX-6R" is one token to
# a reader, and splitting it would compare "ZX" against every hyphenated variant
# and drown the signal. Tokens of 2..5 alpha chars only — single letters are
# almost always a real word or a series letter, and 6+ is a word far more often
# than an initialism.
forms = Hash.new { |h, k| h[k] = Hash.new { |a, b| a[b] = [] } }
records.each do |m|
  m["name"].to_s.split(%r{[\s/]+}).each do |tok|
    next unless tok =~ /\A[A-Za-z]{2,5}\z/
    forms[[m["make_id"], tok.upcase]][tok] << m
  end
end

# A contradiction needs an all-caps spelling AND a not-all-caps spelling. Two
# mixed spellings that are both non-caps ("McLaren"/"Mclaren") are a different
# and rarer defect; left out so this stays a single-signal detector.
conflicts = forms.select do |_key, spellings|
  spellings.size > 1 &&
    spellings.keys.any? { |s| s == s.upcase } &&
    spellings.keys.any? { |s| s != s.upcase }
end

touched = conflicts.values.flat_map { |s| s.values.flatten }.uniq
puts "== tokens one make spells two ways =="
puts "#{conflicts.size} make+token contradictions across #{touched.size} records"
puts "by kind: " + touched.group_by { |m| m["kind"] }.map { |k, v| "#{k} #{v.size}" }.sort.join("  ")
puts
puts "MAJORITY IS NOT AUTHORITY — mercedes VITOx4/Vitox1 resolves to the single"
puts "record; mg MGAx1/Mgax4 resolves to the single record the other way."
puts

conflicts
  .sort_by { |(make, tok), s| [make, -s.values.flatten.size, tok] }
  .each do |(make, tok), spellings|
    tally = spellings.map { |s, ms| "#{s} x#{ms.size}" }.join("  /  ")
    puts "#{make}  [#{tok}]  #{tally}"
    spellings.each do |spelling, ms|
      ms.sort_by { |m| m["id"] }.first(4).each { |m| puts "    #{spelling.ljust(6)} #{m["kind"]}/#{m["id"]}  #{m["name"].inspect}" }
      puts "    #{" " * 6} … and #{ms.size - 4} more" if ms.size > 4
    end
    puts
  end

puts "#{conflicts.size} contradictions, #{touched.size} records."
