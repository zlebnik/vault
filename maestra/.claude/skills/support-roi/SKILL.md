---
name: support-roi
description: >-
  Dev-effort what-if for personalization support toil. Given a proposed dev
  effort (in prose), one or more root-cause ids, or a whole group, estimates how
  much support toil would disappear if that effort shipped — using the
  accumulated root-cause registry from /support-analysis. Read-only; never
  re-fetches tickets. Invoke when the user asks how much support a fix would
  remove, to prioritise dev work by toil reduction, or for a support ROI/what-if.
---

# support-roi (launcher)

The full implementation lives in the project, committed and human-readable, at:

**`/Users/kovalev/vault/maestra/support-analysis/SKILL.roi.md`**

Read that file in full and follow it exactly. It reads
`support-analysis/root-causes/registry.json` (read-only), maps a proposed dev
effort to the root causes it resolves, and writes a report to
`support-analysis/roi-reports/`.

**Argument:** pass through the user's effort description, `rc-*` id(s), or group
name. If ambiguous, ask which causes the effort is meant to resolve before
crediting any toil to it.

Do not credit toil to a fix until the effort→cause mapping is confirmed.
