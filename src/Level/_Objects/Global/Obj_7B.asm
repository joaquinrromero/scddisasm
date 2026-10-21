; Object $7B - Obj2C_20D746 (from R41A, old ID $2C)
Obj2C_20D746:
	tst.b   oSubtype(a0)
	bmi.w   P7B_loc_20D9B6
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P7B_dat_20D76E(pc, d0.w), d0
	jsr     P7B_dat_20D76E(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P7B_dat_20D76E:
	dc.w	P7B_loc_20D778-P7B_dat_20D76E
	dc.w	P7B_loc_20D7F0-P7B_dat_20D76E
	dc.w	P7B_loc_20D840-P7B_dat_20D76E
	dc.w	P7B_loc_20D87E-P7B_dat_20D76E
	dc.w	P7B_loc_20D8B4-P7B_dat_20D76E
P7B_loc_20D778:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$23b0, oTile(a0)
	move.b  #$14, oXRadius(a0)
	move.b  #$14, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.b  #$31, oColType(a0)
	move.w  #$78, $3c(a0)
	move.w  oX(a0), $3e(a0)
	lea     P7B_dat_20DA28(pc), a1
	lea     P7B_dat_20D9DA(pc), a2
	move.l  #$fffffa00, d0
	move.l  #$100, d1
	tst.b   oSubtype(a0)
	beq.s   P7B_loc_20D7E0
	lea     P7B_dat_20D9E6(pc), a1
	lea     P7B_dat_20D9D4(pc), a2
	move.l  #$fffffe00, d0
	move.l  #$c0, d1
P7B_loc_20D7E0:
	move.l  a1, oMap(a0)
	move.l  a2, $38(a0)
	move.l  d0, $30(a0)
	move.l  d1, $34(a0)
P7B_loc_20D7F0:
	move.l  $2c(a0), d6
	add.l   $30(a0), d6
	move.l  #$fffe8000, d5
	tst.b   oSubtype(a0)
	beq.s   P7B_loc_20D80A
	move.l  #$ffff4000, d5
P7B_loc_20D80A:
	cmp.l   d5, d6
	bgt.s   P7B_loc_20D814
	move.l  d5, d6
	bra.w   P7B_loc_20D81C
P7B_loc_20D814:
	neg.l   d5
	cmp.l   d5, d6
	blt.s   P7B_loc_20D824
	move.l  d5, d6
P7B_loc_20D81C:
	addq.b  #$2, oRoutine(a0)
	neg.l   $30(a0)
P7B_loc_20D824:
	move.l  d6, $2c(a0)
	tst.b   oSubtype(a0)
	bne.s   P7B_loc_20D832
	bsr.w   P7B_sub_20D8D8
P7B_loc_20D832:
	movea.l $38(a0), a1
	jsr     AnimateObject.l
	bra.w   P7B_loc_20D8C4
P7B_loc_20D840:
	move.l  $2c(a0), d6
	smi.b   d0
	add.l   $34(a0), d6
	smi.b   d1
	eor.b   d0, d1
	beq.s   P7B_loc_20D86C
	addq.b  #$2, oRoutine(a0)
	neg.l   $34(a0)
	clr.l   d6
	move.w  #$3c, d0
	tst.b   oSubtype(a0)
	beq.s   P7B_loc_20D868
	move.w  #$3c, d0
P7B_loc_20D868:
	move.w  d0, $2a(a0)
P7B_loc_20D86C:
	move.l  d6, $2c(a0)
	tst.b   oSubtype(a0)
	bne.s   P7B_loc_20D87A
	bsr.w   P7B_sub_20D8D8
P7B_loc_20D87A:
	bra.w   P7B_loc_20D8C4
P7B_loc_20D87E:
	subq.w  #$1, $2a(a0)
	bpl.s   P7B_loc_20D8A6
	addq.b  #$2, oRoutine(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	move.w  #$3c, d0
	tst.b   oSubtype(a0)
	beq.s   P7B_loc_20D8A2
	move.w  #$3c, d0
P7B_loc_20D8A2:
	move.w  d0, $2a(a0)
P7B_loc_20D8A6:
	tst.b   oSubtype(a0)
	bne.s   P7B_loc_20D8B0
	bsr.w   P7B_sub_20D8D8
P7B_loc_20D8B0:
	bra.w   P7B_loc_20D8C4
P7B_loc_20D8B4:
	subq.w  #$1, $2a(a0)
	bpl.s   P7B_loc_20D8C0
	move.b  #$2, oRoutine(a0)
P7B_loc_20D8C0:
	bra.w   P7B_loc_20D8C4
P7B_loc_20D8C4:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	move.w  waterHeight.w, oY(a0)
	subq.w  #$8, oY(a0)
	rts     
P7B_dat_20DA28:
	dc.w	$0008,$0027,$0046,$004C,$06FC,$0000,$00EC,$F401
	dc.w	$0001,$F4F4,$0100,$03FC,$F401,$0005,$0404,$0400
	dc.w	$07EC,$0400,$0009,$0406,$F400,$000A,$F4F4,$0000
	dc.w	$0BFC,$F400,$000C,$04FC,$0000,$0DEC,$FC08,$000E
	dc.w	$F404,$0C00,$11EC,$01FC,$0000,$15FC,$01FC,$0000
	dc.w	$16FC
P7B_dat_20D9DA:
	dc.w	$0004,$0008,$0A00,$01FF,$0502,$03FF
P7B_dat_20D9E6:
	dc.w	$0004,$0023,$06FC,$0000,$00EC,$F401,$0017,$F4F4
	dc.w	$0100,$03FC,$F401,$0019,$0404,$0400,$07EC,$0400
	dc.w	$0009,$0406,$F400,$001B,$F4F4,$0000,$0BFC,$F400
	dc.w	$001C,$04FC,$0000,$0DEC,$FC08,$001D,$F404,$0C00
	dc.w	$11EC
P7B_dat_20D9D4:
	dc.w	$0002,$1400,$01FF
P7B_sub_20D8D8:
	subq.w  #$1, $3c(a0)
	bpl.w   P7B_loc_20D97C
	move.w  #$78, $3c(a0)
	lea     objects.w, a6
	bsr.w   P7B_sub_20D97E
	bcc.w   P7B_loc_20D97C
	jsr     FindObjSlot.l
	bne.w   P7B_loc_20D97C
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.w  a0, $2a(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  oSprFlags(a0), $1(a1)
	move.b  oPriority(a0), $18(a1)
	addq.b  #$1, $18(a1)
	move.w  oTile(a0), $2(a1)
	move.b  #$4, $17(a1)
	move.b  #$4, $19(a1)
	move.b  #$4, $16(a1)
	move.b  #$b2, $20(a1)
	move.l  oMap(a0), $4(a1)
	move.l  $38(a0), $38(a1)
	move.b  #$1, $1c(a1)
	move.l  #$fffe0000, d0
	btst.b  #$0, $1(a1)
	beq.s   P7B_loc_20D968
	neg.l   d0
P7B_loc_20D968:
	move.l  d0, $2c(a1)
	tst.b   oSprFlags(a0)
	bpl.s   P7B_loc_20D97C
	move.w  #$a0, d0
	jsr     PlayFMSound.l
P7B_loc_20D97C:
	rts     
P7B_sub_20D97E:
	move.w  $c(a6), d0
	sub.w   oY(a0), d0
	subi.w  #$ffa0, d0
	subi.w  #$c0, d0
	bcc.s   P7B_loc_20D9B4
	move.w  $8(a6), d0
	sub.w   oX(a0), d0
	smi.b   d1
	subi.w  #$ffa0, d0
	subi.w  #$c0, d0
	bcc.s   P7B_loc_20D9B4
	btst.b  #$0, oSprFlags(a0)
	seq.b   d0
	eor.b   d1, d0
	bne.s   P7B_loc_20D9B4
	ori.b   #$1, ccr
P7B_loc_20D9B4:
	rts     
P7B_loc_20D9B6:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	movea.l $38(a0), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
