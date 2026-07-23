# tickets — week 2026-06-29 (ISO 2026-W27, Mon 29 Jun – Sun 05 Jul)

Stage 1 (find). Candidates only. Stage 2 reads + drops false positives.

- **Track:** both
- **ClearFeed coll 4 (product-support):** 38 requests in window → 9 personalization candidates
- **Slack #csm-support:** link+keyword recall → only hit is the Lucy&Yak reco-review thread (parent 07-01), **already counted in W28 (t10)**; deduped by thread_ts, **not re-counted here**
- **Custom-code mechanics (omega, lower bound):** 77 created → **63 with custom code** (html/css 62 · targeting 16 · integration 11), 22 tenants

---

## Section A — Support tickets/threads

```
- [ ] t01 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1782813309221179 | zone3          | 2026-06-30 | new text bar on Zone3 — "whole mess getting it placed"
- [ ] t02 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1782897255892259 | limevizio      | 2026-07-01 | blossomflowerdelivery / limevizio flagged an issue (vague — read)
- [ ] t03 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1782918270506749 | ?              | 2026-07-01 | error adding an A/B test within the popup creation tool
- [ ] t04 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1782923957849159 | atlantacutlery | 2026-07-01 | setting up / fixing the loyalty widget (/personalization/…)
- [ ] t05 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1782927686071299 | selkirkcom     | 2026-07-01 | add a second "Post-purchase cross-sell" algorithm for Selkirk
- [ ] t06 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1782999003845589 | ?              | 2026-07-02 | Email builder — recommendation block renders too narrow (borderline: email, not a mechanic?)
- [ ] t07 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783010541696629 | ?              | 2026-07-02 | pop-up didn't save after creating a teaser
- [ ] t08 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783020763145839 | coolibar       | 2026-07-02 | /personalization/pop-up/58478 — tested new pop-up with authorization…
- [ ] t09 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783020863858259 | ?              | 2026-07-02 | product matcher UI updates broke something
```

> Slack note: the Lucy&Yak thread (`C089G0JMXJP` p1782911849751909, parent 07-01, "review our reco launch") is the same thread whose dedup/swatches findings landed in W28 and were counted there as t10. **Rule applied: dedupe Slack threads by thread_ts; count once, in the week the substantive finding lands.** Not re-counted in W27.

---

## Section B — Custom-code mechanics (omega DB, lower bound)

63 mechanics, grouped by tenant. Buckets: `h`=html/css, `t`=targeting JS, `i`=integration JS.

```
marathonbet-eu — 14 (pop-up) · html/css + targeting JS (GTM gating)
  58396 58397 58415 58416 58417 58418 58465 58466 58467 58468 58473 58474 58475 58476   [h,t]
Foodcycler — 5 (pop-up) [h]:            58379 58380 58389 58469 58470
SvahaUSA — 5 (inline ×4, reco ×1) [h]:  58407 58421 58423 58479 58480
BlueQ — 5 (inline ×2, reco ×3) [h]:     58401 58402 58410 58411 58412
betboom — 4 (pop-up) [h]:               58382 58387 58394 58477
Lucyandyak — 4 (inline ×2, pop-up ×2) [h,i]: 58459 58461 58463 58464
audiogon — 3 (inline) [h]:              58383 58384 58385
Onethrive — 3 (inline) [h]:             58404 58405 58425
Movavicom — 3 (pop-up) [h; 58414 also t=language gating]: 58414 58462 58494
zone3 — 2 (inline) [h,i = header-position fix]: 58388 58390
AlmondCow — 2 (pop-up) [h,i = click handling]: 58420 58424
CopenhagenLiving — 2 (reco) [h/i = mobile slider fix]: 58491 58497
hawaiicoffee — 2 (reco) [h]:            58482 58483
Clientsen — 1 (inline) [h,t = business-hours gating]: 58496
singletons [h unless noted]: ispace 58386(pop) · ilovelinen 58391(inline) · ecofinance 58381(inline) ·
  natvbasics 58419(inline) · bokksu 58488(reco,h,i) · Sena 58481(reco) · atlantacutlery 58408(pop) ·
  Allegianteyewear 58400(reco)
```

Enrichment (cluster-level): marathonbet GTM-gating JS confirmed (`isPopupAllowed()`); targeting also now language (Movavicom) + business-hours (Clientsen) gating → same "targeting UI too limited" cause. Integration JS = reco DOM injection + add-to-cart (Lucyandyak), responsive slider fix (CopenhagenLiving), header positioning (zone3 — ties to t01). Reco/pop-up/inline html/css = hand-authored markup. **60-ish count is the metric.**
