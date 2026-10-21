; Object $70 - ObjTunnelPath (from R61A, old ID $07)
ObjTunnelPath:
	btst.b  #$7, timeZone.l
	beq.s   P70_loc_20906A
	moveq   #$0, d0
	move.b  oSavedFlagsID(a0), d0
	beq.s   P70_loc_20906A
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
	bpl.s   P70_loc_20905A
	moveq   #$0, d1
	bra.s   P70_loc_209062
P70_loc_20905A:
	cmpi.w  #$3, d1
	bcs.s   P70_loc_209062
	moveq   #$2, d1
P70_loc_209062:
	add.w   d1, d0
	bclr.b  #$7, $2(a1, d0.w)
P70_loc_20906A:
	lea     objects.w, a6
	cmpi.b  #$2b, $1c(a6)
	beq.s   P70_loc_20909A
	cmpi.b  #$6, $24(a6)
	bcc.s   P70_loc_20909A
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P70_dat_20909C(pc, d0.w), d1
	jsr     P70_dat_20909C(pc, d1.w)
	cmpi.b  #$4, oRoutine(a0)
	bcc.s   P70_loc_20909A
	jmp     CheckObjDespawn.l
P70_loc_20909A:
	rts     
P70_dat_20909C:
	dc.w	ObjTunnelPath_Init-P70_dat_20909C
	dc.w	P70_loc_2090EE-P70_dat_20909C
	dc.w	P70_loc_2091B4-P70_dat_20909C
	dc.w	P70_loc_2091CE-P70_dat_20909C
ObjTunnelPath_Init:
	move.l  #$239c34, oMap(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$10, oWidth(a0)
	move.w  #$541, oTile(a0)
	addq.b  #$2, oRoutine(a0)
	move.b  oSubtype(a0), d0
	andi.b  #$7f, d0
	add.w   d0, d0
	andi.w  #$fe, d0
	lea     ObjTunnelPath_Paths(pc), a2
	adda.w  (a2, d0.w), a2
	move.w  (a2)+, $3a(a0)
	move.l  a2, $3c(a0)
	move.w  (a2)+, $36(a0)
	move.w  (a2)+, $38(a0)
P70_loc_2090EE:
	cmpi.b  #$6, $24(a6)
	bcc.w   P70_loc_2091B2
	move.w  $8(a6), d0
	sub.w   oX(a0), d0
	addi.w  #$20, d0
	cmpi.w  #$40, d0
	bcc.w   P70_loc_2091B2
	move.w  $c(a6), d1
	sub.w   oY(a0), d1
	addi.w  #$30, d1
	cmpi.w  #$60, d1
	bcc.w   P70_loc_2091B2
	tst.b   $2c(a6)
	bne.w   P70_loc_2091B2
	cmpi.b  #$4, $24(a6)
	bne.s   P70_loc_20913A
	subq.b  #$2, $24(a6)
	move.w  #$78, $30(a6)
P70_loc_20913A:
	addq.b  #$2, oRoutine(a0)
	move.b  #$81, $2c(a6)
	tst.b   oLayer(a0)
	beq.s   P70_loc_209150
	bset.b  #$6, $2c(a6)
P70_loc_209150:
	move.b  #$2, $1c(a6)
	move.w  #$800, $14(a6)
	bclr.b  #$6, $1(a6)
	tst.b   oSubtype(a0)
	bpl.s   P70_loc_20916E
	bset.b  #$6, $1(a6)
P70_loc_20916E:
	cmpi.b  #$4, $24(a6)
	bne.s   P70_loc_20917A
	subq.b  #$2, $24(a6)
P70_loc_20917A:
	move.w  #$0, $10(a6)
	move.w  #$0, $12(a6)
	bclr.b  #$5, oFlags(a0)
	bclr.b  #$5, $22(a6)
	bset.b  #$1, $22(a6)
	move.w  oX(a0), $8(a6)
	move.w  oY(a0), $c(a6)
	clr.b   $32(a0)
	move.w  #$91, d0
	jsr     PlayFMSound.l
P70_loc_2091B2:
	rts     
P70_loc_2091B4:
	move.b  #$2, $1c(a6)
	bsr.w   ObjTunnelPath_SetPlayerSpeed
	addq.b  #$2, oRoutine(a0)
	move.w  #$91, d0
	jsr     PlayFMSound.l
	rts     
P70_loc_2091CE:
	move.b  #$2, $1c(a6)
	addq.l  #$4, a7
	subq.b  #$1, $2e(a0)
	bpl.s   P70_loc_20921E
	move.w  $36(a0), d0
	add.w   oX(a0), d0
	move.w  d0, $8(a6)
	move.w  $38(a0), d0
	add.w   oY(a0), d0
	move.w  d0, $c(a6)
	moveq   #$0, d1
	move.b  $3a(a0), d1
	addq.b  #$6, d1
	cmp.b   $3b(a0), d1
	bcs.s   P70_loc_209206
	moveq   #$0, d1
	bra.s   P70_loc_209274
