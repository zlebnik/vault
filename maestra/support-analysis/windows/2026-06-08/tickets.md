# tickets — week 2026-06-08 (ISO 2026-W24, Mon 08 – Sun 14 Jun)

Stage 1 (find). Candidates only.

- **Track:** both
- **ClearFeed coll 4 (product-support):** 37 requests → 6 personalization candidates
- **Slack #csm-support:** link+keyword → 2 personalization threads (reco-carousel-via-Swiper; Shopify integration/pop-up-sync capabilities). Other hits (amzscout pricing, copenhagen "recognize client") = non-personalization, dropped.
- **Custom-code mechanics (omega, lower bound):** 75 created → **56 with custom code** (html/css 53 · targeting 12 · integration 12), 24 tenants — lightest custom-code week.

---

## Section A — Support tickets/threads

```
- [ ] t01 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1780927113707229 | ?            | 2026-06-08 | please fix these two recommendation widgets
- [ ] t02 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1780944580726519 | bedkingdom   | 2026-06-09 | /personalization/pop-up/57702 — check this pop-up
- [ ] t03 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1781019663873919 | drhonow      | 2026-06-09 | /personalization/reco-widget — need help with a recommendation widget
- [ ] t04 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1781099438076139 | ?            | 2026-06-10 | is there a backlog for reco improvements I can add to?
- [ ] t05 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1781186391436609 | monkeysports | 2026-06-11 | /personalization/reco-w — help hook up the reco widget
- [ ] t06 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1781256213986689 | ?            | 2026-06-12 | reco widget "Frequently Bought With" — PDP add-to-cart button + size selector
- [ ] s01 | slack     | https://maestraio.slack.com/archives/C089G0JMXJP/p1781199051649359 | ?            | 2026-06-11 | merchant wants reco templates built on their site carousel (SwiperJS)
- [ ] s02 | slack     | https://maestraio.slack.com/archives/C089G0JMXJP/p1781207700826419 | ?            | 2026-06-11 | Shopify integration/capabilities: pop-up→Shopify sync, segments, account-portal customization
```

---

## Section B — Custom-code mechanics (omega DB, lower bound)

56 mechanics, 24 tenants. Buckets: `h`=html/css, `t`=targeting JS, `i`=integration JS. Partition: reco html 17 · popup/inline html 24 · targeting 12 · integration-only 3.

```
marathonbet-eu 12 (pop-up)          h,t  — GTM gating
CopenhagenLiving 5 (inline+reco)    h
Lucyandyak 4 (inline+reco)          h; i2
Allegianteyewear 4 (reco)           h
lectricebikes 3 (inline+reco)       h; i2
pescatoreny 3 (pop-up)              h
ilovelinen 2 (pop-up)               h
tac 2 (inline)                      h; i2
ispace 2 (inline)                   h
jewellerybox 2 (reco)               h
astons 2 (pop-up)                   h; i2
octobrowsernet 2 (pop-up)           h
Budsies 2 (pop-up)                  i2 (integration-only)
singletons: urbanarmorgear(pop,i) · betboom(pop) · hawaiicoffee(inline,i) · hoeglcom(inline) · Monkeysports(reco) · natvbasics(inline) · Onethrive(pop) · sarahssilks(pop) · SvahaUSA(reco) · test-maestra(pop) · 1winstore(pop)
```

Enrichment (cluster-level): same recurring patterns — reco hand-authored markup, marathonbet GTM targeting, integration JS (Budsies/tac/astons/Lucyandyak/lectricebikes), pop-up/inline template gap. **56 count is the metric.**
