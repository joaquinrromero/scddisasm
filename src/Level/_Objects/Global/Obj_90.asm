; Object $90 - Obj3DPlant (from R82A, old ID $1D)
Obj3DPlant:
	lea     objects.w, a6
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  Obj3DPlant_Index(pc, d0.w), d0
	jsr     Obj3DPlant_Index(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
Obj3DPlant_Index:
	dc.w	P90_loc_20B482-Obj3DPlant_Index
	dc.w	P90_loc_20B4BA-Obj3DPlant_Index
	dc.w	P90_loc_20B532-Obj3DPlant_Index
	dc.w	P90_loc_20B5B0-Obj3DPlant_Index
	dc.w	P90_loc_20B5F2-Obj3DPlant_Index
P90_loc_20B482:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$3e0, oTile(a0)
	move.l  #$23c15c, oMap(a0)
	move.b  #$1, oMapFrame(a0)
	tst.b   oSubtype(a0)
	beq.s   P90_loc_20B4B4
	move.b  #$2, oMapFrame(a0)
	move.l  #$23c186, oMap(a0)
P90_loc_20B4B4:
	move.b  #$1, $2a(a0)
P90_loc_20B4BA:
	subq.b  #$1, $2a(a0)
	bne.s   P90_loc_20B530
	jsr     FindNextObjSlot.l
	bne.s   P90_loc_20B530
	dc.b	$13,$7C,$00,$1D,$00,$00		; move.b #$1d, $0(a1) (raw: not reproducible by assembler)
	move.b  #$4, $24(a1)
	move.w  oTile(a0), $2(a1)
	move.l  oMap(a0), $4(a1)
	ori.b   #$4, $1(a1)
	move.b  #$2, $18(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  oSubtype(a0), $28(a1)
	andi.w  #$fff0, $c(a1)
	move.b  #$4, $16(a1)
	move.b  #$1e, $2a(a0)
	move.w  #$c5, d0
	tst.b   oSubtype(a0)
	beq.s   P90_loc_20B524
	move.b  #$1e, $2a(a0)
	move.w  #$bc, d0
P90_loc_20B524:
	tst.b   oSprFlags(a0)
	bpl.s   P90_loc_20B530
	jsr     PlayFMSound.l
P90_loc_20B530:
	rts     
P90_loc_20B532:
	move.w  oY(a0), d0
	addq.w  #$4, d0
	move.w  d0, d1
	move.w  d0, oY(a0)
	andi.b  #$f, d1
	bne.s   P90_loc_20B556
	addq.b  #$1, oAnim(a0)
	cmpi.b  #$7, oAnim(a0)
	bcs.s   P90_loc_20B556
	move.b  #$7, oAnim(a0)
P90_loc_20B556:
	lea     loc_21DA00.l, a1
	jsr     AnimateObject.l
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P90_loc_20B5AC
	addq.b  #$2, oRoutine(a0)
	jsr     FindNextObjSlot.l
	bne.s   P90_loc_20B5AC
	dc.b	$13,$7C,$00,$1D,$00,$00		; move.b #$1d, $0(a1) (raw: not reproducible by assembler)
	move.w  oTile(a0), $2(a1)
	move.l  oMap(a0), $4(a1)
	ori.b   #$4, $1(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  #$8, $24(a1)
	move.b  #$8, $1c(a1)
	move.l  a1, $2c(a0)
P90_loc_20B5AC:
	bra.w   P90_loc_20B60A
P90_loc_20B5B0:
	move.w  oY(a0), d0
	addq.w  #$4, d0
	move.w  d0, d1
	andi.w  #$f, d1
	bne.s   P90_loc_20B5CE
	subi.w  #$10, d0
	move.b  oAnim(a0), d1
	subq.b  #$1, d1
	bmi.s   P90_loc_20B5E2
	move.b  d1, oAnim(a0)
P90_loc_20B5CE:
	move.w  d0, oY(a0)
	lea     loc_21DA00.l, a1
	jsr     AnimateObject.l
	bra.w   P90_loc_20B60A
P90_loc_20B5E2:
	movea.l $2c(a0), a1
	move.b  #$1, $2a(a1)
	jmp     DeleteObject.l
P90_loc_20B5F2:
	tst.b   $2a(a0)
	beq.s   P90_loc_20B5FE
	jmp     DeleteObject.l
P90_loc_20B5FE:
	lea     loc_21DA00.l, a1
	jmp     AnimateObject.l
P90_loc_20B60A:
	cmpi.b  #$2b, $1c(a6)
	beq.s   P90_loc_20B620
	tst.b   oSubtype(a0)
	bne.s   P90_loc_20B622
	tst.b   miniSonic.l
	beq.s   P90_loc_20B62A
P90_loc_20B620:
	rts     
P90_loc_20B622:
	tst.b   miniSonic.l
	beq.s   P90_loc_20B620
P90_loc_20B62A:
	tst.b   debugMode.l
	bne.w   P90_loc_20B6DC
	move.b  $17(a6), d1
	ext.w   d1
	addq.w  #$4, d1
	move.w  oX(a0), d0
	sub.w   $8(a6), d0
	add.w   d1, d0
	bmi.w   P90_loc_20B6DC
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.w   P90_loc_20B6DC
	move.w  $16(a6), d1
	ext.w   d1
	move.w  $c(a6), d2
	add.w   d1, d2
	moveq   #$0, d0
	move.b  oAnim(a0), d0
	move.b  P90_dat_20B6DE(pc, d0.w), d0
	ext.w   d0
	add.w   oY(a0), d0
	cmp.w   d2, d0
	bcc.s   P90_loc_20B6DC
	move.w  $c(a6), d2
	sub.w   d1, d2
	move.w  oY(a0), d0
	addq.w  #$4, d0
	cmp.w   d0, d2
	bcc.s   P90_loc_20B6DC
	move.b  #$4, $24(a6)
	bset.b  #$1, $22(a6)
	move.w  #$fc00, $12(a6)
	move.w  #$fe00, $10(a6)
	move.w  $8(a6), d0
	cmp.w   oX(a0), d0
	bcs.s   P90_loc_20B6A8
	neg.w   $10(a6)
P90_loc_20B6A8:
	move.w  #$0, $14(a6)
	move.b  #$38, $1c(a6)
	move.b  #$a, $16(a6)
	move.b  #$5, $17(a6)
	eori.b  #$1, miniSonic.l
	tst.b   miniSonic.l
	bne.s   P90_loc_20B6DC
	move.b  #$13, $16(a6)
	move.b  #$9, $17(a6)
P90_loc_20B6DC:
	rts     
P90_dat_20B6DE:
	dc.w	$F4E4,$D4C4,$B4A4,$9484
