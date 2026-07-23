# enriched — week 2026-06-22 (ISO 2026-W26, Mon 22 – Sun 28 Jun)

Stage 2. Support entries from full threads (proportionate depth); custom-code from DB cluster sampling.

- **Support candidates:** 7 → **kept 7** + 1 Slack **How-to** (s01) = 8. No drops.
- **Kept groups:** Missing feature 5 · Bug 1 · Custom code 1 · How-to 1 · New client setup 0.
- **Custom-code mechanics:** 95 (omega lower bound) — html/css 94 · targeting 19 · integration 26. Partition: reco html 23 · popup/inline html 52 · targeting 19 · integration-only 1.

---

## Support entries

### t01 · Missing feature · Aiby
- **root cause:** As a client building personalized pushes/emails, I need a computed property for "top value of an event's custom field over N days" (e.g. most-frequent contentType), but computed properties can only aggregate over products/orders, not arbitrary custom event fields — so I can't target by favorite content category without a large product-side rework.
- **current solution:** none — declined as too large; suggested the client add a dedicated event. Closed won't-fix, logged to backlog.
- **repetitive:** true · **pain:** can't personalize by favorite content category (computed props don't aggregate custom event fields).

### t02 · Missing feature · jolyn
- **root cause:** As a marketer, I couldn't create a new custom recommendation algorithm because my account silently hit a hard cap on active custom-recommendation mechanics, with no self-serve visibility into the limit or which mechanics are stale.
- **current solution:** Support raised the cap (5→10) in the backend and identified two stale (StoppedDueToDisuse) mechanics to delete.
- **repetitive:** true · **pain:** undisclosed per-account mechanic limit, no self-serve way to see/raise it or spot unused mechanics.

### t03 · Bug · jolyn  →  matches rc-bug-reco-replace-content-race
- **root cause:** As a marketer A/B-testing two reco widgets on the same page selector in "replace content" mode, the two widgets continuously overwrite each other in a loop, causing visible jumping/flickering.
- **current solution:** Support isolated each with test targeting, then had the client adjust targeting so they don't run concurrently on the same selector.
- **repetitive:** true · **pain:** widget flickers on the live site right before a test launch; urgent same-day fix. **Same cause as W28's replace-content race.**

### t04 · Missing feature · hawaiicoffee
- **root cause:** As a CS manager, I need reco-widgets upgraded to a newer template without losing analytics history, but there's no self-serve in-place template upgrade (engineer must hand-edit the backend), and no per-device width override (shared desktop/mobile).
- **current solution:** Engineer manually migrated each widget preserving IDs/analytics, hand-carried the client's CSS/HTML tweaks, and hardcoded a per-device width (100%/90%).
- **repetitive:** true · **pain:** template upgrade + basic per-device sizing require bespoke engineering, risking lost analytics.

### t05 · Custom code · lucyandyak
- **root cause:** As a support engineer, I keep re-patching an inline-block's targeting (block 57525, outlet pages) because it relies on custom code matching specific DOM elements, and the client repeatedly changes their page markup — silently breaking targeting until someone diffs against a known-good block and rewrites the matcher per region (US vs UK).
- **current solution:** Compared against working block 57420, rewrote/simplified the custom targeting code for US, then again for UK.
- **repetitive:** true · **pain:** targeting silently breaks on client markup changes; only a manual per-region custom-code rewrite fixes it.

### t06 · Missing feature · urbanarmorgear
- **root cause:** As a merchant running a lead-gen pop-up, I silently lose a new lead when a returning visitor enters a different email but the same phone as an existing phone-unconfirmed profile — Maestra blocks the merge (anti-takeover) but then drops the whole submission with no error, no profile-history record, no email-search trace.
- **current solution:** none — confirmed as intentional anti-takeover behavior (~2% rate, 14/656 in 7 days); potential fixes discussed, none shipped.
- **repetitive:** true · **pain:** real leads vanish with zero trace on a phone collision.

### t07 · Missing feature · hawaiicoffee
- **root cause:** As a CRM manager setting up a BigCommerce reco-widget, the dropdown variant selector (size/colour) shows nothing because the BigCommerce feed and Maestra's product/operations API don't carry per-SKU variant data — no data source without a hand-built custom feed field.
- **current solution:** No OOTB fix; feed team must add a custom `variants=[…]` JSON field per product. Support flagged "variants missing from operations response" as a recurring custom-code driver (logged to Notion).
- **repetitive:** true · **pain:** no size/colour variant picker in the reco widget on BigCommerce without commissioning custom feed enrichment.

### s01 · How-to · Slack #csm-support  →  rc-howto-reco-preset-purchased-exclusion
- **root cause:** CSM (Julia) needed to confirm which reco presets exclude already-purchased products — answer: customer-keyed presets do (for identified customers), product-anchored presets don't. A product-knowledge clarification, not a defect/gap.
- **current solution:** Answered in-thread by engineering (Paul/Eugenia). Indicates a docs/clarity gap.
- **counted in:** the **How-to** group (added as the 5th group after W26).

---

## Custom-code mechanics — cluster enrichment (omega lower bound)

95 mechanics. Enriched at the pattern level.

- **CC-A · Hand-authored reco-widget markup → rc-mf-reco-variant-dedup** — **23** reco-widget html/css (drhonow, hawaiicoffee, lectricebikes, CopenhagenLiving, Jolyn, BlueQ, bokksu, ispace, natvbasics, pescatoreny reco variants).
- **CC-B · Custom JS targeting the UI can't express → rc-cc-targeting-gtm-gating** — **19** (marathonbet ×14 GTM; Movavicom ×2 language; Jolyn ×2 **Shopify currency**; BlueQ ×1 **1s delay**). Cause keeps broadening.
- **CC-C · Integration JS to place/adjust widgets in the theme → rc-mf-reco-theme-slot-injection** — ~8 (drhonow ×6 `shopify-section` reco injection; lectricebikes init-retry DOM polling).
- **CC-D · Integration JS for API ops, add-to-cart, form handling → rc-cc-popup-integration-ops** — ~18 (hawaiicoffee BigCommerce add-to-cart; ispace viber-unsub + price formatting; SvahaUSA persona API; magnumbikes form-submit guard; natvbasics goal tracking; Sena email capture + PopMechanic.show; Lucyandyak newsletter prefs; atlantacutlery/Jolyn style injection; bokksu image).
- **CC-E · Hand-authored pop-up / inline-block markup → rc-cc-popup-inline-template-gap** — **52** (betboom ×12, marathonbet base markup, pochtoy, Clientsen, Monkeysports, + long tail).
