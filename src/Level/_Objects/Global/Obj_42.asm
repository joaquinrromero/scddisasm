; Object $42 - Obj42_20F23A (from R42A, old ID $42)
P42_Obj42_20F23A:
	tst.b   oSubtype(a0)
	bmi.w   P42_loc_20F32E
	tst.b   oRoutine(a0)
	bne.s   P42_loc_20F2A6
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$8, oXRadius(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  #$4318, oTile(a0)
	move.l  #$20f326, oMap(a0)
	move.l  #$fffd0000, $2c(a0)
	move.w  #$20, d6
	tst.b   oSubtype(a0)
	beq.s   P42_loc_20F29C
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$0, oFlags(a0)
	neg.l   $2c(a0)
	neg.w   d6
P42_loc_20F29C:
	move.w  oX(a0), $30(a0)
	add.w   d6, $30(a0)
P42_loc_20F2A6:
	addi.w  #$ffff, $2a(a0)
	bpl.s   P42_loc_20F31A
	move.w  #$1e, $2a(a0)
	jsr     FindObjSlot.l
	bne.s   P42_loc_20F31A
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.w  $30(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	addq.w  #$4, $c(a1)
	move.l  $2c(a0), $2c(a1)
	move.b  oSprFlags(a0), $1(a1)
	move.b  oPriority(a0), $18(a1)
	addq.b  #$1, $18(a1)
	move.b  #$20, $17(a1)
	move.b  #$20, $19(a1)
	move.b  #$6, $16(a1)
	move.w  #$318, $2(a1)
	move.l  #$20f38a, $4(a1)
	move.b  oSprFlags(a0), $1(a1)
	move.b  oFlags(a0), $22(a1)
P42_loc_20F31A:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P42_loc_20F326:
	dc.w	$0002,$01F0,$0700,$00F8
P42_loc_20F32E:
	lea     objects.w, a1
	bsr.s   P42_sub_20F35E
	bcc.s   P42_loc_20F340
	move.l  $2c(a0), d0
	asr.l   #$8, d0
	move.w  d0, $14(a1)
P42_loc_20F340:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	lea     P42_dat_20F382(pc), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P42_sub_20F35E:
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	subi.w  #$fff4, d0
	subi.w  #$18, d0
	bcc.s   P42_loc_20F380
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	subi.w  #$ffec, d0
	subi.w  #$28, d0
P42_loc_20F380:
	rts     
P42_dat_20F382:
	dc.w	$0002,$0900,$0102,$03FF
P42_loc_20F38A:
	dc.w	$0008,$0013,$001E,$0029,$02F8,$0900,$08F0,$F801
	dc.w	$000E,$0802,$F809,$1008,$F0F8,$0110,$1008,$02F8
	dc.w	$0900,$08F0,$F801,$000E,$0802,$F809,$1008,$F0F8
	dc.w	$0110,$1008
