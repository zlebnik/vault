# enriched — week 2026-06-08 (ISO 2026-W24, Mon 08 – Sun 14 Jun)

Stage 2. Support from full threads (proportionate); custom-code from DB cluster sampling.

- **Support:** 8 (6 ClearFeed + 2 Slack) → **kept 8** (no drops).
- **Kept groups (reconciled):** Missing feature 6 · Bug 2 · Custom code 0 · How-to 0.
- **Custom-code mechanics:** 56 (omega lower bound) — html/css 53 · targeting 12 · integration 12.
- **Reconcile highlights:** t01+t03+s01 → one cause `rc-mf-reco-widget-visual-customization` (reco visuals not self-serve); t05 → `rc-mf-reco-theme-slot-injection` (placement). t01/t05/s01 normalized Custom code → Missing feature (fix = self-serve reco builder).

---

## Support entries

### t01 · lucyandyak → rc-mf-reco-widget-visual-customization [new]  (subagent: Custom code → Missing feature)
- **root cause:** Reco widget's second image (img2) + image link are hidden because the custom CSS (`.popmechanic-labels`) is absolutely positioned over the whole picture. No self-serve fix — a dev hand-corrected the CSS, repeated for **3 widgets** (57933, 57912, 57896).
- **current solution:** Gleb hand-gave a corrected CSS snippet to paste per widget.
- **pain:** paged a dev with a hard deadline for a one-line CSS fix, three times.

### t02 · Bug · bedkingdom (+4ocean) → rc-bug-popup-partial-submission-dropoff [new]  ⚠ high impact
- **root cause:** Pop-up "partial submission" only fired if the user dropped off at the phone-input step, not after requesting the SMS code but before confirming → leads captured as contacts but never subscribed.
- **current solution:** Engineer patched the partial-submission logic (also propagated to the inline block + 4ocean). **Fixed.**
- **pain:** bedkingdom lost **~95%** (~900/950) of email subscriptions over 1.5 days; 4ocean lost ~10% (~$k).

### t03 · Missing feature · drhonow → rc-mf-reco-widget-visual-customization [new]
- **root cause:** The reco-widget AI builder tunes only standard presets and **can't author CSS/JS** (unlike the pop-up assistant) → non-standard visuals (slider arrows, card borders) dead-end into dev escalation.
- **current solution:** CSM spent 2–3h with the AI builder, then an engineer flipped a hidden checkbox + wrote raw CSS (opacity:0, cursor:default).
- **pain:** "вот сюда часы CSM уходят в невьебенном количестве" — hours lost per widget.

### t04 · Missing feature · lucyandyak → rc-mf-reco-image-optimization [new]
- **root cause:** Reco "optimize images" is all-or-nothing — off = slow, on = visibly low quality; no smart compression; no backlog to track such asks.
- **current solution:** none; one-off Notion task filed.
- **pain:** stuck between slow-loading and low-quality reco images.

### t05 · monkeysports → rc-mf-reco-theme-slot-injection [matched]  (subagent: Custom code → Missing feature)
- **root cause:** No self-service way to place a reco widget at an arbitrary DOM location (above "Customers Also Bought", near add-to-cart) → engineer hand-places with custom selectors/CSS + carousel arrows.
- **current solution:** engineer manually hooked it up before the client demo.
- **pain:** placement depends on eng turnaround under demo deadline. **Matches the recurring theme-slot cause.**

### t06 · Bug · Jolyn → rc-bug-reco-report-assisted-revenue-double-count [new]
- **root cause:** Reco BI report showed ~3× real AOV ($200–233) because assisted-revenue double-counted an order when a shopper clicked multiple products in the same widget before buying them together.
- **current solution:** Engineer fixed the double-counting in the assisted-revenue query. **Fixed.**
- **pain:** inflated AOV eroded client trust in reco analytics; ad-hoc investigation.

### s01 · lucyandyak/? (slack) → rc-mf-reco-widget-visual-customization [new]  (subagent: Custom code → Missing feature)
- **root cause:** Reco widget has no native option to defer to a merchant's own carousel (SwiperJS) — only path is disable the native slider and hand-build markup/JS against their Swiper.
- **current solution:** custom-code rebuild per case.
- **pain:** no supported external-carousel integration; bespoke HTML/JS each time.

### s02 · Missing feature · ? (slack) → rc-mf-shopify-two-way-sync [new]
- **root cause:** No native two-way sync between pop-up/segment data and Shopify's customer DB; pop-up subscribers aren't added to Shopify, no subscribe/unsubscribe sync, no segment export (webhooks only). Shopify account-portal customization deprioritized.
- **current solution:** none native — custom webhook integration only.
- **pain:** account team can't answer Shopify clients confidently; loses ground to apps (Dondy, LoyaltyLion) that sync natively — "clients expect this as baseline."

---

## Custom-code mechanics — cluster enrichment (omega lower bound)

56 mechanics, same recurring patterns:
- **rc-mf-reco-variant-dedup** — 17 reco html/css (CopenhagenLiving, Allegianteyewear, Lucyandyak, lectricebikes, jewellerybox, Monkeysports, SvahaUSA).
- **rc-cc-popup-inline-template-gap** — 24 popup/inline html/css (pescatoreny, ilovelinen, ispace, octobrowsernet + tail).
- **rc-cc-targeting-gtm-gating** — 12 (marathonbet ×12 GTM).
- **rc-cc-popup-integration-ops** — ~12 (Budsies ×2 all-integration, tac, astons, Lucyandyak, lectricebikes, urbanarmorgear, hawaiicoffee).
- **rc-mf-reco-theme-slot-injection** — ~3 (theme/DOM injection subset).
