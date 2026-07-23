# root causes — week 2026-06-22 (ISO 2026-W26)

Stage 3. Kept support entries clustered + reconciled. `[matched: id]` = seen in another week; `[new: id]` = first appearance. Custom-code mechanic counts are omega lower bounds and overlap across causes.

**Week totals:** support tickets kept 8 (Missing feature 5 · Bug 1 · Custom code 1 · How-to 1 · New client setup 0) · custom-code mechanics 95 (html/css 94 · targeting 19 · integration 26).

---

## Bug

### Reco A/B "replace content" widgets flicker on the same selector  [matched: rc-bug-reco-replace-content-race]
- tickets: 1 (t03, jolyn) · **now recurring** (also W28) · two reco widgets in replace-content mode loop-overwrite each other on one selector → visible flicker. Fixed per-case by adjusting targeting so they don't run concurrently.

## New client setup

_None this week._

## Missing feature

### Computed properties can't aggregate custom event fields  [new: rc-mf-computed-props-custom-event-fields]
- tickets: 1 (t01, Aiby) · can't personalize by favourite content category; computed props only aggregate products/orders. Declined as too large, backlogged.

### Undisclosed reco-mechanic cap, no self-serve visibility  [new: rc-mf-reco-mechanic-limit-visibility]
- tickets: 1 (t02, jolyn) · hit a hidden hard cap on custom-reco mechanics; support raised it 5→10 and flagged stale ones.

### No self-serve reco-widget template upgrade / per-device width  [new: rc-mf-reco-template-upgrade-selfserve]
- tickets: 1 (t04, hawaiicoffee) · template upgrade (keeping analytics) + per-device width need bespoke engineering.

### Lead-gen pop-up silently drops submissions on phone collision  [new: rc-mf-popup-lead-dropped-phone-collision]
- tickets: 1 (t06, urbanarmorgear) · anti-takeover merge block drops the whole submission with no error/trace (~2% rate). Data loss.

### No product variant data for reco widget dropdowns  [new: rc-mf-reco-no-variant-data]
- tickets: 1 (t07, hawaiicoffee) · feed/operations API doesn't carry per-SKU variants → variant picker needs a hand-built custom feed field. Flagged recurring custom-code driver.

### No native theme-aware placement  [matched: rc-mf-reco-theme-slot-injection]
- tickets: 0 · mechanics: 8 (drhonow ×6 shopify-section injection + lectricebikes DOM polling).

### Reco widget repeats colour variants (dedup/swatches)  [matched: rc-mf-reco-variant-dedup]
- tickets: 0 · mechanics: 23 (reco hand-authored markup). The 3-week-running reco-display gap.

## Custom code

### Custom DOM-matching targeting breaks on client markup changes  [new: rc-cc-dom-dependent-targeting-breaks]
- tickets: 1 (t05, lucyandyak) · inline-block targeting relies on DOM-matching custom code; client markup edits silently break it; manual per-region rewrite each time.

### Custom JS targeting (GTM/consent, language, currency, delay, hours)  [matched: rc-cc-targeting-gtm-gating]
- tickets: 0 · mechanics: 19 · broadened again — Jolyn (Shopify currency), BlueQ (1s delay).

### Pop-up / inline-block template gap → hand-authored markup  [matched: rc-cc-popup-inline-template-gap]
- tickets: 0 · mechanics: 52 · biggest single bucket (betboom ×12 + long tail).

### Integration JS for API ops, add-to-cart, form handling  [matched: rc-cc-popup-integration-ops]
- tickets: 0 · mechanics: 18 · add-to-cart, viber/persona API, form guards, style injection.

## How-to

### Which reco presets exclude already-purchased products  [new: rc-howto-reco-preset-purchased-exclusion]
- tickets: 1 (s01, slack) · pure product-knowledge clarification (Julia↔Paul) → docs/clarity gap. First member of the How-to group (added after W26).
