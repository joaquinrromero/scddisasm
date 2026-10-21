; Object $8E - Obj1E_20BA00 (from R71A, old ID $1E)
Obj1E_20BA00:
	cmpi.b  #$4, oRoutine(a0)
	bcs.s   P8E_loc_20BA14
	tst.b   $3e(a0)
	beq.s   P8E_loc_20BA14
	jmp     DeleteObject.l
P8E_loc_20BA14:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	beq.s   P8E_loc_20BA24
	cmpi.b  #$6, $FFFFD024.w
	bcc.s   P8E_loc_20BA3A
P8E_loc_20BA24:
	move.w  P8E_dat_20BA82(pc, d0.w), d0
	jsr     P8E_dat_20BA82(pc, d0.w)
	cmpi.b  #$4, oRoutine(a0)
	bne.s   P8E_loc_20BA3A
	tst.b   oSubtype(a0)
	bne.s   P8E_loc_20BA40
P8E_loc_20BA3A:
	jsr     DrawObject.l
P8E_loc_20BA40:
	cmpi.b  #$2, oRoutine(a0)
	bne.s   P8E_loc_20BA80
	move.l  $2a(a0), -(a7)
	move.l  $36(a0), -(a7)
	move.l  $3a(a0), -(a7)
	move.w  $34(a0), d0
	jsr     CheckObjDespawn2.l
	bne.s   P8E_loc_20BA68
	move.l  (a7)+, d0
	move.l  (a7)+, d0
	move.l  (a7)+, d0
	rts     
P8E_loc_20BA68:
	movea.l (a7)+, a1
	move.b  #$1, $3e(a1)
	movea.l (a7)+, a1
	move.b  #$1, $3e(a1)
	movea.l (a7)+, a1
	move.b  #$1, $3e(a1)
P8E_loc_20BA80:
	rts     
P8E_dat_20BA82:
	dc.w	P8E_loc_20BA92-P8E_dat_20BA82
	dc.w	P8E_loc_20BB88-P8E_dat_20BA82
	dc.w	P8E_loc_20BBB0-P8E_dat_20BA82
	dc.w	P8E_loc_20BCEE-P8E_dat_20BA82
	dc.w	P8E_loc_20BD58-P8E_dat_20BA82
	dc.w	P8E_sub_20BD94-P8E_dat_20BA82
	dc.w	P8E_sub_20BDCC-P8E_dat_20BA82
	dc.w	P8E_loc_20BEA4-P8E_dat_20BA82
