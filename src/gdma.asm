; Based on kkzero's initial DMA work, rewritten and optimized by Coffee 'Valen' Bat
SECTION "Color lockout hook part 1", ROM0[$0023]
DEF GFX_ADDR = $9634
gbcLockcheckHook:
    ldh a, [hCGB]
    or a
    jr gbcLockcheck.part2
SECTION "Color lockout hook part 2", ROM0[$002B]
gbcLockcheck.part2:
    ret nz
    di
    jr gbcLockcheck.part3

SECTION "Color lockout hook part 3", ROM0[$0033]
gbcLockcheck.part3:
    ; Before jumping to lockout code, copy data to VRAM
    call DisableLCD
    jr gbcLockcheck.part4

SECTION "Color lockout hook part 4", ROM0[$0064]
gbcLockcheck.part4:
    ld hl, rROMB0 | (GFX_ADDR >> 14)
    ld [hl], l
    ld hl, (GFX_ADDR & $7FFF) + $4000
    ld de, $8000
    ld bc, 128 * 16
    :ld a, [hli]
    ld [de], a
    inc de
    dec bc
    ld a, c
    or b
    jr nz, :-
    ld hl, rROMB0 | BANK(gbcLockout)
    ld [hl], l
    jp gbcLockout

SECTION "GBC Lockout code", ROMX[$7000], BANK[15]
gbcLockoutText:
    db "                    "
    db "                    "
    db " ", $63 + " ", "FACEBALL 2000 DX", $63 + " "," "
    db "                    "
    db " The GDMA version of"
    db "this romhack is only"
    db "  compatible with   "
    db "   color enhanced   "
    db "      systems.      "
    db "                    "
    db "If you're looking to"
    db "  play on not-color "
    db " compatible systems,"
    db "please look for the "
    db " NO-GDMA version of "
    db "    this romhack.   "
    db "                    "
    db "                    "

    ; Setup screen
gbcLockout:
    di
    ld hl, gbcLockoutText
    ld de, $9800
    ld b, 18
.LineLoop:
    ld c, 20
.rowLoop:
    ld a, [hli]
    sub " "
    ld [de], a
    inc de
    dec c
    jr nz, .rowLoop
    ld a, e
    add 32 - 20
    ld e, a
    adc d
    sub e
    ld d, a
    dec b
    jr nz, .LineLoop
    ; FInally, setup LCD
    ld a, $E4
    ldh [rBGP], a
    xor a
    ldh [rSCX], a
    ldh [rSCY], a
    ld a, LCDCF_ON | LCDCF_BGON | LCDCF_BG8000
    ldh [rLCDC], a
.Idle:
    halt
    nop
    jr .Idle

SECTION "Buffer RAM Pointers",ROM0[$0300]
    dw $CA00
    dw $CA02
    dw $CA04
    dw $CA06
    dw $CA08
    dw $CA0A
    dw $CA0C
    dw $CA0E
    dw $CB20
    dw $CB22
    dw $CB24
    dw $CB26
    dw $CB28
    dw $CB2A
    dw $CB2C
    dw $CB2E
    dw $CC40
    dw $CC42
    dw $CC44
    dw $CC46
    dw $CC48
    dw $CC4A
    dw $CC4C
    dw $CC4E
    dw $CD60
    dw $CD62
    dw $CD64
    dw $CD66
    dw $CD68
    dw $CD6A
    dw $CD6C
    dw $CD6E
    dw $CE80
    dw $CE82
    dw $CE84
    dw $CE86
    dw $CE88
    dw $CE8A
    dw $CE8C
    dw $CE8E
    dw $CFA0
    dw $CFA2
    dw $CFA4
    dw $CFA6
    dw $CFA8
    dw $CFAA
    dw $CFAC
    dw $CFAE
    dw $D0C0
    dw $D0C2
    dw $D0C4
    dw $D0C6
    dw $D0C8
    dw $D0CA
    dw $D0CC
    dw $D0CE
    dw $D1E0
    dw $D1E2
    dw $D1E4
    dw $D1E6
    dw $D1E8
    dw $D1EA
    dw $D1EC
    dw $D1EE
    dw $D300
    dw $D302
    dw $D304
    dw $D306
    dw $D308
    dw $D30A
    dw $D30C
    dw $D30E
    dw $D420
    dw $D422
    dw $D424
    dw $D426
    dw $D428
    dw $D42A
    dw $D42C
    dw $D42E
    dw $D540
    dw $D542
    dw $D544
    dw $D546
    dw $D548
    dw $D54A
    dw $D54C
    dw $D54E
    dw $D660
    dw $D662
    dw $D664
    dw $D666
    dw $D668
    dw $D66A
    dw $D66C
    dw $D66E
    dw $D780
    dw $D782
    dw $D784
    dw $D786
    dw $D788
    dw $D78A
    dw $D78C
    dw $D78E
    dw $D8A0
    dw $D8A2
    dw $D8A4
    dw $D8A6
    dw $D8A8
    dw $D8AA
    dw $D8AC
    dw $D8AE

SECTION "Buffer Stack Far Walls Fix",ROM0[$1325]
    ld hl, $D0C0

SECTION "Fill Buffer Stack Half 2 (Floor Fix)",ROM0[$1373]
    ld hl, $D1E0
    
