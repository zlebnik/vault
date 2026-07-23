# enriched — week 2026-07-06 (ISO 2026-W28, Mon 06 – Sun 12 Jul)

Stage 2. Support entries read from full threads (subagents); custom-code entries from DB cluster sampling.

- **Support candidates:** 10 → **kept 6** (dropped t01, t02, t07 = infra incidents; t09 = standalone Quizzes product, not a personalization mechanic).
- **Kept groups (as reconciled in stage 3):** Bug 2 · Missing feature 3 · Custom code 1 · New client setup 0.
- **Custom-code mechanics:** 60 (omega lower bound) across 5 patterns.

> Normalization note: t10 was returned as "Custom code" by the subagent but is reconciled to **Missing feature** — its gap (reco parent-product dedup / swatches, popup↔modal mutual-exclusion) is a product gap whose *current* fix happens to be custom code. Rule: classify a cause by the fix it needs, not by today's workaround. t06 stays **Custom code** because the failure is in client-owned custom code itself.

---

## Support entries

### t01  ·  —  ·  drop
- **client:** lucyandyak, jolyn   **source:** clearfeed   **repetitive:** true
- **root cause:** On-call engineer hit a platform-wide DB outage that broke reco report dashboards — a Jul 3 rolling upgrade left zombie replicas whose slots pinned WAL (max_slot_wal_keep_size=-1), filling 10Gi volumes by Jul 5, wedging writes, and half-committing a Vault credential rotation.
- **current solution:** Infra ops (killed frozen vault-agent pods, recreated replicas); follow-up MRs for slot alerting + WAL caps + rotator fixes.
- **pain:** Reco report dashboards would not load for multiple tenants during the outage.
- **drop reason:** Platform/infra incident (WAL disk fill + Vault rotation), not a personalization product defect.

### t02  ·  —  ·  drop
- **client:** ilovelinen   **source:** clearfeed   **repetitive:** false
- **root cause:** Marketer hit unusably slow load/save on the reco-widget settings page because Maestra was mid data-center migration — infra, not the reco feature.
- **current solution:** None — resolved itself once the DC migration finished.
- **pain:** /personalization/reco-widget/58508/settings loaded endlessly, saves crawled, while other sections worked.
- **drop reason:** Infra performance (DC migration), not a mechanic defect.

### t03  ·  Bug  ·  keep
- **client:** lucyandyak   **source:** clearfeed   **repetitive:** true
- **root cause:** As a personalization manager duplicating a reco-widget, I hit an error and a very long delay before the copy completes, because the widget-copy operation has a backend performance issue rather than failing outright.
- **current solution:** Engineering pushed a backend fix to speed up widget-copy; asked reporter to re-verify (ticket marked solved).
- **pain:** "Unable to copy the widgets" — copy threw an error and finished only "с дикой задержкой".

### t04  ·  Missing feature  ·  keep
- **client:** zone3   **source:** clearfeed   **repetitive:** true
- **root cause:** As a CSM configuring a discount pop-up for Zone3, I can't give the client a unique per-customer promo code on the pop-up's final screen, because the pop-up mechanic only renders a single static (universal) code — no way to pull/generate a distinct code per visitor.
- **current solution:** None — only a universal code is possible today.
- **pain:** "Zone3 has asked if we can show a unique promo code for each customer on the final screen of the pop-up… for now we can only display a universal code."

### t05  ·  Missing feature  ·  keep
- **client:** lucyandyak   **source:** clearfeed   **repetitive:** true
- **root cause:** As a CSM managing lucyandyak's reco widgets, I get recommendation lists showing the same product once per colour because the Shopify feed assigns a distinct group id per colour variant, so Maestra's group-id dedup never merges them — and there's no self-serve, account-wide way to fix it. Same pattern seen with Jolyn.
- **current solution:** Engineer added a manual "recommendations custom sorting" rule on *one* widget (reco-widget/57936); noted dupes "will still pop up in other channels" and logged the broader catalog/Shopify fix to backlog. CSM was copying the setting to other widgets by hand.
- **pain:** Reco recommends "как будто одна и та же карточка товара"; "Полная херня в каталоге"; no self-serve account-wide dedupe.

### t06  ·  Custom code  ·  keep
- **client:** lucyandyak   **source:** clearfeed   **repetitive:** true
- **root cause:** As a support engineer triaging "recommendations show nothing," I must first rule out the reco engine before finding the real cause upstream: a client-owned custom JS snippet (Shopify metafield `landy.online_stock_status`, inventoryQuantity fallback) was edited and broke, marking every product out-of-stock, so the reco widget correctly returned zero eligible products.
- **current solution:** Support traced empty reco → product availability; client's own dev fixed the custom stock-status script (outside Maestra). Client confirmed resolved.
- **pain:** Reco looked completely broken (empty everywhere), read as a Maestra bug, but was client custom code silently zeroing stock.

### t07  ·  —  ·  drop
- **client:** marathonbet-eu   **source:** clearfeed   **repetitive:** true
- **root cause:** On-call engineer explained why pop-ups wouldn't launch / reco-widgets wouldn't edit / test links wouldn't generate — a stale Kargo/Octopus promotion rolled back the personalization service's Redis config to a dead EU endpoint, hanging celery calls inside activate/start_test/copy and holding DB locks.
- **current solution:** Promoted fresh freight 1.0.2129; added a downgrade-guard to the Octopus/Kargo promote template. Deeper anti-pattern (external calls inside transaction.atomic()) flagged as follow-up.
- **pain:** All personalization actions blocked ~2h during an infra deploy incident.
- **drop reason:** Infra deployment incident, not a personalization product bug/gap/config.

