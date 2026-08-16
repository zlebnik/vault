# Очередь автономной разработки ЧекЧека

systemd user timer раз в ~15 мин (после конца предыдущего тика) запускает
`queue-runner.sh`: берёт **ровно одну** issue с лейблом `agent:ready` из
`checkcheckonline/checkcheck`, разворачивает git worktree и гоняет headless
`claude -p` полный цикл — ветка → фикс + тесты → self-review → push → PR с
`Closes #N` → зелёный CI → отработанное Codex-ревью. Merge — за человеком.

## Состояния (лейблы = истина на GitHub)

| Лейбл | Значение |
|---|---|
| `agent:ready` | в очереди; поставь его на issue — агент возьмёт |
| `agent:wip` | в работе; пока есть wip — новых не берём |
| `agent:done` | PR готов (CI зелёный, Codex отработан), ждёт merge |
| `agent:blocked` | нужен человек (детали — в комментарии к issue) |

Локальный state — `state/current.json` (issue, session_id, worktree, phase,
attempts). Worktrees — в `/home/zlebnik/Projects/checkcheck/worktrees/<N>`
(маркер `.agent-queue`); убираются автоматически после merge/close PR.

## Rate-limit подписки

Детект по тексту «hit your … limit» в результате → backoff 20 мин, задача
остаётся в очереди, следующий тик делает `claude --resume` той же сессии.
Провал без rate-limit — до 3 попыток resume, потом `agent:blocked` + комментарий.

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
расширяй, если агент упирается в денай), `MAX_ATTEMPTS`, `SESSION_TIMEOUT` (3ч),
`RETRY_BACKOFF` (20 мин), `NTFY_TOPIC` (пусто = выключено). Уведомления: push из
самой сессии (PushNotification tool), `notify-send` и комментарии в issue от
раннера.

Тест state machine без токенов: положить JSON в `state/logs/fake.json` и
запустить `AGENT_DRY_RUN=1 ./queue-runner.sh` (GitHub не мутируется, claude не
запускается).

Известное ограничение: gh-токен без scope `workflow` — issues, требующие правок
`.github/workflows/`, автоматически уходят в `agent:blocked`.
