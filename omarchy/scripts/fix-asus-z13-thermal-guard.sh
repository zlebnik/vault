#!/usr/bin/env bash
#
# fix-asus-z13-thermal-guard.sh — install a tiny thermal logger + emergency power
# limiter for the ASUS ROG Flow Z13 (GZ302EA, Strix Halo).
#
# Why: the machine hard-powers-off while gaming in clamshell at Tctl 90+ °C and the
# journal holds *nothing* about temperatures before the cut — the EC trips before
# the kernel's own 100–120 °C thermal zones ever fire. Two jobs:
#   * LOG   — every 10 s (5 s when hot) write one line to the journal:
#             tctl, GPU edge temp, APU power, fan RPMs, platform_profile, PPT limits.
#             Read it with:  journalctl -t thermal-guard
#   * FANS  — the custom asusd fan curve (fix-asus-z13-fan-curves.sh) has an EC floor
#             of ~3400 rpm even at 6 %, vs ~2800 rpm in factory mode. So the guard keeps
#             the EC in factory mode while cool and switches the custom curve on only
#             when Tctl/GPU reach FAN_ON (60 °C), back to factory after 60 s below
#             FAN_OFF (50 °C). Quiet desk, aggressive fans under load.
#   * GUARD — if Tctl or GPU edge reaches TRIP (default 93 °C), drop the ASUS
#             PPT limits (ppt_pl1_spl/pl2_sppt/pl3_fppt) to 35/40/45 W via
#             /sys/class/firmware-attributes/asus-armoury, and restore the previous
#             limits once both temps stay <= RESTORE (default 80 °C) for 30 s.
#
# asusd only rewrites PPT on profile/AC change (and only when its PPT tuning group
# is enabled, which it is not), so direct sysfs writes don't fight it. If asusd (or
# the user) changes the limits while we are tripped, the guard notices the values
# are no longer its own and simply stands down.
#
# Usage:
#   sudo bash fix-asus-z13-thermal-guard.sh               # install + start
#   sudo bash fix-asus-z13-thermal-guard.sh --status      # service state + last log lines
#   sudo bash fix-asus-z13-thermal-guard.sh --uninstall
# Tuning (edit the unit's Environment= lines, then systemctl restart):
#   THERMAL_GUARD_TRIP=93  THERMAL_GUARD_RESTORE=80  THERMAL_GUARD_INTERVAL=5
#   THERMAL_GUARD_EMERGENCY="35 40 45"   (PL1 PL2 PL3 in W)
#   THERMAL_GUARD_FAN_ON=60  THERMAL_GUARD_FAN_OFF=50  THERMAL_GUARD_FAN_OFF_HOLD=60  (0 = never toggle)
#
# Idempotent.

set -uo pipefail

BIN="/usr/local/bin/asus-z13-thermal-guard"
UNIT="/etc/systemd/system/asus-z13-thermal-guard.service"
SVC="asus-z13-thermal-guard.service"

die() { echo "ERROR: $*" >&2; exit 1; }

