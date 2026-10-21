; Object $BA - Obj23_20D48A (from R82A, old ID $23)
PBA_Obj23_20D48A:
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	move.w  PBA_dat_20D498(pc, d0.w), d0
	jmp     PBA_dat_20D498(pc, d0.w)
PBA_dat_20D498:
	dc.w	PBA_loc_20D4A2-PBA_dat_20D498
	dc.w	PBA_loc_20D6BA-PBA_dat_20D498
	dc.w	PBA_loc_20D9D4-PBA_dat_20D498
	dc.w	PBA_loc_20DA86-PBA_dat_20D498
	dc.w	PBA_loc_20DB48-PBA_dat_20D498
PBA_loc_20D4A2:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PBA_dat_20D4C4(pc, d0.w), d0
	jsr     PBA_dat_20D4C4(pc, d0.w)
	cmpi.b  #$2, oLayer(a0)
	beq.s   PBA_loc_20D4C2
	move.w  $2c(a0), d0
	jmp     CheckObjDespawn2.l
PBA_loc_20D4C2:
	rts     
PBA_dat_20D4C4:
	dc.w	PBA_loc_20D4D2-PBA_dat_20D4C4
	dc.w	PBA_loc_20D510-PBA_dat_20D4C4
	dc.w	PBA_loc_20D512-PBA_dat_20D4C4
	dc.w	PBA_loc_20D51C-PBA_dat_20D4C4
	dc.w	PBA_loc_20D57A-PBA_dat_20D4C4
	dc.w	PBA_loc_20D57C-PBA_dat_20D4C4
	dc.w	PBA_loc_20D586-PBA_dat_20D4C4
PBA_loc_20D4D2:
	move.w  oX(a0), $2c(a0)
	jsr     FindObjSlot.l
	beq.s   PBA_loc_20D4E6
	jmp     DespawnObject.l
