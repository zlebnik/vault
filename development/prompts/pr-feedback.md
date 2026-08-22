The PR for GitHub issue #{{ISSUE}} was already finished (CI green, Codex
handled) and is awaiting merge — but NEW activity appeared on it. Same rules
and OVERRIDES as before: headless, no plan mode, no AskUserQuestion, no
subagents; guardrails remain binding; every comment you post starts with 🤖.

First re-establish the facts — do NOT trust your memory:
- `gh pr list --head "$(git branch --show-current)"` → the PR number
- `gh pr view <pr> --comments`
- inline review comments: `gh api repos/checkcheckonline/checkcheck/pulls/<pr>/comments`
- reviews: `gh api repos/checkcheckonline/checkcheck/pulls/<pr>/reviews`

Identify the comments that are new since your last work and are not yours
(yours start with 🤖). For each one:
- A change request → implement it minimally (diff discipline still applies: a
  review fix should normally remove or correct code, not add a new special
  case), push, and watch CI in the FOREGROUND (`gh pr checks <pr> --watch`).
  After substantive new commits, comment `@codex review` and wait for the
  round (poll ~2 min, up to 20 min).
- A question → answer it with a 🤖 reply in the same thread; no code needed.

Nothing re-invokes you after your turn ends — background waits are useless;
never end the turn "to wait" for something.

Hard constraints: do NOT merge the PR; if stuck print
`AGENT_BLOCKED: <one-line reason>`.

When everything is addressed and CI is green, send a push notification via
PushNotification with a one-line status, then print exactly, as the last line:
`AGENT_DONE PR=<pr-url>`
