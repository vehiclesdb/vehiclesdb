#!/usr/bin/env ruby
# frozen_string_literal: true
#
# audit_aggregate.rb — turn audit ledgers into the numbers RESULTS.md and
# QUALITY.md publish. PRD-FIVE-NINES §2.2 and data/review/audit-PROTOCOL.md
# are the spec; this file is the arithmetic.
#
# WHY THIS EXISTS. The baseline round (v2026.07.5) computed its aggregate by
# hand from four verifiers' prose tallies, and RESULTS-s2w says so plainly:
# "Merging them by hand would mean transcribing ~400 records' worth of prose
# corrections into a single file — exactly the silent-transcription-error
# class this program exists to remove." It kept the files unmerged and paid
# for that honesty with a number nobody can recompute. This script is the
# other half of the fix: the ledgers stay separate and readable, AND the
# aggregate is derived mechanically from them.
#
# THE RESOLUTION RULE (the only place researcher and verifier are combined):
#   final verdict for a claim = the VERIFIER's verdict when the verifier
#   recorded one; otherwise the RESEARCHER's. A verifier does not re-derive
#   100% of `correct` claims (the protocol asks for ≥20%), so most corrects
#   pass through unchanged — but every defective, every unverifiable, and the
#   verifier's sampled corrects are verifier-final. This reproduces the
#   baseline's "corrected aggregate computed from the verifiers' tallies"
#   while leaving every disagreement readable in the files.
#
# CONSERVATIVE BOUND: `unverifiable` counts AGAINST the clean rate, both
# sub-types (protocol rule 8). The clean rate is correct/total; the reported
# defect rate is (defective + unverifiable)/total. They sum to 1 by
# construction — that is the point, not a rounding coincidence.
#
# Usage:
#   ruby scripts/audit_aggregate.rb --tag=v2026.08.3 --half=s4w [--json]
#   ruby scripts/audit_aggregate.rb --self-test

require "yaml"
require "json"
require "date"

