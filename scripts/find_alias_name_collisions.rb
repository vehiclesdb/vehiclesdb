#!/usr/bin/env ruby
# frozen_string_literal: true

# Alias-vs-name collision detector — report-only.
#
# The live resolver (vehiclesdb-web app/models/resolver.rb rung 4,
# `resolve_bare_alias`) REFUSES to answer any bare query that is simultaneously
# one record's published alias and a DIFFERENT record's display name:
#
#   "Rabbit" → alias of car/volkswagen/golf AND name of car/volkswagen/rabbit
#            → resolved_via ["ambiguous_alias:rabbit (also a model name)"], match: nil
#
# Every such string is a paying-customer-visible refusal on /v1/resolve, and the
# colliding alias is dead weight: rung 3 (make-scoped) prefers a direct name/slug
# hit over an alias, so the alias cannot be reached with a make prefix either.
#
# Usage:  ruby scripts/find_alias_name_collisions.rb [dist/vehicles.csv]
# Exit:   0 = clean, 1 = collisions found (see PROMOTION section of the spec).

require "csv"

CSV_PATH = ARGV[0] || File.join(__dir__, "..", "dist", "vehicles.csv")

# --- normalization: byte-for-byte the gem's Vehicles.normalize / .slugify -----
# vehicles 0.6.1 lib/vehicles.rb:273-291. Do NOT "simplify" these — the whole
# point is that the detector keys strings exactly the way the resolver's index
# does. NFKD folding happens BEFORE the separator gsub or "Škoda" becomes
# "s koda".
def fold_diacritics(str)
  s = str.to_s
  s = s.dup.force_encoding(Encoding::UTF_8) unless s.encoding == Encoding::UTF_8
  s = s.scrub("") unless s.valid_encoding?
  s.unicode_normalize(:nfkd).gsub(/\p{Mn}+/, "")
end

def normalize(str) = fold_diacritics(str).downcase.gsub(/[^a-z0-9]+/, " ").strip
def slugify(str)   = fold_diacritics(str).downcase.gsub(/[^a-z0-9]+/, "-").gsub(/(\A-|-\z)/, "")

Record = Struct.new(:kind, :make_slug, :make_name, :model_slug, :model_name,
                    :decile, :countries, :aliases, :former_ids) do
  # The resolver's identity for exemption purposes is [make_slug, model_slug] —
  # KIND-BLIND on purpose (resolver.rb:180, "the same nameplate can appear as
  # several kind-scoped models of one id").
  def id = [ make_slug, model_slug ]
  def canonical = "#{kind}/#{make_slug}/#{model_slug}"
  def label = "#{make_name} #{model_name}"
end

records = CSV.foreach(CSV_PATH, headers: true).map do |r|
  Record.new(
    r["kind"], r["make_slug"], r["make_name"], r["model_slug"], r["model_name"],
    r["global_popularity_decile"]&.then { |d| d.empty? ? nil : d.to_i },
    r["countries"].to_s.split("|"),
    r["aliases"].to_s.split("|").reject(&:empty?),
    r["former_ids"].to_s.split("|").reject(&:empty?)
  )
end

# --- the two indexes the resolver builds (resolver.rb:284-312) ----------------
# Empty normalizations are NOT indexed (`unless an.empty?`) — a Cyrillic-only or
# CJK-only alias folds to "" and can never be queried, so it can never collide.
alias_index = Hash.new { |h, k| h[k] = [] }   # normalized alias  => [Record]
name_index  = Hash.new { |h, k| h[k] = [] }   # normalized name   => [Record]
live_ids    = {}                              # canonical id      => Record

records.each do |rec|
  live_ids[rec.canonical] = rec
  rec.aliases.each do |a|
    an = normalize(a)
    alias_index[an] << rec unless an.empty?
  end
  nn = normalize(rec.model_name)
  name_index[nn] << rec unless nn.empty?
end

findings = { a: [], b: [], c: [], d: [], f: [], g: [] }

