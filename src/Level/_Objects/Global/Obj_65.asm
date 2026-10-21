; Object $65 - Obj34_20ED68 (from R41A, old ID $34)
P65_Obj34_20ED68:
	tst.b   oRoutine(a0)
	bne.s   P65_loc_20EDAC
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.w  #$446a, oTile(a0)
	move.l  #$20edd0, oMap(a0)
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	move.b  d0, oMapFrame(a0)
	add.w   d0, d0
	lea     P65_dat_20EDC2(pc, d0.w), a1
	move.b  (a1)+, d0
	move.b  (a1), d1
	move.b  d0, oXRadius(a0)
	move.b  d0, oWidth(a0)
	move.b  d1, oYRadius(a0)
P65_loc_20EDAC:
	lea     objects.w, a1
	jsr     SolidObject.l
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P65_dat_20EDC2:
	dc.w	$1010,$1010,$2010,$1020,$2020,$4010,$1040
P65_loc_20EDD0:
	dc.w	$000E,$0014,$001A,$0025,$0030,$0045,$005A,$01F0
	dc.w	$0F00,$00F0,$01F0,$0F00,$10F0,$02F0,$0F00,$00E0
	dc.w	$F00F,$0010,$0002,$E00F,$0010,$F000,$0F00,$00F0
	dc.w	$04E0,$0F00,$00E0,$E00F,$0010,$0000,$0F00,$10E0
	dc.w	$000F,$0000,$0004,$F00F,$0000,$C0F0,$0F00,$00E0
	dc.w	$F00F,$0010,$00F0,$0F00,$1020,$04C0,$0F00,$10F0
	dc.w	$E00F,$0010,$F000,$0F00,$00F0,$200F,$0010,$F000
