# root causes — week 2026-05-04 (ISO 2026-W19) — backfill

**Week totals:** support tickets kept 5 (Bug 3 · Missing feature 1 · Custom code 1) · custom-code mechanics 68 (html/css 68 · targeting 24 · integration 5).

## Bug
- **Pop-up heading text→textarea regression** [new: rc-bug-popup-heading-textarea-regression] — 1 (t02, Trashie/AlmondCow) · broke rendering across all pop-ups, unfixed ~2 weeks.
- **Reco custom-JS content silently vanishes** [new: rc-bug-reco-custom-js-vanishes] — 1 (t03, zone3) · no audit-log diff.
- **Reco widget backend load latency** [new: rc-bug-reco-widget-load-latency] — 1 (t04, Monkeysports) · p50 1.5–1.8s blocked cutover; fixed Phase 6 (~90%). Affected many projects.

## Missing feature
- **Reco widget visual/layout customization** [matched: rc-mf-reco-widget-visual-customization] — 1 (s01, bokksu) · mobile one-line layout.

## Custom code
- **Legacy theme tracker snippet outlives changes** [matched: rc-cc-legacy-tracker-per-theme-layout] — 1 (t01, pescatoreny) · old endpointId after rename → popup fails. **Now recurring (also W20).**

## Custom-code mechanics (track)
reco markup 7 · popup/inline template gap 37 · targeting 24 · integration 5 · theme-slot 2.
