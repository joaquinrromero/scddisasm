; Object $BF - Obj2C_20C484 (from R73C, old ID $2C)
Obj2C_20C484:
	lea     objects.w, a1
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PBF_dat_20C4B0(pc, d0.w), d0
	jsr     PBF_dat_20C4B0(pc, d0.w)
	bsr.w   PBF_sub_20C97C
	bsr.w   PBF_sub_20C940
	lea     loc_20D0D8.l, a1
	jsr     AnimateObject.l
	jmp     DrawObject.l
PBF_dat_20C4B0:
	dc.w	PBF_loc_20C4BA-PBF_dat_20C4B0
	dc.w	PBF_loc_20C516-PBF_dat_20C4B0
	dc.w	PBF_loc_20C636-PBF_dat_20C4B0
	dc.w	PBF_loc_20C710-PBF_dat_20C4B0
	dc.w	PBF_loc_20C73E-PBF_dat_20C4B0
PBF_loc_20C4BA:
	move.b  #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$24, oWidth(a0)
	move.b  #$24, oYRadius(a0)
	move.w  #$300, oTile(a0)
	move.l  #$20d0de, oMap(a0)
	addq.b  #$7, bossFlags.w
	move.b  #$7, bossFight.w
	movem.l d7/a0-a7, -(a7)
	move.w  #$6, d0
	jsr     LoadPalette.l
	movem.l (a7)+, d7/a0-a7
	move.b  #$2, oRoutine(a0)
	bsr.w   PBF_sub_20CFBC
	bset.b  #$3, $2c(a0)
	bsr.w   PBF_sub_20CF98
	bsr.w   PBF_sub_20CFFA
	rts     
PBF_loc_20C516:
	bsr.w   PBF_loc_20C9FC
	moveq   #$0, d0
	move.b  $2d(a0), d0
	add.b   d0, d0
	move.w  PBF_dat_20C52A(pc, d0.w), d0
	jmp     PBF_dat_20C52A(pc, d0.w)
PBF_sub_20C97C:
	tst.b   $38(a0)
	bge.s   PBF_loc_20C9B4
	move.w  oX(a0), d0
	subq.w  #$8, d0
	cmpi.w  #$3da0, d0
	ble.s   PBF_loc_20C992
	move.w  #$3da0, d0
PBF_loc_20C992:
	move.w  d0, leftBound.w
	move.w  d0, destLeftBound.w
	move.w  $8(a1), d0
	sub.w   leftBound.w, d0
	subi.w  #$a0, d0
	bge.s   PBF_loc_20C9B4
	addi.w  #$a0, d0
	andi.w  #$fffe, d0
	move.w  d0, camXCenter.w
PBF_loc_20C9B4:
	move.b  $38(a0), d0
	andi.w  #$f, d0
	add.b   d0, d0
	move.w  PBF_dat_20C9C6(pc, d0.w), d0
	jmp     PBF_dat_20C9C6(pc, d0.w)
PBF_sub_20C940:
	btst.b  #$4, $2c(a0)
	beq.s   PBF_loc_20C97A
	lea     objects.w, a3
	tst.b   (a3)
	beq.s   PBF_loc_20C97A
	cmpi.b  #$6, $24(a3)
	bcc.s   PBF_loc_20C97A
	move.w  $8(a3), d0
	sub.w   oX(a0), d0
	cmpi.w  #$10, d0
	bgt.s   PBF_loc_20C97A
	movem.l a0-a2, -(a7)
	movea.l a3, a0
	bset.b  #$7, oFlags(a0)
	bsr.w   KillPlayer
	movem.l (a7)+, a0-a2
PBF_loc_20C97A:
	rts     
PBF_sub_20CFBC:
	jsr     FindNextObjSlot.l
	bne.s   PBF_loc_20CFF8
	move.w  a0, $2e(a1)
	dc.b	$13,$7C,$00,$2D,$00,$00		; move.b #$2d, $0(a1) (raw: not reproducible by assembler)
	move.b  #$0, $28(a1)
	move.b  #$0, $1c(a1)
	jsr     FindNextObjSlot.l
	bne.s   PBF_loc_20CFF8
	move.w  a0, $2e(a1)
	dc.b	$13,$7C,$00,$2D,$00,$00		; move.b #$2d, $0(a1) (raw: not reproducible by assembler)
	move.b  #$1, $28(a1)
	move.b  #$1, $1c(a1)
PBF_loc_20CFF8:
	rts     
