; Object $5B - Obj2E_20B936 (from R31A, old ID $2E)
Obj2E_20B936:
	move.b  oSubtype(a0), d0
	addi.b  #$ff, d0
	bmi.s   P5B_loc_20B944
	bra.w   P5B_loc_20BC42
P5B_loc_20B944:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P5B_dat_20B96E(pc, d0.w), d0
	jsr     P5B_dat_20B96E(pc, d0.w)
	lea     P5B_dat_20BB56(pc), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P5B_dat_20B96E:
	dc.w	P5B_loc_20B97A-P5B_dat_20B96E
	dc.w	P5B_loc_20B9B8-P5B_dat_20B96E
	dc.w	P5B_loc_20B9F2-P5B_dat_20B96E
	dc.w	P5B_loc_20BA42-P5B_dat_20B96E
	dc.w	P5B_loc_20BAD6-P5B_dat_20B96E
	dc.w	P5B_loc_20BAE0-P5B_dat_20B96E
P5B_loc_20B97A:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$84, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$6, oColType(a0)
	move.b  #$e, oWidth(a0)
	move.b  #$e, oYRadius(a0)
	move.w  #$a46a, oTile(a0)
	lea     P5B_dat_20BB5E(pc), a1
	tst.b   oSubtype(a0)
	bmi.s   P5B_loc_20B9B4
	lea     P5B_dat_20BBD0(pc), a1
	st.b    $3f(a0)
P5B_loc_20B9B4:
	move.l  a1, oMap(a0)
P5B_loc_20B9B8:
	addi.l  #$10000, oY(a0)
	jsr     ObjGetFloorDist.l
	subq.w  #$8, d1
	bgt.s   P5B_loc_20B9F0
	sub.w   d1, oY(a0)
	move.l  oY(a0), $32(a0)
	move.l  #$3000, $2e(a0)
	move.w  #$8, $36(a0)
	addq.b  #$2, oRoutine(a0)
	tst.l   $2a(a0)
	beq.s   P5B_loc_20B9F0
	addq.b  #$2, oRoutine(a0)
P5B_loc_20B9F0:
	rts     
P5B_loc_20B9F2:
	bsr.w   P5B_sub_20BB12
	lea     objects.w, a1
	move.w  oY(a0), d0
	sub.w   $c(a1), d0
	subi.w  #$ffb0, d0
	subi.w  #$a0, d0
	bcc.s   P5B_loc_20BA40
	move.w  oX(a0), d0
	sub.w   $8(a1), d0
	move.w  d0, d1
	subi.w  #$ffb0, d0
	subi.w  #$a0, d0
	bcc.s   P5B_loc_20BA40
	addq.b  #$2, oRoutine(a0)
	move.l  #$ffff4000, $2a(a0)
	tst.w   d1
	bmi.s   P5B_loc_20BA40
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	neg.l   $2a(a0)
P5B_loc_20BA40:
	rts     
P5B_loc_20BA42:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	move.l  $32(a0), oY(a0)
	moveq   #$0, d3
	move.b  oXRadius(a0), d3
	lea     ObjGetLWallDist.l, a1
	tst.l   $2a(a0)
	bmi.s   P5B_loc_20BA68
	lea     ObjGetRWallDist.l, a1
P5B_loc_20BA68:
	jsr     (a1)
	tst.w   d1
	bmi.s   P5B_loc_20BAC0
	jsr     ObjGetFloorDist.l
	cmpi.w  #$10, d1
	bge.s   P5B_loc_20BAC6
	subq.w  #$8, d1
	add.w   d1, oY(a0)
	move.l  oY(a0), $32(a0)
	bsr.w   P5B_sub_20BB12
	tst.b   $3f(a0)
	beq.s   P5B_loc_20BABE
	andi.w  #$7f, $36(a0)
	bne.s   P5B_loc_20BABE
	jsr     FindObjSlot.l
	bne.s   P5B_loc_20BABE
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.l  oX(a0), $8(a1)
	move.l  oY(a0), $c(a1)
	addi.w  #$10, $c(a1)
	move.b  #$1, $28(a1)
P5B_loc_20BABE:
	rts     
P5B_loc_20BAC0:
	addq.b  #$2, oRoutine(a0)
	rts     
P5B_loc_20BAC6:
	addq.b  #$4, oRoutine(a0)
	bsr.w   P5B_sub_20BB12
	move.l  oY(a0), $32(a0)
	rts     
P5B_loc_20BAD6:
	addi.l  #$ffff8000, oY(a0)
	rts     
P5B_loc_20BAE0:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	move.w  oX(a0), d3
	moveq   #$0, d4
	move.b  oWidth(a0), d4
	sub.w   d4, d3
	tst.l   $2a(a0)
	bpl.s   P5B_loc_20BAFE
	add.w   d4, d3
	add.w   d4, d3
P5B_loc_20BAFE:
	jsr     ObjGetFloorDist2.l
	cmpi.w  #$10, d1
	blt.s   P5B_loc_20BB10
	addi.b  #$f8, oRoutine(a0)
