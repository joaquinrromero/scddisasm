; Object $B2 - Obj2B_20EB4A (from R73C, old ID $2B)
Obj2B_20EB4A:
	tst.b   oRoutine(a0)
	bne.s   PB2_loc_20EB8E
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$450c, oTile(a0)
	move.l  #$20eca4, oMap(a0)
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	move.b  d0, oMapFrame(a0)
	add.w   d0, d0
	lea     PB2_dat_20EBB4(pc, d0.w), a1
	move.b  (a1)+, d0
	move.b  (a1), d1
	move.b  d0, oXRadius(a0)
	move.b  d0, oWidth(a0)
	move.b  d1, oYRadius(a0)
PB2_loc_20EB8E:
	tst.b   oLayer(a0)
	beq.s   PB2_loc_20EB98
	bsr.w   $20ebc0
PB2_loc_20EB98:
	lea     objects.w, a1
	jsr     SolidObject.l
	beq.s   PB2_loc_20EBA8
	clr.b   $20(a1)
PB2_loc_20EBA8:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PB2_dat_20EBB4:
	btst.b  d5, (a0)
	move.l  (a0), d0
	move.w  (a0), d0
	negx.b  (a0)
	btst.b  d5, -(a0)
	btst.b  d5, $38(a0, d0.l)
	dc.b	$00,$07,$F7,$A7		; ori.b #$a7, d7 (raw: not reproducible by assembler)
	beq.s   PB2_loc_20EC06
	tst.w   $2a(a0)
	bne.s   PB2_loc_20EBF0
	move.w  #$20, d0
	move.w  #$200, d1
	btst.b  #$7, oLayer(a0)
	beq.s   PB2_loc_20EBE2
	neg.w   d0
	neg.w   d1
PB2_loc_20EBE2:
	move.w  d1, oYVel(a0)
	move.w  oY(a0), $2a(a0)
	add.w   d0, $2a(a0)
PB2_loc_20EBF0:
	move.w  oYVel(a0), d0
	ext.l   d0
	lsl.l   #$8, d0
	add.l   d0, oY(a0)
	move.w  oY(a0), d0
	cmp.w   $2a(a0), d0
	beq.s   PB2_loc_20EC08
PB2_loc_20EC06:
	rts     
PB2_loc_20EC08:
	clr.w   $2a(a0)
	move.b  oLayer(a0), d0
	andi.b  #$f, d0
	subq.b  #$1, d0
	beq.w   PB2_loc_20EC88
	andi.b  #$f0, oLayer(a0)
	add.b   d0, oLayer(a0)
	btst.b  #$5, oLayer(a0)
	bne.s   PB2_loc_20EC86
	btst.b  #$4, oLayer(a0)
	beq.s   PB2_loc_20EC4E
	addq.b  #$1, oMapFrame(a0)
	cmpi.b  #$1, oMapFrame(a0)
	bne.s   PB2_loc_20EC46
	move.b  #$4, oMapFrame(a0)
PB2_loc_20EC46:
	subi.w  #$10, oY(a0)
	bra.s   PB2_loc_20EC66
PB2_loc_20EC4E:
	subq.b  #$1, oMapFrame(a0)
	cmpi.b  #$3, oMapFrame(a0)
	bne.s   PB2_loc_20EC60
	move.b  #$0, oMapFrame(a0)
PB2_loc_20EC60:
	addi.w  #$10, oY(a0)
PB2_loc_20EC66:
	moveq   #$0, d0
	move.b  oMapFrame(a0), d0
	add.w   d0, d0
	lea     PB2_dat_20EBB4.l, a1
	adda.w  d0, a1
	move.b  (a1)+, d0
	move.b  (a1), d1
	move.b  d0, oXRadius(a0)
	move.b  d0, oWidth(a0)
	move.b  d1, oYRadius(a0)
PB2_loc_20EC86:
	rts     
PB2_loc_20EC88:
	bclr.b  #$7, bossFlags.w
	btst.b  #$6, oLayer(a0)
	beq.s   PB2_loc_20EC9C
	clr.b   oLayer(a0)
	rts     
PB2_loc_20EC9C:
	addq.l  #$4, a7
	jmp     DeleteObject.l
PB2_loc_20ECA4:
	dc.w	$000C,$0012,$001D,$002D,$0042,$004D,$01F0,$0F00
	dc.w	$00F0,$02F0,$0F00,$00E0,$F00F,$0000,$0003,$F00F
	dc.w	$0000,$D0F0,$0F00,$00F0,$F00F,$0000,$1004,$F00F
	dc.w	$0000,$C0F0,$0F00,$00E0,$F00F,$0000,$00F0,$0F00
	dc.w	$0020,$02E0,$0F00,$00F0,$000F,$0000,$F003,$D00F
	dc.w	$0000,$F0F0,$0F00,$00F0,$100F,$0000,$F000
