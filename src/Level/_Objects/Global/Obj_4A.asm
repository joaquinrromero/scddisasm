; Object $4A - Obj4A_20BA56 (from R43C, old ID $4A)
Obj4A_20BA56:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P4A_dat_20BA94(pc, d0.w), d0
	jsr     P4A_dat_20BA94(pc, d0.w)
	lea     loc_20C208.l, a1
	tst.b   $2d(a0)
	beq.s   P4A_loc_20BA88
	subq.b  #$1, $2d(a0)
	addq.b  #$3, oAnim(a0)
	jsr     AnimateObject.l
	subq.b  #$3, oAnim(a0)
	jmp     DrawObject.l
P4A_loc_20BA88:
	jsr     AnimateObject.l
	jmp     DrawObject.l
P4A_dat_20BA94:
	dc.w	P4A_loc_20BA9E-P4A_dat_20BA94
	dc.w	P4A_loc_20BB06-P4A_dat_20BA94
	dc.w	loc_20C0FE-P4A_dat_20BA94
	dc.w	P4A_loc_20BDE6-P4A_dat_20BA94
	dc.w	P4A_loc_20BFCA-P4A_dat_20BA94
P4A_loc_20BA9E:
	move.b  #$3d, oColType(a0)
	move.b  #$5, oColStatus(a0)
	clr.b   oFlags(a0)
	bset.b  #$0, oFlags(a0)
	move.b  #$8, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$6, oPriority(a0)
	move.b  #$24, oWidth(a0)
	move.b  #$38, oYRadius(a0)
	move.w  #$31e, oTile(a0)
	move.l  #$20c22c, oMap(a0)
	move.l  #$1c000, $3c(a0)
	move.l  #$13c68, oXVel(a0)
	move.w  #$5, d0
	movem.l d7/a0-a7, -(a7)
	jsr     LoadPalette.l
	movem.l (a7)+, d7/a0-a7
	bra.w   P4A_loc_20BFEC
P4A_loc_20BB06:
	move.w  $38(a0), d0
	sub.w   d0, oY(a0)
	bsr.w   P4A_sub_20BEEA
	btst.b  #$7, oSolidType(a0)
	beq.s   P4A_loc_20BB22
	lea     loc_20C0D4.l, a1
	bra.s   P4A_loc_20BB38
P4A_loc_20BB22:
	btst.b  #$6, oSolidType(a0)
	beq.s   P4A_loc_20BB32
	lea     loc_20C0E6.l, a1
	bra.s   P4A_loc_20BB38
P4A_loc_20BB32:
	lea     loc_20C062.l, a1
P4A_loc_20BB38:
	moveq   #$0, d0
	move.b  oSolidType(a0), d0
	andi.b  #$3f, d0
	mulu.w  #$6, d0
	adda.w  d0, a1
	dc.b	$10,$29,$00,$00		; move.b $0(a1), d0 (raw: not reproducible by assembler)
	cmpi.b  #$0, d0
	beq.w   P4A_loc_20BB90
	cmpi.b  #$1, d0
	beq.w   P4A_loc_20BBB8
	cmpi.b  #$5, d0
	beq.w   P4A_loc_20BBE0
	cmpi.b  #$6, d0
	beq.w   P4A_loc_20BC12
	cmpi.b  #$7, d0
	beq.w   P4A_loc_20BC5C
	cmpi.b  #$2, d0
	beq.w   P4A_loc_20BCA6
	cmpi.b  #$3, d0
	beq.w   P4A_loc_20BCD8
	cmpi.b  #$4, d0
	beq.w   P4A_loc_20BD22
P4A_loc_20BB8C:
	bra.w   P4A_loc_20BB8C
P4A_loc_20BB90:
	move.b  #$1, oAnim(a0)
	bclr.b  #$0, oFlags(a0)
	move.l  $3c(a0), d2
	add.l   d2, oX(a0)
	move.w  $2(a1), d0
	cmp.w   oX(a0), d0
	bgt.w   P4A_loc_20BEC4
	move.w  d0, oX(a0)
	bra.w   P4A_loc_20BD6C
