#!/usr/bin/env bash
#
# fix-asus-z13-spurious-wake.sh — stop the ASUS Z13 (homespace) from waking itself
# ~4s after `systemctl suspend`, by disabling wake on ONLY the guilty device that
# diagnose-suspend-wake.sh identified.
#
# Keeps wanted wakes working: Bluetooth 13d3:3608 and dock keyboard 0b05:1a30 are
# refused as targets so they can never be disabled by this script.
#
# Usage:
#   sudo bash fix-asus-z13-spurious-wake.sh --all-safe          # <-- RECOMMENDED: the 4 proven-safe fixes, NO gpe1A mask
#   sudo bash fix-asus-z13-spurious-wake.sh --i8042             # disable phantom PS/2 (IRQ1) wake
#   sudo bash fix-asus-z13-spurious-wake.sh --usb   VID:PID     # e.g. --usb 0b05:18c6
#   sudo bash fix-asus-z13-spurious-wake.sh --acpi  NAME        # e.g. --acpi USBC000  (a /proc/acpi/wakeup device)
#   sudo bash fix-asus-z13-spurious-wake.sh --uninstall
#
# NOTE: the --gpe (gpe1A) mask is intentionally NOT part of --all-safe: it was the
# least-necessary layer and the only one that could conceivably touch PCIe/WiFi power.
#
# Idempotent: re-running applies the same state. --uninstall removes everything.

set -uo pipefail

UDEV_RULE="/etc/udev/rules.d/99-disable-spurious-wake.rules"
ACPI_SERVICE="/etc/systemd/system/omarchy-disable-wake.service"
ACPI_HELPER="/usr/local/sbin/omarchy-disable-acpi-wake"
# NOTE: this systemd build scans ONLY /usr/lib/systemd/system-sleep/ (not /etc/...),
# so the hook must live here to actually run.
SLEEP_HOOK="/usr/lib/systemd/system-sleep/omarchy-spurious-wake-unbind"
SLEEP_HOOK_OLD="/etc/systemd/system-sleep/omarchy-spurious-wake-unbind"
EC_SERVICE="/etc/systemd/system/omarchy-ec-no-wakeup.service"
EC_HELPER="/usr/local/sbin/omarchy-ec-no-wakeup"
WIFI_SERVICE="/etc/systemd/system/omarchy-mt7925-heal.service"
WIFI_HELPER="/usr/local/sbin/omarchy-mt7925-heal"

# Devices we must never disable (wanted wake sources).
PROTECTED_USB="13d3:3608 0b05:1a30"

