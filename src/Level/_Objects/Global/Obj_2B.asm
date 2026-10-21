; Object $2B - Obj2B_20D4DC (from R41A, old ID $2B)
Obj2B_20D4DC:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P2B_dat_20D500(pc, d0.w), d0
	jsr     P2B_dat_20D500(pc, d0.w)
	jsr     DrawObject.l
	move.w  $3e(a0), d0
	jmp     CheckObjDespawn2.l
P2B_dat_20D500:
	dc.w	P2B_loc_20D504-P2B_dat_20D500
	dc.w	P2B_loc_20D57E-P2B_dat_20D500
P2B_loc_20D504:
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$2c, oColType(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$1c, oXRadius(a0)
	move.b  #$1c, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  #$2416, oTile(a0)
	move.w  oX(a0), $3e(a0)
	move.l  oY(a0), $2a(a0)
	lea     P2B_dat_20D5DA(pc), a1
	move.l  #$ffff0000, d0
	move.w  #$4, d1
	move.w  #$100, d2
	tst.b   oSubtype(a0)
	beq.s   P2B_loc_20D568
	lea     P2B_dat_20D698(pc), a1
	move.l  #$ffff8000, d0
	move.w  #$1, d1
	move.w  #$200, d2
P2B_loc_20D568:
	move.l  a1, oMap(a0)
	move.l  d0, $30(a0)
	move.w  d1, $34(a0)
	move.w  d2, $38(a0)
	lsr.w   #$1, d2
	move.w  d2, $36(a0)
P2B_loc_20D57E:
	move.l  $30(a0), d0
	add.l   d0, oX(a0)
	move.w  $2e(a0), d0
	jsr     CalcSine.l
	swap    d0
	clr.w   d0
	asr.l   #$4, d0
	add.l   $2a(a0), d0
	move.l  d0, oY(a0)
	move.w  $34(a0), d0
	add.w   d0, $2e(a0)
	addi.w  #$ffff, $36(a0)
	bne.s   P2B_loc_20D5C4
	move.w  $38(a0), $36(a0)
	neg.l   $30(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
P2B_loc_20D5C4:
	lea     P2B_dat_20D5CE(pc), a1
	jmp     AnimateObject.l
P2B_dat_20D5DA:
	dc.w	$0006,$0043,$0080,$0CF4,$0800,$0AE4,$FC04,$000D
	dc.w	$E4FC,$0000,$0FF4,$0404,$0010,$ECF4,$0000,$00FC
	dc.w	$F408,$0001,$04FC,$0C00,$04FC,$0404,$0008,$FCF0
	dc.w	$0C00,$14E3,$F000,$0018,$03EF,$0C00,$14EA,$EF00
	dc.w	$0018,$0A0C,$F408,$000A,$E4FC,$0400,$0DE4,$FC00
	dc.w	$000F,$F404,$0400,$10EC,$F400,$0000,$FCF4,$0800
	dc.w	$0104,$FC0C,$0004,$FC04,$0400,$08FC,$F20C,$0019
	dc.w	$E3F2,$0000,$1D03,$F10C,$0019,$EAF1,$0000,$1D0A
	dc.w	$0CF4,$0800,$0AE4,$FC04,$0012,$E4FC,$0000,$0FF4
	dc.w	$0404,$0010,$ECF4,$0000,$00FC,$F408,$0001,$04FC
	dc.w	$0C00,$04FC,$0404,$0008,$FCF0,$0C00,$14E3,$F000
	dc.w	$0018,$03EF,$0C00,$14EA,$EF00,$0018,$0A00
P2B_dat_20D698:
	dc.w	$0006,$003E,$0076,$0BF4,$0800,$0AE4,$FC04,$001E
	dc.w	$E4FC,$0000,$0FF4,$0404,$0010,$ECF4,$0C00,$20FC
	dc.w	$FC0C,$0024,$FC04,$0400,$28FC,$F00C,$0014,$E3F0
	dc.w	$0000,$1803,$EF0C,$0014,$EAEF,$0000,$180A,$0BF4
	dc.w	$0800,$0AE4,$FC04,$001E,$E4FC,$0000,$0FF4,$0404
	dc.w	$0010,$ECF4,$0C00,$20FC,$FC0C,$0024,$FC04,$0400
	dc.w	$28FC,$F20C,$0019,$E3F2,$0000,$1D03,$F10C,$0019
	dc.w	$EAF1,$0000,$1D0A,$0BF4,$0800,$0AE4,$FC04,$0012
	dc.w	$E4FC,$0000,$0FF4,$0404,$0010,$ECF4,$0C00,$20FC
	dc.w	$FC0C,$0024,$FC04,$0400,$28FC,$F00C,$0014,$E3F0
	dc.w	$0000,$1803,$EF0C,$0014,$EAEF,$0000,$180A
P2B_dat_20D5CE:
	dc.w	$0004,$0008,$0200,$01FF,$0400,$02FF
