; Object $AB - Obj2A_20EBF8 (from R61A, old ID $2A)
Obj2A_20EBF8:
	tst.b   oSubtype(a0)
	bmi.w   PAB_loc_20ECAA
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PAB_dat_20EC24(pc, d0.w), d0
	jsr     PAB_dat_20EC24(pc, d0.w)
	lea     objects.w, a1
	jsr     SolidObject.l
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PAB_dat_20EC24:
	dc.w	PAB_loc_20EC28-PAB_dat_20EC24
	dc.w	PAB_loc_20EC66-PAB_dat_20EC24
PAB_loc_20EC28:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  #$3a8, oTile(a0)
	move.l  #$20ee7e, oMap(a0)
	move.w  a0, $2a(a0)
	st.b    $34(a0)
	move.w  #$0, $32(a0)
PAB_loc_20EC66:
	tst.b   $34(a0)
	beq.s   PAB_loc_20ECA8
	sf.b    $34(a0)
	lea     PAB_dat_20EE86(pc), a1
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	add.w   d0, d0
	adda.w  (a1, d0.w), a1
	move.w  $32(a0), d0
	adda.w  (a1, d0.w), a1
	move.l  a1, $2c(a0)
	addq.w  #$2, $32(a0)
	cmpi.w  #$8, $32(a0)
	blt.s   PAB_loc_20EC9C
	clr.w   $32(a0)
PAB_loc_20EC9C:
	bsr.w   PAB_sub_20EE3C
	beq.s   PAB_loc_20ECA8
	jmp     DeleteObject.l
PAB_loc_20ECA8:
	rts     
PAB_loc_20ECAA:
	movea.w $2a(a0), a1
	dc.b	$0C,$29,$00,$2A,$00,$00		; cmpi.b #$2a, $0(a1) (raw: not reproducible by assembler)
	bne.w   PAB_loc_20EE36
	move.b  oLayer(a0), d0
	cmp.b   $29(a1), d0
	bne.w   PAB_loc_20EE36
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PAB_dat_20ECE2(pc, d0.w), d0
	jsr     PAB_dat_20ECE2(pc, d0.w)
	lea     objects.w, a1
	jsr     SolidObject.l
	jmp     DrawObject.l
PAB_dat_20EE86:
	dc.w	$000A,$002A,$0042,$0012,$0050,$0010,$0014,$0018
	dc.w	$001C,$0014,$0010,$000C,$0008,$0000,$00FF,$0101
	dc.w	$01FF,$0202,$02FF,$0303,$03FF,$0008,$000C,$0010
	dc.w	$0014,$0000,$01FF,$0100,$01FF,$0202,$01FF,$0303
	dc.w	$03FF,$0008,$000B,$0008,$000B,$0000,$FF02,$02FF
	dc.w	$0008,$000C,$0010,$0014,$0101,$00FF,$0203,$03FF
	dc.w	$0300,$03FF,$0001,$00FF
PAB_sub_20EE3C:
	movea.l $2c(a0), a6
	tst.b   (a6)+
	bmi.s   PAB_loc_20EE7C
	jsr     FindObjSlot.l
	bne.s   PAB_loc_20EE7C
	movea.l a0, a2
	movea.l a1, a3
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
	move.b  #$ff, $28(a1)
	move.w  a0, $36(a1)
	move.l  a6, $2c(a1)
	addq.b  #$1, $18(a1)
	clr.b   $24(a1)
PAB_loc_20EE7C:
	rts     
PAB_loc_20EE7E:
	dc.w	$0002,$01F0,$0F00,$00F0
PAB_dat_20ECE2:
	dc.w	PAB_loc_20ECF6-PAB_dat_20ECE2
	dc.w	PAB_loc_20ED64-PAB_dat_20ECE2
	dc.w	PAB_loc_20ED80-PAB_dat_20ECE2
	dc.w	PAB_loc_20ED9C-PAB_dat_20ECE2
	dc.w	PAB_loc_20EDBA-PAB_dat_20ECE2
	dc.w	PAB_loc_20EDBC-PAB_dat_20ECE2
	dc.w	PAB_loc_20EDD0-PAB_dat_20ECE2
	dc.w	PAB_loc_20EDEC-PAB_dat_20ECE2
	dc.w	PAB_loc_20EE08-PAB_dat_20ECE2
	dc.w	PAB_loc_20EE22-PAB_dat_20ECE2
