#!/usr/bin/env bash
# Один «тик» очереди автономной разработки ЧекЧека.
# Запускается systemd-таймером каждые ~5 мин после конца предыдущего тика,
# либо руками. Строго одна issue в работе; новая не берётся, пока PR текущей
# не смержен (и пока висит agent:blocked).
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

resume_by_stage() {  # запустить resume текущей сессии и обработать по стадии
  local stage rc=0
  stage=$(state_get .stage)
  log "resume issue #$ISSUE (stage=$stage, session=$SID)"
  state_update '.phase="running"'
  run_claude "$WT" "$SID" \
    "$(render_prompt resume.md "$ISSUE" "$(state_get .plan_comment_id)" "$stage")" resume || rc=$?
  if [[ $stage == plan ]]; then handle_plan_result "$rc"; else handle_impl_result "$rc"; fi
}

# --- Есть активная задача: ведём её по фазам, новых не берём -----------------
if [[ -s $STATE ]]; then
  ISSUE=$(state_get .issue)
  SID=$(state_get .session_id)
  WT=$(state_get .worktree)
  phase=$(state_get .phase)
  next=$(state_get .next_retry_at)
  if (( $(date +%s) < ${next:-0} )); then
    log "backoff до $(date -d "@$next" +'%F %T') — пропуск тика"
    exit 0
  fi

  # Issue закрыли, пока задача ждала (план «без кода», закрыл человек и т.п.):
  # это конец задачи в любой ждущей фазе, 👍/merge уже не будет.
  if [[ $phase == awaiting_plan_approval || $phase == awaiting_merge ]] \
     && [[ $(issue_state "$ISSUE") == CLOSED ]]; then
    log "issue #$ISSUE закрыта (phase=$phase) — задача завершена, state очищен"
    if issue_has_label "$ISSUE" agent:wip; then
      gh_mut issue edit "$ISSUE" -R "$GH_REPO" --remove-label agent:wip --add-label agent:done
    fi
    notify "issue #$ISSUE закрыта без merge — очередь свободна"
    clear_state
    exit 0
  fi

  case $phase in
    awaiting_plan_approval)
      cid=$(state_get .plan_comment_id)
      if plan_approved "$cid"; then
        log "план по issue #$ISSUE одобрен (👍) — начинаю реализацию"
        state_update '.stage="implement" | .phase="running" | .attempts=0'
        rc=0
        run_claude "$WT" "$SID" "$(render_prompt implement.md "$ISSUE" "$cid")" resume || rc=$?
        handle_impl_result "$rc"
      else
        fb=$(new_issue_feedback "$ISSUE" "$(state_get .last_activity_ts)")
        if (( fb > 0 )); then
          log "по плану issue #$ISSUE есть новые комментарии ($fb) — корректирую план"
          state_update '.phase="running"'
          rc=0
          run_claude "$WT" "$SID" "$(render_prompt revise.md "$ISSUE" "$cid")" resume || rc=$?
          handle_plan_result "$rc"
        else
          log "план issue #$ISSUE ждёт 👍 — пропуск тика без claude"
        fi
      fi
      ;;

    awaiting_merge)
      pr_state "$WT" "$(state_get .pr_num)"
      case $PR_STATE in
        MERGED)
          notify "PR issue #$ISSUE смержен — очередь свободна"
          log "PR смержен: issue #$ISSUE закрыта, state очищен"
          clear_state
          ;;
        OPEN)
          act=$(new_pr_activity "$PR_NUM" "$(state_get .last_activity_ts)")
          if (( act > 0 )); then
            log "в PR #$PR_NUM новая активность ($act) — отдаю агенту"
            state_update '.phase="running"'
            rc=0
            run_claude "$WT" "$SID" \
              "$(render_prompt pr-feedback.md "$ISSUE" "$(state_get .plan_comment_id)")" resume || rc=$?
            handle_impl_result "$rc"
          else
            log "PR #$PR_NUM ждёт merge — пропуск тика без claude"
          fi
          ;;
        *)
          notify "PR issue #$ISSUE: $PR_STATE без merge — state очищен, разберись с лейблами"
          log "PR в состоянии $PR_STATE — state очищен"
          clear_state
          ;;
      esac
      ;;

    blocked)
      info=$(gh issue view "$ISSUE" -R "$GH_REPO" --json state,labels \
               --jq '{state, labels: [.labels[].name]}' 2>/dev/null || echo '{}')
      istate=$(jq -r '.state // "?"' <<<"$info")
      if [[ $istate == CLOSED ]]; then
        log "blocked issue #$ISSUE закрыта человеком — state очищен"
        clear_state
      elif jq -e '.labels | index("agent:blocked")' <<<"$info" >/dev/null; then
        log "issue #$ISSUE в agent:blocked — очередь держится, жду человека"
      elif jq -e '.labels | index("agent:ready")' <<<"$info" >/dev/null; then
        log "issue #$ISSUE возвращена агенту (agent:ready) — продолжаю ту же сессию"
        gh_mut issue edit "$ISSUE" -R "$GH_REPO" \
          --remove-label agent:ready --add-label agent:wip
        state_update '.attempts=0'
        resume_by_stage
      else
        log "с issue #$ISSUE сняты agent-лейблы — state очищен"
        clear_state
      fi
      ;;

    *)
      # rate_limited / plan_retry / impl_retry / running (прошлый тик умер).
      # Экономия лимита: если PR уже есть и CI ещё крутится — claude не дёргаем.
      if [[ $(state_get .stage) == implement && -n $(state_get .pr_url) \
            && ${AGENT_DRY_RUN:-0} != 1 ]]; then
        vr=0; verify_pr_done "$WT" || vr=$?
        if (( vr == 2 )); then
          log "PR $(state_get .pr_url): CI ещё идёт — пропуск тика без claude"
          exit 0
        fi
      fi
      resume_by_stage
      ;;
  esac
  exit 0
fi

# --- Нет state: очередь свободна? --------------------------------------------
# Любая незавершённая работа держит очередь: wip (потерянный state),
# blocked (ждёт человека), done с ещё открытой issue (PR не смержен).
hold=0
for lbl in agent:wip agent:blocked agent:done; do
  n=$(gh issue list -R "$GH_REPO" --label "$lbl" --state open --json number --jq 'length')
  if (( n > 0 )); then
    log "очередь держится: $n открытых issue с $lbl"
    hold=1
  fi
done
(( hold )) && exit 0

# Берём РОВНО одну issue — самую старую из agent:ready.
ISSUE=$(gh issue list -R "$GH_REPO" --label agent:ready --state open \
          --json number --jq 'sort_by(.number) | .[0].number // empty')
if [[ -z $ISSUE ]]; then
  log "очередь пуста"
  exit 0
fi

log "беру issue #$ISSUE в работу (стадия плана)"
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
write_state "$ISSUE" "$SID" "$WT" running plan 0
log "запуск claude -p, стадия плана (session=$SID, worktree=$WT)"
rc=0
run_claude "$WT" "$SID" "$(render_prompt plan.md "$ISSUE")" || rc=$?
handle_plan_result "$rc"
