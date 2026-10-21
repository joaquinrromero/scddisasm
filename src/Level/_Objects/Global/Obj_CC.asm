; Object $CC - Obj2A_20EE04 (from R83C, old ID $2A)
Obj2A_20EE04:
	tst.b   oLayer(a0)
	beq.s   PCC_loc_20EE30
	movea.w $2a(a0), a1
	dc.b	$0C,$29,$00,$2A,$00,$00		; cmpi.b #$2a, $0(a1) (raw: not reproducible by assembler)
	bne.w   PCC_loc_20EF68
	move.w  $2e(a0), d0
	cmp.w   $2e(a1), d0
	bne.w   PCC_loc_20EF68
	move.w  $30(a0), d0
	cmp.w   $30(a1), d0
	bne.w   PCC_loc_20EF68
PCC_loc_20EE30:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PCC_dat_20EE56(pc, d0.w), d0
	jsr     PCC_dat_20EE56(pc, d0.w)
	jsr     DrawObject.l
	tst.b   oLayer(a0)
	bmi.s   PCC_loc_20EE54
	move.w  $2e(a0), d0
	jmp     CheckObjDespawn2.l
PCC_loc_20EE54:
	rts     
PCC_dat_20EE56:
	dc.w	PCC_loc_20EE5E-PCC_dat_20EE56
	dc.w	PCC_loc_20EF00-PCC_dat_20EE56
	dc.w	PCC_loc_20EF10-PCC_dat_20EE56
	dc.w	PCC_loc_20EF50-PCC_dat_20EE56
PCC_loc_20EE5E:
	lea     PCC_dat_20EFE8(pc), a5
	moveq   #$0, d0
	move.b  oLayer(a0), d0
	add.w   d0, d0
	adda.w  (a5, d0.w), a5
	move.w  (a5)+, $2c(a0)
	lea     (a0), a6
	bsr.s   PCC_sub_20EEC0
	move.w  (a5)+, d6
	bra.s   PCC_loc_20EEBA
PCC_loc_20EE7A:
	jsr     FindObjSlot.l
	beq.s   PCC_loc_20EE88
	jmp     DeleteObject.l
PCC_loc_20EE88:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.w  a0, $2a(a1)
	move.b  oSubtype(a0), $28(a1)
	move.b  #$ff, $29(a1)
	move.w  (a5)+, $2c(a1)
	move.w  oX(a0), d0
	move.w  oY(a0), d1
	add.w   (a5)+, d0
	add.w   (a5)+, d1
	move.w  d0, $8(a1)
	move.w  d1, $c(a1)
	lea     (a1), a6
	bsr.s   PCC_sub_20EEC0
PCC_loc_20EEBA:
	dbra    d6, PCC_loc_20EE7A
	rts     
PCC_dat_20EFE8:
	dc.w	$0004,$0008,$003C,$0000,$003C,$0001,$003C,$0020
	dc.w	$0000
PCC_sub_20EEC0:
	move.b  #$2, $24(a6)
	ori.b   #$4, $1(a6)
	move.b  #$3, $18(a6)
	move.b  #$10, $17(a6)
	move.b  #$10, $19(a6)
	move.b  #$5, $16(a6)
	move.w  #$34c, $2(a6)
	move.l  #$20ef7e, $4(a6)
	move.w  oX(a0), $2e(a6)
	move.w  oY(a0), $30(a6)
	rts     
PCC_loc_20EF00:
	move.b  #$5, oYRadius(a0)
	move.w  #$78, $2c(a0)
	addq.b  #$2, oRoutine(a0)
PCC_loc_20EF10:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	lea     objects.w, a1
	jsr     TopSolidObject.l
	sne.b   $3e(a0)
	addi.w  #$ffff, $2c(a0)
	bne.s   PCC_loc_20EF4E
	move.b  #$10, oYRadius(a0)
	move.w  #$ff, oAnim(a0)
	addq.b  #$2, oRoutine(a0)
	tst.b   $3e(a0)
	beq.s   PCC_loc_20EF4E
	lea     objects.w, a1
	jmp     GetOffObject.l
PCC_loc_20EF4E:
	rts     
PCC_loc_20EF50:
	lea     PCC_dat_20EF6E(pc), a1
	jsr     AnimateObject.l
	tst.b   oMapFrame(a0)
	bne.s   PCC_loc_20EF66
	move.b  #$2, oRoutine(a0)
PCC_loc_20EF66:
	rts     
PCC_loc_20EF68:
	jmp     DeleteObject.l
PCC_dat_20EF6E:
	dc.w	$0002,$0101,$0203,$0405,$0601,$0203,$0405,$00FF
PCC_loc_20EF7E:
	dc.w	$000E,$0019,$0029,$0039,$0049,$0059,$000E,$02F8
	dc.w	$0500,$00F0,$F805,$0800,$0003,$F408,$0004,$F0FC
	dc.w	$0C00,$07F0,$0408,$000B,$F803,$F004,$000E,$F4F8
	dc.w	$0900,$10F4,$0804,$0016,$FC03,$F004,$0018,$F8F8
	dc.w	$0500,$1AF8,$0804,$1018,$F803,$F004,$080E,$FCF8
	dc.w	$0908,$10F4,$0804,$0816,$F403,$F408,$0804,$F8FC
	dc.w	$0C08,$07F0,$0408,$080B,$F000
