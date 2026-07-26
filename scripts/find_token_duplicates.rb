#!/usr/bin/env ruby
# frozen_string_literal: true
#
# find_token_duplicates.rb — the same vehicle published twice under names that
# differ by which TOKENS are present, or by the ORDER they sit in.
#
#     bsa/thunderbolt      "Thunderbolt"       fi,nl,nz   ~104 rows
#     bsa/thunderbolt-650  "Thunderbolt 650"   nl,nz      ~5 rows    <- same bike
#     bsa/650-thunderbolt  "650 Thunderbolt"   nl,nz      ~2 rows    <- same bike
#     bsa/thunderbolt-a65  "Thunderbolt A65"   fi,nl      ~2 rows    <- same bike
#
# WHY THIS EXISTS, AND WHY IT IS NOT find_duplicate_spellings
# `find_duplicate_spellings` folds a name to [A-Z0-9] and tests the folded
# strings for EQUALITY. That catches "280 Se" vs "280SE" and is structurally
# blind to everything above: "THUNDERBOLT" != "THUNDERBOLT650" != "650THUNDERBOLT".
# Run against the two-wheeler half it reports "0 collision groups, 0 records"
# while the half contains the Thunderbolt cluster (5 ids), the A65 Lightning
# cluster (7 ids) and the rest of what this script prints. Both scripts are
# needed; neither subsumes the other.
#
# READS THE PUBLISHED CATALOG, not the override layer — same contract as
# find_duplicate_spellings. A merge you just authored does not reduce the count
# until a build runs; point VDB_CATALOG at a local build to see the real figure.
#
# Usage:  ruby find_token_duplicates.rb [--kind=motorcycle] [--make=bsa]
#                                       [--mode=word|boundary] [--limit=20]
#         (env: VDB_CATALOG, VDB_RAW — see below)
#
#   VDB_CATALOG  catalog/ dir to read (default: THIS repo catalog/, same
#                convention as the other five find_* detectors; point it at a
#                local pipeline build to see pre-release figures)
#   VDB_RAW      OPTIONAL dir of flattened register extracts, used only to
#                print approximate per-id row counts. Absent -> the script
#                still runs and ranks on published rank/decile alone.
#
# ─────────────────────────────────────────────────────────────────────────────
# IT PROPOSES; IT DOES NOT DECIDE. Output is a WORKLIST.
# ─────────────────────────────────────────────────────────────────────────────
# Every group needs one human call, because a token-subset relationship has TWO
# completely different causes and the shapes are not separable by string
# evidence alone:
#
#   (a) SPELLING     one machine, two spellings   -> fold (D6)
#   (b) ALTITUDE     a FAMILY row beside a MODEL row -> both may be legitimate;
#                    this is a granularity decision, never an automatic merge
#
# The script labels which one each edge LOOKS like and prints the reason. The
# label is a sort key for a reviewer, not a verdict. See §ALTITUDE below.
#
# ─────────────────────────────────────────────────────────────────────────────
# WHAT IT CANNOT FIND (measured, not hypothetical — do not read a clean run as
# "no duplicates")
# ─────────────────────────────────────────────────────────────────────────────
#  1. GLUED single-token duplicates. Tokenisation needs a separator, so an id
#     whose whole name is one run of characters cannot be a subset of anything.
#     This misses `bsa/a65t` "A65T" — the FIFTH member of the Thunderbolt
#     cluster the header opens with. The script finds 4 of those 5 and says so;
#     it is NOT a complete cluster finder. No token method can reach a65t from
#     the Thunderbolt side, because the two strings share no token at all.
#
#     --mode=boundary was built to fix this by splitting at letter/digit seams
#     (inverting the normalizer.rb:153 collapse) and IT DOES NOT WORK. Measured
#     on the 2W half: 688 groups / 3784 records — over half the half — and the
#     top group is FORTY-FOUR Honda ids (cbr, cbr600f, cbr1000rr, cbr1100xx,
#     cbr125r, cbr250r …) fused into one, because "CBR" splits out as a shared
#     token and every remaining difference is digits and single letters, which
#     the labeller reads as "number/code" and therefore SPELLING. Those are 44
#     different motorcycles. It is the same blob failure as rule 1 below, in a
#     different disguise, and type-code families dominate this half so it is not
#     a corner case.
#     The flag is LEFT IN because it is genuinely useful scoped to ONE make
#     whose names are words rather than codes, but it prints a warning, it is
#     never the default, and its output must not be counted.
#  2. SUFFIX-LETTER families, which are the biggest 2W duplicate population and
#     are entirely invisible here: honda NSC50 / NSC50T2 / NSC50WH / NSC50MPD,
#     honda WW125 / WW125A / WW125S / WW125EX2, honda CBR600F / FA / FK / FS,
#     honda PC31..PC39, SC32..SC38. These need a code-grammar detector keyed on
#     the marque's type-code shape, NOT a token detector. Different tool.
#  3. Duplicates ACROSS makes — INCLUDING THE CASE WHERE ONE MARQUE HAS TWO
#     make_ids. This is the script's most serious blind spot and it is BY
#     CONSTRUCTION, not by oversight: everything above is scoped within
#     (make_id, kind), so if a marque is split across two make_ids then its
#     duplicated models sit in different scopes and are never compared.
#     CONFIRMED LIVE EXAMPLE (found by another auditor, verified here against
#     this build): the Solex marque is split `solex` / `velosolex`, and
#       moped/solex/1700  +  moped/velosolex/1700
#       moped/solex/3800  +  moped/velosolex/3800   (+ velosolex/s3800)
#       moped/solex/5000  +  moped/velosolex/5000
#     are all live — three slug pairs for one marque — while
#     overrides/makes/aliases.yml has NO Solex entry at all. This script reports
#     zero for it and always will.
#     Cross-make comparison in general is still refused, because it manufactures
#     collisions between unrelated marques (mutt/mastiff and big-dog/mastiff are
#     two marques' real models — data/review/mutt.yml says so explicitly). The
#     narrow, safe version is implemented as --cross-make below: make_ids that
#     are AFFIX VARIANTS of each other AND share a model slug. That pairing
#     requirement is the D12/I-8 model-overlap evidence rule, and it is what
#     keeps the check from firing on genuine homonyms.
#  4. Duplicates across KINDS. Also deliberate: the uk_dft VEH0120 "Motorcycles"
#     body type contains UK mopeds by design (kind_maps/uk_dft.yml), so a
#     motorcycle-kind twin of a moped record is EXPECTED and must not be folded.
#  5. Synonym duplicates with no shared token (e.g. a marque's export name beside
#     its home-market name). Nothing string-based will get these.
#
# ─────────────────────────────────────────────────────────────────────────────
# KNOWN FALSE-POSITIVE SHAPES, with the concrete cases that produce them
# ─────────────────────────────────────────────────────────────────────────────
#  * SERIES-SUFFIX DESIGNATIONS THAT LOOK LIKE DISPLACEMENTS.
#    bmw/r80 "R80" vs bmw/r80-7 "R80/7" — the /7 is BMW's series marker and the
#    two are different motorcycles (the 1978 R80/7 and the 1984+ R80). The
#    tokeniser sees ["R80"] ⊊ ["R80","7"], the added token is a number, so this
#    scores SPELLING — the script's HIGHEST-confidence label. It is wrong. This
#    is the single most important reason the output is a worklist: the top of the
#    list is not safer than the bottom, it is only more token-similar.
#  * THE MIRROR IMAGE: A DISPLACEMENT THAT REALLY IS A DIFFERENT MACHINE.
#    bsa/gold-star "Gold Star" vs bsa/gold-star-250 "Gold Star 250" — the Gold
#    Star 250 is the C15-based 250, a different motorcycle from the 500. Added
#    token is a number, so again SPELLING, again wrong. Compare
#    bsa/thunderbolt + "650", which IS one machine because the Thunderbolt was
#    only ever a 650. NOTHING IN THE STRINGS SEPARATES THESE TWO CASES; it takes
#    knowing whether the marque sold that nameplate in more than one capacity.
#    The script prints the distinct numeric tokens in each cluster so a reviewer
#    sees the question, and that is the most it can do.
#  * REAL VARIANTS SOLD ALONGSIDE THE BASE. bmw/f650gs vs f650gs-dakar are two
#    products; whether the Dakar is a model or a trim (D8) is a judgment call.
#  * MARQUES WHOSE NAMEPLATE IS A NUMBER. debt:bare-displacement-2w — for KTM,
#    CFMoto, Sherco the bare number is a displacement and the family word is
#    missing, so "390" ⊊ "390 Duke" is a REPAIR, not a merge.
#  * ROMAN NUMERALS AND Mk MARKS. "Rocket" ⊊ "Rocket III" is a generation, and
#    DEBT.md records the Jaguar Mk family as a live split-model question. Never
#    auto-fold a numeral edge.
#
# ─────────────────────────────────────────────────────────────────────────────
# §ALTITUDE — how the two causes are separated, and why fan-out is the signal
# ─────────────────────────────────────────────────────────────────────────────
# The discriminator is WHAT KIND OF TOKEN the superset ADDS, decided per edge:
#
#   B adds a NAME WORD (purely-alphabetic token, 3+ chars, absent from A)
#     ->  ALTITUDE. Adding a WORD to a base is how a marque names a MODEL inside
#         a RANGE:  "A65" + Lightning,  "A65" + Thunderbolt,  "A7" + Star Twin,
#         "A10" + Golden Flash,  "Star" + Gold/Blue/Royal/Empire/Shooting.
#
#   B adds only NUMBERS and TYPE CODES (anything else)
#     ->  SPELLING. Adding a displacement or a type code to a name is how a
#         REGISTER respells ONE machine:  "Thunderbolt" + 650,
#         "Thunderbolt" + A65,  "Lightning" + A65L,  "Golden Flash" + A10.
#
# THREE OVERRIDES force ALTITUDE regardless, each on evidence rather than shape:
#
#   (i) A is GENMODEL-ROLLUP. If uk_dft's GenModel for A spans several Model
#       strings then A is PROVEN to be a family row by the register itself, so
#       none of its edges can be a respelling. This was found by running the
#       version without it: the top of the worklist filled with
#       triumph/tiger (43,623 rows, subsetting 27 Tiger models), suzuki/gsx,
#       kawasaki/zx, yamaha/yzf, yamaha/mt, piaggio/vespa, ducati/multistrada,
#       harley-davidson/sportster — every one a gb family row, none a duplicate.
#
#  (ii) A's supersets add TWO OR MORE DISTINCT NUMBERS. A marque that sells one
#       nameplate at 800/900/1200 is running a RANGE, so A is its family word:
#       triumph/tiger, harley-davidson/sportster (883/1200/…),
#       peugeot/speedfight (2/3). Contrast bsa/thunderbolt, whose supersets add
#       650 and nothing else — respelling one machine yields the SAME number
#       every time, which is what separates this from the fan-out rule rejected
#       below: duplication inflates fan-out but it cannot invent a second
#       capacity. This is also the only handle on the Gold Star 250 trap.
#
# (iii) B adds a GENERATION MARKER — a Roman numeral or Mk. "Fiddle" -> "Fiddle
#       II" is a generation, not a spelling, and styling.yml pins II/III as
#       acronym tokens precisely because marques use them this way. Needed
#       explicitly because "II" is too short to be a NAME WORD.
#
# TWO EARLIER RULES WERE TRIED AND REJECTED, recorded so nobody re-adds them:
#
#   1. Transitive closure over ALL edges. Turned BSA into one 15-id blob: "Star"
#      is a token-subset of nine different motorcycles (Gold Star, Blue Star,
#      Royal Star, Empire Star, Shooting Star, Star Twin, A7 Star Twin …) and a
#      shared common word glued the lot together. A blob is worse than nothing —
#      it hides the real four-id Thunderbolt cluster inside noise.
#
#   2. FAN-OUT (count A's distinct supersets; >=2 means A is a family). This
#      looks right and is BACKWARDS on exactly the cases that matter, because
#      DUPLICATION ITSELF INFLATES FAN-OUT. bare "Thunderbolt" has three
#      supersets — Thunderbolt 650, 650 Thunderbolt, Thunderbolt A65 — for the
#      sole reason that three registers respelled one bike, and fan-out then
#      reads that as "family" and excludes the load-bearing 104-row id from its
#      own cluster. Measured: it reported the Thunderbolt cluster as 2 ids
#      instead of 4. Fan-out cannot separate "family with many models" from "one
#      model with many respellings" — both produce many supersets. It survives
#      only as a printed annotation (COMMON-WORD HUB) for reviewer context.
#
# ALTITUDE EDGES DO NOT JOIN CLUSTERS. Clusters are built ONLY from PERMUTATION
# and SPELLING edges; ALTITUDE edges print as annotations and never merge two
# groups, which is what keeps rule 1's blob from coming back.
#
# The bare-family row therefore stays OUT of the duplicate cluster when its
# supersets are differently-NAMED models (bsa/a65 "A65" — the A65 was a range:
# Star, Thunderbolt, Lightning, Spitfire, Hornet, Firebird), and stays IN when
# its supersets only respell it (bsa/thunderbolt). That matches what the curator
# concluded by hand: enrich/bsa.yml enriches a65 SEPARATELY (1962-72,
# gracesguide) from the five Thunderbolt ids (1964-72).
#
# A second, INDEPENDENT altitude signal is emitted where it is available:
#   GENMODEL-ROLLUP — uk_dft keys on GenModel, which is a make-prefixed FAMILY
#   column, so a gb-evidenced id can be a rollup with no sibling ids at all and
#   therefore fanout 0. yamaha/xsr is one id covering XSR125, XSR700, XSR700
#   XTribute, XSR900 and XSR900 Abarth. Detected by counting distinct uk_dft
#   Model strings under the id's GenModel. This flag fires independently of any
#   token edge and is the only altitude evidence for single-id rollups.
#
# ─────────────────────────────────────────────────────────────────────────────
# §EVIDENCE ASYMMETRY — and an honest note on why the counts are approximate
# ─────────────────────────────────────────────────────────────────────────────
# The load-bearing id in a cluster is the one with the registrations; a 1-row id
# beside a 104-row id is the strong signal, and the sampled audit record
# bsa/thunderbolt-a65 was the 2-row straggler.
#
# THE PIPELINE DELIBERATELY DOES NOT PUBLISH COUNTS. reconciler.rb:21 — "Counts
# themselves stay private — only rank/decile ship (the D1 boundary)". So this
# script cannot read the number that would rank a group best. It prints two
# proxies and labels them:
#
#   rank/decile   AUTHORITATIVE but RELATIVE and per-country (from the catalog's
#                 own popularity block). Not comparable across countries.
#   rows~         APPROXIMATE and ABSOLUTE. Re-derived from the flattened raw
#                 register extracts in $VDB_RAW by re-matching the published
#                 name. It uses THIS SCRIPT'S normalisation, not the pipeline's,
#                 so it can disagree with what the build actually counted —
#                 treat it as an order-of-magnitude cue, never as a figure to
#                 quote. Marked with ~ everywhere it appears.
#
# If this graduates into scripts/, the right fix is for the reconciler to emit a
# private per-id count into catalog-plus (which is already the non-public layer),
# and for this script to read that instead of re-deriving anything.

