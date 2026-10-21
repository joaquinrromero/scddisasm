; Object $81 - Obj36_20EF5A (from R41A, old ID $36)
P81_Obj36_20EF5A:
	move.b  oSubtype(a0), d0
	bpl.s   P81_loc_20EF64
	bra.w   P81_loc_20F1B2
P81_loc_20EF64:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P81_dat_20EF7E(pc, d0.w), d0
	jsr     P81_dat_20EF7E(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P81_dat_20EF7E:
	dc.w	P81_loc_20EF82-P81_dat_20EF7E
	dc.w	P81_loc_20F0D0-P81_dat_20EF7E
P81_loc_20EF82:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.l  #$20f1aa, oMap(a0)
	move.w  #$368, oTile(a0)
	move.w  #$100, $2c(a0)
	move.b  oSubtype(a0), d0
	beq.s   P81_loc_20EFBC
	neg.w   $2c(a0)
P81_loc_20EFBC:
	jsr     FindObjSlot.l
	beq.s   P81_loc_20EFCA
	jmp     DeleteObject.l
P81_loc_20EFCA:
	move.w  a1, $2e(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	move.w  a0, $3e(a1)
	jsr     FindObjSlot.l
	beq.s   P81_loc_20EFF8
	jmp     DeleteObject.l
P81_loc_20EFF8:
	move.w  a1, $30(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	move.w  a0, $3e(a1)
	jsr     FindObjSlot.l
	beq.s   P81_loc_20F026
	jmp     DeleteObject.l
P81_loc_20F026:
	move.w  a1, $32(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	move.w  a0, $3e(a1)
	jsr     FindObjSlot.l
	beq.s   P81_loc_20F054
	jmp     DeleteObject.l
P81_loc_20F054:
	move.w  a1, $34(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	move.w  a0, $3e(a1)
	jsr     FindObjSlot.l
	beq.s   P81_loc_20F082
	jmp     DeleteObject.l
P81_loc_20F082:
	move.w  a1, $36(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	move.w  a0, $3e(a1)
	jsr     FindObjSlot.l
	beq.s   P81_loc_20F0B0
	jmp     DeleteObject.l
P81_loc_20F0B0:
	move.w  a1, $38(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$fe, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	move.w  a0, $3e(a1)
P81_loc_20F0D0:
	move.w  $2c(a0), d0
	add.w   d0, $2a(a0)
	move.w  $2a(a0), d0
	lsr.w   #$8, d0
	jsr     CalcSine.l
	swap    d0
	swap    d1
	clr.w   d0
	clr.w   d1
	asr.l   #$2, d0
	asr.l   #$2, d1
	move.l  d0, d4
	move.l  d1, d5
	asr.l   #$1, d0
	asr.l   #$1, d1
	move.l  d0, d2
	move.l  d1, d3
	asr.l   #$1, d0
	asr.l   #$1, d1
	movea.w $2e(a0), a1
	move.l  oY(a0), $2e(a1)
	move.l  oX(a0), $2a(a1)
	add.l   d0, $2e(a1)
	add.l   d1, $2a(a1)
	movea.w $30(a0), a1
	move.l  oY(a0), $2e(a1)
	move.l  oX(a0), $2a(a1)
	add.l   d2, $2e(a1)
	add.l   d3, $2a(a1)
	movea.w $32(a0), a1
	move.l  oY(a0), $2e(a1)
	move.l  oX(a0), $2a(a1)
	add.l   d0, $2e(a1)
	add.l   d1, $2a(a1)
	add.l   d2, $2e(a1)
	add.l   d3, $2a(a1)
	movea.w $34(a0), a1
	move.l  oY(a0), $2e(a1)
	move.l  oX(a0), $2a(a1)
	add.l   d4, $2e(a1)
	add.l   d5, $2a(a1)
	movea.w $36(a0), a1
	move.l  oY(a0), $2e(a1)
	move.l  oX(a0), $2a(a1)
	add.l   d0, $2e(a1)
	add.l   d1, $2a(a1)
	add.l   d4, $2e(a1)
	add.l   d5, $2a(a1)
	movea.w $38(a0), a1
	move.l  oY(a0), $2e(a1)
	move.l  oX(a0), $2a(a1)
	add.l   d2, $2e(a1)
	add.l   d3, $2a(a1)
	add.l   d4, $2e(a1)
	add.l   d5, $2a(a1)
	rts     
P81_loc_20F1AA:
	dc.w	$0002,$01F8,$0500,$00F8
P81_loc_20F1B2:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P81_dat_20F1D8(pc, d0.w), d0
	jsr     P81_dat_20F1D8(pc, d0.w)
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$36,$00,$00		; cmpi.b #$36, $0(a1) (raw: not reproducible by assembler)
	bne.s   P81_loc_20F1D2
	jmp     DrawObject.l
P81_loc_20F1D2:
	jmp     DeleteObject.l
P81_dat_20F1D8:
	dc.w	P81_loc_20F1DC-P81_dat_20F1D8
	dc.w	P81_loc_20F220-P81_dat_20F1D8
P81_loc_20F1DC:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	cmpi.b  #$ff, oSubtype(a0)
	bne.w   P81_loc_20F206
	move.b  #$3, oPriority(a0)
	move.l  #$20f22e, oMap(a0)
	move.w  #$368, oTile(a0)
	bra.s   P81_loc_20F220
P81_loc_20F206:
	move.b  #$2, oPriority(a0)
	move.l  #$20f236, oMap(a0)
	move.w  #$370, oTile(a0)
	move.b  #$a9, oColType(a0)
P81_loc_20F220:
	move.w  $2a(a0), oX(a0)
	move.w  $2e(a0), oY(a0)
	rts     
P81_loc_20F22E:
	dc.w	$0002,$01F8,$0500,$04F8
P81_loc_20F236:
	dc.w	$0002,$01F0,$0F00,$00F0
