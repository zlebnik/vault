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
| **Hard power-off while gaming in clamshell** (Tctl 90+ °C, TDP 60+ W, nothing in the journal) | EC thermal trip fires before the kernel's 100–120 °C zones; the factory fan table tops out at **80 °C → 58 %** and never grows, and ppd's performance profile pins `scaling_governor=performance` so the **only available EPP is `performance`** (asusd's `profile_performance_epp` is silently ignored) | custom fan curves hitting 100 % at 80 °C + ppd `--block-driver=amd_pstate` so asusd sets EPP `balance_performance` + a logger/emergency PPT limiter | [`scripts/fix-asus-z13-fan-curves.sh`](scripts/fix-asus-z13-fan-curves.sh), [`scripts/fix-asus-z13-epp.sh`](scripts/fix-asus-z13-epp.sh), [`scripts/fix-asus-z13-thermal-guard.sh`](scripts/fix-asus-z13-thermal-guard.sh) |

Status: all applied and confirmed working (audio fix 2026-07-26; rest 2026-07-12). Thermal scripts written 2026-08-23 — see [Thermal](#thermal-hard-power-off-while-gaming) for status.

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

### Thermal: hard power-off while gaming

**Symptom** (2026-08-23 analysis): 16 `crash` entries in `last -x` since 2026-07-12; 7 of
them with Steam busy in the final minutes and 5 of those with the lid closed (clamshell
on the kickstand, 4K HDMI). The journal ends mid-stream with **no** thermal/throttle/SMU
line — the kernel's ACPI zones trip at 100–120 °C and would log
`critical temperature reached`, so this is the **EC / hardware trip** cutting power first.
User-observed Tctl was 90+ °C at 60+ W.

**What was wrong on the software side** (TDP itself left at the stock performance
60/75/86 W by choice):

1. **Fans never reach max.** asusd ships with custom curves disabled, so the EC runs its
   factory table. The table the kernel reads back (`asus_custom_fan_curve` hwmon)
   ends at **80 °C → 147/255 (58 %)** CPU, 155/255 (61 %) GPU — no point above 80 °C.
2. **EPP is locked to `performance`.** power-profiles-daemon's `amd_pstate` driver sets
   `scaling_governor=performance` for its performance profile; under `amd-pstate-epp`
   that shrinks `energy_performance_available_preferences` to just `performance`, so
   asusd logs `Available EPP: [Performance]` and its `profile_performance_epp` never
   applies. Every core boosts flat-out even when the game is GPU-bound.
3. **No data.** Nothing logs temperatures, so every crash is a guess.

**Fix — three independent scripts (run in this order, all idempotent, all `--uninstall`):**

```bash
sudo bash scripts/fix-asus-z13-fan-curves.sh     # custom curves: 25 % @42 °C … 100 % @80 °C (performance + balanced)
sudo bash scripts/fix-asus-z13-epp.sh            # ppd --block-driver=amd_pstate + asusd profile_performance_epp: BalancePerformance
sudo bash scripts/fix-asus-z13-thermal-guard.sh  # logger + emergency PPT limiter (systemd service)
```

- **Fan curves** go through asusd (`asusctl fan-curve --mod-profile … --data …
  --enable-fan-curves true`), which persists them in `/etc/asusd/fan_curves.ron` and
  re-applies on profile change and resume. CPU-fan points follow CPU temp, GPU-fan
  points follow GPU temp. Check: `bash scripts/fix-asus-z13-fan-curves.sh --verify`
  (`pwm1_enable=1` = custom active). **Gotcha:** in custom-curve mode the EC has a
  floor of ~3400/3700 rpm no matter how low the first point is (6 % tested), vs
  ~2800/3100 rpm in factory mode — so thermal-guard below toggles the mode by
  temperature instead of leaving the custom curve on permanently. Also `--data`
  resets the profile's enabled flag; enable last.
- **EPP**: a drop-in `/etc/systemd/system/power-profiles-daemon.service.d/10-block-amd-pstate.conf`
  keeps ppd in charge of `platform_profile` only (omarchy's bar, `omarchy-powerprofiles-set`
  and the `99-power-profile.rules` udev hook are untouched); governor falls back to the
  kernel default `powersave` and asusd (`platform_profile_linked_epp: true`) sets EPP per
  profile. Check: `bash scripts/fix-asus-z13-epp.sh --verify` → `governor=powersave
  epp=balance_performance`. Note: on battery ppd (omarchy state → `balanced`) and asusd
  (`Quiet`) both write `platform_profile`, last writer wins — pre-existing, not changed here.
- **thermal-guard** (`/usr/local/bin/asus-z13-thermal-guard`, `asus-z13-thermal-guard.service`):
  every 10 s (every 5 s at ≥85 °C) logs one line —
  `tctl=… gpu=… ppt=…W fan=cpu/gpu curve=factory|custom profile=… pl=PL1/PL2/PL3`.
  **Fan-curve hysteresis:** keeps the EC on the factory table while cool (quiet desk),
  flips `pwm*_enable` to the custom curve when Tctl/GPU reach **60 °C**, and back to
  factory after 60 s below **50 °C** (`THERMAL_GUARD_FAN_ON/OFF/OFF_HOLD`; `FAN_ON=0`
  disables the toggling). If Tctl **or** GPU edge
  reaches **93 °C** it writes **35/40/45 W** into
  `/sys/class/firmware-attributes/asus-armoury/attributes/ppt_*` and restores the
  previous limits once both temps stay ≤80 °C for 30 s (also on service stop). asusd only
  rewrites PPT on profile/AC change (and its tuning group is disabled), so they don't fight;
  if the limits change under the guard it logs and stands down. Thresholds are
  `Environment=THERMAL_GUARD_*` lines in the unit.
  ```bash
  journalctl -t thermal-guard -f                 # live
  journalctl -t thermal-guard --since -30min     # after a session
  journalctl -t thermal-guard -p err             # only TRIP events
  sudo bash scripts/fix-asus-z13-thermal-guard.sh --status
  ```

**If it still trips** — next levers, in order:

1. **BIOS**: the machine runs `GZ302EA.308` (2025-03); ASUS has **.311** (2025-08). Flash
   from Linux-free EZ Flash 3: download from the
   [GZ302 BIOS page](https://rog.asus.com/laptops/rog-flow/rog-flow-z13-2025/helpdesk_bios/),
   put the `.bin` on a FAT32 stick, F2 at boot → Advanced → ASUS EZ Flash 3. Check the
   boot order afterwards (ASUS sometimes resets it). No confirmed changelog entry for
   the thermal cut — treat as "worth trying", not a fix.
2. **Lower PPT** (persisted by asusd per profile, survives profile changes):
   ```bash
   busctl set-property xyz.ljones.Asusd /xyz/ljones xyz.ljones.Platform EnablePptGroup b true
   asusctl armoury set ppt_pl1_spl 50 && asusctl armoury set ppt_pl2_sppt 60 && asusctl armoury set ppt_pl3_fppt 70
   ```
   asusd stores this as `ac_profile_tunings: { Performance: (enabled: true, group: { PptPl1Spl: 50, … }) }`
   in `/etc/asusd/asusd.ron`. Roughly −5–10 % fps in CPU-bound games, much lower peaks.

**Not this issue** — a second crash pattern in the same window: ~6 boots end in silence
7–15 min after `PM: suspend exit` with the machine idle (2026-07-26 04:02, 07-30 06:25,
08-01 13:22, 08-03 04:04, 08-04 22:03, 08-07 05:42). Not thermal; separate investigation.

## Notes
- The two amdgpu params are workarounds for early Strix Halo firmware/driver bugs;
  as `linux` / `linux-firmware` mature they may become removable (test one at a time).
- Kernel cmdline lives in `/etc/default/limine`; `omarchy-refresh-limine` rebuilds it.
- To undo any fix: `sudo bash scripts/<name>.sh --uninstall`.
- Thermal status lines: `journalctl -t thermal-guard`; second crash pattern (idle after resume) still open.
