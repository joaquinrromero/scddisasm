; Object $C0 - Obj24_20C426 (from R81A, old ID $24)
PC0_Obj24_20C426:
	tst.b   oLayer(a0)
	bpl.s   PC0_loc_20C430
	bra.w   PC0_loc_20C554
PC0_loc_20C430:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PC0_dat_20C454(pc, d0.w), d0
	jsr     PC0_dat_20C454(pc, d0.w)
	jsr     DrawObject.l
	move.w  $30(a0), d0
	jmp     CheckObjDespawn2.l
PC0_dat_20C454:
	dc.w	PC0_loc_20C45A-PC0_dat_20C454
	dc.w	PC0_loc_20C4E6-PC0_dat_20C454
	dc.w	PC0_loc_20C502-PC0_dat_20C454
PC0_loc_20C45A:
	move.w  oX(a0), $30(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.w  #$244e, oTile(a0)
	move.l  #$20c546, oMap(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$e, oYRadius(a0)
	move.b  #$2a, oColType(a0)
	move.l  #$ffffb000, $2c(a0)
	addq.b  #$2, oRoutine(a0)
	jsr     FindNextObjSlot.l
	beq.s   PC0_loc_20C4A6
	jmp     DeleteObject.l
PC0_loc_20C4A6:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  oSubtype(a0), $28(a1)
	move.b  #$ff, $29(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.w  a0, $3e(a1)
	tst.b   oLayer(a0)
	beq.s   PC0_loc_20C4E6
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$0, oFlags(a0)
	bset.b  #$0, $1(a1)
	bset.b  #$0, $22(a1)
PC0_loc_20C4E6:
	addi.l  #$10000, oY(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   PC0_loc_20C500
	add.w   d1, oY(a0)
	addq.b  #$2, oRoutine(a0)
PC0_loc_20C500:
	rts     
PC0_loc_20C502:
	tst.b   oSprFlags(a0)
	bpl.s   PC0_loc_20C520
	addq.w  #$1, $32(a0)
	move.w  $32(a0), d0
	andi.w  #$1f, d0
	bne.s   PC0_loc_20C520
	move.w  #$b1, d0
	jsr     PlayFMSound.l
PC0_loc_20C520:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	jsr     ObjGetFloorDist.l
	add.w   d1, oY(a0)
	addi.w  #$ffff, $2a(a0)
	bpl.s   PC0_loc_20C544
	move.w  #$199, $2a(a0)
	neg.l   $2c(a0)
PC0_loc_20C544:
	rts     
PC0_loc_20C546:
	dc.w	$0002,$02F0,$0F00,$00E8,$F007,$0010,$0800
PC0_loc_20C554:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PC0_dat_20C568(pc, d0.w), d0
	jsr     PC0_dat_20C568(pc, d0.w)
	jmp     DrawObject.l
PC0_dat_20C568:
	dc.w	PC0_loc_20C56C-PC0_dat_20C568
	dc.w	PC0_loc_20C59C-PC0_dat_20C568
PC0_loc_20C56C:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$244e, oTile(a0)
	move.l  #$20c620, oMap(a0)
	move.b  #$c, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.b  #$ab, oColType(a0)
PC0_loc_20C59C:
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$24,$00,$00		; cmpi.b #$24, $0(a1) (raw: not reproducible by assembler)
	beq.s   PC0_loc_20C5AE
	jmp     DeleteObject.l
PC0_loc_20C5AE:
	tst.b   oSubtype(a0)
	bne.s   PC0_loc_20C5C8
	addi.w  #$ffff, $2a(a0)
	bpl.s   PC0_loc_20C5F2
	move.w  #$3c, $2a(a0)
	eori.b  #$1, oAnim(a0)
PC0_loc_20C5C8:
	move.w  #$ffe7, $2c(a0)
	move.w  #$0, $2e(a0)
	tst.b   oAnim(a0)
	beq.s   PC0_loc_20C5E6
	move.w  #$ffed, $2c(a0)
	move.w  #$fff1, $2e(a0)
PC0_loc_20C5E6:
	btst.b  #$0, oSprFlags(a0)
	beq.s   PC0_loc_20C5F2
	neg.w   $2c(a0)
PC0_loc_20C5F2:
	move.w  $8(a1), d0
	move.w  $c(a1), d1
	add.w   $2c(a0), d0
	add.w   $2e(a0), d1
	move.w  d0, oX(a0)
	move.w  d1, oY(a0)
	lea     PC0_dat_20C614(pc), a1
	jmp     AnimateObject.l
PC0_dat_20C614:
	dc.w	$0004,$0008,$0200,$01FF,$0202,$03FF
PC0_loc_20C620:
	dc.w	$0008,$0013,$001E,$0029,$02F8,$0900,$24F8,$F00B
	dc.w	$0018,$F402,$F809,$0024,$F8EF,$0B10,$18F4,$02FE
	dc.w	$0600,$2AFC,$F00B,$0018,$F402,$FE06,$002A,$FCEF
	dc.w	$0B10,$18F4
