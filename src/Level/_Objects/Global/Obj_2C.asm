; Object $2C - Obj3DPlant (from R11A, old ID $2C)
Obj3DPlant:
	lea     objects.w, a6
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  Obj3DPlant_Index(pc, d0.w), d0
	jsr     Obj3DPlant_Index(pc, d0.w)
	jsr     DrawObject.l
	move.w  $2a(a0), d0
	bra.w   CheckObjDespawn2
Obj3DPlant_Index:
	dc.w	Obj3DPlant_Init-Obj3DPlant_Index
	dc.w	Obj3DPlant_Main-Obj3DPlant_Index
Obj3DPlant_Init:
	ori.b   #$4, oSprFlags(a0)
	move.l  #$20e02e, oMap(a0)
	move.w  #$4424, oTile(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$14, oYRadius(a0)
	move.w  oX(a0), d3
	movea.l a0, a1
	moveq   #$3, d6
	bclr.b  #$0, oSubtype(a0)
	beq.s   P2C_loc_20DD20
	moveq   #$1, d6
P2C_loc_20DD20:
	moveq   #$0, d2
	bra.s   P2C_loc_20DD2A
P2C_loc_20DD24:
	jsr     FindObjSlot.l
P2C_loc_20DD2A:
	addq.b  #$2, $24(a1)
	dc.b	$13,$7C,$00,$2C,$00,$00		; move.b #$2c, $0(a1) (raw: not reproducible by assembler)
	move.w  d3, $8(a1)
	move.w  oY(a0), $c(a1)
	move.w  d3, $2a(a1)
	move.l  oMap(a0), $4(a1)
	move.w  oTile(a0), $2(a1)
	move.b  oWidth(a0), $19(a1)
	move.b  oYRadius(a0), $16(a1)
	ori.b   #$4, $1(a1)
	move.w  Obj3DPlant_Offsets1(pc, d2.w), d1
	add.w   d1, $8(a1)
	move.w  $8(a1), $2c(a1)
	addq.b  #$2, d2
	dbra    d6, P2C_loc_20DD24
	moveq   #$2, d6
	moveq   #$0, d2
P2C_loc_20DD78:
	jsr     FindObjSlot.l
	addq.b  #$2, $24(a1)
	dc.b	$13,$7C,$00,$2C,$00,$00		; move.b #$2c, $0(a1) (raw: not reproducible by assembler)
	move.b  #$1, $28(a1)
	move.b  #$1, $1a(a1)
	move.b  #$4, $18(a1)
	move.w  d3, $8(a1)
	move.w  d3, $2a(a1)
	move.w  oY(a0), $c(a1)
	move.l  oMap(a0), $4(a1)
	move.w  oTile(a0), $2(a1)
	move.b  #$c, $19(a1)
	move.b  #$c, $16(a1)
	ori.b   #$4, $1(a1)
	move.w  Obj3DPlant_Offsets2(pc, d2.w), d1
	add.w   d1, $8(a1)
	addq.b  #$2, d2
	dbra    d6, P2C_loc_20DD78
	rts     
Obj3DPlant_Main:
	tst.b   oSubtype(a0)
	bne.s   P2C_loc_20DE34
	moveq   #$0, d0
	btst.b  #$1, $2c(a6)
	beq.s   P2C_loc_20DE2C
	moveq   #$0, d3
	move.w  $8(a6), d0
	move.w  d0, d2
	andi.w  #$ff, d0
	cmp.w   $2a(a0), d2
	bcc.s   P2C_loc_20DE0E
	move.w  d0, d1
	move.w  #$ff, d0
	sub.w   d1, d0
P2C_loc_20DE0E:
	cmpi.w  #$c0, d0
	bcs.s   P2C_loc_20DE22
	cmpi.w  #$f0, d0
	bcc.s   P2C_loc_20DE20
	move.w  #$bf, d0
	bra.s   P2C_loc_20DE22
P2C_loc_20DE20:
	moveq   #$0, d0
P2C_loc_20DE22:
	lsr.w   #$1, d0
	cmp.w   $2a(a0), d2
	bcc.s   P2C_loc_20DE2C
	neg.w   d0
P2C_loc_20DE2C:
	add.w   $2c(a0), d0
	move.w  d0, oX(a0)
P2C_loc_20DE34:
	rts     
Obj3DPlant_Offsets1:
	dc.w	$0040,$0080,$FFC0,$FF80
Obj3DPlant_Offsets2:
	dc.w	$0000,$0060,$FFA0
