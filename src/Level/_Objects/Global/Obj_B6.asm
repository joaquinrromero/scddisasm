; Object $B6 - Obj27_20C9DE (from R81A, old ID $27)
PB6_Obj27_20C9DE:
	tst.b   oLayer(a0)
	bne.w   PB6_loc_20CBDC
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PB6_dat_20CA0E(pc, d0.w), d0
	jsr     PB6_dat_20CA0E(pc, d0.w)
	lea     PB6_dat_20CC18(pc), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	move.w  $36(a0), d0
	jmp     CheckObjDespawn2.l
PB6_dat_20CA0E:
	dc.w	PB6_loc_20CA18-PB6_dat_20CA0E
	dc.w	PB6_loc_20CB14-PB6_dat_20CA0E
	dc.w	PB6_loc_20CB4C-PB6_dat_20CA0E
	dc.w	PB6_loc_20CB68-PB6_dat_20CA0E
	dc.w	PB6_loc_20CBA2-PB6_dat_20CA0E
PB6_loc_20CA18:
	move.w  oX(a0), $36(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$4316, oTile(a0)
	move.l  #$23ebf2, oMap(a0)
	move.b  #$a9, oColType(a0)
	move.b  #$50, oWidth(a0)
	move.b  #$50, oYRadius(a0)
	move.l  #$10000, $2c(a0)
	move.l  #$10000, $30(a0)
	btst.b  #$0, oSubtype(a0)
	beq.s   PB6_loc_20CA72
	neg.l   $2c(a0)
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$0, oFlags(a0)
PB6_loc_20CA72:
	btst.b  #$1, oSubtype(a0)
	beq.s   PB6_loc_20CA8A
	neg.l   $30(a0)
	bset.b  #$1, oSprFlags(a0)
	bset.b  #$1, oFlags(a0)
PB6_loc_20CA8A:
	move.w  #$3c, $2a(a0)
	move.b  #$8, oRoutine(a0)
	tst.b   oSubtype(a0)
	bpl.s   PB6_loc_20CAA8
	move.b  #$9, oAnim(a0)
	move.b  #$4, oRoutine(a0)
PB6_loc_20CAA8:
	jsr     FindObjSlot.l
	bne.w   PB6_loc_20CC12
	move.w  a1, $3a(a0)
	move.w  a0, $2a(a1)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  oSprFlags(a0), $1(a1)
	move.w  oTile(a0), $2(a1)
	move.b  oSubtype(a0), $28(a1)
	move.b  #$ff, $29(a1)
	move.b  oPriority(a0), $18(a1)
	addq.b  #$1, $18(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	tst.b   oSubtype(a0)
	bpl.s   PB6_loc_20CB14
	moveq   #$50, d0
	moveq   #$50, d1
	btst.b  #$0, oSubtype(a0)
	beq.s   PB6_loc_20CB02
	neg.w   d0
PB6_loc_20CB02:
	btst.b  #$1, oSubtype(a0)
	beq.s   PB6_loc_20CB0C
	neg.w   d1
PB6_loc_20CB0C:
	sub.w   d0, $8(a1)
	sub.w   d1, $c(a1)
PB6_loc_20CB14:
	addi.w  #$ffff, $2a(a0)
	bne.s   PB6_loc_20CB38
	addq.b  #$1, oAnim(a0)
	move.w  #$9, $2a(a0)
	addi.w  #$ffff, $34(a0)
	bne.s   PB6_loc_20CB38
	addq.b  #$2, oRoutine(a0)
	move.w  #$3c, $2a(a0)
PB6_loc_20CB38:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	move.l  $30(a0), d0
	add.l   d0, oY(a0)
	bra.w   PB6_loc_20CBBC
PB6_loc_20CB4C:
	addi.w  #$ffff, $2a(a0)
	bne.s   PB6_loc_20CB64
	addq.b  #$2, oRoutine(a0)
	move.w  #$9, $34(a0)
	move.w  #$1, $2a(a0)
PB6_loc_20CB64:
	bra.w   PB6_loc_20CBBC
PB6_loc_20CB68:
	addi.w  #$ffff, $2a(a0)
	bne.s   PB6_loc_20CB8E
	addi.b  #$ff, oAnim(a0)
	move.w  #$9, $2a(a0)
	addi.w  #$ffff, $34(a0)
	bne.s   PB6_loc_20CB8E
	addq.b  #$2, oRoutine(a0)
	move.w  #$3c, $2a(a0)
PB6_loc_20CB8E:
	move.l  $2c(a0), d0
	sub.l   d0, oX(a0)
	move.l  $30(a0), d0
	sub.l   d0, oY(a0)
	bra.w   PB6_loc_20CBBC
PB6_loc_20CBA2:
	addi.w  #$ffff, $2a(a0)
	bne.s   PB6_loc_20CBBC
	addi.b  #$fa, oRoutine(a0)
	move.w  #$9, $34(a0)
	move.w  #$1, $2a(a0)
PB6_loc_20CBBC:
	tst.b   oSprFlags(a0)
	bpl.s   PB6_loc_20CBDA
	addq.w  #$1, $38(a0)
	move.w  $38(a0), d0
	andi.w  #$1f, d0
	bne.s   PB6_loc_20CBDA
	move.w  #$b1, d0
	jsr     PlayFMSound.l
PB6_loc_20CBDA:
	rts     
PB6_loc_20CBDC:
	movea.w $2a(a0), a1
	dc.b	$0C,$29,$00,$27,$00,$00		; cmpi.b #$27, $0(a1) (raw: not reproducible by assembler)
	bne.s   PB6_loc_20CC12
	tst.b   oRoutine(a0)
	bne.s   PB6_loc_20CC0C
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.l  #$20cc50, oMap(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$20, oYRadius(a0)
PB6_loc_20CC0C:
	jmp     DrawObject.l
PB6_loc_20CC12:
	jmp     DeleteObject.l
PB6_dat_20CC18:
	dc.w	$0014,$0018,$001C,$0020,$0024,$0028,$002C,$0030
	dc.w	$0034,$0034,$0100,$01FF,$0102,$03FF,$0104,$05FF
	dc.w	$0106,$07FF,$0108,$09FF,$010A,$0BFF,$010C,$0DFF
	dc.w	$010E,$0FFF,$0110,$11FF
PB6_loc_20CC50:
	dc.w	$0002,$03F0,$0508,$22F0,$E605,$0822,$E6DC,$0508
	dc.w	$22DC
