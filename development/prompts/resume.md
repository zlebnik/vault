You are resuming an interrupted autonomous session for GitHub issue #{{ISSUE}}
in the checkcheck repo — same worktree, same rules and OVERRIDES as before:
headless, no plan mode, no AskUserQuestion, no subagents; AGENTS.md and all
guardrails/*.md remain binding.

First re-establish the facts — do NOT trust your memory of previous progress:
- `git status`, `git log origin/main..HEAD`, `git diff`
- `gh pr list --head "$(git branch --show-current)"`
- if a PR exists: `gh pr checks <pr>`, `gh pr view <pr> --comments`, and the
  Codex reaction state (`gh api repos/checkcheckonline/checkcheck/issues/<pr>/reactions`)

Then continue from wherever the work actually stopped and finish it.

IMPORTANT: nothing re-invokes you — background waits are useless, and ending
your turn "to wait" just kills the session. Wait for CI in the FOREGROUND with
`gh pr checks <pr> --watch`; poll Codex with foreground `sleep` loops. End the
turn only with AGENT_DONE or AGENT_BLOCKED.

Same completion contract:
- Definition of done: PR open ending with `Closes #{{ISSUE}}`, CI green, Codex
  review handled. Then print exactly, as the last line: `AGENT_DONE PR=<pr-url>`
- If stuck: `AGENT_BLOCKED: <one-line reason>`
- Do not merge the PR. Do not touch `.github/workflows/`.
- On finish (done or blocked) send a push notification via PushNotification.
