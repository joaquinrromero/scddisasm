; Object $AE - Obj2D_20F2CA (from R62A, old ID $2D)
Obj2D_20F2CA:
	move.b  oSubtype(a0), d0
	bpl.s   PAE_loc_20F2D4
	bra.w   PAE_loc_20F4C8
PAE_loc_20F2D4:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PAE_dat_20F2EE(pc, d0.w), d0
	jsr     PAE_dat_20F2EE(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PAE_dat_20F2EE:
	dc.w	PAE_loc_20F2F2-PAE_dat_20F2EE
	dc.w	PAE_loc_20F406-PAE_dat_20F2EE
PAE_loc_20F2F2:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.l  #$20f4c0, oMap(a0)
	move.w  #$3f8, oTile(a0)
	move.w  #$100, $2c(a0)
	move.b  oSubtype(a0), d0
	beq.s   PAE_loc_20F32C
	neg.w   $2c(a0)
PAE_loc_20F32C:
	jsr     FindNextObjSlot.l
	bne.w   PAE_loc_20F400
	move.w  a0, $3e(a1)
	move.w  a1, $2e(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	jsr     FindNextObjSlot.l
	bne.w   PAE_loc_20F400
	move.w  a0, $3e(a1)
	move.w  a1, $30(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	jsr     FindNextObjSlot.l
	bne.w   PAE_loc_20F400
	move.w  a0, $3e(a1)
	move.w  a1, $32(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	jsr     FindNextObjSlot.l
	bne.w   PAE_loc_20F400
	move.w  a0, $3e(a1)
	move.w  a1, $34(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	jsr     FindNextObjSlot.l
	bne.w   PAE_loc_20F400
	move.w  a0, $3e(a1)
	move.w  a1, $36(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	bra.s   PAE_loc_20F406
PAE_loc_20F400:
	jmp     DeleteObject.l
PAE_loc_20F406:
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
	rts     
PAE_loc_20F4C0:
	dc.w	$0002,$01F8,$0500,$00F8
PAE_loc_20F4C8:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PAE_dat_20F4EE(pc, d0.w), d0
	jsr     PAE_dat_20F4EE(pc, d0.w)
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$2D,$00,$00		; cmpi.b #$2d, $0(a1) (raw: not reproducible by assembler)
	beq.s   PAE_loc_20F4E8
	jmp     DeleteObject.l
PAE_loc_20F4E8:
	jmp     DrawObject.l
PAE_dat_20F4EE:
	dc.w	PAE_loc_20F4F2-PAE_dat_20F4EE
	dc.w	PAE_loc_20F516-PAE_dat_20F4EE
PAE_loc_20F4F2:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.l  #$20f524, oMap(a0)
	move.w  #$3f8, oTile(a0)
	move.b  #$b9, oColType(a0)
PAE_loc_20F516:
	move.w  $2a(a0), oX(a0)
	move.w  $2e(a0), oY(a0)
	rts     
PAE_loc_20F524:
	dc.w	$0002,$01F8,$0500,$04F8
