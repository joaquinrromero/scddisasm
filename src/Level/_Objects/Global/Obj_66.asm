; Object $66 - Obj39_20F23E (from R41A, old ID $39)
P66_Obj39_20F23E:
	tst.b   oLayer(a0)
	bne.w   P66_loc_20F38A
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P66_dat_20F254(pc, d0.w), d0
	jmp     P66_dat_20F254(pc, d0.w)
P66_dat_20F254:
	dc.w	P66_loc_20F25C-P66_dat_20F254
	dc.w	P66_loc_20F296-P66_dat_20F254
	dc.w	P66_loc_20F2D4-P66_dat_20F254
	dc.w	P66_loc_20F2EE-P66_dat_20F254
P66_loc_20F25C:
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.w  #$4364, oTile(a0)
	move.l  #$20f3f8, oMap(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$11, oYRadius(a0)
	move.b  oSubtype(a0), d0
	move.b  d0, d1
	subq.b  #$1, d0
	move.b  d0, oMapFrame(a0)
	lsl.b   #$3, d1
	move.b  d1, oXRadius(a0)
	move.b  d1, oWidth(a0)
P66_loc_20F296:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	beq.s   P66_loc_20F2C8
	addq.b  #$2, oRoutine(a0)
	clr.b   oSavedFlagsID(a0)
	move.w  #$8, $2a(a0)
	moveq   #$8, d0
	tst.w   $FFFFD010.w
	bpl.s   P66_loc_20F2BA
	neg.w   d0
P66_loc_20F2BA:
	move.w  d0, $2c(a0)
	move.w  #$a3, d0
	jsr     PlayFMSound.l
P66_loc_20F2C8:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P66_loc_20F2D4:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	subq.w  #$1, $2a(a0)
	bpl.s   P66_loc_20F2E8
	addq.b  #$2, oRoutine(a0)
P66_loc_20F2E8:
	jmp     DrawObject.l
P66_loc_20F2EE:
	movem.l (a0), a2-a5
	moveq   #$ff, d1
	moveq   #$8, d2
	moveq   #$0, d3
	move.b  oSubtype(a0), d3
	subq.w  #$1, d3
	asl.w   #$3, d3
	tst.w   $2c(a0)
	bmi.s   P66_loc_20F308
	neg.w   d3
P66_loc_20F308:
	jsr     FindObjSlot.l
	bne.w   P66_loc_20F342
	movem.l a2-a5, (a1)
	move.b  d1, $29(a1)
	sub.w   d2, $c(a1)
	add.w   d3, $8(a1)
	move.w  #$4, $2a(a1)
	jsr     FindObjSlot.l
	bne.w   P66_loc_20F342
	movem.l a2-a5, (a1)
	move.b  d1, $29(a1)
	add.w   d2, $c(a1)
	add.w   d3, $8(a1)
P66_loc_20F342:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	beq.s   P66_loc_20F354
	jsr     GetOffObject.l
P66_loc_20F354:
	subq.b  #$1, oSubtype(a0)
	ble.w   P66_loc_20F3F2
	subq.b  #$2, oRoutine(a0)
	subq.b  #$1, oMapFrame(a0)
	subq.b  #$8, oXRadius(a0)
	subq.b  #$8, oWidth(a0)
	move.w  #$7, $2a(a0)
	move.w  $2c(a0), d0
	add.w   d0, oX(a0)
	lea     objects.w, a1
	jsr     TopSolidObject.l
	jmp     DrawObject.l
P66_loc_20F38A:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P66_dat_20F398(pc, d0.w), d0
	jmp     P66_dat_20F398(pc, d0.w)
P66_dat_20F398:
	dc.w	P66_loc_20F39E-P66_dat_20F398
	dc.w	P66_loc_20F3B6-P66_dat_20F398
	dc.w	P66_loc_20F3C6-P66_dat_20F398
P66_loc_20F39E:
	addq.b  #$2, oRoutine(a0)
	move.b  #$8, oMapFrame(a0)
	move.l  #$8080308, oYRadius(a0)
	jmp     DrawObject.l
P66_loc_20F3B6:
	subq.w  #$1, $2a(a0)
	bpl.s   P66_loc_20F3C0
	addq.b  #$2, oRoutine(a0)
P66_loc_20F3C0:
	jmp     DrawObject.l
P66_loc_20F3C6:
	tst.b   oSprFlags(a0)
	bpl.s   P66_loc_20F3F2
	move.l  $2c(a0), d0
	addi.l  #$4000, d0
	cmpi.l  #$160000, d0
	ble.s   P66_loc_20F3E4
	move.l  #$160000, d0
P66_loc_20F3E4:
	move.l  d0, $2c(a0)
	add.l   d0, oY(a0)
	jmp     DrawObject.l
P66_loc_20F3F2:
	jmp     DeleteObject.l
