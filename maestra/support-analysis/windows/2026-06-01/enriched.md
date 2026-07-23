# enriched — week 2026-06-01 (ISO 2026-W23, Mon 01 – Sun 07 Jun)

Stage 2. Support from full threads (proportionate); custom-code from DB cluster sampling.

- **Support:** 10 (ClearFeed) → **kept 10** (no drops; 0 Slack personalization threads).
- **Kept groups:** How-to 4 · Bug 4 · Missing feature 2 · Custom code 0.
- **Custom-code mechanics:** 70 (omega lower bound) — html/css 68 · targeting 17 · integration 17.
- **Matches:** t03 → reco-report accuracy; t06 → reco-needs-richer-feed-data; t07 → reco-mechanic-cap (all now recurring).

---

## Support entries

### t01 · How-to · copenhagenliving → rc-howto-popup-form-config [new]
- Pop-up form couldn't collect the name because fields must be added explicitly per variant. Support clarified; no product change. rep.

### t02 · How-to · lucyandyak → rc-howto-popup-form-config [new]
- CRM manager thought email is only captured on submit; **it's already captured on close**. Misunderstanding of existing behaviour, escalated urgently. one-off.

### t03 · Bug · Jolyn → rc-bug-reco-report-assisted-revenue-double-count [matched, broadened]
- Reco BI dashboard revenue silently drifted (April $43K→$4.6K, March blank): custom data mart broke on migration + a 30-day recalc bug + a future-click attribution bug (~10% inflation). Engineer manually recomputed + fixed attribution; 30-day regression **still pending**. one-off.

### t04 · How-to · lucyandyak → rc-howto-reco-silent-misconfig [new]
- Product-to-product reco returned empty because the widget's **external system wasn't selected** → no product mapping, no error surfaced. Support set it. rep.

### t05 · Bug · natvbasics → rc-bug-popup-editor-hidden-field [new]
- Editor hid the name/systemName field for non-input elements → stray Russian placeholder stuck in a live pop-up, uneditable. Fixed via FE MRs + migration. one-off.

### t06 · Missing feature · Monkeysports → rc-mf-reco-no-variant-data [matched, broadened]  (subagent: Bug → MF)
- Reco widget wants a second/alt product image, but Magento's gallery model doesn't expose it consistently → only partial, hand-dug coverage. Broadens the "reco needs richer feed data (variants, alt images)" cause. rep.

### t07 · Missing feature · lucyandyak → rc-mf-reco-mechanic-limit-visibility [matched]
- Hit the hardcoded **per-algorithm instance cap** (multi-brand needs one per brand); support bumped +1 for all four algo types. No self-serve. rep.

### t08 · Bug · lucyandyak → rc-bug-reco-variant-selector-broken [new]
- Checkout reco widgets: variant selection doesn't work in either, one also fails to show the product name — a rendering-logic bug. Escalated to the widget engineer; fixed ~1 month later. one-off.

### t09 · How-to · sarahssilks → rc-howto-reco-silent-misconfig [new]
- Reco "Add to cart" button looked broken because a required setting wasn't enabled; no error. Support flipped it. rep. **Same silent-misconfig pattern as t04.**

### t10 · Bug · Pescatoreny → rc-bug-reco-update-pipeline-stuck [new]
- Reco feed stuck in "updating" 1.5h+ (serving stale items); no alerting/self-serve. Engineer manually intervened; cause undocumented. one-off.

---

## Custom-code mechanics — cluster enrichment (omega lower bound)

70 mechanics, same recurring patterns:
- **rc-mf-reco-variant-dedup** — 21 reco html/css (Lucyandyak, Monkeysports, pescatoreny, BlueQ, drhonow, bokksu reco).
- **rc-cc-popup-inline-template-gap** — 30 popup/inline html/css (pescatoreny, astons, Movavicom + tail).
- **rc-cc-targeting-gtm-gating** — 17 (Movavicom ×~14 language gating, marathonbet ×2 GTM).
- **rc-cc-popup-integration-ops** — 17 (astons, Lucyandyak, lectricebikes, bokksu).
- **rc-mf-reco-theme-slot-injection** — ~2 (theme/DOM injection subset).
