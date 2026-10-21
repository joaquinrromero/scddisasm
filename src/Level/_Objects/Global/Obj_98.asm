; Object $98 - Obj2F_20C57C (from R51A, old ID $2F)
Obj2F_20C57C:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P98_dat_20C590(pc, d0.w), d0
	jsr     P98_dat_20C590(pc, d0.w)
	jmp     DrawObject.l
P98_dat_20C590:
	dc.w	P98_loc_20C596-P98_dat_20C590
	dc.w	P98_loc_20C686-P98_dat_20C590
	dc.w	P98_loc_20C66C-P98_dat_20C590
P98_loc_20C596:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$4300, oTile(a0)
	move.l  #$20ca80, oMap(a0)
	move.w  oX(a0), $36(a0)
	move.w  oY(a0), $32(a0)
	move.b  #$40, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.b  #$1, oMapFrame(a0)
	lea     $2a(a0), a2
	moveq   #$7, d1
P98_loc_20C5D8:
	jsr     FindObjSlot.l
	bne.w   P98_loc_20C656
	move.w  a1, d0
	subi.w  #$d800, d0
	lsr.w   #$6, d0
	andi.b  #$7f, d0
	move.b  d0, (a2)+
	dc.b	$13,$7C,$00,$2F,$00,$00		; move.b #$2f, $0(a1) (raw: not reproducible by assembler)
	move.b  #$4, $24(a1)
	move.w  oX(a0), $36(a1)
	move.w  oY(a0), $32(a1)
	move.w  oY(a0), $c(a1)
	ori.b   #$4, $1(a1)
	move.b  #$3, $18(a1)
	move.w  #$4300, $2(a1)
	move.l  #$20ca80, $4(a1)
	move.b  #$8, $16(a1)
	move.b  #$8, $19(a1)
	move.w  a0, $34(a1)
	move.b  #$ff, $3f(a1)
	moveq   #$0, d2
	move.b  d1, d2
	move.b  d2, $3c(a1)
	add.w   d2, d2
	lea     P98_dat_20C65C(pc, d2.w), a3
	move.w  (a3)+, d2
	add.w   oX(a0), d2
	move.w  d2, $8(a1)
P98_loc_20C656:
	dbra    d1, P98_loc_20C5D8
	rts     
P98_dat_20C65C:
	dc.w	$0030,$0020,$0010,$0000,$FFF0,$FFE0,$FFD0,$FFC0
P98_loc_20C66C:
	movea.w $34(a0), a1
	dc.b	$0C,$29,$00,$2F,$00,$00		; cmpi.b #$2f, $0(a1) (raw: not reproducible by assembler)
	bne.s   P98_loc_20C680
	tst.b   $3f(a1)
	bne.s   P98_loc_20C680
	rts     
P98_loc_20C680:
	jmp     DeleteObject.l
P98_loc_20C686:
	clr.b   $3d(a0)
	bsr.w   P98_sub_20C9E6
	beq.s   P98_loc_20C694
	bsr.w   P98_sub_20C6CE
P98_loc_20C694:
	tst.b   $3d(a0)
	beq.w   P98_loc_20C6BA
	move.b  $3a(a0), d0
	cmpi.b  #$40, d0
	beq.s   P98_loc_20C6AA
	addq.b  #$4, $3a(a0)
P98_loc_20C6AA:
	bsr.w   P98_sub_20C72E
	tst.b   $3d(a0)
	beq.s   P98_loc_20C6B8
	bsr.w   P98_sub_20C702
P98_loc_20C6B8:
	bra.s   P98_loc_20C6C8
P98_loc_20C6BA:
	tst.b   $3a(a0)
	beq.s   P98_loc_20C6C8
	subq.b  #$4, $3a(a0)
	bsr.w   P98_sub_20C72E
P98_loc_20C6C8:
	jmp     CheckObjDespawn.l
