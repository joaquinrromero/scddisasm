; Object $6A - Obj23_20DA12 (from R51A, old ID $23)
P6A_Obj23_20DA12:
	tst.b   oSubtype(a0)
	bmi.w   P6A_loc_20DC20
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P6A_dat_20DA3A(pc, d0.w), d0
	jsr     P6A_dat_20DA3A(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P6A_dat_20DA3A:
	dc.w	P6A_loc_20DA48-P6A_dat_20DA3A
	dc.w	P6A_loc_20DABC-P6A_dat_20DA3A
	dc.w	P6A_loc_20DAD0-P6A_dat_20DA3A
	dc.w	P6A_loc_20DAFE-P6A_dat_20DA3A
	dc.w	P6A_loc_20DB0E-P6A_dat_20DA3A
	dc.w	P6A_loc_20DB8C-P6A_dat_20DA3A
	dc.w	P6A_loc_20DB98-P6A_dat_20DA3A
P6A_loc_20DA48:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$2414, oTile(a0)
	move.b  #$18, oXRadius(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$18, oYRadius(a0)
	move.b  #$35, oColType(a0)
	lea     P6A_dat_20DCA6(pc), a1
	lea     P6A_dat_20DC9A(pc), a2
	move.l  #$fff80000, d0
	tst.b   oSubtype(a0)
	beq.s   P6A_loc_20DA98
	lea     P6A_dat_20DD46(pc), a1
	lea     P6A_dat_20DCA0(pc), a2
	move.l  #$fffb0000, d0
P6A_loc_20DA98:
	move.l  a1, oMap(a0)
	move.l  a2, $2c(a0)
	move.l  d0, $30(a0)
	tst.b   oLayer(a0)
	beq.s   P6A_loc_20DAB6
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$0, oFlags(a0)
P6A_loc_20DAB6:
	addq.b  #$2, oRoutine(a0)
	bra.s   P6A_loc_20DAD0
P6A_loc_20DABC:
	addq.b  #$2, oRoutine(a0)
	move.b  #$0, oMapFrame(a0)
	subq.w  #$8, oY(a0)
	move.l  $30(a0), $34(a0)
P6A_loc_20DAD0:
	addi.l  #$4000, $34(a0)
	move.l  $34(a0), d0
	add.l   d0, oY(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P6A_loc_20DAFC
	add.w   d1, oY(a0)
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, oMapFrame(a0)
	addq.w  #$8, oY(a0)
P6A_loc_20DAFC:
	rts     
P6A_loc_20DAFE:
	addq.b  #$2, oRoutine(a0)
	move.b  #$36, oColType(a0)
	move.w  #$b4, $2a(a0)
P6A_loc_20DB0E:
	tst.b   oSubtype(a0)
	bne.s   P6A_loc_20DB30
	lea     objects.w, a1
	bsr.s   P6A_sub_20DB44
	tst.b   d6
	beq.s   P6A_loc_20DB30
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, oMapFrame(a0)
	move.w  #$3c, $2a(a0)
	rts     
P6A_loc_20DB30:
	subq.w  #$1, $2a(a0)
	bne.s   P6A_loc_20DB3A
	subq.b  #$6, oRoutine(a0)
P6A_loc_20DB3A:
	movea.l $2c(a0), a1
	jmp     AnimateObject.l
P6A_dat_20DCA6:
	dc.w	$0006,$004D,$0076,$0EF1,$0700,$1BFF,$1104,$0023
	dc.w	$FFF0,$0700,$1B03,$1004,$0023,$03EF,$0700,$1B06
	dc.w	$0F04,$0023,$06E7,$0E00,$00EC,$EF00,$000C,$0CF1
	dc.w	$0708,$1BE4,$1104,$0823,$E4F0,$0708,$1BE8,$1004
	dc.w	$0823,$E8EF,$0708,$1BEB,$0F04,$0823,$EB08,$F107
	dc.w	$000D,$FFF0,$0700,$0D03,$EF07,$000D,$06F0,$0E00
	dc.w	$00EC,$F800,$000C,$0CF1,$0708,$0DE4,$F007,$080D
	dc.w	$E8EF,$0708,$0DEB,$08F9,$0600,$15FF,$F806,$0015
	dc.w	$03F7,$0600,$1506,$F30E,$0000,$ECFB,$0000,$0C0C
	dc.w	$F906,$0815,$E4F8,$0608,$15E8,$F706,$0815,$EB00
P6A_dat_20DC9A:
	dc.w	$0002,$0701,$02FF
P6A_dat_20DD46:
	dc.w	$0006,$0048,$006C,$0DF1,$0700,$1BFF,$1104,$0023
	dc.w	$FFF0,$0700,$1B03,$1004,$0023,$03EF,$0700,$1B06
	dc.w	$0F04,$0023,$06E7,$0E00,$2BEC,$F107,$081B,$E411
	dc.w	$0408,$23E4,$F007,$081B,$E810,$0408,$23E8,$EF07
	dc.w	$081B,$EB0F,$0408,$23EB,$07F1,$0700,$0DFF,$F007
	dc.w	$000D,$03EF,$0700,$0D06,$F00E,$002B,$ECF1,$0708
	dc.w	$0DE4,$F007,$080D,$E8EF,$0708,$0DEB,$07F9,$0600
	dc.w	$15FF,$F806,$0015,$03F7,$0600,$1506,$F30E,$002B
	dc.w	$ECF9,$0608,$15E4,$F806,$0815,$E8F7,$0608,$15EB
P6A_dat_20DCA0:
	dc.w	$0002,$0F01,$02FF
P6A_sub_20DB44:
	moveq   #$0, d6
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	subi.w  #$ffb0, d0
	subi.w  #$a0, d0
	bcc.s   P6A_loc_20DB8A
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	move.w  d0, d1
	subi.w  #$ffb0, d1
	subi.w  #$a0, d1
	bcc.s   P6A_loc_20DB8A
	tst.w   d0
	smi.b   d0
	btst.b  #$0, oSprFlags(a0)
	seq.b   d1
	eor.b   d1, d0
	bne.s   P6A_loc_20DB8A
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	moveq   #$ff, d6
P6A_loc_20DB8A:
	rts     
P6A_loc_20DB8C:
	subq.w  #$1, $2a(a0)
	bne.s   P6A_loc_20DB96
	addq.b  #$2, oRoutine(a0)
P6A_loc_20DB96:
	rts     
P6A_loc_20DB98:
	jsr     FindObjSlot.l
	bne.s   P6A_loc_20DC18
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  oSprFlags(a0), $1(a1)
	move.b  #$1, $18(a1)
	move.w  oTile(a0), $2(a1)
	move.b  #$c, $17(a1)
	move.b  #$c, $19(a1)
	move.b  #$8, $16(a1)
	move.b  #$f7, $20(a1)
	move.l  #$20dddc, $4(a1)
	move.w  #$18, d0
	move.l  #$30000, d1
	btst.b  #$0, $1(a1)
	beq.s   P6A_loc_20DC00
	neg.w   d0
	neg.l   d1
P6A_loc_20DC00:
	add.w   d0, $8(a1)
	move.l  d1, $34(a1)
	tst.b   oSprFlags(a0)
	bpl.s   P6A_loc_20DC18
	move.w  #$a0, d0
	jsr     PlayFMSound.l
P6A_loc_20DC18:
	subi.b  #$a, oRoutine(a0)
	rts     
P6A_loc_20DC20:
	tst.w   $2a(a0)
	bne.s   P6A_loc_20DC60
	tst.b   oColStatus(a0)
	beq.s   P6A_loc_20DC4C
	clr.b   oColStatus(a0)
	lea     objects.w, a1
	cmpi.b  #$4, $24(a1)
	beq.s   P6A_loc_20DC4C
	cmpi.b  #$6, $24(a1)
	beq.s   P6A_loc_20DC4C
	tst.w   $30(a1)
	bne.s   P6A_loc_20DC4C
	bra.s   P6A_loc_20DC56
P6A_loc_20DC4C:
	move.l  $34(a0), d0
	add.l   d0, oX(a0)
	bra.s   P6A_loc_20DC84
P6A_loc_20DC56:
	move.w  a1, $2c(a0)
	move.w  #$78, $2a(a0)
P6A_loc_20DC60:
	subq.w  #$1, $2a(a0)
	bne.s   P6A_loc_20DC6C
	jmp     DeleteObject.l
P6A_loc_20DC6C:
	movea.w $2c(a0), a1
	move.w  $8(a1), oX(a0)
	move.w  $c(a1), oY(a0)
	clr.w   $10(a1)
	clr.w   $14(a1)
P6A_loc_20DC84:
	lea     P6A_dat_20DDD6(pc), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P6A_dat_20DDD6:
	dc.w	$0002,$0200,$01FF
P6A_loc_20DDDC:
	dc.w	$0004,$000A,$01F8,$0980,$25F4,$01F8,$0998,$25F4
