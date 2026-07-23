# enriched — week 2026-05-25 (ISO 2026-W22, Mon 25 – Sun 31 May)

Stage 2. Support from full threads (proportionate); custom-code from DB cluster sampling.

- **Support:** 4 (ClearFeed) → **kept 4** (no drops; 0 Slack personalization threads). All reco.
- **Kept groups:** Bug 2 · Missing feature 1 · How-to 1 · Custom code 0.
- **Custom-code mechanics:** 43 (omega lower bound) — html/css 40 · targeting 16 · integration 13.

---

## Support entries

### t01 · Selkirk → rc-mf-reco-widget-visual-customization [matched]  (subagent: Custom code → Missing feature)
- **root cause:** "Complete the look" card should show the current product + 3 more (one per category slot), but the native reco widget renders one product per slot with no way to compose multiple algorithms into one card (slot ordering, per-slot category, detail slide-out).
- **current solution:** Custom-built widget = 3 algorithms feeding one card + custom JS slide-out, built over ~a sprint. Teammate wants to reuse it → re-implemented per tenant absent a native feature.
- **repetitive:** true · **pain:** multi-week bespoke build; will recur per client. **Now recurring with W24.**

### t02 · Bug · Jolyn → rc-bug-reco-zero-weight-algo-op [new]
- **root cause:** The new multi-algorithm reco checkout widget called the recommendation operation even when an algorithm's weight was 0 (the default) → failed operations (popmechanic-widget-55454-reco-2).
- **current solution:** Fixed same-day (skip the op when weight is 0). one-off release regression.
- **pain:** burst of failed operations in integration logs, flagged by a CSM.

### t03 · Bug · Bokksu → rc-bug-reco-min-count-selector-embed [new]
- **root cause:** The "hide widget if below minimum product count" logic was broken specifically when the widget is embedded via a CSS selector (not the data-popmechanic-embed attribute) → widget rendered with too few products.
- **current solution:** Engineer diagnosed via HAR, fixed same-day. one-off.
- **pain:** reco widget looked broken/empty until the selector-embed display bug was fixed.

### t04 · How-to · Lectric eBikes → rc-howto-reco-ab-participant-counting [new]
- **root cause:** Reco A/B reporting showed 70/30 despite a 50/50 device split (+ non-zero clicks on the no-widget control) because participant counting is asymmetric — control counts *eligibility*, variant counts only *actually-rendered* devices (30–50% render attrition, 56% here) — so a true 50/50 looks broken.
- **current solution:** Support explained the metric definition; no reporting change.
- **repetitive:** true · **pain:** client loses trust in A/B reporting, thinking randomization is broken. (Fix could be symmetric counting — a reporting Missing feature.)

---

## Custom-code mechanics — cluster enrichment (omega lower bound)

43 mechanics (lowest-ratio week: 43 of 130 created), same recurring patterns:
- **rc-mf-reco-variant-dedup** — 6 reco html/css (Lucyandyak, lectricebikes reco).
- **rc-cc-popup-inline-template-gap** — 21 popup/inline html/css.
- **rc-cc-targeting-gtm-gating** — 16 (marathonbet ×12 GTM + others).
- **rc-cc-popup-integration-ops** — 13 (enlightenedequip referral, Lucyandyak, lectricebikes).
- **rc-mf-reco-theme-slot-injection** — ~2.