P98_sub_20C9E6:
	lea     objects.w, a1
	cmpi.b  #$6, $24(a1)
	beq.w   P98_loc_20CA60
	tst.b   debugMode.l
	bne.s   P98_loc_20CA60
	moveq   #$8, d1
	lsl.w   #$3, d1
	move.w  d1, d2
	addq.w  #$8, d1
	add.w   d2, d2
	tst.w   $12(a1)
	bmi.w   P98_loc_20CA60
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	add.w   d1, d0
	bmi.w   P98_loc_20CA60
	cmp.w   d2, d0
	bcc.w   P98_loc_20CA60
	move.w  oY(a0), d0
	subq.w  #$8, d0
	move.w  $c(a1), d2
	move.b  $16(a1), d1
	ext.w   d1
	add.w   d2, d1
	addq.w  #$4, d1
	sub.w   d1, d0
	bhi.w   P98_loc_20CA60
	cmpi.w  #$fff0, d0
	bcs.w   P98_loc_20CA60
	cmpi.b  #$6, $24(a1)
	bcc.w   P98_loc_20CA60
	add.w   d0, d2
	addq.w  #$3, d2
	move.w  d2, $c(a1)
	jsr     StandOnObject.l
	moveq   #$ff, d0
	rts     
P98_loc_20CA60:
	moveq   #$0, d0
	move.b  $3d(a1), d0
	lsl.w   #$6, d0
	addi.l  #$ffd000, d0
	cmpa.w  d0, a0
	bne.s   P98_loc_20CA7C
	clr.b   $38(a1)
	bclr.b  #$3, $22(a1)
P98_loc_20CA7C:
	moveq   #$0, d0
	rts     
P98_loc_20CA80:
	dc.w	$0006,$000C,$000E,$01F8,$0500,$00F8,$0000,$08F8
	dc.w	$0500,$00B8,$F805,$0000,$C8F8,$0500,$00D8,$F805
	dc.w	$0000,$E8F8,$0500,$00F8,$F805,$0000,$08F8,$0500
	dc.w	$0018,$F805,$0000,$2800
P98_sub_20C6CE:
	lea     objects.w, a1
	moveq   #$8, d1
	lsl.w   #$3, d1
	move.w  d1, d2
	addq.w  #$8, d1
	add.w   d2, d2
	btst.b  #$1, $22(a1)
	bne.s   P98_loc_20C6F4
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	add.w   d1, d0
	bmi.s   P98_loc_20C6F4
	cmp.w   d2, d0
	bcs.s   P98_loc_20C6FA
P98_loc_20C6F4:
	clr.b   $3d(a0)
	rts     
P98_loc_20C6FA:
	lsr.w   #$4, d0
	move.b  d0, $3d(a0)
	rts     
P98_sub_20C72E:
	moveq   #$0, d3
	move.b  $3d(a0), d3
	move.b  $3a(a0), d0
	jsr     CalcSine.l
	move.w  d0, d4
	lea     P98_loc_20C8E6.l, a4
	moveq   #$8, d0
	lsl.w   #$4, d0
	move.w  d3, d2
	add.w   d0, d3
	moveq   #$0, d5
	lea     P98_loc_20C7D6.l, a5
	move.b  (a5, d3.w), d5
	andi.w  #$f, d3
	lsl.w   #$4, d3
	lea     (a4, d3.w), a3
	lea     $2a(a0), a2
P98_loc_20C768:
	moveq   #$0, d0
	move.b  (a2)+, d0
	lsl.w   #$6, d0
	addi.l  #$ffd800, d0
	movea.l d0, a1
	moveq   #$0, d0
	move.b  (a3)+, d0
	addq.w  #$1, d0
	mulu.w  d5, d0
	mulu.w  d4, d0
	swap    d0
	add.w   $32(a1), d0
	move.w  d0, $c(a1)
	dbra    d2, P98_loc_20C768
	moveq   #$0, d3
	move.b  $3d(a0), d3
	moveq   #$8, d0
	addq.b  #$1, d3
	sub.b   d0, d3
	neg.b   d3
	bmi.s   P98_loc_20C7D4
	move.w  d3, d2
	lsl.w   #$4, d3
	lea     (a4, d3.w), a3
	adda.w  d2, a3
	subq.w  #$1, d2
	bcs.s   P98_loc_20C7D4
