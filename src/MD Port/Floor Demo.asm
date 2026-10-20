; -------------------------------------------------------------------------
; Sonic CD Disassembly - Mega Drive port
; -------------------------------------------------------------------------
; Mode 7 floor demo — stamp-local camera, RAM texture.
;
; Architecture
;   The camera always lives inside a single 32×32-pixel stamp. When it
;   crosses a 32-pixel boundary the stamp index (stampX/stampY) increments
;   mod 128, the camera wraps back into [0,32), and LoadStampTex rebuilds
;   the RAM texture around the new stamp. No 3-copy or infinite-scroll
;   tiling is needed — the texture is exactly W×W pixels (W=224, 7 stamps).
;
; ROM data
;   FloorStampsPacked  nstamps × 512 B  (32 rows × 16 bytes, 4bpp packed)
;   FloorStampMap      128×128 big-endian words (full stage layout)
;   FloorAngles        per-yaw tables: 1 long + 7 words per segment
;   FloorForward       32 forward vectors (8.8 fixed-point pairs)
;
; RAM texture  (at FLOORTEX_ADDR = $FF6000, 25088 bytes = 24.5 KB)
;   FD_WPACKED (112) bytes per pixel row, W (224) rows.
;   Each byte = 2 horizontal pixels (high nibble = left pixel).
;
; Segment table entry  (1 long + 7 words = 18 bytes)
;   long : signed byte-offset from camera to packed byte 0 of the segment
;   word×7: signed byte-offsets of bytes 1..7 RELATIVE TO byte 0
;   (one entry = 2 pixels; 8 entries × 2 = 16 pixels per segment)
;
; Output buffer layout
;   Same column-major VDP tile layout as the original demo:
;   each scan-line's 256 pixels are split across 16 segments of 16 pixels;
;   pixels 0-3 go to tile-column N, pixels 4-7 skip 380 bytes to tile-column
;   N+1, matching the stride of one VDP tile column ($180 bytes).
; -------------------------------------------------------------------------

	include	"_Include/Common.inc"
	include	"_Include/Main CPU.inc"
	include	"MD Port/Floor Demo/params.inc"

BUF0		EQU	$00FF0000
BUF1		EQU	$00FF3000
IMGBYTES	EQU	$3000
IMGVRAM		EQU	$0020

; Texture at $FF6000 ($FF3000 + $3000), size $6200 (25088), ends at $FFC200
FLOORTEX_ADDR	EQU	BUF1+IMGBYTES

; Camera base pointer within texture = FD_START rows down + FD_START/2 bytes across
; = FD_START*FD_WPACKED + FD_START/2  = 112*112 + 56 = 12544 + 56 = 12600
TEXBASE_OFF	EQU	FD_START*FD_WPACKED+(FD_START/2)

	rsset	$FFFF8000
vcount		rs.w	1
dmaState	rs.b	1
		rs.b	1
backBuf		rs.l	1
frontBuf	rs.l	1
camXl		rs.l	1		; Camera within stamp, 16.16 (integer always in [0,32))
camYl		rs.l	1
camX		rs.w	1		; Camera within stamp, integer pixels
camY		rs.w	1
stampX		rs.w	1		; Current stamp column in map (0..127)
stampY		rs.w	1		; Current stamp row in map (0..127)
yaw		rs.b	1
padHold		rs.b	1
padTap		rs.b	1
		rs.b	1
frames		rs.l	1

; -------------------------------------------------------------------------
; Vector table + ROM header
; -------------------------------------------------------------------------

Vectors:
	dc.l	$01000000
	dc.l	EntryPoint
	rept	23
		dc.l	ErrorTrap
	endr
	dc.l	ErrorTrap
	dc.l	ErrorTrap
	dc.l	ErrorTrap
	dc.l	ErrorTrap
	dc.l	ErrorTrap
	dc.l	VInterrupt
	dc.l	ErrorTrap
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
	dc.w	0
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
; EntryPoint
; -------------------------------------------------------------------------

