; -------------------------------------------------------------------------
; Sonic CD Disassembly - Mega Drive port
; -------------------------------------------------------------------------
; Mode 7 floor demo, "baked" style: single-pixel (1:1) floor of special
; stage 1 drawn from ROM tables, in the spirit of MarkeyJester's Sonic CD
; Mode 7 test. Build with build_floor_demo.sh (it bakes the data first).
; -------------------------------------------------------------------------
; How it works
;  - The stage region around the start is a FLAT 1 byte/pixel texture in ROM
;    (FD_W x FD_W). It exists twice: FloorTexHi (color<<4) and FloorTexLo
;    (color), one right after the other, so two texels combine into one 4bpp
;    byte with a single "or".
;  - The camera is at integer pixels, so the texel offset of every screen
;    pixel RELATIVE to the camera depends only on the yaw. For each of FD_NANG
;    yaw angles there is a table with those offsets for rows FD_R0..95, in
;    segments of 16 pixels: 1 longword (offset of the first pixel) followed by
;    15 words (offset of the others relative to the first one).
;  - Moving the camera is just loading a pointer into the flat texture.
;  - The picture is written straight into VDP tile format (column-major
;    tiles, $180 bytes per column of 12 tiles), double buffered in RAM, and
;    DMA'd to VRAM in two halves by the V-INT.
; Limits: rows above FD_R0 (the far horizon) are left transparent, the camera
; wraps modulo FD_W (infinite tiling stage), and the yaw has FD_NANG steps.
; The texture is stored as 3 vertical copies so the hot loop never needs to
; branch for wrap — offsets of ±FD_W from the middle copy always hit valid data.
; -------------------------------------------------------------------------

	include	"_Include/Common.inc"
	include	"_Include/Main CPU.inc"			; Hardware definitions
	include	"MD Port/Floor Demo/params.inc"

BUF0		EQU	$00FF0000			; Picture buffers (12KB each)
BUF1		EQU	$00FF3000
IMGBYTES	EQU	$3000
IMGVRAM		EQU	$0020				; VRAM address of the picture tiles

	rsset	$FFFF8000
vcount		rs.w	1				; V-INT counter
dmaState	rs.b	1				; 0 idle, 1 copy first half, 2 copy second half
		rs.b	1
backBuf		rs.l	1				; Buffer being rendered
frontBuf	rs.l	1				; Buffer being copied to VRAM
camXl		rs.l	1				; Camera in texture pixels, 16.16
camYl		rs.l	1
camX		rs.w	1				; Camera in whole pixels
camY		rs.w	1
yaw		rs.b	1				; Yaw step 0..FD_NANG-1
padHold		rs.b	1				; Buttons: bit0 up, 1 down, 2 left, 3 right, 4 B, 5 C, 6 A, 7 start
padTap		rs.b	1
		rs.b	1
frames		rs.l	1				; Pictures rendered

; -------------------------------------------------------------------------
; Vector table and ROM header
; -------------------------------------------------------------------------

Vectors:
	dc.l	$01000000				; Initial stack pointer
	dc.l	EntryPoint
	rept	23					; Exceptions (vectors 2-24)
		dc.l	ErrorTrap
	endr
	dc.l	ErrorTrap				; IRQ level 1
	dc.l	ErrorTrap				; IRQ level 2
	dc.l	ErrorTrap				; IRQ level 3
	dc.l	ErrorTrap				; IRQ level 4 (H-INT)
	dc.l	ErrorTrap				; IRQ level 5
	dc.l	VInterrupt				; IRQ level 6 (V-INT)
	dc.l	ErrorTrap				; IRQ level 7
	rept	32
		dc.l	ErrorTrap
	endr

	dc.b	"SEGA MEGA DRIVE "
	dc.b	"(C)SCDM 2026.OCT"
	dc.b	"SONIC CD MD PORT - MODE 7 FLOOR DEMO"
	dcb.b	$150-*,$20
	dc.b	"SONIC CD MD PORT - MODE 7 FLOOR DEMO"
	dcb.b	$180-*,$20
	dc.b	"GM 00000000-00"
	dc.w	0					; Checksum (fixed by the build script)
	dc.b	"J"
	dcb.b	$1A0-*,$20
	dc.l	0
	dc.l	ROMEnd-1
	dc.l	$FF0000,$FFFFFF
	dcb.b	$1F0-*,$20
	dc.b	"JUE"
	dcb.b	$200-*,$20

ErrorTrap:
	bra.s	ErrorTrap

; -------------------------------------------------------------------------
; Entry point
; -------------------------------------------------------------------------

EntryPoint:
	move	#$2700,sr

	move.b	VERSION,d0				; TMSS handshake
	andi.b	#$0F,d0
	beq.s	.NoTMSS
	move.l	#'SEGA',TMSSSEGA
