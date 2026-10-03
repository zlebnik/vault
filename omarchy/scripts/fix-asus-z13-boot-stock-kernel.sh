#!/usr/bin/env bash
#
# Helper: make stock Arch `linux` the default Limine entry instead of linux-omarchy
# (to hold the kernel constant while debugging, or to sit out a kernel regression).
#
# NOTE 2026-09-20: written on the belief that linux-omarchy 7.2.5 broke s2idle. That
# was WRONG — 7.2.3 bounces out of s2idle the same way (IRQ1 i8042 with no wake fixes
# installed). The "clean" suspends on 7.2.3 were lid-closed ones, where logind retries
# the lid action every 30 s until one sticks. The kernel is not the cause.
#
# Mechanism: Omarchy's migration 1789325478 wrote
#   BOOT_ORDER="linux-omarchy, linux-omarchy-*, *, *fallback, Snapshots"
# into /etc/default/limine. It runs once (marker in /var/lib/omarchy/migrations) and
# keeps `linux` installed, so putting `linux` first sticks. linux-omarchy stays
# installed and selectable from the boot menu for retesting newer builds.
#
# Run:   sudo bash fix-asus-z13-boot-stock-kernel.sh
# Undo:  sudo bash fix-asus-z13-boot-stock-kernel.sh --uninstall   (linux-omarchy first again)
# Then REBOOT.

set -euo pipefail

LIMINE_DEFAULT=/etc/default/limine
ORDER_STOCK='BOOT_ORDER="linux, linux-omarchy, linux-omarchy-*, *, *fallback, Snapshots"'
ORDER_OMARCHY='BOOT_ORDER="linux-omarchy, linux-omarchy-*, *, *fallback, Snapshots"'
MARK="# added by fix-asus-z13-boot-stock-kernel.sh"

die() {
  echo "ERROR: $*" >&2
  exit 1
}

[[ $EUID -eq 0 ]] || die "Run as root:  sudo bash $0"
[[ -f $LIMINE_DEFAULT ]] || die "$LIMINE_DEFAULT not found"

case "${1:-}" in
  "") order="$ORDER_STOCK" ;;
  --uninstall) order="$ORDER_OMARCHY" ;;
  *) die "unknown argument: $1" ;;
esac

if [[ -z ${1:-} ]]; then
  pacman -Q linux >/dev/null 2>&1 || die "stock 'linux' package is not installed"
fi

echo "==> Backing up $LIMINE_DEFAULT -> ${LIMINE_DEFAULT}.bak"
cp -a "$LIMINE_DEFAULT" "${LIMINE_DEFAULT}.bak"

sed -i "/^$MARK\$/d" "$LIMINE_DEFAULT"
sed -i -E '/^[[:space:]]*BOOT_ORDER[[:space:]]*=/d' "$LIMINE_DEFAULT"
{
  [[ -z ${1:-} ]] && echo "$MARK"
  echo "$order"
} >>"$LIMINE_DEFAULT"

echo "==> Regenerating bootloader config"
limine-update
# keep snapshot boot entries in sync (omarchy setup); ignore if not present
command -v limine-snapper-sync >/dev/null 2>&1 && limine-snapper-sync || true

echo
grep -n "BOOT_ORDER" "$LIMINE_DEFAULT"
grep -nE "^default_entry|^ *//linux" /boot/limine.conf | head -5
echo
echo "Done. REBOOT, then confirm:  uname -r"