EntryPoint:
	move	#$2700,sr

	move.b	VERSION,d0
	andi.b	#$0F,d0
	beq.s	.NoTMSS
	move.l	#'SEGA',TMSSSEGA
.NoTMSS:
	move.w	VDPCTRL,d0

	move.w	#$100,Z80BUS
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

	lea	PSGCTRL,a0
	move.b	#$9F,(a0)
	move.b	#$BF,(a0)
	move.b	#$DF,(a0)
	move.b	#$FF,(a0)

	moveq	#0,d0
	lea	WORKRAME,a6
	move.w	#WORKRAMS/4-1,d6
.ClearRAM:
	move.l	d0,-(a6)
	dbf	d6,.ClearRAM

	lea	DemoVDPRegs(pc),a0
	move.w	#$8000,d0
	moveq	#DemoVDPRegsEnd-DemoVDPRegs-1,d7
.SetupVDP:
	move.b	(a0)+,d0
	move.w	d0,VDPCTRL
	addi.w	#$100,d0
	dbf	d7,.SetupVDP

	moveq	#$40,d0
	move.b	d0,IOCTRL1
	move.b	d0,IOCTRL2
	move.b	d0,IOCTRL3
	move.b	#$C0,IODATA1

	move.l	#$40000000,VDPCTRL
	lea	VDPDATA,a0
	moveq	#0,d0
	move.w	#$10000/16-1,d7
.ClearVRAM:
	rept	4
		move.l	d0,(a0)
	endr
	dbf	d7,.ClearVRAM

	move.l	#$C0000000,VDPCTRL
	lea	DemoPalette(pc),a1
	moveq	#16/2-1,d7
.LoadPal:
	move.l	(a1)+,(a0)
	dbf	d7,.LoadPal
	moveq	#(64-16)/2-1,d7
.ClearPal:
	move.l	d0,(a0)
	dbf	d7,.ClearPal

	move.l	#$40000010,VDPCTRL
	moveq	#$50/4-1,d7
.ClearVSRAM:
	move.l	d0,(a0)
	dbf	d7,.ClearVSRAM

	movea.l	(Vectors).l,sp

	; Plane A nametable (column-major tile numbers)
	moveq	#0,d6
.NTRow:
	move.l	d6,d0
	lsl.l	#7,d0
	addi.l	#$C000+12*128,d0
	andi.l	#$3FFF,d0
	swap	d0
	ori.l	#$40000003,d0
	move.l	d0,VDPCTRL
	moveq	#0,d5
.NTCol:
	move.w	d5,d1
	mulu.w	#12,d1
	add.w	d6,d1
	addq.w	#1,d1
	move.w	d1,VDPDATA
	addq.w	#1,d5
	cmpi.w	#32,d5
	bne.s	.NTCol
	addq.w	#1,d6
	cmpi.w	#12,d6
	bne.s	.NTRow

	move.l	#BUF1,backBuf.w
	move.l	#BUF0,frontBuf.w

	move.l	#FD_STARTCAMX<<16,camXl.w
	move.l	#FD_STARTCAMY<<16,camYl.w
	move.w	#FD_STARTCAMX,camX.w
	move.w	#FD_STARTCAMY,camY.w
	move.w	#FD_STARTSTX,stampX.w
	move.w	#FD_STARTSTY,stampY.w

	bsr.w	LoadStampTex

	move.w	#$8174,VDPCTRL
	move	#$2000,sr

; -------------------------------------------------------------------------
; Main loop
; -------------------------------------------------------------------------

MainLoop:
	bsr.w	ReadPad
	bsr.w	UpdateCamera
	bsr.w	RenderPicture

.WaitDMA:
	tst.b	dmaState.w
	bne.s	.WaitDMA
	move.l	backBuf.w,d0
	move.l	frontBuf.w,backBuf.w
	move.l	d0,frontBuf.w
	move.b	#1,dmaState.w
	addq.l	#1,frames.w
	bra.s	MainLoop