PBF_sub_20CF98:
	jsr     FindNextObjSlot.l
	bne.s   PBF_loc_20CFBA
	move.w  a0, $2e(a1)
	move.w  a1, $2e(a0)
	dc.b	$13,$7C,$00,$2F,$00,$00		; move.b #$2f, $0(a1) (raw: not reproducible by assembler)
	move.w  #$c30, $8(a1)
	move.w  #$1cd, $c(a1)
PBF_loc_20CFBA:
	rts     
PBF_sub_20CFFA:
	moveq   #$3, d2
	movea.l a0, a3
PBF_loc_20CFFE:
	jsr     FindNextObjSlot.l
	bne.w   PBF_loc_20D048
	move.w  a3, $2e(a1)
	move.w  a0, $3a(a1)
	dc.b	$13,$7C,$00,$2E,$00,$00		; move.b #$2e, $0(a1) (raw: not reproducible by assembler)
	movea.l a1, a3
	cmpi.w  #$3, d2
	beq.s   PBF_loc_20D038
	tst.w   d2
	beq.s   PBF_loc_20D024
	bra.s   PBF_loc_20D02A
PBF_loc_20D024:
	move.b  #$1, $29(a1)
PBF_loc_20D02A:
	move.w  #$2, $36(a1)
	move.w  #$20, $38(a1)
	bra.s   PBF_loc_20D044
PBF_loc_20D038:
	move.w  #$0, $36(a1)
	move.w  #$34, $38(a1)
PBF_loc_20D044:
	dbra    d2, PBF_loc_20CFFE
PBF_loc_20D048:
	rts     
PBF_dat_20C52A:
	dc.w	PBF_loc_20C536-PBF_dat_20C52A
	dc.w	PBF_loc_20C5A2-PBF_dat_20C52A
	dc.w	PBF_loc_20CECA-PBF_dat_20C52A
	dc.w	PBF_loc_20C5D4-PBF_dat_20C52A
	dc.w	PBF_loc_20CECA-PBF_dat_20C52A
	dc.w	PBF_loc_20C606-PBF_dat_20C52A
PBF_loc_20C536:
	andi.b  #$f0, $38(a0)
	addq.b  #$1, $38(a0)
	cmpi.w  #$be0, $8(a1)
	blt.w   PBF_loc_20C580
	move.w  #$fa00, oXVel(a0)
	move.w  #$0, $30(a0)
	addq.b  #$1, $2d(a0)
	bset.b  #$0, oFlags(a0)
	move.w  #$b40, d0
	move.w  d0, leftBound.w
	move.w  d0, destLeftBound.w
	move.w  #$67, d0
	movem.l a0-a2, -(a7)
	jsr     SubCPUCmd.l
	movem.l (a7)+, a0-a2
	rts     
PBF_loc_20C580:
	move.w  $8(a1), d0
	subi.w  #$a0, d0
	cmp.w   leftBound.w, d0
	blt.w   PBF_loc_20C634
	cmpi.w  #$b40, d0
	bgt.w   PBF_loc_20C634
	move.w  d0, leftBound.w
	move.w  d0, destLeftBound.w
	rts     
PBF_loc_20C5A2:
	bsr.w   PBF_sub_20CEA0
	move.w  #$b18, d0
	cmp.w   oX(a0), d0
	blt.w   PBF_loc_20C634
	move.w  d0, oX(a0)
	move.w  #$600, oXVel(a0)
	move.w  #$0, $30(a0)
	addq.b  #$1, $2d(a0)
	bclr.b  #$0, oFlags(a0)
	move.w  #$78, $2a(a0)
	rts     
PBF_loc_20C5D4:
	bsr.w   PBF_sub_20CEA0
	move.w  #$ca8, d0
	cmp.w   oX(a0), d0
	bgt.w   PBF_loc_20C634
	move.w  d0, oX(a0)
	move.w  #$fa00, oXVel(a0)
	move.w  #$0, $30(a0)
	bset.b  #$0, oFlags(a0)
	addq.b  #$1, $2d(a0)
	move.w  #$78, $2a(a0)
	rts     
PBF_loc_20C606:
	bsr.w   PBF_sub_20CEA0
	move.w  #$c20, d0
	cmp.w   oX(a0), d0
	blt.s   PBF_loc_20C634
	move.w  d0, oX(a0)
	clr.w   oXVel(a0)
	clr.w   $30(a0)
	clr.b   $2d(a0)
	clr.w   $2a(a0)
	bclr.b  #$3, $2c(a0)
	move.b  #$4, oRoutine(a0)
PBF_loc_20C634:
	rts     
PBF_loc_20C636:
	bsr.w   PBF_sub_20CEA0
	move.w  #$b00, d0
	cmp.w   oX(a0), d0
	blt.w   PBF_loc_20C64A
	move.w  d0, oX(a0)
