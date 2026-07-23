# tickets — week 2026-06-15 (ISO 2026-W25, Mon 15 – Sun 21 Jun)

Stage 1 (find). Candidates only.

- **Track:** both
- **ClearFeed coll 4 (product-support):** 53 requests → 10 personalization candidates
- **Slack #csm-support:** link+keyword → 2 personalization threads (reco template-upgrade ask; bundle-setup how-to). Other hits (bokksu recharge emails, movavi billing, larixon DPA) = non-personalization, dropped.
- **Custom-code mechanics (omega, lower bound):** 100 created → **64 with custom code** (html/css 59 · targeting 8 · integration 18), 18 tenants.

---

## Section A — Support tickets/threads

```
- [ ] t01 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1781520809482949 | hoeglcom   | 2026-06-15 | /personalization/inline — phone-format issue in the form
- [ ] t02 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1781533862203659 | lucyandyak | 2026-06-15 | "notify in stock" widget button not working (/personalization/inline)
- [ ] t03 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1781631200716869 | drhonow    | 2026-06-16 | /personalization/reco-widget/58044 — issue with recommendation widget
- [ ] t04 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1781632505762839 | deako      | 2026-06-16 | /personalization/reco-widget/55732 — checkout recommendations
- [ ] t05 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1781636585061709 | ?          | 2026-06-16 | issue with geotargeting?
- [ ] t06 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1781675187671859 | zone3      | 2026-06-17 | /personalization/reco-widget/55349 — take a look at this widget
- [ ] t07 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1781705863336709 | ?          | 2026-06-17 | pop-ups working badly
- [ ] t08 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1781783500007889 | ?          | 2026-06-18 | log an improvement for personalization / recommendations
- [ ] t09 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1781784276205999 | ?          | 2026-06-18 | "did we do something with popups?" (vague)
- [ ] t10 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1781787520745879 | ?          | 2026-06-18 | trouble when creating popups
- [ ] s01 | slack     | https://maestraio.slack.com/archives/C089G0JMXJP/p1781719637466469 | hawaiicoffee | 2026-06-17 | reco widgets on old template — update to new one without rebuilding? (matches W26 t04 cause)
- [ ] s02 | slack     | https://maestraio.slack.com/archives/C089G0JMXJP/p1781790498832899 | ?          | 2026-06-18 | bundle setup like Rebuy (select products added together); note: can't do discount only-when-added-from-rec
```

---

## Section B — Custom-code mechanics (omega DB, lower bound)

64 mechanics, 18 tenants. Buckets: `h`=html/css, `t`=targeting JS, `i`=integration JS. Partition: reco html 16 · popup/inline html 35 · targeting 8 · integration-only 5.

```
Lucyandyak 14 (inline+pop-up+reco)  h; i3
magnumbikes 6 (inline+pop-up)       h
marathonbet-eu 6 (pop-up)           h,t  — GTM gating
ispace 5 (inline+pop-up)            h
Budsies 5 (inline+pop-up)           i5 (integration-only, no html)
Deako 4 (inline)                    h
Foodcycler 3 (pop-up)               h; i1
ilovelinen 3 (inline+reco)          h; i3
bokksu 3 (reco)                     h; i3
hawaiicoffee 3 (inline)             h
1winstore 2 (pop-up)                h
AlmondCow 2 (pop-up)                h; i2
betboom 2 (pop-up)                  h
Movavicom 2 (pop-up)                h,t  — language gating
singletons: bedkingdom(inline) · Allegianteyewear(pop) · pescatoreny(reco) · BlueQ(inline,i)
```

Enrichment (cluster-level): same recurring patterns — reco hand-authored markup, marathonbet GTM + Movavicom language targeting, integration JS (Budsies all-integration, Lucyandyak/ilovelinen/bokksu injection & ops), pop-up/inline template gap. **64 count is the metric.**
