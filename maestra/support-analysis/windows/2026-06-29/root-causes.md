# root causes — week 2026-06-29 (ISO 2026-W27)

Stage 3. Kept support entries clustered + reconciled into the registry. `[matched: id]` = same cause seen in another week; `[new: id]` = first appearance. Custom-code mechanic counts are omega lower bounds and overlap across causes.

**Week totals:** support tickets kept 8 (Bug 4 · Missing feature 2 · Custom code 2 · New client setup 0) · custom-code mechanics 63 (html/css 62 · targeting 16 · integration 11).

---

## Bug

### Targeting reach = 0 for API-triggered pop-ups/quizzes  [new: rc-bug-targeting-reach-api-triggered]
- tickets: 1 (t09) · clients SvahaUSA, hawaiicoffee, Sena · **repetitive**
- A fix in the end-of-May Quizzes UI release also killed the targeting event for API/command-triggered widgets (now only fires on button clicks). Under investigation (Gleb), no workaround.

### Pop-up editor lost unsaved edits  [new: rc-bug-popup-editor-unsaved-guard]
- tickets: 1 (t07) · repetitive · **fixed in-week via MR !8819** (Save/Leave/Cancel guard). Should not recur.

### Adding an A/B test errored (backend migration)  [new: rc-bug-popup-ab-migration]
- tickets: 1 (t03) · one-off · migration left A/B config broken; corrected server-side.

### Pop-up SMS auth code intermittently failed  [new: rc-bug-popup-sms-auth-intermittent]
- tickets: 1 (t08) · one-off · coolibar · worked on retest, not reproduced.

## New client setup

_None this week._

## Missing feature

### No native theme-aware placement (slot / header / cart drawer)  [matched: rc-mf-reco-theme-slot-injection]
- tickets: 1 (t01, zone3) · mechanics: 4 · **first support ticket for this cause** (was custom-code-only in W28)
- Placing a text bar in Zone3's Shopify header left a white strip needing a hand-CSS margin fix; no self-serve placement. Evidence: zone3 integration mechanics 58388/58390 (`#header-group` fix), CopenhagenLiving mobile-slider fix.

### Reco widget limited to one algorithm per slot  [new: rc-mf-reco-single-algo-per-slot]
- tickets: 1 (t05, selkirkcom) · repetitive · client wanted a second cross-sell algorithm; engineer had to enable it (no self-serve).

### Reco widget repeats colour variants (dedup/swatches)  [matched: rc-mf-reco-variant-dedup]
- tickets: 0 · mechanics: 10 (hand-authored reco markup) · the reco-display gap continues as custom-code toil; no new ticket this week (the Lucy&Yak thread counted in W28).

## Custom code

### No lint/validation gate on custom code → ships broken  [new: rc-cc-no-custom-code-guardrails]
- tickets: 2 (t02 limevizio `debugger;` in prod; t04 atlantacutlery bespoke loyalty widget with silent config failures) · repetitive
- Related to `rc-cc-client-owned-js-breaks-reco` — candidates to merge if the pattern persists.

### Custom JS targeting (GTM/consent, language, business-hours)  [matched: rc-cc-targeting-gtm-gating]
- tickets: 0 · mechanics: 16 (marathonbet ×14 GTM; Movavicom language; Clientsen business-hours) · broadened from GTM-only.

### Pop-up / inline-block template gap → hand-authored markup  [matched: rc-cc-popup-inline-template-gap]
- tickets: 0 · mechanics: 36 · long-tail baseline (Foodcycler, SvahaUSA, betboom, audiogon, Onethrive…).

### Integration JS for API ops & add-to-cart  [matched: rc-cc-popup-integration-ops]
- tickets: 0 · mechanics: 7 · Lucyandyak add-to-cart/title capture, AlmondCow click handling, bokksu image.