die() { echo "ERROR: $*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "Run as root:  sudo bash $0 $*"

# Append a udev rule to $UDEV_RULE idempotently (rules stack; each fix adds one line).
# $1 = unique tag (for the dedupe/comment), $2 = the rule line.
add_udev_rule() {
  local tag="$1" rule="$2"
  if [[ ! -f "$UDEV_RULE" ]]; then
    cat > "$UDEV_RULE" <<'HDR'
# Disable spurious wake sources on ASUS Z13 (homespace).
# Installed by fix-asus-z13-spurious-wake.sh — rules stack, one per wake source.
# The existing 99-bluetooth-wake.rules still ENABLES wake for Bluetooth 13d3:3608
# and USB keyboard 0b05:1a30; nothing here touches those.
HDR
  fi
  if grep -qF "# tag:$tag" "$UDEV_RULE" 2>/dev/null; then
    echo "udev rule for [$tag] already present in $UDEV_RULE"
  else
    printf '# tag:%s\n%s\n' "$tag" "$rule" >> "$UDEV_RULE"
    echo "added udev rule [$tag] -> $UDEV_RULE"
  fi
}

uninstall() {
  local changed=0
  if [[ -f "$UDEV_RULE" ]]; then rm -f "$UDEV_RULE"; echo "removed $UDEV_RULE"; changed=1; fi
  if [[ -f "$ACPI_SERVICE" ]]; then
    systemctl disable --now omarchy-disable-wake.service 2>/dev/null || true
    rm -f "$ACPI_SERVICE"; echo "removed $ACPI_SERVICE"; changed=1
  fi
  if [[ -f "$ACPI_HELPER" ]]; then rm -f "$ACPI_HELPER"; echo "removed $ACPI_HELPER"; changed=1; fi
  if [[ -f "$SLEEP_HOOK" ]]; then rm -f "$SLEEP_HOOK"; echo "removed $SLEEP_HOOK"; changed=1; fi
  if [[ -f "$SLEEP_HOOK_OLD" ]]; then rm -f "$SLEEP_HOOK_OLD"; echo "removed $SLEEP_HOOK_OLD"; changed=1; fi
  if [[ -f "$EC_SERVICE" ]]; then
    systemctl disable --now omarchy-ec-no-wakeup.service 2>/dev/null || true
    rm -f "$EC_SERVICE"; echo "removed $EC_SERVICE"; changed=1
    echo N > /sys/module/acpi/parameters/ec_no_wakeup 2>/dev/null || true
  fi
  if [[ -f "$EC_HELPER" ]]; then rm -f "$EC_HELPER"; echo "removed $EC_HELPER"; changed=1; fi
  if [[ -f "$WIFI_SERVICE" ]]; then
    systemctl disable --now omarchy-mt7925-heal.service 2>/dev/null || true
    rm -f "$WIFI_SERVICE"; echo "removed $WIFI_SERVICE"; changed=1
  fi
  if [[ -f "$WIFI_HELPER" ]]; then rm -f "$WIFI_HELPER"; echo "removed $WIFI_HELPER"; changed=1; fi
  if [[ $changed -eq 1 ]]; then
    systemctl daemon-reload 2>/dev/null || true
    udevadm control --reload 2>/dev/null || true
    echo "Uninstalled. Wake sources revert to defaults on next boot (or run: udevadm trigger)."
  else
    echo "Nothing installed; nothing to remove."
  fi
}

install_usb() {
  local vidpid="$1"
  [[ "$vidpid" =~ ^[0-9a-fA-F]{4}:[0-9a-fA-F]{4}$ ]] || die "--usb expects VID:PID, got '$vidpid'"
  local vid="${vidpid%%:*}" pid="${vidpid##*:}"
  vid="${vid,,}"; pid="${pid,,}"

  for p in $PROTECTED_USB; do
    [[ "${vidpid,,}" == "$p" ]] && die "Refusing to disable wake on protected device $vidpid (Bluetooth/keyboard)."
  done

  # Warn if the device isn't present, but still install (it may be a dock detached now).
  if ! lsusb 2>/dev/null | grep -qi "ID $vid:$pid"; then
    echo "Note: USB $vid:$pid not currently connected — installing rule anyway."
  fi

  add_udev_rule "usb-$vid:$pid" \
    "ACTION==\"add\", SUBSYSTEM==\"usb\", ATTR{idVendor}==\"$vid\", ATTR{idProduct}==\"$pid\", ATTR{power/wakeup}=\"disabled\""

  udevadm control --reload
  udevadm trigger --subsystem-match=usb --attr-match=idVendor="$vid" --attr-match=idProduct="$pid" 2>/dev/null || true

  echo
  echo "== verify: current wakeup state for $vid:$pid =="
  local found=0 d
  for d in /sys/bus/usb/devices/*; do
    if [[ "$(cat "$d/idVendor" 2>/dev/null)" == "$vid" && "$(cat "$d/idProduct" 2>/dev/null)" == "$pid" ]]; then
      echo "  $(basename "$d")  $(cat "$d/product" 2>/dev/null)  ->  power/wakeup=$(cat "$d/power/wakeup" 2>/dev/null)"
      found=1
    fi
  done
  [[ $found -eq 1 ]] || echo "  (device not connected; rule applies when it reappears)"
}

install_i8042() {
  # The legacy i8042 PS/2 keyboard port (serio0, driver atkbd) fires spurious IRQ1
  # wakeups on this AMD s2idle firmware. The real keyboard is USB (0b05:1a30), so
  # disabling PS/2 wake is safe. Match the port by its stable description attribute.
  add_udev_rule "i8042-kbd" \
    "ACTION==\"add\", SUBSYSTEM==\"serio\", ATTR{description}==\"i8042 KBD port\", ATTR{power/wakeup}=\"disabled\""

  udevadm control --reload
  udevadm trigger --subsystem-match=serio 2>/dev/null || true
  # Apply now without waiting for a re-add event.
  for w in /sys/devices/platform/i8042/serio*/power/wakeup; do
    [[ -e "$w" ]] && echo disabled > "$w" 2>/dev/null || true
  done

  echo
  echo "== verify: i8042 serio wakeup state =="
  local any=0 w d
  for w in /sys/devices/platform/i8042/serio*/power/wakeup; do
    [[ -e "$w" ]] || continue
    d="$(dirname "$(dirname "$w")")"
    echo "  $(basename "$d")  \"$(cat "$d/description" 2>/dev/null)\"  ->  power/wakeup=$(cat "$w")"
    any=1
  done
  [[ $any -eq 1 ]] || echo "  (no i8042 serio ports found?)"
}

install_i2c() {
  # Disable wake on an ACPI i2c-HID input device (e.g. ITE8353:00 touchscreen/HID,
  # ELAN9008:00 touchpad) that spuriously wakes s2idle via the AMD GPIO (IRQ7 /
  # pinctrl_amd). The device keeps working while awake; it just no longer wakes the
  # machine. You still wake via the USB keyboard / Bluetooth.
  local name="$1"
  [[ "$name" =~ ^[A-Za-z0-9:._-]+$ ]] || die "--i2c expects an i2c device name like ITE8353:00 (got '$1')"

  # Locate the device to warn if absent and to apply immediately.
  local dev="" d
  for d in $(find /sys/bus/i2c/devices -maxdepth 1 -name "i2c-*" 2>/dev/null); do
    [[ "$(cat "$d/name" 2>/dev/null)" == "$name" ]] && { dev="$d"; break; }
  done
  [[ -n "$dev" ]] || echo "Note: i2c device '$name' not found right now — installing rule anyway."

  add_udev_rule "i2c-$name" \
    "ACTION==\"add\", SUBSYSTEM==\"i2c\", ATTR{name}==\"$name\", ATTR{power/wakeup}=\"disabled\""

  udevadm control --reload
  udevadm trigger --subsystem-match=i2c 2>/dev/null || true
  # Apply now.
  [[ -n "$dev" && -e "$dev/power/wakeup" ]] && echo disabled > "$dev/power/wakeup" 2>/dev/null || true

  echo
  echo "== verify: i2c '$name' wakeup state =="
  if [[ -n "$dev" && -e "$dev/power/wakeup" ]]; then
    echo "  $(basename "$dev")  name=$name  ->  power/wakeup=$(cat "$dev/power/wakeup")"
  else
    echo "  (device not present; rule applies when it appears)"
  fi
}

install_i2c_unbind() {
  # For an i2c-HID device that fires interrupts continuously (e.g. the ITE8353
  # sensor hub reporting ~1x/sec), merely clearing its wake flag is not enough —
  # a fresh interrupt arrives within ~1s of entering s2idle and pulls the machine
  # back out. So detach it from its driver just before sleep (releasing the GPIO
  # IRQ) and re-attach on resume. The device works normally while awake.
  local name="$1"
  [[ "$name" =~ ^[A-Za-z0-9:._-]+$ ]] || die "--i2c-unbind expects a name like ITE8353:00 (got '$1')"
  local devk="i2c-$name" drv="/sys/bus/i2c/drivers/i2c_hid_acpi"

  if [[ ! -e "$drv/$devk" ]]; then
    # Try to discover the actual driver currently bound to this device.
    local d found=""
    for d in /sys/bus/i2c/devices/i2c-*; do
      if [[ "$(cat "$d/name" 2>/dev/null)" == "$name" ]]; then
        found="$(basename "$(readlink "$d/driver" 2>/dev/null)" 2>/dev/null)"; devk="$(basename "$d")"; break
      fi
    done
    [[ -n "$found" ]] && drv="/sys/bus/i2c/drivers/$found"
    [[ -e "$drv/$devk" ]] || echo "Note: $name not bound to an i2c-HID driver right now — installing hook anyway (targets driver $(basename "$drv"))."
  fi
  local drvname; drvname="$(basename "$drv")"

  # Remove any stale copy in /etc (that dir is not scanned by this systemd build).
  [[ -f "$SLEEP_HOOK_OLD" ]] && { rm -f "$SLEEP_HOOK_OLD"; echo "removed stale $SLEEP_HOOK_OLD"; }

  cat > "$SLEEP_HOOK" <<EOF
#!/bin/bash
# Unbind the '$name' i2c-HID device around sleep so its GPIO interrupt (pinctrl_amd
# / IRQ7) does not immediately wake s2idle; rebind on resume. Only touches this one
# device (the touchpad and others keep working). Installed by
# fix-asus-z13-spurious-wake.sh. Must live in /usr/lib/systemd/system-sleep/ — this
# systemd build does not scan /etc/systemd/system-sleep/.
DRV="/sys/bus/i2c/drivers/$drvname"
DEV="$devk"
case "\$1" in
  pre)  if [[ -e "\$DRV/\$DEV" ]]; then echo "\$DEV" > "\$DRV/unbind" 2>/dev/null \
          && logger -t spurious-wake-unbind "unbound \$DEV before \$2"; fi ;;
  post) if [[ ! -e "\$DRV/\$DEV" ]]; then echo "\$DEV" > "\$DRV/bind" 2>/dev/null \
          && logger -t spurious-wake-unbind "rebound \$DEV after \$2"; fi ;;
