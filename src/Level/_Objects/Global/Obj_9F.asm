; Object $9F - Obj23_20DC50 (from R71A, old ID $23)
P9F_Obj23_20DC50:
	cmpi.b  #$ff, oLayer(a0)
	beq.w   P9F_loc_20DDD8
	cmpi.b  #$fe, oLayer(a0)
	beq.w   P9F_loc_20E172
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P9F_dat_20DC72(pc, d0.w), d0
	jmp     P9F_dat_20DC72(pc, d0.w)
P9F_dat_20DC72:
	dc.w	P9F_loc_20DC7A-P9F_dat_20DC72
	dc.w	P9F_loc_20DCD8-P9F_dat_20DC72
	dc.w	P9F_loc_20DCFC-P9F_dat_20DC72
	dc.w	P9F_loc_20DD82-P9F_dat_20DC72
P9F_loc_20DC7A:
	addq.b  #$2, oRoutine(a0)
	moveq   #$0, d0
	move.b  oSavedFlagsID(a0), d0
	lea     savedObjFlags.l, a1
	move.w  d0, d1
	add.w   d1, d1
	add.w   d1, d0
	moveq   #$0, d1
	move.b  timeZone.l, d1
	add.w   d1, d0
	lea     $2(a1, d0.w), a1
	move.l  a1, $2a(a0)
	lea     P9F_loc_20E33A.l, a1
	move.b  oSubtype(a0), d0
	andi.w  #$c, d0
	adda.w  d0, a1
	move.l  a1, $2e(a0)
	btst.b  #$0, oSubtype(a0)
	sne.b   d0
	move.b  d0, oSubtype(a0)
	move.w  #$845d, d0
	cmpi.b  #$2, act.l
	bne.s   P9F_loc_20DCD4
	move.w  #$8320, d0
P9F_loc_20DCD4:
	move.w  d0, oTile(a0)
P9F_loc_20DCD8:
	move.w  #$ff10, d1
	move.w  #$1e0, d2
	move.w  #$ff10, d3
	move.w  #$1e0, d4
	lea     objects.w, a1
	bsr.w   P9F_sub_20E202
	bcc.s   P9F_loc_20DCF6
	addq.b  #$2, oRoutine(a0)
P9F_loc_20DCF6:
	jmp     CheckObjDespawn.l
P9F_loc_20DCFC:
	addq.b  #$2, oRoutine(a0)
	movea.l $2a(a0), a6
	btst.b  #$0, (a6)
	bne.s   P9F_loc_20DD2A
	jsr     FindNextObjSlot.l
	bne.w   P9F_loc_20E1F6
	move.w  a1, $32(a0)
	bsr.s   P9F_sub_20DD52
	movea.l $2e(a0), a2
	move.w  (a2)+, d0
	move.w  (a2), d1
	add.w   d0, $8(a1)
	add.w   d1, $c(a1)
P9F_loc_20DD2A:
	btst.b  #$1, (a6)
	bne.s   P9F_loc_20DD50
	jsr     FindNextObjSlot.l
	bne.w   P9F_loc_20E1F6
	move.w  a1, $34(a0)
	bsr.s   P9F_sub_20DD52
	movea.l $2e(a0), a2
	move.w  (a2)+, d0
	move.w  (a2), d1
	sub.w   d0, $8(a1)
	sub.w   d1, $c(a1)
P9F_loc_20DD50:
	rts     
P9F_sub_20E202:
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	sub.w   d1, d0
	sub.w   d2, d0
	bcc.s   P9F_loc_20E21C
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	sub.w   d3, d0
	sub.w   d4, d0
P9F_loc_20E21C:
	rts     
P9F_sub_20DD52:
	move.w  a0, $2a(a1)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  oSubtype(a0), $28(a1)
	move.b  #$ff, $29(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.w  oTile(a0), $2(a1)
	move.b  oSavedFlagsID(a0), $36(a1)
	rts     
P9F_loc_20DD82:
	movea.l $2a(a0), a6
	btst.b  #$0, (a6)
	bne.s   P9F_loc_20DDA6
	move.w  $32(a0), d6
	beq.s   P9F_loc_20DDA6
	movea.w d6, a1
	dc.b	$1C,$29,$00,$00		; move.b $0(a1), d6 (raw: not reproducible by assembler)
	cmp.b   oID(a0), d6
	beq.s   P9F_loc_20DDA6
	bset.b  #$0, (a6)
	clr.w   $32(a0)