PAB_loc_20ECF6:
	addq.b  #$2, oRoutine(a0)
	move.w  #$3f, $30(a0)
	move.l  #$0, $38(a0)
	move.l  #$0, $3c(a0)
	movea.l $2c(a0), a1
	move.b  -$1(a1), d0
	bne.s   PAB_loc_20ED22
	move.l  #$ffff8000, $3c(a0)
PAB_loc_20ED22:
	subq.b  #$1, d0
	bne.s   PAB_loc_20ED2E
	move.l  #$8000, $38(a0)
PAB_loc_20ED2E:
	subq.b  #$1, d0
	bne.s   PAB_loc_20ED3A
	move.l  #$8000, $3c(a0)
PAB_loc_20ED3A:
	subq.b  #$1, d0
	bne.s   PAB_loc_20ED46
	move.l  #$ffff8000, $38(a0)
PAB_loc_20ED46:
	movea.w $2a(a0), a1
	cmpi.b  #$2, $28(a1)
	bne.s   PAB_loc_20ED64
	moveq   #$1, d0
	tst.w   $3c(a0)
	bpl.s   PAB_loc_20ED5C
	moveq   #$ff, d0
PAB_loc_20ED5C:
	move.w  d0, $34(a0)
	move.w  d0, oYVel(a0)
PAB_loc_20ED64:
	move.l  $38(a0), d0
	add.l   d0, oX(a0)
	move.l  $3c(a0), d0
	add.l   d0, oY(a0)
	subq.w  #$1, $30(a0)
	bpl.s   PAB_loc_20ED7E
	addq.b  #$2, oRoutine(a0)
PAB_loc_20ED7E:
	rts     
PAB_loc_20ED80:
	addq.b  #$2, oRoutine(a0)
	clr.w   oYVel(a0)
	move.w  #$1e, d0
	cmpi.b  #$2, $28(a1)
	bne.s   PAB_loc_20ED98
	move.w  #$0, d0
PAB_loc_20ED98:
	move.w  d0, $30(a0)
PAB_loc_20ED9C:
	subq.w  #$1, $30(a0)
	bpl.s   PAB_loc_20EDB8
	addq.b  #$2, oRoutine(a0)
	bsr.w   PAB_sub_20EE3C
	beq.s   PAB_loc_20EDB8
	addq.b  #$2, oRoutine(a0)
	movea.w $2a(a0), a1
	st.b    $34(a1)
PAB_loc_20EDB8:
	rts     
PAB_loc_20EDBA:
	rts     
PAB_loc_20EDBC:
	addq.b  #$2, oRoutine(a0)
	move.w  #$3f, $30(a0)
	move.w  $34(a0), oYVel(a0)
	neg.w   oYVel(a0)
PAB_loc_20EDD0:
	move.l  $38(a0), d0
	sub.l   d0, oX(a0)
	move.l  $3c(a0), d0
	sub.l   d0, oY(a0)
	subq.w  #$1, $30(a0)
	bpl.s   PAB_loc_20EDEA
	addq.b  #$2, oRoutine(a0)
PAB_loc_20EDEA:
	rts     
PAB_loc_20EDEC:
	addq.b  #$2, oRoutine(a0)
	clr.w   oYVel(a0)
	move.w  #$1e, d0
	cmpi.b  #$2, $28(a1)
	bne.s   PAB_loc_20EE04
	move.w  #$0, d0
PAB_loc_20EE04:
	move.w  d0, $30(a0)
PAB_loc_20EE08:
	subq.w  #$1, $30(a0)
	bpl.s   PAB_loc_20EE20
	movea.w $36(a0), a1
	tst.b   $28(a1)
	bpl.s   PAB_loc_20EE1C
	addq.b  #$2, $24(a1)
PAB_loc_20EE1C:
	addq.b  #$2, oRoutine(a0)
PAB_loc_20EE20:
	rts     
PAB_loc_20EE22:
	lea     objects.w, a1
	jsr     SolidObject.l
	beq.s   PAB_loc_20EE34
	jsr     GetOffObject.l
PAB_loc_20EE34:
	addq.l  #$4, a7
PAB_loc_20EE36:
	jmp     DeleteObject.l
