; Object $83 - Obj24_20DDEC (from R51A, old ID $24)
P83_Obj24_20DDEC:
	tst.b   oSubtype(a0)
	bmi.w   P83_loc_20DF7A
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P83_dat_20DE0E(pc, d0.w), d0
	jsr     P83_dat_20DE0E(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P83_dat_20DE0E:
	dc.w	P83_loc_20DE14-P83_dat_20DE0E
	dc.w	P83_loc_20DE4A-P83_dat_20DE0E
	dc.w	P83_loc_20DE8E-P83_dat_20DE0E
P83_loc_20DE14:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$0, oMapFrame(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  #$4332, oTile(a0)
	move.l  #$20dfb2, oMap(a0)
P83_loc_20DE4A:
	tst.b   oSubtype(a0)
	beq.s   P83_loc_20DE62
	lea     objects.w, a1
	bsr.s   P83_sub_20DE6C
	bcc.s   P83_loc_20DE62
	addq.b  #$2, oRoutine(a0)
	move.b  #$f8, oColType(a0)
P83_loc_20DE62:
	lea     objects.w, a1
	jmp     SolidObject.l
P83_sub_20DE6C:
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	subq.w  #$8, d0
	subi.w  #$58, d0
	bcc.s   P83_loc_20DE8C
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	subi.w  #$fff8, d0
	subi.w  #$10, d0
P83_loc_20DE8C:
	rts     
P83_loc_20DE8E:
	tst.b   oColStatus(a0)
	bne.s   P83_loc_20DEB2
	move.l  $2e(a0), d0
	add.l   d0, oY(a0)
	addi.l  #$4000, $2e(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bmi.s   P83_loc_20DEB2
	bra.w   P83_loc_20DF98
P83_loc_20DEB2:
	lea     P83_dat_20DF4A(pc), a6
	moveq   #$3, d6
P83_loc_20DEB8:
	jsr     FindObjSlot.l
	bne.s   P83_loc_20DF22
	move.b  #$3, $18(a1)
	move.b  #$ff, $28(a1)
	move.b  #$8, $17(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  oSprFlags(a0), $1(a1)
	move.l  oMap(a0), $4(a1)
	move.w  oTile(a0), $2(a1)
	move.w  (a6)+, d0
	move.w  (a6)+, d1
	add.w   d0, $8(a1)
	add.w   d1, $c(a1)
	move.l  (a6)+, $2a(a1)
	move.l  (a6)+, $2e(a1)
	move.b  d6, d0
	addq.b  #$1, d0
	move.b  d0, $1a(a1)
	dbra    d6, P83_loc_20DEB8
P83_loc_20DF22:
	move.b  #$18, oID(a0)
	move.b  #$0, oRoutine(a0)
	move.b  #$1, oSolidType(a0)
	clr.w   oColType(a0)
	tst.b   oSprFlags(a0)
	bpl.s   P83_loc_20DF48
	move.w  #$9e, d0
	jmp     PlayFMSound.l
P83_loc_20DF48:
	rts     
P83_dat_20DF4A:
	dc.w	$FFF8,$FFF8,$FFFF,$0000,$FFFC,$0000,$0008,$FFF8
	dc.w	$0001,$0000,$FFFC,$0000,$FFF8,$0008,$FFFE,$0000
	dc.w	$FFFD,$0000,$0008,$0008,$0002,$0000,$FFFD,$0000
P83_loc_20DF7A:
	addi.l  #$4000, $2e(a0)
	move.l  $2a(a0), d0
	move.l  $2e(a0), d1
	add.l   d0, oX(a0)
	add.l   d1, oY(a0)
	jsr     DrawObject.l
P83_loc_20DF98:
	lea     objects.w, a1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	cmpi.w  #$ff20, d0
	bgt.s   P83_loc_20DFB0
	jmp     DeleteObject.l
P83_loc_20DFB0:
	rts     
P83_loc_20DFB2:
	dc.w	$000A,$001F,$0025,$002B,$0031,$04F0,$0580,$00F0
	dc.w	$F005,$8004,$0000,$0580,$08F0,$0005,$800C,$0001
	dc.w	$F805,$800C,$F801,$F805,$8008,$F801,$F805,$8004
	dc.w	$F801,$F805,$8000,$F800
