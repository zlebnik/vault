#!/usr/bin/env bash
#
# Make a FAT32 USB stick carrying an ASUS EZ Flash BIOS image for the ROG Flow Z13
# (GZ302EA).
#
# Why: EZ Flash 3 (in the BIOS setup) only reads FAT volumes, and the stick at hand
# was an Omarchy installer (iso9660, read-only), so it has to be wiped.
#
# DESTRUCTIVE: repartitions the whole target device (MBR, one FAT32 partition).
# Guards: the device must be a removable USB disk, must match the expected model,
# must not back any mounted system filesystem, and you must type YES.
#
# Run:  sudo bash make-asus-z13-bios-usb.sh /dev/sdX /path/to/GZ302EAAS.314
# Then: reboot → F2 → F7 (Advanced) → ASUS EZ Flash 3 → pick the stick → the file.
#       Keep AC plugged in; do not power off until it reboots on its own.
# Check afterwards: cat /sys/class/dmi/id/bios_version

set -euo pipefail

EXPECTED_MODEL="DataTraveler 3.0"
LABEL=BIOS

die() {
  echo "ERROR: $*" >&2
  exit 1
}

[[ $# -eq 2 ]] || die "usage: sudo bash $0 /dev/sdX /path/to/GZ302EAAS.NNN"
DEV=$1
IMG=$2

[[ $EUID -eq 0 ]] || die "run with sudo"
[[ -b $DEV ]] || die "$DEV is not a block device"
[[ -f $IMG ]] || die "$IMG not found"
[[ $(basename "$IMG") =~ ^GZ302EAAS\.[0-9]+$ ]] || die "$(basename "$IMG") does not look like a GZ302EA BIOS image"

[[ $(lsblk -dno TYPE "$DEV") == disk ]] || die "$DEV is not a whole disk"
[[ $(lsblk -dno TRAN "$DEV") == usb ]] || die "$DEV is not a USB device"
[[ $(lsblk -dno RM "$DEV" | tr -d ' ') == 1 ]] || die "$DEV is not removable"
MODEL=$(lsblk -dno MODEL "$DEV" | sed 's/ *$//')
[[ $MODEL == "$EXPECTED_MODEL" ]] || die "$DEV model is '$MODEL', expected '$EXPECTED_MODEL'"

# Refuse anything that holds a system mount (only /run/media and /mnt are fair game).
while read -r mp; do
  [[ -z $mp || $mp == /run/media/* || $mp == /mnt/* ]] || die "$DEV has a partition mounted at $mp"
done < <(lsblk -nro MOUNTPOINTS "$DEV")

echo "About to ERASE this device:"
lsblk -o NAME,SIZE,TRAN,RM,FSTYPE,LABEL,MOUNTPOINTS,MODEL "$DEV"
read -r -p "Type YES to wipe $DEV: " answer
[[ $answer == YES ]] || die "aborted"

for part in $(lsblk -nrpo NAME "$DEV" | tail -n +2); do
  umount "$part" 2>/dev/null || true
done

wipefs -a "$DEV"
# Zero the start too: the iso9660 hybrid image keeps a GPT and El Torito structures there.
dd if=/dev/zero of="$DEV" bs=1M count=16 conv=fsync status=none
echo 'label: dos
type=c' | sfdisk --quiet "$DEV"
partprobe "$DEV" 2>/dev/null || true
udevadm settle

PART=${DEV}1
[[ -b $PART ]] || die "$PART did not appear"
wipefs -a "$PART" >/dev/null
mkfs.fat -F 32 -n "$LABEL" "$PART"

MNT=$(mktemp -d)
trap 'mountpoint -q "$MNT" && umount "$MNT"; rmdir "$MNT"' EXIT
mount "$PART" "$MNT"
cp "$IMG" "$MNT/"
sync

want=$(sha256sum "$IMG" | cut -d' ' -f1)
umount "$MNT"
mount -o ro "$PART" "$MNT"
got=$(sha256sum "$MNT/$(basename "$IMG")" | cut -d' ' -f1)
[[ $want == "$got" ]] || die "checksum mismatch after copy ($got != $want)"
ls -l "$MNT"
umount "$MNT"

echo "OK: $(basename "$IMG") is on $PART (FAT32, label $LABEL), sha256 verified."
echo "Next: reboot → F2 → F7 → ASUS EZ Flash 3."
