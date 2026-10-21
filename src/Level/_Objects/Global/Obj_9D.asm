; Object $9D - Obj32_20E052 (from R61A, old ID $32)
P9D_Obj32_20E052:
	tst.b   oLayer(a0)
	bmi.w   P9D_loc_20E3B8
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P9D_dat_20E07A(pc, d0.w), d0
	jsr     P9D_dat_20E07A(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P9D_dat_20E07A:
	dc.w	P9D_loc_20E088-P9D_dat_20E07A
	dc.w	P9D_loc_20E0CE-P9D_dat_20E07A
	dc.w	P9D_loc_20E0DA-P9D_dat_20E07A
	dc.w	P9D_loc_20E110-P9D_dat_20E07A
	dc.w	P9D_loc_20E14E-P9D_dat_20E07A
	dc.w	P9D_loc_20E172-P9D_dat_20E07A
	dc.w	P9D_loc_20E19A-P9D_dat_20E07A
P9D_loc_20E088:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$10, oYRadius(a0)
	move.b  #$13, oXRadius(a0)
	move.b  #$13, oWidth(a0)
	move.w  #$a4a8, oTile(a0)
	move.b  #$36, oColType(a0)
	move.b  oLayer(a0), $33(a0)
	lea     P9D_dat_20E206(pc), a1
	tst.b   oSubtype(a0)
	beq.s   P9D_loc_20E0CA
	lea     P9D_dat_20E2EE(pc), a1
P9D_loc_20E0CA:
	move.l  a1, oMap(a0)
P9D_loc_20E0CE:
	subq.w  #$1, $32(a0)
	bpl.s   P9D_loc_20E0D8
	addq.b  #$2, oRoutine(a0)
P9D_loc_20E0D8:
	rts     
P9D_loc_20E0DA:
	lea     objects.w, a1
	bsr.s   P9D_sub_20E0E8
	bcc.s   P9D_loc_20E0E6
	addq.b  #$2, oRoutine(a0)
P9D_loc_20E0E6:
	rts     
P9D_dat_20E206:
	dc.w	$0008,$003B,$0073,$00B0,$0AF0,$0000,$00F0,$F000
	dc.w	$0001,$F8F0,$0008,$0100,$F000,$0800,$08F8,$0400
	dc.w	$02F0,$F804,$0802,$0000,$0100,$04F0,$0001,$0006
	dc.w	$F800,$0108,$0600,$0001,$0804,$080B,$FB09,$0009
	dc.w	$F4F0,$0000,$00F0,$F000,$0008,$F8F0,$0008,$0800
	dc.w	$F000,$0800,$08F8,$0400,$11F0,$F804,$0811,$0000
	dc.w	$0000,$13F0,$0001,$0014,$F800,$0108,$1400,$0000
	dc.w	$0813,$080C,$FD01,$000F,$ECFD,$0108,$0F0C,$F000
	dc.w	$0000,$F0F0,$0000,$08F8,$F000,$0808,$00F0,$0008
	dc.w	$0008,$F804,$0011,$F0F8,$0408,$1100,$0000,$0013
	dc.w	$F000,$0100,$16F8,$0001,$0816,$0000,$0008,$1308
	dc.w	$0BFB,$0908,$09F4,$F000,$0000,$F0F0,$0000,$08F8
	dc.w	$F000,$0808,$00F0,$0008,$0008,$F804,$0011,$F0F8
	dc.w	$0408,$1100,$0000,$0013,$F000,$0100,$14F8,$0001
	dc.w	$0814,$0000,$0008,$1308
P9D_dat_20E2EE:
	dc.w	$0008,$003B,$0069,$009C,$0AF0,$0000,$00F0,$F000
	dc.w	$0001,$F8F0,$0008,$0100,$F000,$0800,$08F8,$0400
	dc.w	$18F0,$F804,$0818,$0000,$0100,$04F0,$0001,$001A
	dc.w	$F800,$0108,$1A00,$0001,$0804,$0809,$FB09,$0009
	dc.w	$F4F0,$0000,$00F0,$F000,$0008,$F8F0,$0008,$0800
	dc.w	$F000,$0800,$08F8,$0400,$1CF0,$F804,$081C,$0000
	dc.w	$0100,$1EF8,$0001,$081E,$000A,$FD01,$000F,$ECFD
	dc.w	$0108,$0F0C,$F000,$0000,$F0F0,$0000,$08F8,$F000
	dc.w	$0808,$00F0,$0008,$0008,$F804,$001C,$F0F8,$0408
	dc.w	$1C00,$0001,$001E,$F800,$0108,$1E00,$09FB,$0908
	dc.w	$09F4,$F000,$0000,$F0F0,$0000,$08F8,$F000,$0808
	dc.w	$00F0,$0008,$0008,$F804,$001C,$F0F8,$0408,$1C00
	dc.w	$0001,$001E,$F800,$0108,$1E00
P9D_loc_20E3B8:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P9D_dat_20E3D2(pc, d0.w), d0
	jsr     P9D_dat_20E3D2(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P9D_sub_20E0E8:
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	subi.w  #$ffa0, d0
	subi.w  #$c0, d0
	bcc.s   P9D_loc_20E10E
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	move.w  d0, $34(a0)
	subi.w  #$ff88, d0
	subi.w  #$f0, d0
P9D_loc_20E10E:
	rts     
P9D_loc_20E110:
	addq.b  #$2, oRoutine(a0)
	move.l  #$10000, d0
	move.l  #$ffff8000, d1
	move.w  #$60, d2
	tst.b   oSubtype(a0)
	beq.s   P9D_loc_20E13A
	move.l  #$c000, d0
	move.l  #$6000, d1
	move.w  #$2a, d2
P9D_loc_20E13A:
	tst.w   $34(a0)
	bmi.s   P9D_loc_20E142
	neg.l   d0
P9D_loc_20E142:
	move.l  d0, $2a(a0)
	move.l  d1, $2e(a0)
	move.w  d2, $32(a0)
P9D_loc_20E14E:
	subq.w  #$1, $32(a0)
	bpl.s   P9D_loc_20E158
	addq.b  #$2, oRoutine(a0)
P9D_loc_20E158:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	move.l  $2e(a0), d0
	add.l   d0, oY(a0)
	lea     P9D_dat_20E1FE(pc), a1
	jmp     AnimateObject.l
P9D_loc_20E172:
	addq.b  #$2, oRoutine(a0)
	move.w  #$0, $32(a0)
	move.l  #$10000, d0
	tst.b   oSubtype(a0)
	beq.s   P9D_loc_20E18E
	move.l  #$c000, d0
P9D_loc_20E18E:
	tst.w   $34(a0)
	bmi.s   P9D_loc_20E196
	neg.l   d0
P9D_loc_20E196:
	move.l  d0, $2a(a0)
P9D_loc_20E19A:
	tst.b   oSubtype(a0)
	bne.s   P9D_loc_20E1EC
	andi.w  #$3f, $32(a0)
	bne.s   P9D_loc_20E1E8
	lea     objects.w, a1
	bsr.w   P9D_sub_20E0E8
	bcc.s   P9D_loc_20E1E8
	jsr     FindObjSlot.l
	bne.s   P9D_loc_20E1E8
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.l  oX(a0), $8(a1)
	move.l  oY(a0), $c(a1)
	addi.w  #$a, $c(a1)
	move.b  #$ff, $29(a1)
	move.b  oSprFlags(a0), $1(a1)
	move.b  oPriority(a0), $18(a1)
	addq.b  #$1, $18(a1)
P9D_loc_20E1E8:
	addq.w  #$1, $32(a0)
P9D_loc_20E1EC:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	lea     P9D_dat_20E1FE(pc), a1
	jmp     AnimateObject.l
P9D_dat_20E3D2:
	dc.w	P9D_loc_20E3DC-P9D_dat_20E3D2
	dc.w	P9D_loc_20E40E-P9D_dat_20E3D2
	dc.w	P9D_loc_20E438-P9D_dat_20E3D2
	dc.w	P9D_loc_20E44A-P9D_dat_20E3D2
	dc.w	P9D_loc_20E45E-P9D_dat_20E3D2
P9D_loc_20E3DC:
	addq.b  #$2, oRoutine(a0)
	move.b  #$b7, oColType(a0)
	move.b  #$6, oYRadius(a0)
	move.b  #$6, oXRadius(a0)
	move.b  #$6, oWidth(a0)
	move.w  #$84c8, oTile(a0)
	move.l  #$20e488, oMap(a0)
	move.l  #$8000, $2e(a0)
P9D_loc_20E40E:
	move.l  $2e(a0), d0
	add.l   d0, oY(a0)
	addi.l  #$4000, $2e(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P9D_loc_20E436
	addq.b  #$2, oRoutine(a0)
	add.w   d1, oY(a0)
	move.w  #$78, $32(a0)
P9D_loc_20E436:
	rts     
P9D_loc_20E438:
	subq.w  #$1, $32(a0)
	bpl.s   P9D_loc_20E448
	addq.b  #$2, oRoutine(a0)
	move.w  #$78, $32(a0)
P9D_loc_20E448:
	rts     
P9D_loc_20E44A:
	subq.w  #$1, $32(a0)
	bpl.s   P9D_loc_20E454
	addq.b  #$2, oRoutine(a0)
P9D_loc_20E454:
	lea     P9D_dat_20E482(pc), a1
	jmp     AnimateObject.l
P9D_loc_20E45E:
	move.b  #$18, oID(a0)
	move.b  #$0, oRoutine(a0)
	move.b  #$1, oSolidType(a0)
	tst.b   oSprFlags(a0)
	bpl.s   P9D_loc_20E480
	move.w  #$9e, d0
	jsr     PlayFMSound.l
P9D_loc_20E480:
	rts     
P9D_dat_20E1FE:
	dc.w	$0002,$0301,$0203,$02FF
P9D_dat_20E482:
	dc.w	$0002,$0100,$01FF
P9D_loc_20E488:
	dc.w	$0004,$000A,$01F8,$0500,$00F8,$01F8,$0500,$04F8
