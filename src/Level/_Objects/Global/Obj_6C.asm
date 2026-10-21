; Object $6C - Obj27_20E32C (from R51A, old ID $27)
P6C_Obj27_20E32C:
	tst.b   oRoutine(a0)
	bne.w   P6C_loc_20E3EA
	lea     P6C_dat_20E48E(pc), a1
	moveq   #$0, d0
	move.b  timeZone.l, d0
	add.w   d0, d0
	add.w   d0, d0
	move.w  (a1, d0.w), d1
	movea.w $2(a1, d0.w), a5
	tst.b   oSubtype(a0)
	beq.s   P6C_loc_20E354
	neg.w   d1
P6C_loc_20E354:
	move.w  d1, $36(a0)
	moveq   #$3, d6
	moveq   #$0, d5
	moveq   #$0, d4
	moveq   #$0, d3
	movea.w a0, a1
	bra.s   P6C_loc_20E370
P6C_loc_20E364:
	moveq   #$0, d5
	move.w  d4, d3
P6C_loc_20E368:
	jsr     FindObjSlot.l
	bne.s   P6C_loc_20E388
P6C_loc_20E370:
	bsr.s   P6C_sub_20E38E
	move.w  d3, $34(a1)
	addi.w  #$800, d3
	addq.w  #$1, d5
	cmp.w   a5, d5
	ble.s   P6C_loc_20E368
	addi.w  #$4000, d4
	dbra    d6, P6C_loc_20E364
P6C_loc_20E388:
	clr.w   $2a(a0)
	rts     
P6C_dat_20E48E:
	dc.w	$0080,$0001,$00C0,$0001,$0100,$0001
P6C_loc_20E49A:
	dc.w	$0002,$01F8,$0500,$00F8
P6C_sub_20E38E:
	move.w  a0, $2a(a1)
	ori.b   #$4, $1(a1)
	move.b  #$2, $24(a1)
	move.b  #$3, $18(a1)
	move.b  #$8, $17(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	move.w  #$4300, $2(a1)
	move.l  #$20e49a, $4(a1)
	dc.b	$33,$68,$00,$00,$00,$00		; move.w oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.l  oX(a0), $2c(a1)
	move.l  oY(a0), $30(a1)
	move.w  $36(a0), $36(a1)
	rts     
P6C_loc_20E3EA:
	move.w  $2a(a0), d0
	beq.s   P6C_loc_20E400
	movea.w d0, a1
	dc.b	$0C,$29,$00,$27,$00,$00		; cmpi.b #$27, $0(a1) (raw: not reproducible by assembler)
	beq.s   P6C_loc_20E400
	jmp     DeleteObject.l
P6C_loc_20E400:
	move.w  $36(a0), d0
	add.w   d0, $34(a0)
	moveq   #$0, d1
	moveq   #$0, d0
	move.b  $34(a0), d0
	jsr     CalcSine.l
	swap    d1
	swap    d0
	asr.l   #$2, d1
	asr.l   #$2, d0
	move.l  d1, d5
	move.l  d0, d4
	asr.l   #$1, d5
	asr.l   #$1, d4
	add.l   d1, d5
	add.l   d0, d4
	add.l   $2c(a0), d5
	add.l   $30(a0), d4
	move.l  oX(a0), d3
	move.l  d5, oX(a0)
	move.l  d4, oY(a0)
	sub.l   d3, d5
	asr.l   #$8, d5
	move.w  d5, oXVel(a0)
	lea     objects.w, a1
	move.w  oXVel(a0), -(a7)
	move.w  #$0, oXVel(a0)
	move.b  #$a, oYRadius(a0)
	jsr     SolidObject.l
	sne.b   d0
	move.w  (a7)+, oXVel(a0)
	move.b  #$8, oYRadius(a0)
	tst.b   d0
	beq.s   P6C_loc_20E476
	jsr     SolidObject.l
P6C_loc_20E476:
	jsr     DrawObject.l
	tst.w   $2a(a0)
	bne.s   P6C_loc_20E48C
	move.w  $2c(a0), d0
	jmp     CheckObjDespawn2.l
P6C_loc_20E48C:
	rts     
