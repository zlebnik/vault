#!/usr/bin/env bash
# Установка очереди автономной разработки ЧекЧека.
# Флаги: --no-timer (не включать таймер — для этапа ручной проверки),
#        --prune-stale (предложить убрать старые брошенные worktrees).
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

NO_TIMER=0
PRUNE_STALE=0
for arg in "$@"; do
  case $arg in
    --no-timer) NO_TIMER=1 ;;
    --prune-stale) PRUNE_STALE=1 ;;
    *) echo "неизвестный флаг: $arg" >&2; exit 1 ;;
  esac
done

# --- 1. Sanity ---------------------------------------------------------------
for cmd in gh jq uuidgen git; do
  command -v "$cmd" >/dev/null || { echo "нет команды: $cmd" >&2; exit 1; }
done
[[ -x $CLAUDE_BIN ]] || { echo "нет claude: $CLAUDE_BIN" >&2; exit 1; }
git -C "$REPO" remote get-url origin >/dev/null || { echo "нет клона: $REPO" >&2; exit 1; }
gh auth status >/dev/null || { echo "gh не авторизован" >&2; exit 1; }

# --- 2. Лейблы (идемпотентно: --force обновляет существующие) ---------------
gh label create agent:wip     -R "$GH_REPO" -c '#fbca04' -d 'Queue: taken by the agent'            --force
gh label create agent:done    -R "$GH_REPO" -c '#0e8a16' -d 'Queue: PR ready (CI green), awaiting merge' --force
gh label create agent:blocked -R "$GH_REPO" -c '#d93f0b' -d 'Queue: needs a human'                 --force
gh label create agent:ready   -R "$GH_REPO" -c '#1d76db' -d 'Queue: ready for the agent'           --force

# --- 3. Авто-удаление remote-веток после merge -------------------------------
gh api -X PATCH "repos/$GH_REPO" -F delete_branch_on_merge=true >/dev/null

# --- 4. Каталоги и systemd ---------------------------------------------------
mkdir -p "$LOGS" "$WORKTREES_DIR" "$HOME/.config/systemd/user"
ln -sf "$DEV/systemd/checkcheck-agent.service" "$HOME/.config/systemd/user/"
ln -sf "$DEV/systemd/checkcheck-agent.timer"   "$HOME/.config/systemd/user/"
systemctl --user daemon-reload
if (( NO_TIMER )); then
  echo "таймер НЕ включён (--no-timer); включить: systemctl --user enable --now checkcheck-agent.timer"
else
  systemctl --user enable --now checkcheck-agent.timer
  systemctl --user list-timers checkcheck-agent.timer --no-pager
fi

# --- 5. Опционально: уборка старых брошенных worktrees -----------------------
if (( PRUNE_STALE )); then
  echo
  echo "Кандидаты на удаление (worktrees без маркера очереди):"
  mapfile -t candidates < <(
    for wt in "$REPO"/.claude/worktrees/*/ "$WORKTREES_DIR"/*/; do
      [[ -d $wt && ! -f "$wt/.agent-queue" ]] || continue
      br=$(git -C "$wt" branch --show-current 2>/dev/null) || continue
      st=$(gh pr list -R "$GH_REPO" --head "${br:-__none__}" --state all \
            --json state --jq '.[0].state // "NO_PR"' 2>/dev/null || echo '?')
      printf '%s\t%s\t%s\n' "$wt" "${br:--}" "$st"
    done
  )
  if (( ${#candidates[@]} == 0 )); then
    echo "  нет кандидатов"
  else
    printf '  %s\n' "${candidates[@]}"
    echo
    read -rp "Удалить те, у которых PR MERGED/CLOSED? [y/N] " ans
    if [[ $ans == y || $ans == Y ]]; then
      for line in "${candidates[@]}"; do
        IFS=$'\t' read -r wt br st <<<"$line"
        [[ $st == MERGED || $st == CLOSED ]] || continue
        echo "  удаляю $wt ($br, $st)"
        git -C "$REPO" worktree remove --force "$wt" || true
        [[ $br != - ]] && git -C "$REPO" branch -D "$br" 2>/dev/null || true
      done
      git -C "$REPO" worktree prune
    fi
  fi
fi

echo
echo "✓ setup завершён"