; -------------------------------------------------------------------------
; ReadPad
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
; UpdateCamera
; -------------------------------------------------------------------------
; Camera integer part always kept in [0,32).  Crossing a boundary increments
; the stamp index (mod 128) and triggers a texture reload.
; -------------------------------------------------------------------------

UpdateCamera:
	moveq	#0,d0
	move.b	yaw.w,d0
	btst	#2,padHold.w
	beq.s	.NotLeft
	subq.b	#1,d0
.NotLeft:
	btst	#3,padHold.w
	beq.s	.NotRight
	addq.b	#1,d0
.NotRight:
	andi.b	#FD_NANG-1,d0
	move.b	d0,yaw.w

	lea	FloorForward,a0
	lsl.w	#2,d0
	movea.w	d0,a1
	move.w	(a0,a1.l),d1
	move.w	2(a0,a1.l),d2
	ext.l	d1
	ext.l	d2
	asl.l	#8,d1
	asl.l	#8,d2

	btst	#0,padHold.w
	bne.s	.Move
	btst	#1,padHold.w
	beq.s	.NoMove
	neg.l	d1
	neg.l	d2
.Move:
	add.l	d1,camXl.w
	add.l	d2,camYl.w
.NoMove:
	move.l	camXl.w,d3
	move.l	camYl.w,d4
	swap	d3
	swap	d4
	moveq	#0,d5			; boundary-crossed flag

	tst.w	d3
	bpl.s	.XNotNeg
	addi.w	#32,d3
	move.w	stampX.w,d6
	subq.w	#1,d6
	andi.w	#$7F,d6
	move.w	d6,stampX.w
	moveq	#1,d5
	bra.s	.XDone
.XNotNeg:
	cmpi.w	#32,d3
	blt.s	.XDone
	subi.w	#32,d3
	move.w	stampX.w,d6
	addq.w	#1,d6
	andi.w	#$7F,d6
	move.w	d6,stampX.w
	moveq	#1,d5
.XDone:
	tst.w	d4
	bpl.s	.YNotNeg
	addi.w	#32,d4
	move.w	stampY.w,d6
	subq.w	#1,d6
	andi.w	#$7F,d6
	move.w	d6,stampY.w
	moveq	#1,d5
	bra.s	.YDone
.YNotNeg:
	cmpi.w	#32,d4
	blt.s	.YDone
	subi.w	#32,d4
	move.w	stampY.w,d6
	addq.w	#1,d6
	andi.w	#$7F,d6
	move.w	d6,stampY.w
	moveq	#1,d5
.YDone:
	move.w	d3,camX.w
	move.w	d4,camY.w

	swap	d3
	move.w	camXl+2.w,d3
	move.l	d3,camXl.w
	swap	d4
	move.w	camYl+2.w,d4
	move.l	d4,camYl.w

	tst.w	d5
	beq.s	.NoCross
	bsr.w	LoadStampTex
.NoCross:
	rts

; -------------------------------------------------------------------------
; LoadStampTex — rebuild W×W RAM texture around current stamp
; -------------------------------------------------------------------------
; The texture is FD_WSTAMPS × FD_WSTAMPS stamps (7×7 = 224×224 pixels).
; Top-left stamp: TX = (stampX - FD_WSTAMPS/2) & $7F
;                 TY = (stampY - FD_WSTAMPS/2) & $7F
;
; For each of the 7 stamp-rows:
;   For each of 32 pixel rows within that stamp strip:
;     For each of 7 stamp columns:
;       Copy 16 bytes (one packed stamp row) → texture row
;
; Register allocation:
;   d0 = TX (starting stamp column, updated each stamp-col loop)
;   d1 = TY (starting stamp row)
;   d2 = current stamp-row counter (outer, 7 iterations)
;   d3 = current map row (wraps mod 128)
;   d4 = pixel row within stamp (0..31)
;   d5 = scratch (stamp index, byte offsets)
;   d6 = current stamp-col counter (inner, 7 iterations)
;   a0 = pointer to start of current map row (FloorStampMap + row*256)
;   a1 = output: current position in FLOORTEX
;   a2 = pointer to stamp rom row being copied
;   a3 = current map column pointer (a0 + col*2)
; -------------------------------------------------------------------------

