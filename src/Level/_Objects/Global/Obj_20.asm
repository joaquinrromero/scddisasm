; Object $20 - ObjCollapsePlatform (from R11A, old ID $20)
ObjCollapsePlatform:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjCollapsePlatform_Index(pc, d0.w), d0
	jsr     ObjCollapsePlatform_Index(pc, d0.w)
	jsr     DrawObject.l
	cmpi.b  #$4, oRoutine(a0)
	bge.s   P20_loc_20C238
	jmp     CheckObjDespawn.l
P20_loc_20C238:
	rts     
ObjCollapsePlatform_Index:
	dc.w	ObjCollapsePlatform_Init-ObjCollapsePlatform_Index
	dc.w	ObjCollapsePlatform_Main-ObjCollapsePlatform_Index
	dc.w	ObjCollapsePlatform_Delay-ObjCollapsePlatform_Index
	dc.w	ObjCollapsePlatform_Fall-ObjCollapsePlatform_Index
ObjCollapsePlatform_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$44be, oTile(a0)
	lea     MapSpr_CollapsePlatform1(pc), a1
	lea     ObjCollapsePlatform_Sizes1(pc), a2
	move.b  oSubtype(a0), d0
	bpl.s   P20_loc_20C26E
	lea     MapSpr_CollapsePlatform2(pc), a1
	lea     ObjCollapsePlatform_Sizes2(pc), a2
P20_loc_20C26E:
	move.l  a1, oMap(a0)
	btst.l  #$4, d0
	beq.s   P20_loc_20C284
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$0, oFlags(a0)
P20_loc_20C284:
	andi.w  #$f, d0
	move.b  d0, oMapFrame(a0)
	add.w   d0, d0
	move.w  (a2, d0.w), d0
	move.b  (a2, d0.w), d1
	addq.b  #$1, d1
	asl.b   #$3, d1
	move.b  d1, oXRadius(a0)
	move.b  d1, oWidth(a0)
	move.b  $1(a2, d0.w), d1
	bpl.s   P20_loc_20C2AA
	neg.b   d1
P20_loc_20C2AA:
	addq.b  #$1, d1
	asl.b   #$3, d1
	addq.b  #$2, d1
	move.b  d1, oYRadius(a0)
ObjCollapsePlatform_Main:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	bne.s   P20_loc_20C2C2
	rts     
P20_loc_20C2C2:
	jsr     GetOffObject.l
	move.w  #$a3, d0
	jsr     PlayFMSound.l
	addq.b  #$2, oRoutine(a0)
	move.b  oSubtype(a0), d0
	bpl.w   ObjCollapsePlatform_BreakUp_MultiRow
	bra.w   ObjCollapsePlatform_BreakUp_SingleRow
ObjCollapsePlatform_Delay:
	addi.w  #$ffff, $2a(a0)
	bne.s   P20_loc_20C2EE
	addq.b  #$2, oRoutine(a0)
P20_loc_20C2EE:
	move.b  $3e(a0), d0
	beq.s   P20_loc_20C30C
	lea     objects.w, a1
	jsr     TopSolidObject.l
	beq.s   P20_loc_20C30C
	tst.w   $2a(a0)
	bne.s   P20_loc_20C30C
	jsr     GetOffObject.l
P20_loc_20C30C:
	rts     
ObjCollapsePlatform_Fall:
	move.l  $2c(a0), d0
	add.l   d0, oY(a0)
	addi.l  #$4000, $2c(a0)
	move.w  oY(a0), d0
	lea     objects.w, a1
	sub.w   $c(a1), d0
	cmpi.w  #$200, d0
	bgt.w   P20_loc_20C334
	rts     
P20_loc_20C334:
	jmp     DeleteObject.l
ObjCollapsePlatform_Sizes1:
	dc.w	$0002,$0403,$FFFF,$0000,$0001,$0203,$0304,$0005
	dc.w	$0505,$0506,$0606,$0606
ObjCollapsePlatform_Sizes2:
	dc.w	$000C,$000C,$0014,$001A,$0020,$0024,$0501,$0000
	dc.w	$0000,$0000,$0303,$0102,$0202,$0303,$0202,$0202
	dc.w	$0103,$0305,$0103,$0504
ObjCollapsePlatform_BreakUp_MultiRow:
	move.b  oSubtype(a0), d0
	suba.l  a4, a4
	btst.l  #$4, d0
	beq.s   P20_loc_20C34A
	lea     ObjCollapsePlatform_BreakUp_MultiRow(pc), a4
P20_loc_20C34A:
	lea     ObjCollapsePlatform_Sizes1(pc), a6
	andi.w  #$f, d0
	add.w   d0, d0
	move.w  (a6, d0.w), d0
	lea     (a6, d0.w), a6
	moveq   #$0, d0
	move.b  (a6)+, d0
	movea.w d0, a5
	asl.w   #$3, d0
	move.w  #$fff0, d1
	cmpa.w  #$0, a4
	bne.s   P20_loc_20C372
	neg.w   d0
	neg.w   d1
