; Object $C8 - Obj2B_20E9C8 (from R83C, old ID $2B)
Obj2B_20E9C8:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PC8_dat_20E9D6(pc, d0.w), d0
	jmp     PC8_dat_20E9D6(pc, d0.w)
PC8_dat_20E9D6:
	dc.w	PC8_loc_20E9DA-PC8_dat_20E9D6
	dc.w	PC8_loc_20EA0E-PC8_dat_20E9D6
PC8_loc_20E9DA:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.l  #$20ea64, oMap(a0)
	move.w  #$8440, oTile(a0)
	move.w  oX(a0), $30(a0)
	move.b  #$b1, $33(a0)
	move.l  #$5000, $2c(a0)
	move.l  #$4c100110, oYRadius(a0)
PC8_loc_20EA0E:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	moveq   #$0, d0
	tst.b   layer.l
	bne.s   PC8_loc_20EA24
	move.b  $33(a0), d0
PC8_loc_20EA24:
	move.b  d0, oColType(a0)
	subq.w  #$1, $2a(a0)
	bpl.s   PC8_loc_20EA44
	move.w  #$199, $2a(a0)
	neg.l   $2c(a0)
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
PC8_loc_20EA44:
	lea     PC8_dat_20EA5E(pc), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	move.w  $30(a0), d0
	jmp     CheckObjDespawn2.l
PC8_dat_20EA5E:
	dc.w	$0002,$0100,$01FF
PC8_loc_20EA64:
	dc.w	$0004,$006E,$15B4,$0100,$02F8,$B401,$0802,$003C
	dc.w	$0110,$02F8,$3C01,$1802,$00C4,$0600,$04F8,$C402
	dc.w	$000A,$F0C4,$0208,$0A08,$DC06,$0004,$F8DC,$0200
	dc.w	$0AF0,$DC02,$080A,$08F4,$0600,$04F8,$F402,$000A
	dc.w	$F0F4,$0208,$0A08,$0C06,$0004,$F80C,$0200,$0AF0
	dc.w	$0C02,$080A,$0824,$0600,$04F8,$2402,$000A,$F024
	dc.w	$0208,$0A08,$B500,$0800,$F043,$0008,$01F0,$15B4
	dc.w	$0100,$02F8,$B401,$0802,$003C,$0110,$02F8,$3C01
	dc.w	$1802,$00C4,$0600,$04F8,$C402,$000A,$F0C4,$0208
	dc.w	$0A08,$DC06,$0004,$F8DC,$0200,$0AF0,$DC02,$080A
	dc.w	$08F4,$0600,$04F8,$F402,$000A,$F0F4,$0208,$0A08
	dc.w	$0C06,$0004,$F80C,$0200,$0AF0,$0C02,$080A,$0824
	dc.w	$0600,$04F8,$2402,$000A,$F024,$0208,$0A08,$B500
	dc.w	$0801,$F043,$0008,$00F0
