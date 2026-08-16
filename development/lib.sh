#!/usr/bin/env bash
# Общая библиотека очереди автономной разработки ЧекЧека.
# Подключается из queue-runner.sh / attach.sh / setup.sh / uninstall.sh.

DEV="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO=/home/zlebnik/Projects/checkcheck/checkcheck
WORKTREES_DIR=/home/zlebnik/Projects/checkcheck/worktrees
GH_REPO=checkcheckonline/checkcheck
CLAUDE_BIN="${CLAUDE_BIN:-/home/zlebnik/.local/share/mise/installs/claude/latest/claude}"

STATE_DIR="$DEV/state"
STATE="$STATE_DIR/current.json"
LOGS="$STATE_DIR/logs"

MAX_ATTEMPTS=3
SESSION_TIMEOUT=10800   # 3h на одну headless-сессию (timeout(1))
RETRY_BACKOFF=1200      # 20 мин backoff после rate-limit
NTFY_TOPIC="${NTFY_TOPIC:-}"  # непустой topic -> дублировать уведомления в ntfy.sh/<topic>

# Allow-лист инструментов headless-сессии. Денай в headless = проваленный tool
# call: агент его видит и адаптируется. Расширять по мере обнаружения затыков.
ALLOWED_TOOLS=(
  Read Edit Write Glob Grep WebFetch TodoWrite PushNotification
  "Bash(git:*)" "Bash(gh:*)" "Bash(cd:*)" "Bash(ls:*)" "Bash(cat:*)"
  "Bash(grep:*)" "Bash(rg:*)" "Bash(find:*)" "Bash(sed -n:*)"
  "Bash(head:*)" "Bash(tail:*)" "Bash(wc:*)" "Bash(echo:*)" "Bash(diff:*)"
  "Bash(mkdir:*)" "Bash(touch:*)" "Bash(sleep:*)" "Bash(python3:*)"
  "Bash(./venv/bin/python:*)" "Bash(./venv/bin/black:*)"
  "Bash(DEBUG=true ./venv/bin/python:*)"
)

log() { printf '[%s] %s\n' "$(date +'%F %T')" "$*"; }

notify() {
  local msg=$1
  notify-send -u critical "checkcheck agent" "$msg" 2>/dev/null || true
  if [[ -n $NTFY_TOPIC ]]; then
    curl -fsS -d "$msg" "https://ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1 || true
  fi
}

# Мутирующие gh-вызовы идут через обёртку, чтобы AGENT_DRY_RUN=1 не трогал GitHub.
gh_mut() {
  if [[ ${AGENT_DRY_RUN:-0} == 1 ]]; then
    log "DRY: gh $*"
  else
    gh "$@"
  fi
}

# --- state -------------------------------------------------------------------

write_state() {  # issue sid worktree phase attempts next_retry_at
  jq -n --argjson issue "$1" --arg sid "$2" --arg wt "$3" --arg phase "$4" \
        --argjson attempts "$5" --argjson retry "${6:-0}" \
        '{issue:$issue, session_id:$sid, worktree:$wt, phase:$phase,
          attempts:$attempts, next_retry_at:$retry,
          started_at:(now|todate), pr_url:null}' \
    > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
}

state_get()    { jq -r "$1 // empty" "$STATE" 2>/dev/null; }
state_update() { jq "$1" "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"; }
clear_state()  { rm -f "$STATE"; }

render_prompt() {  # <template-basename> <issue>
  sed "s/{{ISSUE}}/$2/g" "$DEV/prompts/$1"
}

# --- запуск claude -----------------------------------------------------------

# Использует глобалы ISSUE; выставляет OUT_JSON/OUT_ERR.
run_claude() {  # worktree sid prompt [resume]
  local wt=$1 sid=$2 prompt=$3 mode=${4:-new}
  local ts; ts=$(date +%s)
  OUT_JSON="$LOGS/issue-$ISSUE-$ts.json"
  OUT_ERR="$LOGS/issue-$ISSUE-$ts.log"
  if [[ ${AGENT_DRY_RUN:-0} == 1 ]]; then
    cp "$LOGS/fake.json" "$OUT_JSON"; : > "$OUT_ERR"
    return "${AGENT_DRY_RC:-0}"
  fi
  local args=(-p "$prompt" --output-format json)
  if [[ $mode == resume ]]; then
    args+=(--resume "$sid")
  else
    args+=(--session-id "$sid")
  fi
  args+=(--allowedTools "${ALLOWED_TOOLS[@]}")
  ( cd "$wt" && CLAUDE_CODE_RETRY_WATCHDOG=1 \
      timeout --kill-after=60 "$SESSION_TIMEOUT" "$CLAUDE_BIN" "${args[@]}" \
      > "$OUT_JSON" 2> "$OUT_ERR" )
}

# --- верификация результата --------------------------------------------------