# === CLASS G: BARE-RESOLUTION OPT-IN (alias == own name after folding) =======
# NOT redundancy — this is the resolver's only mechanism for making a bare,
# single-token nameplate resolvable, and it is deliberate. Rung 3 bails on
# one-token input (`return nil if tokens.length < 2`) and rung 4 fires only on
# ALIASES, so a record's own NAME can never answer a bare query. Publishing the
# name (or its accented native spelling — normalize folds diacritics) as an
# alias is what opts the record in. resolver.rb:177-179 cites exactly this:
# SEAT publishes "Málaga" so that `resolve("malaga")` answers.
#
# So these rows are intent, and the interesting thing is whether the intent
# SUCCEEDS. An opt-in blocked by a foreign name-holder (class A) or by a rival
# opt-in (class B) is dead on arrival: the curator asked for bare resolution and
# the resolver answers with a refusal instead.
records.each do |rec|
  own_name = normalize(rec.model_name)
  rec.aliases.each do |a|
    an = normalize(a)
    next if an.empty?
    next unless an == own_name || an == rec.model_slug

    # Follow the resolver's own order: the foreign-NAME test (class A) is
    # evaluated against A_q, so a rival that ALSO publishes the alias is a
    # class B multi-id refusal, not a class A one.
    a_ids = (alias_index[an] || []).map(&:id).uniq
    foreign_names = (name_index[an] || []).reject { |m| a_ids.include?(m.id) }
    rivals = a_ids.reject { |i| i == rec.id }
    status = if foreign_names.any? then "DEAD (class A — also the name of #{foreign_names.map(&:canonical).join(', ')})"
    elsif rivals.any?  then "DEAD (class B — #{rivals.map { |i| i.join('/') }.join(', ')} publishes it too)"
    else "works — bare \"#{an}\" resolves here"
    end
    findings[:g] << { alias: a, rec:, status: }
  end
end

# === CLASS A: alias-vs-name collision (the resolver's hard refusal) ===========
# resolver.rb:180-190. For a normalized query q:
#   A_q = ids of records publishing an alias that normalizes to q
#   N_q = ids of records whose display name normalizes to q
#   refusal  iff  A_q non-empty AND (N_q \ A_q) non-empty
# The set difference IS the same-record exemption: SEAT publishing "Málaga" for
# car/seat/malaga is fine, because the name-holder's id is already in A_q.
alias_index.each do |q, holders|
  alias_ids = holders.map(&:id).uniq
  foreign = (name_index[q] || []).reject { |m| alias_ids.include?(m.id) }
  next if foreign.empty?

  # Make-scoped vs global: if the name-holder shares the alias-holder's make,
  # rung 3 also shadows the alias (direct name/slug beats alias inside a make),
  # so the alias is unreachable through EVERY rung. Cross-make collisions still
  # resolve when the make is named — only the bare query refuses.
  same_make = foreign.any? { |f| holders.any? { |h| h.make_slug == f.make_slug } }
  findings[:a] << { q:, holders:, foreign:, scope: same_make ? "same-make" : "cross-make" }
end

# === CLASS B: multi-id alias ambiguity (resolver.rb:192-199) ==================
# Same rung, different refusal: one alias published by two DIFFERENT ids.
alias_index.each do |q, holders|
  ids = holders.map(&:id).uniq
  findings[:b] << { q:, holders: } if ids.length > 1
end

# === CLASS C: former_id shadowed by a live canonical id ======================
# Rung 1 (exact id) runs BEFORE rung 2 (former_id), so a former_id that is still
# a live id resolves to the LIVE record, never to the absorbing one. That is a
# silent misresolution at confidence 1.0, not a refusal — and it means the
# append-only migration contract was violated somewhere upstream.
records.each do |rec|
  rec.former_ids.each do |fid|
    live = live_ids[fid.downcase]
    next unless live
    next if live.equal?(rec) # self-reference: dead weight, not a misresolution
    findings[:c] << { former_id: fid.downcase, claimed_by: rec, resolves_to: live }
  end
end

