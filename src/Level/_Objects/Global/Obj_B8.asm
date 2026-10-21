; Object $B8 - Obj35_20B4E4 (from R81A, old ID $35)
PB8_Obj35_20B4E4:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PB8_dat_20B51E(pc, d0.w), d0
	jsr     PB8_dat_20B51E(pc, d0.w)
	jsr     DrawObject.l
	move.w  oX(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.w   PB8_loc_20B518
	rts     
PB8_loc_20B518:
	jmp     DeleteObject.l
PB8_dat_20B51E:
	dc.w	PB8_loc_20B522-PB8_dat_20B51E
	dc.w	PB8_loc_20B630-PB8_dat_20B51E
PB8_loc_20B522:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.l  #$20b85a, oMap(a0)
	move.w  #$3a0, oTile(a0)
	move.b  #$5, oPriority(a0)
	move.b  #$0, oMapFrame(a0)
	move.b  #$28, oWidth(a0)
	move.b  #$38, oYRadius(a0)
	move.b  #$1, $30(a0)
	clr.w   $3e(a0)
	jsr     FindNextObjSlot.l
	bne.w   PB8_loc_20B62E
	move.b  #$2, $24(a1)
	ori.b   #$4, $1(a1)
	move.l  oMap(a0), $4(a1)
	move.w  #$43a0, $2(a1)
	move.b  #$6, $18(a1)
	move.b  #$5, $1a(a1)
	move.b  #$10, $19(a1)
	move.b  #$10, $16(a1)
	move.w  #$0, $12(a1)
	clr.w   $3e(a1)
	move.b  (a0), (a1)
	bset.b  #$0, $3e(a1)
	move.l  oX(a0), $8(a1)
	move.l  oY(a0), $c(a1)
	move.w  oY(a0), $36(a1)
	move.l  a0, $32(a1)
	jsr     FindNextObjSlot.l
	bne.w   PB8_loc_20B62E
	move.b  #$2, $24(a1)
	ori.b   #$4, $1(a1)
	move.l  #$20b85a, $4(a1)
	move.w  #$3a0, $2(a1)
	move.b  #$3, $18(a1)
	move.b  #$8, $1a(a1)
	move.b  #$28, $19(a1)
	move.b  #$c, $16(a1)
	move.w  #$0, $12(a1)
	clr.w   $3e(a1)
	move.b  (a0), (a1)
	bset.b  #$1, $3e(a1)
	move.l  oX(a0), $8(a1)
	move.w  oY(a0), $36(a1)
	move.l  oY(a0), $c(a1)
	move.w  $c(a1), d1
	addi.w  #$ffd4, d1
	move.w  d1, $c(a1)
	move.l  a0, $32(a1)
PB8_loc_20B62E:
	rts     
PB8_loc_20B630:
	btst.b  #$4, $3e(a0)
	bne.w   PB8_loc_20B710
	btst.b  #$0, $3e(a0)
	bne.w   PB8_loc_20B716
	btst.b  #$1, $3e(a0)
	bne.w   PB8_loc_20B7B8
	btst.b  #$5, $3e(a0)
	beq.w   PB8_loc_20B710
	tst.w   timeStopTimer.l
	bne.w   PB8_loc_20B710
	move.w  #$0, oYVel(a0)
	btst.b  #$7, $3e(a0)
	bne.s   PB8_loc_20B68C
	subq.b  #$1, $30(a0)
	bcc.w   PB8_loc_20B710
	move.b  #$5, $31(a0)
	bset.b  #$7, $3e(a0)
	addq.b  #$1, oMapFrame(a0)
	bra.w   PB8_loc_20B710
PB8_loc_20B68C:
	btst.b  #$6, $3e(a0)
	bne.s   PB8_loc_20B6C6
	subq.b  #$1, $31(a0)
	bcc.w   PB8_loc_20B710
	addq.b  #$1, oMapFrame(a0)
	move.b  #$5, $31(a0)
	cmpi.b  #$4, oMapFrame(a0)
	blt.w   PB8_loc_20B710
	bset.b  #$6, $3e(a0)
	move.b  #$0, $30(a0)
	move.b  #$a, $31(a0)
	bra.w   PB8_loc_20B710
PB8_loc_20B6C6:
	btst.b  #$2, $3e(a0)
	bne.w   PB8_loc_20B6FE
	subq.b  #$1, $31(a0)
	bcc.s   PB8_loc_20B710
	addq.b  #$1, $30(a0)
	move.b  $30(a0), d1
	ext.w   d1
	cmpi.w  #$4, d1
	bne.s   PB8_loc_20B6EE
	move.b  #$0, $30(a0)
	moveq   #$0, d1
PB8_loc_20B6EE:
	move.b  PB8_dat_20B712(pc, d1.w), d2
	move.b  d2, oMapFrame(a0)
	move.b  #$a, $31(a0)
	bra.s   PB8_loc_20B710
PB8_loc_20B6FE:
	cmpi.b  #$4, oMapFrame(a0)
	beq.s   PB8_loc_20B710
	addq.b  #$1, oMapFrame(a0)
	move.b  #$a, $31(a0)
PB8_loc_20B710:
	rts     
PB8_dat_20B712:
	dc.w	$0302,$0102
PB8_loc_20B716:
	tst.w   timeStopTimer.l
	bne.w   PB8_loc_20B7AA
	movea.l $32(a0), a1
	btst.b  #$5, $3e(a1)
	beq.s   PB8_loc_20B7AA
	btst.b  #$7, $3e(a0)
	bne.s   PB8_loc_20B742
	move.w  #$d000, oYVel(a0)
	bset.b  #$7, $3e(a0)
	bra.s   PB8_loc_20B7AA
PB8_loc_20B742:
	addi.w  #$100, oYVel(a0)
	bmi.s   PB8_loc_20B784
	move.w  oY(a0), d1
	sub.w   $36(a0), d1
	cmpi.w  #$8, d1
	bhi.s   PB8_loc_20B784
	move.w  #$4, d1
	add.w   $36(a0), d1
	move.w  d1, oY(a0)
	movea.l $32(a0), a1
	bset.b  #$4, $3e(a1)
	bset.b  #$4, $3e(a0)
	move.b  #$4, $1a(a1)
	move.w  #$0, oYVel(a0)
	bra.w   PB8_loc_20B7AA
PB8_loc_20B784:
	cmpi.w  #$0, oYVel(a0)
	bne.s   PB8_loc_20B79E
	addq.b  #$1, oMapFrame(a0)
	move.b  #$a4, oColType(a0)
	move.b  #$4, oPriority(a0)
	bra.s   PB8_loc_20B7AA
PB8_loc_20B79E:
	cmpi.w  #$e000, oYVel(a0)
	bne.s   PB8_loc_20B7AA
	addq.b  #$1, oMapFrame(a0)
PB8_loc_20B7AA:
	move.w  oYVel(a0), d0
	ext.l   d0
	lsl.l   #$6, d0
	add.l   d0, oY(a0)
	rts     
PB8_loc_20B7B8:
	tst.w   timeStopTimer.l
	bne.w   PB8_loc_20B832
	movea.l $32(a0), a1
	btst.b  #$5, $3e(a1)
	bne.s   PB8_loc_20B7E2
	lea     objects.w, a1
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jsr     SolidObject.l
	beq.s   PB8_loc_20B7EC
PB8_loc_20B7E2:
	movea.l $32(a0), a1
	bset.b  #$5, $3e(a1)
PB8_loc_20B7EC:
	movea.l $32(a0), a1
	move.b  $1a(a1), d1
	ext.w   d1
	asl.w   #$1, d1
	move.w  PB8_dat_20B850(pc, d1.w), d2
	move.w  $36(a0), d3
	add.w   d2, d3
	move.w  d3, oY(a0)
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	bsr.w   PB8_sub_20B834
	movea.l $32(a0), a1
	bclr.b  #$2, $3e(a1)
	lea     objects.w, a1
	jsr     SolidObject.l
	beq.s   PB8_loc_20B832
	movea.l $32(a0), a1
	bset.b  #$2, $3e(a1)
PB8_loc_20B832:
	rts     
PB8_dat_20B850:
	dc.w	$FFD4,$FFE4,$FFF4,$000C,$001C
PB8_loc_20B85A:
	dc.w	$0012,$0064,$00C0,$00E0,$013C,$018E,$019A,$01BA
	dc.w	$01EE,$10F0,$0400,$13F0,$E803,$0015,$E808,$0200
	dc.w	$19E8,$2002,$001C,$E8F0,$0408,$1300,$E803,$0815
	dc.w	$1008,$0208,$1910,$2002,$081C,$10C8,$0000,$1FD8
	dc.w	$D006,$0020,$D8E8,$0700,$26E0,$C800,$081F,$20D0
	dc.w	$0608,$2018,$E807,$0826,$1000,$0900,$0DE8,$0009
	dc.w	$080D,$0000,$12F0,$0400,$13F0,$E803,$0015,$E808
	dc.w	$0200,$19E8,$2002,$001C,$E8F0,$0408,$1300,$E803
	dc.w	$0815,$1008,$0208,$1910,$2002,$081C,$10D8,$0000
	dc.w	$2ED8,$E005,$002F,$D8F0,$0400,$33E0,$F800,$0035
	dc.w	$E8D8,$0008,$2E20,$E005,$082F,$18F0,$0408,$3310
	dc.w	$F800,$0835,$10F8,$0900,$0DE8,$F809,$080D,$0000
	dc.w	$06E8,$0300,$15E8,$0802,$0019,$E820,$0200,$1CE8
	dc.w	$E803,$0815,$1008,$0208,$1910,$2002,$081C,$1000
	dc.w	$12F0,$0400,$13F0,$E803,$0015,$E808,$0200,$19E8
	dc.w	$2002,$001C,$E8F0,$0408,$1300,$E803,$0815,$1008
	dc.w	$0208,$1910,$2002,$081C,$10E0,$0000,$36E8,$E804
	dc.w	$0037,$E0F0,$0500,$39D8,$0000,$003D,$D8E0,$0008
	dc.w	$3610,$E804,$0837,$10F0,$0508,$3918,$0000,$083D
	dc.w	$20E5,$0900,$0DE8,$E509,$080D,$0000,$10F0,$0400
	dc.w	$13F0,$E803,$0015,$E808,$0200,$19E8,$2002,$001C
	dc.w	$E8F0,$0408,$1300,$E803,$0815,$1008,$0208,$1910
	dc.w	$2002,$081C,$10D8,$0700,$3EE0,$F806,$0046,$D810
	dc.w	$0000,$4CD8,$D807,$083E,$10F8,$0608,$4618,$1000
	dc.w	$084C,$20DD,$0900,$0DE8,$DD09,$080D,$0000,$02F0
	dc.w	$0700,$73F0,$F007,$0873,$0000,$06E8,$0200,$65F8
	dc.w	$0002,$0068,$F8F0,$0700,$6BE8,$E802,$0865,$0000
	dc.w	$0208,$6800,$F007,$086B,$0800,$0AE0,$0300,$4DF8
	dc.w	$0003,$0051,$F8E8,$0900,$55E0,$F805,$005B,$E808
	dc.w	$0900,$5FE0,$E003,$084D,$0000,$0308,$5100,$E809
	dc.w	$0855,$08F8,$0508,$5B08,$0809,$085F,$0800,$04F4
	dc.w	$0000,$00D8,$F40E,$0001,$E0F4,$0008,$0020,$F40E
	dc.w	$0801,$0000
PB8_sub_20B834:
	movea.l $32(a0), a1
	moveq   #$0, d1
	move.b  $1a(a1), d1
	move.b  PB8_dat_20B84A(pc, d1.w), d1
	lsl.w   #$8, d1
	move.w  d1, oYVel(a0)
	rts     
PB8_dat_20B84A:
	dc.w	$0008,$1008,$0000
