; Object $BD - ObjPataBata (from R71A, old ID $21)
ObjPataBata:
	jsr     DestroyOnGoodFuture.l
	tst.b   oRoutine(a0)
	bne.w   ObjPataBata_Main
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$23e9, oTile(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  oX(a0), $3a(a0)
	move.w  oY(a0), $2e(a0)
	move.w  #$8000, $30(a0)
	lea     PBD_dat_20D23E(pc), a1
	lea     PBD_dat_20D1B6(pc), a2
	move.w  #$fe00, d0
	move.l  #$ffffc000, d1
	tst.b   oSubtype(a0)
	beq.s   PBD_loc_20D11E
	lea     PBD_dat_20D332(pc), a1
	lea     PBD_dat_20D1FA(pc), a2
	move.w  #$ff00, d0
	move.l  #$ffffc000, d1
PBD_loc_20D11E:
	move.l  a1, oMap(a0)
	move.l  a2, $36(a0)
	move.w  d0, $34(a0)
	move.l  d1, $3c(a0)
ObjPataBata_Main:
	move.l  oX(a0), d6
	add.l   $3c(a0), d6
	move.l  d6, d0
	swap    d0
	sub.w   $3a(a0), d0
	bpl.s   PBD_loc_20D142
	neg.w   d0
PBD_loc_20D142:
	cmpi.w  #$40, d0
	ble.s   PBD_loc_20D166
	neg.l   $3c(a0)
	add.l   $3c(a0), d6
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	clr.w   $32(a0)
	move.w  #$ff, oAnim(a0)
PBD_loc_20D166:
	move.l  d6, oX(a0)
	move.w  $32(a0), d0
	add.w   $34(a0), d0
	move.w  d0, $32(a0)
	lsr.w   #$8, d0
	jsr     CalcSine.l
	swap    d0
	asr.l   #$2, d0
	add.l   $2e(a0), d0
	move.l  d0, oY(a0)
	movea.l $36(a0), a1
	jsr     AnimateObject.l
	lea     PBD_dat_20D41C(pc), a1
	moveq   #$0, d0
	move.b  oMapFrame(a0), d0
	lsr.b   #$1, d0
	move.b  (a1, d0.w), oColType(a0)
	jsr     DrawObject.l
	move.w  $3a(a0), d0
	jmp     CheckObjDespawn2.l
PBD_dat_20D23E:
	dc.w	$0010,$0016,$0044,$0063,$0087,$00A6,$00CA,$00DF
	dc.w	$01F0,$0F80,$00F0,$09F0,$0080,$10F0,$F000,$8011
	dc.w	$F8F0,$0080,$1200,$F805,$8013,$F0F8,$0080,$1700
	dc.w	$F800,$8018,$0800,$0480,$1900,$0800,$801B,$F808
	dc.w	$0090,$1200,$06F4,$0880,$1CF4,$FC04,$801F,$F4FC
	dc.w	$0080,$2104,$0400,$8022,$F404,$0080,$23FC,$0400
	dc.w	$8024,$0407,$F400,$8025,$F4F4,$0480,$26FC,$FC04
	dc.w	$8028,$F4FC,$0480,$2A04,$0400,$802C,$F404,$0480
	dc.w	$2DFC,$0C04,$802F,$FC06,$F408,$001C,$F4FC,$0400
	dc.w	$1FF4,$FC00,$0021,$0404,$0000,$22F4,$0400,$0023
	dc.w	$FC04,$0000,$2404,$07F4,$0000,$25F4,$F404,$0026
	dc.w	$FCFC,$0400,$28F4,$FC04,$002A,$0404,$0000,$2CF4
	dc.w	$0404,$002D,$FC0C,$0400,$2FFC,$04F4,$0900,$31F4
	dc.w	$0400,$0037,$F404,$0000,$38FC,$0400,$0039,$0404
	dc.w	$F405,$003A,$F4FC,$0000,$3E04,$0400,$003F,$F404
	dc.w	$0000,$40FC
PBD_dat_20D1B6:
	dc.w	$0002,$0106,$0706,$0706,$0706,$0704,$0504,$0504
	dc.w	$0504,$0502,$0302,$0302,$0302,$0300,$0100,$0100
	dc.w	$0100,$0100,$0100,$0100,$0100,$0102,$0302,$0302
	dc.w	$0302,$0304,$0504,$0504,$0504,$0506,$0706,$0706
	dc.w	$0706,$07FF
PBD_dat_20D332:
	dc.w	$0010,$0016,$003A,$0059,$007D,$009C,$00C0,$00D5
	dc.w	$01F0,$0F80,$41F0,$07F0,$0080,$10F0,$F004,$8051
	dc.w	$F8F8,$0880,$53F0,$F800,$8018,$0800,$0480,$56F0
	dc.w	$0004,$8019,$0008,$0480,$58F8,$06F4,$0880,$5AF4
	dc.w	$FC04,$805D,$F4FC,$0080,$2104,$0400,$805F,$F404
	dc.w	$0080,$23FC,$0400,$8060,$0407,$F400,$8025,$F4F4
	dc.w	$0480,$61FC,$FC04,$8063,$F4FC,$0480,$2A04,$0400
	dc.w	$802C,$F404,$0480,$65FC,$0C04,$802F,$FC06,$F408
	dc.w	$005A,$F4FC,$0400,$5DF4,$FC00,$0021,$0404,$0000
	dc.w	$5FF4,$0400,$0023,$FC04,$0000,$6004,$07F4,$0000
	dc.w	$25F4,$F404,$0061,$FCFC,$0400,$63F4,$FC04,$002A
	dc.w	$0404,$0000,$2CF4,$0404,$0065,$FC0C,$0400,$2FFC
	dc.w	$04F4,$0900,$67F4,$0400,$006D,$F404,$0000,$38FC
	dc.w	$0400,$006E,$0404,$F405,$006F,$F4FC,$0000,$3E04
	dc.w	$0400,$003F,$F404,$0000,$73FC
PBD_dat_20D1FA:
	dc.w	$0002,$0306,$0706,$0706,$0706,$0704,$0504,$0504
	dc.w	$0504,$0502,$0302,$0302,$0302,$0300,$0100,$0100
	dc.w	$0100,$0100,$0100,$0100,$0100,$0102,$0302,$0302
	dc.w	$0302,$0304,$0504,$0504,$0504,$0506,$0706,$0706
	dc.w	$0706,$07FF
PBD_dat_20D41C:
	dc.w	$2F30,$3000
