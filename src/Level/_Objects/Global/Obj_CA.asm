; Object $CA - Obj2C_20D54E (from R81A, old ID $2C)
Obj2C_20D54E:
	tst.b   oSubtype(a0)
	bpl.s   PCA_loc_20D57A
	movea.w $2c(a0), a1
	dc.b	$0C,$29,$00,$2C,$00,$00		; cmpi.b #$2c, $0(a1) (raw: not reproducible by assembler)
	bne.w   PCA_loc_20D6C2
	move.w  $2e(a0), d0
	cmp.w   $2e(a1), d0
	bne.w   PCA_loc_20D6C2
	move.w  $30(a0), d0
	cmp.w   $30(a1), d0
	bne.w   PCA_loc_20D6C2
PCA_loc_20D57A:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PCA_dat_20D5A0(pc, d0.w), d0
	jsr     PCA_dat_20D5A0(pc, d0.w)
	jsr     DrawObject.l
	tst.b   oSubtype(a0)
	bmi.s   PCA_loc_20D59E
	move.w  $2e(a0), d0
	jmp     CheckObjDespawn2.l
PCA_loc_20D59E:
	rts     
PCA_dat_20D5A0:
	dc.w	PCA_loc_20D5AA-PCA_dat_20D5A0
	dc.w	PCA_loc_20D64C-PCA_dat_20D5A0
	dc.w	PCA_loc_20D65A-PCA_dat_20D5A0
	dc.w	PCA_loc_20D676-PCA_dat_20D5A0
	dc.w	PCA_loc_20D6A4-PCA_dat_20D5A0
PCA_loc_20D5AA:
	lea     PCA_dat_20D7F2(pc), a5
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	add.w   d0, d0
	adda.w  (a5, d0.w), a5
	move.w  (a5)+, $2a(a0)
	lea     (a0), a6
	bsr.s   PCA_sub_20D606
	move.w  (a5)+, d6
	bra.s   PCA_loc_20D600
PCA_loc_20D5C6:
	jsr     FindObjSlot.l
	beq.s   PCA_loc_20D5D4
	jmp     DeleteObject.l
PCA_loc_20D5D4:
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.w  a0, $2c(a1)
	move.b  #$ff, $28(a1)
	move.w  (a5)+, $2a(a1)
	move.w  oX(a0), d0
	move.w  oY(a0), d1
	add.w   (a5)+, d0
	add.w   (a5)+, d1
	move.w  d0, $8(a1)
	move.w  d1, $c(a1)
	lea     (a1), a6
	bsr.s   PCA_sub_20D606
PCA_loc_20D600:
	dbra    d6, PCA_loc_20D5C6
	rts     
PCA_dat_20D7F2:
	dc.w	$0006,$000A,$0014,$003C,$0000,$003C,$0001,$003C
	dc.w	$0020,$0000,$005A,$0002,$00B4,$0020,$0010,$010E
	dc.w	$0040,$0020
PCA_sub_20D606:
	ori.b   #$4, $1(a6)
	move.b  #$3, $18(a6)
	move.b  #$10, $17(a6)
	move.b  #$10, $19(a6)
	move.b  #$10, $16(a6)
	move.w  #$398, $2(a6)
	move.l  #$20d6c8, $4(a6)
	move.b  #$6, $1a(a6)
	move.b  #$2, $24(a6)
	move.w  oX(a0), $2e(a6)
	move.w  oY(a0), $30(a6)
	rts     
PCA_loc_20D64C:
	addi.w  #$ffff, $2a(a0)
	bne.s   PCA_loc_20D658
	addq.b  #$2, oRoutine(a0)
PCA_loc_20D658:
	rts     
PCA_loc_20D65A:
	lea     PCA_dat_20D726(pc), a1
	jsr     AnimateObject.l
	tst.b   oMapFrame(a0)
	bne.s   PCA_loc_20D674
	move.w  #$78, $2a(a0)
	addq.b  #$2, oRoutine(a0)
PCA_loc_20D674:
	rts     
PCA_loc_20D676:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	sne.b   $3f(a0)
	addi.w  #$ffff, $2a(a0)
	bne.s   PCA_loc_20D6A2
	move.w  #$1ff, oAnim(a0)
	addq.b  #$2, oRoutine(a0)
	tst.b   $3f(a0)
	beq.s   PCA_loc_20D6A2
	jmp     GetOffObject.l
PCA_loc_20D6A2:
	rts     
PCA_loc_20D6A4:
	lea     PCA_dat_20D726(pc), a1
	jsr     AnimateObject.l
	tst.b   oMapFrame(a0)
	bne.s   PCA_loc_20D6C0
	move.w  #$78, $2a(a0)
	addi.b  #$fe, oRoutine(a0)
PCA_loc_20D6C0:
	rts     
PCA_loc_20D6C2:
	jmp     DeleteObject.l
PCA_loc_20D6C8:
	dc.w	$0010,$0025,$003A,$0045,$0050,$0056,$005C,$0010
	dc.w	$04F0,$0300,$04F0,$F003,$0004,$F8F0,$0300,$0400
	dc.w	$F003,$0004,$0804,$F003,$0000,$F0F0,$0300,$00F8
	dc.w	$F003,$0000,$00F0,$0300,$0008,$02F0,$0300,$04F8
	dc.w	$F003,$0004,$0002,$F003,$0000,$F8F0,$0300,$0000
	dc.w	$01F0,$0300,$04FC,$01F0,$0300,$00FC,$0000
PCA_dat_20D726:
	dc.w	$0004,$0033,$0005,$0505,$0505,$0404,$0405,$0505
	dc.w	$0505,$0404,$0403,$0303,$0303,$0202,$0203,$0303
	dc.w	$0303,$0202,$0201,$0101,$0101,$0707,$0701,$0101
	dc.w	$0101,$0000,$0101,$0101,$0107,$0707,$0101,$0101
	dc.w	$0102,$0202,$0303,$0303,$0302,$0202,$0303,$0303
	dc.w	$0304,$0404,$0505,$0505,$0504,$0404,$0505,$0505
	dc.w	$0506,$0606,$0606,$0606,$0606,$0606,$0606,$0606
	dc.w	$0606,$0606,$0606,$0606,$0606,$0606,$0606,$0606
	dc.w	$0606,$0606,$0606,$0606,$0606,$0606,$0606,$0606
	dc.w	$0606,$0606,$0606,$0606,$0606,$0606,$0605,$0505
	dc.w	$0505,$0404,$0405,$0505,$0505,$0404,$0403,$0303
	dc.w	$0303,$0202,$0203,$0303,$0303,$0202,$0201,$0101
	dc.w	$0101,$0707,$0701,$0101,$0101,$0000