PBF_loc_20C64A:
	bsr.w   PBF_loc_20C9FC
	lea     PBF_loc_20C658.l, a3
	bra.w   PBF_sub_20CEE0
PBF_loc_20C658:
	dc.w	$0078,$0030,$00B4,$0052,$00B8,$0044,$00B9,$006E
	dc.w	$00BE,$0060,$00DC,$0052,$00E0,$0044,$00E6,$0060
	dc.w	$0104,$0052,$0108,$0044,$010E,$0060,$01A4,$0080
	dc.w	$3468,$002E,$157C,$0004,$0024,$426A,$002A,$422A
	dc.w	$002D,$4E75,$08E8,$0006,$002C,$08E8,$0005,$002C
	dc.w	$4E75,$08E8,$0006,$002C,$08A8,$0005,$002C,$4E75
	dc.w	$08A8,$0006,$002C,$08A8,$0005,$002C,$4E75,$08E8
	dc.w	$0003,$002C,$317C,$FE00,$0010,$4268,$0030,$4E75
	dc.w	$61D0,$117C,$0006,$0024,$08E8,$0004,$002C,$317C
	dc.w	$0200,$0010,$317C,$0200,$0034,$317C,$0002,$0030
	dc.w	$4268,$0012,$4268,$0032,$08A8,$0000,$0022,$4228
	dc.w	$002D,$4268,$002A,$4E75
PBF_loc_20C710:
	move.w  #$3e50, d0
	cmp.w   oX(a0), d0
	ble.s   PBF_loc_20C726
	bsr.w   PBF_sub_20CE68
	bsr.w   PBF_sub_20C8A6
	bra.w   PBF_loc_20C9FC
PBF_loc_20C726:
	move.w  d0, oX(a0)
	move.b  #$8, oRoutine(a0)
	clr.b   $2d(a0)
	clr.w   oXVel(a0)
	clr.w   oYVel(a0)
	rts     
PBF_loc_20C73E:
	moveq   #$0, d0
	move.b  $2d(a0), d0
	add.b   d0, d0
	move.w  PBF_dat_20C74E(pc, d0.w), d0
	jmp     PBF_dat_20C74E(pc, d0.w)
PBF_dat_20C9C6:
	dc.w	PBF_loc_20C9CE-PBF_dat_20C9C6
	dc.w	PBF_loc_20C9D0-PBF_dat_20C9C6
	dc.w	PBF_loc_20C9DE-PBF_dat_20C9C6
	dc.w	PBF_loc_20C9EC-PBF_dat_20C9C6
PBF_loc_20C9CE:
	rts     
PBF_loc_20C9D0:
	move.w  #$b40, d0
	move.w  d0, rightBound.w
	move.w  d0, destRightBound.w
	rts     
PBF_loc_20C9DE:
	move.w  #$3da0, d0
	move.w  d0, rightBound.w
	move.w  d0, destRightBound.w
	rts     
PBF_loc_20C9EC:
	lea     loc_202932.l, a3
	move.w  (a3), rightBound.w
	move.w  (a3), destRightBound.w
	rts     
PBF_loc_20C9FC:
	addi.w  #$80, oY(a0)
	bsr.w   PBF_sub_20CA64
	subi.w  #$80, oY(a0)
	rts     
PBF_sub_20CEA0:
	move.w  $30(a0), d0
	add.w   d0, oXVel(a0)
	move.w  $32(a0), d0
	add.w   d0, oYVel(a0)
PBF_loc_20CEB0:
	move.w  oXVel(a0), d0
	ext.l   d0
	lsl.l   #$8, d0
	add.l   d0, oX(a0)
	move.w  oYVel(a0), d0
	ext.l   d0
	lsl.l   #$8, d0
	add.l   d0, oY(a0)
	rts     
PBF_loc_20CECA:
	subq.w  #$1, $2a(a0)
	beq.s   PBF_loc_20CEDA
	rts     
PBF_loc_20CED2:
	subq.b  #$1, $2a(a0)
	beq.s   PBF_loc_20CEDA
	rts     
PBF_loc_20CEDA:
	addq.b  #$1, $2d(a0)
	rts     
PBF_sub_20CEE0:
	moveq   #$0, d0
	move.b  $2d(a0), d0
	add.b   d0, d0
	add.b   d0, d0
	move.w  (a3, d0.w), d0
	cmp.w   $2a(a0), d0
	beq.s   PBF_loc_20CEFA
	addq.w  #$1, $2a(a0)
	rts     
