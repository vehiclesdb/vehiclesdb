#!/usr/bin/env ruby
# frozen_string_literal: true
#
# union_resolve.rb — resolve a rebase conflict in an append-only override file
# as a PURE UNION, and PROVE nothing was dropped.
#
# WHY THIS EXISTS. Both maintainers append to the same EOF region of
# `overrides/models/former_ids.yml` (and `moves.yml`), so a rebase across a
# concurrent fold batch conflicts on almost every branch. Neither side is
# "wrong" — the correct resolution is always both, in order — and the standing
# checklist says so explicitly:
#
#     "Resolve as PURE UNION: keep BOTH conflict sides in order (ours=main
#      first, then yours). Script it — hand-picking is where chains sneak in."
#
# The failure it guards is silent. A hand-resolve that drops one alias line
# produces a file that parses, lints, builds, and passes the gate — right up
# until a consumer follows the missing id and 404s. There is no downstream check
# that can tell you an alias was never written.
#
# WHAT IT ASSERTS, and the assertions are the point:
#   1. every alias key present on EITHER side of EVERY conflict block is still
#      present after the union — collected BEFORE resolving, so a dropped line
#      fails loudly instead of vanishing
#   2. no conflict markers survive
#   3. the file still parses
#   4. NO ALIAS CHAINS anywhere in the file (A -> X where X is itself a key),
#      not merely in the conflicted region — a union can create a chain out of
#      two individually-fine sides
#
# Usage:  ruby scripts/union_resolve.rb overrides/models/former_ids.yml
#         git add <file> && git rebase --continue
#
# Exit 0 = resolved and proven. Non-zero = nothing written that you should trust;
# read the message, do not "fix it up" by hand.

require "yaml"

path = ARGV[0]
abort "usage: union_resolve.rb <path-to-conflicted-yml>" unless path && File.exist?(path)
label = path.sub(%r{\A.*/(?=overrides/)}, "")   # name the file in every message:
                                                # a bare count invites misreading
                                                # one file's total as another's.

s = File.read(path)
blocks = s.scan(/<<<<<<< [^\n]*\n(.*?)=======\n(.*?)>>>>>>> [^\n]*\n/m)
abort "#{label}: no conflict blocks — nothing to resolve" if blocks.empty?

KEY_RE = /^"([^"]+)":/
expected = blocks.flat_map { |ours, theirs| (ours + theirs).scan(KEY_RE).flatten }.uniq

s = s.gsub(/<<<<<<< [^\n]*\n(.*?)=======\n(.*?)>>>>>>> [^\n]*\n/m) do
  ours, theirs = Regexp.last_match(1), Regexp.last_match(2)
  # main side first, exactly one newline between, then ours
  ours.sub(/\n*\z/, "\n") + theirs
end
abort "#{label}: conflict markers survived the union — refusing to write" if s.match?(/^(<<<<<<<|=======|>>>>>>>)/)
File.write(path, s)

doc = begin
  YAML.safe_load_file(path, aliases: false) || {}
rescue Psych::SyntaxError => e
  abort "#{label}: does not parse after union — #{e.message}"
end

missing = expected.reject { |k| doc.key?(k) }
unless missing.empty?
  abort "#{label}: THE UNION LOST #{missing.size} KEY(S) that were present on one side: " \
        "#{missing.first(8).inspect}. Nothing downstream would have caught this — " \
        "the file parses and builds fine with an alias missing, and the consumer 404s later."
end

target = ->(v) { v.is_a?(Hash) ? v["to"] : v }
chains = doc.select { |_, v| doc.key?(target.call(v)) }
unless chains.empty?
  abort "#{label}: #{chains.size} ALIAS CHAIN(S) after the union — #{chains.first(5).inspect}. " \
        "Two individually-correct sides can compose into A -> X -> Y. Repoint the first hop " \
        "at the FINAL target before continuing the rebase."
end

puts "#{label}: union resolved — #{blocks.size} block(s), " \
     "#{expected.size} key(s) from both sides all present, 0 chains, #{doc.size} entries total"
