; Object $84 - Obj26_20E0F4 (from R51A, old ID $26)
P84_Obj26_20E0F4:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P84_dat_20E154(pc, d0.w), d0
	jsr     P84_dat_20E154(pc, d0.w)
	jsr     DrawObject.l
	moveq   #$0, d1
	move.w  $34(a0), d1
	beq.s   P84_loc_20E132
	movea.w d1, a1
	move.w  $8(a1), oX(a0)
	move.w  $c(a1), oY(a0)
	move.b  $38(a0), d0
	ext.w   d0
	add.w   d0, oX(a0)
	move.b  $39(a0), d0
	ext.w   d0
	add.w   d0, oY(a0)
P84_loc_20E132:
	move.w  $36(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.s   P84_loc_20E150
	rts     
P84_loc_20E150:
	bra.w   loc_20E302
P84_dat_20E154:
	dc.w	loc_20E164-P84_dat_20E154
	dc.w	loc_20E1B4-P84_dat_20E154
