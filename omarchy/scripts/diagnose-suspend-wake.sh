#!/usr/bin/env bash
#
# diagnose-suspend-wake.sh — find what wakes an ASUS Z13 (homespace) right back up
# after `systemctl suspend` (s2idle).
#
# It snapshots every device's wakeup_count, does ONE suspend, and on resume reports
# which device's counter advanced + the wake IRQ. Per-device wakeup counters reset on
# reboot, so this MUST be run in the same boot as the wake we're catching.
#
# Usage:  sudo bash /home/zlebnik/vault/diagnose-suspend-wake.sh
#
# The machine will suspend, then (that's the bug) wake itself in a few seconds. Do NOT
# touch the keyboard/mouse and leave the charger as-is so we capture the *spurious*
# source, not a wake you caused. If it does NOT wake on its own within ~60s, the bug
# didn't reproduce — press a key to wake and re-run.

set -uo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root:  sudo bash $0" >&2
  exit 1
fi

SNAP_DIR="$(mktemp -d /tmp/wake-snap.XXXXXX)"
BEFORE="$SNAP_DIR/before"
AFTER="$SNAP_DIR/after"
trap 'rm -rf "$SNAP_DIR"' EXIT

# Snapshot: "<count> <active_count> <sysfs-dir> <human-name>" per wakeup-capable device.
snapshot() {
  local out="$1"
  : > "$out"
  local f d cnt act name
  while IFS= read -r f; do
    d="$(dirname "$f")"
    cnt="$(cat "$f" 2>/dev/null || echo 0)"
    act="$(cat "$d/wakeup_active_count" 2>/dev/null || echo 0)"
    # Best-effort human name: USB product, else parent dir name.
    name="$(cat "$d/../product" 2>/dev/null)"
    [[ -z "$name" ]] && name="$(cat "$d/../name" 2>/dev/null)"
    [[ -z "$name" ]] && name="$(basename "$(dirname "$d")")"
    printf '%s\t%s\t%s\t%s\n' "$cnt" "$act" "${d#/sys/devices/}" "$name" >> "$out"
  done < <(find /sys/devices -name wakeup_count 2>/dev/null)
  sort -o "$out" "$out"
}

echo "== enabling kernel wake debug messages =="
echo 1 > /sys/power/pm_debug_messages 2>/dev/null || echo "(pm_debug_messages not available)"
# Enable AMD pinctrl dynamic debug so the exact waking GPIO pin is logged on resume.
echo 'file pinctrl-amd.c +p' > /sys/kernel/debug/dynamic_debug/control 2>/dev/null \
  || echo "(pinctrl-amd dynamic debug not available)"

# Snapshot the per-pin amd_gpio child interrupt counts (IRQ7/pinctrl_amd demuxes these).
irq_snapshot() { grep -E 'amd_gpio' /proc/interrupts > "$1" 2>/dev/null; }

