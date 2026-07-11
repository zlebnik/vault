#!/bin/bash
#
# Enable clamshell mode on the ASUS Z13 (omarchy / Hyprland).
#
# By default systemd-logind suspends the machine when the lid closes, which
# happens BEFORE Hyprland can react — so clamshell is impossible. This drop-in
# tells logind to ignore the lid and hand control to Hyprland, whose
# ~/.config/hypr/clamshell.sh then decides:
#   - external monitor connected -> turn off the internal panel, keep running
#   - no external monitor         -> suspend (normal laptop behavior)
#
# The Hyprland side (clamshell.sh + the two `bindl switch:...:Lid Switch`
# bindings) is already installed in ~/.config/hypr/.
#
# Run:   sudo bash setup-clamshell-logind.sh
# Undo:  sudo bash setup-clamshell-logind.sh --uninstall

set -euo pipefail

DROPIN=/etc/systemd/logind.conf.d/10-clamshell.conf

if [[ $EUID -ne 0 ]]; then
  echo "Run as root:  sudo bash $0" >&2
  exit 1
fi

if [[ "${1:-}" == "--uninstall" ]]; then
  rm -fv "$DROPIN"
  echo "==> Reloading systemd-logind"
  systemctl reload systemd-logind
  echo "Done. Lid now uses the default behavior (suspend on close)."
  exit 0
fi

echo "==> Writing $DROPIN"
mkdir -p "$(dirname "$DROPIN")"
cat > "$DROPIN" <<'EOF'
# Hand lid handling to Hyprland (~/.config/hypr/clamshell.sh) so clamshell mode
# works: with an external monitor the machine stays awake with the internal
# panel off; with no external monitor Hyprland suspends instead.
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF

echo "==> Reloading systemd-logind"
systemctl reload systemd-logind

echo
echo "==> Effective lid settings now:"
loginctl show-session 2>/dev/null | grep -i lid || \
  systemd-analyze cat-config systemd/logind.conf 2>/dev/null | grep -iE "HandleLidSwitch" | grep -v '^#' || true

echo
echo "Done. Test it:"
echo "  1. Connect the external monitor."
echo "  2. Close the lid  -> internal screen off, external keeps working, no suspend."
echo "  3. Open the lid   -> internal screen comes back."
echo "  4. Disconnect external, close lid -> suspends as normal."
