# Faceball 2000 DX

This is a color/enhancement hack of the technological marvel that is Faceball 2000 for the Game Boy.

### Credits:
- [Zarithya](https://github.com/Zarithya): 16 player fixes, SGB support, etc. (v2.0)
- [kkzero](https://github.com/kkzero241): Colorization (from release v1.0)
- [AntonioND](https://github.com/AntonioND): Original double-speed mod (http://www.skylyrac.net/2014-06-04-faceball-2000-double-speed-mod-v0-1.html)

#### v2.0 (2024)
- Fixed 16 player support (official release has support for only up to 15 players due to an off-by-one mistake)
- Finished support for >4 players (disabled certain features and maps that do not work for high numbers of players)
- Added SGB support (screen border, colorization)
- Finished colorization (certain screens had incorrect colors)
- Added DMG simulation mode (to play at original speed on hardware with GBC clock speed functionality, press B+SELECT+Down on copyright screens)
- Added a way to skip copyright screens by pressing A/START
- Added support for pressing A on title screen

#### v1.0 (August 1st, 2021)
- Initial release

FEATURES:
- HIGHER FRAMERATE: This hack takes advantage of the GBC's extra hardware to increase the speed of gameplay.
- FULL COLOR: Multiple palettes have been utilized to add a splash of color to the game.
- SUPER GAME BOY ENHANCEMENTS: The same colorization the GBC has, now on the SGB! Also includes cool border!
- FIXED AUDIO: Sound channel 3 now actually gets a waveform loaded, making the music sound as intended.
- RESTORED 16 PLAYER SUPPORT: The fabled 16 player mode is here, in minor bugfix and complete restoration flavors!

Build requirements:
- RGBDS: https://github.com/gbdev/rgbds

RGBDS should be in your path.

## Building
1. Choose your options in config.inc (full 16 player fixes, and DX mod with or without GDMA).
2. Put an unmodified Faceball 2000 ROM (CRC32: 7D890CD0) called "fb2k.gb" into this directory.
3. In a command prompt, run patch.bat (Windows) or patch.sh (Linux) with the changes you'd like to include (dx.asm and/or 16.asm) as arguments.
If everything went well, fb2k_mod.gb will be created.

Also included is a symbol map (fb2k_dx.sym) that can aid you in looking at this game's innards yourself!

#### IMPORTANT: GDMA VS. NO GDMA
When playing on Game Boy Color or Advance (or emulators thereof), you have the option of enabling the GDMA renderer (either by using the patch or by building with it enabled).
This uses the GBC's General DMA channel to render the 3D display faster, but has some trade-offs.
Namely, it has issues with several emulators and hardware versions, as well as with link connectivity.
It is experimental and not recommended for most players.

##### GDMA VERSION COMPATIBILITY:
Emulator:
- BGB - Pretty much flawless
- VBA - Pretty much flawless
- Sameboy - Playable, but suffers graphical artifacts on screen
- mGBA - Playable, but suffers graphical artifacts on screen

Hardware:
- DMG, MGB, SGB - incompatible
- CGB-001 - Playable, but suffers severe graphical glitchiness
- AGB-001 - Playable, but suffers severe graphical glitchiness
- AGS-001 - Untested
- AGS-101 - Pretty much flawless, other than the top tile row flickering
- DOL-017 - Untested
