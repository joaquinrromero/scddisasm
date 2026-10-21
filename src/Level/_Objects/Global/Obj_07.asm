; Object $07 - ObjTunnelPath (from R11A, old ID $07)
ObjTunnelPath:
	btst.b  #$7, timeZone.l
	beq.s   P07_loc_208B3E
	moveq   #$0, d0
	move.b  oSavedFlagsID(a0), d0
	beq.s   P07_loc_208B3E
	lea     savedObjFlags.l, a1
	move.w  d0, d1
	add.w   d1, d1
	add.w   d1, d0
	moveq   #$0, d1
	move.b  timeZone.l, d1
	bclr.l  #$7, d1
	move.b  timeWarpDir.w, d2
	ext.w   d2
	neg.w   d2
	add.w   d2, d1
	bpl.s   P07_loc_208B2E
	moveq   #$0, d1
	bra.s   P07_loc_208B36
P07_loc_208B2E:
	cmpi.w  #$3, d1
	bcs.s   P07_loc_208B36
	moveq   #$2, d1
P07_loc_208B36:
	add.w   d1, d0
	bclr.b  #$7, $2(a1, d0.w)
P07_loc_208B3E:
	lea     objects.w, a6
	cmpi.b  #$2b, $1c(a6)
	beq.s   P07_loc_208B6E
	cmpi.b  #$6, $24(a6)
	bcc.s   P07_loc_208B6E
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P07_dat_208B70(pc, d0.w), d1
	jsr     P07_dat_208B70(pc, d1.w)
	cmpi.b  #$4, oRoutine(a0)
	bcc.s   P07_loc_208B6E
	jmp     CheckObjDespawn.l
P07_loc_208B6E:
	rts     
P07_dat_208B70:
	dc.w	ObjTunnelPath_Init-P07_dat_208B70
	dc.w	ObjTunnelPath_Main-P07_dat_208B70
	dc.w	ObjTunnelPath_GotPlayer-P07_dat_208B70
	dc.w	ObjTunnelPath_MovePlayer-P07_dat_208B70
ObjTunnelPath_Init:
	move.l  #$23ee9c, oMap(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$10, oWidth(a0)
	move.w  #$541, oTile(a0)
	addq.b  #$2, oRoutine(a0)
	move.b  oSubtype(a0), d0
	add.w   d0, d0
	andi.w  #$fe, d0
	lea     ObjTunnelPath_Paths(pc), a2
	adda.w  (a2, d0.w), a2
	move.w  (a2)+, $3a(a0)
	move.l  a2, $3c(a0)
	move.w  (a2)+, $36(a0)
	move.w  (a2)+, $38(a0)
ObjTunnelPath_Main:
	move.w  $8(a6), d0
	sub.w   oX(a0), d0
	addi.w  #$10, d0
	cmpi.w  #$20, d0
	bcc.w   P07_loc_208C5C
	move.w  $c(a6), d1
	sub.w   oY(a0), d1
	addi.w  #$10, d1
	cmpi.w  #$20, d1
	bcc.w   P07_loc_208C5C
	tst.b   $2c(a6)
	bne.w   P07_loc_208C5C
	cmpi.b  #$4, $24(a6)
	bne.s   P07_loc_208C00
	subq.b  #$2, $24(a6)
	move.w  #$78, $30(a6)
P07_loc_208C00:
	addq.b  #$2, oRoutine(a0)
	move.b  #$81, $2c(a6)
	tst.b   oLayer(a0)
	beq.s   P07_loc_208C16
	ori.b   #$40, $2c(a6)
P07_loc_208C16:
	move.b  #$2, $1c(a6)
	bsr.w   ObjTunnelPath_SetPlayerGVel
	move.w  #$0, $10(a6)
	move.w  #$0, $12(a6)
	bclr.b  #$5, oFlags(a0)
	bclr.b  #$5, $22(a6)
	bset.b  #$1, $22(a6)
	clr.b   $3c(a6)
	move.w  oX(a0), $8(a6)
	move.w  oY(a0), $c(a6)
	clr.b   $32(a0)
	move.w  #$91, d0
	jsr     PlayFMSound.l
P07_loc_208C5C:
	rts     
ObjTunnelPath_GotPlayer:
	bsr.w   ObjTunnelPath_SetPlayerSpeed
	addq.b  #$2, oRoutine(a0)
	move.w  #$91, d0
	jsr     PlayFMSound.l
	rts     
ObjTunnelPath_MovePlayer:
	subq.b  #$1, $2e(a0)
	bpl.s   P07_loc_208CAE
	move.w  $36(a0), $8(a6)
	move.w  $38(a0), $c(a6)
	moveq   #$0, d1
	move.b  $3a(a0), d1
	addq.b  #$4, d1
	cmp.b   $3b(a0), d1
	bcs.s   P07_loc_208C96
	moveq   #$0, d1
	bra.s   P07_loc_208CD4
