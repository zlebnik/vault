# Root-cause registry

Accumulated across all weekly windows. Generated from `registry.json` by `build_dashboard.js` (stage 30/40) — **do not hand-edit**. Ranked by tickets, then mechanics. Custom-code mechanic counts are omega lower bounds and overlap across causes; exact per-window bucket figures live in `registry.json → custom_code_totals`.

**Windows covered:** 2026-04-13, 2026-04-20, 2026-04-27, 2026-05-04, 2026-05-11, 2026-05-18, 2026-05-25, 2026-06-01, 2026-06-08, 2026-06-15, 2026-06-22, 2026-06-29, 2026-07-06, 2026-07-13 (14). **Causes:** 60. **Recurring (≥2 weeks):** 18.

| # | Root cause | Group | Tickets | Mechanics | Weeks | Span |
|---|-----------|-------|--------:|----------:|------:|------|
| 1 | Reco widget visual customization not self-serve (CSS/arrows/carousel) | Missing feature | 8 | 0 | 6 | 04-20→06-08 |
| 2 | Reco A/B replace-content race → empty/flickering widget | Bug | 5 | 0 | 4 | 04-27→07-13 |
| 3 | Pop-up / inline-block template gap → hand-authored markup | Custom code | 3 | 476 | 14 | 04-13→07-13 |
| 4 | No native theme-aware placement (slot / header / cart drawer) | Missing feature | 3 | 45 | 14 | 04-13→07-13 |
| 5 | No lint/validation gate on custom code → ships broken | Custom code | 3 | 0 | 2 | 06-29→07-13 |
| 6 | Undisclosed reco-mechanic cap, no self-serve visibility | Missing feature | 3 | 0 | 3 | 04-27→06-22 |
| 7 | Pop-up partial-submission misses code-confirm dropoff (lost subs) | Bug | 3 | 0 | 3 | 05-11→07-13 |
| 8 | Reco widget repeats colour variants (SKU dedup, no swatches, no self-serve) | Missing feature | 2 | 194 | 14 | 04-13→07-13 |
| 9 | Migration left A/B config broken | Bug | 2 | 0 | 2 | 06-29→07-13 |
| 10 | No self-serve reco-widget template upgrade / per-device width | Missing feature | 2 | 0 | 2 | 06-15→06-22 |
| 11 | Custom DOM-matching targeting breaks on client markup changes | Custom code | 2 | 0 | 2 | 06-15→06-22 |
| 12 | No product variant data for reco widget dropdowns | Missing feature | 2 | 0 | 2 | 06-01→06-22 |
| 13 | No native Yotpo ratings integration for reco widgets | Missing feature | 2 | 0 | 2 | 06-15→07-13 |
| 14 | Popup image padding differs desktop vs mobile | Bug | 2 | 0 | 2 | 04-20→06-15 |
| 15 | Reco BI report double-counts assisted revenue (~3x AOV) | Bug | 2 | 0 | 2 | 06-01→06-08 |
| 16 | How-to: pop-up form field config + capture-on-close | How-to | 2 | 0 | 1 | 06-01 |
| 17 | How-to: reco widget silently broken when a setting isn't enabled | How-to | 2 | 0 | 1 | 06-01 |
| 18 | Legacy manual tracker install fails per theme layout / after rename | Custom code | 2 | 0 | 2 | 05-04→05-11 |
| 19 | As a merchandiser/CSM, my reco widget recommends out-of-stock or unpublished var | Missing feature | 2 | 0 | 1 | 07-13 |
| 20 | Integration JS for API ops, add-to-cart, form handling | Custom code | 1 | 211 | 14 | 04-13→07-13 |
| 21 | Pop-up can’t show a per-customer promo code | Missing feature | 1 | 0 | 1 | 07-06 |
| 22 | Reco widget limited to one algorithm per slot | Missing feature | 1 | 0 | 1 | 06-29 |
| 23 | Targeting reach = 0 for API-triggered widgets | Bug | 1 | 0 | 1 | 06-29 |
| 24 | Pop-up editor lost unsaved edits (fixed MR !8819) | Bug | 1 | 0 | 1 | 06-29 |
| 25 | Reco-widget copy slow / errors | Bug | 1 | 0 | 1 | 07-06 |
| 26 | Client-owned custom JS zeroes reco eligibility | Custom code | 1 | 0 | 1 | 07-06 |
| 27 | Pop-up SMS auth code intermittently failed | Bug | 1 | 0 | 1 | 06-29 |
| 28 | Computed properties can't aggregate custom event fields | Missing feature | 1 | 0 | 1 | 06-22 |
| 29 | Lead-gen pop-up silently drops submissions on phone collision | Missing feature | 1 | 0 | 1 | 06-22 |
| 30 | How-to: which reco presets exclude already-purchased products | How-to | 1 | 0 | 1 | 06-22 |
| 31 | Phone-format validation missing countries (fixed GH #1071) | Bug | 1 | 0 | 1 | 06-15 |
| 32 | Checkout reco widget settings ignored (Shopify-side) | Bug | 1 | 0 | 1 | 06-15 |
| 33 | Geotargeting country-exclusion ignored (fixed) | Bug | 1 | 0 | 1 | 06-15 |
| 34 | Reco carousel breaks on specific Android devices | Bug | 1 | 0 | 1 | 06-15 |
| 35 | Popup rotation degrades under traffic surge | Bug | 1 | 0 | 1 | 06-15 |
| 36 | No per-device CSS selector for widget placement | Missing feature | 1 | 0 | 1 | 06-15 |
| 37 | Custom-code editor rejects <script> tags | Custom code | 1 | 0 | 1 | 06-15 |
| 38 | Bundle reco: no discount-only-when-added-from-rec | Missing feature | 1 | 0 | 1 | 06-15 |
| 39 | Reco image optimization all-or-nothing (slow vs low quality) | Missing feature | 1 | 0 | 1 | 06-08 |
| 40 | No two-way sync of pop-up/segment data to Shopify | Missing feature | 1 | 0 | 1 | 06-08 |
| 41 | Pop-up editor hides name field → stuck placeholder in live pop-up | Bug | 1 | 0 | 1 | 06-01 |
| 42 | Checkout reco variant selector / product name not rendering | Bug | 1 | 0 | 1 | 06-01 |
| 43 | Reco update pipeline stuck (stale items, no alerting) | Bug | 1 | 0 | 1 | 06-01 |
| 44 | Reco op called even when algorithm weight = 0 (failed ops) | Bug | 1 | 0 | 1 | 05-25 |
| 45 | Reco min-product-count hide broken on selector-embed | Bug | 1 | 0 | 1 | 05-25 |
| 46 | How-to: reco A/B participant counting (eligibility vs render) | How-to | 1 | 0 | 1 | 05-25 |
| 47 | Pop-up heading text→textarea change broke all pop-ups | Bug | 1 | 0 | 1 | 05-04 |
| 48 | Reco widget custom JS silently vanishes (no audit log) | Bug | 1 | 0 | 1 | 05-04 |
| 49 | Reco widget backend load latency (slow CDP lookups) | Bug | 1 | 0 | 1 | 05-04 |
| 50 | Pop-up regional rendering bug | Bug | 1 | 0 | 1 | 04-27 |
| 51 | Reco ranking opaque + popularity lookback not tunable | Missing feature | 1 | 0 | 1 | 04-27 |
| 52 | Reco preview settings hash unresolvable in DB | Bug | 1 | 0 | 1 | 04-27 |
| 53 | Inline-block settings form missing localization | Bug | 1 | 0 | 1 | 04-20 |
| 54 | No explicit cart-based reco rules + fallback | Missing feature | 1 | 0 | 1 | 04-20 |
| 55 | No subscription-source attribution (pop-up vs registration) | Missing feature | 1 | 0 | 1 | 04-13 |
| 56 | As a client syncing a product feed, a single invisible/zero-width unicode charac | Bug | 1 | 0 | 1 | 07-13 |
| 57 | As a client, customers who click an in-app message's CTA aren't taken to the con | Bug | 1 | 0 | 1 | 07-13 |
| 58 | As a CSM troubleshooting a legacy client, the product feed is stale with no clea | Bug | 1 | 0 | 1 | 07-13 |
| 59 | As a CSM, I need a zone/region audience filter but only found a distance-radius  | How-to | 1 | 0 | 1 | 07-13 |
| 60 | Custom JS targeting (GTM/consent, language, currency, delay, hours) | Custom code | 0 | 206 | 14 | 04-13→07-13 |

---

**Recurring across ≥2 weeks (the durable toil):**

- **Pop-up / inline-block template gap → hand-authored markup** (`rc-cc-popup-inline-template-gap`) — 3t / 476m over 14w · 04-13:1t/27m · 04-20:0t/33m · 04-27:1t/29m · 05-04:0t/37m · 05-11:0t/36m · 05-18:1t/40m · 05-25:0t/21m · 06-01:0t/30m · 06-08:0t/24m · 06-15:0t/35m · 06-22:0t/52m · 06-29:0t/36m · 07-06:0t/24m · 07-13:0t/52m
- **Integration JS for API ops, add-to-cart, form handling** (`rc-cc-popup-integration-ops`) — 1t / 211m over 14w · 04-13:0t/12m · 04-20:0t/16m · 04-27:0t/13m · 05-04:0t/5m · 05-11:0t/35m · 05-18:1t/18m · 05-25:0t/13m · 06-01:0t/17m · 06-08:0t/12m · 06-15:0t/18m · 06-22:0t/18m · 06-29:0t/7m · 07-06:0t/6m · 07-13:0t/21m
- **Custom JS targeting (GTM/consent, language, currency, delay, hours)** (`rc-cc-targeting-gtm-gating`) — 0t / 206m over 14w · 04-13:0t/7m · 04-20:0t/5m · 04-27:0t/25m · 05-04:0t/24m · 05-11:0t/28m · 05-18:0t/9m · 05-25:0t/16m · 06-01:0t/17m · 06-08:0t/12m · 06-15:0t/8m · 06-22:0t/19m · 06-29:0t/16m · 07-06:0t/8m · 07-13:0t/12m
- **Reco widget repeats colour variants (SKU dedup, no swatches, no self-serve)** (`rc-mf-reco-variant-dedup`) — 2t / 194m over 14w · 04-13:0t/6m · 04-20:0t/13m · 04-27:0t/5m · 05-04:0t/7m · 05-11:0t/24m · 05-18:0t/4m · 05-25:0t/6m · 06-01:0t/21m · 06-08:0t/17m · 06-15:0t/16m · 06-22:0t/23m · 06-29:0t/10m · 07-06:2t/26m · 07-13:0t/16m
- **No native theme-aware placement (slot / header / cart drawer)** (`rc-mf-reco-theme-slot-injection`) — 3t / 45m over 14w · 04-13:0t/2m · 04-20:0t/2m · 04-27:0t/2m · 05-04:0t/2m · 05-11:0t/3m · 05-18:0t/3m · 05-25:0t/2m · 06-01:0t/2m · 06-08:1t/3m · 06-15:0t/5m · 06-22:0t/8m · 06-29:1t/4m · 07-06:0t/4m · 07-13:1t/3m
- **Reco widget visual customization not self-serve (CSS/arrows/carousel)** (`rc-mf-reco-widget-visual-customization`) — 8t / 0m over 6w · 04-20:1t/0m · 04-27:1t/0m · 05-04:1t/0m · 05-11:1t/0m · 05-25:1t/0m · 06-08:3t/0m
- **Reco A/B replace-content race → empty/flickering widget** (`rc-bug-reco-replace-content-race`) — 5t / 0m over 4w · 04-27:1t/0m · 06-22:1t/0m · 07-06:1t/0m · 07-13:2t/0m
- **Undisclosed reco-mechanic cap, no self-serve visibility** (`rc-mf-reco-mechanic-limit-visibility`) — 3t / 0m over 3w · 04-27:1t/0m · 06-01:1t/0m · 06-22:1t/0m
- **Pop-up partial-submission misses code-confirm dropoff (lost subs)** (`rc-bug-popup-partial-submission-dropoff`) — 3t / 0m over 3w · 05-11:1t/0m · 06-08:1t/0m · 07-13:1t/0m
- **No lint/validation gate on custom code → ships broken** (`rc-cc-no-custom-code-guardrails`) — 3t / 0m over 2w · 06-29:2t/0m · 07-13:1t/0m
- **Migration left A/B config broken** (`rc-bug-popup-ab-migration`) — 2t / 0m over 2w · 06-29:1t/0m · 07-13:1t/0m
- **No self-serve reco-widget template upgrade / per-device width** (`rc-mf-reco-template-upgrade-selfserve`) — 2t / 0m over 2w · 06-15:1t/0m · 06-22:1t/0m
- **Custom DOM-matching targeting breaks on client markup changes** (`rc-cc-dom-dependent-targeting-breaks`) — 2t / 0m over 2w · 06-15:1t/0m · 06-22:1t/0m
- **No product variant data for reco widget dropdowns** (`rc-mf-reco-no-variant-data`) — 2t / 0m over 2w · 06-01:1t/0m · 06-22:1t/0m
- **No native Yotpo ratings integration for reco widgets** (`rc-mf-reco-yotpo-ratings-integration`) — 2t / 0m over 2w · 06-15:1t/0m · 07-13:1t/0m
- **Popup image padding differs desktop vs mobile** (`rc-bug-popup-image-responsive-padding`) — 2t / 0m over 2w · 04-20:1t/0m · 06-15:1t/0m
- **Reco BI report double-counts assisted revenue (~3x AOV)** (`rc-bug-reco-report-assisted-revenue-double-count`) — 2t / 0m over 2w · 06-01:1t/0m · 06-08:1t/0m
- **Legacy manual tracker install fails per theme layout / after rename** (`rc-cc-legacy-tracker-per-theme-layout`) — 2t / 0m over 2w · 05-04:1t/0m · 05-11:1t/0m

**Merge watch:** `rc-cc-no-custom-code-guardrails` ↔ `rc-cc-client-owned-js-breaks-reco` (custom code fails silently, no validation gate); `rc-cc-dom-dependent-targeting-breaks` ↔ `rc-cc-targeting-gtm-gating` (custom JS targeting). Merge if they keep co-occurring.

**Resolved:** rc-bug-popup-editor-unsaved-guard (MR !8819) — should not recur.
