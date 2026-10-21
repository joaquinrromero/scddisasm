; Object $14 - ObjBigRing (from R11A, old ID $14)
ObjBigRing:
	tst.b   oSubtype(a0)
	bne.s   ObjBigRingFlash
	cmpi.w  #$32, rings.l
	bcc.s   P14_loc_20D51C
	jmp     CheckObjDespawn.l
P14_loc_20D51C:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P14_dat_20D53A(pc, d0.w), d0
	jsr     P14_dat_20D53A(pc, d0.w)
	cmpi.b  #$4, oRoutine(a0)
	beq.s   P14_loc_20D538
	jmp     DrawObject.l
P14_loc_20D538:
	rts     
ObjBigRingFlash:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P14_dat_20D4D6(pc, d0.w), d0
	jsr     P14_dat_20D4D6(pc, d0.w)
	jmp     DrawObject.l
P14_dat_20D53A:
	dc.w	ObjBigRing_Init-P14_dat_20D53A
	dc.w	ObjBigRing_Main-P14_dat_20D53A
	dc.w	ObjBigRing_Animate-P14_dat_20D53A
P14_dat_20D4D6:
	dc.w	ObjBigRingFlash_Init-P14_dat_20D4D6
	dc.w	ObjBigRingFlash_Animate-P14_dat_20D4D6
	dc.w	ObjBigRingFlash_Delete-P14_dat_20D4D6
ObjBigRing_Init:
	cmpi.b  #$7f, timeStones.l
	bne.s   P14_loc_20D550
	jmp     DeleteObject.l
P14_loc_20D550:
	tst.b   timeAttackMode.l
	beq.s   P14_loc_20D55E
	jmp     DeleteObject.l
P14_loc_20D55E:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$2488, oTile(a0)
	move.l  #$23f16a, oMap(a0)
	move.b  #$20, oXRadius(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$20, oYRadius(a0)
ObjBigRing_Main:
	lea     objects.w, a1
	bsr.w   ObjBigRing_CheckTouch
	beq.s   ObjBigRing_Animate
	move.b  #$1, specialStage.l
	addq.b  #$2, oRoutine(a0)
	move.w  cameraX.w, d0
	addi.w  #$150, d0
	move.w  d0, $8(a1)
	bset.b  #$0, ctrlLocked.w
	move.w  #$808, playerCtrl.w
	move.w  #$0, $10(a1)
	move.w  #$0, $14(a1)
	move.b  #$1, scrollLock.w
	move.w  #$af, d0
	jsr     PlayFMSound.l
	jsr     FindObjSlot.l
	bne.s   ObjBigRing_Main
	dc.b	$13,$7C,$00,$14,$00,$00		; move.b #$14, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  #$1, $28(a1)
ObjBigRing_Animate:
	lea     Ani_BigRing.l, a1
	jmp     AnimateObject.l
ObjBigRingFlash_Init:
	ori.b   #$4, oSprFlags(a0)
	addq.b  #$2, oRoutine(a0)
	move.w  #$3ef, oTile(a0)
	move.l  #$20d9aa, oMap(a0)
ObjBigRingFlash_Animate:
	lea     Ani_BigRingFlash.l, a1
	jmp     AnimateObject.l
ObjBigRingFlash_Delete:
	jmp     DeleteObject.l
ObjBigRing_CheckTouch:
	move.b  $17(a1), d1
	ext.w   d1
	addi.w  #$10, d1
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	add.w   d1, d0
	bmi.s   P14_loc_20D63A
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P14_loc_20D63A
	move.b  $16(a1), d1
	ext.w   d1
	addi.w  #$20, d1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	add.w   d1, d0
	bmi.s   P14_loc_20D63A
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P14_loc_20D63A
	moveq   #$1, d0
	rts     
P14_loc_20D63A:
	moveq   #$0, d0
	rts     
