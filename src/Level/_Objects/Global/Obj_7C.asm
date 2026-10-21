; Object $7C - Obj2D_20DA7A (from R41A, old ID $2D)
Obj2D_20DA7A:
	tst.b   oSubtype(a0)
	bpl.s   P7C_loc_20DA84
	bra.w   P7C_loc_20DE12
P7C_loc_20DA84:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P7C_dat_20DAA4(pc, d0.w), d0
	jsr     P7C_dat_20DAA4(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P7C_dat_20DAA4:
	dc.w	P7C_loc_20DAAE-P7C_dat_20DAA4
	dc.w	P7C_loc_20DBEA-P7C_dat_20DAA4
	dc.w	P7C_loc_20DCDC-P7C_dat_20DAA4
	dc.w	P7C_loc_20DD82-P7C_dat_20DAA4
	dc.w	P7C_loc_20DDB2-P7C_dat_20DAA4
P7C_loc_20DAAE:
	move.w  oX(a0), $38(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$23d0, oTile(a0)
	move.b  #$14, oXRadius(a0)
	move.b  #$14, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.b  #$2d, oColType(a0)
	addq.b  #$2, oRoutine(a0)
	move.l  #$20ddde, oMap(a0)
	move.l  #$ffff0000, $2c(a0)
	move.w  #$c8, $36(a0)
	tst.b   oSubtype(a0)
	beq.s   P7C_loc_20DB16
	move.l  #$20ddf8, oMap(a0)
	move.l  #$ffff8000, $2c(a0)
	move.w  #$190, $36(a0)
	rts     
P7C_loc_20DB16:
	jsr     FindObjSlot.l
	bne.w   P7C_loc_20DE8A
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  oSavedFlagsID(a0), $3d(a1)
	move.w  a0, $3e(a1)
	move.w  a1, $30(a0)
	jsr     FindObjSlot.l
	bne.w   P7C_loc_20DE8A
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  oSavedFlagsID(a0), $3d(a1)
	move.w  a0, $3e(a1)
	move.w  a1, $32(a0)
	jsr     FindObjSlot.l
	bne.w   P7C_loc_20DE8A
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  oSavedFlagsID(a0), $3d(a1)
	move.w  a0, $3e(a1)
	move.w  a1, $34(a0)
	movea.w $30(a0), a6
	bsr.s   P7C_sub_20DBB8
	addq.w  #$2, $8(a6)
	addi.w  #$fff6, $c(a6)
	movea.w $32(a0), a6
	bsr.s   P7C_sub_20DBB8
	addi.w  #$fffd, $8(a6)
	addi.w  #$fff6, $c(a6)
	movea.w $34(a0), a6
	bsr.s   P7C_sub_20DBB8
	addi.w  #$fff9, $8(a6)
	addi.w  #$fff7, $c(a6)
	rts     
P7C_sub_20DBB8:
	move.w  oX(a0), $8(a6)
	move.w  oY(a0), $c(a6)
	ori.b   #$4, $1(a6)
	move.w  #$23d0, $2(a6)
	move.b  #$3, $18(a6)
	move.b  #$2, $17(a6)
	move.b  #$2, $19(a6)
	move.b  #$2, $16(a6)
	rts     
P7C_loc_20DBEA:
	tst.b   oSubtype(a0)
	bne.s   P7C_loc_20DBFC
	lea     objects.w, a6
	bsr.w   P7C_sub_20DCA2
	bcs.w   P7C_loc_20DCD0
P7C_loc_20DBFC:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	tst.b   oSubtype(a0)
	bne.s   P7C_loc_20DC22
	movea.w $30(a0), a1
	add.l   d0, $8(a1)
	movea.w $32(a0), a1
	add.l   d0, $8(a1)
	movea.w $34(a0), a1
	add.l   d0, $8(a1)
P7C_loc_20DC22:
	addi.w  #$ffff, $2a(a0)
	bpl.w   P7C_loc_20DC98
	move.w  $36(a0), $2a(a0)
	neg.l   $2c(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	tst.b   oSubtype(a0)
	bne.s   P7C_loc_20DC98
	movea.w $30(a0), a1
	movea.w $32(a0), a2
	movea.w $34(a0), a3
	move.w  oX(a0), $8(a1)
	move.w  oX(a0), $8(a2)
	move.w  oX(a0), $8(a3)
	move.w  #$fffe, d1
	move.w  #$3, d2
	move.w  #$7, d3
	btst.b  #$0, oSprFlags(a0)
	beq.s   P7C_loc_20DC8C
	neg.w   d1
	neg.w   d2
	neg.w   d3
	addi.w  #$fffd, d1
	addi.w  #$fffd, d2
	addi.w  #$fffd, d3
P7C_loc_20DC8C:
	add.w   d1, $8(a1)
	add.w   d2, $8(a2)
	add.w   d3, $8(a3)
P7C_loc_20DC98:
	lea     P7C_dat_20DDD8(pc), a1
	jmp     AnimateObject.l
P7C_sub_20DCA2:
	move.w  $c(a6), d0
	sub.w   oY(a0), d0
	subi.w  #$ffc8, d0
	subi.w  #$38, d0
	bcc.s   P7C_loc_20DCCE
	move.w  $8(a6), d0
	sub.w   oX(a0), d0
	btst.b  #$0, oSprFlags(a0)
	bne.s   P7C_loc_20DCC6
	neg.w   d0
P7C_loc_20DCC6:
	subi.w  #$28, d0
	subi.w  #$78, d0
P7C_loc_20DCCE:
	rts     
P7C_loc_20DCD0:
	addq.b  #$2, oRoutine(a0)
	move.w  #$3c, $2a(a0)
	rts     
P7C_loc_20DCDC:
	addi.w  #$ffff, $2a(a0)
	bpl.w   P7C_loc_20DD80
	tst.b   oSprFlags(a0)
	bpl.s   P7C_loc_20DCF6
	move.w  #$b3, d0
	jsr     PlayFMSound.l
P7C_loc_20DCF6:
	move.w  #$3c, $2a(a0)
	addq.b  #$2, oRoutine(a0)
	tst.b   oSubtype(a0)
	bne.w   P7C_loc_20DD80
	movea.w $30(a0), a1
	move.l  #$fffe0000, $2a(a1)
	move.l  #$fffd0000, $2e(a1)
	move.l  #$0, $32(a1)
	move.l  #$2000, $36(a1)
	addq.b  #$2, $24(a1)
	movea.w $32(a0), a1
	move.l  #$10000, $2a(a1)
	move.l  #$fffd0000, $2e(a1)
	move.l  #$0, $32(a1)
	move.l  #$2000, $36(a1)
	addq.b  #$2, $24(a1)
	movea.w $34(a0), a1
	move.l  #$20000, $2a(a1)
	move.l  #$fffd0000, $2e(a1)
	move.l  #$0, $32(a1)
	move.l  #$2000, $36(a1)
	addq.b  #$2, $24(a1)
P7C_loc_20DD80:
	rts     
P7C_loc_20DD82:
	addi.w  #$ffff, $2a(a0)
	bpl.s   P7C_loc_20DDB0
	addq.b  #$2, oRoutine(a0)
	move.l  #$40000, $2c(a0)
	tst.b   oSubtype(a0)
	beq.s   P7C_loc_20DDA4
	move.l  #$18000, $2c(a0)
P7C_loc_20DDA4:
	btst.b  #$0, oSprFlags(a0)
	bne.s   P7C_loc_20DDB0
	neg.l   $2c(a0)
P7C_loc_20DDB0:
	rts     
P7C_loc_20DDB2:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	rts     
	move.w  oX(a0), d0
	lea     objects.w, a1
	sub.w   $8(a1), d0
	bpl.w   P7C_loc_20DDCE
	neg.w   d0
P7C_loc_20DDCE:
	cmpi.w  #$140, d0
	bge.w   P7C_loc_20DE8A
	rts     
P7C_dat_20DDD8:
	dc.w	$0002,$1E00,$01FF
P7C_loc_20DDDE:
	dc.w	$0004,$000F,$02F4,$0E00,$00EC,$F401,$000C,$0C02
	dc.w	$F40A,$000E,$ECF4,$0500,$1704
P7C_loc_20DDF8:
	dc.w	$0004,$000F,$02F4,$0E00,$00EC,$F401,$000C,$0C02
	dc.w	$F40A,$000E,$ECF4,$0500,$1704
P7C_loc_20DE12:
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$2D,$00,$00		; cmpi.b #$2d, $0(a1) (raw: not reproducible by assembler)
	bne.w   P7C_loc_20DE8A
	move.b  $23(a1), d0
	cmp.b   $3d(a0), d0
	bne.w   P7C_loc_20DE8A
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P7C_dat_20DE3A(pc, d0.w), d0
	jmp     P7C_dat_20DE3A(pc, d0.w)
P7C_dat_20DE3A:
	dc.w	P7C_loc_20DE40-P7C_dat_20DE3A
	dc.w	P7C_loc_20DE4C-P7C_dat_20DE3A
	dc.w	P7C_loc_20DE52-P7C_dat_20DE3A
P7C_loc_20DE40:
	addq.b  #$2, oRoutine(a0)
	move.l  #$20de90, oMap(a0)
P7C_loc_20DE4C:
	jmp     DrawObject.l
P7C_loc_20DE52:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	move.l  $2e(a0), d0
	add.l   d0, oY(a0)
	move.l  $32(a0), d0
	add.l   d0, $2a(a0)
	move.l  $36(a0), d0
	add.l   d0, $2e(a0)
	lea     objects.w, a1
	move.w  oY(a0), d0
	sub.w   $c(a1), d0
	cmpi.w  #$e0, d0
	bge.s   P7C_loc_20DE8A
	jmp     DrawObject.l
P7C_loc_20DE8A:
	jmp     DeleteObject.l
P7C_loc_20DE90:
	dc.w	$0002,$0100,$0000,$1B00
