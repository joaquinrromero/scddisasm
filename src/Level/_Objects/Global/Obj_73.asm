; Object $73 - Obj3DPlant (from R71A, old ID $1D)
Obj3DPlant:
	lea     objects.w, a6
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  Obj3DPlant_Index(pc, d0.w), d0
	jsr     Obj3DPlant_Index(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
Obj3DPlant_Index:
	dc.w	P73_loc_20B844-Obj3DPlant_Index
	dc.w	P73_loc_20B888-Obj3DPlant_Index
	dc.w	P73_loc_20B910-Obj3DPlant_Index
	dc.w	P73_loc_20B91C-Obj3DPlant_Index
P73_loc_20B844:
	tst.b   oSubtype(a0)
	beq.s   P73_loc_20B850
	bset.b  #$1, oSprFlags(a0)
P73_loc_20B850:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$34d, oTile(a0)
	tst.b   layer.l
	bne.s   P73_loc_20B86E
	ori.b   #$80, oTile(a0)
P73_loc_20B86E:
	move.l  #$20b956, oMap(a0)
	move.b  #$18, oXRadius(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$18, oYRadius(a0)
P73_loc_20B888:
	tst.b   $2a(a0)
	beq.s   P73_loc_20B894
	subq.b  #$1, $2a(a0)
	bra.s   P73_loc_20B8E6
P73_loc_20B894:
	move.b  $17(a6), d0
	ext.w   d0
	move.b  oXRadius(a0), d1
	ext.w   d1
	add.w   d0, d1
	move.w  oX(a0), d0
	sub.w   $8(a6), d0
	add.w   d1, d0
	bmi.s   P73_loc_20B8E8
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P73_loc_20B8E8
	move.b  $16(a6), d0
	ext.w   d0
	move.b  oYRadius(a0), d1
	ext.w   d1
	add.w   d0, d1
	move.w  oY(a0), d0
	sub.w   $c(a6), d0
	add.w   d1, d0
	bmi.s   P73_loc_20B8E8
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P73_loc_20B8E8
	move.b  #$3c, $2a(a0)
	addq.b  #$2, oRoutine(a0)
	eori.b  #$1, layer.l
P73_loc_20B8E6:
	rts     
P73_loc_20B8E8:
	btst.b  #$7, oTile(a0)
	beq.s   P73_loc_20B8FA
	tst.b   layer.l
	bne.s   P73_loc_20B904
	rts     
P73_loc_20B8FA:
	tst.b   layer.l
	beq.s   P73_loc_20B904
	rts     
P73_loc_20B904:
	move.b  #$3c, $2a(a0)
	addq.b  #$2, oRoutine(a0)
	rts     
P73_loc_20B910:
	lea     P73_loc_20B948.l, a1
	jmp     AnimateObject.l
P73_loc_20B91C:
	ori.w   #$8000, oTile(a0)
	move.b  #$4, oPriority(a0)
	tst.b   layer.l
	beq.s   P73_loc_20B93C
	andi.w  #$7fff, oTile(a0)
	move.b  #$0, oPriority(a0)
P73_loc_20B93C:
	move.b  #$0, oAnimFrame(a0)
	subq.b  #$4, oRoutine(a0)
	rts     
P73_loc_20B948:
	dc.w	$0002,$0400,$0102,$0304,$0302,$0100,$FC00
P73_loc_20B956:
	dc.w	$000A,$002A,$004A,$008A,$006A,$06F0,$0700,$00F0
	dc.w	$F007,$0800,$00F8,$0300,$10E8,$1004,$0014,$F0F8
	dc.w	$0308,$1010,$1004,$0814,$0000,$06F4,$0600,$08F0
	dc.w	$F406,$0808,$00F8,$0300,$10E8,$1004,$0014,$F0F8
	dc.w	$0308,$1010,$1004,$0814,$0000,$06FC,$0400,$0EF0
	dc.w	$FC04,$080E,$00F8,$0300,$10E8,$1004,$0014,$F0F8
	dc.w	$0308,$1010,$1004,$0814,$0000,$06F0,$0710,$00F0
	dc.w	$F007,$1800,$00F8,$0300,$10E8,$1004,$0014,$F0F8
	dc.w	$0308,$1010,$1004,$0814,$0000,$06F4,$0610,$08F0
	dc.w	$F406,$1808,$00F8,$0300,$10E8,$1004,$0014,$F0F8
	dc.w	$0308,$1010,$1004,$0814,$0000
