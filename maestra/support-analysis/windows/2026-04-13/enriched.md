# enriched — week 2026-04-13 (ISO 2026-W16) — backfill

Stage 2. 2 ClearFeed (both kept) + custom-code clusters. 0 Slack.

### t01 · Custom code · almondcow → rc-cc-popup-inline-template-gap [matched]
- Pop-up form shows a stray border/outline because the Shopify theme's global focus-visible/outline styling bleeds through; support hand-wrote a CSS override (`#popmechanic-form:focus{outline:none!important}` + box-shadow:none). Theme-CSS conflict needing custom CSS.

### t02 · Missing feature · Jolyn → rc-mf-subscription-source-attribution [new]
- No report/field linking a subscription to the action that created it (pop-up vs registration form), so list growth can't be attributed/segmented by channel. One-off manual pull from raw events; no permanent fix.

## Custom-code mechanics (omega lower bound)
44 mechanics — reco markup 6 · popup/inline template gap 27 · targeting 7 · integration 12 · theme-slot 2.