PBF_loc_20CEFA:
	addq.w  #$1, $2a(a0)
	moveq   #$0, d0
	move.b  $2d(a0), d0
	addq.b  #$1, $2d(a0)
	add.b   d0, d0
	add.b   d0, d0
	move.w  $2(a3, d0.w), d0
	adda.w  d0, a3
	jmp     (a3)
PBF_sub_20CE68:
	move.w  $32(a0), d0
	add.w   d0, oYVel(a0)
	move.w  $30(a0), d0
	add.w   d0, oXVel(a0)
	tst.w   $30(a0)
	beq.s   PBF_loc_20CEB0
	bmi.s   PBF_loc_20CE90
	move.w  $34(a0), d0
	cmp.w   oXVel(a0), d0
	bgt.s   PBF_loc_20CEB0
	move.w  d0, oXVel(a0)
	bra.s   PBF_loc_20CEB0
PBF_loc_20CE90:
	move.w  $34(a0), d0
	cmp.w   oXVel(a0), d0
	blt.s   PBF_loc_20CEB0
	move.w  d0, oXVel(a0)
	bra.s   PBF_loc_20CEB0
PBF_sub_20C8A6:
	move.b  oWidth(a0), d0
	move.w  oX(a0), d1
	sub.w   cameraX.w, d1
	add.w   d0, d1
	bge.s   PBF_loc_20C8D2
	addq.w  #$1, $3c(a0)
	bsr.w   PBF_sub_20C8FE
	tst.w   $3a(a0)
	beq.s   PBF_loc_20C8CA
	subq.w  #$1, $3a(a0)
	rts     
PBF_loc_20C8CA:
	bclr.b  #$2, $2c(a0)
	rts     
PBF_loc_20C8D2:
	clr.w   $3c(a0)
	bsr.w   PBF_sub_20C8FE
	bset.b  #$2, $2c(a0)
	beq.s   PBF_loc_20C8E4
	rts     
PBF_loc_20C8E4:
	move.w  #$f0, $3a(a0)
	move.w  #$100, d1
	move.w  $10(a1), d0
	cmp.w   d1, d0
	bge.s   PBF_loc_20C8F8
	move.w  d1, d0
PBF_loc_20C8F8:
	move.w  d0, oXVel(a0)
	rts     
PBF_dat_20C74E:
	dc.w	PBF_loc_20C762-PBF_dat_20C74E
	dc.w	PBF_loc_20C778-PBF_dat_20C74E
	dc.w	PBF_loc_20CECA-PBF_dat_20C74E
	dc.w	PBF_loc_20C7A0-PBF_dat_20C74E
	dc.w	PBF_loc_20CECA-PBF_dat_20C74E
	dc.w	PBF_loc_20C7E8-PBF_dat_20C74E
	dc.w	PBF_loc_20CECA-PBF_dat_20C74E
	dc.w	PBF_loc_20C80C-PBF_dat_20C74E
	dc.w	PBF_loc_20CECA-PBF_dat_20C74E
	dc.w	PBF_loc_20C826-PBF_dat_20C74E
PBF_loc_20C762:
	move.b  $39(a0), d0
	andi.b  #$f, d0
	cmpi.b  #$1, d0
	beq.s   PBF_loc_20C780
	cmpi.b  #$2, d0
	beq.s   PBF_loc_20C778
	rts     
PBF_loc_20C778:
	move.b  #$1, $2d(a0)
	rts     
PBF_loc_20C780:
	bclr.b  #$5, $2c(a0)
	bclr.b  #$4, $2c(a0)
	andi.b  #$f, $38(a0)
	move.b  #$2, $2d(a0)
	move.w  #$1e, $2a(a0)
	rts     
PBF_loc_20C7A0:
	addq.w  #$1, $2a(a0)
	cmpi.w  #$78, $2a(a0)
	bge.s   PBF_loc_20C7C4
	moveq   #$0, d0
	move.w  $2a(a0), d0
	divu.w  #$14, d0
	swap    d0
	tst.w   d0
	bne.s   PBF_loc_20C7C2
	eori.b  #$40, $2c(a0)
PBF_loc_20C7C2:
	rts     
PBF_loc_20C7C4:
	bclr.b  #$6, $2c(a0)
	addq.b  #$1, $2d(a0)
	move.w  #$1e, $2a(a0)
	clr.w   oXVel(a0)
	move.w  #$200, oYVel(a0)
	moveq   #$4, d0
	jsr     LoadPLC.l
	rts     
PBF_loc_20C7E8:
	bsr.w   PBF_loc_20CEB0
	cmpi.w  #$190, oY(a0)
	bge.s   PBF_loc_20C7F6
	rts     
