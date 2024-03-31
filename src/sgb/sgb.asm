DEF LCDC_DEFAULT_SGB 	EQU (1 << LCDCB_ON) | (1 << LCDCB_BGON)

INCLUDE "src/sgb/layouts.asm"
INCLUDE "src/sgb/blk_packets.asm"
INCLUDE "src/sgb/pal_packets.asm"
INCLUDE "src/sgb/ctrl_packets.asm"

PredefPals:
	table_width PALETTE_SIZE, PredefPals
INCLUDE "gfx/sgb/predef.pal"
	assert_table_length NUM_PREDEF_PALS

SGBBorderGFX:
; 4 bits per pixel image, in SNES format
INCBIN "gfx/sgb/sgb_border.4bpp"

SGBBorderMapAndPalettes:
; interleaved tile ids and palette ids, without the center 20x18 screen area
INCBIN "gfx/sgb/sgb_border.sgb.tilemap"
; four SGB palettes of 16 colors each; only the first palette is used
INCLUDE "gfx/sgb/sgb_border.pal"

SGB_CheckIsSGB:
; Request SGB 2 player compatibility, carry set if on SGB
	ld hl, MltReq2Packet
	call _SGB_PushPacket
	call SGB_Delay
	call SGB_Delay
	ldh a, [rP1]
	and $3
	cp $3
	jr nz, .carry
	ld a, $20
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	call SGB_Delay
	call SGB_Delay
	ld a, $30
	ldh [rP1], a
	call SGB_Delay
	call SGB_Delay
	ld a, $10
	ldh [rP1], a
rept 6
	ldh a, [rP1]
endr
	call SGB_Delay
	call SGB_Delay
	ld a, $30
	ldh [rP1], a
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	call SGB_Delay
	call SGB_Delay
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
; reset SGB to single player
	ld hl, MltReq1Packet
	call _SGB_PushPacket
	call SGB_Delay
	jp SGB_Delay

SGB_PushPredefPals:
; Push predefined SGB palettes using VRAM transfer
	call DisableLCD
	ld a, %11100100
	ldh [rBGP], a
	ld hl, PredefPals
	ld de, _VRAM8800
	ld bc, $100 tiles
	call CopyData
	call SGB_DrawTilemapForVRAMTransfer
	ld a, LCDC_DEFAULT_SGB
	ldh [rLCDC], a
	ld hl, PalTrnPacket
	call SGB_PushPacket
	call SGB_Delay
	xor a
	ldh [rBGP], a
	ret

SGB_DrawTilemapForVRAMTransfer:
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

SGB_Init:
	di
	ld a, $1
	ld [hDisableInputs], a
	xor a
	ldh [rP1], a
	call SGB_CheckIsSGB
	jr nc, .skip
	ld a, IS_SGB
	ldh [hCGB], a
	call SGB_PushDefaultSNESCode
	call SGB_PushPredefPals
	call SGB_Delay
	call SGB_ClearVRAM
	call SGB_PushBorder
	call SGB_Delay
	call SGB_ClearVRAM
	ld hl, MaskEnCancelPacket
	call SGB_PushPacket
	call SGB_Delay
.skip
	xor a
	ld [hDisableInputs], a
	reti

SGB_PushBorder:
	ld hl, SGBBorderGFX
	call SGBBorder_PushTiles
	ld hl, SGBBorderMapAndPalettes
	call SGBBorder_PushMapAndPal
	ret

SGBBorder_PushMapAndPal:
; Push SGB border tilemap and palettes using VRAM transfer
	call DisableLCD
	ld a, %11100100
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
	call SGB_DrawTilemapForVRAMTransfer
	ld a, LCDC_DEFAULT_SGB
	ldh [rLCDC], a
	ld hl, PctTrnPacket
	call SGB_PushPacket
	call SGB_Delay
	xor a
	ldh [rBGP], a
	ret

SGBBorder_PushTiles:
; Push SGB border tiles using two VRAM transfers
	call DisableLCD
	ld a, %11100100
	ldh [rBGP], a
	push hl
	ld de, _VRAM8800
	ld bc, $80 tiles * 2
	call CopyData
	call SGB_DrawTilemapForVRAMTransfer
	ld a, LCDC_DEFAULT_SGB
	ldh [rLCDC], a
	ld hl, ChrTrn1Packet
	call SGB_PushPacket
	call SGB_Delay

; second transfer
	call DisableLCD
	pop hl
	ld de, _VRAM8800
	ld bc, $80 tiles * 2
	add hl, bc
	call CopyData
	call SGB_DrawTilemapForVRAMTransfer
	ld a, LCDC_DEFAULT_SGB
	ldh [rLCDC], a
	ld hl, ChrTrn2Packet
	call SGB_PushPacket
	call SGB_Delay

	xor a
	ldh [rBGP], a
	ret

SGB_ClearVRAM:
    call DisableLCD
	ld de, _VRAM
	ld bc, _SRAM - _VRAM
	call ClearBytes
	ret

SGB_PushDefaultSNESCode:
	ld hl, .PacketPointerTable
	ld c, 9
.loop
	push bc
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	call SGB_PushPacket
	call SGB_Delay
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

SGB_PushPacket:
	ld a, $1
	ld [hDisableInputs], a
	call _SGB_PushPacket
	xor a
	ld [hDisableInputs], a
	ret

_SGB_PushPacket:
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
	call SGB_Delay
	jr .loop

SGB_Delay:
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
