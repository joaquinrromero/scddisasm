; Object $99 - Obj2A_20E77C (from R52A, old ID $2A)
Obj2A_20E77C:
	tst.b   oLayer(a0)
	beq.s   P99_loc_20E78A
	bpl.w   P99_loc_20E8D4
	bra.w   P99_loc_20E906
P99_loc_20E78A:
	tst.b   oRoutine(a0)
	bne.w   P99_loc_20E83A
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$8, oXRadius(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$358, oTile(a0)
	move.l  #$20e994, oMap(a0)
	lea     P99_dat_20E9B6(pc), a1
	move.b  oSubtype(a0), d0
	andi.w  #$fffe, d0
	add.w   d0, d0
	adda.w  d0, a1
	move.w  (a1)+, $36(a0)
	move.w  (a1), $30(a0)
	move.w  #$100, $34(a0)
	btst.b  #$0, oSubtype(a0)
	beq.s   P99_loc_20E7F0
	neg.l   $2e(a0)
	neg.l   $32(a0)
P99_loc_20E7F0:
	lea     $38(a0), a6
	move.w  $36(a0), d6
P99_loc_20E7F8:
	jsr     FindNextObjSlot.l
	bne.w   P99_loc_20E94E
	move.w  a1, d0
	lsr.w   #$6, d0
	move.b  d0, (a6)+
	move.b  #$1, $29(a1)
	move.w  a0, $2a(a1)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  oSprFlags(a0), $1(a1)
	move.l  oMap(a0), $4(a1)
	dbra    d6, P99_loc_20E7F8
	move.b  #$ff, $29(a1)
P99_loc_20E83A:
	move.l  $2a(a0), d6
	add.l   $32(a0), d6
	move.l  $2e(a0), d5
	beq.s   P99_loc_20E864
	move.l  d6, d1
	move.l  d5, d0
	bpl.s   P99_loc_20E852
	neg.l   d1
	neg.l   d0
P99_loc_20E852:
	tst.l   d1
	bge.s   P99_loc_20E85A
	moveq   #$0, d6
	bra.s   P99_loc_20E860
P99_loc_20E85A:
	cmp.l   d0, d1
	ble.s   P99_loc_20E864
	move.l  d5, d6
P99_loc_20E860:
	neg.l   $32(a0)
P99_loc_20E864:
	move.l  d6, $2a(a0)
	lea     $38(a0), a6
	move.w  $36(a0), d6
	subq.w  #$1, d6
	move.l  oX(a0), d5
	move.l  oY(a0), d4
	moveq   #$0, d1
	moveq   #$0, d0
	move.b  $2c(a0), d0
	jsr     CalcSine.l
	swap    d1
	swap    d0
	asr.l   #$4, d1
	asr.l   #$4, d0
P99_loc_20E890:
	moveq   #$ff, d2
	move.b  (a6)+, d2
	lsl.w   #$6, d2
	movea.w d2, a1
	add.l   d1, d5
	add.l   d0, d4
	move.l  d5, $8(a1)
	move.l  d4, $c(a1)
	dbra    d6, P99_loc_20E890
	moveq   #$ff, d2
	move.b  (a6), d2
	lsl.w   #$6, d2
	movea.w d2, a1
	add.l   d1, d5
	add.l   d0, d4
	move.l  $8(a1), d3
	move.l  d5, $8(a1)
	move.l  d4, $c(a1)
	sub.l   d3, d5
	asr.l   #$8, d5
	move.w  d5, $10(a1)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P99_loc_20E8D4:
	tst.b   oRoutine(a0)
	bne.w   P99_loc_20E93C
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, oMapFrame(a0)
	move.b  #$8, oXRadius(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$358, oTile(a0)
	rts     
P99_loc_20E906:
	tst.b   oRoutine(a0)
	bne.s   P99_loc_20E934
	addq.b  #$2, oRoutine(a0)
	move.b  #$2, oMapFrame(a0)
	move.b  #$20, oXRadius(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.b  #$2, oPriority(a0)
	move.w  #$431c, oTile(a0)
P99_loc_20E934:
	lea     objects.w, a1
	bsr.w   P99_sub_20E954
P99_loc_20E93C:
	movea.w $2a(a0), a1
	dc.b	$0C,$29,$00,$2A,$00,$00		; cmpi.b #$2a, $0(a1) (raw: not reproducible by assembler)
	bne.s   P99_loc_20E94E
	jmp     DrawObject.l
P99_loc_20E94E:
	jmp     DeleteObject.l
P99_dat_20E9B6:
	dc.w	$0005,$0000,$0005,$8000,$0007,$4000
P99_sub_20E954:
	move.w  oXVel(a0), -(a7)
	move.w  #$0, oXVel(a0)
	move.b  #$a, oYRadius(a0)
	jsr     TopSolidObject.l
	sne.b   d0
	move.w  (a7)+, oXVel(a0)
	move.b  #$8, oYRadius(a0)
	tst.b   d0
	beq.s   P99_loc_20E992
	jsr     TopSolidObject.l
	beq.s   P99_loc_20E992
	moveq   #$2, d0
	tst.b   $ff158f.l
	beq.s   P99_loc_20E98E
	neg.w   d0
P99_loc_20E98E:
	add.w   d0, $8(a1)
P99_loc_20E992:
	rts     
P99_loc_20E994:
	dc.w	$0006,$000C,$0012,$01F8,$0500,$00F8,$01F8,$0500
	dc.w	$04F8,$03F8,$0500,$00E0,$F80D,$0004,$F0F8,$0500
	dc.w	$0C10
