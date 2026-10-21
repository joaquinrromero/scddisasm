; Object $3E - ObjPataBata (from R11A, old ID $3E)
ObjPataBata:
	jsr     DestroyOnGoodFuture.l
	tst.b   oRoutine(a0)
	bne.w   ObjPataBata_Main
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$2a, oColType(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  oX(a0), $2a(a0)
	move.w  oY(a0), $2c(a0)
	move.w  #$8000, $2e(a0)
	moveq   #$1, d0
	jsr     SetObjectTileID.l
	tst.b   oSubtype(a0)
	bne.s   P3E_loc_20B492
	move.l  #$ffff8000, d0
	move.w  #$fe00, d1
	moveq   #$3, d2
	moveq   #$0, d3
	lea     MapSpr_PataBata1(pc), a1
	bra.s   P3E_loc_20B4A4
P3E_loc_20B492:
	move.l  #$ffffc000, d0
	move.w  #$ff00, d1
	moveq   #$4, d2
	moveq   #$1, d3
	lea     MapSpr_PataBata2(pc), a1
P3E_loc_20B4A4:
	move.l  d0, $30(a0)
	move.w  d1, $36(a0)
	move.w  d2, $38(a0)
	move.b  d3, oAnim(a0)
	move.l  a1, oMap(a0)
ObjPataBata_Main:
	move.l  $30(a0), d0
	add.l   d0, oX(a0)
	move.w  oX(a0), d0
	sub.w   $2a(a0), d0
	bpl.s   P3E_loc_20B4CC
	neg.w   d0
P3E_loc_20B4CC:
	cmpi.w  #$80, d0
	blt.s   P3E_loc_20B4EE
	neg.l   $30(a0)
	move.l  $30(a0), d0
	add.l   d0, oX(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	clr.w   $34(a0)
P3E_loc_20B4EE:
	move.w  $36(a0), d0
	add.w   d0, $34(a0)
	move.b  $34(a0), d0
	jsr     CalcSine.l
	swap    d0
	move.w  $38(a0), d1
	asr.l   d1, d0
	add.l   $2c(a0), d0
	move.l  d0, oY(a0)
	lea     Ani_PataBata(pc), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	move.w  $2a(a0), d0
	jmp     CheckObjDespawn2.l
