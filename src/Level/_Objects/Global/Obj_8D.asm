; Object $8D - ObjResults (from R63C, old ID $34)
ObjResults:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P8D_dat_20A896(pc, d0.w), d0
	jmp     P8D_dat_20A896(pc, d0.w)
P8D_dat_20A896:
	dc.w	ObjResults_Init-P8D_dat_20A896
	dc.w	ObjResults_WaitPLC-P8D_dat_20A896
	dc.w	ObjResults_Move-P8D_dat_20A896
	dc.w	ObjResults_Bonus-P8D_dat_20A896
	dc.w	ObjResults_NextLevel-P8D_dat_20A896
ObjResults_Init:
	subq.b  #$1, $32(a0)
	beq.s   P8D_loc_20A8A8
	rts     
P8D_loc_20A8A8:
	moveq   #$10, d0
	jsr     LoadPLC.l
	addq.b  #$2, oRoutine(a0)
ObjResults_WaitPLC:
	tst.l   plcBuffer.w
	bne.s   P8D_loc_20A8D6
	cmpi.w  #$502, zoneAct.l
	beq.s   P8D_loc_20A8D8
	lea     objects.w, a6
	move.w  cameraX.w, d0
	addi.w  #$150, d0
	cmp.w   $8(a6), d0
	bcs.s   P8D_loc_20A8D8
P8D_loc_20A8D6:
	rts     
P8D_loc_20A8D8:
	lea     ObjResults_InitData.l, a2
	moveq   #$2, d6
	moveq   #$0, d1
	movea.l a0, a1
	move.w  #$168, $32(a0)
	bra.s   P8D_loc_20A8F2
P8D_loc_20A8EC:
	jsr     FindObjSlot.l
P8D_loc_20A8F2:
	move.w  #$168, $32(a1)
	dc.b	$13,$7C,$00,$3A,$00,$00		; move.b #$3a, $0(a1) (raw: not reproducible by assembler)
	move.b  #$4, $24(a1)
	move.w  #$83c4, $2(a1)
	cmpi.w  #$502, zoneAct.l
	bne.s   P8D_loc_20A934
	move.w  #$82f2, $2(a1)
	move.l  #$20ab6a, $4(a1)
	tst.b   goodFuture.l
	beq.s   P8D_loc_20A94C
	move.l  #$20ab7e, $4(a1)
	bra.s   P8D_loc_20A94C
P8D_loc_20A934:
	move.l  #$20ab60, $4(a1)
	tst.b   goodFuture.l
	beq.s   P8D_loc_20A94C
	move.l  #$20ab74, $4(a1)
P8D_loc_20A94C:
	move.w  d1, d2
	lsl.w   #$3, d2
	move.w  (a2, d2.w), $a(a1)
	move.w  $2(a2, d2.w), $8(a1)
	move.w  $4(a2, d2.w), $2a(a1)
	move.b  $7(a2, d2.w), $1a(a1)
	cmpi.b  #$2, d1
	bne.s   P8D_loc_20A978
	move.b  act.l, d2
	add.b   d2, $1a(a1)
P8D_loc_20A978:
	addq.b  #$1, d1
	dbra    d6, P8D_loc_20A8EC
	rts     
ObjResults_Move:
	tst.w   $32(a0)
	beq.s   P8D_loc_20A98A
	subq.w  #$1, $32(a0)
P8D_loc_20A98A:
	moveq   #$8, d0
	move.w  $2a(a0), d1
	cmp.w   oX(a0), d1
	beq.s   P8D_loc_20A9AE
	bge.s   P8D_loc_20A99A
	neg.w   d0
P8D_loc_20A99A:
	add.w   d0, oX(a0)
P8D_loc_20A99E:
	cmpi.w  #$160, $32(a0)
	bcc.s   P8D_loc_20A9AC
	jmp     DrawObject.l
P8D_loc_20A9AC:
	rts     
P8D_loc_20A9AE:
	tst.b   oMapFrame(a0)
	bne.s   P8D_loc_20A99E
	addq.b  #$2, oRoutine(a0)
	bra.s   P8D_loc_20A99E
