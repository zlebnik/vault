STAGE 1 (PLANNING) continues for GitHub issue #{{ISSUE}} — the maintainer left
new comments on the issue instead of (or before) approving your plan. Same
rules and OVERRIDES as before: headless, no plan mode, no AskUserQuestion, no
subagents; guardrails remain binding; every comment you post starts with 🤖.
Still NO code in this stage.

Your plan lives in issue comment id {{PLAN_COMMENT_ID}}.

Steps:
1. Re-read the facts — do NOT trust your memory:
   `gh issue view {{ISSUE}} --comments` (everything after your plan comment is
   feedback), and the reactions on your plan comment:
   `gh api repos/checkcheckonline/checkcheck/issues/comments/{{PLAN_COMMENT_ID}}/reactions`
2. Address every point of feedback. Adjust the plan — usually toward a SMALLER
   diff, never toward a bigger one without an explicit request.
3. Update your existing plan comment IN PLACE (edit `.agent-plan.md`, then):
   `gh api -X PATCH repos/checkcheckonline/checkcheck/issues/comments/{{PLAN_COMMENT_ID}} -F body=@.agent-plan.md`
   Post a separate 🤖 reply comment only if a direct question needs an answer;
   the updated plan comment is otherwise enough.
4. Send a push notification via PushNotification: «План #{{ISSUE}} обновлён —
   жду 👍».

If the feedback makes the task impossible or contradictory, print:
`AGENT_BLOCKED: <one-line reason>`

Finish by printing exactly, as the last line of your final message:
`AGENT_PLAN_POSTED COMMENT_ID={{PLAN_COMMENT_ID}}`
