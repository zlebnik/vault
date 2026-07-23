# enriched — week 2026-05-11 (ISO 2026-W20) — backfill

Stage 2. 3 support (all kept) + custom-code clusters.

### t01 · Missing feature · Pescatore NY (+Almond Cow) → rc-bug-popup-partial-submission-dropoff [matched]
- **root cause:** Multi-step pop-up doesn't save step data incrementally, so if a visitor closes the tab after step 1 (email) but before the final step, the lead is lost entirely. Competitors (Klaviyo, Omnisend, Postscript) save incrementally.
- **current solution:** none — data only persists on popup close/completion. Reproduced on 2 clients; GH #963 filed.
- **repetitive:** true · **pain:** partially-entered leads silently lost on abandon. **Now recurring with W24 (partial-submission).**

### t02 · Custom code · Lectric eBikes → rc-cc-legacy-tracker-per-theme-layout [new]
- **root cause:** Legacy manual tracker install (script in theme.liquid, not the app embed) isn't present on an alternate theme layout (theme.theone.liquid), so the tracker doesn't load and the reco widget silently fails on those pages only.
- **current solution:** support traced it to the alt layout and switched the site to the Maestra app embed (propagates to all layouts).
- **repetitive:** true · **pain:** per-page-only failure needing manual theme-layout diffing; legacy installs may be silently costing performance across older accounts.

### s01 · Missing feature · (Slack, concise) → rc-mf-reco-widget-visual-customization [matched]
- reco needs a separate widget per screen width (layout can't adapt: slider vs list/vertical) → the reco-visual-customization / per-device family. Light-attributed from a concise Slack thread.

## Custom-code mechanics (omega lower bound)
91 mechanics — reco markup 24 · popup/inline template gap 36 · targeting (GTM/language) 28 · integration ops 35 · theme-slot ~3.
