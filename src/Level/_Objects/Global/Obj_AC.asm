; Object $AC - Obj2C_20F16A (from R61A, old ID $2C)
Obj2C_20F16A:
	tst.b   oSubtype(a0)
	bne.w   PAC_loc_20F3B2
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PAC_dat_20F18C(pc, d0.w), d0
	jsr     PAC_dat_20F18C(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PAC_dat_20F18C:
	dc.w	PAC_loc_20F192-PAC_dat_20F18C
	dc.w	PAC_loc_20F260-PAC_dat_20F18C
	dc.w	PAC_loc_20F34A-PAC_dat_20F18C
PAC_loc_20F192:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$18, oXRadius(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$18, oYRadius(a0)
	move.w  #$3b8, oTile(a0)
	move.l  #$20f3ee, oMap(a0)
	jsr     FindObjSlot.l
	bne.w   PAC_loc_20F3C0
	bsr.w   PAC_sub_20F20C
	move.w  a1, $2a(a0)
	subi.w  #$28, $8(a1)
	subi.w  #$18, $c(a1)
	jsr     FindObjSlot.l
	bne.w   PAC_loc_20F3C0
	bsr.w   PAC_sub_20F20C
	move.w  a1, $2c(a0)
	addi.w  #$28, $8(a1)
	addi.w  #$18, $c(a1)
	bset.b  #$0, $1(a1)
	bset.b  #$0, $22(a1)
	rts     
PAC_sub_20F20C:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  oSprFlags(a0), $1(a1)
	move.b  oPriority(a0), $18(a1)
	move.w  oTile(a0), $2(a1)
	move.l  oMap(a0), $4(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  #$ff, $28(a1)
	move.b  #$10, $17(a1)
	move.b  #$10, $19(a1)
	move.b  #$8, $16(a1)
	move.b  #$9, $1a(a1)
	move.w  a0, $2a(a1)
	move.w  #$78, $2e(a0)
	rts     
PAC_loc_20F260:
	lea     PAC_dat_20F2CC(pc), a1
	tst.w   oYVel(a0)
	beq.s   PAC_loc_20F26E
	lea     PAC_dat_20F2EE(pc), a1
PAC_loc_20F26E:
	jsr     (a1)
	move.w  a0, -(a7)
	movea.w $2c(a0), a0
	lea     objects.w, a1
	jsr     TopSolidObject.l
	jsr     DrawObject.l
	movea.w (a7)+, a0
	move.w  a0, -(a7)
	movea.w $2a(a0), a0
	lea     objects.w, a1
	jsr     TopSolidObject.l
	sne.b   $3f(a0)
	jsr     DrawObject.l
	movea.w (a7)+, a0
	movea.w $2a(a0), a1
	tst.b   $3f(a1)
	bne.s   PAC_loc_20F2B8
	lea     PAC_dat_20F3C6(pc), a1
	jmp     AnimateObject.l
PAC_loc_20F2B8:
	move.b  #$4, oRoutine(a0)
	move.w  #$3, $2e(a0)
	move.b  #$8, oMapFrame(a0)
	rts     
PAC_dat_20F2CC:
	tst.w   $2e(a0)
	bmi.s   PAC_loc_20F2EC
	subq.w  #$1, $2e(a0)
	bmi.s   PAC_loc_20F2E2
	cmpi.w  #$3c, $2e(a0)
	beq.s   PAC_loc_20F2E8
	bra.s   PAC_loc_20F2EC
PAC_loc_20F2E2:
	move.w  #$100, oYVel(a0)
PAC_loc_20F2E8:
	addq.b  #$1, oAnim(a0)
PAC_loc_20F2EC:
	rts     
PAC_dat_20F2EE:
	movea.w $2a(a0), a1
	movea.w $2c(a0), a2
	moveq   #$0, d0
	move.b  oYVel(a0), d0
	add.w   d0, oY(a0)
	add.w   d0, $c(a1)
	add.w   d0, $c(a2)
	moveq   #$0, d0
	move.b  $19(a2), d0
	move.w  $8(a2), d3
	cmp.w   oX(a0), d3
	blt.s   PAC_loc_20F31A
	neg.w   d0
PAC_loc_20F31A:
	add.w   d0, d3
	move.w  a0, -(a7)
	movea.w a2, a0
	jsr     ObjGetFloorDist2.l
	movea.w (a7)+, a0
	tst.w   d1
	bmi.s   PAC_loc_20F32E
	rts     
PAC_loc_20F32E:
	movea.w $2a(a0), a1
	movea.w $2c(a0), a2
	add.w   d1, oY(a0)
	add.w   d1, $c(a1)
	add.w   d1, $c(a2)
	move.w  #$0, oYVel(a0)
	rts     
PAC_loc_20F34A:
	movea.w $2c(a0), a1
	subi.w  #$18, $c(a1)
	subi.w  #$c, oY(a0)
	subq.w  #$1, $2e(a0)
	bpl.s   PAC_loc_20F362
	bsr.s   PAC_sub_20F37E
PAC_loc_20F362:
	move.w  a0, -(a7)
	movea.w $2c(a0), a0
	jsr     DrawObject.l
	movea.w (a7), a0
	movea.w $2a(a0), a0
	jsr     DrawObject.l
	movea.w (a7)+, a0
	rts     
PAC_dat_20F3C6:
	dc.w	$000C,$0010,$0016,$001A,$001E,$0024,$0200,$01FF
	dc.w	$0200,$0102,$03FF,$0202,$03FF,$0204,$05FF,$0204
	dc.w	$0506,$07FF,$0206,$07FF
PAC_loc_20F3EE:
	dc.w	$0014,$0024,$0034,$0044,$0054,$0064,$0074,$0084
	dc.w	$0094,$00A4,$03E8,$0B00,$08E8,$F80B,$081A,$0008
	dc.w	$0500,$2AF8,$03E8,$0B00,$08E8,$F80B,$081A,$0008
	dc.w	$0508,$2AF8,$03E8,$0B00,$08E8,$F80B,$081A,$0008
	dc.w	$0500,$26F8,$03E8,$0B00,$08E8,$F80B,$081A,$0008
	dc.w	$0508,$26F8,$03F8,$0B00,$1AE8,$E80B,$0808,$0008
	dc.w	$0500,$2AF8,$03F8,$0B00,$1AE8,$E80B,$0808,$0008
	dc.w	$0508,$2AF8,$03F8,$0B00,$1AE8,$E80B,$0808,$0008
	dc.w	$0500,$26F8,$03F8,$0B00,$1AE8,$E80B,$0808,$0008
	dc.w	$0508,$26F8,$03F8,$0900,$14E8,$F809,$0814,$0008
	dc.w	$0500,$2AF8,$01F9,$0D00,$00F0
PAC_sub_20F37E:
	move.b  #$2, oRoutine(a0)
	move.w  #$0, oYVel(a0)
	move.w  #$78, $2e(a0)
	move.w  $2a(a0), $2c(a0)
	move.w  a1, $2a(a0)
	moveq   #$0, d0
	cmpi.b  #$2, oAnim(a0)
	bgt.s   PAC_loc_20F3A6
	moveq   #$3, d0
PAC_loc_20F3A6:
	move.b  d0, oAnim(a0)
	move.b  #$ff, oPrevAnim(a0)
	rts     
PAC_loc_20F3B2:
	movea.w $2a(a0), a1
	dc.b	$0C,$29,$00,$2C,$00,$00		; cmpi.b #$2c, $0(a1) (raw: not reproducible by assembler)
	bne.s   PAC_loc_20F3C0
	rts     
PAC_loc_20F3C0:
	jmp     DeleteObject.l