module AuditAggregate
  ROOT = File.expand_path("..", __dir__)
  CLAIM_TYPES = %w[id name make kind availability enrichment].freeze
  VERDICTS = %w[correct defective unverifiable].freeze
  SUBTYPES = %w[source-gap not-attempted].freeze
  # Head = deciles 1-6 (PRD-FIVE-NINES §1.3.1 option (i)); tail = 7-10 + none.
  # The boundary is MASS-defined and read from decile-mass.json, never asserted.
  HEAD_BANDS = (1..6).map(&:to_s).freeze

  # ── statistics ────────────────────────────────────────────────────────────
  # Clopper-Pearson is what the protocol asks for ("95% Clopper-Pearson
  # intervals"). It is the exact binomial interval: conservative by
  # construction, which is the right bias for a bound we publish as a claim.
  # Wilson is computed alongside ONLY because the 4W baseline reported Wilson
  # and a round-over-round comparison must compare like with like.
  module Stats
    module_function

    def lgamma(x) = Math.lgamma(x)[0]

    # Regularized incomplete beta I_x(a,b), Lentz's continued fraction.
    def betai(a, b, x)
      return 0.0 if x <= 0.0
      return 1.0 if x >= 1.0
      bt = Math.exp(lgamma(a + b) - lgamma(a) - lgamma(b) + a * Math.log(x) + b * Math.log(1.0 - x))
      if x < (a + 1.0) / (a + b + 2.0)
        bt * betacf(a, b, x) / a
      else
        1.0 - bt * betacf(b, a, 1.0 - x) / b
      end
    end

    def betacf(a, b, x)
      tiny = 1.0e-30
      qab = a + b; qap = a + 1.0; qam = a - 1.0
      c = 1.0
      d = 1.0 - qab * x / qap
      d = tiny if d.abs < tiny
      d = 1.0 / d
      h = d
      (1..300).each do |m|
        m2 = 2 * m
        aa = m * (b - m) * x / ((qam + m2) * (a + m2))
        d = 1.0 + aa * d; d = tiny if d.abs < tiny
        c = 1.0 + aa / c;  c = tiny if c.abs < tiny
        d = 1.0 / d
        h *= d * c
        aa = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2))
        d = 1.0 + aa * d; d = tiny if d.abs < tiny
        c = 1.0 + aa / c;  c = tiny if c.abs < tiny
        d = 1.0 / d
        del = d * c
        h *= del
        break if (del - 1.0).abs < 3.0e-12
      end
      h
    end

    # Inverse of betai in x, by bisection. Bisection (not Newton) because the
    # inputs here are tiny counts at the edges (k=0, k=n) where a derivative
    # method wanders off the interval; 200 halvings of [0,1] is exact to 1e-60
    # and costs microseconds at our call volume.
    def beta_quantile(p, a, b)
      return 0.0 if p <= 0.0
      return 1.0 if p >= 1.0
      lo = 0.0; hi = 1.0
      200.times do
        mid = (lo + hi) / 2.0
        if betai(a, b, mid) < p then lo = mid else hi = mid end
      end
      (lo + hi) / 2.0
    end

    # Exact binomial 95% interval for k of n.
    def clopper_pearson(k, n, alpha: 0.05)
      return [0.0, 0.0] if n.zero?
      lower = k.zero? ? 0.0 : beta_quantile(alpha / 2.0, k, n - k + 1)
      upper = k == n ? 1.0 : beta_quantile(1.0 - alpha / 2.0, k + 1, n - k)
      [lower, upper]
    end

    def wilson(k, n, z: 1.959963985)
      return [0.0, 0.0] if n.zero?
      phat = k.to_f / n
      denom = 1 + z**2 / n
      centre = (phat + z**2 / (2 * n)) / denom
      half = (z * Math.sqrt(phat * (1 - phat) / n + z**2 / (4 * n**2))) / denom
      [[centre - half, 0.0].max, [centre + half, 1.0].min]
    end

    # Rule of three: with k=0 defects in n samples, r <= 3/n at ~95%.
    def rule_of_three(n) = n.zero? ? 1.0 : 3.0 / n
  end

  # ── the pinned build: strata membership and the published weights ─────────
  class Build
    attr_reader :path, :decile_of, :kind_of, :mass

    def initialize(path)
      @path = path
      @decile_of = {}
      @kind_of = {}
      %w[car van truck bus motorcycle moped].each do |kind|
        f = File.join(path, "catalog", kind, "models.json")
        next unless File.exist?(f)
        JSON.parse(File.read(f)).each do |m|
          full = "#{kind}/#{m["id"]}"
          @decile_of[full] = m.dig("popularity", "global_decile")
          @kind_of[full] = kind
        end
      end
      mf = File.join(path, "catalog", "meta", "decile-mass.json")
      @mass = File.exist?(mf) ? JSON.parse(File.read(mf)) : nil
    end

    def band_of(id)
      d = @decile_of[id]
      return "none" if d.nil?
      d <= 6 ? "head" : "tail"
    end

    # w_head / w_tail WITHIN a half, read from the published artifact.
    # Renormalised inside the half because a half's audit can only speak for
    # its own records; the cross-half combination is done once, at the end,
    # with each half's share of total catalog mass.
    def weights_for(half)
      return nil unless @mass
      kinds = half == "s4w" ? %w[car van truck bus] : %w[motorcycle moped]
      head = 0.0; tail = 0.0
      kinds.each do |k|
        next unless @mass["kinds"][k]
        @mass["kinds"][k].each do |band, x|
          if band != "none" && band.to_i <= 6 then head += x["mass_share"] else tail += x["mass_share"] end
        end
      end
      total = head + tail
      return nil if total.zero?
      { "half_mass_share" => total, "w_head" => head / total, "w_tail" => tail / total,
        "head_mass" => head, "tail_mass" => tail }
    end
  end

  # ── ledgers ───────────────────────────────────────────────────────────────
  # A claim's identity is (id, claim, country). `country` is nil for
  # everything but availability, where there is one claim PER entry.
  def self.claim_key(c) = [c["id"], c["claim"], c["country"]].join("|")

  def self.load_ledgers(tag, half)
    dir = File.join(ROOT, "data", "review", "audit-#{tag}", "ledger")
    r_files = Dir[File.join(dir, "researcher-#{half}-b*.yml")].sort
    v_files = Dir[File.join(dir, "verifier-#{half}-b*.yml")].sort
    abort "no researcher ledgers in #{dir}" if r_files.empty?
    researcher = {}
    verifier = {}
    meta = { "researcher_files" => r_files.map { |f| File.basename(f) },
             "verifier_files" => v_files.map { |f| File.basename(f) },
             "slices" => {} }
    r_files.each do |f|
      doc = YAML.safe_load_file(f, permitted_classes: [Date], aliases: false)
      slice = doc["slice"].to_s
      meta["slices"][slice] ||= {}
      meta["slices"][slice]["researcher"] = doc["researcher"]
      meta["slices"][slice]["build_pin"] = doc["build_pin"]
      (doc["claims"] || []).each do |c|
        c = c.merge("slice" => slice)
        researcher[claim_key(c)] = c
      end
    end
    v_files.each do |f|
      doc = YAML.safe_load_file(f, permitted_classes: [Date], aliases: false)
      slice = doc["slice"].to_s
      meta["slices"][slice] ||= {}
      meta["slices"][slice]["verifier"] = doc["verifier"]
      (doc["verdicts"] || []).each do |v|
        verifier[claim_key(v)] = v.merge("slice" => slice)
      end
    end
    [researcher, verifier, meta]
  end

  # I-11 as an assertion, not a hope: a slice whose researcher and verifier
  # are the same agent (or whose verifier never signed) is not a verified
  # slice, and its numbers must not be published as if they were.
  def self.check_i11(meta)
    problems = []
    meta["slices"].each do |slice, s|
      if s["verifier"].to_s.empty?
        problems << "slice #{slice}: no verifier signed — I-11 unsatisfied, numbers are researcher-only"
      elsif s["verifier"].to_s == s["researcher"].to_s
        problems << "slice #{slice}: researcher == verifier (#{s['researcher']}) — I-11 violated"
      end
    end
    problems
  end

  # ── resolution + tallies ──────────────────────────────────────────────────
  Resolved = Struct.new(:id, :claim, :country, :verdict, :defect_class,
                        :subtype, :source, :slice, :researcher_verdict, keyword_init: true)

  def self.resolve(researcher, verifier)
    keys = (researcher.keys + verifier.keys).uniq
    keys.map do |k|
      r = researcher[k]
      v = verifier[k]
      chosen = v && !v["final_verdict"].to_s.empty? ? v : r
      next nil unless chosen
      Resolved.new(
        id: (r || v)["id"], claim: (r || v)["claim"], country: (r || v)["country"],
        verdict: (chosen == v ? v["final_verdict"] : chosen["verdict"]).to_s,
        defect_class: (chosen == v ? v["final_defect_class"] : chosen["defect_class"]).to_s,
        subtype: (chosen == v ? v["final_unverifiable_subtype"] : chosen["unverifiable_subtype"]).to_s,
        source: chosen == v ? "verifier" : "researcher",
        slice: (chosen)["slice"],
        researcher_verdict: r && r["verdict"].to_s
      )
    end.compact
  end

  def self.tally(resolved)
    t = Hash.new { |h, k| h[k] = { "correct" => 0, "defective" => 0,
                                   "source-gap" => 0, "not-attempted" => 0, "total" => 0 } }
    resolved.each do |c|
      row = t[c.claim]
      row["total"] += 1
      case c.verdict
      when "correct" then row["correct"] += 1
      when "defective" then row["defective"] += 1
      when "unverifiable"
        st = SUBTYPES.include?(c.subtype) ? c.subtype : "not-attempted"
        row[st] += 1
      end
    end
    t
  end

  def self.rates(row)
    n = row["total"]
    unver = row["source-gap"] + row["not-attempted"]
    bad = row["defective"] + unver
    cp = Stats.clopper_pearson(bad, n)
    wl = Stats.wilson(bad, n)
    { "n" => n, "correct" => row["correct"], "defective" => row["defective"],
      "source_gap" => row["source-gap"], "not_attempted" => row["not-attempted"],
      "unverifiable" => unver, "bad" => bad,
      "clean_rate" => n.zero? ? 0.0 : row["correct"].to_f / n,
      "defect_rate" => n.zero? ? 0.0 : bad.to_f / n,
      "cp_lo" => cp[0], "cp_hi" => cp[1], "wilson_lo" => wl[0], "wilson_hi" => wl[1] }
  end

  # ── the three-strata arithmetic (§1.3) ────────────────────────────────────
  # weighted_defect_rate <= w_head * r_head + w_tail * r_tail.
  # Detector coverage is NOT a stratum (it spans all deciles and would push
  # the weights past 1); it reduces both r's and carries no weight.
  def self.stratified(resolved, build, half)
    w = build.weights_for(half)
    groups = { "head" => [], "tail" => [] }
    resolved.each { |c| groups[build.band_of(c.id) == "head" ? "head" : "tail"] << c }
    out = { "weights" => w, "strata" => {} }
    groups.each do |name, claims|
      recs = claims.map(&:id).uniq
      row = tally(claims).values.reduce({ "correct" => 0, "defective" => 0, "source-gap" => 0,
                                          "not-attempted" => 0, "total" => 0 }) do |a, b|
        a.merge(b) { |_, x, y| x + y }
      end
      r = rates(row)
      # Record-level: a record is defective if ANY of its claims is bad.
      bad_ids = claims.reject { |c| c.verdict == "correct" }.map(&:id).uniq
      r["records"] = recs.size
      r["records_defective"] = bad_ids.size
      r["record_rate"] = recs.empty? ? 0.0 : bad_ids.size.to_f / recs.size
      r["claims_per_record"] = recs.empty? ? 0.0 : claims.size.to_f / recs.size
      out["strata"][name] = r
    end
    if w
      rh = out["strata"]["head"]["cp_hi"]   # upper bounds, so the sum is a bound
      rt = out["strata"]["tail"]["cp_hi"]
      out["bound"] = { "w_head" => w["w_head"], "r_head_hi" => rh,
                       "w_tail" => w["w_tail"], "r_tail_hi" => rt,
                       "weighted_upper_bound" => w["w_head"] * rh + w["w_tail"] * rt }
    end
    out
  end

  # The audit's own error rate (§5.2): of the researcher `correct` claims the
  # verifier re-derived, how many moved? Published, because a measurement
  # instrument without a published error rate is a marketing number.
  def self.audit_error_rates(researcher, verifier, resolved)
    sampled = verifier.values.select { |v| researcher[claim_key(v)] &&
                                           researcher[claim_key(v)]["verdict"].to_s == "correct" }
    missed = sampled.count { |v| v["final_verdict"].to_s != "correct" && !v["final_verdict"].to_s.empty? }
    cp = Stats.clopper_pearson(missed, sampled.size)
    # Defect verdicts: did adversarial re-derivation hold them?
    dv = verifier.values.select { |v| researcher[claim_key(v)] &&
                                      researcher[claim_key(v)]["verdict"].to_s == "defective" }
    held = dv.count { |v| v["final_verdict"].to_s == "defective" }
    # Class labels: confirmed defective, but under a different D-class.
    moved = dv.count do |v|
      r = researcher[claim_key(v)]
      v["final_verdict"].to_s == "defective" &&
        !v["final_defect_class"].to_s.empty? &&
        v["final_defect_class"].to_s != r["defect_class"].to_s
    end
    { "corrects_sampled" => sampled.size, "corrects_missed" => missed,
      "miss_rate" => sampled.empty? ? 0.0 : missed.to_f / sampled.size,
      "miss_cp_lo" => cp[0], "miss_cp_hi" => cp[1],
      "defect_verdicts_reviewed" => dv.size, "defect_verdicts_held" => held,
      "defect_hold_rate" => dv.empty? ? 0.0 : held.to_f / dv.size,
      "class_labels_moved" => moved,
      "class_move_rate" => dv.empty? ? 0.0 : moved.to_f / dv.size }
  end

  def self.defect_classes(resolved)
    resolved.select { |c| c.verdict == "defective" }
            .group_by { |c| c.defect_class.empty? ? "(unclassified)" : c.defect_class }
            .transform_values(&:size).sort_by { |_, n| -n }.to_h
  end

  def self.run(tag, half)
    researcher, verifier, meta = load_ledgers(tag, half)
    resolved = resolve(researcher, verifier)
    build_pin = meta["slices"].values.map { |s| s["build_pin"] }.compact.uniq
    build = build_pin.size == 1 ? Build.new(build_pin.first) : nil
    {
      "tag" => tag, "half" => half, "meta" => meta,
      "build_pin" => build_pin,
      "i11" => check_i11(meta),
      "by_claim" => tally(resolved).transform_values { |r| rates(r) },
      "overall" => rates(tally(resolved).values.reduce({ "correct" => 0, "defective" => 0,
                                                        "source-gap" => 0, "not-attempted" => 0,
                                                        "total" => 0 }) { |a, b| a.merge(b) { |_, x, y| x + y } }),
      "stratified" => build ? stratified(resolved, build, half) : nil,
      "audit_error" => audit_error_rates(researcher, verifier, resolved),
      "defect_classes" => defect_classes(resolved),
      "resolved_count" => resolved.size,
      "verifier_touched" => resolved.count { |c| c.source == "verifier" }
    }
  end

  # ── self-test ─────────────────────────────────────────────────────────────
  def self.self_test!
    # Clopper-Pearson, checked TWO ways.
    #
    # (a) Textbook intervals for small n. These four are standard published
    #     values (R's binom.test) and are safe to hardcode.
    [[0, 10, 0.0, 0.30850],
     [1, 10, 0.00253, 0.44502],
     [5, 10, 0.18709, 0.81291],
     [10, 10, 0.69150, 1.0]].each do |k, n, lo, hi|
      a, b = Stats.clopper_pearson(k, n)
      raise "CP(#{k}/#{n}) lo #{a.round(5)} != #{lo}" if (a - lo).abs > 1e-4
      raise "CP(#{k}/#{n}) hi #{b.round(5)} != #{hi}" if (b - hi).abs > 1e-4
    end
    #
    # (b) The DEFINING PROPERTY, at the sizes this round actually reports.
    #     A remembered constant is not a reference — the first draft of this
    #     test asserted CP(412/2624) lower = 0.14340 from memory and the code
    #     returned 0.14329; the code was right. So the large-n check is now
    #     self-verifying instead of trusting a recalled number: p_L is the p
    #     at which P(X >= k) = alpha/2, and p_U the p at which P(X <= k) =
    #     alpha/2. The binomial tail below is summed directly from log-gamma
    #     terms — an INDEPENDENT code path from betai's continued fraction,
    #     so agreement is evidence and not a tautology.
    binom_cdf = lambda do |k, n, p|
      return 1.0 if p <= 0.0
      return (k >= n ? 1.0 : 0.0) if p >= 1.0
      (0..k).sum do |i|
        Math.exp(Stats.lgamma(n + 1) - Stats.lgamma(i + 1) - Stats.lgamma(n - i + 1) +
                 i * Math.log(p) + (n - i) * Math.log(1.0 - p))
      end
    end
    [[412, 2624], [7, 100], [1, 400], [95, 656]].each do |k, n|
      lo, hi = Stats.clopper_pearson(k, n)
      if k > 0
        upper_tail = 1.0 - binom_cdf.call(k - 1, n, lo)   # P(X >= k | p_L)
        raise "CP lower defining property failed at #{k}/#{n}: #{upper_tail}" if (upper_tail - 0.025).abs > 1e-6
      end
      if k < n
        lower_tail = binom_cdf.call(k, n, hi)             # P(X <= k | p_U)
        raise "CP upper defining property failed at #{k}/#{n}: #{lower_tail}" if (lower_tail - 0.025).abs > 1e-6
      end
    end
    # Wilson against the 4W baseline's own published interval — and note WHICH
    # numerator reproduces it. RESULTS.md reports "2,184 correct / 412
    # defective / 28 unverifiable of 2,624" with "defect+unverifiable rate
    # 16.77%, 95% CI 15.39%-18.25% (Wilson)". 412/2624 is 15.70% and its
    # interval does NOT match; 440/2624 (defective PLUS unverifiable) is
    # 16.77% and reproduces the published bounds exactly. That is the
    # conservative-bound convention of the protocol, and `bad` in this file
    # is defined as that same sum — so this assertion is a check that the
    # aggregator counts the way the published round counted.
    raise "baseline numerator" unless ((440.0 / 2624) - 0.1677).abs < 5e-5
    wl, wh = Stats.wilson(440, 2624)
    raise "Wilson lo #{wl}" if (wl - 0.1539).abs > 5e-4
    raise "Wilson hi #{wh}" if (wh - 0.1825).abs > 5e-4
    # betai sanity: I_x(a,b) is a CDF — monotone, endpoints exact.
    raise "betai(0)" unless Stats.betai(2, 3, 0.0) == 0.0
    raise "betai(1)" unless Stats.betai(2, 3, 1.0) == 1.0
    raise "betai monotone" unless Stats.betai(2, 3, 0.3) < Stats.betai(2, 3, 0.7)
    # Resolution rule: verifier wins where it spoke, researcher elsewhere.
    r = { "car/a/b|id|" => { "id" => "car/a/b", "claim" => "id", "verdict" => "correct", "slice" => "1" },
          "car/a/c|id|" => { "id" => "car/a/c", "claim" => "id", "verdict" => "defective",
                             "defect_class" => "D6", "slice" => "1" } }
    v = { "car/a/b|id|" => { "id" => "car/a/b", "claim" => "id", "final_verdict" => "defective",
                             "final_defect_class" => "D8", "slice" => "1" } }
    res = resolve(r, v)
    b_row = res.find { |x| x.id == "car/a/b" }
    c_row = res.find { |x| x.id == "car/a/c" }
    raise "verifier did not win" unless b_row.verdict == "defective" && b_row.defect_class == "D8"
    raise "researcher not preserved" unless c_row.verdict == "defective" && c_row.source == "researcher"
    # The audit's own error rate sees that overturn as a researcher MISS.
    ae = audit_error_rates(r, v, res)
    raise "miss not counted" unless ae["corrects_sampled"] == 1 && ae["corrects_missed"] == 1
    # Conservative bound: clean + defect == 1 exactly.
    t = tally(res)
    t.each_value do |row|
      rr = rates(row)
      raise "clean+defect != 1" if ((rr["clean_rate"] + rr["defect_rate"]) - 1.0).abs > 1e-12
    end
    # I-11 assertion fires on a self-signed slice.
    bad = { "slices" => { "1" => { "researcher" => "x", "verifier" => "x" } } }
    raise "I-11 check silent" if check_i11(bad).empty?
    puts "self-test: OK (Clopper-Pearson vs 4 textbook intervals AND its defining property at " \
         "4 round-realistic sizes via an independent binomial-tail path; Wilson reproducing the " \
         "published baseline CI from the defective+unverifiable numerator; resolution rule; " \
         "audit-error accounting; conservative-bound identity; I-11 assertion)"
  end
