; Object $C2 - Obj2F_20DC88 (from R81A, old ID $2F)
Obj2F_20DC88:
	cmpi.b  #$2, oSubtype(a0)
	beq.w   PC2_loc_20E19A
	bcs.w   PC2_loc_20DE66
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PC2_dat_20DCA4(pc, d0.w), d0
	jmp     PC2_dat_20DCA4(pc, d0.w)
PC2_dat_20DCA4:
	dc.w	PC2_loc_20DCAA-PC2_dat_20DCA4
	dc.w	PC2_loc_20DCD6-PC2_dat_20DCA4
	dc.w	PC2_loc_20DDA2-PC2_dat_20DCA4
PC2_loc_20DCAA:
	addq.b  #$2, oRoutine(a0)
	moveq   #$0, d0
	move.b  oSavedFlagsID(a0), d0
	lea     savedObjFlags.l, a1
	move.w  d0, d1
	add.w   d1, d1
	add.w   d1, d0
	moveq   #$0, d1
	move.b  timeZone.l, d1
	bclr.l  #$7, d1
	add.w   d1, d0
	lea     $2(a1, d0.w), a1
	move.l  a1, $2a(a0)
PC2_loc_20DCD6:
	lea     objects.w, a1
	bsr.s   PC2_sub_20DCE4
	bcs.s   PC2_loc_20DD08
	jmp     CheckObjDespawn.l
PC2_sub_20DCE4:
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	subi.w  #$fec0, d0
	subi.w  #$280, d0
	bcc.s   PC2_loc_20DD06
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	subi.w  #$fec0, d0
	subi.w  #$280, d0
PC2_loc_20DD06:
	rts     
PC2_loc_20DD08:
	addq.b  #$2, oRoutine(a0)
	movea.l $2a(a0), a6
	btst.b  #$0, (a6)
	bne.s   PC2_loc_20DD3E
	jsr     FindNextObjSlot.l
	bne.w   PC2_loc_20E312
	bsr.s   PC2_sub_20DD84
	move.w  a1, $2e(a0)
	move.b  oSubtype(a0), d0
	andi.b  #$1, d0
	move.b  d0, $28(a1)
	btst.b  #$4, oSubtype(a0)
	sne.b   d0
	move.b  d0, $29(a1)
PC2_loc_20DD3E:
	btst.b  #$1, (a6)
	bne.s   PC2_loc_20DD82
	move.b  oLayer(a0), d6
	bmi.w   PC2_loc_20DD9C
	cmpi.b  #$7, d6
	bhi.w   PC2_loc_20DD9C
	jsr     FindNextObjSlot.l
	bne.w   PC2_loc_20E312
	bsr.s   PC2_sub_20DD84
	move.w  a1, $30(a0)
	move.b  #$2, $28(a1)
	move.b  d6, $29(a1)
	subq.w  #$4, $c(a1)
	moveq   #$18, d0
	btst.b  #$4, oSubtype(a0)
	beq.s   PC2_loc_20DD7E
	neg.w   d0
PC2_loc_20DD7E:
	sub.w   d0, $8(a1)
PC2_loc_20DD82:
	rts     
PC2_sub_20DD84:
	move.w  a0, $2a(a1)
	dc.b	$13,$7C,$00,$2F,$00,$00		; move.b #$2f, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	rts     
PC2_loc_20DD9C:
	bset.b  #$1, (a6)
	rts     
PC2_loc_20DDA2:
	movea.l $2a(a0), a6
	btst.b  #$0, (a6)
	bne.s   PC2_loc_20DDDE
	move.w  $2e(a0), d6
	beq.s   PC2_loc_20DDDE
	movea.w d6, a1
	dc.b	$0C,$29,$00,$2F,$00,$00		; cmpi.b #$2f, $0(a1) (raw: not reproducible by assembler)
	beq.s   PC2_loc_20DDDE
	bset.b  #$0, (a6)
	clr.w   $2e(a0)
	move.w  $30(a0), d6
	beq.s   PC2_loc_20DDD0
	movea.w d6, a1
	clr.w   $10(a1)
