# enriched — week 2026-06-15 (ISO 2026-W25, Mon 15 – Sun 21 Jun)

Stage 2. Support from full threads (proportionate); custom-code from DB cluster sampling.

- **Support candidates:** 12 (10 ClearFeed + 2 Slack) → **kept 12** (no drops).
- **Kept groups:** Bug 6 · Missing feature 4 · Custom code 2 · How-to 0 · New client setup 0.
- **Custom-code mechanics:** 64 (omega lower bound) — html/css 59 · targeting 8 · integration 18. Partition: reco html 16 · popup/inline html 35 · targeting 8 · integration-only 5.
- **Matches:** s01 → `rc-mf-reco-template-upgrade-selfserve` (now recurring w/ W26); t02 → `rc-cc-dom-dependent-targeting-breaks` (now recurring w/ W26).

---

## Support entries

### t01 · Bug · hoeglcom  →  rc-bug-phone-format-validation [new]
- **root cause:** Inline-block phone-capture form rejected valid local numbers (e.g. Austrian) because the platform's phone-format list didn't include that country's format.
- **current solution:** Engineer (Eugenia) filed GH #1071 and **shipped a fix within ~1 day**; client confirmed.
- **repetitive:** true · **pain:** couldn't collect valid phone numbers → blocked lead capture.

### t02 · Custom code · lucyandyak  →  rc-cc-dom-dependent-targeting-breaks [matched]
- **root cause:** "Notify me when back in stock" button visibility is custom JS reacting to storefront variant-select events; it races with the store's own DOM (sold-out, add-to-cart) → flickers, shows before a size is selected.
- **current solution:** Gleb hand-patched repeatedly (targeting, delay, no-variant case); flagged remaining edge cases; same flicker resurfaced on a new client.
- **repetitive:** true · **pain:** button flickers/premature; bespoke tuning per client, recurs on rollouts.

### t03 · Missing feature · drhonow  →  rc-mf-reco-yotpo-ratings-integration [new]
- **root cause:** Reco widget needs star-ratings from the client's Yotpo, but there's no native backend Yotpo integration into the feed/custom fields — so it calls Yotpo client-side, causing a visible ~3s load lag.
- **current solution:** Hand-patched the widget to read ratings from custom fields (popmechanic-rating snippet); a proper Yotpo backend integration is queued (built once before for furniturefair).
- **repetitive:** true · **pain:** rating widget lags on load (live Yotpo fetch).

### t04 · Bug · Deako  →  rc-bug-checkout-reco-settings-ignored [new]
- **root cause:** Checkout-recommendations widget ignores Maestra-side item-count/limit settings because that config isn't wired through for the checkout placement — it's controlled on the Shopify app side.
- **current solution:** Told the client to configure counts/limits via the Shopify app instead.
- **repetitive:** true · **pain:** Maestra widget config silently has no effect on checkout recs.

### t05 · Bug · svahausa  →  rc-bug-geotargeting-exclusion-ignored [new]
- **root cause:** Country-exclusion geotargeting ("None of: United States") was ignored/miscomputed → campaign showed to excluded US visitors.
- **current solution:** Engineering **fixed the bug** platform-side within hours; client used a temporary test-preview URL rule while debugging.
- **repetitive:** false · **pain:** shipping banner shown to explicitly-excluded US visitors for part of a day.

### t06 · Bug · zone3  →  rc-bug-reco-carousel-mobile-device [new]
- **root cause:** Reco-widget carousel mobile rendering breaks on specific Android devices (Samsung S25, Fold) — left card slides off-screen — and engineering can't reproduce without those exact devices.
- **current solution:** none — unresolved a month later; asking client for a screen recording.
- **repetitive:** true · **pain:** client-facing layout bug unfixed for a month; no device to repro; can't commit a deadline.

### t07 · Bug · magnumbikes  →  rc-bug-popup-rotation-perf-under-load [new]
- **root cause:** Popups rotated near-unusably slowly because a traffic surge overloaded the popup-serving/rotation feature, degrading all popups site-wide.
- **current solution:** Support disabled the overloaded feature live; recovery ~5 min. No capacity/rate-limit fix.
- **repetitive:** true · **pain:** popups unusable during a traffic spike; manual feature-kill to restore.

### t08 · Missing feature · lucyandyak  →  rc-mf-per-device-placement-selector [new]
- **root cause:** A widget form supports only one attach CSS selector, but sites use different DOM/selectors on desktop vs mobile — so CSMs build two separate forms per widget to vary placement by device.
- **current solution:** Workaround = two forms per widget. Logged as a product improvement (Notion effort doc).
- **repetitive:** true · **pain:** duplicate widget setup for nearly every site → manual overhead.

### t09 · Custom code · foodcycler  →  rc-cc-editor-no-script-tag [new]
- **root cause:** Couldn't save AI-generated pop-up custom code because it included a `<script>` tag (unsupported/stripped by the custom-code editor) and CSS that depended on that script to reveal the first screen.
- **current solution:** Told the user to remove `<script>` and set `display:block` in CSS instead; user re-prompted their AI for compliant code. No product change.
- **repetitive:** true · **pain:** AI-generated code silently violates an unstated no-`<script>` constraint → "why won't this save".

### t10 · Bug · ?  →  rc-bug-popup-image-responsive-padding [new]
- **root cause:** Same popup image renders with different padding on desktop vs mobile because on mobile the image doesn't inherit its `popmechanic-image-container` size when set as a percentage.
- **current solution:** none confirmed — support suggested an explicit width; thread went unanswered.
- **repetitive:** true · **pain:** inconsistent popup image sizing across breakpoints; trial-and-error, no documented fix.

### s01 · Missing feature · Hawaii Coffee (slack)  →  rc-mf-reco-template-upgrade-selfserve [matched]
- **root cause:** No self-serve/bulk way to re-template a reco widget on the backend — an engineer must migrate each one.
- **current solution:** CS clones the old widget; engineer (Gleb) migrates it manually, one at a time.
- **repetitive:** true · **pain:** CS waited ~1 day just to know whether to keep building on the old template. **Same cause as W26 t04.**

### s02 · Missing feature · ? (slack)  →  rc-mf-reco-bundle-discount-on-add [new]
- **root cause:** For a Rebuy-style bundle reco, a discount can't be restricted to trigger only when the product was added via the recommendation widget.
- **current solution:** Pointed to 3 existing bundle setups to copy (Bokksu, Sena, BlueQ); the discount-on-add behavior itself is unsupported.
- **repetitive:** true · **pain:** can't fully replicate Rebuy-style discounted bundling.

---

## Custom-code mechanics — cluster enrichment (omega lower bound)

64 mechanics, same recurring patterns:
- **rc-mf-reco-variant-dedup** — 16 reco-widget html/css (Lucyandyak, bokksu, ilovelinen, pescatoreny, Allegianteyewear).
- **rc-cc-popup-inline-template-gap** — 35 popup/inline html/css (Lucyandyak, magnumbikes, ispace, Deako, hawaiicoffee, betboom, 1winstore + tail).
- **rc-cc-targeting-gtm-gating** — 8 (marathonbet ×6 GTM, Movavicom ×2 language).
- **rc-cc-popup-integration-ops** — ~18 (Budsies ×5 all-integration, Lucyandyak, ilovelinen, bokksu, AlmondCow, Foodcycler, BlueQ).
- **rc-mf-reco-theme-slot-injection** — ~5 (theme/DOM injection subset of the integration JS).
