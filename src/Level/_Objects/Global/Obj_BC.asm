; Object $BC - Obj29_20E4D8 (from R82A, old ID $29)
PBC_Obj29_20E4D8:
	move.w  $2a(a0), d0
	bne.w   PBC_loc_20E6B4
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PBC_dat_20E4EE(pc, d0.w), d0
	jmp     PBC_dat_20E4EE(pc, d0.w)
PBC_dat_20E4EE:
	dc.w	PBC_loc_20E4F8-PBC_dat_20E4EE
	dc.w	PBC_loc_20E5A2-PBC_dat_20E4EE
	dc.w	PBC_loc_20E5FC-PBC_dat_20E4EE
	dc.w	PBC_loc_20E628-PBC_dat_20E4EE
	dc.w	PBC_loc_20E64C-PBC_dat_20E4EE
PBC_loc_20E4F8:
	addq.b  #$2, oRoutine(a0)
	move.w  oY(a0), $2e(a0)
	subi.w  #$10, $2e(a0)
	lea     PBC_dat_20E596(pc), a1
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	add.w   d0, d0
	add.w   d0, d0
	move.l  (a1, d0.w), oMap(a0)
	jsr     FindNextObjSlot.l
	bne.w   PBC_loc_20E6C0
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.l  oMap(a0), $4(a1)
	move.w  a0, $2a(a1)
	move.w  a1, $2c(a0)
	bsr.s   PBC_sub_20E560
	sub.w   d0, $c(a1)
	sub.w   d0, $30(a1)
	sub.w   d1, $32(a1)
	movea.w a0, a1
	bsr.s   PBC_sub_20E560
	add.w   d0, $c(a1)
	add.w   d0, $30(a1)
	add.w   d1, $32(a1)
	rts     
PBC_dat_20E596:
	dc.w	$0020,$E6CC,$0020,$E6D6,$0020,$E6F0
PBC_loc_20E5A2:
	bsr.w   PBC_sub_20E67C
	tst.b   $3f(a0)
	beq.s   PBC_loc_20E5B2
	clr.b   $3f(a0)
	bra.s   PBC_loc_20E5CC
PBC_loc_20E5B2:
	move.b  oSubtype(a0), d0
	beq.s   PBC_loc_20E5D0
	moveq   #$8, d4
	moveq   #$40, d5
	cmpi.b  #$1, d0
	beq.s   PBC_loc_20E5C6
	moveq   #$b8, d4
	moveq   #$40, d5
PBC_loc_20E5C6:
	bsr.w   PBC_sub_20E694
	bcc.s   PBC_loc_20E5D0
PBC_loc_20E5CC:
	addq.b  #$2, oRoutine(a0)
PBC_loc_20E5D0:
	lea     PBC_dat_20E6C6(pc), a1
	jsr     AnimateObject.l
	movea.w $2c(a0), a1
	move.b  oMapFrame(a0), $1a(a1)
	move.w  a0, -(a7)
	movea.w a1, a0
	jsr     DrawObject.l
	movea.w (a7)+, a0
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PBC_loc_20E5FC:
	bsr.w   PBC_sub_20E67C
	movea.w $2c(a0), a1
	addq.w  #$2, oY(a0)
	subq.w  #$2, $c(a1)
	move.w  oY(a0), d0
	cmp.w   $32(a0), d0
	blt.s   PBC_loc_20E626
	addq.b  #$2, oRoutine(a0)
	move.w  $32(a0), oY(a0)
	move.w  $32(a1), $c(a1)
PBC_loc_20E626:
	bra.s   PBC_loc_20E5D0
PBC_loc_20E628:
	bsr.w   PBC_sub_20E67C
	move.b  oSubtype(a0), d0
	beq.s   PBC_loc_20E64A
	moveq   #$d8, d4
	moveq   #$70, d5
	cmpi.b  #$1, d0
	beq.s   PBC_loc_20E640
	moveq   #$b8, d4
	moveq   #$70, d5
PBC_loc_20E640:
	bsr.w   PBC_sub_20E694
	bcs.s   PBC_loc_20E64A
	addq.b  #$2, oRoutine(a0)
PBC_loc_20E64A:
	bra.s   PBC_loc_20E5D0
PBC_loc_20E64C:
	bsr.w   PBC_sub_20E67C
	movea.w $2c(a0), a1
	subq.w  #$2, oY(a0)
	addq.w  #$2, $c(a1)
	move.w  oY(a0), d0
	cmp.w   $30(a0), d0
	bgt.s   PBC_loc_20E678
	move.b  #$2, oRoutine(a0)
	move.w  $30(a0), oY(a0)
	move.w  $30(a1), $c(a1)
PBC_loc_20E678:
	bra.w   PBC_loc_20E5D0
PBC_sub_20E560:
	ori.b   #$4, $1(a1)
	move.b  #$3, $18(a1)
	move.w  #$47e, $2(a1)
	move.b  #$8, $19(a1)
	move.b  #$10, $16(a1)
	move.w  $2e(a0), $c(a1)
	move.w  $2e(a0), $30(a1)
	move.w  $2e(a0), $32(a1)
	moveq   #$10, d0
	moveq   #$31, d1
	rts     
PBC_sub_20E67C:
	move.w  a0, -(a7)
	movea.w $2c(a0), a0
	lea     objects.w, a1
	jsr     SolidObject.l
	movea.w (a7)+, a0
	jmp     SolidObject.l
PBC_sub_20E694:
	move.w  $FFFFD008.w, d0
	sub.w   oX(a0), d0
	sub.w   d4, d0
	sub.w   d5, d0
	bcc.s   PBC_loc_20E6B2
	move.w  $FFFFD00C.w, d0
	sub.w   $2e(a0), d0
	subi.w  #$ffd0, d0
	subi.w  #$60, d0
PBC_loc_20E6B2:
	rts     
PBC_loc_20E6B4:
	movea.w d0, a1
	dc.b	$0C,$29,$00,$29,$00,$00		; cmpi.b #$29, $0(a1) (raw: not reproducible by assembler)
	bne.s   PBC_loc_20E6C0
	rts     
PBC_loc_20E6C0:
	jmp     DeleteObject.l
PBC_dat_20E6C6:
	dc.w	$0002,$0200,$01FF,$0004,$0004,$01F0,$0700,$00F8
	dc.w	$0004,$000F,$02F0,$0700,$00F8,$FC00,$0808,$0802
	dc.w	$F007,$0000,$F8FC,$0008,$0908,$0004,$000F,$02F0
	dc.w	$0700,$00F8,$FC00,$0008,$F002,$F007,$0000,$F8FC
	dc.w	$0000,$09F0
