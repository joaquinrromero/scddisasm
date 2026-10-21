; Object $A6 - Obj36_20D3F6 (from R73C, old ID $36)
PA6_Obj36_20D3F6:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PA6_dat_20D40A(pc, d0.w), d0
	jsr     PA6_dat_20D40A(pc, d0.w)
	jmp     DrawObject.l
PA6_dat_20D40A:
	dc.w	PA6_loc_20D410-PA6_dat_20D40A
	dc.w	PA6_loc_20D484-PA6_dat_20D40A
	dc.w	PA6_loc_20D536-PA6_dat_20D40A
PA6_loc_20D410:
	move.b  #$4, oSprFlags(a0)
	move.b  #$0, oPriority(a0)
	move.w  #$451c, oTile(a0)
	move.l  #$20d56e, oMap(a0)
	addq.b  #$2, oRoutine(a0)
	tst.b   oSubtype(a0)
	bne.s   PA6_loc_20D450
	jsr     FindNextObjSlot.l
	bne.s   PA6_loc_20D450
	dc.b	$13,$7C,$00,$36,$00,$00		; move.b #$36, $0(a1) (raw: not reproducible by assembler)
	move.b  #$1, $28(a1)
	move.w  a1, $2e(a0)
	move.w  a0, $2e(a1)
PA6_loc_20D450:
	tst.b   oSubtype(a0)
	bne.s   PA6_loc_20D46A
	move.b  #$18, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.b  #$2, oRoutine(a0)
	rts     
PA6_loc_20D46A:
	move.b  #$1, oMapFrame(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$70, oYRadius(a0)
	move.b  #$4, oRoutine(a0)
	rts     
PA6_loc_20D484:
	bsr.w   PA6_sub_20D4FA
	move.w  d0, $30(a0)
	move.w  #$160, $32(a0)
	move.w  cameraY.w, d0
	subi.w  #$160, d0
	ext.l   d0
	divs.w  #$3, d0
	sub.w   d0, $32(a0)
	move.w  $32(a0), d0
	addi.w  #$c, d0
	move.w  cameraY.w, d1
	cmp.w   d0, d1
	bge.s   PA6_loc_20D4D4
	move.w  $30(a0), oX(a0)
	move.w  $32(a0), oY(a0)
	move.b  #$0, oMapFrame(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	rts     
PA6_loc_20D4D4:
	move.w  $30(a0), oX(a0)
	move.w  $32(a0), oY(a0)
	addi.w  #$15c, oY(a0)
	move.b  #$1, oMapFrame(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$70, oYRadius(a0)
	rts     
PA6_sub_20D4FA:
	moveq   #$0, d0
	moveq   #$0, d1
	move.w  cameraX.w, d0
	divu.w  #$140, d0
	cmpi.w  #$30, d0
	ble.s   PA6_loc_20D510
	move.w  #$0, d0
PA6_loc_20D510:
	move.l  d0, d1
	addq.w  #$1, d0
	andi.l  #$ffff, d0
	mulu.w  #$140, d0
	addi.w  #$100, d0
	swap    d1
	andi.l  #$ffff, d1
	mulu.w  #$100, d1
	divu.w  #$140, d1
	sub.w   d1, d0
	rts     
PA6_loc_20D536:
	movea.w $2e(a0), a1
	move.w  $30(a1), oX(a0)
	move.w  $32(a1), oY(a0)
	addi.w  #$7c, oY(a0)
	rts     
	move.w  oX(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bls.s   PA6_loc_20D56C
	rts     
PA6_loc_20D56C:
	rts     
PA6_loc_20D56E:
	dc.w	$0004,$0010,$02F4,$0A80,$00E8,$F40A,$8800,$0000
	dc.w	$0790,$0780,$09F8,$B007,$8009,$F8D0,$0780,$09F8
	dc.w	$F007,$8009,$F810,$0780,$09F8,$3007,$8009,$F850
	dc.w	$0780,$09F8
