# /support-analysis — weekly personalization support-toil pipeline

Authoritative implementation. The launcher at `.claude/skills/support-analysis/`
points here. Runs one **Monday–Sunday week** end to end and updates the
cross-window registry + dashboard. **Read-only** over every source.

## Argument → week

Accept a date (`2026-07-08`), an ISO week (`2026-W28`), or a Monday date. Snap to
the containing week: **Monday 00:00:00 → Sunday 23:59:59** (local). The Monday
date is the canonical **week key** (e.g. `2026-07-06`) used for the window dir,
the registry occurrences, and the dashboard x-axis.

- No argument → use the most recent **complete** week (last Sunday or earlier).
- If the resolved week is the current, still-running week → **stop and warn**,
  suggest the last complete week. Override only if the user passed `--allow-partial`.

Compute the ISO week label (`2026-W28`) and human range (`06–12 Jul`) once and
carry them through.

## Tracks

Two input domains, same pipeline, one dashboard:

- **support** — tickets/threads from ClearFeed collection 4 (`product-support`) +
  Slack `#csm-support`.
- **custom-code** — mechanics created this week in the omega DB (HTML/CSS,
  Targeting JS, Integration JS buckets).

Default runs **both**. `--track support|custom|both` narrows it. The merged
dashboard expects both over time; if you run only one track, say so in the run
summary so a partial week isn't mistaken for a full one.

## Stages

Run in order. Each references a prompt file — read it before running the stage.

| # | Stage | Prompt | Model | Notes |
|---|-------|--------|-------|-------|
| 0 | Preflight (gate) | `prompts/00-preflight.md` | — | Verify ClearFeed, Slack, DB. Refuse to proceed if any required source is down. |
| 1 | Find | `prompts/10-find.md` | haiku (cheap) | Enumerate only. Writes `windows/<key>/tickets.md`. |
| 2 | Enrich | `prompts/20-enrich.md` | sonnet | Batched subagents via the Workflow tool (~6 entries each). Writes `windows/<key>/enriched.md`. |
| 3 | Root causes + reconcile | `prompts/30-root-causes.md` | inherit | Writes `windows/<key>/root-causes.md`; updates `root-causes/registry.{json,md}`. |
| 4 | Dashboard | `prompts/40-dashboard.md` | inherit | Runs the committed builder `build_dashboard.js` — regenerates `dashboard/data.json` (schemaVersion 2), `dashboard/index.html`, and `root-causes/registry.md` from the registry + `tickets.md`. |

### Stage 2 uses the Workflow tool

Stage 2 is the fan-out. Invoke the **committed workflow** `workflows/enrich.wf.js`
via the `Workflow` tool, passing the stage-1 candidates as `args` (an array of
`{id, source, secondary_id?|channel_id?+message_ts?, client, title}`). It batches
them ~4 per `sonnet` subagent, each running the `prompts/20-enrich.md` contract,
and returns validated structured entries (deduped to the ids you sent).

The script normalizes `args` (parses it if it arrives as a JSON string) and hard-
asserts it is an array, caps candidates at 100 and batches at 30, and rejects
malformed candidates. **This guard is load-bearing:** the W29 run passed `args`
as a JSON string, an unguarded `slice()` chopped the raw JSON into ~500 fragments,
and the fan-out ballooned to 530 subagents / ~27M tokens before returning. Never
reintroduce an inline enrich script without these guards — use the committed one.

Recover from a failed/partial run via the run's `journal.jsonl` (one result line
per agent) rather than re-running. The rest of the stages run inline.

## Groups (fixed taxonomy — identical every week)

Every kept entry is classified into exactly one:

- **Bug** — product defect; existing feature not working as intended.
- **New client setup** — first-time configuration / onboarding of a mechanic
  that the product should make self-serve.
- **Missing feature** — the product can't do what the client needs; a feature
  gap.
- **Custom code** — resolved by hand-written HTML/CSS/JS (the custom-code track
  lands here too).
- **How-to** — a pure product-knowledge / clarification question with no defect
  or gap (e.g. "which reco presets exclude purchased products?"). A recurring
  how-to signals a docs/clarity gap. (Added as a 5th group after W26 —
  earlier windows carried none except W26 s01, backfilled.)

Definitions never change between weeks — that is what makes windows comparable.

## Outputs (all committed)

```
windows/<monday>/tickets.md       stage 1 — flat found list
windows/<monday>/enriched.md      stage 2 — per-entry root cause (user story) + current solution
windows/<monday>/root-causes.md   stage 3 — this week's causes, grouped, tagged matched:<id>|new
root-causes/registry.{json,md}    stage 3 (json) / stage 4 (md, generated)
dashboard/data.json + index.html  stage 4 — merged weekly chart + per-week detail
build_dashboard.js                stage 4 builder (derives all figures from the registry)
```

## Rules

- **Never print, echo, or commit DB credentials.** Vault creds go to clipboard /
  env only. Same for any token.
- **Read-only everywhere.** Reader Vault role only; no writes to any source.
- **Omega is one shard.** Every custom-code count is an omega-only **lower
  bound** — label it as such in outputs.
- **Windows are comparable only if scope is fixed.** Same sources, same group
  definitions, same queries every week. If you change any of them, note it on the
  affected week so the series break is visible.
- Re-running a week **overwrites** its `windows/<key>/` dir and re-reconciles the
  registry (idempotent by week key — don't double-count).

## Finish

End with a one-screen run summary: week key + range, per-group counts, custom-code
buckets (lower bound), how many registry causes were matched vs new, and the
dashboard path. Do not open a browser unless asked.
