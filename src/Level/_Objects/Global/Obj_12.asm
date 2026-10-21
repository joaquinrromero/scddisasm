; Object $12 - ObjFloatBlock (from R11A, old ID $12)
ObjFloatBlock:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P12_dat_20A2C0(pc, d0.w), d0
	jsr     P12_dat_20A2C0(pc, d0.w)
	move.w  oX(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.w   DeleteObject
	rts     
P12_dat_20A2C0:
	dc.w	ObjFloatBlock_Init-P12_dat_20A2C0
	dc.w	ObjFloatBlock_Main-P12_dat_20A2C0
	dc.w	ObjFloatBlock_Fall-P12_dat_20A2C0
	dc.w	ObjFloatBlock_Appear-P12_dat_20A2C0
	dc.w	ObjFloatBlock_Visible-P12_dat_20A2C0
	dc.w	ObjFloatBlock_Vanish-P12_dat_20A2C0
	dc.w	ObjFloatBlock_Reset-P12_dat_20A2C0
ObjFloatBlock_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.l  #$20a408, oMap(a0)
	moveq   #$5, d0
	jsr     SetObjectTileID.l
	move.b  #$1, oPriority(a0)
	move.b  #$c, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.b  #$5, oMapFrame(a0)
ObjFloatBlock_Main:
	bsr.w   ObjFloatBlock_TopSolid
	tst.b   timeZone.l
	beq.s   P12_loc_20A33A
	cmpi.b  #$2, timeZone.l
	bne.s   P12_loc_20A320
	btst.b  #$3, oFlags(a0)
	bne.s   P12_loc_20A340
	bra.s   P12_loc_20A33A
P12_loc_20A320:
	move.b  #$0, oMapFrame(a0)
	btst.b  #$3, oFlags(a0)
	beq.s   P12_loc_20A33A
	move.b  #$6, oRoutine(a0)
	move.b  #$1, oAnim(a0)
P12_loc_20A33A:
	jmp     DrawObject.l
P12_loc_20A340:
	addq.b  #$2, oRoutine(a0)
ObjFloatBlock_Fall:
	bsr.w   ObjFloatBlock_TopSolid
	addq.w  #$2, oY(a0)
	move.w  cameraY.w, d0
	addi.w  #$e0, d0
	cmp.w   oY(a0), d0
	bcc.s   P12_loc_20A360
	jmp     DeleteObject.l
P12_loc_20A360:
	jmp     DrawObject.l
ObjFloatBlock_Appear:
	bsr.w   ObjFloatBlock_TopSolid
	btst.b  #$3, oFlags(a0)
	bne.s   P12_loc_20A37A
	move.b  #$2, oRoutine(a0)
	rts     
P12_loc_20A37A:
	lea     Ani_FloatBlock.l, a1
	bsr.w   AnimateObject
	jmp     DrawObject.l
ObjFloatBlock_Visible:
	move.b  #$0, oAnim(a0)
	bsr.w   ObjFloatBlock_TopSolid
	btst.b  #$3, oFlags(a0)
	bne.s   P12_loc_20A3A8
	addq.b  #$2, oRoutine(a0)
	move.b  #$2, oAnim(a0)
	rts     
P12_loc_20A3A8:
	lea     Ani_FloatBlock.l, a1
	bsr.w   AnimateObject
	jmp     DrawObject.l
ObjFloatBlock_Vanish:
	bsr.w   ObjFloatBlock_TopSolid
	lea     Ani_FloatBlock.l, a1
	bsr.w   AnimateObject
	jmp     DrawObject.l
ObjFloatBlock_Reset:
	move.b  #$2, oRoutine(a0)
	rts     
ObjFloatBlock_TopSolid:
	lea     objects.w, a1
	bsr.w   P12_sub_20A3DC
P12_sub_20A3DC:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     TopSolidObject.l
