; Object $58 - Obj2A_20B136 (from R31A, old ID $2A)
Obj2A_20B136:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P58_dat_20B154(pc, d0.w), d0
	jsr     P58_dat_20B154(pc, d0.w)
	jsr     DrawObject.l
	move.w  $3e(a0), d0
	jmp     CheckObjDespawn2.l
P58_dat_20B154:
	dc.w	P58_loc_20B158-P58_dat_20B154
	dc.w	P58_loc_20B1C2-P58_dat_20B154
P58_loc_20B158:
	move.w  oX(a0), $3e(a0)
	addq.b  #$2, oRoutine(a0)
	move.l  #$20b27a, oMap(a0)
	move.w  #$435e, oTile(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$e7, oColType(a0)
	move.w  #$c0, $30(a0)
	move.w  #$60, $2e(a0)
	btst.b  #$7, oSubtype(a0)
	bne.s   P58_loc_20B1AE
	move.w  #$a0, $30(a0)
	move.w  #$50, $2e(a0)
P58_loc_20B1AE:
	move.l  #$10000, $2a(a0)
	btst.b  #$6, oSubtype(a0)
	bne.s   P58_loc_20B1C2
	neg.l   $2a(a0)
P58_loc_20B1C2:
	tst.b   oColStatus(a0)
	beq.w   P58_loc_20B252
	tst.b   oSprFlags(a0)
	bpl.s   P58_loc_20B1DA
	move.w  #$b5, d0
	jsr     PlayFMSound.l
P58_loc_20B1DA:
	lea     objects.w, a1
	clr.b   oColStatus(a0)
	move.w  $8(a1), d5
	move.w  $c(a1), d6
	sub.w   oX(a0), d5
	sub.w   oY(a0), d6
	move.w  d6, d0
	subi.w  #$fff8, d0
	subi.w  #$10, d0
	bcc.s   P58_loc_20B208
	move.w  #$0, $10(a1)
	bra.w   P58_loc_20B252
P58_loc_20B208:
	move.w  d5, d0
	subi.w  #$ffe8, d0
	subi.w  #$30, d0
	bcc.s   P58_loc_20B224
	move.w  #$700, $12(a1)
	tst.w   d6
	bpl.s   P58_loc_20B222
	neg.w   $12(a1)
P58_loc_20B222:
	bra.s   P58_loc_20B240
P58_loc_20B224:
	move.w  #$4f3, $10(a1)
	tst.w   d5
	bpl.s   P58_loc_20B232
	neg.w   $10(a1)
P58_loc_20B232:
	move.w  #$4f3, $12(a1)
	tst.w   d6
	bpl.s   P58_loc_20B240
	neg.w   $12(a1)
P58_loc_20B240:
	bset.b  #$1, $22(a1)
	bclr.b  #$4, $22(a1)
	bclr.b  #$5, $22(a1)
P58_loc_20B252:
	lea     oX(a0), a1
	tst.w   oSubtype(a0)
	bmi.s   P58_loc_20B260
	lea     oY(a0), a1
P58_loc_20B260:
	move.l  $2a(a0), d0
	add.l   d0, (a1)
	addi.w  #$ffff, $2e(a0)
	bne.s   P58_loc_20B278
	move.w  $30(a0), $2e(a0)
	neg.l   $2a(a0)
P58_loc_20B278:
	rts     
P58_loc_20B27A:
	dc.w	$0002,$06F0,$0C00,$00E0,$F80D,$0004,$E008,$0C10
	dc.w	$00E0,$F00C,$0800,$00F8,$0D08,$0400,$080C,$1800
	dc.w	$0000
