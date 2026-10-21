; Object $6F - Obj05_20895A (from R61A, old ID $05)
P6F_Obj05_20895A:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P6F_dat_208974(pc, d0.w), d0
	jsr     P6F_dat_208974(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P6F_dat_208974:
	dc.w	P6F_loc_208982-P6F_dat_208974
	dc.w	P6F_loc_2089A0-P6F_dat_208974
	dc.w	P6F_loc_2089F0-P6F_dat_208974
	dc.w	P6F_loc_208A00-P6F_dat_208974
	dc.w	P6F_loc_208A10-P6F_dat_208974
	dc.w	P6F_loc_208A56-P6F_dat_208974
	dc.w	P6F_loc_208AE6-P6F_dat_208974
P6F_loc_208982:
	ori.b   #$4, oSprFlags(a0)
	move.w  #$310, oTile(a0)
	move.l  #$208d94, oMap(a0)
	move.b  #$78, $2a(a0)
	addq.b  #$2, oRoutine(a0)
P6F_loc_2089A0:
	tst.b   $2a(a0)
	beq.s   P6F_loc_2089EE
	subq.b  #$1, $2a(a0)
	bne.s   P6F_loc_2089EE
	jsr     FindObjSlot.l
	bne.s   P6F_loc_2089EE
	move.l  a0, $2a(a1)
	dc.b	$13,$7C,$00,$05,$00,$00		; move.b #$5, $0(a1) (raw: not reproducible by assembler)
	move.b  #$3, $18(a1)
	ori.b   #$4, $1(a1)
	move.w  oTile(a0), $2(a1)
	move.l  oMap(a0), $4(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	addi.w  #$24, $c(a1)
	move.b  #$4, $24(a1)
P6F_loc_2089EE:
	rts     
P6F_loc_2089F0:
	bsr.w   P6F_sub_208CA0
	lea     P6F_loc_208D18.l, a1
	jmp     AnimateObject.l
P6F_loc_208A00:
	movea.l $2a(a0), a1
	move.b  #$78, $2a(a1)
	jmp     DeleteObject.l
P6F_loc_208A10:
	addi.w  #$38, oYVel(a0)
	move.l  oY(a0), d3
	move.w  oYVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, d3
	move.l  d3, oY(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P6F_loc_208A4A
	move.w  #$92, d0
	jsr     SubCPUCmd.l
	move.b  #$f, $30(a0)
	add.w   d1, oY(a0)
	addq.b  #$2, oRoutine(a0)
P6F_loc_208A4A:
	movea.l $2a(a0), a1
	move.l  oY(a0), $c(a1)
	rts     
P6F_loc_208A56:
	movea.l $2a(a0), a1
	tst.b   $30(a0)
	beq.s   P6F_loc_208AAE
	subq.b  #$1, $30(a0)
	move.b  p1CtrlTap.w, d0
	andi.b  #$70, d0
	beq.s   P6F_loc_208AE4
	bclr.b  #$0, $2c(a1)
	bclr.b  #$6, $2c(a1)
	move.w  #$f980, $12(a1)
	move.b  #$e, $16(a1)
	move.b  #$7, $17(a1)
	addq.w  #$5, $c(a1)
	bset.b  #$2, $22(a1)
	bclr.b  #$5, $22(a1)
	move.b  #$2, $1c(a1)
	move.w  #$92, d0
	jsr     PlayFMSound.l
	bra.s   P6F_loc_208ACA
P6F_loc_208AAE:
	movea.l a0, a3
	movea.l a0, a2
	movea.l $2a(a0), a0
	bclr.b  #$0, $2c(a0)
	bclr.b  #$6, $2c(a0)
	jsr     P6F_sub_207086.l
	movea.l a3, a0
P6F_loc_208ACA:
	addq.b  #$2, oRoutine(a0)
	move.b  #$a, oMapFrame(a0)
	move.b  #$14, $30(a0)
	move.b  #$2, $31(a0)
	bsr.w   P6F_sub_208B88
P6F_loc_208AE4:
	rts     
P6F_loc_208AE6:
	subq.b  #$1, $30(a0)
	bne.s   P6F_loc_208B10
	cmpi.b  #$b, oMapFrame(a0)
	beq.s   P6F_loc_208B0A
	moveq   #$0, d0
	move.b  $31(a0), d0
	add.w   d0, d0
	move.w  P6F_dat_208B22(pc, d0.w), d0
	lea     P6F_dat_208B22(pc, d0.w), a3
	moveq   #$3, d6
	bsr.w   P6F_sub_208B90
P6F_loc_208B0A:
	jmp     DeleteObject.l
P6F_loc_208B10:
	move.w  oXVel(a0), d0
	add.w   d0, oX(a0)
	move.w  oYVel(a0), d0
	add.w   d0, oY(a0)
	rts     
P6F_sub_208CA0:
	cmpi.b  #$1, oAnim(a0)
	bne.s   P6F_loc_208CB8
	lea     objects.w, a1
	cmpi.b  #$2b, $1c(a1)
	beq.s   P6F_loc_208CB8
	bsr.s   P6F_sub_208CBA
	bne.s   P6F_loc_208C40
P6F_loc_208CB8:
	rts     
P6F_sub_207086:
	clr.b   $2a(a0)
	andi.b  #$e7, $2c(a0)
	clr.w   $3e(a0)
	tst.b   shield.l
	bne.s   P6F_loc_2070C0
	tst.w   rings.l
	beq.w   P6F_loc_207126
	jsr     FindObjSlot.l
	bne.s   P6F_loc_2070C0
	dc.b	$13,$7C,$00,$11,$00,$00		; move.b #$11, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
P6F_loc_2070C0:
	bclr.b  #$0, shield.l
	bne.s   P6F_loc_2070D2
	move.b  #$0, combineRing.l
P6F_loc_2070D2:
	move.b  #$4, oRoutine(a0)
	bsr.w   Player_ResetOnFloor
	bset.b  #$1, oFlags(a0)
	move.w  #$fc00, oYVel(a0)
	move.w  #$fe00, oXVel(a0)
	btst.b  #$6, oFlags(a0)
	beq.s   P6F_loc_207102
	move.w  #$fe00, oYVel(a0)
	move.w  #$ff00, oXVel(a0)
P6F_loc_207102:
	move.w  oX(a0), d0
	cmp.w   $8(a2), d0
	bcs.s   P6F_loc_207110
	neg.w   oXVel(a0)
P6F_loc_207110:
	move.w  #$0, $14(a0)
	move.b  #$1a, oAnim(a0)
	move.w  #$78, $30(a0)
	moveq   #$ff, d0
	rts     
P6F_loc_207126:
	tst.w   debugCheat.l
	bne.w   P6F_loc_2070C0
P6F_sub_208B88:
	moveq   #$5, d6
	lea     P6F_loc_208C10.l, a3
P6F_dat_208B22:
	dc.w	$0006,$0026,$0046,$0000,$0A0B,$0000,$FF00,$0000
	dc.w	$0A0B,$0001,$0000,$0000,$0A0B,$0000,$0100,$0000
	dc.w	$0A0B,$00FF,$0000,$0000,$0A0B,$00FF,$FF00,$0000
	dc.w	$0A0B,$0001,$FF00,$0000,$0A0B,$0000,$0100,$0000
	dc.w	$010B,$00FF,$0000,$0000,$0A0B,$00FF,$FF00,$0000
	dc.w	$0A0B,$0001,$FF00,$0000,$0A0B,$0001,$0100,$0000
	dc.w	$0A0B,$00FF,$0100
P6F_sub_208B90:
	moveq   #$0, d1
P6F_loc_208B92:
	jsr     FindObjSlot.l
	bne.s   P6F_loc_208C0E
	dc.b	$13,$7C,$00,$05,$00,$00		; move.b #$5, $0(a1) (raw: not reproducible by assembler)
	move.b  #$c, $24(a1)
	ori.b   #$4, $1(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.w  #$2e1, $2(a1)
	move.l  #$208d94, $4(a1)
	move.b  (a3, d1.w), d2
	ext.w   d2
	add.w   d2, $8(a1)
	move.b  $1(a3, d1.w), d2
	ext.w   d2
	add.w   d2, $c(a1)
	move.b  $2(a3, d1.w), $30(a1)
	move.b  $3(a3, d1.w), $1a(a1)
	move.b  $4(a3, d1.w), d2
	or.b    d2, $1(a1)
	move.b  $5(a3, d1.w), d2
	ext.w   d2
	move.w  d2, $10(a1)
	move.b  $6(a3, d1.w), d2
	ext.w   d2
	move.w  d2, $12(a1)
	move.b  $7(a3, d1.w), $31(a1)
	addq.w  #$8, d1
	dbra    d6, P6F_loc_208B92
P6F_loc_208C0E:
	rts     
P6F_loc_208C10:
	dc.w	$F0F4,$0A09,$00FF,$FF00,$F00C,$0A09,$02FF,$0100
	dc.w	$10F4,$0A09,$0101,$FF00,$100C,$0A09,$0301,$0100
	dc.w	$00F0,$0F0A,$0100,$FF01,$0010,$0F0A,$0300,$0101
P6F_loc_208C40:
	movea.l a1, a2
	jsr     FindObjSlot.l
	bne.s   P6F_loc_208C9E
	bset.b  #$0, $2c(a2)
	bset.b  #$6, $2c(a2)
	move.l  a2, $2a(a1)
	dc.b	$13,$7C,$00,$05,$00,$00		; move.b #$5, $0(a1) (raw: not reproducible by assembler)
	ori.b   #$4, $1(a1)
	move.w  $8(a2), $8(a1)
	move.w  $c(a2), $c(a1)
	move.w  #$2e1, $2(a1)
	move.l  #$208d94, $4(a1)
	move.b  #$18, $17(a1)
	move.b  #$18, $19(a1)
	move.b  #$18, $16(a1)
	move.b  #$8, $1a(a1)
	move.b  #$8, $24(a1)
P6F_loc_208C9E:
	rts     
P6F_sub_208CBA:
	tst.b   invincible.l
	bne.s   P6F_loc_208D14
	tst.b   timeWarp.l
	bne.s   P6F_loc_208D14
	cmpi.b  #$4, $24(a1)
	bcc.s   P6F_loc_208D14
	tst.b   $2c(a1)
	bne.s   P6F_loc_208D14
	move.b  $17(a1), d1
	ext.w   d1
	addi.w  #$10, d1
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	add.w   d1, d0
	bmi.s   P6F_loc_208D14
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P6F_loc_208D14
	move.b  $16(a1), d1
	ext.w   d1
	addi.w  #$20, d1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	add.w   d1, d0
	bmi.s   P6F_loc_208D14
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P6F_loc_208D14
	moveq   #$1, d0
	rts     
P6F_loc_208D14:
	moveq   #$0, d0
	rts     
P6F_loc_208D18:
	dc.w	$0006,$000E,$0068,$0103,$0706,$07FD,$0100,$0102
	dc.w	$0704,$0705,$0701,$0702,$0704,$0705,$0701,$0702
	dc.w	$0704,$0705,$0701,$0702,$0704,$0705,$0701,$0702
	dc.w	$0704,$0705,$0701,$0702,$0704,$0705,$0701,$0702
	dc.w	$0704,$0705,$0701,$0702,$0704,$0705,$0701,$0702
	dc.w	$0704,$0705,$0701,$0702,$0704,$0705,$0701,$0702
	dc.w	$0707,$0407,$0705,$FD02,$0707,$0702,$0707,$0705
	dc.w	$0707,$0707,$0207,$0707,$0705,$FC00
P6F_loc_208D94:
	dc.w	$0018,$0024,$003A,$0050,$005C,$0072,$0088,$0094
	dc.w	$0096,$00AC,$00B2,$00B8,$02F8,$0D00,$00E0,$F80D
	dc.w	$0800,$0000,$04E0,$0D00,$08F0,$F00D,$0008,$F000
	dc.w	$0E00,$10F0,$1804,$001C,$F800,$04D8,$0D00,$08F0
	dc.w	$E80D,$0008,$F0F8,$0E00,$10F0,$1004,$001C,$F800
	dc.w	$02E0,$0E00,$10F0,$F804,$001C,$F800,$04E0,$0D08
	dc.w	$08F0,$F00D,$0808,$F000,$0E08,$10F0,$1804,$081C
	dc.w	$F800,$04D8,$0D08,$08F0,$E80D,$0808,$F0F8,$0E08
	dc.w	$10F0,$1004,$081C,$F800,$02E0,$0E08,$10F0,$F804
	dc.w	$081C,$F800,$FF00,$04E8,$0F00,$00E8,$E807,$0010
	dc.w	$0808,$0D00,$18E8,$0805,$0020,$0800,$01F4,$0600
	dc.w	$24F8,$01F8,$0500,$2AF8,$01FC,$0000,$2EFC
