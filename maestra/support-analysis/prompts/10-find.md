# Stage 1 — Find (cheap model: haiku)

Enumerate **every candidate entry** created in the week `[Monday 00:00, Sunday
23:59]`. This stage **finds and lists only** — no thread reading, no root-cause
classification (that is stage 2). Cast a wide net; stage 2 drops false positives.

Write results to `windows/<monday>/tickets.md` with the two sections below. One
markdown checkbox row per entry, stable local anchor id (`t01`, `t02`, … for
ClearFeed support; `s01`, `s02`, … for Slack support; `m01`, `m02`, … for
mechanics). Dedupe by id.

**Thread-index contract (required — the dashboard depends on it).** Section A is
the canonical thread index: stage 2 reuses these exact ids as its entry anchors
(`enriched.md#t01`), the registry stores them in `occurrences[].entries`, and the
dashboard builder joins on them to render each ticket's **thread link, client, and
summary**. So every Section-A row **must** carry a real, working thread URL (the
ClearFeed/Slack permalink) — never a placeholder. A missing URL means that ticket
shows "no link" on the dashboard and in the recurring drill-down. Keep ids stable
across re-runs of the same week.

## Section A — Support tickets/threads

**ClearFeed** — collection **4 `product-support`**, `created_after`/`created_before`
= the week. Pull candidates with `requests_search` (personalization keywords:
popup / pop-up, form, targeting, reco / reco-widget, popmechanic / попмех,
inline-block) + `requests_list` for the window, dedupe by request id. Keyword
match is noisy (matches "plat**form**", "in**form**ation") — that's fine here,
stage 2 filters.

**Slack `#csm-support`** (`C089G0JMXJP`) — **link + keyword** recall: match
messages/threads in the window that either carry a `/personalization/` link **or**
mention personalization keywords (reco / reco-widget / recommendation / popup /
pop-up / inline-block / widget / targeting / попап / виджет / рекоменд). Run
per-keyword searches (Slack has no boolean OR). Attribute a thread to the week of
its **in-window activity**, even if the parent message predates the window. Add as
`source=slack`, dedupe against ClearFeed. (Enrichment drops keyword false positives.)

Row format:
```
- [ ] t01 | clearfeed | <url> | <client|?> | <YYYY-MM-DD> | <one-line title>
```

## Section B — Custom-code mechanics (omega DB, read-only)

Run the three bucket queries below, scoped to the week and `deleted = false`.
Verify column names against the live schema first (Django can drift). Join
`app_accountmatch` for the tenant name. **Omega is one shard → lower bound.**

Use `f.created >= DATE '<monday>' AND f.created < DATE '<sunday>' + 1`.

**HTML/CSS** (non-empty variant markup = custom):
```sql
SELECT DISTINCT f.id, f.created, am.mindbox_system_name
FROM cabinet_form f
JOIN cabinet_formvariant v ON v.form_id = f.id AND v.deleted = false
LEFT JOIN app_accountmatch am ON am.account_id = f.account_id
WHERE f.deleted = false AND f.created >= DATE '<monday>' AND f.created < DATE '<sunday>' + 1
  AND (COALESCE(v.html,'') <> '' OR COALESCE(v.css,'') <> ''
    OR COALESCE(v.button_html,'') <> '' OR COALESCE(v.button_css,'') <> '');
```

**Targeting JS** (`"field":"js"` node in the filter tree):
```sql
SELECT f.id, f.created, am.mindbox_system_name
FROM cabinet_form f
JOIN cabinet_newtargeting t ON t.form_id = f.id OR t.test_group_id = f.test_group_id
LEFT JOIN app_accountmatch am ON am.account_id = f.account_id
WHERE f.deleted = false AND f.created >= DATE '<monday>' AND f.created < DATE '<sunday>' + 1
  AND jsonb_path_exists(t.filter, '$.**.field ? (@ == "js")');
```

**Integration JS** (any non-empty JS body):
```sql
SELECT f.id, f.created, am.mindbox_system_name
FROM cabinet_form f
JOIN cabinet_integration i ON i.form_id = f.id
JOIN cabinet_javascriptintegration ji ON ji.integration_ptr_id = i.id
LEFT JOIN app_accountmatch am ON am.account_id = f.account_id
WHERE f.deleted = false AND f.created >= DATE '<monday>' AND f.created < DATE '<sunday>' + 1
  AND (COALESCE(ji.on_render,'') <> '' OR COALESCE(ji.on_show,'') <> ''
    OR COALESCE(ji.on_success,'') <> '' OR COALESCE(ji.on_close_success,'') <> ''
    OR COALESCE(ji.on_close_fail,'') <> '');
```

Resolve `f.id` → the `app_formproxy` mechanic id/type to build the
`/personalization/{type}/{id}/` link (host from `am`). A mechanic can appear in
more than one bucket — list all its buckets on one row.

Row format:
```
- [ ] m01 | <proxy-url> | <mindbox_system_name|?> | <YYYY-MM-DD> | <bucket(s): html/css,targeting,integration>
```

## Output header

Start `tickets.md` with: week key, ISO week label, range, track(s) run, and the
raw candidate counts per source. Then Section A, then Section B.
