# Stage 0 — Preflight gate

Verify every source the requested track needs is reachable **before** doing any
work. If a required source is down, **stop and report exactly how to fix it** —
do not silently fall back to a mirror or a partial run.

Never print, echo, or commit any credential or token in any check below.

## ClearFeed (support track)

Make one cheap call (e.g. list collections, or an `insights_query` count over the
window). Confirm collection **4 `product-support`** is visible.

- ✅ returns → green.
- ❌ "requires re-authorization / token expired" → **STOP.** Tell the user to
  reconnect the ClearFeed MCP connector (`/mcp`, then re-auth) and re-run. Do not
  substitute the Slack `#product-support` mirror unless the user explicitly asks
  for the provisional fallback.

## Slack (support track)

Run one cheap `slack_search_public_and_private` (e.g. a `/personalization/` search
scoped to the window). Confirm results come back and channel `#csm-support`
(`C089G0JMXJP`) is searchable.

- ❌ unauthorized / no access → **STOP** with the reconnect instruction.

## Omega DB (custom-code track)

Read-only, reader role only. Steps:

1. Ensure the Teleport app proxy is up (start if needed, leave running):
   `tsh proxy app db-personalization-omega-us --port 15432`
2. Get reader creds (12h lease, **never print them**):
   `VAULT_ADDR=https://vault.maestra.io vault read database/creds/db-reader-personalization-omega-us`
3. Smoke test: `psql "host=127.0.0.1 port=15432 dbname=personalization user=<vault user> sslmode=disable" -c 'SELECT 1'`

- ❌ any step fails → **STOP** with the failing step and remediation. If `tsh`
  needs login: `tsh login --proxy=teleport.maestra.io`. If Vault token expired,
  re-auth Vault first.

> ⚠️ The app + role were renamed with a `-us` suffix ~Jul 2026; the un-suffixed
> `db-personalization-omega` names no longer exist. Prefer the direct
> `tsh proxy app` + `vault read` path above — the `vault_config.sh` / `ensure_vnet`
> helpers have triggered a browser OIDC login and an unexpected k8s-admin
> access-request in the past.

## Gate

- `--track both` (default): all three green required.
- `--track support`: ClearFeed + Slack.
- `--track custom`: DB only.

Only proceed to stage 1 once the required sources are green. Report which sources
were checked and their status in one line before continuing.
