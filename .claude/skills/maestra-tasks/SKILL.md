---
name: maestra-tasks
description: Use when the user asks to add, update, or roll over tasks in maestra/tasks.md, mentions "tasks" or "todo" in the vault, asks for a daily rollover/cleanup of completed Maestra tasks, or asks to "check Slack threads" / "scan Slack" / "update task list from Slack".
---

# Maestra Tasks

Personal task list in `maestra/tasks.md`. Daily rollover moves completed `[x]` items into `maestra/completed/YYMMDD.md`. Source of new tasks is Slack — see "Scanning Slack" below.

Gleb's Slack user_id: `U085GRRHC3V`.

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

### Scanning Slack for new tasks
Trigger: user asks to "check Slack threads", "update task list from Slack", "scan Slack", or starts a new day and asks for an updated list.

**Run all of these queries in parallel — do NOT rely on a single filter:**

1. `from:<@U085GRRHC3V> after:YYYY-MM-DD` — threads where Gleb already replied (his own outgoing activity).
2. `<@U085GRRHC3V> after:YYYY-MM-DD -from:<@U085GRRHC3V>` — threads where Gleb is **mentioned** but hasn't replied yet. **This is the one easy to miss.** ClearFeed-routed tickets, CSM asks, и любые @-tag-и приходят сюда.
3. `to:me after:YYYY-MM-DD` — DM-style routed messages (often returns 0, but cheap to include).
4. `in:#product-support <@U085GRRHC3V> after:YYYY-MM-DD` и `in:#product-support-triage <@U085GRRHC3V> after:YYYY-MM-DD` — основные саппорт-каналы с ClearFeed-тикетами (CF-NNNN). Часто там mention’ы от Aliaksandr/Julia/Philipp/Alex Glazkov/Sergey/Konstantin.

Date for `after:` = day before last rollover (т.е. чтобы не пропустить вечерние тикеты после прошлого скана).

**Triage rules:**
- ClearFeed ticket (CF-NNNN) с явным «high priority» / «к [date]» / упоминанием суммы сделки → ставь в top of `Active — my move` с тегом `_(high prio, к ...)_`.
- Mention без явного запроса (просто tag в обсуждении) → не задача, пропускай.
- Mention с прямым вопросом / запросом помощи → задача.
- Thread где последнее сообщение от Gleb’а и он спросил/обещал что-то → задача (он же owe-er).
- Thread где Gleb ответил и закрыл (ClearFeed: Ticket was moved to Solved) → не задача.

**Дедуп:** перед добавлением проверь, нет ли задачи с тем же CF-номером или тем же thread_ts в `tasks.md` или recent `completed/*.md`.

## What not to do

- Don't auto-rollover without being asked. The user controls the cadence.
- Don't rewrite/reformat unrelated tasks while doing an operation.
- Don't drop links or context when moving items — copy the whole block.
- Don't create `completed/YYMMDD.md` empty. If nothing rolled, no file.
- Don't reorder tasks or "improve" wording unless asked.
- **Don't rely on a single Slack search filter when scanning for new tasks.** `from:<@gleb>` alone misses threads where он только tagged. `to:me` alone почти всегда пусто. Always combine the queries in "Scanning Slack" — пропуск high-prio тикета (e.g. CF-1061) — главный fail-mode этого скилла.

## Edge cases

- **`[x]` task with no body** — rollover just the single line.
- **Multiple completions across sections** — group in destination file by origin section comment.
- **Date format** — always `YYMMDD` (260518), not `YYYY-MM-DD`, for the filename. Heading inside file uses `YYYY-MM-DD`.
- **User marks then unmarks** — only `[x]` items get rolled. `[ ]` stays.
