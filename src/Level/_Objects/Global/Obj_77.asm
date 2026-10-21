; Object $77 - Obj20_20A552 (from R41A, old ID $20)
P77_Obj20_20A552:
	lea     objects.w, a6
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P77_dat_20A564(pc, d0.w), d1
	jmp     P77_dat_20A564(pc, d1.w)
P77_dat_20A564:
	dc.w	P77_loc_20A570-P77_dat_20A564
	dc.w	P77_loc_20A5CE-P77_dat_20A564
	dc.w	P77_loc_20A5E8-P77_dat_20A564
	dc.w	P77_loc_20A69E-P77_dat_20A564
	dc.w	P77_loc_20A6BC-P77_dat_20A564
	dc.w	P77_loc_20A6C0-P77_dat_20A564
P77_loc_20A570:
	addq.b  #$2, oRoutine(a0)
	move.l  #$21e9b4, oMap(a0)
	move.w  #$848a, oTile(a0)
	move.b  #$84, oSprFlags(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$1, oPriority(a0)
	move.b  oSubtype(a0), d0
	bpl.s   P77_loc_20A5B4
	addq.b  #$8, oRoutine(a0)
	andi.w  #$7f, d0
	move.b  d0, $32(a0)
	move.b  d0, $33(a0)
	move.b  #$6, oAnim(a0)
	bra.w   P77_loc_20A6C0
P77_loc_20A5B4:
	move.b  d0, oAnim(a0)
	move.w  oX(a0), $30(a0)
	move.w  #$ff78, oYVel(a0)
	jsr     Random.l
	move.b  d0, oAngle(a0)
P77_loc_20A5CE:
	lea     P77_loc_20A858.l, a1
	jsr     AnimateObject.l
	cmpi.b  #$6, oMapFrame(a0)
	bne.s   P77_loc_20A5E8
	move.b  #$1, $2e(a0)
P77_loc_20A5E8:
	move.w  waterHeight.w, d0
	cmp.w   oY(a0), d0
	bcs.s   P77_loc_20A600
P77_loc_20A5F2:
	move.b  #$6, oRoutine(a0)
	addq.b  #$3, oAnim(a0)
	bra.w   P77_loc_20A69E
P77_loc_20A600:
	move.b  oAngle(a0), d0
	addq.b  #$1, oAngle(a0)
	andi.w  #$7f, d0
	lea     P77_Data_21D7A6.l, a1
	move.b  (a1, d0.w), d0
	ext.w   d0
	add.w   $30(a0), d0
	move.w  d0, oX(a0)
	tst.b   $2e(a0)
	beq.s   P77_loc_20A688
	bsr.w   P77_sub_20A81E
	beq.s   P77_loc_20A688
	bsr.w   ResumeMusicS1
	move.w  #$ad, d0
	jsr     PlayFMSound.l
	clr.w   $10(a6)
	clr.w   $12(a6)
	clr.w   $14(a6)
	move.b  #$15, $1c(a6)
	move.w  #$23, $3e(a6)
	move.b  #$0, $3c(a6)
	bclr.b  #$5, $22(a6)
	bclr.b  #$4, $22(a6)
	btst.b  #$2, $22(a6)
	beq.w   P77_loc_20A5F2
	bclr.b  #$2, $22(a6)
	move.b  #$13, $16(a6)
	move.b  #$9, $17(a6)
	subq.w  #$5, $c(a6)
	bra.w   P77_loc_20A5F2
P77_loc_20A688:
	bsr.w   ObjMove
	tst.b   oSprFlags(a0)
	bpl.s   P77_loc_20A698
	jmp     DrawObject.l
P77_loc_20A698:
	jmp     DeleteObject.l
P77_loc_20A69E:
	lea     P77_loc_20A858.l, a1
	jsr     AnimateObject.l
	tst.b   oSprFlags(a0)
	bpl.s   P77_loc_20A6B6
	jmp     DrawObject.l
P77_loc_20A6B6:
	jmp     DeleteObject.l
P77_loc_20A6BC:
	bra.w   DeleteObject
P77_loc_20A6C0:
	tst.w   $36(a0)
	bne.s   P77_loc_20A722
	move.w  waterHeight.w, d0
	cmp.w   oY(a0), d0
	bcc.w   P77_loc_20A7D4
	tst.b   oSprFlags(a0)
	bpl.w   P77_loc_20A7D4
	subq.w  #$1, $38(a0)
	bpl.w   P77_loc_20A7C8
	move.w  #$1, $36(a0)