### t08  ·  Bug  ·  keep
- **client:** lucyandyak   **source:** clearfeed   **repetitive:** true
- **root cause:** As a CRM manager A/B-testing two reco-widget variants that both use "replace content" on the same PDP slot, I get an intermittently empty widget because the two variants (and the site's legacy reco block) race to replace the same DOM node — load order decides who wins. Assignee: "была такая же проблема" — a known failure mode of replace-content + A/B on one target.
- **current solution:** Engineer made a manual server-side/config fix to stop the race; confirmed working. Fallback discussed: ask client to remove their legacy block.
- **pain:** "You may also like" randomly disappears on refresh — "иногда появляется, а иногда продолжает быть пусто".

### t09  ·  —  ·  drop
- **client:** lectricebikes   **source:** clearfeed   **repetitive:** true
- **root cause:** CS manager hit a side-image-disappears bug on later quiz questions — the image only shows in the "no product matched yet" state and vanishes once the quiz has matched products.
- **current solution:** Engineer patching quiz image logic; interim workaround = set the picture on the first question step.
- **pain:** Side image won't show on later steps, blocking client preview before a call.
- **drop reason:** Bug in the standalone **Quizzes** product (its own campaign type), not a pop-up/inline-block/reco-widget mechanic.

### t10  ·  Missing feature  ·  keep  (subagent said Custom code — reconciled, see note)
- **client:** lucyandyak   **source:** slack (#csm-support)   **repetitive:** true
- **root cause:** As a CSM reviewing a newly-launched client's reco widgets, I find the same product shown multiple times as separate colour variants because the reco engine dedupes at SKU level, not parent-product, and has no native swatch rendering — so the fix is hand-coded, not a config toggle. Separately, the site fires both a signup popup AND a modal on one visit because there's no mutual-exclusion/priority rule.
- **current solution:** No native fix — CSM tells AM to reach out to Gleb / use the internal "claude skill" to hand-code dedupe + swatches. Popup+modal overlap only flagged as a callout, no fix yet.
- **pain:** "Until we stop displaying repeats of the same product… that's really going to limit performance"; plus popup+modal at once.
- **secondary cause (flagged, not separately counted):** popup↔modal no mutual-exclusion rule (Missing feature) — promote to its own registry cause if it recurs with a dedicated ticket.

---

## Custom-code mechanics — cluster enrichment (omega lower bound)

60 mechanics with custom code created this week. Enriched at the **pattern** level (sampled), since the count is the metric and the reasons cluster. Buckets: html/css 58 · targeting 8 · integration 10.

### CC-A · Hand-authored reco-widget card markup  ·  Custom code
- **mechanics:** ~27 reco-widget variants w/ custom html/css — **zone3 ×16** (59519–59553), Deako (59514, 59528), drhonow (59592), Lucyandyak (58503, 58509), ilovelinen (59566), sarahssilks (59561), selkirkcom (59598), tac (59574), bedkingdom (58500).
- **evidence:** zone3 variant 59519 = 2.6 KB html / 11.7 KB css of EJS card-render logic (`resolveAttr`, `getUniqueValue` dedupe helpers), differs from its template.
- **root cause:** The reco widget's product-card layout / dedup / swatch rendering can't be done in the template UI, so CSMs hand-author EJS/HTML/CSS per widget. **Same product gap as t05/t10** (reco display: dedup colour variants, swatches, layout) — these mechanics are the hand-coded workaround.

### CC-B · Custom JS targeting for GTM/consent gating  ·  Custom code
- **mechanics:** marathonbet-eu ×8 pop-ups (59531–59536, 59589, 59590), all html/css + targeting JS.
- **evidence:** targeting rule `{"field":"js","operator":"$exec","value":"return !!(gtmHandler.popmechanic?.isPopupAllowed());"}`.
- **root cause:** Client needs display gated on a GTM/consent flag the targeting UI can't express → a custom `$exec` JS rule, repeated across every popup.

### CC-C · Integration JS to place widgets into Shopify theme slots  ·  Custom code
- **mechanics:** Deako (minicart recommendation panel), drhonow (`shopify-section… product-recom`), Lucyandyak (`shopify-section… related-products`, on_render/on_show), urbanarmorgear (`.popmechanic-widget`).
- **root cause:** No native anchor/slot to place a reco widget into a specific theme section / cart drawer → on_render DOM injection. The classic cart-drawer/slot gap.

### CC-D · Integration JS for API operations & add-to-cart  ·  Custom code
- **mechanics:** BlueQ (`maestra async RefParamUpdate` — referral params), Limevizio (`mindbox sync getname` + `PopMechanic.show`), sarahssilks (`maestraShopifyAddToCart`), AlmondCow (click-outside handling), drhonow (FR localization on_show).
- **root cause:** Popups need to call Maestra/Shopify operations (referral capture, personalize-by-name, add-to-cart, localization) not exposed as built-in popup actions → hand-written integration JS.

### CC-E · Hand-authored pop-up / inline-block markup  ·  Custom code
- **mechanics:** the html/css tail — betboom ×3, 1winstore ×2, BookDepot ×2, Onethrive ×2, hoeglcom, natvbasics, Nationsphotolab, SvahaUSA, pescatoreny, 4ocean, zone3 pop-up 59570, Lucyandyak inline 59544/59545, plus html/css on the AlmondCow/BlueQ/Limevizio popups.
- **root cause:** The pop-up/inline template library doesn't cover the desired design → hand-authored variant HTML/CSS. The broad, long-tail baseline of custom-code toil.
