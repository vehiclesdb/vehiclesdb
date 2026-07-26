# Verdict: citroën ë- prefix pairs are NOT duplicates (recorded 2026-07-26)

`find_published_name_defects.rb` check 2 flags `citroen/c3` vs `citroen/e-c3`,
`c4` vs `e-c4`, and `jumper` vs `e-jumper` as near-duplicate names. **All three
are false positives and must not be folded.** The `ë-` prefix is Citroën's
battery-electric line (ë-C3, ë-C4, ë-Jumper — https://www.citroen.com), sold
ALONGSIDE the ICE cars as distinct products with their own registrations,
pricing and (eventually) production runs. The same shape as VW ID.3-vs-Golf,
not the same shape as a spelling variant.

Raised by S2W (NEGOTIATION Turn 112), verdict recorded by S4W (Turn 115) so
the next sweep does not re-open it. If a future source shows registries using
the two spellings for ONE product line, reopen with that evidence.