P70_loc_209206:
	move.b  d1, $3a(a0)
P70_loc_20920A:
	movea.l $3c(a0), a2
	move.w  (a2, d1.w), $36(a0)
	move.w  $2(a2, d1.w), $38(a0)
	bra.w   ObjTunnelPath_SetPlayerSpeed
P70_loc_20921E:
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
	moveq   #$0, d1
	move.b  $3a(a0), d1
	movea.l $3c(a0), a2
	move.w  $4(a2, d1.w), d1
	bmi.s   P70_loc_209254
P70_loc_209252:
	rts     
P70_loc_209254:
	move.b  p1CtrlData.w, d0
	andi.b  #$70, d0
	beq.s   P70_loc_209252
	andi.w  #$7fff, d1
	add.b   d1, d1
	move.b  d1, d0
	add.b   d0, d0
	add.b   d0, d1
	add.b   $3b(a0), d1
	move.b  d1, $3a(a0)
	bra.s   P70_loc_20920A
P70_loc_209274:
	andi.w  #$7ff, $c(a6)
	clr.b   oRoutine(a0)
	clr.b   $2c(a6)
	move.w  #$2, oRoutine(a0)
	rts     
ObjTunnelPath_Paths:
	dc.w	$0026,$0082,$00A2,$014C,$0178,$01DA,$0218,$0226
	dc.w	$023A,$0254,$026E,$0288,$0296,$02B0,$02D0,$02DE
	dc.w	$032E,$035A,$038C,$004E,$0000,$0000,$0000,$0008
	dc.w	$0020,$0000,$0000,$0048,$0000,$FFE8,$0060,$0000
	dc.w	$FFB8,$0070,$0000,$FF88,$0060,$0000,$FF70,$0048
	dc.w	$0000,$FF68,$0020,$0000,$FF70,$0000,$0000,$FF88
	dc.w	$FFE0,$8001,$FFB8,$FFD0,$0000,$FFE8,$FFE0,$8000
	dc.w	$0000,$0000,$8000,$0050,$FFE0,$0000,$FF88,$FF98
	dc.w	$0000,$0018,$0000,$0000,$0000,$0030,$FFF0,$0000
	dc.w	$0060,$0000,$8000,$0078,$0020,$8000,$00C8,$0000
	dc.w	$0000,$0096,$0000,$0000,$0000,$0008,$0020,$0000
	dc.w	$0000,$0040,$0000,$FFE8,$0060,$0000,$FFB8,$0070
	dc.w	$0000,$FF88,$0080,$0000,$FF70,$00A0,$0000,$FF68
	dc.w	$00C0,$0000,$FF70,$00E0,$8002,$FF88,$0100,$8002
	dc.w	$FFB8,$0110,$0000,$FFE8,$0100,$0000,$0000,$00E0
	dc.w	$0000,$0008,$00C0,$0000,$0000,$00A0,$0000,$FFE8
	dc.w	$0080,$0000,$FFB8,$0070,$0000,$FF88,$0060,$0000
	dc.w	$FF70,$0040,$0000,$FF68,$0020,$0000,$FF70,$0000
	dc.w	$8001,$FF88,$FFE0,$8001,$FFB8,$FFD0,$0000,$FFE8
	dc.w	$FFE0,$8000,$0000,$0000,$8000,$0040,$FFE0,$0000
	dc.w	$FF28,$FFE0,$0000,$FF48,$00F0,$0000,$001E,$0000
	dc.w	$0000,$8001,$0018,$FFE0,$8001,$0048,$FFD0,$0000
	dc.w	$0078,$FFE0,$8000,$0090,$0000,$8000,$00D0,$FFE0
	dc.w	$0000,$FFB8,$FFE0,$0000,$004E,$0000,$0000,$8002
	dc.w	$0018,$0020,$8002,$0048,$0030,$0000,$0078,$0020
	dc.w	$0000,$0090,$0000,$0000,$0098,$FFE0,$0000,$0090
	dc.w	$FFC0,$0000,$0078,$FFA0,$0000,$0048,$FF90,$0000
	dc.w	$0018,$FF80,$0000,$0000,$FF60,$0000,$FFF8,$FF40
	dc.w	$0000,$0000,$FF20,$8001,$00D0,$FF00,$0000,$FFB8
	dc.w	$FF00,$0000,$FFD8,$0010,$0000,$003C,$0000,$0000
	dc.w	$0000,$0000,$0150,$0000,$FF98,$0150,$0000,$FF98
	dc.w	$0200,$0000,$FFF8,$0200,$0000,$FFC8,$0200,$0000
	dc.w	$FFC8,$0328,$0000,$0218,$0328,$0000,$0218,$0370
	dc.w	$0000,$03C0,$0370,$0000,$000C,$0000,$0000,$0000
	dc.w	$0038,$0000,$0000,$0012,$0000,$0000,$0000,$0000
	dc.w	$02A8,$0000,$0050,$02A8,$0000,$0018,$0000,$0000
	dc.w	$0000,$0008,$0000,$0000,$0008,$FF00,$0000,$0038
	dc.w	$FF00,$0000,$0018,$0000,$0000,$0000,$0008,$0000
	dc.w	$0000,$0008,$0100,$0000,$0038,$0100,$0000,$0018
	dc.w	$0000,$0000,$0000,$0008,$0000,$0000,$0008,$FF00
	dc.w	$0000,$0038,$FF00,$0000,$000C,$0000,$0000,$0000
	dc.w	$0060,$0000,$0000,$0018,$0000,$0000,$0000,$01B0
	dc.w	$0000,$0000,$01B0,$0100,$0000,$03E0,$0100,$0000
	dc.w	$001E,$0000,$0000,$0000,$0000,$02A8,$0000,$03C0
	dc.w	$02A8,$0000,$03C0,$01A8,$0000,$0190,$01A8,$0000
	dc.w	$000C,$0000,$0000,$0000,$0160,$0000,$0000,$004E
	dc.w	$0000,$0000,$0000,$0000,$02B8,$0000,$FF88,$02B8
	dc.w	$0000,$FF88,$0368,$0000,$FFE8,$0368,$0000,$FFB8
	dc.w	$03B8,$0000,$FF58,$03B8,$0000,$FFB8,$03B8,$0000
	dc.w	$FFB8,$03F8,$0000,$0018,$03F8,$0000,$0018,$0458
	dc.w	$0000,$FFC8,$0458,$0000,$FFC8,$04E0,$0000,$002A
	dc.w	$0000,$0000,$0000,$0000,$02A8,$0000,$FF88,$02A8
	dc.w	$0000,$FF88,$0358,$0000,$FFE8,$0358,$0000,$FFB8
	dc.w	$0358,$0000,$FFB8,$04D0,$0000,$0030,$0000,$0000
	dc.w	$0000,$0000,$0208,$0000,$FF88,$0208,$0000,$FF88
	dc.w	$02B8,$0000,$FFE8,$02B8,$0000,$FFC8,$02B8,$0000
	dc.w	$FFC8,$0318,$0000,$0250,$0318,$0000,$000C,$0000
	dc.w	$0000,$0000,$0128,$0000,$0000
