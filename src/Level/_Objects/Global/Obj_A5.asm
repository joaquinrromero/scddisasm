; Object $A5 - Obj35_20F5E6 (from R71A, old ID $35)
PA5_Obj35_20F5E6:
	tst.b   oRoutine(a0)
	bne.s   PA5_loc_20F610
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$20, oXRadius(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$11, oYRadius(a0)
	move.l  #$20f650, oMap(a0)
PA5_loc_20F610:
	move.b  debugCheat.l, oMapFrame(a0)
	tst.b   layer.l
	beq.s   PA5_loc_20F630
	lea     objects.w, a1
	jsr     SolidObject.l
	sne.b   $2a(a0)
	bra.s   PA5_loc_20F644
PA5_loc_20F630:
	tst.b   $2a(a0)
	beq.s   PA5_loc_20F644
	clr.b   $2a(a0)
	lea     objects.w, a1
	jsr     GetOffObject.l
PA5_loc_20F644:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PA5_loc_20F650:
	dc.w	$0004,$0005,$0002,$F00F,$0000,$E0F0,$0F00,$0000
