; Object $87 - Obj23_20CFB2 (from R61A, old ID $23)
P87_Obj23_20CFB2:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P87_dat_20CFCC(pc, d0.w), d0
	jsr     P87_dat_20CFCC(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P87_dat_20CFCC:
	dc.w	P87_loc_20CFDA-P87_dat_20CFCC
	dc.w	P87_loc_20D004-P87_dat_20CFCC
	dc.w	P87_loc_20D01E-P87_dat_20CFCC
	dc.w	P87_loc_20D074-P87_dat_20CFCC
P87_loc_20CFD4:
	jmp     P87_loc_20D0F0.l
P87_loc_20CFDA:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$43e8, oTile(a0)
	move.l  #$20d0e2, oMap(a0)
	move.b  #$10, oYRadius(a0)
	move.b  #$20, oWidth(a0)
P87_loc_20D004:
	jsr     P87_dat_20D0BA(pc)
	bne.s   P87_loc_20D01A
	move.w  #$fa00, oYVel(a0)
	move.w  #$10, $3e(a0)
	addq.b  #$2, oRoutine(a0)
P87_loc_20D01A:
	bra.w   P87_loc_20CFD4
P87_loc_20D01E:
	jsr     P87_dat_20D098(pc)
	jsr     ObjGetCeilDist.l
	tst.w   d1
	bpl.s   P87_loc_20D030
	clr.w   oYVel(a0)
P87_loc_20D030:
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P87_loc_20D070
	jsr     P87_dat_20D0BA(pc)
	bne.s   P87_loc_20D060
	move.w  #$fa00, oYVel(a0)
	move.w  #$10, $3e(a0)
	btst.b  #$7, oSprFlags(a0)
	beq.s   P87_loc_20D070
	move.w  #$b4, d0
	jsr     PlayFMSound.l
	bra.s   P87_loc_20D070
P87_loc_20D060:
	move.w  #$fe80, oYVel(a0)
	move.w  #$10, $3e(a0)
	addq.b  #$2, oRoutine(a0)
P87_loc_20D070:
	bra.w   P87_loc_20CFD4
P87_loc_20D074:
	jsr     P87_dat_20D098(pc)
	tst.w   oYVel(a0)
	bmi.s   P87_loc_20D094
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P87_loc_20D094
	clr.w   oYVel(a0)
	clr.w   $3e(a0)
	subq.b  #$4, oRoutine(a0)
P87_loc_20D094:
	bra.w   P87_loc_20CFD4
P87_dat_20D0BA:
	cmpi.b  #$2, timeZone.l
	bcc.s   P87_loc_20D0DA
	move.b  #$3c, d0
	tst.b   timeZone.l
	beq.s   P87_loc_20D0D4
	addi.b  #$1e, d0
P87_loc_20D0D4:
	cmp.b   $FFFFF7B3.w, d0
	beq.s   P87_loc_20D0DE
P87_loc_20D0DA:
	moveq   #$0, d0
	rts     
P87_loc_20D0DE:
	moveq   #$ff, d0
	rts     
P87_loc_20D0E2:
	dc.w	$0002,$02F0,$0F00,$00E0,$F00F,$0800,$0000
P87_loc_20D0F0:
	lea     objects.w, a1
	move.w  $12(a1), d0
	bpl.s   P87_loc_20D104
	neg.w   d0
	cmpi.w  #$600, d0
	bgt.w   P87_loc_20D158
P87_loc_20D104:
	tst.w   oYVel(a0)
	beq.s   P87_loc_20D112
	move.b  #$4, $2e(a0)
	bra.s   P87_loc_20D118
P87_loc_20D112:
	move.b  #$0, $2e(a0)
P87_loc_20D118:
	move.b  $2e(a0), d0
	add.b   d0, oYRadius(a0)
	lea     objects.w, a1
	bsr.s   P87_sub_20D130
	move.b  $2e(a0), d0
	sub.b   d0, oYRadius(a0)
	rts     
P87_dat_20D098:
	move.w  oYVel(a0), d0
	add.w   $3e(a0), d0
	bmi.s   P87_loc_20D0AC
	cmpi.w  #$600, d0
	bcs.s   P87_loc_20D0AC
	move.w  #$600, d0
P87_loc_20D0AC:
	move.w  d0, oYVel(a0)
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, oY(a0)
	rts     
P87_sub_20D130:
	move.w  $12(a1), $30(a0)
	btst.b  #$3, $22(a1)
	beq.s   P87_loc_20D14A
	btst.b  #$1, $22(a1)
	bne.s   P87_loc_20D14A
	clr.w   $12(a1)
P87_loc_20D14A:
	jsr     SolidObject.l
	bne.s   P87_loc_20D15A
	move.w  $30(a0), $12(a1)
P87_loc_20D158:
	rts     
P87_loc_20D15A:
	cmpi.b  #$6, $24(a1)
	bcc.s   P87_loc_20D184
	move.l  oY(a0), $c(a1)
	move.b  $16(a1), d0
	ext.w   d0
	addi.w  #$10, d0
	sub.w   d0, $c(a1)
	tst.w   oYVel(a0)
	bge.s   P87_loc_20D184
	move.w  oYVel(a0), $12(a1)
	rts     
P87_loc_20D184:
	clr.w   $12(a1)
	rts     
