; Object $8F - Obj38_20F660 (from R71A, old ID $38)
P8F_Obj38_20F660:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P8F_dat_20F678(pc, d0.w), d0
	jsr     P8F_dat_20F678(pc, d0.w)
	move.w  $36(a0), d0
	jmp     CheckObjDespawn2.l
P8F_dat_20F678:
	dc.w	P8F_loc_20F67C-P8F_dat_20F678
	dc.w	P8F_loc_20F6DC-P8F_dat_20F678
P8F_loc_20F67C:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.l  #$20f86c, oMap(a0)
	move.b  #$7f, oWidth(a0)
	move.b  #$7f, oYRadius(a0)
	move.w  oX(a0), $36(a0)
	move.b  oLayer(a0), d0
	andi.b  #$3, d0
	move.b  d0, $30(a0)
	move.b  #$1, oPriority(a0)
	move.w  #$a4af, oTile(a0)
	btst.b  #$3, oLayer(a0)
	beq.s   P8F_loc_20F6DC
	move.b  #$3, oPriority(a0)
	move.w  #$24af, oTile(a0)
	cmpi.b  #$1, timeZone.l
	beq.s   P8F_loc_20F6DC
	addi.w  #$2000, oTile(a0)
P8F_loc_20F6DC:
	move.w  cameraY.w, d0
	addi.w  #$70, d0
	move.w  d0, oY(a0)
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	add.w   d0, d0
	move.w  P8F_dat_20F72A(pc, d0.w), d0
	jsr     P8F_dat_20F72A(pc, d0.w)
	move.w  levelFrames.l, d0
	andi.b  #$3, d0
	btst.b  #$2, oLayer(a0)
	beq.s   P8F_loc_20F718
	cmp.b   $30(a0), d0
	bne.s   P8F_loc_20F716
	jsr     DrawObject.l
P8F_loc_20F716:
	rts     
P8F_loc_20F718:
	andi.b  #$1, d0
	cmp.b   $30(a0), d0
	bne.s   P8F_loc_20F728
	jsr     DrawObject.l
P8F_loc_20F728:
	rts     
P8F_dat_20F72A:
	dc.w	P8F_loc_20F73C-P8F_dat_20F72A
	dc.w	P8F_loc_20F7D6-P8F_dat_20F72A
	dc.w	P8F_loc_20F804-P8F_dat_20F72A
	dc.w	P8F_loc_20F822-P8F_dat_20F72A
	dc.w	P8F_loc_20F840-P8F_dat_20F72A
	dc.w	P8F_loc_20F840-P8F_dat_20F72A
	dc.w	P8F_loc_20F840-P8F_dat_20F72A
	dc.w	P8F_loc_20F850-P8F_dat_20F72A
	dc.w	P8F_loc_20F850-P8F_dat_20F72A
P8F_loc_20F73C:
	lea     P8F_dat_20F74A(pc), a2
	move.b  #$b, $3d(a0)
	bra.w   P8F_loc_20F776
P8F_dat_20F74A:
	dc.w	$000A,$0000,$0314,$0000,$0214,$0044,$0114,$000C
	dc.w	$030A,$0000,$021E,$01FC,$0114,$000C,$0314,$0000
	dc.w	$010A,$0140,$0314,$0000,$0214,$01F0
P8F_loc_20F776:
	tst.b   $3a(a0)
	bne.s   P8F_loc_20F7BC
	moveq   #$0, d0
	move.b  $3c(a0), d0
	add.b   d0, d0
	add.b   d0, d0
	lea     (a2, d0.w), a2
	move.b  (a2)+, oMapFrame(a0)
	move.b  (a2)+, $3a(a0)
	move.b  (a2)+, d1
	move.b  (a2)+, d0
	ext.w   d0
	add.w   $36(a0), d0
	move.w  d0, oX(a0)
	bclr.b  #$0, oSprFlags(a0)
	bclr.b  #$0, oFlags(a0)
	tst.b   d1
	beq.s   P8F_loc_20F7BC
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$0, oFlags(a0)
P8F_loc_20F7BC:
	subq.b  #$1, $3a(a0)
	bne.s   P8F_loc_20F7D4
	addq.b  #$1, $3c(a0)
	move.b  $3c(a0), d0
	cmp.b   $3d(a0), d0
	bcs.s   P8F_loc_20F7D4
	clr.b   $3c(a0)
P8F_loc_20F7D4:
	rts     
P8F_loc_20F7D6:
	lea     P8F_dat_20F7E4(pc), a2
	move.b  #$8, $3d(a0)
	bra.w   P8F_loc_20F776
P8F_dat_20F7E4:
	dc.w	$001E,$0000,$011E,$0030,$021E,$005C,$011E,$0030
	dc.w	$001E,$0000,$011E,$01D0,$021E,$01A4,$011E,$01D0
P8F_loc_20F804:
	lea     P8F_dat_20F812(pc), a2
	move.b  #$4, $3d(a0)
	bra.w   P8F_loc_20F776
P8F_dat_20F812:
	dc.w	$001E,$0000,$011E,$0030,$021E,$005C,$011E,$0030
P8F_loc_20F822:
	lea     P8F_dat_20F830(pc), a2
	move.b  #$4, $3d(a0)
	bra.w   P8F_loc_20F776
P8F_dat_20F830:
	dc.w	$001E,$0000,$011E,$01D0,$021E,$01A4,$011E,$01D0
P8F_loc_20F840:
	move.b  oSubtype(a0), d0
	subq.b  #$4, d0
	bcc.s   P8F_loc_20F84A
	moveq   #$0, d0
P8F_loc_20F84A:
	move.b  d0, oMapFrame(a0)
	rts     
P8F_loc_20F850:
	move.b  oSubtype(a0), d0
	subq.b  #$6, d0
	bcc.s   P8F_loc_20F85A
	moveq   #$0, d0
P8F_loc_20F85A:
	move.b  d0, oMapFrame(a0)
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$0, oFlags(a0)
	rts     
P8F_loc_20F86C:
	dc.w	$0008,$002C,$0050,$0098,$0790,$0B00,$00F4,$B00B
	dc.w	$0000,$F4D0,$0B00,$00F4,$F00B,$0000,$F410,$0B00
	dc.w	$00F4,$300B,$0000,$F450,$0B00,$00F4,$0790,$0F00
	dc.w	$0C08,$B00F,$000C,$00D0,$0F00,$0CF8,$F00F,$000C
	dc.w	$F010,$0F00,$0CE8,$300F,$000C,$E050,$0F00,$0CD8
	dc.w	$0E90,$0D00,$1C28,$A00D,$001C,$20B0,$0D00,$1C18
	dc.w	$C00D,$001C,$10D0,$0D00,$1C08,$E00D,$001C,$00F0
	dc.w	$0D00,$1CF8,$000D,$001C,$F010,$0D00,$1CE8,$200D
	dc.w	$001C,$E030,$0D00,$1CD8,$400D,$001C,$D050,$0D00
	dc.w	$1CC8,$600D,$001C,$C000,$0000
