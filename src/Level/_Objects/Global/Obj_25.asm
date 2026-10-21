; Object $25 - Obj25_20CEE0 (from R42A, old ID $25)
P25_Obj25_20CEE0:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P25_dat_20CEEE(pc, d0.w), d0
	jmp     P25_dat_20CEEE(pc, d0.w)
P25_dat_20CEEE:
	dc.w	P25_loc_20CEF4-P25_dat_20CEEE
	dc.w	P25_loc_20CF2A-P25_dat_20CEEE
	dc.w	P25_loc_20CFC4-P25_dat_20CEEE
P25_loc_20CEF4:
	lea     switchFlags.w, a1
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	adda.w  d0, a1
	tst.b   (a1)
	bne.w   P25_loc_20CFE2
	move.l  a1, $30(a0)
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$446a, oTile(a0)
	move.l  #$20cfe8, oMap(a0)
	move.l  #$40400340, oYRadius(a0)
P25_loc_20CF2A:
	movea.l $30(a0), a1
	tst.b   (a1)
	bne.s   P25_loc_20CF48
	lea     objects.w, a1
	jsr     SolidObject.l
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P25_loc_20CF48:
	addq.b  #$2, oRoutine(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.w  #$80, $2a(a0)
	move.l  #$ffff0000, $2c(a0)
	addq.b  #$1, oMapFrame(a0)
	subi.w  #$30, oX(a0)
	move.w  #$2, d6
	move.w  oX(a0), d5
P25_loc_20CF78:
	jsr     FindNextObjSlot.l
	bne.w   P25_loc_20CFE2
	movea.w a0, a2
	movea.w a1, a3
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	move.l  (a2)+, (a3)+
	addi.w  #$20, d5
	move.w  d5, $8(a1)
	move.w  d6, d0
	andi.w  #$1, d0
	bne.s   P25_loc_20CFBE
	neg.l   $2c(a1)
	addq.b  #$1, $1a(a1)
P25_loc_20CFBE:
	dbra    d6, P25_loc_20CF78
	bra.s   P25_loc_20CFD2
P25_loc_20CFC4:
	subq.w  #$1, $2a(a0)
	bmi.s   P25_loc_20CFE2
	move.l  $2c(a0), d0
	add.l   d0, oY(a0)
P25_loc_20CFD2:
	lea     objects.w, a1
	jsr     SolidObject.l
	jmp     DrawObject.l
P25_loc_20CFE2:
	jmp     DeleteObject.l
P25_loc_20CFE8:
	dc.w	$0006,$0057,$006C,$10C0,$0F00,$00C0,$C00F,$0010
	dc.w	$E0C0,$0F00,$0000,$C00F,$0010,$20E0,$0F00,$00C0
	dc.w	$E00F,$0010,$E0E0,$0F00,$0000,$E00F,$0010,$2000
	dc.w	$0F00,$00C0,$000F,$0010,$E000,$0F00,$0000,$000F
	dc.w	$0010,$2020,$0F00,$00C0,$200F,$0010,$E020,$0F00
	dc.w	$0000,$200F,$0010,$2004,$C00F,$0000,$F0E0,$0F00
	dc.w	$00F0,$000F,$0000,$F020,$0F00,$00F0,$04C0,$0F00
	dc.w	$10F0,$E00F,$0010,$F000,$0F00,$10F0,$200F,$0010
	dc.w	$F000