# === CLASS D-10: "+"-bearing display names (the S4W shared-predicate item) ====
# `+` is not [a-z0-9], so normalize("Golf+") == "golf" and slugify("Golf+") ==
# "golf". A plus-bearing name therefore competes in rung 3's DIRECT match
# (`normalize(m.name) == mq || m.model_slug == mq`) for the plain query, and can
# WIN the decile tie-break against the record actually named "Golf". Scoped to
# the make, because rung 3 is make-scoped.
#
# Two arms, because "+" can hurt in two different ways:
#   (i)  RESOLVE arm — normalize(name) ties with a same-make sibling's
#        normalized name or bare slug, so rung 3 returns both and tie-breaks.
#   (ii) ID arm — slugify(name) (which drops the "+" to a separator) equals a
#        DIFFERENT live record's model_slug in the same make: two ids that
#        differ only by the plus, i.e. a fold that was never done.
# Note rung 3's slug branch compares `m.model_slug == mq` where mq is
# space-separated: a hyphenated slug ("elan-2") can NEVER match that branch, so
# for multi-token records the name branch carries the whole risk. Faithful to
# resolver.rb:228 — do not "fix" it here.
by_make = records.group_by(&:make_slug)
records.select { |r| r.model_name.include?("+") }.each do |rec|
  stripped = normalize(rec.model_name)
  next if stripped.empty?
  siblings = (by_make[rec.make_slug] || []).reject { |o| o.id == rec.id }
  resolve_rivals = siblings.select do |o|
    normalize(o.model_name) == stripped || o.model_slug == stripped
  end
  id_rivals = siblings.select { |o| o.model_slug == slugify(rec.model_name) }
  rivals = (resolve_rivals + id_rivals).uniq
  findings[:d] << { rec:, stripped:, rivals:,
                    slug_drift: slugify(rec.model_name) != rec.model_slug,
                    status: rivals.empty? ? "clear" : "COLLIDES" }
end

# === CLASS F: alias shadowed by rung 3 (published promise the API breaks) ====
# Rung 3 runs BEFORE rung 4. A multi-token alias whose leading tokens form a
# live make, where that make has a matching model, is answered by rung 3 and
# the alias never fires — e.g. "Renault Logan" is published as an alias of
# car/dacia/logan, but car/renault/logan is a live record, so the API answers
# the Renault. Not a refusal and not obviously wrong, but the alias is inert:
# the published data promises a mapping the resolver will never make.
#
# Make resolution mirrors Dataset#find_make (vehicles 0.6.1 dataset.rb:81-99):
# builtin aliases first, then raw slug, then normalized name/slug/make-alias.
# User-configured Vehicles.configuration.aliases are deployment-specific and
# deliberately not modelled.
BUILTIN_MAKE_ALIASES = {
  "vw" => "volkswagen", "vdub" => "volkswagen",
  "merc" => "mercedes-benz", "mercedes" => "mercedes-benz", "benz" => "mercedes-benz",
  "mb" => "mercedes-benz", "chevy" => "chevrolet",
  "beemer" => "bmw", "bimmer" => "bmw", "alfa" => "alfa-romeo",
  "landrover" => "land-rover", "range rover" => "land-rover", "rangerover" => "land-rover"
}.freeze

# Make-level aliases live only in vehicles.json (the CSV is model-scoped), so
# pick them up when the JSON sits next to the CSV; without it the scan still
# runs, just blind to 36 makes' aliases.
make_alias_rows = []
json_path = File.join(File.dirname(File.expand_path(CSV_PATH)), "vehicles.json")
if File.exist?(json_path)
  require "json"
  JSON.parse(File.read(json_path))["makes"].each do |m|
    (m["aliases"] || []).each { |a| make_alias_rows << [ a, m["slug"] ] }
  end
end
MAKE_ALIAS_MODE = make_alias_rows.empty? ? "names+slugs only (vehicles.json not found)" : "with #{make_alias_rows.size} make aliases"

make_by_slug = {}
make_index   = {}
by_make.each_key do |slug|
  make_by_slug[slug] = slug
  make_index[normalize(by_make[slug].first.make_name)] ||= slug
  make_index[normalize(slug)] ||= slug
end
make_alias_rows.each { |a, slug| make_index[normalize(a)] ||= slug }

find_make = lambda do |q|
  return nil if q.empty?
  if (s = BUILTIN_MAKE_ALIASES[q])
    return make_by_slug[s]
  end
  make_by_slug[q] || make_index[q]
end