end

if $PROGRAM_NAME == __FILE__
  opts = {}
  ARGV.each do |a|
    case a
    when "--self-test" then AuditAggregate.self_test!; exit 0
    when /\A--tag=(.+)/ then opts["tag"] = $1
    when /\A--half=(s4w|s2w)\z/ then opts["half"] = $1
    when "--json" then opts["json"] = true
    else abort "unknown arg #{a}"
    end
  end
  abort "need --tag= and --half= (or --self-test)" unless opts["tag"] && opts["half"]
  out = AuditAggregate.run(opts["tag"], opts["half"])
  if opts["json"]
    puts JSON.pretty_generate(out)
  else
    puts "round #{out['tag']} half #{out['half']} — #{out['resolved_count']} claims " \
         "(#{out['verifier_touched']} verifier-final)"
    out["i11"].each { |p| puts "I-11: #{p}" }
    puts format("%-14s %6s %8s %8s %9s %13s %7s", "claim", "n", "correct", "defect", "unverif", "defect rate", "CP95 hi")
    out["by_claim"].sort.each do |k, r|
      puts format("%-14s %6d %8d %8d %9d %12.2f%% %6.2f%%",
                  k, r["n"], r["correct"], r["defective"], r["unverifiable"],
                  r["defect_rate"] * 100, r["cp_hi"] * 100)
    end
    o = out["overall"]
    puts format("%-14s %6d %8d %8d %9d %12.2f%% %6.2f%%", "ALL", o["n"], o["correct"],
                o["defective"], o["unverifiable"], o["defect_rate"] * 100, o["cp_hi"] * 100)
    if (s = out["stratified"]) && s["bound"]
      b = s["bound"]
      puts format("bound: w_head %.4f x r_head<=%.4f + w_tail %.4f x r_tail<=%.4f = %.6f",
                  b["w_head"], b["r_head_hi"], b["w_tail"], b["r_tail_hi"], b["weighted_upper_bound"])
    end
  end
end
