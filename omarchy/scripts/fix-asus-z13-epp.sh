#!/usr/bin/env bash
#
# fix-asus-z13-epp.sh — unlock the amd-pstate EPP on the ASUS ROG Flow Z13 so the
# "performance" platform profile no longer pins every core to EPP=performance.
#
# Why: power-profiles-daemon's amd_pstate driver sets scaling_governor=performance
# for its performance profile. Under amd-pstate-epp that makes the *only* available
# EPP "performance" — asusd logs `Available EPP: [Performance]` and its
# profile_performance_epp setting is silently ignored. The CPU then boosts flat-out
# regardless of demand, adding heat while gaming (GPU-bound) in clamshell.
#
# Fix (two parts, both reversible):
#   1. drop-in: run ppd with --block-driver=amd_pstate. ppd keeps managing
#      platform_profile (omarchy's bar / omarchy-powerprofiles-set / udev rule are
#      unchanged), but stops touching governor/EPP. The kernel default governor for
#      amd-pstate-epp is powersave, which exposes the full EPP list.
#   2. /etc/asusd/asusd.ron: profile_performance_epp Performance -> BalancePerformance
#      (asusd already has platform_profile_linked_epp: true, so it sets EPP per profile).
#
# Usage:
#   sudo bash fix-asus-z13-epp.sh             # apply
#   sudo bash fix-asus-z13-epp.sh --verify    # show state
#   sudo bash fix-asus-z13-epp.sh --uninstall # revert both parts
#
# Idempotent.

set -uo pipefail

DROPIN_DIR="/etc/systemd/system/power-profiles-daemon.service.d"
DROPIN="$DROPIN_DIR/10-block-amd-pstate.conf"
ASUSD_CONF="/etc/asusd/asusd.ron"
PPD_BIN="/usr/lib/power-profiles-daemon"
CPU0=/sys/devices/system/cpu/cpu0/cpufreq

die() { echo "ERROR: $*" >&2; exit 1; }

verify() {
  echo "== cpufreq (cpu0) =="
  echo "  driver=$(cat $CPU0/scaling_driver 2>/dev/null)  governor=$(cat $CPU0/scaling_governor 2>/dev/null)  epp=$(cat $CPU0/energy_performance_preference 2>/dev/null)"
  echo "  available EPP: $(cat $CPU0/energy_performance_available_preferences 2>/dev/null)"
  echo "  governors in use: $(sort /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor | uniq -c | awk '{printf "%s×%s ", $1, $2}')"
  echo "== platform_profile: $(cat /sys/firmware/acpi/platform_profile 2>/dev/null) =="
  echo "== ppd =="
  [[ -f "$DROPIN" ]] && echo "  drop-in present: $DROPIN" || echo "  drop-in absent (ppd still drives amd_pstate)"
  powerprofilesctl 2>/dev/null | sed 's/^/  /' | grep -E '^\s*(\*|  )?[a-z-]+:|Driver' 
  echo "== asusd =="
  grep -E 'profile_performance_epp|platform_profile_linked_epp' "$ASUSD_CONF" 2>/dev/null | sed 's/^/  /'
  journalctl -u asusd --no-pager -n 200 2>/dev/null | grep 'Available EPP' | tail -1 | sed 's/^/  last: /'
}

set_governor_powersave() {
  local g
  for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo powersave > "$g" 2>/dev/null || true
  done
}

