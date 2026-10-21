; Object $55 - Obj22_20C2E2 (from R31A, old ID $22)
P55_Obj22_20C2E2:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P55_dat_20C318(pc, d0.w), d0
	jsr     P55_dat_20C318(pc, d0.w)
	jsr     DrawObject.l
	move.w  $36(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.s   P55_loc_20C314
	rts     
P55_loc_20C314:
	bra.w   loc_20CFDE
P55_dat_20C318:
	dc.w	P55_loc_20C31C-P55_dat_20C318
	dc.w	P55_loc_20C3B8-P55_dat_20C318
P55_loc_20C31C:
	ori.b   #$4, oSprFlags(a0)
	move.w  #$39f, oTile(a0)
	move.b  #$3, oPriority(a0)
	move.l  #$20c442, oMap(a0)
	move.b  oSubtype(a0), d0
	lsr.b   #$2, d0
	move.b  d0, oMapFrame(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$e, oYRadius(a0)
	move.w  oX(a0), $36(a0)
	move.w  oY(a0), $32(a0)
	addq.b  #$2, oRoutine(a0)
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	andi.b  #$3, d0
	beq.s   P55_loc_20C3B8
	moveq   #$20, d1
	cmpi.b  #$1, d0
	beq.s   P55_loc_20C372
	moveq   #$a, d1
P55_loc_20C372:
	jsr     FindNextObjSlot.l
	bne.s   P55_loc_20C3B8
	dc.b	$13,$41,$00,$00		; move.b d1, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.w  a0, $34(a1)
	move.b  #$20, $38(a1)
	move.b  #$2, $28(a1)
	cmpi.b  #$20, d1
	beq.s   P55_loc_20C3B8
	move.b  #$18, $38(a1)
	move.b  oSubtype(a0), d0
	andi.b  #$1, d0
	add.b   d0, d0
	ori.b   #$4, d0
	move.b  d0, $28(a1)
P55_loc_20C3B8:
	jsr     P55_dat_20C3CE(pc)
	lea     objects.w, a1
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     SolidObject.l
P55_dat_20C3CE:
	btst.b  #$2, oSubtype(a0)
	bne.s   P55_loc_20C3EA
	jsr     P55_dat_20C400(pc)
	moveq   #$0, d0
	move.b  $3b(a0), d0
	add.w   $32(a0), d0
	move.w  d0, oY(a0)
	rts     
P55_loc_20C3EA:
	jsr     P55_dat_20C400(pc)
	moveq   #$0, d0
	move.b  $3b(a0), d0
	neg.w   d0
	add.w   $32(a0), d0
	move.w  d0, oY(a0)
	rts     
P55_dat_20C400:
	lea     objects.w, a1
	move.w  oX(a0), d0
	move.b  oWidth(a0), d1
	ext.w   d1
	sub.w   d1, d0
	move.w  $8(a1), d1
	sub.w   d0, d1
	bcs.s   P55_loc_20C42E
	cmpi.w  #$50, d1
	bcc.s   P55_loc_20C420
	rts     
P55_loc_20C420:
	subq.b  #$8, $3b(a0)
	bcc.s   P55_loc_20C440
	move.b  #$0, $3b(a0)
	rts     
P55_loc_20C42E:
	addq.b  #$8, $3b(a0)
	cmpi.b  #$20, $3b(a0)
	bcs.s   P55_loc_20C440
	move.b  #$20, $3b(a0)
P55_loc_20C440:
	rts     
P55_loc_20C442:
	dc.w	$0004,$000A,$01F0,$0F00,$00F0,$01F0,$0F10,$00F0
