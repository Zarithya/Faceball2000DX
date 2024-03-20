; CGBLayoutJumptable indexes (see engine/gfx/cgb_layouts.asm)
; SGBLayoutJumptable indexes (see engine/gfx/sgb_layouts.asm)
	const_def
	const SCGB_DEFAULT
	const SCGB_BPS_LOGO
	const SCGB_COPYRIGHT
	const SCGB_TITLE
	const SCGB_INTERFACE
	const SCGB_TEAMPLAY
	const SCGB_GAMEPLAY
	const SCGB_ENDING_SMILOIDS
	const SCGB_CREDITS
DEF NUM_SCGB_LAYOUTS EQU const_value

; PredefPals indexes (see gfx/sgb/predef.pal)
; GetPredefPal arguments (see engine/gfx/color.asm)
	const_def
	const PREDEFPAL_BPS_WORDMARK
	const PREDEFPAL_BPS_LOGO
	const PREDEFPAL_GAMEPLAY
	const PREDEFPAL_GAMEPLAY_FADE1
	const PREDEFPAL_GAMEPLAY_FADE2
	const PREDEFPAL_INTERFACE
	const PREDEFPAL_INTERFACE_FADE1
	const PREDEFPAL_INTERFACE_FADE2
	const PREDEFPAL_TITLE
	const PREDEFPAL_TITLE_FADE1
	const PREDEFPAL_TITLE_FADE2
	const PREDEFPAL_HUD_BORDER
	const PREDEFPAL_HUD_BORDER_FADE1
	const PREDEFPAL_HUD_BORDER_FADE2
	const PREDEFPAL_HUD_TEXT
	const PREDEFPAL_HUD_TEXT_FADE1
	const PREDEFPAL_HUD_TEXT_FADE2
	const PREDEFPAL_WHITE
DEF NUM_PREDEF_PALS EQU const_value

; SGB system command codes
; http://gbdev.gg8.se/wiki/articles/SGB_Functions#SGB_System_Command_Table
	const_def
	const SGB_PAL01
	const SGB_PAL23
	const SGB_PAL03
	const SGB_PAL12
	const SGB_ATTR_BLK
	const SGB_ATTR_LIN
	const SGB_ATTR_DIV
	const SGB_ATTR_CHR
	const SGB_SOUND
	const SGB_SOU_TRN
	const SGB_PAL_SET
	const SGB_PAL_TRN
	const SGB_ATRC_EN
	const SGB_TEST_EN
	const SGB_ICON_EN
	const SGB_DATA_SND
	const SGB_DATA_TRN
	const SGB_MLT_REQ
	const SGB_JUMP
	const SGB_CHR_TRN
	const SGB_PCT_TRN
	const SGB_ATTR_TRN
	const SGB_ATTR_SET
	const SGB_MASK_EN
	const SGB_OBJ_TRN
