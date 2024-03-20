# Faceball 2000 DX

Build requirements:
- RGBDS: https://github.com/gbdev/rgbds

RGBDS should be in your path.

## Building
1. Choose your options in config.inc (full 16 player fixes, and DX mod with or without GDMA).
2. Put an unmodified Faceball 2000 ROM (CRC32: 7D890CD0) called "fb2k.gb" into this directory.
3. In a command prompt, run patch.bat (Windows) or patch.sh (Linux) with the changes you'd like to include (dx.asm and/or 16.asm) as arguments.
If everything went well, fb2k_mod.gb will be created.

Also included is a symbol map (fb2k_dx.sym) that can aid you in looking at this game's innards yourself!
