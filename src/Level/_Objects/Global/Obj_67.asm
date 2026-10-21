; Object $67 - Obj3D_20EBB6 (from R41B, old ID $3D)
Obj3D_20EBB6:
	cmpi.b  #$ff, $3c(a0)
	beq.w   P67_loc_20EE16
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P67_dat_20EBDA(pc, d0.w), d0
	jsr     P67_dat_20EBDA(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P67_dat_20EBDA:
	dc.w	P67_loc_20EBF2-P67_dat_20EBDA
	dc.w	P67_loc_20EC82-P67_dat_20EBDA
	dc.w	P67_loc_20ED02-P67_dat_20EBDA
	dc.w	P67_loc_20ED52-P67_dat_20EBDA
P67_loc_20EBE2:
	jmp     DespawnObject.l
	lea     objects.w, a1
	jmp     TopSolidObject.l
P67_loc_20EBF2:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.l  #$20ef14, oMap(a0)
	move.w  #$4300, oTile(a0)
	move.b  #$40, oYRadius(a0)
	move.b  #$40, oWidth(a0)
	move.b  oSubtype(a0), d0
	andi.b  #$3, d0
	move.b  d0, oMapFrame(a0)
	move.b  d0, $3d(a0)
	jsr     FindObjSlot.l
	bne.w   P67_loc_20EBE2
	dc.b	$13,$7C,$00,$3D,$00,$00		; move.b #$3d, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $36(a1)
	move.w  a0, $34(a1)
	move.b  #$ff, $3c(a1)
	move.b  #$0, $3d(a1)
	move.w  a1, $30(a0)
	jsr     FindObjSlot.l
	bne.w   P67_loc_20EBE2
	dc.b	$13,$7C,$00,$3D,$00,$00		; move.b #$3d, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $36(a1)
	move.w  a0, $34(a1)
	move.b  #$ff, $3c(a1)
	move.b  #$1, $3d(a1)
	move.w  a1, $34(a0)
	rts     
P67_loc_20EC82:
	movea.w $30(a0), a1
	tst.b   $3e(a1)
	bmi.s   P67_loc_20EC8E
	rts     
P67_loc_20EC8E:
	lea     objects.w, a1
	cmpi.b  #$2, $3d(a0)
	bcc.s   P67_loc_20ECAC
	move.w  oX(a0), d0
	move.b  $19(a1), d1
	addq.b  #$2, d1
	ext.w   d1
	add.w   $8(a1), d1
	bra.s   P67_loc_20ECBE
P67_loc_20ECAC:
	move.w  oX(a0), d1
	move.b  $19(a1), d0
	addq.b  #$2, d0
	neg.b   d0
	ext.w   d0
	add.w   $8(a1), d0
P67_loc_20ECBE:
	sub.w   d1, d0
	bcc.s   P67_loc_20ECC4
	rts     
P67_loc_20ECC4:
	moveq   #$10, d0
	jsr     P67_sub_20EDE8.l
	tst.b   d1
	bmi.s   P67_loc_20ECD6
	cmpi.b  #$10, d1
	bcc.s   P67_loc_20ECF2
P67_loc_20ECD6:
	movea.w $34(a0), a1
	tst.b   $3e(a1)
	beq.s   P67_loc_20ECF0
	move.b  #$6, oRoutine(a0)
	move.b  #$10, $3a(a0)
	clr.b   $3b(a0)
P67_loc_20ECF0:
	rts     
P67_loc_20ECF2:
	addq.b  #$2, oRoutine(a0)
	move.b  #$10, $3a(a0)
	clr.b   $3b(a0)
	rts     
P67_loc_20ED02:
	moveq   #$0, d0
	move.b  $3d(a0), d0
	add.b   d0, d0
	add.b   d0, d0
	add.b   $3b(a0), d0
	move.b  P67_dat_20ED42(pc, d0.w), d0
	bmi.s   P67_loc_20ED36
	move.b  d0, oMapFrame(a0)
	subq.b  #$1, $3a(a0)
	bne.s   P67_loc_20ED40
	move.w  #$bf, d0
	jsr     PlayFMSound.l
	move.b  #$4, $3a(a0)
	addq.b  #$1, $3b(a0)
	rts     
P67_loc_20ED36:
	move.b  oMapFrame(a0), $3d(a0)
	subq.b  #$2, oRoutine(a0)
P67_loc_20ED40:
	rts     
P67_sub_20EDE8:
	move.w  oY(a0), d2
	add.w   d0, d2
	move.w  oX(a0), d3
	lea     primaryAngle.w, a4
	clr.b   (a4)
	movea.w #$10, a3
	moveq   #$0, d6
	moveq   #$d, d5
	jsr     FindLevelFloor.l
	move.b  primaryAngle.w, d3
	btst.l  #$0, d3
	beq.s   P67_loc_20EE14
	move.b  #$0, d3
P67_loc_20EE14:
	rts     
P67_loc_20EE16:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P67_dat_20EE34(pc, d0.w), d0
	jsr     P67_dat_20EE34(pc, d0.w)
	jsr     DrawObject.l
	move.w  $36(a0), d0
	jmp     CheckObjDespawn2.l
P67_dat_20ED42:
	dc.w	$0004,$01FF,$0105,$02FF,$0205,$01FF,$0306,$02FF
P67_loc_20ED52:
	moveq   #$0, d0
	move.b  $3d(a0), d0
	add.b   d0, d0
	add.b   d0, d0
	add.b   $3b(a0), d0
	move.b  P67_dat_20EDD8(pc, d0.w), d0
	bmi.s   P67_loc_20EDCA
	move.b  d0, oMapFrame(a0)
	lea     objects.w, a1
	move.w  oY(a0), d0
	move.b  oYRadius(a0), d1
	ext.w   d1
	sub.w   d1, d0
	move.b  $16(a1), d1
	ext.w   d1
	sub.w   d1, d0
	move.w  d0, $c(a1)
	subq.b  #$1, $3a(a0)
	bne.s   P67_loc_20EDD6
	move.b  #$8, $3a(a0)
	addq.b  #$1, $3b(a0)
	lea     objects.w, a1
	cmpi.b  #$1, $3b(a0)
	bne.s   P67_loc_20EDAA
	move.w  oX(a0), $8(a1)
	rts     
P67_loc_20EDAA:
	cmpi.b  #$2, $3b(a0)
	bne.s   P67_loc_20EDD6
	move.w  #$10, d0
	btst.b  #$1, $3d(a0)
	beq.s   P67_loc_20EDC0
	neg.w   d0
P67_loc_20EDC0:
	add.w   oX(a0), d0
	move.w  d0, $8(a1)
	rts     
P67_loc_20EDCA:
	move.b  oMapFrame(a0), $3d(a0)
	move.b  #$2, oRoutine(a0)
P67_loc_20EDD6:
	rts     
P67_dat_20EE34:
	dc.w	P67_loc_20EE38-P67_dat_20EE34
	dc.w	P67_loc_20EE7A-P67_dat_20EE34
P67_loc_20EE38:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.l  #$20ef14, oMap(a0)
	move.w  #$4300, oTile(a0)
	move.b  #$8, oMapFrame(a0)
	move.b  #$20, d0
	move.b  #$10, d1
	tst.b   $3d(a0)
	beq.s   P67_loc_20EE72
	move.b  #$10, d0
	move.b  #$10, d1
P67_loc_20EE72:
	move.b  d0, oWidth(a0)
	move.b  d1, oYRadius(a0)
P67_loc_20EE7A:
	movea.w $34(a0), a1
	moveq   #$0, d0
	move.b  $1a(a1), d0
	cmpi.b  #$4, d0
	bcc.w   P67_loc_20EEFA
	add.b   d0, d0
	lea     P67_loc_20EF04.l, a2
	tst.b   $3d(a0)
	beq.s   P67_loc_20EEA0
	lea     P67_loc_20EF0C.l, a2
P67_loc_20EEA0:
	lea     (a2, d0.w), a2
	move.b  (a2)+, d0
	move.b  (a2)+, d1
	ext.w   d0
	ext.w   d1
	add.w   $8(a1), d0
	add.w   $c(a1), d1
	move.w  d0, oX(a0)
	move.w  d1, oY(a0)
	lea     objects.w, a1
	jsr     SolidObject.l
	tst.b   $3d(a0)
	bne.s   P67_loc_20EED8
	btst.b  #$3, oFlags(a0)
	sne.b   $3e(a0)
	rts     
P67_loc_20EED8:
	btst.b  #$5, oFlags(a0)
	beq.s   P67_loc_20EEF4
	tst.b   $3f(a0)
	bne.s   P67_loc_20EEF8
	move.w  #$ffff, $3e(a0)
	bclr.b  #$5, oFlags(a0)
	rts     
P67_loc_20EEF4:
	clr.w   $3e(a0)
P67_loc_20EEF8:
	rts     
P67_loc_20EEFA:
	lea     objects.w, a1
	jmp     GetOffObject.l
P67_loc_20EF04:
	dc.w	$F000,$F000,$1000,$1000
P67_loc_20EF0C:
	dc.w	$00E0,$0020,$0020,$00E0
P67_dat_20EDD8:
	dc.w	$0007,$03FF,$0104,$02FF,$0204,$01FF,$0307,$00FF