require "json"
require "set"
require "optparse"

ROOT = File.expand_path("..", __dir__)
CATALOG = File.expand_path(
  ENV["VDB_CATALOG"] ||
  File.join(ROOT, "catalog")
)
RAW = File.expand_path(ENV["VDB_RAW"] || File.join(__dir__, "raw"))

opts = { kinds: %w[moped motorcycle], mode: "word", limit: 20, make: nil, cross_make: false }
OptionParser.new do |o|
  o.on("--kind=K")     { |v| opts[:kinds] = [v] }
  o.on("--make=M")     { |v| opts[:make] = v }
  o.on("--mode=M")     { |v| opts[:mode] = v }
  o.on("--limit=N")    { |v| opts[:limit] = v.to_i }
  o.on("--cross-make") { opts[:cross_make] = true }
end.parse!

# ── tokenisation ────────────────────────────────────────────────────────────
# word mode: split on anything that is not a letter or digit. This is the
#   conservative reading — it only sees seams the CURATOR left in the name.
# boundary mode: additionally split at letter<->digit seams, which inverts
#   normalizer.rb:153's two-wheeler space collapse and recovers glued ids like
#   "THUNDERBOLT650". Costs precision: "A65" becomes ["A","65"], so short
#   type codes start colliding with each other. Always report which mode ran.
# Roman numerals folded to digits so "Fiddle II" and "Fiddle 2" become the same
# token multiset. FOUND BY RUNNING THIS: sym/fiddle-2 "Fiddle 2" and
# sym/fiddle-ii "Fiddle II" are two live ids for ONE SYM generation, and without
# this fold the labeller sent one to SPELLING and the other to ALTITUDE, so the
# pair was never nominated.
#
# THE ALLOWLIST IS DELIBERATELY TWO ENTRIES. Valid Roman numerals collide
# viciously with real 2W type codes: XL is Harley's Sportster prefix (XL883) and
# also 40; DL is Suzuki's V-Strom code and also 550; CD is a Honda range and 400;
# CX, LC, MX, IX, VI all appear as codes. Folding any of those would corrupt real
# names. II and III are safe because styling.yml already pins exactly those two
# as global acronym tokens, on the finding that no 2W marque uses them as
# anything but numerals. Do not extend without the same evidence.
ROMAN_FOLD = { "II" => "2", "III" => "3" }.freeze

