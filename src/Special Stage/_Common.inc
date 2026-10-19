; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Common special stage definitions
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Graphics chip
; -------------------------------------------------------------------------

TRACETBL	EQU	$1C800			; Trace table
IMGBUFFER	EQU	$1D000			; Image buffer
STAMPMAP	EQU	$20000			; Stamp map

IMGWIDTH	EQU	256			; Image buffer width
IMGHEIGHT	EQU	96			; Image buffer height
IMGWTILE	EQU	IMGWIDTH/8		; Image buffer width in tiles
IMGHTILE	EQU	IMGHEIGHT/8		; Image buffer height in tiles

IMGLENGTH	EQU	IMGWTILE*IMGHTILE*$20	; Image buffer length in bytes

; -------------------------------------------------------------------------
; Communication
; -------------------------------------------------------------------------

ctrlData	EQU	GACOMCMDE		; Controller data
ctrlHold	EQU	ctrlData		; Controller held buttons data
ctrlTap		EQU	ctrlData+1		; Controller tapped buttons data
ufoCount	EQU	GACOMSTATB		; UFO count

; -------------------------------------------------------------------------
; Word RAM
; -------------------------------------------------------------------------

	if def(SSMDPORT)
STAMPRAM	EQU	$00FF0000			; Stamp map (RAM, 32KB)
	rsset	RAM_SUBBUF			; (SSVARS and the rest of the RAM map: "MD Port/RAM Map.inc")
	else
STAMPRAM	EQU	WORDRAM2M+STAMPMAP
	rsset	WORDRAM2M+$1C000
	endif
subSprites	rs.b	$280			; Sprite buffer
subSndQueue1	rs.b	1			; FM sound queue 1
subSndQueue2	rs.b	1			; FM sound queue 2
subSndQueue3	rs.b	1			; FM sound queue 3
		rs.b	1
subSplashLoad	rs.b	1			; Splash art load flag
subScrollFlags	rs.b	1			; Scroll flags
		rs.b	$7A
subSonicArtBuf	rs.b	$300			; Sonic art buffer
	if def(SSMDPORT)
SUBBUFEND	rs.b	0
	endif

; -------------------------------------------------------------------------
