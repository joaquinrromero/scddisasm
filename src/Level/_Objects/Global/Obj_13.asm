; Object $13 - ObjCheckpoint (from R11A, old ID $13)
ObjCheckpoint:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P13_dat_205E76(pc, d0.w), d0
	jsr     P13_dat_205E76(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P13_dat_205E76:
	dc.w	ObjCheckpoint_Init-P13_dat_205E76
	dc.w	ObjCheckpoint_Main-P13_dat_205E76
	dc.w	ObjCheckpoint_Ball-P13_dat_205E76
	dc.w	ObjCheckpoint_Animate-P13_dat_205E76
ObjCheckpoint_Init:
	addq.b  #$2, oRoutine(a0)
	move.l  #$23f120, oMap(a0)
	move.w  #$6cb, oTile(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$18, oYRadius(a0)
	move.b  #$4, oPriority(a0)
	move.b  checkpoint.l, d0
	cmp.b   oSubtype(a0), d0
	bcs.s   P13_loc_205EBC
	move.b  #$1, $2e(a0)
	bra.s   P13_loc_205EC2
P13_loc_205EBC:
	move.b  #$e3, oColType(a0)
P13_loc_205EC2:
	jsr     FindObjSlot.l
	bne.s   P13_loc_205F34
	dc.b	$13,$7C,$00,$13,$00,$00		; move.b #$13, $0(a1) (raw: not reproducible by assembler)
	addq.b  #$4, $24(a1)
	tst.b   $2e(a0)
	beq.s   P13_loc_205EDE
	addq.b  #$2, $24(a1)
P13_loc_205EDE:
	move.l  #$23f120, $4(a1)
	move.w  #$6cb, $2(a1)
	move.b  #$4, $1(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	move.b  #$3, $18(a1)
	move.b  #$1, $1a(a1)
	move.l  a0, $30(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$20, $c(a1)
	move.w  oX(a0), $2a(a1)
	move.w  oY(a0), $2c(a1)
	subi.w  #$18, $2c(a1)
	rts     
P13_loc_205F34:
	jmp     DeleteObject.l
ObjCheckpoint_Main:
	tst.b   $2e(a0)
	bne.s   P13_loc_205F6E
	tst.b   oColStatus(a0)
	beq.s   P13_loc_205F6E
	clr.b   oColType(a0)
	move.b  #$1, $2e(a0)
	move.b  oSubtype(a0), checkpoint.l
	move.b  #$1, spawnMode.l
	bsr.w   ObjCheckpoint_SaveData
	move.w  #$ae, d0
	jmp     PlayFMSound.l
P13_loc_205F6E:
	rts     
ObjCheckpoint_Ball:
	tst.b   $2e(a0)
	bne.s   P13_loc_205F86
	movea.l $30(a0), a1
	tst.b   $2e(a1)
	beq.s   P13_loc_205FC0
	move.b  #$1, $2e(a0)
P13_loc_205F86:
	addq.b  #$8, $34(a0)
	moveq   #$0, d0
	move.b  $34(a0), d0
	jsr     CalcSine.l
	muls.w  #$8, d0
	lsr.l   #$8, d0
	move.w  $2a(a0), oX(a0)
	add.w   d0, oX(a0)
	muls.w  #$fff8, d1
	lsr.l   #$8, d1
	move.w  $2c(a0), oY(a0)
	add.w   d1, oY(a0)
	tst.b   $34(a0)
	bne.s   P13_loc_205FC0
	addq.b  #$2, oRoutine(a0)
P13_loc_205FC0:
	rts     
ObjCheckpoint_Animate:
	lea     Ani_Checkpoint.l, a1
	bra.w   AnimateObject
ObjCheckpoint_SaveData:
	move.b  spawnMode.l, savedSpawnMode.l
	move.w  $FFFFD008.w, savedX.l
	move.w  $FFFFD00C.w, savedY.l
	move.b  waterRoutine.w, savedWaterRoutine.l
	move.w  bottomBound.w, savedBtmBound.l
	move.w  cameraX.w, savedCamX.l
	move.w  cameraY.w, savedCamY.l
	move.w  cameraBgX.w, savedCamBgX.l
	move.w  cameraBgY.w, savedCamBgY.l
	move.w  cameraBg2X.w, savedCamBg2X.l
	move.w  cameraBg2Y.w, savedCamBg2Y.l
	move.w  cameraBg3X.w, savedCamBg3X.l
	move.w  cameraBg3Y.w, savedCamBg3Y.l
	move.w  waterHeight2.w, savedWaterHeight.l
	move.b  waterRoutine.w, savedWaterRoutine.l
	move.b  waterFullscreen.w, savedWaterFull.l
	move.l  time.l, d0
	cmpi.l  #$50000, d0
	bcs.s   P13_loc_205E4A
	move.l  #$50000, d0
P13_loc_205E4A:
	move.l  d0, savedTime.l
	move.b  miniSonic.l, savedMiniSonic.l
	rts     