LoadStampTex:
	movem.l	d0-d6/a0-a3,-(sp)

	; Top-left stamp of the 7×7 texture window
	move.w	stampX.w,d0
	subi.w	#FD_WSTAMPS/2,d0		; TX = stampX - 3
	andi.w	#$7F,d0
	move.w	stampY.w,d1
	subi.w	#FD_WSTAMPS/2,d1		; TY = stampY - 3
	andi.w	#$7F,d1

	lea	FLOORTEX_ADDR,a1		; a1 = running output pointer in texture RAM

	move.w	d1,d3				; d3 = current map row (wraps mod 128)
	moveq	#FD_WSTAMPS-1,d2		; d2 = stamp-row counter (outer loop)

.SRow:
	; a0 → start of this map row: FloorStampMap + d3*256
	move.w	d3,d5
	lsl.w	#8,d5
	lea	FloorStampMap,a0
	adda.w	d5,a0

	; For each of 32 pixel rows within this stamp strip:
	moveq	#0,d4				; d4 = pixel row within stamp (0..31)

.PRow:
	; a3 = running stamp column, starts at TX each pixel row
	move.w	d0,d5				; d5 = TX (starting column)
	moveq	#FD_WSTAMPS-1,d6		; d6 = stamp-col counter

.SCol:
	; d5 = running stamp column (unwrapped).  a3 used as scratch.
	move.w	d5,a3				; a3 = running col (preserved across this iter)
	andi.w	#$7F,d5				; d5 = wrapped col (0..127)
	lsl.w	#1,d5				; d5 = byte offset into map row (col*2)
	move.w	(a0,d5.w),d5			; d5.w = stamp index — upper word still dirty!
	andi.l	#$FFFF,d5			; clear upper word → d5 = clean stamp index

	; a2 → stamp pixel row d4 in ROM
	lsl.l	#8,d5				; d5 * 256
	add.l	d5,d5				; d5 * 512 (each stamp = 512 bytes)
	lea	FloorStampsPacked,a2
	adda.l	d5,a2				; a2 → stamp base
	move.w	d4,d5
	lsl.w	#4,d5				; d4 * 16 (each row = 16 bytes)
	adda.w	d5,a2				; a2 → pixel row within stamp

	; Copy 16 bytes to RAM texture
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+
	move.l	(a2)+,(a1)+

	; Next column
	move.w	a3,d5				; restore running col
	addq.w	#1,d5				; increment
	dbf	d6,.SCol

	; Next pixel row
	addq.w	#1,d4
	cmpi.w	#32,d4
	blt.s	.PRow

	; Next stamp row in map
	addq.w	#1,d3
	andi.w	#$7F,d3
	dbf	d2,.SRow

	movem.l	(sp)+,d0-d6/a0-a3
	rts

