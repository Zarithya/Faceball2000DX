INCLUDE "inc/hardware.inc"
INCLUDE "inc/ram.inc"

SECTION "Receive Serial Data",ROM0[$0EC7]
jr_000_0ec7:
    bit 1, c
    jp nz, Jump_000_0f28

    swap a
    and $0f
    ld e, a
    ld d, $00
    ld hl, $0d3c
    add hl, de
    ld a, [hl]
    ld [$c908], a
    ld a, b
    and $f0
    cp $10
    jr nz, jr_000_0efb

; recv'd byte begins with 0x1X
    bit 3, c ; is primary?
    jr z, jr_000_0eef

; system is primary
    ld a, b
    and $0f
    inc a ; FIX: increment recv'd player count before storing
    ld [wPlayerCount], a
    jp nz, Jump_000_0f4c

; system is secondary
jr_000_0eef:
    inc b ; FIX: increment recv'd player number before storing
    ld a, b
    and $0f
    ldh [hPlayerNum], a
    ;inc b ; FIX: moved up to use for current player number as well
    ld a, b
    ldh [rSB], a ; send to next system
    jp $0fb5


jr_000_0efb:
    cp $20
    jr nz, jr_000_0f10

; recvd byte begins with 0x2X
    bit 3, c ; is primary?
    jp nz, Jump_000_0f4c

; system is secondary
    ld a, b
    and $0f
    inc a ; FIX: increment recv'd player count before storing
    ld [wPlayerCount], a
    ld a, b
    ldh [rSB], a ; send to next system
    jp $0fb5


jr_000_0f10:
    cp $00
    jp z, $0f79

; recvd byte does not begin with 0x0X
    bit 2, c
    jr nz, jr_000_0f28

; is this our own sent 0x3X byte?
    ldh a, [hPlayerNum]
    or $30
    cp b
    jr nz, jr_000_0f28

; yes, this is ours. send next byte (?)
    set 2, c
    ld a, [$c909]
    ld [$c90a], a

Jump_000_0f28:
jr_000_0f28:
    set 1, c
    ld hl, $c908
    dec [hl]
    jr nz, jr_000_0f32

    res 1, c

jr_000_0f32:
    ld a, [$c957]
    ld l, a
    ld h, $c0
    ld a, b
    ld [hli], a
    ld a, l
    ld [$c957], a
    bit 2, c
    jr z, $0f6d

    ld hl, $c90a
    dec [hl]
    jr nz, $0f79

    ld hl, $c90b
    inc [hl]

Jump_000_0f4c:
    res 0, c
    res 1, c
    res 2, c
    ldh a, [hPlayerNum]
    ;or a, $00 ; FIX: removed no-op to allow extra instructions above
    ldh [rSB], a

SECTION "Send Serial Data",ROM0[$104F]
jr_000_104f:
    di
    ldh a, [$ff91]
    set 3, a
    ldh [$ff91], a
    ei
    xor a
    ldh [hPlayerNum], a
    ld a, $10 ; start with 0th player (this device)
    nop ; FIX: was or $01, replaced with nop to allow inserting dec a later
    ldh [rSB], a ; send to next device in chain
    di
    ldh a, [$ff91]
    set 0, a
    ldh [$ff91], a
    ei
    ld a, $81
    ldh [rSC], a
    ld b, $14

jr_000_106e:
    push bc
    ld bc, $0001
    call $09f1
    pop bc
    ldh a, [$ff91]
    bit 0, a
    jr z, jr_000_1092

    dec b
    jr nz, jr_000_106e

    ld a, $00
    ldh [rSC], a
    ld a, 1
    ld [wPlayerCount], a
    ldh a, [$ff91]
    res 0, a
    res 4, a
    ldh [$ff91], a
    jr $1024

jr_000_1092:
    ld a, [wPlayerCount]
    dec a ; FIX: decrease player number before sending commands
    and $0f
    or $20
    ldh [rSB], a

IF DEF(_FIX16_FULL)
SECTION "Arena List Hook",ROM0[$26F1]
    ld c, a
    ld a, $03
    di
    ldh [hNewBank], a
    ldh a, [hCurBank]
    push af
    ldh a, [hNewBank]
    ldh [hCurBank], a
    ld [rROMB0 + $100], a
    ei
    call SwapArenaListsForPlayerCounts
    ld b, $00
    sla c
    rl b
    add hl, bc

