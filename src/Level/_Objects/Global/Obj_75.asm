; Object $75 - Obj09_2062FE (from R82A, old ID $09)
P75_Obj09_2062FE:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P75_dat_206318(pc, d0.w), d0
	jsr     P75_dat_206318(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P75_dat_206318:
	dc.w	P75_loc_20631C-P75_dat_206318
	dc.w	P75_loc_206340-P75_dat_206318
P75_loc_20631C:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.l  #$20634a, oMap(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
P75_loc_206340:
	lea     objects.w, a1
	jmp     SolidObject.l
P75_loc_20634A:
	dc.w	$0002,$0000
