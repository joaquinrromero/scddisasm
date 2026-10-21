; Object $7E - Obj2F_20E386 (from R41A, old ID $2F)
Obj2F_20E386:
	jsr     CheckAnimalPrescence.l
	tst.b   oRoutine(a0)
	bmi.w   P7E_loc_20E45A
	bne.w   P7E_loc_20E4EA
	ori.b   #$4, oSprFlags(a0)
	move.b  #$5, oPriority(a0)
	move.b  #$8, oXRadius(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	lea     ObjAnimal_BaseTileList(pc), a1
	moveq   #$0, d0
	move.b  act.l, d0
	asl.w   #$2, d0
	add.b   timeZone.l, d0
	add.w   d0, d0
	move.w  (a1, d0.w), oTile(a0)
	btst.b  #$0, oSubtype(a0)
	beq.s   P7E_loc_20E3E0
	addi.w  #$2000, oTile(a0)
P7E_loc_20E3E0:
	lea     P7E_dat_20E574(pc), a1
	btst.b  #$0, oSubtype(a0)
	beq.s   P7E_loc_20E3F0
	lea     P7E_dat_20E59C(pc), a1
P7E_loc_20E3F0:
	move.l  a1, oMap(a0)
	move.w  oY(a0), $2e(a0)
	move.b  oSubtype(a0), d0
	bpl.s   P7E_loc_20E43E
	subq.b  #$2, oRoutine(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	move.w  oX(a0), $38(a0)
	move.l  #$200, $34(a0)
	btst.l  #$0, d0
	beq.s   P7E_loc_20E43C
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	neg.l   $34(a0)
	move.l  #$3000, $30(a0)
P7E_loc_20E43C:
	rts     
P7E_loc_20E43E:
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, oAnim(a0)
	move.l  #$10000, $2a(a0)
	move.l  #$100, $34(a0)
	rts     
P7E_loc_20E45A:
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$52,$00,$00		; cmpi.b #$52, $0(a1) (raw: not reproducible by assembler)
	bne.s   P7E_loc_20E46C
	tst.b   $3f(a1)
	beq.s   P7E_loc_20E472
P7E_loc_20E46C:
	jmp     DeleteObject.l
P7E_loc_20E472:
	move.b  $32(a0), d0
	jsr     CalcSine.l
	swap    d1
	swap    d0
	asr.l   #$3, d1
	asr.l   #$4, d0
	addi.l  #$8000, d1
	addi.l  #$8000, d0
	swap    d1
	swap    d0
	add.w   $38(a0), d1
	add.w   $2e(a0), d0
	move.w  d1, oX(a0)
	move.w  d0, oY(a0)
	move.l  $34(a0), d0
	add.l   d0, $30(a0)
	move.l  $30(a0), d0
	andi.l  #$7fff, d0
	bne.s   P7E_loc_20E4DA
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	cmpi.b  #$5, oPriority(a0)
	beq.s   P7E_loc_20E4D4
	move.b  #$5, oPriority(a0)
	bra.s   P7E_loc_20E4DA
P7E_loc_20E4D4:
	move.b  #$3, oPriority(a0)
P7E_loc_20E4DA:
	lea     P7E_dat_20E54E(pc), a1
	jsr     AnimateObject.l
	jmp     DrawObject.l
P7E_loc_20E4EA:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	move.b  $32(a0), d0
	jsr     CalcSine.l
	swap    d0
	asr.l   #$3, d0
	addi.l  #$8000, d0
	swap    d0
	add.w   $2e(a0), d0
	move.w  d0, oY(a0)
	move.l  $34(a0), d0
	add.l   d0, $30(a0)
	bmi.s   P7E_loc_20E524
	cmpi.l  #$10000, $30(a0)
	blt.s   P7E_loc_20E538
P7E_loc_20E524:
	neg.l   $34(a0)
	neg.l   $2a(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
P7E_loc_20E538:
	lea     P7E_dat_20E54E(pc), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P7E_dat_20E574:
	dc.w	$0006,$0016,$0026,$03F4,$0400,$00F8,$FC04,$0002
	dc.w	$F804,$0410,$00F8,$03F4,$0400,$04F8,$FC04,$0006
	dc.w	$F804,$0410,$04F8,$0000
P7E_dat_20E59C:
	dc.w	$0006,$0016,$0026,$03F4,$0400,$08F8,$FC04,$000A
	dc.w	$F804,$0410,$08F8,$03F4,$0400,$0CF8,$FC04,$000E
	dc.w	$F804,$0410,$0CF8,$0000
P7E_dat_20E54E:
	dc.w	$0004,$0022,$0000,$0002,$0000,$0201,$0102,$0101
	dc.w	$0200,$0002,$0200,$0002,$0201,$0102,$0201,$0102
	dc.w	$02FF,$1300,$01FF
