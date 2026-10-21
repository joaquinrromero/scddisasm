; Object $A4 - ObjSpinTunnel (from R71A, old ID $2B)
ObjSpinTunnel:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjSpinTunnel_Index(pc, d0.w), d0
	jsr     ObjSpinTunnel_Index(pc, d0.w)
	tst.b   debugCheat.l
	beq.s   PA4_loc_206398
	jsr     DrawObject.l
PA4_loc_206398:
	jmp     CheckObjDespawn.l
ObjSpinTunnel_Index:
	dc.w	ObjSpinTunnel_Init-ObjSpinTunnel_Index
	dc.w	ObjSpinTunnel_Main-ObjSpinTunnel_Index
ObjSpinTunnel_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$544, oTile(a0)
	move.l  #$23b49a, oMap(a0)
	move.b  oSubtype(a0), oMapFrame(a0)
	addq.b  #$1, oMapFrame(a0)
ObjSpinTunnel_Main:
	lea     objects.w, a1
	cmpi.b  #$2b, $1c(a1)
	beq.w   PA4_loc_206480
	cmpi.b  #$6, $24(a1)
	bcc.w   PA4_loc_206480
	bsr.w   ObjSpinTunnel_CheckInRange
	beq.w   PA4_loc_206480
	tst.b   oSubtype(a0)
	bne.s   PA4_loc_206432
	move.w  $10(a1), d0
	bpl.s   PA4_loc_2063F2
	neg.w   d0
PA4_loc_2063F2:
	move.w  #$a00, d1
	cmpi.b  #$5, zoneAct.l
	bne.s   PA4_loc_206404
	move.w  #$d00, d1
PA4_loc_206404:
	cmp.w   d1, d0
	bcc.s   PA4_loc_20640A
	move.w  d1, d0
PA4_loc_20640A:
	tst.w   $10(a1)
	bpl.s   PA4_loc_206412
	neg.w   d0
PA4_loc_206412:
	move.w  d0, $10(a1)
	move.w  d0, $14(a1)
	move.b  $26(a1), d0
	addi.b  #$20, d0
	andi.b  #$c0, d0
	cmpi.b  #$80, d0
	bne.s   PA4_loc_206462
	neg.w   $14(a1)
	bra.s   PA4_loc_206462
PA4_loc_206432:
	cmpi.b  #$2, oSubtype(a0)
	bcc.s   PA4_loc_206482
	move.w  $12(a1), d0
	bpl.s   PA4_loc_206442
	neg.w   d0
PA4_loc_206442:
	cmpi.w  #$d00, d0
	bcc.s   PA4_loc_20644C
	move.w  #$d00, d0
PA4_loc_20644C:
	tst.w   $12(a1)
	bpl.s   PA4_loc_206454
	neg.w   d0
PA4_loc_206454:
	move.w  d0, $12(a1)
	move.w  d0, $14(a1)
	bset.b  #$1, $22(a1)
PA4_loc_206462:
	bset.b  #$2, $22(a1)
	bne.s   PA4_loc_206480
	move.b  #$e, $16(a1)
	move.b  #$7, $17(a1)
	addq.w  #$5, $c(a1)
	move.b  #$2, $1c(a1)
PA4_loc_206480:
	rts     
PA4_loc_206482:
	move.b  p1CtrlData.w, d1
	cmpi.b  #$4, oSubtype(a0)
	beq.s   PA4_loc_2064CE
	cmpi.b  #$2, oSubtype(a0)
	bne.s   PA4_loc_20649E
	tst.w   $12(a1)
	bpl.s   PA4_loc_206462
	bra.s   PA4_loc_2064A4
PA4_loc_20649E:
	tst.w   $12(a1)
	bmi.s   PA4_loc_206462
PA4_loc_2064A4:
	move.w  #$d00, d0
	btst.l  #$3, d1
	bne.s   PA4_loc_2064B6
	btst.l  #$2, d1
	beq.s   PA4_loc_206462
	neg.w   d0
PA4_loc_2064B6:
	cmpi.b  #$2, oSubtype(a0)
	beq.s   PA4_loc_2064C4
	bset.b  #$1, $22(a1)
PA4_loc_2064C4:
	move.w  d0, $10(a1)
	move.w  d0, $14(a1)
	bra.s   PA4_loc_206462
PA4_loc_2064CE:
	tst.w   $10(a1)
	bmi.s   PA4_loc_206462
	btst.l  #$0, d1
	beq.w   PA4_loc_206462
	move.w  #$f600, d0
	bra.w   PA4_loc_206454
ObjSpinTunnel_CheckInRange:
	tst.b   debugMode.l
	bne.s   PA4_loc_206518
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	addi.w  #$28, d0
	bmi.s   PA4_loc_206518
	cmpi.w  #$50, d0
	bcc.s   PA4_loc_206518
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	addi.w  #$28, d0
	bmi.s   PA4_loc_206518
	cmpi.w  #$50, d0
	bcc.s   PA4_loc_206518
	moveq   #$1, d0
	rts     
PA4_loc_206518:
	moveq   #$0, d0
	rts     