SECTION "Main Menu Actions Hook",ROMX[$5F3C],BANK[1]
MainMenuActions:
    db $f0
    dw $5f6b ; draw function

    db $f1 ; new menu option
    db 1, 2 ; cursor X, cursor Y
    dw 0 ; controls box text
    db $01 ; action button
    dw StartCyberscapeFromMainMenuHook ; action function
    db $08 ; action button
    dw StartCyberscapeFromMainMenuHook ; action function

    db $f1
    db 1, 4
    dw 0
    db $01
    dw $5d2d
    db $08
    dw $5d2d

    db $f1
    db 1, 9
    dw 0
    db $01
    dw $635e
    db $08
    dw $635e

    db $f2 ; common actions
    db $40
    dw $5d62
    db $80
    dw $5d66
    db $04
    dw $5d6a

    db $f3 ; end of actions

SECTION "Draw Main Menu Hook",ROMX[$5F71],BANK[1]
    call DrawMainMenuHook

SECTION "Choose Arena Select Button",ROMX[$6DD2],BANK[1]
ChooseArena_SelectButton:
    ld a, [wMenuItemCount]
    ld b, a
    ld a, [wCurMap]
    inc a
    cp b
    jr c, .nooverflow
    xor a

.nooverflow
    ld [wCurMap], a
    jp $5d6e

SECTION "Choose Arena Actions Hook",ROMX[$6D9A],BANK[1]
ChooseArenaActions:
    db $f0
    dw $6db7 ; draw function

    db $f2 ; common actions
    db $40 ; d-pad up
    dw ChooseArena_UpRightButtons
    db $80 ; d-pad down
    dw $6dee
    db $10 ; d-pad right
    dw ChooseArena_UpRightButtons
    db $20 ; d-pad left
    dw $6dee
    db $04 ; select
    dw ChooseArena_SelectButton
    db $01 ; a
    dw $6dfa
    db $02 ; b
    dw $6dff
    db $08 ; start
    dw $6dfa

    db $f3 ; end of actions

SECTION "Bank 1 New Routines",ROMX[$7FB0],BANK[1]
ChooseArena_UpRightButtons:
    ld a, [wMenuItemCount]
    ld b, a
    ld a, [wCurMap]
    inc a
    cp b
    ret nc
    ld [wCurMap], a
    jp $5d6e

StartCyberscapeFromMainMenuHook:
    ldh a, [hPlayerCount]
    cp 5 ; check for >4 players
    ret nc
    jp $5d47

DrawMainMenuHook:
    ldh a, [hPlayerCount]
    cp 5 ; check for >4 players
    jr nc, .disablecyberscape
    ld hl, $5ee1
    ret

.disablecyberscape
    ld hl, MainMenuTextCyberscapeDisabled
    ret

MainMenuTextCyberscapeDisabled:
    dw $5ee8 ; next text def
    dw $5d93 ; string
    db 3 ; text mode
    db 2, 2 ; x, y

SECTION "Substitute Arena Lists For Player Counts",ROMX[$7D80],BANK[3]
SwapArenaListsForPlayerCounts:
    ld hl, $4000 ; default arena list
    ld a, 14 ; are we loading Cyberscape map?
    cp c
    ret c ; use default list
    ld b, 15 ; 15 maps in default list
    ldh a, [hPlayerCount]
    cp 5 ; use default list for <=4 players
    jr c, .end
    ld hl, Arenas12Players
    ld b, 13 ; 13 maps in <=12 player list
    cp 13
    jr c, .end
    ld hl, Arenas16Players
    ld b, 10 ; 10 maps in <=16 player list

.end
    ld a, b
    ld [wMenuItemCount], a
    ret

Arenas16Players:
    dw $722f, $725b, $7288, $72b5, $72e3, $730e, $7349, $7386, $73d0, $73f8

Arenas12Players:
    dw $719b, $71ea, $720e, $722f, $725b, $7288, $72b5, $72e3, $730e, $7349, $7386, $73d0, $73f8
ENDC