esac
exit 0
EOF
  chmod 755 "$SLEEP_HOOK"
  echo "wrote $SLEEP_HOOK  (driver=$drvname device=$devk)"

  echo
  echo "== verify: hook present & executable =="
  ls -l "$SLEEP_HOOK" | sed 's/^/  /'
  echo "  Takes effect on the NEXT suspend (unbinds '$name' during sleep, rebinds on wake)."
}

install_wifi_heal() {
  # Safety net: the MediaTek MT7925 intermittently loses its firmware-load race at
  # boot and comes up with no wlan interface. If that happens, reload the driver once.
  cat > "$WIFI_HELPER" <<'EOF'
#!/usr/bin/env bash
# Reload mt7925e if no wlan interface appears shortly after boot. Installed by
# fix-asus-z13-spurious-wake.sh.
set -u
for _ in 1 2 3 4 5 6 7 8; do
  ip -br link 2>/dev/null | grep -qiE '^wl' && exit 0
  sleep 2
done
logger -t mt7925-heal "no wlan interface ~16s after boot; reloading mt7925e"
modprobe -r mt7925e 2>/dev/null; sleep 1; modprobe mt7925e 2>/dev/null
EOF
  chmod +x "$WIFI_HELPER"
  echo "wrote $WIFI_HELPER"

  cat > "$WIFI_SERVICE" <<EOF
[Unit]
Description=Reload MT7925 WiFi if it lost the firmware race at boot
After=multi-user.target

[Service]
Type=oneshot
ExecStart=$WIFI_HELPER

[Install]
WantedBy=multi-user.target
EOF
  echo "wrote $WIFI_SERVICE"

  systemctl daemon-reload
  systemctl enable --now omarchy-mt7925-heal.service
  echo "  (checks for wlan at each boot; reloads mt7925e only if missing)"
}