P77_loc_20A6E8:
	jsr     Random.l
	move.w  d0, d1
	andi.w  #$7, d0
	cmpi.w  #$6, d0
	bcc.s   P77_loc_20A6E8
	move.b  d0, $34(a0)
	andi.w  #$c, d1
	lea     P77_loc_20A80C.l, a1
	adda.w  d1, a1
	move.l  a1, $3c(a0)
	subq.b  #$1, $32(a0)
	bpl.s   P77_loc_20A720
	move.b  $33(a0), $32(a0)
	bset.b  #$7, $36(a0)
P77_loc_20A720:
	bra.s   P77_loc_20A72A
P77_loc_20A722:
	subq.w  #$1, $38(a0)
	bpl.w   P77_loc_20A7C8
P77_loc_20A72A:
	jsr     Random.l
	andi.w  #$1f, d0
	move.w  d0, $38(a0)
	tst.b   oSprFlags(a0)
	bpl.s   P77_loc_20A7AC
	bsr.w   FindObjSlot
	bne.s   P77_loc_20A7AC
	dc.b	$13,$7C,$00,$20,$00,$00		; move.b #$20, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	jsr     Random.l
	andi.w  #$f, d0
	subq.w  #$8, d0
	add.w   d0, $8(a1)
	move.w  oY(a0), $c(a1)
	moveq   #$0, d0
	move.b  $34(a0), d0
	movea.l $3c(a0), a2
	move.b  (a2, d0.w), $28(a1)
	btst.b  #$7, $36(a0)
	beq.s   P77_loc_20A7AC
	jsr     Random.l
	andi.w  #$3, d0
	bne.s   P77_loc_20A798
	bset.b  #$6, $36(a0)
	bne.s   P77_loc_20A7AC
	move.b  #$2, $28(a1)
P77_loc_20A798:
	tst.b   $34(a0)
	bne.s   P77_loc_20A7AC
	bset.b  #$6, $36(a0)
	bne.s   P77_loc_20A7AC
	move.b  #$2, $28(a1)
P77_loc_20A7AC:
	subq.b  #$1, $34(a0)
	bpl.s   P77_loc_20A7C8
	jsr     Random.l
	andi.w  #$7f, d0
	addi.w  #$80, d0
	add.w   d0, $38(a0)
	clr.w   $36(a0)
P77_loc_20A7C8:
	lea     P77_loc_20A858.l, a1
	jsr     AnimateObject.l
P77_loc_20A7D4:
	tst.b   oSprFlags(a0)
	bmi.s   P77_loc_20A7F8
	move.w  oX(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.w   DeleteObject
P77_loc_20A7F8:
	move.w  waterHeight.w, d0
	cmp.w   oY(a0), d0
	bcs.w   DrawObject
	bclr.b  #$7, oSprFlags(a0)
	rts     
P77_loc_20A80C:
	dc.w	$0001,$0000,$0000,$0100,$0000,$0001,$0001,$0000
	dc.w	$0100
P77_Data_21D7A6:
	incbin	"Level/Tidal Tempest/Data/Misc/P77_Data_21D7A6.bin"
P77_sub_20A81E:
	tst.b   $2c(a6)
	bmi.s   P77_loc_20A854
	move.w  $8(a6), d0
	move.w  oX(a0), d1
	subi.w  #$10, d1
	cmp.w   d0, d1
	bcc.s   P77_loc_20A854
	addi.w  #$20, d1
	cmp.w   d0, d1
	bcs.s   P77_loc_20A854
	move.w  $c(a6), d0
	move.w  oY(a0), d1
	cmp.w   d0, d1
	bcc.s   P77_loc_20A854
	addi.w  #$10, d1
	cmp.w   d0, d1
	bcs.s   P77_loc_20A854
	moveq   #$1, d0
	rts     
P77_loc_20A854:
	moveq   #$0, d0
	rts     
P77_loc_20A858:
	dc.w	$000E,$0014,$001A,$0022,$0022,$0024,$002A,$0E00
	dc.w	$0102,$FC00,$0E01,$0203,$04FC,$0E02,$0304,$0506
	dc.w	$FC00,$04FC,$0406,$0708,$FC00,$0F13,$1415,$FF00
