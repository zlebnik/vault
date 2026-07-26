---
_organized: true
---
# Omarchy / ASUS ROG Flow Z13 (GZ302EA)

Fixes and tweaks for my **ASUS ROG Flow Z13** (AMD **Strix Halo**, Radeon 8060S)
running **Arch Linux + [Omarchy](https://omarchy.org/)** (Hyprland, Limine
bootloader, SDDM autologin, s2idle-only).

All root changes are delivered as **self-contained scripts** you run yourself
(`sudo bash <script>`); each is idempotent and supports `--uninstall`.

## Known issues & fixes

| Issue | Cause | Fix | Script |
|-------|-------|-----|--------|
| Random **hard freezes** (login screen, on wake) | amdgpu **SMU firmware hang** — `SMU: No response` / `Failed to disable gfxoff!` (27× in logs) | kernel param `amdgpu.gfxoff=0` | [`scripts/fix-amdgpu-gfxoff-freeze.sh`](scripts/fix-amdgpu-gfxoff-freeze.sh) |
| **Black screen** at boot (system boots fine, panel stays dark) | display bring-up / Panel Self Refresh | kernel param `amdgpu.dcdebugmask=0x10` (disable PSR) | [`scripts/fix-amdgpu-black-screen-psr.sh`](scripts/fix-amdgpu-black-screen-psr.sh) |
| **Keyboard dead after resume** | keyboard is the detachable **USB dock** (`0b05:1a30`) that intermittently fails to re-init on s2idle wake | udev power-pin + system-sleep rebind hook | [`scripts/fix-asus-z13-keyboard-resume.sh`](scripts/fix-asus-z13-keyboard-resume.sh) |
| **Clamshell** (lid closed + external monitor → internal panel off, stay awake) | logind suspends on lid before Hyprland can react | logind drop-in `HandleLidSwitch=ignore` + Hyprland lid handling | [`scripts/setup-clamshell-logind.sh`](scripts/setup-clamshell-logind.sh) + [`scripts/clamshell.sh`](scripts/clamshell.sh) |
| **Speakers far too quiet** (~20 dB down) | omarchy's `alsa-soft-mixer.conf` forces `api.alsa.soft-mixer` on for *all* cards, so PipeWire never touches the ALSA mixer and `Master` stays at its driver default **−20.25 dB** | wireplumber fragment turning soft-mixer off for the built-in card only | [`scripts/fix-asus-z13-quiet-speakers.sh`](scripts/fix-asus-z13-quiet-speakers.sh) |

Status: all applied and confirmed working (audio fix 2026-07-26; rest 2026-07-12).

## Scripts

### Kernel-param fixes (Limine)
Both edit `/etc/default/limine` (`KERNEL_CMDLINE[default]+=`) — the update-safe
location; the `99-limine` pacman hook re-applies it on every kernel update — then
run `limine-update`. **Reboot** after running.

```bash
sudo bash scripts/fix-amdgpu-gfxoff-freeze.sh      # stops the SMU/gfxoff freeze
sudo bash scripts/fix-amdgpu-black-screen-psr.sh   # stops the black screen at boot
sudo reboot
```
Verify: `grep -o 'amdgpu.[a-z]*=[0-9a-fx]*' /proc/cmdline`

### Keyboard-after-resume
Installs a udev rule (`/etc/udev/rules.d/99-asus-z13-keyboard-power.rules`) and a
resume hook (`/etc/systemd/system-sleep/asus-keyboard-resume`) that re-binds the
USB keyboard dock on wake if its input node went missing.

```bash
sudo bash scripts/fix-asus-z13-keyboard-resume.sh
```
Recovery events are logged: `journalctl -t asus-keyboard-resume`

### Clamshell mode
Two parts:

- **`scripts/setup-clamshell-logind.sh`** (root) — installs
  `/etc/systemd/logind.conf.d/10-clamshell.conf` so the lid stops force-suspending
  and hands control to Hyprland.
- **`scripts/clamshell.sh`** — lives at **`~/.config/hypr/clamshell.sh`** (kept
  here as a reference copy). Decides per lid event:
  - close + external monitor → disable internal panel (`eDP-1`)
  - close + no external → suspend
  - open → re-enable internal panel
  - `init` (run at startup via `exec-once`) → start in clamshell if booted with
    the lid already closed + external connected

```bash
sudo bash scripts/setup-clamshell-logind.sh
```

Hyprland wiring (in `~/.config/hypr/`, **not** in this repo):
```
# bindings.conf
bindl = , switch:on:Lid Switch,  exec, $HOME/.config/hypr/clamshell.sh close
bindl = , switch:off:Lid Switch, exec, $HOME/.config/hypr/clamshell.sh open
# autostart.conf
exec-once = $HOME/.config/hypr/clamshell.sh init
```

### Quiet speakers
The one fix here that needs **no root** — it writes a wireplumber fragment into
`~/.config/wireplumber/wireplumber.conf.d/zz-z13-hw-mixer.conf`.

```bash
bash scripts/fix-asus-z13-quiet-speakers.sh              # apply + verify
bash scripts/fix-asus-z13-quiet-speakers.sh --verify     # check only
bash scripts/fix-asus-z13-quiet-speakers.sh --uninstall  # revert
```

This is **not** the CS35L41 firmware bug that dominates search results (e.g.
[this gist](https://gist.github.com/sankao/5200b85af887b6b0fd45260d18c0241f)).
On kernel ≥ 7.1 with `linux-firmware-cirrus` ≥ 20260622 the Z13's SSID
`10431FB3` is already supported upstream and both amps load real tuned firmware
(`Firmware Loaded - Type: spk-prot, Gain: 15`, no *"Falling back to default
firmware"*) — the script checks this and warns if your machine is the exception.

Gotchas worth remembering:
- The **`zz-` filename prefix is load-bearing.** Wireplumber merges `.conf.d`
  fragments lexicographically and the last matching rule wins; a `99-` prefix
  sorts *before* `alsa-soft-mixer.conf` (`9` < `a`) and silently loses.
- Don't edit `alsa-soft-mixer.conf` directly — it's an omarchy default copied
  from `~/.local/share/omarchy/default/wireplumber/` and may be re-synced.
- The gist's optional `.bincfg` gain tweak (15.5 → 19.5 dB) is **inert**: the
  driver only ever requests `wmfw`/`bin` extensions, `bincfg` appears nowhere in
  the cs35l41/cs_dsp modules, and the formats differ (real tuning is `WMDR`, a
  bincfg starts `35 4a 9a 10`). Forcing one in as the `.bin` makes the driver
  reject it and fall back to default firmware — strictly worse.

Verify: `pactl list sinks | grep Flags:` must include **`HW_VOLUME_CTRL`**, and
`amixer -c1 sget Master` must reach `[0.00dB]` at 100% volume (the bug pins it at
`60 [69%] [-20.25dB]`).

## Notes
- The two amdgpu params are workarounds for early Strix Halo firmware/driver bugs;
  as `linux` / `linux-firmware` mature they may become removable (test one at a time).
- Kernel cmdline lives in `/etc/default/limine`; `omarchy-refresh-limine` rebuilds it.
- To undo any fix: `sudo bash scripts/<name>.sh --uninstall`.
