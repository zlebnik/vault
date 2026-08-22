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

# Комментарии агента на GitHub всегда начинаются с этого маркера — только так
# отличаем их от человеческих (агент и человек пишут под одним логином).
AGENT_MARK="🤖"

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
now_iso() { date -u +%FT%TZ; }

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
# phase: running | plan_retry | awaiting_plan_approval | impl_retry
#        | awaiting_merge | blocked | rate_limited
# stage: plan | implement   (что делает claude-сессия по сути)

write_state() {  # issue sid worktree phase stage attempts
  jq -n --argjson issue "$1" --arg sid "$2" --arg wt "$3" --arg phase "$4" \
        --arg stage "$5" --argjson attempts "$6" \
        '{issue:$issue, session_id:$sid, worktree:$wt, phase:$phase, stage:$stage,
          attempts:$attempts, next_retry_at:0, started_at:(now|todate),
          pr_url:null, plan_comment_id:null, last_activity_ts:null}' \
    > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
}

state_get()    { jq -r "$1 // empty" "$STATE" 2>/dev/null; }
state_update() { jq "$1" "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"; }
clear_state()  { rm -f "$STATE"; }

render_prompt() {  # <template-basename> <issue> [plan_comment_id] [stage]
  sed -e "s/{{ISSUE}}/$2/g" \
      -e "s/{{PLAN_COMMENT_ID}}/${3:-unknown}/g" \
      -e "s/{{STAGE}}/${4:-}/g" \
      "$DEV/prompts/$1"
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

# --- работа с планом и комментариями -----------------------------------------

# 0, если на комментарии плана есть хотя бы один 👍.
plan_approved() {  # comment_id
  [[ ${AGENT_DRY_RUN:-0} == 1 ]] && return "${AGENT_DRY_APPROVED:-1}"
  local n
  n=$(gh api "repos/$GH_REPO/issues/comments/$1/reactions" \
        --jq '[.[] | select(.content == "+1")] | length' 2>/dev/null || echo 0)
  (( n > 0 ))
}

# Последний комментарий агента с планом (fallback, если id не распарсился).
find_plan_comment() {  # issue -> печатает id или ничего
  gh api "repos/$GH_REPO/issues/$1/comments" --paginate \
    --jq "[.[] | select(.body | startswith(\"$AGENT_MARK **План\"))] | last | .id // empty" \
    2>/dev/null || true
}

# Кол-во человеческих комментариев к issue после отметки времени.
# Человеческий = не начинается с 🤖 (агент и человек — один логин).
new_issue_feedback() {  # issue since_iso -> печатает число
  [[ ${AGENT_DRY_RUN:-0} == 1 ]] && { echo "${AGENT_DRY_FEEDBACK:-0}"; return; }
  gh api "repos/$GH_REPO/issues/$1/comments" --paginate --jq \
    "[.[] | select(.created_at > \"$2\")
          | select(.body // \"\" | startswith(\"$AGENT_MARK\") | not)] | length" \
    2>/dev/null || echo 0
}

# Кол-во новой человеческой активности в PR после отметки времени:
# обычные комментарии + inline-комментарии + ревью. Исключаем: комментарии
# агента (🤖), боилерплейт Codex «no major issues» и триггеры «@codex review».
new_pr_activity() {  # pr_number since_iso -> печатает число
  [[ ${AGENT_DRY_RUN:-0} == 1 ]] && { echo "${AGENT_DRY_PR_ACTIVITY:-0}"; return; }
  local pr=$1 since=$2 filt n1 n2 n3
  filt="[.[] | select((.created_at // .submitted_at // \"\") > \"$since\")
             | select(.body // \"\" | startswith(\"$AGENT_MARK\") | not)
             | select(.body // \"\" | contains(\"find any major issues\") | not)
             | select((.body // \"\" | gsub(\"\\\\s\"; \"\")) != \"@codexreview\")
             | select((.body // \"\") != \"\")] | length"
  n1=$(gh api "repos/$GH_REPO/issues/$pr/comments" --paginate --jq "$filt" 2>/dev/null || echo 0)
  n2=$(gh api "repos/$GH_REPO/pulls/$pr/comments" --paginate --jq "$filt" 2>/dev/null || echo 0)
  n3=$(gh api "repos/$GH_REPO/pulls/$pr/reviews" --paginate --jq "$filt" 2>/dev/null || echo 0)
  echo $(( n1 + n2 + n3 ))
}

# Состояние PR задачи. Выставляет глобалы PR_STATE (MERGED/CLOSED/OPEN/NONE)
# и PR_NUM/PR_URL. Не вызывать через $(…) — значения нужны вне subshell.
# Если известен номер PR — ищем по нему (worktree может уже не существовать);
# иначе по ветке worktree.
pr_state() {  # worktree [pr_num]
  local wt=$1 num=${2:-} branch pr
  PR_STATE=NONE PR_NUM= PR_URL=
  if [[ ${AGENT_DRY_RUN:-0} == 1 ]]; then
    PR_NUM=0; PR_URL="(dry-run)"; PR_STATE=${AGENT_DRY_PR_STATE:-OPEN}; return
  fi
  if [[ -n $num ]]; then
    pr=$(gh pr view "$num" -R "$GH_REPO" --json number,url,state 2>/dev/null || true)
  else
    branch=$(git -C "$wt" branch --show-current 2>/dev/null || true)
    [[ -z $branch ]] && return
    pr=$(gh pr list -R "$GH_REPO" --head "$branch" --state all \
          --json number,url,state --jq '.[0] // empty' 2>/dev/null)
  fi
  [[ -z $pr ]] && return
  PR_NUM=$(jq -r .number <<<"$pr")
  PR_URL=$(jq -r .url <<<"$pr")
  PR_STATE=$(jq -r .state <<<"$pr")
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

block_issue() {  # reason; использует ISSUE, OUT_ERR; state ОСТАЁТСЯ (держит очередь)
  local reason=$1 sid wt
  sid=$(state_get .session_id); wt=$(state_get .worktree)
  gh_mut issue edit "$ISSUE" -R "$GH_REPO" \
    --remove-label agent:wip --add-label agent:blocked || true
  gh_mut issue comment "$ISSUE" -R "$GH_REPO" --body "$(printf \
    '%s agent:blocked — %s\n\nworktree: `%s`\nsession: `%s`\nПродолжить руками: `~/vault/development/attach.sh --take`; вернуть агенту: снять agent:blocked и поставить agent:ready.\n\nХвост лога:\n```\n%s\n```' \
    "$AGENT_MARK" "$reason" "${wt:-?}" "${sid:-?}" \
    "$(tail -c 1500 "${OUT_ERR:-/dev/null}" 2>/dev/null || true)")" || true
  notify "issue #$ISSUE заблокирован: $reason"
  log "blocked: issue #$ISSUE — $reason (state сохранён, очередь держится)"
  state_update '.phase="blocked"'
}

# Общие первые проверки результата claude-сессии. Возвращает 0, если исход
# уже обработан (rate-limit/blocked), 1 — если решать вызывающему.
handle_common() {  # использует OUT_JSON/OUT_ERR; выставляет RESULT
  RESULT=$(jq -r '.result // ""' "$OUT_JSON" 2>/dev/null || echo "")
  if grep -qiE 'hit your (session|weekly|usage) limit|usage limit (reached|exceeded)' \
       <<<"$RESULT"$'\n'"$(tail -c 2000 "$OUT_ERR" 2>/dev/null || true)"; then
    log "rate-limit: backoff $((RETRY_BACKOFF / 60)) мин, resume той же сессии позже"
    state_update ".phase=\"rate_limited\" | .next_retry_at=$(( $(date +%s) + RETRY_BACKOFF ))"
    return 0
  fi
  if grep -q 'AGENT_BLOCKED' <<<"$RESULT"; then
    block_issue "$(grep -o 'AGENT_BLOCKED:.*' <<<"$RESULT" | head -1)"
    return 0
  fi
  return 1
}

# rc — exit code запуска claude; стадия планирования.
handle_plan_result() {
  local rc=$1 cid attempts
  handle_common && return 0
  if grep -q 'AGENT_PLAN_POSTED' <<<"$RESULT"; then
    cid=$(grep -o 'AGENT_PLAN_POSTED COMMENT_ID=[0-9]*' <<<"$RESULT" \
            | head -1 | grep -o '[0-9]*$' || true)
    [[ -z $cid && ${AGENT_DRY_RUN:-0} != 1 ]] && cid=$(find_plan_comment "$ISSUE")
    if [[ -n $cid ]]; then
      log "план по issue #$ISSUE опубликован (comment $cid) — жду 👍"
      notify "план по issue #$ISSUE готов — поставь 👍 или прокомментируй"
      state_update ".phase=\"awaiting_plan_approval\" | .attempts=0 \
        | .plan_comment_id=\"$cid\" | .last_activity_ts=\"$(now_iso)\" | .next_retry_at=0"
      return 0
    fi
    log "маркер AGENT_PLAN_POSTED есть, но комментарий плана не найден"
  fi
  attempts=$(( $(state_get .attempts) + 1 ))
  if (( attempts >= MAX_ATTEMPTS )); then
    block_issue "план не опубликован после $attempts попыток (exit=$rc)"
  else
    log "план не опубликован (exit=$rc), попытка $attempts/$MAX_ATTEMPTS — resume следующим тиком"
    state_update ".phase=\"plan_retry\" | .attempts=$attempts | .next_retry_at=0"
  fi
}

# rc — exit code запуска claude; стадия реализации (включая PR-feedback).
handle_impl_result() {
  local rc=$1 vr attempts
  handle_common && return 0
  if [[ ${AGENT_DRY_RUN:-0} == 1 ]]; then
    if grep -q 'AGENT_DONE' <<<"$RESULT"; then vr=0; PR_URL="(dry-run)"; else vr=1; fi
  else
    vr=0; verify_pr_done "$WT" || vr=$?
  fi
  case $vr in
    0)
      gh_mut issue edit "$ISSUE" -R "$GH_REPO" \
        --remove-label agent:wip --add-label agent:done || true
      notify "issue #$ISSUE готов к merge: $PR_URL"
      log "готов к merge: issue #$ISSUE — $PR_URL (state держит очередь до merge)"
      state_update ".phase=\"awaiting_merge\" | .pr_url=\"$PR_URL\" \
        | .pr_num=${PR_NUM:-0} | .attempts=0 \
        | .last_activity_ts=\"$(now_iso)\" | .next_retry_at=0"
      ;;
    2)
      log "PR открыт ($PR_URL), CI ещё идёт — дожмём следующим тиком"
      state_update ".phase=\"impl_retry\" | .pr_url=\"$PR_URL\" | .next_retry_at=0"
      ;;
    *)
      attempts=$(( $(state_get .attempts) + 1 ))
      if (( attempts >= MAX_ATTEMPTS )); then
        block_issue "нет готового PR после $attempts попыток (exit=$rc)"
      else
        log "неудача (exit=$rc, verify=$vr), попытка $attempts/$MAX_ATTEMPTS — resume следующим тиком"
        state_update ".phase=\"impl_retry\" | .attempts=$attempts | .next_retry_at=0"
      fi
      ;;
  esac
}

# --- уборка ------------------------------------------------------------------

# Сносим только worktrees, созданные очередью (маркер .agent-queue),
# и только когда их PR смержен или закрыт. Blocked (без PR) не трогаем.
# Worktree АКТИВНОЙ задачи не трогаем тоже: финал (merge/close) должна увидеть
# и обработать state machine, иначе awaiting_merge найдёт NONE вместо MERGED.
cleanup_finished_worktrees() {
  local wt br st active
  active=$(state_get .worktree)
  for wt in "$WORKTREES_DIR"/*/; do
    [[ -n $active && ${wt%/} == "${active%/}" ]] && continue
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
