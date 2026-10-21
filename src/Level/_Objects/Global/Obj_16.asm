; Object $16 - ObjGoalPost (from R11A, old ID $16)
ObjGoalPost:
	lea     objects.w, a6
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P16_dat_20D666(pc, d0.w), d0
	jsr     P16_dat_20D666(pc, d0.w)
	cmpi.b  #$2, act.l
	beq.s   P16_loc_20D660
	jsr     DrawObject.l
P16_loc_20D660:
	jmp     CheckObjDespawn.l
P16_dat_20D666:
	dc.w	ObjGoalPost_Init-P16_dat_20D666
	dc.w	ObjGoalPost_Main-P16_dat_20D666
	dc.w	ObjGoalPost_Done-P16_dat_20D666
ObjGoalPost_Init:
	cmpi.w  #$201, zoneAct.l
	bne.s   P16_loc_20D69C
	cmpi.b  #$1, timeZone.l
	bne.s   P16_loc_20D69C
	tst.b   oSubtype(a0)
	bne.s   P16_loc_20D694
	move.b  #$1, oSubtype(a0)
	moveq   #$13, d0
	jmp     LoadPLC.l
P16_loc_20D694:
	tst.l   plcBuffer.w
	beq.s   P16_loc_20D69C
	rts     
P16_loc_20D69C:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.l  #$23f228, oMap(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$20, oYRadius(a0)
	move.b  #$5, oMapFrame(a0)
	bsr.w   ObjGoalPost_SetBaseTile
ObjGoalPost_Main:
	move.w  $c(a6), d0
	sub.w   oY(a0), d0
	addi.w  #$80, d0
	bmi.s   P16_loc_20D714
	cmpi.w  #$100, d0
	bcc.s   P16_loc_20D714
	move.w  $8(a6), d0
	cmp.w   oX(a0), d0
	bcs.s   P16_loc_20D714
	addq.b  #$2, oRoutine(a0)
	move.w  cameraX.w, leftBound.w
	move.w  cameraX.w, destLeftBound.w
	clr.w   timeWarpTimer.w
	clr.b   timeWarpDir.w
	clr.b   timeWarp.l
	moveq   #$12, d0
	jmp     LoadPLC.l
P16_loc_20D714:
	rts     
ObjGoalPost_Done:
	rts     
ObjGoalPost_SetBaseTile:
	moveq   #$0, d0
	move.w  zoneAct.l, d0
	lsl.b   #$7, d0
	lsr.w   #$4, d0
	move.b  timeZone.l, d1
	cmpi.b  #$2, d1
	bne.s   P16_loc_20D736
	add.b   goodFuture.l, d1
P16_loc_20D736:
	add.b   d1, d1
	add.b   d1, d0
	move.w  P16_dat_20D752(pc, d0.w), oTile(a0)
	cmpi.b  #$3, zoneAct.l
	beq.s   P16_loc_20D750
	ori.w   #$8000, oTile(a0)
P16_loc_20D750:
	rts     
P16_dat_20D752:
	dc.w	$035A,$04F7,$04F7,$04F7,$0381,$04F7,$04F7,$04F7
	dc.w	$0300,$0300,$0300,$0300,$0300,$0300,$0300,$0300
	dc.w	$04F2,$04F2,$04F2,$04F2,$04F2,$04F2,$04F2,$04F2
	dc.w	$02BA,$02CC,$02B3,$02B1,$02BA,$02CC,$02B3,$02B1
	dc.w	$0254,$022C,$0294,$0238,$0278,$028A,$02BC,$0298
	dc.w	$03AE,$03AE,$03AE,$03AE,$03AE,$03AE,$03AE,$03AE
	dc.w	$0220,$0221,$024C,$0236,$023E,$024A,$025D,$0246
