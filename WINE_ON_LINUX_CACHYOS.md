# the-old-via

Everything needed to change RGB colors / keymap on a **GrayStudio Space80 Apollo (Mouser hotswap)** keyboard from Linux, using the only version of VIA its firmware speaks: **VIA 1.3.1**.

## Why this repo exists

The Space80 Apollo's stock firmware uses the old VIA protocol (V2-era). Anything newer than VIA 1.3.1 — including the modern web app at https://usevia.app and the V3 desktop builds — uses an incompatible protocol and **will not detect the keyboard**.

VIA 1.3.1 was released in 2020. The Linux `.deb` and the source on GitHub are no longer downloadable; only the Windows installer (`via-1.3.1-win.exe`) remains in the GitHub releases assets. So this repo bundles:

- `Space80_Apollo_Mouser_Hotswap.hex` — the QMK firmware (only needed if reflashing)
- `Mouser_Space80.json` — the VIA keyboard definition (loaded via VIA's Design tab)
- `92-via.rules` — udev rule that gives the user access to the keyboard's hidraw nodes
- `run-via.sh` — launches VIA under Wine

The Windows installer itself (`via-1.3.1-win.exe`) is **not** committed — grab it from the upstream releases page:

- https://github.com/the-via/releases/releases/tag/v1.3.1 (asset: `via-1.3.1-win.exe`)

Drop it into the repo root before running the extraction step below.

## Hardware identifiers

- Vendor: `0x000D` (GrayStudio), Product: `0x1969` (Space80)
- `lsusb` shows: `ID 000d:1969 GrayStudio Space80`

## Setup (Arch / CachyOS)

Tested on CachyOS with Wine 11.7 and `7zip` 26.x.

```bash
sudo pacman -S --needed wine 7zip
```

### 1. Extract VIA from the Windows installer

The NSIS installer is just a 7z wrapper around an Electron app. Extract it directly — no need to actually run the installer under Wine:

```bash
7z x via-1.3.1-win.exe -ovia-extracted -y
7z x 'via-extracted/$PLUGINSDIR/app-64.7z' -ovia-app -y
# Result: ./via-app/VIA.exe
```

Note: on Arch the binary is `7z`, not `7zz`.

### 2. Install the udev rule

Without this, `/dev/hidraw*` for the keyboard is `root:root 0600` and VIA cannot open it.

```bash
sudo cp 92-via.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger --action=change
```

Verify — the Space80 hidraw nodes should now be group-readable by `users`:

```bash
ls -l /dev/hidraw* | grep -B0 -A0 .   # the Space80 nodes should be root:users 0660
```

**Gotcha:** `TAG+="uaccess"` alone is the "correct" systemd-style approach, but on this system it did not actually apply ACLs — the device stayed `root:root`. Adding `GROUP="users"` fixed it (and the user is already in `users`). The rule keeps both: `uaccess` for systems where it works, and the explicit group as a reliable fallback.

### 3. Run VIA

```bash
./run-via.sh
```

This is just a wrapper for:

```bash
cd via-app && WINEDEBUG=-all wine VIA.exe
```

If you've changed the udev rule while VIA was running, fully reset wine state:

```bash
pkill -f VIA.exe; wineserver -k
./run-via.sh
```

### 4. Load the keyboard definition

Inside VIA:

1. **Settings** (gear icon) → enable **Show Design tab**.
2. **Design** tab → load `Mouser_Space80.json`.
3. **Configure** tab → the Space80 should appear → use the **Lighting** menu for colors / effects / brightness.

## Harmless noise to ignore in the Wine log

- `Cannot download "...via-1.3.1-win.exe.blockmap", status 404` — VIA's auto-updater trying to "upgrade" to v3.0.0. Incompatible anyway; ignore.
- `Error: Redirect was cancelled` — same auto-updater path.
- `libEGL warning: pci id for fd ...: 10de:..., driver (null)` — NVIDIA + Wine GLES warning, cosmetic.
- `Loading non context-aware native modules in the renderer process is deprecated` — old Electron warning.

## Things that DO NOT work (don't waste time)

- **https://usevia.app** (web VIA / V3) — protocol mismatch; keyboard not detected.
- **VIA 2.x / 3.x desktop AppImage** — same protocol mismatch.
- **VIAL** — would require reflashing with a VIAL-patched firmware. Overkill just to change colors.
- **`7zz`** — not the binary name on Arch; use `7z`.
- **Running the NSIS installer under Wine** — works but pointless; direct extraction is cleaner and avoids creating a wineprefix full of registry junk.

## Reflashing the firmware (only if you really need to)

The `.hex` is a QMK firmware for ATmega32U4-class MCUs. Put the keyboard into bootloader mode (usually via a reset button or a `QK_BOOT` keycode) and use `qmk flash` or `avrdude`. You don't need this for color or keymap changes — VIA writes those to EEPROM at runtime.