def tokens(name, mode)
  s = name.to_s.upcase
  s = s.gsub(/([A-Z])(\d)/, '\1 \2').gsub(/(\d)([A-Z])/, '\1 \2') if mode == "boundary"
  s.split(/[^A-Z0-9]+/).reject(&:empty?).map { |t| ROMAN_FOLD.fetch(t, t) }
end

def multiset(toks) = toks.tally

def subset?(a, b) # multiset a ⊆ multiset b
  a.all? { |t, n| b.fetch(t, 0) >= n }
end

# ── load the published catalog ──────────────────────────────────────────────
records = []
opts[:kinds].each do |kind|
  path = File.join(CATALOG, kind, "models.json")
  abort "no catalog at #{path}" unless File.exist?(path)
  JSON.parse(File.read(path)).each do |r|
    next if opts[:make] && r["make_id"] != opts[:make]
    records << {
      key: "#{kind}/#{r['id']}", kind: kind, make: r["make_id"], name: r["name"],
      countries: (r["availability"] || []).map { |a| a["country"] },
      sources: r["sources"] || [],
      pop: r["popularity"] || {},
    }
  end
end
records.each { |r| r[:ms] = multiset(tokens(r[:name], opts[:mode])) }

# ── COMPANION CHECK: one marque under two make_ids (--cross-make) ───────────
# Scoped to AFFIX-VARIANT make_id pairs that SHARE A MODEL SLUG. The shared slug
# is the evidence; without it this would fire on every marque whose name happens
# to contain another's. Catches solex/velosolex, and per another auditor's report
# would also catch zero/zero-motorcycles and emax/e-max.
if opts[:cross_make]
  slugs = {}
  records.each { |r| ((slugs[[r[:kind], r[:make]]] ||= {})[r[:key].split("/").last] = r) }
  mkeys = slugs.keys
  fold = ->(m) { m.to_s.downcase.gsub(/[^a-z0-9]/, "") }
  hits = []
  mkeys.combination(2) do |(k1, m1), (k2, m2)|
    next unless k1 == k2
    f1, f2 = fold.(m1), fold.(m2)
    short, long = [f1, f2].sort_by(&:length)
    next if short.length < 4
    next unless f1 == f2 || long.include?(short)
    shared = slugs[[k1, m1]].keys & slugs[[k2, m2]].keys
    next if shared.empty?
    hits << [k1, m1, m2, shared, slugs[[k1, m1]], slugs[[k2, m2]]]
  end
  puts "find_token_duplicates.rb --cross-make   kinds=#{opts[:kinds].join(',')}"
  puts "catalog: #{CATALOG}"
  puts
  puts "ONE MARQUE UNDER TWO make_ids — affix-variant make_ids that share >=1 model slug."
  puts "This is class D12 (make near-dupe), remedy makes/aliases.yml, NOT a model merge."
  puts "Still a WORKLIST: an affix pair can be two real marques (check the marque, not the string)."
  puts
  puts "pairs found: #{hits.size}"
  hits.sort_by { |_k, _a, _b, sh, _s1, _s2| -sh.size }.each do |kind, m1, m2, shared, s1, s2|
    puts "#{'─' * 78}"
    puts "  #{kind}: make_id #{m1.inspect}  vs  #{m2.inspect}   #{shared.size} shared model slug(s)"
    shared.sort.each do |sl|
      a, b = s1[sl], s2[sl]
      puts format("      %-34s %-12s   |   %-34s %-12s",
                  a[:key], "[#{a[:countries].join(',')}]", b[:key], "[#{b[:countries].join(',')}]")
    end
    only1 = (s1.keys - shared).sort
    only2 = (s2.keys - shared).sort
    puts "      #{m1} only: #{only1.join(', ')}" if only1.any?
    puts "      #{m2} only: #{only2.join(', ')}" if only2.any?
  end
  puts "#{'─' * 78}"
  exit 0
