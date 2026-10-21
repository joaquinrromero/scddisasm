; Object $27 - Obj27_20CB84 (from R41A, old ID $27)
P27_Obj27_20CB84:
	tst.b   oRoutine(a0)
	bne.w   P27_loc_20CBCE
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.w  #$50a, oTile(a0)
	move.l  #$20ccea, oMap(a0)
	move.b  #$a, oYRadius(a0)
	lea     switchFlags.w, a1
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	lea     (a1, d0.w), a1
	move.w  a1, $3c(a0)
P27_loc_20CBCE:
	move.w  $34(a0), d0
	beq.s   P27_loc_20CBFE
	movea.w d0, a1
	move.w  oX(a0), d1
	move.b  $38(a0), d0
	ext.w   d0
	add.w   $8(a1), d0
	move.w  d0, oX(a0)
	sub.w   d1, d0
	asl.w   #$8, d0
	move.w  d0, oXVel(a0)
	move.b  $39(a0), d0
	ext.w   d0
	add.w   $c(a1), d0
	move.w  d0, oY(a0)
P27_loc_20CBFE:
	move.b  $3f(a0), $3e(a0)
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	lea     objects.w, a1
	jsr     SolidObject.l
	beq.s   P27_loc_20CC1C
	bsr.w   P27_sub_20CCCE
P27_loc_20CC1C:
	movea.w $3c(a0), a4
	sne.b   $3f(a0)
	bne.s   P27_loc_20CC2C
	bclr.b  #$7, (a4)
	bra.s   P27_loc_20CC38
P27_loc_20CC2C:
	bsr.w   P27_sub_20CCCE
	bset.b  #$7, (a4)
	bset.b  #$6, (a4)
P27_loc_20CC38:
	cmpi.w  #$ff, $3e(a0)
	bne.s   P27_loc_20CC72
	tst.b   oSprFlags(a0)
	bpl.s   P27_loc_20CC50
	move.w  #$bf, d0
	jsr     PlayFMSound.l
P27_loc_20CC50:
	bchg.b  #$5, (a4)
	addq.w  #$8, $c(a1)
	tst.w   $34(a0)
	beq.s   P27_loc_20CC64
	addq.b  #$4, $39(a0)
	bra.s   P27_loc_20CC68
P27_loc_20CC64:
	addq.w  #$4, oY(a0)
P27_loc_20CC68:
	move.b  #$1, oMapFrame(a0)
	subq.b  #$4, oYRadius(a0)
P27_loc_20CC72:
	cmpi.w  #$ff00, $3e(a0)
	bne.s   P27_loc_20CC96
	subq.w  #$8, $c(a1)
	tst.w   $34(a0)
	beq.s   P27_loc_20CC8A
	subq.b  #$4, $39(a0)
	bra.s   P27_loc_20CC8E
P27_loc_20CC8A:
	subq.w  #$4, oY(a0)
P27_loc_20CC8E:
	clr.b   oMapFrame(a0)
	addq.b  #$4, oYRadius(a0)
P27_loc_20CC96:
	jsr     DrawObject.l
	move.w  $34(a0), d0
	bne.s   P27_loc_20CCA8
	jmp     CheckObjDespawn.l
P27_loc_20CCA8:
	movea.w d0, a1
	move.w  $36(a1), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.s   P27_loc_20CCC8
	rts     
P27_loc_20CCC8:
	jmp     DespawnObject.l
P27_sub_20CCCE:
	move.w  oY(a0), d0
	move.b  oYRadius(a0), d1
	ext.w   d1
	sub.w   d1, d0
	move.b  $16(a1), d1
	ext.w   d1
	sub.w   d1, d0
	addq.w  #$1, d0
	move.w  d0, $c(a1)
	rts     
P27_loc_20CCEA:
	dc.w	$0004,$000F,$02F8,$0500,$00F0,$F805,$0800,$0002
	dc.w	$FC04,$0004,$F0FC,$0408,$0400
