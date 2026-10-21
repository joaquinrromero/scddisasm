; Object $68 - Obj38_20EA8A (from R41C, old ID $38)
P68_Obj38_20EA8A:
	tst.w   $3e(a0)
	beq.s   P68_loc_20EAA2
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$38,$00,$00		; cmpi.b #$38, $0(a1) (raw: not reproducible by assembler)
	beq.s   P68_loc_20EAA2
	jmp     DeleteObject.l
P68_loc_20EAA2:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P68_dat_20EAB0(pc, d0.w), d0
	jmp     P68_dat_20EAB0(pc, d0.w)
P68_dat_20EAB0:
	dc.w	P68_loc_20EAB4-P68_dat_20EAB0
	dc.w	P68_loc_20EBCE-P68_dat_20EAB0
P68_loc_20EAB4:
	move.w  oX(a0), $34(a0)
	jsr     FindObjSlot.l
	beq.s   P68_loc_20EAC8
	jmp     DeleteObject.l
P68_loc_20EAC8:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$2, $24(a1)
	move.w  a0, $3e(a1)
	lea     (a1), a3
	jsr     FindObjSlot.l
	beq.s   P68_loc_20EAE8
	jmp     DeleteObject.l
P68_loc_20EAE8:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$2, $24(a1)
	move.w  a0, $3e(a1)
	lea     (a1), a2
	jsr     FindObjSlot.l
	beq.s   P68_loc_20EB08
	jmp     DeleteObject.l
P68_loc_20EB08:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$2, $24(a1)
	move.w  a0, $3e(a1)
	move.w  #$f800, d0
	tst.b   oSubtype(a0)
	bpl.s   P68_loc_20EB24
	neg.w   d0
P68_loc_20EB24:
	move.w  d0, d1
	move.w  d0, $2e(a1)
	add.w   d0, d0
	move.w  d0, $2e(a2)
	add.w   d1, d0
	move.w  d0, $2e(a3)
	move.w  #$100, $30(a0)
	tst.b   oSubtype(a0)
	bpl.s   P68_loc_20EB46
	neg.w   $30(a0)
P68_loc_20EB46:
	move.b  oSubtype(a0), d0
	bpl.s   P68_loc_20EB4E
	neg.b   d0
P68_loc_20EB4E:
	andi.w  #$7f, d0
	move.w  d0, $32(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$2, $18(a1)
	move.b  #$3, $18(a2)
	move.b  #$4, $18(a3)
	lea     (a0), a6
	bsr.w   P68_sub_20EB82
	lea     (a1), a6
	bsr.w   P68_sub_20EB82
	lea     (a2), a6
	bsr.w   P68_sub_20EB82
	lea     (a3), a6
P68_sub_20EB82:
	ori.b   #$4, $1(a6)
	move.b  #$a9, $20(a6)
	move.b  #$10, $17(a6)
	move.b  #$10, $19(a6)
	move.b  #$10, $16(a6)
	move.w  #$370, $2(a6)
	move.l  #$20ec0e, $4(a6)
	move.b  #$2, $24(a6)
	move.w  oX(a0), $2a(a6)
	move.w  oY(a0), $2c(a6)
	move.w  $30(a0), $30(a6)
	move.w  $32(a0), $32(a6)
	rts     
P68_loc_20EBCE:
	move.w  $30(a0), d0
	add.w   d0, $2e(a0)
	move.w  $2e(a0), d0
	asr.w   #$8, d0
	jsr     CalcSine.l
	move.w  $32(a0), d3
	asr.w   d3, d1
	asr.w   d3, d0
	add.w   $2a(a0), d1
	add.w   $2c(a0), d0
	move.w  d1, oX(a0)
	move.w  d0, oY(a0)
	jsr     DrawObject.l
	tst.w   $3e(a0)
	bne.s   P68_loc_20EC0C
	jmp     CheckObjDespawn.l
P68_loc_20EC0C:
	rts     
P68_loc_20EC0E:
	dc.w	$0002,$01F0,$0F00,$00F0
