; Object $A1 - Obj26_20E53C (from R71A, old ID $26)
PA1_Obj26_20E53C:
	tst.b   oLayer(a0)
	bne.w   PA1_loc_20E5C4
	tst.b   oRoutine(a0)
	bne.s   PA1_loc_20E586
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.w  #$38e, oTile(a0)
	move.l  #$20e6c4, oMap(a0)
	move.b  oSubtype(a0), oMapFrame(a0)
	move.w  #$96, $2a(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
PA1_loc_20E586:
	subq.w  #$1, $2a(a0)
	bne.s   PA1_loc_20E5B8
	move.w  #$96, $2a(a0)
	jsr     FindObjSlot.l
	bne.s   PA1_loc_20E5B8
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  oSubtype(a0), $28(a1)
	move.b  #$ff, $29(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
PA1_loc_20E5B8:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PA1_loc_20E5C4:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PA1_dat_20E5D8(pc, d0.w), d0
	jsr     PA1_dat_20E5D8(pc, d0.w)
	jmp     DrawObject.l
PA1_dat_20E5D8:
	dc.w	PA1_loc_20E5E0-PA1_dat_20E5D8
	dc.w	PA1_loc_20E654-PA1_dat_20E5D8
	dc.w	PA1_loc_20E670-PA1_dat_20E5D8
	dc.w	PA1_loc_20E69C-PA1_dat_20E5D8
PA1_loc_20E5E0:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.b  #$b5, oColType(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  #$386, oTile(a0)
	move.l  #$20e6f8, oMap(a0)
	move.w  #$20, $2e(a0)
	move.l  #$8000, d0
	btst.b  #$0, oSubtype(a0)
	seq.b   $3f(a0)
	bne.s   PA1_loc_20E630
	neg.l   d0
PA1_loc_20E630:
	move.l  d0, $30(a0)
	lea     oX(a0), a1
	move.w  oX(a0), d0
	cmpi.b  #$2, oSubtype(a0)
	bge.s   PA1_loc_20E64C
	lea     oY(a0), a1
	move.w  oY(a0), d0
PA1_loc_20E64C:
	move.w  a1, $2a(a0)
	move.w  d0, $2c(a0)
PA1_loc_20E654:
	move.l  $30(a0), d0
	movea.w $2a(a0), a1
	add.l   d0, (a1)
	subq.w  #$1, $2e(a0)
	bne.s   PA1_loc_20E66E
	addq.b  #$2, oRoutine(a0)
	move.w  #$1e, $2e(a0)
PA1_loc_20E66E:
	rts     
PA1_loc_20E670:
	subq.w  #$1, $2e(a0)
	bne.s   PA1_loc_20E69A
	addq.b  #$2, oRoutine(a0)
	move.l  #$60000, d0
	move.l  #$ffffc000, d1
	btst.b  #$0, oSubtype(a0)
	bne.s   PA1_loc_20E692
	neg.l   d0
	neg.l   d1
PA1_loc_20E692:
	move.l  d0, $30(a0)
	move.l  d1, $34(a0)
PA1_loc_20E69A:
	rts     
PA1_loc_20E69C:
	move.l  $34(a0), d0
	add.l   d0, $30(a0)
	move.l  $30(a0), d0
	movea.w $2a(a0), a1
	add.l   d0, (a1)
	move.w  (a1), d0
	sub.w   $2c(a0), d0
	smi.b   d0
	cmp.b   $3f(a0), d0
	beq.s   PA1_loc_20E6C2
	jmp     DeleteObject.l
PA1_loc_20E6C2:
	rts     
PA1_loc_20E6C4:
	dc.w	$0008,$0013,$001E,$0029,$02F0,$0580,$00F0,$F005
	dc.w	$8800,$0002,$0005,$9000,$F000,$0598,$0000,$02F0
	dc.w	$0580,$04F0,$0005,$9004,$F002,$F005,$8804,$0000
	dc.w	$0598,$0400
PA1_loc_20E6F8:
	dc.w	$0002,$02F0,$0D00,$00F0,$000D,$1000,$F000
