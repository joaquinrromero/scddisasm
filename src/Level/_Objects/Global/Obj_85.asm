; Object $85 - Obj31_20CFEE (from R51A, old ID $31)
P85_Obj31_20CFEE:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P85_dat_20D008(pc, d0.w), d0
	jsr     P85_dat_20D008(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P85_dat_20D008:
	dc.w	P85_loc_20D010-P85_dat_20D008
	dc.w	P85_loc_20D052-P85_dat_20D008
	dc.w	P85_loc_20D0BC-P85_dat_20D008
	dc.w	P85_loc_20D0FA-P85_dat_20D008
P85_loc_20D010:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$18, oYRadius(a0)
	move.w  #$4797, oTile(a0)
	move.l  #$20d134, oMap(a0)
	btst.b  #$0, $ff158f.l
	beq.s   P85_loc_20D04A
	move.b  #$2, oMapFrame(a0)
P85_loc_20D04A:
	move.b  $ff158f.l, $3c(a0)
P85_loc_20D052:
	tst.b   debugMode.l
	bne.s   P85_loc_20D0A0
	lea     objects.w, a1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	bcc.s   P85_loc_20D06A
	neg.w   d0
P85_loc_20D06A:
	cmpi.w  #$10, d0
	bcc.s   P85_loc_20D0A0
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	bcc.s   P85_loc_20D07C
	neg.w   d0
P85_loc_20D07C:
	cmpi.w  #$8, d0
	bcc.s   P85_loc_20D0A0
	bchg.b  #$0, $ff158f.l
	addq.b  #$2, oRoutine(a0)
	tst.b   oSprFlags(a0)
	bpl.s   P85_loc_20D09E
	move.w  #$bf, d0
	jsr     PlayFMSound.l
P85_loc_20D09E:
	rts     
P85_loc_20D0A0:
	move.b  $ff158f.l, d0
	cmp.b   $3c(a0), d0
	beq.s   P85_loc_20D0B6
	move.b  #$ff, $3d(a0)
	addq.b  #$2, oRoutine(a0)
P85_loc_20D0B6:
	move.b  d0, $3c(a0)
	rts     
P85_loc_20D0BC:
	addq.b  #$1, $3a(a0)
	cmpi.b  #$7, $3a(a0)
	bne.s   P85_loc_20D0D0
	move.b  #$1, oMapFrame(a0)
	bra.s   P85_loc_20D0F8
P85_loc_20D0D0:
	cmpi.b  #$e, $3a(a0)
	bne.s   P85_loc_20D0F8
	clr.b   $3a(a0)
	clr.b   oMapFrame(a0)
	btst.b  #$0, $ff158f.l
	beq.s   P85_loc_20D0F0
	move.b  #$2, oMapFrame(a0)
P85_loc_20D0F0:
	addq.b  #$2, oRoutine(a0)
	clr.b   $3d(a0)
P85_loc_20D0F8:
	rts     
P85_loc_20D0FA:
	lea     objects.w, a1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	bcc.s   P85_loc_20D10A
	neg.w   d0
P85_loc_20D10A:
	cmpi.b  #$20, d0
	bcc.s   P85_loc_20D124
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	bcc.s   P85_loc_20D11C
	neg.w   d0
P85_loc_20D11C:
	cmpi.b  #$10, d0
	bcc.s   P85_loc_20D124
	rts     
P85_loc_20D124:
	move.b  #$2, oRoutine(a0)
	move.b  $ff158f.l, $3c(a0)
	rts     
P85_loc_20D134:
	dc.w	$0006,$0012,$001E,$02F0,$0900,$0304,$F402,$0000
	dc.w	$FC00,$02DC,$0600,$09F8,$F402,$0000,$FC00,$02F0
	dc.w	$0908,$03E4,$F402,$0000,$FC00
