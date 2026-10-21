; Object $1D - Obj1D_20ADAC (from R31A, old ID $1D)
Obj1D_20ADAC:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P1D_dat_20ADBA(pc, d0.w), d1
	jmp     P1D_dat_20ADBA(pc, d1.w)
P1D_dat_20ADBA:
	dc.w	P1D_loc_20ADBE-P1D_dat_20ADBA
	dc.w	P1D_loc_20AE38-P1D_dat_20ADBA
P1D_loc_20ADBE:
	addq.b  #$2, oRoutine(a0)
	move.l  #$20b0b8, oMap(a0)
	move.w  #$4ce, oTile(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$d7, oColType(a0)
	move.w  oX(a0), $32(a0)
	move.w  #$5, $34(a0)
	moveq   #$0, d0
	move.b  oSubtype(a0), d6
	btst.l  #$1, d6
	beq.s   P1D_loc_20AE10
	addi.w  #$40, d0
P1D_loc_20AE10:
	btst.l  #$0, d6
	beq.s   P1D_loc_20AE1A
	addi.w  #$20, d0
P1D_loc_20AE1A:
	move.w  d0, $30(a0)
	lsr.w   #$1, d0
	move.w  d0, $2e(a0)
	beq.s   P1D_loc_20AE38
	move.l  #$10000, $2a(a0)
	btst.l  #$6, d6
	bne.s   P1D_loc_20AE38
	neg.l   $2a(a0)
P1D_loc_20AE38:
	move.l  $2a(a0), d0
	beq.s   P1D_loc_20AE60
	lea     oX(a0), a1
	tst.w   oSubtype(a0)
	bmi.s   P1D_loc_20AE4C
	lea     oY(a0), a1
P1D_loc_20AE4C:
	add.l   d0, (a1)
	addi.w  #$ffff, $2e(a0)
	bne.s   P1D_loc_20AE60
	move.w  $30(a0), $2e(a0)
	neg.l   $2a(a0)
P1D_loc_20AE60:
	tst.b   oColStatus(a0)
	beq.w   P1D_loc_20AEFC
	tst.w   $34(a0)
	beq.s   P1D_loc_20AE7E
	subq.w  #$1, $34(a0)
	moveq   #$a, d0
	bsr.w   AddPoints
	moveq   #$0, d1
	bsr.w   P1D_sub_205FC0
P1D_loc_20AE7E:
	tst.b   oSprFlags(a0)
	bpl.s   P1D_loc_20AE8E
	move.w  #$7f, d0
	jsr     SubCPUCmd.l
P1D_loc_20AE8E:
	lea     objects.w, a1
	clr.b   oColStatus(a0)
	move.w  oX(a0), d1
	move.w  oY(a0), d2
	sub.w   $8(a1), d1
	sub.w   $c(a1), d2
	jsr     CalcAngle.l
	jsr     CalcSine.l
	muls.w  #$f900, d1
	asr.l   #$8, d1
	move.w  d1, $10(a1)
	muls.w  #$f900, d0
	asr.l   #$8, d0
	move.w  d0, $12(a1)
	bset.b  #$1, $22(a1)
	bclr.b  #$4, $22(a1)
	bclr.b  #$5, $22(a1)
	clr.b   $3c(a1)
	move.b  #$1, oAnim(a0)
	lea     savedObjFlags.l, a2
	moveq   #$0, d0
	move.b  oSavedFlagsID(a0), d0
	beq.s   P1D_loc_20AEFC
	cmpi.b  #$8a, $2(a2, d0.w)
	bcc.s   P1D_loc_20AEFC
	addq.b  #$1, $2(a2, d0.w)
P1D_loc_20AEFC:
	lea     loc_20B0A8.l, a1
	bsr.w   AnimateObject
	jsr     DrawObject.l
	move.w  $32(a0), d0
	jmp     CheckObjDespawn2.l
P1D_sub_205FC0:
	ori.b   #$80, d1
	jsr     FindObjSlot.l
	bne.s   P1D_loc_205FE2
	dc.b	$13,$7C,$00,$1C,$00,$00		; move.b #$1c, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  d1, $28(a1)
P1D_loc_205FE2:
	rts     
