; Object $B9 - Obj36_20BDB2 (from R81A, old ID $36)
PB9_Obj36_20BDB2:
	tst.b   oSubtype(a0)
	bmi.w   PB9_loc_20BEA4
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PB9_dat_20BDD8(pc, d0.w), d0
	jsr     PB9_dat_20BDD8(pc, d0.w)
	jsr     DrawObject.l
	move.w  $36(a0), d0
	jmp     CheckObjDespawn2.l
PB9_dat_20BDD8:
	dc.w	PB9_loc_20BDDC-PB9_dat_20BDD8
	dc.w	PB9_loc_20BE6E-PB9_dat_20BDD8
PB9_loc_20BDDC:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$43f0, oTile(a0)
	move.b  #$3, oPriority(a0)
	move.l  #$20be9c, oMap(a0)
	move.w  oX(a0), $36(a0)
	move.w  oY(a0), $32(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	jsr     FindObjSlot.l
	beq.s   PB9_loc_20BE20
	jmp     DeleteObject.l
PB9_loc_20BE20:
	cmpi.b  #$1, oSubtype(a0)
	beq.s   PB9_loc_20BE4C
	dc.b	$13,$7C,$00,$0A,$00,$00		; move.b #$a, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  #$e8, $39(a1)
	move.w  a0, $34(a1)
	move.b  oSubtype(a0), $28(a1)
	bra.s   PB9_loc_20BE6E
PB9_loc_20BE4C:
	dc.b	$13,$7C,$00,$36,$00,$00		; move.b #$36, $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  #$e8, $39(a1)
	move.w  a0, $34(a1)
PB9_loc_20BE6E:
	btst.b  #$7, oSprFlags(a0)
	beq.s   PB9_loc_20BE9A
	lea     objects.w, a1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	bcc.s   PB9_loc_20BE86
	neg.w   d0
PB9_loc_20BE86:
	cmpi.w  #$20, d0
	bcc.s   PB9_loc_20BE9A
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jsr     SolidObject.l
PB9_loc_20BE9A:
	rts     
PB9_loc_20BE9C:
	dc.w	$0002,$01F0,$0F00,$00F0
PB9_loc_20BEA4:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PB9_dat_20BEF8(pc, d0.w), d0
	jsr     PB9_dat_20BEF8(pc, d0.w)
	jsr     DrawObject.l
	moveq   #$0, d1
	move.w  $34(a0), d1
	beq.s   PB9_loc_20BEE8
	movea.w d1, a1
	dc.b	$4A,$29,$00,$00		; tst.b $0(a1) (raw: not reproducible by assembler)
	beq.s   PB9_loc_20BEF2
	move.w  $8(a1), oX(a0)
	move.w  $c(a1), oY(a0)
	move.b  $38(a0), d0
	ext.w   d0
	add.w   d0, oX(a0)
	move.b  $39(a0), d0
	ext.w   d0
	add.w   d0, oY(a0)
PB9_loc_20BEE8:
	move.w  $36(a0), d0
	jmp     CheckObjDespawn2.l
PB9_loc_20BEF2:
	jmp     DeleteObject.l
PB9_dat_20BEF8:
	dc.w	PB9_loc_20BEFC-PB9_dat_20BEF8
	dc.w	PB9_loc_20BF4C-PB9_dat_20BEF8
PB9_loc_20BEFC:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$488, oTile(a0)
	move.b  #$4, oPriority(a0)
	move.l  #$20bfea, oMap(a0)
	move.w  oX(a0), $36(a0)
	move.w  oY(a0), $32(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	cmpi.b  #$ff, oSubtype(a0)
	beq.s   PB9_loc_20BF4C
	move.b  #$1, oMapFrame(a0)
	move.b  #$83, oColType(a0)
	move.b  #$12, oWidth(a0)
PB9_loc_20BF4C:
	tst.b   oMapFrame(a0)
	bne.w   PB9_loc_20BFBC
	lea     objects.w, a1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	bcc.s   PB9_loc_20BF64
	neg.w   d0
PB9_loc_20BF64:
	cmpi.w  #$20, d0
	bcc.s   PB9_loc_20BFBA
	jsr     SolidObject.l
	beq.s   PB9_loc_20BFBA
	btst.b  #$3, oFlags(a0)
	beq.s   PB9_loc_20BFBA
	tst.b   timeWarp.l
	bne.s   PB9_loc_20BFBA
	tst.b   invincible.l
	bne.s   PB9_loc_20BFBA
	move.l  a0, -(a7)
	movea.l a0, a2
	lea     objects.w, a0
	cmpi.b  #$4, oRoutine(a0)
	bcc.s   PB9_loc_20BFB8
	tst.w   $30(a0)
	bne.s   PB9_loc_20BFB8
	move.l  oY(a0), d3
	move.w  oYVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	sub.l   d0, d3
	move.l  d3, oY(a0)
	jsr     HurtPlayer.l
PB9_loc_20BFB8:
	movea.l (a7)+, a0
PB9_loc_20BFBA:
	rts     
PB9_loc_20BFBC:
	btst.b  #$7, oSprFlags(a0)
	beq.s   PB9_loc_20BFE8
	lea     objects.w, a1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	bcc.s   PB9_loc_20BFD4
	neg.w   d0
PB9_loc_20BFD4:
	cmpi.w  #$20, d0
	bcc.s   PB9_loc_20BFE8
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jsr     SolidObject.l
PB9_loc_20BFE8:
	rts     
PB9_loc_20BFEA:
	dc.w	$0004,$000A,$01F0,$0F00,$00F0,$01F0,$0F10,$00F0
