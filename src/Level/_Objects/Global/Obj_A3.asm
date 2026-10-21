; Object $A3 - ObjRobotGenerator (from R71A, old ID $29)
ObjRobotGenerator:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjRobotGenerator_Index(pc, d0.w), d0
	jsr     ObjRobotGenerator_Index(pc, d0.w)
	jsr     DrawObject.l
	cmpi.b  #$2, oRoutine(a0)
	bgt.s   PA3_loc_20EDB2
	jmp     CheckObjDespawn.l
PA3_loc_20EDB2:
	rts     
ObjRobotGenerator_Index:
	dc.w	ObjRobotGenerator_Init-ObjRobotGenerator_Index
	dc.w	ObjRobotGenerator_Main-ObjRobotGenerator_Index
	dc.w	ObjRobotGenerator_Exploding-ObjRobotGenerator_Index
	dc.w	ObjRobotGenerator_BreakDown-ObjRobotGenerator_Index
ObjRobotGenerator_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.b  #$22, oXRadius(a0)
	move.b  #$22, oWidth(a0)
	move.b  #$20, oYRadius(a0)
	lea     ObjRobotGenerator_BaseTileList(pc), a1
	moveq   #$0, d0
	move.b  act.l, d0
	asl.w   #$2, d0
	add.b   timeZone.l, d0
	add.w   d0, d0
	move.w  (a1, d0.w), oTile(a0)
	move.l  #$20ef64, oMap(a0)
	move.l  #$20f1a2, $2c(a0)
	move.w  oY(a0), $30(a0)
	move.w  #$4, $2a(a0)
	move.w  #$1, $32(a0)
	moveq   #$0, d0
	tst.b   goodFuture.l
	bne.s   PA3_loc_20EE28
	addq.b  #$2, d0
PA3_loc_20EE28:
	tst.b   timeZone.l
	bne.s   PA3_loc_20EE32
	addq.b  #$1, d0
PA3_loc_20EE32:
	move.b  d0, oMapFrame(a0)
	tst.b   goodFuture.l
	bne.s   ObjRobotGenerator_Main
	tst.b   timeZone.l
	bne.s   ObjRobotGenerator_Main
	move.b  #$fa, oColType(a0)
	subi.w  #$10, oY(a0)
ObjRobotGenerator_Main:
	tst.b   goodFuture.l
	bne.s   PA3_loc_20EEBA
	tst.b   timeZone.l
	bne.s   PA3_loc_20EEBA
	bsr.w   ObjRobotGenerator_Float
	tst.b   oColStatus(a0)
	beq.s   PA3_loc_20EEA6
	clr.w   oColType(a0)
	clr.w   $2a(a0)
	move.b  #$7, oMapFrame(a0)
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, goodFuture.l
	move.l  #$96, d0
	jsr     AddPoints.l
	lea     objects.w, a1
	jsr     SolidObject.l
	beq.s   PA3_loc_20EEA4
	jsr     GetOffObject.l
PA3_loc_20EEA4:
	rts     
PA3_loc_20EEA6:
	lea     objects.w, a1
	jsr     SolidObject.l
	lea     Ani_RobotGenerator(pc), a1
	jmp     AnimateObject.l
PA3_loc_20EEBA:
	rts     
ObjRobotGenerator_Exploding:
	movea.l $2c(a0), a6
	move.b  (a6)+, d0
	bmi.s   PA3_loc_20EF0E
	addq.b  #$1, $2a(a0)
	cmp.b   $2a(a0), d0
	bne.s   PA3_loc_20EF0C
	move.b  (a6)+, d5
	move.b  (a6)+, d6
	move.l  a6, $2c(a0)
	ext.w   d5
	ext.w   d6
	jsr     FindObjSlot.l
	bne.s   PA3_loc_20EF0C
	dc.b	$13,$7C,$00,$18,$00,$00		; move.b #$18, $0(a1) (raw: not reproducible by assembler)
	move.b  #$1, $25(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	add.w   d5, $8(a1)
	add.w   d6, $c(a1)
	move.w  #$9e, d0
	jsr     PlayFMSound.l
PA3_loc_20EF0C:
	rts     
PA3_loc_20EF0E:
	addq.b  #$2, oRoutine(a0)
	move.b  #$8, $2a(a0)
	rts     
ObjRobotGenerator_BreakDown:
	subq.b  #$1, $2a(a0)
	bne.s   PA3_loc_20EF34
	subq.b  #$6, oRoutine(a0)
	move.w  $30(a0), oY(a0)
	move.w  #$d9, d0
	jmp     PlayFMSound.l
PA3_loc_20EF34:
	rts     
ObjRobotGenerator_BaseTileList:
	dc.w	$03AE,$03AE,$0000,$0000,$03AE,$03AE,$0000,$0000
	dc.w	$0000,$0000,$0000
ObjRobotGenerator_Float:
	addq.w  #$1, $2a(a0)
	move.w  $2a(a0), d0
	andi.w  #$7, d0
	bne.s   PA3_loc_20EF4C
	move.w  $32(a0), d0
	add.w   d0, oY(a0)
PA3_loc_20EF4C:
	move.w  $2a(a0), d0
	andi.w  #$1f, d0
	bne.s   PA3_loc_20EF5A
	neg.w   $32(a0)
PA3_loc_20EF5A:
	rts     
