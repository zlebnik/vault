#!/bin/bash
# Clamshell / lid handling for the ASUS Z13 (omarchy / Hyprland).
#
#   lid close + external monitor connected -> turn OFF the internal panel, keep
#                                             running (clamshell mode)
#   lid close + no external monitor        -> suspend (normal laptop behavior;
#                                             hypridle locks before sleep)
#   lid open                               -> turn the internal panel back on
#
# Driven by Hyprland `bindl switch:...:Lid Switch` (see bindings.conf).
# Requires logind to NOT suspend on lid (see /etc/systemd/logind.conf.d/).

INTERNAL="eDP-1"

external_connected() {
  # true if any enabled monitor other than the internal panel is present
  [[ -n "$(hyprctl monitors -j 2>/dev/null | jq -r --arg i "$INTERNAL" \
      '.[] | select(.name != $i) | .name')" ]]
}

lid_closed() {
  grep -qi closed /proc/acpi/button/lid/*/state 2>/dev/null
}

case "$1" in
  init)
    # Runs at Hyprland startup. If we booted with the lid already closed and an
    # external monitor is present, start in clamshell (internal panel off).
    # Never suspends here (booting with lid closed + no external = do nothing).
    sleep 1  # let external outputs finish enumerating on a cold boot
    if lid_closed && external_connected; then
      hyprctl keyword monitor "$INTERNAL, disable"
    fi
    ;;
  close)
    if external_connected; then
      hyprctl keyword monitor "$INTERNAL, disable"
    else
      systemctl suspend
    fi
    ;;
  open)
    hyprctl keyword monitor "$INTERNAL, preferred, auto, 1.6"
    ;;
esac
