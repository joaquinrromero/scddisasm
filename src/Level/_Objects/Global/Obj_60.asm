; Object $60 - Obj10_208814 (from R33C, old ID $10)
P60_Obj10_208814:
	dc.w	$7000,$1028,$0024,$323B,$0006,$4EFB,$1002,$002A
	dc.w	$01DE,$0216,$026E,$027C,$1000,$1800,$2000,$0010
	dc.w	$0018,$0020,$1010,$1818,$2020,$F010,$E818,$E020
	dc.w	$1008,$1810,$F008,$E810,$45F9,$00FF,$1200,$7000
	dc.w	$1028,$0023,$3200,$D241,$D041,$7200,$1239,$00FF
	dc.w	$152E,$0881,$0007,$6718,$1438,$F784,$4882,$4442
	dc.w	$D242,$6A04,$7200,$6008,$0C41,$0003,$6502,$7202
	dc.w	$D041,$45F2,$0002,$1812,$1228,$0028,$7000,$1001
	dc.w	$0241,$0007,$0C41,$0007,$6602,$7206,$4841,$323C
	dc.w	$0001,$E808,$D040,$43F9,$0020,$882C,$1A31,$0000
	dc.w	$4885,$1C31,$0001,$4886,$2248,$3428,$0008,$3628
	dc.w	$000C,$47EA,$0001,$7000,$1039,$00FF,$152E,$0880
	dc.w	$0007,$6718,$1438,$F784,$4882,$4442,$D042,$6A04
	dc.w	$7000,$6008,$0C40,$0003,$6502,$7002,$1823,$E22C
	dc.w	$6500,$00C8,$51C8,$FFF6,$0892,$0007,$6044
P60_loc_208902:
	swap    d1
	lea     $1(a2), a3
	moveq   #$0, d0
	move.b  timeZone.l, d0
	bclr.l  #$7, d0
	beq.s   P60_loc_20892E
	move.b  timeWarpDir.w, d2
	ext.w   d2
	neg.w   d2
	add.w   d2, d0
	bpl.s   P60_loc_208926
	moveq   #$0, d0
	bra.s   P60_loc_20892E
P60_loc_208926:
	cmpi.w  #$3, d0
	bcs.s   P60_loc_20892E
	moveq   #$2, d0
P60_loc_20892E:
	move.b  -(a3), d4
	lsr.b   d1, d4
	bcs.w   P60_loc_2089BE
	dbra    d0, P60_loc_20892E
	bclr.b  #$7, (a2)
	bsr.w   FindNextObjSlot
	bne.w   P60_loc_2089CA
	dc.b	$13,$7C,$00,$10,$00,$00		; move.b #$10, $0(a1) (raw: not reproducible by assembler)
	move.b  #$2, $24(a1)
	move.w  d2, $8(a1)
	move.w  oX(a0), $32(a1)
	move.w  d3, $c(a1)
	move.l  #$208c90, $4(a1)
	move.w  #$a7ae, $2(a1)
	move.b  #$2, $18(a1)
	cmpi.b  #$6, zoneAct.l
	bne.s   P60_loc_20899C
	move.b  #$0, $18(a1)
	move.b  oLayer(a0), $29(a1)
	tst.b   $29(a1)
	beq.s   P60_loc_20899C
	andi.b  #$7f, $2(a1)
	move.b  #$2, $18(a1)
P60_loc_20899C:
	move.b  #$4, $1(a1)
	move.b  #$47, $20(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	move.b  oSavedFlagsID(a0), $23(a1)
	move.b  d1, $34(a1)
P60_loc_2089BE:
	addq.w  #$1, d1
	add.w   d5, d2
	add.w   d6, d3
	swap    d1
	dbra    d1, P60_loc_208902
P60_loc_2089CA:
	moveq   #$0, d0
	move.b  timeZone.l, d0
	bclr.l  #$7, d0
	beq.s   P60_loc_2089F0
	move.b  timeWarpDir.w, d2
	ext.w   d2
	neg.w   d2
	add.w   d2, d0
	bpl.s   P60_loc_2089E8
	moveq   #$0, d0
	bra.s   P60_loc_2089F0
P60_loc_2089E8:
	cmpi.w  #$3, d0
	bcs.s   P60_loc_2089F0
	moveq   #$2, d0
P60_loc_2089F0:
	lea     $1(a2), a3
P60_loc_2089F4:
	btst.b  #$0, -(a3)
	bne.w   DeleteObject
	dbra    d0, P60_loc_2089F4
	tst.b   oSprFlags(a0)
	bmi.s   P60_loc_208A24
	move.w  $32(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.w   P60_loc_208A9E
P60_loc_208A24:
	tst.w   timeStopTimer.l
	bne.s   P60_loc_208A34
	move.b  ringAnimFrame.l, oMapFrame(a0)
P60_loc_208A34:
	bra.w   DrawObject
	addq.b  #$2, oRoutine(a0)
	move.b  #$0, oColType(a0)
	move.b  #$1, oPriority(a0)
	bsr.w   CollectRing
	lea     savedObjFlags.l, a2
	moveq   #$0, d0
	move.b  oSavedFlagsID(a0), d0
	move.w  d0, d1
	add.w   d1, d1
	add.w   d1, d0
	moveq   #$0, d1
	move.b  timeZone.l, d1
	bclr.l  #$7, d1
	beq.s   P60_loc_208A84
	move.b  timeWarpDir.w, d2
	ext.w   d2
	neg.w   d2
	add.w   d2, d1
	bpl.s   P60_loc_208A7C
	moveq   #$0, d1
	bra.s   P60_loc_208A84
P60_loc_208A7C:
	cmpi.w  #$3, d1
	bcs.s   P60_loc_208A84
	moveq   #$2, d1
P60_loc_208A84:
	add.w   d1, d0
	move.b  $34(a0), d1
	subq.b  #$1, d1
	bset.b  d1, $2(a2, d0.w)
	lea     Ani_Ring.l, a1
	bsr.w   AnimateObject
	bra.w   DrawObject
P60_loc_208A9E:
	bra.w   DeleteObject
