; Object $34 - ObjSpinTunnel (from R11A, old ID $34)
ObjSpinTunnel:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjSpinTunnel_Index(pc, d0.w), d0
	jsr     ObjSpinTunnel_Index(pc, d0.w)
	tst.b   debugCheat.l
	beq.s   P34_loc_2065FC
	jsr     DrawObject.l
P34_loc_2065FC:
	jmp     CheckObjDespawn.l
ObjSpinTunnel_Index:
	dc.w	ObjSpinTunnel_Init-ObjSpinTunnel_Index
	dc.w	ObjSpinTunnel_Main-ObjSpinTunnel_Index
ObjSpinTunnel_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$544, oTile(a0)
	move.l  #$23ee9c, oMap(a0)
	move.b  oSubtype(a0), oMapFrame(a0)
	addq.b  #$1, oMapFrame(a0)
ObjSpinTunnel_Main:
	lea     objects.w, a1
	cmpi.b  #$2b, $1c(a1)
	beq.w   P34_loc_2066E4
	cmpi.b  #$6, $24(a1)
	bcc.w   P34_loc_2066E4
	bsr.w   ObjSpinTunnel_CheckInRange
	beq.w   P34_loc_2066E4
	tst.b   oSubtype(a0)
	bne.s   P34_loc_206696
	move.w  $10(a1), d0
	bpl.s   P34_loc_206656
	neg.w   d0
P34_loc_206656:
	move.w  #$a00, d1
	cmpi.b  #$5, zoneAct.l
	bne.s   P34_loc_206668
	move.w  #$d00, d1
P34_loc_206668:
	cmp.w   d1, d0
	bcc.s   P34_loc_20666E
	move.w  d1, d0
P34_loc_20666E:
	tst.w   $10(a1)
	bpl.s   P34_loc_206676
	neg.w   d0
P34_loc_206676:
	move.w  d0, $10(a1)
	move.w  d0, $14(a1)
	move.b  $26(a1), d0
	addi.b  #$20, d0
	andi.b  #$c0, d0
	cmpi.b  #$80, d0
	bne.s   P34_loc_2066C6
	neg.w   $14(a1)
	bra.s   P34_loc_2066C6
P34_loc_206696:
	cmpi.b  #$2, oSubtype(a0)
	bcc.s   P34_loc_2066E6
	move.w  $12(a1), d0
	bpl.s   P34_loc_2066A6
	neg.w   d0
P34_loc_2066A6:
	cmpi.w  #$d00, d0
	bcc.s   P34_loc_2066B0
	move.w  #$d00, d0
P34_loc_2066B0:
	tst.w   $12(a1)
	bpl.s   P34_loc_2066B8
	neg.w   d0
P34_loc_2066B8:
	move.w  d0, $12(a1)
	move.w  d0, $14(a1)
	bset.b  #$1, $22(a1)
P34_loc_2066C6:
	bset.b  #$2, $22(a1)
	bne.s   P34_loc_2066E4
	move.b  #$e, $16(a1)
	move.b  #$7, $17(a1)
	addq.w  #$5, $c(a1)
	move.b  #$2, $1c(a1)
P34_loc_2066E4:
	rts     
P34_loc_2066E6:
	move.b  p1CtrlData.w, d1
	cmpi.b  #$4, oSubtype(a0)
	beq.s   P34_loc_206732
	cmpi.b  #$2, oSubtype(a0)
	bne.s   P34_loc_206702
	tst.w   $12(a1)
	bpl.s   P34_loc_2066C6
	bra.s   P34_loc_206708
P34_loc_206702:
	tst.w   $12(a1)
	bmi.s   P34_loc_2066C6
P34_loc_206708:
	move.w  #$d00, d0
	btst.l  #$3, d1
	bne.s   P34_loc_20671A
	btst.l  #$2, d1
	beq.s   P34_loc_2066C6
	neg.w   d0
P34_loc_20671A:
	cmpi.b  #$2, oSubtype(a0)
	beq.s   P34_loc_206728
	bset.b  #$1, $22(a1)
P34_loc_206728:
	move.w  d0, $10(a1)
	move.w  d0, $14(a1)
	bra.s   P34_loc_2066C6
P34_loc_206732:
	tst.w   $10(a1)
	bmi.s   P34_loc_2066C6
	btst.l  #$0, d1
	beq.w   P34_loc_2066C6
	move.w  #$f600, d0
	bra.w   P34_loc_2066B8
ObjSpinTunnel_CheckInRange:
	tst.b   debugMode.l
	bne.s   P34_loc_20677C
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	addi.w  #$28, d0
	bmi.s   P34_loc_20677C
	cmpi.w  #$50, d0
	bcc.s   P34_loc_20677C
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	addi.w  #$28, d0
	bmi.s   P34_loc_20677C
	cmpi.w  #$50, d0
	bcc.s   P34_loc_20677C
	moveq   #$1, d0
	rts     
P34_loc_20677C:
	moveq   #$0, d0
	rts     
