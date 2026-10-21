; Object $BB - Obj26_20E1C0 (from R82A, old ID $26)
PBB_Obj26_20E1C0:
	tst.b   oSubtype(a0)
	bne.w   PBB_loc_20E482
	moveq   #$0, d0
	move.b  $2a(a0), d0
	move.w  PBB_dat_20E1D6(pc, d0.w), d0
	jmp     PBB_dat_20E1D6(pc, d0.w)
PBB_dat_20E1D6:
	dc.w	PBB_loc_20E1E0-PBB_dat_20E1D6
	dc.w	PBB_loc_20E268-PBB_dat_20E1D6
	dc.w	PBB_loc_20E2D6-PBB_dat_20E1D6
	dc.w	PBB_loc_20E2DC-PBB_dat_20E1D6
	dc.w	PBB_loc_20E2EE-PBB_dat_20E1D6
PBB_loc_20E1E0:
	lea     $2e(a0), a6
	move.w  oX(a0), d4
	moveq   #$8, d5
	moveq   #$8, d6
	movea.w a0, a1
	bra.s   PBB_loc_20E230
PBB_loc_20E1F0:
	jsr     FindObjSlot.l
	bne.w   PBB_loc_20E490
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$1, $28(a1)
	move.b  #$3, $18(a1)
	move.b  #$1, $1a(a1)
	move.b  #$4, $17(a1)
	move.b  #$4, $19(a1)
	move.b  #$4, $16(a1)
	move.w  oY(a0), $c(a1)
	add.w   d5, d4
	move.w  d4, $8(a1)
PBB_loc_20E230:
	move.w  a1, (a6)+
	move.w  a0, $2e(a1)
	ori.b   #$4, $1(a1)
	move.w  #$318, $2(a1)
	move.l  #$20e496, $4(a1)
	dbra    d6, PBB_loc_20E1F0
	bsr.w   PBB_sub_20E2F8
	movea.w a0, a1
	bsr.w   PBB_sub_20E2F8
	addq.b  #$2, $2a(a0)
	move.b  #$c, $2b(a0)
	move.w  #$8000, $2c(a0)
PBB_loc_20E268:
	move.w  a0, -(a7)
	movea.w $3e(a0), a0
	bsr.w   PBB_sub_20E318
	movea.w (a7)+, a0
	bsr.w   PBB_sub_20E3B6
PBB_loc_20E278:
	move.w  a0, -(a7)
	movea.w (a7), a0
	movea.w $30(a0), a0
	jsr     DrawObject.l
	movea.w (a7), a0
	movea.w $32(a0), a0
	jsr     DrawObject.l
	movea.w (a7), a0
	movea.w $34(a0), a0
	jsr     DrawObject.l
	movea.w (a7), a0
	movea.w $36(a0), a0
	jsr     DrawObject.l
	movea.w (a7), a0
	movea.w $38(a0), a0
	jsr     DrawObject.l
	movea.w (a7), a0
	movea.w $3a(a0), a0
	jsr     DrawObject.l
	movea.w (a7), a0
	movea.w $3c(a0), a0
	jsr     DrawObject.l
	movea.w (a7)+, a0
	jmp     CheckObjDespawn.l
PBB_loc_20E2D6:
	move.b  #$6, $2a(a0)
PBB_loc_20E2DC:
	bsr.w   PBB_sub_20E318
	move.w  a0, -(a7)
	movea.w $3e(a0), a0
	bsr.w   PBB_sub_20E3B6
	movea.w (a7)+, a0
	bra.s   PBB_loc_20E278
PBB_loc_20E2EE:
	move.b  #$2, $2a(a0)
	bra.w   PBB_loc_20E268
PBB_sub_20E2F8:
	move.b  #$0, $1a(a1)
	move.b  #$4, $18(a1)
	move.b  #$18, $17(a1)
	move.b  #$18, $19(a1)
	move.b  #$29, $16(a1)
	rts     
PBB_sub_20E318:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PBB_dat_20E326(pc, d0.w), d0
	jmp     PBB_dat_20E326(pc, d0.w)
PBB_sub_20E3B6:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PBB_dat_20E3C4(pc, d0.w), d0
	jmp     PBB_dat_20E3C4(pc, d0.w)
PBB_dat_20E326:
	dc.w	PBB_loc_20E32C-PBB_dat_20E326
	dc.w	PBB_loc_20E33C-PBB_dat_20E326
	dc.w	PBB_loc_20E34C-PBB_dat_20E326