P4A_loc_20BBB8:
	move.b  #$1, oAnim(a0)
	bset.b  #$0, oFlags(a0)
	move.l  $3c(a0), d2
	sub.l   d2, oX(a0)
	move.w  $2(a1), d0
	cmp.w   oX(a0), d0
	blt.w   P4A_loc_20BEC4
	move.w  d0, oX(a0)
	bra.w   P4A_loc_20BD6C
P4A_loc_20BBE0:
	move.b  #$0, oAnim(a0)
	move.l  $3c(a0), d2
	add.l   d2, oY(a0)
	move.w  $4(a1), d0
	cmp.w   oY(a0), d0
	bgt.w   P4A_loc_20BEE0
	cmpi.w  #$880, d0
	beq.s   P4A_loc_20BC08
	move.w  d0, oY(a0)
	bra.w   P4A_loc_20BD6C
P4A_loc_20BC08:
	move.w  #$80, oY(a0)
	bra.w   P4A_loc_20BD6C
P4A_loc_20BC12:
	move.b  #$2, oAnim(a0)
	bset.b  #$0, oFlags(a0)
	moveq   #$0, d1
	move.l  oXVel(a0), d2
	add.l   d2, oY(a0)
	move.w  $4(a1), d0
	cmp.w   oY(a0), d0
	bgt.w   P4A_loc_20BC3A
	move.w  d0, oY(a0)
	addq.l  #$1, d1
P4A_loc_20BC3A:
	sub.l   d2, oX(a0)
	move.w  $2(a1), d0
	cmp.w   oX(a0), d0
	blt.w   P4A_loc_20BC50
	move.w  d0, oX(a0)
	addq.l  #$1, d1
P4A_loc_20BC50:
	cmpi.w  #$2, d1
	beq.w   P4A_loc_20BD6C
	bra.w   P4A_loc_20BEE0
P4A_loc_20BC5C:
	move.b  #$2, oAnim(a0)
	bclr.b  #$0, oFlags(a0)
	moveq   #$0, d1
	move.l  oXVel(a0), d2
	add.l   d2, oY(a0)
	move.w  $4(a1), d0
	cmp.w   oY(a0), d0
	bgt.w   P4A_loc_20BC84
	move.w  d0, oY(a0)
	addq.l  #$1, d1
P4A_loc_20BC84:
	add.l   d2, oX(a0)
	move.w  $2(a1), d0
	cmp.w   oX(a0), d0
	bgt.w   P4A_loc_20BC9A
	move.w  d0, oX(a0)
	addq.l  #$1, d1
P4A_loc_20BC9A:
	cmpi.w  #$2, d1
	beq.w   P4A_loc_20BD6C
	bra.w   P4A_loc_20BEE0
P4A_loc_20BCA6:
	move.b  #$0, oAnim(a0)
	move.l  $3c(a0), d2
	sub.l   d2, oY(a0)
	move.w  $4(a1), d0
	cmp.w   oY(a0), d0
	blt.w   P4A_loc_20BEE0
	cmpi.w  #$ff40, d0
	beq.s   P4A_loc_20BCCE
	move.w  d0, oY(a0)
	bra.w   P4A_loc_20BD6C
P4A_loc_20BCCE:
	move.w  #$740, oY(a0)
	bra.w   P4A_loc_20BD6C
P4A_loc_20BCD8:
	move.b  #$2, oAnim(a0)
	bset.b  #$0, oFlags(a0)
	moveq   #$0, d1
	move.l  $3c(a0), d2
	sub.l   d2, oY(a0)
	move.w  $4(a1), d0
	cmp.w   oY(a0), d0
	blt.w   P4A_loc_20BD00
	move.w  d0, oY(a0)
	addq.l  #$1, d1
P4A_loc_20BD00:
	sub.l   d2, oX(a0)
	move.w  $2(a1), d0
	cmp.w   oX(a0), d0
	blt.w   P4A_loc_20BD16
	move.w  d0, oX(a0)
	addq.l  #$1, d1
