; -------------------------------------------------------------------------
; Sonic CD Disassembly - Mega Drive port
; -------------------------------------------------------------------------
; Mode 7 floor demo — RAM streaming texture, full stage layout.
; Build with build_floor_demo.sh (it bakes the data first).
; -------------------------------------------------------------------------
; How it works
;  - A 224x224 4bpp-packed texture lives in Work RAM (FloorTex, ~24 KB).
;    It is a sliding window into the full stage map; the camera can move
;    anywhere and the texture wraps modulo FD_W in both axes.
;  - On init, BuildTex fills the texture from FloorStampMap + FloorStampsPacked
;    (both in ROM).  When the camera crosses a stamp boundary (every 32 px),
;    UpdateTexture rewrites one column and one row of stamps (~3 KB of work,
;    done entirely between frames).
;  - The camera is at integer pixels, so the texel offset of every screen
;    pixel RELATIVE to the camera depends only on the yaw.  For each of FD_NANG
;    yaw angles there is a table for rows FD_R0..95, in segments of 16 pixels:
;    1 signed longword (base offset from camera, can be negative) followed by
;    15 signed words (offset of each pixel relative to the first in the segment).
;  - RenderPicture adds the camera's position in the texture to the base offset,
;    wraps modulo FD_TEXSIZE once per segment (two compares), then reads each
;    4bpp byte directly from the RAM texture.  No OR trick needed — the packed
;    format already has both nibbles.
;  - The picture is written straight into VDP tile format, double-buffered in
;    RAM and DMA'd to VRAM in two halves by the V-INT.
; Limits: rows above FD_R0 are transparent; yaw has FD_NANG steps.
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
camXl		rs.l	1				; Camera in map pixels, 16.16 fixed point
camYl		rs.l	1
camX		rs.w	1				; Camera in whole map pixels
camY		rs.w	1
yaw		rs.b	1				; Yaw step 0..FD_NANG-1
padHold		rs.b	1				; Buttons: bit0 up, 1 down, 2 left, 3 right, 4 B, 5 C, 6 A, 7 start
padTap		rs.b	1
		rs.b	1
frames		rs.l	1				; Pictures rendered
; Texture streaming state
texOrgX		rs.w	1				; Map pixel of texture column 0 (mod 4096)
texOrgY		rs.w	1				; Map pixel of texture row 0 (mod 4096)
texCamX		rs.w	1				; Camera position within texture (0..FD_W-1)
texCamY		rs.w	1				; Camera position within texture (0..FD_W-1)
lastStampX	rs.w	1				; Stamp column that was last updated
lastStampY	rs.w	1				; Stamp row that was last updated

; RAM texture — must be aligned, placed after variables
		cnop	0,2
FloorTex	rs.b	FD_TEXSIZE			; 224x224 4bpp packed = 24 KB

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

	; Camera starts at (FD_STARTCAMX, FD_STARTCAMY) in map pixels (16.16 fixed point)
	move.l	#FD_STARTCAMX<<16,camXl.w
	move.l	#FD_STARTCAMY<<16,camYl.w
	move.w	#FD_STARTCAMX,camX.w
	move.w	#FD_STARTCAMY,camY.w

	; Texture window origin: camera minus half the texture size
	move.w	#FD_STARTSX,texOrgX.w
	move.w	#FD_STARTSY,texOrgY.w
	move.w	#FD_START,texCamX.w			; camera is at W/2 inside the texture
	move.w	#FD_START,texCamY.w
	move.w	#FD_STARTMX,lastStampX.w
	move.w	#FD_STARTMY,lastStampY.w

	bsr.w	BuildTex				; Fill RAM texture from stamp data

	move.w	#$8174,VDPCTRL				; Display on, V-INT on, DMA on
	move	#$2000,sr				; Interrupts on

; -------------------------------------------------------------------------
; Main loop
; -------------------------------------------------------------------------

