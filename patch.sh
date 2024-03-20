#!/usr/bin/env bash

# For this to work, open the asm with this and make sure the rom is called "fb2k.gb".
# Oh, and rgbds is expected to be defined in your PATH environment.

echo "Assembling specified file(s)..."
list=
for var in "$@"
do
    filename="${var%%.*}"
    rgbasm -o "./${filename}.obj" $var
    list+=" ./${filename}.obj"
done
echo "Patching fb2k.gb..."
rgblink -O fb2k.gb -o "./fb2k_mod.gb" $list -n "./fb2k_mod.sym"
echo "Fixing the new rom's checksum..."
#Currently doing this manually for compatibility with just 16 player mod
#rgbfix -O -f gh  -s -c -k "8B" -l 0x33 -m "MBC5" -p 0xFF -t "FACEBALL2000DX" "./fb2k_mod.gb"
rgbfix -O -f gh "./fb2k_mod.gb"
echo "Done!"
