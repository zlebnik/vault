# enriched — week 2026-04-27 (ISO 2026-W18) — backfill

Stage 2. 5 ClearFeed (all kept) + 2 Slack + custom-code clusters.

### t01 · Bug · doraihome → rc-bug-popup-regional-render [new]
- Pop-up 55505 rendered broken on the live storefront (regional rendering bug); eng fixed server-side + rolled out.

### t02 · Bug · Jolyn → rc-bug-reco-replace-content-race [matched — app-embed variant]
- Two instances of the same reco-widget (57016) via Shopify app-embed duplicate the recommendation on some products (selector matched/mounted twice); unreproducible, widget disabled, never root-caused. (Broadens the multi-instance/selector-conflict cause.)

### t03 · Missing feature · Jolyn → rc-mf-reco-ranking-opacity-tuning [new]
- Custom Recommendations ranking opaque (attribute-similarity → popularity only on tie, hidden 180-day window), lookback not tunable in UI → manual justification each time. Configurable-lookback declined; one-off 180→60 override for Jolyn.

### t04 · Bug · sena → rc-bug-reco-preview-hash-missing [new]
- Bundle reco live-preview test-hash points to settings "can't be found in DB" → preview fails; fixed by re-saving. No root cause.

### t05 · Missing feature · bokksu → rc-mf-reco-mechanic-limit-visibility [matched]
- Needed >10 reco-algorithm slots (quiz/segment-driven); hardcoded per-project cap, support bumped 10→20. Recurring cap cause.

### s01 · Custom code · Svaha (Slack) → rc-cc-popup-inline-template-gap [matched]
- CSM: "many site personalization campaigns don't fit any template, so I use create-custom from empty." Template-gap acknowledged as routine.

### s02 · Missing feature · bokksu (Slack) → rc-mf-reco-widget-visual-customization [matched]
- "Customers Also Loved" cart widget — replacing the client's custom widget / building into their existing drawer. reco-visual-customization/theme placement.

## Custom-code mechanics (omega lower bound)
62 mechanics — reco markup 5 · popup/inline template gap 29 · targeting 25 · integration 13 · theme-slot 2.
