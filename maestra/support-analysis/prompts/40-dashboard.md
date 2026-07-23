# Stage 4 — Dashboard

The dashboard is **generated deterministically** by the committed builder
`support-analysis/build_dashboard.js` — do not hand-assemble the data. It reads:

- `root-causes/registry.json` — authoritative accumulator (per-cause
  `occurrences` + `custom_code_totals`). Everything numeric is derived from it.
- each `windows/<monday>/tickets.md` — the per-entry thread index (pipe rows,
  see stage 1) that supplies the thread **links, client, and one-line summary**.

It writes three outputs (all committed, diff-readable):

- `dashboard/data.json` — machine-readable, `schemaVersion: 2` (also read by
  `/support-roi`).
- `dashboard/index.html` — the same JSON injected into the
  `<script id="toil-data">` block; the chart/JS around it is hand-maintained and
  the builder only replaces that one block, so it opens straight from a served dir.
- `root-causes/registry.md` — human-readable ranked registry.

## How to run it

Prerequisite: stage 3 has upserted this week into `registry.json` (occurrences
+ `custom_code_totals`) and stage 1 wrote `windows/<monday>/tickets.md`.

```
node support-analysis/build_dashboard.js
```

That's the whole update. It prints a per-window check (support groups sum to
`supportTickets`, entry counts, custom-code totals, and how many entries resolved
a thread URL). All windows must show `✓` and the final line must say `sums OK`.

Do **not** hand-edit `data.json`, the `#toil-data` block, or `registry.md` —
re-run the builder instead. Per-window `support`-by-group and `customCode` are
derived from the registry, so the registry is the only place to correct a number.
`updated` defaults to the latest window's Monday; override with `DASH_UPDATED=YYYY-MM-DD`.

## What the page renders (schemaVersion 2)

- **KPI cards** — latest week's total tickets, per-group split, custom-code total
  (labeled omega lower bound), distinct recurring causes.
- **Weekly chart** — stacked bars per Mon–Sun week (the 5 groups, fixed colors:
  Bug `#a32d2d`, New client setup `#185fa5`, Missing feature `#534ab7`, Custom
  code `#0f6e56`, How-to `#b26a00`), with custom-code mechanics as an overlaid
  line on a second y-axis (mechanics ≠ tickets — different unit). Every bar
  dataset needs `type:"bar"` or the mixed chart throws at runtime.
- **Per-week detail (click a bar)** — clicking any week's column opens a panel
  below the chart listing that week's support tickets: group pill · client ·
  ticket summary (↳ matched root cause) · **↗ thread link**. Defaults to the
  latest week on load. Driven by each window's `entries[]`.
- **Recurring causes** — table ranked by cumulative tickets. Rows with threads
  are **expandable**: click a row to reveal every contributing thread (week ·
  client · summary · ↗ link). Driven by each cause's `threads[]`.

Entries/threads carry a real thread URL only where the week's `tickets.md` has
one; otherwise they render as "no link" (honest gap, e.g. lighter backfill weeks).

## Provenance line

Footer states: sources (ClearFeed coll 4 + Slack `#csm-support` + omega DB),
omega-only lower bound for custom code, and that windows are comparable only while
scope is fixed. If any week was run on a single track or `--allow-partial`, mark it.

## Verify the rebuild

1. The builder's own output: all windows `✓`, final line `sums OK`.
2. **Render-check** if a Chrome browser is connected — a mixed bar+line Chart.js
   config throws at runtime (e.g. a dataset missing `type`) in a way static JSON
   checks can't catch. The extension can't open `file://`; serve the dir over
   `python3 -m http.server 8787` and open `localhost:8787`. Confirm: zero console
   errors, chart + recurring table draw, **clicking a bar** opens the week panel
   with working thread links, and **expanding a recurring row** shows its threads.
3. If no browser is connected, run the JS through a headless DOM shim (stub
   `document` + `Chart`) to confirm the render functions don't throw, then say the
   live render wasn't verified.
