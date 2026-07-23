# root causes — week 2026-06-01 (ISO 2026-W23)

Stage 3. Kept support entries clustered + reconciled. `[matched: id]` = seen in another week; `[new: id]` = first appearance. Custom-code mechanic counts are omega lower bounds and overlap across causes.

**Week totals:** support tickets kept 10 (How-to 4 · Bug 4 · Missing feature 2 · Custom code 0 · New client setup 0) · custom-code mechanics 70 (html/css 68 · targeting 17 · integration 17).

> The How-to group earned its keep: 4 of 10 tickets are product-knowledge/config clarifications — two on pop-up form behaviour, two on reco widgets silently returning nothing when a setting isn't enabled (no error surfaced).

---

## How-to

- **Pop-up form config + capture-on-close** [new: rc-howto-popup-form-config] — 2 (t01 copenhagenliving, t02 lucyandyak) · fields must be added per variant; email is already captured on close (not only submit) — both misunderstandings of existing behaviour.
- **Reco widget silently broken when a setting isn't enabled** [new: rc-howto-reco-silent-misconfig] — 2 (t04 lucyandyak external-system-not-selected, t09 sarahssilks add-to-cart-toggle-off) · returns nothing / looks broken with **no error surfaced** → always a support diagnosis. (Fix could be validation/error surfacing.)

## Bug

- **Reco BI report revenue inaccuracies** [matched: rc-bug-reco-report-assisted-revenue-double-count] — 1 (t03, Jolyn) · revenue silently drifted (migration break + 30-day recalc bug + future-click attribution ~10%). **Now recurring (also W24).** 30-day regression still pending.
- **Pop-up editor hides name field → stuck placeholder** [new: rc-bug-popup-editor-hidden-field] — 1 (t05, natvbasics) · stray Russian placeholder stuck uneditable in a live pop-up. Fixed via FE MRs + migration.
- **Checkout reco variant selector / product name not rendering** [new: rc-bug-reco-variant-selector-broken] — 1 (t08, lucyandyak) · escalated to the widget engineer; fixed ~1 month later.
- **Reco update pipeline stuck (stale items, no alerting)** [new: rc-bug-reco-update-pipeline-stuck] — 1 (t10, Pescatoreny) · feed stuck "updating" 1.5h+; no alerting/self-serve; cause undocumented.

## New client setup

_None this week._

## Missing feature

- **Reco needs richer feed data (variants, alt images)** [matched: rc-mf-reco-no-variant-data] — 1 (t06, Monkeysports) · Magento gallery doesn't reliably expose a second image → partial hand-dug coverage. **Now recurring (also W26).**
- **Undisclosed reco mechanic / per-algorithm cap** [matched: rc-mf-reco-mechanic-limit-visibility] — 1 (t07, lucyandyak) · hit hardcoded per-algorithm instance cap (multi-brand); support bumped it. **Now recurring (also W26).**

## Custom code

_None as a distinct group this week._

## Custom-code mechanics (track, no tickets)

- reco markup [rc-mf-reco-variant-dedup] 21 · pop-up/inline template gap [rc-cc-popup-inline-template-gap] 30 · targeting [rc-cc-targeting-gtm-gating] 17 (Movavicom language + marathonbet GTM) · integration ops [rc-cc-popup-integration-ops] 17 · theme-slot injection [rc-mf-reco-theme-slot-injection] 2.
