; Object $6D - Obj29_20E802 (from R51A, old ID $29)
P6D_Obj29_20E802:
	tst.b   oRoutine(a0)
	bne.w   P6D_loc_20E8BC
	move.w  oX(a0), d0
	move.w  d0, $2c(a0)
	swap    d0
	clr.w   d0
	subi.l  #$800000, d0
	move.l  d0, $2e(a0)
	addi.l  #$1000000, d0
	move.l  d0, $32(a0)
	moveq   #$1, d6
	move.w  oX(a0), d5
	addi.w  #$40, d5
	move.w  #$80, d4
	move.w  #$8000, d3
	tst.b   oSubtype(a0)
	beq.s   P6D_loc_20E846
	addi.w  #$8000, d3
P6D_loc_20E846:
	movea.w a0, a1
	bsr.s   P6D_sub_20E882
	bra.s   P6D_loc_20E856
P6D_loc_20E84C:
	jsr     FindObjSlot.l
	bne.s   P6D_loc_20E864
	bsr.s   P6D_sub_20E866
P6D_loc_20E856:
	move.w  d5, $8(a1)
	sub.w   d4, d5
	move.w  d3, $38(a1)
	dbra    d6, P6D_loc_20E84C
P6D_loc_20E864:
	rts     
P6D_sub_20E882:
	ori.b   #$4, $1(a1)
	move.b  #$2, $24(a1)
	move.b  #$3, $18(a1)
	move.b  #$20, $17(a1)
	move.b  #$20, $19(a1)
	move.b  #$10, $16(a1)
	move.w  #$4487, $2(a1)
	move.l  #$20e96e, $4(a1)
	move.w  oY(a0), $36(a1)
	rts     
P6D_loc_20E8BC:
	move.l  oX(a0), d0
	move.l  d0, d1
	subi.l  #$8000, d1
	cmp.l   $2e(a0), d1
	bgt.s   P6D_loc_20E8D4
	move.l  $32(a0), d0
	move.l  d0, d1
P6D_loc_20E8D4:
	move.l  d1, oX(a0)
	sub.l   d0, d1
	asr.l   #$8, d1
	move.w  d1, oXVel(a0)
	addi.w  #$100, $38(a0)
	move.w  $38(a0), d0
	asr.w   #$8, d0
	jsr     CalcSine.l
	swap    d1
	asr.l   #$2, d1
	move.l  d1, d0
	asr.l   #$1, d0
	add.l   d1, d0
	addi.l  #$8000, d0
	swap    d0
	add.w   $36(a0), d0
	move.w  d0, oY(a0)
	tst.w   $2a(a0)
	beq.s   P6D_loc_20E924
	movea.w $2a(a0), a1
	dc.b	$0C,$29,$00,$29,$00,$00		; cmpi.b #$29, $0(a1) (raw: not reproducible by assembler)
	beq.s   P6D_loc_20E930
	jmp     DeleteObject.l
P6D_loc_20E924:
	bsr.s   P6D_loc_20E930
	move.w  $2c(a0), d0
	jmp     CheckObjDespawn2.l
P6D_loc_20E930:
	lea     objects.w, a1
	bsr.s   P6D_sub_20E93C
	jmp     DrawObject.l
P6D_sub_20E866:
	move.w  a0, $2a(a1)
	dc.b	$33,$68,$00,$00,$00,$00		; move.w oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.l  $2e(a0), $2e(a1)
	move.l  $32(a0), $32(a1)
	move.w  oY(a0), $c(a1)
P6D_sub_20E93C:
	move.w  oXVel(a0), $3a(a0)
	move.w  #$0, oXVel(a0)
	move.b  #$12, oYRadius(a0)
	jsr     TopSolidObject.l
	sne.b   d0
	move.w  $3a(a0), oXVel(a0)
	move.b  #$10, oYRadius(a0)
	tst.b   d0
	beq.s   P6D_loc_20E96C
	jsr     TopSolidObject.l
P6D_loc_20E96C:
	rts     
P6D_loc_20E96E:
	dc.w	$0002,$02F0,$0F00,$00E0,$F00F,$0010,$0000
