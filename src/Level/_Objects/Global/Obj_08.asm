; Object $08 - Obj08_208854 (from R61A, old ID $08)
P08_Obj08_208854:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P08_dat_208868(pc, d0.w), d0
	jsr     P08_dat_208868(pc, d0.w)
	jmp     CheckObjDespawn.l
P08_dat_208868:
	dc.w	P08_loc_208870-P08_dat_208868
	dc.w	P08_loc_208880-P08_dat_208868
	dc.w	P08_loc_2088AE-P08_dat_208868
	dc.w	P08_loc_2088C4-P08_dat_208868
P08_loc_208870:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$32, $2b(a0)
P08_loc_208880:
	move.w  $FFFFD008.w, d0
	sub.w   oX(a0), d0
	addi.w  #$10, d0
	bcs.s   P08_loc_2088AC
	cmpi.w  #$20, d0
	bcc.s   P08_loc_2088AC
	move.w  $FFFFD00C.w, d0
	sub.w   oY(a0), d0
	addi.w  #$20, d0
	bcs.s   P08_loc_2088AC
	cmpi.w  #$40, d0
	bcc.s   P08_loc_2088AC
	addq.b  #$2, oRoutine(a0)
P08_loc_2088AC:
	rts     
P08_loc_2088AE:
	subq.b  #$1, $2a(a0)
	bpl.s   P08_loc_2088C4
	move.b  #$a, $2a(a0)
	subq.b  #$1, $2b(a0)
	bpl.s   P08_loc_2088C6
	addq.b  #$2, oRoutine(a0)
P08_loc_2088C4:
	rts     
P08_loc_2088C6:
	jsr     FindObjSlot.l
	bne.s   P08_loc_208948
	dc.b	$13,$7C,$00,$11,$00,$00		; move.b #$11, $0(a1) (raw: not reproducible by assembler)
	addq.b  #$2, $24(a1)
	move.b  #$8, $16(a1)
	move.b  #$8, $17(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	addi.w  #$18, $8(a1)
	subi.w  #$10, $c(a1)
	move.l  #$20a6c0, $4(a1)
	move.w  #$a7ae, $2(a1)
	move.b  #$3, $18(a1)
	move.b  #$4, $1(a1)
	move.b  #$47, $20(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	move.b  #$ff, ringLossAnimTimer.l
	move.w  #$fe00, $12(a1)
	jsr     Random.l
	lsl.w   #$1, d0
	andi.w  #$e, d0
	move.w  P08_dat_20894A(pc, d0.w), $10(a1)
P08_loc_208948:
	rts     
P08_dat_20894A:
	dc.w	$FF00,$FF80,$0000,$0080,$0100,$0180,$0200,$0280
