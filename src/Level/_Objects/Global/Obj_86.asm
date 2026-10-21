; Object $86 - Obj33_20B3DA (from R53C, old ID $33)
P86_Obj33_20B3DA:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P86_dat_20B3FC(pc, d0.w), d0
	jsr     P86_dat_20B3FC(pc, d0.w)
	movea.w $30(a0), a1
	btst.b  #$3, $2c(a1)
	bne.s   P86_loc_20B3FA
	jmp     DrawObject.l
P86_loc_20B3FA:
	rts     
P86_dat_20B3FC:
	dc.w	P86_loc_20B404-P86_dat_20B3FC
	dc.w	P86_loc_20B444-P86_dat_20B3FC
	dc.w	P86_loc_20B4C0-P86_dat_20B3FC
	dc.w	P86_loc_20B50E-P86_dat_20B3FC
P86_loc_20B404:
	move.w  #$6, d0
	movem.l d7/a0-a7, -(a7)
	jsr     LoadPalette.l
	movem.l (a7)+, d7/a0-a7
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$18, oYRadius(a0)
	move.w  #$22bc, oTile(a0)
	move.l  #$20c466, oMap(a0)
	bsr.w   P86_sub_20C2AE
P86_loc_20B444:
	btst.b  #$1, $2c(a0)
	bne.s   P86_loc_20B464
	cmpi.w  #$c8, camYCenter.w
	blt.s   P86_loc_20B460
	move.b  #$5, bossFlags.w
	bset.b  #$1, $2c(a0)
P86_loc_20B460:
	addq.w  #$6, camYCenter.w
P86_loc_20B464:
	move.w  #$cc0, d0
	move.w  d0, rightBound.w
	move.w  d0, destRightBound.w
	bsr.w   P86_sub_20C416
	move.w  $8(a1), d0
	subi.w  #$a0, d0
	cmp.w   leftBound.w, d0
	blt.s   P86_loc_20B4BE
	cmpi.w  #$d60, $8(a1)
	blt.s   P86_loc_20B4B6
	bclr.b  #$1, $2c(a0)
	move.w  #$67, d0
	jsr     SubCPUCmd.l
	move.b  #$5, bossFight.w
	move.b  #$6, oRoutine(a0)
	move.w  #$cc0, d0
	move.w  d0, rightBound.w
	move.w  d0, destRightBound.w
	move.w  #$cc0, d0
P86_loc_20B4B6:
	move.w  d0, leftBound.w
	move.w  d0, destLeftBound.w
P86_loc_20B4BE:
	rts     
P86_loc_20B4C0:
	lea     loc_202858.l, a1
	move.w  (a1)+, d0
	move.w  (a1)+, d1
	move.w  (a1)+, d2
	move.w  (a1)+, d3
	addq.w  #$6, rightBound.w
	addq.w  #$6, destRightBound.w
	cmp.w   rightBound.w, d1
	ble.s   P86_loc_20B4DE
	rts     
P86_loc_20B4DE:
	clr.b   bossFight.w
	move.w  d1, rightBound.w
	move.w  d1, destRightBound.w
	move.w  #$1a, d0
	tst.b   goodFuture.l
	beq.s   P86_loc_20B4FA
	move.w  #$19, d0
P86_loc_20B4FA:
	jsr     SubCPUCmd.l
	jsr     LoadCapsulePal.l
	move.b  #$6, oRoutine(a0)
	rts     
P86_loc_20B50E:
	movea.w $30(a0), a1
	bclr.b  #$7, $2c(a1)
	beq.s   P86_loc_20B520
	move.b  #$8, $3e(a0)
P86_loc_20B520:
	tst.b   $3e(a0)
	beq.s   P86_loc_20B540
	subq.b  #$1, $3e(a0)
	move.w  #$2, d0
	btst.b  #$0, $3e(a0)
	beq.s   P86_loc_20B538
	neg.w   d0
P86_loc_20B538:
	add.w   d0, bottomBound.w
	add.w   d0, destBottomBound.w
P86_loc_20B540:
	rts     
P86_sub_20C2AE:
	movea.l a0, a3
	jsr     FindObjSlot.l
	bne.w   P86_loc_20C2DA
	move.w  a3, $2e(a1)
	move.w  a1, $30(a3)
	dc.b	$13,$7C,$00,$34,$00,$00		; move.b #$34, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	addi.w  #$38, $c(a1)
P86_loc_20C2DA:
	rts     
P86_sub_20C416:
	lea     objects.w, a1
	rts     
