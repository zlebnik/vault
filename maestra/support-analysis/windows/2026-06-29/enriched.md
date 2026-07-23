# enriched — week 2026-06-29 (ISO 2026-W27, Mon 29 Jun – Sun 05 Jul)

Stage 2. Support entries read from full threads (subagents, proportionate depth); custom-code from DB cluster sampling.

- **Support candidates:** 9 → **kept 8** (dropped t06 = email-builder recommendation block, not a personalization mechanic).
- **Kept groups (reconciled in stage 3):** Bug 4 · Missing feature 2 · Custom code 2 · New client setup 0.
- **Custom-code mechanics:** 63 (omega lower bound) — html/css 62 · targeting 16 · integration 11.

> Group normalization (classify by the fix, not the workaround): **t01** returned as "Custom code" but reconciled to **Missing feature** — the gap is self-serve theme placement (maps to `rc-mf-reco-theme-slot-injection`); hand-CSS is the stopgap. t02/t04 stay **Custom code** (custom code failing with no guardrail).

---

## Support entries

### t01 · Missing feature · keep · zone3  (subagent: Custom code — reconciled)
- **root cause:** As a CSM launching an inline-block text bar in Zone3's Shopify header, I hit a white strip under the bar because placing personalization blocks into a theme's header needs hand-tuned CSS margins — there's no self-serve, theme-aware placement, so it falls back to engineering each time (as with this client's original header placement).
- **current solution:** Support engineer manually zeroed the CSS margin on the inline-block.
- **repetitive:** true · **pain:** header text bar leaves an unwanted white strip on the live site; CSM/client can't fix without an engineer.
- **maps to:** `rc-mf-reco-theme-slot-injection` (evidence: zone3 integration mechanics 58388/58390 = `#header-group` position fix).

### t02 · Custom code · keep · limevizio (blossomflowerdelivery)
- **root cause:** As a client, I had a `debugger;` left in my form's custom JS in production because nobody stripped it and Maestra has no lint/review gate on custom code before it saves to a live form.
- **current solution:** Support manually deleted the `debugger;` from the form's custom-code editor.
- **repetitive:** true · **pain:** visitors with DevTools open got their browser paused mid-session on the live site.

### t03 · Bug · keep · ?
- **root cause:** As a user of the popup creation tool, adding an A/B test errored because a backend migration left the A/B-test config in a broken state.
- **current solution:** Migration errors corrected server-side; user asked to retry.
- **repetitive:** false · **pain:** couldn't add an A/B variant, blocked by an unexplained error.

### t04 · Custom code · keep · atlantacutlery
- **root cause:** As an implementation engineer building a bespoke loyalty widget (pop-up + hand-authored JSON reward config wired to custom DirectCRM operations + scenarios), I hit several silent failures (secret-key-gated registration, a JSON syntax error that silently fell back to a default config, an inactive scenario) because this custom loyalty mechanic has no built-in validation or error surfacing across its layers.
- **current solution:** Engineer manually removed the secret-key requirement, fixed the JSON, activated the scenario.
- **repetitive:** true · **pain:** multi-day trial-and-error across config/operations/scenarios with no clear errors.

### t05 · Missing feature · keep · selkirkcom
- **root cause:** As a CSM configuring the "Post-purchase cross-sell" reco widget for Selkirk, I can't add a second algorithm to the same slot because the platform restricts each reco-widget type to one active algorithm, so testing/running multiple needs an engineer.
- **current solution:** Engineer manually enabled a second algorithm slot on the backend (no self-serve path).
- **repetitive:** true · **pain:** client wanted a second cross-sell algorithm; had to file a ticket and wait.

### t06 · — · drop · ?
- **root cause:** Email recommendation block renders too narrow with 1–2 products; manual Height in px shrinks card width, Width only settable as %.
- **drop reason:** Email-builder bug (recommendation block inside email templates), not a personalization pop-up/inline/reco mechanic.

### t07 · Bug · keep · ?
- **root cause:** As a marketer building a pop-up, I lose the finished pop-up when I navigate to create a teaser because the editor had no unsaved-changes guard — it silently discarded in-progress edits.
- **current solution:** none at report time (had to rebuild); **fixed in-week via MR !8819** (Save/Leave/Cancel dialog + browser prompt on refresh/close).
- **repetitive:** true · **pain:** fully built pop-up silently vanished, forcing a full redo with no warning.

### t08 · Bug · keep · coolibar
- **root cause:** As a merchant QA-testing a new pop-up with SMS/phone auth (CheckCodeForSubscription / SendSmsVerificationCode), the code failed on a second test with no trace in integration logs — an intermittent verification-flow issue support couldn't reproduce.
- **current solution:** none — worked on retest, ticket closed without a fix.
- **repetitive:** false · **pain:** verification code silently failed, blocking launch confidence.

### t09 · Bug · keep · Svaha USA / Hawaii Coffee / Sena
- **root cause:** As a CSM analyzing performance, targeting-reach shows 0 for pop-ups/quizzes triggered via API/command (not button click), because a fix shipped with the end-of-May Quizzes UI release (to stop quizzes firing the targeting event on every page load) also killed the event for legitimate API-triggered widgets — it now only fires on button-triggered conditions.
- **current solution:** none — Gleb still investigating; no workaround shipped.
- **repetitive:** true · **pain:** reach drops to 0 in reports for API-triggered widgets; merchants panic thinking targeting broke.

---

## Custom-code mechanics — cluster enrichment (omega lower bound)

63 mechanics. Enriched at the pattern level (sampled).

### CC-A · Hand-authored reco-widget card markup  →  rc-mf-reco-variant-dedup
- **mechanics:** ~10 reco-widget variants w/ custom html/css — BlueQ (58410–58412), hawaiicoffee (58482/58483), SvahaUSA (58480), Sena (58481), Allegianteyewear (58400), bokksu (58488).
- Same family as W28's reco-display gap (dedup/swatches/layout hand-coded per widget).

### CC-B · Custom JS targeting rules the UI can't express  →  rc-cc-targeting-gtm-gating
- **mechanics:** 16 — marathonbet-eu ×14 (`return !!(gtmHandler.popmechanic?.isPopupAllowed())` = GTM/consent gating), Movavicom 58414 (`document.documentElement.lang.startsWith("en")` = **language gating**), Clientsen 58496 (**business-hours** gating, Mon–Fri 04:00–17:00 ET).
- Broadens the cause: targeting UI can't express GTM/consent, language, or business-hours/timezone gating → custom `$exec` JS.

### CC-C · Integration JS to place/adjust widgets in the theme  →  rc-mf-reco-theme-slot-injection
- **mechanics:** ~4 — zone3 58388/58390 (`#header-group` position fix — ties to t01), CopenhagenLiving 58491/58497 ("destroy the slider on mobile so cards stack vertically").
- No native theme-aware placement/layout → hand-written DOM/CSS-in-JS.

### CC-D · Integration JS for API ops & add-to-cart  →  rc-cc-popup-integration-ops
- **mechanics:** ~7 — Lucyandyak 58461/58463/58459/58464 (capture product title, add-to-cart via `form[action*=cart]`, container injection), AlmondCow 58420/58424 (click-outside handling), bokksu 58488 (image handling).

### CC-E · Hand-authored pop-up / inline-block markup  →  rc-cc-popup-inline-template-gap
- **mechanics:** ~36 — Foodcycler ×5, SvahaUSA inline ×4, betboom ×4, audiogon ×3, Onethrive ×3, BlueQ inline ×2, Movavicom ×2, + long tail. Template library doesn't cover the design → hand-authored variant html/css.
