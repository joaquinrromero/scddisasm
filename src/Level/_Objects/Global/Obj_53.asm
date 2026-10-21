; Object $53 - Obj20_20BF76 (from R31A, old ID $20)
P53_Obj20_20BF76:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P53_dat_20BFD6(pc, d0.w), d0
	jsr     P53_dat_20BFD6(pc, d0.w)
	jsr     DrawObject.l
	moveq   #$0, d1
	move.w  $34(a0), d1
	beq.s   P53_loc_20BFB4
	movea.w d1, a1
	move.w  $8(a1), oX(a0)
	move.w  $c(a1), oY(a0)
	move.b  $38(a0), d0
	ext.w   d0
	add.w   d0, oX(a0)
	move.b  $39(a0), d0
	ext.w   d0
	add.w   d0, oY(a0)
P53_loc_20BFB4:
	move.w  $36(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.s   P53_loc_20BFD2
	rts     
P53_loc_20BFD2:
	bra.w   loc_20CFDE
P53_dat_20BFD6:
	dc.w	loc_20BFE6-P53_dat_20BFD6
	dc.w	loc_20C044-P53_dat_20BFD6
