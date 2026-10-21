; Object $5C - Obj2F_20B5DE (from R31A, old ID $2F)
Obj2F_20B5DE:
	tst.b   oSubtype(a0)
	bmi.w   P5C_loc_20B5EA
	bra.w   P5C_loc_20B8B8
P5C_loc_20B5EA:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P5C_dat_20B604(pc, d0.w), d0
	jsr     P5C_dat_20B604(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P5C_dat_20B604:
	dc.w	P5C_loc_20B61A-P5C_dat_20B604
	dc.w	P5C_loc_20B65A-P5C_dat_20B604
	dc.w	P5C_loc_20B718-P5C_dat_20B604
	dc.w	P5C_loc_20B768-P5C_dat_20B604
	dc.w	P5C_loc_20B784-P5C_dat_20B604
	dc.w	P5C_loc_20B7A0-P5C_dat_20B604
	dc.w	P5C_loc_20B7CC-P5C_dat_20B604
	dc.w	P5C_loc_20B7F8-P5C_dat_20B604
	dc.w	P5C_loc_20B814-P5C_dat_20B604
	dc.w	P5C_loc_20B830-P5C_dat_20B604
	dc.w	P5C_loc_20B878-P5C_dat_20B604
P5C_loc_20B61A:
	cmpi.b  #$2, timeZone.l
	bne.w   P5C_loc_20B636
	tst.b   goodFuture.l
	beq.w   P5C_loc_20B636
	jmp     DeleteObject.l
P5C_loc_20B636:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$0, oPriority(a0)
	move.w  #$3af, oTile(a0)
	move.l  #$20b88e, oMap(a0)
	move.w  #$7, $30(a0)
P5C_loc_20B65A:
	tst.w   debugMode.l
	bne.w   P5C_loc_20B678
	lea     objects.w, a6
	lea     $3e(a0), a5
	bsr.w   P5C_sub_20B67A
	tst.b   $3e(a0)
	bne.w   P5C_loc_20B6FE
P5C_loc_20B678:
	rts     
P5C_sub_20B67A:
	tst.w   $12(a6)
	bmi.w   P5C_loc_20B6FC
	cmpi.b  #$4, $24(a6)
	beq.w   P5C_loc_20B6FC
	cmpi.b  #$6, $24(a6)
	beq.w   P5C_loc_20B6FC
	move.w  $c(a6), d0
	sub.w   oY(a0), d0
	subi.w  #$ffe8, d0
	subi.w  #$10, d0
	bcc.w   P5C_loc_20B6FC
	move.w  $8(a6), d0
	sub.w   oX(a0), d0
	subi.w  #$ffe8, d0
	subi.w  #$30, d0
	bcc.w   P5C_loc_20B6FC
	st.b    (a5)
	bset.b  #$0, $2c(a6)
	bset.b  #$2, $22(a6)
	move.b  #$e, $16(a6)
	move.b  #$7, $17(a6)
	move.b  #$2, $1c(a6)
	move.w  #$0, $10(a6)
	move.w  #$f800, $12(a6)
	move.w  oX(a0), $8(a6)
	move.w  oY(a0), d0
	addi.w  #$fff0, d0
	move.w  d0, $c(a6)
P5C_loc_20B6FC:
	rts     
P5C_loc_20B6FE:
	addq.b  #$2, oRoutine(a0)
	move.w  #$8, $2a(a0)
	move.b  #$1, oMapFrame(a0)
	move.w  #$d7, d0
	jmp     PlayFMSound.l
P5C_loc_20B718:
	addi.w  #$ffff, $2a(a0)
	bpl.w   P5C_loc_20B760
	addq.b  #$2, oRoutine(a0)
	move.b  #$2, oMapFrame(a0)
	move.w  #$6, $2a(a0)
	jsr     FindObjSlot.l
	bne.w   P5C_loc_20B762
	move.w  a1, $2c(a0)
	move.w  a0, $2e(a1)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	lea     objects.w, a6
	bset.b  #$6, $2c(a6)
P5C_loc_20B760:
	rts     
P5C_loc_20B762:
	jmp     DeleteObject.l
P5C_loc_20B768:
	addi.w  #$ffff, $2a(a0)
	bpl.w   P5C_loc_20B782
	addq.b  #$2, oRoutine(a0)
	move.w  #$2, $2a(a0)
	move.b  #$3, oMapFrame(a0)
P5C_loc_20B782:
	rts     
P5C_loc_20B784:
	addi.w  #$ffff, $2a(a0)
	bpl.w   P5C_loc_20B79E
	addq.b  #$2, oRoutine(a0)
	move.w  #$1e, $2a(a0)
	move.b  #$0, oMapFrame(a0)
P5C_loc_20B79E:
	rts     
P5C_loc_20B7A0:
	addi.w  #$ffff, $2a(a0)
	bpl.w   P5C_loc_20B7CA
	addq.b  #$2, oRoutine(a0)
	move.w  #$1e, $2a(a0)
	tst.w   $30(a0)
	beq.s   P5C_loc_20B7CA
	subq.w  #$1, $30(a0)
	moveq   #$a, d0
	bsr.w   AddPoints
	moveq   #$0, d1
	bra.w   P5C_sub_205FC0
P5C_loc_20B7CA:
	rts     
P5C_loc_20B7CC:
	addi.w  #$ffff, $2a(a0)
	bpl.w   P5C_loc_20B7F6
	addq.b  #$2, oRoutine(a0)
	move.w  #$1e, $2a(a0)
	tst.w   $30(a0)
	beq.s   P5C_loc_20B7F6
	subq.w  #$1, $30(a0)
	moveq   #$a, d0
	bsr.w   AddPoints
	moveq   #$0, d1
	bra.w   P5C_sub_205FC0
P5C_loc_20B7F6:
	rts     
P5C_loc_20B7F8:
	addi.w  #$ffff, $2a(a0)
	bpl.w   P5C_loc_20B812
	addq.b  #$2, oRoutine(a0)
	move.w  #$4, $2a(a0)
	move.b  #$3, oMapFrame(a0)
P5C_loc_20B812:
	rts     
P5C_loc_20B814:
	addi.w  #$ffff, $2a(a0)
	bpl.w   P5C_loc_20B82E
	addq.b  #$2, oRoutine(a0)
	move.w  #$6, $2a(a0)
	move.b  #$2, oMapFrame(a0)
P5C_loc_20B82E:
	rts     
P5C_loc_20B830:
	addi.w  #$ffff, $2a(a0)
	bpl.w   P5C_loc_20B876
	move.w  #$9f, d0
	jsr     PlayFMSound.l
	addq.b  #$2, oRoutine(a0)
	move.b  #$0, oMapFrame(a0)
	move.w  #$78, $2a(a0)
	movea.w $2c(a0), a1
	move.b  #$4, $24(a1)
	tst.b   $3e(a0)
	beq.w   P5C_loc_20B876
	sf.b    $3e(a0)
	bclr.b  #$0, $FFFFD02C.w
	bclr.b  #$6, $FFFFD02C.w
P5C_loc_20B876:
	rts     
P5C_loc_20B878:
	addi.w  #$ffff, $2a(a0)
	bpl.w   P5C_loc_20B88C
	move.b  #$2, oRoutine(a0)
	sf.b    $3e(a0)
P5C_loc_20B88C:
	rts     
P5C_loc_20B88E:
	dc.w	$0008,$0009,$0014,$001F,$0002,$F809,$C000,$E8F8
	dc.w	$09C8,$0000,$02E8,$0500,$06F0,$E805,$0806,$0002
	dc.w	$F000,$000A,$F8F0,$0008,$0A00
P5C_loc_20B8B8:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P5C_dat_20B8C6(pc, d0.w), d0
	jmp     P5C_dat_20B8C6(pc, d0.w)
P5C_sub_205FC0:
	ori.b   #$80, d1
	jsr     FindObjSlot.l
	bne.s   P5C_loc_205FE2
	dc.b	$13,$7C,$00,$1C,$00,$00		; move.b #$1c, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  d1, $28(a1)
P5C_loc_205FE2:
	rts     
P5C_dat_20B8C6:
	dc.w	P5C_loc_20B8CC-P5C_dat_20B8C6
	dc.w	P5C_loc_20B8F6-P5C_dat_20B8C6
	dc.w	P5C_loc_20B91A-P5C_dat_20B8C6
P5C_loc_20B8CC:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$0, oPriority(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.w  #$43af, oTile(a0)
	move.l  #$20b926, oMap(a0)
P5C_loc_20B8F6:
	movea.w $2e(a0), a1
	dc.b	$0C,$29,$00,$2F,$00,$00		; cmpi.b #$2f, $0(a1) (raw: not reproducible by assembler)
	beq.w   P5C_loc_20B90A
	jmp     DeleteObject.l
P5C_loc_20B90A:
	lea     P5C_dat_20B920(pc), a1
	jsr     AnimateObject.l
	jmp     DrawObject.l
P5C_loc_20B91A:
	jmp     DeleteObject.l
P5C_dat_20B920:
	dc.w	$0002,$0300,$01FF
P5C_loc_20B926:
	dc.w	$0004,$000F,$02F8,$0900,$00E8,$F809,$0800,$0000
