# Stage 2 — Enrich (batched subagents, sonnet)

For each candidate from `windows/<monday>/tickets.md`, read the actual source and
turn it into one enriched entry. Run the **committed workflow**
`workflows/enrich.wf.js` (Workflow tool) with the candidates as `args` — it
batches them ~4 per `sonnet` subagent under this contract and returns validated
entries. Do **not** hand-write an inline fan-out script: the committed one carries
the args-normalization + batch-cap guard that prevents the W29 runaway (see
`SKILL.analysis.md` → "Stage 2 uses the Workflow tool"). Then write the returned
entries to `windows/<monday>/enriched.md`.

## What each entry produces

For a **support** candidate: read the full thread — ClearFeed `requests_get`
(incl. messages) or Slack `slack_read_thread`. For a **mechanic** candidate:
inspect it — query the variant vs its `cabinet_formtemplate` (diff `html`/`css`),
and read the Targeting/Integration JS bodies to see what the code actually does.

Fill these fields per entry:

- **id** — carry over the stage-1 anchor verbatim (`t01` / `s01` / `m01`). It is
  the join key: the registry stores it in `occurrences[].entries` and the
  dashboard resolves the thread link/client/summary from the matching
  `tickets.md` row, so it must match exactly.
- **keep** — `true` only if this is a real **product personalization** matter
  (URL `/personalization/…`, or clear popup/form/targeting/reco context). Set
  `false` for platform/infra (deploys, migrations, host/omega ops), and for
  keyword false positives. Dropped entries stay in the file with a one-line
  reason — never delete them silently.
- **group** — exactly one of: `Bug`, `New client setup`, `Missing feature`,
  `Custom code`, `How-to` (definitions in `SKILL.analysis.md`). **Classify by the
  fix the cause needs, not by today's workaround:** if the product simply can't do
  X, it is `Missing feature` even when the current stopgap is hand-coded. Reserve
  `Custom code` for cases where custom code *is* the accepted mechanism — a
  client-owned script failing, or genuinely one-off hand-coding — plus every
  DB custom-code mechanic. Use `How-to` only for a pure product-knowledge /
  clarification question with no underlying defect or gap.
- **root_cause** — written as a **user story**:
  `As a <role>, I <need / hit> <situation> because <underlying reason>.`
  This is the *why it existed*, not a restatement of the symptom.
- **current_solution** — how it's handled today, if anything exists
  (`hand-written on_render JS`, `CSM edits the variant HTML`, `manual DB fix`,
  workaround doc…). `none` if there is no current workaround.
- **repetitive** — `true` if this is a pattern seen before / likely to recur,
  `false` if genuinely one-off. Judge honestly; do not default to `true`.
- **pain** — one line, the actual user pain in their words where possible.
- **client** — `mindbox_system_name` / tenant, or `?`.
- **date** — creation date (YYYY-MM-DD).
- **url**, **source** (`clearfeed` / `slack` / `db`).

## Custom-code track: enrich at the cluster level, not per mechanic

A week routinely has dozens of custom-code mechanics (the **count is the metric**
— an omega lower bound). Do **not** enrich all of them individually. Instead:

- Group the mechanics by tenant + bucket signature, then **sample** 1–2 per
  distinct pattern (a variant vs its template diff, the targeting `$exec` JS, a
  representative integration-JS body) to characterise *why* the custom code exists.
- Emit one enriched block per **pattern** (e.g. `cc-a`, `cc-b`, …), each naming
  the mechanics/tenants it covers and the underlying product gap.
- Keep the exact bucket counts (distinct / html-css / targeting / integration)
  for stage 3's `custom_code_totals`.

## Keep investigation proportionate

Read enough to name the root cause and the current solution — don't run a full
incident post-mortem. If a thread is clearly an infra/platform incident (deploy,
DB outage, migration), mark `keep:false` with a one-line reason and stop.

## Output format (one block per entry in `enriched.md`)

```
### t01  ·  Bug  ·  keep
- **client:** zone3   **date:** 2026-07-08   **source:** clearfeed
- **url:** <link>
- **root cause:** As a CSM launching a popup, I hit … because …
- **current solution:** none
- **repetitive:** true
- **pain:** "the popup renders twice on mobile"
```

Dropped entry:
```
### t14  ·  — · drop
- **reason:** SMPP delivery incident, not personalization.
```

## Rules

- Read-only. Never print DB creds. Keep the group taxonomy identical to every
  other week.
- If a thread is inaccessible, mark the entry `keep: unknown` with the error and
  move on — don't block the batch.
- Return structured entries from each subagent (schema mirrors the block above)
  so the caller can assemble `enriched.md` deterministically.
