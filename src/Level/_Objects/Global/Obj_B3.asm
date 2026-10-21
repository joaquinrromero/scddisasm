; Object $B3 - Obj32_20ED02 (from R73C, old ID $32)
PB3_Obj32_20ED02:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PB3_dat_20ED10(pc, d0.w), d0
	jmp     PB3_dat_20ED10(pc, d0.w)
PB3_dat_20ED10:
	dc.w	PB3_loc_20ED16-PB3_dat_20ED10
	dc.w	PB3_loc_20ED74-PB3_dat_20ED10
	dc.w	PB3_loc_20EEC2-PB3_dat_20ED10
PB3_loc_20ED16:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$4fc, oTile(a0)
	move.l  #$20eef4, oMap(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.b  #$2f, d0
	bsr.w   PB3_sub_20EEDA
	bne.s   PB3_loc_20ED6E
	move.w  a1, $2a(a0)
	moveq   #$0, d1
	move.w  oX(a0), d0
	move.b  oWidth(a0), d1
	sub.w   d1, d0
	sub.w   $8(a1), d0
	move.b  $19(a1), d1
	sub.w   d1, d0
	blt.s   PB3_loc_20ED6E
	bra.s   PB3_loc_20ED74
PB3_loc_20ED6E:
	jmp     DeleteObject.l
PB3_loc_20ED74:
	tst.w   $2a(a0)
	beq.s   PB3_loc_20ED96
	movea.w $2a(a0), a1
	move.w  oX(a0), d0
	sub.w   $8(a1), d0
	bge.s   PB3_loc_20ED8A
	neg.w   d0
PB3_loc_20ED8A:
	moveq   #$0, d1
	move.b  oWidth(a0), d1
	cmp.w   d1, d0
	blt.w   PB3_loc_20EE0A
PB3_loc_20ED96:
	lea     objects.w, a1
	jsr     SolidObject.l
	beq.s   PB3_loc_20EDFE
	clr.b   $20(a1)
	clr.b   $35(a0)
	btst.b  #$3, $22(a1)
	beq.s   PB3_loc_20EDFE
	move.b  #$1, $35(a0)
	tst.b   invincible.l
	bne.s   PB3_loc_20EDFE
	move.l  a0, -(a7)
	movea.l a0, a2
	lea     objects.w, a0
	cmpi.b  #$4, oRoutine(a0)
	beq.s   PB3_loc_20EDFC
	tst.w   $30(a0)
	bne.s   PB3_loc_20EDFC
	move.l  oY(a0), d3
	move.w  oYVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	sub.l   d0, d3
	move.l  d3, oY(a0)
	jsr     HurtPlayer.l
	movea.l (a7)+, a0
	lea     objects.w, a1
	jsr     GetOffObject.l
	bra.s   PB3_loc_20EDFE
PB3_loc_20EDFC:
	movea.l (a7)+, a0
PB3_loc_20EDFE:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PB3_loc_20EE0A:
	move.w  #$a3, d0
	movem.l a0-a2, -(a7)
	jsr     PlayFMSound.l
	movem.l (a7)+, a0-a2
	moveq   #$f4, d4
	moveq   #$3, d3
	lea     PB3_loc_20EEA2.l, a2
PB3_loc_20EE26:
	jsr     FindObjSlot.l
	bne.s   PB3_loc_20EE8C
	dc.b	$13,$7C,$00,$32,$00,$00		; move.b #$32, $0(a1) (raw: not reproducible by assembler)
	move.b  #$4, $24(a1)
	move.b  #$1, $1a(a1)
	move.b  #$4, $1(a1)
	move.b  #$5, $18(a1)
	move.b  #$4, $19(a1)
	move.b  #$10, $16(a1)
	move.w  #$4fc, $2(a1)
	move.l  #$20eef4, $4(a1)
	move.w  oX(a0), $8(a1)
	add.w   d4, $8(a1)
	move.w  oY(a0), $c(a1)
	move.w  (a2)+, $10(a1)
	move.w  (a2)+, $12(a1)
	move.w  (a2)+, $30(a1)
	move.w  (a2)+, $32(a1)
	addq.w  #$8, d4
	dbra    d3, PB3_loc_20EE26
PB3_loc_20EE8C:
	tst.b   $35(a0)
	beq.s   PB3_loc_20EE9C
	lea     objects.w, a1
	jsr     GetOffObject.l
PB3_loc_20EE9C:
	jmp     DeleteObject.l
PB3_loc_20EEA2:
	dc.w	$0240,$FE00,$0006,$0010,$0220,$FE00,$0000,$0012
	dc.w	$0200,$FE00,$0006,$0014,$01E0,$FE00,$000A,$0010
PB3_loc_20EEC2:
	bsr.w   PB3_sub_20CEA0
	eori.b  #$1, $34(a0)
	beq.s   PB3_loc_20EED4
	jsr     DrawObject.l
PB3_loc_20EED4:
	jmp     CheckObjDespawn.l
PB3_sub_20EEDA:
	lea     objHUDScoreSlot.w, a1
	moveq   #$7d, d1
PB3_loc_20EEE0:
	dc.b	$B0,$29,$00,$00		; cmp.b $0(a1), d0 (raw: not reproducible by assembler)
	bne.s   PB3_loc_20EEE8
	rts     
PB3_loc_20EEE8:
	adda.w  #$40, a1
	dbra    d1, PB3_loc_20EEE0
	moveq   #$ff, d1
	rts     
PB3_loc_20EEF4:
	dc.w	$0004,$000A,$01F0,$0F00,$00F0,$01F0,$0300,$00FC
PB3_sub_20CEA0:
	move.w  $30(a0), d0
	add.w   d0, oXVel(a0)
	move.w  $32(a0), d0
	add.w   d0, oYVel(a0)
PB3_loc_20CEB0:
	move.w  oXVel(a0), d0
	ext.l   d0
	lsl.l   #$8, d0
	add.l   d0, oX(a0)
	move.w  oYVel(a0), d0
	ext.l   d0
	lsl.l   #$8, d0
	add.l   d0, oY(a0)
	rts     
PB3_loc_20CECA:
	subq.w  #$1, $2a(a0)
	beq.s   PB3_loc_20CEDA
	rts     
PB3_loc_20CED2:
	subq.b  #$1, $2a(a0)
	beq.s   PB3_loc_20CEDA
	rts     
PB3_loc_20CEDA:
	addq.b  #$1, $2d(a0)
	rts     
