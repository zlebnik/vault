#!/usr/bin/env bash
#
# fix-asus-z13-fan-curves.sh — enable aggressive custom fan curves on the ASUS ROG
# Flow Z13 (GZ302EA, Strix Halo) so the fans actually reach 100% before the EC's
# hard thermal trip cuts power.
#
# Why: with asusd's custom curves disabled (the default) the EC runs its factory
# table. The factory "performance" table the kernel reads back tops out at
# 80 °C -> 147/255 (58%) for the CPU fan and 155/255 (61%) for the GPU fan and
# never grows past that. Gaming in clamshell (lid closed, 4K HDMI) pushed Tctl past
# 90 °C with the fans nowhere near max, followed by a hard power cut with nothing
# in the journal. A custom curve that hits 100% at 80 °C buys real headroom.
#
# Curves are written through asusd (asusctl fan-curve ...), which persists them in
# /etc/asusd/fan_curves.ron and re-applies them on profile change and resume.
#
# Usage:
#   sudo bash fix-asus-z13-fan-curves.sh            # apply + enable (performance + balanced)
#   sudo bash fix-asus-z13-fan-curves.sh --verify   # show current state only
#   sudo bash fix-asus-z13-fan-curves.sh --uninstall  # back to factory curves
#
# Idempotent. Quiet profile is left untouched.

set -uo pipefail

# 8 points, "TEMPc:PWM%". CPU-fan points track CPU temp, GPU-fan points track GPU temp.
PERF_CURVE="42c:12%,50c:22%,55c:35%,60c:50%,65c:65%,70c:80%,75c:95%,80c:100%"
BAL_CURVE="42c:10%,50c:20%,55c:30%,60c:45%,65c:60%,70c:75%,75c:85%,80c:100%"

die() { echo "ERROR: $*" >&2; exit 1; }

need_tools() {
  command -v asusctl >/dev/null || die "asusctl not installed (pacman -S asusctl)"
  systemctl is-active --quiet asusd || die "asusd.service is not running"
}

# Path of the asus_custom_fan_curve hwmon node (number is not stable across boots).
custom_hwmon() {
  local h
  for h in /sys/class/hwmon/hwmon*; do
    [[ "$(cat "$h/name" 2>/dev/null)" == "asus_custom_fan_curve" ]] && { echo "$h"; return 0; }
  done
  return 1
}

verify() {
  local h
  echo "== asusd: enabled fan-curve profiles =="
  asusctl fan-curve --get-enabled 2>&1 | sed 's/^/  /'
  echo "== asusd: performance curves =="
  asusctl fan-curve --mod-profile performance 2>&1 | grep -E 'fan:|pwm:|temp:|enabled:' | sed 's/^/  /'
  echo "== platform_profile: $(cat /sys/firmware/acpi/platform_profile 2>/dev/null) =="
  if h="$(custom_hwmon)"; then
    echo "== kernel: $h (asus_custom_fan_curve) =="
    local p i
    for p in 1 2; do
      printf '  pwm%s_enable=%s (1 = custom curve active, 2 = factory)  points:' "$p" "$(cat "$h/pwm${p}_enable")"
      for i in 1 2 3 4 5 6 7 8; do
        printf ' %s°C→%s' "$(cat "$h/pwm${p}_auto_point${i}_temp")" "$(cat "$h/pwm${p}_auto_point${i}_pwm")"
      done
      echo
    done
  else
    echo "  (asus_custom_fan_curve hwmon not found — kernel driver missing?)"
  fi
  echo "== fans now =="
  for h in /sys/class/hwmon/hwmon*; do
    [[ "$(cat "$h/name" 2>/dev/null)" == "asus" ]] || continue
    echo "  cpu_fan=$(cat "$h/fan1_input" 2>/dev/null) rpm  gpu_fan=$(cat "$h/fan2_input" 2>/dev/null) rpm"
  done
}

apply_profile() {
  local profile="$1" curve="$2" fan
  for fan in cpu gpu; do
    asusctl fan-curve --mod-profile "$profile" --fan "$fan" --data "$curve" >/dev/null \
      || die "failed to set $profile/$fan curve"
  done
  # NOTE: --data resets the enabled flag, so enable must come last.
  asusctl fan-curve --mod-profile "$profile" --enable-fan-curves true >/dev/null \
    || die "failed to enable curves for $profile"
  echo "set + enabled $profile curve: $curve"
}

install() {
  need_tools
  apply_profile performance "$PERF_CURVE"
  apply_profile balanced "$BAL_CURVE"
  # asusd writes the curve for the *active* profile immediately; nudge it so the
  # kernel-side state reflects the new table without waiting for a profile change.
  local cur; cur="$(cat /sys/firmware/acpi/platform_profile 2>/dev/null)"
  if [[ "$cur" == performance || "$cur" == balanced ]]; then
    asusctl profile set "$cur" >/dev/null 2>&1 || true
  fi
  sleep 1
  echo
  verify
  echo
  local h
  if h="$(custom_hwmon)" && [[ "$cur" == performance || "$cur" == balanced ]]; then
    [[ "$(cat "$h/pwm1_enable")" == 1 && "$(cat "$h/pwm1_auto_point8_pwm")" == 255 ]] \
      && echo "OK: custom curve active, CPU fan reaches 255 (100%) at $(cat "$h/pwm1_auto_point8_temp") °C" \
      || echo "WARN: kernel does not show the custom curve active yet — try switching profile (asusctl profile set performance) or reboot"
  fi
  echo "Expect more fan noise from ~65 °C. Revert: sudo bash $0 --uninstall"
}

uninstall() {
  need_tools
  local p
  for p in performance balanced; do
    asusctl fan-curve --mod-profile "$p" --enable-fan-curves false >/dev/null 2>&1 && echo "disabled custom curves for $p"
  done
  local cur; cur="$(cat /sys/firmware/acpi/platform_profile 2>/dev/null)"
  asusctl fan-curve --default >/dev/null 2>&1 || true
  [[ -n "$cur" ]] && asusctl profile set "$cur" >/dev/null 2>&1 || true
  sleep 1
  verify
  echo "Factory fan tables restored (pwm*_enable should read 2)."
}

case "${1:-}" in
  --verify) verify ;;
  --uninstall) [[ $EUID -eq 0 ]] || die "Run as root:  sudo bash $0 --uninstall"; uninstall ;;
  "") [[ $EUID -eq 0 ]] || die "Run as root:  sudo bash $0"; install ;;
  *) echo "Usage: sudo bash $0 [--verify|--uninstall]" >&2; exit 2 ;;
esac
