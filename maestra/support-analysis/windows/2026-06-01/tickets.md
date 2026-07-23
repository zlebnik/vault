# tickets — week 2026-06-01 (ISO 2026-W23, Mon 01 – Sun 07 Jun)

Stage 1 (find). Candidates only.

- **Track:** both
- **ClearFeed coll 4 (product-support):** 57 requests → 10 personalization candidates. (Note: `requests_list` timed out once — connector slowness — succeeded on retry.)
- **Slack #csm-support:** link+keyword → 0 personalization threads (all legal/DPA, SMS/brokstock, WhatsApp-survey, channel-naming — dropped).
- **Custom-code mechanics (omega, lower bound):** 80 created → **70 with custom code** (html/css 68 · targeting 17 · integration 17), 12+ tenants. Partition: reco html 21 · popup/inline html 30 · targeting 17 · integration-only 2.

---

## Section A — Support tickets/threads

```
- [ ] t01 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1780320296258729 | copenhagenliving | 2026-06-01 | /personalization/... — why can't we collect names in this form
- [ ] t02 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1780326565482399 | ?            | 2026-06-01 | help with a pop-up (urgent)
- [ ] t03 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1780387344597939 | ?            | 2026-06-02 | issue with the Product Recommendations dashboard?
- [ ] t04 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1780399163426149 | lucyandyak   | 2026-06-02 | /personalization/reco-widget/57719 + test link
- [ ] t05 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1780417106343099 | natvbasics   | 2026-06-02 | /personalization/pop-up/56874/settings
- [ ] t06 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1780567512308009 | ?            | 2026-06-04 | add a second image to a magento product for the widget
- [ ] t07 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1780581321897409 | lucyandyak   | 2026-06-04 | /recommendations-algorithms — please add algorithms
- [ ] t08 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1780582938116049 | lucyandyak   | 2026-06-04 | variant selection not working in both widgets
- [ ] t09 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1780611238595579 | sarahssilks  | 2026-06-05 | help with this widget
- [ ] t10 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1780697348797889 | ?            | 2026-06-06 | product recommendations stuck in "updating" ~1.5h
```

---

## Section B — Custom-code mechanics (omega DB, lower bound)

70 mechanics. Buckets: `h`=html/css, `t`=targeting JS, `i`=integration JS. Partition: reco html 21 · popup/inline html 30 · targeting 17 · integration-only 2.

```
Movavicom 14   (pop-up; targeting = language gating)
pescatoreny 8
Lucyandyak 7   (inline+reco; i)
astons 7       (pop-up; i)
Monkeysports 7 (reco)
lectricebikes 4 (i)
BlueQ 4
marathonbet-eu 2 (targeting = GTM)
drhonow 2 · bokksu 2 · test-maestra 2 · natvbasics 2 · + tail
```

Enrichment (cluster-level): same recurring patterns — reco markup (rc-mf-reco-variant-dedup), targeting (Movavicom language + marathonbet GTM → rc-cc-targeting-gtm-gating), integration ops (astons/Lucyandyak/lectricebikes/bokksu → rc-cc-popup-integration-ops), pop-up/inline template gap. **70 count is the metric.**