install_full() {
  # Robust set: all 4 wake fixes + WiFi auto-heal safety net.
  echo "### [1/6] i8042 PS/2 wake ###";           install_i8042
  echo; echo "### [2/6] ITE8353 sleep-unbind ###"; install_i2c_unbind "ITE8353:00"
  echo; echo "### [3/6] ITE8353 wake flag ###";    install_i2c "ITE8353:00"
  echo; echo "### [4/6] ec_no_wakeup ###";         install_ec_no_wakeup
  echo; echo "### [5/6] gpe1A mask ###";           install_gpe "gpe1A"
  echo; echo "### [6/6] MT7925 WiFi auto-heal ###"; install_wifi_heal
  echo
  echo "Full robust fix applied. Now: sudo bash diagnose-suspend-wake.sh (a few times), then reboot."
}

install_minimal() {
  # THE minimal proven set (empirically reduced): only the two fixes that address
  # wake sources which actually keep firing on this machine.
  #   1) ITE8353 sensor-hub unbind during sleep  (IRQ7/pin8, ~1/sec)
  #   2) ec_no_wakeup                             (IRQ9, EC battery/AC notify)
  # NOT included (tested unnecessary): i8042 PS/2 wake, ITE8353 wake-flag rule, gpe1A.
  echo "### [1/2] ITE8353 sleep-unbind ###"; install_i2c_unbind "ITE8353:00"
  echo; echo "### [2/2] ec_no_wakeup ###";   install_ec_no_wakeup
  echo
  echo "Minimal fix applied (ITE8353 unbind + ec_no_wakeup). Now: sudo bash diagnose-suspend-wake.sh"
}

install_all_safe() {
  # The proven-working set MINUS the gpe1A mask (dropped as the only WiFi suspect):
  #   1) i8042 PS/2 wake off   2) ITE8353 sensor-hub unbind during sleep
  #   3) ITE8353 wake flag off 4) ec_no_wakeup (EC battery/AC notify)
  echo "### [1/4] i8042 PS/2 wake ###";        install_i8042
  echo; echo "### [2/4] ITE8353 sleep-unbind ###"; install_i2c_unbind "ITE8353:00"
  echo; echo "### [3/4] ITE8353 wake flag ###";    install_i2c "ITE8353:00"
  echo; echo "### [4/4] ec_no_wakeup ###";         install_ec_no_wakeup
  echo
  echo "All safe fixes applied (no gpe1A mask). Now: sudo bash diagnose-suspend-wake.sh"
}

