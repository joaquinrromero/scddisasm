; Object $3F - ObjAnton (from R11A, old ID $3F)
ObjAnton:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjAnton_Index(pc, d0.w), d0
	jsr     ObjAnton_Index(pc, d0.w)
	jsr     DrawObject.l
	move.w  $2e(a0), d0
	jmp     CheckObjDespawn2.l
ObjAnton_Index:
	dc.w	ObjAnton_Init-ObjAnton_Index
	dc.w	ObjAnton_Place-ObjAnton_Index
	dc.w	ObjAnton_Main-ObjAnton_Index
ObjAnton_Init:
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.l  #$20b3b8, oMap(a0)
	move.b  #$18, oXRadius(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$13, oYRadius(a0)
	move.b  #$29, oColType(a0)
	move.w  oX(a0), $2e(a0)
	moveq   #$2, d0
	jsr     SetObjectTileID.l
	tst.b   oSubtype(a0)
	bne.s   P3F_loc_20B336
	move.l  #$ffff0000, d0
	moveq   #$0, d1
	bra.s   P3F_loc_20B33E
P3F_loc_20B336:
	move.l  #$ffff8000, d0
	moveq   #$1, d1
P3F_loc_20B33E:
	move.l  d0, $2a(a0)
	move.b  d1, oAnim(a0)
ObjAnton_Place:
	move.l  #$10000, d0
	add.l   d0, oY(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P3F_loc_20B35E
	addq.b  #$2, oRoutine(a0)
P3F_loc_20B35E:
	rts     
ObjAnton_Main:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	move.w  oX(a0), d0
	sub.w   $2e(a0), d0
	bpl.s   P3F_loc_20B374
	neg.w   d0
P3F_loc_20B374:
	cmpi.w  #$80, d0
	bge.s   P3F_loc_20B39A
	jsr     ObjGetFloorDist.l
	cmpi.w  #$fff9, d1
	blt.s   P3F_loc_20B39A
	cmpi.w  #$7, d1
	bgt.s   P3F_loc_20B39A
	add.w   d1, oY(a0)
	lea     Ani_Anton(pc), a1
	jmp     AnimateObject.l
P3F_loc_20B39A:
	neg.l   $2a(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	bra.s   ObjAnton_Main