ObjTunnelPath_SetPlayerSpeed:
	moveq   #$0, d0
	move.w  $14(a6), d2
	move.w  $14(a6), d3
	move.w  $36(a0), d0
	add.w   oX(a0), d0
	sub.w   $8(a6), d0
	bge.s   P70_loc_2092A6
	neg.w   d0
	neg.w   d2
P70_loc_2092A6:
	moveq   #$0, d1
	move.w  $38(a0), d1
	add.w   oY(a0), d1
	sub.w   $c(a6), d1
	bge.s   P70_loc_2092BA
	neg.w   d1
	neg.w   d3
P70_loc_2092BA:
	cmp.w   d0, d1
	bcs.s   P70_loc_2092F8
	moveq   #$0, d1
	move.w  $38(a0), d1
	add.w   oY(a0), d1
	sub.w   $c(a6), d1
	swap    d1
	divs.w  d3, d1
	moveq   #$0, d0
	move.w  $36(a0), d0
	add.w   oX(a0), d0
	sub.w   $8(a6), d0
	beq.s   P70_loc_2092E4
	swap    d0
	divs.w  d1, d0
P70_loc_2092E4:
	move.w  d0, $10(a6)
	move.w  d3, $12(a6)
	tst.w   d1
	bpl.s   P70_loc_2092F2
	neg.w   d1
P70_loc_2092F2:
	move.w  d1, $2e(a0)
	rts     
P70_loc_2092F8:
	moveq   #$0, d0
	move.w  $36(a0), d0
	add.w   oX(a0), d0
	sub.w   $8(a6), d0
	swap    d0
	divs.w  d2, d0
	moveq   #$0, d1
	move.w  $38(a0), d1
	add.w   oY(a0), d1
	sub.w   $c(a6), d1
	beq.s   P70_loc_20931E
	swap    d1
	divs.w  d0, d1
P70_loc_20931E:
	move.w  d1, $12(a6)
	move.w  d2, $10(a6)
	tst.w   d0
	bpl.s   P70_loc_20932C
	neg.w   d0
P70_loc_20932C:
	move.w  d0, $2e(a0)
	rts     