P9F_loc_20DDA6:
	btst.b  #$1, (a6)
	bne.s   P9F_loc_20DDC6
	move.w  $34(a0), d6
	beq.s   P9F_loc_20DDC6
	movea.w d6, a1
	dc.b	$1C,$29,$00,$00		; move.b $0(a1), d6 (raw: not reproducible by assembler)
	cmp.b   oID(a0), d6
	beq.s   P9F_loc_20DDC6
	bset.b  #$1, (a6)
	clr.w   $34(a0)
P9F_loc_20DDC6:
	cmpi.b  #$83, (a6)
	beq.w   P9F_loc_20E1FC
	tst.l   $32(a0)
	beq.w   P9F_loc_20E1F6
	rts     
P9F_loc_20DDD8:
	movea.w $2a(a0), a1
	dc.b	$0C,$29,$00,$23,$00,$00		; cmpi.b #$23, $0(a1) (raw: not reproducible by assembler)
	bne.w   P9F_loc_20E1FC
	move.b  $23(a1), d0
	cmp.b   $36(a0), d0
	bne.w   P9F_loc_20E1FC
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P9F_dat_20DE06(pc, d0.w), d0
	jmp     P9F_dat_20DE06(pc, d0.w)
P9F_dat_20DE06:
	dc.w	P9F_loc_20DE1C-P9F_dat_20DE06
	dc.w	P9F_loc_20DE9A-P9F_dat_20DE06
	dc.w	P9F_loc_20DF0A-P9F_dat_20DE06
	dc.w	P9F_loc_20DFFA-P9F_dat_20DE06
	dc.w	P9F_loc_20E03C-P9F_dat_20DE06
	dc.w	P9F_loc_20E04C-P9F_dat_20DE06
	dc.w	P9F_loc_20E07C-P9F_dat_20DE06
	dc.w	P9F_loc_20E0B8-P9F_dat_20DE06
	dc.w	P9F_loc_20E07C-P9F_dat_20DE06
	dc.w	P9F_loc_20E0CE-P9F_dat_20DE06
	dc.w	P9F_loc_20E0DA-P9F_dat_20DE06
P9F_loc_20DE1C:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$14, oXRadius(a0)
	move.b  #$14, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.b  #$32, oColType(a0)
	move.w  oX(a0), $2c(a0)
	tst.b   oSubtype(a0)
	bne.s   P9F_loc_20DE60
	lea     MapSpr_Mosqui1(pc), a1
	lea     Ani_Mosqui1(pc), a2
	move.l  #$ffff0000, d0
	bra.s   P9F_loc_20DE6E
P9F_loc_20DE60:
	lea     MapSpr_Mosqui2(pc), a1
	lea     Ani_Mosqui2(pc), a2
	move.l  #$ffff8000, d0
