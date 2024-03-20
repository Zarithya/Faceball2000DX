INCLUDE "inc/hardware.inc"
INCLUDE "config.inc"
INCLUDE "inc/const.inc"
INCLUDE "inc/gfx.inc"
INCLUDE "inc/coords.inc"
INCLUDE "inc/asserts.inc"
INCLUDE "inc/gfx_constants.inc"
INCLUDE "inc/scgb_constants.inc"

DEF IS_DMG      EQU $00 ; single-speed
DEF IS_SGB      EQU $01 ; single-speed, colorized
DEF IS_CGB      EQU $02 ; double-speed, colorized
DEF IS_CDMG     EQU $03 ; special grayscale single-speed mode on CGB

SECTION "Start",ROM0[$0101]
    jp _Start

SECTION "Title",ROM0[$0134]
    db "FACEBALL 2000DX"

SECTION "Target System",ROM0[$0143]
    db $80 ; DMG & CGB

SECTION "New Licensee Code",ROM0[$0144]
    db "8B" ; Bullet-Proof Software (New License)

SECTION "SGB Flag",ROM0[$0146]
    db $03 ; SGB compatible

SECTION "MBC & Size",ROM0[$0147]
    db $19
    db 3

SECTION "Old Licensee Code",ROM0[$014B]
    db $33 ; Use "New Licensee Code" instead (and enable SGB)

SECTION "Game Boot",ROM0[$00C0]
; Check for DMG/SGB or CGB using accumulator value
_Start::
    cp $11 ; CGB check
    jr z, .cgb
    xor a ; IS_DMG
    jr .all

.cgb
    di
    ld a, 1
    ldh [rSPD], a
    ld a, $30
    ldh [rP1], a
    stop ; switch to double-speed
    ld a, IS_CGB
.all
    ldh [hCGB], a
    jp $09B1

ClearHRAM:
    ld hl, _HRAM
    
.loop
    xor a
    ld [hli], a
    ld a, l
    and a
    jr nz, .loop
    ret

ClearVRAM:
    ld bc, _SRAM - _VRAM
    ld hl, _VRAM
.statcheck
    ldh a, [rSTAT]
    and $02
    jr nz, .statcheck

    xor a
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jr nz, .statcheck
    ret
;
; Misc hooks
;
SECTION "Clear HRAM Hook",ROM0[$09DB]
    ldh a, [hCGB]
    push af
    call ClearHRAM
    pop af
    ldh [hCGB], a

SECTION "BPS Screen Button Checks",ROMX[$775C],BANK[1]
    jp BootScreensButtonChecks

SECTION "Copyright Screen Title",ROMX[$421F],BANK[7]
    db "  FACEBALL 2000 DX  ", 0

SECTION "Copyright Screen License",ROMX[$436F],BANK[7]
    db "; 2024 FB DX16 Team ", 0

SECTION "Title Screen Logo",ROMX[$6634],BANK[2]
	INCBIN "gfx/logo.2bpp"

SECTION "Title Screen Timer Init",ROMX[$77DD],BANK[1]
    ld a, $c8

SECTION "Title Screen Credits Swapping",ROMX[$783A],BANK[1]
    call TitleScreenCreditsSwap

SECTION "Title Screen Start Flash",ROMX[$7852],BANK[1]
    and $04
    jr z, $7867

SECTION "Title Screen Flashing Shots Timer",ROMX[$7A0B],BANK[1]
    and a, $0F

SECTION "Title Screen Timer Hook 1",ROMX[$7898],BANK[1]
    call TitleScreenTimerFix

SECTION "Title Screen Timer Hook 2",ROMX[$78B4],BANK[1]
    call TitleAndDemoTimerFix

SECTION "Press A on Title Instead of Select",ROMX[$7978],BANK[1]
    bit 0, a

SECTION "Demo Timer Init",ROMX[$78C2],BANK[1]
    ld a, $90
    ld [$d9f9], a
    ld a, $01

SECTION "Speed Up Demo Timer",ROMX[$41FD],BANK[1]
    call TitleAndDemoTimerFix

