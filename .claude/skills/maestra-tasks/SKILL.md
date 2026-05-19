---
name: maestra-tasks
description: Use when the user asks to add, update, or roll over tasks in maestra/tasks.md, mentions "tasks" or "todo" in the vault, or asks for a daily rollover/cleanup of completed Maestra tasks.
---

# Maestra Tasks

Personal task list in `maestra/tasks.md`. Daily rollover moves completed `[x]` items into `maestra/completed/YYMMDD.md`.

## File layout

```
maestra/
  tasks.md                 # active list, source of truth
  completed/
    YYMMDD.md              # one file per day, only days with completions exist
```

## tasks.md format

Markdown with checkbox items grouped under section headings (`## Active — my move`, `## Waiting on others`, `## To verify`, etc.). Each task is a `- [ ]` line with a bold title, a one-paragraph context block, and relevant links (Slack thread, Notion, GitLab MR, GitHub issue).

Don't impose a strict schema beyond `- [ ]` / `- [x]`. The user edits this file by hand.

## Operations

### Adding a task
- Pick the right section (or create one).
- Use `- [ ]` + bold title + short context + links.
- Don't reformat existing tasks while adding.

### Marking complete
- Flip `- [ ]` → `- [x]` on the requested item(s). Don't touch anything else.

### Daily rollover
Trigger: user asks to "roll over", "cleanup", "move completed", or starts a new day's session and there are `[x]` items in `tasks.md`.

Steps:
1. Get today's date in `YYMMDD` (e.g. 2026-05-18 → `260518`). Use the actual current date, not a guess.
2. Read `maestra/tasks.md`. Collect every `- [x]` line **plus** its indented continuation lines (context, links, sub-bullets) until the next `- [ ]`, `- [x]`, or blank line followed by a heading.
3. If no completed items → tell the user, do nothing else.
4. Append the collected items to `maestra/completed/YYMMDD.md`:
   - If the file doesn't exist: create with a `# YYYY-MM-DD` heading, then the items.
   - If it exists: append the items under the existing heading (don't duplicate the heading).
   - Preserve section context: prefix each rolled-over item with a comment like `<!-- from: Active — my move -->` on its own line above, so the origin section isn't lost.
5. Remove the same lines from `tasks.md`. Leave the section headings even if they become empty (user can clean them up).
6. Show the user a one-line summary: `Rolled over N task(s) to maestra/completed/260518.md`.

### Listing / showing tasks
Just read `tasks.md` and render. No need to parse into structured data unless the user asks for counts.

## What not to do

- Don't auto-rollover without being asked. The user controls the cadence.
- Don't rewrite/reformat unrelated tasks while doing an operation.
- Don't drop links or context when moving items — copy the whole block.
- Don't create `completed/YYMMDD.md` empty. If nothing rolled, no file.
- Don't reorder tasks or "improve" wording unless asked.

## Edge cases

- **`[x]` task with no body** — rollover just the single line.
- **Multiple completions across sections** — group in destination file by origin section comment.
- **Date format** — always `YYMMDD` (260518), not `YYYY-MM-DD`, for the filename. Heading inside file uses `YYYY-MM-DD`.
- **User marks then unmarks** — only `[x]` items get rolled. `[ ]` stays.
