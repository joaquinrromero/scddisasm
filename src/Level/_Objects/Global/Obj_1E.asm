; Object $1E - Obj1E_20AF16 (from R31A, old ID $1E)
Obj1E_20AF16:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P1E_dat_20AF24(pc, d0.w), d0
	jmp     P1E_dat_20AF24(pc, d0.w)
P1E_dat_20AF24:
	dc.w	P1E_loc_20AF28-P1E_dat_20AF24
	dc.w	P1E_loc_20AF52-P1E_dat_20AF24
P1E_loc_20AF28:
	addq.b  #$2, oRoutine(a0)
	move.l  #$20b0f8, oMap(a0)
	move.w  #$49d, oTile(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$10, oYRadius(a0)
P1E_loc_20AF52:
	tst.b   oAnim(a0)
	bne.s   P1E_loc_20AF60
	lea     objects.w, a1
	bsr.w   P1E_sub_20AF76
P1E_loc_20AF60:
	lea     P1E_loc_20B0EA.l, a1
	bsr.w   AnimateObject
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P1E_sub_20AF76:
	cmpi.b  #$2b, $1c(a1)
	beq.w   P1E_loc_20B01E
	move.w  $8(a1), d0
	moveq   #$0, d1
	move.b  oWidth(a0), d1
	sub.w   oX(a0), d0
	add.w   d1, d0
	bmi.w   P1E_loc_20B01E
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.w   P1E_loc_20B01E
	move.w  $8(a1), d0
	moveq   #$0, d3
	move.b  oWidth(a0), d3
	move.w  oX(a0), d2
	sub.w   d3, d2
	sub.w   d2, d0
	btst.b  #$0, oFlags(a0)
	beq.s   P1E_loc_20AFBE
	move.w  #$40, d2
	sub.w   d0, d2
	move.w  d2, d0
P1E_loc_20AFBE:
	lea     P1E_loc_20B028.l, a3
	tst.w   $12(a1)
	bpl.s   P1E_loc_20AFD0
	lea     P1E_loc_20B068.l, a3
P1E_loc_20AFD0:
	move.b  (a3, d0.w), d0
	ext.w   d0
	add.w   oY(a0), d0
	move.w  d0, d1
	moveq   #$0, d3
	move.b  $16(a1), d3
	tst.w   $12(a1)
	bpl.s   P1E_loc_20AFEA
	neg.w   d3
P1E_loc_20AFEA:
	sub.w   d3, d1
	add.w   $c(a1), d3
	sub.w   d0, d3
	addq.w  #$8, d3
	bmi.s   P1E_loc_20B01E
	cmpi.w  #$10, d3
	bcc.s   P1E_loc_20B01E
	move.w  d1, $c(a1)
	tst.w   $12(a1)
	bmi.s   P1E_loc_20B00E
	jsr     StandOnObject.l
	bra.s   P1E_loc_20B01A
P1E_loc_20B00E:
	move.w  #$0, $12(a1)
	move.w  $10(a1), $14(a1)
P1E_loc_20B01A:
	moveq   #$1, d0
	rts     
P1E_loc_20B01E:
	jsr     GetOffObject.l
	moveq   #$0, d0
	rts     
P1E_loc_20B028:
	dc.w	$0E0D,$0C0B,$0B0A,$0A09,$0908,$0807,$0706,$0605
	dc.w	$0504,$0403,$0302,$0201,$0100,$00FF,$FFFE,$FEFD
	dc.w	$FDFC,$FCFB,$FBFA,$FAF9,$F9F8,$F8F7,$F7F6,$F6F5
	dc.w	$F5F5,$F4F4,$F4F4,$F4F4,$F5F5,$F6F6,$F7F8,$FAFC
P1E_loc_20B068:
	dc.w	$1213,$1414,$1414,$1414,$1413,$1313,$1313,$1313
	dc.w	$1212,$1212,$1212,$1111,$1111,$1111,$1010,$1010
	dc.w	$1010,$100F,$0F0F,$0F0F,$0E0E,$0E0E,$0E0E,$0D0D
	dc.w	$0D0D,$0D0D,$0C0C,$0C0C,$0B0B,$0A0A,$0908,$0604
P1E_loc_20B0A8:
	dc.w	$0004,$0008,$0F00,$FF00,$0401,$0201,$02FD,$0000
P1E_loc_20B0B8:
	dc.w	$0006,$000C,$0012,$01F0,$0F00,$00F0,$01F4,$0A00
	dc.w	$10F4,$06EC,$0400,$19F0,$F40A,$001B,$E80C,$0410
	dc.w	$19F0,$EC04,$0819,$00F4,$0A08,$1B00,$0C04,$1819
	dc.w	$0000
P1E_loc_20B0EA:
	dc.w	$0004,$0008,$0F00,$FF00,$0101,$0201,$FD00
P1E_loc_20B0F8:
	dc.w	$0006,$001C,$0028,$0404,$0D00,$00E0,$FC04,$0008
	dc.w	$F0F4,$0E00,$0A00,$0C08,$0016,$0000,$02F4,$0E00
	dc.w	$19E0,$F40E,$0025,$0000,$04EC,$0D10,$00E0,$FC04
	dc.w	$1008,$F0F4,$0E10,$0A00,$EC08,$1016,$0000