SECTION "Input Read Hook",ROM0[$085B]
    call InputReadHook

SECTION "Congrats Screen Timer",ROM0[$3450]
    ld a, $38

SECTION "Congrats Screen Hook",ROMX[$4166],BANK[1]
    jp CongratsScreenTimerFix

;
; Colorization Hooks
;
SECTION "Fade Hook",ROM0[$08BF]
    jp LoadPalettesForFade

SECTION "Copyright Init Hook",ROMX[$7799],BANK[1]
    call CopyrightInitHook

SECTION "Title Init Hook",ROMX[$77CB],BANK[1]
    call TitleInitHook

SECTION "Inter-Face Init Hook",ROMX[$45C2],BANK[1]
    call InterFaceInitHook

SECTION "Team Play Init Hook",ROMX[$6CC2],BANK[1]
    call TeamPlayInitHook

SECTION "Return To Inter-Face Init Hook",ROMX[$6CED],BANK[1]
    call ReturnToInterFaceInitHook

SECTION "Gameplay Scene Init Hook",ROM0[$21DC]
    call GameplaySceneInitHook

SECTION "Ending Smiloid Scene Init Hook",ROMX[$7B31],BANK[1]
    call EndingSmiloidSceneInitHook

SECTION "Credits Init Hook",ROMX[$5A9E],BANK[4]
    call CreditsInitHook

SECTION "UpdateVRAMGFX Hook",ROM0[$12D2]
UpdateVRAMGFX:
    call UpdateVRAMGFXHook

;
; Colorization Jumps
;
SECTION "Tile Attribute Load Jumps",ROM0[$0150]
BPSLogoInitHook::
    di
    ldh a, [hCurBank]
    push af
    ld a, 8
    ldh [hCurBank], a
    ld [rROMB0 + $100], a
    ei
    call LoadWaveform
    ld a, [hCGB]
    cp IS_DMG ; SGB identifies as DMG on boot
    jr nz, .notsgb
    call CheckAndInitSGB
.notsgb
    push de
    ld b, SCGB_BPS_LOGO
    call _LoadTileAttrs
    pop de
    di
    pop af
    ldh [hCurBank], a
    ld [rROMB0 + $100], a
    reti

CopyrightInitHook::
    call UpdateVRAMGFX
    push de
    ld b, SCGB_COPYRIGHT
    call LoadTileAttrs
    pop de
    ret

TitleInitHook::
    call $37BF
    push de
    ld b, SCGB_TITLE
    call LoadTileAttrs
    pop de
    ret

InterFaceInitHook::
    push de
    ld b, SCGB_INTERFACE
    call LoadTileAttrs
    pop de
    ld a, [$C907]
    ret

TeamPlayInitHook::
    push de
    ld b, SCGB_TEAMPLAY
    call LoadTileAttrs
    pop de
    call $13d6 ; PrepareCopyrightTilemapUpdate
    ret

ReturnToInterFaceInitHook::
    push de
    ld b, SCGB_INTERFACE
    call LoadTileAttrs
    pop de
    call $13d6 ; PrepareCopyrightTilemapUpdate
    ret

GameplaySceneInitHook::
    push de
    ld b, SCGB_GAMEPLAY
    call LoadTileAttrs
    pop de
    ld hl, $c7b0
    ret

EndingSmiloidSceneInitHook::
    push de
    ld b, SCGB_ENDING_SMILOIDS
    call LoadTileAttrs
    pop de
    ld hl, $7BC2
    ret

CreditsInitHook::
    call $00A1
    push de
    ld b, SCGB_CREDITS
    call LoadTileAttrs
    pop de
    ret

; Switch between original title screen bottom row credits and DX hack credits every few frames
TitleScreenCreditsSwap::
    ld a, [$da53]
    and $20
    jr z, .draw
    ld hl, DXCreditsTitle
.draw
    call $1d29
    ret

; Prevent reading of inputs during SGB transfers (SGB transfers are done through joypad register)
InputReadHook::
    ld a, [hDisableInputs]
    and a
    ret nz
    call $14BB ; ReadInput
    ret

