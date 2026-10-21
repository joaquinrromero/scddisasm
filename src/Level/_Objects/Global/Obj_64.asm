; Object $64 - Obj33_20EB28 (from R41A, old ID $33)
P64_Obj33_20EB28:
	tst.b   oSubtype(a0)
	bmi.s   P64_loc_20EB3A
	tst.b   oRoutine(a0)
	bne.s   P64_loc_20EB36
	bsr.s   P64_sub_20EB3E
P64_loc_20EB36:
	bra.w   P64_loc_20EC36
P64_loc_20EB3A:
	bra.w   P64_loc_20EC9E
P64_sub_20EB3E:
	addq.b  #$2, oRoutine(a0)
	move.w  oX(a0), $30(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  #$446a, oTile(a0)
	move.l  #$20ecbe, oMap(a0)
	move.b  #$4, oMapFrame(a0)
	move.w  a0, $32(a0)
	move.w  #$c0, $2a(a0)
	move.l  #$ffff8000, $2c(a0)
	lea     $38(a0), a6
	lea     P64_dat_20ED00(pc), a5
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	addq.w  #$1, d0
	asl.w   #$3, d0
	adda.w  d0, a5
	moveq   #$3, d6
	moveq   #$1, d5
P64_loc_20EBA4:
	move.w  d5, d4
P64_loc_20EBA6:
	jsr     FindNextObjSlot.l
	beq.s   P64_loc_20EBB4
	jmp     DeleteObject.l
P64_loc_20EBB4:
	move.w  a1, d0
	asr.w   #$6, d0
	move.b  d0, (a6)+
	move.w  d4, d0
	subq.b  #$2, d0
	move.b  d0, $28(a1)
	move.w  oY(a0), d2
	subi.w  #$30, d2
	move.w  d6, d0
	asl.w   #$5, d0
	add.w   d0, d2
	move.w  d2, $c(a1)
	moveq   #$0, d3
	move.b  -(a5), d3
	move.b  d3, $1a(a1)
	move.w  d3, d0
	addq.w  #$1, d0
	asl.w   #$4, d0
	move.b  d0, $17(a1)
	move.b  d0, $19(a1)
	move.w  oX(a0), d2
	move.w  #$40, d1
	move.w  d3, d0
	asl.b   #$4, d0
	tst.w   d4
	bne.s   P64_loc_20EBFE
	neg.w   d1
	neg.w   d0
P64_loc_20EBFE:
	add.w   d1, d2
	sub.w   d0, d2
	move.w  d2, $8(a1)
	move.w  a0, $32(a1)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  oSprFlags(a0), $1(a1)
	move.b  oPriority(a0), $18(a1)
	move.b  oYRadius(a0), $16(a1)
	move.w  oTile(a0), $2(a1)
	move.l  oMap(a0), $4(a1)
	dbra    d4, P64_loc_20EBA6
	dbra    d6, P64_loc_20EBA4
P64_loc_20EC36:
	lea     $38(a0), a6
	moveq   #$3, d6
	move.l  $2c(a0), d5
	moveq   #$6, d4
P64_loc_20EC42:
	moveq   #$ff, d0
	move.b  (a6)+, d0
	lsl.w   d4, d0
	movea.w d0, a1
	sub.l   d5, $8(a1)
	move.l  d5, d0
	asr.l   #$8, d0
	neg.w   d0
	move.w  d0, $10(a1)
	moveq   #$ff, d0
	move.b  (a6)+, d0
	lsl.w   d4, d0
	movea.w d0, a1
	add.l   d5, $8(a1)
	move.l  d5, d0
	asr.l   #$8, d0
	move.w  d0, $10(a1)
	dbra    d6, P64_loc_20EC42
	addi.w  #$ffff, $2a(a0)
	bne.s   P64_loc_20EC94
	lea     P64_dat_20ED48(pc), a1
	adda.w  $34(a0), a1
	move.l  (a1)+, d0
	move.w  d0, $2a(a0)
	move.l  (a1)+, $2c(a0)
	addq.w  #$8, $34(a0)
	andi.w  #$1f, $34(a0)
P64_loc_20EC94:
	move.w  $30(a0), d0
	jmp     CheckObjDespawn2.l
P64_loc_20EC9E:
	movea.w $32(a0), a6
	dc.b	$0C,$2E,$00,$33,$00,$00		; cmpi.b #$33, $0(a6) (raw: not reproducible by assembler)
	beq.s   P64_loc_20ECB0
	jmp     DeleteObject.l
P64_loc_20ECB0:
	lea     objects.w, a1
	bsr.w   SolidObject
	jmp     DrawObject.l
P64_loc_20ECBE:
	dc.w	$000A,$0010,$001B,$002B,$0040,$01F0,$0F00,$00F0
	dc.w	$02F0,$0F00,$00E0,$F00F,$0000,$0003,$F00F,$0000
	dc.w	$D0F0,$0F00,$00F0,$F00F,$0000,$1004,$F00F,$0000
	dc.w	$C0F0,$0F00,$00E0,$F00F,$0000,$00F0,$0F00,$0020
	dc.w	$0000
P64_dat_20ED00:
	dc.w	$0201,$0102,$0201,$0102,$0003,$0102,$0201,$0300
	dc.w	$0300,$0003,$0300,$0003,$0102,$0000,$0000,$0201
	dc.w	$0201,$0102,$0102,$0201,$0003,$0200,$0200,$0003
	dc.w	$0300,$0000,$0000,$0003,$0201,$0102,$0300,$0003
	dc.w	$0102,$0101,$0101,$0201
P64_dat_20ED48:
	dc.w	$0000,$003C,$0000,$0000,$0000,$0030,$0002,$0000
	dc.w	$0000,$003C,$0000,$0000,$0000,$00C0,$FFFF,$8000