install() {
  [[ -x "$PPD_BIN" ]] || die "$PPD_BIN not found"
  [[ -f "$ASUSD_CONF" ]] || die "$ASUSD_CONF not found (asusd not installed?)"
  "$PPD_BIN" --help-all 2>&1 | grep -q -- '--block-driver' || die "this power-profiles-daemon build lacks --block-driver"

  # 1) ppd drop-in
  mkdir -p "$DROPIN_DIR"
  local want; want="$(cat <<EOF
# Installed by fix-asus-z13-epp.sh: let asusd own governor/EPP; ppd only switches
# platform_profile. Without this, ppd's performance profile forces
# scaling_governor=performance and the only available EPP is "performance".
[Service]
ExecStart=
ExecStart=$PPD_BIN --block-driver=amd_pstate
EOF
)"
  if [[ -f "$DROPIN" && "$(cat "$DROPIN")" == "$want" ]]; then
    echo "drop-in already present: $DROPIN"
  else
    printf '%s\n' "$want" > "$DROPIN"
    echo "wrote $DROPIN"
  fi

  # 2) asusd: performance profile -> balance_performance EPP
  if grep -qE '^\s*profile_performance_epp:\s*BalancePerformance,' "$ASUSD_CONF"; then
    echo "asusd.ron already has profile_performance_epp: BalancePerformance"
  elif grep -qE '^\s*profile_performance_epp:\s*[A-Za-z]+,' "$ASUSD_CONF"; then
    cp -n "$ASUSD_CONF" "$ASUSD_CONF.bak-epp" 2>/dev/null || true
    sed -i -E 's/^(\s*profile_performance_epp:\s*)[A-Za-z]+,/\1BalancePerformance,/' "$ASUSD_CONF"
    echo "set profile_performance_epp: BalancePerformance in $ASUSD_CONF (backup: $ASUSD_CONF.bak-epp)"
  else
    die "profile_performance_epp line not found in $ASUSD_CONF — asusd config format changed?"
  fi

  systemctl daemon-reload
  systemctl restart power-profiles-daemon.service || die "ppd failed to restart (check: journalctl -u power-profiles-daemon)"
  # ppd no longer resets the governor; undo what the old instance left behind so
  # the EPP list opens up right now (after reboot the kernel default is powersave).
  set_governor_powersave
  systemctl restart asusd.service || die "asusd failed to restart (check: journalctl -u asusd)"
  sleep 2
  # Re-assert the current platform profile so asusd writes the EPP for it.
  local cur; cur="$(cat /sys/firmware/acpi/platform_profile 2>/dev/null)"
  [[ -n "$cur" ]] && asusctl profile set "$cur" >/dev/null 2>&1 || true
  sleep 1

  echo; verify; echo
  local epp; epp="$(cat $CPU0/energy_performance_preference 2>/dev/null)"
  if [[ "$(cat $CPU0/scaling_governor)" == powersave && "$cur" == performance && "$epp" == balance_performance ]]; then
    echo "OK: governor=powersave, EPP=balance_performance under platform_profile=performance"
  elif [[ "$(cat $CPU0/scaling_governor)" == powersave ]]; then
    echo "OK: governor=powersave (EPP now follows asusd per profile; current profile=$cur epp=$epp)"
  else
    echo "WARN: governor is still $(cat $CPU0/scaling_governor) — check journalctl -u power-profiles-daemon"
  fi
}

uninstall() {
  local changed=0
  if [[ -f "$DROPIN" ]]; then rm -f "$DROPIN"; rmdir "$DROPIN_DIR" 2>/dev/null || true; echo "removed $DROPIN"; changed=1; fi
  if grep -qE '^\s*profile_performance_epp:\s*BalancePerformance,' "$ASUSD_CONF" 2>/dev/null; then
    sed -i -E 's/^(\s*profile_performance_epp:\s*)BalancePerformance,/\1Performance,/' "$ASUSD_CONF"
    echo "restored profile_performance_epp: Performance in $ASUSD_CONF"; changed=1
  fi
  if [[ $changed -eq 1 ]]; then
    systemctl daemon-reload
    systemctl restart power-profiles-daemon.service asusd.service
    sleep 2
    local cur; cur="$(cat /sys/firmware/acpi/platform_profile 2>/dev/null)"
    [[ -n "$cur" ]] && powerprofilesctl set "$cur" >/dev/null 2>&1 || true
    echo; verify
    echo "Reverted: ppd drives amd_pstate again (performance profile => governor performance)."
  else
    echo "Nothing installed; nothing to remove."
  fi
}

case "${1:-}" in
  --verify) verify ;;
  --uninstall) [[ $EUID -eq 0 ]] || die "Run as root:  sudo bash $0 --uninstall"; uninstall ;;
  "") [[ $EUID -eq 0 ]] || die "Run as root:  sudo bash $0"; install ;;
  *) echo "Usage: sudo bash $0 [--verify|--uninstall]" >&2; exit 2 ;;
esac