P07_loc_208C96:
	move.b  d1, $3a(a0)
	movea.l $3c(a0), a2
	move.w  (a2, d1.w), $36(a0)
	move.w  $2(a2, d1.w), $38(a0)
	bra.w   ObjTunnelPath_SetPlayerSpeed
P07_loc_208CAE:
	move.l  $8(a6), d2
	move.l  $c(a6), d3
	move.w  $10(a6), d0
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, d2
	move.w  $12(a6), d0
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, d3
	move.l  d2, $8(a6)
	move.l  d3, $c(a6)
	rts     
P07_loc_208CD4:
	andi.w  #$7ff, $c(a6)
	clr.b   oRoutine(a0)
	clr.b   $2c(a6)
	move.w  #$2, oRoutine(a0)
	rts     
ObjTunnelPath_Paths:
	dc.w	$0006,$0090,$00D6
	dc.w	$0088,$1440,$00F0,$1478,$0108,$1490,$0140,$1490
	dc.w	$01E0,$1440,$01F8,$1400,$01E0,$13F0,$01C0,$13F0
	dc.w	$0180,$1400,$0170,$1420,$0168,$1440,$0170,$1468
	dc.w	$01A8,$1660,$0218,$16A0,$0210,$16C0,$01F8,$16D0
	dc.w	$01C8,$16C0,$01A8,$1680,$0198,$1658,$01A0,$1640
	dc.w	$01C8,$1650,$01F0,$1680,$0200,$16C0,$0200,$16D0
	dc.w	$0210,$16D0,$0288,$16C0,$02C0,$1680,$02D8,$1650
	dc.w	$02C0,$1650,$02A0,$1680,$0290,$1700,$0290,$1728
	dc.w	$02A0,$1728,$02E0,$1700,$02F0
	dc.w	$0044,$0F08,$01A0,$0F90,$01A0,$0FC8,$01B8,$0FE0
	dc.w	$01F0,$0FE0,$0260,$1000,$0290,$1030,$02A0,$1068
	dc.w	$0288,$1080,$0250,$1068,$0218,$1030,$0200,$0FF0
	dc.w	$0220,$0FE0,$0260,$1000,$0290,$1030,$02A0,$1068
	dc.w	$0288,$1130,$01C8
	dc.w	$0044,$1630,$0290,$1630,$0318,$1638,$0338,$16D0
	dc.w	$03D0,$1700,$03E0,$1738,$03C8,$1758,$0390,$1738
	dc.w	$0358,$16F8,$0340,$16C0,$0360,$16A8,$0390,$16D0
	dc.w	$03D0,$1700,$03E0,$1738,$03C8,$17B8,$0348,$17D0
	dc.w	$0320,$17D0,$0268
ObjTunnelPath_SetPlayerGVel:
	move.w  #$1000, $14(a6)
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	bmi.s   P07_loc_208D9C
	andi.w  #$f, d0
	add.w   d0, d0
	move.w  ObjTunnelPath_GVels(pc, d0.w), d0
	cmp.w   $14(a6), d0
	ble.s   P07_loc_208D9C
	move.w  d0, $14(a6)
P07_loc_208D9C:
	rts     
ObjTunnelPath_SetPlayerSpeed:
	moveq   #$0, d0
	move.w  $14(a6), d2
	move.w  $14(a6), d3
	move.w  $36(a0), d0
	sub.w   $8(a6), d0
	bge.s   P07_loc_208D02
	neg.w   d0
	neg.w   d2
P07_loc_208D02:
	moveq   #$0, d1
	move.w  $38(a0), d1
	sub.w   $c(a6), d1
	bge.s   P07_loc_208D12
	neg.w   d1
	neg.w   d3
P07_loc_208D12:
	cmp.w   d0, d1
	bcs.s   P07_loc_208D48
	moveq   #$0, d1
	move.w  $38(a0), d1
	sub.w   $c(a6), d1
	swap    d1
	divs.w  d3, d1
	moveq   #$0, d0
	move.w  $36(a0), d0
	sub.w   $8(a6), d0
	beq.s   P07_loc_208D34
	swap    d0
	divs.w  d1, d0
P07_loc_208D34:
	move.w  d0, $10(a6)
	move.w  d3, $12(a6)
	tst.w   d1
	bpl.s   P07_loc_208D42
	neg.w   d1
P07_loc_208D42:
	move.w  d1, $2e(a0)
	rts     
P07_loc_208D48:
	moveq   #$0, d0
	move.w  $36(a0), d0
	sub.w   $8(a6), d0
	swap    d0
	divs.w  d2, d0
	moveq   #$0, d1
	move.w  $38(a0), d1
	sub.w   $c(a6), d1
	beq.s   P07_loc_208D66
	swap    d1
	divs.w  d0, d1
P07_loc_208D66:
	move.w  d1, $12(a6)
	move.w  d2, $10(a6)
	tst.w   d0
	bpl.s   P07_loc_208D74
	neg.w   d0
P07_loc_208D74:
	move.w  d0, $2e(a0)
	rts     
ObjTunnelPath_GVels:
	dc.w	$1000,$0C00,$0C00,$0800