PBB_loc_20E32C:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	jmp     DrawObject.l
PBB_loc_20E33C:
	addq.b  #$2, oRoutine(a0)
	move.w  #$8000, oYScr(a0)
	move.w  #$8000, oYSub(a0)
PBB_loc_20E34C:
	movea.w $2e(a0), a1
	addi.w  #$200, $2c(a1)
	lea     $30(a1), a6
	moveq   #$6, d6
	move.l  oX(a0), d5
	move.l  oY(a0), d4
	moveq   #$0, d1
	moveq   #$0, d0
	move.b  $2c(a1), d0
	jsr     CalcSine.l
	swap    d1
	swap    d0
	asr.l   #$5, d1
	asr.l   #$5, d0
PBB_loc_20E37A:
	movea.w (a6)+, a5
	add.l   d1, d5
	add.l   d0, d4
	move.l  d5, $8(a5)
	move.l  d4, $c(a5)
	dbra    d6, PBB_loc_20E37A
	movea.w $3e(a1), a5
	tst.b   oSubtype(a0)
	beq.s   PBB_loc_20E39A
	movea.w $2e(a1), a5
PBB_loc_20E39A:
	move.l  $8(a5), d3
	add.l   d1, d5
	add.l   d0, d4
	move.l  d5, $8(a5)
	move.l  d4, $c(a5)
	sub.l   d3, d5
	asr.l   #$8, d5
	move.w  d5, $10(a5)
	bra.w   PBB_loc_20E32C
PBB_dat_20E3C4:
	dc.w	PBB_loc_20E3C8-PBB_dat_20E3C4
	dc.w	PBB_loc_20E3F8-PBB_dat_20E3C4
PBB_loc_20E3C8:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	beq.s   PBB_loc_20E3F2
	movea.w $2e(a0), a1
	tst.b   $2b(a1)
	beq.s   PBB_loc_20E3F2
	subq.b  #$1, $2b(a1)
	movea.w $2e(a1), a2
	movea.w $3e(a1), a3
	addq.b  #$2, $24(a2)
	addq.b  #$2, $24(a3)
PBB_loc_20E3F2:
	jmp     DrawObject.l
PBB_loc_20E3F8:
	lea     objects.w, a1
	bsr.w   PBB_sub_20E454
	jsr     DrawObject.l
	movea.w $2e(a0), a1
	move.w  $2c(a1), d0
	addi.w  #$4000, d0
	bmi.s   PBB_loc_20E452
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   PBB_loc_20E452
	addq.w  #$2, d1
	add.w   d1, oY(a0)
	movea.w $2e(a0), a1
	addq.b  #$2, $2a(a1)
	addi.w  #$8000, $2c(a1)
	movea.w $2e(a1), a2
	movea.w $3e(a1), a3
	clr.b   $24(a2)
	clr.b   $24(a3)
	clr.w   $10(a2)
	clr.w   $10(a3)
	clr.w   $12(a2)
	clr.w   $12(a3)
PBB_loc_20E452:
	rts     
PBB_sub_20E454:
	move.w  oXVel(a0), -(a7)
	move.w  #$0, oXVel(a0)
	move.b  #$2b, oYRadius(a0)
	jsr     TopSolidObject.l
	sne.b   d0
	move.w  (a7)+, oXVel(a0)
	move.b  #$29, oYRadius(a0)
	tst.b   d0
	beq.s   PBB_loc_20E480
	jmp     TopSolidObject.l
PBB_loc_20E480:
	rts     
PBB_loc_20E482:
	movea.w $2e(a0), a1
	dc.b	$0C,$29,$00,$26,$00,$00		; cmpi.b #$26, $0(a1) (raw: not reproducible by assembler)
	bne.s   PBB_loc_20E490
	rts     
PBB_loc_20E490:
	jmp     DeleteObject.l
PBB_loc_20E496:
	dc.w	$0004,$003C,$0BFC,$0000,$10FC,$D809,$0000,$E8D8
	dc.w	$0908,$0000,$E801,$0006,$F8E8,$0108,$0600,$F801
	dc.w	$0008,$F8F8,$0108,$0800,$0801,$0006,$F808,$0108
	dc.w	$0600,$1809,$000A,$E818,$0908,$0A00,$01FC,$0000
	dc.w	$10FC
