; Object $C7 - Obj33_20CDA8 (from R82A, old ID $33)
PC7_Obj33_20CDA8:
	tst.b   oSubtype(a0)
	bmi.w   PC7_loc_20D0BE
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PC7_dat_20CDD0(pc, d0.w), d0
	jsr     PC7_dat_20CDD0(pc, d0.w)
	bsr.s   PC7_sub_20CDD8
	jsr     DrawObject.l
	move.w  $36(a0), d0
	jmp     CheckObjDespawn2.l
PC7_dat_20CDD0:
	dc.w	PC7_loc_20CE06-PC7_dat_20CDD0
	dc.w	PC7_loc_20CF7E-PC7_dat_20CDD0
	dc.w	PC7_loc_20CFD6-PC7_dat_20CDD0
	dc.w	PC7_loc_20D0BC-PC7_dat_20CDD0
PC7_sub_20CDD8:
	dc.w	$0C28
	dc.w	$0003,$001A
	bne.s   PC7_loc_20CDE2
PC7_loc_20CDE0:
	rts     
PC7_loc_20CDE2:
	btst.b  #$7, oSprFlags(a0)
	beq.s   PC7_loc_20CDE0
	lea     objects.w, a1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	bcc.s   PC7_loc_20CDFA
	neg.w   d0
PC7_loc_20CDFA:
	cmpi.w  #$20, d0
	bcc.s   PC7_loc_20CDE0
	jmp     SolidObject.l
PC7_loc_20CE06:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$400, oTile(a0)
	move.l  #$20d11a, oMap(a0)
	bsr.w   PC7_sub_20CF14
	moveq   #$0, d0
	tst.b   $3d(a0)
	bne.w   PC7_loc_20CEAA
	move.b  $3c(a0), d0
	asl.b   #$2, d0
	lea     PC7_dat_20CF5A(pc), a2
	lea     (a2, d0.w), a2
	move.b  (a2)+, oMapFrame(a0)
	move.b  (a2)+, d0
	move.b  (a2)+, oWidth(a0)
	move.b  (a2)+, oYRadius(a0)
	move.w  oX(a0), $36(a0)
	move.w  oY(a0), $32(a0)
	ext.w   d0
	add.w   $36(a0), d0
	move.w  d0, oX(a0)
	move.b  #$1, $3b(a0)
	jsr     FindObjSlot.l
	beq.s   PC7_loc_20CE78
	jmp     loc_20CCAC.l
PC7_loc_20CE78:
	dc.b	$13,$7C,$00,$33,$00,$00		; move.b #$33, $0(a1) (raw: not reproducible by assembler)
	move.b  #$1, $3d(a1)
	lea     PC7_dat_20CF66(pc), a2
	bsr.s   PC7_sub_20CEDC
	jsr     FindObjSlot.l
	beq.s   PC7_loc_20CE98
	jmp     loc_20CCAC.l
PC7_loc_20CE98:
	dc.b	$13,$7C,$00,$33,$00,$00		; move.b #$33, $0(a1) (raw: not reproducible by assembler)
	move.b  #$2, $3d(a1)
	lea     PC7_dat_20CF72(pc), a2
	bsr.s   PC7_sub_20CEDC
PC7_loc_20CEAA:
	cmpi.b  #$3, oMapFrame(a0)
	beq.s   PC7_loc_20CEDA
	jsr     FindObjSlot.l
	bne.s   PC7_loc_20CEDA
	dc.b	$13,$7C,$00,$33,$00,$00		; move.b #$33, $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.w  oX(a0), $8(a1)
	move.w  oMapFrame(a0), $3c(a1)
	move.w  a0, $34(a1)
	move.w  a1, $34(a0)
PC7_loc_20CEDA:
	rts     
PC7_sub_20CF14:
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	move.b  PC7_dat_20CF22(pc, d0.w), $3c(a0)
	rts     
PC7_dat_20CF5A:
	dc.w	$01CC,$1C08,$04BC,$0C08,$05DC,$2C08
PC7_dat_20CF66:
	dc.w	$0300,$1808,$03E0,$1808,$0320,$1808
PC7_sub_20CEDC:
	moveq   #$0, d0
	move.b  $3c(a0), d0
	asl.b   #$2, d0
	lea     (a2, d0.w), a2
	move.b  (a2)+, $1a(a1)
	move.b  (a2)+, d0
	move.b  (a2)+, $19(a1)
	move.b  (a2)+, $16(a1)
	move.w  $36(a0), $36(a1)
	move.w  oY(a0), $c(a1)
	ext.w   d0
	add.w   $36(a0), d0
	move.w  d0, $8(a1)
	move.b  oSubtype(a0), $28(a1)
	rts     
PC7_dat_20CF72:
	dc.b	$02,$34,$1C,$08,$05,$24,$2C,$08		; andi.b #$8, $2c08(a4, d0.w * 4) (raw: not reproducible by assembler)
	subi.w  #$c08, d4
PC7_loc_20CF7E:
	lea     objects.w, a1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	bcs.s   PC7_loc_20CFA8
	cmpi.w  #$100, d0
	bcc.s   PC7_loc_20CFA8
	lea     PC7_dat_20CFAA(pc), a2
	tst.b   oSubtype(a0)
	beq.s   PC7_loc_20CFA0
	lea     PC7_sub_20CFB2(pc), a2
PC7_loc_20CFA0:
	jsr     (a2)
	beq.s   PC7_loc_20CFA8
	addq.b  #$2, oRoutine(a0)
PC7_loc_20CFA8:
	rts     
