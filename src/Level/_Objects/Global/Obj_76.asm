; Object $76 - Obj3E_20B7D2 (from R82A, old ID $3E)
Obj3E_20B7D2:
	lea     objects.w, a6
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P76_dat_20B80E(pc, d0.w), d0
	jsr     P76_dat_20B80E(pc, d0.w)
	tst.b   oRoutine(a0)
	beq.s   P76_loc_20B808
	jsr     DrawObject.l
	cmpi.b  #$8, oRoutine(a0)
	bcs.s   P76_loc_20B802
	move.w  $2a(a0), d0
	jmp     CheckObjDespawn2.l
P76_loc_20B802:
	jmp     CheckObjDespawn.l
P76_loc_20B808:
	jmp     DespawnObject.l
P76_dat_20B80E:
	dc.w	P76_loc_20B81A-P76_dat_20B80E
	dc.w	P76_loc_20B928-P76_dat_20B80E
	dc.w	P76_loc_20B99C-P76_dat_20B80E
	dc.w	P76_loc_20B9B6-P76_dat_20B80E
	dc.w	P76_loc_20BA00-P76_dat_20B80E
	dc.w	P76_loc_20BA1A-P76_dat_20B80E
P76_loc_20B81A:
	move.l  a0, -(a7)
	moveq   #$3, d6
P76_loc_20B81E:
	jsr     FindNextObjSlot.l
	bne.w   P76_loc_20B920
	movea.l a1, a0
	dbra    d6, P76_loc_20B81E
	movea.l (a7)+, a0
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$28, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.l  #$20ba84, oMap(a0)
	move.w  #$41b, oTile(a0)
	jsr     FindNextObjSlot.l
	dc.b	$13,$7C,$00,$3E,$00,$00		; move.b #$3e, $0(a1) (raw: not reproducible by assembler)
	move.b  #$4, $1(a1)
	move.b  #$1, $18(a1)
	move.l  #$20ba84, $4(a1)
	move.w  #$41b, $2(a1)
	move.b  #$28, $19(a1)
	move.b  #$8, $16(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$b0, $c(a1)
	move.b  #$1, $28(a1)
	addq.b  #$2, $24(a1)
	moveq   #$2, d6