PBA_loc_20D4E6:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$2, $28(a1)
	move.b  oLayer(a0), $29(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.w  a0, $3e(a1)
	move.w  a1, $3c(a0)
	addq.b  #$2, oRoutine(a0)
PBA_loc_20D510:
	rts     
PBA_loc_20D512:
	move.w  #$1e, $2a(a0)
	addq.b  #$2, oRoutine(a0)
PBA_loc_20D51C:
	addi.w  #$ffff, $2a(a0)
	bne.s   PBA_loc_20D578
	movea.w $3c(a0), a1
	addq.b  #$2, $24(a1)
	jsr     FindObjSlot.l
	beq.s   PBA_loc_20D53A
	jmp     DeleteObject.l
PBA_loc_20D53A:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$4, $28(a1)
	move.w  a0, $3e(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), d0
	addi.w  #$ffe1, d0
	move.w  d0, $c(a1)
	movea.w $3c(a0), a2
	btst.b  #$0, $1(a2)
	beq.s   PBA_loc_20D574
	bchg.b  #$0, $1(a1)
	bchg.b  #$0, $22(a1)
PBA_loc_20D574:
	addq.b  #$2, oRoutine(a0)
PBA_loc_20D578:
	rts     
PBA_loc_20D57A:
	rts     
PBA_loc_20D57C:
	move.w  #$0, $2a(a0)
	addq.b  #$2, oRoutine(a0)
PBA_loc_20D586:
	addq.w  #$1, $2a(a0)
	cmpi.w  #$20, $2a(a0)
	bne.s   PBA_loc_20D59A
	movea.w $3c(a0), a1
	addq.b  #$2, $24(a1)
PBA_loc_20D59A:
	cmpi.w  #$1e, $2a(a0)
	bne.s   PBA_loc_20D5C8
	jsr     FindObjSlot.l
	beq.s   PBA_loc_20D5B0
	jmp     DeleteObject.l
PBA_loc_20D5B0:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$6, $28(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
PBA_loc_20D5C8:
	cmpi.w  #$1f, $2a(a0)
	bne.w   PBA_loc_20D66C
	jsr     PBA_sub_20D67C.l
	move.l  #$ffff0000, $2a(a1)
	move.l  #$fffbe000, $2e(a1)
	jsr     PBA_sub_20D67C.l
	move.l  #$fffe0000, $2a(a1)
	move.l  #$fffae000, $2e(a1)
	jsr     PBA_sub_20D67C.l
	move.l  #$fffd0000, $2a(a1)
	move.l  #$fff9e000, $2e(a1)
	jsr     PBA_sub_20D67C.l
	move.l  #$10000, $2a(a1)
	move.l  #$fffbe000, $2e(a1)
	jsr     PBA_sub_20D67C.l
	move.l  #$20000, $2a(a1)
	move.l  #$fffae000, $2e(a1)
	jsr     PBA_sub_20D67C.l
	move.l  #$30000, $2a(a1)
	move.l  #$fff9e000, $2e(a1)
	jsr     PBA_sub_20D67C.l
	move.l  #$0, $2a(a1)
	move.l  #$fffce000, $2e(a1)
PBA_loc_20D66C:
	cmpi.w  #$28, $2a(a0)
	bne.s   PBA_loc_20D67A
	jmp     DeleteObject.l
PBA_loc_20D67A:
	rts     
PBA_sub_20D67C:
	jsr     FindObjSlot.l
	beq.s   PBA_loc_20D68A
	jmp     DespawnObject.l
PBA_loc_20D68A:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$8, $28(a1)
	move.b  oLayer(a0), $29(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.l  #$0, $32(a1)
	move.l  #$2000, $36(a1)
	rts     
PBA_loc_20D6BA:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PBA_dat_20D6EC(pc, d0.w), d0
	jsr     PBA_dat_20D6EC(pc, d0.w)
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$23,$00,$00		; cmpi.b #$23, $0(a1) (raw: not reproducible by assembler)
	bne.s   PBA_loc_20D6E6
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	jmp     DrawObject.l
PBA_loc_20D6E6:
	jmp     DeleteObject.l
PBA_dat_20D6EC:
	dc.w	PBA_loc_20D706-PBA_dat_20D6EC
	dc.w	PBA_loc_20D736-PBA_dat_20D6EC
	dc.w	PBA_loc_20D774-PBA_dat_20D6EC
	dc.w	PBA_loc_20D78E-PBA_dat_20D6EC
	dc.w	PBA_loc_20D7AC-PBA_dat_20D6EC
	dc.w	PBA_loc_20D7F6-PBA_dat_20D6EC
	dc.w	PBA_loc_20D822-PBA_dat_20D6EC
	dc.w	PBA_loc_20D840-PBA_dat_20D6EC
	dc.w	PBA_loc_20D8E0-PBA_dat_20D6EC
	dc.w	PBA_loc_20D8EC-PBA_dat_20D6EC
	dc.w	PBA_loc_20D908-PBA_dat_20D6EC
	dc.w	PBA_loc_20D912-PBA_dat_20D6EC
	dc.w	PBA_loc_20D914-PBA_dat_20D6EC
PBA_loc_20D706:
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.w  #$8340, oTile(a0)
	move.l  #$20d91a, oMap(a0)
	move.b  #$14, oWidth(a0)
	move.b  #$1a, oYRadius(a0)
	move.b  #$a6, $3d(a0)
	addq.b  #$2, oRoutine(a0)
PBA_loc_20D736:
	addi.l  #$10000, oY(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   PBA_loc_20D772
	add.w   d1, oY(a0)
	cmpi.b  #$2, oLayer(a0)
	beq.s   PBA_loc_20D762
	move.b  #$c, oRoutine(a0)
	move.b  #$a6, oColType(a0)
	rts     
PBA_loc_20D762:
	addq.b  #$2, oRoutine(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
PBA_loc_20D772:
	rts     
PBA_loc_20D774:
	lea     objects.w, a6
	bsr.w   PBA_sub_20D8B8
	bcc.s   PBA_loc_20D788
	move.w  $8(a6), d0
	sub.w   oX(a0), d0
	bpl.s   PBA_loc_20D78A
PBA_loc_20D788:
	rts     
PBA_loc_20D78A:
	addq.b  #$2, oRoutine(a0)
PBA_loc_20D78E:
	addq.b  #$2, oRoutine(a0)
	move.l  #$28000, $2c(a0)
	move.w  #$e6, $2a(a0)
	move.w  #$12, $30(a0)
	move.b  #$3, oMapFrame(a0)
PBA_loc_20D7AC:
	moveq   #$0, d0
	tst.b   layer.l
	bne.s   PBA_loc_20D7BA
	move.b  $3d(a0), d0
PBA_loc_20D7BA:
	move.b  d0, oColType(a0)
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	subq.w  #$1, $30(a0)
	bpl.s   PBA_loc_20D7E8
	addq.b  #$1, oMapFrame(a0)
	andi.b  #$3, oMapFrame(a0)
	lea     PBA_dat_20D8B0(pc), a1
	moveq   #$0, d0
	move.b  oMapFrame(a0), d0
	add.w   d0, d0
	move.w  (a1, d0.w), $30(a0)
PBA_loc_20D7E8:
	addi.w  #$ffff, $2a(a0)
	bpl.s   PBA_loc_20D7F4
	addq.b  #$2, oRoutine(a0)
PBA_loc_20D7F4:
	rts     
PBA_loc_20D7F6:
	moveq   #$0, d0
	tst.b   layer.l
	bne.s   PBA_loc_20D804
	move.b  $3d(a0), d0
PBA_loc_20D804:
	move.b  d0, oColType(a0)
	tst.b   layer.l
	bne.s   PBA_loc_20D820
	lea     objects.w, a6
	bsr.w   PBA_sub_20D8B8
	bcc.s   PBA_loc_20D820
	move.b  #$10, oRoutine(a0)
PBA_loc_20D820:
	rts     
PBA_loc_20D822:
	addq.b  #$2, oRoutine(a0)
	move.l  #$ffff6000, $2c(a0)
	move.w  #$0, $2a(a0)
	move.w  #$0, $30(a0)
	move.b  #$3, oMapFrame(a0)
PBA_loc_20D840:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	jsr     ObjGetFloorDist.l
	add.w   d1, oY(a0)
	addi.w  #$ffff, $2a(a0)
	bpl.s   PBA_loc_20D87C
	neg.l   $2c(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	move.w  #$cc, d0
	tst.b   oLayer(a0)
	beq.s   PBA_loc_20D878
	move.w  #$19, d0
PBA_loc_20D878:
	move.w  d0, $2a(a0)
PBA_loc_20D87C:
	addi.w  #$ffff, $30(a0)
	bpl.s   PBA_loc_20D8A0
	addq.b  #$1, oMapFrame(a0)
	andi.b  #$3, oMapFrame(a0)
	lea     PBA_dat_20D8B0(pc), a1
	moveq   #$0, d0
	move.b  oMapFrame(a0), d0
	add.w   d0, d0
	move.w  (a1, d0.w), $30(a0)
PBA_loc_20D8A0:
	tst.b   oMapFrame(a0)
	bne.s   PBA_loc_20D8AE
	lea     objects.w, a6
	bsr.s   PBA_sub_20D8B8
	bcs.s   PBA_loc_20D8DC
PBA_loc_20D8AE:
	rts     
PBA_sub_20D8B8:
	move.w  $c(a6), d0
	sub.w   oY(a0), d0
	subi.w  #$ff60, d0
	subi.w  #$f0, d0
	bcc.s   PBA_loc_20D8DA
	move.w  $8(a6), d0
	sub.w   oX(a0), d0
	subi.w  #$ffa0, d0
	subi.w  #$c0, d0
PBA_loc_20D8DA:
	rts     
PBA_loc_20D8DC:
	addq.b  #$2, oRoutine(a0)
PBA_loc_20D8E0:
	addq.b  #$2, oRoutine(a0)
	movea.w $3e(a0), a1
	addq.b  #$2, $24(a1)
PBA_loc_20D8EC:
	cmpi.b  #$2, oLayer(a0)
	bne.s   PBA_loc_20D906
	moveq   #$0, d0
	tst.b   layer.l
	bne.s   PBA_loc_20D902
	move.b  $3d(a0), d0
PBA_loc_20D902:
	move.b  d0, oColType(a0)
PBA_loc_20D906:
	rts     
PBA_loc_20D908:
	move.b  #$4, oMapFrame(a0)
	addq.b  #$2, oRoutine(a0)
PBA_loc_20D912:
	bra.s   PBA_loc_20D8EC
PBA_loc_20D914:
	jmp     DeleteObject.l
PBA_loc_20D91A:
	dc.w	$000A,$002E,$0052,$0076,$009A,$07D4,$0200,$55FC
	dc.w	$030E,$0000,$F413,$0400,$0CE4,$EC0F,$0034,$ECEC
	dc.w	$0300,$440C,$0C0C,$0048,$EC0C,$0000,$4C0C,$07D2
	dc.w	$0200,$55FC,$030E,$000E,$FC0B,$0500,$1AEC,$EA0F
	dc.w	$0034,$ECEA,$0300,$440C,$0A0C,$0048,$EC0A,$0000
	dc.w	$4C0C,$07D4,$0200,$55FC,$030A,$001E,$FC13,$0400
	dc.w	$27EC,$EC0F,$0034,$ECEC,$0300,$440C,$0C0C,$0048
	dc.w	$EC0C,$0000,$4C0C,$07D2,$0200,$55FC,$030A,$0029
	dc.w	$FC0B,$0100,$32F4,$EA0F,$0034,$ECEA,$0300,$440C
	dc.w	$0A0C,$0048,$EC0A,$0000,$4C0C,$0603,$0E00,$00F4
	dc.w	$1304,$000C,$E4EC,$0F00,$34EC,$EC03,$0044,$0C0C
	dc.w	$0C00,$48EC,$0C00,$004C,$0C00
PBA_loc_20D9D4:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PBA_dat_20D9E8(pc, d0.w), d0
	jsr     PBA_dat_20D9E8(pc, d0.w)
	jmp     DrawObject.l
PBA_dat_20D8B0:
	dc.w	$0019,$000F,$0019,$0012
PBA_dat_20D9E8:
	dc.w	PBA_loc_20D9F0-PBA_dat_20D9E8
	dc.w	PBA_loc_20DA20-PBA_dat_20D9E8
	dc.w	PBA_loc_20DA3C-PBA_dat_20D9E8
	dc.w	PBA_loc_20DA5A-PBA_dat_20D9E8
PBA_loc_20D9F0:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$2, oPriority(a0)
	move.w  #$8340, oTile(a0)
	move.l  #$20da76, oMap(a0)
	move.b  #$4, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.w  #$3c, $2a(a0)
PBA_loc_20DA20:
	addi.w  #$ffff, $2a(a0)
	bne.s   PBA_loc_20DA32
	move.w  #$4c, $2a(a0)
	addq.b  #$2, oRoutine(a0)
PBA_loc_20DA32:
	lea     PBA_dat_20DA70(pc), a1
	jmp     AnimateObject.l
PBA_loc_20DA3C:
	addi.l  #$5000, oY(a0)
	addi.w  #$ffff, $2a(a0)
	bpl.s   PBA_loc_20DA50
	addq.b  #$2, oRoutine(a0)
PBA_loc_20DA50:
	lea     PBA_dat_20DA70(pc), a1
	jmp     AnimateObject.l
PBA_loc_20DA5A:
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$23,$00,$00		; cmpi.b #$23, $0(a1) (raw: not reproducible by assembler)
	bne.s   PBA_loc_20DA6A
	addq.b  #$2, $24(a1)
PBA_loc_20DA6A:
	jmp     DeleteObject.l
PBA_dat_20DA70:
	dc.w	$0002,$0200,$01FF
PBA_loc_20DA76:
	dc.w	$0004,$000A,$01F4,$0200,$58FC,$01F4,$0200,$5BFC
PBA_loc_20DA86:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PBA_dat_20DA9A(pc, d0.w), d0
	jsr     PBA_dat_20DA9A(pc, d0.w)
	jmp     DrawObject.l
PBA_dat_20DA9A:
	dc.w	PBA_loc_20DA9E-PBA_dat_20DA9A
	dc.w	PBA_loc_20DAC2-PBA_dat_20DA9A
PBA_loc_20DA9E:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.w  #$8680, oTile(a0)
	move.l  #$20dae4, oMap(a0)
	move.w  #$28, $2a(a0)
PBA_loc_20DAC2:
	addi.w  #$ffff, $2a(a0)
	bne.s   PBA_loc_20DAD0
	jmp     DeleteObject.l
PBA_loc_20DAD0:
	lea     PBA_dat_20DADA(pc), a1
	jmp     AnimateObject.l
PBA_dat_20DADA:
	dc.w	$0002,$0300,$0102,$0304,$FF00
PBA_loc_20DAE4:
	dc.w	$000A,$0015,$0025,$003A,$004F,$02F8,$0500,$00F0
	dc.w	$F805,$0800,$0003,$F00D,$0004,$F000,$0500,$0CF0
	dc.w	$0005,$080C,$0004,$F005,$0010,$F0F0,$0500,$1400
	dc.w	$0005,$0018,$F000,$0518,$1000,$04E8,$0A00,$1CE8
	dc.w	$E80A,$081C,$0000,$0A10,$1CE8,$000A,$181C,$0004
	dc.w	$E80A,$0025,$E8E8,$0A08,$2500,$000A,$1025,$E800
	dc.w	$0A18,$2500
PBA_loc_20DB48:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PBA_dat_20DB5C(pc, d0.w), d0
	jsr     PBA_dat_20DB5C(pc, d0.w)
	jmp     DrawObject.l
PBA_dat_20DB5C:
	dc.w	PBA_loc_20DB60-PBA_dat_20DB5C
	dc.w	PBA_loc_20DB96-PBA_dat_20DB5C
PBA_loc_20DB60:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.w  #$8340, oTile(a0)
	move.l  #$20dbf8, oMap(a0)
	move.b  #$a7, oColType(a0)
	move.b  #$a7, $3d(a0)
PBA_loc_20DB96:
	cmpi.b  #$2, oLayer(a0)
	bne.s   PBA_loc_20DBB0
	moveq   #$0, d0
	tst.b   layer.l
	bne.s   PBA_loc_20DBAC
	move.b  $3d(a0), d0
PBA_loc_20DBAC:
	move.b  d0, oColType(a0)
PBA_loc_20DBB0:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	move.l  $2e(a0), d0
	add.l   d0, oY(a0)
	move.l  $32(a0), d0
	add.l   d0, $2a(a0)
	move.l  $36(a0), d0
	add.l   d0, $2e(a0)
	lea     objects.w, a1
	move.w  oY(a0), d0
	sub.w   $c(a1), d0
	cmpi.w  #$e0, d0
	blt.s   PBA_loc_20DBE8
	jmp     DeleteObject.l
PBA_loc_20DBE8:
	lea     PBA_dat_20DBF2(pc), a1
	jmp     AnimateObject.l
PBA_dat_20DBF2:
	dc.w	$0002,$0100,$01FF
PBA_loc_20DBF8:
	dc.w	$0004,$000A,$01F8,$0500,$4DF8,$01F8,$0500,$51F8