SECTION "Fill Buffer Stack Half 1",ROM0[$1399]
    ld hl, $CA00

SECTION "Framebuffer Stack Clear",ROM0[$13B8]
    ld hl, $CA00

; Since were no longer using the upper part of vram
SECTION "updategameplaystuff LCDC fix", ROM0[$0808]
    nop
    nop
    
    nop
    nop

    nop
    nop

SECTION "updategameplaystuff LCDC fix 2", ROM0[$081C]
    set LCDCB_BLKS, a

; Changes starting buffer tile index from 0:8804 to 1:8004
SECTION "Framebuffer tilemap fix", ROM0[$37db]
    ld d, $04

; I ran out of ROM0 for this one, whoops
SECTION "Update Framebuffer hook",ROM0[$13F0]
UpdateFramebuffer::
    ; No idea why this must be 2, maybe it's the game state?
    ld a, [$C9A2]
    cp a, 2
    ret z
    ; Just in case, disable VBlank since it calls this
    ldh a, [rIE]
    push af
    and LOW(~IEF_VBLANK)
    ldh [rIE], a
    ldh a, [hCurBank]
    push af
    ld a, BANK(realUpdateFramebuffer)
    ldh [hCurBank], a
    ld [rROMB0], a
    call realUpdateFramebuffer
    pop af
    ldh [hCurBank], a
    ld [rROMB0], a
    pop af
    ldh [rIE], a
    ret

SECTION "ACTUAL Update framebuffer", ROMX[$4000], BANK[15]
;; Chunky GDMA renderer for Faceball 2000 DX

; Chunky GDMA code that relies on HDMA address registers being consistent and incremented between copies
; THis behaviour seems to be correct on accurate emulators and my own GBC
; Supposedly GDMA won't work if you don't reset the address regs (HDMA1-4) before firing the copy,
; But... on BGB, Sameboy, Mesen2 AND my GBC (CPU-CGB-C), it just... works?
; Still gotta do further testing
; (Looking at you AGS!)

; The lowest ceiling for the Chunky GDMA part is ~70 tiles, but since we copy the remainder HDMA tiles *while* we clear the buffer, 
; we gotta copy less HDMA tiles to finish copying HDMA tiles before the CPU can clear the whole buffer, so 74 does it
DEF COPY_SIZE       EQU 74 * $10
DEF COPYCHUNK_SIZE  EQU 32
DEF BUFFER_SRC      EQU $CA00
DEF BUFFER_TRG      EQU _VRAM8000 + $40
DEF GDMA_LEN        EQU 128
DEF SHORT_GDMA_LEN  EQU 12
realUpdateFramebuffer::
    ; First, just in case, set LCDC correctly
    ld hl, rLCDC
    set LCDCB_BLKS, [hl]

    ; Copy first chunk using GDMA (The way Nintendo intended)
    ld l, LOW(rHDMA1)
    ld a, HIGH(BUFFER_SRC)
    ld [hli], a
    ld a, LOW(BUFFER_SRC)
    ld [hli], a
    ld a, HIGH(BUFFER_TRG)
    ld [hli], a
    ld [hl], LOW(BUFFER_TRG)
    ; Set bank
    ld l, LOW(rIF)
    ld a, 1
    ld bc, ((SHORT_GDMA_LEN - 1) << 8) | LOW(rHDMA5)
    di
    ldh [rVBK], a
    ld a, GDMA_LEN - 1
    ; Now wait for vblank
    res IEB_VBLANK, [hl]
    :bit IEB_VBLANK, [hl]
    jr z, :-
    ; Trigger DMA as soon as we hit the start of Vblank, this means we don't run the risk of mode 3 creeping in
    ldh [c], a
    xor a
    ldh [rVBK], a
    ; According to pandocs, we might just have enough room for a few more tiles...?
    ld a, b
    ei
    ldh [c], a

    ; Now copy enough tiles using chunky GDMA to leave the rest to HDMA
    ld l, LOW(rHDMA5)
    ld bc, ((COPY_SIZE / COPYCHUNK_SIZE) << 8) | LOW(rSTAT)
    ld de, (LOW(%11) << 8) | LOW(~%11)
.copyLoop:
    di
    ; First, wait for MODE 3
    :ldh a, [c]
    or e
    inc a
    jr nz, :-

    ; Now for MODE 0
    :ldh a, [c]
    and d
    jr nz, :-

    ; Spit out chunked part
    ei
    ld [hl], HDMA5F_MODE_GP | ((COPYCHUNK_SIZE >> 4) - 1)
    dec b
    jr nz, .copyLoop

    ; Copy the remaining tiles using simple HDMA
    ld l, LOW(rHDMA5)
    di
    ; ...Just in case, make sure we don't start on mode 0
    :ldh a, [rSTAT]
    and STATF_LCD
    jr z, :-
    ei
    ld [hl], ((252 - (GDMA_LEN + SHORT_GDMA_LEN + (COPY_SIZE >> 4))) - 1) | HDMA5F_MODE_HBL

    ; Now time to clean that buffer
    ld hl, BUFFER_SRC
    ld c, 252 / 4
    xor a
.clearLoop:
REPT 64
    ld [hli], a
ENDR
    dec c
    jr nz, .clearLoop
    ret