P4A_loc_20BD16:
	cmpi.w  #$2, d1
	beq.w   P4A_loc_20BD6C
	bra.w   P4A_loc_20BEE0
P4A_loc_20BD22:
	moveq   #$0, d1
	move.l  $3c(a0), d2
	sub.l   d2, oY(a0)
	move.w  $4(a1), d0
	cmp.w   oY(a0), d0
	blt.w   P4A_loc_20BD3E
	move.w  d0, oY(a0)
	addq.l  #$1, d1
P4A_loc_20BD3E:
	add.l   d2, oX(a0)
	move.w  $2(a1), d0
	cmp.w   oX(a0), d0
	bgt.w   P4A_loc_20BD54
	move.w  d0, oX(a0)
	addq.l  #$1, d1
P4A_loc_20BD54:
	move.b  #$2, oAnim(a0)
	bclr.b  #$0, oFlags(a0)
	cmpi.w  #$2, d1
	beq.w   P4A_loc_20BD6C
	bra.w   P4A_loc_20BEE0
P4A_loc_20BD6C:
	tst.b   $1(a1)
	beq.s   P4A_loc_20BDCC
	tst.b   oColStatus(a0)
	bne.w   P4A_loc_20BDCC
	cmpi.b  #$1, $1(a1)
	beq.s   P4A_loc_20BDA0
	cmpi.b  #$2, $1(a1)
	beq.s   P4A_loc_20BDB6
	move.l  #$38000, $3c(a0)
	move.b  #$4, oRoutine(a0)
	move.b  #$0, oAnim(a0)
	rts     
P4A_loc_20BDA0:
	move.b  #$80, oSolidType(a0)
	movea.w $30(a0), a1
	movea.w $32(a1), a1
	move.b  #$1, $3f(a1)
	rts     
P4A_loc_20BDB6:
	move.b  #$40, oSolidType(a0)
	movea.w $30(a0), a1
	movea.w $34(a1), a1
	move.b  #$1, $3f(a1)
	rts     
P4A_loc_20BDCC:
	addq.b  #$1, oSolidType(a0)
	move.b  oSolidType(a0), d0
	andi.b  #$3f, d0
	cmpi.b  #$13, d0
	blt.s   P4A_loc_20BDE4
	andi.b  #$c0, oSolidType(a0)
P4A_loc_20BDE4:
	rts     
P4A_loc_20BDE6:
	bsr.w   P4A_sub_20BF80
	lea     objects.w, a1
	moveq   #$0, d1
	moveq   #$0, d2
	move.w  $8(a1), d1
	sub.w   oX(a0), d1
	bge.s   P4A_loc_20BDFE
	neg.w   d1
P4A_loc_20BDFE:
	move.w  $c(a1), d2
	sub.w   oY(a0), d2
	bge.s   P4A_loc_20BE0A
	neg.w   d2
P4A_loc_20BE0A:
	mulu.w  d1, d1
	mulu.w  d2, d2
	add.l   d2, d1
	btst.b  #$5, $2e(a0)
	beq.s   P4A_loc_20BE28
	cmpi.l  #$5100, d1
	bge.w   P4A_loc_20BEAA
	bclr.b  #$5, $2e(a0)
P4A_loc_20BE28:
	cmpi.l  #$11040, d1
	bge.w   P4A_loc_20BEAA
	cmpi.l  #$1e40, d1
	blt.w   P4A_loc_20BE6E
	cmpi.l  #$4840, d1
	blt.w   P4A_loc_20BE5A
	move.l  #$1c000, $3c(a0)
	move.l  #$13c68, oXVel(a0)
	bra.w   P4A_loc_20BEA6
P4A_loc_20BE5A:
	move.l  #$30000, $3c(a0)
	move.l  #$21ef8, oXVel(a0)
	bra.w   P4A_loc_20BEA6
P4A_loc_20BE6E:
	cmpi.w  #$800, $12(a1)
	bgt.s   P4A_loc_20BE92
	cmpi.w  #$800, $10(a1)
	bgt.s   P4A_loc_20BE92
	move.l  #$80000, $3c(a0)
	move.l  #$5a550, oXVel(a0)
	bra.w   P4A_loc_20BEA6