MainLoop:
	bsr.w	ReadPad
	bsr.w	UpdateCamera
	bsr.w	UpdateTexture
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
	; ---- yaw update ----
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

	; ---- movement ----
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
	; ---- wrap camera in map space modulo 4096 (=128 stamps * 32 px) ----
	move.l	camXl.w,d3
	move.l	camYl.w,d4
	swap	d3					; integer to low word
	swap	d4
	; X wrap in map space [0, 4096)
	tst.w	d3
	bpl.s	.MXPos
	addi.w	#4096,d3
.MXPos:
	cmpi.w	#4096,d3
	blt.s	.MXDone
	subi.w	#4096,d3
.MXDone:
	; Y wrap in map space [0, 4096)
	tst.w	d4
	bpl.s	.MYPos
	addi.w	#4096,d4
.MYPos:
	cmpi.w	#4096,d4
	blt.s	.MYDone
	subi.w	#4096,d4
.MYDone:
	move.w	d3,camX.w
	move.w	d4,camY.w
	swap	d3
	move.w	camXl+2.w,d3
	move.l	d3,camXl.w
	swap	d4
	move.w	camYl+2.w,d4
	move.l	d4,camYl.w

	; ---- update texCamX/Y = (camX - texOrgX) mod FD_W ----
	move.w	camX.w,d0
	sub.w	texOrgX.w,d0
	tst.w	d0
	bpl.s	.TCXPos
	addi.w	#FD_W,d0
.TCXPos:
	cmpi.w	#FD_W,d0
	blt.s	.TCXDone
	subi.w	#FD_W,d0
.TCXDone:
	move.w	d0,texCamX.w

	move.w	camY.w,d0
	sub.w	texOrgY.w,d0
	tst.w	d0
	bpl.s	.TCYPos
	addi.w	#FD_W,d0
.TCYPos:
	cmpi.w	#FD_W,d0
	blt.s	.TCYDone
	subi.w	#FD_W,d0
.TCYDone:
	move.w	d0,texCamY.w
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
; RenderPicture - draw rows FD_R0..95 into backBuf from baked tables + RAM texture
; -------------------------------------------------------------------------
; The angle table stores SIGNED offsets relative to the camera position in
; the texture.  The table offset L = rel_y * FD_W + rel_x.  We add the
; camera's position in the texture (texCamY * FD_WPACKED + texCamX/2) and
; wrap once per segment.  Each byte read from FloorTex is one 4bpp output
; byte (packed — no OR needed).
;
; Column layout in backBuf: 256 pixels per row -> 128 bytes packed -> but
; the VDP tile format is column-major, 12 rows of tiles per column, so
; pixels 0-7 go to column 0 offset +r*4, pixels 8-15 to column 1 etc.
; The segment boundary falls at pixel 128 (column split), matching the
; existing tile layout.  Each 16-pixel segment covers 8 bytes packed.
;
; The bake samples only even-indexed pixels (one per packed byte) and pre-
; divides by 2.  Format per segment: 1 signed longword (base byte offset of
; packed byte 0) + 7 signed words (relative byte offsets of packed bytes 1-7).
; 8 bytes = 16 output pixels.  max_rel=1344 < 32768, words suffice.
; -------------------------------------------------------------------------

RenderPicture:
	; Base = camera position inside packed texture.
	; texCamX/Y = (camX/Y - texOrgX/Y) mod FD_W.
	; Since texOrgX = camX - FD_START always, texCamX = FD_START always.
	; Compute directly from camX/Y and texOrgX/Y to avoid any sync issues.
	moveq	#0,d0
	move.w	camY.w,d0
	sub.w	texOrgY.w,d0
	bpl.s	.TBYPos
	addi.w	#FD_W,d0
.TBYPos:
	mulu.w	#FD_WPACKED,d0				; row offset in bytes
	moveq	#0,d1
	move.w	camX.w,d1
	sub.w	texOrgX.w,d1
	bpl.s	.TBXPos
	addi.w	#FD_W,d1
