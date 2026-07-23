# enriched — week 2026-05-04 (ISO 2026-W19) — backfill

Stage 2. 4 ClearFeed (all kept) + 1 Slack + custom-code clusters.

### t01 · Custom code · pescatoreny (allfreshseafood) → rc-cc-legacy-tracker-per-theme-layout [matched]
- Legacy manual tracker snippet hardcoded with the OLD endpointId (allfreshseafood.Shopify) survived a store/endpoint rename and kept firing → popup preview failed. Support stripped the legacy snippet, enabled the app-embed pixel. **Now recurring with W20.**

### t02 · Bug · Trashie/AlmondCow → rc-bug-popup-heading-textarea-regression [new]
- A text→textarea change to the pop-up heading field (to allow multi-line custom HTML) broke rendering across ALL pop-ups; reported w/ Loom, unfixed ~2 weeks. (Root desire = custom HTML in heading = template gap.)

### t03 · Bug · zone3 → rc-bug-reco-custom-js-vanishes [new]
- Custom JS silently disappears from a reco-widget + its copies (toggle stays on), no before/after audit log to diagnose.

### t04 · Bug · Monkeysports → rc-bug-reco-widget-load-latency [new]
- Reco backend call (CDP lookups) took p50 ~1.5–1.8s (up to 3s), visibly slower than a competitor and blocking cutover. Fixed "Phase 6" (~90% p50 cut). Affected many projects.

### s01 · Missing feature · bokksu (Slack) → rc-mf-reco-widget-visual-customization [matched]
- reco mobile layout: fit all 5 products in one line / slider→list (reco-widget/56999). reco-visual-customization.

## Custom-code mechanics (omega lower bound)
68 mechanics — reco markup 7 · popup/inline template gap 37 · targeting 24 · integration 5 · theme-slot 2.