SECTION "Load Tile Attributes",ROM0[$0490]
LoadTileAttrs::
    di
    ldh a, [hCurBank]
    push af
    ld a, 8
    ldh [hCurBank], a
    ld [rROMB0 + $100], a
    ei
    call _LoadTileAttrs
    di
    pop af
    ldh [hCurBank], a
    ld [rROMB0 + $100], a
    reti

; Clear both VRAM banks on CGB
UpdateVRAMGFXHook:
    ld a, 1
    ld [rVBK], a
    call ClearVRAM
    xor a
    ld [rVBK], a
    ld hl, _VRAM
    ret

DXCreditsTitle::
    dw DXCredits2 ; next text def
    dw .text ; string
    db 0 ; text mode
    db 0, 16 ; x, y
.text
    db "     Modded by      ", 0

DXCredits2::
    dw 0 ; next text def
    dw .text ; string
    db 0 ; text mode
    db 0, 17 ; x, y
.text
    db " Zarithya & kkzero  ", 0

SECTION "Load Palettes",ROM0[$0590]
LoadPalettesForFade::
    ld hl, $14b6
    ldh a, [hCGB]
    and a ; IS_DMG
    jp z, $08c2 ; original fade routine
    call LoadPalettes
    ldh a, [hCGB]
    cp a, IS_SGB
    jp nz, $08ca
.sgb
    ld a, $27
    jp $08c4 ; force specific pal order for SGB compatibility

LoadPalettes::
    di
    ldh a, [hCurBank]
    push af
    ld a, 8
    ldh [hCurBank], a
    ld [rROMB0 + $100], a
    ei
    call _LoadPalettes
    di
    pop af
    ldh [hCurBank], a
    ld [rROMB0 + $100], a
    reti

; Run timer at double speed on non-CGB (compensate for clock speed difference)
CongratsScreenTimerFix:
    dec a
    jp z, $416B
    push af
    ldh a, [hCGB]
    cp IS_CGB
    jr z, .end
    pop af
    dec a
    jp z, $416B
    jp $4169

.end
    pop af
    jp $4169

SECTION "Boot Screens Button Checks (UnDXify, Skip Screens)",ROM0[$0690]
BootScreensButtonChecks::
    ld a, [$c902]
    ld c, a
    bit 0, c
    jr nz, .skipscreen
    bit 3, c
    jr nz, .skipscreen

    ldh a, [hCGB]
	bit 1, a ; IS_CGB or IS_CDMG
    jr z, .end

    bit 1, c
    jr z, .end
    bit 2, c
    jr z, .end

    cp a, IS_CDMG
    jr z, .reDX

    bit 7, c
    jr z, .end
    ld a, IS_CDMG
    jr .loadandend

.reDX
    bit 6, c
    jr z, .end
    ld a, IS_CGB

.loadandend
    ldh [hCGB], a
    ld a, [$c905]
    ld c, a
    ld b, $00
    call LoadPalettes
    di
    ld a, $30
    ldh [rP1], a
    ld a, 1
    ldh [rSPD], a
    stop
    ei

.end
    call $125d
    jp $775f

.skipscreen
    pop bc
    and a
    ret

; Run timer at double speed on non-CGB (compensate for clock speed difference)
TitleScreenTimerFix:
    ldh a, [hCGB]
    cp IS_CGB
    jr z, .end
    inc [hl]
.end
    ld a, [$da46]
    ret

; Run timer at double speed on non-CGB (compensate for clock speed difference)
TitleAndDemoTimerFix:
    ld b, a
    dec bc
    or c
    jr z, .end
    ldh a, [hCGB]
    cp IS_CGB
    jr z, .end
    dec bc
.end
    ld a, c
    ret

; Clear both VRAM banks on CGB
SECTION "Clear VRAM Hook",ROMX[$4021],BANK[4]
    call ClearVRAM
    ld a, 1
    ld [rVBK], a
    call ClearVRAM
    xor a
    ld [rVBK], a
    call BPSLogoInitHook
    nop