PC2_loc_20DDD0:
	move.w  $32(a1), d6
	beq.s   PC2_loc_20DDDE
	movea.w d6, a1
	bclr.b  #$0, $2c(a1)
PC2_loc_20DDDE:
	btst.b  #$1, (a6)
	bne.s   PC2_loc_20DDFC
	move.w  $30(a0), d6
	beq.s   PC2_loc_20DDFC
	movea.w d6, a1
	dc.b	$0C,$29,$00,$2F,$00,$00		; cmpi.b #$2f, $0(a1) (raw: not reproducible by assembler)
	beq.s   PC2_loc_20DDFC
	bset.b  #$1, (a6)
	clr.w   $30(a0)
PC2_loc_20DDFC:
	btst.b  #$0, (a6)
	sne.b   d0
	lsl.w   #$8, d0
	btst.b  #$1, (a6)
	sne.b   d0
	cmpi.w  #$ffff, d0
	beq.w   PC2_loc_20E318
	cmpi.w  #$0, d0
	bne.s   PC2_loc_20DE58
	move.w  $2e(a0), d0
	sne.b   d0
	move.w  $30(a0), d1
	sne.b   d1
	eor.b   d0, d1
	beq.s   PC2_loc_20DE58
	tst.b   d0
	beq.s   PC2_loc_20DE4A
	movea.w $2e(a0), a1
	move.w  $32(a1), d0
	beq.s   PC2_loc_20DE3E
	movea.w d0, a2
	bclr.b  #$0, $2c(a2)
PC2_loc_20DE3E:
	jsr     loc_20371A.l
	clr.w   $2e(a0)
	bra.s   PC2_loc_20DE58
PC2_loc_20DE4A:
	movea.w $30(a0), a1
	jsr     loc_20371A.l
	clr.w   $30(a0)
PC2_loc_20DE58:
	move.w  $2e(a0), d0
	or.w    $30(a0), d0
	beq.w   PC2_loc_20E312
	rts     
PC2_loc_20DE66:
	cmpi.b  #$1, oLayer(a0)
	beq.w   PC2_loc_20E174
	movea.w $2a(a0), a1
	dc.b	$0C,$29,$00,$2F,$00,$00		; cmpi.b #$2f, $0(a1) (raw: not reproducible by assembler)
	bne.w   PC2_loc_20E318
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PC2_dat_20DEAE(pc, d0.w), d0
	jsr     PC2_dat_20DEAE(pc, d0.w)
	jsr     DrawObject.l
	move.w  $2a(a0), -(a7)
	jsr     CheckObjDespawn.l
	movea.w (a7)+, a1
	tst.w   (a0)
	bne.s   PC2_loc_20DEAC
	clr.w   $2e(a1)
PC2_loc_20DEAC:
	rts     
PC2_dat_20DEAE:
	dc.w	PC2_loc_20DEB2-PC2_dat_20DEAE
	dc.w	PC2_loc_20DF8C-PC2_dat_20DEAE
