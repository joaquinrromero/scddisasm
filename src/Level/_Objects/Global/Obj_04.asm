; Object $04 - Obj04_208E52 (from R61A, old ID $04)
P04_Obj04_208E52:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P04_dat_208E6C(pc, d0.w), d0
	jsr     P04_dat_208E6C(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P04_dat_208E6C:
	dc.w	P04_loc_208E76-P04_dat_208E6C
	dc.w	P04_loc_208EE2-P04_dat_208E6C
	dc.w	P04_loc_208F12-P04_dat_208E6C
	dc.w	P04_loc_208FB4-P04_dat_208E6C
	dc.w	P04_loc_208FD0-P04_dat_208E6C
P04_loc_208E76:
	ori.b   #$4, oSprFlags(a0)
	move.w  #$400, oTile(a0)
	move.l  #$209000, oMap(a0)
	move.w  oX(a0), $2e(a0)
	move.b  #$1c, oXRadius(a0)
	move.b  #$1c, oWidth(a0)
	move.b  #$4, oYRadius(a0)
	addq.b  #$2, oRoutine(a0)
	jsr     FindNextObjSlot.l
	dc.b	$13,$7C,$00,$04,$00,$00		; move.b #$4, $0(a1) (raw: not reproducible by assembler)
	ori.b   #$4, $1(a1)
	move.w  #$400, $2(a1)
	move.l  #$209000, $4(a1)
	move.b  #$4, $17(a1)
	move.b  #$c, $16(a1)
	move.b  #$1, $1a(a1)
	move.l  a0, $2a(a1)
	move.b  #$8, $24(a1)
P04_loc_208EE2:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	beq.s   P04_loc_208F10
	bset.b  #$0, $2c(a1)
	move.w  oX(a0), $8(a1)
	bclr.b  #$0, $22(a1)
	move.b  #$3a, $1c(a1)
	addq.b  #$2, oRoutine(a0)
	move.w  #$c00, oXVel(a0)
P04_loc_208F10:
	rts     
P04_loc_208F12:
	move.w  oXVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	move.l  oX(a0), d1
	add.l   d0, d1
	move.l  d1, oX(a0)
	lea     objects.w, a1
	jsr     TopSolidObject.l
	move.w  p1CtrlData.w, d0
	andi.b  #$70, d0
	beq.s   P04_loc_208F76
	bclr.b  #$0, $2c(a1)
	move.w  #$f980, $12(a1)
	move.w  oXVel(a0), $10(a1)
	move.b  #$e, $16(a1)
	move.b  #$7, $17(a1)
	addq.w  #$5, $c(a1)
	bset.b  #$2, $22(a1)
	bclr.b  #$5, $22(a1)
	move.b  #$2, $1c(a1)
	move.w  #$92, d0
	jsr     PlayFMSound.l
P04_loc_208F76:
	move.w  $2e(a0), d0
	addi.w  #$390, d0
	cmp.w   oX(a0), d0
	bcc.s   P04_loc_208FB2
	move.w  d0, oX(a0)
	addq.b  #$2, oRoutine(a0)
	btst.b  #$3, oFlags(a0)
	beq.s   P04_loc_208FB2
	bclr.b  #$0, $2c(a1)
	move.w  oXVel(a0), $10(a1)
	move.b  #$0, $1c(a1)
	bset.b  #$1, $22(a1)
	bclr.b  #$3, $22(a1)
P04_loc_208FB2:
	rts     
P04_loc_208FB4:
	subq.w  #$4, oX(a0)
	move.w  $2e(a0), d0
	cmp.w   oX(a0), d0
	bcs.s   P04_loc_208FCE
	move.w  $2e(a0), oX(a0)
	move.b  #$2, oRoutine(a0)
P04_loc_208FCE:
	rts     
P04_loc_208FD0:
	movea.l $2a(a0), a1
	cmpi.b  #$4, $24(a1)
	bcc.s   P04_loc_208FFE
	move.w  $8(a1), oX(a0)
	subi.w  #$18, oX(a0)
	move.w  $c(a1), oY(a0)
	subi.w  #$10, oY(a0)
	lea     objects.w, a1
	jmp     SolidObject.l
P04_loc_208FFE:
	rts     
P04_loc_209000:
	dc.w	$0004,$001E,$05E4,$0000,$00E4,$EC06,$0001,$E4F4
	dc.w	$0000,$07F4,$FC0C,$0008,$F4FC,$0000,$0C14,$FF00
