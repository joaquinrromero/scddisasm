; Object $AF - Obj22_20D420 (from R71A, old ID $22)
PAF_Obj22_20D420:
	move.b  oLayer(a0), d0
	bpl.s   PAF_loc_20D440
	addq.b  #$1, d0
	beq.s   PAF_loc_20D42E
	bra.w   PAF_loc_20D66E
PAF_loc_20D42E:
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$22,$00,$00		; cmpi.b #$22, $0(a1) (raw: not reproducible by assembler)
	beq.s   PAF_loc_20D446
PAF_loc_20D43A:
	jmp     DeleteObject.l
PAF_loc_20D440:
	jsr     DestroyOnGoodFuture.l
PAF_loc_20D446:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PAF_dat_20D46A(pc, d0.w), d0
	jsr     PAF_dat_20D46A(pc, d0.w)
	lea     PAF_Data_20D6DE(pc), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
PAF_dat_20D46A:
	dc.w	PAF_loc_20D46E-PAF_dat_20D46A
	dc.w	PAF_loc_20D566-PAF_dat_20D46A
PAF_loc_20D46E:
	move.b  #$31, oColType(a0)
	move.w  oX(a0), $2a(a0)
	move.w  oY(a0), $2e(a0)
	move.w  #$8000, $2c(a0)
	move.w  #$8000, $30(a0)
	move.w  #$200, d0
	move.w  #$100, d1
	moveq   #$4, d2
	tst.b   oSubtype(a0)
	beq.s   PAF_loc_20D4A6
	move.w  #$100, d0
	move.w  #$80, d1
	moveq   #$0, d2
PAF_loc_20D4A6:
	move.w  d0, $36(a0)
	move.w  d1, $38(a0)
	move.b  d2, oAnim(a0)
	movea.w a0, a1
	bsr.s   PAF_sub_20D532
	moveq   #$2, d6
	move.w  #$1000, d5
	move.w  #$800, d4
	tst.b   oSubtype(a0)
	beq.s   PAF_loc_20D4CE
	move.w  #$2000, d5
	move.w  #$1000, d4
PAF_loc_20D4CE:
	moveq   #$0, d3
	moveq   #$0, d2
	moveq   #$0, d1
PAF_loc_20D4D4:
	jsr     FindNextObjSlot.l
	bne.w   PAF_loc_20D43A
	move.w  a0, $3e(a1)
	addq.b  #$1, d1
	move.b  d1, d0
	add.b   oAnim(a0), d0
	move.b  d0, $1c(a1)
	sub.w   d5, d3
	sub.w   d4, d2
	move.w  d3, $32(a1)
	move.w  d2, $34(a1)
	move.b  #$ff, $29(a1)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.l  $2a(a0), $2a(a1)
	move.l  $2e(a0), $2e(a1)
	move.w  $36(a0), $36(a1)
	move.w  $38(a0), $38(a1)
	bsr.s   PAF_sub_20D532
	dbra    d6, PAF_loc_20D4D4
	rts     
PAF_Data_20D6DE:
	incbin	"Level/Stardust Speedway/Data/Misc/PAF_Data_20D6DE.bin"
PAF_loc_20DBA4:
	dc.w	$001C,$0027,$0032,$003D,$0048,$0053,$005E,$0069
	dc.w	$0074,$007F,$008A,$0095,$00A0,$00A1,$02F8,$0500
	dc.w	$00F8,$FA04,$0018,$F802,$F805,$0000,$F8FA,$0410
	dc.w	$18F8,$02F8,$0500,$04F8,$FA08,$001C,$F402,$F805
	dc.w	$0004,$F8FA,$0800,$1FF4,$02FB,$0000,$22F6,$F805
	dc.w	$0008,$F802,$FB00,$1022,$F6F8,$0500,$08F8,$02FA
	dc.w	$0800,$1CF4,$F805,$000C,$F802,$FA08,$001F,$F4F8
	dc.w	$0500,$0CF8,$02FA,$0400,$18F8,$F805,$0010,$F802
	dc.w	$FA04,$1018,$F8F8,$0500,$10F8,$02FB,$0000,$1AFF
	dc.w	$F805,$0014,$F802,$FB00,$001B,$FFF8,$0500,$14F8
	dc.w	$0002,$FB00,$8022,$F6F8,$0580,$08F8
