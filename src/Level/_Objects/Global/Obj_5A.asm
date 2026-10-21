; Object $5A - Obj2D_20B336 (from R31A, old ID $2D)
Obj2D_20B336:
	move.b  oSubtype(a0), d0
	subq.b  #$1, d0
	bmi.s   P5A_loc_20B342
	bra.w   P5A_loc_20B55E
P5A_loc_20B342:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P5A_dat_20B362(pc, d0.w), d0
	jsr     P5A_dat_20B362(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P5A_dat_20B362:
	dc.w	P5A_loc_20B36C-P5A_dat_20B362
	dc.w	P5A_loc_20B3B0-P5A_dat_20B362
	dc.w	P5A_loc_20B3C4-P5A_dat_20B362
	dc.w	P5A_loc_20B3F2-P5A_dat_20B362
	dc.w	P5A_loc_20B452-P5A_dat_20B362
P5A_loc_20B36C:
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$0, oMapFrame(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.w  #$a421, oTile(a0)
	move.w  #$3d, $2a(a0)
	lea     P5A_dat_20B4BE(pc), a1
	tst.b   oSubtype(a0)
	bmi.s   P5A_loc_20B3AC
	lea     P5A_dat_20B500(pc), a1
	st.b    $3f(a0)
P5A_loc_20B3AC:
	move.l  a1, oMap(a0)
P5A_loc_20B3B0:
	addi.w  #$ffff, $2a(a0)
	bne.s   P5A_loc_20B3C2
	addq.b  #$2, oRoutine(a0)
	move.w  #$3d, $2a(a0)
P5A_loc_20B3C2:
	rts     
P5A_loc_20B3C4:
	addi.w  #$ffff, $2a(a0)
	bne.s   P5A_loc_20B3E0
	move.b  #$25, oColType(a0)
	addq.b  #$2, oRoutine(a0)
	addq.b  #$1, oAnim(a0)
	move.w  #$33, $2a(a0)
P5A_loc_20B3E0:
	lea     P5A_loc_20B4AA.l, a1
	jsr     AnimateObject.l
	jmp     DrawObject.l
P5A_loc_20B3F2:
	addi.w  #$ffff, $2a(a0)
	bne.s   P5A_loc_20B450
	move.b  #$26, oColType(a0)
	addq.b  #$2, oRoutine(a0)
	addq.b  #$1, oAnim(a0)
	move.l  #$8000, $30(a0)
	move.w  #$20, $2a(a0)
	move.l  #$ffff8000, $2c(a0)
	tst.b   oSubtype(a0)
	bpl.s   P5A_loc_20B432
	move.w  #$30, $2a(a0)
	move.l  #$ffffc000, $2c(a0)
P5A_loc_20B432:
	move.w  oX(a0), d0
	lea     objects.w, a1
	sub.w   $8(a1), d0
	bpl.s   P5A_loc_20B450
	neg.l   $2c(a0)
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$0, oFlags(a0)
P5A_loc_20B450:
	bra.s   P5A_loc_20B3E0
P5A_loc_20B452:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	move.l  $30(a0), d0
	add.l   d0, oY(a0)
	addi.w  #$ffff, $2a(a0)
	bne.s   P5A_loc_20B4A6
	move.w  #$41, $2a(a0)
	tst.b   oSubtype(a0)
	bpl.s   P5A_loc_20B47C
	move.w  #$61, $2a(a0)
P5A_loc_20B47C:
	neg.l   $30(a0)
	tst.b   $3f(a0)
	beq.s   P5A_loc_20B4A6
	jsr     FindObjSlot.l
	bne.s   P5A_loc_20B4A6
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.l  oX(a0), $8(a1)
	move.l  oY(a0), $c(a1)
	move.b  #$1, $28(a1)
P5A_loc_20B4A6:
	bra.w   P5A_loc_20B3E0
P5A_loc_20B4AA:
	dc.w	$0006,$000A,$000D,$1D00,$0101,$3102,$0204,$0304
	dc.w	$0504,$FF00
P5A_dat_20B4BE:
	dc.w	$0083,$0089,$008F,$000C,$0021,$0031,$04F6,$0C00
	dc.w	$2FF0,$FE00,$0004,$F0FE,$0400,$33F8,$0608,$0035
	dc.w	$F003,$F800,$000A,$F0F8,$0800,$38F8,$0008,$003B
	dc.w	$F003,$F600,$0011,$F0F6,$0400,$3EF8,$FE0C,$0040
	dc.w	$F000
P5A_dat_20B500:
	dc.w	$0041,$0047,$004D,$000C,$0021,$0031,$04F4,$0C00
	dc.w	$00F0,$FC00,$0004,$F0FC,$0400,$05F8,$0408,$0007
	dc.w	$F003,$F800,$000A,$F0F8,$0800,$0BF8,$0008,$000E
	dc.w	$F003,$F800,$0011,$F0F8,$0400,$12F8,$000C,$0014
	dc.w	$F001,$F409,$0018,$F401,$F40A,$001E,$F403,$F003
	dc.w	$0027,$F4F0,$0300,$2BFC,$F003,$0827,$0400
P5A_loc_20B55E:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P5A_dat_20B572(pc, d0.w), d0
	jsr     P5A_dat_20B572(pc, d0.w)
	jmp     DrawObject.l
P5A_dat_20B572:
	dc.w	P5A_loc_20B578-P5A_dat_20B572
	dc.w	P5A_loc_20B5AE-P5A_dat_20B572
	dc.w	P5A_loc_20B5C8-P5A_dat_20B572
P5A_loc_20B578:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$6, oXRadius(a0)
	move.b  #$6, oWidth(a0)
	move.b  #$6, oYRadius(a0)
	move.w  #$a7ae, oTile(a0)
	move.l  #$209bf2, oMap(a0)
	move.w  #$b4, $2a(a0)
P5A_loc_20B5AE:
	addi.w  #$ffff, $2a(a0)
	beq.s   P5A_loc_20B5C8
	addi.l  #$10000, oY(a0)
	lea     P5A_dat_20B5CE(pc), a1
	jmp     AnimateObject.l
P5A_loc_20B5C8:
	jmp     DeleteObject.l
P5A_dat_20B5CE:
	dc.w	$0002,$0504,$0506,$07FF
