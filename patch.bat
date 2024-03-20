@echo off

:: For this to work, open the asm with this and make sure the rom is called "fb2k.gb".
:: Oh, and rgbds is expected to be defined in your PATH environment.


echo Assembling specified file(s)...
set list=
:Loop
IF "%1"=="" GOTO Continue
    rgbasm -o ".\%~n1.obj" %1
    set list=%list% ".\%~n1.obj"
SHIFT
GOTO Loop
:Continue
echo Patching fb2k.gb...
rgblink -O fb2k.gb -o ".\fb2k_mod.gb" %list% -n ".\fb2k_mod.sym"
echo Fixing the new rom's checksum...
rgbfix -f gh ".\fb2k_mod.gb"