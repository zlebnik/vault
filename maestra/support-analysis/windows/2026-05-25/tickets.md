# tickets — week 2026-05-25 (ISO 2026-W22, Mon 25 – Sun 31 May)

Stage 1 (find). Candidates only.

- **Track:** both
- **ClearFeed coll 4 (product-support):** 46 requests → 4 personalization candidates.
- **Slack #csm-support:** link+keyword → 0 personalization threads (all billing/pricing/invoicing — dropped).
- **Custom-code mechanics (omega, lower bound):** 130 created → **43 with custom code** (html/css 40 · targeting 16 · integration 13) — a high creation week but the **lowest custom-code ratio** (33%) seen. Partition: reco html 6 · popup/inline html 21 · targeting 16 · integration overlaps.

> Infra note: restarting the DB proxy triggered a browser OIDC login (maestra tsh session likely expired) — queries still returned valid data, so W22 is complete, but a `tsh login` may be needed before the next DB run.

---

## Section A — Support tickets/threads

```
- [ ] t01 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1779822892936139 | selkirkcom   | 2026-05-25 | Selkirk wants recommendations showing multiple products on one card
- [ ] t02 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1779870162822599 | ?            | 2026-05-26 | strange operation popmechanic-widget-55454-reco-2 + errors
- [ ] t03 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1779874030094519 | ?            | 2026-05-26 | why can('t) my client see the widget
- [ ] t04 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1779994668165949 | lectricebikes | 2026-05-28 | A/B tests & reporting question for a reco A/B test
```

---

## Section B — Custom-code mechanics (omega DB, lower bound)

43 mechanics. Buckets: `h`=html/css, `t`=targeting JS, `i`=integration JS. Partition: reco html 6 · popup/inline html 21 · targeting 16 · integration 13 (overlaps).

```
marathonbet-eu 12  (pop-up; targeting = GTM)
Lucyandyak 6       (inline+reco; i)
enlightenedequip 4 (referral integration i)
lectricebikes 3    (i)
bedkingdom 2 · idaka 2 · ispace 2 · Strikeman 2
pochtoy 1 · astons 1 · Wowvendor-us 1 · betboom 1 · + tail
```

Enrichment (cluster-level): same recurring patterns — reco markup (rc-mf-reco-variant-dedup), targeting (marathonbet GTM → rc-cc-targeting-gtm-gating), integration ops (enlightenedequip referral, Lucyandyak, lectricebikes → rc-cc-popup-integration-ops), pop-up/inline template gap. **43 count is the metric (lowest ratio week).**