install_ec_no_wakeup() {
  # THE key fix for the EC-triggered s2idle wake (battery/AC Notify on IRQ9): tell the
  # kernel to ignore EC events as suspend-to-idle wake triggers. Power button, lid and
  # USB keyboard still wake the machine; charging/thermal/battery reporting are
  # unaffected (verified: toggling this does not change charging). Runtime-writable, so
  # a boot oneshot is enough — no bootloader/UKI rebuild needed.
  [[ -e /sys/module/acpi/parameters/ec_no_wakeup ]] || die "ec_no_wakeup not supported by this kernel"

  cat > "$EC_HELPER" <<'EOF'
#!/usr/bin/env bash
# Ignore EC events as suspend-to-idle wake triggers on ASUS Z13. Installed by
# fix-asus-z13-spurious-wake.sh.
set -u
[[ -e /sys/module/acpi/parameters/ec_no_wakeup ]] && echo Y > /sys/module/acpi/parameters/ec_no_wakeup
EOF
  chmod +x "$EC_HELPER"
  echo "wrote $EC_HELPER"

  cat > "$EC_SERVICE" <<EOF
[Unit]
Description=Ignore EC events as s2idle wake source on ASUS Z13 (ec_no_wakeup)
After=multi-user.target

[Service]
Type=oneshot
ExecStart=$EC_HELPER

[Install]
WantedBy=multi-user.target
EOF
  echo "wrote $EC_SERVICE"

  systemctl daemon-reload
  systemctl enable --now omarchy-ec-no-wakeup.service

  echo
  echo "== verify: ec_no_wakeup =="
  echo "  /sys/module/acpi/parameters/ec_no_wakeup = $(cat /sys/module/acpi/parameters/ec_no_wakeup)  (want Y)"
}

install_gpe() {
  # Mask a specific ACPI GPE that spuriously wakes s2idle (IRQ9 / "non-EC GPE wakeup").
  # /sys/firmware/acpi/interrupts/gpeXX accepts: enable|disable|clear|mask|unmask.
  # "mask" durably stops it from firing. Masking resets on reboot, so a boot service
  # re-applies it. NOTE: never mask gpe0A here — that's the EC (keyboard/lid/battery).
  local gpe="${1,,}"
  [[ "$gpe" =~ ^gpe[0-9a-f]+$ ]] || die "--gpe expects a name like gpe19 (got '$1')"
  [[ "$gpe" == "gpe0a" ]] && die "Refusing to mask gpe0A (the Embedded Controller)."
  # sysfs uses uppercase hex in the node name (e.g. gpe19, gpe1A).
  local node="/sys/firmware/acpi/interrupts/$gpe"
  [[ -e "$node" ]] || node="/sys/firmware/acpi/interrupts/${gpe/gpe/gpe}"
  if [[ ! -e "$node" ]]; then
    # try to find case-insensitively
    node="$(find /sys/firmware/acpi/interrupts -maxdepth 1 -iname "$gpe" 2>/dev/null | head -1)"
  fi
  [[ -n "$node" && -e "$node" ]] || die "$gpe not found under /sys/firmware/acpi/interrupts/"
  local gpename; gpename="$(basename "$node")"

  cat > "$ACPI_HELPER" <<EOF
#!/usr/bin/env bash
# Mask spurious ACPI wake GPE '$gpename' on ASUS Z13. Idempotent.
set -u
node="/sys/firmware/acpi/interrupts/$gpename"
[[ -e "\$node" ]] || node="\$(find /sys/firmware/acpi/interrupts -maxdepth 1 -iname '$gpename' | head -1)"
[[ -n "\$node" && -e "\$node" ]] && echo mask > "\$node"
EOF
  chmod +x "$ACPI_HELPER"
  echo "wrote $ACPI_HELPER"

  cat > "$ACPI_SERVICE" <<EOF
[Unit]
Description=Mask spurious ACPI wake GPE ($gpename) on ASUS Z13
After=multi-user.target

[Service]
Type=oneshot
ExecStart=$ACPI_HELPER

[Install]
WantedBy=multi-user.target
EOF
  echo "wrote $ACPI_SERVICE"

  systemctl daemon-reload
  systemctl enable --now omarchy-disable-wake.service

  echo
  echo "== verify: $gpename state =="
  cat "$node" | sed "s|^|  $gpename: |"
}