# Snapshot ACPI GPE / SCI interrupt counters (for IRQ9 / "ACPI GPE wakeup" cases).
gpe_snapshot() {
  local out="$1"; : > "$out"
  local f n
  for f in /sys/firmware/acpi/interrupts/*; do
    [[ -f "$f" ]] || continue
    n="$(basename "$f")"
    printf '%s\t%s\n' "$n" "$(cat "$f" 2>/dev/null)" >> "$out"
  done
  sort -o "$out" "$out"
}

cat <<EOF

--------------------------------------------------------------------
Suspending in 5 seconds.
  * Do NOT touch the keyboard, touchpad, or mouse.
  * Leave the charger exactly as it is (plugged or unplugged).
  * Just wait — if the bug is present it will wake itself in a few seconds.
After it wakes, this script prints the culprit. Then re-open your terminal.
--------------------------------------------------------------------
EOF
sleep 5

# Snapshot IMMEDIATELY before suspend so the delta reflects ONLY the sleep window
# (not chatty devices firing during the countdown, and after any pre-sleep unbind
# hooks have run).
echo "== snapshotting wakeup counters (right before suspend) =="
snapshot "$BEFORE"
gpe_snapshot "$SNAP_DIR/gpe.before"
irq_snapshot "$SNAP_DIR/irq.before"
WINDOW_START="$(date '+%Y-%m-%d %H:%M:%S')"
GLOBAL_BEFORE="$(cat /sys/power/wakeup_count 2>/dev/null || echo '?')"

echo "== suspending now ($WINDOW_START) =="
systemctl suspend
# Execution resumes here after the system wakes.
sleep 2

echo "== snapshotting wakeup counters (after) =="
snapshot "$AFTER"
gpe_snapshot "$SNAP_DIR/gpe.after"
irq_snapshot "$SNAP_DIR/irq.after"
GLOBAL_AFTER="$(cat /sys/power/wakeup_count 2>/dev/null || echo '?')"

echo
echo "===================== RESULTS ====================="
echo "global /sys/power/wakeup_count:  $GLOBAL_BEFORE -> $GLOBAL_AFTER"

WIRQ="$(cat /sys/power/pm_wakeup_irq 2>/dev/null || true)"
echo
echo "--- wake IRQ (/sys/power/pm_wakeup_irq): ${WIRQ:-<empty>} ---"
if [[ -n "${WIRQ:-}" ]]; then
  echo "  owner in /proc/interrupts:"
  grep -E "^\s*${WIRQ}:" /proc/interrupts | sed 's/^/    /' || echo "    (no match)"
fi

echo
echo "--- devices whose wakeup_count INCREASED (the culprit[s]) ---"
# Join before/after on the sysfs-dir field (col 3) and show rows where count grew.
awk -F'\t' '
  NR==FNR { b[$3]=$1; next }
  { if (($3 in b) && ($1+0) > (b[$3]+0)) printf "  +%d  %s   [%s]\n", $1-b[$3], $3, $4 }
' "$BEFORE" "$AFTER" | sort -t+ -k2 -rn
echo "  (nothing listed above = counter-based detection found nothing; rely on IRQ + dmesg)"

echo
echo "--- ACPI GPE/SCI counters that INCREASED (culprit for IRQ9 / GPE wakes) ---"
awk -F'\t' '
  NR==FNR { b[$1]=$2; next }
  { split($2,a," "); c=a[1]+0;
    if (($1 in b)) { split(b[$1],p," "); pc=p[1]+0; if (c>pc) printf "  +%d  %s\t(%s)\n", c-pc, $1, $2 } }
' "$SNAP_DIR/gpe.before" "$SNAP_DIR/gpe.after" | sort -t+ -k2 -rn
echo "  (the GPExx above with the biggest jump is the wake source; map it via /proc/acpi/wakeup Sysfs node)"

echo
echo "--- AMD GPIO pins (amd_gpio) whose IRQ count INCREASED (culprit for IRQ7/pinctrl_amd) ---"
# Each amd_gpio child line: "<irq>: <percpu counts...> amd_gpio <pin> <name>".
# Sum the numeric per-CPU fields, key by irq, and show pins that fired during sleep.
awk '
  function total(   i,s){ s=0; for(i=2;i<=NF;i++) if($i ~ /^[0-9]+$/) s+=$i; return s }
  function label(   i,l){ l=""; for(i=1;i<=NF;i++) if($i=="amd_gpio"){ l=$(i+1); for(j=i+2;j<=NF;j++) l=l" "$j; break } return l }
  NR==FNR { b[$1]=total(); next }
  /amd_gpio/ { t=total(); if(($1 in b) && t>b[$1]) printf "  +%d  IRQ %s  pin/name: %s\n", t-b[$1], $1, label() }
' "$SNAP_DIR/irq.before" "$SNAP_DIR/irq.after" | sort -t+ -k2 -rn
echo "  (the pin above that jumped is the actual wake source demuxed under IRQ7)"

echo
echo "--- kernel pinctrl_amd wake lines (names the pin directly if debug worked) ---"
journalctl --since "$WINDOW_START" -k 2>/dev/null \
  | grep -iE 'pinctrl_amd|amd_gpio|GPIO.*(wake|irq)|Waking' | tail -15 | sed 's/^/  /'

echo
echo "--- also: devices whose wakeup_active_count increased ---"
awk -F'\t' '
  NR==FNR { b[$3]=$2; next }
  { if (($3 in b) && ($2+0) > (b[$3]+0)) printf "  +%d  %s   [%s]\n", $2-b[$3], $3, $4 }
' "$BEFORE" "$AFTER"

echo
echo "--- kernel wake lines since $WINDOW_START ---"
journalctl --since "$WINDOW_START" -k 2>/dev/null \
  | grep -iE 'wakeup|suspend exit|suspend entry|Reason for|PM: |amd_pmc|ACPI: EC' \
  | tail -30 | sed 's/^/  /'

echo
echo "--- /proc/acpi/wakeup (currently enabled sources) ---"
grep -E '\*enabled' /proc/acpi/wakeup | sed 's/^/  /'

echo
echo "==================================================="
echo "Paste everything above back to Claude to pick the exact device to disable."
echo "Wanted-wake devices to KEEP: 13d3:3608 (Bluetooth), 0b05:1a30 (keyboard)."
