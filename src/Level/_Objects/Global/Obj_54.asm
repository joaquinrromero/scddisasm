; Object $54 - Obj21_20C1A4 (from R31A, old ID $21)
P54_Obj21_20C1A4:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P54_dat_20C1DA(pc, d0.w), d0
	jsr     P54_dat_20C1DA(pc, d0.w)
	jsr     DrawObject.l
	move.w  $32(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.s   P54_loc_20C1D6
	rts     
P54_loc_20C1D6:
	bra.w   loc_20CFDE
P54_dat_20C1DA:
	dc.w	P54_loc_20C1DE-P54_dat_20C1DA
	dc.w	P54_loc_20C254-P54_dat_20C1DA
P54_loc_20C1DE:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$433e, oTile(a0)
	move.b  #$3, oPriority(a0)
	move.l  #$20c2da, oMap(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  oX(a0), $32(a0)
	move.w  oY(a0), $30(a0)
	cmpi.b  #$2, oSubtype(a0)
	bcs.s   P54_loc_20C254
	jsr     FindNextObjSlot.l
	beq.s   P54_loc_20C22A
	jmp     DeleteObject.l
P54_loc_20C22A:
	dc.b	$13,$7C,$00,$0A,$00,$00		; move.b #$a, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  #$ea, $39(a1)
	move.w  a0, $34(a1)
	move.b  oSubtype(a0), d0
	andi.b  #$1, d0
	add.b   d0, d0
	move.b  d0, $28(a1)
P54_loc_20C254:
	bsr.s   P54_sub_20C2B8
	tst.b   timeZone.l
	beq.s   P54_loc_20C28A
P54_loc_20C25E:
	cmpi.b  #$1, oSubtype(a0)
	beq.s   P54_loc_20C28A
	tst.b   $3a(a0)
	bne.s   P54_loc_20C28C
	moveq   #$0, d0
	move.b  $3b(a0), d0
	add.b   d0, d0
	add.b   d0, d0
	lea     P54_dat_20C2CA(pc, d0.w), a1
	move.b  (a1)+, $3a(a0)
	move.b  (a1)+, d0
	ext.w   d0
	move.w  d0, $38(a0)
	move.w  (a1)+, $36(a0)
P54_loc_20C28A:
	rts     
P54_loc_20C28C:
	move.w  $38(a0), d0
	add.w   d0, $36(a0)
	move.w  $36(a0), d0
	move.w  d0, oXVel(a0)
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, oX(a0)
	subq.b  #$1, $3a(a0)
	beq.s   P54_loc_20C2AC
	rts     
P54_loc_20C2AC:
	addq.b  #$1, $3b(a0)
	andi.b  #$3, $3b(a0)
	bra.s   P54_loc_20C25E
P54_sub_20C2B8:
	lea     objects.w, a1
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     SolidObject.l
P54_dat_20C2CA:
	dc.w	$40F8,$0200,$40F8,$0000,$4008,$FE00,$4008,$0000
P54_loc_20C2DA:
	dc.w	$0002,$01F0,$0F00,$00F0
