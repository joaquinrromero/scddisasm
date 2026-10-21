; Object $93 - Obj22_20D7A8 (from R51A, old ID $22)
P93_Obj22_20D7A8:
	tst.b   oLayer(a0)
	bne.s   P93_loc_20D7B4
	jsr     DestroyOnGoodFuture.l
P93_loc_20D7B4:
	tst.b   oRoutine(a0)
	beq.s   P93_loc_20D7D8
	movem.w $3a(a0), a1-a3
	dc.b	$0C,$29,$00,$22,$00,$00		; cmpi.b #$22, $0(a1) (raw: not reproducible by assembler)
	bne.s   P93_loc_20D808
	dc.b	$0C,$2A,$00,$22,$00,$00		; cmpi.b #$22, $0(a2) (raw: not reproducible by assembler)
	bne.s   P93_loc_20D808
	dc.b	$0C,$2B,$00,$22,$00,$00		; cmpi.b #$22, $0(a3) (raw: not reproducible by assembler)
	bne.s   P93_loc_20D808
P93_loc_20D7D8:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P93_dat_20D7FE(pc, d0.w), d0
	jsr     P93_dat_20D7FE(pc, d0.w)
	jsr     DrawObject.l
	tst.b   oLayer(a0)
	bne.s   P93_loc_20D7FC
	move.w  $34(a0), d0
	jmp     CheckObjDespawn2.l
P93_loc_20D7FC:
	rts     
P93_dat_20D7FE:
	dc.w	P93_loc_20D80E-P93_dat_20D7FE
	dc.w	P93_loc_20D918-P93_dat_20D7FE
	dc.w	P93_loc_20D940-P93_dat_20D7FE
	dc.w	P93_loc_20D968-P93_dat_20D7FE
	dc.w	P93_loc_20D98A-P93_dat_20D7FE
P93_loc_20D808:
	jmp     DeleteObject.l
P93_loc_20D80E:
	move.w  #$3, $2a(a0)
	move.b  #$1, oMapFrame(a0)
	move.b  #$c, oYRadius(a0)
	move.b  #$33, oColType(a0)
	movea.w a0, a1
	bsr.w   P93_sub_20D8E4
	tst.b   oSubtype(a0)
	bne.s   P93_loc_20D83C
	move.w  #$24, d0
	move.w  #$6, d1
	bra.s   P93_loc_20D844
P93_loc_20D83C:
	move.w  #$24, d0
	move.w  #$c, d1
P93_loc_20D844:
	move.w  d0, $2c(a0)
	move.w  d1, $30(a0)
	lea     $3a(a0), a6
	move.w  #$2, d6
	move.w  oX(a0), d5
	tst.b   oSubtype(a0)
	bne.s   P93_loc_20D866
	moveq   #$2, d4
	moveq   #$b, d3
	moveq   #$b4, d2
	bra.s   P93_loc_20D86C
P93_loc_20D866:
	moveq   #$3, d4
	moveq   #$7, d3
	moveq   #$33, d2
P93_loc_20D86C:
	jsr     FindNextObjSlot.l
	bne.s   P93_loc_20D808
	move.w  a1, (a6)+
	move.w  d6, $2a(a1)
	addi.w  #$c, d5
	move.w  d5, $8(a1)
	move.b  d4, $1a(a1)
	move.b  d3, $16(a1)
	move.b  d2, $20(a1)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  oSubtype(a0), $28(a1)
	move.w  oY(a0), $c(a1)
	move.w  $2c(a0), $2c(a1)
	move.w  $30(a0), $30(a1)
	move.b  #$ff, $29(a1)
	bsr.s   P93_sub_20D8E4
	dbra    d6, P93_loc_20D86C
	movem.w $3a(a0), a1-a3
	move.w  a0, $3a(a1)
	move.w  a2, $3c(a1)
	move.w  a3, $3e(a1)
	move.w  a0, $3a(a2)
	move.w  a1, $3c(a2)
	move.w  a3, $3e(a2)
	move.w  a0, $3a(a3)
	move.w  a1, $3c(a3)
	move.w  a2, $3e(a3)
	rts     
P93_sub_20D8E4:
	move.b  #$2, $24(a1)
	ori.b   #$4, $1(a1)
	move.b  #$3, $18(a1)
	move.b  #$8, $17(a1)
	move.b  #$8, $19(a1)
	move.w  #$23fe, $2(a1)
	move.l  #$20d9f2, $4(a1)
	move.w  oX(a0), $34(a1)
	rts     
P93_loc_20D918:
	addq.w  #$1, oY(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P93_loc_20D93E
	add.w   d1, oY(a0)
	addq.b  #$2, oRoutine(a0)
	movea.w a0, a1
	tst.b   oLayer(a0)
	beq.s   P93_loc_20D93A
	movea.w $3a(a0), a1
P93_loc_20D93A:
	addq.w  #$1, $36(a1)
P93_loc_20D93E:
	rts     
P93_loc_20D940:
	tst.b   oLayer(a0)
	bne.s   P93_loc_20D966
	cmpi.w  #$4, $36(a0)
	bne.s   P93_loc_20D966
	movem.w $3a(a0), a1-a3
	addq.b  #$2, oRoutine(a0)
	addq.b  #$2, $24(a1)
	addq.b  #$2, $24(a2)
	addq.b  #$2, $24(a3)
	bra.s   P93_loc_20D968
P93_loc_20D966:
	rts     
P93_loc_20D968:
	addq.b  #$2, oRoutine(a0)
	eori.w  #$3, $2a(a0)
	move.w  $2c(a0), $2e(a0)
	move.w  $30(a0), $32(a0)
	tst.b   oLayer(a0)
	bne.s   P93_loc_20D98A
	eori.b  #$1, oMapFrame(a0)
P93_loc_20D98A:
	move.w  $2a(a0), d0
	sub.w   d0, $32(a0)
	bne.s   P93_loc_20D9C2
	move.w  $30(a0), $32(a0)
	bsr.s   P93_sub_20D9DE
	move.w  $34(a0), d0
	sub.w   oX(a0), d0
	bpl.s   P93_loc_20D9A8
	neg.w   d0
P93_loc_20D9A8:
	cmpi.w  #$50, d0
	bge.s   P93_loc_20D9CE
	jsr     ObjGetFloorDist.l
	move.w  d1, d0
	addq.w  #$7, d0
	subi.w  #$e, d0
	bcc.s   P93_loc_20D9CE
	add.w   d1, oY(a0)
P93_loc_20D9C2:
	subq.w  #$1, $2e(a0)
	bne.s   P93_loc_20D9CC
	subq.b  #$2, oRoutine(a0)
P93_loc_20D9CC:
	rts     
P93_loc_20D9CE:
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	bsr.s   P93_sub_20D9DE
	bra.s   P93_loc_20D98A
P93_sub_20D9DE:
	btst.b  #$0, oSprFlags(a0)
	bne.s   P93_loc_20D9EC
	subq.w  #$1, oX(a0)
	bra.s   P93_loc_20D9F0
P93_loc_20D9EC:
	addq.w  #$1, oX(a0)
P93_loc_20D9F0:
	rts     
P93_loc_20D9F2:
	dc.w	$0008,$000E,$0014,$001A,$01F4,$0600,$00F8,$01F4
	dc.w	$0600,$06F8,$01F4,$0600,$0CF8,$01F8,$0500,$12F8
