#!/bin/bash
#
# Fix: intermittent BLACK SCREEN at boot on the ASUS ROG Flow Z13 (Strix Halo).
# The system boots fine underneath (filesystems mount, journal flushes) but the
# panel never lights up — a display bring-up issue, distinct from the SMU/gfxoff
# hang already fixed by amdgpu.gfxoff=0.
#
# The usual culprit on AMD laptop panels is PSR (Panel Self Refresh). Disabling
# it via amdgpu.dcdebugmask=0x10 (DC_DISABLE_PSR) is the standard fix.
#
# Same mechanism/location as the gfxoff fix: /etc/default/limine (update-safe).
#
# Run:   sudo bash fix-amdgpu-black-screen-psr.sh
# Undo:  sudo bash fix-amdgpu-black-screen-psr.sh --uninstall
# Then REBOOT.

set -euo pipefail

LIMINE_DEFAULT=/etc/default/limine
PARAM="amdgpu.dcdebugmask=0x10"
MARK="# added by fix-amdgpu-black-screen-psr.sh"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root:  sudo bash $0" >&2
  exit 1
fi

regen() {
  echo "==> Regenerating bootloader config"
  limine-update
  command -v limine-snapper-sync >/dev/null 2>&1 && limine-snapper-sync || true
}

if [[ "${1:-}" == "--uninstall" ]]; then
  if grep -qF "$MARK" "$LIMINE_DEFAULT"; then
    sed -i "/$MARK/,+1d" "$LIMINE_DEFAULT"
    echo "Removed $PARAM from $LIMINE_DEFAULT"
    regen
    echo "Done. Reboot to apply."
  else
    echo "Nothing to remove (marker not found)."
  fi
  exit 0
fi

if grep -qF "amdgpu.dcdebugmask" "$LIMINE_DEFAULT"; then
  echo "amdgpu.dcdebugmask already set in $LIMINE_DEFAULT — nothing to do."
  grep -n "amdgpu.dcdebugmask" "$LIMINE_DEFAULT"
  exit 0
fi

echo "==> Backing up $LIMINE_DEFAULT -> ${LIMINE_DEFAULT}.bak"
cp -a "$LIMINE_DEFAULT" "${LIMINE_DEFAULT}.bak"

echo "==> Adding '$PARAM' to kernel cmdline"
{
  echo ""
  echo "$MARK"
  echo "KERNEL_CMDLINE[default]+=\" $PARAM\""
} >> "$LIMINE_DEFAULT"

regen

echo
echo "==> Verify it landed:"
grep -m1 "amdgpu.dcdebugmask" /boot/limine.conf && echo "    OK — present in /boot/limine.conf" \
  || echo "    WARNING: not found — check limine-update output above"

echo
echo "Done. REBOOT to apply:  sudo reboot"
echo "After reboot confirm:   grep -o 'amdgpu.dcdebugmask=[0-9a-fx]*' /proc/cmdline"
