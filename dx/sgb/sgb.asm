DEF LCDC_DEFAULT         EQU (1 << LCDCB_ON) | (1 << LCDCB_BGON)

INCLUDE "gfx/sgb_layouts.asm"
INCLUDE "gfx/sgb/blk_packets.asm"
INCLUDE "gfx/sgb/pal_packets.asm"
INCLUDE "dx/sgb/sgb_ctrl_packets.asm"

PredefPals:
	table_width PALETTE_SIZE, PredefPals
INCLUDE "gfx/sgb/predef.pal"
	assert_table_length NUM_PREDEF_PALS

SGBBorderMapAndPalettes:
; interleaved tile ids and palette ids, without the center 20x18 screen area
INCBIN "gfx/sgb/sgb_border.sgb.tilemap"
; four SGB palettes of 16 colors each; only the first 4 colors are used
INCLUDE "gfx/sgb/sgb_border.pal"

SGBBorderGFX:
INCBIN "gfx/sgb/sgb_border.4bpp"

CheckSGB:
	ld hl, MltReq2Packet
	call _PushSGBPacket
	call SGBDelayCycles
	call SGBDelayCycles
	ldh a, [rP1]
	and $3
	cp $3
	jr nz, .carry
	ld a, $20
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	call SGBDelayCycles
	call SGBDelayCycles
	ld a, $30
	ldh [rP1], a
	call SGBDelayCycles
	call SGBDelayCycles
	ld a, $10
	ldh [rP1], a
rept 6
	ldh a, [rP1]
endr
	call SGBDelayCycles
	call SGBDelayCycles
	ld a, $30
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	call SGBDelayCycles
	call SGBDelayCycles
	ldh a, [rP1]
	and $3
	cp $3
	jr nz, .carry
	call .FinalPush
	and a
	ret

.carry
	call .FinalPush
	scf
	ret

.FinalPush:
	ld hl, MltReq1Packet
	call _PushSGBPacket
	call SGBDelayCycles
	jp SGBDelayCycles

SGBBorder_PushBGPals:
	call DisableLCD
	ld a, %11100100
	ldh [rBGP], a
	ld hl, PredefPals
	ld de, _VRAM8800
	ld bc, $100 tiles
	call CopyData
	call DrawDefaultTiles
	ld a, LCDC_DEFAULT
	ldh [rLCDC], a
	ld hl, PalTrnPacket
	call PushSGBPacket
	call SGBDelayCycles
	xor a
	ldh [rBGP], a
	ret

DisableLCD::
; Turn the LCD off

; Don't need to do anything if the LCD is already off
	ldh a, [rLCDC]
	bit LCDCB_ON, a
	ret z

	xor a
	ldh [rIF], a
	ldh a, [rIE]
	ld b, a

; Disable VBlank
	res IEB_VBLANK, a
	ldh [rIE], a

.wait
; Wait until VBlank would normally happen
	ldh a, [rLY]
	cp SCRN_Y + 1
	jr nz, .wait

	ldh a, [rLCDC]
	and ~(1 << LCDCB_ON)
	ldh [rLCDC], a

	xor a
	ldh [rIF], a
	ld a, b
	ldh [rIE], a
	ret

EnableLCD::
	ldh a, [rLCDC]
	set LCDCB_ON, a
	ldh [rLCDC], a
	ret

DrawDefaultTiles:
; Draw 240 tiles (2/3 of the screen) from tiles in VRAM
	hlbgcoord 0, 0 ; BG Map 0
	ld de, BG_MAP_WIDTH - SCREEN_WIDTH
	ld a, $80 ; starting tile
	ld c, 12 + 1
.line
	ld b, 20
.tile
	ld [hli], a
	inc a
	dec b
	jr nz, .tile
; next line
	add hl, de
	dec c
	jr nz, .line
	ret

CopyData:
; copy bc bytes of data from hl to de
.loop
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, c
	or b
	jr nz, .loop
	ret

ClearBytes:
; clear bc bytes of data starting from de
.loop
	xor a
	ld [de], a
	inc de
	dec bc
	ld a, c
	or b
	jr nz, .loop
	ret

ByteFill::
; fill bc bytes with the value of a, starting at hl
	inc b ; we bail the moment b hits 0, so include the last run
	inc c ; same thing; include last byte
	jr .HandleLoop
.PutByte:
	ld [hli], a
.HandleLoop:
	dec c
	jr nz, .PutByte
	dec b
	jr nz, .PutByte
	ret

