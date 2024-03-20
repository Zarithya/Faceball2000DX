; macros taken from pokered's data/sgb_packets.asm
; names taken from pandocs
; http://gbdev.gg8.se/wiki/articles/SGB_Functions#SGB_Palette_Commands

MACRO attr_blk
	db (SGB_ATTR_BLK << 3) + ((\1 * 6) / 16 + 1)
	db \1
ENDM

MACRO attr_blk_data
	db \1 ; which regions are affected
	db \2 + (\3 << 2) + (\4 << 4) ; palette for each region
	db \5, \6, \7, \8 ; x1, y1, x2, y2
ENDM

BlkPacket_BPSLogo:
	attr_blk 2
	attr_blk_data %111, 0,0,1, 00,00, 19,05
	attr_blk_data %010, 0,0,0, 00,06, 04,06
	ds 2, 0

BlkPacket_Copyright:
	attr_blk 1
	attr_blk_data %110, 0,0,0, 00,00, 19,17
	ds 8, 0

BlkPacket_TitleScreen:
	attr_blk 1
	attr_blk_data %111, 0,2,1, 00,00, 19,15
	ds 8, 0

BlkPacket_InterFace:
	attr_blk 1
	attr_blk_data %111, 0,2,1, 00,00, 19,15
	ds 8, 0

BlkPacket_Teamplay:
	attr_blk 1
	attr_blk_data %111, 1,1,0, 11,01, 19,02
	ds 8, 0

BlkPacket_Gameplay:
	attr_blk 3
	attr_blk_data %111, 0,2,1, 00,00, 19,15
	attr_blk_data %010, 0,2,1, 15,15, 19,17
	attr_blk_data %001, 1,1,0, 16,15, 18,17
	ds 12, 0

BlkPacket_EndingSmiloids:
	attr_blk 1
	attr_blk_data %001, 0,0,0, 01,01, 18,14
	ds 8, 0

BlkPacket_Credits:
	attr_blk 1
	attr_blk_data %001, 0,0,0, 01,01, 18,14
	ds 8, 0