.NoTMSS:
	move.w	VDPCTRL,d0

	move.w	#$100,Z80BUS				; Park the Z80 on a harmless loop
	move.w	#$100,Z80RESET
.WaitZ80:
	btst	#0,Z80BUS
	bne.s	.WaitZ80
	lea	Z80RAM,a0
	move.b	#$F3,(a0)+
	move.b	#$F3,(a0)+
	move.b	#$C3,(a0)+
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.w	#0,Z80RESET
	moveq	#$7F,d0
	dbf	d0,*
	move.w	#0,Z80BUS
	move.w	#$100,Z80RESET

	lea	PSGCTRL,a0				; Silence the PSG
	move.b	#$9F,(a0)
	move.b	#$BF,(a0)
	move.b	#$DF,(a0)
	move.b	#$FF,(a0)

	moveq	#0,d0					; Clear Work RAM
	lea	WORKRAME,a6
	move.w	#WORKRAMS/4-1,d6
.ClearRAM:
	move.l	d0,-(a6)
	dbf	d6,.ClearRAM

	lea	DemoVDPRegs(pc),a0			; VDP registers
	move.w	#$8000,d0
	moveq	#DemoVDPRegsEnd-DemoVDPRegs-1,d7
.SetupVDP:
	move.b	(a0)+,d0
	move.w	d0,VDPCTRL
	addi.w	#$100,d0
	dbf	d7,.SetupVDP

	moveq	#$40,d0					; Controller ports
	move.b	d0,IOCTRL1
	move.b	d0,IOCTRL2
	move.b	d0,IOCTRL3
	move.b	#$C0,IODATA1

	move.l	#$40000000,VDPCTRL			; Clear VRAM
	lea	VDPDATA,a0
	moveq	#0,d0
	move.w	#$10000/16-1,d7
.ClearVRAM:
	rept	4
		move.l	d0,(a0)
	endr
	dbf	d7,.ClearVRAM

	move.l	#$C0000000,VDPCTRL			; Palette: stage 1 colors in line 0, the rest black
	lea	DemoPalette(pc),a1
	moveq	#16/2-1,d7
.LoadPal:
	move.l	(a1)+,(a0)
	dbf	d7,.LoadPal
	moveq	#(64-16)/2-1,d7
.ClearPal:
	move.l	d0,(a0)
	dbf	d7,.ClearPal

	move.l	#$40000010,VDPCTRL			; Clear VSRAM
	moveq	#$50/4-1,d7
.ClearVSRAM:
	move.l	d0,(a0)
	dbf	d7,.ClearVSRAM

	movea.l	(Vectors).l,sp

	; Plane A: the picture (32x12 tiles, column-major tile numbers) at tile rows 12-23
	moveq	#0,d6					; d6 = tile row
.NTRow:
	move.l	d6,d0
	lsl.l	#7,d0					; row*128
	addi.l	#$C000+12*128,d0
	andi.l	#$3FFF,d0
	swap	d0
	ori.l	#$40000003,d0
	move.l	d0,VDPCTRL
	moveq	#0,d5					; d5 = tile column
.NTCol:
	move.w	d5,d1
	mulu.w	#12,d1
	add.w	d6,d1
	addq.w	#1,d1					; tile = 1 + column*12 + row
	move.w	d1,VDPDATA
	addq.w	#1,d5
	cmpi.w	#32,d5
	bne.s	.NTCol
	addq.w	#1,d6
	cmpi.w	#12,d6
	bne.s	.NTRow

	move.l	#BUF1,backBuf.w
	move.l	#BUF0,frontBuf.w
	move.l	#FD_START<<16,camXl.w
	move.l	#FD_START<<16,camYl.w
	move.w	#FD_START,camX.w
	move.w	#FD_START,camY.w

	move.w	#$8174,VDPCTRL				; Display on, V-INT on, DMA on
	move	#$2000,sr				; Interrupts on

; -------------------------------------------------------------------------
; Main loop
; -------------------------------------------------------------------------

MainLoop:
	bsr.w	ReadPad
	bsr.w	UpdateCamera
	bsr.w	RenderPicture

.WaitDMA:
	tst.b	dmaState.w				; The previous picture must be in VRAM
	bne.s	.WaitDMA
	move.l	backBuf.w,d0				; Swap buffers
	move.l	frontBuf.w,backBuf.w
	move.l	d0,frontBuf.w
	move.b	#1,dmaState.w				; Ask the V-INT to copy the new front buffer
	addq.l	#1,frames.w
	bra.s	MainLoop

; -------------------------------------------------------------------------
; Controls: left/right turn, up/down move forward/back
; -------------------------------------------------------------------------

