# Propose overrides/models/former_ids.yml entries from an id diff between two
# builds. PROPOSES — a human/agent reviews before it lands, same contract as
# every other file in overrides/.
#
# Safety rules, all enforced here and re-asserted by lint/gate:
#   1. an old id may only be mapped if it is ABSENT from the new build
#      (S4W's caveat: audi/89 SURVIVES and merely loses bogus DE evidence, so
#      mapping it onto audi/a3 would tell consumers a live id is an alias)
#   2. successor must be same kind + same make
#   3. slug must be identical modulo non-alphanumerics (mechanical rename) —
#      anything else is left for explicit authoring, never guessed
#   4. successor's countries must be a SUPERSET of the old id's, i.e. the
#      evidence actually moved rather than vanished
# Anything failing 3 or 4 is reported as NEEDS-REVIEW rather than emitted.
require 'csv'

old_csv, new_csv = ARGV[0], ARGV[1]
load_ids = ->(p) {
  CSV.read(p, headers: true).map(&:to_h).to_h { |r|
    [["#{r['kind']}/#{r['make_slug']}/#{r['model_slug']}"],
     { name: r['model_name'], countries: r['countries'].to_s.split('|').sort, kind: r['kind'],
       make: r['make_slug'], slug: r['model_slug'] }]
  }.transform_keys(&:first)
}
o = load_ids.(old_csv)
n = load_ids.(new_csv)
gone  = o.keys - n.keys
added = n.keys - o.keys
norm = ->(s) { s.gsub(/[^a-z0-9]/, '') }

emit, review = [], []
gone.each do |g|
  og = o[g]
  cands = added.select { |a| n[a][:kind] == og[:kind] && n[a][:make] == og[:make] && norm.(n[a][:slug]) == norm.(og[:slug]) }
  if cands.size == 1
    a = cands.first
    lost = og[:countries] - n[a][:countries]
    if lost.empty?
      emit << [g, a, og, n[a]]
    else
      review << [g, a, "successor missing countries #{lost.join(',')} (evidence did not fully move)"]
    end
  elsif cands.empty?
    review << [g, nil, "no mechanical successor — needs explicit authoring or is a genuine removal"]
  else
    review << [g, nil, "ambiguous: #{cands.size} candidates #{cands.inspect}"]
  end
end

puts "# ---- PROPOSED (#{emit.size}) ----"
emit.sort.each do |g, a, og, na|
  puts format('%-46s %-46s # %s -> %s  [%s]', "\"#{g}\":", "\"#{a}\"", og[:name], na[:name], na[:countries].join(','))
end
puts "\n# ---- NEEDS REVIEW (#{review.size}) ----"
review.sort_by { |r| r[0] }.first(40).each { |g, a, why| puts format('# %-44s %s', g, why) }
puts "# ... +#{review.size - 40} more" if review.size > 40
warn "proposed=#{emit.size} review=#{review.size} gone=#{gone.size} added=#{added.size}"