.TBXPos:
	lsr.w	#1,d1					; pixel -> byte (packed)
	add.l	d1,d0					; d0 = base byte offset in texture
	lea	FloorTex,a5				; a5 = base texel ptr in RAM texture

	moveq	#0,d1					; a2 = packed angle table
	move.b	yaw.w,d1
	lsl.w	#2,d1
	lea	FloorAngleDir,a2
	movea.l	(a2,d1.w),a2

	movea.l	backBuf.w,a0
	adda.w	#FD_R0*4,a0				; Row r starts r*4 bytes into the buffer
	moveq	#FD_ROWS-1,d7

.Row:
	movea.l	a0,a1
	moveq	#256/16-1,d6

.Seg:
	; d2 = base offset for this segment (in packed bytes, already pre-divided)
	move.l	(a2)+,d2
	add.l	d0,d2					; add camera base
	; wrap into [0, FD_TEXSIZE)
	tst.l	d2
	bpl.s	.WrapPos
	addi.l	#FD_TEXSIZE,d2
.WrapPos:
	cmpi.l	#FD_TEXSIZE,d2
	blt.s	.WrapDone
	subi.l	#FD_TEXSIZE,d2
.WrapDone:
	lea	(a5,d2.l),a3				; a3 = pointer to first byte of segment

	; Each segment covers 16 pixels = 8 packed bytes (2 px/byte).
	; Split across two tile columns (4 bytes each), separated by 380-byte gap.
	; Relative offsets are in packed byte units (pre-divided by 2 in bake).
	; Bytes 0-3 (pixels 0-7) — tile column 0
	move.b	(a3),(a1)+				; byte 0 (pixel 0/1, rel=0)
	rept	3
	move.w	(a2)+,d1
	move.b	(a3,d1.w),(a1)+
	endr
	lea	380(a1),a1				; jump to tile column 1
	; Bytes 4-7 (pixels 8-15) — tile column 1
	rept	4
	move.w	(a2)+,d1
	move.b	(a3,d1.w),(a1)+
	endr
	lea	380(a1),a1				; jump back for next segment

	dbf	d6,.Seg
	addq.l	#4,a0					; Next row
	dbf	d7,.Row
	rts

; -------------------------------------------------------------------------
; BuildTex — fill FloorTex (224x224 4bpp packed) from ROM stamp data
; -------------------------------------------------------------------------
; Called once at startup.  Reads FloorStampMap at (lastStampX, lastStampY)
; and paints 7x7 stamps into FloorTex.  Stamp transforms (flip/rot) are not
; applied in this initial version — visually acceptable for stage 1.
; Trashes d0-d7/a0-a6.
; -------------------------------------------------------------------------
; FloorStampMap layout: 128x128 big-endian words, row-major.
;   word = %HRRxxxxSSSSSSSSxx  (H=hflip, R=rot[1:0], S=stamp_id[8:0])
;   sid  = (word & $07FC) >> 2   (bits 10..2)
; FloorStampsPacked layout: nstamps x 32 rows x 16 bytes (512 B/stamp).
; -------------------------------------------------------------------------

BuildTex:
	; a4 = FloorTex base
	lea	FloorTex,a4

	; Loop: ty = 0..FD_WSTAMPS-1, tx = 0..FD_WSTAMPS-1
	move.w	#FD_WSTAMPS-1,d7			; outer loop counter (ty)
	moveq	#0,d5					; d5 = ty
.BldTY:
	move.w	#FD_WSTAMPS-1,d6			; inner loop counter (tx)
	moveq	#0,d4					; d4 = tx