UpdateCamera:
	moveq	#0,d0
	move.b	yaw.w,d0
	btst	#2,padHold.w				; Left
	beq.s	.NotLeft
	subq.b	#1,d0
.NotLeft:
	btst	#3,padHold.w				; Right
	beq.s	.NotRight
	addq.b	#1,d0
.NotRight:
	andi.b	#FD_NANG-1,d0
	move.b	d0,yaw.w

	lea	FloorForward,a0				; Forward step for this yaw (8.8 px)
	lsl.w	#2,d0
	movea.w	d0,a1
	move.w	(a0,a1.l),d1
	move.w	2(a0,a1.l),d2
	ext.l	d1
	ext.l	d2
	asl.l	#8,d1					; 8.8 -> 16.16
	asl.l	#8,d2

	btst	#0,padHold.w				; Up: forward
	bne.s	.Move
	btst	#1,padHold.w				; Down: backward
	beq.s	.NoMove
	neg.l	d1
	neg.l	d2
.Move:
	add.l	d1,camXl.w
	add.l	d2,camYl.w
.NoMove:
	; Wrap camX/camY modulo FD_W — infinite stage, no boundary clamping
	move.l	camXl.w,d3				; d3 = 16.16 X
	move.l	camYl.w,d4				; d4 = 16.16 Y
	swap	d3					; integer part in low word
	swap	d4
	tst.w	d3					; wrap X negative edge
	bpl.s	.WrapXPos
	addi.w	#FD_W,d3
.WrapXPos:
	cmpi.w	#FD_W,d3				; wrap X positive edge
	blt.s	.WrapXDone
	subi.w	#FD_W,d3
.WrapXDone:
	tst.w	d4					; wrap Y negative edge
	bpl.s	.WrapYPos
	addi.w	#FD_W,d4
.WrapYPos:
	cmpi.w	#FD_W,d4				; wrap Y positive edge
	blt.s	.WrapYDone
	subi.w	#FD_W,d4
.WrapYDone:
	move.w	d3,camX.w				; store wrapped integer coords
	move.w	d4,camY.w
	; Write back to 16.16 variables: integer is in low word of d3/d4 after swap;
	; swap puts it back in the high word, then patch the low word with the fractional part.
	swap	d3					; integer -> high word
	move.w	camXl+2.w,d3				; restore fractional word (low word of camXl longword)
	move.l	d3,camXl.w
	swap	d4
	move.w	camYl+2.w,d4
	move.l	d4,camYl.w
	rts

; -------------------------------------------------------------------------
; Read controller 1 (3-button) into padHold/padTap
; -------------------------------------------------------------------------

ReadPad:
	lea	padHold.w,a5
	lea	IODATA1,a6
	move.b	#0,(a6)
	tst.w	(a5)
	move.b	(a6),d0
	lsl.b	#2,d0
	andi.b	#$C0,d0
	move.b	#$40,(a6)
	tst.w	(a5)
	move.b	(a6),d1
	andi.b	#$3F,d1
	or.b	d1,d0
	not.b	d0
	move.b	d0,d1
	move.b	(a5),d2
	eor.b	d2,d0
	move.b	d1,(a5)+
	and.b	d1,d0
	move.b	d0,(a5)+
	rts

; -------------------------------------------------------------------------
; RenderPicture - draw rows FD_R0..95 into backBuf from the baked tables
; -------------------------------------------------------------------------
; Inputs: camX.w, camY.w (texture pixels), yaw.w (step), backBuf.w
; Per segment of 16 pixels: header long -> pointer to the first texel, then
; 8 pairs of texels (hi texture | lo texture) written as 4bpp bytes.
; -------------------------------------------------------------------------

RenderPicture:
	moveq	#0,d0					; a5 = texel under the camera (hi texture)
	move.w	camY.w,d0
	mulu.w	#FD_W,d0
	moveq	#0,d1
	move.w	camX.w,d1
	add.l	d1,d0
	addi.l	#FD_TEXSIZE,d0				; Base is in the MIDDLE copy (copy 1 of 3)
	lea	FloorTexHi,a5				; so ±FD_W offsets always land in a valid copy
	adda.l	d0,a5

	moveq	#0,d0					; a2 = angle table
	move.b	yaw.w,d0
	lsl.w	#2,d0
	lea	FloorAngleDir,a2
	movea.l	(a2,d0.w),a2

	movea.l	backBuf.w,a0
	adda.w	#FD_R0*4,a0				; Row r starts r*4 bytes into the buffer
	move.l	#FD_TEX3SIZE,d3				; lo texture = hi texture + FD_TEX3SIZE (3 copies each)
	moveq	#FD_ROWS-1,d7

.Row:
	movea.l	a0,a1
	moveq	#256/16-1,d6

