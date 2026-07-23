# Stage 3 — Root causes + registry reconcile

Two outputs: this week's grouped root causes, and the accumulated cross-window
registry that they feed into. Only `keep: true` entries count.

## Part A — This week's causes → `windows/<monday>/root-causes.md`

Cluster the kept entries into **distinct root causes** (multiple tickets can share
one cause). Group by the four groups. For each cause list its member entries
(links back to `enriched.md` anchors) and the ticket count.

```
## Missing feature

### Reco widget can't render in a cart drawer without custom JS   [matched: rc-reco-cart-drawer]
- tickets: 3  (t04, t09, m02)
- story: As a CSM, I need the reco widget inside the cart drawer, but the product
  has no slot for it, so we inject on_render JS per client.
- current solution: hand-written on_render JS
```

Tag every cause with its registry decision: **`[matched: rc-…]`** or **`[new]`**.

## Part B — Reconcile into `root-causes/registry.json`

1. Load `registry.json`.
2. For each of this week's causes, decide **matched vs new**:
   - *matched* — same underlying cause as an existing entry (wording may differ;
     judge by `story` + `current_solution`, not exact text). Reuse its `id`.
   - *new* — mint a stable kebab id: `rc-<group-initial>-<slug>`
     (e.g. `rc-mf-reco-cart-drawer`). Keep it short and descriptive.
3. Update the entry:
   - append an occurrence `{ "window": "<monday>", "tickets": <n>, "mechanics": <n>, "entries": [links] }`
     — occurrences carry **both** units: `tickets` (support threads) and
     `mechanics` (omega custom-code mechanics evidencing this cause).
   - recompute `total_tickets` and `total_mechanics` (sums), `first_seen`
     (earliest window), `last_seen` (latest window)
   - keep the best `story`, `group`, `kind` (`support`|`custom-code`|`both`),
     `current_solution` (update if this week's is clearer); leave `proposed_fix` /
     `effort` untouched (set by hand or by `/support-roi`).
4. **Idempotency:** if an occurrence for `<monday>` already exists (re-run of the
   same week), replace it — never double-count.
5. Also upsert this window's exact custom-code figures into the top-level
   `custom_code_totals` array: `{ window, distinct, htmlcss, targeting,
   integration, created_in_window, shard }`. Per-cause `mechanics` counts
   **overlap** (one mechanic can exhibit several patterns) and must **not** be
   summed as if exact — `custom_code_totals` holds the authoritative
   non-overlapping numbers.

Registry entry shape (schemaVersion 2):
```json
{
  "id": "rc-mf-reco-cart-drawer",
  "group": "Missing feature",
  "kind": "both",
  "story": "As a CSM, I need the reco widget inside the cart drawer …",
  "current_solution": "hand-written on_render JS",
  "proposed_fix": null,
  "effort": null,
  "clients": ["lucyandyak", "Deako"],
  "occurrences": [
    { "window": "2026-07-06", "tickets": 3, "mechanics": 4, "entries": ["windows/2026-07-06/enriched.md#t04"] }
  ],
  "total_tickets": 3,
  "total_mechanics": 4,
  "first_seen": "2026-07-06",
  "last_seen": "2026-07-06"
}
```

## Part C — Regenerate `root-causes/registry.md`

Human view from `registry.json`: causes grouped, sorted by `total_tickets` desc,
each showing story, current solution, total tickets, week span, and per-week
occurrence counts (a little inline sparkline of weeks is welcome). This file is
generated — note that at the top.

Keep the JSON the source of truth; the md is a rendering of it.
