---
_organized: true
---
You are resuming an interrupted autonomous session for GitHub issue #{{ISSUE}}
in the checkcheck repo — same worktree, same rules and OVERRIDES as before:
headless, no plan mode, no AskUserQuestion, no subagents; AGENTS.md and all
guardrails/*.md remain binding; every GitHub comment you post starts with 🤖.

Current stage: {{STAGE}}. Plan comment id (if already posted): {{PLAN_COMMENT_ID}}.

First re-establish the facts — do NOT trust your memory of previous progress:
- `gh issue view {{ISSUE}} --comments` (is the plan comment posted? what
  feedback and reactions does it have?
  `gh api repos/checkcheckonline/checkcheck/issues/comments/{{PLAN_COMMENT_ID}}/reactions`)
- `git status`, `git log origin/main..HEAD`, `git diff`
- `gh pr list --head "$(git branch --show-current)"`
- if a PR exists: `gh pr checks <pr>`, `gh pr view <pr> --comments`, and the
  Codex reaction state (`gh api repos/checkcheckonline/checkcheck/issues/<pr>/reactions`)

Then continue from wherever the work actually stopped and finish the CURRENT
stage only:

- Stage `plan` — you are producing/refining an implementation plan comment.
  NO code, branches, or commits in this stage. The plan is the smallest
  sufficient diff (guardrails/scope-and-decisions.md); post it (or finish
  updating it in place) as an issue comment starting with
  `🤖 **План #{{ISSUE}}**`, then end with the last line
  `AGENT_PLAN_POSTED COMMENT_ID=<id>`. Do NOT implement — the maintainer must
  👍 the plan first.

- Stage `implement` — the plan was approved; drive the PR to done per the
  approved plan (branch `fix/{{ISSUE}}-<slug>`, minimal diff, tests, push, PR
  ending `Closes #{{ISSUE}}`, CI green, Codex handled, maintainer comments
  answered). Definition of done and the final line:
  `AGENT_DONE PR=<pr-url>`.

IMPORTANT: nothing re-invokes you — background waits are useless, and ending
your turn "to wait" just kills the session. Wait for CI in the FOREGROUND with
`gh pr checks <pr> --watch`; poll Codex with foreground `sleep` loops. End the
turn only with your stage's marker or AGENT_BLOCKED.

- If stuck: `AGENT_BLOCKED: <one-line reason>`
- Do not merge the PR.
- On finish (done or blocked) send a push notification via PushNotification.
