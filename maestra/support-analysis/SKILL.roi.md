# /support-roi — dev-effort what-if for support toil

Authoritative implementation. The launcher at `.claude/skills/support-roi/`
points here. Estimates how much personalization support toil would disappear if
a proposed dev effort shipped. **Read-only** over the registry — never re-fetches
tickets, so it's cheap and re-runnable as often as you like.

## Input

One of:

- **Prose** — a described dev effort ("native cart-drawer slot for reco widgets").
- **Root-cause ids** — one or more `rc-*` ids from the registry.
- **Group** — a whole group (`Bug` / `New client setup` / `Missing feature` /
  `Custom code`).

## Data

Read only `root-causes/registry.json`. Do **not** call ClearFeed, Slack, or the
DB. The registry already holds, per cause: `story`, `group`, `current_solution`,
`total_tickets`, and `occurrences[] = {window, tickets, entries}`.

## Method

1. **Map effort → causes.** Propose which registry causes the effort resolves.
   For prose input this is judgement: match the effort against each cause's
   `story` + `current_solution`. **Present the proposed mapping and get the user
   to confirm before crediting any toil.** Never silently claim a fix kills a
   cause. For `rc-*`/group input the mapping is explicit — skip to step 2.
2. **Sum the toil.** For the confirmed causes, sum `total_tickets` across all
   windows → absolute tickets removed. Divide by the registry-wide total →
   **% of support toil removed**. Build a **per-window breakdown** (tickets
   removed per Monday-week) so the trend of savings is visible, not just a total.
3. **Rank (optional).** If the user supplies an effort tier (S/M/L, or a rough
   cost) per cause or per candidate effort, compute `tickets_removed ÷ effort`
   and rank candidates. This is the quantified successor to "top-2 next steps."
4. **Caveat.** State assumptions and confidence: the registry is omega-only and
   only as complete as the weeks that have been run; a fix rarely removes 100% of
   a cause's tickets — note the assumed coverage.

## Output

Write `roi-reports/<effort-slug>.md`, committed. Include:

- The effort, and the confirmed cause→effort mapping (with `rc-*` ids).
- Tickets removed: absolute + % of total toil.
- Per-window breakdown (table: week | tickets removed).
- The credited causes with links back to their registry entries / threads.
- Assumptions + confidence note, and the ROI ranking if effort tiers were given.

Also print a short summary to the chat. Do not modify the registry or any window
files — this skill only reads them.
