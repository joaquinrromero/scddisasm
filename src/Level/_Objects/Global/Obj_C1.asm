; Object $C1 - Obj28_20CC62 (from R81A, old ID $28)
PC1_Obj28_20CC62:
	tst.b   oSubtype(a0)
	beq.s   PC1_loc_20CC6C
	bra.w   PC1_loc_20CE10
PC1_loc_20CC6C:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PC1_dat_20CC94(pc, d0.w), d0
	jsr     PC1_dat_20CC94(pc, d0.w)
	lea     PC1_dat_20CDAA(pc), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	move.w  $30(a0), d0
	jmp     CheckObjDespawn2.l
PC1_dat_20CC94:
	dc.w	PC1_loc_20CC9A-PC1_dat_20CC94
	dc.w	PC1_loc_20CD6C-PC1_dat_20CC94
	dc.w	PC1_loc_20CD84-PC1_dat_20CC94
PC1_loc_20CC9A:
	move.w  oX(a0), $30(a0)
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.w  #$36a, oTile(a0)
	move.w  #$80, $2a(a0)
	move.l  #$10000, $2c(a0)
	move.l  #$20cdb0, oMap(a0)
	move.b  #$8, oXRadius(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$2e, oYRadius(a0)
	jsr     FindNextObjSlot.l
	beq.s   PC1_loc_20CCEC
	jmp     DeleteObject.l
PC1_loc_20CCEC:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.w  a0, $3e(a1)
	move.b  #$1, $28(a1)
	lea     (a1), a2
	jsr     FindNextObjSlot.l
	beq.s   PC1_loc_20CD0C
	jmp     DeleteObject.l
PC1_loc_20CD0C:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.w  a0, $3e(a1)
	move.b  #$ff, $28(a1)
	move.w  #$ffd4, $3c(a1)
	move.w  #$14, $3c(a2)
	bset.b  #$1, $1(a2)
	bset.b  #$1, $22(a2)
	lea     (a1), a6
	bsr.s   PC1_sub_20CD3A
	lea     (a2), a6
PC1_dat_20CDAA:
	dc.w	$0002,$0A00,$01FF
PC1_loc_20CDB0:
	dc.w	$0004,$0032,$09D8,$0000,$2DFC,$E000,$002D,$FCE8
	dc.w	$0000,$2DFC,$F000,$002D,$FCF8,$0000,$2DFC,$0000
	dc.w	$002D,$FC08,$0000,$2DFC,$1800,$002D,$FC20,$0500
	dc.w	$25F8,$09D8,$0000,$2DFC,$E000,$002D,$FCE8,$0000
	dc.w	$2DFC,$F000,$002D,$FCF8,$0000,$2DFC,$0000,$002D
	dc.w	$FC08,$0000,$2DFC,$1800,$002D,$FC20,$0500,$29F8
PC1_loc_20CE10:
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$28,$00,$00		; cmpi.b #$28, $0(a1) (raw: not reproducible by assembler)
	beq.s   PC1_loc_20CE22
	jmp     DeleteObject.l
PC1_loc_20CE22:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PC1_dat_20CE4E(pc, d0.w), d0
	jsr     PC1_dat_20CE4E(pc, d0.w)
	movea.w $3e(a0), a1
	move.w  $8(a1), oX(a0)
	move.w  $c(a1), oY(a0)
	move.w  $3c(a0), d0
	add.w   d0, oY(a0)
	jmp     DrawObject.l
PC1_sub_20CD3A:
	ori.b   #$4, $1(a6)
	move.w  #$36a, $2(a6)
	move.w  a0, $3e(a6)
	move.b  #$3, $18(a6)
	move.l  #$20cf1a, $4(a6)
	move.b  #$20, $17(a6)
	move.b  #$20, $19(a6)
	move.b  #$1c, $16(a6)
	rts     
PC1_loc_20CD6C:
	addq.w  #$1, oY(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   PC1_loc_20CD82
	add.w   d1, oY(a0)
	addq.b  #$2, oRoutine(a0)
PC1_loc_20CD82:
	rts     
