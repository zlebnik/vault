#!/usr/bin/env bash
# Remote control очереди: статус, перехват сессии человеком, возврат агенту.
#   attach.sh              статус текущей задачи
#   attach.sh --take       пауза очереди + интерактивный claude --resume той же сессии
#   attach.sh --release    вернуть задачу агенту (следующий тик продолжит сессию)
#   attach.sh --done N     человек дорешал сам: лейбл agent:done, state очищен
#   attach.sh --cleanup N  снести worktree/ветку задачи (например, заблокированной)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cmd=${1:---status}
case $cmd in
  --status)
    if [[ -s $STATE ]]; then
      echo "Активная задача:"
      jq . "$STATE"
      last_log=$(ls -t "$LOGS"/issue-*.log 2>/dev/null | head -1 || true)
      if [[ -n ${last_log:-} ]]; then
        echo; echo "Хвост $last_log:"; tail -20 "$last_log"
      fi
    else
      echo "Нет активной задачи."
    fi
    [[ -f "$STATE_DIR/pause" ]] && echo "⏸ Очередь на паузе (state/pause)."
    echo
    echo "Очередь на GitHub:"
    gh issue list -R "$GH_REPO" --label agent:ready --state open || true
    gh issue list -R "$GH_REPO" --label agent:wip --state open || true
    gh issue list -R "$GH_REPO" --label agent:blocked --state open || true
    ;;
  --take)
    [[ -s $STATE ]] || { echo "Нет активной задачи — нечего перехватывать." >&2; exit 1; }
    touch "$STATE_DIR/pause"
    if systemctl --user is-active --quiet checkcheck-agent.service; then
      echo "Тик активен — останавливаю (сессия останется резюмируемой)…"
      systemctl --user stop checkcheck-agent.service
    fi
    sid=$(state_get .session_id); wt=$(state_get .worktree)
    echo "Пауза поставлена. Подключаюсь к сессии $sid в $wt"
    echo "(вернуть агенту после выхода: ./attach.sh --release)"
    cd "$wt"
    exec "$CLAUDE_BIN" --resume "$sid"
    ;;
  --release)
    rm -f "$STATE_DIR/pause"
    echo "Пауза снята — следующий тик продолжит задачу."
    ;;
  --done)
    n=${2:?"нужен номер issue: attach.sh --done N"}
    gh issue edit "$n" -R "$GH_REPO" \
      --remove-label agent:wip --remove-label agent:blocked --add-label agent:done || true
    if [[ $(state_get .issue) == "$n" ]]; then clear_state; fi
    rm -f "$STATE_DIR/pause"
    echo "issue #$n помечена agent:done."
    ;;
  --cleanup)
    n=${2:?"нужен номер issue: attach.sh --cleanup N"}
    wt="$WORKTREES_DIR/$n"
    [[ -d $wt ]] || { echo "нет worktree $wt" >&2; exit 1; }
    br=$(git -C "$wt" branch --show-current 2>/dev/null || true)
    git -C "$REPO" worktree remove --force "$wt"
    [[ -n $br ]] && git -C "$REPO" branch -D "$br" 2>/dev/null || true
    git -C "$REPO" worktree prune
    if [[ $(state_get .issue) == "$n" ]]; then clear_state; fi
    echo "worktree issue #$n убран."
    ;;
  *)
    echo "usage: attach.sh [--status|--take|--release|--done N|--cleanup N]" >&2
    exit 1
    ;;
esac
