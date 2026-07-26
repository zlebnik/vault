#!/usr/bin/env bash
#
# fix-asus-z13-quiet-speakers.sh — restore ~20 dB of lost speaker volume on the
# ASUS ROG Flow Z13 (GZ302EA, ALC294 + 2x Cirrus CS35L41).
#
# NOT the CS35L41 firmware bug everyone chases online. On kernel >= 7.1 with
# linux-firmware-cirrus >= 20260622 the Z13's SSID 10431FB3 is already handled
# upstream and both amps load their real tuned firmware:
#     cs35l41-hda ...: Firmware Loaded - Type: spk-prot, Gain: 15
#     cs35l41-hda ...: CS35L41 Bound - SSID: 10431FB3, ..., FW EN: 1
# (no "Falling back to default firmware"). This script checks that and tells you
# if your machine is the exception.
#
# The real cause is omarchy's own default:
#   ~/.config/wireplumber/wireplumber.conf.d/alsa-soft-mixer.conf
# sets `api.alsa.soft-mixer = true` for EVERY card (matches ~alsa_card.*). With
# soft-mixer on, PipeWire does volume purely in software and never touches the
# ALSA mixer — so 'Master Playback Volume' sits at its driver default of
# 60/87 = -20.25 dB forever and nothing ever raises it. 'Speaker' and 'PCM' are
# already at 0 dB, so Master is the entire loss.
#
# The fix: turn soft-mixer back OFF for the built-in card only. USB, Bluetooth
# and HDMI keep omarchy's behavior.
#
# Usage:
#   bash fix-asus-z13-quiet-speakers.sh              # apply + verify
#   bash fix-asus-z13-quiet-speakers.sh --verify     # check only, change nothing
#   bash fix-asus-z13-quiet-speakers.sh --uninstall  # revert to omarchy default
#
# Runs as your normal user — NOT with sudo (it writes into $HOME and talks to
# your user PipeWire session). Idempotent.

set -uo pipefail

CONF_DIR="$HOME/.config/wireplumber/wireplumber.conf.d"
# The "zz-" prefix is load-bearing: wireplumber merges .conf.d fragments in
# lexicographic order and appends monitor.alsa.rules entries, with the LAST
# matching rule winning. "zz-" sorts after omarchy's alsa-soft-mixer.conf.
# A "99-" prefix would sort BEFORE it ('9' < 'a') and silently lose.
CONF="$CONF_DIR/zz-z13-hw-mixer.conf"
OMARCHY_CONF="$CONF_DIR/alsa-soft-mixer.conf"

die() { echo "ERROR: $*" >&2; exit 1; }

[[ $EUID -ne 0 ]] || die "Do NOT run this as root — it configures your user PipeWire session.
Run:  bash $0 ${*:-}"

# --- discover the built-in analog card ------------------------------------
# The Z13 has two HDA cards both named "HD-Audio Generic": the AMD HDMI audio
# card and the ALC294/CS35L41 analog one. Pick the analog one by codec vendor,
# then derive the exact device.name PipeWire uses (udev ID_PATH with ':' -> '_').
find_analog_card() {
  local c idx
  for c in /proc/asound/card*/codec*; do
    [[ -f "$c" ]] || continue
    grep -qiE '^Codec: (Realtek|Cirrus)' "$c" || continue
    idx="${c#/proc/asound/card}"; idx="${idx%%/*}"
    [[ "$idx" =~ ^[0-9]+$ ]] && { echo "$idx"; return 0; }
  done
  return 1
}

CARD="$(find_analog_card)" || die "No Realtek/Cirrus analog HDA card found in /proc/asound — is this the right machine?"

ID_PATH="$(udevadm info -q property -p "/sys/class/sound/card$CARD" 2>/dev/null \
           | sed -n 's/^ID_PATH=//p' | head -1)"
[[ -n "$ID_PATH" ]] || die "Could not read ID_PATH for sound card $CARD via udevadm."
DEVICE_NAME="alsa_card.${ID_PATH//:/_}"

restart_audio() {
  echo "Restarting PipeWire..."
  if command -v omarchy-restart-pipewire >/dev/null 2>&1; then
    omarchy-restart-pipewire >/dev/null 2>&1
  else
    systemctl --user restart wireplumber pipewire pipewire-pulse 2>/dev/null
  fi
  sleep 3
}

