; Object $9A - Obj21_20BDB8 (from R53C, old ID $21)
P9A_Obj21_20BDB8:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P9A_dat_20BDCC(pc, d0.w), d0
	jsr     P9A_dat_20BDCC(pc, d0.w)
	jmp     DrawObject.l
P9A_dat_20BDCC:
	dc.w	P9A_loc_20BDD6-P9A_dat_20BDCC
	dc.w	P9A_loc_20BE0C-P9A_dat_20BDCC
	dc.w	P9A_loc_20BE26-P9A_dat_20BDCC
	dc.w	P9A_loc_20BE44-P9A_dat_20BDCC
	dc.w	P9A_loc_20BE62-P9A_dat_20BDCC
P9A_loc_20BDD6:
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$20, oYRadius(a0)
	move.w  #$42bc, oTile(a0)
	move.l  #$20c836, oMap(a0)
	move.b  #$bf, oColType(a0)
	move.b  #$2, oColStatus(a0)
P9A_loc_20BE0C:
	bsr.w   P9A_sub_20C416
	cmpi.w  #$c50, $8(a1)
	bge.s   P9A_loc_20BE1A
	rts     
P9A_loc_20BE1A:
	moveq   #$4, d0
	jsr     LoadPLC.l
	addq.b  #$2, oRoutine(a0)
P9A_loc_20BE26:
	subi.l  #$20000, oY(a0)
	cmpi.w  #$2a0, oY(a0)
	ble.s   P9A_loc_20BE3A
	bra.w   P9A_loc_20BE66
P9A_loc_20BE3A:
	move.w  #$2a0, oY(a0)
	addq.b  #$2, oRoutine(a0)
P9A_loc_20BE44:
	addi.l  #$20000, oX(a0)
	cmpi.w  #$cd0, oX(a0)
	bge.s   P9A_loc_20BE58
	bra.w   P9A_loc_20BE66
P9A_loc_20BE58:
	addq.b  #$2, oRoutine(a0)
	move.w  #$cd0, oX(a0)
P9A_loc_20BE62:
	bra.w   P9A_loc_20BE66
P9A_loc_20BE66:
	move.b  #$c, oWidth(a0)
	move.b  #$1e, oYRadius(a0)
	bsr.w   P9A_sub_20B802
	move.b  #$20, oWidth(a0)
	move.b  #$20, oYRadius(a0)
	rts     
P9A_sub_20C416:
	lea     objects.w, a1
	rts     
P9A_sub_20B802:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	lea     objects.w, a1
	jsr     SolidObject.l
	rts     
