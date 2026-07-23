# support-analysis

Repeatable, weekly analysis of **personalization support toil** + **custom-code
mechanics**, driven by two Claude Code skills. Each run processes one fixed
Monday–Sunday week, accumulates a cross-window root-cause registry, and updates a
merged dashboard. All outputs are committed markdown/JSON — that's the shareable
artifact.

## Two skills

| Skill | What it does |
|-------|--------------|
| **`/support-analysis <week>`** | Runs the 5-stage pipeline for one week: preflight → find → enrich → root-causes(+reconcile) → dashboard. |
| **`/support-roi <effort>`** | Read-only what-if: given a dev effort / root-cause id(s) / group, estimates how much support toil would disappear if it shipped. |

Authoritative logic: `SKILL.analysis.md`, `SKILL.roi.md`. The `.claude/skills/*`
entries are thin launchers so `/support-analysis` and `/support-roi` are
invokable; they just point back here.

## Weekly window

Windows are **ISO calendar weeks, Monday 00:00 → Sunday 23:59** — fixed
boundaries so weeks are comparable and dedup-able. Any date snaps to its week; the
**Monday date is the canonical key** (`2026-07-06`, ISO `2026-W28`). No argument
→ most recent complete week. A still-running week warns unless `--allow-partial`.

## Pipeline (5 stages)

0. **Preflight** — gate on ClearFeed, Slack, and the omega DB being reachable.
   Refuses to run (no silent fallback) if a required source is down.
1. **Find** (cheap model) — enumerate all candidate tickets/threads + custom-code
   mechanics for the week. List only.
2. **Enrich** (batched subagents via the Workflow tool) — read each thread /
   inspect each mechanic; write a root cause **as a user story** + its current
   solution + group.
3. **Root causes + reconcile** — cluster into distinct causes, then merge into
   the accumulating `root-causes/registry.json` (matched vs new).
4. **Dashboard** — upsert the week into `dashboard/data.json`, rebuild
   `dashboard/index.html`.

## Groups (fixed taxonomy)

`Bug` · `New client setup` · `Missing feature` · `Custom code`. Definitions live
in `SKILL.analysis.md` and never change between weeks.

## Layout

```
SKILL.analysis.md      /support-analysis implementation
SKILL.roi.md           /support-roi implementation
prompts/               one file per pipeline stage (00–40)
windows/<monday>/       per-week outputs: tickets.md, enriched.md, root-causes.md
root-causes/           registry.json (source of truth) + registry.md (generated view)
roi-reports/           /support-roi outputs
dashboard/             data.json (source of truth) + index.html (generated, opens from file://)
```

## Sources & connections (insist on these before a run)

- **ClearFeed MCP** — collection 4 `product-support`. Re-auth via `/mcp` if the
  token has expired.
- **Slack MCP** — channel `#csm-support` (`C089G0JMXJP`), matched by
  `/personalization/` links.
- **Omega DB** (read-only) — `tsh proxy app db-personalization-omega-us --port
  15432` + Vault reader role `db-reader-personalization-omega-us`
  (`VAULT_ADDR=https://vault.maestra.io`). Reader creds only; **never printed or
  committed**.

## Limitations

- Omega is **one shard** → every custom-code count is a **lower bound**.
- Windows are comparable **only** while sources, queries, and group definitions
  stay fixed. Any scope change is noted on the affected week.
- Slack recall is limited to messages carrying a `/personalization/` link.
