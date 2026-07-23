# tickets — week 2026-06-22 (ISO 2026-W26, Mon 22 – Sun 28 Jun)

Stage 1 (find). Candidates only.

- **Track:** both
- **ClearFeed coll 4 (product-support):** 50 requests → 7 personalization candidates
- **Slack #csm-support:** link+keyword → 1 new personalization thread (reco-preset how-to, parent 06-23) — **out of the 4-group taxonomy (how-to)**, flagged for a taxonomy decision, not counted in groups. (bokksu subscription-email thread = transactional email, dropped.)
- **Custom-code mechanics (omega, lower bound):** 118 created → **95 with custom code** (html/css 94 · targeting 19 · integration 26), 26 tenants — the biggest week so far.

---

## Section A — Support tickets/threads

```
- [ ] t01 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1782232239138659 | Aiby       | 2026-06-23 | wants personalized pushes/emails based on favorite category (feature request)
- [ ] t02 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1782300214210689 | jolyn      | 2026-06-24 | add a custom recommendation at /recommendations-algorithms
- [ ] t03 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1782312749710779 | jolyn      | 2026-06-24 | launched two new widgets, needs help
- [ ] t04 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1782324762714079 | hawaiicoffee | 2026-06-24 | help updating the widget template
- [ ] t05 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1782390851350049 | lucyandyak | 2026-06-25 | /personalization/inline-block/57525 — "эта срань" (broken)
- [ ] t06 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1782422545098389 | ?          | 2026-06-25 | what happens to user information on lead (forms/lead capture)
- [ ] t07 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1782457814996109 | ?          | 2026-06-26 | help with the dropdown variant block in the widget
- [flagged] s01 | slack | https://maestraio.slack.com/archives/C089G0JMXJP/p1782161347047509 | ? | 2026-06-23 | HOW-TO: which reco presets exclude already-purchased products (Julia↔Paul) — out of taxonomy
```

> Taxonomy note: s01 is genuine personalization support toil but a pure product-knowledge **how-to** — no bug/gap/config/custom-code. The 4-group taxonomy has no slot for it (the original scope had a "how-to" category). Held out of the comparable group counts pending your decision on whether to add a 5th "How-to / docs" group.

---

## Section B — Custom-code mechanics (omega DB, lower bound)

95 mechanics, 26 tenants. Buckets: `h`=html/css, `t`=targeting JS, `i`=integration JS.

```
marathonbet-eu 14 (pop-up)      h,t  — GTM gating
betboom 12 (pop-up)             h
drhonow 12 (inline+reco)        h; i6 — shopify-section reco injection
hawaiicoffee 6 (inline+reco)    h; i1 — BigCommerce add-to-cart
magnumbikes 5 (inline)          h; i2 — form submit guard
SvahaUSA 4 (inline)             h; i1 — persona API
lectricebikes 4 (inline+reco)   h; i3 — init retry/DOM-ready polling
Lucyandyak 4 (inline+pop+reco)  h; i1 — newsletter prefs
pochtoy 3 (pop-up)              h
Sena 3 (inline+pop-up)          h; i3 — email capture + PopMechanic.show
ispace 3 (inline+reco)          h2; i2 — price formatting, viber-unsub API
CopenhagenLiving 3 (reco)       h
atlantacutlery 2 (pop-up)       h; i2 — close-button style injection
BlueQ 2 (inline+reco)           h; t1 — 1s delay gate
bokksu 2 (inline+reco)          h; i1 — image handling
Clientsen 2 (inline)            h
Jolyn 2 (reco)                  h; t2 (Shopify currency gating); i2 (embed style)
Monkeysports 2 (inline)         h
Movavicom 2 (pop-up)            h; t2 (language gating)
natvbasics 2 (inline+reco)      h; i1 — goal tracking
singletons: pescatoreny(reco) · larixon(pop) · selkirkcom(pop) · hoeglcom(inline,i) · doraihome(inline) · Wowvendor-us(inline)
```

Enrichment (cluster-level): targeting now also **currency** (Jolyn) and **1s-delay** (BlueQ) gating — same "targeting UI too limited" cause. Integration = theme-slot injection (drhonow ×6), add-to-cart (hawaiicoffee), API ops (ispace viber, SvahaUSA persona), form handling (magnumbikes/natvbasics/Sena/Lucyandyak), style injection (atlantacutlery/Jolyn). html/css = hand-authored markup baseline. **95 count is the metric.**
