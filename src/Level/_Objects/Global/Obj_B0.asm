; Object $B0 - Obj24_20E34A (from R71A, old ID $24)
PB0_Obj24_20E34A:
	tst.b   oRoutine(a0)
	bne.s   PB0_loc_20E38E
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$4376, oTile(a0)
	move.l  #$20e3b0, oMap(a0)
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	move.b  d0, oMapFrame(a0)
	add.w   d0, d0
	lea     PB0_dat_20E3A4(pc, d0.w), a1
	move.b  (a1)+, d0
	move.b  (a1), d1
	move.b  d0, oXRadius(a0)
	move.b  d0, oWidth(a0)
	move.b  d1, oYRadius(a0)
PB0_loc_20E38E:
	lea     objects.w, a1
	jsr     SolidObject.l
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PB0_dat_20E3A4:
	dc.w	$0C11,$1C11,$2C11,$3C11,$0C21,$0C31
PB0_loc_20E3B0:
	dc.w	$000C,$0012,$001D,$002D,$0042,$004D,$01F0,$0F00
	dc.w	$00F0,$02F0,$0F00,$00E0,$F00F,$0000,$0003,$F00F
	dc.w	$0000,$D0F0,$0F00,$00F0,$F00F,$0000,$1004,$F00F
	dc.w	$0000,$C0F0,$0F00,$00E0,$F00F,$0000,$00F0,$0F00
	dc.w	$0020,$02E0,$0F00,$00F0,$000F,$0000,$F003,$D00F
	dc.w	$0000,$F0F0,$0F00,$00F0,$100F,$0000,$F000
