; Object $80 - Obj35_20EE40 (from R41A, old ID $35)
P80_Obj35_20EE40:
	tst.b   oRoutine(a0)
	bne.s   P80_loc_20EEB0
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$4380, oTile(a0)
	move.b  oSubtype(a0), d6
	bpl.s   P80_loc_20EE68
	move.b  #$ff, $3f(a0)
P80_loc_20EE68:
	lea     P80_dat_20EEFE(pc), a1
	move.b  #$10, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	btst.l  #$1, d6
	beq.s   P80_loc_20EE8E
	lea     P80_dat_20EF2C(pc), a1
	move.b  #$8, oWidth(a0)
	move.b  #$10, oYRadius(a0)
P80_loc_20EE8E:
	move.l  a1, oMap(a0)
	btst.l  #$0, d6
	beq.s   P80_loc_20EEB0
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$1, oSprFlags(a0)
	bset.b  #$0, oFlags(a0)
	bset.b  #$1, oFlags(a0)
P80_loc_20EEB0:
	move.b  oLayer(a0), d0
	bmi.s   P80_loc_20EED0
	tst.b   $3e(a0)
	bne.s   P80_loc_20EED0
	lea     switchFlags.w, a1
	ext.w   d0
	tst.b   (a1, d0.w)
	beq.s   P80_loc_20EED0
	st.b    $3e(a0)
	not.b   $3f(a0)
P80_loc_20EED0:
	tst.b   $3f(a0)
	bne.s   P80_loc_20EEDE
	move.b  #$0, oMapFrame(a0)
	bra.s   P80_loc_20EEE8
P80_loc_20EEDE:
	lea     P80_dat_20EEF4(pc), a1
	jsr     AnimateObject.l
P80_loc_20EEE8:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P80_dat_20EEFE:
	dc.w	$000A,$0010,$0016,$0021,$0027,$01F8,$0D00,$00F0
	dc.w	$01F8,$0900,$08F4,$02F8,$0100,$0EF8,$F801,$080E
	dc.w	$0001,$F809,$0808,$F401,$F80D,$0800,$F000
P80_dat_20EF2C:
	dc.w	$000A,$0010,$0016,$0021,$0027,$01F0,$0708,$10F8
	dc.w	$01F4,$0608,$18F8,$02F8,$0408,$1EF8,$0004,$181E
	dc.w	$F801,$F406,$1818,$F801,$F007,$1810,$F800
P80_dat_20EEF4:
	dc.w	$0002,$0100,$0102,$0304,$FF00
