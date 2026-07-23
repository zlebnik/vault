# tickets — week 2026-07-13 (ISO 2026-W29, Mon 13 – Sun 19 Jul)

Stage 1 (find). Candidates only — no thread reading / classification (stage 2 drops false positives).

- **Track:** both
- **ClearFeed coll 4 (product-support):** 48 requests in window → 14 personalization candidates (title triage; wide net).
- **Slack #csm-support:** link+keyword recall → 2 personalization threads (Okendo/reviews-for-reco; reco template + product-based algorithms). Other channel traffic (mailings/scenarios/segments/webhooks/DNS/infra) = non-personalization, not listed.
- **Custom-code mechanics (omega, lower bound):** 88 created → **69 with custom code** (html/css 68 · targeting 12 · integration 21), partition: reco html 16 · popup/inline html 52 · targeting 12 · integration 21.

---

## Section A — Support tickets/threads

```
- [ ] t01 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783931587983539 | jolyn      | 2026-07-13 | Reco BI report not working (jolyn/lucy product-recommendations dashboard)
- [ ] t02 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783933603376309 | ?          | 2026-07-13 | "maybe related to reco report but emails also not working"
- [ ] t03 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783941155257219 | drhonow    | 2026-07-13 | "Alarm — launched many widgets & recommendations, inline blocks" (drhonow)
- [ ] t04 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783954538310529 | movavicom  | 2026-07-13 | movavi — error with our tracker/script?
- [ ] t05 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783957670801839 | lucyandyak | 2026-07-13 | reco variants show out-of-stock products (lucyandyak)
- [ ] t06 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1784021823125099 | lucyandyak | 2026-07-14 | new ticket: product availability in reco (lucy, client-side stock)
- [ ] t07 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1784022710000989 | lucyandyak | 2026-07-14 | US product feed not loading for lucy
- [ ] t08 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1784028042696819 | ?          | 2026-07-14 | "you may also like" recommendations not working again
- [ ] t09 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1784108286481209 | ?          | 2026-07-15 | desktop/mobile: add-to-cart / cart-update on click stopped working
- [ ] t10 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1784113403113449 | lucyandyak | 2026-07-15 | enable filter by custom-field zones for lucy (targeting)
- [ ] t11 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1784193387998739 | ?          | 2026-07-16 | "take a look at this in-app" (in-app/inline message)
- [ ] t12 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1784214427144459 | ?          | 2026-07-16 | verification code in popup doesn't work
- [ ] t13 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1784279899455249 | ?          | 2026-07-17 | product feed broken — not updating
- [ ] t14 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1784284564946539 | betboom    | 2026-07-17 | betboom /personalization/pop-up/59687
- [ ] s01 | slack     | https://maestraio.slack.com/archives/C089G0JMXJP/p1784213194210719 | ?          | 2026-07-16 | Okendo reviews integration for reco widget (reviews/ratings into feed, like Yotpo)
- [ ] s02 | slack     | https://maestraio.slack.com/archives/C089G0JMXJP/p1783947104045289 | ?          | 2026-07-13 | reco template update + product-based algorithm tuning (in-window activity; parent predates week)
```

---

## Section B — Custom-code mechanics (omega DB, read-only, lower bound)

Summarized at cluster level (per established practice; exact bucket figures below feed the registry `custom_code_totals`). Enrichment samples clusters, not per-mechanic.

- **created in window:** 88 · **with custom code (distinct):** 69
- **html/css:** 68 — by proxy type: pop-up 35 · inline-block 17 · reco-widget 16
- **targeting JS:** 12
- **integration JS:** 21

Custom-code clusters (stable): reco markup 16 · popup/inline template gap 52 · targeting 12 · integration ops 21.