PBF_loc_20C7F6:
	move.w  #$600, oXVel(a0)
	clr.w   oYVel(a0)
	addq.b  #$1, $2d(a0)
	move.w  #$3c, $2a(a0)
	rts     
PBF_loc_20C80C:
	bsr.w   PBF_loc_20CEB0
	cmpi.w  #$3f60, oX(a0)
	bge.s   PBF_loc_20C81A
	rts     
PBF_loc_20C81A:
	addq.b  #$1, $2d(a0)
	move.w  #$3c, $2a(a0)
	rts     
PBF_loc_20C826:
	move.w  #$20, d0
	tst.b   goodFuture.l
	beq.s   PBF_loc_20C836
	move.w  #$1f, d0
PBF_loc_20C836:
	movem.l a0-a2, -(a7)
	jsr     SubCPUCmd.l
	movem.l (a7)+, a0-a2
	move.b  #$3, $38(a0)
	bsr.w   PBF_sub_20C97C
	jsr     LoadCapsulePal.l
	bsr.s   PBF_sub_20C85E
	addq.l  #$4, a7
	jmp     DeleteObject.l
PBF_sub_20CA64:
	movem.l a1-a2, -(a7)
	jsr     ObjGetFloorDist.l
	movem.l (a7)+, a1-a2
	cmpi.w  #$8, d1
	ble.s   PBF_loc_20CA7E
	bsr.w   PBF_sub_20CA8E
	bra.s   PBF_loc_20CA88
PBF_loc_20CA7E:
	cmpi.w  #$fff8, d1
	bge.s   PBF_loc_20CA88
	bsr.w   PBF_sub_20CA8E
PBF_loc_20CA88:
	add.w   d1, oY(a0)
	rts     
PBF_sub_20C8FE:
	cmpi.w  #$ff60, d1
	ble.s   PBF_loc_20C920
	cmpi.w  #$3100, $8(a1)
	bge.s   PBF_loc_20C91C
	cmpi.w  #$dc0, $8(a1)
	bge.s   PBF_loc_20C918
	moveq   #$0, d0
	bra.s   PBF_loc_20C922
PBF_loc_20C918:
	moveq   #$4, d0
	bra.s   PBF_loc_20C922
PBF_loc_20C91C:
	moveq   #$8, d0
	bra.s   PBF_loc_20C922
PBF_loc_20C920:
	moveq   #$c, d0
PBF_loc_20C922:
	lea     PBF_dat_20C930(pc, d0.w), a3
	move.w  (a3)+, $34(a0)
	move.w  (a3), $30(a0)
	rts     
PBF_sub_20C85E:
	lea     PBF_dat_20C886(pc), a3
	lea     $FFFFFB20.w, a4
	movem.l (a3)+, d0-d3
	movem.l d0-d3, (a4)
	movem.l d0-d3, -$80(a4)
	movem.l (a3)+, d0-d3
	movem.l d0-d3, $10(a4)
	movem.l d0-d3, -$70(a4)
	rts     
PBF_sub_20CA8E:
	lea     PBF_loc_20CABA.l, a2
PBF_loc_20CA94:
	move.w  (a2)+, d2
	bmi.w   PBF_loc_20CAB8
	move.w  (a2)+, d3
	move.w  (a2)+, d4
	sub.w   oX(a0), d2
	bgt.s   PBF_loc_20CAA6
	neg.w   d2
PBF_loc_20CAA6:
	cmpi.w  #$40, d2
	bgt.s   PBF_loc_20CA94
	add.w   d3, oX(a0)
	add.w   d4, oY(a0)
	clr.w   d1
	rts     
PBF_loc_20CAB8:
	rts     
PBF_loc_20CABA:
	dc.w	$0C30,$0000,$0000,$1610,$0000,$FFFE,$1858,$0000
	dc.w	$FFF0,$2220,$0000,$FFFE,$2490,$0000,$FFF0,$2820
	dc.w	$0000,$FFFE,$2A79,$0000,$FFF0,$2C60,$0000,$FFF0
	dc.w	$2E60,$0000,$FFF0,$2FC0,$0000,$0000,$3020,$0000
	dc.w	$FFFE,$3030,$0000,$FFFE,$3E30,$0000,$0000,$3FB0
	dc.w	$0000,$0000,$FFFF
PBF_dat_20C930:
	dc.w	$0200,$0002,$0300,$0002,$0440,$0008,$0600,$0004
PBF_dat_20C886:
	dc.w	$0000,$0000,$0628,$084A,$0E6E,$0EAE,$0EEE,$0AAA
	dc.w	$0888,$0444,$08AE,$006C,$00C2,$0080,$0806,$000E
