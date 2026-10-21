; Object $71 - ObjSpinTunnel (from R61A, old ID $1E)
ObjSpinTunnel:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjSpinTunnel_Index(pc, d0.w), d0
	jsr     ObjSpinTunnel_Index(pc, d0.w)
	tst.b   debugCheat.l
	beq.s   P71_loc_206762
	jsr     DrawObject.l
P71_loc_206762:
	jmp     CheckObjDespawn.l
ObjSpinTunnel_Index:
	dc.w	ObjSpinTunnel_Init-ObjSpinTunnel_Index
	dc.w	ObjSpinTunnel_Main-ObjSpinTunnel_Index
ObjSpinTunnel_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$544, oTile(a0)
	move.l  #$239c34, oMap(a0)
	move.b  oSubtype(a0), oMapFrame(a0)
	addq.b  #$1, oMapFrame(a0)
ObjSpinTunnel_Main:
	lea     objects.w, a1
	cmpi.b  #$2b, $1c(a1)
	beq.w   P71_loc_20684A
	cmpi.b  #$6, $24(a1)
	bcc.w   P71_loc_20684A
	bsr.w   ObjSpinTunnel_CheckInRange
	beq.w   P71_loc_20684A
	tst.b   oSubtype(a0)
	bne.s   P71_loc_2067FC
	move.w  $10(a1), d0
	bpl.s   P71_loc_2067BC
	neg.w   d0
P71_loc_2067BC:
	move.w  #$a00, d1
	cmpi.b  #$5, zoneAct.l
	bne.s   P71_loc_2067CE
	move.w  #$d00, d1
P71_loc_2067CE:
	cmp.w   d1, d0
	bcc.s   P71_loc_2067D4
	move.w  d1, d0
P71_loc_2067D4:
	tst.w   $10(a1)
	bpl.s   P71_loc_2067DC
	neg.w   d0
P71_loc_2067DC:
	move.w  d0, $10(a1)
	move.w  d0, $14(a1)
	move.b  $26(a1), d0
	addi.b  #$20, d0
	andi.b  #$c0, d0
	cmpi.b  #$80, d0
	bne.s   P71_loc_20682C
	neg.w   $14(a1)
	bra.s   P71_loc_20682C
P71_loc_2067FC:
	cmpi.b  #$2, oSubtype(a0)
	bcc.s   P71_loc_20684C
	move.w  $12(a1), d0
	bpl.s   P71_loc_20680C
	neg.w   d0
P71_loc_20680C:
	cmpi.w  #$d00, d0
	bcc.s   P71_loc_206816
	move.w  #$d00, d0
P71_loc_206816:
	tst.w   $12(a1)
	bpl.s   P71_loc_20681E
	neg.w   d0
P71_loc_20681E:
	move.w  d0, $12(a1)
	move.w  d0, $14(a1)
	bset.b  #$1, $22(a1)
P71_loc_20682C:
	bset.b  #$2, $22(a1)
	bne.s   P71_loc_20684A
	move.b  #$e, $16(a1)
	move.b  #$7, $17(a1)
	addq.w  #$5, $c(a1)
	move.b  #$2, $1c(a1)
P71_loc_20684A:
	rts     
P71_loc_20684C:
	move.b  p1CtrlData.w, d1
	cmpi.b  #$4, oSubtype(a0)
	beq.s   P71_loc_206898
	cmpi.b  #$2, oSubtype(a0)
	bne.s   P71_loc_206868
	tst.w   $12(a1)
	bpl.s   P71_loc_20682C
	bra.s   P71_loc_20686E
P71_loc_206868:
	tst.w   $12(a1)
	bmi.s   P71_loc_20682C
P71_loc_20686E:
	move.w  #$d00, d0
	btst.l  #$3, d1
	bne.s   P71_loc_206880
	btst.l  #$2, d1
	beq.s   P71_loc_20682C
	neg.w   d0
P71_loc_206880:
	cmpi.b  #$2, oSubtype(a0)
	beq.s   P71_loc_20688E
	bset.b  #$1, $22(a1)
P71_loc_20688E:
	move.w  d0, $10(a1)
	move.w  d0, $14(a1)
	bra.s   P71_loc_20682C
P71_loc_206898:
	tst.w   $10(a1)
	bmi.s   P71_loc_20682C
	btst.l  #$0, d1
	beq.w   P71_loc_20682C
	move.w  #$f600, d0
	bra.w   P71_loc_20681E
ObjSpinTunnel_CheckInRange:
	tst.b   debugMode.l
	bne.s   P71_loc_2068E2
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	addi.w  #$28, d0
	bmi.s   P71_loc_2068E2
	cmpi.w  #$50, d0
	bcc.s   P71_loc_2068E2
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	addi.w  #$28, d0
	bmi.s   P71_loc_2068E2
	cmpi.w  #$50, d0
	bcc.s   P71_loc_2068E2
	moveq   #$1, d0
	rts     
P71_loc_2068E2:
	moveq   #$0, d0
	rts     