P20_loc_20C372:
	add.w   oX(a0), d0
	movea.w d0, a2
	movea.w d1, a3
	moveq   #$0, d6
	move.b  (a6)+, d6
	move.w  d6, d4
	asl.w   #$3, d4
	add.w   oY(a0), d4
	move.w  #$9, d2
	move.b  oID(a0), $3f(a0)
P20_loc_20C390:
	move.w  a5, d5
	move.w  a2, d3
	move.w  d2, d1
P20_loc_20C396:
	jsr     FindObjSlot.l
	bne.w   P20_loc_20C426
	move.b  (a6)+, d0
	bmi.w   P20_loc_20C410
	move.b  d0, $1a(a1)
	ori.b   #$4, $1(a1)
	move.b  #$3, $18(a1)
	move.w  #$44be, $2(a1)
	move.l  #$20c5bc, $4(a1)
	move.l  #$20000, $2c(a1)
	dc.b	$13,$68,$00,$3F,$00,$00		; move.b $3f(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  oRoutine(a0), $24(a1)
	cmpa.w  #$0, a4
	beq.s   P20_loc_20C3EA
	bset.b  #$0, $1(a1)
	bset.b  #$0, $22(a1)
P20_loc_20C3EA:
	tst.w   d6
	bne.s   P20_loc_20C404
	st.b    $3e(a1)
	move.b  #$8, $17(a1)
	move.b  #$8, $19(a1)
	move.b  #$9, $16(a1)
P20_loc_20C404:
	move.w  d4, $c(a1)
	move.w  d3, $8(a1)
	move.w  d1, $2a(a1)
P20_loc_20C410:
	add.w   a3, d3
	addi.w  #$c, d1
	dbra    d5, P20_loc_20C396
	addi.w  #$fff0, d4
	addq.w  #$5, d2
	dbra    d6, P20_loc_20C390
	bra.s   P20_loc_20C438
P20_loc_20C426:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	beq.s   P20_loc_20C438
	jsr     GetOffObject.l
P20_loc_20C438:
	jmp     DeleteObject.l
ObjCollapsePlatform_BreakUp_SingleRow:
	move.b  oSubtype(a0), d2
	lea     ObjCollapsePlatform_Sizes2(pc), a6
	move.b  d2, d0
	andi.w  #$1f, d0
	add.w   d0, d0
	move.w  (a6, d0.w), d0
	lea     (a6, d0.w), a6
	move.b  (a6)+, d5
	move.b  (a6)+, d1
	addq.b  #$1, d1
	asl.b   #$3, d1
	addq.b  #$2, d1
	andi.w  #$ff, d5
	move.w  d5, d4
	lsl.w   #$3, d4
	neg.w   d4
	move.w  #$10, d3
	moveq   #$1, d6
	btst.l  #$6, d2
	bne.w   P20_loc_20C47C
	lsl.b   #$2, d2
	bra.s   P20_loc_20C48E
P20_loc_20C47C:
	lea     objects.w, a1
	move.w  $10(a1), d0
	btst.l  #$5, d2
	beq.s   P20_loc_20C48C
	neg.w   d0
P20_loc_20C48C:
	tst.w   d0
P20_loc_20C48E:
	bpl.s   P20_loc_20C49A
	lea     (a6, d5.w), a6
	neg.w   d4
	neg.w   d3
	neg.w   d6
P20_loc_20C49A:
	add.w   oX(a0), d4
	move.w  #$9, d2
	move.b  oID(a0), $3f(a0)
P20_loc_20C4A8:
	jsr     FindObjSlot.l
	bne.w   P20_loc_20C516
	move.b  #$3, $18(a1)
	move.w  #$44be, $2(a1)
	ori.b   #$4, $1(a1)
	move.l  #$20c7ba, $4(a1)
	move.l  #$20000, $2c(a1)
	dc.b	$13,$68,$00,$3F,$00,$00		; move.b $3f(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  oRoutine(a0), $24(a1)
	move.w  oY(a0), $c(a1)
	st.b    $3e(a1)
	move.b  #$8, $17(a1)
	move.b  #$8, $19(a1)
	move.b  d1, $16(a1)
	move.b  (a6), $1a(a1)
	lea     (a6, d6.w), a6
	move.w  d4, $8(a1)
	add.w   d3, d4
	move.w  d2, $2a(a1)
	addi.w  #$c, d2
	dbra    d5, P20_loc_20C4A8
	bra.s   P20_loc_20C528
P20_loc_20C516:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	beq.s   P20_loc_20C528
	jsr     GetOffObject.l
P20_loc_20C528:
	jmp     DeleteObject.l
