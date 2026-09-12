#!/usr/bin/env ruby
# frozen_string_literal: true
#
# check_rulings.rb — before applying a research dossier, grep the rulings for
# every cluster tag the change ships.
#
# WHY THIS EXISTS. data#281 shipped the kawasaki A-21 fold
# (`concours-14 -> 1400gtr`) after the owner had ruled A-21 **NO-FOLD** under
# D-3. Nothing was wrong with the batch's own verification — 41 folds
# re-derived clean, lint green, gates green, the removals reconciled one by one.
# The failure was structural: **the dossier and the ruling live in different
# documents**, the dossier's original proposal survived into the apply, and the
# override did not. No check in this repo reads NEGOTIATION.md.
#
# So: an apply's checklist must include this. It is deliberately a REPORTER and
# not a judge — it cannot tell an "A-21 is ruled no-fold" from an "A-21's
# evidence was accepted", and pretending otherwise would produce a gate people
# learn to wave through. It exits non-zero whenever it finds anything, so the
# applier has to read the hits and say why each one is satisfied.
#
# LIMITATION, learned 2026-08-21: cluster tags are only meaningful WITHIN a
# dossier. Grepping `D-2` for the honda window returns the OPEL dossier`s D-2
# ruling, which is a different question entirely. The tool cannot disambiguate
# and should not pretend to — it is one more reason the output must be READ
# rather than counted. When a hit looks unrelated, check which dossier the
# ruling turn is about before dismissing it, and say so in the PR either way.
#
# USAGE
#   ruby scripts/check_rulings.rb A-1 A-21 D-3          # explicit tags
#   ruby scripts/check_rulings.rb --from-diff           # tags from the working diff
#   ruby scripts/check_rulings.rb --from-diff origin/main
#
# A "tag" is a dossier cluster id: A-21, B-0, C-6, D-3, S-2, G-1 …
# The scan is deliberately narrow — a bare "A-1" matches far too much prose, so
# a line counts only if it carries the tag AND a ruling word.

require "set"

DOC = File.expand_path("../NEGOTIATION.md", __dir__)
abort "check_rulings: #{DOC} not found" unless File.exist?(DOC)

# Words that mark a line as a DECISION rather than discussion. Kept tight on
# purpose: every addition here trades a missed ruling for noise, and a noisy
# reporter is one people stop reading.
RULING = /\bRULED\b|\bRULING\b|\bADJUDICAT|\bNO-FOLD\b|does NOT fold|stays unfolded|
          \bOVERRIDE\b|\bBLOCKED\b|\bWITHDRAWN\b|\bDENIED\b|\bAPPROVED\b/xi

# Tag shape: one or two letters, a hyphen, digits. Anchored on both sides so
# "A-1" does not match inside "A-12" — that near-miss is the whole reason the
# boundary is explicit rather than a plain \b.
def tag_re(tag) = /(?<![A-Za-z0-9-])#{Regexp.escape(tag)}(?![0-9-])/

def tags_from_diff(base)
  diff = `git diff #{base} -- overrides/ enrich/ 2>/dev/null`
  diff = `git diff -- overrides/ enrich/` if diff.strip.empty?
  # Cluster tags live in the trailing comment of each added line.
  diff.lines.select { |l| l.start_with?("+") }
      # Section letters only (A-G plus S for the yamaha suspect series), or model
      # codes leak in as tags: a first pass matched ZX-6/ZX-9/ZX-10 out of the
      # very comments it was reading. Harmless here — they hit nothing — but a
      # reporter that cries wolf is one people stop reading.
      .flat_map { |l| l[/#(.*)$/, 1].to_s.scan(/(?<![A-Za-z0-9-])([A-GS]-\d{1,2})(?![0-9-])/) }
      .flatten.to_set.to_a.sort
end

args = ARGV.dup
if (i = args.index("--from-diff"))
  args.delete_at(i)
  base = args[i] && !args[i].start_with?("-") ? args.delete_at(i) : "origin/main"
  tags = tags_from_diff(base)
  puts "check_rulings: #{tags.size} cluster tag(s) in the diff vs #{base}: #{tags.join(' ')}"
else
  tags = args
end

if tags.empty?
  puts "check_rulings: no cluster tags to check — pass tags, or --from-diff"
  exit 0
end

lines = File.readlines(DOC)
hits = Hash.new { |h, k| h[k] = [] }
lines.each_with_index do |l, i|
  next unless l.match?(RULING)
  tags.each { |t| hits[t] << [i + 1, l.strip] if l.match?(tag_re(t)) }
end

if hits.empty?
  puts "check_rulings: no ruling lines mention #{tags.join(', ')} — nothing to reconcile."
  exit 0
end

puts
puts "=" * 78
puts "check_rulings: #{hits.values.sum(&:size)} ruling line(s) touch the tags this change ships."
puts "READ EVERY ONE and state in the PR why the change complies. This tool"
puts "cannot tell an override from an endorsement; that judgement is yours."
puts "=" * 78
hits.sort.each do |tag, rows|
  puts
  puts "── #{tag} — #{rows.size} hit(s)"
  rows.each { |ln, text| puts "   NEGOTIATION.md:#{ln}  #{text[0, 300]}" }
end
puts
exit 1
