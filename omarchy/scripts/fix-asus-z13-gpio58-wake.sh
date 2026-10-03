#!/usr/bin/env bash
#
# Fix: on linux-omarchy 7.2.5 the ASUS ROG Flow Z13 wakes itself 3–4 s after every
# suspend (lid close or `systemctl suspend`). Stock linux 7.2.3 slept fine (27 clean
# suspends in the previous boot, with no wake fixes installed at all).
#
# Root cause (diagnose-suspend-wake.sh, 2026-09-20):
#   PM: Triggering wakeup from IRQ 7            <- pinctrl_amd
#   ACPI: PM: Wakeup unrelated to ACPI SCI
#   +1  IRQ 27:  pin/name: 58 ACPI:Event        <- the only non-unbound pin that moved
#   +1  PNP0C0D:00 (lid) wakeup_active_count
#   ACPI: button: [Firmware Bug]: Unexpected lid state reported by firmware
# GPIO 58 of AMDI0030:00 is an ACPI event pin the firmware pulses right as s2idle is
# entered; it is armed as a wake source, so the machine bounces straight back up.
# Not ITE8353 (already unbound), not gpe1A (masked), not the EC (ec_no_wakeup=Y).
#
# Mechanism: `gpiolib_acpi.ignore_wake=AMDI0030:00@58` — the kernel's own quirk knob:
# the pin keeps delivering its ACPI event while awake, it just is not armed for wake.
# The parameter is read-only at runtime, so it goes on the kernel cmdline via
# /etc/default/limine (update-safe: the 99-limine pacman hook re-applies it).
#
# Wake sources that remain: dock keyboard 0b05:1a30, Bluetooth 13d3:3608, power button.
# CHECK after applying: whether opening the lid still wakes the machine.
#
# Run:    sudo bash fix-asus-z13-gpio58-wake.sh
# Verify: bash fix-asus-z13-gpio58-wake.sh --verify
# Undo:   sudo bash fix-asus-z13-gpio58-wake.sh --uninstall
# Then REBOOT.

set -euo pipefail

LIMINE_DEFAULT=/etc/default/limine
PARAM="gpiolib_acpi.ignore_wake=AMDI0030:00@58"
MARK="# added by fix-asus-z13-gpio58-wake.sh"

die() {
  echo "ERROR: $*" >&2
  exit 1
}

regen() {
  echo "==> Regenerating bootloader config"
  limine-update
  # keep snapshot boot entries in sync (omarchy setup); ignore if not present
  command -v limine-snapper-sync >/dev/null 2>&1 && limine-snapper-sync || true
}

case "${1:-}" in
  --verify | --status)
    echo "kernel:      $(uname -r)"
    echo "cmdline:     $(grep -o 'gpiolib_acpi.ignore_wake=[^ ]*' /proc/cmdline || echo 'not set')"
    echo "ignore_wake: $(cat /sys/module/gpiolib_acpi/parameters/ignore_wake)"
    echo "last wake:   IRQ $(cat /sys/power/pm_wakeup_irq 2>/dev/null || echo '-')"
    journalctl -k -b --no-pager | grep -E "PM: suspend (entry|exit)" | tail -6
    exit 0
    ;;
  "" | --uninstall) ;;
  *) die "unknown argument: $1" ;;
esac

[[ $EUID -eq 0 ]] || die "Run as root:  sudo bash $0"
[[ -f $LIMINE_DEFAULT ]] || die "$LIMINE_DEFAULT not found"

if [[ ${1:-} == "--uninstall" ]]; then
  if grep -qF "$MARK" "$LIMINE_DEFAULT"; then
    # remove our marker line and the KERNEL_CMDLINE line that follows it
    sed -i "/$MARK/,+1d" "$LIMINE_DEFAULT"
    echo "Removed $PARAM from $LIMINE_DEFAULT"
    regen
    echo "Done. Reboot to apply."
  else
    echo "Nothing to remove (marker not found in $LIMINE_DEFAULT)."
  fi
  exit 0
fi

if grep -qF "gpiolib_acpi.ignore_wake" "$LIMINE_DEFAULT"; then
  echo "gpiolib_acpi.ignore_wake is already set in $LIMINE_DEFAULT — nothing to do."
  grep -n "gpiolib_acpi.ignore_wake" "$LIMINE_DEFAULT"
  exit 0
fi

echo "==> Backing up $LIMINE_DEFAULT -> ${LIMINE_DEFAULT}.bak"
cp -a "$LIMINE_DEFAULT" "${LIMINE_DEFAULT}.bak"

echo "==> Adding '$PARAM' to kernel cmdline"
{
  echo ""
  echo "$MARK"
  echo "KERNEL_CMDLINE[default]+=\" $PARAM\""
} >>"$LIMINE_DEFAULT"

regen

grep -qm1 "gpiolib_acpi.ignore_wake" /boot/limine.conf && echo "    OK — present in /boot/limine.conf" ||
  echo "    WARNING: not found in /boot/limine.conf — check limine-update output above"

echo
echo "Done. REBOOT, close the lid for a few minutes, then:  bash $0 --verify"