; New credits pages data
SECTION "Credits",ROMX[$5B2F],BANK[4]
    db 4
    dw CreditsScreen1Line1, CreditsScreen1Line2, $5BBA, $5BCE

    db 2
    dw $5BE2, $5BF6

    db 4
    dw $5C0A, $5C1E, $5C32, $5C46

    db 3
    dw $5C5A, $5C6E, $5C82

    db 3
    dw $5C96, $5CAA, $5CBE

    db 3
    dw $5CD2, $5CE6, $5CFA

    db 3
    dw $5D0E, $5D22, $5D36

    db 4
    dw $5D4A, $5D5E, $5D72, $5D86

    db 3
    dw $5D9A, $5DAE, $5DC2

    db 4
    dw $5DD6, $5DEA, $5DFE, $5E12

    db 4
    dw $5E26, $5E3A, $5E4E, $5E62

    db 4
    dw CreditsScreenDXLine1, CreditsScreenDXLine2, CreditsScreenDXLine3, CreditsScreenDXLine4

    db 5
    dw CreditsScreenGB16TeamLine1, CreditsScreenGB16TeamLine2, CreditsScreenGB16TeamLine3, CreditsScreenGB16TeamLine4, CreditsScreenGB16TeamLine5

    db 4
    dw CreditsScreenSpecialThanksLine1, CreditsScreenSpecialThanksLine2, CreditsScreenSpecialThanksLine3, CreditsScreenSpecialThanksLine4

    db 6
    dw $5E76, $5E8A, $5E9E, $5EB2, $5EC6, $5EDA

    db 0

; New credits text data
SECTION "New Credits",ROMX[$7E08],BANK[4]
CreditsScreen1Line1:
    db 1,   " FACEBALL 2000 DX ", 0
    
CreditsScreen1Line2:
    db 3,   " ---------------- ", 0
    
CreditsScreenDXLine1::
    db 2,   "      DX HACK     ", 0

CreditsScreenDXLine2::
    db 5,   "     Zarithya     ", 0
    
CreditsScreenDXLine3::
    db 7,   "      kkzero      ", 0

CreditsScreenDXLine4::
    db 9,   "     AntonioND    ", 0

CreditsScreenGB16TeamLine1::
    db 2,   "FACEBALL GB16 TEAM", 0

CreditsScreenGB16TeamLine2::
    db 5,   "     Zarithya     ", 0

CreditsScreenGB16TeamLine3::
    db 7,   "     Alex Bahr    ", 0

CreditsScreenGB16TeamLine4::
    db 9,   "     Uncle Bob    ", 0

CreditsScreenGB16TeamLine5::
    db 11,  "SSFF Derek & Grace", 0

CreditsScreenSpecialThanksLine1::
    db 2,   "  SPECIAL THANKS  ", 0

CreditsScreenSpecialThanksLine2::
    db 5,   "  Don Komarechka  ", 0
    
CreditsScreenSpecialThanksLine3::
    db 7,   "   Kelsey Lewin   ", 0

CreditsScreenSpecialThanksLine4::
    db 9,   "     Chris D.     ", 0

SECTION "New Data Bank",ROMX[$4000],BANK[8]
LoadWaveform::
    ld a, [rNR30]
    res 7, a
    ld [rNR30], a
    ld hl, _AUD3WAVERAM
    ld de, Waveform
    ld b, 16
.load_waveform_byte
    ld a, [de]
    inc de
    ld [hli], a
    dec b
    jr nz, .load_waveform_byte
.waveform_done
    ld a, [rNR30]
    set 7, a
    ld [rNR30], a
    ret

Waveform::
    ;db $49, $45, $47, $E1, $49, $45, $47, $E1, $10, $33, $A2, $8F, $DD, $E7, $60, $5E ; from BGB
    db $AC, $DD, $DA, $48, $36, $02, $CF, $16, $2C, $04, $E5, $2C, $AC, $DD, $DA, $48 ; from R-Type DX

INCLUDE "dx/color.asm"
INCLUDE "dx/sgb/sgb.asm"

IF GDMA_VER > 0
INCLUDE "gdma.asm"
ENDC

SECTION "this only exists to pad the file size",ROMX[$4000],BANK[$0F]
