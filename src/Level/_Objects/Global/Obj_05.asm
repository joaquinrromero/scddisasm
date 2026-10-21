; Object $05 - Obj05_2069EC (from R42A, old ID $05)
P05_Obj05_2069EC:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P05_dat_206A06(pc, d0.w), d0
	jsr     P05_dat_206A06(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P05_dat_206A06:
	dc.w	P05_loc_206A0E-P05_dat_206A06
	dc.w	P05_loc_206A26-P05_dat_206A06
	dc.w	P05_loc_206A7C-P05_dat_206A06
	dc.w	P05_loc_206ADC-P05_dat_206A06
P05_loc_206A0E:
	ori.b   #$4, oSprFlags(a0)
	move.w  #$42f8, oTile(a0)
	move.l  #$206b18, oMap(a0)
	addq.b  #$2, oRoutine(a0)
P05_loc_206A26:
	bsr.w   P05_sub_206ADE
	beq.s   P05_loc_206A7A
	bset.b  #$0, $2c(a1)
	move.w  oX(a0), $8(a1)
	moveq   #$0, d1
	move.w  #$18, d0
	tst.w   $10(a1)
	bpl.s   P05_loc_206A48
	moveq   #$1, d1
	neg.w   d0
P05_loc_206A48:
	andi.b  #$fe, $22(a1)
	or.b    d1, $22(a1)
	or.b    d1, oSprFlags(a0)
	add.w   d0, $8(a1)
	move.b  #$11, $1c(a1)
	move.w  #$b4, $2a(a0)
	tst.b   oSubtype(a0)
	beq.s   P05_loc_206A72
	move.w  #$3c, $2a(a0)
P05_loc_206A72:
	move.l  a1, $2c(a0)
	addq.b  #$2, oRoutine(a0)
P05_loc_206A7A:
	rts     
P05_loc_206A7C:
	movea.l $2c(a0), a1
	subq.w  #$1, $2a(a0)
	beq.s   P05_loc_206ACC
	move.w  p1CtrlData.w, d0
	move.w  d0, d1
	andi.b  #$70, d0
	bne.s   P05_loc_206ACC
	move.w  oY(a0), d0
	lsr.w   #$8, d1
	btst.l  #$0, d1
	beq.s   P05_loc_206AB2
	subq.w  #$1, $c(a1)
	subi.w  #$18, d0
	cmp.w   $c(a1), d0
	bcs.s   P05_loc_206ADC
	move.w  d0, $c(a1)
	bra.s   P05_loc_206ADC
P05_loc_206AB2:
	btst.l  #$1, d1
	beq.s   P05_loc_206ADC
	addq.w  #$1, $c(a1)
	addi.w  #$18, d0
	cmp.w   $c(a1), d0
	bcc.s   P05_loc_206ADC
	move.w  d0, $c(a1)
	bra.s   P05_loc_206ADC
P05_loc_206ACC:
	bclr.b  #$0, $2c(a1)
	move.b  #$1, oMapFrame(a0)
	addq.b  #$2, oRoutine(a0)
P05_loc_206ADC:
	rts     
P05_sub_206ADE:
	lea     objects.w, a1
	tst.b   debugMode.l
	bne.s   P05_loc_206B14
	move.w  oX(a0), d0
	sub.w   $8(a1), d0
	addq.w  #$4, d0
	bmi.s   P05_loc_206B14
	cmpi.w  #$8, d0
	bcc.s   P05_loc_206B14
	move.w  oY(a0), d0
	sub.w   $c(a1), d0
	addi.w  #$18, d0
	bmi.s   P05_loc_206B14
	cmpi.w  #$30, d0
	bcc.s   P05_loc_206B14
	moveq   #$1, d0
	rts     
P05_loc_206B14:
	moveq   #$0, d0
	rts     
P05_loc_206B18:
	dc.w	$0004,$0024,$06D2,$0110,$00FC,$E001,$0002,$FCF0
	dc.w	$0100,$02FC,$0001,$0002,$FC10,$0100,$02FC,$1E01
	dc.w	$0000,$FC00,$06D2,$0110,$00FC,$E001,$0002,$FCF0
	dc.w	$0510,$04FC,$0005,$0004,$FC10,$0100,$02FC,$1E01
	dc.w	$0000,$FC00