write_bin() {
  cat > "$BIN" <<'GUARD_EOF'
#!/usr/bin/env bash
# asus-z13-thermal-guard — thermal logger + emergency PPT limiter.
# Installed by fix-asus-z13-thermal-guard.sh (vault/omarchy). Runs as root under systemd.
set -u

TRIP="${THERMAL_GUARD_TRIP:-93}"           # °C: drop PPT at/above this (Tctl or GPU edge)
RESTORE="${THERMAL_GUARD_RESTORE:-80}"     # °C: restore PPT once both temps <= this ...
RESTORE_HOLD="${THERMAL_GUARD_RESTORE_HOLD:-30}"   # ... for this many seconds
INTERVAL="${THERMAL_GUARD_INTERVAL:-5}"    # s between samples
HOT="${THERMAL_GUARD_HOT:-85}"             # °C: log every sample (warning) at/above this
read -r EM1 EM2 EM3 <<<"${THERMAL_GUARD_EMERGENCY:-35 40 45}"
FAN_ON="${THERMAL_GUARD_FAN_ON:-60}"        # °C: switch EC to the custom (aggressive) curve; 0 disables toggling
FAN_OFF="${THERMAL_GUARD_FAN_OFF:-50}"      # °C: back to factory curve once below this ...
FAN_OFF_HOLD="${THERMAL_GUARD_FAN_OFF_HOLD:-60}"   # ... for this many seconds

ARM=/sys/class/firmware-attributes/asus-armoury/attributes
PL1="$ARM/ppt_pl1_spl/current_value"
PL2="$ARM/ppt_pl2_sppt/current_value"
PL3="$ARM/ppt_pl3_fppt/current_value"

log() { local prio="$1"; shift; printf '%s\n' "$*" | systemd-cat -t thermal-guard -p "$prio"; }

# Resolve hwmon dirs by name (numbers change between boots).
hw_by_name() { local h; for h in /sys/class/hwmon/hwmon*; do [[ "$(<"$h/name")" == "$1" ]] && { echo "$h"; return; }; done; }
find_sensors() {
  K10="$(hw_by_name k10temp)"; GPU="$(hw_by_name amdgpu)"; ASUS="$(hw_by_name asus)"
  FANHW="$(hw_by_name asus_custom_fan_curve)"
}
find_sensors
[[ -n "$K10" ]] || { log err "k10temp hwmon not found; exiting"; exit 1; }

rd() { local v; v="$(<"$1")" 2>/dev/null || v=""; echo "${v:-0}"; }
milli_to_c() { awk -v v="$1" 'BEGIN{printf "%.1f", v/1000}'; }
ge() { awk -v a="$1" -v b="$2" 'BEGIN{exit !(a>=b)}'; }
le() { awk -v a="$1" -v b="$2" 'BEGIN{exit !(a<=b)}'; }
max() { awk -v a="$1" -v b="$2" 'BEGIN{print (a>b)?a:b}'; }

ppt_ok() { [[ -w "$PL1" && -w "$PL2" && -w "$PL3" ]]; }
set_ppt() { echo "$1" > "$PL1" && echo "$2" > "$PL2" && echo "$3" > "$PL3"; }

# Fan-curve mode: 1 = custom curve (asusd) active in EC, 2 = factory table.
fan_mode() { rd "$FANHW/pwm1_enable"; }
fan_can_toggle() { [[ "$FAN_ON" != 0 && -n "$FANHW" && -w "$FANHW/pwm1_enable" && -w "$FANHW/pwm2_enable" ]]; }
set_fan_mode() { echo "$1" > "$FANHW/pwm1_enable" && echo "$1" > "$FANHW/pwm2_enable"; }

tripped=0; saved=""; cool_since=""; tick=0; fan_cool_since=""
log notice "started: trip=${TRIP}°C restore<=${RESTORE}°C for ${RESTORE_HOLD}s interval=${INTERVAL}s emergency=${EM1}/${EM2}/${EM3}W ppt_writable=$(ppt_ok && echo yes || echo no) fan_toggle=$(fan_can_toggle && echo "on>=${FAN_ON} off<${FAN_OFF}/${FAN_OFF_HOLD}s" || echo no)"
# Start quiet: factory table until something warms up.
fan_can_toggle && [[ "$(fan_mode)" == 1 ]] && set_fan_mode 2 && log info "fan curve: factory (cool start)"

# On exit (stop/restart) never leave the limits clamped.
cleanup() {
  [[ -n "${sleep_pid:-}" ]] && kill "$sleep_pid" 2>/dev/null
  if [[ $tripped -eq 1 && -n "$saved" ]]; then set_ppt $saved && log notice "exit: restored PPT ${saved// //}W"; fi
  exit 0
}
trap cleanup TERM INT

while :; do
  # hwmon nodes can vanish/reappear across suspend; re-resolve if missing.
  [[ -r "$K10/temp1_input" ]] || find_sensors
  tctl="$(milli_to_c "$(rd "$K10/temp1_input")")"
  gpu="$(milli_to_c "$(rd "$GPU/temp1_input")")"
  watts="$(awk -v v="$(rd "$GPU/power1_average")" 'BEGIN{printf "%.1f", v/1000000}')"
  fan1="$(rd "$ASUS/fan1_input")"; fan2="$(rd "$ASUS/fan2_input")"
  prof="$(rd /sys/firmware/acpi/platform_profile)"
  pl="$(rd "$PL1")/$(rd "$PL2")/$(rd "$PL3")"
  hot="$(max "$tctl" "$gpu")"
  line="tctl=${tctl} gpu=${gpu} ppt=${watts}W fan=${fan1}/${fan2} curve=$([[ "$(fan_mode)" == 1 ]] && echo custom || echo factory) profile=${prof} pl=${pl}$([[ $tripped -eq 1 ]] && echo ' TRIPPED')"

  if ge "$hot" "$HOT"; then log warning "$line"
  elif (( tick % 2 == 0 )); then log info "$line"; fi
  tick=$((tick + 1))

  # Fan-curve hysteresis (independent of the PPT trip).
  if fan_can_toggle; then
    if ge "$hot" "$FAN_ON"; then
      fan_cool_since=""
      [[ "$(fan_mode)" == 1 ]] || { set_fan_mode 1 && log notice "fan curve: custom (tctl=${tctl} gpu=${gpu} >= ${FAN_ON}°C)"; }
    elif [[ "$(fan_mode)" == 1 ]] && awk -v a="$hot" -v b="$FAN_OFF" 'BEGIN{exit !(a<b)}'; then
      now=$(date +%s); : "${fan_cool_since:=$now}"
      if (( now - fan_cool_since >= FAN_OFF_HOLD )); then
        set_fan_mode 2 && log notice "fan curve: factory (tctl=${tctl} gpu=${gpu} < ${FAN_OFF}°C for ${FAN_OFF_HOLD}s)"
        fan_cool_since=""
      fi
    else
      fan_cool_since=""
    fi
  fi

  if [[ $tripped -eq 0 ]]; then
    if ge "$hot" "$TRIP" && ppt_ok; then
      saved="$(rd "$PL1") $(rd "$PL2") $(rd "$PL3")"
      if set_ppt "$EM1" "$EM2" "$EM3"; then
        tripped=1; cool_since=""
        log err "TRIP: tctl=${tctl} gpu=${gpu} >= ${TRIP}°C — PPT ${saved// //} -> ${EM1}/${EM2}/${EM3}W"
      else
        log err "TRIP: tctl=${tctl} gpu=${gpu} but failed to write PPT limits"
      fi
    fi
  else
    cur="$(rd "$PL1") $(rd "$PL2") $(rd "$PL3")"
    if [[ "$cur" != "$EM1 $EM2 $EM3" ]]; then
      log notice "PPT changed externally to ${cur// //} while tripped — standing down"
      tripped=0; saved=""; cool_since=""
    elif le "$hot" "$RESTORE"; then
      now=$(date +%s); : "${cool_since:=$now}"
      if (( now - cool_since >= RESTORE_HOLD )); then
        set_ppt $saved && log notice "RESTORE: tctl=${tctl} gpu=${gpu} <= ${RESTORE}°C for ${RESTORE_HOLD}s — PPT back to ${saved// //}W"
        tripped=0; saved=""; cool_since=""
      fi
    else
      cool_since=""
    fi
  fi
  # background sleep + wait so a stop signal is handled immediately, not after INTERVAL
  sleep "$INTERVAL" & sleep_pid=$!; wait "$sleep_pid"; sleep_pid=""
done
GUARD_EOF
  chmod 755 "$BIN"
  echo "wrote $BIN"
}

