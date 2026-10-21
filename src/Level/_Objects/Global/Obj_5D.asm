; Object $5D - Obj32_20E09A (from R31A, old ID $32)
P5D_Obj32_20E09A:
	tst.b   timeAttackMode.l
	bne.w   loc_20E04A
	tst.b   amyCaptured.l
	bne.w   loc_20E04A
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P5D_dat_20E0D0(pc, d0.w), d0
	jsr     P5D_dat_20E0D0(pc, d0.w)
	bsr.w   P5D_sub_20E300
	cmpi.w  #$4c0, $8(a1)
	bcc.w   loc_20E04A
	jmp     DrawObject.l
P5D_dat_20E0D0:
	dc.w	P5D_loc_20E0D6-P5D_dat_20E0D0
	dc.w	P5D_loc_20E128-P5D_dat_20E0D0
	dc.w	P5D_loc_20E1EE-P5D_dat_20E0D0
P5D_loc_20E0D6:
	tst.b   $3e(a0)
	bmi.s   P5D_loc_20E0E8
	moveq   #$b, d0
	jsr     LoadPLC.l
	st.b    $3e(a0)
P5D_loc_20E0E8:
	ori.b   #$4, oSprFlags(a0)
	move.w  #$235e, oTile(a0)
	move.b  #$1, oPriority(a0)
	move.l  #$23bdb2, oMap(a0)
	bsr.w   ObjAmyRose_LoadPal
	bsr.w   P5D_sub_20E300
	bsr.w   ObjAmyRose_SetFacing
	move.w  $8(a1), d0
	cmp.w   oX(a0), d0
	bcs.s   P5D_loc_20E11C
	addq.b  #$2, oRoutine(a0)
P5D_loc_20E11C:
	lea     P5D_Data_23BF08.l, a1
	bra.w   AnimateObjSimple
	dc.w	$4E75
P5D_loc_20E128:
	bsr.w   P5D_sub_20E300
	move.w  $34(a0), d0
	beq.s   P5D_loc_20E14E
	movea.w d0, a2
	tst.b   $3d(a2)
	beq.s   P5D_loc_20E14E
	move.b  #$4, oRoutine(a0)
	move.w  #$7d, d0
	jsr     SubCPUCmd.l
	bra.w   P5D_loc_20E1E0
P5D_loc_20E14E:
	bsr.w   ObjAmyRose_SetFacing
	btst.b  #$0, oFlags(a0)
	beq.s   P5D_loc_20E16E
	cmpi.w  #$80, oX(a0)
	bcc.s   P5D_loc_20E16E
	clr.b   oAnim(a0)
	clr.w   oXVel(a0)
	bra.w   P5D_loc_20E1E0
P5D_loc_20E16E:
	cmpi.w  #$3c0, oX(a0)
	bcc.s   P5D_loc_20E1B4
	move.w  #$ffe0, d0
	btst.b  #$0, oFlags(a0)
	bne.s   P5D_loc_20E184
	neg.w   d0
P5D_loc_20E184:
	add.w   oXVel(a0), d0
	move.w  d0, d1
	move.w  #$200, d2
	tst.w   d1
	bpl.s   P5D_loc_20E196
	neg.w   d1
	neg.w   d2
P5D_loc_20E196:
	cmpi.w  #$200, d1
	bcs.s   P5D_loc_20E19E
	move.w  d2, d0
P5D_loc_20E19E:
	move.w  d0, oXVel(a0)
	bsr.w   ObjectMoveX
	move.b  #$1, oAnim(a0)
	cmpi.w  #$3c0, oX(a0)
	bcs.s   P5D_loc_20E1E0
P5D_loc_20E1B4:
	clr.b   oAnim(a0)
	tst.w   $34(a0)
	bne.s   P5D_loc_20E1E0
	jsr     FindObjSlot.l
	bne.s   P5D_loc_20E1E0
	dc.b	$13,$7C,$00,$31,$00,$00		; move.b #$31, $0(a1) (raw: not reproducible by assembler)
	move.w  #$500, $8(a1)
	move.w  #$3e8, $c(a1)
	move.w  a0, $34(a1)
	move.w  a1, $34(a0)
P5D_loc_20E1E0:
	lea     P5D_Data_23BF08.l, a1
	bsr.w   AnimateObjSimple
	bra.w   P5D_loc_20E306
P5D_loc_20E1EE:
	movea.w $34(a0), a1
	dc.b	$0C,$29,$00,$31,$00,$00		; cmpi.b #$31, $0(a1) (raw: not reproducible by assembler)
	bne.s   P5D_loc_20E230
	moveq   #$8, d0
	bsr.w   ObjAmyRose_XFlip
	btst.b  #$0, $22(a1)
	beq.s   P5D_loc_20E20E
	neg.w   d0
	bsr.w   ObjAmyRose_XUnflip
P5D_loc_20E20E:
	add.w   $8(a1), d0
	move.w  d0, oX(a0)
	move.w  $c(a1), d0
	addq.w  #$4, d0
	move.w  d0, oY(a0)
	move.b  #$2, oAnim(a0)
	lea     P5D_Data_23BF08.l, a1
	bra.w   AnimateObjSimple
P5D_loc_20E230:
	jmp     DeleteObject.l
P5D_sub_20E300:
	lea     objects.w, a1
	rts     
P5D_loc_20E306:
	addq.b  #$8, $3b(a0)
	bcc.s   P5D_loc_20E33E
	jsr     FindObjSlot.l
	bne.s   P5D_loc_20E33E
	dc.b	$13,$7C,$00,$33,$00,$00		; move.b #$33, $0(a1) (raw: not reproducible by assembler)
	moveq   #$c, d1
	btst.b  #$0, oFlags(a0)
	beq.s   P5D_loc_20E328
	move.w  #$fff2, d1
P5D_loc_20E328:
	move.w  oX(a0), d0
	add.w   d1, d0
	move.w  d0, $8(a1)
	move.w  oY(a0), d0
	subi.w  #$c, d0
	move.w  d0, $c(a1)
P5D_loc_20E33E:
	rts     
P5D_Data_23BF08:
	incbin	"Level/Collision Chaos/Data/Misc/P5D_Data_23BF08.bin"

