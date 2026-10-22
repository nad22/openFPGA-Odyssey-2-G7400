Videopac+ G7400 / Odyssey2 Analogue Pocket port
================================================

System selection
----------------
The core starts in Videopac+ G7400 mode. In the core menu you can select:

- Videopac+ G7400 (PAL)
- Videopac G7000 (PAL)
- Odyssey2 (NTSC)

The core resets the emulated machine after a system change.

Required data files
-------------------
Load these files through the core's data slots from `Assets/odyssey2/nad22.Videopac+ G7400/`. The ROM files are not included in this package:

- `o2bios.bin` — Odyssey2 BIOS, 1024 bytes
- `g7400bios.bin` — Videopac+ G7400 BIOS, 1024 bytes
- `videopac_charset.bin` — Videopac character set, 512 bytes
- `ef9340_charset.bin` — G7400 EF9340 character set, 2560 bytes

The filenames and exact sizes are defined in `data.json`. The ROM images must be supplied by the user.

Cartridges
----------
Load `.bin` cartridges up to 16 KiB using the Cartridge data slot.

Building from source
--------------------
Open `src/fpga/ap_core.qpf` with Quartus Prime 25.1 and compile the `ap_core` revision for device `5CEBA4F23C8`. Convert the generated RBF to the bit-reversed APF format:

`python src\fpga\rbf_reverse.py src\fpga\output_files\ap_core.rbf "release\Cores\nad22.Videopac+ G7400\g7400.rbf_r"`

The resulting `g7400.rbf_r` is the Pocket core image referenced by `core.json`.

Controls and limitations
------------------------
D-pad = joystick, B = action button, Start/Select = keys 1/2, Y/X = keys 3/4, L/R trigger = Enter/Clear. Use the core menu's Swap Controllers option to exchange the players.

The Voice speech hardware and USB keyboard input are not implemented.
