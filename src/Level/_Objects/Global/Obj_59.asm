; Object $59 - Obj2C_20BD2E (from R31A, old ID $2C)
Obj2C_20BD2E:
	move.b  oSubtype(a0), d0
	bpl.s   P59_loc_20BD38
	bra.w   P59_loc_20BEA0
P59_loc_20BD38:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P59_dat_20BD52(pc, d0.w), d0
	jsr     P59_dat_20BD52(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P59_dat_20BD52:
	dc.w	P59_loc_20BD56-P59_dat_20BD52
	dc.w	P59_loc_20BE16-P59_dat_20BD52
P59_loc_20BD56:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.l  #$20be98, oMap(a0)
	move.w  #$3bd, oTile(a0)
	move.w  #$100, $2c(a0)
	move.b  oSubtype(a0), d0
	beq.s   P59_loc_20BD90
	neg.w   $2c(a0)
P59_loc_20BD90:
	jsr     FindNextObjSlot.l
	bne.w   P59_loc_20BE10
	move.w  a0, $3e(a1)
	move.w  a1, $2e(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	jsr     FindNextObjSlot.l
	bne.w   P59_loc_20BE10
	move.w  a0, $3e(a1)
	move.w  a1, $30(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	jsr     FindNextObjSlot.l
	bne.w   P59_loc_20BE10
	move.w  a0, $3e(a1)
	move.w  a1, $32(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	bra.s   P59_loc_20BE16
P59_loc_20BE10:
	jmp     DeleteObject.l
P59_loc_20BE16:
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
	rts     
P59_loc_20BE98:
	dc.w	$0002,$01F8,$0500,$00F8
P59_loc_20BEA0:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P59_dat_20BEC6(pc, d0.w), d0
	jsr     P59_dat_20BEC6(pc, d0.w)
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$2C,$00,$00		; cmpi.b #$2c, $0(a1) (raw: not reproducible by assembler)
	beq.s   P59_loc_20BEC0
	jmp     DeleteObject.l
P59_loc_20BEC0:
	jmp     DrawObject.l
P59_dat_20BEC6:
	dc.w	P59_loc_20BECA-P59_dat_20BEC6
	dc.w	P59_loc_20BEEE-P59_dat_20BEC6
P59_loc_20BECA:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.l  #$20befc, oMap(a0)
	move.w  #$3bd, oTile(a0)
	move.b  #$8b, oColType(a0)
P59_loc_20BEEE:
	move.w  $2a(a0), oX(a0)
	move.w  $2e(a0), oY(a0)
	rts     
P59_loc_20BEFC:
	dc.w	$0002,$01F8,$0500,$04F8
