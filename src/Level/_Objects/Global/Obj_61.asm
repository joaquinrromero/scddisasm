; Object $61 - Obj30_20DB54 (from R33C, old ID $30)
P61_Obj30_20DB54:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P61_dat_20DB62(pc, d0.w), d0
	jmp     P61_dat_20DB62(pc, d0.w)
P61_dat_20DB62:
	dc.w	P61_loc_20DB6A-P61_dat_20DB62
	dc.w	P61_loc_20DBDC-P61_dat_20DB62
	dc.w	P61_loc_20DC08-P61_dat_20DB62
	dc.w	P61_loc_20DC52-P61_dat_20DB62
P61_loc_20DB6A:
	move.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.b  #$30, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  #$31e, oTile(a0)
	move.l  #$20e82c, oMap(a0)
	move.l  #$fffd8000, $30(a0)
	move.w  oY(a0), $2e(a0)
	addi.w  #$ffd0, $2e(a0)
	move.b  #$3e, oColType(a0)
	move.b  #$2, oColStatus(a0)
	bsr.w   FindObjSlot
	bne.s   P61_loc_20DBDC
	move.w  a0, $34(a1)
	dc.b	$13,$7C,$00,$32,$00,$00		; move.b #$32, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	subi.w  #$30, $8(a1)
	move.w  oY(a0), $c(a1)
	move.w  a1, $34(a0)
P61_loc_20DBDC:
	tst.b   oColType(a0)
	bne.s   P61_loc_20DC02
	move.w  #$ac, d0
	jsr     PlayFMSound.l
	move.b  #$4, oRoutine(a0)
	bset.b  #$2, $2c(a0)
	move.b  #$1, oAnim(a0)
	clr.b   oColStatus(a0)
P61_loc_20DC02:
	jmp     DrawObject.l
P61_loc_20DC08:
	bsr.w   P61_sub_20DC84
	addq.b  #$1, $2a(a0)
	cmpi.b  #$10, $2a(a0)
	blt.s   P61_loc_20DC2A
	move.b  #$0, oAnim(a0)
	lea     loc_20E820.l, a1
	jsr     AnimateObject.l
P61_loc_20DC2A:
	move.l  $30(a0), d0
	add.l   d0, oY(a0)
	move.w  $2e(a0), d0
	cmp.w   oY(a0), d0
	blt.s   P61_loc_20DC4C
	bclr.b  #$2, $2c(a0)
	move.w  d0, oY(a0)
	move.b  #$6, oRoutine(a0)
P61_loc_20DC4C:
	jmp     DrawObject.l
P61_loc_20DC52:
	bsr.w   P61_sub_20DC84
	cmpi.w  #$78, $3e(a0)
	bge.s   P61_loc_20DC68
	bsr.w   P61_sub_20E0CE
	jsr     DrawObject.l
P61_loc_20DC68:
	btst.b  #$1, $2c(a0)
	beq.s   P61_loc_20DC82
	movea.w $34(a0), a3
	jsr     DeleteObject.l
	movea.l a3, a1
	jmp     loc_203AF6.l
P61_loc_20DC82:
	rts     
P61_sub_20DC84:
	btst.b  #$1, $2c(a0)
	bne.w   P61_loc_20DCD0
	lea     objects.w, a1
	cmpi.w  #$480, $8(a1)
	blt.s   P61_loc_20DCD0
	cmpi.w  #$51c, $c(a1)
	bgt.s   P61_loc_20DCD0
	bset.b  #$1, $2c(a0)
	move.w  #$67, d0
	jsr     SubCPUCmd.l
	bsr.w   FindObjSlot
	bne.s   P61_loc_20DCD0
	dc.b	$13,$7C,$00,$3F,$00,$00		; move.b #$3f, $0(a1) (raw: not reproducible by assembler)
	move.b  #$6, $24(a1)
	move.w  #$420, $8(a1)
	move.w  #$540, $c(a1)
P61_loc_20DCD0:
	rts     
	tst.b   $2b(a0)
	bne.s   P61_loc_20DCDA
	rts     
P61_loc_20DCDA:
	bchg.b  #$7, $2b(a0)
	bne.s   P61_loc_20DCEE
	move.w  #$5, d0
	ori.b   #$1, oMapFrame(a0)
	bra.s   P61_loc_20DCF8
P61_loc_20DCEE:
	move.w  #$6, d0
	andi.b  #$fe, oMapFrame(a0)
P61_loc_20DCF8:
	subq.b  #$1, $2b(a0)
	movem.l d7/a1-a3, -(a7)
	jsr     LoadPalette.l
	movem.l (a7)+, d7/a1-a3
	rts     
P61_sub_20E0CE:
	addq.w  #$1, $3e(a0)
	cmpi.w  #$78, $3e(a0)
	beq.s   P61_loc_20E0E4
	bcc.s   P61_loc_20E0F4
	lea     P61_dat_20E0F6(pc), a2
	bra.w   P61_loc_20E190
P61_loc_20E0E4:
	bset.b  #$0, $2c(a0)
	movea.w $34(a0), a1
	bset.b  #$0, $2c(a1)
P61_loc_20E0F4:
	rts     
P61_dat_20E0F6:
	dc.w	$0004,$000A,$FFD0,$FFF0,$0030,$0010,$FFF0,$FFF0
	dc.w	$0010,$0010,$FFE0,$0000,$0030,$FFF0,$FFD0,$0010
	dc.w	$FFF0,$0010,$0010,$FFF0,$0020,$0000,$5268,$003E
	dc.w	$0C68,$0004,$003E,$6408,$45FA,$0008,$6000,$005C
	dc.w	$4E75,$0001,$0003,$0000,$0000,$FFE0,$0000,$0020
	dc.w	$0000,$5268,$003E,$0C68,$0004,$003E,$6408,$45FA
	dc.w	$0008,$6000,$0036,$4E75,$0001,$0003,$0000,$FFC8
	dc.w	$FFE0,$FFC8,$0020,$FFC8,$5268,$003E,$0C68,$0003
	dc.w	$003E,$6408,$45FA,$0008,$6000,$0010,$4E75,$0001
	dc.w	$0002,$FFF0,$FFC8,$0010,$FFC8
P61_loc_20E190:
	moveq   #$0, d2
	moveq   #$0, d0
	move.w  $3e(a0), d2
	move.w  (a2)+, d0
	divu.w  d0, d2
	move.l  d2, d0
	swap    d0
	tst.w   d0
	bne.s   P61_loc_20E1EC
	andi.l  #$ffff, d2
	moveq   #$0, d0
	move.w  (a2)+, d0
	divu.w  d0, d2
	swap    d2
	add.w   d2, d2
	add.w   d2, d2
	bsr.w   FindObjSlot
	bne.s   P61_loc_20E1EC
	adda.w  d2, a2
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.w  (a2)+, d0
	add.w   d0, $8(a1)
	move.w  (a2), d0
	add.w   d0, $c(a1)
	dc.b	$13,$7C,$00,$3E,$00,$00		; move.b #$3e, $0(a1) (raw: not reproducible by assembler)
	move.b  #$a, $24(a1)
	move.w  #$9e, d0
	jsr     PlayFMSound.l
P61_loc_20E1EC:
	rts     
