GetSGBLayout:
;	call CheckCGB
;	jp nz, GetSGBLayoutCGB

	ld l, a
	ld h, 0
	add hl, hl
	ld de, SGBLayoutJumptable
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [wFadeLevel]
	rla
	rla
	rla
	rla
	ld e, a
	xor a
	ld d, a
	jp hl

SGBLayoutJumptable:
	table_width 2, SGBLayoutJumptable
	dw .SGB_Default
	dw .SGB_BPSLogo
	dw .SGB_Copyright
	dw .SGB_TitleScreen
	dw .SGB_InterFace
	dw .SGB_Teamplay
	dw .SGB_Gameplay
	dw .SGB_EndingSmiloids
	dw .SGB_Credits
	assert_table_length NUM_SCGB_LAYOUTS

.SGB_Default:
	ld hl, PalPacket_Default
	ld de, BlkPacket_BPSLogo
	ret

.SGB_BPSLogo:
	ld hl, PalPacket_BPSLogo
	ld de, BlkPacket_BPSLogo
	ret

.SGB_Copyright:
	ld hl, PalPacket_Copyright
	add hl, de
	ld de, BlkPacket_Copyright
	ret

.SGB_TitleScreen:
	ld hl, PalPacket_TitleScreen
	add hl, de
	ld de, BlkPacket_TitleScreen
	ret

.SGB_InterFace:
	ld hl, PalPacket_InterFace
	add hl, de
	ld de, BlkPacket_InterFace
	ret

.SGB_Teamplay:
	ld hl, PalPacket_Teamplay
	add hl, de
	ld de, BlkPacket_Teamplay
	ret

.SGB_Gameplay:
	ld hl, PalPacket_Gameplay
	add hl, de
	ld de, BlkPacket_Gameplay
	ret

.SGB_EndingSmiloids:
	ld hl, PalPacket_EndingSmiloids
	add hl, de
	ld de, BlkPacket_EndingSmiloids
	ret

.SGB_Credits:
	ld hl, PalPacket_Credits
	add hl, de
	ld de, BlkPacket_Credits
	ret
