---
_organized: true
---
# Maestra — Workflow

Personal task tracking for Maestra work. Источник задач — Slack. Жильё — `tasks.md`, архив — `completed/YYMMDD.md`. Автоматизация — скилл `maestra-tasks` в `~/vault/.claude/skills/`.

## Files

- `tasks.md` — single source of truth: Active / Waiting / To verify / Scheduled.
- `completed/YYMMDD.md` — дневной архив. Создаётся только если есть что закрывать.
- `.claude/skills/maestra-tasks/SKILL.md` — правила scan, rollover, triage.

## Daily cycle

**Утро** — «wrap up yesterday, get today's tasks»:
1. Roll `[x]` в `completed/YYMMDD.md` (вчерашняя дата).
2. Slack scan (см. ниже).
3. Сurfaced scheduled-задачи на сегодня → Active.

**В течение дня** — пользователь триажит:
- «X — done» → `[x]`
- «X — перенеси на [date]» → в Scheduled с датой
- «X — мяч на стороне Y» → To verify
- «X — не на мне» → закрыть или to verify

## Slack scan — главное правило

**Single-filter searches врут.** CF-1061 пропустил потому что `to:me` вернул 0, а `from:gleb` пропускает mentions без ответа. Всегда запускать в параллель:

1. `<@U085GRRHC3V> after:DATE -from:<@U085GRRHC3V>` — упоминания без ответа Глеба. **Самый важный.**
2. `from:<@U085GRRHC3V> after:DATE` — исходящие (обещания, in-flight asks).
3. `to:me after:DATE` — DMs.
4. `in:#product-support <@U085GRRHC3V>` и `in:#product-support-triage` — ClearFeed-тикеты.

`DATE` = день перед последним сканом (поймать вечерние тикеты после прошлого прохода).

## Triage

**Task:**
- Прямой ask / вопрос
- Последнее сообщение от Gleb с обещанием
- ClearFeed-тикет (CF-NNNN)
- High-prio markers: deadline, churn risk, размер сделки

**Not a task:**
- Mention в обсуждении вскользь
- ClearFeed: Solved/Closed
- Celebration / FYI / announcement

## Sections

- **Active — my move** — ход на тебе, сегодняшний pile
- **Waiting on others** — почти не используется, обычно лучше "To verify"
- **To verify** — ход не на тебе, ждём чужой проверки/ответа
- **Scheduled / future** — задачи с датой или условным триггером

## Item format

```
- [ ] **Title** _(опц. флаги: high prio / due today / overdue +Nd)_ — assignee/source
  Один параграф контекста: что/почему/текущее состояние.
  Ссылки: Slack thread, GitHub issue, Notion, GitLab MR, customer URL.
```

Жёсткой схемы нет, пользователь правит руками.

## Rollover

- Filename: `YYMMDD.md` (260525). Heading внутри: `YYYY-MM-DD`.
- Сохранять origin section как `<!-- from: Active — my move -->` над каждым item.
- Пустой rollover → файла нет.
- Не катить автоматически — пользователь контролирует ритм.

## Communication

- Russian/English mix окей.
- Профанити нормально.
- Всегда давать stats line: `N active · M to verify · K scheduled = T open`.
- ⚠️ для urgent / risk.
- Не задавать уточняющих, если пользователь сказал «без вопросов».
- Кратко. Пользователь читает дифф, развёрнутый narration не нужен.

## Don'ts

- Не катить автоматом.
- Не переформатировать соседние задачи при правке одной.
- Не терять контекст/ссылки при переносе.
- Не создавать пустые `completed/YYMMDD.md`.
- Не полагаться на один Slack filter.
- Не делать задачи из celebrations / FYI / announcements.
- Не переупорядочивать задачи без запроса.

## User

Gleb Kovalev, Slack `U085GRRHC3V`. Maestra (бывш. Mindbox). Frontend / personalization / pixel / Shopify integration.
