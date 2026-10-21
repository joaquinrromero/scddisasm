; Object $9B - Obj24_20D18A (from R61A, old ID $24)
P9B_Obj24_20D18A:
	tst.b   oRoutine(a0)
	bne.s   P9B_loc_20D1D2
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.w  #$39a, oTile(a0)
	move.l  #$20d24a, oMap(a0)
	move.b  #$8, oYRadius(a0)
	lea     switchFlags.w, a1
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	lea     (a1, d0.w), a1
	move.w  a1, $3c(a0)
P9B_loc_20D1D2:
	move.b  $3f(a0), $3e(a0)
	lea     objects.w, a1
	jsr     SolidObject.l
	movea.w $3c(a0), a4
	sne.b   $3f(a0)
	bne.s   P9B_loc_20D1F2
	bclr.b  #$7, (a4)
	bra.s   P9B_loc_20D1FA
P9B_loc_20D1F2:
	bset.b  #$7, (a4)
	bset.b  #$6, (a4)
P9B_loc_20D1FA:
	cmpi.w  #$ff, $3e(a0)
	bne.s   P9B_loc_20D226
	tst.b   oSprFlags(a0)
	bpl.s   P9B_loc_20D212
	move.w  #$bf, d0
	jsr     PlayFMSound.l
P9B_loc_20D212:
	bchg.b  #$5, (a4)
	addq.w  #$8, $c(a1)
	addq.w  #$4, oY(a0)
	addq.b  #$1, oMapFrame(a0)
	subq.b  #$4, oYRadius(a0)
P9B_loc_20D226:
	cmpi.w  #$ff00, $3e(a0)
	bne.s   P9B_loc_20D23E
	subq.w  #$8, $c(a1)
	subq.w  #$4, oY(a0)
	subq.b  #$1, oMapFrame(a0)
	addq.b  #$4, oYRadius(a0)
P9B_loc_20D23E:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P9B_loc_20D24A:
	dc.w	$0004,$0010,$02F8,$0500,$00F0,$F805,$0800,$0000
	dc.w	$02FC,$0400,$04F0,$FC04,$0804,$0000