PC2_loc_20DEB2:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$20, oXRadius(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$b, oYRadius(a0)
	move.b  #$f0, oColType(a0)
	move.b  #$1, oPriority(a0)
	move.w  #$243f, oTile(a0)
	move.l  #$20e32a, oMap(a0)
	move.w  oX(a0), $2c(a0)
	move.w  #$3c, $34(a0)
	jsr     ObjGetFloorDist.l
	add.w   d1, oY(a0)
	jsr     FindNextObjSlot.l
	bne.w   PC2_loc_20E312
	dc.b	$13,$7C,$00,$2F,$00,$00		; move.b #$2f, $0(a1) (raw: not reproducible by assembler)
	move.b  #$1, $29(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  oSprFlags(a0), $1(a1)
	move.b  oXRadius(a0), $17(a1)
	move.b  oWidth(a0), $19(a1)
	move.b  oYRadius(a0), $16(a1)
	move.w  oTile(a0), $2(a1)
	move.l  oMap(a0), $4(a1)
	move.w  a1, $3c(a0)
	move.w  a0, $2a(a1)
	tst.b   oLayer(a0)
	beq.s   PC2_loc_20DF6A
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$0, $1(a1)
	bset.b  #$0, oFlags(a0)
	bset.b  #$0, $22(a1)
PC2_loc_20DF6A:
	lea     PC2_dat_20E31E(pc), a1
	move.l  #$6000, d0
	tst.b   oSubtype(a0)
	beq.s   PC2_loc_20DF84
	lea     PC2_dat_20E324(pc), a1
	move.l  #$3000, d0
PC2_loc_20DF84:
	move.l  a1, $38(a0)
	move.l  d0, $2e(a0)
PC2_loc_20DF8C:
	move.w  oY(a0), -(a7)
	move.w  oX(a0), -(a7)
	tst.w   $34(a0)
	bmi.s   PC2_loc_20DFCE
	move.l  $2e(a0), d6
	add.l   d6, oX(a0)
	move.w  oX(a0), d0
	sub.w   $2c(a0), d0
	bpl.s   PC2_loc_20DFAE
	neg.w   d0
PC2_loc_20DFAE:
	cmpi.w  #$40, d0
	blt.s   PC2_loc_20DFB6
	bsr.s   PC2_sub_20E032
PC2_loc_20DFB6:
	jsr     ObjGetFloorDist.l
	move.w  d1, d0
	addq.w  #$7, d0
	subi.w  #$e, d0
	bcs.s   PC2_loc_20DFCA
	bsr.s   PC2_sub_20E032
	bra.s   PC2_loc_20DFCE
PC2_loc_20DFCA:
	add.w   d1, oY(a0)
PC2_loc_20DFCE:
	move.w  (a7)+, d6
	move.w  (a7)+, d5
	sub.w   oX(a0), d6
	sub.w   oY(a0), d5
	movea.w $2a(a0), a1
	move.w  $30(a1), d4
	beq.s   PC2_loc_20DFF8
	movea.w d4, a1
	sub.w   d6, $8(a1)
	sub.w   d5, $c(a1)
	move.w  d6, d0
	neg.w   d0
	asl.w   #$8, d0
	move.w  d0, $10(a1)
PC2_loc_20DFF8:
	move.w  $32(a0), d4
	beq.s   PC2_loc_20E008
	movea.w d4, a1
	sub.w   d6, $8(a1)
	sub.w   d5, $c(a1)
PC2_loc_20E008:
	moveq   #$0, d0
	move.b  oSolidType(a0), d0
	move.w  PC2_dat_20E040(pc, d0.w), d0
	jsr     PC2_dat_20E040(pc, d0.w)
	movea.w $3c(a0), a1
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  oMapFrame(a0), d0
	addq.b  #$3, d0
	move.b  d0, $1a(a1)
	rts     
PC2_dat_20E31E:
	dc.w	$0002,$0900,$01FF
PC2_dat_20E324:
	dc.w	$0002,$1300,$01FF
PC2_loc_20E32A:
	dc.w	$000C,$0021,$0036,$004B,$0056,$0066,$04F4,$0A00
	dc.w	$0000,$F40D,$000F,$E004,$0400,$17E0,$0404,$0019
	dc.w	$F004,$F40A,$0000,$00F4,$0D00,$24E0,$0400,$002C
	dc.w	$E004,$0400,$19F0,$04F4,$0A00,$0000,$F40D,$0035
	dc.w	$D8F4,$0100,$3DF8,$0404,$0019,$F002,$F404,$0009
	dc.w	$F0FC,$0500,$0BE8,$03F4,$0800,$1BE8,$FC0C,$001E
	dc.w	$E004,$0400,$22E0,$01F4,$0D00,$2DE0
PC2_sub_20E032:
	move.l  $2e(a0), d6
	sub.l   d6, oX(a0)
	neg.l   $2e(a0)
	rts     
PC2_dat_20E040:
	dc.w	PC2_loc_20E046-PC2_dat_20E040
	dc.w	PC2_loc_20E0EA-PC2_dat_20E040
	dc.w	PC2_loc_20E15E-PC2_dat_20E040
PC2_loc_20E046:
	tst.b   oColStatus(a0)
	beq.s   PC2_loc_20E076
	lea     objects.w, a1
	cmpi.b  #$4, $24(a1)
	beq.s   PC2_loc_20E072
	cmpi.b  #$6, $24(a1)
	beq.s   PC2_loc_20E072
	tst.w   $30(a1)
	bne.s   PC2_loc_20E072
	movea.w $2a(a0), a1
	tst.w   $30(a1)
	bne.s   PC2_loc_20E072
	bra.s   PC2_loc_20E096
PC2_loc_20E072:
	clr.b   oColStatus(a0)
PC2_loc_20E076:
	subq.w  #$1, $34(a0)
	bpl.s   PC2_loc_20E08C
	cmpi.w  #$ffe2, $34(a0)
	bgt.s   PC2_loc_20E08A
	move.w  #$3c, $34(a0)
PC2_loc_20E08A:
	rts     
PC2_loc_20E08C:
	movea.l $38(a0), a1
	jmp     AnimateObject.l
PC2_loc_20E096:
	lea     objects.w, a1
	move.w  a1, $32(a0)
	bset.b  #$0, $2c(a1)
	bset.b  #$2, $22(a1)
	move.b  #$2, $1c(a1)
	move.b  #$e, $16(a1)
	move.b  #$7, $17(a1)
	move.w  oY(a0), d0
	subq.w  #$3, d0
	move.w  d0, $c(a1)
	moveq   #$e8, d0
	tst.b   oLayer(a0)
	beq.s   PC2_loc_20E0D0
	neg.w   d0
PC2_loc_20E0D0:
	add.w   oX(a0), d0
	move.w  d0, $8(a1)
	addq.b  #$2, oSolidType(a0)
	move.w  #$78, $36(a0)
PC2_loc_20E0E2:
	move.w  #$f000, oColType(a0)
	rts     
PC2_loc_20E0EA:
	subq.w  #$1, $36(a0)
	beq.s   PC2_loc_20E0F4
	bsr.s   PC2_loc_20E0E2
	bra.s   PC2_loc_20E076
PC2_loc_20E0F4:
	movea.w $32(a0), a1
	clr.w   $32(a0)
	bclr.b  #$0, $2c(a1)
	move.w  #$0, $12(a1)
	move.w  #$f600, d0
	tst.b   oSubtype(a0)
	beq.s   PC2_loc_20E116
	move.w  #$fb00, d0
PC2_loc_20E116:
	move.w  d0, $10(a1)
	bset.b  #$0, $22(a1)
	tst.b   oLayer(a0)
	beq.s   PC2_loc_20E130
	neg.w   $10(a1)
	bclr.b  #$0, $22(a1)
PC2_loc_20E130:
	move.w  #$f, $3e(a1)
	move.w  $10(a1), $14(a1)
	clr.b   $26(a1)
	bclr.b  #$5, $22(a1)
	addq.b  #$2, oSolidType(a0)
	move.w  #$0, oColType(a0)
	move.b  #$2, oMapFrame(a0)
	move.w  #$1e, $36(a0)
	rts     
PC2_loc_20E15E:
	subq.w  #$1, $36(a0)
	beq.s   PC2_loc_20E166
	rts     
PC2_loc_20E166:
	clr.b   oSolidType(a0)
	move.b  #$ff, oPrevAnim(a0)
	bra.w   PC2_loc_20E0E2
PC2_loc_20E174:
	movea.w $2a(a0), a1
	dc.b	$0C,$29,$00,$2F,$00,$00		; cmpi.b #$2f, $0(a1) (raw: not reproducible by assembler)
	bne.w   PC2_loc_20E318
	tst.b   oRoutine(a0)
	beq.s   PC2_loc_20E18E
	jmp     DrawObject.l
PC2_loc_20E18E:
	addq.b  #$2, oRoutine(a0)
	move.b  #$3, oPriority(a0)
	rts     
PC2_loc_20E19A:
	movea.w $2a(a0), a1
	dc.b	$0C,$29,$00,$2F,$00,$00		; cmpi.b #$2f, $0(a1) (raw: not reproducible by assembler)
	bne.w   PC2_loc_20E318
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PC2_dat_20E1B6(pc, d0.w), d1
	jmp     PC2_dat_20E1B6(pc, d1.w)
PC2_dat_20E1B6:
	dc.w	PC2_loc_20E1C0-PC2_dat_20E1B6
	dc.w	PC2_loc_20E206-PC2_dat_20E1B6
	dc.w	PC2_loc_20E274-PC2_dat_20E1B6
	dc.w	PC2_loc_20E244-PC2_dat_20E1B6
	dc.w	PC2_loc_20E258-PC2_dat_20E1B6
PC2_loc_20E1C0:
	addq.b  #$2, oRoutine(a0)
	move.b  #$e, oYRadius(a0)
	move.b  #$e, oXRadius(a0)
	move.l  #$20944a, oMap(a0)
	move.w  #$5a8, oTile(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$2, oPriority(a0)
	move.b  #$f, oWidth(a0)
	move.b  #$c6, oColType(a0)
	move.b  oLayer(a0), oAnim(a0)
	jsr     ObjGetFloorDist.l
	add.w   d1, oY(a0)
PC2_loc_20E206:
	tst.b   oSprFlags(a0)
	bpl.w   PC2_loc_20E258
	move.b  oSolidType(a0), d0
	beq.s   PC2_loc_20E236
	jsr     ObjMoveGrv.l
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.w   PC2_loc_20E244
	add.w   d1, oY(a0)
	clr.w   oYVel(a0)
	clr.b   oSolidType(a0)
	bra.w   PC2_loc_20E244
PC2_loc_20E236:
	tst.b   oSprFlags(a0)
	bpl.s   PC2_loc_20E244
	lea     objects.w, a1
	bsr.w   PC2_sub_20E2F6
PC2_loc_20E244:
	tst.w   timeStopTimer.l
	bne.s   PC2_loc_20E258
	lea     Ani_Monitor.l, a1
	jsr     AnimateObject.l
PC2_loc_20E258:
	jsr     DrawObject.l
	move.w  $2a(a0), -(a7)
	jsr     CheckObjDespawn.l
	movea.w (a7)+, a1
	tst.w   (a0)
	bne.s   PC2_loc_20E272
	clr.w   $30(a1)
PC2_loc_20E272:
	rts     
PC2_loc_20E274:
	movea.w $2a(a0), a1
	move.w  $2e(a1), d6
	beq.s   PC2_loc_20E286
	movea.w d6, a6
	move.b  #$1, $21(a6)
PC2_loc_20E286:
	lea     objects.w, a1
	bsr.w   PC2_sub_20E2F6
	beq.s   PC2_loc_20E296
	jsr     GetOffObject.l
PC2_loc_20E296:
	move.w  #$96, d0
	jsr     PlayFMSound.l
	addq.b  #$4, oRoutine(a0)
	move.b  #$0, oColType(a0)
	jsr     FindObjSlot.l
	bne.s   PC2_loc_20E2CA
	dc.b	$13,$7C,$00,$1A,$00,$00		; move.b #$1a, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  oAnim(a0), $1c(a1)
PC2_loc_20E2CA:
	jsr     FindObjSlot.l
	bne.s   PC2_loc_20E2F0
	dc.b	$13,$7C,$00,$18,$00,$00		; move.b #$18, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  #$1, $25(a1)
	move.b  #$1, $28(a1)
PC2_loc_20E2F0:
	jmp     DeleteObject.l
PC2_sub_20E2F6:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	move.b  #$19, oID(a0)
	jsr     SolidObject.l
	move.b  #$2f, oID(a0)
	rts     
PC2_loc_20E312:
	jmp     DespawnObject.l
PC2_loc_20E318:
	jmp     DeleteObject.l
