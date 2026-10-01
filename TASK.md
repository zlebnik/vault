# CF-2541 — Уход от per-domain форм (omega)

Контекст: Кирилл Кошель, #dev-mindbox 01.10.2026.
Thread: https://maestraio.slack.com/archives/C09HTKSQS4U/p1790838066779799
Mattermost context: https://mindbox.time-messenger.ru/mindbox/pl/18ico81wk3t63bapnmzcit9ken

## Суть
На omega у одного тенанта остались незапущенные per-domain формы. Нужно у этого тенанта обнулить `site_id` на форме, чтобы форма перестала быть привязана к конкретному домену. Это финализация миграции omega — ровно то, о чём «уход от per-domain форм» на сегодня.

## Что уже есть
- Кирилл приложил md-файл с запросами (SQL): `omega-perdomain-finalization.md` в треде, File ID `F0C5WEY487L`.
- Говорит: «можно руками или агенту отдать».

## Что сделать (в этой сессии)
1. **Положи файл в cwd руками:** скачай `omega-perdomain-finalization.md` из Slack треда (ссылка выше) и сохрани в этот worktree под тем же именем.
2. Прочитай его. Разложи что это за запросы: SELECT'ы для проверки/отбора, UPDATE'ы для обнуления, какой БД (personalization-api? popmechanic-backend? Nexus?), какой тенант.
3. Прежде чем что-то выполнять — проверь обзор:
   - какая БД, какой engine (PG/MSSQL/CH?) — через скилл `database-tools:db-connect`
   - читающие запросы прогони через `database-tools:query-database` — убедись что targeting верен (один тенант, N форм, ожидаемый site_id до → NULL)
   - прикинь риск: что ещё в коде/схеме WHERE'ит `site_id` на формах (grep в репе), есть ли FK, кэши
4. Как только убедился в scope — вернись к триажной сессии (окно `triage` в tmux-сессии `maestra`) и покажи:
   - сколько строк затронется
   - какой тенант
   - верификационный SELECT + UPDATE отдельно
   - любые риски
   Жду явного «ok, пускай» от юзера перед UPDATE.
5. После применения — POST результат в CF-2541 тред через `mcp__claude_ai_ClearFeed__requests_post_message` (secondary_id: 2541), apdate state → solved если всё, и в worktree оставь run.md с запросами которые реально отработали + их выводом.

## Правила
- Это prod-БД (omega). Не запускай UPDATE/DELETE/INSERT без явного подтверждения юзера.
- Если файл противоречит сути (вместо SELECT/UPDATE там что-то DDL / мультитенант) — стоп, сообщи триажу, не придумывай.
- Не менять код в репах — только БД-операции. Если из разбора окажется что нужен code change — вернись в триаж.
