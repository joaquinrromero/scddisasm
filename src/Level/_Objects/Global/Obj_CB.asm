; Object $CB - Obj21_20F3E8 (from R82A, old ID $21)
PCB_Obj21_20F3E8:
	tst.b   oRoutine(a0)
	bne.w   PCB_loc_20F442
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.w  #$4e4, d0
	cmpi.b  #$2, act.l
	bne.s   PCB_loc_20F41E
	move.w  #$386, d0
PCB_loc_20F41E:
	move.w  d0, oTile(a0)
	move.l  #$20f4c2, oMap(a0)
	move.b  #$8, oYRadius(a0)
	lea     switchFlags.w, a1
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	lea     (a1, d0.w), a1
	move.w  a1, $3c(a0)
PCB_loc_20F442:
	move.b  $3f(a0), $3e(a0)
	lea     objects.w, a1
	jsr     SolidObject.l
	movea.w $3c(a0), a2
	sne.b   $3f(a0)
	bne.w   PCB_loc_20F466
	bclr.b  #$7, (a2)
	bra.w   PCB_loc_20F46E
PCB_loc_20F466:
	bset.b  #$7, (a2)
	bset.b  #$6, (a2)
PCB_loc_20F46E:
	cmpi.w  #$ff, $3e(a0)
	bne.w   PCB_loc_20F49C
	tst.b   oSprFlags(a0)
	bpl.s   PCB_loc_20F488
	move.w  #$bf, d0
	jsr     PlayFMSound.l
PCB_loc_20F488:
	bchg.b  #$5, (a2)
	addq.w  #$8, $c(a1)
	addq.w  #$4, oY(a0)
	addq.b  #$1, oMapFrame(a0)
	subq.b  #$4, oYRadius(a0)
PCB_loc_20F49C:
	cmpi.w  #$ff00, $3e(a0)
	bne.w   PCB_loc_20F4B6
	subq.w  #$8, $c(a1)
	subq.w  #$4, oY(a0)
	subq.b  #$1, oMapFrame(a0)
	addq.b  #$4, oYRadius(a0)
PCB_loc_20F4B6:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PCB_loc_20F4C2:
	dc.w	$0004,$000F,$02F8,$0500,$00F0,$F805,$0800,$0002
	dc.w	$FC04,$0004,$F0FC,$0408,$0400
