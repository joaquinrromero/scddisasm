; Object $8B - ObjProjector (from R61A, old ID $2B)
ObjProjector:
	tst.b   oSubtype(a0)
	bne.w   P8B_loc_20F0B8
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjProjector_Index(pc, d0.w), d0
	jsr     ObjProjector_Index(pc, d0.w)
	jsr     DrawObject.l
	cmpi.b  #$2, oRoutine(a0)
	bgt.s   P8B_loc_20EF18
	jmp     CheckObjDespawn.l
P8B_loc_20EF18:
	rts     
ObjProjector_Index:
	dc.w	P8B_loc_20EF24-ObjProjector_Index
	dc.w	P8B_loc_20EF72-ObjProjector_Index
	dc.w	P8B_loc_20EF9E-ObjProjector_Index
	dc.w	P8B_loc_20F002-ObjProjector_Index
	dc.w	P8B_loc_20F00E-ObjProjector_Index
P8B_loc_20EF24:
	tst.b   goodFuture.l
	beq.s   P8B_loc_20EF34
	addq.l  #$4, a7
	jmp     DeleteObject.l
P8B_loc_20EF34:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$14, oXRadius(a0)
	move.b  #$14, oWidth(a0)
	move.b  #$1c, oYRadius(a0)
	move.w  #$44e8, oTile(a0)
	move.l  #$20f066, oMap(a0)
	move.b  #$f8, oColType(a0)
	move.l  #$20f086, $2c(a0)
P8B_loc_20EF72:
	tst.b   oColStatus(a0)
	beq.s   P8B_loc_20EF94
	clr.w   oColType(a0)
	addq.b  #$2, oRoutine(a0)
	lea     objects.w, a1
	jsr     SolidObject.l
	beq.s   P8B_loc_20EF92
	jsr     GetOffObject.l
P8B_loc_20EF92:
	rts     
P8B_loc_20EF94:
	lea     objects.w, a1
	jmp     SolidObject.l
P8B_loc_20EF9E:
	movea.l $2c(a0), a6
	move.b  (a6)+, d0
	bmi.s   P8B_loc_20EFF0
	addq.b  #$1, $3f(a0)
	cmp.b   $3f(a0), d0
	bne.s   P8B_loc_20EFEE
	move.b  (a6)+, d5
	move.b  (a6)+, d6
	move.l  a6, $2c(a0)
	ext.w   d5
	ext.w   d6
	jsr     FindObjSlot.l
	bne.s   P8B_loc_20EFEE
	dc.b	$13,$7C,$00,$18,$00,$00		; move.b #$18, $0(a1) (raw: not reproducible by assembler)
	move.b  #$1, $25(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	add.w   d5, $8(a1)
	add.w   d6, $c(a1)
	move.w  #$9e, d0
	jsr     PlayFMSound.l
P8B_loc_20EFEE:
	rts     
P8B_loc_20EFF0:
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, oMapFrame(a0)
	move.b  #$3c, $3f(a0)
	rts     
P8B_loc_20F002:
	subq.b  #$1, $3f(a0)
	bne.s   P8B_loc_20F00C
	addq.b  #$2, oRoutine(a0)
P8B_loc_20F00C:
	rts     
P8B_loc_20F00E:
	lea     P8B_dat_20F0A2(pc), a6
	move.b  oID(a0), d1
	moveq   #$ff, d2
	move.w  oX(a0), d3
	move.w  oY(a0), d4
P8B_loc_20F020:
	move.b  (a6)+, d5
	cmpi.b  #$ff, d5
	beq.s   P8B_loc_20F060
	move.b  (a6)+, d6
	ext.w   d5
	ext.w   d6
	jsr     FindObjSlot.l
	bne.s   P8B_loc_20F060
	dc.b	$13,$41,$00,$00		; move.b d1, $0(a1) (raw: not reproducible by assembler)
	move.b  d2, $28(a1)
	move.w  d3, $8(a1)
	move.w  d4, $c(a1)
	subi.w  #$a0, $c(a1)
	add.w   d5, $8(a1)
	add.w   d6, $c(a1)
	move.w  d4, $2e(a1)
	addi.w  #$26, $2e(a1)
	bra.s   P8B_loc_20F020
P8B_loc_20F060:
	jmp     DeleteObject.l
P8B_loc_20F066:
	dc.w	$0004,$001E,$05E4,$0400,$00F4,$E400,$0002,$0CEC
	dc.w	$0F00,$03EC,$EC03,$0013,$0C0C,$0900,$17F4,$0000
P8B_loc_20F086:
	dc.w	$0100,$0005,$EEF6,$0AF6,$0A0F,$00F6,$14F6,$F619
	dc.w	$0DF6,$1EF6,$1423,$0DF6,$28F6,$0AFF
P8B_dat_20F0A2:
	dc.w	$E8C0,$F840,$0800,$1880,$2880,$3840,$4840,$5880
	dc.w	$6840,$78C0,$FF00
P8B_loc_20F0B8:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P8B_dat_20F0CC(pc, d0.w), d0
	jsr     P8B_dat_20F0CC(pc, d0.w)
	jmp     DrawObject.l
P8B_dat_20F0CC:
	dc.w	P8B_loc_20F0D2-P8B_dat_20F0CC
	dc.w	P8B_loc_20F110-P8B_dat_20F0CC
	dc.w	P8B_loc_20F138-P8B_dat_20F0CC
P8B_loc_20F0D2:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$6, oYRadius(a0)
	move.b  #$6, oXRadius(a0)
	move.b  #$6, oWidth(a0)
	move.w  #$4c8, oTile(a0)
	move.l  #$20f15a, oMap(a0)
	move.b  #$b7, oColType(a0)
	move.l  #$0, $2a(a0)
P8B_loc_20F110:
	move.l  $2a(a0), d0
	add.l   d0, oY(a0)
	addi.l  #$400, $2a(a0)
	move.w  oY(a0), d0
	cmp.w   $2e(a0), d0
	blt.s   P8B_loc_20F12E
	addq.b  #$2, oRoutine(a0)
P8B_loc_20F12E:
	lea     P8B_dat_20F154(pc), a1
	jmp     AnimateObject.l
P8B_loc_20F138:
	move.b  #$18, oID(a0)
	move.b  #$0, oRoutine(a0)
	move.b  #$1, oSolidType(a0)
	move.w  #$9e, d0
	jmp     PlayFMSound.l
P8B_dat_20F154:
	dc.w	$0002,$0100,$01FF
P8B_loc_20F15A:
	dc.w	$0004,$000A,$01F8,$0500,$00F8,$01F8,$0500,$04F8
