; Object $9C - Obj31_20DB72 (from R61A, old ID $31)
P9C_Obj31_20DB72:
	tst.b   oSubtype(a0)
	bmi.w   P9C_loc_20DF82
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P9C_dat_20DBA4(pc, d0.w), d0
	jsr     P9C_dat_20DBA4(pc, d0.w)
	lea     P9C_dat_20DE10(pc), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P9C_dat_20DBA4:
	dc.w	P9C_loc_20DBB8-P9C_dat_20DBA4
	dc.w	P9C_loc_20DC0E-P9C_dat_20DBA4
	dc.w	P9C_loc_20DC24-P9C_dat_20DBA4
	dc.w	P9C_loc_20DCAA-P9C_dat_20DBA4
	dc.w	P9C_loc_20DCB4-P9C_dat_20DBA4
	dc.w	P9C_loc_20DCDA-P9C_dat_20DBA4
	dc.w	P9C_loc_20DCE8-P9C_dat_20DBA4
	dc.w	P9C_loc_20DCF2-P9C_dat_20DBA4
	dc.w	P9C_loc_20DD2E-P9C_dat_20DBA4
	dc.w	P9C_loc_20DDD2-P9C_dat_20DBA4
P9C_loc_20DBB8:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$18, oXRadius(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.w  #$a457, oTile(a0)
	move.b  #$31, oColType(a0)
	move.w  #$fff8, $30(a0)
	lea     P9C_dat_20DE1C(pc), a1
	move.l  #$ffff0000, d0
	tst.b   oSubtype(a0)
	beq.s   P9C_loc_20DC06
	lea     P9C_dat_20DF04(pc), a1
	move.l  #$ffff8000, d0
P9C_loc_20DC06:
	move.l  a1, oMap(a0)
	move.l  d0, $2c(a0)
P9C_loc_20DC0E:
	addq.b  #$2, oRoutine(a0)
	move.w  #$200, d0
	tst.b   oSubtype(a0)
	beq.s   P9C_loc_20DC20
	move.w  #$400, d0
P9C_loc_20DC20:
	move.w  d0, $2a(a0)
P9C_loc_20DC24:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	tst.b   oSubtype(a0)
	bne.s   P9C_loc_20DC4E
	tst.w   $32(a0)
	beq.s   P9C_loc_20DC3E
	subq.w  #$1, $32(a0)
	bra.s   P9C_loc_20DC4E
P9C_loc_20DC3E:
	lea     objects.w, a1
	bsr.s   P9C_sub_20DC5C
	beq.s   P9C_loc_20DC4E
	move.b  #$c, oRoutine(a0)
	rts     
P9C_loc_20DC4E:
	subq.w  #$1, $2a(a0)
	bpl.s   P9C_loc_20DC5A
	move.b  #$6, oRoutine(a0)
P9C_loc_20DC5A:
	rts     
P9C_dat_20DE10:
	dc.w	$0004,$0008,$0100,$01FF,$0102,$03FF
P9C_dat_20DE1C:
	dc.w	$0008,$004A,$008C,$00BA,$0DEE,$0C00,$10E9,$EE00
	dc.w	$0014,$09F4,$0500,$00E8,$F401,$0004,$F8F4,$0000
	dc.w	$0600,$F400,$0007,$08F4,$0000,$0810,$FC08,$0009
	dc.w	$0004,$0400,$0CE8,$0400,$000E,$F804,$0000,$0F00
	dc.w	$0400,$1007,$0804,$0010,$0810,$0DF1,$0C00,$15E9
	dc.w	$F100,$0019,$09F4,$0500,$00E8,$F401,$0004,$F8F4
	dc.w	$0000,$0600,$F400,$0007,$08F4,$0000,$0810,$FC08
	dc.w	$0009,$0004,$0400,$0CE8,$0400,$000E,$F804,$0000
	dc.w	$0F00,$0400,$1007,$0804,$0010,$0810,$09EA,$0C00
	dc.w	$10F1,$EA00,$0014,$11F0,$0500,$00F0,$F001,$0004
	dc.w	$00F0,$0000,$0608,$F800,$001A,$0800,$0400,$0CF0
	dc.w	$0004,$001B,$0008,$0800,$1DF8,$09ED,$0C00,$15F1
	dc.w	$ED00,$0019,$11F0,$0500,$00F0,$F001,$0004,$00F0
	dc.w	$0000,$0608,$F800,$001A,$0800,$0400,$0CF0,$0004
	dc.w	$001B,$0008,$0800,$1DF8
P9C_dat_20DF04:
	dc.w	$0004,$0041,$0CEE,$0C00,$10E9,$EE00,$0014,$09F4
	dc.w	$0500,$00E8,$F400,$0028,$F8F4,$0000,$0600,$F400
	dc.w	$0007,$08F4,$0000,$2910,$FC0C,$002A,$F804,$0800
	dc.w	$2EE8,$0400,$000F,$0004,$0010,$0708,$0400,$1029
	dc.w	$100C,$F10C,$0015,$E9F1,$0000,$1909,$F405,$0000
	dc.w	$E8F4,$0000,$28F8,$F400,$0006,$00F4,$0000,$0708
	dc.w	$F400,$0029,$10FC,$0C00,$2AF8,$0408,$002E,$E804
	dc.w	$0000,$0F00,$0400,$1007,$0804,$0010,$2910
P9C_loc_20DF82:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P9C_dat_20DF9C(pc, d0.w), d0
	jsr     P9C_dat_20DF9C(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P9C_sub_20DC5C:
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	subi.w  #$ffa0, d0
	subi.w  #$c0, d0
	bcc.s   P9C_loc_20DCA6
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	spl.b   d1
	subi.w  #$ff88, d0
	subi.w  #$f0, d0
	bcc.s   P9C_loc_20DCA6
	btst.b  #$0, oSprFlags(a0)
	sne.b   d2
	eor.b   d1, d2
	beq.s   P9C_loc_20DCA2
	neg.l   $2c(a0)
	neg.w   $30(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
P9C_loc_20DCA2:
	moveq   #$ff, d0
	rts     
P9C_loc_20DCA6:
	moveq   #$0, d0
	rts     
P9C_loc_20DCAA:
	addq.b  #$2, oRoutine(a0)
	move.w  #$1e, $2a(a0)
P9C_loc_20DCB4:
	subq.w  #$1, $2a(a0)
	bpl.s   P9C_loc_20DCD8
	addq.b  #$2, oRoutine(a0)
	move.w  #$1e, $2a(a0)
	neg.l   $2c(a0)
	neg.w   $30(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
P9C_loc_20DCD8:
	rts     
P9C_loc_20DCDA:
	subq.w  #$1, $2a(a0)
	bpl.s   P9C_loc_20DCE6
	move.b  #$2, oRoutine(a0)
P9C_loc_20DCE6:
	rts     
P9C_loc_20DCE8:
	addq.b  #$2, oRoutine(a0)
	move.w  #$1e, $2a(a0)
P9C_loc_20DCF2:
	subq.w  #$1, $2a(a0)
	bpl.s   P9C_loc_20DD2C
	addq.b  #$2, oRoutine(a0)
	move.w  #$1e, $2a(a0)
	move.b  #$1, oAnim(a0)
	move.b  #$32, oColType(a0)
	move.b  #$10, oYRadius(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.w  $30(a0), d0
	add.w   d0, oX(a0)
	addq.w  #$4, oY(a0)
P9C_loc_20DD2C:
	rts     
P9C_loc_20DD2E:
	subq.w  #$1, $2a(a0)
	bpl.w   P9C_loc_20DDD0
	addq.b  #$2, oRoutine(a0)
	move.w  #$1e, $2a(a0)
	jsr     FindObjSlot.l
	bne.w   P9C_loc_20DDD0
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.b  oSprFlags(a0), $1(a1)
	move.w  oTile(a0), $2(a1)
	move.l  #$20e00e, $4(a1)
	move.b  #$1, $18(a1)
	move.b  #$10, $16(a1)
	move.b  #$10, $17(a1)
	move.b  #$10, $19(a1)
	move.b  #$b3, $20(a1)
	move.w  oY(a0), $c(a1)
	addi.w  #$17, $c(a1)
	move.l  #$20000, $30(a1)
	move.w  oX(a0), $8(a1)
	move.w  #$7, d0
	move.l  #$20000, d1
	btst.b  #$0, oSprFlags(a0)
	bne.s   P9C_loc_20DDB8
	neg.w   d0
	neg.l   d1
P9C_loc_20DDB8:
	add.w   d0, $8(a1)
	move.l  d1, $2c(a1)
	tst.b   oSprFlags(a0)
	bpl.s   P9C_loc_20DDD0
	move.w  #$a0, d0
	jsr     PlayFMSound.l
P9C_loc_20DDD0:
	rts     
P9C_loc_20DDD2:
	subq.w  #$1, $2a(a0)
	bpl.s   P9C_loc_20DE0E
	move.b  #$2, oRoutine(a0)
	move.w  #$3c, $32(a0)
	move.b  #$0, oAnim(a0)
	move.b  #$31, oColType(a0)
	move.b  #$c, oYRadius(a0)
	move.b  #$18, oXRadius(a0)
	move.b  #$18, oWidth(a0)
	move.w  $30(a0), d0
	sub.w   d0, oX(a0)
	subq.w  #$4, oY(a0)
P9C_loc_20DE0E:
	rts     
P9C_dat_20DF9C:
	dc.w	P9C_loc_20DFA4-P9C_dat_20DF9C
	dc.w	P9C_loc_20DFAE-P9C_dat_20DF9C
	dc.w	P9C_loc_20DFC6-P9C_dat_20DF9C
	dc.w	P9C_loc_20DFE2-P9C_dat_20DF9C
P9C_loc_20DFA4:
	addq.b  #$2, oRoutine(a0)
	move.w  #$3, $2a(a0)
P9C_loc_20DFAE:
	subq.w  #$1, $2a(a0)
	bpl.s   P9C_loc_20DFC4
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, oMapFrame(a0)
	move.w  #$a, $2a(a0)
P9C_loc_20DFC4:
	rts     
P9C_loc_20DFC6:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	move.l  $30(a0), d0
	add.l   d0, oY(a0)
	subq.w  #$1, $2a(a0)
	bpl.s   P9C_loc_20DFE0
	addq.b  #$2, oRoutine(a0)
P9C_loc_20DFE0:
	rts     
P9C_loc_20DFE2:
	tst.b   oSprFlags(a0)
	bmi.s   P9C_loc_20DFEE
	jmp     DeleteObject.l
P9C_loc_20DFEE:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	move.l  $30(a0), d0
	add.l   d0, oY(a0)
	lea     P9C_dat_20E008(pc), a1
	jmp     AnimateObject.l
P9C_dat_20E008:
	dc.w	$0002,$0102,$03FF
P9C_loc_20E00E:
	dc.w	$0008,$000E,$0019,$002E,$01F8,$0500,$20F8,$02F8
	dc.w	$0400,$24F8,$0004,$1824,$F804,$F800,$0026,$F8F8
	dc.w	$0008,$2600,$0000,$1026,$F800,$0018,$2600,$04F8
	dc.w	$0000,$27F8,$F800,$0827,$0000,$0010,$27F8,$0000
	dc.w	$1827,$0000