; -------------------------------------------------------------------------
; RenderPicture
; -------------------------------------------------------------------------
; Reads the packed 4bpp RAM texture at FLOORTEX_ADDR.
; Per segment (16 output pixels = 8 output bytes):
;   a2 table: [long: base byte-offset from camera] [word×7: rel offsets 1..7]
; Output: same column-major tile layout as original demo.
;   First 4 bytes of the 8 → written to a1 (4 bytes)
;   Skip 380 bytes (next tile column), write last 4 bytes
;   Skip 380 bytes (ready for next segment's first tile column)
; -------------------------------------------------------------------------

RenderPicture:
	lea	FLOORTEX_ADDR,a5
	addi.l	#TEXBASE_OFF,a5			; a5 = tex byte under camera

	moveq	#0,d0
	move.b	yaw.w,d0
	lsl.w	#2,d0
	lea	FloorAngleDir,a2
	movea.l	(a2,d0.w),a2

	movea.l	backBuf.w,a0
	adda.w	#FD_R0*4,a0
	moveq	#FD_ROWS-1,d7

.Row:
	movea.l	a0,a1
	moveq	#256/16-1,d6

.Seg:
	move.l	(a2)+,d2			; byte offset of pair 0
	lea	(a5,d2.l),a3			; a3 = base of this segment in tex

	; Pairs 0-3: 4 output bytes, then skip to next tile column
	move.b	(a3),(a1)+			; pair 0
	move.w	(a2)+,d1
	move.b	(a3,d1.w),(a1)+			; pair 1
	move.w	(a2)+,d1
	move.b	(a3,d1.w),(a1)+			; pair 2
	move.w	(a2)+,d1
	move.b	(a3,d1.w),(a1)+			; pair 3
	lea	380(a1),a1			; skip to next tile column

	; Pairs 4-7: 4 more output bytes, then skip to next tile column
	move.w	(a2)+,d1
	move.b	(a3,d1.w),(a1)+			; pair 4
	move.w	(a2)+,d1
	move.b	(a3,d1.w),(a1)+			; pair 5
	move.w	(a2)+,d1
	move.b	(a3,d1.w),(a1)+			; pair 6
	move.w	(a2)+,d1
	move.b	(a3,d1.w),(a1)+			; pair 7
	lea	380(a1),a1			; skip to next tile column (next segment starts here)

	dbf	d6,.Seg
	addq.l	#4,a0				; next row
	dbf	d7,.Row
	rts

; -------------------------------------------------------------------------
; VInterrupt
; -------------------------------------------------------------------------

VInterrupt:
	movem.l	d0-d6/a0-a1/a5-a6,-(sp)
	move.w	VDPCTRL,d0
	addq.w	#1,vcount.w

	moveq	#0,d4
	move.b	dmaState.w,d4
	beq.w	.Done
	subq.b	#1,d4

	move.w	d4,d5
	mulu.w	#IMGBYTES/2,d5
	move.w	d5,d0
	addi.w	#IMGVRAM,d0
	move.l	frontBuf.w,d6
	add.l	d5,d6
	lsr.l	#1,d6

	move.l	d0,d1
	andi.l	#$3FFF,d1
	swap	d1
	andi.w	#$C000,d0
	rol.w	#2,d0
	andi.l	#3,d0
	or.l	d0,d1
	move.l	d1,d2
	ori.l	#$40000080,d1
	ori.l	#$40000000,d2

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
	move.w	#$977F,(a6)
	move.l	d1,-(sp)
	move.w	(sp)+,(a6)
	move.w	(sp)+,(a6)

	move.l	d2,(a6)
	movea.l	frontBuf.w,a5
	adda.w	d5,a5
	move.w	(a5),VDPDATA

	cmpi.b	#2,dmaState.w
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
	dc.b	%00000100
	dc.b	%00110100
	dc.b	$C000/$400
	dc.b	0
	dc.b	$E000/$2000
	dc.b	$D400/$200
	dc.b	0
	dc.b	$0A
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	%00000000
	dc.b	%00000000
	dc.b	$D000/$400
	dc.b	0
	dc.b	2
	dc.b	%00000001
	dc.b	0
	dc.b	0
DemoVDPRegsEnd:
	even

DemoPalette:
	incbin	"Special Stage/Data/Stage 1/Palette.bin",0,32
	even

FloorForward:
	incbin	"MD Port/Floor Demo/forward.bin"
	even
FloorAngleDir:
	include	"MD Port/Floor Demo/angle_dir.inc"

	cnop	0,2
FloorStampsPacked:
	incbin	"MD Port/Floor Demo/stamps_packed.bin"
	even
FloorStampMap:
	incbin	"MD Port/Floor Demo/stamp_map.bin"
	even
FloorAngles:
	incbin	"MD Port/Floor Demo/angles.bin"
	even
ROMEnd:
