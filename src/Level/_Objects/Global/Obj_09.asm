; Object $09 - ObjSpinningDisc (from R11A, old ID $09)
ObjSpinningDisc:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjSpinningDisc_Index(pc, d0.w), d0
	jsr     ObjSpinningDisc_Index(pc, d0.w)
	tst.w   timeStopTimer.l
	bne.s   P09_loc_2093D4
	lea     Ani_SpinningDisc.l, a1
	bsr.w   AnimateObject
P09_loc_2093D4:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
ObjSpinningDisc_Index:
	dc.w	ObjSpinningDisc_Init-ObjSpinningDisc_Index
	dc.w	ObjSpinningDisc_Main-ObjSpinningDisc_Index
ObjSpinningDisc_Init:
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.l  #$2095d4, oMap(a0)
	moveq   #$6, d0
	jsr     SetObjectTileID(pc)
	move.b  #$10, oWidth(a0)
	move.b  #$8, oYRadius(a0)
ObjSpinningDisc_Main:
	tst.b   oSprFlags(a0)
	bpl.w   P09_loc_209452
	lea     objects.w, a1
	bsr.s   ObjSpinningDisc_SolidObj
	beq.s   P09_loc_209452
	bset.b  #$0, $2c(a1)
	bne.s   P09_loc_209448
	move.b  #$2d, $1c(a1)
	moveq   #$0, d0
	move.b  d0, $2b(a1)
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	bcc.s   P09_loc_209444
	neg.w   d0
	move.b  #$80, $2b(a1)
P09_loc_209444:
	move.b  d0, $39(a1)
P09_loc_209448:
	cmpi.b  #$6, $24(a1)
	bcc.s   P09_loc_209452
	bra.s   P09_loc_209454
P09_loc_209452:
	rts     
P09_loc_209454:
	addq.b  #$8, $2b(a1)
	move.b  $2b(a1), d0
	jsr     CalcSine.l
	moveq   #$0, d0
	move.b  $39(a1), d0
	muls.w  d1, d0
	lsr.l   #$8, d0
	move.w  oX(a0), $8(a1)
	add.w   d0, $8(a1)
	moveq   #$0, d0
	move.b  $2b(a1), d0
	move.b  d0, d1
	andi.b  #$f0, d0
	lsr.b   #$4, d0
	move.b  ObjSpinningDisc_PlayerFrames(pc, d0.w), $1b(a1)
	andi.b  #$3f, d1
	bne.s   P09_loc_209494
	addq.b  #$1, $39(a1)
P09_loc_209494:
	move.w  p1CtrlData.w, playerCtrl.w
	bsr.w   ObjSpinningDisc_CheckDirs
	bra.w   ObjSpinningDisc_CheckJump
	dc.w	$4E75
ObjSpinningDisc_SolidObj:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     SolidObject.l
ObjSpinningDisc_PlayerFrames:
	dc.w	$0000,$0001,$0102,$0202,$0303,$0304,$0405,$0505
ObjSpinningDisc_CheckDirs:
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	bcc.s   P09_loc_2094E2
	btst.b  #$2, playerCtrl.w
	beq.s   P09_loc_2094CC
	addq.b  #$1, $39(a1)
	bra.s   P09_loc_209504
P09_loc_2094CC:
	btst.b  #$3, playerCtrl.w
	beq.s   P09_loc_209504
	subq.b  #$1, $39(a1)
	bcc.s   P09_loc_209504
	move.b  #$0, $39(a1)
	bra.s   P09_loc_209504
P09_loc_2094E2:
	btst.b  #$3, playerCtrl.w
	beq.s   P09_loc_2094F0
	addq.b  #$1, $39(a1)
	bra.s   P09_loc_209504
P09_loc_2094F0:
	btst.b  #$2, playerCtrl.w
	beq.s   P09_loc_209504
	subq.b  #$1, $39(a1)
	bcc.s   P09_loc_209504
	move.b  #$0, $39(a1)
P09_loc_209504:
	rts     
ObjSpinningDisc_CheckJump:
	move.b  playerCtrlTap.w, d0
	andi.b  #$70, d0
	beq.w   P09_loc_2095C2
	clr.b   $2c(a1)
	move.w  #$680, d2
	btst.b  #$6, oFlags(a0)
	beq.s   P09_loc_209526
	move.w  #$380, d2
P09_loc_209526:
	moveq   #$0, d0
	move.b  $26(a1), d0
	subi.b  #$40, d0
	jsr     CalcSine.l
	muls.w  d2, d1
	asr.l   #$8, d1
	add.w   d1, $10(a1)
	muls.w  d2, d0
	asr.l   #$8, d0
	add.w   d0, $12(a1)
	bset.b  #$1, $22(a1)
	bclr.b  #$5, $22(a1)
	move.b  #$1, $3c(a1)
	clr.b   $38(a1)
	move.w  #$a0, d0
	jsr     PlayFMSound.l
	tst.b   miniSonic.l
	beq.s   P09_loc_20957C
	move.b  #$a, $16(a1)
	move.b  #$5, $17(a1)
	bra.s   P09_loc_209588
P09_loc_20957C:
	move.b  #$13, $16(a1)
	move.b  #$9, $17(a1)
P09_loc_209588:
	btst.b  #$2, $22(a1)
	bne.s   P09_loc_2095C4
	tst.b   miniSonic.l
	beq.s   P09_loc_2095A6
	move.b  #$a, $16(a1)
	move.b  #$5, $17(a1)
	bra.s   P09_loc_2095B6
P09_loc_2095A6:
	move.b  #$e, $16(a1)
	move.b  #$7, $17(a1)
	addq.w  #$5, $c(a1)
P09_loc_2095B6:
	bset.b  #$2, $22(a1)
	move.b  #$2, $1c(a1)
P09_loc_2095C2:
	rts     
P09_loc_2095C4:
	bset.b  #$4, $22(a1)
	rts     
