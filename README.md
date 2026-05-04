# the-old-via

Files needed to use the **GrayStudio Space80 Apollo (Mouser hotswap)** keyboard with VIA. Its firmware only speaks the old VIA protocol, so you need VIA **1.3.1** — newer versions (the web app at https://usevia.app, or VIA 2.x/3.x) will not detect it.

USB IDs: `000d:1969` (`lsusb`: `GrayStudio Space80`).

## Files

- `Mouser_Space80.json` — VIA keyboard definition. Load via VIA's **File → Load Draft Definition**.
- `firmware/Space80_Apollo_Mouser_Hotswap.hex` — QMK firmware. Only needed if reflashing; not used for color or keymap changes (VIA writes those to EEPROM at runtime).
- `linux/` — Wine setup, udev rule, launcher. See [linux/README.md](linux/README.md).

## Using VIA

1. Get VIA 1.3.1: https://github.com/mbaan/the-old-via/releases/tag/v1.3.1 (Linux: see [linux/README.md](linux/README.md)).
2. **File** menu → **Load Draft Definition** → select `Mouser_Space80.json`.
3. **Lighting** menu → change colors / effects / brightness.

Credit: original [the-old-via](https://github.com/shiroshiro14/the-old-via) for preserving the 1.3.1 binary; upstream [the-via](https://github.com/the-via).
