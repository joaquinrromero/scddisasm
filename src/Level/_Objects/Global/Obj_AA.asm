; Object $AA - Obj21_20CBB2 (from R61A, old ID $21)
PAA_Obj21_20CBB2:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PAA_dat_20CBCC(pc, d0.w), d0
	jsr     PAA_dat_20CBCC(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PAA_dat_20CBCC:
	dc.w	PAA_loc_20CBD2-PAA_dat_20CBCC
	dc.w	PAA_loc_20CC06-PAA_dat_20CBCC
	dc.w	PAA_loc_20CC88-PAA_dat_20CBCC
PAA_loc_20CBD2:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.w  #$6358, oTile(a0)
	move.l  #$20ce82, oMap(a0)
	move.b  #$10, oYRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  oSubtype(a0), oMapFrame(a0)
	bsr.w   PAA_sub_20CCF4
PAA_loc_20CC06:
	tst.b   oSubtype(a0)
	beq.s   PAA_loc_20CC5A
	bsr.w   PAA_sub_20CCE2
	tst.w   $3a(a0)
	bne.s   PAA_loc_20CC5C
	bsr.w   PAA_sub_20CD38
	cmpi.b  #$2, timeZone.l
	bne.s   PAA_loc_20CC2C
	tst.b   goodFuture.l
	bne.s   PAA_loc_20CC5A
PAA_loc_20CC2C:
	tst.b   act.l
	bne.s   PAA_loc_20CC3E
	move.w  cameraY.w, d0
	cmpi.w  #$400, d0
	bcc.s   PAA_loc_20CC5A
PAA_loc_20CC3E:
	move.w  #$168, d0
	move.b  timeZone.l, d1
	beq.s   PAA_loc_20CC56
	move.w  #$1e0, d0
	subq.b  #$1, d1
	beq.s   PAA_loc_20CC56
	move.w  #$f0, d0
PAA_loc_20CC56:
	move.w  d0, $3a(a0)
PAA_loc_20CC5A:
	rts     
PAA_loc_20CC5C:
	subq.w  #$1, $3a(a0)
	bne.s   PAA_loc_20CC5A
	addq.b  #$2, oRoutine(a0)
	move.w  #$78, $3a(a0)
	move.w  #$5a, $30(a0)
	clr.b   $2e(a0)
	btst.b  #$7, oSprFlags(a0)
	beq.s   PAA_loc_20CC88
	move.w  #$b2, d0
	jsr     PlayFMSound.l
PAA_loc_20CC88:
	bsr.w   PAA_sub_20CCE2
	tst.w   $30(a0)
	beq.s   PAA_loc_20CCA6
	move.b  $3c(a0), d0
	bsr.w   PAA_sub_20CE5C
	subq.w  #$1, $30(a0)
	beq.s   PAA_loc_20CCA2
	rts     
PAA_loc_20CCA2:
	bsr.w   PAA_sub_20CD38
PAA_loc_20CCA6:
	move.b  $3c(a0), d0
	addq.b  #$1, d0
	move.b  d0, wwzBeamMode.l
	moveq   #$0, d0
	move.b  $3c(a0), d0
	bsr.w   PAA_sub_20CD80
	subq.w  #$1, $3a(a0)
	bne.s   PAA_loc_20CCE0
	subq.b  #$2, oRoutine(a0)
	clr.b   wwzBeamMode.l
	addq.b  #$1, $3c(a0)
	cmpi.b  #$3, $3c(a0)
	bcs.s   PAA_loc_20CCE0
	clr.b   $3c(a0)
	clr.w   $3e(a0)
PAA_loc_20CCE0:
	rts     
PAA_sub_20CCF4:
	lea     resObjectsEnd.w, a1
	move.w  #$5f, d0
PAA_loc_20CCFC:
	dc.b	$0C,$29,$00,$21,$00,$00		; cmpi.b #$21, $0(a1) (raw: not reproducible by assembler)
	bne.s   PAA_loc_20CD0A
	tst.b   $28(a1)
	bne.s   PAA_loc_20CD36
PAA_loc_20CD0A:
	lea     $40(a1), a1
	dbra    d0, PAA_loc_20CCFC
	jsr     FindObjSlot.l
	bne.s   PAA_loc_20CD36
	dc.b	$13,$7C,$00,$21,$00,$00		; move.b #$21, $0(a1) (raw: not reproducible by assembler)
	move.b  #$1, $28(a1)
	lea     objects.w, a2
	move.w  $8(a2), $8(a1)
	move.w  $c(a2), $c(a1)
PAA_loc_20CD36:
	rts     
PAA_sub_20CCE2:
	lea     objects.w, a1
	move.w  $8(a1), oX(a0)
	move.w  $c(a1), oY(a0)
	rts     
PAA_sub_20CD38:
	lea     $FFFFFB40.w, a3
	move.w  #$626, d0
	move.w  #$646, d2
	move.b  timeZone.l, d1
	beq.s   PAA_loc_20CD6E
	lea     $FFFFFB7A.w, a3
	move.w  #$222, d0
	move.w  #$680, d2
	subq.b  #$1, d1
	beq.s   PAA_loc_20CD6E
	move.w  #$402, d0
	move.w  #$246, d2
	tst.b   goodFuture.l
	beq.s   PAA_loc_20CD6E
	rts     
PAA_loc_20CD6E:
	lea     $FFFFFB64.w, a2
	move.w  d0, (a2)+
	move.w  d0, (a2)+
	move.w  d0, (a2)+
	move.w  d2, (a3)+
	rts     
PAA_sub_20CE5C:
	move.b  PAA_dat_20CE7E(pc, d0.w), d0
	lea     $FFFFFB64.w, a2
	lea     (a2, d0.w), a2
	move.w  #$80, d0
	tst.b   $2e(a0)
	beq.s   PAA_loc_20CE74
	moveq   #$0, d0
PAA_loc_20CE74:
	move.w  d0, (a2)
	eori.b  #$1, $2e(a0)
	rts     
PAA_sub_20CD80:
	move.b  PAA_dat_20CD7C(pc, d0.w), d0
	lea     $FFFFFB64.w, a2
	lea     (a2, d0.w), a2
	lea     PAA_loc_20CE28.l, a1
	move.b  timeZone.l, d1
	beq.s   PAA_loc_20CDAA
	lea     PAA_loc_20CE0E.l, a1
	subq.b  #$1, d1
	beq.s   PAA_loc_20CDAA
	lea     PAA_loc_20CE42.l, a1
PAA_loc_20CDAA:
	moveq   #$0, d1
	move.b  $3e(a0), d1
	add.b   d1, d1
	lea     (a1, d1.w), a1
	move.w  (a1)+, (a2)+
	addq.b  #$1, $3e(a0)
	move.w  (a1), d1
	cmpi.w  #$ffff, d1
	bne.s   PAA_loc_20CDC8
	clr.b   $3e(a0)
PAA_loc_20CDC8:
	lea     $FFFFFB40.w, a2
	lea     PAA_loc_20CE38.l, a1
	move.b  timeZone.l, d1
	beq.s   PAA_loc_20CDEE
	lea     $FFFFFB7A.w, a2
	lea     PAA_loc_20CE1E.l, a1
	subq.b  #$1, d1
	beq.s   PAA_loc_20CDEE
	lea     PAA_loc_20CE52.l, a1
PAA_loc_20CDEE:
	moveq   #$0, d1
	move.b  $3f(a0), d1
	add.b   d1, d1
	lea     (a1, d1.w), a1
	move.w  (a1)+, (a2)+
	addq.b  #$1, $3f(a0)
	move.w  (a1), d1
	cmpi.w  #$ffff, d1
	bne.s   PAA_loc_20CE0C
	clr.b   $3f(a0)
PAA_loc_20CE0C:
	rts     
PAA_loc_20CE0E:
	dc.w	$0000,$0EE0,$0000,$00EE,$0000,$0E0E,$0000,$FFFF
PAA_loc_20CE1E:
	dc.w	$0A60,$0AA0,$0A60,$0AA0,$FFFF
PAA_loc_20CE28:
	dc.w	$0000,$0EE0,$0000,$00EE,$0000,$0E0E,$0000,$FFFF
PAA_loc_20CE38:
	dc.w	$0846,$084A,$0846,$084A,$FFFF
PAA_loc_20CE42:
	dc.w	$0000,$0EE0,$0000,$00EE,$0000,$0E0E,$0000,$FFFF
PAA_loc_20CE52:
	dc.w	$0244,$0248,$0244,$0248,$FFFF
PAA_dat_20CE7E:
	dc.w	$0002,$0400
PAA_loc_20CE82:
	dc.w	$0004,$001A,$04E8,$0A00,$00E8,$000A,$0009,$E8E8
	dc.w	$0A08,$0000,$000A,$0809,$0000,$0000
PAA_dat_20CD7C:
	dc.w	$0002,$0400
