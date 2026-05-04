# Running VIA 1.3.1 on Linux

Tested on CachyOS / Arch with Wine 11.7 and `7zip` 26.x.

## Prerequisites

```bash
sudo pacman -S --needed wine 7zip
```

Download `via-1.3.1-win.exe` from https://github.com/the-via/releases/releases/tag/v1.3.1 and drop it in the repo root. (Linux `.deb` and source are no longer available upstream.)

## 1. Extract the app

The NSIS installer is just a 7z-wrapped Electron app; extract it directly. From the repo root:

```bash
7z x via-1.3.1-win.exe -ovia-extracted -y
7z x 'via-extracted/$PLUGINSDIR/app-64.7z' -ovia-app -y
# Produces ./via-app/VIA.exe
```

## 2. Install the udev rule

Without this, the keyboard's hidraw nodes are `root:root 0600` and VIA can't open them.

```bash
sudo cp linux/92-via.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger --action=change
ls -l /dev/hidraw*   # Space80 nodes should be root:users 0660
```

The rule sets both `TAG+="uaccess"` and `GROUP="users"`. `uaccess` alone did not apply ACLs on CachyOS for unclear reasons; the explicit group is a reliable fallback (assumes your user is in `users`, which is the default).

## 3. Run VIA

```bash
./linux/run-via.sh
```

After changing the udev rule while VIA is running, reset Wine state first:

```bash
pkill -f VIA.exe; wineserver -k
```

Then load `Mouser_Space80.json` per the steps in the [root README](../README.md).

The auto-updater errors in the log (404 on blockmap, "Redirect was cancelled") are VIA trying to upgrade to the incompatible v3 — harmless, ignore.