P5B_loc_20BB10:
	rts     
P5B_dat_20BB56:
	dc.w	$0002,$0300,$0102,$FF00
P5B_dat_20BB5E:
	dc.w	$0006,$002A,$004E,$07F0,$0800,$00F8,$F80C,$0003
	dc.w	$F000,$0400,$24F0,$0000,$0026,$0000,$0100,$0A08
	dc.w	$0800,$000C,$F008,$0400,$27F8,$07F0,$0D00,$0FF0
	dc.w	$0004,$0024,$F000,$0000,$2900,$0000,$0018,$0808
	dc.w	$0000,$0CF0,$0804,$0027,$F808,$0000,$1908,$07F0
	dc.w	$0D00,$1AF0,$0004,$0024,$F000,$0000,$2A00,$0000
	dc.w	$0023,$0808,$0000,$0CF0,$0804,$0027,$F808,$0000
	dc.w	$1908
P5B_dat_20BBD0:
	dc.w	$0006,$002A,$004E,$07F0,$0800,$00F8,$F80C,$0003
	dc.w	$F000,$0400,$07F0,$0000,$0009,$0000,$0100,$0A08
	dc.w	$0800,$000C,$F008,$0400,$0DF8,$07F0,$0D00,$0FF0
	dc.w	$0004,$0007,$F000,$0000,$1700,$0000,$0018,$0808
	dc.w	$0000,$0CF0,$0804,$000D,$F808,$0000,$1908,$07F0
	dc.w	$0D00,$1AF0,$0004,$0007,$F000,$0000,$2200,$0000
	dc.w	$0023,$0808,$0000,$0CF0,$0804,$000D,$F808,$0000
	dc.w	$1908
P5B_loc_20BC42:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P5B_dat_20BC56(pc, d0.w), d0
	jsr     P5B_dat_20BC56(pc, d0.w)
	jmp     DrawObject.l
P5B_sub_20BB12:
	addq.w  #$1, $36(a0)
	move.l  $2e(a0), d0
	add.l   d0, oY(a0)
	move.w  $36(a0), d0
	andi.w  #$f, d0
	bne.s   P5B_loc_20BB2C
	neg.l   $2e(a0)
P5B_loc_20BB2C:
	rts     
	lea     objects.w, a1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	subi.w  #$ff00, d0
	subi.w  #$200, d0
	bcc.s   P5B_loc_20BB54
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	subi.w  #$ff00, d0
	subi.w  #$200, d0
P5B_loc_20BB54:
	rts     
P5B_dat_20BC56:
	dc.w	P5B_loc_20BC60-P5B_dat_20BC56
	dc.w	P5B_loc_20BC96-P5B_dat_20BC56
	dc.w	P5B_loc_20BCBE-P5B_dat_20BC56
	dc.w	P5B_loc_20BCD8-P5B_dat_20BC56
	dc.w	P5B_loc_20BCF4-P5B_dat_20BC56
P5B_loc_20BC60:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$2, oPriority(a0)
	move.b  #$8b, oColType(a0)
	move.b  #$6, oXRadius(a0)
	move.b  #$6, oWidth(a0)
	move.b  #$6, oYRadius(a0)
	move.w  #$495, oTile(a0)
	move.l  #$20bd1e, oMap(a0)
P5B_loc_20BC96:
	tst.b   oColStatus(a0)
	bne.s   P5B_loc_20BCF4
	addi.l  #$10000, oY(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P5B_loc_20BCBC
	add.w   d1, oY(a0)
	move.w  #$78, $2a(a0)
	addq.b  #$2, oRoutine(a0)
P5B_loc_20BCBC:
	rts     
P5B_loc_20BCBE:
	tst.b   oColStatus(a0)
	bne.s   P5B_loc_20BCF4
	addi.w  #$ffff, $2a(a0)
	bne.s   P5B_loc_20BCD6
	move.w  #$78, $2a(a0)
	addq.b  #$2, oRoutine(a0)
P5B_loc_20BCD6:
	rts     
P5B_loc_20BCD8:
	tst.b   oColStatus(a0)
	bne.s   P5B_loc_20BCF4
	addi.w  #$ffff, $2a(a0)
	bne.s   P5B_loc_20BCEA
	addq.b  #$2, oRoutine(a0)
P5B_loc_20BCEA:
	lea     P5B_dat_20BD18(pc), a1
	jmp     AnimateObject.l
P5B_loc_20BCF4:
	move.b  #$18, oID(a0)
	move.b  #$0, oRoutine(a0)
	move.b  #$1, oSolidType(a0)
	tst.b   oSprFlags(a0)
	bpl.s   P5B_loc_20BD16
	move.w  #$9e, d0
	jsr     PlayFMSound.l
P5B_loc_20BD16:
	rts     
P5B_dat_20BD18:
	dc.w	$0002,$0100,$01FF
P5B_loc_20BD1E:
	dc.w	$0004,$000A,$01F8,$0500,$00F8,$01F8,$0500,$04F8
