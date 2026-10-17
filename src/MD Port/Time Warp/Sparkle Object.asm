; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Sparkle object (time warp)
; -------------------------------------------------------------------------

ObjSparkle:
	moveq	#0,d0				; Run routine
	move.b	twoRoutine(a0),d0
	add.w	d0,d0
	move.w	.Index(pc,d0.w),d0
	jmp	.Index(pc,d0.w)

; -------------------------------------------------------------------------

.Index:
	dc.w	ObjSparkle_Init-.Index
	dc.w	ObjSparkle_Main-.Index

; -------------------------------------------------------------------------

ObjSparkle_Init:
	move.w	#0,twoTile(a0)			; Base tile ID
	move.l	#MapSpr_Sparkle,twoMap(a0)	; Mappings
	
	moveq	#0,d0				; Set animation
	jsr	SetObjAnim(pc)
	
	addq.b	#1,twoRoutine(a0)			; Set to main routine
	
	bsr.w	TWRandom				; Set random Y velocity
	move.w	d0,d1
	andi.l	#$3FFFF,d0
	move.l	d0,twoYVel(a0)
	
	andi.w	#$1F,d1				; Set random X offset relative to Sonic
	move.w	sonicObject+twoX.w,twoX(a0)
	subi.w	#$10,twoX(a0)
	add.w	d1,twoX(a0)
	
	move.w	sonicObject+twoY.w,twoY(a0)		; Set Y offset relative to Sonic
	subi.w	#$18,twoY(a0)
	
	move.w	#45,twoTimer(a0)			; Set timer

; -------------------------------------------------------------------------

ObjSparkle_Main:
	move.l	twoXVel(a0),d0			; Move
	add.l	d0,twoX(a0)
	move.l	twoYVel(a0),d0
	add.l	d0,twoY(a0)
	
	subq.w	#1,twoTimer(a0)			; Decrement timer
	bne.s	.End				; If it hasn't run out, branch
	bset	#0,twoFlags(a0)			; Delete object

.End:	
	rts


; -------------------------------------------------------------------------

MapSpr_Sparkle:
	include	"Time Warp Cutscene/Objects/Sparkle/Data/Mappings.asm"
	even

; -------------------------------------------------------------------------
