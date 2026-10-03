#!/usr/bin/env bash
#
# Setup: tablet mode on the ASUS ROG Flow Z13 — the root half.
#
# State before: the accelerometer is exposed by the kernel (iio:device0 "accel_3d",
# behind the ITE8353 sensor hub) but nothing reads it: iio-sensor-proxy is not
# installed, so there is no auto-rotation. Omarchy ships nothing for this.
#
# Mechanism:
#   - iio-sensor-proxy (extra) publishes orientation on D-Bus; the user-side daemon
#     ~/.local/bin/z13-autorotate (started from ~/.config/hypr/autostart.lua) turns
#     it into Hyprland transforms for eDP-1 + touchscreen + pen, only while the
#     keyboard dock (0b05:1a30) is detached.
#   - sleep hook: iio-sensor-proxy does not pick the accelerometer back up if the
#     sensor hub re-enumerates across s2idle (fix-asus-z13-spurious-wake.sh can unbind
#     ITE8353:00 during sleep), so it is restarted on resume. Lives in
#     /usr/lib/systemd/system-sleep/ — this systemd build does not scan /etc/....
#   - libva-utils rides along for `vainfo` (checking VCN hardware decode).
#
# Not root, run yourself afterwards:   omarchy pkg aur add wvkbd
# Deliberately not used: aur/iio-hyprland-git (stale since 2024-11), hyprgrass
# (plugin ABI is fragile against Hyprland 0.56).
#
# Run:    sudo bash setup-asus-z13-tablet.sh
# Verify: bash setup-asus-z13-tablet.sh --verify
# Undo:   sudo bash setup-asus-z13-tablet.sh --uninstall    (packages are left alone)

set -euo pipefail

SLEEP_HOOK=/usr/lib/systemd/system-sleep/zz-asus-z13-iio-restart
MARK="# added by setup-asus-z13-tablet.sh"
PACKAGES=(iio-sensor-proxy libva-utils)

die() {
  echo "ERROR: $*" >&2
  exit 1
}

verify() {
  for pkg in "${PACKAGES[@]}" wvkbd; do
    pacman -Q "$pkg" 2>/dev/null || echo "$pkg: not installed"
  done
  echo "iio-sensor-proxy: $(systemctl is-active iio-sensor-proxy 2>/dev/null || true)"
  echo "sleep hook:       $([[ -x $SLEEP_HOOK ]] && echo present || echo missing)"
  echo "accelerometer:    $(cat /sys/bus/iio/devices/iio:device*/name 2>/dev/null | tr '\n' ' ')"
  echo "autorotate:       $(pgrep -fa z13-autorotate | head -1 || echo 'not running (starts with Hyprland)')"
  if command -v monitor-sensor >/dev/null; then
    echo "== monitor-sensor (3 s — tilt the tablet)"
    timeout 3 monitor-sensor --accel || true
  fi
  if command -v vainfo >/dev/null; then
    echo "== vainfo"
    vainfo 2>&1 | grep -E "Driver version|VAProfile" | head -20 || true
  fi
}

case "${1:-}" in
  --verify | --status)
    verify
    exit 0
    ;;
  "" | --uninstall) ;;
  *) die "unknown argument: $1" ;;
esac

[[ $EUID -eq 0 ]] || die "Run as root:  sudo bash $0"

if [[ ${1:-} == "--uninstall" ]]; then
  if [[ -f $SLEEP_HOOK ]] && grep -qF "$MARK" "$SLEEP_HOOK"; then
    rm -f "$SLEEP_HOOK"
    echo "Removed $SLEEP_HOOK"
  fi
  echo "Done. Packages left installed: ${PACKAGES[*]}"
  echo "User side: remove the z13 lines from ~/.config/hypr/{autostart,input,bindings}.lua and run 'z13-autorotate reset'."
  exit 0
fi

echo "==> Installing ${PACKAGES[*]}"
pacman -S --needed --noconfirm "${PACKAGES[@]}"

echo "==> Writing $SLEEP_HOOK"
cat >"$SLEEP_HOOK" <<EOF
#!/bin/bash
$MARK
# Restart iio-sensor-proxy after resume so it re-opens the accelerometer.
[[ \$1 == post ]] || exit 0
(sleep 3; systemctl try-restart iio-sensor-proxy.service) &
EOF
chmod 755 "$SLEEP_HOOK"

# started by udev when an accelerometer is present; kick it now instead of waiting for a reboot
udevadm trigger --subsystem-match=iio || true
systemctl start iio-sensor-proxy.service || true

echo
echo "Done. Next, as your user:"
echo "  omarchy pkg aur add wvkbd"
echo "  bash $0 --verify"
echo "Then detach the keyboard and rotate. Lock: SUPER+CTRL+ALT+O   Keyboard: SUPER+CTRL+ALT+K"
