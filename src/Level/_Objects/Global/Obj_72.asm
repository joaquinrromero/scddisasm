; Object $72 - Obj08_20C26C (from R71A, old ID $08)
P72_Obj08_20C26C:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P72_dat_20C286(pc, d0.w), d0
	jsr     P72_dat_20C286(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P72_dat_20C286:
	dc.w	P72_loc_20C28E-P72_dat_20C286
	dc.w	P72_loc_20C2D2-P72_dat_20C286
	dc.w	P72_loc_20C2D6-P72_dat_20C286
	dc.w	P72_loc_20C304-P72_dat_20C286
P72_loc_20C28E:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$300, oTile(a0)
	move.l  #$20c41e, oMap(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.b  #$2, oMapFrame(a0)
	tst.b   oSubtype(a0)
	beq.s   P72_loc_20C2D2
	move.b  #$0, oMapFrame(a0)
	move.w  #$f800, oYVel(a0)
	move.b  #$6, oRoutine(a0)
	bra.s   P72_loc_20C304
P72_loc_20C2D2:
	bra.w   P72_loc_20C326
P72_loc_20C2D6:
	tst.b   $2a(a0)
	beq.s   P72_loc_20C2EE
	jsr     ObjMove.l
	subq.b  #$1, $2a(a0)
	bne.s   P72_loc_20C2EC
	neg.w   oXVel(a0)
P72_loc_20C2EC:
	rts     
P72_loc_20C2EE:
	jsr     ObjMove.l
	move.w  oX(a0), d0
	cmp.w   $2c(a0), d0
	bne.s   P72_loc_20C2EC
	subq.b  #$2, oRoutine(a0)
	rts     
P72_loc_20C304:
	addi.w  #$40, oYVel(a0)
	jsr     ObjMove.l
	move.w  cameraY.w, d0
	addi.w  #$e8, d0
	cmp.w   oY(a0), d0
	bcc.s   P72_loc_20C324
	jmp     DeleteObject.l
P72_loc_20C324:
	rts     
P72_loc_20C326:
	tst.b   debugMode.l
	bne.s   P72_loc_20C338
	lea     objects.w, a2
	bsr.s   P72_sub_20C33A
	bne.w   P72_loc_20C352
P72_loc_20C338:
	rts     
P72_sub_20C33A:
	btst.b  #$1, $22(a2)
	beq.s   P72_loc_20C346
	moveq   #$0, d0
	rts     
P72_loc_20C346:
	move.w  #$20, d2
	move.w  #$10, d3
	bra.w   loc_20BFA4
P72_loc_20C352:
	clr.b   $FFFFD02C.w
	jsr     FindObjSlot.l
	bne.s   P72_loc_20C396
	dc.b	$13,$7C,$00,$08,$00,$00		; move.b #$8, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  #$1, $28(a1)
	movea.l a1, a3
	jsr     FindObjSlot.l
	bne.s   P72_loc_20C396
	dc.b	$13,$7C,$00,$09,$00,$00		; move.b #$9, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subq.w  #$6, $c(a1)
P72_loc_20C396:
	move.w  #$ce, d0
	jsr     PlayFMSound.l
	addq.b  #$2, oRoutine(a0)
	move.w  oX(a0), $2c(a0)
	move.b  #$6, $2a(a0)
	move.w  oX(a0), d0
	cmp.w   $8(a2), d0
	bcc.s   P72_loc_20C3E6
	move.w  #$f000, $10(a2)
	bset.b  #$0, $22(a1)
	move.w  #$200, $10(a3)
	addi.w  #$10, $8(a1)
	move.w  $10(a2), $14(a2)
	move.w  #$800, oXVel(a0)
	bset.b  #$0, $22(a2)
	rts     
P72_loc_20C3E6:
	move.w  #$1000, $10(a2)
	bclr.b  #$0, $22(a1)
	move.w  #$fe00, $10(a3)
	subi.w  #$10, $8(a1)
	move.w  $10(a2), $14(a2)
	move.w  #$f800, oXVel(a0)
	bclr.b  #$0, $22(a2)
	rts     
P72_loc_20C412:
	dc.w	$0002,$0501,$0101,$0101,$0101,$01FF
P72_loc_20C41E:
	dc.w	$000A,$0010,$0016,$0022,$002E,$01FC,$0400,$00F8
	dc.w	$01F8,$0500,$02F8,$02F4,$0E00,$06E0,$F40E,$0806
	dc.w	$0000,$02E0,$0B00,$12F4,$000B,$1012,$F400,$07E4
	dc.w	$0A00,$1E04,$EC00,$0027,$FCF4,$0500,$28F4,$FC00
	dc.w	$002C,$ECFC,$0000,$2D04,$0400,$002E,$FC04,$0A00
	dc.w	$2FE4