.Seg:
	move.l	(a2)+,d2				; Offset of the first pixel
	lea	(a5,d2.l),a3
	lea	(a3,d3.l),a4

	move.b	(a3),d0					; Pair 0: first pixel needs no offset
	move.w	(a2)+,d1
	or.b	(a4,d1.w),d0
	move.b	d0,(a1)+
	rept	3					; Pairs 1-3
	move.w	(a2)+,d1
	move.b	(a3,d1.w),d0
	move.w	(a2)+,d1
	or.b	(a4,d1.w),d0
	move.b	d0,(a1)+
	endr
	lea	380(a1),a1				; Next tile column
	rept	4					; Pairs 4-7
	move.w	(a2)+,d1
	move.b	(a3,d1.w),d0
	move.w	(a2)+,d1
	or.b	(a4,d1.w),d0
	move.b	d0,(a1)+
	endr
	lea	380(a1),a1

	dbf	d6,.Seg
	addq.l	#4,a0					; Next row
	dbf	d7,.Row
	rts

; -------------------------------------------------------------------------
; V-BLANK: copy the finished picture to VRAM, one half per V-INT
; -------------------------------------------------------------------------

VInterrupt:
	movem.l	d0-d6/a0-a1/a5-a6,-(sp)
	move.w	VDPCTRL,d0
	addq.w	#1,vcount.w

	moveq	#0,d4
	move.b	dmaState.w,d4
	beq.w	.Done
	subq.b	#1,d4					; d4 = half (0/1)

	move.w	d4,d5
	mulu.w	#IMGBYTES/2,d5				; byte offset of this half
	move.w	d5,d0
	addi.w	#IMGVRAM,d0				; VRAM destination
	move.l	frontBuf.w,d6
	add.l	d5,d6					; RAM source
	lsr.l	#1,d6					; in words

	move.l	d0,d1					; VDP command words
	andi.l	#$3FFF,d1
	swap	d1
	andi.w	#$C000,d0
	rol.w	#2,d0
	andi.l	#3,d0
	or.l	d0,d1
	move.l	d1,d2
	ori.l	#$40000080,d1				; DMA command
	ori.l	#$40000000,d2				; write command

	lea	VDPCTRL,a6
	move.l	#$93009400|((((IMGBYTES/2)/2)&$FF00)>>8)|((((IMGBYTES/2)/2)&$FF)<<16),(a6)
	move.w	d6,d0
	andi.w	#$00FF,d0
	ori.w	#$9500,d0
	move.w	d0,(a6)
	move.w	d6,d0
	lsr.w	#8,d0
	ori.w	#$9600,d0
	move.w	d0,(a6)
	move.w	#$977F,(a6)				; Source in Work RAM
	move.l	d1,-(sp)
	move.w	(sp)+,(a6)
	move.w	(sp)+,(a6)				; DMA starts

	move.l	d2,(a6)					; Write the first word by hand (same as DMA68K2)
	movea.l	frontBuf.w,a5
	adda.w	d5,a5
	move.w	(a5),VDPDATA

	cmpi.b	#2,dmaState.w				; After the second half we are done
	bne.s	.Second
	clr.b	dmaState.w
	bra.s	.Done
.Second:
	move.b	#2,dmaState.w
.Done:
	movem.l	(sp)+,d0-d6/a0-a1/a5-a6
	rte

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

DemoVDPRegs:
	dc.b	%00000100				; 0: no H-INT
	dc.b	%00110100				; 1: V-INT, DMA, mode 5 (display off for now)
	dc.b	$C000/$400				; 2: plane A
	dc.b	0					; 3: window
	dc.b	$E000/$2000				; 4: plane B
	dc.b	$D400/$200				; 5: sprite table
	dc.b	0
	dc.b	$0A					; 7: backdrop = palette line 0, color 10 (sky)
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	%00000000				; 11: full-screen scroll
	dc.b	%00000000				; 12: H32
	dc.b	$D000/$400				; 13: H-scroll table
	dc.b	0
	dc.b	2					; 15: auto increment 2
	dc.b	%00000001				; 16: 64x32 planes
	dc.b	0
	dc.b	0
DemoVDPRegsEnd:
	even

DemoPalette:
	incbin	"Special Stage/Data/Stage 1/Palette.bin",0,32	; First 16 colors
	even

FloorForward:
	incbin	"MD Port/Floor Demo/forward.bin"
	even
FloorAngleDir:
	include	"MD Port/Floor Demo/angle_dir.inc"

	cnop	0,2
FloorTexHi:
	incbin	"MD Port/Floor Demo/tex_hi.bin"
FloorTexLo:
	incbin	"MD Port/Floor Demo/tex_lo.bin"		; (must follow FloorTexHi: lo = hi + FD_TEXSIZE)
FloorAngles:
	incbin	"MD Port/Floor Demo/angles.bin"
	even
ROMEnd:
