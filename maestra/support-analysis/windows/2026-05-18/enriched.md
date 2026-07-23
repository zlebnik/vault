# enriched — week 2026-05-18 (ISO 2026-W21) — backfill

Stage 2. 2 support (both kept, Custom code) + custom-code clusters. 0 Slack personalization threads.

### t01 · Custom code · natvbasics → rc-cc-popup-inline-template-gap [matched — first ticket]
- **root cause:** A custom multi-screen "click an interest → auto-advance" pop-up isn't supported by standard templates, so the AI build skill fell back to a button-template + script version that silently breaks analytics tracking and native country-by-IP passing.
- **current solution:** responder manually rebuilding on the correct native fullscreen/data-collection template (no scripts); unfinished at close.
- **repetitive:** true · **pain:** standard templates don't cover multi-screen data-collection pop-ups → script workaround breaks analytics/geo.

### t02 · Custom code · Idaka golf → rc-cc-popup-integration-ops [matched — first ticket]
- **root cause:** Reco widget "add to cart" only updates the cart count, not the custom theme's cart-drawer refresh, so it needs per-theme reverse-engineered custom JS.
- **current solution:** engineer reverse-engineered the theme JS, hand-wrote custom JS (copyable per site, but each theme needs bespoke work).
- **repetitive:** true · **pain:** add-to-cart didn't refresh the cart drawer; per-theme custom-code under near-churn time pressure.

## Custom-code mechanics (omega lower bound)
59 mechanics — reco markup [rc-mf-reco-variant-dedup] 4 · popup/inline template gap [rc-cc-popup-inline-template-gap] 40 · targeting [rc-cc-targeting-gtm-gating] 9 · integration ops [rc-cc-popup-integration-ops] 18 · theme-slot [rc-mf-reco-theme-slot-injection] ~3.
