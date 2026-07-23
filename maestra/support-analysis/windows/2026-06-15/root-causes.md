# root causes — week 2026-06-15 (ISO 2026-W25)

Stage 3. Kept support entries clustered + reconciled. `[matched: id]` = seen in another week; `[new: id]` = first appearance. Custom-code mechanic counts are omega lower bounds and overlap across causes.

**Week totals:** support tickets kept 12 (Bug 6 · Missing feature 4 · Custom code 2 · How-to 0 · New client setup 0) · custom-code mechanics 64 (html/css 59 · targeting 8 · integration 18). Heaviest support week of the four.

---

## Bug

- **Phone-format validation missing countries** [new: rc-bug-phone-format-validation] — 1 (t01, hoeglcom) · form rejected valid local numbers; **fixed same-day (GH #1071)**.
- **Checkout reco widget settings ignored** [new: rc-bug-checkout-reco-settings-ignored] — 1 (t04, Deako) · Maestra-side counts/limits have no effect (Shopify app controls checkout recs).
- **Geotargeting country-exclusion ignored** [new: rc-bug-geotargeting-exclusion-ignored] — 1 (t05, svahausa) · one-off; fixed platform-side in hours.
- **Reco carousel breaks on specific Android devices** [new: rc-bug-reco-carousel-mobile-device] — 1 (t06, zone3) · not reproducible internally; unresolved a month.
- **Popup rotation degrades under traffic surge** [new: rc-bug-popup-rotation-perf-under-load] — 1 (t07, magnumbikes) · feature disabled as a stopgap; no capacity fix.
- **Popup image padding differs desktop vs mobile** [new: rc-bug-popup-image-responsive-padding] — 1 (t10) · % image size doesn't inherit container on mobile.

## New client setup

_None this week._

## Missing feature

- **No self-serve/bulk reco template upgrade** [matched: rc-mf-reco-template-upgrade-selfserve] — 1 (s01, Hawaii Coffee) · **now recurring (also W26)**; engineer migrates each widget by hand.
- **No native Yotpo ratings integration** [new: rc-mf-reco-yotpo-ratings-integration] — 1 (t03, drhonow) · reco ratings fetched client-side (lag); needs a backend integration.
- **No per-device CSS selector for widget placement** [new: rc-mf-per-device-placement-selector] — 1 (t08, lucyandyak) · one selector per form → two forms per widget.
- **Bundle reco: no discount-only-when-added-from-rec** [new: rc-mf-reco-bundle-discount-on-add] — 1 (s02) · can't replicate Rebuy-style discounted bundling.

## Custom code

- **Custom DOM-dependent widget code is fragile** [matched: rc-cc-dom-dependent-targeting-breaks] — 1 (t02, lucyandyak) · **now recurring (also W26)**; notify-in-stock button JS races with storefront DOM, flickers; per-client tuning.
- **Custom-code editor rejects `<script>` tags** [new: rc-cc-editor-no-script-tag] — 1 (t09, foodcycler) · AI-generated pop-up code silently fails to save; must use CSS-driven visibility.

## Custom-code mechanics (track, no tickets)

- reco markup [rc-mf-reco-variant-dedup] 16 · pop-up/inline template gap [rc-cc-popup-inline-template-gap] 35 · targeting [rc-cc-targeting-gtm-gating] 8 · integration ops [rc-cc-popup-integration-ops] 18 · theme-slot injection [rc-mf-reco-theme-slot-injection] 5.
