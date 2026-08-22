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
| **Clamshell** (lid closed + external monitor → internal panel off, stay awake) | logind suspends on lid before Hyprland can react | ~~logind drop-in + `clamshell.sh`~~ **retired & uninstalled 2026-08-22**: Omarchy handles clamshell natively now, and the old drop-in actively broke suspend — see [Clamshell mode](#clamshell-mode--retired-2026-08-22) | — (scripts removed; in git history) |
| **Speakers far too quiet** (~20 dB down) | omarchy's `alsa-soft-mixer.conf` forces `api.alsa.soft-mixer` on for *all* cards, so PipeWire never touches the ALSA mixer and `Master` stays at its driver default **−20.25 dB** | wireplumber fragment turning soft-mixer off for the built-in card only | [`scripts/fix-asus-z13-quiet-speakers.sh`](scripts/fix-asus-z13-quiet-speakers.sh) |
| **OpenWhispr dictation hotkey "doesn't work"** | Omarchy loads Hyprland config from **Lua only**; legacy `~/.config/hypr/*.conf` files are silently ignored, so the bind OpenWhispr auto-writes there never registers — and its recording indicator opens pinned to one workspace | manual `o.bind` in `bindings.lua` + pin window rule | — (config edits, see [OpenWhispr dictation](#openwhispr-dictation)) |

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

### Clamshell mode — retired (2026-08-22)

The custom setup (logind drop-in + `clamshell.sh` wired to lid-switch binds) is
**no longer in use**. Two things changed:

1. **The wiring went dead silently.** Omarchy migrated Hyprland config to Lua
   (`~/.config/hypr/*.lua`); the legacy `bindings.conf` / `autostart.conf`
   holding the `clamshell.sh` binds stopped being read entirely (see the
   OpenWhispr section — same gotcha).
2. **Omarchy now does clamshell natively.** Its default lid binds
   (`$OMARCHY_PATH/default/hypr/bindings/utilities.lua`) call
   `omarchy-system-lid-close` / `omarchy-hyprland-monitor-clamshell`, which
   cover everything `clamshell.sh` did and more: close + external → internal
   panel off (remembers scale/position), open → panel back on, close + no
   external → lock; boot/hotplug reconcile via `omarchy-hyprland-monitor-watch`.

Crucially, the native scheme expects **logind to do the suspending** on a
non-docked lid close (`HandleLidSwitchDocked=ignore` is already the systemd
default for the docked case). Our old drop-in set all `HandleLidSwitch*=ignore`,
so with it in place, lid close on battery **locked but never suspended** — it
had to go.

Everything is uninstalled and cleaned up (2026-08-22): the drop-in
`/etc/systemd/logind.conf.d/10-clamshell.conf` is removed (effective
`HandleLidSwitch` verified back to `suspend`), `~/.config/hypr/clamshell.sh` is
deleted, and both scripts (`clamshell.sh`, `setup-clamshell-logind.sh`) are
dropped from `scripts/` — retrieve them from git history if ever needed. The
dead `bindl`/`exec-once` lines still sit in the unread `.conf` files —
harmless, but don't copy them anywhere.

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

### OpenWhispr dictation

Local voice typing (Russian works well): **`openwhispr-vulkan`** from the AUR,
model `large-v3-turbo`, Vulkan backend confirmed running on the Radeon 8060S.
Hotkey: **CTRL+SHIFT+SPACE** toggles recording; text is auto-pasted via `wtype`.

Setting it up meant re-doing the app's broken Hyprland integration by hand
(all edits in `~/.config/hypr/`, **not** in this repo):

- **The hotkey silently doesn't register.** Omarchy configures Hyprland in
  **Lua** (`hyprland.lua`, `bindings.lua`, …); the legacy `hyprland.conf` /
  `bindings.conf` / `autostart.conf` still sit in `~/.config/hypr/` but are
  **never loaded** (`hyprctl binds` shows every bind with dispatcher `__lua`).
  OpenWhispr's Hyprland integration appends
  `source = ./openwhispr-binds.conf` to `hyprland.conf` — into the void, and it
  re-appends it on every app restart. Fix in `bindings.lua`:

  ```lua
  o.bind(
    "CTRL + SHIFT + SPACE",
    "Dictation (OpenWhispr)",
    "dbus-send --session --type=method_call --dest=com.openwhispr.App /com/openwhispr/App com.openwhispr.App.Toggle"
  )
  ```

- **The recording indicator hides on one workspace.** The "Voice Recorder"
  window (120×120 floating) opens on whatever workspace the app started on and
  stays there — so the hotkey *looks* dead: recording toggles with zero visual
  feedback. Fix in `hyprland.lua`:

  ```lua
  o.window({ class = "open-whispr", title = "Voice Recorder" }, {
    float = true,
    pin = true,      -- visible on every workspace
    no_focus = true, -- focus must stay in the window receiving the text
  })
  ```

Debugging gotchas from that session:

- **`wtype` cannot trigger Hyprland binds** (virtual-keyboard input bypasses
  them here) — test binds with a physical keypress, e.g. a temporary
  `o.bind(..., "touch /tmp/marker")`.
- The **"Wayland Paste Setup" warning about ydotool is a false alarm** on
  Hyprland: the app's paste code tries `wtype` first on wlroots compositors and
  only falls back to ydotool. Safe to dismiss (it reappears each launch unless
  ydotool is fully set up).
- Useful checks: `omarchy menu keybindings --print` (is the bind live),
  `sqlite3 ~/.config/open-whispr/transcriptions.db "select * from transcriptions"`
  (did transcription happen at all), and
  `dbus-send --session --print-reply --dest=com.openwhispr.App /com/openwhispr/App com.openwhispr.App.Toggle`
  (does the app answer).

## Notes
- The two amdgpu params are workarounds for early Strix Halo firmware/driver bugs;
  as `linux` / `linux-firmware` mature they may become removable (test one at a time).
- Kernel cmdline lives in `/etc/default/limine`; `omarchy-refresh-limine` rebuilds it.
- To undo any fix: `sudo bash scripts/<name>.sh --uninstall`.