PC7_dat_20CF22:
	dc.w	$0001,$0201,$0002,$0000,$0102,$0102,$0102,$0102
	dc.w	$0002,$0102,$0001,$0201,$0102,$0102,$0201,$0202
	dc.w	$0102,$0101,$0001,$0200,$0102,$0201,$0001,$0201
	dc.w	$0100,$0201,$0001,$0202
PC7_dat_20CFAA:
	moveq   #$0, d1
	move.b  #$30, d1
	bra.s   PC7_loc_20CFB8
PC7_sub_20CFB2:
	moveq   #$0, d1
	move.b  #$50, d1
PC7_loc_20CFB8:
	lea     objects.w, a1
	move.w  $8(a1), d0
	sub.w   $36(a0), d0
	add.w   d1, d0
	bmi.s   PC7_loc_20CFD2
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   PC7_loc_20CFD2
	moveq   #$1, d0
	rts     
PC7_loc_20CFD2:
	moveq   #$0, d0
	rts     
PC7_loc_20CFD6:
	tst.b   oSubtype(a0)
	bne.s   PC7_loc_20CFE4
	tst.b   $3d(a0)
	bne.s   PC7_loc_20CFE4
	bsr.s   PC7_sub_20D038
PC7_loc_20CFE4:
	tst.b   $3f(a0)
	bne.s   PC7_loc_20D01A
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	add.w   d0, d0
	move.w  PC7_dat_20D02C(pc, d0.w), d0
	move.l  oY(a0), -(a7)
	add.w   d0, oY(a0)
	jsr     ObjGetFloorDist.l
	move.l  (a7)+, oY(a0)
	tst.w   d1
	bmi.s   PC7_loc_20D01C
	addi.l  #$8000, oY(a0)
	move.w  #$80, oYVel(a0)
PC7_loc_20D01A:
	rts     
PC7_loc_20D01C:
	clr.w   oYVel(a0)
	clr.w   $34(a0)
	move.b  #$ff, $3f(a0)
	rts     
PC7_sub_20D038:
	lea     objects.w, a1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	bcc.s   PC7_loc_20D04E
	neg.w   d0
	cmpi.w  #$80, d0
	bcc.s   PC7_loc_20D080
PC7_loc_20D04E:
	bsr.w   PC7_sub_20CFB2
	beq.s   PC7_loc_20D080
	addq.w  #$1, $30(a0)
	cmpi.w  #$12c, $30(a0)
	bne.s   PC7_loc_20D062
	bra.s   PC7_loc_20D082
PC7_loc_20D062:
	cmpi.w  #$258, $30(a0)
	bne.s   PC7_loc_20D06C
	bra.s   PC7_loc_20D082
PC7_loc_20D06C:
	cmpi.w  #$348, $30(a0)
	bne.s   PC7_loc_20D076
	bra.s   PC7_loc_20D082
PC7_loc_20D076:
	cmpi.w  #$438, $30(a0)
	bne.s   PC7_loc_20D080
	bra.s   PC7_loc_20D082
PC7_loc_20D080:
	rts     
PC7_loc_20D082:
	cmpi.b  #$5, $3b(a0)
	bcc.s   PC7_loc_20D0BA
	jsr     FindObjSlot.l
	beq.s   PC7_loc_20D094
	rts     
PC7_loc_20D094:
	dc.b	$13,$7C,$00,$33,$00,$00		; move.b #$33, $0(a1) (raw: not reproducible by assembler)
	move.w  $36(a0), $8(a1)
	moveq   #$0, d0
	move.b  $3b(a0), d0
	move.b  d0, $28(a1)
	asl.w   #$4, d0
	neg.w   d0
	add.w   $32(a0), d0
	move.w  d0, $c(a1)
	addq.b  #$1, $3b(a0)
PC7_loc_20D0BA:
	rts     
PC7_loc_20D0BC:
	rts     
PC7_loc_20D0BE:
	ori.b   #$4, oSprFlags(a0)
	move.l  #$20d11a, oMap(a0)
	move.w  #$4400, oTile(a0)
	move.b  #$6, oMapFrame(a0)
	move.w  $34(a0), d0
	beq.s   PC7_loc_20D10E
	movea.w d0, a1
	dc.b	$0C,$29,$00,$33,$00,$00		; cmpi.b #$33, $0(a1) (raw: not reproducible by assembler)
	bne.s   PC7_loc_20D10E
	move.w  $12(a1), oYVel(a0)
	move.w  $c(a1), d0
	addi.w  #$c, d0
	move.w  d0, oY(a0)
	moveq   #$0, d0
	move.b  $3c(a0), d0
	move.b  PC7_dat_20D114(pc, d0.w), d0
	move.b  d0, oColType(a0)
	jmp     DrawObject.l
PC7_loc_20D10E:
	jmp     DeleteObject.l
PC7_dat_20D02C:
	dc.w	$0008,$0020,$0038,$0050,$0068,$0080
PC7_dat_20D114:
	dc.w	$009C,$9C00,$9B9D
PC7_loc_20D11A:
	dc.w	$000E,$002E,$003A,$0046,$0052,$0058,$0068,$06F4
	dc.w	$0A00,$0CB0,$F40E,$0000,$C8F4,$0900,$15E8,$F409
	dc.w	$0015,$00F4,$0E00,$0018,$F40E,$0000,$3800,$02F8
	dc.w	$0A00,$0CE4,$F80E,$0000,$FC00,$02F8,$0E00,$00E4
	dc.w	$F80A,$000C,$0400,$02F8,$0900,$15E8,$F809,$0015
	dc.w	$0000,$01F8,$0A00,$0CF4,$03F8,$0E00,$00D4,$F80E
	dc.w	$0000,$F4F8,$0A00,$0C14,$00FC,$0000,$00FC
