#!/bin/bash
#
# Fix: random hard freezes / black screen on the ASUS ROG Flow Z13 (Strix Halo,
# Radeon 8060S) — at the SDDM login screen, after wake from sleep, and sometimes
# a black screen right after boot.
#
# Root cause (from the journal, 27 occurrences):
#   amdgpu ...: SMU: No response msg_reg: 32 resp_reg: 0
#   amdgpu ...: Failed to disable gfxoff!
#   amdgpu ...: [drm] *ERROR* DPM disable vpe failed, ret = -62
# The GPU's SMU firmware stops responding and GFX power-gating (gfxoff) can't be
# toggled, hard-hanging the whole graphical session. This is a known Strix Halo
# issue. Disabling GFXOFF stops the SMU from being asked to power-gate the GFX
# block, which avoids the hang (small idle-power cost).
#
# This appends `amdgpu.gfxoff=0` to the kernel cmdline via /etc/default/limine
# (the persistent, update-safe location — the 99-limine pacman hook re-applies it
# on every kernel update) and regenerates the bootloader config.
#
# Run:   sudo bash fix-amdgpu-gfxoff-freeze.sh
# Undo:  sudo bash fix-amdgpu-gfxoff-freeze.sh --uninstall
# Then REBOOT.

set -euo pipefail

LIMINE_DEFAULT=/etc/default/limine
PARAM="amdgpu.gfxoff=0"
MARK="# added by fix-amdgpu-gfxoff-freeze.sh"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root:  sudo bash $0" >&2
  exit 1
fi

regen() {
  echo "==> Regenerating bootloader config"
  limine-update
  # keep snapshot boot entries in sync (omarchy setup); ignore if not present
  command -v limine-snapper-sync >/dev/null 2>&1 && limine-snapper-sync || true
}

if [[ "${1:-}" == "--uninstall" ]]; then
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

if grep -qF "amdgpu.gfxoff" "$LIMINE_DEFAULT"; then
  echo "amdgpu.gfxoff is already set in $LIMINE_DEFAULT — nothing to do."
  grep -n "amdgpu.gfxoff" "$LIMINE_DEFAULT"
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
echo "==> Verify it landed in the boot entry:"
grep -m1 "amdgpu.gfxoff" /boot/limine.conf && echo "    OK — present in /boot/limine.conf" \
  || echo "    WARNING: not found in /boot/limine.conf — check limine-update output above"

echo
echo "Done. REBOOT to apply:  sudo reboot"
echo "After reboot, confirm it's active:   grep -o 'amdgpu.gfxoff=[0-9]' /proc/cmdline"
echo "And watch for the hang disappearing:  journalctl -k -g 'gfxoff|SMU: No response'"