ObjResults_Bonus:
	move.b  #$1, updateHUDBonus.w
	moveq   #$0, d0
	tst.w   timeBonus.w
	bne.s   P8D_loc_20A9F8
	tst.w   ringBonus.w
	bne.s   P8D_loc_20AA08
	subq.w  #$1, $32(a0)
	bpl.s   P8D_loc_20A9D8
	addq.b  #$2, oRoutine(a0)
P8D_loc_20A9D8:
	cmpi.w  #$1e, $32(a0)
	bne.s   P8D_loc_20A9F2
	tst.b   specialStage.l
	beq.s   P8D_loc_20A9F2
	move.w  #$c8, d0
	jsr     PlayFMSound.l
P8D_loc_20A9F2:
	jmp     DrawObject.l
P8D_loc_20A9F8:
	addi.w  #$a, d0
	subi.w  #$64, timeBonus.w
	tst.w   ringBonus.w
	beq.s   P8D_loc_20AA12
P8D_loc_20AA08:
	addi.w  #$a, d0
	subi.w  #$64, ringBonus.w
P8D_loc_20AA12:
	move.l  d0, d1
	tst.w   timeBonus.w
	bne.s   P8D_loc_20AA44
	tst.w   ringBonus.w
	bne.s   P8D_loc_20AA44
	jsr     StopZ80.l
	move.b  #$9a, $a01c09.l
	jsr     StartZ80.l
	cmpi.w  #$2d, $32(a0)
	bcc.s   P8D_loc_20AA60
	move.w  #$2d, $32(a0)
	bra.s   P8D_loc_20AA60
P8D_loc_20AA44:
	tst.w   $32(a0)
	beq.s   P8D_loc_20AA4E
	subq.w  #$1, $32(a0)
P8D_loc_20AA4E:
	btst.b  #$0, $32(a0)
	bne.s   P8D_loc_20AA60
	move.w  #$bd, d0
	jsr     PlayFMSound.l
P8D_loc_20AA60:
	move.l  d1, d0
	jsr     AddPoints.l
	jmp     DrawObject.l
ObjResults_NextLevel:
	move.w  #$2, levelRestart.l
	move.b  #$0, spawnMode.l
	clr.w   sectionID.l
	clr.l   flowerCount.l
	clr.b   unkLevelFlag.l
	clr.b   projDestroyed.l
	clr.b   checkpoint.l
	tst.b   timeAttackMode.l
	beq.s   P8D_loc_20AAAC
	bclr.b  #$0, plcLoadFlags.l
P8D_loc_20AAAC:
	bclr.b  #$1, plcLoadFlags.l
	move.b  #$1, timeZone.l
	move.w  zoneAct.l, d0
	addq.b  #$1, d0
	cmpi.b  #$2, d0
	bne.s   P8D_loc_20AAD2
	move.b  #$2, timeZone.l
P8D_loc_20AAD2:
	cmpi.b  #$3, d0
	bne.s   P8D_loc_20AAE4
	move.b  #$0, d0
	addi.w  #$100, d0
	move.b  #$0, d0
P8D_loc_20AAE4:
	move.w  d0, zoneAct.l
	jsr     ResetSavedObjFlags.l
	jsr     FadeOutMusic.l
	jsr     DrawObject.l
	move.b  act.l, d0
	subq.b  #$1, d0
	bpl.s   P8D_loc_20AB0E
	clr.b   goodFutureFlags.l
	rts     
P8D_loc_20AB0E:
	tst.b   timeAttackMode.l
	bne.s   P8D_loc_20AB46
	cmpi.b  #$7f, timeStones.l
	beq.s   P8D_loc_20AB3E
	tst.b   goodFuture.l
	beq.s   P8D_loc_20AB46
	clr.b   goodFuture.l
	bset.b  d0, goodFutureFlags.l
	cmpi.b  #$3, goodFutureFlags.l
	bne.s   P8D_loc_20AB46
P8D_loc_20AB3E:
	move.b  #$1, goodFuture.l
P8D_loc_20AB46:
	rts     
ObjResults_InitData:
	dc.w	$00CC,$0000,$0120,$0000,$0110,$0200,$00F0,$0001
	dc.w	$00CC,$0000,$0120,$0002