.BldTX:
	; ---- look up stamp id from map ----
	; map row  = lastStampY + ty  (mod 128)
	; map col  = lastStampX + tx  (mod 128)
	move.w	lastStampY.w,d0
	add.w	d5,d0
	andi.w	#$7F,d0					; mod 128
	move.w	lastStampX.w,d1
	add.w	d4,d1
	andi.w	#$7F,d1					; mod 128

	; address = FloorStampMap + (row*128 + col) * 2
	mulu.w	#128,d0
	add.w	d1,d0
	lsl.l	#1,d0
	lea	FloorStampMap,a0
	move.w	(a0,d0.l),d0				; raw map word
	andi.w	#$07FC,d0				; extract sid bits 10..2
	lsr.w	#2,d0					; d0 = sid

	; ---- compute destination pointer in FloorTex ----
	; base row = ty*32, base col byte = tx*16
	; byte offset = (ty*32) * FD_WPACKED + tx*16
	move.l	d5,d1
	mulu.w	#32*FD_WPACKED,d1			; ty*32 rows * stride
	move.l	d4,d2
	mulu.w	#16,d2					; tx*16 bytes
	add.l	d2,d1
	lea	(a4,d1.l),a1				; a1 = destination (first row of this stamp in tex)

	; ---- compute source pointer in FloorStampsPacked ----
	; offset = sid * 512 bytes
	mulu.w	#512,d0
	lea	FloorStampsPacked,a0
	lea	(a0,d0.l),a2				; a2 = source (stamp row 0)

	; ---- copy 32 rows x 16 bytes into texture ----
	; Each row: copy 16 bytes (4 longwords) from a2 to a1
	; After each row, a1 advances by FD_WPACKED (112), a2 by 16
	move.w	#32-1,d3
.BldRow:
	move.l	(a2)+,(a1)
	move.l	(a2)+,4(a1)
	move.l	(a2)+,8(a1)
	move.l	(a2)+,12(a1)
	lea	FD_WPACKED(a1),a1			; next tex row
	dbf	d3,.BldRow

	addq.w	#1,d4
	dbf	d6,.BldTX

	addq.w	#1,d5
	dbf	d7,.BldTY
	rts

; -------------------------------------------------------------------------
; UpdateTexture — stream new stamps into FloorTex when camera crosses boundary
; -------------------------------------------------------------------------
; Called every frame (after UpdateCamera).
; Checks if camX/camY has crossed a 32-pixel (1 stamp) boundary.
; If X: rewrites one column of 7 stamps into FloorTex.
; If Y: rewrites one row of 7 stamps into FloorTex.
; texOrgX/Y and lastStampX/Y are updated accordingly.
; Trashes d0-d5/a0-a3.
; -------------------------------------------------------------------------

; UpdateTexture logic:
;   texOrgX = map pixel of texture column 0.  Maintained here.
;   lastStampX = texOrgX/32 mod 128 at the last update.
;   When camX/32 != lastStampX:
;     * Advance texOrgX by 32 * delta (mod 4096), keeping camera in the
;       middle of the window.
;     * The new column to write into the texture is the one that just
;       became visible (rightmost if moving right, leftmost if left).
;     * Its tex slot = new texOrgX/32 + FD_WSTAMPS - 1  (right edge) if moving
;       right, or new texOrgX/32 (left edge) if moving left, mod FD_WSTAMPS.
;     * We recalculate texOrgX so the camera is always FD_START px from
;       tex column 0:  texOrgX = (camX - FD_START) mod 4096.
;     * Then the rightmost map stamp column = (texOrgX/32 + FD_WSTAMPS-1) & 127.

; How texOrgX / texCamX work together:
;   texOrgX = map pixel of texture column 0.  Always = (camX - FD_START) mod 4096.
;   texCamX = camX - texOrgX = FD_START (constant!).
;
;   When the camera crosses a stamp boundary (camX/32 changes), we:
;     1) Recompute texOrgX = (camX - FD_START) mod 4096.
;     2) The new texOrgX differs from the old one by ±32 (one stamp).
;        Moving right: new texOrgX = old + 32.  The newly exposed column is
;        at slot (new texOrgX/32 + FD_WSTAMPS - 1) mod FD_WSTAMPS — rightmost.
;        Moving left: new texOrgX = old - 32.  Newly exposed column is at
;        slot (new texOrgX/32) mod FD_WSTAMPS — leftmost.
;     3) Write that single column/row.

UpdateTexture:
	; ---- X axis ----
	move.w	camX.w,d0
	lsr.w	#5,d0					; d0 = camX/32 mod 128
	andi.w	#$7F,d0
	move.w	lastStampX.w,d1				; d1 = old stamp index
	cmp.w	d1,d0
	beq.s	.NoX

	move.w	d0,lastStampX.w

	; Recompute texOrgX = (camX - FD_START) mod 4096
	move.w	camX.w,d2
	subi.w	#FD_START,d2
	bpl.s	.TOXPos
	addi.w	#4096,d2
