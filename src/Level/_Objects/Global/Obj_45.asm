; Object $45 - Obj45_20EF66 (from R42A, old ID $45)
P45_Obj45_20EF66:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P45_dat_20EF80(pc, d0.w), d0
	jsr     P45_dat_20EF80(pc, d0.w)
	jsr     DrawObject.l
	jmp     P45_loc_20F03E.l
P45_dat_20EF80:
	dc.w	P45_loc_20EF88-P45_dat_20EF80
	dc.w	P45_loc_20EFFA-P45_dat_20EF80
	dc.w	P45_loc_20F00E-P45_dat_20EF80
	dc.w	P45_sub_20F034-P45_dat_20EF80
P45_loc_20EF88:
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$20, oXRadius(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$40, oYRadius(a0)
	move.w  #$446a, oTile(a0)
	move.l  #$20f06a, oMap(a0)
	moveq   #$0, d0
	move.b  oSavedFlagsID(a0), d0
	lea     savedObjFlags.l, a1
	move.w  d0, d1
	add.w   d1, d1
	add.w   d1, d0
	moveq   #$0, d1
	move.b  timeZone.l, d1
	add.w   d1, d0
	lea     $2(a1, d0.w), a1
	move.l  a1, $2c(a0)
	btst.b  #$0, (a1)
	bne.s   P45_loc_20EFEE
	bset.b  #$0, (a1)
	move.w  #$3c, $2a(a0)
	addq.b  #$2, oRoutine(a0)
	rts     
P45_loc_20EFEE:
	addi.w  #$c0, oX(a0)
	addq.b  #$6, oRoutine(a0)
	rts     
P45_loc_20EFFA:
	addi.w  #$ffff, $2a(a0)
	bne.s   P45_loc_20F00C
	move.w  #$180, $2a(a0)
	addq.b  #$2, oRoutine(a0)
P45_loc_20F00C:
	bra.s   P45_sub_20F034
P45_loc_20F00E:
	bsr.s   P45_sub_20F034
	beq.s   P45_loc_20F01E
	move.l  #$8000, d0
	asr.l   #$8, d0
	move.w  d0, $14(a1)
P45_loc_20F01E:
	addi.l  #$8000, oX(a0)
	addi.w  #$ffff, $2a(a0)
	bne.s   P45_loc_20F032
	addq.b  #$2, oRoutine(a0)
P45_loc_20F032:
	rts     
P45_sub_20F034:
	lea     objects.w, a1
	jmp     SolidObject.l
P45_loc_20F03E:
	move.w  oX(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bls.s   P45_loc_20F068
	movea.l $2c(a0), a1
	bclr.b  #$7, (a1)
	jmp     DeleteObject.l
P45_loc_20F068:
	rts     
