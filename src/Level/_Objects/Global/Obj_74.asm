; Object $74 - Obj0F_20E7F0 (from R81A, old ID $0F)
Obj0F_20E7F0:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P74_dat_20E808(pc, d0.w), d0
	jsr     P74_dat_20E808(pc, d0.w)
	move.w  $36(a0), d0
	jmp     CheckObjDespawn2.l
P74_dat_20E808:
	dc.w	P74_loc_20E80E-P74_dat_20E808
	dc.w	ObjMovingSpring_AlignToGround-P74_dat_20E808
	dc.w	loc_20E8B4-P74_dat_20E808
P74_loc_20E80E:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.l  #$20e920, oMap(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$6, oYRadius(a0)
	move.w  oX(a0), $36(a0)
	move.w  #$100, oXVel(a0)
	moveq   #$e, d0
	jsr     SetObjectTileID.l
	jsr     FindNextObjSlot.l
	beq.s   P74_loc_20E854
	jmp     DeleteObject.l
P74_loc_20E854:
	dc.b	$13,$7C,$00,$0A,$00,$00		; move.b #$a, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$10, $c(a1)
	move.b  #$f0, $39(a1)
	move.w  a0, $34(a1)
	move.b  oSubtype(a0), d0
	andi.b  #$f, d0
	move.b  d0, $28(a1)
	move.w  #$50, $3a(a0)
	tst.b   oSubtype(a0)
	bpl.s   ObjMovingSpring_AlignToGround
	move.w  #$40, $3a(a0)
