# root causes — week 2026-07-06 (ISO 2026-W28)

Stage 3. Kept support entries clustered into distinct causes and grouped. First run → every cause is `[new]` in the registry. Custom-code mechanic counts are omega lower bounds and overlap across custom-code causes (see `custom_code_totals` in the registry for exact bucket figures).

**Week totals:** support tickets kept 6 (Bug 2 · Missing feature 3 · Custom code 1 · New client setup 0) · custom-code mechanics 60 (html/css 58 · targeting 8 · integration 10).

---

## Bug

### Reco A/B "replace content" variants race on the same slot → widget intermittently empty  [new: rc-bug-reco-replace-content-race]
- tickets: 1 (t08) · client lucyandyak
- Two reco variants + a legacy site block replace the same DOM node; load order decides who wins. Known recurring failure mode. Current fix: manual server-side config per case.

### Reco-widget copy is slow / errors  [new: rc-bug-reco-widget-copy-perf]
- tickets: 1 (t03) · client lucyandyak
- Duplicating a reco-widget errors and finishes only after an extreme delay (backend perf). Engineering pushed a speed-up.

## New client setup

_None this week._

## Missing feature

### Reco widget repeats colour variants — SKU-level dedup, no swatches, no self-serve dedupe  [new: rc-mf-reco-variant-dedup]
- tickets: 2 (t05, t10) · mechanics: ~26 (hand-coded reco markup) · clients lucyandyak, jolyn, zone3 + reco tenants
- **The week's hot spot.** Recommendation lists repeat the same product per colour because dedup is SKU-level; there's no native swatch rendering and no account-wide self-serve dedupe. The large zone3/reco custom-code cluster (CC-A) is the hand-coded workaround for exactly this gap. Also surfaced on the #csm-support review of Lucy & Yak (t10).

### No native slot to place a reco/widget into a Shopify theme section / cart drawer  [new: rc-mf-reco-theme-slot-injection]
- tickets: 0 · mechanics: 4 (integration JS) · clients Deako, drhonow, Lucyandyak, urbanarmorgear
- Placement requires hand-written on_render DOM injection. Cart-drawer/slot gap.

### Pop-up can't show a unique per-customer promo code on its final screen  [new: rc-mf-popup-per-customer-promocode]
- tickets: 1 (t04) · client zone3
- Pop-up mechanic only renders a single universal code; no per-visitor code generation/injection.

> Secondary (flagged, not separately counted this week): popup↔modal have no mutual-exclusion/priority rule, so both can fire on one visit (from t10). Promote to its own cause if it recurs with a dedicated ticket.

## Custom code

### Client-owned custom JS breaks and silently zeroes reco eligibility  [new: rc-cc-client-owned-js-breaks-reco]
- tickets: 1 (t06) · client lucyandyak
- A broken client stock-status script marked all products out-of-stock → reco returned nothing, first read as a Maestra bug. Support toil = triage to rule out the engine.

### Custom JS targeting for GTM/consent gating  [new: rc-cc-targeting-gtm-gating]
- tickets: 0 · mechanics: 8 · client marathonbet-eu
- `$exec` rule `return !!(gtmHandler.popmechanic?.isPopupAllowed())` repeated across every pop-up; targeting UI can't express GTM/consent gating.

### Pop-up integration JS for API ops & add-to-cart  [new: rc-cc-popup-integration-ops]
- tickets: 0 · mechanics: 6 · clients BlueQ, Limevizio, sarahssilks, AlmondCow, drhonow, (Demonstration=test)
- Referral capture, personalize-by-name, add-to-cart, localization — not built-in pop-up actions, so hand-written integration JS.

### Hand-authored pop-up / inline-block markup (template library gap)  [new: rc-cc-popup-inline-template-gap]
- tickets: 0 · mechanics: 24 · clients betboom, 1winstore, BookDepot, Onethrive + long tail
- Baseline custom-code toil: the template library doesn't cover the desired design, so CSMs hand-author variant HTML/CSS.
