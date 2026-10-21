; Object $22 - ObjTamabboh (from R11A, old ID $22)
ObjTamabboh:
	cmpi.b  #$1, oSubtype(a0)
	beq.w   ObjTamabbohMissile
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjTamabboh_Index(pc, d0.w), d0
	jsr     ObjTamabboh_Index(pc, d0.w)
	jsr     DrawObject.l
	move.w  $2a(a0), d0
	jmp     CheckObjDespawn2.l
ObjTamabbohMissile:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P22_dat_20B9C8(pc, d0.w), d0
	jsr     P22_dat_20B9C8(pc, d0.w)
	jmp     DrawObject.l
ObjTamabboh_Index:
	dc.w	ObjTamabboh_Init-ObjTamabboh_Index
	dc.w	ObjTamabboh_Position-ObjTamabboh_Index
	dc.w	ObjTamabboh_Main-ObjTamabboh_Index
	dc.w	ObjTamabboh_Wait1-ObjTamabboh_Index
	dc.w	ObjTamabboh_Wait2-ObjTamabboh_Index
	dc.w	ObjTamabboh_Fire-ObjTamabboh_Index
P22_dat_20B9C8:
	dc.w	ObjTamabbohMissile_Init-P22_dat_20B9C8
	dc.w	ObjTamabbohMissile_Main-P22_dat_20B9C8
ObjTamabboh_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.b  #$2c, oColType(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$f, oYRadius(a0)
	move.w  oX(a0), $2a(a0)
	moveq   #$4, d0
	jsr     SetObjectTileID.l
	tst.b   oSubtype(a0)
	bne.s   P22_loc_20B7F8
	lea     MapSpr_Tamabboh1(pc), a1
	lea     Ani_Tamabboh1(pc), a2
	move.l  #$ffff6000, d0
	bra.s   P22_loc_20B806
P22_loc_20B7F8:
	lea     MapSpr_Tamabboh2(pc), a1
	lea     Ani_Tamabboh2(pc), a2
	move.l  #$ffffb000, d0
P22_loc_20B806:
	move.l  a1, oMap(a0)
	move.l  a2, $30(a0)
	move.l  d0, $2c(a0)
ObjTamabboh_Position:
	move.l  #$10000, d0
	add.l   d0, oY(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P22_loc_20B82A
	addq.b  #$2, oRoutine(a0)
P22_loc_20B82A:
	rts     
ObjTamabboh_Main:
	tst.w   debugMode.l
	bne.s   P22_loc_20B84E
	tst.b   oSubtype(a0)
	bne.s   P22_loc_20B84E
	tst.w   $34(a0)
	beq.s   P22_loc_20B846
	subq.w  #$1, $34(a0)
	bra.s   P22_loc_20B84E
P22_loc_20B846:
	lea     objects.w, a1
	bsr.s   ObjTamabboh_CheckInRange
	bcs.s   P22_loc_20B89A
P22_loc_20B84E:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	move.w  oX(a0), d0
	sub.w   $2a(a0), d0
	bpl.s   P22_loc_20B862
	neg.w   d0
P22_loc_20B862:
	cmpi.w  #$80, d0
	bge.s   P22_loc_20B888
	jsr     ObjGetFloorDist.l
	cmpi.w  #$fff9, d1
	blt.s   P22_loc_20B888
	cmpi.w  #$7, d1
	bgt.s   P22_loc_20B888
	add.w   d1, oY(a0)
	movea.l $30(a0), a1
	jmp     AnimateObject.l
P22_loc_20B888:
	neg.l   $2c(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	bra.s   ObjTamabboh_Main
P22_loc_20B89A:
	addq.b  #$2, oRoutine(a0)
	rts     
ObjTamabboh_Wait1:
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, oAnim(a0)
ObjTamabboh_Wait2:
	movea.l $30(a0), a1
	jmp     AnimateObject.l
ObjTamabboh_Fire:
	move.b  #$4, oRoutine(a0)
	move.b  #$0, oAnim(a0)
	move.w  #$78, $34(a0)
	tst.b   oSubtype(a0)
	bne.s   P22_loc_20B91E
	jsr     FindObjSlot.l
	bne.s   P22_loc_20B91E
	tst.b   oSprFlags(a0)
	bpl.s   P22_loc_20B90A
	move.w  #$a0, d0
	jsr     PlayFMSound.l
P22_loc_20B90A:
	bsr.s   ObjTamabboh_InitMissile
	sf.b    $3f(a1)
	jsr     FindObjSlot.l
	bne.s   P22_loc_20B91E
	bsr.s   ObjTamabboh_InitMissile
	st.b    $3f(a1)
P22_loc_20B91E:
	rts     
ObjTamabbohMissile_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$ad, oColType(a0)
	move.b  #$8, oXRadius(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.l  #$20ba7e, oMap(a0)
	move.l  #$0, $32(a0)
	move.l  #$2000, $36(a0)
	tst.b   $3f(a0)
	bne.s   P22_loc_20BA1A
	move.l  #$20000, d0
	move.l  #$fffc0000, d1
	bra.s   P22_loc_20BA26
P22_loc_20BA1A:
	move.l  #$fffe0000, d0
	move.l  #$fffc0000, d1
P22_loc_20BA26:
	move.l  d0, $2a(a0)
	move.l  d1, $2e(a0)
	rts     
ObjTamabbohMissile_Main:
	tst.b   oSprFlags(a0)
	bmi.s   P22_loc_20BA3C
	jmp     DeleteObject.l
P22_loc_20BA3C:
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P22_loc_20BA4C
	jmp     DeleteObject.l
P22_loc_20BA4C:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	move.l  $2e(a0), d0
	add.l   d0, oY(a0)
	move.l  $32(a0), d0
	add.l   d0, $2a(a0)
	move.l  $36(a0), d0
	add.l   d0, $2e(a0)
	lea     Ani_TamabbohMissile(pc), a1
	jmp     AnimateObject.l
ObjTamabboh_CheckInRange:
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	subi.w  #$ffb0, d0
	subi.w  #$a0, d0
	bcc.s   P22_loc_20B8C4
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	move.w  d0, d1
	subi.w  #$ffb0, d1
	subi.w  #$a0, d1
P22_loc_20B8C4:
	rts     
ObjTamabboh_InitMissile:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$1, $28(a1)
	move.w  oTile(a0), $2(a1)
	move.b  oPriority(a0), $18(a1)
	addq.b  #$1, $18(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$a, $c(a1)
	rts     