write_unit() {
  cat > "$UNIT" <<EOF
[Unit]
Description=ASUS Z13 thermal logger + emergency PPT limiter
After=asusd.service
# Installed by fix-asus-z13-thermal-guard.sh (vault/omarchy)

[Service]
Type=simple
ExecStart=$BIN
Restart=always
RestartSec=5
Environment=THERMAL_GUARD_TRIP=93
Environment=THERMAL_GUARD_RESTORE=80
Environment=THERMAL_GUARD_RESTORE_HOLD=30
Environment=THERMAL_GUARD_INTERVAL=5
Environment=THERMAL_GUARD_EMERGENCY="35 40 45"
Environment=THERMAL_GUARD_FAN_ON=60
Environment=THERMAL_GUARD_FAN_OFF=50
Environment=THERMAL_GUARD_FAN_OFF_HOLD=60
Nice=-5

[Install]
WantedBy=multi-user.target
EOF
  echo "wrote $UNIT"
}

status() {
  systemctl --no-pager status "$SVC" 2>&1 | head -8 | sed 's/^/  /'
  echo "== last log lines (journalctl -t thermal-guard) =="
  journalctl -t thermal-guard --no-pager -n 15 -o short 2>/dev/null | cut -c1-160 | sed 's/^/  /'
  echo "== current PPT limits (W) =="
  echo "  pl1=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value 2>/dev/null) pl2=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl2_sppt/current_value 2>/dev/null) pl3=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl3_fppt/current_value 2>/dev/null)"
}

install() {
  [[ -d /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl ]] \
    || die "asus-armoury ppt_* attributes not found (kernel asus-armoury driver missing?)"
  command -v systemd-cat >/dev/null || die "systemd-cat missing"
  write_bin
  write_unit
  systemctl daemon-reload
  systemctl enable "$SVC" >/dev/null 2>&1
  systemctl restart "$SVC" || die "service failed to start (journalctl -u $SVC)"
  sleep 3
  echo
  status
  echo
  echo "Thresholds live in $UNIT (Environment=THERMAL_GUARD_*); edit + systemctl daemon-reload + restart $SVC."
}

uninstall() {
  local changed=0
  if systemctl list-unit-files "$SVC" >/dev/null 2>&1 && [[ -f "$UNIT" ]]; then
    systemctl disable --now "$SVC" 2>/dev/null || true
    rm -f "$UNIT"; echo "removed $UNIT"; changed=1
  fi
  if [[ -f "$BIN" ]]; then rm -f "$BIN"; echo "removed $BIN"; changed=1; fi
  if [[ $changed -eq 1 ]]; then
    systemctl daemon-reload
    echo "Uninstalled. (The guard restores PPT limits on stop; if in doubt: asusctl profile set performance)"
  else
    echo "Nothing installed; nothing to remove."
  fi
}

case "${1:-}" in
  --status) status ;;
  --uninstall) [[ $EUID -eq 0 ]] || die "Run as root:  sudo bash $0 --uninstall"; uninstall ;;
  "") [[ $EUID -eq 0 ]] || die "Run as root:  sudo bash $0"; install ;;
  *) echo "Usage: sudo bash $0 [--status|--uninstall]" >&2; exit 2 ;;
esac
