#!/usr/bin/env bash
#
# Setup: let the Radeon 8060S (Strix Halo, gfx1151) use most of the 128 GB of unified
# memory for local LLMs, and install a Vulkan llama.cpp.
#
# Why: memory on Strix Halo is mapped, not partitioned. The GPU reaches system RAM
# through GTT, and the kernel caps GTT at half of RAM by default:
#   mem_info_gtt_total = ~60.7 GiB of 127 GiB    (ttm pages_limit = 15924435)
# so any model over ~60 GiB fails to load even though the RAM is there.
#
# Mechanism: `ttm.pages_limit=<4 KiB pages>` on the kernel cmdline raises the cap.
# Default here is 106 GiB (27787264 pages), leaving ~20 GiB for the host.
# `amdgpu.gttsize` is deprecated (logs a warning) and is deliberately NOT used;
# `amd_iommu=off` is deliberately NOT used either — it breaks the XDNA NPU.
# The cmdline goes through /etc/default/limine (update-safe: the 99-limine pacman
# hook re-applies it on every kernel update).
#
# Packages (all from extra): llama-cpp + ggml-vulkan. Vulkan/RADV beats ROCm/HIP
# for decode on gfx1151; add ggml-hip + rocm-hip-sdk later only if you need it.
#
# Also do by hand, once: BIOS → UMA / dedicated VRAM → minimum (512 MB). GTT is
# strictly more flexible than the carve-out (currently 4 GiB).
#
# Run:    sudo bash setup-strix-halo-gtt.sh [--gib N]
# Verify: bash setup-strix-halo-gtt.sh --verify
# Undo:   sudo bash setup-strix-halo-gtt.sh --uninstall     (packages are left alone)
# Then REBOOT.

set -euo pipefail

LIMINE_DEFAULT=/etc/default/limine
MARK="# added by setup-strix-halo-gtt.sh"
PACKAGES=(llama-cpp ggml-vulkan)
GIB=106

die() {
  echo "ERROR: $*" >&2
  exit 1
}

verify() {
  echo "cmdline:        $(grep -o 'ttm.pages_limit=[0-9]*' /proc/cmdline || echo 'ttm.pages_limit not set (kernel default)')"
  echo "ttm pages_limit: $(cat /sys/module/ttm/parameters/pages_limit)"
  for card in /sys/class/drm/card*/device; do
    [[ -r $card/mem_info_gtt_total ]] || continue
    awk -v c="$card" '{ printf "%s GTT:  %.1f GiB\n", c, $1 / 1073741824 }' "$card/mem_info_gtt_total"
    awk -v c="$card" '{ printf "%s VRAM: %.1f GiB\n", c, $1 / 1073741824 }' "$card/mem_info_vram_total"
  done
  for pkg in "${PACKAGES[@]}"; do
    pacman -Q "$pkg" 2>/dev/null || echo "$pkg: not installed"
  done
  if command -v llama-cli >/dev/null; then
    echo "llama.cpp devices:"
    llama-cli --list-devices 2>/dev/null | sed 's/^/  /' || true
  fi
}

regen() {
  echo "==> Regenerating bootloader config"
  limine-update
  # keep snapshot boot entries in sync (omarchy setup); ignore if not present
  command -v limine-snapper-sync >/dev/null 2>&1 && limine-snapper-sync || true
}

remove_param() {
  # remove our marker line and the KERNEL_CMDLINE line that follows it
  sed -i "/$MARK/,+1d" "$LIMINE_DEFAULT"
}

ACTION=install
while (($#)); do
  case "$1" in
    --verify | --status) ACTION=verify ;;
    --uninstall) ACTION=uninstall ;;
    --gib)
      GIB="${2:-}"
      shift
      ;;
    *) die "unknown argument: $1" ;;
  esac
  shift
done

if [[ $ACTION == verify ]]; then
  verify
  exit 0
fi

[[ $EUID -eq 0 ]] || die "Run as root:  sudo bash $0"
[[ -f $LIMINE_DEFAULT ]] || die "$LIMINE_DEFAULT not found"

if [[ $ACTION == uninstall ]]; then
  if grep -qF "$MARK" "$LIMINE_DEFAULT"; then
    remove_param
    echo "Removed ttm.pages_limit from $LIMINE_DEFAULT"
    regen
    echo "Done. Reboot to apply."
  else
    echo "Nothing to remove (marker not found in $LIMINE_DEFAULT)."
  fi
  exit 0
fi

[[ $GIB =~ ^[0-9]+$ ]] || die "--gib needs an integer"
total_gib=$(awk '/MemTotal/ { printf "%d", $2 / 1048576 }' /proc/meminfo)
((GIB >= 16 && GIB <= total_gib - 8)) || die "--gib $GIB out of range (16..$((total_gib - 8)); keep >= 8 GiB for the host)"

PARAM="ttm.pages_limit=$((GIB * 262144))"

if grep -v "^$MARK" "$LIMINE_DEFAULT" | grep -F "ttm.pages_limit" | grep -qvF "$PARAM"; then
  if grep -qF "$MARK" "$LIMINE_DEFAULT"; then
    echo "==> Replacing previous ttm.pages_limit"
    remove_param
  else
    die "ttm.pages_limit is already set in $LIMINE_DEFAULT by something else — not touching it"
  fi
fi

if grep -qF "$PARAM" "$LIMINE_DEFAULT"; then
  echo "$PARAM is already set in $LIMINE_DEFAULT."
else
  echo "==> Backing up $LIMINE_DEFAULT -> ${LIMINE_DEFAULT}.bak"
  cp -a "$LIMINE_DEFAULT" "${LIMINE_DEFAULT}.bak"

  echo "==> Adding '$PARAM' (${GIB} GiB GTT) to kernel cmdline"
  {
    echo ""
    echo "$MARK"
    echo "KERNEL_CMDLINE[default]+=\" $PARAM\""
  } >>"$LIMINE_DEFAULT"

  regen

  grep -qm1 "ttm.pages_limit" /boot/limine.conf && echo "    OK — present in /boot/limine.conf" ||
    echo "    WARNING: not found in /boot/limine.conf — check limine-update output above"
fi

echo "==> Installing ${PACKAGES[*]}"
pacman -S --needed --noconfirm "${PACKAGES[@]}"

echo
echo "Done. REBOOT to apply, then:  bash $0 --verify"
echo "Expect GTT ≈ ${GIB} GiB. Run models with:  llama-server -m <model.gguf> -ngl 999 -fa on"
echo "If RADV crashes in vkCreateComputePipelines: MESA_SHADER_CACHE_DISABLE=true"