# 0 = PR открыт и CI зелёный; 1 = PR нет; 2 = CI ещё идёт; 3 = CI красный.
# Выставляет PR_NUM/PR_URL при наличии PR.
verify_pr_done() {  # worktree
  local wt=$1 branch pr buckets fail pending
  branch=$(git -C "$wt" branch --show-current 2>/dev/null || true)
  [[ -z $branch ]] && return 1
  pr=$(gh pr list -R "$GH_REPO" --head "$branch" --state open \
        --json number,url --jq '.[0] // empty')
  [[ -z $pr ]] && return 1
  PR_NUM=$(jq -r .number <<<"$pr")
  PR_URL=$(jq -r .url <<<"$pr")
  buckets=$(gh pr checks "$PR_NUM" -R "$GH_REPO" --json bucket \
              --jq '[.[].bucket]' 2>/dev/null || echo '[]')
  fail=$(jq '[.[] | select(. == "fail")] | length' <<<"$buckets")
  pending=$(jq '[.[] | select(. == "pending")] | length' <<<"$buckets")
  (( fail > 0 )) && return 3
  (( pending > 0 )) && return 2
  return 0
}

block_issue() {  # reason; использует ISSUE, OUT_ERR
  local reason=$1 sid wt
  sid=$(state_get .session_id); wt=$(state_get .worktree)
  gh_mut issue edit "$ISSUE" -R "$GH_REPO" \
    --remove-label agent:wip --add-label agent:blocked || true
  gh_mut issue comment "$ISSUE" -R "$GH_REPO" --body "$(printf \
    '🤖 agent:blocked — %s\n\nworktree: `%s`\nsession: `%s`\nПродолжить руками: `~/vault/development/attach.sh --take`\n\nХвост лога:\n```\n%s\n```' \
    "$reason" "${wt:-?}" "${sid:-?}" \
    "$(tail -c 1500 "${OUT_ERR:-/dev/null}" 2>/dev/null || true)")" || true
  notify "issue #$ISSUE заблокирован: $reason"
  log "blocked: issue #$ISSUE — $reason"
  clear_state
}

# rc — exit code запуска claude; использует ISSUE, WT, OUT_JSON, OUT_ERR.
handle_result() {
  local rc=$1 result vr attempts
  result=$(jq -r '.result // ""' "$OUT_JSON" 2>/dev/null || echo "")

  # 1. Rate-limit подписки: backoff, attempts не растёт, сессия будет resumed.
  if grep -qiE 'hit your (session|weekly|usage) limit|usage limit (reached|exceeded)' \
       <<<"$result"$'\n'"$(tail -c 2000 "$OUT_ERR" 2>/dev/null || true)"; then
    log "rate-limit: backoff $((RETRY_BACKOFF / 60)) мин, resume той же сессии позже"
    state_update ".phase=\"rate_limited\" | .next_retry_at=$(( $(date +%s) + RETRY_BACKOFF ))"
    return 0
  fi

  # 2. Явная блокировка (маркер агента или отказ push из-за workflow-scope).
  if grep -q 'AGENT_BLOCKED' <<<"$result" || \
     grep -q 'refusing to allow an OAuth App' "$OUT_ERR" 2>/dev/null; then
    local reason
    reason=$(grep -o 'AGENT_BLOCKED:.*' <<<"$result" | head -1)
    block_issue "${reason:-push отклонён: нет workflow-scope у gh-токена}"
    return 0
  fi

  # 3. Маркеру AGENT_DONE не верим на слово — проверяем PR и CI на GitHub.
  if [[ ${AGENT_DRY_RUN:-0} == 1 ]]; then
    if grep -q 'AGENT_DONE' <<<"$result"; then vr=0; PR_URL="(dry-run)"; else vr=1; fi
  else
    vr=0; verify_pr_done "$WT" || vr=$?
  fi

  case $vr in
    0)
      gh_mut issue edit "$ISSUE" -R "$GH_REPO" \
        --remove-label agent:wip --add-label agent:done
      notify "issue #$ISSUE готов к merge: $PR_URL"
      log "done: issue #$ISSUE — $PR_URL"
      clear_state
      ;;
    2)
      log "PR открыт ($PR_URL), CI ещё идёт — дожмём следующим тиком"
      state_update ".phase=\"failed_retry\" | .pr_url=\"$PR_URL\" | .next_retry_at=0"
      ;;
    *)
      attempts=$(( $(state_get .attempts) + 1 ))
      if (( attempts >= MAX_ATTEMPTS )); then
        block_issue "нет готового PR после $attempts попыток (exit=$rc)"
      else
        log "неудача (exit=$rc, verify=$vr), попытка $attempts/$MAX_ATTEMPTS — resume следующим тиком"
        state_update ".phase=\"failed_retry\" | .attempts=$attempts | .next_retry_at=0"
      fi
      ;;
  esac
}

# --- уборка ------------------------------------------------------------------

# Сносим только worktrees, созданные очередью (маркер .agent-queue),
# и только когда их PR смержен или закрыт. Blocked (без PR) не трогаем.
cleanup_finished_worktrees() {
  local wt br st
  for wt in "$WORKTREES_DIR"/*/; do
    [[ -f "$wt/.agent-queue" ]] || continue
    br=$(git -C "$wt" branch --show-current 2>/dev/null) || continue
    [[ -z $br ]] && continue
    st=$(gh pr list -R "$GH_REPO" --head "$br" --state all \
          --json state --jq '.[0].state // empty' 2>/dev/null)
    if [[ $st == MERGED || $st == CLOSED ]]; then
      log "cleanup: $wt (ветка $br, PR $st)"
      git -C "$REPO" worktree remove --force "$wt" || true
      git -C "$REPO" branch -D "$br" 2>/dev/null || true
    fi
  done
  git -C "$REPO" worktree prune 2>/dev/null || true
}