.TOXPos:
	cmpi.w	#4096,d2
	blt.s	.TOXDone
	subi.w	#4096,d2
.TOXDone:
	move.w	d2,texOrgX.w

	; Detect direction: d0 = new stamp, d1 = old stamp (both mod 128)
	; Moved right if ((d0 - d1) & 127) < 64, left otherwise.
	; Newly visible stamp column in map = rightmost or leftmost of window.
	move.w	d2,d3
	lsr.w	#5,d3					; d3 = texOrgX/32 (0..127)

	sub.w	d1,d0					; d0 = new - old (may wrap)
	andi.w	#$7F,d0
	cmpi.w	#64,d0
	bge.s	.MovedLeft				; moved left: write leftmost slot

	; Moved right: new column is at the right edge of the texture window
	; tex slot = (texOrgX/32 + FD_WSTAMPS - 1) mod FD_WSTAMPS
	move.w	d3,d2
	addi.w	#FD_WSTAMPS-1,d2
	; map col = (texOrgX/32 + FD_WSTAMPS - 1) mod 128
	move.w	d2,d5
	andi.w	#$7F,d5					; d5 = map stamp col (for WriteStampCol d3)
	andi.w	#FD_WSTAMPS-1,d2			; d2 = tex col slot
	move.w	d5,d3
	bra.s	.DoWriteCol

.MovedLeft:
	; tex slot = texOrgX/32 mod FD_WSTAMPS (leftmost)
	move.w	d3,d2
	andi.w	#FD_WSTAMPS-1,d2
	; map col = texOrgX/32 mod 128 = d3 & 127 = d3 (already < 128)
	andi.w	#$7F,d3

.DoWriteCol:
	bsr.w	WriteStampCol

.NoX:
	; ---- Y axis ----
	move.w	camY.w,d0
	lsr.w	#5,d0
	andi.w	#$7F,d0
	move.w	lastStampY.w,d1
	cmp.w	d1,d0
	beq.s	.NoY

	move.w	d0,lastStampY.w

	move.w	camY.w,d2
	subi.w	#FD_START,d2
	bpl.s	.TOYPos
	addi.w	#4096,d2
.TOYPos:
	cmpi.w	#4096,d2
	blt.s	.TOYDone
	subi.w	#4096,d2
.TOYDone:
	move.w	d2,texOrgY.w

	move.w	d2,d3
	lsr.w	#5,d3					; d3 = texOrgY/32

	sub.w	d1,d0
	andi.w	#$7F,d0
	cmpi.w	#64,d0
	bge.s	.MovedUp

	; Moved down: write bottom row slot
	move.w	d3,d2
	addi.w	#FD_WSTAMPS-1,d2
	move.w	d2,d5
	andi.w	#$7F,d5
	andi.w	#FD_WSTAMPS-1,d2
	move.w	d5,d3
	bra.s	.DoWriteRow

.MovedUp:
	move.w	d3,d2
	andi.w	#FD_WSTAMPS-1,d2
	andi.w	#$7F,d3

.DoWriteRow:
	bsr.w	WriteStampRow

.NoY:
	rts

; -------------------------------------------------------------------------
; WriteStampCol — write one column of FD_WSTAMPS stamps into FloorTex
; -------------------------------------------------------------------------
; d2.w = texture column slot (0..FD_WSTAMPS-1)
; d3.w = map stamp column index (0..127)
; Trashes d0-d5/a0-a3.
; -------------------------------------------------------------------------

WriteStampCol:
	; Destination x-byte offset in each tex row = d2 * 16
	mulu.w	#16,d2					; d2 = x byte offset in tex row

	; Loop over 7 stamp rows
	move.w	#FD_WSTAMPS-1,d7
	moveq	#0,d5					; d5 = stamp row ty (0..6)
