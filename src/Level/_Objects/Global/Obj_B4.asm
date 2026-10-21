; Object $B4 - Obj33_20EF04 (from R73C, old ID $33)
PB4_Obj33_20EF04:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PB4_dat_20EF32(pc, d0.w), d0
	jsr     PB4_dat_20EF32(pc, d0.w)
	jsr     DrawObject.l
	jsr     CheckObjDespawn.l
	cmpi.b  #$33, oID(a0)
	beq.s   PB4_loc_20EF30
	lea     loc_200738.l, a3
	bsr.w   ObjAmyRose_ResetPal
PB4_loc_20EF30:
	rts     
PB4_dat_20EF32:
	dc.w	PB4_loc_20EF44-PB4_dat_20EF32
	dc.w	PB4_loc_20EFEE-PB4_dat_20EF32
	dc.w	PB4_loc_20F036-PB4_dat_20EF32
	dc.w	PB4_loc_20F036-PB4_dat_20EF32
	dc.w	ObjAmyRose_WaitLand-PB4_dat_20EF32
	dc.w	loc_20F1C6-PB4_dat_20EF32
	dc.w	loc_20F21E-PB4_dat_20EF32
	dc.w	ObjAmyRose_FollowSonic-PB4_dat_20EF32
	dc.w	ObjAmyRose_WaitLand-PB4_dat_20EF32
PB4_loc_20EF44:
	ori.b   #$4, oSprFlags(a0)
	move.w  #$a3cb, oTile(a0)
	move.b  #$1, oPriority(a0)
	move.l  #$21f5b0, oMap(a0)
	move.b  #$c, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  oX(a0), $36(a0)
	move.b  #$f5, oColType(a0)
	tst.b   goodFuture.l
	bne.s   PB4_loc_20EF8A
	move.w  #$3f43, oX(a0)
	move.w  #$1ab, oY(a0)
PB4_loc_20EF8A:
	lea     objects.w, a1
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	bcc.s   PB4_loc_20EF9A
	neg.w   d0
PB4_loc_20EF9A:
	move.b  #$6, oAnim(a0)
	tst.b   oColStatus(a0)
	beq.s   PB4_loc_20EFE4
	jsr     FindObjSlot.l
	bne.s   PB4_loc_20EFD0
	dc.b	$13,$7C,$00,$18,$00,$00		; move.b #$18, $0(a1) (raw: not reproducible by assembler)
	move.b  #$1, $25(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.w  #$9e, d0
	jsr     PlayFMSound.l
PB4_loc_20EFD0:
	lea     objects.w, a1
	neg.w   $12(a1)
	addq.b  #$2, oRoutine(a0)
	move.w  #$258, $30(a0)
	rts     
PB4_loc_20EFE4:
	lea     PB4_Data_21F706.l, a1
	bra.w   AnimateObjSimple
PB4_loc_20EFEE:
	tst.b   $3c(a0)
	bmi.s   PB4_loc_20F01A
	addi.w  #$10, oYVel(a0)
	bsr.w   ObjectMoveY
	move.w  oY(a0), d0
	cmpi.w  #$1d0, d0
	bcs.s   PB4_loc_20F018
	move.w  #$1d0, oY(a0)
	clr.w   oYVel(a0)
	move.b  #$ff, $3c(a0)
PB4_loc_20F018:
	rts     
PB4_loc_20F01A:
	lea     objects.w, a1
	bsr.w   ObjAmyRose_SetFacing
	move.b  #$3c, $3f(a0)
	addq.b  #$2, oRoutine(a0)
	lea     PB4_Data_21F706.l, a1
	bra.w   AnimateObjSimple
PB4_loc_20F036:
	bsr.w   PB4_sub_20F36A
	lea     objects.w, a1
	bsr.w   ObjAmyRose_SetFacing
	tst.w   $30(a0)
	beq.s   PB4_loc_20F050
	subq.w  #$1, $30(a0)
	beq.w   PB4_loc_20F138
PB4_loc_20F050:
	tst.b   $3f(a0)
	beq.s   PB4_loc_20F05C
	subq.b  #$1, $3f(a0)
	bne.s   PB4_loc_20F0A8
PB4_loc_20F05C:
	bsr.w   PB4_sub_20F24E
	btst.b  #$2, $3e(a0)
	bne.w   PB4_loc_20F090
	tst.w   $10(a1)
	bne.s   PB4_loc_20F0A8
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	bcc.s   PB4_loc_20F07C
	neg.w   d0
PB4_loc_20F07C:
	cmpi.w  #$a, d0
	bcc.s   PB4_loc_20F0A8
PB4_loc_20F082:
	bset.b  #$2, $3e(a0)
	clr.w   oXVel(a0)
	bra.w   PB4_loc_20F128
PB4_loc_20F090:
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	bcc.s   PB4_loc_20F09C
	neg.w   d0
