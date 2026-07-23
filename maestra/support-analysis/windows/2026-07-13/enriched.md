# enriched — week 2026-07-13 (ISO 2026-W29, Mon 13 – Sun 19 Jul)

Stage 2. Support from full threads (ClearFeed `requests_get` + Slack `slack_read_thread`); custom-code from DB cluster sampling.

- **Support candidates:** 16 (14 ClearFeed + 2 Slack) → **kept 13**, dropped 3.
- **Kept groups:** Bug 7 · Missing feature 4 · Custom code 1 · How-to 1 · New client setup 0.
- **Custom-code mechanics:** 69 (omega lower bound) — html/css 68 (pop-up 35 · inline 17 · reco 16) · targeting 12 · integration 21.
- **Dropped:** t01 (reco BI-report/reporting-infra outage, self-resolved — not a personalization mechanic), t02 (platform mailing-pipeline incident), s02 (in-window message is only a thank-you; substantive thread predates the window).

---

## Support entries

### t01 · Bug · jolyn/lucyandyak  →  DROP
- Reco BI product-recommendations dashboard briefly showed no data for two tenants; reporting/analytics pipeline glitch, self-resolved. Not an on-site personalization mechanic (pop-up/inline/reco widget/targeting). Recurs as a reporting-infra pattern but out of scope.

### t02 · Bug · myorganicapps (+others)  →  DROP
- Automated-campaign emails failed to send across several tenants; platform mailing-pipeline incident, fix already in flight. Not personalization.

### t03 · Bug · drhonow  →  rc-bug-reco-replace-content-race [matched]
- **root cause:** Personalized inline-block + reco variant won't render under a live A/B test because the "replace block" targeting selector doesn't work once the A/B runtime wraps the variant — replace-content and A/B testing are structurally incompatible.
- **current solution:** Switch the mechanic from "replace block" to "start of block" + hand-written on_render JS (`PopMechanic.$(sel).remove()`) to strip the native site element; done per-widget referencing a prior thread.
- **repetitive:** true · **pain:** recommendations barely show / inline block doesn't show at all during an A/B test, burning impressions pre-launch.

### t04 · Custom code · movavicom  →  rc-cc-no-custom-code-guardrails [matched]
- **root cause:** Client's own custom targeting `$exec` rule (Download-Reminder popup) does `JSON.parse(raw).includes(...)` with no null guard; when the `downloadedProducts` cookie is absent, `JSON.parse` → null → `TypeError`, breaking the tracker. No validation gate catches unguarded custom code before it ships.
- **current solution:** Support traced it into the client's minified bundle and suggested `JSON.parse(raw) || []`; client's code, their fix. CF-1627 closed.
- **repetitive:** true · **pain:** custom targeting silently throws when expected data isn't present; client can't tell if it's their bug or Maestra's without eng tracing bundle code.

### t05 · Missing feature · lucyandyak  →  rc-mf-reco-variant-availability-filter [new]
- **root cause:** Reco widget recommends out-of-stock / unpublished variants because availability was computed from a raw `available` flag rather than the retailer's real stock definition (Online-Store publication + per-location stock); no self-serve availability filtering.
- **current solution:** Eng shipped a same-day patch (only surface variants with `available` explicitly true; previously missing = available). A follow-up (t06) opened next day → underlying gap not fully closed.
- **repetitive:** true · **pain:** customers can add out-of-stock variants shown in "recently viewed" recs.

### t06 · Missing feature · lucyandyak  →  rc-mf-reco-variant-availability-filter [new]
- **root cause:** Correct "in stock" for this Shopify multi-channel catalog is a 3-signal AND (product Active + `landy.online_stock_status` metafield + Online-Store publication); Maestra's default availability rule can't compose multiple signals, so both false-available and false-unavailable products appeared.
- **current solution:** Eng hand-built a custom retail-availability filter (AND of the 3 signals), iterated hours with the client, documented in the Shopify-integration runbook. Per-tenant custom, not self-serve.
- **repetitive:** true · **pain:** availability wrong in both directions, breaking trust in reco/catalog filters before a client call.

### t07 · Bug · lucyandyak  →  rc-bug-feed-invalid-char-rejection [new]
- **root cause:** A Shopify custom field ("Material") enum value contains an invisible zero-width unicode char; the feed importer rejects the whole product/field instead of sanitizing or skipping it → new products stop syncing.
- **current solution:** Eng manually dropped the offending custom field from the feed mapping; no value-sanitization fix.
- **repetitive:** false · **pain:** products silently stop syncing because of one invisible character.

### t08 · Missing feature · lucyandyak  →  rc-mf-reco-theme-slot-injection [matched]
- **root cause:** "You may also like" shows stale/gone products because the widget uses fragile "replace block" placement (no native theme-aware slot) that doesn't reliably clear the site's legacy recommendation markup without a custom JS assist.
- **current solution:** Re-adjusted to "start of block" + custom on_render JS to strip old content; CSM added a "popular products" fallback so the slot never renders empty.
- **repetitive:** true · **pain:** recurrence of a previously-fixed stale-recs issue, undermining trust the fix holds.

