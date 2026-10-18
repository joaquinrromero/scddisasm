; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Sonic object (time warp)
; -------------------------------------------------------------------------

TWObjSonic:
	moveq	#0,d0				; Run routine
	move.b	twoRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	TWObjSonic_Init-.Index
	dc.w	TWObjSonic_Enter-.Index
	dc.w	TWObjSonic_Wait-.Index
	dc.w	TWObjSonic_Leave-.Index
	dc.w	TWObjSonic_Done-.Index

; -------------------------------------------------------------------------

TWObjSonic_Init:	
	move.w	#$8000,twoTile(a0)		; Base tile ID
	move.l	#TWMapSpr_Sonic,twoMap(a0)		; Mappings
	move.w	#160+128,twoX(a0)			; Set position
	move.w	#288+128,twoY(a0)
	
	moveq	#0,d0				; Set animation
	jsr	SetObjAnim(pc)
	
	addq.b	#1,twoRoutine(a0)			; Enter in

; -------------------------------------------------------------------------

TWObjSonic_Enter:	
	subq.w	#8,twoY(a0)			; Move up
	cmpi.w	#120+128,twoY(a0)			; Have we moved up enough?
	bne.s	.End				; If not, branch
	addq.b	#1,twoRoutine(a0)			; Stop moving
	move.b	#120,twoTimer(a0)

.End:	
	rts

; -------------------------------------------------------------------------

TWObjSonic_Wait:	
	subq.b	#1,twoTimer(a0)			; Decrement timer
	bne.s	.End				; If it hasn't run out, branch
	addq.b	#1,twoRoutine(a0)			; Exit out

.End:	
	rts

; -------------------------------------------------------------------------

TWObjSonic_Leave:	
	subq.w	#8,twoY(a0)			; Move up
	cmpi.w	#-32+128,twoY(a0)			; Have we moved up enough?
	bne.s	TWObjSonic_Done			; If not, branch
	addq.b	#1,twoRoutine(a0)			; Stop

; -------------------------------------------------------------------------

TWObjSonic_Done:
	rts

; -------------------------------------------------------------------------

TWMapSpr_Sonic:
	include	"Time Warp Cutscene/Objects/Sonic/Data/Mappings.asm"
	even
	
; -------------------------------------------------------------------------
