You are running fully autonomously and headless (`claude -p`, no human present).
OVERRIDE for this session, superseding the "Claude Code specifics" of CLAUDE.md:
do NOT use plan mode, do NOT use AskUserQuestion, do NOT delegate to subagents.
All other repo rules (AGENTS.md and every guardrails/*.md file) remain binding —
guardrails/scope-and-decisions.md is the core one for this stage.

Your task — STAGE 1 (PLANNING) for GitHub issue #{{ISSUE}}: research the issue
and post an implementation plan as an issue comment for the maintainer to
approve. In this stage you write NO code: no branches, no edits to repo files,
no commits, no pushes.

Context:
- You are in a dedicated git worktree, detached at fresh origin/main. Never
  touch other branches, worktrees, or issues.
- Every GitHub comment you post MUST start with the 🤖 character — that is how
  the queue tells your comments from the maintainer's (same login).
- You run under a tool allow-list. If a command is denied, find an allowed
  equivalent.

Steps:
1. `gh issue view {{ISSUE}} --comments`. Read the relevant code, docs/,
   guidelines/ and guardrails/ until you understand the root cause.
2. Check production reality in Sentry (MCP server `sentry`, org `checkcheck`,
   project `python-django`; read-only — never resolve/assign/ignore issues):
   `mcp__sentry__search_issues` / `search_events` for the exception, view,
   task or endpoint from the issue; `get_sentry_resource` for the stack trace
   and tags of the relevant Sentry issue (`analyze_issue_with_seer` only for
   a genuinely confusing trace). Use it to answer with FACTS the questions
   you would otherwise have to assume: does the error actually happen in
   prod, how often, since which release, with what inputs. No match in
   Sentry is also a fact — say so. Keep this to a few targeted queries.
3. Draft the plan. Hard requirements (guardrails/scope-and-decisions.md):
   - The SMALLEST diff that resolves the issue and covers it with tests.
     Diff size is a design constraint — no compat shims for values a data
     migration rewrites, no defensive code for hypothetical states.
   - If anything depends on the state of production data or on a product
     decision — do NOT design around it. First try to settle it from Sentry
     (step 2); what Sentry cannot answer goes into the «Вопросы» section with
     a recommended answer, and the plan itself stays the no-assumptions
     variant.
4. Write the plan body to `.agent-plan.md` in the worktree root (this file is
   never staged or committed). Plan format, in Russian, body starting exactly
   with `🤖 **План #{{ISSUE}}**`:
   - **Проблема** — root cause in 1–3 sentences; cite the Sentry issue
     short id(s) and frequency if found (`PYTHON-DJANGO-XXX`, N events /
     M users за период), or «в Sentry не встречается».
   - **Изменения** — exact file paths and what changes in each.
   - **Тесты** — which existing test module is extended, which invariants are
     asserted (one-shot self-verification tests are forbidden — see
     guardrails/testing-and-ci.md "Tests must earn their keep").
   - **Не делаю** — adjacent things deliberately left out of scope.
   - **Ожидаемый размер** — rough LOC estimate of the final diff.
   - **Вопросы** — only if genuinely needed; each with a recommended answer.
5. Post it and capture the comment id:
   `gh api "repos/checkcheckonline/checkcheck/issues/{{ISSUE}}/comments" -F body=@.agent-plan.md --jq .id`
6. Send a push notification via PushNotification: «План по issue #{{ISSUE}}
   готов — жду 👍».

Hard constraints:
- Never react to or approve your own plan; never start implementing. The
  maintainer approves with a 👍 reaction on your comment — a later session
  will do the implementation.
- If you become genuinely stuck, stop and print:
  `AGENT_BLOCKED: <one-line reason>`

Finish by printing exactly, as the last line of your final message:
`AGENT_PLAN_POSTED COMMENT_ID=<id>`