P8E_loc_20BA92:
	addq.b  #$2, oRoutine(a0)
	move.w  oX(a0), $34(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$300, oTile(a0)
	move.l  #$20c41e, oMap(a0)
	move.b  #$8, oXRadius(a0)
	move.b  #$8, oYRadius(a0)
	move.b  #$1, oMapFrame(a0)
	move.b  oSubtype(a0), d0
	cmpi.b  #$2, d0
	bcs.s   P8E_loc_20BADC
	subq.b  #$1, d0
	move.b  d0, oLayer(a0)
	move.b  d0, oAnimFrame(a0)
	move.b  #$0, oSubtype(a0)
P8E_loc_20BADC:
	moveq   #$2, d6
	move.l  a0, -(a7)
P8E_loc_20BAE0:
	jsr     FindNextObjSlot.l
	beq.s   P8E_loc_20BAF0
	movea.l (a7)+, a0
	jmp     DeleteObject.l
P8E_loc_20BAF0:
	movea.l a1, a0
	dbra    d6, P8E_loc_20BAE0
	movea.l (a7)+, a0
	moveq   #$2, d6
	move.b  #$4, d1
P8E_loc_20BAFE:
	jsr     FindNextObjSlot.l
	dc.b	$13,$7C,$00,$1E,$00,$00		; move.b #$1e, $0(a1) (raw: not reproducible by assembler)
	ori.b   #$4, $1(a1)
	move.w  oX(a0), $8(a1)
	move.w  oX(a0), $34(a1)
	move.w  oY(a0), $c(a1)
	cmpi.b  #$2, d6
	bne.s   P8E_loc_20BB42
	move.w  #$520, $2(a1)
	move.l  #$20982c, $4(a1)
	move.b  #$5, $18(a1)
	move.l  a1, $2a(a0)
	bra.s   P8E_loc_20BB6C
P8E_loc_20BB42:
	move.w  #$300, $2(a1)
	move.l  #$20c41e, $4(a1)
	move.b  #$20, $17(a1)
	move.b  #$20, $16(a1)
	cmpi.w  #$1, d6
	bne.s   P8E_loc_20BB68
	move.l  a1, $36(a0)
	bra.s   P8E_loc_20BB6C
P8E_loc_20BB68:
	move.l  a1, $3a(a0)
P8E_loc_20BB6C:
	move.b  oSubtype(a0), $28(a1)
	move.l  a0, $2a(a1)
	move.b  d1, $24(a1)
	cmpi.w  #$2, d6
	bne.s   P8E_loc_20BB82
	addq.b  #$4, d1
P8E_loc_20BB82:
	addq.b  #$2, d1
	dbra    d6, P8E_loc_20BAFE
P8E_loc_20BB88:
	tst.b   oLayer(a0)
	bne.s   P8E_loc_20BBA2
	movea.l $2a(a0), a1
	cmpi.b  #$6, $24(a1)
	bcs.s   P8E_loc_20BBA4
	cmpi.b  #$2, $29(a1)
	beq.s   P8E_loc_20BBA4
P8E_loc_20BBA2:
	rts     
P8E_loc_20BBA4:
	lea     loc_20C412.l, a1
	jmp     AnimateObject.l
P8E_loc_20BBB0:
	tst.b   oSubtype(a0)
	bne.s   P8E_loc_20BBBE
	bsr.w   P8E_loc_20BBC0
	bra.w   P8E_loc_20BF88
P8E_loc_20BBBE:
	rts     
P8E_loc_20BBC0:
	lea     P8E_loc_20BC64.l, a2
	lea     P8E_loc_20BC82.l, a3
	tst.b   oSubtype(a0)
	beq.s   P8E_loc_20BBF2
	lea     P8E_loc_20BC6E.l, a2
	lea     P8E_loc_20BCA6.l, a3
	cmpi.b  #$1, oSubtype(a0)
	beq.s   P8E_loc_20BBF2
	lea     P8E_loc_20BC78.l, a2
	lea     P8E_loc_20BCCA.l, a3
P8E_loc_20BBF2:
	move.w  #$520, oTile(a0)
	movea.l $2a(a0), a1
	moveq   #$0, d0
	move.b  $1b(a1), d0
	btst.l  #$0, d0
	bne.s   P8E_loc_20BC0E
	move.w  #$4f2, oTile(a0)
P8E_loc_20BC0E:
	move.w  d0, d1
	move.b  P8E_dat_20BC4E(pc, d0.w), d0
	add.w   d0, d0
	add.w   d0, d0
	move.l  P8E_dat_20BC58(pc, d0.w), oMap(a0)
	andi.b  #$fc, oSprFlags(a0)
	move.b  (a2, d1.w), d0
	or.b    d0, oSprFlags(a0)
	add.w   d1, d1
	add.w   d1, d1
	move.w  (a3, d1.w), d0
	move.w  $8(a1), oX(a0)
	add.w   d0, oX(a0)
	move.w  $2(a3, d1.w), d0
	move.w  $c(a1), oY(a0)
	add.w   d0, oY(a0)
	rts     
P8E_sub_20BD94:
	lea     P8E_loc_20BEDA.l, a2
	lea     P8E_loc_20BEE4.l, a3
	lea     P8E_loc_20BF0C.l, a4
	tst.b   oSubtype(a0)
	beq.s   P8E_loc_20BDC4
	lea     P8E_loc_20BEF8.l, a3
	lea     P8E_loc_20BF20.l, a4
	tst.b   oLayer(a0)
	beq.s   P8E_loc_20BDC4
	lea     P8E_loc_20BF34.l, a4
P8E_loc_20BDC4:
	lea     P8E_loc_20C238.l, a5
	bra.s   P8E_loc_20BE02
P8E_sub_20BDCC:
	lea     P8E_loc_20BEDA.l, a2
	lea     P8E_loc_20BEEE.l, a3
	lea     P8E_loc_20BF16.l, a4
	tst.b   oSubtype(a0)
	beq.s   P8E_loc_20BDFC
	lea     P8E_loc_20BF02.l, a3
	lea     P8E_loc_20BF2A.l, a4
	tst.b   oLayer(a0)
	beq.s   P8E_loc_20BDFC
	lea     P8E_loc_20BF3E.l, a4
P8E_loc_20BDFC:
	lea     P8E_loc_20C242.l, a5
P8E_loc_20BE02:
	movea.l $2a(a0), a1
	moveq   #$0, d0
	move.b  $1b(a1), d0
	move.b  (a2, d0.w), oMapFrame(a0)
	andi.b  #$fc, oSprFlags(a0)
	move.b  (a3, d0.w), d1
	or.b    d1, oSprFlags(a0)
	move.b  (a4, d0.w), d0
	lea     P8E_loc_20BF48.l, a4
	add.w   d0, d0
	add.w   d0, d0
	move.w  (a4, d0.w), d1
	move.w  $8(a1), oX(a0)
	add.w   d1, oX(a0)
	move.w  $2(a4, d0.w), d1
	move.w  $c(a1), oY(a0)
	add.w   d1, oY(a0)
	tst.b   oSubtype(a0)
	beq.s   P8E_loc_20BE96
	movea.l $2a(a0), a2
	movea.l $2a(a2), a2
	tst.b   $29(a2)
	beq.s   P8E_loc_20BE7E
	cmpi.b  #$2, $29(a2)
	bne.s   P8E_loc_20BE96
	tst.b   oLayer(a0)
	bne.s   P8E_loc_20BE96
	movea.l a5, a3
	move.l  a0, -(a7)
	movea.l a2, a0
	movea.l $2e(a2), a2
	bsr.w   P8E_sub_20C002
	movea.l (a7)+, a0
	rts     
P8E_loc_20BE7E:
	tst.b   debugMode.l
	bne.s   P8E_loc_20BE96
	lea     objects.w, a2
	bsr.s   P8E_sub_20BE98
	bne.w   P8E_loc_20C0B2
	move.b  #$0, oLayer(a0)
P8E_loc_20BE96:
	rts     
P8E_dat_20BC4E:
	dc.w	$0200,$0201,$0200,$0201,$0200
P8E_dat_20BC58:
	dc.w	$0020,$982C,$0020,$9826,$0020,$9876
P8E_loc_20BC64:
	dc.w	$0000,$0000,$0101,$0100,$0000
P8E_loc_20BC6E:
	dc.w	$0200,$0000,$0101,$0302,$0200
P8E_loc_20BC78:
	dc.w	$0101,$0302,$0200,$0000,$0100
P8E_loc_20BC82:
	dc.w	$0008,$FFF8,$0008,$0000,$0008,$FFF8,$0000,$FFF8
	dc.w	$FFF8,$FFF8,$FFF8,$0000,$FFF8,$FFF8,$0000,$FFF8
	dc.w	$0008,$FFF8
P8E_loc_20BCA6:
	dc.w	$0008,$0008,$0008,$0000,$0008,$FFF8,$0000,$FFF8
	dc.w	$FFF8,$FFF8,$FFF8,$0000,$FFF8,$0008,$0000,$0008
	dc.w	$0008,$0008
P8E_loc_20BCCA:
	dc.w	$FFF8,$FFF8,$FFF8,$0000,$FFF8,$0008,$0000,$0008
	dc.w	$0008,$0008,$0008,$0000,$0008,$FFF8,$0000,$FFF8
	dc.w	$FFF8,$FFF8
P8E_loc_20BCEE:
	movea.l $2e(a0), a1
	tst.b   oSubtype(a0)
	beq.s   P8E_loc_20BD2C
	cmpi.b  #$4, oLayer(a0)
	beq.s   P8E_loc_20BD48
	cmpi.b  #$2, oLayer(a0)
	bne.s   P8E_loc_20BD54
	move.b  p1CtrlTap.w, d0
	andi.b  #$70, d0
	beq.s   P8E_loc_20BD54
	move.b  #$4, oLayer(a0)
	movea.l a1, a2
	movea.l $2a(a0), a1
	moveq   #$0, d2
	move.b  $1b(a1), d2
	bsr.w   P8E_sub_20C194
	movea.l a2, a1
	bra.s   P8E_loc_20BD38
P8E_loc_20BD2C:
	tst.b   $32(a0)
	beq.s   P8E_loc_20BD48
	subq.b  #$1, $32(a0)
	bne.s   P8E_loc_20BD54
P8E_loc_20BD38:
	bclr.b  #$0, $FFFFD02C.w
	move.w  #$ce, d0
	jsr     PlayFMSound.l
P8E_loc_20BD48:
	lea     Ani_Spring.l, a1
	jsr     AnimateObject.l
P8E_loc_20BD54:
	bra.w   P8E_loc_20BBC0
P8E_loc_20BD58:
	subq.b  #$4, oRoutine(a0)
	move.b  #$0, oAnimFrame(a0)
	move.b  #$0, oMapFrame(a0)
	move.b  #$0, oLayer(a0)
	tst.b   oSubtype(a0)
	beq.s   P8E_loc_20BD92
	movea.l $2a(a0), a1
	movea.l $36(a1), a2
	move.b  #$0, $29(a2)
	movea.l $3a(a1), a2
	move.b  #$0, $29(a2)
	move.b  #$0, oLayer(a0)
P8E_loc_20BD92:
	rts     
P8E_sub_20C002:
	moveq   #$0, d0
	move.b  $1b(a1), d0
	move.w  d0, d2
	move.b  (a3, d0.w), d0
	lea     P8E_loc_20C24C.l, a1
	add.w   d0, d0
	add.w   d0, d0
	move.w  oX(a0), $8(a2)
	move.w  (a1, d0.w), d1
	add.w   d1, $8(a2)
	move.w  oY(a0), $c(a2)
	move.w  $2(a1, d0.w), d1
	add.w   d1, $c(a2)
	rts     
P8E_loc_20C036:
	lea     P8E_loc_20C06A.l, a3
	moveq   #$0, d0
	move.b  $25(a4), d0
	subi.b  #$a, d0
	beq.s   P8E_loc_20C04E
	lea     P8E_loc_20C08E.l, a3
P8E_loc_20C04E:
	move.b  $1b(a1), d0
	add.w   d0, d0
	add.w   d0, d0
	move.w  (a3, d0.w), $10(a4)
	move.w  $2(a3, d0.w), $12(a4)
	move.b  #$1a, $32(a4)
	rts     
P8E_loc_20C06A:
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$0001,$0000,$0001
	dc.w	$0001,$0001,$0001,$0000,$0001,$FFFF,$0000,$FFFF
	dc.w	$FFFF,$FFFF
P8E_loc_20C08E:
	dc.w	$0001,$0001,$0001,$0000,$0001,$FFFF,$0000,$FFFF
	dc.w	$FFFF,$FFFF,$FFFF,$0000,$FFFF,$0001,$0000,$0001
	dc.w	$0001,$0001
P8E_loc_20C0B2:
	clr.b   $3c(a2)
	bset.b  #$0, $2c(a2)
	bset.b  #$2, $22(a2)
	move.b  #$e, $16(a2)
	move.b  #$7, $17(a2)
	move.b  #$2, $1c(a2)
	movea.l $2a(a0), a4
	movea.l $2a(a4), a4
	addq.b  #$2, $24(a4)
	move.b  #$1, $29(a4)
	move.l  a2, $2e(a4)
	movea.l a5, a3
	movem.l a0-a1, -(a7)
	movea.l a4, a0
	bsr.w   P8E_sub_20C002
	movem.l (a7)+, a0-a1
	movea.l $2a(a0), a4
	cmpi.b  #$a, oRoutine(a0)
	bne.s   P8E_loc_20C10C
	adda.l  #$4, a4
P8E_loc_20C10C:
	movea.l $36(a4), a4
	move.b  $24(a4), $25(a4)
	movem.l a0-a4, -(a7)
	movea.l $2a(a0), a1
	movea.l $2a(a1), a1
	movea.l a4, a0
	cmpi.b  #$a, oRoutine(a0)
	bne.s   P8E_loc_20C138
	move.b  #$2, $28(a1)
	bsr.w   P8E_sub_20BD94
	bra.s   P8E_loc_20C142
P8E_loc_20C138:
	move.b  #$1, $28(a1)
	bsr.w   P8E_sub_20BDCC
P8E_loc_20C142:
	movem.l (a7)+, a0-a4
	move.b  #$e, $24(a4)
	move.b  #$1, $29(a4)
	bra.w   P8E_loc_20C036
P8E_loc_20C156:
	clr.b   $3c(a2)
	bset.b  #$0, $2c(a2)
	bset.b  #$2, $22(a2)
	move.b  #$e, $16(a2)
	move.b  #$7, $17(a2)
	move.b  #$2, $1c(a2)
	move.l  a2, $2e(a0)
	move.b  #$3c, $32(a0)
	addq.b  #$2, oRoutine(a0)
	movea.l $2a(a0), a1
	lea     P8E_loc_20C224.l, a3
	bsr.w   P8E_sub_20C002
P8E_sub_20BE98:
	move.w  #$18, d2
	move.w  #$18, d3
	bra.w   P8E_loc_20BFA4
P8E_loc_20BEA4:
	subq.b  #$1, $32(a0)
	bne.s   P8E_loc_20BEC8
	movea.l $2a(a0), a1
	movea.l $2a(a1), a1
	move.b  #$2, $29(a1)
	move.b  oSolidType(a0), oRoutine(a0)
	move.w  #$c0, d0
	jmp     PlayFMSound.l
P8E_loc_20BEC8:
	move.w  oXVel(a0), d0
	add.w   d0, oX(a0)
	move.w  oYVel(a0), d0
	add.w   d0, oY(a0)
	rts     
P8E_loc_20BEDA:
	dc.w	$0402,$0403,$0402,$0403,$0400
P8E_loc_20BEE4:
	dc.w	$0000,$0000,$0202,$0200,$0000
P8E_loc_20BEEE:
	dc.w	$0302,$0301,$0100,$0101,$0300
P8E_loc_20BEF8:
	dc.w	$0100,$0000,$0202,$0301,$0100
P8E_loc_20BF02:
	dc.w	$0202,$0301,$0100,$0000,$0200
P8E_loc_20BF0C:
	dc.w	$0100,$0102,$0304,$0302,$0100
P8E_loc_20BF16:
	dc.w	$0908,$090A,$0B0C,$0B0A,$0900
P8E_loc_20BF20:
	dc.w	$0700,$0102,$0304,$0506,$0700
P8E_loc_20BF2A:
	dc.w	$0304,$0506,$0700,$0102,$0300
P8E_loc_20BF34:
	dc.w	$0B0C,$0D0E,$0F08,$090A,$0B00
P8E_loc_20BF3E:
	dc.w	$0F08,$090A,$0B0C,$0D0E,$0F00
P8E_loc_20BF48:
	dc.w	$0018,$FFF0,$0004,$FFE4,$FFF0,$FFE8,$FFE4,$FFFC
	dc.w	$FFE8,$0010,$FFFC,$001C,$0010,$0018,$001C,$0004
	dc.w	$0018,$0010,$001C,$FFFC,$0010,$FFE8,$FFFC,$FFE4
	dc.w	$FFE8,$FFF0,$FFE4,$0004,$FFF0,$0018,$0004,$001C
P8E_loc_20BF88:
	tst.b   debugMode.l
	bne.s   P8E_loc_20BF9A
	lea     objects.w, a2
	bsr.s   P8E_sub_20BF9C
	bne.w   P8E_loc_20C156
P8E_loc_20BF9A:
	rts     
P8E_sub_20C194:
	btst.l  #$0, d2
	bne.s   P8E_loc_20C1EA
	move.w  #$e0, d0
	jsr     CalcSine.l
	mulu.w  #$1000, d0
	mulu.w  #$1000, d1
	lsr.l   #$8, d0
	lsr.l   #$8, d1
	move.w  d0, $12(a2)
	move.w  d1, $10(a2)
	btst.b  #$1, oSprFlags(a0)
	beq.s   P8E_loc_20C1C4
	neg.w   $12(a2)
P8E_loc_20C1C4:
	bclr.b  #$0, $22(a2)
	btst.b  #$0, oSprFlags(a0)
	beq.s   P8E_loc_20C1DC
	bset.b  #$0, $22(a2)
	neg.w   $10(a2)
P8E_loc_20C1DC:
	bset.b  #$1, $22(a2)
	bclr.b  #$3, $22(a2)
	rts     
P8E_loc_20C1EA:
	btst.l  #$1, d2
	bne.s   P8E_loc_20C20A
	move.w  #$0, $12(a2)
	move.w  #$1000, $10(a2)
	btst.b  #$0, oSprFlags(a0)
	beq.s   P8E_loc_20C1DC
	neg.w   $10(a2)
	bra.s   P8E_loc_20C1DC
P8E_loc_20C20A:
	move.w  #$0, $10(a2)
	move.w  #$f000, $12(a2)
	btst.b  #$1, oSprFlags(a0)
	beq.s   P8E_loc_20C1DC
	neg.w   $12(a2)
	bra.s   P8E_loc_20C1DC
P8E_loc_20C224:
	dc.w	$0100,$0102,$0304,$0302,$0100,$0700,$0102,$0304
	dc.w	$0506,$0700
P8E_loc_20C238:
	dc.w	$0100,$0102,$0304,$0506,$0700
P8E_loc_20C242:
	dc.w	$0304,$0506,$0700,$0102,$0300
P8E_loc_20C24C:
	dc.w	$0018,$0000,$0018,$FFE8,$0000,$FFE8,$FFE8,$FFE8
	dc.w	$FFE8,$0000,$FFE8,$0018,$0000,$0018,$0018,$0018
P8E_sub_20BF9C:
	move.w  #$20, d2
	move.w  #$20, d3
P8E_loc_20BFA4:
	cmpi.b  #$4, $24(a2)
	bne.s   P8E_loc_20BFB6
	subq.b  #$2, $24(a2)
	move.w  #$78, $30(a2)
P8E_loc_20BFB6:
	cmpi.b  #$2b, $1c(a2)
	beq.s   P8E_loc_20BFFE
	cmpi.b  #$6, $24(a2)
	bcc.s   P8E_loc_20BFFE
	move.b  $17(a2), d1
	ext.w   d1
	add.w   d2, d1
	move.w  oX(a0), d0
	sub.w   $8(a2), d0
	add.w   d1, d0
	bmi.s   P8E_loc_20BFFE
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P8E_loc_20BFFE
	move.b  $16(a2), d1
	ext.w   d1
	add.w   d3, d1
	move.w  oY(a0), d0
	sub.w   $c(a2), d0
	add.w   d1, d0
	bmi.s   P8E_loc_20BFFE
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P8E_loc_20BFFE
	moveq   #$1, d0
	rts     
P8E_loc_20BFFE:
	moveq   #$0, d0
	rts     
