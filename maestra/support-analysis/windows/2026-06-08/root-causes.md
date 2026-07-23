# root causes — week 2026-06-08 (ISO 2026-W24)

Stage 3. Kept support entries clustered + reconciled. `[matched: id]` = seen in another week; `[new: id]` = first appearance. Custom-code mechanic counts are omega lower bounds and overlap across causes.

**Week totals:** support tickets kept 8 (Missing feature 6 · Bug 2 · Custom code 0 · How-to 0 · New client setup 0) · custom-code mechanics 56 (html/css 53 · targeting 12 · integration 12).

> Reco-widget theme this week: 4 of 8 tickets (t01, t03, t05, s01) are "reco widget customization/placement isn't self-serve." Three (t01/t03/s01) consolidate into one cause; t05 matches the placement cause. All normalized to Missing feature (fix = self-serve reco builder).

---

## Bug

- **Pop-up partial-submission misses code-confirm dropoff** [new: rc-bug-popup-partial-submission-dropoff] — 1 (t02, bedkingdom +4ocean) · **high impact: ~95% of subscriptions lost** over 1.5 days. Fixed.
- **Reco BI report double-counts assisted revenue** [new: rc-bug-reco-report-assisted-revenue-double-count] — 1 (t06, Jolyn) · ~3× real AOV; multi-product clicks in one widget double-counted. Fixed.

## New client setup

_None this week._

## Missing feature

- **Reco widget visual customization not self-serve** [new: rc-mf-reco-widget-visual-customization] — **3 (t01, t03, s01)** · lucyandyak, drhonow · the reco AI builder can't author CSS/JS (arrows, borders, image positioning, external SwiperJS) → hours of CSM time + dev escalation per widget. **The week's dominant theme.**
- **No self-service reco widget placement** [matched: rc-mf-reco-theme-slot-injection] — 1 (t05, monkeysports) · placement at an arbitrary DOM location needs an engineer. Recurring placement cause.
- **Reco image optimization all-or-nothing** [new: rc-mf-reco-image-optimization] — 1 (t04, lucyandyak) · slow (off) vs low-quality (on); no smart compression.
- **No two-way sync of pop-up/segment data to Shopify** [new: rc-mf-shopify-two-way-sync] — 1 (s02) · pop-up subscribers/segments don't sync to Shopify; losing ground to Dondy/LoyaltyLion.

## Custom code / How-to

_None as a distinct group this week (the reco-customization tickets are classified Missing feature by the fix they need)._

## Custom-code mechanics (track, no tickets)

- reco markup [rc-mf-reco-variant-dedup] 17 · pop-up/inline template gap [rc-cc-popup-inline-template-gap] 24 · targeting [rc-cc-targeting-gtm-gating] 12 · integration ops [rc-cc-popup-integration-ops] 12 · theme-slot injection [rc-mf-reco-theme-slot-injection] 3.
