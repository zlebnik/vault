# root causes — week 2026-07-13 (ISO 2026-W29)

**Week totals:** support tickets kept 13 (Bug 7 · Missing feature 4 · Custom code 1 · How-to 1) · custom-code mechanics 69 (html/css 68 · targeting 12 · integration 21; omega lower bound).

## Bug
- **Reco render race → empty widget** [matched: rc-bug-reco-replace-content-race] — 2 (t03 drhonow, t09 lucyandyak) · A/B "replace block" incompatible + add-to-cart/cart-update race (also fails in Incognito); workaround = start-of-block + on_render strip + popular-products fallback.
- **Pop-up code-confirm dropoff (lost subs)** [matched: rc-bug-popup-partial-submission-dropoff] — 1 (t12 deako) · OTP step doesn't handle already-known phone → silently drops subs; ~3× fewer phones, suspected ~2× welcome-revenue hit; A/B running.
- **Deleting A/B test breaks pop-up launch** [matched: rc-bug-popup-ab-migration] — 1 (t14 betboom) · stale A/B reference blocks launch+copy; manual cleanup + recreate.
- **Feed importer rejects invalid unicode char** [new: rc-bug-feed-invalid-char-rejection] — 1 (t07 lucyandyak) · zero-width char in a custom-field value → whole product/field rejected; eng dropped the field.
- **In-app CTA redirect not firing** [new: rc-bug-inapp-redirect-not-firing] — 1 (t11 mokka-eu) · click-redirect doesn't navigate; unresolved.
- **Legacy feed, unclear ownership/source** [new: rc-bug-legacy-feed-ownership-stale] — 1 (t13 magnumbikes) · third-party-agency setup, dead external feed URL, live source unknown.

## Missing feature
- **Reco recommends unavailable variants (no self-serve availability filter)** [new: rc-mf-reco-variant-availability-filter] — 2 (t05, t06 lucyandyak) · availability = multi-signal Shopify AND; needed per-tenant custom filter; partial platform patch shipped.
- **No native theme-aware reco placement** [matched: rc-mf-reco-theme-slot-injection] — 1 (t08 lucyandyak) · "replace block" is fragile, shows stale products; needs a native slot. Also ~3 mechanics.
- **No native third-party reviews integration for reco** [matched: rc-mf-reco-yotpo-ratings-integration] — 1 (s01) · Okendo reviews/ratings into reco (broadens the Yotpo cause); no connector, bespoke webhook work.

## Custom code
- **No validation gate on custom code → ships broken** [matched: rc-cc-no-custom-code-guardrails] — 1 (t04 movavicom) · client's custom targeting `$exec` JS has unguarded `JSON.parse(null)` → TypeError breaks tracker sitewide.

## How-to
- **How-to: region/zone audience via custom field** [new: rc-howto-targeting-custom-field-audience] — 1 (t10 lucyandyak) · only distance-radius was known; eng walked through custom-field "Area" filter (mirror of Jolyn).

## Custom-code mechanics (track)
reco markup 16 [rc-mf-reco-variant-dedup] · popup/inline template gap 52 [rc-cc-popup-inline-template-gap] · targeting 12 [rc-cc-targeting-gtm-gating] · integration ops 21 [rc-cc-popup-integration-ops] · theme-slot ~3 [rc-mf-reco-theme-slot-injection].

_Dropped: t01 (reco BI-report/reporting-infra outage, self-resolved), t02 (platform mailing incident), s02 (in-window msg is a thank-you; substance predates window)._
