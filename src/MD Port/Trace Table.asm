; -------------------------------------------------------------------------
; Sonic CD Disassembly - Mega Drive port
; -------------------------------------------------------------------------
; Division-free trace table generator for the special stage floor
; -------------------------------------------------------------------------
; The special stage pitch is always $80 (set once in Objects/Sonic/Main.asm),
; so with FOV = $80 and center = -$40 the original GenGfxTraceTbl formulas
; collapse to (row = 3-95, yaw sine ys, yaw cosine yc):
;
;	Z point  = -8 * row                     (the only divisor, per row)
;	(FOV*sin(pitch) = $8000 is read as -$8000 by the original's muls.w, so
;	 its sin(yaw) term has a negative sign; that is reproduced here)
;	u        = camZ / Z point               (one table lookup + 1 muls)
;	X start  = camX*8 - 2*ys - ((ys+yc)*4)  * u
;	Y start  = camY*8 + 2*yc + ((yc-ys)*4)  * u
;	X delta  =              ((2040*yc)>>8)  * u
;	Y delta  =              ((2040*ys)>>8)  * u
;
; That is 5 muls per row and no divs (the original spends 9 muls + 4 divs).
; Output has the same format as the original trace table: 4 words per row
; (X start, Y start, X delta, Y delta), first 3 rows blanked.
; Verified against the original formulas: max sample position error ~1 px.
;
; INPUT:  gfxVars (camera X/Y/Z, yaw sine/cosine; run GetGfxSines first)
; OUTPUT: TRACETBLMD
; -------------------------------------------------------------------------

GenGfxTraceTblMD:
	lea	gfxVars,a6			; Graphics operations variables
	lea	TRACETBLMD,a5			; Trace table buffer

	move.l	#$FFF8,(a5)+			; Blank out first 3 lines
	move.l	#0,(a5)+
	move.l	#$FFF8,(a5)+
	move.l	#0,(a5)+
	move.l	#$FFF8,(a5)+
	move.l	#0,(a5)+

	move.w	gfxCamX(a6),d0			; Camera X
	lsl.w	#3,d0
	move.w	gfxCamY(a6),d1			; Camera Y
	lsl.w	#3,d1
	move.w	gfxYawSin(a6),d2		; ys
	move.w	gfxYawCos(a6),d3		; yc

	move.w	d2,d4				; X base = camX*8 - 2*ys
	add.w	d4,d4
	sub.w	d4,d0
	move.w	d3,d4				; Y base = camY*8 + 2*yc
	add.w	d4,d4
	add.w	d4,d1

	move.w	d2,d5				; X start factor = -(ys + yc)
	add.w	d3,d5
	neg.w	d5
	move.w	d3,d6				; Y start factor = yc - ys
	sub.w	d2,d6

	muls.w	#2040,d3			; X delta factor = (2040*yc)>>8
	asr.l	#8,d3
	move.w	d3,d7
	muls.w	#2040,d2			; Y delta factor = (2040*ys)>>8
	asr.l	#8,d2
	move.w	d2,-(sp)			; (kept on the stack, out of registers)

	moveq	#10,d4				; Shift for the Z scale
	lea	TraceRecip(pc),a0
	lea	TraceRecipEnd(pc),a4

.Row:
	move.w	(a0)+,d2			; u = (camZ * recip(row)) >> 10
	muls.w	gfxCamZ(a6),d2
	asr.l	d4,d2

	move.w	d5,d3				; X start
	muls.w	d2,d3
	asr.l	#6,d3
	add.w	d0,d3
	move.w	d3,(a5)+

	move.w	d6,d3				; Y start
	muls.w	d2,d3
	asr.l	#6,d3
	add.w	d1,d3
	move.w	d3,(a5)+

	move.w	d7,d3				; X delta
	muls.w	d2,d3
	asr.l	#8,d3
	move.w	d3,(a5)+

	move.w	(sp),d3				; Y delta
	muls.w	d2,d3
	asr.l	#8,d3
	move.w	d3,(a5)+

	cmpa.l	a4,a0
	bne.s	.Row

	addq.l	#2,sp				; Free the stack slot
	rts

; -------------------------------------------------------------------------
; Reciprocal table: round(-32768 / row) for rows 3-95
; -------------------------------------------------------------------------

TraceRecip:
traceRow	set	3
	rept	93
		dc.w	-((32768+(traceRow/2))/traceRow)
traceRow	set	traceRow+1
	endr
TraceRecipEnd:
	even
