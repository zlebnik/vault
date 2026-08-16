#!/usr/bin/env bash
# Снять очередь: таймер, юниты. --purge дополнительно чистит state и worktrees очереди.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

systemctl --user disable --now checkcheck-agent.timer 2>/dev/null || true
systemctl --user stop checkcheck-agent.service 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/checkcheck-agent.service" \
      "$HOME/.config/systemd/user/checkcheck-agent.timer"
systemctl --user daemon-reload
echo "✓ таймер и юниты сняты"

if [[ ${1:-} == --purge ]]; then
  for wt in "$WORKTREES_DIR"/*/; do
    [[ -f "$wt/.agent-queue" ]] || continue
    br=$(git -C "$wt" branch --show-current 2>/dev/null || true)
    git -C "$REPO" worktree remove --force "$wt" || true
    [[ -n $br ]] && git -C "$REPO" branch -D "$br" 2>/dev/null || true
  done
  git -C "$REPO" worktree prune 2>/dev/null || true
  rm -rf "$STATE_DIR"
  echo "✓ state и worktrees очереди удалены (лейблы на GitHub не тронуты)"
fi
