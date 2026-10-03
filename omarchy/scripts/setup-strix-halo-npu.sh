#!/usr/bin/env bash
#
# Setup: make the Ryzen AI Max+ 395 NPU (XDNA2) usable from userspace.
#
# State before: the kernel side is complete — `amdxdna` is loaded, /dev/accel/accel0
# exists, firmware is in /lib/firmware/amdnpu/17f0_* — but no userspace is installed,
# so nothing can talk to the device.
#
# Mechanism:
#   - packages, all from extra: xrt, xrt-plugin-amdxdna (without the plugin XRT does
#     not see the NPU), fastflowlm (NPU-native LLM runtime, `flm`)
#   - NPU buffers are pinned memory, so the default 8 MiB memlock limit makes every
#     run fail. Raised with drop-ins (no edits to the main files):
#       /etc/systemd/system.conf.d/30-npu-memlock.conf   DefaultLimitMEMLOCK=infinity
#       /etc/security/limits.d/99-npu-memlock.conf       * soft/hard memlock unlimited
#
# NEVER add amd_iommu=off on this machine: amdxdna does not work without the IOMMU.
#
# Worth knowing: the GPU is ~2.4x faster on sustained decode. The NPU is for low-power
# small models and for running next to a busy GPU, not for max tok/s.
#
# Run:    sudo bash setup-strix-halo-npu.sh
# Verify: bash setup-strix-halo-npu.sh --verify
# Undo:   sudo bash setup-strix-halo-npu.sh --uninstall     (packages are left alone)
# Then REBOOT (or at least log out and back in) for the memlock limit to apply.

set -euo pipefail

SYSTEMD_DROPIN=/etc/systemd/system.conf.d/30-npu-memlock.conf
LIMITS_DROPIN=/etc/security/limits.d/99-npu-memlock.conf
MARK="# added by setup-strix-halo-npu.sh"
PACKAGES=(xrt xrt-plugin-amdxdna fastflowlm)

die() {
  echo "ERROR: $*" >&2
  exit 1
}

find_xrt_smi() {
  command -v xrt-smi 2>/dev/null && return 0
  for candidate in /opt/xilinx/xrt/bin/xrt-smi /usr/lib/xrt/bin/xrt-smi; do
    [[ -x $candidate ]] && echo "$candidate" && return 0
  done
  return 1
}

verify() {
  local xrt_smi

  echo "module:   $(lsmod | awk '$1 == "amdxdna" { print "amdxdna loaded" }' | grep . || echo 'amdxdna NOT loaded')"
  echo "device:   $(ls /dev/accel/accel* 2>/dev/null | tr '\n' ' ' || true)"
  echo "iommu:    $(grep -o 'amd_iommu=[a-z]*' /proc/cmdline || echo 'default (ok)')"
  echo "memlock:  $(ulimit -l)  (want: unlimited)"
  for pkg in "${PACKAGES[@]}"; do
    pacman -Q "$pkg" 2>/dev/null || echo "$pkg: not installed"
  done

  if xrt_smi=$(find_xrt_smi); then
    echo "== $xrt_smi examine"
    "$xrt_smi" examine || true
  else
    echo "xrt-smi not found"
  fi

  if command -v flm >/dev/null; then
    echo "== flm validate"
    flm validate || true
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
  for file in "$SYSTEMD_DROPIN" "$LIMITS_DROPIN"; do
    if [[ -f $file ]] && grep -qF "$MARK" "$file"; then
      rm -f "$file"
      echo "Removed $file"
    fi
  done
  systemctl daemon-reexec
  echo "Done. Packages left installed: ${PACKAGES[*]}"
  exit 0
fi

grep -q 'amd_iommu=off' /proc/cmdline && die "amd_iommu=off is on the kernel cmdline — amdxdna cannot work with it; remove it first"

echo "==> Installing ${PACKAGES[*]}"
pacman -S --needed --noconfirm "${PACKAGES[@]}"

echo "==> Writing $SYSTEMD_DROPIN"
mkdir -p "$(dirname "$SYSTEMD_DROPIN")"
cat >"$SYSTEMD_DROPIN" <<EOF
$MARK
[Manager]
DefaultLimitMEMLOCK=infinity
EOF

echo "==> Writing $LIMITS_DROPIN"
mkdir -p "$(dirname "$LIMITS_DROPIN")"
cat >"$LIMITS_DROPIN" <<EOF
$MARK
* soft memlock unlimited
* hard memlock unlimited
EOF

systemctl daemon-reexec

echo
echo "Done. REBOOT (or log out and back in), then:  bash $0 --verify"
echo "First run:  flm run llama3.2:1b"
