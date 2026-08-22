STAGE 2 (IMPLEMENTATION) for GitHub issue #{{ISSUE}}: the maintainer approved
your plan with a 👍. Same rules and OVERRIDES as before: headless, no plan
mode, no AskUserQuestion, no subagents; AGENTS.md and every guardrails/*.md
remain binding; every GitHub comment you post starts with 🤖.

Your approved plan is issue comment id {{PLAN_COMMENT_ID}} — re-read it first:
`gh api repos/checkcheckonline/checkcheck/issues/comments/{{PLAN_COMMENT_ID}} --jq .body`
Also re-read the issue comments after it — the approval may have come with
extra remarks.

Implement EXACTLY the approved plan. If implementation reveals the plan is
materially wrong, do NOT improvise a bigger change: post a 🤖 comment on the
issue explaining what broke, and print `AGENT_BLOCKED: plan invalidated —
<reason>`.

Step by step:
1. Create branch `fix/{{ISSUE}}-<short-slug>` from the current HEAD.
2. Implement the fix AND tests per the plan. Diff discipline:
   - Stay within the plan's «Изменения» file list and near its LOC estimate.
     If the diff balloons past ~2× the estimate, stop — you are almost
     certainly adding defensive code the guardrails forbid.
   - Tests extend the module named in the plan; no one-shot self-verification
     tests (guardrails/testing-and-ci.md).
   - NEVER run the full test suite locally; a scoped local check only via
     `DEBUG=true ./venv/bin/python manage.py test --settings=checkcheck.settings_test <dotted.path>`
     from backend/. CI is the source of truth.
3. Self-review the full diff (`git diff`) against the plan and guardrails.
   Format touched files with `./venv/bin/black` from backend/. Stage explicit
   paths only — never `git add -A`, never stage `.agent-queue`, `backend/.env`
   or `.agent-plan.md`. Conventional commit with scope, issue number in
   parens, body explaining root cause and design, trailer:
   `Co-Authored-By: Claude <model> <noreply@anthropic.com>`
4. Push the branch (`git push -u origin <branch>`) and open a PR whose body
   ends with `Closes #{{ISSUE}}`.
5. Watch CI in the FOREGROUND: `gh pr checks <pr> --watch`. If red — diagnose,
   fix, push, repeat. Nothing re-invokes you after your turn ends — background
   waits are useless; never end the turn "to wait" for something.
6. Wait for the Codex auto-review (inline comments or a 👍 reaction on the
   PR). Poll every ~2 minutes for up to 20 minutes:
   `gh pr view <pr> --comments` and
   `gh api repos/checkcheckonline/checkcheck/issues/<pr>/reactions`.
   Handle findings per guardrails/workflow.md: verify each against the code;
   a fix for a finding should normally remove or correct code, not add a new
   special case — if findings keep growing the diff, question the premise
   instead. Reply in-thread (🤖) for findings you reject. After pushing
   substantive fixes comment `@codex review` and wait again.
7. Codex being satisfied is NOT the end: check the PR once more for any
   maintainer comments (comments not starting with 🤖) and address them the
   same way before finishing.

Hard constraints:
- If you become genuinely stuck, stop and print:
  `AGENT_BLOCKED: <one-line reason>`
- Do NOT merge the PR. The human merges. After you finish, the queue keeps
  watching the PR and will wake you if new comments arrive before the merge.

Notifications: when you finish (done or blocked), send a push notification via
the PushNotification tool with a one-line status for issue #{{ISSUE}}.

Definition of done — ALL of: PR open whose body ends with `Closes #{{ISSUE}}`,
CI green, Codex review received and every finding handled, no unanswered
maintainer comments. Then print exactly, as the last line of your final
message:
`AGENT_DONE PR=<pr-url>`
