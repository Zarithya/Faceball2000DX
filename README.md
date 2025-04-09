# Faceball 2000 DX

This is a color/enhancement hack of the technological marvel that is Faceball 2000 for the Game Boy.

FEATURES:
- HIGHER FRAMERATE: This hack takes advantage of the GBC's extra hardware to increase the speed of gameplay.
- FULL COLOR: Multiple palettes have been utilized to add a splash of color to the game.
- SUPER GAME BOY ENHANCEMENTS: The same colorization the GBC has, now on the SGB! Also includes cool border!
- FIXED AUDIO: Sound channel 3 now actually gets a waveform loaded, making the music sound as intended.
- RESTORED 16 PLAYER SUPPORT: The fabled 16 player mode is here, in both minor-bugfix and complete-restoration flavors!

### Credits:
- [Zarithya](https://twitch.tv/Zarithya): 16 player fixes, SGB support, etc. (v2.0)
- [kkzero](https://github.com/kkzero241): Colorization, original GDMA Renderer and wave RAM initialization (from release v1.0)
- [Coffee 'Valen' Bat](https://github.com/coffeevalenbat): Rewritten GDMA Renderer and GBC lockout
- [AntonioND](https://github.com/AntonioND): Original [double-speed mod](http://www.skylyrac.net/2014-06-04-faceball-2000-double-speed-mod-v0-1.html)
- [planetclue](https://planetclue.com): SGB border design
- [Stop Skeletons From Fighting](https://youtube.com/@StopSkeletonsFromFighting): Bringing us all together and documenting the ride
- Uncle Bob: Sinking far too much time and money into making 16-player Faceball a reality
- Alex Bahr: Designing the world's first 16-player Game Boy adapter
- Don Komarechka: Documenting the legend of 16-player Faceball 2000
- Kelsey Lewin: Hosting the first ever 16-player Faceball tournament at Pink Gorilla Games in Seattle, WA on January 13, 2024
- Chris D: Connecting people together
- Rob Champagne, Michael Park, Darren Stone, and the rest of the Faceball 2000 & MIDI Maze dev teams: Dreaming big and making this all possible

This would not have been possible without all the people above and the support of many more. Thank you!

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

## Building
### Requirements:
- RGBDS: https://github.com/gbdev/rgbds

1. Put an unmodified Faceball 2000 ROM (CRC32: 7D890CD0) called "fb2k.gb" into this directory.
2. In a terminal window, run `make` with no arguments to build with the recommended config (full 16 player feature & DX colorization/speed hack). You can also specify arguments to configure the build to your liking (e.g. `make FIX16=2 DX=1` represents the default config):

| Variable Name | =1                               | =2                       |
| ---           | ---                              | ---                      |
| FIX16         | Basic 16 player fix              | Full completed feature   |
| DX            | Colorization, speed improvements | GDMA renderer (See below)|

3. If everything went well, a ROM with your desired changes will be created in the `build` directory.

Also included is a symbol map (fb2k_dx.sym) that can aid you in looking at this game's innards yourself!

#### IMPORTANT: GDMA VS. NO GDMA
When playing on Game Boy Color or Advance (or emulators thereof), you have the option of enabling the GDMA renderer (either by using the patch or by building with it enabled). This uses the GBC's General DMA channel to render the 3D display faster, but may cause issues with link cable connectivity and innacurate/untested systems/emulators.

The GDMA renderer is still untested on many hardware revisions, but should work on any Game Boy Color or Game Boy Advance system. Please report any found incompatibilities with official Nintendo hardware.

##### GDMA VERSION COMPATIBILITY:
Emulators:
- BGB - Pretty much flawless
- Sameboy - Pretty much flawless
- Mesen2 - Pretty much flawless
- Emulicious - Pretty much flawless
- VBA - Mostly flawless, but missing a small portion of the screen on the bottom right
- VBA-M - Crashes after title screen (?)
- GoombaColor - Crashes after title screen (?)

Hardware:
- DMG, MGB, SGB - Incompatible
- CGB-001 - Pretty much flawless
- AGB/AGS - Untested