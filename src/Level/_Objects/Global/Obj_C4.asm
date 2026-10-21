; Object $C4 - Obj20_20F0DC (from R82A, old ID $20)
PC4_Obj20_20F0DC:
	tst.b   oLayer(a0)
	bmi.w   PC4_loc_20F21C
	tst.b   oSubtype(a0)
	bpl.s   PC4_loc_20F0F8
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$20,$00,$00		; cmpi.b #$20, $0(a1) (raw: not reproducible by assembler)
	bne.w   PC4_loc_20F38C
PC4_loc_20F0F8:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PC4_dat_20F11E(pc, d0.w), d0
	jsr     PC4_dat_20F11E(pc, d0.w)
	jsr     DrawObject.l
	tst.b   oSubtype(a0)
	bmi.s   PC4_loc_20F11C
	move.w  $2a(a0), d0
	jmp     CheckObjDespawn2.l
PC4_loc_20F11C:
	rts     
PC4_dat_20F11E:
	dc.w	PC4_loc_20F126-PC4_dat_20F11E
	dc.w	PC4_loc_20F13E-PC4_dat_20F11E
	dc.w	PC4_loc_20F160-PC4_dat_20F11E
	dc.w	PC4_loc_20F20A-PC4_dat_20F11E
PC4_loc_20F126:
	move.w  oX(a0), $2a(a0)
	movea.l a0, a6
	bsr.w   PC4_sub_20F1D0
	move.b  #$2, oRoutine(a0)
	move.b  #$5, oMapFrame(a0)
PC4_loc_20F13E:
	lea     objects.w, a1
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	subi.w  #$fec0, d0
	subi.w  #$280, d0
	bcc.s   PC4_loc_20F15E
	addq.b  #$2, oRoutine(a0)
	move.b  #$0, oMapFrame(a0)
PC4_loc_20F15E:
	rts     
PC4_loc_20F160:
	jsr     FindObjSlot.l
	bne.w   PC4_loc_20F38C
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.w  a0, $3e(a1)
	move.b  #$ff, $28(a1)
	move.w  oX(a0), $8(a1)
	addi.w  #$30, $8(a1)
	bchg.b  #$0, $1(a1)
	bchg.b  #$0, $22(a1)
	lea     (a0), a6
	bsr.s   PC4_sub_20F1D0
	lea     (a1), a6
	bsr.s   PC4_sub_20F1D0
	jsr     FindObjSlot.l
	bne.w   PC4_loc_20F38C
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  oSubtype(a0), $28(a1)
	move.b  #$ff, $29(a1)
	move.w  oX(a0), $8(a1)
	addi.w  #$18, $8(a1)
	move.w  oY(a0), $c(a1)
	move.w  a0, $3e(a1)
	bra.w   PC4_loc_20F20A
PC4_sub_20F1D0:
	move.b  #$6, $24(a6)
	ori.b   #$4, $1(a6)
	move.b  #$3, $18(a6)
	move.w  #$33c, $2(a6)
	move.b  #$8, $17(a6)
	move.b  #$8, $19(a6)
	move.b  #$4, $16(a6)
	move.l  #$20f3a8, $4(a6)
	move.w  oY(a0), $c(a6)
	rts     
PC4_loc_20F20A:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	lea     objects.w, a1
	jmp     TopSolidObject.l
PC4_loc_20F21C:
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$20,$00,$00		; cmpi.b #$20, $0(a1) (raw: not reproducible by assembler)
	bne.w   PC4_loc_20F38C
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PC4_dat_20F23E(pc, d0.w), d0
	jsr     PC4_dat_20F23E(pc, d0.w)
	jmp     DrawObject.l
PC4_dat_20F23E:
	dc.w	PC4_loc_20F24C-PC4_dat_20F23E
	dc.w	PC4_loc_20F27C-PC4_dat_20F23E
	dc.w	PC4_loc_20F296-PC4_dat_20F23E
	dc.w	PC4_loc_20F2E6-PC4_dat_20F23E
	dc.w	PC4_loc_20F2FA-PC4_dat_20F23E
	dc.w	PC4_loc_20F31A-PC4_dat_20F23E
	dc.w	PC4_loc_20F346-PC4_dat_20F23E