PB4_loc_20F09C:
	cmpi.w  #$20, d0
	bcs.s   PB4_loc_20F082
	bclr.b  #$2, $3e(a0)
PB4_loc_20F0A8:
	move.w  #$ffe0, d0
	btst.b  #$0, oFlags(a0)
	bne.s   PB4_loc_20F0B6
	neg.w   d0
PB4_loc_20F0B6:
	add.w   oXVel(a0), d0
	move.w  d0, d1
	move.w  #$280, d2
	tst.w   d1
	bpl.s   PB4_loc_20F0C8
	neg.w   d1
	neg.w   d2
PB4_loc_20F0C8:
	cmpi.w  #$280, d1
	bcs.s   PB4_loc_20F0D0
	move.w  d2, d0
PB4_loc_20F0D0:
	move.w  d0, oXVel(a0)
	tst.w   oXVel(a0)
	bpl.s   PB4_loc_20F0FA
	move.w  #$60, d1
	tst.b   goodFuture.l
	bne.s   PB4_loc_20F0EA
	move.w  #$80, d1
PB4_loc_20F0EA:
	move.w  $36(a0), d0
	sub.w   d1, d0
	cmp.w   oX(a0), d0
	bcs.s   PB4_loc_20F0FA
	bra.w   PB4_loc_20F124
PB4_loc_20F0FA:
	jsr     ObjGetFloorDist.l
	cmpi.w  #$7, d1
	bpl.s   PB4_loc_20F110
	cmpi.w  #$fff9, d1
	bmi.s   PB4_loc_20F110
	add.w   d1, oY(a0)
PB4_loc_20F110:
	bsr.w   ObjectMoveX
	move.b  #$2, oAnim(a0)
	lea     PB4_Data_21F706.l, a1
	bra.w   AnimateObjSimple
PB4_loc_20F124:
	clr.w   oXVel(a0)
PB4_loc_20F128:
	move.b  #$1, oAnim(a0)
	lea     PB4_Data_21F706.l, a1
	bra.w   AnimateObjSimple
PB4_loc_20F138:
	move.b  #$ff, $38(a0)
	clr.b   updateHUDTime.l
	move.b  #$1, $2a(a0)
	jmp     StartResults.l
PB4_Data_21F706:
	incbin	"Level/Stardust Speedway/Data/Misc/PB4_Data_21F706.bin"
PB4_sub_20F36A:
	addq.b  #$6, $3b(a0)
	bcc.s   PB4_loc_20F3AC
	jsr     FindObjSlot.l
	bne.s   PB4_loc_20F3AC
	dc.b	$13,$7C,$00,$34,$00,$00		; move.b #$34, $0(a1) (raw: not reproducible by assembler)
	moveq   #$8, d1
	btst.b  #$0, oFlags(a0)
	beq.s   PB4_loc_20F38C
	move.w  #$fff6, d1
PB4_loc_20F38C:
	btst.b  #$0, $3e(a0)
	beq.s   PB4_loc_20F396
	neg.w   d1
PB4_loc_20F396:
	move.w  oX(a0), d0
	add.w   d1, d0
	move.w  d0, $8(a1)
	move.w  oY(a0), d0
	subi.w  #$c, d0
	move.w  d0, $c(a1)
PB4_loc_20F3AC:
	rts     
	lea     objects.w, a1
	rts     
PB4_sub_20F24E:
	lea     objects.w, a1
	tst.b   debugMode.l
	bne.w   PB4_loc_20F2E0
	btst.b  #$0, $22(a1)
	bne.s   PB4_loc_20F26E
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	bra.s   PB4_loc_20F276
PB4_loc_20F26E:
	move.w  oX(a0), d0
	sub.w   $8(a1), d0
PB4_loc_20F276:
	bcs.w   PB4_loc_20F2E0
	cmpi.w  #$8, d0
	bcs.w   PB4_loc_20F2E0
	cmpi.w  #$1c, d0
	bcc.s   PB4_loc_20F2E0
	moveq   #$8, d1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	add.w   d1, d0
	bmi.s   PB4_loc_20F2E0
	move.w  d1, d2
	add.w   d2, d2
	cmp.w   d2, d0
	bcc.s   PB4_loc_20F2E0
	move.w  $10(a1), d0
	bpl.s   PB4_loc_20F2A6
	neg.w   d0
PB4_loc_20F2A6:
	btst.b  #$1, $22(a1)
	bne.s   PB4_loc_20F2E2
	btst.b  #$2, $22(a1)
	bne.s   PB4_loc_20F2E2
	bclr.b  #$2, $22(a1)
	ori.b   #$81, $3e(a0)
	clr.w   oYVel(a0)
	clr.w   oXVel(a0)
	move.b  #$7, oMapFrame(a0)
	move.b  #$a, oRoutine(a0)
	move.w  #$7c, d0
	jsr     SubCPUCmd.l
PB4_loc_20F2E0:
	rts     
PB4_loc_20F2E2:
	move.b  #$e, oRoutine(a0)
	rts     