P76_loc_20B8AA:
	jsr     FindNextObjSlot.l
	dc.b	$13,$7C,$00,$3E,$00,$00		; move.b #$3e, $0(a1) (raw: not reproducible by assembler)
	move.b  #$4, $1(a1)
	move.b  #$1, $18(a1)
	move.l  #$20ba84, $4(a1)
	move.w  #$41b, $2(a1)
	move.b  #$8, $19(a1)
	move.b  #$50, $16(a1)
	move.b  P76_dat_20B924(pc, d6.w), $2d(a1)
	move.b  #$2, $1a(a1)
	move.b  #$8, $24(a1)
	move.w  oX(a0), $2a(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$58, $c(a1)
	move.b  $2d(a1), d0
	jsr     CalcSine.l
	muls.w  #$20, d1
	lsr.l   #$8, d1
	move.w  $2a(a1), $8(a1)
	add.w   d1, $8(a1)
	dbra    d6, P76_loc_20B8AA
	rts     
P76_loc_20B920:
	movea.l (a7)+, a0
	rts     
P76_dat_20B924:
	dc.w	$4095,$EA00
P76_loc_20B928:
	tst.b   oSubtype(a0)
	beq.s   P76_loc_20B942
	cmpi.b  #$33, $1c(a6)
	bcs.s   P76_loc_20B99A
	lea     P76_loc_20BA7E.l, a1
	jmp     AnimateObject.l
P76_loc_20B942:
	bsr.w   P76_sub_20B9F0
	beq.s   P76_loc_20B994
	move.w  oX(a0), d0
	sub.w   $8(a6), d0
	addq.w  #$8, d0
	bcs.s   P76_loc_20B994
	cmpi.w  #$10, d0
	bcc.s   P76_loc_20B994
	bset.b  #$0, $2c(a0)
	bne.s   P76_loc_20B99A
	bset.b  #$0, $2c(a6)
	move.w  oX(a0), $8(a6)
	move.w  #$0, $10(a6)
	move.w  #$0, $14(a6)
	move.b  #$33, $1c(a6)
	tst.b   layer.l
	beq.s   P76_loc_20B98E
	move.b  #$34, $1c(a6)
P76_loc_20B98E:
	addq.b  #$2, oRoutine(a0)
	rts     
P76_loc_20B994:
	move.b  #$0, $2c(a0)
P76_loc_20B99A:
	rts     
P76_loc_20B99C:
	lea     P76_loc_20BA7E.l, a1
	jsr     AnimateObject.l
	cmpi.b  #$5, $1c(a6)
	bne.w   P76_sub_20B9F0
	addq.b  #$2, oRoutine(a0)
P76_loc_20B9B6:
	bclr.b  #$0, $2c(a6)
	bsr.w   P76_sub_20B9F0
	eori.b  #$1, layer.l
	eori.b  #$1, $1(a6)
	eori.b  #$1, $22(a6)
	ori.w   #$8000, $2(a6)
	tst.b   layer.l
	beq.s   P76_loc_20B9E8
	andi.w  #$7fff, $2(a6)
P76_loc_20B9E8:
	move.b  #$2, oRoutine(a0)
	rts     
P76_sub_20B9F0:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	movea.l a6, a1
	jmp     TopSolidObject.l
P76_loc_20BA00:
	cmpi.b  #$33, $1c(a6)
	bcs.s   P76_loc_20BA18
	addq.b  #$2, oRoutine(a0)
	move.b  $2d(a0), $2e(a0)
	addi.b  #$80, $2e(a0)
P76_loc_20BA18:
	rts     
P76_loc_20BA1A:
	cmpi.b  #$33, $1c(a6)
	bcc.s   P76_loc_20BA2E
	subq.b  #$2, oRoutine(a0)
	move.b  $2e(a0), $2d(a0)
	bra.s   P76_loc_20BA50
P76_loc_20BA2E:
	moveq   #$4, d0
	btst.b  #$0, $22(a6)
	bne.s   P76_loc_20BA42
	tst.b   layer.l
	beq.s   P76_loc_20BA4C
	bra.s   P76_loc_20BA4A
P76_loc_20BA42:
	tst.b   layer.l
	bne.s   P76_loc_20BA4C
P76_loc_20BA4A:
	neg.b   d0
P76_loc_20BA4C:
	add.b   d0, $2d(a0)
P76_loc_20BA50:
	move.b  $2d(a0), d0
	jsr     CalcSine.l
	muls.w  #$18, d1
	lsr.l   #$8, d1
	move.w  $2a(a0), oX(a0)
	add.w   d1, oX(a0)
	move.b  #$1, oPriority(a0)
	tst.b   $2d(a0)
	bmi.s   P76_loc_20BA7C
	move.b  #$4, oPriority(a0)
P76_loc_20BA7C:
	rts     
P76_loc_20BA7E:
	dc.w	$0002,$0200,$01FF
P76_loc_20BA84:
	dc.w	$0006,$0016,$0026,$03F8,$0500,$00D8,$F80D,$0004
	dc.w	$E8F8,$0D00,$0C08,$03F8,$0500,$00D8,$F80D,$0804
	dc.w	$E8F8,$0D00,$0C08,$05B0,$0300,$14FC,$D003,$0014
	dc.w	$FCF0,$0300,$14FC,$1003,$0014,$FC30,$0300,$14FC
P76_loc_20BAC4:
	dc.w	$0002,$06A0,$0708,$00F8,$C007,$0800,$F8E0,$0708
	dc.w	$00F8,$0007,$0800,$F820,$0708,$00F8,$4007,$0800
	dc.w	$F800