PC4_loc_20F24C:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.w  #$33c, oTile(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$4, oYRadius(a0)
	move.l  #$20f3a8, oMap(a0)
PC4_loc_20F27C:
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, oMapFrame(a0)
	lea     switchFlags.w, a1
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	bclr.b  #$6, (a1, d0.w)
PC4_loc_20F296:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	lea     switchFlags.w, a2
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	tst.b   (a2, d0.w)
	bpl.s   PC4_loc_20F2B2
	bra.s   PC4_loc_20F2CE
PC4_loc_20F2B2:
	move.w  #$fff8, d0
	move.w  #$10, d1
	move.w  #$fffd, d2
	move.w  #$7b, d3
	lea     objects.w, a6
	bsr.w   PC4_sub_20F36A
	bcs.s   PC4_loc_20F2DA
	rts     
PC4_loc_20F2CE:
	addq.b  #$2, oRoutine(a0)
	move.w  #$5, $2a(a0)
	rts     
PC4_loc_20F2DA:
	addq.b  #$6, oRoutine(a0)
	move.w  #$5, oMapFrame(a0)
	rts     
PC4_loc_20F2E6:
	subq.w  #$1, $2a(a0)
	bpl.s   PC4_loc_20F2F0
	addq.b  #$2, oRoutine(a0)
PC4_loc_20F2F0:
	lea     PC4_dat_20F392(pc), a1
	jmp     AnimateObject.l
PC4_loc_20F2FA:
	lea     objects.w, a6
	move.w  #$ff00, d0
	move.w  #$200, d1
	move.w  #$ff60, d2
	move.w  #$140, d3
	bsr.s   PC4_sub_20F370
	bcc.s   PC4_loc_20F314
	rts     
PC4_loc_20F314:
	subq.b  #$6, oRoutine(a0)
	rts     
PC4_loc_20F31A:
	move.w  #$fff8, d0
	move.w  #$10, d1
	move.w  #$ff88, d2
	move.w  #$74, d3
	lea     objects.w, a6
	bsr.s   PC4_sub_20F36A
	bcs.s   PC4_loc_20F334
	rts     
PC4_loc_20F334:
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, oAnim(a0)
	move.w  #$7, $2a(a0)
	rts     
PC4_loc_20F346:
	subq.w  #$1, $2a(a0)
	bpl.s   PC4_loc_20F360
	subi.b  #$a, oRoutine(a0)
	move.b  #$0, oAnim(a0)
	move.b  #$1, oMapFrame(a0)
	rts     
PC4_loc_20F360:
	lea     PC4_dat_20F392(pc), a1
	jmp     AnimateObject.l
PC4_sub_20F36A:
	tst.w   $12(a6)
	bpl.s   PC4_loc_20F38A
PC4_dat_20F392:
	dc.w	$0004,$000C,$0001,$0203,$0405,$05FF,$0004,$0403
	dc.w	$0302,$0201,$01FF
PC4_loc_20F3A8:
	dc.w	$000C,$0012,$001D,$0028,$0033,$003E,$01FC,$0440
	dc.w	$00F8,$02FC,$0400,$02F0,$FC04,$0802,$0002,$FC04
	dc.w	$0002,$ECFC,$0408,$0204,$02FC,$0400,$02E8,$FC04
	dc.w	$0802,$0802,$FC04,$0002,$E4FC,$0408,$020C,$0000
PC4_sub_20F370:
	move.w  $c(a6), d4
	sub.w   oY(a0), d4
	sub.w   d2, d4
	sub.w   d3, d4
	bcc.s   PC4_loc_20F38A
	move.w  $8(a6), d4
	sub.w   oX(a0), d4
	sub.w   d0, d4
	sub.w   d1, d4
PC4_loc_20F38A:
	rts     
PC4_loc_20F38C:
	jmp     DeleteObject.l