verify() {
  local rc=0

  echo "== card =="
  echo "  ALSA card $CARD  ($(sed -n '1p' "/proc/asound/card$CARD/codec"* 2>/dev/null | head -1))"
  echo "  PipeWire device.name = $DEVICE_NAME"

  echo
  echo "== CS35L41 amp firmware (should NOT say 'Falling back to default') =="
  local fw
  fw="$(journalctl -k -b 2>/dev/null | grep -E 'cs35l41.*(Firmware Loaded|Bound|Falling back)' | tail -4)"
  if [[ -n "$fw" ]]; then
    echo "$fw" | sed 's/^.*: cs35l41/  cs35l41/'
    if grep -qi 'Falling back' <<<"$fw"; then
      echo "  !! Amps fell back to default firmware — you also need the driver/firmware"
      echo "     fix for SSID 10431FB3 (upstream since kernel ~7.1 / linux-firmware 20260622)."
      rc=1
    fi
  else
    echo "  (no cs35l41 lines in this boot's kernel log)"
  fi

  echo
  echo "== config fragment =="
  if [[ -f "$CONF" ]]; then
    echo "  present: $CONF"
    [[ -f "$OMARCHY_CONF" ]] && echo "  omarchy default still in place (expected): $(basename "$OMARCHY_CONF")"
  else
    echo "  absent: $CONF  (not installed)"
  fi

  echo
  echo "== hardware mixer in use? =="
  # The decisive signal: with soft-mixer on, the sink has no HW_VOLUME_CTRL flag.
  local flags
  flags="$(pactl list sinks 2>/dev/null \
           | awk -v c="alsa.card = \"$CARD\"" '/^Sink #/{f=""} /Flags:/{f=$0} $0 ~ c {print f; exit}')"
  if [[ -n "$flags" ]]; then
    echo "  ${flags##*Flags: }"
    if grep -q 'HW_VOLUME_CTRL' <<<"$flags"; then
      echo "  -> hardware volume control ACTIVE (good)"
    else
      echo "  -> software volume only; Master will stay pinned at its driver default"
      rc=1
    fi
  else
    echo "  (no sink found for card $CARD)"
    rc=1
  fi

  echo
  echo "== Master Playback Volume (the ~20 dB that was being lost) =="
  if amixer -c"$CARD" sget Master >/dev/null 2>&1; then
    echo "  $(amixer -c"$CARD" sget Master | tail -1 | sed 's/^ *//')"
    echo "  current PipeWire volume: $(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo '?')"
    echo "  At 100% volume this must read [0.00dB]; the bug pins it at 60 [69%] [-20.25dB]."
  else
    echo "  (no 'Master' control on card $CARD)"
  fi

  return $rc
}

uninstall() {
  if [[ -f "$CONF" ]]; then
    rm -f "$CONF"
    echo "removed $CONF"
    restart_audio
    echo "Reverted to the omarchy default (soft-mixer for all cards)."
    echo "Speakers will be quiet again until you re-run this script."
  else
    echo "Nothing installed; nothing to remove."
  fi
}

install() {
  [[ -f "$OMARCHY_CONF" ]] || echo "Note: $OMARCHY_CONF not found — omarchy may have changed its
      defaults. Installing anyway; this fragment only forces hardware mixing on."

  mkdir -p "$CONF_DIR"
  cat > "$CONF" <<EOF
## ASUS ROG Flow Z13 (GZ302EA): use the ALSA hardware mixer for the built-in card.
##
## Omarchy's alsa-soft-mixer.conf sets api.alsa.soft-mixer = true for ALL cards,
## so PipeWire never touches the ALSA mixer and 'Master Playback Volume' stays at
## its driver default of 60/87 = -20.25 dB. 'Speaker' and 'PCM' are already at
## 0 dB, so that one control was the entire loss of loudness.
##
## Other cards (USB / Bluetooth / HDMI) keep the omarchy default.
##
## Filename must sort AFTER alsa-soft-mixer.conf: wireplumber merges .conf.d
## fragments lexicographically and the last matching rule wins.
##
## Installed by scripts/fix-asus-z13-quiet-speakers.sh — do not edit by hand.

monitor.alsa.rules = [
  {
    matches = [
      {
        device.name = "$DEVICE_NAME"
      }
    ]
    actions = {
      update-props = {
        api.alsa.soft-mixer = false
      }
    }
  }
]
EOF
  echo "wrote $CONF  (device.name = $DEVICE_NAME)"

  restart_audio
  echo
  verify
}

case "${1:-}" in
  "")           install ;;
  --verify)     verify ;;
  --uninstall)  uninstall ;;
  *)
    cat >&2 <<EOF
Usage:
  bash $0              apply the fix (write the fragment, restart PipeWire, verify)
  bash $0 --verify     check current state only, change nothing
  bash $0 --uninstall  remove the fragment, revert to the omarchy default

Run as your normal user, NOT with sudo.
EOF
    exit 2 ;;
esac
