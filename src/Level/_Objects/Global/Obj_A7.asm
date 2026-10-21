; Object $A7 - Obj34_20BA5E (from R81A, old ID $34)
PA7_Obj34_20BA5E:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PA7_dat_20BA78(pc, d0.w), d0
	jsr     PA7_dat_20BA78(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PA7_dat_20BA78:
	dc.w	PA7_loc_20BA7C-PA7_dat_20BA78
	dc.w	loc_20BB78-PA7_dat_20BA78
PA7_loc_20BA7C:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.l  #$20bc8a, oMap(a0)
	move.w  #$498, oTile(a0)
	move.b  #$3, oPriority(a0)
	move.w  oY(a0), $30(a0)
	clr.w   oYVel(a0)
	clr.w   oXVel(a0)
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	move.b  d0, d1
	andi.w  #$30, d1
	lsr.w   #$3, d1
	move.w  PA7_dat_20BB04(pc, d1.w), d2
	move.w  d2, $32(a0)
	move.b  d0, d1
	andi.w  #$40, d1
	lsr.w   #$5, d1
	move.w  PA7_dat_20BB0C(pc, d1.w), d2
	move.w  d2, $36(a0)
	move.w  $32(a0), d2
	move.w  d0, d3
	lsr.w   #$2, d2
	move.w  d2, d0
	jsr     CalcSine.l
	muls.w  $36(a0), d0
	lsr.l   #$8, d0
	add.w   $30(a0), d0
	move.w  d0, oY(a0)
	move.w  d3, d0
	move.w  d0, d1
	andi.w  #$3, d1
	lsl.w   #$1, d1
	move.w  PA7_dat_20BAFE(pc, d1.w), d1
	jmp     PA7_dat_20BAFE(pc, d1.w)
PA7_dat_20BB04:
	dc.w	$0000,$0100,$0200,$0300
PA7_dat_20BB0C:
	dc.w	$0020,$0030
PA7_dat_20BAFE:
	dc.w	loc_20BB18-PA7_dat_20BAFE
	dc.w	loc_20BB3C-PA7_dat_20BAFE
	dc.w	loc_20BB18-PA7_dat_20BAFE
