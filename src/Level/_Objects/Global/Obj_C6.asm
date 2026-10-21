; Object $C6 - Obj2D_20ECFC (from R82A, old ID $2D)
Obj2D_20ECFC:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PC6_dat_20ED1C(pc, d0.w), d0
	jsr     PC6_dat_20ED1C(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PC6_dat_20ED1C:
	dc.w	PC6_loc_20ED3A-PC6_dat_20ED1C
	dc.w	PC6_loc_20ED88-PC6_dat_20ED1C
	dc.w	PC6_loc_20EDA4-PC6_dat_20ED1C
	dc.w	PC6_loc_20EDB8-PC6_dat_20ED1C
	dc.w	PC6_loc_20EE10-PC6_dat_20ED1C
	dc.w	PC6_loc_20EDF4-PC6_dat_20ED1C
	dc.w	PC6_loc_20EE1A-PC6_dat_20ED1C
	dc.w	PC6_loc_20EDF4-PC6_dat_20ED1C
	dc.w	PC6_loc_20EE2E-PC6_dat_20ED1C
	dc.w	PC6_loc_20EE68-PC6_dat_20ED1C
	dc.w	PC6_loc_20EE50-PC6_dat_20ED1C
	dc.w	PC6_loc_20EE68-PC6_dat_20ED1C
	dc.w	PC6_loc_20EEEA-PC6_dat_20ED1C
	dc.w	PC6_loc_20EDF4-PC6_dat_20ED1C
	dc.w	PC6_loc_20EF04-PC6_dat_20ED1C
PC6_loc_20ED3A:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$e, oXRadius(a0)
	move.b  #$e, oWidth(a0)
	move.b  #$9, oYRadius(a0)
	move.b  #$2c, oColType(a0)
	move.w  #$242f, oTile(a0)
	lea     PC6_dat_20EFDA(pc), a1
	lea     PC6_dat_20EF80(pc), a2
	tst.b   oSubtype(a0)
	beq.s   PC6_loc_20ED7E
	lea     PC6_dat_20F048(pc), a1
	lea     PC6_dat_20EFAA(pc), a2
PC6_loc_20ED7E:
	move.l  a1, oMap(a0)
	move.l  a2, $2e(a0)
	rts     
PC6_loc_20ED88:
	addi.l  #$10000, oY(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   PC6_loc_20EDA2
	add.w   d1, oY(a0)
	addq.b  #$2, oRoutine(a0)
PC6_loc_20EDA2:
	rts     
PC6_loc_20EDA4:
	addq.b  #$2, oRoutine(a0)
	move.l  #$6000, d0
	move.l  #$1000, d1
	bra.w   PC6_loc_20EF1C
PC6_loc_20EDB8:
	bsr.w   PC6_sub_20EF34
	beq.s   PC6_loc_20EDFE
	move.w  $FFFFD008.w, d0
	sub.w   oX(a0), d0
	spl.b   d1
	subi.w  #$ff80, d0
	subi.w  #$100, d0
	bcc.s   PC6_loc_20EDF4
	move.w  $FFFFD00C.w, d0
	sub.w   oY(a0), d0
	subi.w  #$ff80, d0
	subi.w  #$100, d0
	bcc.s   PC6_loc_20EDF4
	btst.b  #$0, oSprFlags(a0)
	sne.b   d0
	eor.b   d1, d0
	bne.s   PC6_loc_20EDF4
	addq.b  #$2, oRoutine(a0)
PC6_loc_20EDF4:
	movea.l $2e(a0), a1
	jmp     AnimateObject.l
PC6_loc_20EDFE:
	neg.l   $2a(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	rts     
PC6_loc_20EE10:
	addq.b  #$2, oRoutine(a0)
	addq.b  #$1, oAnim(a0)
	rts     
PC6_loc_20EE1A:
	addq.b  #$2, oRoutine(a0)
	addq.b  #$1, oAnim(a0)
	subq.w  #$6, oY(a0)
	move.b  #$10, oYRadius(a0)
	rts     
PC6_loc_20EE2E:
	addq.b  #$2, oRoutine(a0)
	addq.b  #$1, oAnim(a0)
	addq.w  #$3, oY(a0)
	move.b  #$d, oYRadius(a0)
	move.b  #$ed, oColType(a0)
	move.l  #$0, $2a(a0)
	rts     
PC6_loc_20EE50:
	addq.b  #$2, oRoutine(a0)
	addq.b  #$1, oAnim(a0)
	move.l  #$40000, d0
	move.l  #$10000, d1
	bra.w   PC6_loc_20EF1C
PC6_loc_20EE68:
	tst.b   oColStatus(a0)
	bne.s   PC6_loc_20EE84
	bsr.w   PC6_sub_20EF34
	beq.s   PC6_loc_20EE7E
	movea.l $2e(a0), a1
	jmp     AnimateObject.l
PC6_loc_20EE7E:
	addq.b  #$2, oRoutine(a0)
	rts     
PC6_loc_20EE84:
	lea     objects.w, a1
	move.w  oX(a0), d1
	move.w  oY(a0), d2
	sub.w   $8(a1), d1
	sub.w   $c(a1), d2
	jsr     CalcAngle.l
	jsr     CalcSine.l
	muls.w  #$f900, d1
	asr.l   #$8, d1
	move.w  d1, $10(a1)
	muls.w  #$f900, d0
	asr.l   #$8, d0
	move.w  d0, $12(a1)
	bset.b  #$1, $22(a1)
	bclr.b  #$4, $22(a1)
	bclr.b  #$5, $22(a1)
	clr.b   $3c(a1)
	clr.b   oColStatus(a0)
	neg.w   d1
	ext.l   d1
	asl.l   #$8, d1
	move.l  d1, $2a(a0)
	move.b  #$4, oAnim(a0)
	move.b  #$16, oRoutine(a0)
	rts     
PC6_loc_20EEEA:
	addq.b  #$2, oRoutine(a0)
	addq.b  #$1, oAnim(a0)
	subq.w  #$3, oY(a0)
	move.b  #$10, oYRadius(a0)
	move.b  #$2c, oColType(a0)
	rts     
PC6_loc_20EF04:
	move.b  #$4, oRoutine(a0)
	move.b  #$0, oAnim(a0)
	addq.w  #$6, oY(a0)
	move.b  #$9, oYRadius(a0)
	rts     
PC6_loc_20EF1C:
	tst.b   oSubtype(a0)
	beq.s   PC6_loc_20EF24
	move.l  d1, d0
PC6_loc_20EF24:
	btst.b  #$0, oSprFlags(a0)
	bne.s   PC6_loc_20EF2E
	neg.l   d0
PC6_loc_20EF2E:
	move.l  d0, $2a(a0)
	rts     
PC6_dat_20EFDA:
	dc.w	$000C,$0035,$005E,$00DC,$00EC,$00F7,$08F4,$0000
	dc.w	$00F0,$F400,$0001,$F8F4,$0000,$0200,$F400,$0003
	dc.w	$08FC,$0C00,$04F0,$0400,$0008,$F004,$0400,$09F8
	dc.w	$0400,$000B,$0808,$F400,$0000,$F0F4,$0000,$01F8
	dc.w	$F400,$0002,$00F4,$0000,$0308,$FC0C,$0004,$F004
	dc.w	$0400,$0CF0,$0400,$000E,$0004,$0000,$0F08,$03F4
	dc.w	$0400,$35FB,$F00D,$0010,$F000,$0D10,$10F0
PC6_dat_20EF80:
	dc.w	$000C,$0010,$0013,$0018,$0020,$0024,$0900,$01FF
	dc.w	$0000,$FC03,$0404,$05FC,$0402,$0302,$0302,$03FC
	dc.w	$0402,$03FF,$0405,$0404,$FC00
PC6_dat_20F048:
	dc.w	$000C,$0035,$005E,$006E,$007E,$0089,$08F4,$0000
	dc.w	$37F0,$F400,$0001,$F8F4,$0000,$3800,$F400,$0003
	dc.w	$08FC,$0C00,$39F0,$0400,$0008,$F004,$0400,$3DF8
	dc.w	$0400,$000B,$0808,$F400,$0037,$F0F4,$0000,$01F8
	dc.w	$F400,$0038,$00F4,$0000,$0308,$FC0C,$0039,$F004
	dc.w	$0400,$0CF0,$0400,$003F,$0004,$0000,$0F08,$03EF
	dc.w	$0100,$40F0,$FF01,$1040,$F0EF,$0B00,$42F8,$03F4
	dc.w	$0400,$35FC,$F00D,$0010,$F000,$0D10,$10F0,$02F0
	dc.w	$0400,$18F8,$F80E,$001A,$F002,$F108,$0026,$F0F9
	dc.w	$0E00,$29F0
PC6_dat_20EFAA:
	dc.w	$000C,$0010,$0013,$0018,$0026,$002A,$1D00,$01FF
	dc.w	$3B00,$FC09,$0404,$05FC,$0902,$0302,$0302,$0302
	dc.w	$0302,$0302,$03FC,$0902,$03FF,$0905,$0404,$FC00
PC6_sub_20EF34:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	moveq   #$0, d3
	move.b  oXRadius(a0), d3
	lea     ObjGetRWallDist.l, a1
	tst.w   $2a(a0)
	bpl.s   PC6_loc_20EF56
	neg.w   d3
	lea     ObjGetLWallDist.l, a1
PC6_loc_20EF56:
	jsr     (a1)
	tst.w   d1
	bmi.s   PC6_loc_20EF74
	jsr     ObjGetFloorDist.l
	move.w  d1, d0
	addq.w  #$7, d0
	subi.w  #$e, d0
	bcc.s   PC6_loc_20EF74
	add.w   d1, oY(a0)
	moveq   #$ff, d0
	rts     
PC6_loc_20EF74:
	move.l  $2a(a0), d0
	sub.l   d0, oX(a0)
	moveq   #$0, d0
	rts     
