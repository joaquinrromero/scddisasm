; Object $6B - Obj25_20DFEA (from R51A, old ID $25)
P6B_Obj25_20DFEA:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P6B_dat_20E004(pc, d0.w), d0
	jsr     P6B_dat_20E004(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P6B_dat_20E004:
	dc.w	P6B_loc_20E00A-P6B_dat_20E004
	dc.w	P6B_loc_20E05A-P6B_dat_20E004
	dc.w	P6B_loc_20E092-P6B_dat_20E004
P6B_loc_20E00A:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$8, oXRadius(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$18, oYRadius(a0)
	move.l  #$20e0e6, oMap(a0)
	move.w  #$342, d0
	tst.b   timeZone.l
	beq.s   P6B_loc_20E052
	cmpi.b  #$1, timeZone.l
	beq.s   P6B_loc_20E056
	tst.b   goodFuture.l
	bne.s   P6B_loc_20E056
P6B_loc_20E052:
	move.w  #$4342, d0
P6B_loc_20E056:
	move.w  d0, oTile(a0)
P6B_loc_20E05A:
	lea     objects.w, a1
	bsr.s   P6B_sub_20E06E
	bcc.s   P6B_loc_20E06C
	addq.b  #$2, oRoutine(a0)
	move.b  #$b9, oColType(a0)
P6B_loc_20E06C:
	rts     
P6B_sub_20E06E:
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	subi.w  #$18, d0
	subi.w  #$68, d0
	bcc.s   P6B_loc_20E090
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	subi.w  #$fff8, d0
	subi.w  #$10, d0
P6B_loc_20E090:
	rts     
P6B_loc_20E092:
	tst.b   oSprFlags(a0)
	bmi.s   P6B_loc_20E0A8
	move.w  oY(a0), d0
	cmp.w   $FFFFD00C.w, d0
	blt.s   P6B_loc_20E0A8
	jmp     DeleteObject.l
P6B_loc_20E0A8:
	move.w  oX(a0), d3
	move.w  oY(a0), d2
	moveq   #$0, d0
	move.b  oYRadius(a0), d0
	sub.w   d0, d2
	jsr     P6B_sub_206DE6.l
	tst.w   d1
	smi.b   d0
	bmi.s   P6B_loc_20E0D0
	tst.b   $3f(a0)
	bpl.s   P6B_loc_20E0D0
	jmp     DeleteObject.l
P6B_loc_20E0D0:
	move.b  d0, $3f(a0)
	move.l  $2a(a0), d0
	add.l   d0, oY(a0)
	addi.l  #$4000, $2a(a0)
	rts     
P6B_loc_20E0E6:
	dc.w	$0002,$02E8,$0700,$00F8,$0805,$0008,$F800
P6B_sub_206DE6:
	lea     primaryAngle.w, a4
	move.b  #$0, (a4)
	movea.w #$10, a3
	move.w  #$0, d6
	moveq   #$d, d5
	jsr     FindLevelFloor.l
	move.b  primaryAngle.w, d3
	btst.l  #$0, d3
	beq.s   P6B_loc_206E0C
	move.b  #$0, d3
P6B_loc_206E0C:
	rts     
