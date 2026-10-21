; Object $44 - Obj44_20EDEC (from R42A, old ID $44)
P44_Obj44_20EDEC:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P44_dat_20EE0A(pc, d0.w), d0
	jsr     P44_dat_20EE0A(pc, d0.w)
	jsr     DrawObject.l
	move.w  $36(a0), d0
	jmp     CheckObjDespawn2.l
P44_dat_20EE0A:
	dc.w	P44_loc_20EE14-P44_dat_20EE0A
	dc.w	P44_loc_20EE60-P44_dat_20EE0A
	dc.w	P44_loc_20EE94-P44_dat_20EE0A
	dc.w	P44_loc_20EEB8-P44_dat_20EE0A
	dc.w	P44_loc_20EEC6-P44_dat_20EE0A
P44_loc_20EE14:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.w  #$350, oTile(a0)
	move.l  #$20ef5e, oMap(a0)
	move.w  oX(a0), $36(a0)
	cmpi.w  #$780, destWaterHeight.w
	beq.s   P44_loc_20EE60
	cmpi.w  #$5e0, destWaterHeight.w
	beq.s   P44_loc_20EE60
	jmp     DeleteObject.l
P44_loc_20EE60:
	move.w  waterHeight.w, oY(a0)
	move.w  waterHeight2.w, d0
	cmp.w   destWaterHeight.w, d0
	bne.s   P44_loc_20EE92
	cmpi.w  #$780, d0
	bne.s   P44_loc_20EE7E
	move.b  #$4, oRoutine(a0)
	bra.s   P44_loc_20EE94
P44_loc_20EE7E:
	cmpi.w  #$5e0, d0
	bne.s   P44_loc_20EE8C
	move.b  #$6, oRoutine(a0)
	bra.s   P44_loc_20EEB8
P44_loc_20EE8C:
	jmp     DeleteObject.l
P44_loc_20EE92:
	rts     
P44_loc_20EE94:
	move.w  waterHeight.w, oY(a0)
	lea     objects.w, a1
	jsr     TopSolidObject.l
	beq.s   P44_loc_20EEB6
	addq.b  #$2, oRoutine(a0)
	move.w  $8(a1), oX(a0)
	move.w  #$5e0, destWaterHeight.w
P44_loc_20EEB6:
	rts     
P44_loc_20EEB8:
	addq.b  #$2, oRoutine(a0)
	move.w  waterMoveSpeed.w, d0
	neg.w   d0
	move.w  d0, oYVel(a0)
P44_loc_20EEC6:
	move.w  waterHeight.w, oY(a0)
	lea     objects.w, a1
	move.b  $10(a1), d4
	ext.w   d4
	add.w   $8(a1), d4
	sub.w   oX(a0), d4
	beq.s   P44_loc_20EF4A
	lea     loc_206F36.l, a6
	moveq   #$1, d6
	moveq   #$0, d5
	move.b  oXRadius(a0), d5
	tst.w   d4
	bpl.s   P44_loc_20EEFE
	lea     loc_2070D8.l, a6
	neg.w   d6
	neg.w   d5
	neg.w   d4
P44_loc_20EEFE:
	move.l  a6, $2a(a0)
	move.w  d6, $2e(a0)
	move.w  d5, $30(a0)
	move.w  d4, $32(a0)
	move.w  oY(a0), $34(a0)
	addq.w  #$7, $34(a0)
P44_loc_20EF18:
	movea.l $2a(a0), a6
	move.w  oX(a0), d3
	add.w   $30(a0), d3
	cmpa.l  #$206f36, a6
	beq.s   P44_loc_20EF30
	eori.w  #$f, d3
P44_loc_20EF30:
	move.w  $34(a0), d2
	jsr     (a6)
	tst.w   d1
	bmi.s   P44_loc_20EF4A
	subq.w  #$1, $32(a0)
	ble.s   P44_loc_20EF4A
	move.w  $2e(a0), d0
	add.w   d0, oX(a0)
	bra.s   P44_loc_20EF18
P44_loc_20EF4A:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	beq.s   P44_loc_20EF5C
	move.w  oX(a0), $8(a1)
P44_loc_20EF5C:
	rts     
P44_loc_20EF5E:
	dc.w	$0002,$01F8,$0D00,$00F0
