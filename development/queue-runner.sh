#!/usr/bin/env bash
# Один «тик» очереди автономной разработки ЧекЧека.
# Запускается systemd-таймером каждые ~15 мин после конца предыдущего тика,
# либо руками. Строго одна issue в работе одновременно.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

mkdir -p "$LOGS" "$WORKTREES_DIR"

# Один тик за раз: длинная сессия держит lock, параллельный запуск молча выходит.
exec 9>"$STATE_DIR/lock"
flock -n 9 || exit 0
if [[ -f "$STATE_DIR/pause" ]]; then
  log "пауза (state/pause) — пропуск тика"
  exit 0
fi

cleanup_finished_worktrees

# Есть активная задача — продолжаем её, новых не берём.
if [[ -s $STATE ]]; then
  ISSUE=$(state_get .issue)
  SID=$(state_get .session_id)
  WT=$(state_get .worktree)
  next=$(state_get .next_retry_at)
  if (( $(date +%s) < ${next:-0} )); then
    log "backoff до $(date -d "@$next" +'%F %T') — пропуск тика"
    exit 0
  fi
  # Экономия лимита: пока PR есть и CI ещё крутится — claude не дёргаем,
  # тик просто проверяет чеки через gh и выходит.
  if [[ -n $(state_get .pr_url) && ${AGENT_DRY_RUN:-0} != 1 ]]; then
    vr=0; verify_pr_done "$WT" || vr=$?
    if (( vr == 2 )); then
      log "PR $(state_get .pr_url): CI ещё идёт — пропуск тика без claude"
      exit 0
    fi
  fi
  log "resume issue #$ISSUE (phase=$(state_get .phase), session=$SID)"
  state_update '.phase="running"'
  rc=0
  run_claude "$WT" "$SID" "$(render_prompt resume.md "$ISSUE")" resume || rc=$?
  handle_result "$rc"
  exit 0
fi

# Страховка: wip на GitHub без локального state — чужая/потерянная задача.
wip=$(gh issue list -R "$GH_REPO" --label agent:wip --state open --json number --jq 'length')
if (( wip > 0 )); then
  log "agent:wip на GitHub без локального state — жду ручного разбора"
  notify "agent:wip без локального state — разберись руками"
  exit 0
fi

# Берём РОВНО одну issue — самую старую из agent:ready.
ISSUE=$(gh issue list -R "$GH_REPO" --label agent:ready --state open \
          --json number --jq 'sort_by(.number) | .[0].number // empty')
if [[ -z $ISSUE ]]; then
  log "очередь пуста"
  exit 0
fi

log "беру issue #$ISSUE в работу"
gh_mut issue edit "$ISSUE" -R "$GH_REPO" --remove-label agent:ready --add-label agent:wip

if [[ ${AGENT_DRY_RUN:-0} == 1 ]]; then
  WT="$STATE_DIR/dry-worktree"
  mkdir -p "$WT"
else
  git -C "$REPO" fetch origin main
  WT="$WORKTREES_DIR/$ISSUE"
  git -C "$REPO" worktree add --detach "$WT" origin/main
  touch "$WT/.agent-queue"
  # venv и .env не версионируются — берём из основного клона
  # (нужны для точечных локальных тестов по dotted-path).
  ln -s "$REPO/backend/venv" "$WT/backend/venv"
  if [[ -f "$REPO/backend/.env" ]]; then cp "$REPO/backend/.env" "$WT/backend/.env"; fi
fi

# session_id генерируем сами ДО запуска: resume возможен даже после kill/timeout,
# когда JSON с session_id не дописался.
SID=$(uuidgen)
write_state "$ISSUE" "$SID" "$WT" running 0 0
log "запуск claude -p (session=$SID, worktree=$WT)"
rc=0
run_claude "$WT" "$SID" "$(render_prompt task.md "$ISSUE")" || rc=$?
handle_result "$rc"
