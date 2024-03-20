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

SECTION "Update Framebuffer",ROM0[$13F0]
UpdateFramebuffer::
    ld a, [$C9A2]
    cp a, 2
    ret z
    ld [$C95D], sp
    ld hl, _VRAM8800 + $40
    di
    ld sp, $CA00
    ld b, 2
;.stat_check_1
    ;ldh a, [rSTAT]
    ;and a, 2
    ;jr z, .stat_check_1
;.stat_check_2
    ;ldh a, [rSTAT]
    ;and a, 2
    ;jr z, .stat_check_2
.prepare_transfer
    ld a, h
    ldh [rHDMA3], a
    ld a, l
    ldh [rHDMA4], a
    ld hl, sp + 0
    ld a, h
    ldh [rHDMA1], a
    ld a, l
    ldh [rHDMA2], a
.check_ly
    ldh a, [rLY]
    sub a, $78
    jr c, .set_tilespace_to_display
.set_tilespace_to_hud
    ldh a, [rLCDC]
    set 4, a
    ldh [rLCDC], a
    jr .check_if_vblank
.set_tilespace_to_display
    ldh a, [rLCDC]
    res 4, a
    ldh [rLCDC], a
.check_if_vblank
    ldh a, [rSTAT]
    and a, 3
    cp 1
    jr nz, .check_ly
.init_transfer
    ld a, $7D
    ldh [rHDMA5], a
    ;ld sp, $C9A1
    ;ei
;.do_stat_check_for_buffer
    ;ldh a, [rSTAT]
    ;and a, 2
    ;jr z, .do_stat_check_for_buffer
    ;di
.check_if_buffer_fill_done
    dec b
    jr z, .done_filling_buffer
    ld sp, $D1E0
    ld hl, _VRAM9000 + $20
    jr .prepare_transfer
.done_filling_buffer
    ld sp, $D9C2
    call $13B8
    ld a, [$C95D]
    ld l, a
    ld a, [$C95E]
    ld h, a
    ld sp, hl
    ei
    ret
