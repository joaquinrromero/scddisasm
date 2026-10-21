; Object $4C - Obj4C_20C3CE (from R43C, old ID $4C)
Obj4C_20C3CE:
	bclr.b  #$6, $2c(a0)
	tst.b   $2b(a0)
	beq.s   P4C_loc_20C3F8
	subq.b  #$1, $2b(a0)
	bne.s   ObjWaterfall
	move.b  #$0, oAnim(a0)
	clr.b   oMapFrame(a0)
	clr.b   oAnimFrame(a0)
	clr.b   oAnimTime(a0)
	clr.b   $1f(a0)
	bra.s   ObjWaterfall
P4C_loc_20C3F8:
	bsr.w   P4C_sub_20C7AA
P4C_sub_20C7AA:
	tst.b   oAnim(a0)
	bne.s   P4C_loc_20C7C6
	lea     objects.w, a1
	tst.w   $30(a1)
	bne.w   P4C_sub_20C7C8
	cmpi.b  #$6, $24(a1)
	beq.w   P4C_sub_20C7C8
P4C_loc_20C7C6:
	rts     
P4C_sub_20C7C8:
	move.b  #$78, $2b(a0)
	move.b  #$1, oAnim(a0)
	clr.b   oMapFrame(a0)
	clr.b   oAnimFrame(a0)
	clr.b   oAnimTime(a0)
	clr.b   $1f(a0)
	rts     