records.each do |rec|
  rec.aliases.each do |a|
    q = normalize(a)
    tokens = q.split
    next if tokens.length < 2

    (tokens.length - 1).downto(1) do |i|
      mk = find_make.call(tokens[0, i].join(" "))
      next unless mk

      mq = tokens[i..].join(" ")
      pool = by_make[mk] || []
      answers = pool.select { |m| normalize(m.model_name) == mq || m.model_slug == mq }
      answers = pool.select { |m| m.aliases.any? { |x| normalize(x) == mq } } if answers.empty?
      next if answers.empty?

      findings[:f] << { alias: a, q:, holder: rec, answers: } unless answers.all? { |m| m.id == rec.id }
      break
    end
  end
end

# === CLASS E (diagnostic, not a gate): rung-3 silent tie-break surface =======
# Generalizes D-10 past "+": ANY two records in one make whose display names
# normalize identically are both returned by rung 3's direct match, and
# tie_break silently picks one at confidence 0.97. Sized here to judge whether
# the D-10 predicate can safely be widened later.
class_e = by_make.flat_map do |mk, recs|
  recs.group_by { |r| normalize(r.model_name) }
      .reject { |nn, g| nn.empty? || g.map(&:id).uniq.size < 2 }
      .map { |nn, g| { make: mk, q: nn, group: g } }
end

# --- report ------------------------------------------------------------------
def show(recs) = recs.map { |r| "#{r.canonical} (\"#{r.label}\", d#{r.decile || '-'})" }.join(", ")

puts "alias-name collision scan — #{records.size} records, " \
     "#{alias_index.size} distinct normalized aliases, #{name_index.size} distinct normalized names"
puts "make resolution: #{MAKE_ALIAS_MODE}"
puts

puts "== CLASS A: alias == another record's name (rung-4 REFUSAL) : #{findings[:a].size}"
findings[:a].sort_by { |f| f[:q] }.each do |f|
  puts %(  "#{f[:q]}" [#{f[:scope]}])
  puts "      alias of : #{show(f[:holders])}"
  puts "      name  of : #{show(f[:foreign])}"
end
puts

puts "== CLASS B: one alias, several ids (rung-4 REFUSAL)         : #{findings[:b].size}"
findings[:b].sort_by { |f| f[:q] }.each { |f| puts %(  "#{f[:q]}" → #{show(f[:holders])}) }
puts

puts "== CLASS C: former_id shadowed by a live id (SILENT WRONG)  : #{findings[:c].size}"
findings[:c].sort_by { |f| f[:former_id] }.each do |f|
  puts "  #{f[:former_id]} claimed by #{f[:claimed_by].canonical} but rung 1 answers #{f[:resolves_to].canonical}"
end
puts

d_bad = findings[:d].select { |f| f[:status] == "COLLIDES" }
puts "== CLASS D-10 watchlist: \"+\" names       : #{findings[:d].size} seen, #{d_bad.size} colliding"
findings[:d].sort_by { |f| f[:rec].canonical }.each do |f|
  puts %(  #{f[:status].ljust(8)} #{f[:rec].canonical} "#{f[:rec].model_name}" → "#{f[:stripped]}") +
       (f[:slug_drift] ? " [slug drift]" : "") +
       (f[:rivals].empty? ? "" : " vs #{show(f[:rivals])}")
end
puts

g_dead = findings[:g].count { |f| f[:status].start_with?("DEAD") }
puts "== CLASS G: bare-resolution opt-ins      : #{findings[:g].size} seen, #{g_dead} dead on arrival"
findings[:g].sort_by { |f| f[:rec].canonical }.each do |f|
  puts %(  "#{f[:alias]}" on #{f[:rec].canonical} → #{f[:status]})
end
puts

puts "== CLASS F: alias shadowed by rung 3 (INERT alias)          : #{findings[:f].size}"
findings[:f].sort_by { |f| f[:q] }.each do |f|
  puts %(  "#{f[:alias]}" on #{f[:holder].canonical} — rung 3 answers #{show(f[:answers])})
end
puts

puts "== CLASS E (diagnostic): same-make duplicate normalized names : #{class_e.size} groups"
class_e.sort_by { |f| [ f[:make], f[:q] ] }.first(25).each do |f|
  puts %(  #{f[:make]} "#{f[:q]}" → #{show(f[:group])})
end
puts "  ... (#{class_e.size - 25} more)" if class_e.size > 25
puts

hard = findings[:a].size + findings[:b].size + findings[:c].size + d_bad.size
puts "TOTAL hard findings: #{hard}"
exit(hard.zero? ? 0 : 1)
