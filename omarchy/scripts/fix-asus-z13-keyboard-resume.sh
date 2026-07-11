#!/bin/bash
#
# Fix: ASUS ROG Flow Z13 (GZ302EA) detachable keyboard sometimes dead after
# waking from s2idle sleep.
#
# The keyboard is a USB dock (0b05:1a30) that intermittently fails to re-init its
# HID interfaces on resume. This installs:
#   1. a udev rule pinning the dock's USB power so it never autosuspends, and
#   2. a systemd system-sleep hook that re-binds the dock on wake if the
#      keyboard's input node went missing.
#
# Both changes are local and reversible (see --uninstall at the bottom).
#
# Run:   sudo bash fix-asus-z13-keyboard-resume.sh
# Undo:  sudo bash fix-asus-z13-keyboard-resume.sh --uninstall

set -euo pipefail

UDEV_RULE=/etc/udev/rules.d/99-asus-z13-keyboard-power.rules
SLEEP_HOOK=/etc/systemd/system-sleep/asus-keyboard-resume

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root:  sudo bash $0" >&2
  exit 1
fi

if [[ "${1:-}" == "--uninstall" ]]; then
  rm -fv "$UDEV_RULE" "$SLEEP_HOOK"
  udevadm control --reload
  echo "Uninstalled. (power/control for the dock will revert on next replug/reboot.)"
  exit 0
fi

echo "==> Writing udev power rule: $UDEV_RULE"
cat > "$UDEV_RULE" <<'EOF'
# ASUS ROG Flow Z13 (GZ302EA) detachable keyboard/touchpad dock.
# Keep the USB dock powered (no autosuspend) to reduce dead-keyboard-after-resume
# on s2idle. Pairs with /etc/systemd/system-sleep/asus-keyboard-resume.
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", ATTR{idProduct}=="1a30", TEST=="power/control", ATTR{power/control}="on"
EOF

echo "==> Writing resume hook: $SLEEP_HOOK"
mkdir -p "$(dirname "$SLEEP_HOOK")"
cat > "$SLEEP_HOOK" <<'EOF'
#!/bin/bash
# Recover the ASUS ROG Flow Z13 (GZ302EA) detachable keyboard after s2idle resume.
# The USB dock (0b05:1a30) occasionally fails to re-init its HID interfaces on
# wake, leaving the keyboard dead. On resume, if the keyboard input node is
# missing, re-bind the USB device to force re-enumeration.

[[ $1 == post ]] || exit 0

VENDOR=0b05
PRODUCT=1a30

for d in /sys/bus/usb/devices/*/; do
  [[ -e "$d/idVendor" && -e "$d/idProduct" ]] || continue
  [[ "$(<"$d/idVendor")" == "$VENDOR" && "$(<"$d/idProduct")" == "$PRODUCT" ]] || continue

  port="$(basename "$d")"

  # Healthy resume: keyboard input node is present -> nothing to do.
  if grep -qi "GZ302EA-Keyboard" /proc/bus/input/devices 2>/dev/null; then
    exit 0
  fi

  logger -t asus-keyboard-resume "keyboard input missing after resume; rebinding $port"
  echo "$port" > /sys/bus/usb/drivers/usb/unbind 2>/dev/null
  sleep 1
  echo "$port" > /sys/bus/usb/drivers/usb/bind 2>/dev/null

  # Verify; fall back to a device-level reset if rebind didn't restore it.
  sleep 1
  if ! grep -qi "GZ302EA-Keyboard" /proc/bus/input/devices 2>/dev/null; then
    logger -t asus-keyboard-resume "rebind incomplete; issuing usbreset"
    usbreset "$VENDOR:$PRODUCT" 2>/dev/null || true
  fi
  exit 0
done
EOF
chmod 0755 "$SLEEP_HOOK"

echo "==> Reloading udev and applying power rule now"
udevadm control --reload
udevadm trigger --subsystem-match=usb

echo
echo "==> Done. Quick checks:"
echo "    power/control (want 'on'): $(cat /sys/bus/usb/devices/3-4/power/control 2>/dev/null || echo '?')"
echo "    hook installed & executable:"
ls -l "$SLEEP_HOOK"
bash -n "$SLEEP_HOOK" && echo "    hook syntax OK"
echo
echo "Test: suspend a few times (systemctl suspend), wake, and type."
echo "If the hook ever had to recover the keyboard, it is logged at:"
echo "    journalctl -t asus-keyboard-resume"
