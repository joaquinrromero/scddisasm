; Object $94 - Obj28_20E4A2 (from R51A, old ID $28)
P94_Obj28_20E4A2:
	tst.b   oLayer(a0)
	bne.w   P94_loc_20E60A
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P94_dat_20E4B8(pc, d0.w), d0
	jmp     P94_dat_20E4B8(pc, d0.w)
P94_dat_20E4B8:
	dc.w	P94_loc_20E4C0-P94_dat_20E4B8
	dc.w	P94_loc_20E50A-P94_dat_20E4B8
	dc.w	P94_loc_20E548-P94_dat_20E4B8
	dc.w	P94_loc_20E562-P94_dat_20E4B8
P94_loc_20E4C0:
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.l  #$20e672, oMap(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$11, oYRadius(a0)
	move.w  #$4350, d0
	cmpi.b  #$2, act.l
	bne.s   P94_loc_20E4F0
	move.w  #$43a0, d0
P94_loc_20E4F0:
	move.w  d0, oTile(a0)
	move.b  oSubtype(a0), d0
	move.b  d0, d1
	subq.b  #$1, d0
	move.b  d0, oMapFrame(a0)
	lsl.b   #$3, d1
	move.b  d1, oXRadius(a0)
	move.b  d1, oWidth(a0)
P94_loc_20E50A:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	beq.s   P94_loc_20E53C
	addq.b  #$2, oRoutine(a0)
	clr.b   oSavedFlagsID(a0)
	move.w  #$8, $2a(a0)
	moveq   #$8, d0
	tst.w   $FFFFD010.w
	bpl.s   P94_loc_20E52E
	neg.w   d0
P94_loc_20E52E:
	move.w  d0, $2c(a0)
	move.w  #$a3, d0
	jsr     PlayFMSound.l
P94_loc_20E53C:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P94_loc_20E548:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	subq.w  #$1, $2a(a0)
	bpl.s   P94_loc_20E55C
	addq.b  #$2, oRoutine(a0)
P94_loc_20E55C:
	jmp     DrawObject.l
P94_loc_20E562:
	movem.l (a0), a2-a5
	moveq   #$ff, d1
	moveq   #$8, d2
	moveq   #$0, d3
	move.b  oSubtype(a0), d3
	subq.w  #$1, d3
	asl.w   #$3, d3
	tst.w   $2c(a0)
	bmi.s   P94_loc_20E57C
	neg.w   d3
P94_loc_20E57C:
	jsr     FindObjSlot.l
	bne.w   P94_loc_20E5C2
	movem.l a2-a5, (a1)
	move.b  d1, $29(a1)
	sub.w   d2, $c(a1)
	add.w   d3, $8(a1)
	move.w  #$4, $2a(a1)
	move.b  #$8, $1a(a1)
	jsr     FindObjSlot.l
	bne.w   P94_loc_20E5C2
	movem.l a2-a5, (a1)
	move.b  d1, $29(a1)
	add.w   d2, $c(a1)
	add.w   d3, $8(a1)
	move.b  #$9, $1a(a1)
P94_loc_20E5C2:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	beq.s   P94_loc_20E5D4
	jsr     GetOffObject.l
P94_loc_20E5D4:
	subq.b  #$1, oSubtype(a0)
	ble.w   P94_loc_20E66C
	subq.b  #$2, oRoutine(a0)
	subq.b  #$1, oMapFrame(a0)
	subq.b  #$8, oXRadius(a0)
	subq.b  #$8, oWidth(a0)
	move.w  #$7, $2a(a0)
	move.w  $2c(a0), d0
	add.w   d0, oX(a0)
	lea     objects.w, a1
	jsr     TopSolidObject.l
	jmp     DrawObject.l
P94_loc_20E60A:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P94_dat_20E618(pc, d0.w), d0
	jmp     P94_dat_20E618(pc, d0.w)
P94_dat_20E618:
	dc.w	P94_loc_20E61E-P94_dat_20E618
	dc.w	P94_loc_20E630-P94_dat_20E618
	dc.w	P94_loc_20E640-P94_dat_20E618
P94_loc_20E61E:
	addq.b  #$2, oRoutine(a0)
	move.l  #$8080308, oYRadius(a0)
	jmp     DrawObject.l
P94_loc_20E630:
	subq.w  #$1, $2a(a0)
	bpl.s   P94_loc_20E63A
	addq.b  #$2, oRoutine(a0)
P94_loc_20E63A:
	jmp     DrawObject.l
P94_loc_20E640:
	tst.b   oSprFlags(a0)
	bpl.s   P94_loc_20E66C
	move.l  $2c(a0), d0
	addi.l  #$4000, d0
	cmpi.l  #$160000, d0
	ble.s   P94_loc_20E65E
	move.l  #$160000, d0
P94_loc_20E65E:
	move.l  d0, $2c(a0)
	add.l   d0, oY(a0)
	jmp     DrawObject.l
P94_loc_20E66C:
	jmp     DeleteObject.l
P94_loc_20E672:
	dc.w	$0014,$001F,$0034,$0053,$007C,$00AF,$00EC,$0133
	dc.w	$0184,$018A,$02F0,$0500,$00F8,$0005,$0004,$F804
	dc.w	$F005,$0000,$F000,$0500,$04F0,$F005,$0000,$0000
	dc.w	$0500,$0400,$06F0,$0500,$00E8,$0005,$0004,$E8F0
	dc.w	$0500,$00F8,$0005,$0004,$F8F0,$0500,$0008,$0005
	dc.w	$0004,$0808,$F005,$0000,$E000,$0500,$04E0,$F005
	dc.w	$0000,$F000,$0500,$04F0,$F005,$0000,$0000,$0500
	dc.w	$0400,$F005,$0000,$1000,$0500,$0410,$0AF0,$0500
	dc.w	$00D8,$0005,$0004,$D8F0,$0500,$00E8,$0005,$0004
	dc.w	$E8F0,$0500,$00F8,$0005,$0004,$F8F0,$0500,$0008
	dc.w	$0005,$0004,$08F0,$0500,$0018,$0005,$0004,$180C
	dc.w	$F005,$0000,$D000,$0500,$04D0,$F005,$0000,$E000
	dc.w	$0500,$04E0,$F005,$0000,$F000,$0500,$04F0,$F005
	dc.w	$0000,$0000,$0500,$0400,$F005,$0000,$1000,$0500
	dc.w	$0410,$F005,$0000,$2000,$0500,$0420,$0EF0,$0500
	dc.w	$00C8,$0005,$0004,$C8F0,$0500,$00D8,$0005,$0004
	dc.w	$D8F0,$0500,$00E8,$0005,$0004,$E8F0,$0500,$00F8
	dc.w	$0005,$0004,$F8F0,$0500,$0008,$0005,$0004,$08F0
	dc.w	$0500,$0018,$0005,$0004,$18F0,$0500,$0028,$0005
	dc.w	$0004,$2810,$F005,$0000,$C000,$0500,$04C0,$F005
	dc.w	$0000,$D000,$0500,$04D0,$F005,$0000,$E000,$0500
	dc.w	$04E0,$F005,$0000,$F000,$0500,$04F0,$F005,$0000
	dc.w	$0000,$0500,$0400,$F005,$0000,$1000,$0500,$0410
	dc.w	$F005,$0000,$2000,$0500,$0420,$F005,$0000,$3000
	dc.w	$0500,$0430,$01F8,$0500,$00F8,$01F8,$0500,$04F8
