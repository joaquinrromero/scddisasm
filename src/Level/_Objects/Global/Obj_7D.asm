; Object $7D - Obj2E_20DE98 (from R41A, old ID $2E)
Obj2E_20DE98:
	tst.b   oSubtype(a0)
	beq.s   P7D_loc_20DEA2
	bra.w   P7D_loc_20E10C
P7D_loc_20DEA2:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P7D_dat_20DEB6(pc, d0.w), d0
	jmp     P7D_dat_20DEB6(pc, d0.w)
P7D_dat_20DEB6:
	dc.w	P7D_loc_20DEC8-P7D_dat_20DEB6
	dc.w	P7D_loc_20DEFE-P7D_dat_20DEB6
	dc.w	P7D_loc_20DF44-P7D_dat_20DEB6
	dc.w	P7D_loc_20DFC0-P7D_dat_20DEB6
	dc.w	P7D_loc_20DFF2-P7D_dat_20DEB6
	dc.w	P7D_loc_20E008-P7D_dat_20DEB6
	dc.w	P7D_loc_20E022-P7D_dat_20DEB6
	dc.w	P7D_loc_20E05A-P7D_dat_20DEB6
	dc.w	P7D_loc_20E0AE-P7D_dat_20DEB6
P7D_loc_20DEC8:
	move.w  oX(a0), $3e(a0)
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$2f, oColType(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.w  #$23f0, oTile(a0)
	move.l  #$20e0e2, oMap(a0)
P7D_loc_20DEFE:
	addi.l  #$10000, oY(a0)
	jsr     ObjGetFloorDist.l
	cmpi.w  #$5, d1
	bmi.s   P7D_loc_20DF2E
P7D_loc_20DF12:
	lea     P7D_loc_20E0DC.l, a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	move.w  $3e(a0), d0
	jmp     CheckObjDespawn2.l
P7D_loc_20DF2E:
	addq.b  #$2, oRoutine(a0)
	move.l  #$500000, $2a(a0)
	move.l  #$ffffc000, $2e(a0)
	bra.s   P7D_loc_20DF12
P7D_loc_20DF44:
	addi.l  #$ffffc000, $2a(a0)
	bmi.s   P7D_loc_20DFA4
	move.l  $2e(a0), d0
	add.l   d0, oX(a0)
	jsr     ObjGetFloorDist.l
	subq.w  #$5, d1
	add.w   d1, oY(a0)
	moveq   #$0, d3
	move.b  oXRadius(a0), d3
	lea     ObjGetRWallDist.l, a1
	btst.b  #$0, oSprFlags(a0)
	bne.s   P7D_loc_20DF7C
	lea     ObjGetLWallDist.l, a1
P7D_loc_20DF7C:
	jsr     (a1)
	cmpi.w  #$5, d1
	bmi.s   P7D_loc_20DFA4
	move.w  oX(a0), d0
	sub.w   $FFFFD008.w, d0
	btst.b  #$0, oSprFlags(a0)
	beq.s   P7D_loc_20DF96
	neg.w   d0
P7D_loc_20DF96:
	subi.w  #$10, d0
	subi.w  #$40, d0
	bcs.s   P7D_loc_20DFB2
	bra.w   P7D_loc_20DF12
P7D_loc_20DFA4:
	addq.b  #$2, oRoutine(a0)
	move.w  #$1f, $32(a0)
	bra.w   P7D_loc_20DF12
P7D_loc_20DFB2:
	addq.b  #$6, oRoutine(a0)
	move.w  #$7, $32(a0)
	bra.w   P7D_loc_20DF12
P7D_loc_20DFC0:
	addi.w  #$ffff, $32(a0)
	beq.s   P7D_loc_20DFCC
	bra.w   P7D_loc_20DF12
P7D_loc_20DFCC:
	addq.b  #$2, oRoutine(a0)
	move.w  #$1f, $32(a0)
	move.l  #$500000, $2a(a0)
	neg.l   $2e(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	bra.w   P7D_loc_20DF12
P7D_loc_20DFF2:
	addi.w  #$ffff, $32(a0)
	beq.s   P7D_loc_20DFFE
	bra.w   P7D_loc_20DF12
P7D_loc_20DFFE:
	addi.b  #$fc, oRoutine(a0)
	bra.w   P7D_loc_20DF12
P7D_loc_20E008:
	addi.w  #$ffff, $32(a0)
	beq.s   P7D_loc_20E014
	bra.w   P7D_loc_20DF12
P7D_loc_20E014:
	addq.b  #$2, oRoutine(a0)
	move.w  #$1f, $32(a0)
	bra.w   P7D_loc_20DF12
P7D_loc_20E022:
	addi.l  #$2000, oY(a0)
	addi.w  #$ffff, $32(a0)
	beq.s   P7D_loc_20E036
	bra.w   P7D_loc_20DF12
P7D_loc_20E036:
	addq.b  #$2, oRoutine(a0)
	move.l  #$fffb8000, $38(a0)
	btst.b  #$0, oSprFlags(a0)
	beq.s   P7D_loc_20E04E
	neg.l   $38(a0)
P7D_loc_20E04E:
	move.l  #$fffe8000, $34(a0)
	bra.w   P7D_loc_20DF12
P7D_loc_20E05A:
	move.l  $38(a0), d0
	add.l   d0, oX(a0)
	moveq   #$0, d3
	move.b  oXRadius(a0), d3
	lea     ObjGetRWallDist.l, a1
	btst.b  #$0, oSprFlags(a0)
	bne.s   P7D_loc_20E07C
	lea     ObjGetLWallDist.l, a1
P7D_loc_20E07C:
	jsr     (a1)
	cmpi.w  #$5, d1
	bmi.s   P7D_loc_20E014
	move.l  $34(a0), d0
	add.l   d0, oY(a0)
	tst.l   $34(a0)
	bpl.s   P7D_loc_20E09A
	addi.l  #$2000, $34(a0)
P7D_loc_20E09A:
	jsr     CheckObjDespawn.l
	bra.w   P7D_loc_20DF12
	move.b  #$6, oRoutine(a0)
	bra.w   P7D_loc_20DF12
P7D_loc_20E0AE:
	addi.l  #$10000, oY(a0)
	jsr     ObjGetFloorDist.l
	cmpi.w  #$5, d1
	bmi.s   P7D_loc_20E0C6
	bra.w   P7D_loc_20DF12
P7D_loc_20E0C6:
	move.b  #$6, oRoutine(a0)
	subq.w  #$5, d1
	add.w   d1, oY(a0)
	move.w  #$1f, $32(a0)
	bra.w   P7D_loc_20DF12
P7D_loc_20E0DC:
	dc.w	$0002,$0900,$01FF
P7D_loc_20E0E2:
	dc.w	$0004,$0014,$03F4,$0500,$00E8,$0400,$0004,$F0F4
	dc.w	$0E00,$05F8,$04FC,$0400,$11E8,$F405,$0000,$E804
	dc.w	$0000,$04F0,$F40E,$0005,$F800
P7D_loc_20E10C:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P7D_dat_20E120(pc, d0.w), d0
	jmp     P7D_dat_20E120(pc, d0.w)
P7D_dat_20E120:
	dc.w	P7D_loc_20E132-P7D_dat_20E120
	dc.w	P7D_loc_20E168-P7D_dat_20E120
	dc.w	P7D_loc_20E1B4-P7D_dat_20E120
	dc.w	P7D_loc_20E230-P7D_dat_20E120
	dc.w	P7D_loc_20E262-P7D_dat_20E120
	dc.w	P7D_loc_20E278-P7D_dat_20E120
	dc.w	P7D_loc_20E292-P7D_dat_20E120
	dc.w	P7D_loc_20E2CA-P7D_dat_20E120
	dc.w	P7D_loc_20E328-P7D_dat_20E120
P7D_loc_20E132:
	move.w  oX(a0), $3e(a0)
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$2f, oColType(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.w  #$23f0, oTile(a0)
	move.l  #$20e35c, oMap(a0)
P7D_loc_20E168:
	addi.l  #$10000, oY(a0)
	jsr     ObjGetFloorDist.l
	cmpi.w  #$5, d1
	bmi.s   P7D_loc_20E198
P7D_loc_20E17C:
	lea     P7D_loc_20E356.l, a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	move.w  $3e(a0), d0
	jmp     CheckObjDespawn2.l
P7D_loc_20E198:
	addq.b  #$2, oRoutine(a0)
	subq.w  #$5, d1
	add.w   d1, oY(a0)
	move.l  #$500000, $2a(a0)
	move.l  #$ffffc000, $2e(a0)
	bra.s   P7D_loc_20E17C
P7D_loc_20E1B4:
	addi.l  #$ffffc000, $2a(a0)
	bmi.s   P7D_loc_20E214
	move.l  $2e(a0), d0
	add.l   d0, oX(a0)
	jsr     ObjGetFloorDist.l
	subq.w  #$5, d1
	add.w   d1, oY(a0)
	moveq   #$0, d3
	move.b  oXRadius(a0), d3
	lea     ObjGetRWallDist.l, a1
	btst.b  #$0, oSprFlags(a0)
	bne.s   P7D_loc_20E1EC
	lea     ObjGetLWallDist.l, a1
P7D_loc_20E1EC:
	jsr     (a1)
	cmpi.w  #$5, d1
	bmi.s   P7D_loc_20E214
	move.w  oX(a0), d0
	sub.w   $FFFFD008.w, d0
	btst.b  #$0, oSprFlags(a0)
	beq.s   P7D_loc_20E206
	neg.w   d0
P7D_loc_20E206:
	subi.w  #$10, d0
	subi.w  #$40, d0
	bcs.s   P7D_loc_20E222
	bra.w   P7D_loc_20E17C
P7D_loc_20E214:
	addq.b  #$2, oRoutine(a0)
	move.w  #$1f, $32(a0)
	bra.w   P7D_loc_20E17C
P7D_loc_20E222:
	addq.b  #$6, oRoutine(a0)
	move.w  #$7, $32(a0)
	bra.w   P7D_loc_20E17C
P7D_loc_20E230:
	addi.w  #$ffff, $32(a0)
	beq.s   P7D_loc_20E23C
	bra.w   P7D_loc_20E17C
P7D_loc_20E23C:
	addq.b  #$2, oRoutine(a0)
	move.w  #$1f, $32(a0)
	move.l  #$500000, $2a(a0)
	neg.l   $2e(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	bra.w   P7D_loc_20E17C
P7D_loc_20E262:
	addi.w  #$ffff, $32(a0)
	beq.s   P7D_loc_20E26E
	bra.w   P7D_loc_20E17C
P7D_loc_20E26E:
	addi.b  #$fc, oRoutine(a0)
	bra.w   P7D_loc_20E17C
P7D_loc_20E278:
	addi.w  #$ffff, $32(a0)
	beq.s   P7D_loc_20E284
	bra.w   P7D_loc_20E17C
P7D_loc_20E284:
	addq.b  #$2, oRoutine(a0)
	move.w  #$1f, $32(a0)
	bra.w   P7D_loc_20E17C
P7D_loc_20E292:
	addi.l  #$2800, oY(a0)
	addi.w  #$ffff, $32(a0)
	beq.s   P7D_loc_20E2A6
	bra.w   P7D_loc_20E17C
P7D_loc_20E2A6:
	addq.b  #$2, oRoutine(a0)
	move.l  #$ffff0000, $38(a0)
	btst.b  #$0, oSprFlags(a0)
	beq.s   P7D_loc_20E2BE
	neg.l   $38(a0)
P7D_loc_20E2BE:
	move.l  #$fffe8000, $34(a0)
	bra.w   P7D_loc_20E17C
P7D_loc_20E2CA:
	move.l  $38(a0), d0
	add.l   d0, oX(a0)
	moveq   #$0, d3
	move.b  oXRadius(a0), d3
	lea     ObjGetRWallDist.l, a1
	btst.b  #$0, oSprFlags(a0)
	bne.s   P7D_loc_20E2EC
	lea     ObjGetLWallDist.l, a1
P7D_loc_20E2EC:
	jsr     (a1)
	tst.w   d1
	bmi.s   P7D_loc_20E316
	move.l  $34(a0), d0
	add.l   d0, oY(a0)
	addi.l  #$1000, $34(a0)
	bmi.w   P7D_loc_20E17C
	jsr     ObjGetFloorDist.l
	cmpi.w  #$5, d1
	bmi.s   P7D_loc_20E31E
	bra.w   P7D_loc_20E17C
P7D_loc_20E316:
	addq.b  #$2, oRoutine(a0)
	bra.w   P7D_loc_20E17C
P7D_loc_20E31E:
	move.b  #$4, oRoutine(a0)
	bra.w   P7D_loc_20E17C
P7D_loc_20E328:
	addi.l  #$10000, oY(a0)
	jsr     ObjGetFloorDist.l
	cmpi.w  #$5, d1
	bmi.s   P7D_loc_20E340
	bra.w   P7D_loc_20E17C
P7D_loc_20E340:
	move.b  #$6, oRoutine(a0)
	subq.w  #$5, d1
	add.w   d1, oY(a0)
	move.w  #$1f, $32(a0)
	bra.w   P7D_loc_20E17C
P7D_loc_20E356:
	dc.w	$0002,$0900,$01FF
P7D_loc_20E35C:
	dc.w	$0004,$0014,$03F4,$0D00,$13E8,$F405,$001B,$0804
	dc.w	$0800,$1FF0,$04FC,$0400,$22E8,$F40D,$0013,$E8F4
	dc.w	$0500,$1B08,$0408,$001F,$F000
