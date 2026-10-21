; Object $47 - Obj47_20B6C0 (from R43C, old ID $47)
P47_Obj47_20B6C0:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P47_dat_20B6E4(pc, d0.w), d0
	jsr     P47_dat_20B6E4(pc, d0.w)
	lea     objects.w, a1
	jsr     SolidObject.l
	jsr     DrawObject.l
	jmp     P47_loc_20B7DC.l
P47_dat_20B6E4:
	dc.w	P47_loc_20B6EC-P47_dat_20B6E4
	dc.w	P47_loc_20B776-P47_dat_20B6E4
	dc.w	P47_loc_20B7AC-P47_dat_20B6E4
	dc.w	P47_loc_20B7C0-P47_dat_20B6E4
P47_loc_20B6EC:
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$40, oXRadius(a0)
	move.b  #$40, oWidth(a0)
	move.b  #$40, oYRadius(a0)
	move.w  #$446a, oTile(a0)
	move.l  #$20b810, oMap(a0)
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
	bne.s   P47_loc_20B75E
	move.w  #$10, d0
	move.b  oSubtype(a0), d1
	beq.s   P47_loc_20B750
	addi.w  #$10, d0
P47_loc_20B750:
	move.w  d0, $2a(a0)
	addq.b  #$1, d1
	add.b   d1, d1
	move.b  d1, oRoutine(a0)
	rts     
P47_loc_20B75E:
	move.w  #$40, d0
	tst.b   oSubtype(a0)
	beq.s   P47_loc_20B76C
	addi.w  #$40, d0
P47_loc_20B76C:
	add.w   d0, oY(a0)
	addq.b  #$4, oRoutine(a0)
	rts     
P47_loc_20B776:
	lea     objects.w, a6
	bsr.s   P47_sub_20B788
	bcc.s   P47_loc_20B786
	st.b    $3f(a0)
	addq.b  #$2, oRoutine(a0)
P47_loc_20B786:
	rts     
P47_sub_20B788:
	move.w  $c(a6), d0
	sub.w   oY(a0), d0
	subi.w  #$0, d0
	subi.w  #$80, d0
	bcc.s   P47_loc_20B7AA
	move.w  $8(a6), d0
	sub.w   oX(a0), d0
	subi.w  #$a0, d0
	subi.w  #$20, d0
P47_loc_20B7AA:
	rts     
P47_loc_20B7AC:
	tst.b   $3f(a0)
	beq.s   P47_loc_20B7BE
	movea.l $2c(a0), a1
	bset.b  #$0, (a1)
	addq.b  #$2, oRoutine(a0)
P47_loc_20B7BE:
	rts     
P47_loc_20B7C0:
	addi.l  #$40000, oY(a0)
	addi.w  #$ffff, $2a(a0)
	bne.s   P47_loc_20B7DA
	sf.b    $3f(a0)
	addi.b  #$fe, oRoutine(a0)
P47_loc_20B7DA:
	rts     
P47_loc_20B7DC:
	cmpi.b  #$1, oSubtype(a0)
	beq.s   P47_loc_20B80E
	move.w  oX(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bls.s   P47_loc_20B80E
	movea.l $2c(a0), a1
	bclr.b  #$7, (a1)
	jmp     DeleteObject.l
P47_loc_20B80E:
	rts     
P47_loc_20B810:
	dc.w	$0002,$10C0,$0F00,$00C0,$C00F,$0000,$E0C0,$0F00
	dc.w	$0000,$C00F,$0000,$20E0,$0F00,$00C0,$E00F,$0000
	dc.w	$E0E0,$0F00,$0000,$E00F,$0000,$2000,$0F00,$00C0
	dc.w	$000F,$0000,$E000,$0F00,$0000,$000F,$0000,$2020
	dc.w	$0F00,$00C0,$200F,$0000,$E020,$0F00,$0000,$200F
	dc.w	$0000,$2000