### t09 · Bug · lucyandyak  →  rc-bug-reco-replace-content-race [matched]
- **root cause:** PDP/cart reco widgets fail to render the cart-update recommendation right after "add to cart" — the reco fetch loses a race with the cart-update trigger (only renders after reload); also fully broken in Incognito.
- **current solution:** Workaround only — added a "popular products" fallback so the widget isn't empty while the real reco loads; add-to-cart timing race + Incognito failure unresolved at thread end.
- **repetitive:** true · **pain:** reco shows nothing until reload, nothing in Incognito, conversions not counting 100% in QA.

### t10 · How-to · lucyandyak  →  rc-howto-targeting-custom-field-audience [new]
- **root cause:** CSM needed a zone/region audience filter (mirroring an existing Jolyn setup) but the project only had a distance-radius filter; didn't know custom-field-backed area filters were the supported path.
- **current solution:** Eng walked the CSM through creating an "Area" custom field and building the audience filter from it (mirror of Jolyn). Pure config consultation, no product change.
- **repetitive:** true · **pain:** CSM couldn't self-serve a common region-targeting setup; needed eng hand-holding.

### t11 · Bug · mokka-eu  →  rc-bug-inapp-redirect-not-firing [new]
- **root cause:** Customers clicking an in-app message with a configured redirect link aren't taken to the right page — the in-app click-redirect action isn't firing correctly (or the client's app isn't handling the deep link).
- **current solution:** None — ticket stalled after initial report; reporter pinged again a week later.
- **repetitive:** false · **pain:** in-app CTA doesn't navigate; client-facing, unresolved.

### t12 · Bug · deako  →  rc-bug-popup-partial-submission-dropoff [matched]
- **root cause:** Pop-up phone-verification (OTP) step doesn't gracefully handle contacts whose phone is already in the base (unconfirmed) — entering the code does nothing (no next screen, no error), so those subscribers are silently dropped. The OTP requirement itself is suspected of a real conversion drop.
- **current solution:** None shipped — team debating de-scoping the phone requirement, "one-tap" verification still unbuilt, running an A/B test to quantify the conversion hit.
- **repetitive:** true · **pain:** confirm-code pop-up collected ~3× fewer phones than a normal pop-up; suspected ~2× welcome-revenue drop; test inconclusive after a week.

### t13 · Bug · magnumbikes  →  rc-bug-legacy-feed-ownership-stale [new]
- **root cause:** Legacy project set up by a third-party agency (whynotdgtl) with an externally-hosted feed URL; the feed is stale and nobody can tell whether settings consume the dead external feed or a Maestra-generated one — no clear ownership/source of truth.
- **current solution:** Support dug through candidate feed URLs, couldn't confirm the live source, escalated to eng in another channel; ticket marked solved but resolution not visible in-thread.
- **repetitive:** false · **pain:** feed "just doesn't update"; the external feed URL is dead; live source unknown.

### t14 · Bug · betboom  →  rc-bug-popup-ab-migration [matched]
- **root cause:** Deleting a pop-up's linked A/B test leaves a stale reference behind; the pop-up's launch and copy actions both fail (one cites the deleted A/B test, the other a generic error) because state isn't cleaned up after the test is removed.
- **current solution:** Support manually removed the stale reference and had the client recreate the pop-up under a new label; flagged for a proper cleanup-logic fix.
- **repetitive:** true · **pain:** pop-up can't be launched or duplicated after its A/B test is deleted, blocking a live campaign.

### s01 · Missing feature · (CSM ask)  →  rc-mf-reco-yotpo-ratings-integration [matched]
- **root cause:** Client wants Okendo product reviews/ratings inside the reco widget (like the existing Yotpo case) but there's no native Okendo connector — would need scoped custom webhook work (and the client's Okendo plan must support webhooks).
- **current solution:** None — no self-serve reviews integration; team would scope custom work.
- **repetitive:** true · **pain:** social-proof (ratings/reviews) can't be surfaced in recs without bespoke integration. Broadens the cause from Yotpo-only to third-party reviews generally.

### s02 · How-to · (CSM)  →  DROP
- In-window message is only a thank-you ("this is incredibly helpful, started working on them") referencing a reco template/product-algorithm notes doc; substantive discussion is in a parent thread predating the window. No independent defect/gap in-window.

---

## Custom-code mechanics (omega lower bound)

69 mechanics — partition: reco markup 16 · popup/inline template gap 52 · targeting 12 · integration ops 21 · theme-slot ~3.

- **rc-cc-popup-inline-template-gap** — 52 (pop-up 35 + inline 17 html/css; templates don't fit → hand-authored markup).
- **rc-mf-reco-variant-dedup** — 16 (reco widget markup: dedup/swatches/layout).
- **rc-cc-targeting-gtm-gating** — 12 (custom JS targeting: consent/GTM, language, delay, hours).
- **rc-cc-popup-integration-ops** — 21 (integration JS: API ops, add-to-cart, form handling).
- **rc-mf-reco-theme-slot-injection** — ~3 (native theme placement gap; also t08).
