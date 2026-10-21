; Object $56 - Obj24_20D008 (from R31A, old ID $24)
P56_Obj24_20D008:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P56_dat_20D022(pc, d0.w), d0
	jsr     P56_dat_20D022(pc, d0.w)
	jmp     CheckObjDespawn.l
P56_dat_20D022:
	dc.w	P56_loc_20D030-P56_dat_20D022
	dc.w	P56_loc_20D082-P56_dat_20D022
	dc.w	P56_loc_20D0A4-P56_dat_20D022
	dc.w	P56_loc_20D10E-P56_dat_20D022
	dc.w	P56_loc_20D128-P56_dat_20D022
	dc.w	P56_loc_20D136-P56_dat_20D022
	dc.w	P56_loc_20D19E-P56_dat_20D022
P56_loc_20D030:
	move.l  #$2358ca, d1
	move.b  #$1, d0
	move.b  oSubtype(a0), $2e(a0)
	bpl.s   P56_loc_20D04C
	move.l  #$235a7a, d1
	move.b  #$2, d0
P56_loc_20D04C:
	move.b  d0, oMapFrame(a0)
	move.l  d1, oMap(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$14, oYRadius(a0)
	move.w  #$23f2, oTile(a0)
	move.w  #$100, oYVel(a0)
	move.b  #$6, oColType(a0)
	addq.b  #$2, oRoutine(a0)
P56_loc_20D082:
	jsr     P56_dat_20D1BC(pc)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P56_loc_20D094
	addq.b  #$2, oRoutine(a0)
P56_loc_20D094:
	lea     P56_dat_20D268(pc), a1
	jsr     AnimateObject.l
	jmp     DrawObject.l
P56_loc_20D0A4:
	btst.b  #$7, oSprFlags(a0)
	beq.s   P56_loc_20D0F2
	bclr.b  #$0, oSprFlags(a0)
	bclr.b  #$0, oFlags(a0)
	lea     objects.w, a1
	move.w  oX(a0), d0
	sub.w   $8(a1), d0
	bcc.s   P56_loc_20D0D4
	neg.w   d0
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$0, oFlags(a0)
P56_loc_20D0D4:
	tst.b   oSprFlags(a0)
	bpl.s   P56_loc_20D0F2
	move.w  oY(a0), d1
	sub.w   $c(a1), d1
	bcc.s   P56_loc_20D0E6
	neg.w   d1
P56_loc_20D0E6:
	cmpi.w  #$20, d1
	bcc.s   P56_loc_20D0F2
	cmpi.w  #$60, d0
	bcs.s   P56_loc_20D0FA
P56_loc_20D0F2:
	move.b  #$1, oAnim(a0)
	bra.s   P56_loc_20D094
P56_loc_20D0FA:
	move.b  #$2, oAnim(a0)
	jsr     P56_dat_20D1D6(pc)
	move.w  #$78, $2c(a0)
	addq.b  #$2, oRoutine(a0)
P56_loc_20D10E:
	subq.w  #$1, $2c(a0)
	beq.s   P56_loc_20D118
	bra.w   P56_loc_20D094
P56_loc_20D118:
	move.b  #$3, oAnim(a0)
	move.w  #$3c, $2c(a0)
	addq.b  #$2, oRoutine(a0)
P56_loc_20D128:
	subq.w  #$1, $2c(a0)
	beq.s   P56_loc_20D132
	bra.w   P56_loc_20D094
P56_loc_20D132:
	addq.b  #$2, oRoutine(a0)
P56_loc_20D136:
	move.w  #$100, d0
	tst.b   oSubtype(a0)
	bpl.s   P56_loc_20D144
	move.w  #$80, d0
P56_loc_20D144:
	move.b  #$0, oAnim(a0)
	btst.b  #$0, oFlags(a0)
	bne.s   P56_loc_20D154
	neg.w   d0
P56_loc_20D154:
	move.w  d0, oXVel(a0)
	jsr     P56_dat_20D1BC(pc)
	jsr     Player_GetLWallDist.l
	tst.w   d1
	bmi.s   P56_loc_20D18E
	jsr     Player_GetRWallDist.l
	tst.w   d1
	bmi.s   P56_loc_20D18E
	jsr     ObjGetFloorDist.l
	tst.w   d1
	beq.s   P56_loc_20D18A
	cmpi.w  #$7, d1
	bpl.s   P56_loc_20D18E
	cmpi.w  #$fff9, d1
	bmi.s   P56_loc_20D18E
	add.w   d1, oY(a0)
P56_loc_20D18A:
	bra.w   P56_loc_20D094
P56_loc_20D18E:
	move.w  #$48, $2c(a0)
	move.w  #$3, oAnim(a0)
	addq.b  #$2, oRoutine(a0)
P56_loc_20D19E:
	subq.w  #$1, $2c(a0)
	beq.s   P56_loc_20D1A8
	bra.w   P56_loc_20D094
P56_loc_20D1A8:
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	subq.b  #$2, oRoutine(a0)
	bra.w   P56_loc_20D094
P56_dat_20D1BC:
	move.w  oXVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, oX(a0)
	move.w  oYVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, oY(a0)
	rts     
P56_dat_20D268:
	dc.w	$000A,$0010,$0014,$0018,$001C,$0700,$0102,$03FF
	dc.w	$0705,$06FF,$0700,$04FF,$0707,$04FF,$0700,$FF00
P56_dat_20D1D6:
	tst.b   oSubtype(a0)
	bpl.s   P56_loc_20D1DE
	rts     
P56_loc_20D1DE:
	jsr     FindObjSlot.l
	bne.s   P56_loc_20D222
	dc.b	$13,$7C,$00,$25,$00,$00		; move.b #$25, $0(a1) (raw: not reproducible by assembler)
	move.w  a0, $30(a1)
	move.w  #$40, $2c(a1)
	move.b  oSubtype(a0), $28(a1)
	move.b  oSprFlags(a0), $2e(a1)
	move.w  oY(a0), d0
	subq.w  #$4, d0
	move.w  d0, $c(a1)
	move.w  oX(a0), d0
	moveq   #$11, d1
	btst.b  #$0, oSprFlags(a0)
	bne.s   P56_loc_20D21C
	neg.w   d1
P56_loc_20D21C:
	add.w   d1, d0
	move.w  d0, $8(a1)
P56_loc_20D222:
	jsr     FindObjSlot.l
	bne.s   P56_loc_20D266
	dc.b	$13,$7C,$00,$25,$00,$00		; move.b #$25, $0(a1) (raw: not reproducible by assembler)
	move.w  a0, $30(a1)
	move.w  #$14, $2c(a1)
	move.b  oSubtype(a0), $28(a1)
	move.b  oSprFlags(a0), $2e(a1)
	move.w  oY(a0), d0
	subq.w  #$6, d0
	move.w  d0, $c(a1)
	move.w  oX(a0), d0
	moveq   #$9, d1
	btst.b  #$0, oSprFlags(a0)
	bne.s   P56_loc_20D260
	neg.w   d1
P56_loc_20D260:
	add.w   d1, d0
	move.w  d0, $8(a1)
P56_loc_20D266:
	rts     