P9F_loc_20DE6E:
	move.l  a1, oMap(a0)
	move.l  a2, $32(a0)
	move.l  d0, $2e(a0)
	lea     objects.w, a1
	move.w  $8(a1), d0
	cmp.w   oX(a0), d0
	blt.s   P9F_loc_20DE98
	neg.l   $2e(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
P9F_loc_20DE98:
	rts     
P9F_loc_20DE9A:
	move.l  $2e(a0), d0
	add.l   d0, oX(a0)
	move.w  oX(a0), d0
	sub.w   $2c(a0), d0
	bpl.s   P9F_loc_20DEAE
	neg.w   d0
P9F_loc_20DEAE:
	cmpi.w  #$50, d0
	blt.s   P9F_loc_20DECC
	move.l  $2e(a0), d0
	sub.l   d0, oX(a0)
	neg.l   $2e(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
P9F_loc_20DECC:
	move.w  #$ffc8, d1
	move.w  #$70, d2
	move.w  #$ffb0, d3
	move.w  #$a0, d4
	lea     objects.w, a1
	bsr.w   P9F_sub_20E202
	bcc.s   P9F_loc_20DF06
	movea.w $2a(a0), a2
	move.w  $32(a2), d0
	beq.s   P9F_loc_20DEF8
	movea.w d0, a3
	move.b  #$4, $24(a3)
P9F_loc_20DEF8:
	move.w  $34(a2), d0
	beq.s   P9F_loc_20DF06
	movea.w d0, a4
	move.b  #$4, $24(a4)
P9F_loc_20DF06:
	bra.w   P9F_loc_20E086
P9F_loc_20DF0A:
	movea.w $2a(a0), a2
	move.w  $32(a2), d0
	beq.w   P9F_loc_20DFF6
	movea.w d0, a3
	move.w  $34(a2), d0
	beq.w   P9F_loc_20DFF6
	movea.w d0, a4
	sf.b    d6
	move.w  $8(a3), d0
	add.w   $8(a4), d0
	asr.w   #$1, d0
	sub.w   cameraX.w, d0
	cmpi.w  #$98, d0
	blt.w   P9F_loc_20DF7A
	cmpi.w  #$a8, d0
	bgt.w   P9F_loc_20DFA4
	st.b    d6
P9F_loc_20DF44:
	sf.b    d5
	move.w  $c(a3), d0
	add.w   $c(a4), d0
	asr.w   #$1, d0
	sub.w   cameraY.w, d0
	cmpi.w  #$68, d0
	blt.w   P9F_loc_20DFD0
	cmpi.w  #$78, d0
	bgt.w   P9F_loc_20DFE2
	st.b    d5
P9F_loc_20DF66:
	and.b   d6, d5
	beq.s   P9F_loc_20DF76
	move.b  #$6, $24(a3)
	move.b  #$6, $24(a4)
P9F_loc_20DF76:
	bra.w   P9F_loc_20E086
P9F_loc_20DF7A:
	bset.b  #$0, $1(a3)
	bset.b  #$0, $1(a4)
	bset.b  #$0, $22(a3)
	bset.b  #$0, $22(a4)
	move.l  $2e(a0), d0
	bpl.s   P9F_loc_20DF9A
	neg.l   d0
P9F_loc_20DF9A:
	add.l   d0, $8(a3)
	add.l   d0, $8(a4)
	bra.s   P9F_loc_20DF44
P9F_loc_20DFA4:
	bclr.b  #$0, $1(a3)
	bclr.b  #$0, $1(a4)
	bclr.b  #$0, $22(a3)
	bclr.b  #$0, $22(a4)
	move.l  $2e(a0), d0
	bpl.s   P9F_loc_20DFC4
	neg.l   d0
P9F_loc_20DFC4:
	sub.l   d0, $8(a3)
	sub.l   d0, $8(a4)
	bra.w   P9F_loc_20DF44
P9F_loc_20DFD0:
	move.l  $2e(a0), d0
	bpl.s   P9F_loc_20DFD8
	neg.l   d0
P9F_loc_20DFD8:
	add.l   d0, $c(a3)
	add.l   d0, $c(a4)
	bra.s   P9F_loc_20DF66
P9F_loc_20DFE2:
	move.l  $2e(a0), d0
	bpl.s   P9F_loc_20DFEA
	neg.l   d0
P9F_loc_20DFEA:
	sub.l   d0, $c(a3)
	sub.l   d0, $c(a4)
	bra.w   P9F_loc_20DF66
P9F_loc_20DFF6:
	addq.b  #$2, oRoutine(a0)
P9F_loc_20DFFA:
	addq.b  #$2, oRoutine(a0)
	move.b  #$c, oXRadius(a0)
	move.b  #$c, oWidth(a0)
	move.b  #$14, oYRadius(a0)
	move.b  #$33, oColType(a0)
	move.b  #$0, oSprFlags(a0)
	move.w  oX(a0), d0
	move.w  oY(a0), d1
	sub.w   cameraX.w, d0
	sub.w   cameraY.w, d1
	addi.w  #$80, d0
	addi.w  #$80, d1
	swap    d0
	move.w  d1, d0
	move.l  d0, oX(a0)
P9F_loc_20E03C:
	movea.l $32(a0), a1
	jsr     AnimateObject.l
	jmp     DrawObject.l
P9F_loc_20E04C:
	addq.b  #$2, oRoutine(a0)
	move.w  #$1ff, oAnim(a0)
	move.b  #$4, oSprFlags(a0)
	move.w  oX(a0), d0
	move.w  oYScr(a0), d1
	subi.w  #$80, d0
	subi.w  #$80, d1
	add.w   cameraX.w, d0
	add.w   cameraY.w, d1
	move.w  d0, oX(a0)
	move.w  d1, oY(a0)
P9F_loc_20E07C:
	movea.l $32(a0), a1
	jsr     AnimateObject.l
P9F_loc_20E086:
	jsr     DrawObject.l
	move.w  $2a(a0), -(a7)
	jsr     CheckObjDespawn.l
	movea.w (a7)+, a1
	tst.b   (a0)
	beq.s   P9F_loc_20E0AA
	rts     
P9F_loc_20E09E:
	move.w  $2a(a0), -(a7)
	jsr     DeleteObject.l
	movea.w (a7)+, a1
P9F_loc_20E0AA:
	lea     $32(a1), a2
	cmpa.w  (a2), a0
	beq.s   P9F_loc_20E0B4
	addq.w  #$2, a2
P9F_loc_20E0B4:
	clr.w   (a2)
	rts     
P9F_loc_20E0B8:
	addq.b  #$2, oRoutine(a0)
	move.w  #$2ff, oAnim(a0)
	tst.b   oSubtype(a0)
	bne.s   P9F_loc_20E0CC
	bsr.w   P9F_sub_20E0F8
P9F_loc_20E0CC:
	bra.s   P9F_loc_20E07C
P9F_loc_20E0CE:
	addq.b  #$2, oRoutine(a0)
	move.w  #$3ff, oAnim(a0)
	bra.s   P9F_loc_20E07C
P9F_loc_20E0DA:
	subq.w  #$2, oY(a0)
	tst.b   oSprFlags(a0)
	bmi.s   P9F_loc_20E0F6
	lea     objects.w, a1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	cmpi.w  #$a0, d0
	bgt.s   P9F_loc_20E09E
P9F_loc_20E0F6:
	bra.s   P9F_loc_20E07C
P9F_sub_20E0F8:
	movea.w $2a(a0), a1
	move.w  $32(a1), d5
	beq.s   P9F_loc_20E170
	move.w  $34(a1), d6
	beq.s   P9F_loc_20E170
	movea.w d5, a5
	movea.w d6, a6
	cmpa.w  a0, a5
	bne.s   P9F_loc_20E170
	tst.b   $1(a5)
	bpl.s   P9F_loc_20E170
	tst.b   $1(a6)
	bpl.s   P9F_loc_20E170
	moveq   #$2, d6
	move.w  $8(a5), d5
	move.w  $c(a5), d4
	move.w  $8(a6), d3
	move.w  $c(a6), d2
	sub.w   d5, d3
	sub.w   d4, d2
	asr.w   #$2, d3
	asr.w   #$2, d2
	addq.w  #$7, d4
P9F_loc_20E138:
	jsr     FindObjSlot.l
	bne.s   P9F_loc_20E170
	move.w  a5, $2a(a1)
	move.w  a6, $2c(a1)
	dc.b	$13,$6D,$00,$00,$00,$00		; move.b $0(a5), $0(a1) (raw: not reproducible by assembler)
	move.b  $28(a5), $28(a1)
	move.b  #$fe, $29(a1)
	move.w  $2(a5), $2(a1)
	add.w   d3, d5
	add.w   d2, d4
	move.w  d5, $8(a1)
	move.w  d4, $c(a1)
	dbra    d6, P9F_loc_20E138
P9F_loc_20E170:
	rts     
P9F_loc_20E172:
	movea.w $2a(a0), a1
	movea.w $2c(a0), a2
	dc.b	$0C,$29,$00,$23,$00,$00		; cmpi.b #$23, $0(a1) (raw: not reproducible by assembler)
	bne.w   P9F_loc_20E1FC
	dc.b	$0C,$2A,$00,$23,$00,$00		; cmpi.b #$23, $0(a2) (raw: not reproducible by assembler)
	bne.w   P9F_loc_20E1FC
	cmpi.b  #$10, $24(a1)
	bne.w   P9F_loc_20E1FC
	cmpi.b  #$10, $24(a1)
	bne.w   P9F_loc_20E1FC
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P9F_dat_20E1B0(pc, d0.w), d0
	jmp     P9F_dat_20E1B0(pc, d0.w)
P9F_dat_20E1B0:
	dc.w	P9F_loc_20E1B6-P9F_dat_20E1B0
	dc.w	P9F_loc_20E1E6-P9F_dat_20E1B0
	dc.w	P9F_loc_20E1FC-P9F_dat_20E1B0
P9F_loc_20E1B6:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$2, oPriority(a0)
	move.b  #$c, oXRadius(a0)
	move.b  #$c, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.b  #$b4, oColType(a0)
	move.l  #$20e322, oMap(a0)
P9F_loc_20E1E6:
	lea     P9F_dat_20E31A(pc), a1
	jsr     AnimateObject.l
	jmp     DrawObject.l
P9F_loc_20E1F6:
	jmp     DespawnObject.l
P9F_loc_20E1FC:
	jmp     DeleteObject.l
P9F_dat_20E31A:
	dc.w	$0002,$0100,$0102,$FF00
P9F_loc_20E322:
	dc.w	$0006,$000C,$0012,$01F4,$0A00,$2BF4,$01F4,$0A00
	dc.w	$34F4,$01F4,$0A08,$34F4
P9F_loc_20E33A:
	dc.w	$0024,$003C,$0008,$FFBC,$0038,$FFC8,$0050,$0010