P4A_loc_20BE92:
	move.l  #$100000, $3c(a0)
	move.l  #$b4e88, oXVel(a0)
	bra.w   P4A_loc_20BEA6
P4A_loc_20BEA6:
	bra.w   P4A_loc_20BB06
P4A_loc_20BEAA:
	bset.b  #$5, $2e(a0)
	move.w  $38(a0), d0
	sub.w   d0, oY(a0)
	move.b  #$0, oAnim(a0)
	bra.w   P4A_loc_20BEC4
	dc.w	$4E75
P4A_loc_20BEC4:
	moveq   #$0, d0
	addq.b  #$2, $2f(a0)
	move.b  $2f(a0), d0
	jsr     CalcSine.l
	asr.w   #$5, d0
	move.w  d0, $38(a0)
	add.w   d0, oY(a0)
	rts     
P4A_loc_20BEE0:
	move.w  $38(a0), d0
	add.w   d0, oY(a0)
	rts     
P4A_sub_20BEEA:
	tst.b   $2c(a0)
	beq.s   P4A_loc_20BF06
	subq.b  #$1, $2c(a0)
	bne.s   P4A_loc_20BF06
	move.l  #$1c000, $3c(a0)
	move.l  #$13c68, oXVel(a0)
P4A_loc_20BF06:
	tst.b   oColStatus(a0)
	beq.w   P4A_loc_20BF7E
	tst.b   $2b(a0)
	bne.s   P4A_loc_20BF20
	tst.b   oColType(a0)
	beq.w   P4A_loc_20BF32
	bra.w   P4A_loc_20BF7E
P4A_loc_20BF20:
	subq.b  #$1, $2b(a0)
	bne.w   P4A_loc_20BF7E
	move.b  #$3d, oColType(a0)
	bra.w   P4A_loc_20BF7E
P4A_loc_20BF32:
	move.w  #$ac, d0
	jsr     PlayFMSound.l
	movea.w $30(a0), a1
	move.b  #$28, $2a(a1)
	move.b  #$46, $2c(a0)
	move.l  #$48000, $3c(a0)
	move.l  #$32c80, oXVel(a0)
	move.b  #$10, $2d(a0)
	cmpi.b  #$1, oColStatus(a0)
	beq.s   P4A_loc_20BF74
	move.b  #$1e, $2b(a0)
	bra.w   P4A_loc_20BF7E
P4A_loc_20BF74:
	move.b  #$6, oRoutine(a0)
	clr.b   oColStatus(a0)
P4A_loc_20BF7E:
	rts     
P4A_sub_20BF80:
	movea.w $30(a0), a1
	move.b  #$1e, $2a(a1)
	tst.b   $2a(a0)
	bne.s   P4A_loc_20BF9A
	move.b  #$20, $2a(a0)
	bsr.w   P4A_sub_20BFA0
P4A_loc_20BF9A:
	subq.b  #$1, $2a(a0)
	rts     
P4A_sub_20BFA0:
	jsr     FindObjSlot.l
	bne.s   P4A_loc_20BFC8
	st.b    $25(a1)
	dc.b	$13,$7C,$00,$18,$00,$00		; move.b #$18, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.w  #$9e, d0
	jsr     PlayFMSound.l
P4A_loc_20BFC8:
	rts     
P4A_loc_20BFCA:
	lea     objects.w, a1
	cmpi.w  #$478, $8(a1)
	blt.s   P4A_loc_20BFEA
	move.b  #$2, oRoutine(a0)
	move.b  #$4, bossFight.w
	move.l  #$32c80, oXVel(a0)
P4A_loc_20BFEA:
	rts     
P4A_loc_20BFEC:
	movea.l a0, a3
	jsr     FindObjSlot.l
	bne.w   P4A_loc_20C012
	move.w  a1, $30(a3)
	move.w  a3, $30(a1)
	dc.b	$13,$7C,$00,$4B,$00,$00		; move.b #$4b, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
P4A_loc_20C012:
	rts     