P98_loc_20C7AC:
	moveq   #$0, d0
	move.b  (a2)+, d0
	lsl.w   #$6, d0
	addi.l  #$ffd800, d0
	movea.l d0, a1
	moveq   #$0, d0
	move.b  -(a3), d0
	addq.w  #$1, d0
	mulu.w  d5, d0
	mulu.w  d4, d0
	add.w   d0, d0
	swap    d0
	add.w   $32(a1), d0
	move.w  d0, $c(a1)
	dbra    d2, P98_loc_20C7AC
P98_loc_20C7D4:
	rts     
P98_loc_20C7D6:
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0200,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0202,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0204,$0200,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0204,$0402,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0204,$0604,$0200,$0000,$0000,$0000,$0000,$0000
	dc.w	$0204,$0606,$0402,$0000,$0000,$0000,$0000,$0000
	dc.w	$0204,$0608,$0604,$0200,$0000,$0000,$0000,$0000
	dc.w	$0204,$0608,$0806,$0402,$0000,$0000,$0000,$0000
	dc.w	$0204,$0608,$0A08,$0604,$0200,$0000,$0000,$0000
	dc.w	$0204,$0608,$0A0A,$0806,$0402,$0000,$0000,$0000
	dc.w	$0204,$0608,$0A0C,$0A08,$0604,$0200,$0000,$0000
	dc.w	$0204,$0608,$0A0C,$0C0A,$0806,$0402,$0000,$0000
	dc.w	$0204,$0608,$0A0C,$0E0C,$0A08,$0604,$0200,$0000
	dc.w	$0204,$0608,$0A0C,$0E0E,$0C0A,$0806,$0402,$0000
	dc.w	$0204,$0608,$0A0C,$0E10,$0E0C,$0A08,$0604,$0200
	dc.w	$0204,$0608,$0A0C,$0E10,$100E,$0C0A,$0806,$0402
P98_loc_20C8E6:
	dc.w	$FF00,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$B5FF,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$7EDB,$FF00,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$61B5,$ECFF,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$4A93,$CDF3,$FF00,$0000,$0000,$0000,$0000,$0000
	dc.w	$3E7E,$B0DB,$F6FF,$0000,$0000,$0000,$0000,$0000
	dc.w	$386D,$9DC5,$E4F8,$FF00,$0000,$0000,$0000,$0000
	dc.w	$3161,$8EB5,$D4EC,$FBFF,$0000,$0000,$0000,$0000
	dc.w	$2B56,$7EA2,$C1DB,$EEFB,$FF00,$0000,$0000,$0000
	dc.w	$254A,$7393,$B0CD,$E1F3,$FCFF,$0000,$0000,$0000
	dc.w	$1F44,$6788,$A7BD,$D4E7,$F4FD,$FF00,$0000,$0000
	dc.w	$1F3E,$5C7E,$98B0,$C9DB,$EAF6,$FDFF,$0000,$0000
	dc.w	$1938,$5673,$8EA7,$BDD1,$E1EE,$F8FE,$FF00,$0000
	dc.w	$1938,$506D,$839D,$B0C5,$D8E4,$F1F8,$FEFF,$0000
	dc.w	$1931,$4A67,$7E93,$A7BD,$CDDB,$E7F3,$F9FE,$FF00
	dc.w	$1931,$4A61,$788E,$A2B5,$C5D4,$E1EC,$F4FB,$FEFF
P98_sub_20C702:
	lea     objects.w, a1
	moveq   #$0, d0
	move.b  $3d(a0), d0
	move.b  $2a(a0, d0.w), d0
	lsl.w   #$6, d0
	addi.l  #$ffd800, d0
	movea.l d0, a2
	move.w  $c(a2), d0
	subq.w  #$8, d0
	moveq   #$0, d1
	move.b  $16(a1), d1
	sub.w   d1, d0
	move.w  d0, $c(a1)
	rts     
