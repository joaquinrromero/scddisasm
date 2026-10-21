; Object $9E - Obj33_20E498 (from R61A, old ID $33)
P9E_Obj33_20E498:
	tst.b   oLayer(a0)
	beq.s   P9E_loc_20E4A6
	bmi.w   P9E_loc_20E714
	bra.w   P9E_loc_20E6F4
P9E_loc_20E4A6:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P9E_dat_20E4C6(pc, d0.w), d0
	jsr     P9E_dat_20E4C6(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P9E_dat_20E4C6:
	dc.w	P9E_loc_20E4D8-P9E_dat_20E4C6
	dc.w	P9E_loc_20E586-P9E_dat_20E4C6
	dc.w	P9E_loc_20E596-P9E_dat_20E4C6
	dc.w	P9E_loc_20E5DC-P9E_dat_20E4C6
	dc.w	P9E_loc_20E5E8-P9E_dat_20E4C6
	dc.w	P9E_loc_20E606-P9E_dat_20E4C6
	dc.w	P9E_loc_20E620-P9E_dat_20E4C6
	dc.w	P9E_loc_20E63E-P9E_dat_20E4C6
	dc.w	P9E_loc_20E660-P9E_dat_20E4C6
P9E_loc_20E4D8:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$10, oYRadius(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.w  #$2488, oTile(a0)
	move.b  #$34, oColType(a0)
	addq.w  #$8, oY(a0)
	move.w  oY(a0), $34(a0)
	move.w  oY(a0), $36(a0)
	addi.w  #$5f, $36(a0)
	lea     P9E_dat_20E79E(pc), a1
	tst.b   oSubtype(a0)
	beq.s   P9E_loc_20E52A
	lea     P9E_dat_20E7F6(pc), a1
P9E_loc_20E52A:
	move.l  a1, oMap(a0)
	jsr     FindNextObjSlot.l
	beq.s   P9E_loc_20E53C
	jmp     DeleteObject.l
P9E_loc_20E53C:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $29(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  oSprFlags(a0), $1(a1)
	move.b  oPriority(a0), $18(a1)
	addq.b  #$1, $18(a1)
	move.w  oTile(a0), $2(a1)
	move.l  oMap(a0), $4(a1)
	move.b  #$20, $16(a1)
	move.b  #$1, $17(a1)
	move.b  #$1, $19(a1)
	move.w  a0, $38(a1)
P9E_loc_20E586:
	addq.b  #$2, oRoutine(a0)
	move.b  #$9, oMapFrame(a0)
	move.w  #$79, $2a(a0)
P9E_loc_20E596:
	subq.w  #$1, $2a(a0)
	bne.s   P9E_loc_20E5B6
	move.w  #$79, $2a(a0)
	move.b  #$2, d6
	lea     objects.w, a1
	bsr.w   P9E_sub_20E5B8
	bcs.s   P9E_loc_20E5B2
	neg.b   d6
P9E_loc_20E5B2:
	add.b   d6, oRoutine(a0)
P9E_loc_20E5B6:
	rts     
P9E_dat_20E79E:
	dc.w	$0084,$0085,$0090,$00A0,$00B5,$00CF,$00EE,$0112
	dc.w	$013B,$0018,$002D,$003D,$04F0,$0000,$00F8,$F000
	dc.w	$0800,$00F8,$0200,$01F8,$F802,$0801,$0003,$F003
	dc.w	$0004,$F4F0,$0300,$08FC,$F003,$0804,$0405,$F000
	dc.w	$0000,$F8F0,$0008,$0000,$F802,$000C,$F0F8,$0600
	dc.w	$0FF8,$F802,$080C,$0800
P9E_dat_20E7F6:
	dc.w	$002C,$002D,$0038,$0048,$005D,$0077,$0096,$00BA
	dc.w	$00E3,$0016,$0021,$02F0,$0400,$16F8,$F806,$0018
	dc.w	$F802,$F004,$0816,$F8F8,$0600,$18F8,$0002,$F400
	dc.w	$0015,$FCFC,$0000,$15FC,$03F0,$0000,$15FC,$F800
	dc.w	$0015,$FC00,$0000,$15FC,$04EC,$0000,$15FC,$F400
	dc.w	$0015,$FCFC,$0000,$15FC,$0400,$0015,$FC05,$E800
	dc.w	$0015,$FCF0,$0000,$15FC,$F800,$0015,$FC00,$0000
	dc.w	$15FC,$0800,$0015,$FC06,$E400,$0015,$FCEC,$0000
	dc.w	$15FC,$F400,$0015,$FCFC,$0000,$15FC,$0400,$0015
	dc.w	$FC0C,$0000,$15FC,$07E0,$0000,$15FC,$E800,$0015
	dc.w	$FCF0,$0000,$15FC,$F800,$0015,$FC00,$0000,$15FC
	dc.w	$0800,$0015,$FC10,$0000,$15FC,$08DC,$0000,$15FC
	dc.w	$E400,$0015,$FCEC,$0000,$15FC,$F400,$0015,$FCFC
	dc.w	$0000,$15FC,$0400,$0015,$FC0C,$0000,$15FC,$1400
	dc.w	$0015,$FC09,$D800,$0015,$FCE0,$0000,$15FC,$E800
	dc.w	$0015,$FCF0,$0000,$15FC,$F800,$0015,$FC00,$0000
	dc.w	$15FC,$0800,$0015,$FC10,$0000,$15FC,$1800,$0015
	dc.w	$FC00
P9E_sub_20E5B8:
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	subi.w  #$28, d0
	subi.w  #$78, d0
	bcc.s   P9E_loc_20E5DA
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	subi.w  #$ff58, d0
	subi.w  #$150, d0
P9E_loc_20E5DA:
	rts     
P9E_loc_20E5DC:
	addq.b  #$2, oRoutine(a0)
	move.l  #$80000, $30(a0)
P9E_loc_20E5E8:
	move.l  $30(a0), d0
	add.l   d0, oY(a0)
	move.w  $36(a0), d0
	sub.w   oY(a0), d0
	bgt.s   P9E_loc_20E604
	add.w   d0, oY(a0)
	move.b  #$e, oRoutine(a0)
P9E_loc_20E604:
	rts     
P9E_loc_20E606:
	addq.b  #$2, oRoutine(a0)
	move.l  #$70000, d0
	tst.b   oSubtype(a0)
	beq.s   P9E_loc_20E61C
	move.l  #$20000, d0
P9E_loc_20E61C:
	move.l  d0, $30(a0)
P9E_loc_20E620:
	move.l  $30(a0), d0
	sub.l   d0, oY(a0)
	move.w  $34(a0), d0
	sub.w   oY(a0), d0
	blt.s   P9E_loc_20E63C
	add.w   d0, oY(a0)
	move.b  #$2, oRoutine(a0)
P9E_loc_20E63C:
	rts     
P9E_loc_20E63E:
	addq.b  #$2, oRoutine(a0)
	move.w  #$e6, d0
	move.w  #$ff, d1
	tst.b   oSubtype(a0)
	beq.s   P9E_loc_20E658
	move.w  #$3d, d0
	move.w  #$1ff, d1
P9E_loc_20E658:
	move.w  d0, $2a(a0)
	move.w  d1, oAnim(a0)
P9E_loc_20E660:
	subq.w  #$1, $2a(a0)
	bne.s   P9E_loc_20E66C
	move.b  #$a, oRoutine(a0)
P9E_loc_20E66C:
	lea     P9E_dat_20E750(pc), a1
	jsr     AnimateObject.l
	tst.b   oSubtype(a0)
	bne.w   P9E_loc_20E6F2
	cmpi.b  #$1e, oAnimFrame(a0)
	bne.w   P9E_loc_20E6F2
	jsr     FindNextObjSlot.l
	bne.w   P9E_loc_20E6F2
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$1, $29(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	addq.w  #$4, $c(a1)
	move.b  oSprFlags(a0), $1(a1)
	move.b  oPriority(a0), $18(a1)
	move.w  oTile(a0), $2(a1)
	move.l  oMap(a0), $4(a1)
	move.b  oYRadius(a0), $16(a1)
	move.b  oXRadius(a0), $17(a1)
	move.b  oWidth(a0), $19(a1)
	move.w  a0, $38(a1)
	move.b  #$b5, $20(a1)
	tst.b   oSprFlags(a0)
	bpl.s   P9E_loc_20E6F2
	move.w  #$b7, d0
	jsr     PlayFMSound.l
P9E_loc_20E6F2:
	rts     
P9E_loc_20E6F4:
	movea.w $38(a0), a1
	dc.b	$0C,$29,$00,$33,$00,$00		; cmpi.b #$33, $0(a1) (raw: not reproducible by assembler)
	bne.s   P9E_loc_20E70E
	cmpi.b  #$1, $1b(a1)
	beq.s   P9E_loc_20E70E
	jmp     DrawObject.l
P9E_loc_20E70E:
	jmp     DeleteObject.l
P9E_loc_20E714:
	movea.w $38(a0), a1
	dc.b	$0C,$29,$00,$33,$00,$00		; cmpi.b #$33, $0(a1) (raw: not reproducible by assembler)
	beq.s   P9E_loc_20E726
	jmp     DeleteObject.l
P9E_loc_20E726:
	move.w  $c(a1), d0
	sub.w   $34(a1), d0
	subi.w  #$18, d0
	asr.w   #$3, d0
	bpl.s   P9E_loc_20E738
	moveq   #$0, d0
P9E_loc_20E738:
	move.b  d0, oMapFrame(a0)
	asl.w   #$2, d0
	add.w   $34(a1), d0
	addi.w  #$10, d0
	move.w  d0, oY(a0)
	jmp     DrawObject.l
P9E_dat_20E750:
	dc.w	$0004,$004A,$0009,$0909,$0909,$0909,$0909,$0909
	dc.w	$0909,$0909,$0909,$0909,$0909,$0909,$0909,$0909
	dc.w	$0909,$090A,$0B0B,$0B0A,$090A,$0B0B,$0B0B,$0B0B
	dc.w	$0B0B,$0B0B,$0B0B,$0B0B,$0B0B,$0B0B,$0B0B,$0B0B
	dc.w	$0B0B,$0B0B,$0B0B,$0B0B,$0AFF,$0909,$0AFF
