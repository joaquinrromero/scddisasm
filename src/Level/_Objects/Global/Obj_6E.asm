; Object $6E - Obj2B_20EBC2 (from R51A, old ID $2B)
Obj2B_20EBC2:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P6E_dat_20EBDC(pc, d0.w), d0
	jsr     P6E_dat_20EBDC(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P6E_dat_20EBDC:
	dc.w	P6E_loc_20EBE2-P6E_dat_20EBDC
	dc.w	P6E_loc_20EC18-P6E_dat_20EBDC
	dc.w	ObjBreakableWall_Fall-P6E_dat_20EBDC
P6E_loc_20EBE2:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$30, oYRadius(a0)
	move.b  #$ee, oColType(a0)
	move.w  #$446b, oTile(a0)
	move.l  #$20ed08, oMap(a0)
P6E_loc_20EC18:
	move.b  oColStatus(a0), d6
	beq.s   P6E_loc_20EC3E
	clr.b   oColStatus(a0)
	lea     objects.w, a1
	asr.w   $10(a1)
	asr.w   $14(a1)
	jsr     SolidObject.l
	beq.s   P6E_loc_20EC3C
	jsr     GetOffObject.l
P6E_loc_20EC3C:
	bra.s   P6E_loc_20EC48
P6E_loc_20EC3E:
	lea     objects.w, a1
	jmp     SolidObject.l
P6E_loc_20EC48:
	move.w  #$b0, d0
	jsr     PlayFMSound.l
	addq.b  #$2, oRoutine(a0)
	clr.b   oColType(a0)
	lea     P6E_dat_20ED7E(pc), a6
	lea     P6E_dat_20ED9E(pc), a5
	lea     P6E_dat_20ED76(pc), a4
	moveq   #$7, d6
	movea.w a0, a1
	bra.s   P6E_loc_20ECA4
P6E_loc_20EC6C:
	jsr     FindObjSlot.l
	bne.s   ObjBreakableWall_Fall
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.b  oRoutine(a0), $24(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  oSprFlags(a0), $1(a1)
	move.b  oPriority(a0), $18(a1)
	move.l  oMap(a0), $4(a1)
	move.w  oTile(a0), $2(a1)
P6E_loc_20ECA4:
	move.b  #$10, $17(a1)
	move.b  #$10, $19(a1)
	move.b  #$c, $16(a1)
	move.w  (a6)+, d0
	move.w  (a6)+, d1
	add.w   d0, $8(a1)
	add.w   d1, $c(a1)
	move.l  (a5)+, $2a(a1)
	move.l  (a5)+, $2e(a1)
	move.b  (a4)+, $1a(a1)
	dbra    d6, P6E_loc_20EC6C
P6E_dat_20ED7E:
	dc.w	$FFF8,$FFE8,$0010,$0000,$0000,$0010,$0010,$0010
	dc.w	$0000,$0020,$0010,$0020,$0000,$0030,$0010,$0030
P6E_dat_20ED9E:
	dc.w	$FFFE,$D2D3,$FFFE,$0000,$0001,$2D2D,$FFFE,$0000
	dc.w	$FFFD,$8000,$FFFE,$8000,$0002,$8000,$FFFE,$8000
	dc.w	$FFFB,$0000,$0000,$8000,$0005,$0000,$0000,$8000
	dc.w	$FFFD,$8000,$0001,$0000,$0002,$8000,$0001,$0000
P6E_dat_20ED76:
	dc.w	$0205,$0305,$0405,$0705