.WCLoop:
	; map row = (lastStampY + ty) mod 128  — but we track texOrgY
	; Use: map_row = (texOrgY/32 + ty) mod 128
	move.w	texOrgY.w,d0
	lsr.w	#5,d0
	add.w	d5,d0
	andi.w	#$7F,d0					; d0 = map row

	; map address = (row*128 + col) * 2
	mulu.w	#128,d0
	add.w	d3,d0
	lsl.l	#1,d0
	lea	FloorStampMap,a0
	move.w	(a0,d0.l),d0				; raw map word
	andi.w	#$07FC,d0
	lsr.w	#2,d0					; d0 = sid

	; source = FloorStampsPacked + sid*512
	mulu.w	#512,d0
	lea	FloorStampsPacked,a2
	lea	(a2,d0.l),a2

	; destination = FloorTex + ty*32*FD_WPACKED + d2(x byte offset)
	move.l	d5,d0
	mulu.w	#32*FD_WPACKED,d0
	lea	FloorTex,a1
	lea	(a1,d0.l),a1
	adda.w	d2,a1					; move to correct column

	; copy 32 rows x 16 bytes; source rows are contiguous (a2 auto-advances)
	; destination rows are FD_WPACKED bytes apart
	move.w	#32-1,d4
.WCRow:
	move.l	(a2)+,(a1)
	move.l	(a2)+,4(a1)
	move.l	(a2)+,8(a1)
	move.l	(a2)+,12(a1)
	lea	FD_WPACKED(a1),a1
	dbf	d4,.WCRow

	addq.w	#1,d5
	dbf	d7,.WCLoop
	rts

; -------------------------------------------------------------------------
; WriteStampRow — write one row of FD_WSTAMPS stamps into FloorTex
; -------------------------------------------------------------------------
; d2.w = texture row slot (0..FD_WSTAMPS-1)
; d3.w = map stamp row index (0..127)
; Trashes d0-d5/a0-a3.
; -------------------------------------------------------------------------

WriteStampRow:
	; Destination first-row byte offset in FloorTex = d2 * 32 * FD_WPACKED
	mulu.w	#32*FD_WPACKED,d2			; d2 = y byte offset in tex

	; Loop over FD_WSTAMPS stamp columns
	move.w	#FD_WSTAMPS-1,d7
	moveq	#0,d5					; d5 = stamp col tx (0..6)
.WRLoop:
	; map col = (texOrgX/32 + tx) mod 128
	move.w	texOrgX.w,d0
	lsr.w	#5,d0
	add.w	d5,d0
	andi.w	#$7F,d0					; d0 = map col

	; map address = (row*128 + col) * 2
	move.w	d3,d1
	mulu.w	#128,d1
	add.w	d0,d1
	lsl.l	#1,d1
	lea	FloorStampMap,a0
	move.w	(a0,d1.l),d0
	andi.w	#$07FC,d0
	lsr.w	#2,d0					; d0 = sid

	; source = FloorStampsPacked + sid*512
	mulu.w	#512,d0
	lea	FloorStampsPacked,a2
	lea	(a2,d0.l),a2

	; destination = FloorTex + d2(y offset) + tx*16
	move.l	d5,d0
	mulu.w	#16,d0					; x byte offset
	lea	FloorTex,a1
	adda.l	d2,a1
	adda.l	d0,a1

	; copy 32 rows x 16 bytes
	move.w	#32-1,d4
.WRRow:
	move.l	(a2)+,(a1)
	move.l	(a2)+,4(a1)
	move.l	(a2)+,8(a1)
	move.l	(a2)+,12(a1)
	lea	FD_WPACKED(a1),a1
	dbf	d4,.WRRow

	addq.w	#1,d5
	dbf	d7,.WRLoop
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
FloorStampsPacked:
	incbin	"MD Port/Floor Demo/stamps_packed.bin"	; FD_NSTAMPS x 512 B (32 rows x 16 bytes each)
	even
FloorStampMap:
	incbin	"MD Port/Floor Demo/stamp_map.bin"	; 128x128 big-endian words
	even
FloorAngles:
	incbin	"MD Port/Floor Demo/angles.bin"
	even
ROMEnd:
