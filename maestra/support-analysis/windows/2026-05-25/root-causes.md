# root causes — week 2026-05-25 (ISO 2026-W22)

Stage 3. Kept support entries clustered + reconciled. `[matched: id]` = seen in another week; `[new: id]` = first appearance. Custom-code mechanic counts are omega lower bounds and overlap across causes.

**Week totals:** support tickets kept 4 (Bug 2 · Missing feature 1 · How-to 1 · Custom code 0 · New client setup 0) · custom-code mechanics 43 (html/css 40 · targeting 16 · integration 13). Quiet support week; all 4 tickets are reco.

---

## Bug

- **Reco op called even when algorithm weight = 0** [new: rc-bug-reco-zero-weight-algo-op] — 1 (t02, Jolyn) · multi-algorithm checkout widget fired the reco operation at weight 0 (default) → failed ops. Fixed same-day.
- **Reco min-product-count hide broken on selector-embed** [new: rc-bug-reco-min-count-selector-embed] — 1 (t03, Bokksu) · "hide if below minimum products" failed when embedded via CSS selector (not data-attribute). Fixed same-day.

## New client setup

_None this week._

## Missing feature

- **Reco widget visual customization not self-serve** [matched: rc-mf-reco-widget-visual-customization] — 1 (t01, Selkirk) · "complete the look" card (current product + 3 more, one per slot) needs a custom-built widget composing 3 algorithms + JS slide-out; native reco does one product/slot. **Now recurring (also W24).**

## How-to

- **Reco A/B participant counting (eligibility vs render)** [new: rc-howto-reco-ab-participant-counting] — 1 (t04, Lectric eBikes) · reported split looks skewed (70/30 vs 50/50) because control counts eligibility while variant counts only rendered devices (30–50% attrition). Support explained; no reporting change. (Fix could be symmetric counting.)

## Custom code

_None as a distinct group this week._

## Custom-code mechanics (track, no tickets)

- reco markup [rc-mf-reco-variant-dedup] 6 · pop-up/inline template gap [rc-cc-popup-inline-template-gap] 21 · targeting [rc-cc-targeting-gtm-gating] 16 (marathonbet GTM) · integration ops [rc-cc-popup-integration-ops] 13 (enlightenedequip referral) · theme-slot injection [rc-mf-reco-theme-slot-injection] 2.
