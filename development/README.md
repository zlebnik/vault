---
_organized: true
---
# Очередь автономной разработки ЧекЧека

systemd user timer раз в ~5 мин (после конца предыдущего тика) запускает
`queue-runner.sh`. Строго **одна** issue за раз, и новая не берётся, пока PR
текущей не **смержен** (а blocked ждёт человека) — параллелизм поджат во имя
качества.

## Пайплайн задачи

1. **План.** Агент берёт самую старую issue с `agent:ready` (лейбл → `agent:wip`,
   worktree с origin/main) и публикует комментарий `🤖 **План #N**`: root cause,
   точные файлы, тесты, «Не делаю», оценка размера диффа, вопросы. Кода на этой
   стадии нет. Перед планом агент сверяется с **Sentry** (MCP `sentry`, org
   `checkcheck`, проект `python-django`): есть ли ошибка в проде, как часто, с
   какими входами — чтобы в плане были факты, а не гипотезы о прод-данных.
2. **Ожидание 👍.** Тики дешёвые (только gh): реакция 👍 на комментарии плана =
   одобрение; новый человеческий комментарий (не начинающийся с 🤖) → агент
   корректирует план **правкой того же комментария** и снова ждёт.
3. **Реализация.** Строго по одобренному плану: ветка `fix/N-<slug>`,
   минимальный дифф, тесты, push, PR с `Closes #N`, зелёный CI, Codex-ревью,
   ответы на комментарии мейнтейнера. План поплыл → `AGENT_BLOCKED`, а не
   импровизация.
4. **Ожидание merge.** Лейбл `agent:done`, state живёт дальше: каждый тик
   проверяет новые комментарии в PR (даже после «ок» от Codex) — появились →
   агент просыпается и отвечает/чинит. Merge (человеком) → state очищен,
   worktree снесён, очередь свободна.

## Состояния (лейблы = истина на GitHub)

| Лейбл | Значение |
|---|---|
| `agent:ready` | в очереди; поставь его на issue — агент возьмёт |
| `agent:wip` | в работе (план или код) |
| `agent:done` | PR готов, ждёт merge; **держит очередь** до merge |
| `agent:blocked` | нужен человек; **держит очередь**. Вернуть агенту: снять blocked, поставить ready — та же сессия продолжит |

Локальный state — `state/current.json` (issue, session_id, worktree, phase,
stage, attempts, plan_comment_id, pr_url, last_activity_ts). Worktrees — в
`/home/zlebnik/Projects/checkcheck/worktrees/<N>` (маркер `.agent-queue`);
убираются автоматически после merge/close PR.

Все комментарии агента на GitHub начинаются с `🤖` — только так он отличим от
человека (логин один и тот же). Свои комментарии этим символом не начинай.

## Rate-limit подписки

Детект по тексту «hit your … limit» в результате → backoff 20 мин, задача
остаётся на месте, следующий тик делает `claude --resume` той же сессии.
Провал без rate-limit — до 3 попыток resume на стадию, потом `agent:blocked`
+ комментарий.

## Команды

```bash
./setup.sh [--no-timer] [--prune-stale]   # установка (лейблы, юниты, таймер)
./queue-runner.sh                         # ручной тик
./attach.sh                               # статус задачи и очереди
./attach.sh --take                        # пауза + интерактивный resume сессии
./attach.sh --release                     # вернуть задачу агенту
./attach.sh --done N | --cleanup N        # ручное закрытие / снос worktree
./uninstall.sh [--purge]                  # снять таймер (+ почистить state)
systemctl --user list-timers checkcheck-agent.timer
journalctl --user -u checkcheck-agent -f  # живой лог тиков
```

## Настройка

Всё в шапке `lib.sh`: пути, `ALLOWED_TOOLS` (allow-лист headless-сессии —
расширяй, если агент упирается в денай; `mcp__sentry` целиком) и
`DISALLOWED_TOOLS` (deny сильнее allow: `update_issue` и универсальный
`execute_sentry_tool` — агент Sentry только читает). Sentry MCP живёт в
user-scope `~/.claude.json` с org-scoped URL `…/mcp/checkcheck`; локальный
override в клоне checkcheck с URL без org ломает каталог (остаются только
find_organizations/projects/teams) — не заводи его. `MAX_ATTEMPTS`, `SESSION_TIMEOUT` (3ч),
`RETRY_BACKOFF` (20 мин), `NTFY_TOPIC` (пусто = выключено). Уведомления: push из
самой сессии (PushNotification tool), `notify-send` и комментарии в issue от
раннера.

Тест state machine без токенов: положить JSON в `state/logs/fake.json` и
запустить `AGENT_DRY_RUN=1 ./queue-runner.sh` (GitHub не мутируется, claude не
запускается). Доп. ручки: `AGENT_DRY_RC`, `AGENT_DRY_APPROVED` (0=👍 стоит),
`AGENT_DRY_FEEDBACK`, `AGENT_DRY_PR_ACTIVITY`, `AGENT_DRY_ISSUE_STATE` (CLOSED).
