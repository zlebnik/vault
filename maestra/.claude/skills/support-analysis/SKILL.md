---
name: support-analysis
description: >-
  Weekly (Mon–Sun) analysis of personalization support toil + custom-code
  mechanics. Given a date or ISO week, finds all support tickets/threads
  (ClearFeed + Slack) and custom-code mechanics (omega DB) created in that week,
  enriches each into a root cause written as a user story plus its current
  solution, accumulates a cross-window root-cause registry, and updates the
  merged weekly dashboard. Read-only over all sources. Invoke when the user asks
  to run the support-toil analysis, process a week, or refresh the toil tracker.
---

# support-analysis (launcher)

The full implementation lives in the project, committed and human-readable, at:

**`/Users/kovalev/vault/maestra/support-analysis/SKILL.analysis.md`**

Read that file in full and follow it exactly. It defines a 5-stage pipeline
(preflight → find → enrich → root-causes → dashboard) and references the stage
prompts in `support-analysis/prompts/`.

**Argument:** pass through whatever the user gave (a date like `2026-07-08`, an
ISO week like `2026-W28`, or a Monday date). The pipeline snaps it to the
containing Monday–Sunday week. No argument → default to the most recent
*complete* week.

Do not start any stage until you have read `SKILL.analysis.md`.
