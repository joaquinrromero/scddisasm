; Object $15 - ObjCapsule (from R13C, old ID $15)
ObjCapsule:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P15_dat_20AF50(pc, d0.w), d0
	jsr     P15_dat_20AF50(pc, d0.w)
	tst.b   oRoutine(a0)
	beq.s   P15_loc_20AF4E
	cmpi.b  #$a, oRoutine(a0)
	beq.s   P15_loc_20AF48
	cmpi.b  #$6, oRoutine(a0)
	bcc.s   P15_loc_20AF4E
P15_loc_20AF48:
	jmp     DrawObject.l
P15_loc_20AF4E:
	rts     
P15_dat_20AF50:
	dc.w	ObjCapsule_Init-P15_dat_20AF50
	dc.w	ObjCapsule_Main-P15_dat_20AF50
	dc.w	ObjCapsule_Explode-P15_dat_20AF50
	dc.w	StartResults-P15_dat_20AF50
	dc.w	ResultsActive-P15_dat_20AF50
	dc.w	ObjCapsule_Seed-P15_dat_20AF50
ObjCapsule_Init:
	ori.b   #$4, oSprFlags(a0)
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oPriority(a0)
	move.l  #$23c942, oMap(a0)
	move.w  #$2481, oTile(a0)
	move.b  #$20, oXRadius(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$18, oYRadius(a0)
ObjCapsule_Main:
	lea     Ani_FlowerCapsule.l, a1
	jsr     AnimateObject.l
	lea     objects.w, a6
	bsr.w   ObjCapsule_CheckHit
	beq.s   P15_loc_20AFEE
	clr.b   updateHUDTime.l
	move.b  #$2, oMapFrame(a0)
	move.b  #$78, $2a(a0)
	addq.b  #$2, oRoutine(a0)
	move.w  $FFFFD008.w, d0
	move.b  $FFFFD017.w, d1
	ext.w   d1
	addi.w  #$20, d1
	sub.w   oX(a0), d0
	add.w   d1, d0
	bmi.s   P15_loc_20AFE2
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P15_loc_20AFE2
	move.w  $FFFFD012.w, d0
	neg.w   d0
	asr.w   #$2, d0
	move.w  d0, $FFFFD012.w
	rts     
P15_loc_20AFE2:
	move.w  $FFFFD010.w, d0
	neg.w   d0
	asr.w   #$2, d0
	move.w  d0, $FFFFD010.w
P15_loc_20AFEE:
	rts     
ObjCapsule_Explode:
	subq.b  #$1, $2a(a0)
	bmi.s   P15_loc_20B04C
	move.b  $2a(a0), d0
	move.b  d0, d1
	andi.b  #$3, d1
	bne.s   P15_loc_20B05A
	lsr.w   #$2, d0
	andi.w  #$7, d0
	add.w   d0, d0
	lea     P15_dat_20B05C(pc, d0.w), a2
	jsr     FindObjSlot.l
	bne.s   P15_loc_20B05A
	move.w  #$9e, d0
	jsr     PlayFMSound.l
	dc.b	$13,$7C,$00,$18,$00,$00		; move.b #$18, $0(a1) (raw: not reproducible by assembler)
	move.b  #$1, $25(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  (a2), d0
	ext.w   d0
	add.w   d0, $8(a1)
	move.b  $1(a2), d0
	ext.w   d0
	add.w   d0, $c(a1)
	rts     
P15_loc_20B04C:
	bsr.w   ObjCapsule_SpawnSeeds
	addq.b  #$2, oRoutine(a0)
	move.b  #$3c, $2a(a0)
P15_loc_20B05A:
	rts     
ObjCapsule_Seed:
	lea     Ani_FlowerCapsule.l, a1
	jsr     AnimateObject.l
	jsr     ObjMoveGrv.l
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P15_loc_20B114
	move.b  #$1f, oID(a0)
	move.b  #$1, oSubtype(a0)
	move.b  #$0, oRoutine(a0)
P15_loc_20B114:
	rts     
ObjCapsule_CheckHit:
	btst.b  #$2, $22(a6)
	beq.s   P15_loc_20B15A
	move.b  $17(a6), d1
	ext.w   d1
	addi.w  #$20, d1
	move.w  $8(a6), d0
	sub.w   oX(a0), d0
	add.w   d1, d0
	bmi.s   P15_loc_20B15A
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P15_loc_20B15A
	move.b  $16(a6), d1
	ext.w   d1
	addi.w  #$1c, d1
	move.w  $c(a6), d0
	sub.w   oY(a0), d0
	add.w   d1, d0
	bmi.s   P15_loc_20B15A
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P15_loc_20B15A
	moveq   #$1, d0
	rts     
P15_loc_20B15A:
	moveq   #$0, d0
	rts     
P15_dat_20B05C:
	dc.w	$0000,$20F8,$E000,$E8F8,$1808,$F008,$1008,$F8F8
ObjCapsule_SpawnSeeds:
	moveq   #$0, d0
	move.b  $20e32c.l, d0
	move.l  d7, d6
	jsr     LoadPalette.l
	move.l  d6, d7
	moveq   #$6, d6
	moveq   #$0, d1
P15_loc_20B082:
	jsr     FindObjSlot.l
	bne.s   P15_loc_20B0CE
	dc.b	$13,$7C,$00,$15,$00,$00		; move.b #$15, $0(a1) (raw: not reproducible by assembler)
	ori.b   #$4, $1(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  #$a, $24(a1)
	move.l  #$23c942, $4(a1)
	move.w  #$2481, $2(a1)
	move.b  #$1, $1c(a1)
	move.w  #$fa00, $12(a1)
	move.w  P15_dat_20B0D0(pc, d1.w), $10(a1)
	addq.w  #$2, d1
	dbra    d6, P15_loc_20B082
P15_loc_20B0CE:
	rts     
P15_dat_20B0D0:
	dc.w	$0000,$FF80,$0080,$FF00,$0100,$FE80,$0180,$FE00
	dc.w	$0200,$FD80,$0280
