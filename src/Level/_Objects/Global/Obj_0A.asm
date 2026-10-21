; Object $0A - ObjSpring (from R11A, old ID $0A)
ObjSpring:
	cmpi.b  #$5, oSolidType(a0)
	beq.s   ObjSpring2
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	beq.s   P0A_loc_2097D2
	tst.b   oSprFlags(a0)
	bpl.s   P0A_loc_2097DA
P0A_loc_2097D2:
	move.w  ObjSpring_Index(pc, d0.w), d1
	jsr     ObjSpring_Index(pc, d1.w)
P0A_loc_2097DA:
	bsr.w   DrawObject
	move.l  #$ffff0000, d1
	move.w  $34(a0), d1
	beq.s   P0A_loc_20980C
	movea.l d1, a1
	move.w  $8(a1), oX(a0)
	move.w  $c(a1), oY(a0)
	move.b  $38(a0), d0
	ext.w   d0
	add.w   d0, oX(a0)
	move.b  $39(a0), d0
	ext.w   d0
	add.w   d0, oY(a0)
P0A_loc_20980C:
	move.w  $36(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.w   DeleteObject
	rts     
ObjSpring2:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjSpring2_Index(pc, d0.w), d0
	jmp     ObjSpring2_Index(pc, d0.w)
ObjSpring_Index:
	dc.w	ObjSpring_Init-ObjSpring_Index
	dc.w	ObjSpring_Main_Up-ObjSpring_Index
	dc.w	ObjSpring_Anim_Up-ObjSpring_Index
	dc.w	ObjSpring_Reset_Up-ObjSpring_Index
	dc.w	ObjSpring_Main_Side-ObjSpring_Index
	dc.w	ObjSpring_Anim_Side-ObjSpring_Index
	dc.w	ObjSpring_Reset_Side-ObjSpring_Index
	dc.w	ObjSpring_Main_Down-ObjSpring_Index
	dc.w	ObjSpring_Anim_Down-ObjSpring_Index
	dc.w	ObjSpring_Reset_Down-ObjSpring_Index
	dc.w	ObjSpring_Main_Diag-ObjSpring_Index
	dc.w	ObjSpring_Anim_Diag-ObjSpring_Index
	dc.w	ObjSpring_Reset_Diag-ObjSpring_Index
ObjSpring2_Index:
	dc.w	ObjSpring2_Init-ObjSpring2_Index
	dc.w	ObjSpring2_Main-ObjSpring2_Index
ObjSpring_Init:
	addq.b  #$2, oRoutine(a0)
	move.l  #$209bae, oMap(a0)
	move.w  #$520, oTile(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.w  oX(a0), $36(a0)
	move.b  #$4, oPriority(a0)
	move.b  oSubtype(a0), d0
	btst.l  #$2, d0
	beq.s   P0A_loc_20989C
	move.b  #$8, oRoutine(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.l  #$209bb4, oMap(a0)
	bra.s   P0A_loc_2098DE
P0A_loc_20989C:
	btst.l  #$3, d0
	beq.s   P0A_loc_2098CA
	move.b  #$14, oRoutine(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.l  #$209bfe, oMap(a0)
	move.l  d0, -(a7)
	moveq   #$f, d0
	jsr     SetObjectTileID.l
	move.l  (a7)+, d0
	bra.s   P0A_loc_2098DE
P0A_loc_2098CA:
	btst.b  #$1, oSprFlags(a0)
	beq.s   P0A_loc_2098DE
	move.b  #$e, oRoutine(a0)
	bset.b  #$1, oFlags(a0)
P0A_loc_2098DE:
	btst.l  #$1, d0
	beq.s   P0A_loc_2098EA
	bset.b  #$5, oTile(a0)
P0A_loc_2098EA:
	andi.w  #$2, d0
	move.w  ObjSpring_Speeds(pc, d0.w), $30(a0)
	rts     
ObjSpring_Main_Up:
	tst.b   oSprFlags(a0)
	bpl.s   P0A_loc_209916
	lea     objects.w, a1
	bsr.s   ObjSpring_SolidObject
	bne.s   P0A_loc_209918
P0A_loc_209916:
	rts     
P0A_loc_209918:
	move.b  #$4, oRoutine(a0)
	addq.w  #$8, $c(a1)
	move.w  $30(a0), $12(a1)
	bset.b  #$1, $22(a1)
	bclr.b  #$3, $22(a1)
	move.b  #$10, $1c(a1)
	bclr.b  #$3, oFlags(a0)
	move.w  #$98, d0
	jmp     PlayFMSound.l
ObjSpring_Anim_Up:
	lea     Ani_Spring.l, a1
	bra.w   AnimateObject
ObjSpring_Reset_Up:
	bclr.b  #$3, oFlags(a0)
	move.b  #$1, oPrevAnim(a0)
	subq.b  #$4, oRoutine(a0)
	move.b  #$0, oMapFrame(a0)
	rts     
ObjSpring_Main_Side:
	tst.b   oSprFlags(a0)
	bpl.s   P0A_loc_20998E
	lea     objects.w, a1
	bsr.s   ObjSpring_SolidObject2
	btst.b  #$5, oFlags(a0)
	bne.s   P0A_loc_209990
P0A_loc_20998E:
	rts     
P0A_loc_209990:
	move.b  #$a, oRoutine(a0)
	move.w  $30(a0), $10(a1)
	addq.w  #$8, $8(a1)
	bset.b  #$0, $22(a1)
	btst.b  #$0, oFlags(a0)
	bne.s   P0A_loc_2099BE
	subi.w  #$10, $8(a1)
	neg.w   $10(a1)
	bclr.b  #$0, $22(a1)
P0A_loc_2099BE:
	move.w  #$f, $3e(a1)
	move.w  $10(a1), $14(a1)
	btst.b  #$2, $22(a1)
	bne.s   P0A_loc_2099D8
	move.b  #$0, $1c(a1)
P0A_loc_2099D8:
	clr.b   $26(a1)
	bclr.b  #$5, oFlags(a0)
	bclr.b  #$5, $22(a1)
	move.w  #$98, d0
	jmp     PlayFMSound.l
ObjSpring_Anim_Side:
	lea     Ani_Spring.l, a1
	bra.w   AnimateObject
ObjSpring_Reset_Side:
	move.b  #$1, oPrevAnim(a0)
	subq.b  #$4, oRoutine(a0)
	move.b  #$0, oMapFrame(a0)
	rts     
ObjSpring_Main_Down:
	tst.b   oSprFlags(a0)
	bpl.s   P0A_loc_209A2A
	lea     objects.w, a1
	bsr.s   ObjSpring_SolidObject3
	bne.s   P0A_loc_209A2C
P0A_loc_209A2A:
	rts     
P0A_loc_209A2C:
	move.b  #$10, oRoutine(a0)
	subq.w  #$8, $c(a1)
	move.w  $30(a0), $12(a1)
	neg.w   $12(a1)
	bset.b  #$1, $22(a1)
	bclr.b  #$3, $22(a1)
	bclr.b  #$3, oFlags(a0)
	move.w  #$98, d0
	jsr     PlayFMSound.l
ObjSpring_Anim_Down:
	lea     Ani_Spring.l, a1
	bra.w   AnimateObject
ObjSpring_Reset_Down:
	move.b  #$1, oPrevAnim(a0)
	subq.b  #$4, oRoutine(a0)
	move.b  #$0, oMapFrame(a0)
	rts     
ObjSpring_Main_Diag:
	tst.b   oSprFlags(a0)
	bpl.s   P0A_loc_209A90
	lea     objects.w, a1
	bsr.w   ObjSpring_SolidObject
	bne.s   P0A_loc_209A92
	btst.b  #$5, oFlags(a0)
	bne.s   P0A_loc_209A92
P0A_loc_209A90:
	rts     
P0A_loc_209A92:
	move.b  #$16, oRoutine(a0)
	moveq   #$0, d0
	move.b  #$e0, d0
	jsr     CalcSine.l
	move.w  $30(a0), d2
	neg.w   d2
	mulu.w  d2, d0
	mulu.w  d2, d1
	lsr.l   #$8, d0
	lsr.l   #$8, d1
	move.w  d0, $12(a1)
	move.w  d1, $10(a1)
	addq.w  #$8, $c(a1)
	btst.b  #$1, oSprFlags(a0)
	beq.s   P0A_loc_209AD0
	subi.w  #$10, $c(a1)
	neg.w   $12(a1)
P0A_loc_209AD0:
	bclr.b  #$0, $22(a1)
	subq.w  #$8, $8(a1)
	btst.b  #$0, oFlags(a0)
	beq.s   P0A_loc_209AF2
	addi.w  #$10, $8(a1)
	bset.b  #$0, $22(a1)
	neg.w   $10(a1)
P0A_loc_209AF2:
	bset.b  #$1, $22(a1)
	bclr.b  #$3, $22(a1)
	bclr.b  #$5, $22(a1)
	bclr.b  #$3, oFlags(a0)
	bclr.b  #$5, oFlags(a0)
	move.w  #$98, d0
	jsr     PlayFMSound.l
ObjSpring_Anim_Diag:
	lea     Ani_Spring.l, a1
	bra.w   AnimateObject
ObjSpring_Reset_Diag:
	move.b  #$1, oPrevAnim(a0)
	subq.b  #$4, oRoutine(a0)
	move.b  #$0, oMapFrame(a0)
	rts     
	dc.w	$0004,$0010,$0000,$0000,$0202,$0202,$0202,$00FC
	dc.w	$0004,$0303,$0505,$0505,$0505,$03FC,$000C,$0017
	dc.w	$001D,$002D,$0033,$0039,$02F8,$0C00,$00F0,$000C
	dc.w	$0004,$F001,$000C,$0000,$F003,$E80C,$0000,$F0F0
	dc.w	$0500,$08F8,$000C,$000C,$F001,$F007,$0000,$F801
	dc.w	$F003,$0004,$F804,$F003,$0004,$10F8,$0900,$08F8
	dc.w	$F000,$0000,$F808,$0000,$03F8
ObjSpring2_Init:
	move.l  #$209bae, oMap(a0)
	move.w  #$8520, oTile(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.b  #$4, oPriority(a0)
	addq.b  #$2, oRoutine(a0)
ObjSpring2_Main:
	move.w  $FFFFD008.w, oX(a0)
	move.w  $FFFFD00C.w, oY(a0)
	jmp     DrawObject.l
ObjSpring_Speeds:
	dc.w	$F000,$F600
ObjSpring_SolidObject:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     SolidObject.l
ObjSpring_SolidObject2:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     SolidObject.l
ObjSpring_SolidObject3:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     BtmSolidObject.l