install_acpi() {
  local name="$1"
  [[ "$name" =~ ^[A-Za-z0-9._-]+$ ]] || die "--acpi expects a /proc/acpi/wakeup device name, got '$name'"
  grep -qw "$name" /proc/acpi/wakeup || die "'$name' not found in /proc/acpi/wakeup. Available:
$(awk 'NR==1 || /enabled|disabled/' /proc/acpi/wakeup)"

  # /proc/acpi/wakeup is a TOGGLE and does not persist across boot, so install a
  # boot-time oneshot that disables the device only if it is currently enabled.
  cat > "$ACPI_HELPER" <<EOF
#!/usr/bin/env bash
# Disable spurious ACPI wake source '$name' on ASUS Z13. Idempotent: only toggles
# when currently *enabled (writing the name flips its state).
set -u
if grep -qE "^$name\b.*\*enabled" /proc/acpi/wakeup; then
  echo "$name" > /proc/acpi/wakeup
fi
EOF
  chmod +x "$ACPI_HELPER"
  echo "wrote $ACPI_HELPER"

  cat > "$ACPI_SERVICE" <<EOF
[Unit]
Description=Disable spurious ACPI wake source ($name) on ASUS Z13
After=multi-user.target

[Service]
Type=oneshot
ExecStart=$ACPI_HELPER

[Install]
WantedBy=multi-user.target
EOF
  echo "wrote $ACPI_SERVICE"

  systemctl daemon-reload
  systemctl enable --now omarchy-disable-wake.service

  echo
  echo "== verify: /proc/acpi/wakeup line for $name =="
  grep -E "^$name\b" /proc/acpi/wakeup | sed 's/^/  /'
}

case "${1:-}" in
  --uninstall) uninstall ;;
  --full) install_full ;;
  --wifi-heal) install_wifi_heal ;;
  --minimal) install_minimal ;;
  --all-safe) install_all_safe ;;
  --i8042) install_i8042 ;;
  --i2c)  [[ -n "${2:-}" ]] || die "--i2c needs a device name like ITE8353:00"; install_i2c "$2" ;;
  --i2c-unbind) [[ -n "${2:-}" ]] || die "--i2c-unbind needs a name like ITE8353:00"; install_i2c_unbind "$2" ;;
  --ec-no-wakeup) install_ec_no_wakeup ;;
  --gpe)  [[ -n "${2:-}" ]] || die "--gpe needs a name like gpe19"; install_gpe "$2" ;;
  --usb)  [[ -n "${2:-}" ]] || die "--usb needs VID:PID";  install_usb "$2" ;;
  --acpi) [[ -n "${2:-}" ]] || die "--acpi needs NAME";    install_acpi "$2" ;;
  *)
    cat >&2 <<EOF
Usage:
  sudo bash $0 --full            RECOMMENDED: all 4 wake fixes + MT7925 WiFi auto-heal
  sudo bash $0 --wifi-heal       just the MT7925 auto-reload-if-missing boot service
  sudo bash $0 --minimal         the 2 essential fixes only (ITE8353 unbind + ec_no_wakeup)
  sudo bash $0 --all-safe        4 safe fixes, no gpe1A (i8042 + ITE8353 + ec_no_wakeup)
  sudo bash $0 --i8042           disable phantom PS/2 (IRQ1) wake
  sudo bash $0 --i2c NAME        disable wake flag on an i2c-HID device (e.g. --i2c ITE8353:00)
  sudo bash $0 --i2c-unbind NAME unbind a chatty i2c-HID device during sleep (e.g. --i2c-unbind ITE8353:00)
  sudo bash $0 --ec-no-wakeup    ignore EC events as s2idle wake (fixes the battery-notify IRQ9 wake)
  sudo bash $0 --gpe gpeXX       mask a spurious ACPI GPE (IRQ9 wake, e.g. --gpe gpe19)
  sudo bash $0 --usb VID:PID     disable wake on a USB device (e.g. --usb 0b05:18c6)
  sudo bash $0 --acpi NAME       disable an ACPI wake source  (e.g. --acpi USBC000)
  sudo bash $0 --uninstall       remove everything this script installed

Run diagnose-suspend-wake.sh first to learn which device to pass.
Protected (never disabled): Bluetooth 13d3:3608, keyboard 0b05:1a30.
EOF
    exit 2 ;;
esac

echo
echo "Done. Now re-run diagnose-suspend-wake.sh to confirm the machine STAYS asleep."
