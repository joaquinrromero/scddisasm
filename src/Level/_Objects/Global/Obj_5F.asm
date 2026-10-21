; Object $5F - Obj28_20D58E (from R32A, old ID $28)
P5F_Obj28_20D58E:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P5F_dat_20D5C4(pc, d0.w), d0
	jsr     P5F_dat_20D5C4(pc, d0.w)
	jsr     DrawObject.l
	move.w  $32(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.s   P5F_loc_20D5C0
	rts     
P5F_loc_20D5C0:
	bra.w   loc_20D85C
P5F_dat_20D5C4:
	dc.w	loc_20D620-P5F_dat_20D5C4
	dc.w	loc_20D66E-P5F_dat_20D5C4
	dc.w	loc_20D6AE-P5F_dat_20D5C4
	dc.w	loc_20D6E8-P5F_dat_20D5C4
