; Object $82 - Obj21_20D3D8 (from R51A, old ID $21)
P82_Obj21_20D3D8:
	tst.b   oLayer(a0)
	beq.s   P82_loc_20D3E6
	bpl.w   loc_20D6D6
	bra.w   loc_20D6D6
P82_loc_20D3E6:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P82_dat_20D414(pc, d0.w), d0
	jsr     P82_dat_20D414(pc, d0.w)
	lea     P82_dat_20D70C(pc), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	move.w  $2a(a0), d0
	jmp     CheckObjDespawn2.l
P82_dat_20D414:
	dc.w	P82_loc_20D42A-P82_dat_20D414
	dc.w	loc_20D4AE-P82_dat_20D414
	dc.w	loc_20D500-P82_dat_20D414
	dc.w	ObjTamabboh_Wait1-P82_dat_20D414
	dc.w	loc_20D5E6-P82_dat_20D414
	dc.w	loc_20D60A-P82_dat_20D414
	dc.w	loc_20D614-P82_dat_20D414
	dc.w	loc_20D68A-P82_dat_20D414
	dc.w	loc_20D694-P82_dat_20D414
	dc.w	loc_20D6B8-P82_dat_20D414
	dc.w	loc_20D6C2-P82_dat_20D414
P82_loc_20D42A:
	addq.b  #$2, oRoutine(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$18, oXRadius(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.b  #$31, oColType(a0)
	move.w  oX(a0), $2a(a0)
	lea     P82_dat_20D712(pc), a1
	move.l  #$ffff0000, d0
	move.w  #$3, d1
	tst.b   oSubtype(a0)
	beq.s   P82_loc_20D474
	lea     P82_dat_20D74A(pc), a1
	move.l  #$ffff8000, d0
	move.w  #$7, d1
P82_loc_20D474:
	move.l  a1, oMap(a0)
	move.l  d0, $2c(a0)
	move.w  d1, $32(a0)
	movea.w a0, a1
	bra.s   loc_20D4A0
P82_dat_20D70C:
	dc.w	$0002,$1D00,$01FF
P82_dat_20D712:
	dc.w	$0004,$001E,$05FD,$0D00,$19EB,$F008,$0000,$F0F8
	dc.w	$0D00,$03E8,$F007,$000B,$08FC,$0D00,$19E0,$05FD
	dc.w	$0D00,$19E7,$F008,$0000,$F0F8,$0D00,$03E8,$F007
	dc.w	$000B,$08FC,$0D00,$19E4
P82_dat_20D74A:
	dc.w	$0004,$001E,$05FD,$0D00,$38E9,$F008,$0021,$F0F8
	dc.w	$0D00,$24E8,$F007,$002C,$08FC,$0D00,$38E1,$05FD
	dc.w	$0D00,$38E8,$F008,$0021,$F0F8,$0D00,$24E8,$F007
	dc.w	$002C,$08FC,$0D00,$38E2
P82_loc_20D782:
	dc.w	$0004,$000A,$01F8,$0900,$13F4,$01F8,$0500,$34F8
