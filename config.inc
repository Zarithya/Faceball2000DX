
; Toggle which version of the 16 player hack to assemble
; 0 - just fix 16 player compatibility
; 1 - finish the feature, stopping too many players from trying to use Cyberscape or enter small maps
DEF FULL16_VER EQU 1

;Toggle which version of the DX colorization and speed hack to assemble
; 0 - use original renderer (slower but compatible)
; 1 - use GDMA renderer (faster but doesn't work on hardware or most emulators)
DEF GDMA_VER EQU 0

DEF wFadeStatus EQU $c904
DEF wFadeLevel EQU $c905
DEF wPlayerCount EQU $c907
DEF wMenuItemCount EQU $da1f
DEF wCurMap EQU $dabb
DEF hCurBank EQU $ff80
DEF hNewBank EQU $ff81
DEF hPlayerNum EQU $ff92
DEF hPlayerCount EQU $ffa1
DEF hCGB EQU $fffc
DEF hDisableInputs EQU $fffd
DEF hCurrentLayout EQU $fffe
