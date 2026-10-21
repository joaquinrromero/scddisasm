; Object $7F - Obj32_20E92E (from R41A, old ID $32)
P7F_Obj32_20E92E:
	tst.b   oSubtype(a0)
	bpl.s   P7F_loc_20E938
	bra.w   P7F_loc_20EAF6
P7F_loc_20E938:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	beq.s   P7F_loc_20E946
	tst.b   oSprFlags(a0)
	bpl.s   P7F_loc_20E958
P7F_loc_20E946:
	move.w  P7F_dat_20E964(pc, d0.w), d0
	jsr     P7F_dat_20E964(pc, d0.w)
	lea     objects.w, a1
	jsr     SolidObject.l
P7F_loc_20E958:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P7F_dat_20E964:
	dc.w	P7F_loc_20E972-P7F_dat_20E964
	dc.w	P7F_loc_20EA24-P7F_dat_20E964
	dc.w	P7F_loc_20EA64-P7F_dat_20E964
	dc.w	P7F_loc_20EA92-P7F_dat_20E964
	dc.w	P7F_loc_20EA9E-P7F_dat_20E964
	dc.w	P7F_loc_20EAE0-P7F_dat_20E964
	dc.w	P7F_loc_20EAF4-P7F_dat_20E964
P7F_loc_20E972:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$40, oYRadius(a0)
	move.w  #$3a0, oTile(a0)
	move.l  #$20eb0e, oMap(a0)
	move.l  #$3000, d0
	move.w  oY(a0), d1
	cmp.w   waterHeight2.w, d1
	ble.s   P7F_loc_20E9B8
	move.l  #$1000, d0
P7F_loc_20E9B8:
	move.l  d0, $34(a0)
	jsr     FindNextObjSlot.l
	bne.s   P7F_loc_20EA22
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  #$ff, $28(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	addi.w  #$30, $c(a1)
	move.w  a0, $3e(a1)
	move.w  a1, $3c(a0)
	move.b  #$b0, $20(a1)
	move.b  oSprFlags(a0), $1(a1)
	move.b  oPriority(a0), $18(a1)
	move.b  #$10, $17(a1)
	move.b  #$10, $19(a1)
	move.b  #$10, $16(a1)
	move.w  #$3a0, $2(a1)
	move.l  #$20eb0e, $4(a1)
	move.b  #$1, $1a(a1)
P7F_loc_20EA22:
	rts     
P7F_loc_20EA24:
	lea     objects.w, a6
	bsr.s   P7F_sub_20EA2E
	bcs.s   P7F_loc_20EA52
	rts     
P7F_sub_20EA2E:
	move.w  $c(a6), d0
	sub.w   oY(a0), d0
	subi.w  #$40, d0
	subi.w  #$80, d0
	bcc.s   P7F_loc_20EA50
	move.w  $8(a6), d0
	sub.w   oX(a0), d0
	subi.w  #$fff0, d0
	subi.w  #$20, d0
P7F_loc_20EA50:
	rts     
P7F_loc_20EA52:
	addq.b  #$2, oRoutine(a0)
	move.w  #$100, oYVel(a0)
	move.w  #$14, $32(a0)
	rts     
P7F_loc_20EA64:
	move.l  $2a(a0), d0
	add.l   d0, oY(a0)
	movea.w $3c(a0), a1
	add.l   d0, $c(a1)
	addi.l  #$2000, $2a(a0)
	subq.w  #$1, $32(a0)
	bpl.s   P7F_loc_20EA90
	addq.b  #$2, oRoutine(a0)
	clr.l   $2a(a0)
	move.w  #$1e, $32(a0)
P7F_loc_20EA90:
	rts     
P7F_loc_20EA92:
	subq.w  #$1, $32(a0)
	bpl.s   P7F_loc_20EA9C
	addq.b  #$2, oRoutine(a0)
P7F_loc_20EA9C:
	rts     
P7F_loc_20EA9E:
	move.l  $2a(a0), d0
	add.l   d0, oY(a0)
	movea.w $3c(a0), a1
	add.l   d0, $c(a1)
	move.l  $34(a0), d0
	add.l   d0, $2a(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P7F_loc_20EADE
	addq.b  #$2, oRoutine(a0)
	add.w   d1, oY(a0)
	clr.w   oYVel(a0)
	move.l  #$200000, $2e(a0)
	movea.w $3c(a0), a1
	jmp     loc_203C2C.l
P7F_loc_20EADE:
	rts     
P7F_loc_20EAE0:
	move.l  $2a(a0), d0
	add.l   d0, oY(a0)
	sub.l   d0, $2e(a0)
	bpl.s   P7F_loc_20EAF2
	addq.b  #$2, oRoutine(a0)
P7F_loc_20EAF2:
	rts     
P7F_loc_20EAF4:
	rts     
P7F_loc_20EAF6:
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$32,$00,$00		; cmpi.b #$32, $0(a1) (raw: not reproducible by assembler)
	beq.s   P7F_loc_20EB08
	jmp     DeleteObject.l
P7F_loc_20EB08:
	jmp     DrawObject.l
P7F_loc_20EB0E:
	dc.w	$0004,$0019,$04C0,$0F40,$CAF0,$E00F,$40CA,$F000
	dc.w	$0F40,$CAF0,$200F,$1000,$F000
