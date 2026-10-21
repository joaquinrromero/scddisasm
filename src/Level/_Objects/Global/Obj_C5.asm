; Object $C5 - Obj22_20B320 (from R82A, old ID $22)
PC5_Obj22_20B320:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PC5_dat_20B32E(pc, d0.w), d1
	jmp     PC5_dat_20B32E(pc, d1.w)
PC5_dat_20B32E:
	dc.w	PC5_loc_20B332-PC5_dat_20B32E
	dc.w	PC5_loc_20B394-PC5_dat_20B32E
PC5_loc_20B332:
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.b  #$8, oWidth(a0)
	move.w  oX(a0), $32(a0)
	move.w  oY(a0), $30(a0)
	move.b  #$18, $34(a0)
	move.b  #$48, $38(a0)
	move.b  oSubtype(a0), d1
	andi.b  #$f, d1
	beq.s   PC5_loc_20B376
	move.b  #$10, $34(a0)
	move.b  #$30, $38(a0)
PC5_loc_20B376:
	move.b  oSubtype(a0), d1
	andi.b  #$f0, d1
	ext.w   d1
	asl.w   #$3, d1
	move.w  d1, $36(a0)
	move.b  oFlags(a0), d0
	ror.b   #$2, d0
	andi.b  #$c0, d0
	move.b  d0, oAngle(a0)
PC5_loc_20B394:
	bsr.w   PC5_sub_20B39E
	jmp     CheckObjDespawn.l
PC5_sub_20B39E:
	moveq   #$0, d2
	move.b  $38(a0), d2
	move.w  d2, d3
	add.w   d3, d3
	lea     objects.w, a1
	move.w  $8(a1), d0
	sub.w   $32(a0), d0
	add.w   d2, d0
	cmp.w   d3, d0
	bcc.s   PC5_loc_20B3D6
	move.w  $c(a1), d1
	sub.w   $30(a0), d1
	add.w   d2, d1
	cmp.w   d3, d1
	bcc.s   PC5_loc_20B3D6
	btst.b  #$1, $22(a1)
	beq.s   PC5_loc_20B3E6
	clr.b   $3a(a0)
	rts     
PC5_loc_20B3D6:
	tst.b   $3a(a0)
	beq.s   PC5_loc_20B3E4
	clr.b   $38(a1)
	clr.b   $3a(a0)
PC5_loc_20B3E4:
	rts     
PC5_loc_20B3E6:
	tst.b   $3a(a0)
	bne.s   PC5_loc_20B410
	move.b  #$1, $3a(a0)
	btst.b  #$2, $22(a1)
	bne.s   PC5_loc_20B3FE
	clr.b   $1c(a1)
PC5_loc_20B3FE:
	bclr.b  #$5, $22(a1)
	move.b  #$1, $1d(a1)
	move.b  #$1, $38(a1)
PC5_loc_20B410:
	move.w  $14(a1), d0
	tst.w   $36(a0)
	bpl.s   PC5_loc_20B436
	cmpi.w  #$fc00, d0
	ble.s   PC5_loc_20B428
	move.w  #$fc00, $14(a1)
	rts     
PC5_loc_20B428:
	cmpi.w  #$f100, d0
	bge.s   PC5_loc_20B434
	move.w  #$f100, $14(a1)
PC5_loc_20B434:
	rts     
PC5_loc_20B436:
	cmpi.w  #$400, d0
	bge.s   PC5_loc_20B444
	move.w  #$400, $14(a1)
	rts     
PC5_loc_20B444:
	cmpi.w  #$f00, d0
	ble.s   PC5_loc_20B450
	move.w  #$f00, $14(a1)
PC5_loc_20B450:
	rts     
	dc.w	$0002,$01F8,$0500,$00F8
