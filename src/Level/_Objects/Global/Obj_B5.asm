; Object $B5 - Obj25_20C654 (from R81A, old ID $25)
PB5_Obj25_20C654:
	tst.b   oLayer(a0)
	bne.w   ObjSpring2
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PB5_dat_20C66A(pc, d0.w), d0
	jmp     PB5_dat_20C66A(pc, d0.w)
PB5_dat_20C66A:
	dc.w	PB5_loc_20C674-PB5_dat_20C66A
	dc.w	PB5_loc_20C6D0-PB5_dat_20C66A
	dc.w	PB5_loc_20C70E-PB5_dat_20C66A
	dc.w	PB5_loc_20C728-PB5_dat_20C66A
	dc.w	PB5_loc_20C7D0-PB5_dat_20C66A
PB5_loc_20C674:
	move.b  #$4, oSprFlags(a0)
	move.l  #$20c84e, oMap(a0)
	move.b  #$11, oYRadius(a0)
	move.w  #$44d8, d0
	cmpi.b  #$2, act.l
	bne.s   PB5_loc_20C69A
	move.w  #$437a, d0
PB5_loc_20C69A:
	move.w  d0, oTile(a0)
	move.b  oSubtype(a0), d0
	bpl.s   PB5_loc_20C6A6
	neg.b   d0
PB5_loc_20C6A6:
	move.b  d0, d1
	subq.b  #$1, d0
	move.b  d0, oMapFrame(a0)
	lsl.b   #$3, d1
	move.b  d1, oXRadius(a0)
	move.b  d1, oWidth(a0)
	moveq   #$3, d0
	moveq   #$2, d1
	tst.b   oSubtype(a0)
	bpl.s   PB5_loc_20C6C6
	moveq   #$1, d0
	moveq   #$8, d1
PB5_loc_20C6C6:
	move.b  d0, oPriority(a0)
	move.b  d1, oRoutine(a0)
	rts     
PB5_loc_20C6D0:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	beq.s   PB5_loc_20C702
	addq.b  #$2, oRoutine(a0)
	clr.b   oSavedFlagsID(a0)
	move.w  #$8, $2a(a0)
	moveq   #$8, d0
	tst.w   $FFFFD010.w
	bpl.s   PB5_loc_20C6F4
	neg.w   d0
PB5_loc_20C6F4:
	move.w  d0, $2c(a0)
	move.w  #$a3, d0
	jsr     PlayFMSound.l
PB5_loc_20C702:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PB5_loc_20C70E:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	subq.w  #$1, $2a(a0)
	bpl.s   PB5_loc_20C722
	addq.b  #$2, oRoutine(a0)
PB5_loc_20C722:
	jmp     DrawObject.l
PB5_loc_20C728:
	movem.l (a0), a2-a5
	moveq   #$ff, d1
	moveq   #$8, d2
	moveq   #$0, d3
	move.b  oSubtype(a0), d3
	subq.w  #$1, d3
	asl.w   #$3, d3
	tst.w   $2c(a0)
	bmi.s   PB5_loc_20C742
	neg.w   d3
PB5_loc_20C742:
	jsr     FindObjSlot.l
	bne.w   PB5_loc_20C788
	movem.l a2-a5, (a1)
	move.b  d1, $29(a1)
	sub.w   d2, $c(a1)
	add.w   d3, $8(a1)
	move.w  #$4, $2a(a1)
	move.b  #$8, $1a(a1)
	jsr     FindObjSlot.l
	bne.w   PB5_loc_20C788
	movem.l a2-a5, (a1)
	move.b  d1, $29(a1)
	add.w   d2, $c(a1)
	add.w   d3, $8(a1)
	move.b  #$9, $1a(a1)
PB5_loc_20C788:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	beq.s   PB5_loc_20C79A
	jsr     GetOffObject.l
PB5_loc_20C79A:
	subq.b  #$1, oSubtype(a0)
	ble.w   loc_20C848
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
PB5_loc_20C7D0:
	lea     objects.w, a1
	jsr     SolidObject.l
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
