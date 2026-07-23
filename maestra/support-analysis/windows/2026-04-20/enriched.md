# enriched — week 2026-04-20 (ISO 2026-W17) — backfill

Stage 2. 4 ClearFeed → 3 kept (t01 dropped = Metabase reporting infra) + 1 Slack + custom-code clusters.

### t01 · — · drop · Furniture Fair
- Metabase-backed reco-report dashboard page not loading; fixed on the Metabase side. Not a mechanic issue.

### t02 · Bug · natvbasics → rc-bug-inline-block-form-localization-missing [new]
- Inline-block settings form missing localization (block created under RU locale); fix prevents new forms losing it, legacy not backfilled.

### t03 · Missing feature · Selkirk → rc-mf-reco-explicit-cart-rules [new]
- Wants explicit cart-based product→product reco rules (Boomstick→paddle case) + fallback; only the algorithmic "often purchased with items in product list" preset exists. Dev effort filed; unresolved 5+ weeks.

### t04 · Bug · 4ocean → rc-bug-popup-image-responsive-padding [matched]
- Pop-up logo image block has a hardcoded (square) aspect ratio + missing CSS → huge un-editable margins; per-popup CSS patch. (Broadens the popup-image-sizing cause.)

### s01 · Missing feature · (Slack) → rc-mf-reco-widget-visual-customization [matched]
- Bundle template gap ("bundle template in queue, needs backend"; skill updated in cowork as a stopgap) + a reco-report-by-collection reporting gap. Light-attributed.

## Custom-code mechanics (omega lower bound)
52 mechanics — reco markup 13 · popup/inline template gap 33 · targeting 5 · integration 16 · theme-slot 2.
