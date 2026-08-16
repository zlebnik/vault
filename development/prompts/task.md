You are running fully autonomously and headless (`claude -p`, no human present).
OVERRIDE for this session, superseding the "Claude Code specifics" of CLAUDE.md:
do NOT use plan mode, do NOT use AskUserQuestion, do NOT delegate to subagents —
implement everything yourself, in this session, right now. All other repo rules
(AGENTS.md and every guardrails/*.md file) remain fully binding.

Your task: completely resolve GitHub issue #{{ISSUE}} and drive its PR to a
mergeable state.

Context:
- You are in a dedicated git worktree, detached at fresh origin/main. Work only
  inside this worktree. Never touch other branches, worktrees, or issues.
- `backend/venv` is symlinked from the main clone; use `./venv/bin/python` from
  `backend/` for any scoped local test runs.
- You run under a tool allow-list. If a command is denied, find an allowed
  equivalent; if truly impossible, use the AGENT_BLOCKED protocol below.

Step by step:
1. `gh issue view {{ISSUE}} --comments`. Understand the problem; read the
   relevant code, docs/ and guidelines/ before writing anything.
2. Create branch `fix/{{ISSUE}}-<short-slug>` from the current HEAD.
3. Implement the fix AND tests (tests are mandatory — see
   guardrails/testing-and-ci.md). NEVER run the full test suite locally; if a
   scoped local check is genuinely needed, run only a dotted path from backend/:
   `DEBUG=true ./venv/bin/python manage.py test --settings=checkcheck.settings_test <dotted.path>`
   CI is the source of truth.
4. Self-review your full diff (`git diff`) against the issue and guardrails
   before committing. Format touched files with `./venv/bin/black` from
   backend/. Stage explicit paths only — never `git add -A` (and never stage
   `.agent-queue` or `backend/.env`). Conventional commit with scope, issue
   number in parens, body explaining root cause and design, trailer:
   `Co-Authored-By: Claude <model> <noreply@anthropic.com>`
5. Push the branch (`git push -u origin <branch>`) and open a PR whose body
   ends with `Closes #{{ISSUE}}`.
6. Watch CI: `gh pr checks <pr> --watch`. If red — diagnose, fix, push, repeat.
7. Wait for the Codex auto-review (inline comments or a 👍 reaction on the PR).
   Poll every ~2 minutes for up to 20 minutes:
   `gh pr view <pr> --comments` and
   `gh api repos/checkcheckonline/checkcheck/issues/<pr>/reactions`.
   Handle findings per guardrails/workflow.md: verify each against the code,
   fix what is real and in scope, reply in-thread otherwise; after pushing
   substantive fixes comment `@codex review` and wait again.

Hard constraints:
- You MUST NOT create or modify anything under `.github/workflows/` — the gh
  token lacks the `workflow` scope and the push will fail. If the issue cannot
  be solved without workflow changes, stop immediately and print exactly:
  `AGENT_BLOCKED: requires .github/workflows changes — <one-line reason>`
- If you become genuinely stuck for any other reason (need a product decision,
  missing credentials, contradictory requirements), stop and print:
  `AGENT_BLOCKED: <one-line reason>`
- Do NOT merge the PR. The human merges.

Notifications: when you finish (done or blocked), send a push notification via
the PushNotification tool with a one-line status for issue #{{ISSUE}}.

Definition of done — ALL of: PR open whose body ends with `Closes #{{ISSUE}}`,
CI green, Codex review received and every finding handled. Then print exactly,
as the last line of your final message:
`AGENT_DONE PR=<pr-url>`