PC1_loc_20CD84:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	jsr     ObjGetFloorDist.l
	add.w   d1, oY(a0)
	addi.w  #$ffff, $2a(a0)
	bne.s   PC1_loc_20CDA8
	neg.l   $2c(a0)
	move.w  #$80, $2a(a0)
PC1_loc_20CDA8:
	rts     
PC1_dat_20CE4E:
	dc.w	PC1_loc_20CE60-PC1_dat_20CE4E
	dc.w	PC1_loc_20CE78-PC1_dat_20CE4E
	dc.w	PC1_loc_20CE8E-PC1_dat_20CE4E
	dc.w	PC1_loc_20CE9E-PC1_dat_20CE4E
	dc.w	PC1_loc_20CEAE-PC1_dat_20CE4E
	dc.w	PC1_loc_20CEBE-PC1_dat_20CE4E
	dc.w	PC1_loc_20CECE-PC1_dat_20CE4E
	dc.w	PC1_loc_20CEDE-PC1_dat_20CE4E
	dc.w	PC1_loc_20CEF4-PC1_dat_20CE4E
PC1_loc_20CE60:
	tst.b   oSubtype(a0)
	bpl.s   PC1_loc_20CE6E
	move.b  #$a, oRoutine(a0)
	bra.s   PC1_loc_20CEBE
PC1_loc_20CE6E:
	move.b  #$2, oRoutine(a0)
	bra.w   PC1_loc_20CE78
PC1_loc_20CE78:
	move.b  #$6, oMapFrame(a0)
	move.w  #$5, $2a(a0)
	move.w  #$0, oColType(a0)
	addq.b  #$2, oRoutine(a0)
PC1_loc_20CE8E:
	addi.w  #$ffff, $2a(a0)
	bne.s   PC1_loc_20CE9C
	addq.b  #$2, oRoutine(a0)
	bra.s   PC1_loc_20CE9E
PC1_loc_20CE9C:
	rts     
PC1_loc_20CE9E:
	move.b  #$7, oMapFrame(a0)
	move.w  #$49, $2a(a0)
	addq.b  #$2, oRoutine(a0)
PC1_loc_20CEAE:
	addi.w  #$ffff, $2a(a0)
	bne.s   PC1_loc_20CEBC
	addq.b  #$2, oRoutine(a0)
	bra.s   PC1_loc_20CEBE
PC1_loc_20CEBC:
	rts     
PC1_loc_20CEBE:
	move.b  #$6, oMapFrame(a0)
	move.w  #$5, $2a(a0)
	addq.b  #$2, oRoutine(a0)
PC1_loc_20CECE:
	addi.w  #$ffff, $2a(a0)
	bne.s   PC1_loc_20CEDC
	addq.b  #$2, oRoutine(a0)
	bra.s   PC1_loc_20CEDE
PC1_loc_20CEDC:
	rts     
PC1_loc_20CEDE:
	move.w  #$ff, oAnim(a0)
	move.w  #$49, $2a(a0)
	move.w  #$a800, oColType(a0)
	addq.b  #$2, oRoutine(a0)
PC1_loc_20CEF4:
	addi.w  #$ffff, $2a(a0)
	bne.s   PC1_loc_20CF06
	addi.b  #$f2, oRoutine(a0)
	bra.w   PC1_loc_20CE78
PC1_loc_20CF06:
	lea     PC1_dat_20CF10(pc), a1
	jmp     AnimateObject.l
PC1_dat_20CF10:
	dc.w	$0002,$0200,$0102,$0304,$05FF
PC1_loc_20CF1A:
	dc.w	$0010,$001B,$0026,$002C,$0032,$0038,$0043,$004E
	dc.w	$02FC,$0C00,$00E0,$FC0C,$0800,$0002,$FC08,$0004
	dc.w	$E8FC,$0800,$0700,$01FC,$0C00,$0AF0,$01FC,$0000
	dc.w	$0EFC,$01FC,$0C08,$0AF0,$02FC,$0800,$04E8,$FC08
	dc.w	$0007,$0002,$FC04,$000F,$F804,$0D00,$11F0,$01FC
	dc.w	$0B00,$19F4
