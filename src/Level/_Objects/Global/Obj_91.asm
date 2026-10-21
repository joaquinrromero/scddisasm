; Object $91 - Obj3D_20D2A0 (from R83C, old ID $3D)
Obj3D_20D2A0:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P91_dat_20D2BA(pc, d0.w), d0
	jsr     P91_dat_20D2BA(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P91_dat_20D2BA:
	dc.w	P91_loc_20D2C0-P91_dat_20D2BA
	dc.w	P91_loc_20D328-P91_dat_20D2BA
	dc.w	P91_loc_20D33A-P91_dat_20D2BA
P91_loc_20D2C0:
	move.w  oX(a0), $2a(a0)
	movea.l a0, a1
	move.b  #$1, oSubtype(a0)
	bset.b  #$0, oSprFlags(a0)
	bsr.s   P91_sub_20D2E2
	bsr.w   FindObjSlot
	beq.s   P91_sub_20D2E2
	jmp     DespawnObject.l
P91_sub_20D2E2:
	dc.b	$13,$7C,$00,$3D,$00,$00		; move.b #$3d, $0(a1) (raw: not reproducible by assembler)
	move.w  $2a(a0), $2a(a1)
	move.w  $2a(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	moveq   #$8, d0
	tst.b   $28(a1)
	beq.s   P91_loc_20D304
	neg.w   d0
P91_loc_20D304:
	add.w   d0, $8(a1)
	addq.b  #$2, $24(a1)
	ori.b   #$4, $1(a1)
	move.b  #$2, $18(a1)
	move.l  #$20d67e, $4(a1)
	move.w  #$8797, $2(a1)
	rts     
P91_loc_20D328:
	tst.b   bossFight.w
	bpl.s   P91_loc_20D338
	clr.b   $ff1959.l
	addq.b  #$2, oRoutine(a0)
P91_loc_20D338:
	rts     
P91_loc_20D33A:
	move.w  oX(a0), d1
	subq.w  #$8, d1
	move.w  d1, d5
	andi.w  #$f, d1
	bne.s   P91_loc_20D37C
	addq.b  #$1, $2c(a0)
	cmpi.b  #$11, $2c(a0)
	bcs.s   P91_loc_20D35A
	jmp     DespawnObject.l
P91_loc_20D35A:
	moveq   #$0, d3
	move.w  oY(a0), d4
	subi.w  #$60, d4
	movem.l d0-d7/a0-a6, -(a7)
	moveq   #$b, d6
P91_loc_20D36A:
	jsr     PlaceBlockAtPos.l
	addi.w  #$10, d4
	dbra    d6, P91_loc_20D36A
	movem.l (a7)+, d0-d7/a0-a6
P91_loc_20D37C:
	addq.w  #$2, oX(a0)
	tst.b   oSubtype(a0)
	beq.s   P91_loc_20D38A
	subq.w  #$4, oX(a0)
P91_loc_20D38A:
	rts     