CheckAndInitSGB:
	di
	ld a, $1
	ld [hDisableInputs], a
	xor a
	ldh [rP1], a
	call CheckSGB
	jr nc, .skip
	ld a, IS_SGB
	ldh [hCGB], a
	call PushSNESCodeToSGB
	call SGBBorder_PushBGPals
	call SGBDelayCycles
	call SGB_ClearVRAM
	call PushSGBBorder
	call SGBDelayCycles
	call SGB_ClearVRAM
	ld hl, MaskEnCancelPacket
	call PushSGBPacket
	call SGBDelayCycles
.skip
	xor a
	ld [hDisableInputs], a
	reti

PushSGBBorder:
	ld hl, SGBBorderGFX
	call SGBBorder_PushTiles
	ld hl, SGBBorderMapAndPalettes
	call SGBBorder_PushMapAndPal
	ret

SGBBorder_PushMapAndPal:
	call DisableLCD
	ld a, $e4
	ldh [rBGP], a
	ld de, _VRAM8800
	ld bc, (6 + SCREEN_WIDTH + 6) * 5 * 2
	call CopyData
	ld b, SCREEN_HEIGHT
.loop
	push bc
	ld bc, 6 * 2
	call CopyData
	ld bc, SCREEN_WIDTH * 2
	call ClearBytes
	ld bc, 6 * 2
	call CopyData
	pop bc
	dec b
	jr nz, .loop
	ld bc, (6 + SCREEN_WIDTH + 6) * 5 * 2
	call CopyData
	ld bc, $100
	call ClearBytes
	ld bc, 16 palettes
	call CopyData
	call DrawDefaultTiles
	ld a, LCDC_DEFAULT
	ldh [rLCDC], a
	ld hl, PctTrnPacket
	call PushSGBPacket
	call SGBDelayCycles
	xor a
	ldh [rBGP], a
	ret

SGBBorder_PushTiles:
	call DisableLCD
	ld a, %11100100
	ldh [rBGP], a
	push hl
	ld de, _VRAM8800
	ld bc, $80 tiles * 2
	call CopyData
	call DrawDefaultTiles
	ld a, LCDC_DEFAULT
	ldh [rLCDC], a
	ld hl, ChrTrn1Packet
	call PushSGBPacket
	call SGBDelayCycles
	call DisableLCD
	pop hl
	ld de, _VRAM8800
	ld bc, $80 tiles * 2
	add hl, bc
	call CopyData
	call DrawDefaultTiles
	ld a, LCDC_DEFAULT
	ldh [rLCDC], a
	ld hl, ChrTrn2Packet
	call PushSGBPacket
	call SGBDelayCycles
	xor a
	ldh [rBGP], a
	ret

SGB_ClearVRAM:
    call DisableLCD
	ld hl, _VRAM
	ld bc, _SRAM - _VRAM
	xor a
	call ByteFill
	ret

PushSNESCodeToSGB:
	ld hl, .PacketPointerTable
	ld c, 9
.loop
	push bc
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	call PushSGBPacket
	call SGBDelayCycles
	pop hl
	inc hl
	pop bc
	dec c
	jr nz, .loop
	ret

.PacketPointerTable:
	dw MaskEnFreezePacket
	dw DataSndPacket1
	dw DataSndPacket2
	dw DataSndPacket3
	dw DataSndPacket4
	dw DataSndPacket5
	dw DataSndPacket6
	dw DataSndPacket7
	dw DataSndPacket8

PushSGBPacket:
	ld a, $1
	ld [hDisableInputs], a
	call _PushSGBPacket
	xor a
	ld [hDisableInputs], a
	ret

_PushSGBPacket:
	ld a, [hl]
	and $7
	ret z
	ld b, a
.loop
	push bc
	xor a
	ldh [rP1], a
	ld a, $30
	ldh [rP1], a
	ld b, $10
.loop2
	ld e, $8
	ld a, [hli]
	ld d, a
.loop3
	bit 0, d
	ld a, $10
	jr nz, .okay
	ld a, $20
.okay
	ldh [rP1], a
	ld a, $30
	ldh [rP1], a
	rr d
	dec e
	jr nz, .loop3
	dec b
	jr nz, .loop2
	ld a, $20
	ldh [rP1], a
	ld a, $30
	ldh [rP1], a
	pop bc
	dec b
	ret z
	call SGBDelayCycles
	jr .loop

SGBDelayCycles:
	ld de, 7000
.wait
	nop
	nop
	nop
	dec de
	ld a, d
	or e
	jr nz, .wait
	ret
