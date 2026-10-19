; -------------------------------------------------------------------------
; Sonic CD Disassembly - Mega Drive port
; -------------------------------------------------------------------------
; Work RAM map for the special stage (single source of truth)
; -------------------------------------------------------------------------
; Every region is placed right after the previous one using a RESERVED size
; (RSV_*). The real sizes are only known once the program files have been
; assembled, so "RAM Check.inc" (included at the very end) verifies that each
; region still fits in its reservation. Nothing else should hardcode a RAM
; address: if a region grows, the build stops with a message instead of two
; regions silently overlapping.
;
; Everything from $FFFF8000 up can be reached with absolute SHORT addressing
; (".w"), which the original code relies on, so keep new variables there.
;
;   $FF0000-$FF7FFF      Stamp map (32KB, fixed; collision code reads it)
;   $FFFF8000-$FFFFFEFF  everything below, in order
;   $FFFFFF00-$FFFFFFFF  survives restarts (magic word + stage ID, see
;                        SSNextStage); the stack grows down from here
; -------------------------------------------------------------------------

; Floor image buffer: 256x96 dots at 4bpp = $3000 bytes (IMGLENGTH), stored as
; 32 columns of tiles ($180 bytes each). It is rendered and DMA'd in
; FLOORBANDS bands of 32/FLOORBANDS tile columns (8 columns = $C00 bytes when
; 4). A band is contiguous in the image, so each one is a single DMA. It must
; divide 32. 1 would keep the whole buffer in RAM, which does NOT fit.
; Two band buffers are kept (FLOORBUFS) so the sampler can render the next band
; while the previous one waits for its DMA.
FLOORBANDS	EQU	4
IMGBYTES	EQU	$3000
FLOORBANDCOLS	EQU	32/FLOORBANDS			; Tile columns per band
FLOORBANDLEN	EQU	IMGBYTES/FLOORBANDS		; Bytes per band
FLOORBUFS	EQU	2				; Band buffers in RAM (ping-pong)
FLOORSLICEROWS	EQU	2				; Sample rows rendered per slice (one slice per VSync wait iteration)

; Sampler resolution: dots covered by one sample horizontally (2 or 4).
; Vertically a sample is always 2 rows. 2 = h2v2 (6144 samples), 4 = h4v2 (3072)
FLOORHDIV	EQU	4
FLOORSPT	EQU	8/FLOORHDIV			; Samples per tile column
FLOORSPR	EQU	FLOORBANDCOLS*FLOORSPT		; Samples per row in one band

	if ((32/FLOORBANDS)*FLOORBANDS)<>32
		inform	3,"RAM map: FLOORBANDS must divide the 32 tile columns evenly (1, 2, 4, 8, 16 or 32)"
	endif
	if (FLOORHDIV<>2)&(FLOORHDIV<>4)
		inform	3,"Floor sampler: FLOORHDIV must be 2 or 4"
	endif

RSV_STACK	EQU	$800				; Minimum room kept for the stack

; Region                   address             reserved size
RAM_GA		EQU	$FFFF8000			; "Gate array" comm block (plain RAM)
RSV_GA		EQU	$40
RAM_SUBVARS	EQU	RAM_GA+RSV_GA			; Object/logic variables (Sub.asm: VARSLEN)
RSV_SUBVARS	EQU	$2500				;   actual $2462
RAM_SUBBUF	EQU	RAM_SUBVARS+RSV_SUBVARS		; Sprites/Sonic art handed to the display ("_Common.inc")
RSV_SUBBUF	EQU	$600				;   actual $600
RAM_TRACETBL	EQU	RAM_SUBBUF+RSV_SUBBUF		; Floor trace table, 96 rows * 8 bytes (TRACETBLMD)
RSV_TRACETBL	EQU	$300
RAM_FLOORVARS	EQU	RAM_TRACETBL+RSV_TRACETBL	; Floor sampler variables (Main.asm)
RSV_FLOORVARS	EQU	$40				;   actual $10
RAM_IMGBAND	EQU	RAM_FLOORVARS+RSV_FLOORVARS	; FLOORBUFS floor image bands (stageImage)
RSV_IMGBAND	EQU	FLOORBUFS*FLOORBANDLEN
RAM_MAINVARS2	EQU	RAM_IMGBAND+RSV_IMGBAND		; Display program variables (Main.asm)
RSV_MAINVARS2	EQU	$1C00				;   actual $1B04
RAM_MAINVARS	EQU	RAM_MAINVARS2+RSV_MAINVARS2	; IPX-style globals (Main CPU Variables.inc)
RSV_MAINVARS	EQU	$1200				;   actual $1100
RAM_RWDATA	EQU	RAM_MAINVARS+RSV_MAINVARS	; Writable data that used to live in the Main CPU image
RSV_RWDATA	EQU	$40				;   actual $35 (see SSRWDATAUSED)
RAM_END		EQU	RAM_RWDATA+RSV_RWDATA

SSRWDATAUSED	EQU	$35				; Bytes used in RAM_RWDATA (update if variables are added)
SSPERSIST	EQU	$FFFFFF00			; Survives restarts: magic word + stage ID

	if (RAM_END+RSV_STACK)>SSPERSIST
		inform	3,"RAM map: the regions plus the minimum stack do not fit below SSPERSIST (try more FLOORBANDS)"
	endif

; Names the rest of the code uses
SSVARS		EQU	RAM_SUBVARS
SSMAINVARS2	EQU	RAM_MAINVARS2
SSMAINVARS	EQU	RAM_MAINVARS
SSRWDATA	EQU	RAM_RWDATA
SSFLOORVARS	EQU	RAM_FLOORVARS
TRACETBLMD	EQU	RAM_TRACETBL
SSIMGBAND	EQU	RAM_IMGBAND
