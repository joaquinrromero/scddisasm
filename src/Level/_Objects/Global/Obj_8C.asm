; Object $8C - Obj30_20D8EC (from R61A, old ID $30)
P8C_Obj30_20D8EC:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P8C_dat_20D90C(pc, d0.w), d0
	jsr     P8C_dat_20D90C(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P8C_dat_20D90C:
	dc.w	P8C_loc_20D914-P8C_dat_20D90C
	dc.w	P8C_loc_20D998-P8C_dat_20D90C
	dc.w	P8C_loc_20DA14-P8C_dat_20D90C
	dc.w	P8C_loc_20DA74-P8C_dat_20D90C
P8C_loc_20D914:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$2438, oTile(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.l  #$70000, $2e(a0)
	move.l  #$206e58, $36(a0)
	move.w  #$fff0, $34(a0)
	move.b  #$1, oMapFrame(a0)
	bsr.w   P8C_loc_20DB08
	movea.l #$20db2a, a1
	move.l  #$ffff6000, d0
	move.b  #$7, d1
	tst.b   oSubtype(a0)
	beq.s   P8C_loc_20D97C
	movea.l #$20db4e, a1
	move.l  #$ffff8000, d0
	move.b  #$3, d1
P8C_loc_20D97C:
	move.l  a1, oMap(a0)
	move.l  d0, $2a(a0)
	move.l  #$70000, $2e(a0)
	move.b  d1, $33(a0)
	move.b  d1, $32(a0)
	addq.b  #$1, $32(a0)
P8C_loc_20D998:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	move.l  $2e(a0), d0
	add.l   d0, oY(a0)
	jsr     ObjGetFloorDist.l
	move.w  d1, $3e(a0)
	move.w  $34(a0), d3
	movea.l $36(a0), a1
	jsr     (a1)
	tst.w   d1
	bpl.s   P8C_loc_20D9D2
	tst.w   $3e(a0)
	bpl.w   P8C_loc_20DAD4
	cmp.w   $3e(a0), d1
	ble.w   P8C_loc_20DAD4
	bra.s   P8C_loc_20D9F4
P8C_loc_20D9D2:
	tst.w   $3e(a0)
	bmi.s   P8C_loc_20D9F4
	addi.l  #$2000, $2e(a0)
	cmpi.l  #$70000, $2e(a0)
	blt.s   P8C_loc_20D9F2
	move.l  #$70000, $2e(a0)
P8C_loc_20D9F2:
	rts     
P8C_loc_20D9F4:
	addq.b  #$2, oRoutine(a0)
	move.w  $3e(a0), d0
	add.w   d0, oY(a0)
	move.w  #$1, d0
	tst.b   oSubtype(a0)
	beq.s   P8C_loc_20DA0E
	move.w  #$14, d0
P8C_loc_20DA0E:
	move.w  d0, $3a(a0)
	rts     
P8C_loc_20DA14:
	tst.b   oSubtype(a0)
	beq.s   P8C_loc_20DA44
	move.w  #$7, d6
	move.w  $3a(a0), d0
	cmpi.w  #$6, d0
	beq.s   P8C_loc_20DA3C
	cmpi.w  #$b, d0
	beq.s   P8C_loc_20DA3A
	cmpi.w  #$f, d0
	beq.s   P8C_loc_20DA3C
	cmpi.w  #$12, d0
	bne.s   P8C_loc_20DA44
P8C_loc_20DA3A:
	neg.w   d6
P8C_loc_20DA3C:
	add.w   d6, oY(a0)
	bsr.w   P8C_loc_20DB08
P8C_loc_20DA44:
	subq.w  #$1, $3a(a0)
	bne.s   P8C_loc_20DA72
	addq.b  #$2, oRoutine(a0)
	subq.w  #$7, oY(a0)
	bsr.w   P8C_loc_20DB08
	move.l  #$fffa0000, d0
	tst.b   oSubtype(a0)
	beq.s   P8C_loc_20DA68
	move.l  #$fffb0000, d0
P8C_loc_20DA68:
	move.l  d0, $2e(a0)
	subq.b  #$1, $32(a0)
	bmi.s   P8C_loc_20DAD4
P8C_loc_20DA72:
	rts     
P8C_loc_20DA74:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	move.l  $2e(a0), d0
	add.l   d0, oY(a0)
	jsr     ObjGetCeilDist.l
	move.w  d1, $3e(a0)
	move.w  $34(a0), d3
	movea.l $36(a0), a1
	jsr     (a1)
	tst.w   d1
	bpl.s   P8C_loc_20DAAA
	tst.w   $3e(a0)
	bpl.s   P8C_loc_20DAD4
	cmp.w   $3e(a0), d1
	ble.s   P8C_loc_20DAD4
	bra.s   P8C_loc_20DABC
P8C_loc_20DAAA:
	tst.w   $3e(a0)
	bmi.s   P8C_loc_20DABC
	addi.l  #$2000, $2e(a0)
	bpl.s   P8C_loc_20DAC8
	rts     
P8C_loc_20DABC:
	move.w  $3e(a0), d0
	sub.w   d0, oY(a0)
	clr.l   $2e(a0)
P8C_loc_20DAC8:
	subq.b  #$4, oRoutine(a0)
	subi.w  #$b, oY(a0)
	bra.s   P8C_loc_20DB08
P8C_loc_20DAD4:
	move.b  $33(a0), $32(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	neg.l   $2a(a0)
	neg.w   $34(a0)
	lea     ObjGetLWallDist.l, a1
	lea     ObjGetRWallDist.l, a2
	cmpa.l  $36(a0), a1
	bne.s   P8C_loc_20DB02
	exg.l   a1, a2
P8C_loc_20DB02:
	move.l  a1, $36(a0)
	rts     
P8C_loc_20DB08:
	tst.b   oMapFrame(a0)
	beq.s   P8C_loc_20DB16
	moveq   #$0, d0
	moveq   #$13, d1
	moveq   #$2f, d2
	bra.s   P8C_loc_20DB1C
P8C_loc_20DB16:
	moveq   #$1, d0
	moveq   #$1c, d1
	moveq   #$30, d2
P8C_loc_20DB1C:
	move.b  d0, oMapFrame(a0)
	move.b  d1, oYRadius(a0)
	move.b  d2, oColType(a0)
	rts     
P8C_loc_20DB2A:
	dc.w	$0004,$0014,$03EE,$0000,$00F0,$F60D,$0001,$F006
	dc.w	$0500,$09F8,$03E3,$0000,$00F0,$EB0D,$0001,$F0FB
	dc.w	$0700,$0DF8
P8C_loc_20DB4E:
	dc.w	$0004,$0014,$03EE,$0400,$15F0,$F60D,$0017,$F006
	dc.w	$0500,$09F8,$03E3,$0400,$15F0,$EB0D,$0017,$F0FB
	dc.w	$0700,$0DF8
