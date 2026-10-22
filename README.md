# Videopac+ G7400 / Odyssey2 for Analogue Pocket

openFPGA core for the Philips Videopac+ G7400, Videopac G7000 and Magnavox Odyssey2, based on the
[Odyssey2 MiSTer G7400 core](https://github.com/nad22/Odyssey2_MiSTer-G7400).

## Systems

The core starts in Videopac+ G7400 mode (with the EF9340/EF9341 graphics overlay and "Select game" screen).
The core menu switches between:

- Videopac+ G7400 (PAL)
- Videopac G7000 (PAL)
- Odyssey2 (NTSC)

This is a fresh openFPGA port. The RTL comes from the MiSTer fork linked above, which adds the G7400
video system (EF9340/EF9341 overlay graphics) to the original Odyssey2/Videopac core. Video and audio
output were adapted for the Pocket: a frame buffer re-times the console video to a fixed 320x240 @ 60 Hz
signal and shows it pixel-exact (no resampling).

## Installation

1. Download `Videopac+_G7400_Pocket_<version>.zip` from the [Releases](../../releases) page and extract it
   to the root of the Pocket SD card (it creates `Cores/nad22.Videopac+ G7400/` and
   `Platforms/`). The core folder must keep this name (author + short name from `core.json`).
2. Add the BIOS/character ROM files listed below. They are not included and must come from your own dumps.
3. Put cartridge `.bin` files anywhere in `Assets/odyssey2/common/` and pick one when the core starts.

Place these files in `Assets/odyssey2/nad22.Videopac+ G7400/` (they are not included):

| File | Size |
|------|------|
| `o2bios.bin` | 1024 bytes |
| `g7400bios.bin` | 1024 bytes |
| `videopac_charset.bin` | 512 bytes |
| `ef9340_charset.bin` | 2560 bytes |

Cartridge `.bin` files up to 16 KiB are loaded from the Cartridge slot at core start.

## Controls

| Pocket | Videopac key |
|--------|--------------|
| D-pad | Joystick |
| B | Action button |
| Start / Select | Keys 1 / 2 |
| Y / X | Keys 3 / 4 |
| L / R trigger | Enter / Clear |

Use *Swap Controllers* in the core menu to exchange the players.

The Voice and USB keyboard are not implemented.

## Notes

- G7400 BIOS and EF9340 character ROM are required for the "Select game" screen and Plus graphics.
  Plus games (e.g. Stone Sling) show their overlay only in G7400 mode.
- The picture is cropped slightly in G7400 mode for Plus games; this matches the MiSTer core.
- Not implemented: The Voice, USB keyboard, sleep/save states.

## Related projects and credits

- MiSTer version with G7400 support (RTL source of this port): <https://github.com/nad22/Odyssey2_MiSTer-G7400>
- Upstream MiSTer Odyssey2 core: <https://github.com/MiSTer-devel/Odyssey2_MiSTer>
- Original FPGA Videopac by Arnim Laeuger (T48 / i8244 / vp_console VHDL), MiSTer port by Kitrinx and wsoltys.
- Analogue openFPGA framework template: <https://github.com/open-fpga/core-template>

The VHDL files retain their original copyright headers. This project is licensed under the GNU GPL v3
(see `LICENSE`).

## Building

Open `src/fpga/ap_core.qpf` with Quartus Prime 25.1 (device `5CEBA4F23C8`), compile, and convert the bitstream:

```
python src\fpga\rbf_reverse.py src\fpga\output_files\ap_core.rbf "release\Cores\nad22.Videopac+ G7400\g7400.rbf_r"
```