PAF_sub_20D532:
	move.b  #$2, $24(a1)
	ori.b   #$4, $1(a1)
	move.b  #$3, $18(a1)
	move.b  #$c, $17(a1)
	move.b  #$c, $19(a1)
	move.b  #$8, $16(a1)
	move.w  #$23c6, $2(a1)
	move.l  #$20dba4, $4(a1)
	rts     
PAF_loc_20D566:
	tst.b   oSubtype(a0)
	bne.w   PAF_loc_20D604
	tst.b   oLayer(a0)
	bmi.w   PAF_loc_20D604
	tst.w   $3a(a0)
	beq.s   PAF_loc_20D584
	subq.w  #$1, $3a(a0)
	bra.w   PAF_loc_20D604
PAF_loc_20D584:
	lea     objects.w, a2
	bsr.w   PAF_sub_20D646
	bcc.w   PAF_loc_20D604
	move.w  #$f0, $3a(a0)
	jsr     FindObjSlot.l
	bne.s   PAF_loc_20D604
	move.b  #$8, $1c(a1)
	move.b  #$fe, $29(a1)
	move.b  #$f1, $20(a1)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	bsr.w   PAF_sub_20D532
	move.w  d5, d1
	move.w  d6, d2
	jsr     CalcAngle.l
	jsr     CalcSine.l
	swap    d1
	swap    d0
	asr.l   #$7, d1
	asr.l   #$7, d0
	move.l  d0, $2e(a1)
	move.l  d1, $2a(a1)
	bpl.s   PAF_loc_20D5F4
	bchg.b  #$0, $1(a1)
	bchg.b  #$0, $22(a1)
PAF_loc_20D5F4:
	tst.b   oSprFlags(a0)
	bpl.s   PAF_loc_20D604
	move.w  #$a0, d0
	jsr     PlayFMSound.l
PAF_loc_20D604:
	move.w  $32(a0), d0
	add.w   $36(a0), d0
	move.w  d0, $32(a0)
	lsr.w   #$8, d0
	jsr     CalcSine.l
	swap    d0
	asr.l   #$4, d0
	add.l   $2a(a0), d0
	move.l  d0, oX(a0)
	move.w  $34(a0), d0
	add.w   $38(a0), d0
	move.w  d0, $34(a0)
	lsr.w   #$8, d0
	jsr     CalcSine.l
	swap    d1
	asr.l   #$2, d1
	add.l   $2e(a0), d1
	move.l  d1, oY(a0)
	rts     
PAF_sub_20D646:
	move.w  $c(a2), d0
	sub.w   oY(a0), d0
	move.w  d0, d6
	subi.w  #$ffa0, d0
	subi.w  #$c0, d0
	bcc.s   PAF_loc_20D66C
	move.w  $8(a2), d0
	sub.w   oX(a0), d0
	move.w  d0, d5
	subi.w  #$ff88, d0
	subi.w  #$f0, d0
PAF_loc_20D66C:
	rts     
PAF_loc_20D66E:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	move.l  $2e(a0), d0
	add.l   d0, oY(a0)
	tst.b   oColStatus(a0)
	beq.s   PAF_loc_20D6B0
	move.w  oX(a0), d5
	move.w  oY(a0), d6
	jsr     DeleteObject.l
	move.w  d5, oX(a0)
	move.w  d6, oY(a0)
	move.b  #$18, oID(a0)
	move.b  #$1, oSolidType(a0)
	move.w  #$9e, d0
	jmp     PlayFMSound.l
PAF_loc_20D6B0:
	lea     objects.w, a1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	bpl.s   PAF_loc_20D6C0
	neg.w   d0
PAF_loc_20D6C0:
	cmpi.w  #$e0, d0
	bgt.w   PAF_loc_20D43A
	lea     PAF_Data_20D6DE(pc), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
