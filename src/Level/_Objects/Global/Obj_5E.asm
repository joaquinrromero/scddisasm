; Object $5E - ObjSpinTunnel (from R31A, old ID $35)
ObjSpinTunnel:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjSpinTunnel_Index(pc, d0.w), d0
	jsr     ObjSpinTunnel_Index(pc, d0.w)
	tst.b   debugCheat.l
	beq.s   P5E_loc_20656C
	jsr     DrawObject.l
P5E_loc_20656C:
	jmp     CheckObjDespawn.l
ObjSpinTunnel_Index:
	dc.w	ObjSpinTunnel_Init-ObjSpinTunnel_Index
	dc.w	ObjSpinTunnel_Main-ObjSpinTunnel_Index
ObjSpinTunnel_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$544, oTile(a0)
	move.l  #$23a4c8, oMap(a0)
	move.b  oSubtype(a0), oMapFrame(a0)
	addq.b  #$1, oMapFrame(a0)
ObjSpinTunnel_Main:
	lea     objects.w, a1
	cmpi.b  #$2b, $1c(a1)
	beq.w   P5E_loc_206654
	cmpi.b  #$6, $24(a1)
	bcc.w   P5E_loc_206654
	bsr.w   ObjSpinTunnel_CheckInRange
	beq.w   P5E_loc_206654
	tst.b   oSubtype(a0)
	bne.s   P5E_loc_206606
	move.w  $10(a1), d0
	bpl.s   P5E_loc_2065C6
	neg.w   d0
P5E_loc_2065C6:
	move.w  #$a00, d1
	cmpi.b  #$5, zoneAct.l
	bne.s   P5E_loc_2065D8
	move.w  #$d00, d1
P5E_loc_2065D8:
	cmp.w   d1, d0
	bcc.s   P5E_loc_2065DE
	move.w  d1, d0
P5E_loc_2065DE:
	tst.w   $10(a1)
	bpl.s   P5E_loc_2065E6
	neg.w   d0
P5E_loc_2065E6:
	move.w  d0, $10(a1)
	move.w  d0, $14(a1)
	move.b  $26(a1), d0
	addi.b  #$20, d0
	andi.b  #$c0, d0
	cmpi.b  #$80, d0
	bne.s   P5E_loc_206636
	neg.w   $14(a1)
	bra.s   P5E_loc_206636
P5E_loc_206606:
	cmpi.b  #$2, oSubtype(a0)
	bcc.s   P5E_loc_206656
	move.w  $12(a1), d0
	bpl.s   P5E_loc_206616
	neg.w   d0
P5E_loc_206616:
	cmpi.w  #$d00, d0
	bcc.s   P5E_loc_206620
	move.w  #$d00, d0
P5E_loc_206620:
	tst.w   $12(a1)
	bpl.s   P5E_loc_206628
	neg.w   d0
P5E_loc_206628:
	move.w  d0, $12(a1)
	move.w  d0, $14(a1)
	bset.b  #$1, $22(a1)
P5E_loc_206636:
	bset.b  #$2, $22(a1)
	bne.s   P5E_loc_206654
	move.b  #$e, $16(a1)
	move.b  #$7, $17(a1)
	addq.w  #$5, $c(a1)
	move.b  #$2, $1c(a1)
P5E_loc_206654:
	rts     
P5E_loc_206656:
	move.b  p1CtrlData.w, d1
	cmpi.b  #$4, oSubtype(a0)
	beq.s   P5E_loc_2066A2
	cmpi.b  #$2, oSubtype(a0)
	bne.s   P5E_loc_206672
	tst.w   $12(a1)
	bpl.s   P5E_loc_206636
	bra.s   P5E_loc_206678
P5E_loc_206672:
	tst.w   $12(a1)
	bmi.s   P5E_loc_206636
P5E_loc_206678:
	move.w  #$d00, d0
	btst.l  #$3, d1
	bne.s   P5E_loc_20668A
	btst.l  #$2, d1
	beq.s   P5E_loc_206636
	neg.w   d0
P5E_loc_20668A:
	cmpi.b  #$2, oSubtype(a0)
	beq.s   P5E_loc_206698
	bset.b  #$1, $22(a1)
P5E_loc_206698:
	move.w  d0, $10(a1)
	move.w  d0, $14(a1)
	bra.s   P5E_loc_206636
P5E_loc_2066A2:
	tst.w   $10(a1)
	bmi.s   P5E_loc_206636
	btst.l  #$0, d1
	beq.w   P5E_loc_206636
	move.w  #$f600, d0
	bra.w   P5E_loc_206628
ObjSpinTunnel_CheckInRange:
	tst.b   debugMode.l
	bne.s   P5E_loc_2066EC
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	addi.w  #$28, d0
	bmi.s   P5E_loc_2066EC
	cmpi.w  #$50, d0
	bcc.s   P5E_loc_2066EC
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	addi.w  #$28, d0
	bmi.s   P5E_loc_2066EC
	cmpi.w  #$50, d0
	bcc.s   P5E_loc_2066EC
	moveq   #$1, d0
	rts     
P5E_loc_2066EC:
	moveq   #$0, d0
	rts     