end

# ── optional: approximate per-id row counts from the flattened raw extracts ──
# Absent $VDB_RAW this whole block is skipped and rows~ prints as "?".
# INDEXED, not scanned: keyed [country][model-with-its-own-make-prefix-stripped]
# -> [[raw_make, n], …]. The first version scanned every raw row for every
# record (7,083 x ~290k rows) and did not finish in two minutes.
RAW_TABLES = {}
if Dir.exist?(RAW)
  norm = ->(s) { s.to_s.upcase.gsub(/[^A-Z0-9]/, "") }
  add = lambda do |cc, mk, md, n|
    rmk, rmd = norm.(mk), norm.(md)
    key = (rmd.start_with?(rmk) && rmd != rmk) ? rmd.sub(/\A#{Regexp.escape(rmk)}/, "") : rmd
    ((RAW_TABLES[cc] ||= {})[key] ||= []) << [rmk, n.to_i]
  end
  Dir[File.join(RAW, "nl_*.txt")].each do |f|
    File.foreach(f, chomp: true) { |l| mk, md, n = l.split("|", 3); add.("nl", mk, md, n) }
  end
  Dir[File.join(RAW, "nz_*.txt")].each do |f|
    File.foreach(f, chomp: true) { |l| mk, md, n = l.split("|", 3); add.("nz", mk, md, n) }
  end
  f = File.join(RAW, "fi_L.txt")
  File.foreach(f, chomp: true) { |l| c, mk, mm, kn, _tn, n = l.split("|"); add.("fi", mk, kn.to_s.empty? ? mm : kn, n) } if File.exist?(f)
  f = File.join(RAW, "es_L.txt")
  File.foreach(f, chomp: true) { |l| _c, mk, md, n = l.split("|"); add.("es", mk, md, n) } if File.exist?(f)
  f = File.join(RAW, "lu_L.txt")
  File.foreach(f, chomp: true) { |l| _c, mk, md, _tn, n = l.split("|"); add.("lu", mk, md, n) } if File.exist?(f)
  f = File.join(RAW, "ua_L.txt")
  File.foreach(f, chomp: true) { |l| _k, mk, md, n = l.split("|"); add.("ua", mk, md, n) } if File.exist?(f)
  f = File.join(RAW, "th.txt")
  File.foreach(f, chomp: true) { |l| _t, mk, md, n = l.split("|"); add.("th", mk, md, n) } if File.exist?(f)
  f = File.join(RAW, "uk.txt")
  File.foreach(f, chomp: true) { |l| _b, mk, gm, _md, _fu, _st, n = l.split("|"); add.("gb", mk, gm, n) } if File.exist?(f)
end

def approx_rows(rec, tables)
  return nil if tables.empty?
  want = rec[:name].to_s.upcase.gsub(/[^A-Z0-9]/, "")
  mk   = rec[:make].to_s.upcase.delete("-")
  total = 0
  rec[:countries].each do |cc|
    ((tables[cc] || {})[want] || []).each do |rmk, n|
      total += n if rmk.include?(mk) || mk.include?(rmk)
    end
  end
  total
end
records.each { |r| r[:rows] = approx_rows(r, RAW_TABLES) }

# ── uk_dft GenModel rollup flag (independent altitude signal) ───────────────
# Indexed the same way: [stripped-GenModel] -> { raw_make => Set(Model strings) }
GENMODEL_SPREAD = {}
uk = File.join(RAW, "uk.txt")
if File.exist?(uk)
  File.foreach(uk, chomp: true) do |l|
    _body, mk, gm, md, = l.split("|")
    next if md.to_s.include?("MODEL MISSING")
    rmk = mk.to_s.upcase.gsub(/[^A-Z0-9]/, "")
    key = gm.to_s.upcase.gsub(/[^A-Z0-9]/, "")
    key = key.sub(/\A#{Regexp.escape(rmk)}/, "") if key.start_with?(rmk) && key != rmk
    (((GENMODEL_SPREAD[key] ||= {})[rmk] ||= Set.new) << md.to_s.upcase)
  end
end

def genmodel_rollup(rec)
  return nil unless rec[:countries].include?("gb")
  want = rec[:name].to_s.upcase.gsub(/[^A-Z0-9]/, "")
  mk   = rec[:make].to_s.upcase.delete("-")
  (GENMODEL_SPREAD[want] || {}).each do |rmk, models|
    next unless rmk.include?(mk) || mk.include?(rmk)
    return models if models.size > 1
  end
  nil
end
records.each { |r| r[:rollup] = genmodel_rollup(r) }

# ── build edges within (make, kind) ─────────────────────────────────────────
by_scope = records.group_by { |r| [r[:make], r[:kind]] }
perm_edges = []   # [a, b]  multisets equal, names differ
sub_edges  = []   # [a, b]  a ⊊ b
by_scope.each_value do |rs|
  rs.combination(2) do |a, b|
    next if a[:ms].empty? || b[:ms].empty?
    if a[:ms] == b[:ms]
      perm_edges << [a, b] if a[:name] != b[:name]
    elsif subset?(a[:ms], b[:ms])
      sub_edges << [a, b]
    elsif subset?(b[:ms], a[:ms])
      sub_edges << [b, a]
    end
  end
end

# fan-out: how many DISTINCT proper supersets each id has, in its own scope
fanout = Hash.new(0)
sub_edges.each { |a, _b| fanout[a[:key]] += 1 }

# A NAME WORD is a purely-alphabetic token of 3+ chars. Short alphabetic tokens
# (L, S, R, T) are variant letters, not model names — "Quickly" -> "Quickly L"
# is a variant, and treating L as a name word would wrongly split that pair off.
def name_words_added(a, b)
  (b[:ms].keys - a[:ms].keys).select { |t| t.match?(/\A[A-Z]{3,}\z/) }
end

ROMAN = /\A(?:M{0,3})(?:CM|CD|D?C{0,3})(?:XC|XL|L?X{0,3})(?:IX|IV|V?I{1,3})\z/
def generation_markers_added(a, b)
  (b[:ms].keys - a[:ms].keys).select { |t| t == "MK" || (t.match?(/\A[IVXLCDM]+\z/) && t.match?(ROMAN)) }
end

# DISTINCT NUMBERS a subset id's supersets add, across all of them. >=2 means the
# marque runs a RANGE under that name -> A is the family word. See §ALTITUDE (ii).
def capacity_spread(sub_edges)
  spread = {}
  sub_edges.each do |a, b|
    nums = (b[:ms].keys - a[:ms].keys).select { |t| t.match?(/\A\d+\z/) }
    ((spread[a[:key]] ||= Set.new)).merge(nums)
  end
  spread
end

# PER-EDGE label, with the three evidence overrides. Deliberately does NOT
# consult raw fan-out — see §ALTITUDE rule 2.
def label_for(a, b, spread)
  words = name_words_added(a, b)
  gens  = generation_markers_added(a, b)
  caps  = spread[a[:key]] || Set.new
  if a[:rollup]
    ["ALTITUDE", "#{a[:name].inspect} is GENMODEL-ROLLUP: uk_dft proves it spans #{a[:rollup].size} Model strings, so it is a family row and cannot be a respelling of #{b[:name].inspect}"]
  elsif caps.size >= 2
    ["ALTITUDE", "#{a[:name].inspect} has supersets adding #{caps.size} DIFFERENT capacities (#{caps.to_a.sort.join(', ')}) -> a range under one family word, not one machine respelled"]
  elsif gens.any?
    ["ALTITUDE", "#{b[:name].inspect} adds the GENERATION MARKER #{gens.join(', ')} to #{a[:name].inspect} -> a generation, not a spelling"]
  elsif words.any?
    ["ALTITUDE", "#{b[:name].inspect} adds the NAME WORD(S) #{words.join(', ')} to #{a[:name].inspect} -> a model named inside a range, not a respelling"]
  else
    added = (b[:ms].keys - a[:ms].keys)
    ["SPELLING", "#{b[:name].inspect} adds only number/code token(s) #{added.join(', ')} to #{a[:name].inspect}, and no superset of #{a[:name].inspect} adds a second capacity -> one machine respelled is the likelier reading (NOT proven: bmw/r80 vs R80/7 lands here and is wrong)"]
  end
end

CAP_SPREAD = capacity_spread(sub_edges)
labelled_sub = sub_edges.map { |a, b| lab, why = label_for(a, b, CAP_SPREAD); [lab, a, b, why] }

# ── cluster on PERMUTATION + SPELLING edges ONLY ────────────────────────────
# ALTITUDE edges deliberately do NOT union — see §ALTITUDE in the header for the
# 15-id BSA blob that this rule exists to prevent.
parent = {}
find = ->(x) { parent[x] = x unless parent.key?(x); parent[x] == x ? x : (parent[x] = find.(parent[x])) }
union = ->(x, y) { rx, ry = find.(x), find.(y); parent[rx] = ry unless rx == ry }
joining = perm_edges.map { |a, b| [a, b] } +
          labelled_sub.select { |lab, _a, _b, _w| lab == "SPELLING" }.map { |_l, a, b, _w| [a, b] }
joining.each { |a, b| union.(a[:key], b[:key]) }

groups = {}
joining.flatten(1).uniq { |r| r[:key] }.each { |r| (groups[find.(r[:key])] ||= []) << r }
groups.each_value { |v| v.uniq! { |r| r[:key] } }

edge_index = {}
perm_edges.each { |a, b| (edge_index[find.(a[:key])] ||= []) << ["PERMUTATION", a, b, "same token multiset, different order/spacing — the strongest shape this script has"] }
labelled_sub.each do |lab, a, b, why|
  root = parent.key?(a[:key]) ? find.(a[:key]) : (parent.key?(b[:key]) ? find.(b[:key]) : nil)
  next unless root                     # an ALTITUDE-only pair forms no group
  (edge_index[root] ||= []) << [lab, a, b, why]
end
# ALTITUDE pairs where NEITHER id is in any cluster: report separately, because
# they are a granularity worklist in their own right and must not be folded.
altitude_only = labelled_sub.select { |lab, a, b, _w| lab == "ALTITUDE" && !parent.key?(a[:key]) && !parent.key?(b[:key]) }

def asym(g)
  counts = g.map { |r| r[:rows] }.compact
  return 0 if counts.size < 2
  hi, lo = counts.max, counts.min
  lo.zero? ? hi : (hi.to_f / lo)
end

ranked = groups.map { |root, g| [root, g] }
               .sort_by { |root, g| [-asym(g), -g.size] }

# ── report ──────────────────────────────────────────────────────────────────
n_perm_groups = groups.count { |root, _| (edge_index[root] || []).any? { |e| e[0] == "PERMUTATION" } }
rollups = records.select { |r| r[:rollup] }

puts "find_token_duplicates.rb — mode=#{opts[:mode]}  kinds=#{opts[:kinds].join(',')}" \
     "#{opts[:make] ? "  make=#{opts[:make]}" : ''}"
if opts[:mode] == "boundary"
  warn "!! BOUNDARY MODE IS NOT FIT FOR COUNTING. Measured on the full 2W half it"
  warn "!! fuses 44 different Honda CBR models into one group (see the header)."
  warn "!! Use it scoped to a single word-named make, and never quote its totals."
end
puts "catalog: #{CATALOG}"
puts "raw (for approximate row counts): #{Dir.exist?(RAW) ? RAW : 'ABSENT — rows~ will print ?'}"
puts
puts "records scanned:                      #{records.size}"
puts "DUPLICATE groups nominated:           #{groups.size}    (PERMUTATION + SPELLING edges only)"
puts "records in a duplicate group:         #{groups.values.sum(&:size)}"
puts "  groups containing a PERMUTATION:    #{n_perm_groups}   (strongest shape)"
puts "  SPELLING edges:                     #{labelled_sub.count { |l, | l == 'SPELLING' }}"
puts "ALTITUDE edges (NOT duplicates):      #{labelled_sub.count { |l, | l == 'ALTITUDE' }}    family-vs-model granularity, never auto-folded"
puts "  of which pairs in no cluster:       #{altitude_only.size}    -> the granularity worklist at the end"
puts "GENMODEL-ROLLUP ids (independent):    #{rollups.size}   (uk_dft family column; fires with no token edge)"
puts
puts "WORKLIST, not a verdict. Every group needs one human call. Order is by"
puts "evidence asymmetry (rows~ hi:lo), which surfaces stragglers — it does NOT"
puts "mean the top of the list is safe to fold."
puts

ranked.first(opts[:limit]).each_with_index do |(root, g), i|
  a = asym(g)
  nums = g.flat_map { |r| r[:ms].keys }.uniq.select { |t| t.match?(/\A\d+\z/) }.sort
  hubs = g.select { |r| fanout[r[:key]] >= 3 }
  puts "#{'─' * 78}"
  puts "[#{i + 1}] #{g.first[:make]} / #{g.first[:kind]}   #{g.size} ids   asymmetry #{a.zero? ? '?' : "#{a.round(1)}x"}"
  puts "     ?? distinct numeric tokens in cluster: #{nums.join(', ')} — if the marque sold this nameplate in MORE THAN ONE capacity these are different machines, not respellings (the Gold Star 250 trap)" if nums.size >= 1
  puts "     ~~ COMMON-WORD HUB: #{hubs.map { |r| "#{r[:name].inspect} is a subset of #{fanout[r[:key]]} names in this make" }.join('; ')}" if hubs.any?
  g.sort_by { |r| -(r[:rows] || 0) }.each do |r|
    ranks = (r[:pop]["by_country"] || {}).map { |cc, p| "#{cc}#{p['rank']}/d#{p['decile']}" }.join(" ")
    puts format("     %-42s %-26s %-14s rows~%-7s %s",
                r[:key], r[:name].inspect, r[:countries].join(","),
                r[:rows].nil? ? "?" : r[:rows], ranks)
    puts "        !! GENMODEL-ROLLUP: uk_dft GenModel spans #{r[:rollup].size} Model strings -> #{r[:rollup].to_a.first(4).join(' | ')}#{r[:rollup].size > 4 ? ' …' : ''}" if r[:rollup]
  end
  (edge_index[root] || []).uniq { |e| [e[0], e[1][:key], e[2][:key]] }.each do |lab, x, y, why|
    puts "     #{lab}: #{x[:name].inspect} ⊆ #{y[:name].inspect}"
    puts "        why: #{why}"
  end
end

puts "#{'─' * 78}"
puts
if altitude_only.any?
  puts "GRANULARITY WORKLIST — ALTITUDE pairs that form no duplicate cluster."
  puts "These are family-row-beside-model-row. DO NOT FOLD; decide the altitude."
  altitude_only.uniq { |_l, a, b, _w| [a[:key], b[:key]] }
               .sort_by { |_l, a, b, _w| -[(a[:rows] || 0), (b[:rows] || 0)].max }
               .first(opts[:limit]).each do |_l, a, b, why|
    puts format("     %-34s rows~%-7s ⊂  %-34s rows~%s", a[:name].inspect, a[:rows] || "?", b[:name].inspect, b[:rows] || "?")
    puts "        #{a[:key]}  |  #{b[:key]}"
    puts "        why: #{why}"
  end
  puts
end
if rollups.any?
  puts "GENMODEL-ROLLUP ids with NO token edge (invisible to every duplicate detector,"
  puts "including this one — they are single ids covering several vehicles):"
  rollups.reject { |r| parent.key?(r[:key]) }.sort_by { |r| -r[:rollup].size }.first(opts[:limit]).each do |r|
    puts format("     %-42s %-24s %d Models: %s",
                r[:key], r[:name].inspect, r[:rollup].size, r[:rollup].to_a.first(5).join(" | "))
  end
  puts
end
puts "REMINDER: a clean run is not evidence of no duplicates. Re-read"
puts "\"WHAT IT CANNOT FIND\" in the header — glued single-token ids and"
puts "suffix-letter families (NSC50/NSC50T2, WW125/WW125A, PC31..PC39) are"
puts "outside this script's reach by construction and need their own detector."
