; R31A (Collision Chaos Act 1 Present) - auto-disassembly (scdtrace/emit)
; load address $200000. MDPORT=1 builds the Mega Drive version (see MD Port/).
	if def(MDPORT)=0
	include	"Level/_Definitions.inc"
	endif

	if def(MDPORT)
	dcb.b	$200000-*,$FF		; the level lives at its original Word RAM address, now in cartridge ROM
	else
	org	$200000
	endif

	dc.w	$0000,$0000,$0000,$0000,$0020,$0100,$0020,$010C
	dc.w	$0020,$0112,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
JmpTo_Start:
	jmp     Start.l
JmpTo_Error:
	jmp     ErrorTrap.l
JmpTo_HInt:
	jmp     HInterrupt.l
JmpTo_VInt:
	jmp     VInterrupt.l
ErrorTrap:
	nop     
	nop     
	bra.s   ErrorTrap
Start:
	btst.b  #$6, IOCTRL3.l
	beq.s   loc_200136
	cmpi.l  #$696e6974, initFlag.l
	beq.w   loc_200166
loc_200136:
	lea     unkBuffer.l, a6
	moveq   #$0, d7
	move.w  #$ff, d6
	move.w  #$7f, d6
loc_200146:
	move.l  d7, (a6)+
	dbra    d6, loc_200146
	move.b  VERSION.l, d0
	andi.b  #$c0, d0
	move.b  d0, versionCache.l
	move.l  #$696e6974, initFlag.l
loc_200166:
	bsr.w   InitVDP
	bsr.w   InitControllers
	move.b  #$0, gameMode.w
	move.b  gameMode.w, d0
	andi.w  #$1c, d0
	jmp     GameModes(pc, d0.w)
GameModes:
	bra.w   LevelStart
PalCycle_Do:
	lea     palCycleTimers.w, a5
	lea     palCycleSteps.w, a4
	lea     PalCycleScript1.l, a1
	lea     PalCycleColors1.l, a2
	bsr.s   CycleColor
	lea     PalCycleScript2.l, a1
	lea     PalCycleColors2.l, a2
	bsr.s   CycleColor
	lea     PalCycleScript5.l, a1
	lea     PalCycleColors5.l, a2
	bsr.s   CycleColor
	lea     PalCycleScript6.l, a1
	lea     PalCycleColors6.l, a2
CycleColor:
	subq.b  #$1, (a5)
	bpl.s   loc_2001F6
	moveq   #$0, d0
	move.b  (a1)+, d0
	move.b  (a1)+, d1
	add.w   d0, d0
	lea     palette.w, a3
	lea     (a3, d0.w), a3
	moveq   #$0, d0
	move.b  (a4), d0
	addq.b  #$1, d0
	cmp.b   d1, d0
	bcs.s   loc_2001E2
	moveq   #$0, d0
loc_2001E2:
	move.b  d0, (a4)
	add.w   d0, d0
	move.b  (a1, d0.w), (a5)
	move.b  $1(a1, d0.w), d0
	ext.w   d0
	add.w   d0, d0
	move.w  (a2, d0.w), (a3)
loc_2001F6:
	adda.w  #$1, a4
	adda.w  #$1, a5
	rts     
PalCycleScript1:
	dc.w	$2F03,$0100,$0101,$0202
PalCycleColors1:
	dc.w	$00EE,$000E,$0000
PalCycleScript2:
	dc.w	$3C10,$0100,$0201,$0100,$0201,$0100,$0201,$0100
	dc.w	$0201,$0100,$0201,$0100,$0201,$0100,$0201,$0100
	dc.w	$0801
PalCycleColors2:
	dc.w	$00EE,$0000
PalCycleScript5:
	dc.w	$3D0F,$1600,$0201,$0200,$0201,$0200,$0201,$0200
	dc.w	$0201,$0200,$0102,$0201,$0102,$0201,$0102,$0201
PalCycleColors5:
	dc.w	$0000,$0E0E,$0EAE
PalCycleScript6:
	dc.w	$3F02,$0100,$0201
PalCycleColors6:
	dc.w	$0EE0,$0000
FadeFromBlack:
	moveq   #$0, d0
	lea     palette.w, a0
	move.b  palFadeInfo.w, d0
	adda.w  d0, a0
	moveq   #$0, d1
	move.b  palFadeLen.w, d0
loc_200276:
	move.w  d1, (a0)+
	dbra    d0, loc_200276
	move.w  #$15, d4
loc_200280:
	move.b  #$12, vintRoutine.w
	bsr.w   VSync
	bsr.s   FadeColorsFromBlack
	bsr.w   ProcessPLCs
	dbra    d4, loc_200280
	rts     
FadeColorsFromBlack:
	moveq   #$0, d0
	lea     palette.w, a0
	lea     fadePalette.w, a1
	move.b  palFadeInfo.w, d0
	adda.w  d0, a0
	adda.w  d0, a1
	move.b  palFadeLen.w, d0
loc_2002AC:
	bsr.s   FadeColorFromBlack
	dbra    d0, loc_2002AC
	cmpi.b  #$1, zoneAct.l
	bne.s   loc_2002D8
	moveq   #$0, d0
	lea     waterPalette.w, a0
	lea     waterFadePal.w, a1
	move.b  palFadeInfo.w, d0
	adda.w  d0, a0
	adda.w  d0, a1
	move.b  palFadeLen.w, d0
loc_2002D2:
	bsr.s   FadeColorFromBlack
	dbra    d0, loc_2002D2
loc_2002D8:
	rts     
FadeColorFromBlack:
	move.w  (a1)+, d2
	move.w  (a0), d3
	cmp.w   d2, d3
	beq.s   loc_200302
	move.w  d3, d1
	addi.w  #$200, d1
	cmp.w   d2, d1
	bhi.s   loc_2002F0
	move.w  d1, (a0)+
	rts     
loc_2002F0:
	move.w  d3, d1
	addi.w  #$20, d1
	cmp.w   d2, d1
	bhi.s   loc_2002FE
	move.w  d1, (a0)+
	rts     
loc_2002FE:
	addq.w  #$2, (a0)+
	rts     
loc_200302:
	addq.w  #$2, a0
	rts     
FadeToBlack:
	move.w  #$3f, palFadeInfo.w
	move.w  #$15, d4
loc_200310:
	move.b  #$12, vintRoutine.w
	bsr.w   VSync
	bsr.s   FadeColorsToBlack
	bsr.w   ProcessPLCs
	dbra    d4, loc_200310
	rts     
FadeColorsToBlack:
	moveq   #$0, d0
	lea     palette.w, a0
	move.b  palFadeInfo.w, d0
	adda.w  d0, a0
	move.b  palFadeLen.w, d0
loc_200336:
	bsr.s   FadeColorToBlack
	dbra    d0, loc_200336
	moveq   #$0, d0
	lea     waterPalette.w, a0
	move.b  palFadeInfo.w, d0
	adda.w  d0, a0
	move.b  palFadeLen.w, d0
loc_20034C:
	bsr.s   FadeColorToBlack
	dbra    d0, loc_20034C
	rts     
FadeColorToBlack:
	move.w  (a0), d2
	beq.s   loc_200380
	move.w  d2, d1
	andi.w  #$e, d1
	beq.s   loc_200364
	subq.w  #$2, (a0)+
	rts     
loc_200364:
	move.w  d2, d1
	andi.w  #$e0, d1
	beq.s   loc_200372
	subi.w  #$20, (a0)+
	rts     
loc_200372:
	move.w  d2, d1
	andi.w  #$e00, d1
	beq.s   loc_200380
	subi.w  #$200, (a0)+
	rts     
loc_200380:
	addq.w  #$2, a0
	rts     
FadeFromWhite:
	move.w  #$3f, palFadeInfo.w
	moveq   #$0, d0
	lea     palette.w, a0
	move.b  palFadeInfo.w, d0
	adda.w  d0, a0
	move.w  #$eee, d1
	move.b  palFadeLen.w, d0
loc_20039E:
	move.w  d1, (a0)+
	dbra    d0, loc_20039E
	move.w  #$15, d4
loc_2003A8:
	move.b  #$12, vintRoutine.w
	bsr.w   VSync
	bsr.s   sub_2003BE
	bsr.w   ProcessPLCs
	dbra    d4, loc_2003A8
	rts     
sub_2003BE:
	moveq   #$0, d0
	lea     palette.w, a0
	lea     fadePalette.w, a1
	move.b  palFadeInfo.w, d0
	adda.w  d0, a0
	adda.w  d0, a1
	move.b  palFadeLen.w, d0
loc_2003D4:
	bsr.s   FadeColorFromWhite
	dbra    d0, loc_2003D4
	cmpi.b  #$1, zoneAct.l
	bne.s   loc_200400
	moveq   #$0, d0
	lea     waterPalette.w, a0
	lea     waterFadePal.w, a1
	move.b  palFadeInfo.w, d0
	adda.w  d0, a0
	adda.w  d0, a1
	move.b  palFadeLen.w, d0
loc_2003FA:
	bsr.s   FadeColorFromWhite
	dbra    d0, loc_2003FA
loc_200400:
	rts     
FadeColorFromWhite:
	move.w  (a1)+, d2
	move.w  (a0), d3
	cmp.w   d2, d3
	beq.s   loc_20042E
	move.w  d3, d1
	subi.w  #$200, d1
	bcs.s   loc_20041A
	cmp.w   d2, d1
	bcs.s   loc_20041A
	move.w  d1, (a0)+
	rts     
loc_20041A:
	move.w  d3, d1
	subi.w  #$20, d1
	bcs.s   loc_20042A
	cmp.w   d2, d1
	bcs.s   loc_20042A
	move.w  d1, (a0)+
	rts     
loc_20042A:
	subq.w  #$2, (a0)+
	rts     
loc_20042E:
	addq.w  #$2, a0
	rts     
FadeToWhite:
	move.w  #$3f, palFadeInfo.w
	move.w  #$15, d4
loc_20043C:
	move.b  #$12, vintRoutine.w
	bsr.w   VSync
	bsr.s   sub_200452
	bsr.w   ProcessPLCs
	dbra    d4, loc_20043C
	rts     
sub_200452:
	moveq   #$0, d0
	lea     palette.w, a0
	move.b  palFadeInfo.w, d0
	adda.w  d0, a0
	move.b  palFadeLen.w, d0
loc_200462:
	bsr.s   FadeColorToWhite
	dbra    d0, loc_200462
	moveq   #$0, d0
	lea     waterPalette.w, a0
	move.b  palFadeInfo.w, d0
	adda.w  d0, a0
	move.b  palFadeLen.w, d0
loc_200478:
	bsr.s   FadeColorToWhite
	dbra    d0, loc_200478
	rts     
FadeColorToWhite:
	move.w  (a0), d2
	cmpi.w  #$eee, d2
	beq.s   loc_2004BC
	move.w  d2, d1
	andi.w  #$e, d1
	cmpi.w  #$e, d1
	beq.s   loc_200498
	addq.w  #$2, (a0)+
	rts     
loc_200498:
	move.w  d2, d1
	andi.w  #$e0, d1
	cmpi.w  #$e0, d1
	beq.s   loc_2004AA
	addi.w  #$20, (a0)+
	rts     
loc_2004AA:
	move.w  d2, d1
	andi.w  #$e00, d1
	cmpi.w  #$e00, d1
	beq.s   loc_2004BC
	addi.w  #$200, (a0)+
	rts     
loc_2004BC:
	addq.w  #$2, a0
	rts     
LoadFadePal:
	lea     PaletteTable.l, a1
	lsl.w   #$3, d0
	adda.w  d0, a1
	movea.l (a1)+, a2
	movea.w (a1)+, a3
	adda.w  #$80, a3
	move.w  (a1)+, d7
loc_2004D4:
	move.l  (a2)+, (a3)+
	dbra    d7, loc_2004D4
	rts     
LoadPalette:
	lea     PaletteTable.l, a1
	lsl.w   #$3, d0
	adda.w  d0, a1
	movea.l (a1)+, a2
	movea.w (a1)+, a3
	move.w  (a1)+, d7
loc_2004EC:
	move.l  (a2)+, (a3)+
	dbra    d7, loc_2004EC
	rts     
	lea     PaletteTable.l, a1
	lsl.w   #$3, d0
	adda.w  d0, a1
	movea.l (a1)+, a2
	movea.w (a1)+, a3
	suba.w  #$80, a3
	move.w  (a1)+, d7
loc_200508:
	move.l  (a2)+, (a3)+
	dbra    d7, loc_200508
	rts     
	lea     PaletteTable.l, a1
	lsl.w   #$3, d0
	adda.w  d0, a1
	movea.l (a1)+, a2
	movea.w (a1)+, a3
	suba.w  #$100, a3
	move.w  (a1)+, d7
loc_200524:
	move.l  (a2)+, (a3)+
	dbra    d7, loc_200524
	rts     
PaletteTable:
	dc.w	$0020,$055C,$FB00,$001F,$0020,$055C,$FB00,$001F
	dc.w	$0020,$05DC,$FB00,$001F,$0020,$065C,$FB00,$0007
	dc.w	$0020,$067C,$FB20,$0017,$0020,$06DC,$FB20,$0017
	dc.w	$0A20,$0600,$0C00,$0E44,$0E66,$0E88,$0EEE,$00AE
	dc.w	$006A,$0026,$00EE,$0EAA,$000C,$0006,$0002,$0000
	dc.w	$0000,$0C00,$0E22,$0E44,$0E66,$0E88,$0EEE,$0AAA
	dc.w	$0888,$0666,$0444,$0248,$08AE,$068C,$0000,$000E
	dc.w	$0800,$0002,$0EEE,$0026,$0048,$006C,$008E,$00CE
	dc.w	$0C42,$0E86,$0ECA,$0EEC,$0040,$0060,$00A4,$00E8
	dc.w	$0C82,$0A02,$0C42,$0E86,$0ECA,$0EEC,$0EEE,$0EAC
	dc.w	$0E8A,$0E68,$00E8,$00A4,$0002,$0026,$006C,$00CE
	dc.w	$0000,$0000,$0002,$0002,$0224,$0224,$0446,$0446
	dc.w	$0224,$0224,$0446,$0668,$0224,$0002,$0000,$0000
	dc.w	$0000,$0000,$0002,$0224,$0224,$0446,$0668,$0224
	dc.w	$0446,$0224,$0002,$0224,$0446,$0224,$0000,$0224
	dc.w	$0000,$00EE,$0000,$0000,$0000,$0000,$00EE,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0EEC,$0000,$0000,$0000,$0000,$0EEC,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0822,$0A44,$0C66,$0E88,$0EEE,$0AAA
	dc.w	$0888,$0444,$08AE,$046A,$000E,$0008,$0004,$00EE
loc_20067C:
	dc.w	$0666,$0000,$0E42,$0E86,$0060,$00A0,$0EEE,$0888
	dc.w	$0444,$0C20,$0006,$006E,$00EE,$0088,$0044,$000E
	dc.w	$0804,$06EE,$0A6E,$084E,$082C,$0406,$0204,$00E2
	dc.w	$00A0,$0040,$0000,$0EEE,$0EA0,$0E04,$040A,$00AE
	dc.w	$0804,$00EE,$006E,$004A,$0028,$0002,$006E,$080C
	dc.w	$0808,$000E,$0000,$0880,$00EE,$0E0E,$0000,$00E0
	dc.w	$0666,$0000,$0E42,$0E86,$0060,$00A0,$0EEE,$0888
	dc.w	$0444,$0C20,$0006,$006E,$00EE,$0088,$0044,$000E
	dc.w	$0804,$06EE,$0A6E,$084E,$082C,$0406,$0204,$00E0
	dc.w	$00A0,$0040,$0000,$0EEE,$0EA0,$0E04,$040A,$00AE
	dc.w	$0804,$00EE,$006E,$004A,$0028,$0002,$006E,$080C
	dc.w	$0808,$000E,$0000,$0880,$00EE,$0E0E,$0000,$00E0
	dc.w	$3028,$0008,$0240,$FF80,$3238,$F700,$0441,$0080
	dc.w	$0241,$FF80,$9041,$0C40,$0280,$6200,$0006,$6000
	dc.w	$3312,$45F9,$00FF,$1200,$7000,$1028,$0023,$6706
	dc.w	$08B2,$0007,$0002,$6000,$33A6
VSync:
	move.w  #$2300, sr
loc_20077A:
	tst.b   vintRoutine.w
	bne.s   loc_20077A
	rts     
CalcSine:
	andi.w  #$ff, d0
	add.w   d0, d0
	addi.w  #$80, d0
	move.w  SineTable(pc, d0.w), d1
	subi.w  #$80, d0
	move.w  SineTable(pc, d0.w), d0
	rts     
SineTable:
	dc.w	$0000,$0006,$000C,$0012,$0019,$001F,$0025,$002B
	dc.w	$0031,$0038,$003E,$0044,$004A,$0050,$0056,$005C
	dc.w	$0061,$0067,$006D,$0073,$0078,$007E,$0083,$0088
	dc.w	$008E,$0093,$0098,$009D,$00A2,$00A7,$00AB,$00B0
	dc.w	$00B5,$00B9,$00BD,$00C1,$00C5,$00C9,$00CD,$00D1
	dc.w	$00D4,$00D8,$00DB,$00DE,$00E1,$00E4,$00E7,$00EA
	dc.w	$00EC,$00EE,$00F1,$00F3,$00F4,$00F6,$00F8,$00F9
	dc.w	$00FB,$00FC,$00FD,$00FE,$00FE,$00FF,$00FF,$00FF
	dc.w	$0100,$00FF,$00FF,$00FF,$00FE,$00FE,$00FD,$00FC
	dc.w	$00FB,$00F9,$00F8,$00F6,$00F4,$00F3,$00F1,$00EE
	dc.w	$00EC,$00EA,$00E7,$00E4,$00E1,$00DE,$00DB,$00D8
	dc.w	$00D4,$00D1,$00CD,$00C9,$00C5,$00C1,$00BD,$00B9
	dc.w	$00B5,$00B0,$00AB,$00A7,$00A2,$009D,$0098,$0093
	dc.w	$008E,$0088,$0083,$007E,$0078,$0073,$006D,$0067
	dc.w	$0061,$005C,$0056,$0050,$004A,$0044,$003E,$0038
	dc.w	$0031,$002B,$0025,$001F,$0019,$0012,$000C,$0006
	dc.w	$0000,$FFFA,$FFF4,$FFEE,$FFE7,$FFE1,$FFDB,$FFD5
	dc.w	$FFCF,$FFC8,$FFC2,$FFBC,$FFB6,$FFB0,$FFAA,$FFA4
	dc.w	$FF9F,$FF99,$FF93,$FF8B,$FF88,$FF82,$FF7D,$FF78
	dc.w	$FF72,$FF6D,$FF68,$FF63,$FF5E,$FF59,$FF55,$FF50
	dc.w	$FF4B,$FF47,$FF43,$FF3F,$FF3B,$FF37,$FF33,$FF2F
	dc.w	$FF2C,$FF28,$FF25,$FF22,$FF1F,$FF1C,$FF19,$FF16
	dc.w	$FF14,$FF12,$FF0F,$FF0D,$FF0C,$FF0A,$FF08,$FF07
	dc.w	$FF05,$FF04,$FF03,$FF02,$FF02,$FF01,$FF01,$FF01
	dc.w	$FF00,$FF01,$FF01,$FF01,$FF02,$FF02,$FF03,$FF04
	dc.w	$FF05,$FF07,$FF08,$FF0A,$FF0C,$FF0D,$FF0F,$FF12
	dc.w	$FF14,$FF16,$FF19,$FF1C,$FF1F,$FF22,$FF25,$FF28
	dc.w	$FF2C,$FF2F,$FF33,$FF37,$FF3B,$FF3F,$FF43,$FF47
	dc.w	$FF4B,$FF50,$FF55,$FF59,$FF5E,$FF63,$FF68,$FF6D
	dc.w	$FF72,$FF78,$FF7D,$FF82,$FF88,$FF8B,$FF93,$FF99
	dc.w	$FF9F,$FFA4,$FFAA,$FFB0,$FFB6,$FFBC,$FFC2,$FFC8
	dc.w	$FFCF,$FFD5,$FFDB,$FFE1,$FFE7,$FFEE,$FFF4,$FFFA
	dc.w	$0000,$0006,$000C,$0012,$0019,$001F,$0025,$002B
	dc.w	$0031,$0038,$003E,$0044,$004A,$0050,$0056,$005C
	dc.w	$0061,$0067,$006D,$0073,$0078,$007E,$0083,$0088
	dc.w	$008E,$0093,$0098,$009D,$00A2,$00A7,$00AB,$00B0
	dc.w	$00B5,$00B9,$00BD,$00C1,$00C5,$00C9,$00CD,$00D1
	dc.w	$00D4,$00D8,$00DB,$00DE,$00E1,$00E4,$00E7,$00EA
	dc.w	$00EC,$00EE,$00F1,$00F3,$00F4,$00F6,$00F8,$00F9
	dc.w	$00FB,$00FC,$00FD,$00FE,$00FE,$00FF,$00FF,$00FF
CalcAngle:
	movem.l d3-d4, -(a7)
	moveq   #$0, d3
	moveq   #$0, d4
	move.w  d1, d3
	move.w  d2, d4
	or.w    d3, d4
	beq.s   loc_200A76
	move.w  d2, d4
	tst.w   d3
	bpl.w   loc_200A34
	neg.w   d3
loc_200A34:
	tst.w   d4
	bpl.w   loc_200A3C
	neg.w   d4
loc_200A3C:
	cmp.w   d3, d4
	bcc.w   loc_200A4E
	lsl.l   #$8, d4
	divu.w  d3, d4
	moveq   #$0, d0
	move.b  ArcTanTable(pc, d4.w), d0
	bra.s   loc_200A58
loc_200A4E:
	lsl.l   #$8, d3
	divu.w  d4, d3
	moveq   #$40, d0
	sub.b   ArcTanTable(pc, d3.w), d0
loc_200A58:
	tst.w   d1
	bpl.w   loc_200A64
	neg.w   d0
	addi.w  #$80, d0
loc_200A64:
	tst.w   d2
	bpl.w   loc_200A70
	neg.w   d0
	addi.w  #$100, d0
loc_200A70:
	movem.l (a7)+, d3-d4
	rts     
loc_200A76:
	move.w  #$40, d0
	movem.l (a7)+, d3-d4
	rts     
ArcTanTable:
	dc.w	$0000,$0000,$0101,$0101,$0101,$0202,$0202,$0202
	dc.w	$0303,$0303,$0303,$0304,$0404,$0404,$0405,$0505
	dc.w	$0505,$0506,$0606,$0606,$0606,$0707,$0707,$0707
	dc.w	$0808,$0808,$0808,$0809,$0909,$0909,$090A,$0A0A
	dc.w	$0A0A,$0A0A,$0B0B,$0B0B,$0B0B,$0B0C,$0C0C,$0C0C
	dc.w	$0C0C,$0D0D,$0D0D,$0D0D,$0D0E,$0E0E,$0E0E,$0E0E
	dc.w	$0F0F,$0F0F,$0F0F,$0F10,$1010,$1010,$1010,$1111
	dc.w	$1111,$1111,$1111,$1212,$1212,$1212,$1213,$1313
	dc.w	$1313,$1313,$1314,$1414,$1414,$1414,$1415,$1515
	dc.w	$1515,$1515,$1515,$1616,$1616,$1616,$1616,$1717
	dc.w	$1717,$1717,$1717,$1718,$1818,$1818,$1818,$1818
	dc.w	$1919,$1919,$1919,$1919,$1919,$1A1A,$1A1A,$1A1A
	dc.w	$1A1A,$1A1B,$1B1B,$1B1B,$1B1B,$1B1B,$1B1C,$1C1C
	dc.w	$1C1C,$1C1C,$1C1C,$1C1C,$1D1D,$1D1D,$1D1D,$1D1D
	dc.w	$1D1D,$1D1E,$1E1E,$1E1E,$1E1E,$1E1E,$1E1E,$1F1F
	dc.w	$1F1F,$1F1F,$1F1F,$1F1F,$1F1F,$2020,$2020,$2020
	dc.w	$2000
Player_GroundCol:
	btst.b  #$3, oFlags(a0)
	beq.s   loc_200B96
	moveq   #$0, d0
	move.b  d0, primaryAngle.w
	move.b  d0, secondaryAngle.w
	rts     
loc_200B96:
	moveq   #$3, d0
	move.b  d0, primaryAngle.w
	move.b  d0, secondaryAngle.w
	move.b  oAngle(a0), d0
	addi.b  #$20, d0
	bpl.s   loc_200BB8
	move.b  oAngle(a0), d0
	bpl.s   loc_200BB2
	subq.b  #$1, d0
loc_200BB2:
	addi.b  #$20, d0
	bra.s   loc_200BC4
loc_200BB8:
	move.b  oAngle(a0), d0
	bpl.s   loc_200BC0
	addq.b  #$1, d0
loc_200BC0:
	addi.b  #$1f, d0
loc_200BC4:
	andi.b  #$c0, d0
	cmpi.b  #$40, d0
	beq.w   Player_WalkVertL
	cmpi.b  #$80, d0
	beq.w   Player_WalkCeiling
	cmpi.b  #$c0, d0
	beq.w   Player_WalkVertR
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oYRadius(a0), d0
	ext.w   d0
	add.w   d0, d2
	move.b  oXRadius(a0), d0
	ext.w   d0
	add.w   d0, d3
	lea     primaryAngle.w, a4
	movea.w #$10, a3
	move.w  #$0, d6
	moveq   #$d, d5
	bsr.w   FindLevelFloor
	move.w  d1, -(a7)
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oYRadius(a0), d0
	ext.w   d0
	add.w   d0, d2
	move.b  oXRadius(a0), d0
	ext.w   d0
	neg.w   d0
	add.w   d0, d3
	lea     secondaryAngle.w, a4
	movea.w #$10, a3
	move.w  #$0, d6
	moveq   #$d, d5
	bsr.w   FindLevelFloor
	move.w  (a7)+, d0
	bsr.w   Player_PickSensor
	tst.w   d1
	beq.s   loc_200C52
	bpl.s   loc_200C54
	cmpi.w  #$fff2, d1
	blt.s   Player_AnglePos_Done
	add.w   d1, oY(a0)
loc_200C52:
	rts     
loc_200C54:
	cmpi.w  #$e, d1
	bgt.s   loc_200C60
loc_200C5A:
	add.w   d1, oY(a0)
	rts     
loc_200C60:
	tst.b   $38(a0)
	bne.s   loc_200C5A
	bset.b  #$1, oFlags(a0)
	bclr.b  #$5, oFlags(a0)
	move.b  #$1, oPrevAnim(a0)
	rts     
Player_AnglePos_Done:
	rts     
	move.l  oX(a0), d2
	move.w  oXVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	sub.l   d0, d2
	move.l  d2, oX(a0)
	move.w  #$38, d0
	ext.l   d0
	asl.l   #$8, d0
	sub.l   d0, d3
	move.l  d3, oY(a0)
	rts     
Player_WalkVert_Done:
	rts     
	move.l  oY(a0), d3
	move.w  oYVel(a0), d0
	subi.w  #$38, d0
	move.w  d0, oYVel(a0)
	ext.l   d0
	asl.l   #$8, d0
	sub.l   d0, d3
	move.l  d3, oY(a0)
	rts     
	dc.w	$4E75,$2428,$0008,$2628,$000C,$3028,$0010,$48C0
	dc.w	$E180,$9480,$3028,$0012,$48C0,$E180,$9680,$2142
	dc.w	$0008,$2143,$000C,$4E75
Player_PickSensor:
	move.b  secondaryAngle.w, d2
	cmp.w   d0, d1
	ble.s   loc_200CF2
	move.b  primaryAngle.w, d2
	move.w  d0, d1
loc_200CF2:
	btst.l  #$0, d2
	bne.s   loc_200CFE
	move.b  d2, oAngle(a0)
	rts     
loc_200CFE:
	move.b  oAngle(a0), d2
	addi.b  #$20, d2
	andi.b  #$c0, d2
	move.b  d2, oAngle(a0)
	rts     
Player_WalkVertR:
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oXRadius(a0), d0
	ext.w   d0
	neg.w   d0
	add.w   d0, d2
	move.b  oYRadius(a0), d0
	ext.w   d0
	add.w   d0, d3
	lea     primaryAngle.w, a4
	movea.w #$10, a3
	move.w  #$0, d6
	moveq   #$d, d5
	bsr.w   FindLevelWall
	move.w  d1, -(a7)
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oXRadius(a0), d0
	ext.w   d0
	add.w   d0, d2
	move.b  oYRadius(a0), d0
	ext.w   d0
	add.w   d0, d3
	lea     secondaryAngle.w, a4
	movea.w #$10, a3
	move.w  #$0, d6
	moveq   #$d, d5
	bsr.w   FindLevelWall
	move.w  (a7)+, d0
	bsr.w   Player_PickSensor
	tst.w   d1
	beq.s   loc_200D84
	bpl.s   loc_200D86
	cmpi.w  #$fff2, d1
	blt.w   Player_WalkVert_Done
	add.w   d1, oX(a0)
loc_200D84:
	rts     
loc_200D86:
	cmpi.w  #$e, d1
	bgt.s   loc_200D92
loc_200D8C:
	add.w   d1, oX(a0)
	rts     
loc_200D92:
	tst.b   $38(a0)
	bne.s   loc_200D8C
	bset.b  #$1, oFlags(a0)
	bclr.b  #$5, oFlags(a0)
	move.b  #$1, oPrevAnim(a0)
	rts     
Player_WalkCeiling:
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oYRadius(a0), d0
	ext.w   d0
	sub.w   d0, d2
	eori.w  #$f, d2
	move.b  oXRadius(a0), d0
	ext.w   d0
	add.w   d0, d3
	lea     primaryAngle.w, a4
	movea.w #$fff0, a3
	move.w  #$1000, d6
	moveq   #$d, d5
	bsr.w   FindLevelFloor
	move.w  d1, -(a7)
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oYRadius(a0), d0
	ext.w   d0
	sub.w   d0, d2
	eori.w  #$f, d2
	move.b  oXRadius(a0), d0
	ext.w   d0
	sub.w   d0, d3
	lea     secondaryAngle.w, a4
	movea.w #$fff0, a3
	move.w  #$1000, d6
	moveq   #$d, d5
	bsr.w   FindLevelFloor
	move.w  (a7)+, d0
	bsr.w   Player_PickSensor
	tst.w   d1
	beq.s   loc_200E26
	bpl.s   loc_200E28
	cmpi.w  #$fff2, d1
	blt.w   Player_AnglePos_Done
	sub.w   d1, oY(a0)
loc_200E26:
	rts     
loc_200E28:
	cmpi.w  #$e, d1
	bgt.s   loc_200E34
loc_200E2E:
	sub.w   d1, oY(a0)
	rts     
loc_200E34:
	tst.b   $38(a0)
	bne.s   loc_200E2E
	bset.b  #$1, oFlags(a0)
	bclr.b  #$5, oFlags(a0)
	move.b  #$1, oPrevAnim(a0)
	rts     
Player_WalkVertL:
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oXRadius(a0), d0
	ext.w   d0
	sub.w   d0, d2
	move.b  oYRadius(a0), d0
	ext.w   d0
	sub.w   d0, d3
	eori.w  #$f, d3
	lea     primaryAngle.w, a4
	movea.w #$fff0, a3
	move.w  #$800, d6
	moveq   #$d, d5
	bsr.w   FindLevelWall
	move.w  d1, -(a7)
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oXRadius(a0), d0
	ext.w   d0
	add.w   d0, d2
	move.b  oYRadius(a0), d0
	ext.w   d0
	sub.w   d0, d3
	eori.w  #$f, d3
	lea     secondaryAngle.w, a4
	movea.w #$fff0, a3
	move.w  #$800, d6
	moveq   #$d, d5
	bsr.w   FindLevelWall
	move.w  (a7)+, d0
	bsr.w   Player_PickSensor
	tst.w   d1
	beq.s   loc_200EC8
	bpl.s   loc_200ECA
	cmpi.w  #$fff2, d1
	blt.w   Player_WalkVert_Done
	sub.w   d1, oX(a0)
loc_200EC8:
	rts     
loc_200ECA:
	cmpi.w  #$e, d1
	bgt.s   loc_200ED6
loc_200ED0:
	sub.w   d1, oX(a0)
	rts     
loc_200ED6:
	tst.b   $38(a0)
	bne.s   loc_200ED0
	bset.b  #$1, oFlags(a0)
	bclr.b  #$5, oFlags(a0)
	move.b  #$1, oPrevAnim(a0)
	rts     
GetLevelBlock:
	move.w  d2, d0
	lsr.w   #$1, d0
	andi.w  #$780, d0
	cmpi.b  #$2, zoneAct.l
	bne.s   loc_200F06
	andi.w  #$380, d0
loc_200F06:
	move.w  d3, d1
	lsr.w   #$8, d1
	andi.w  #$7f, d1
	add.w   d1, d0
	move.l  #$210000, d1
	lea     levelLayout.w, a1
	move.b  (a1, d0.w), d1
	beq.s   loc_200F66
	bmi.s   loc_200F6A
	cmpi.b  #$5, zoneAct.l
	beq.s   loc_200F36
	cmpi.b  #$6, zoneAct.l
	bne.s   loc_200F3C
loc_200F36:
	andi.w  #$7fff, oTile(a0)
loc_200F3C:
	cmpi.b  #$4, zoneAct.l
	bne.s   loc_200F4C
	bclr.b  #$6, oSprFlags(a0)
loc_200F4C:
	subq.b  #$1, d1
	ext.w   d1
	ror.w   #$7, d1
	move.w  d2, d0
	add.w   d0, d0
	andi.w  #$1e0, d0
	add.w   d0, d1
	move.w  d3, d0
	lsr.w   #$3, d0
	andi.w  #$1e, d0
	add.w   d0, d1
loc_200F66:
	movea.l d1, a1
	rts     
loc_200F6A:
	andi.w  #$7f, d1
	cmpi.b  #$4, zoneAct.l
	bne.s   loc_200FD2
	btst.b  #$6, oSprFlags(a0)
	bne.s   loc_200F98
	cmpi.b  #$14, d1
	bne.w   loc_2010BC
	bset.b  #$6, oSprFlags(a0)
	andi.b  #$7f, oTile(a0)
	bra.w   loc_2010BC
loc_200F98:
	cmpi.b  #$15, d1
	bne.s   loc_200FA6
	move.w  #$60, d1
	bra.w   loc_2010BC
loc_200FA6:
	cmpi.b  #$1e, d1
	bne.s   loc_200FB4
	move.w  #$61, d1
	bra.w   loc_2010BC
loc_200FB4:
	cmpi.b  #$1f, d1
	bne.s   loc_200FC2
	move.w  #$62, d1
	bra.w   loc_2010BC
loc_200FC2:
	cmpi.b  #$32, d1
	bne.w   loc_2010BC
	move.w  #$63, d1
	bra.w   loc_2010BC
loc_200FD2:
	cmpi.b  #$5, zoneAct.l
	bne.w   loc_201038
	ori.w   #$8000, oTile(a0)
	cmpi.b  #$4, d1
	beq.s   loc_201022
	cmpi.b  #$6, d1
	beq.s   loc_201022
	tst.b   layer.l
	beq.w   loc_2010BC
	andi.w  #$7fff, oTile(a0)
	cmpi.b  #$28, d1
	beq.s   loc_201032
	cmpi.b  #$3c, d1
	beq.s   loc_201032
	cmpi.b  #$37, d1
	beq.s   loc_201032
	cmpi.b  #$2f, d1
	beq.s   loc_201032
	cmpi.b  #$16, d1
	beq.s   loc_201032
	bra.w   loc_2010BC
loc_201022:
	andi.w  #$7fff, oTile(a0)
	btst.b  #$6, oSprFlags(a0)
	beq.w   loc_2010BC
loc_201032:
	addq.b  #$1, d1
	bra.w   loc_2010BC
loc_201038:
	cmpi.b  #$6, zoneAct.l
	bne.s   loc_2010A8
	cmpi.b  #$3, oID(a0)
	bcc.w   loc_2010BC
	ori.w   #$8000, oTile(a0)
	tst.b   layer.l
	beq.s   loc_2010BC
	andi.w  #$7fff, oTile(a0)
	cmpi.b  #$46, d1
	bne.s   loc_20106C
	move.w  #$6a, d1
	bra.s   loc_2010BC
loc_20106C:
	cmpi.b  #$48, d1
	bne.s   loc_201078
	move.w  #$6b, d1
	bra.s   loc_2010BC
loc_201078:
	cmpi.b  #$4a, d1
	bne.s   loc_201084
	move.w  #$6c, d1
	bra.s   loc_2010BC
loc_201084:
	cmpi.b  #$10, d1
	bne.s   loc_201090
	move.w  #$6d, d1
	bra.s   loc_2010BC
loc_201090:
	cmpi.b  #$63, d1
	bne.s   loc_20109C
	move.w  #$6e, d1
	bra.s   loc_2010BC
loc_20109C:
	cmpi.b  #$43, d1
	bne.s   loc_2010BC
	move.w  #$6f, d1
	bra.s   loc_2010BC
loc_2010A8:
	btst.b  #$6, oSprFlags(a0)
	beq.s   loc_2010BC
	addq.w  #$1, d1
	cmpi.w  #$29, d1
	bne.s   loc_2010BC
	move.w  #$51, d1
loc_2010BC:
	subq.b  #$1, d1
	ror.w   #$7, d1
	move.w  d2, d0
	add.w   d0, d0
	andi.w  #$1e0, d0
	add.w   d0, d1
	move.w  d3, d0
	lsr.w   #$3, d0
	andi.w  #$1e, d0
	add.w   d0, d1
	movea.l d1, a1
	rts     
FindLevelFloor:
	bsr.w   GetLevelBlock
	cmpi.l  #$210000, d1
	beq.s   loc_2010F2
	move.w  (a1), d0
	move.w  d0, d4
	andi.w  #$7ff, d0
	beq.s   loc_2010F2
	btst.l  d5, d4
	bne.s   loc_201100
loc_2010F2:
	add.w   a3, d2
	bsr.w   FindLevelFloor2
	sub.w   a3, d2
	addi.w  #$10, d1
	rts     
loc_201100:
	movea.l collisionPtr.w, a2
	move.b  (a2, d0.w), d0
	andi.w  #$ff, d0
	beq.s   loc_2010F2
	lea     ColAngleMap.l, a2
	move.b  (a2, d0.w), (a4)
	lsl.w   #$4, d0
	move.w  d3, d1
	btst.l  #$b, d4
	beq.s   loc_201126
	not.w   d1
	neg.b   (a4)
loc_201126:
	btst.l  #$c, d4
	beq.s   loc_201136
	addi.b  #$40, (a4)
	neg.b   (a4)
	subi.b  #$40, (a4)
loc_201136:
	andi.w  #$f, d1
	add.w   d0, d1
	lea     ColHeightMap.l, a2
	move.b  (a2, d1.w), d0
	ext.w   d0
	eor.w   d6, d4
	btst.l  #$c, d4
	beq.s   loc_201152
	neg.w   d0
loc_201152:
	tst.w   d0
	beq.s   loc_2010F2
	bmi.s   loc_20116E
	cmpi.b  #$10, d0
	beq.s   loc_20118A
loc_20115E:
	move.w  d2, d1
	andi.w  #$f, d1
	add.w   d1, d0
	move.w  #$f, d1
	sub.w   d0, d1
	rts     
loc_20116E:
	cmpa.w  #$10, a3
	bne.s   loc_20117E
	move.w  #$10, d0
	move.b  #$0, (a4)
	bra.s   loc_20115E
loc_20117E:
	move.w  d2, d1
	andi.w  #$f, d1
	add.w   d1, d0
	bpl.w   loc_2010F2
loc_20118A:
	sub.w   a3, d2
	bsr.w   FindLevelFloor2
	add.w   a3, d2
	subi.w  #$10, d1
	rts     
FindLevelFloor2:
	bsr.w   GetLevelBlock
	cmpi.l  #$210000, d1
	beq.s   loc_2011B2
	move.w  (a1), d0
	move.w  d0, d4
	andi.w  #$7ff, d0
	beq.s   loc_2011B2
	btst.l  d5, d4
	bne.s   loc_2011C0
loc_2011B2:
	move.w  #$f, d1
	move.w  d2, d0
	andi.w  #$f, d0
	sub.w   d0, d1
	rts     
loc_2011C0:
	movea.l collisionPtr.w, a2
	move.b  (a2, d0.w), d0
	andi.w  #$ff, d0
	beq.s   loc_2011B2
	lea     ColAngleMap.l, a2
	move.b  (a2, d0.w), (a4)
	lsl.w   #$4, d0
	move.w  d3, d1
	btst.l  #$b, d4
	beq.s   loc_2011E6
	not.w   d1
	neg.b   (a4)
loc_2011E6:
	btst.l  #$c, d4
	beq.s   loc_2011F6
	addi.b  #$40, (a4)
	neg.b   (a4)
	subi.b  #$40, (a4)
loc_2011F6:
	andi.w  #$f, d1
	add.w   d0, d1
	lea     ColHeightMap.l, a2
	move.b  (a2, d1.w), d0
	ext.w   d0
	eor.w   d6, d4
	btst.l  #$c, d4
	beq.s   loc_201212
	neg.w   d0
loc_201212:
	tst.w   d0
	beq.s   loc_2011B2
	bmi.s   loc_201228
loc_201218:
	move.w  d2, d1
	andi.w  #$f, d1
	add.w   d1, d0
	move.w  #$f, d1
	sub.w   d0, d1
	rts     
loc_201228:
	cmpa.w  #$10, a3
	bne.s   loc_201238
	move.w  #$10, d0
	move.b  #$0, (a4)
	bra.s   loc_201218
loc_201238:
	move.w  d2, d1
	andi.w  #$f, d1
	add.w   d1, d0
	bpl.w   loc_2011B2
	not.w   d1
	rts     
FindLevelWall:
	bsr.w   GetLevelBlock
	cmpi.l  #$210000, d1
	beq.s   loc_201262
	move.w  (a1), d0
	move.w  d0, d4
	andi.w  #$7ff, d0
	beq.s   loc_201262
	btst.l  d5, d4
	bne.s   loc_201270
loc_201262:
	add.w   a3, d3
	bsr.w   FindLevelWall2
	sub.w   a3, d3
	addi.w  #$10, d1
	rts     
loc_201270:
	movea.l collisionPtr.w, a2
	move.b  (a2, d0.w), d0
	andi.w  #$ff, d0
	beq.s   loc_201262
	lea     ColAngleMap.l, a2
	move.b  (a2, d0.w), (a4)
	lsl.w   #$4, d0
	move.w  d2, d1
	btst.l  #$c, d4
	beq.s   loc_20129E
	not.w   d1
	addi.b  #$40, (a4)
	neg.b   (a4)
	subi.b  #$40, (a4)
loc_20129E:
	btst.l  #$b, d4
	beq.s   loc_2012A6
	neg.b   (a4)
loc_2012A6:
	andi.w  #$f, d1
	add.w   d0, d1
	lea     ColWidthMap.l, a2
	move.b  (a2, d1.w), d0
	ext.w   d0
	eor.w   d6, d4
	btst.l  #$b, d4
	beq.s   loc_2012C2
	neg.w   d0
loc_2012C2:
	tst.w   d0
	beq.s   loc_201262
	bmi.s   loc_2012DE
	cmpi.b  #$10, d0
	beq.s   loc_2012EA
	move.w  d3, d1
	andi.w  #$f, d1
	add.w   d1, d0
	move.w  #$f, d1
	sub.w   d0, d1
	rts     
loc_2012DE:
	move.w  d3, d1
	andi.w  #$f, d1
	add.w   d1, d0
	bpl.w   loc_201262
loc_2012EA:
	sub.w   a3, d3
	bsr.w   FindLevelWall2
	add.w   a3, d3
	subi.w  #$10, d1
	rts     
FindLevelWall2:
	bsr.w   GetLevelBlock
	cmpi.l  #$210000, d1
	beq.s   loc_201312
	move.w  (a1), d0
	move.w  d0, d4
	andi.w  #$7ff, d0
	beq.s   loc_201312
	btst.l  d5, d4
	bne.s   loc_201320
loc_201312:
	move.w  #$f, d1
	move.w  d3, d0
	andi.w  #$f, d0
	sub.w   d0, d1
	rts     
loc_201320:
	movea.l collisionPtr.w, a2
	move.b  (a2, d0.w), d0
	andi.w  #$ff, d0
	beq.s   loc_201312
	lea     ColAngleMap.l, a2
	move.b  (a2, d0.w), (a4)
	lsl.w   #$4, d0
	move.w  d2, d1
	btst.l  #$c, d4
	beq.s   loc_20134E
	not.w   d1
	addi.b  #$40, (a4)
	neg.b   (a4)
	subi.b  #$40, (a4)
loc_20134E:
	btst.l  #$b, d4
	beq.s   loc_201356
	neg.b   (a4)
loc_201356:
	andi.w  #$f, d1
	add.w   d0, d1
	lea     ColWidthMap.l, a2
	move.b  (a2, d1.w), d0
	ext.w   d0
	eor.w   d6, d4
	btst.l  #$b, d4
	beq.s   loc_201372
	neg.w   d0
loc_201372:
	tst.w   d0
	beq.s   loc_201312
	bmi.s   loc_201388
	move.w  d3, d1
	andi.w  #$f, d1
	add.w   d1, d0
	move.w  #$f, d1
	sub.w   d0, d1
	rts     
loc_201388:
	move.w  d3, d1
	andi.w  #$f, d1
	add.w   d1, d0
	bpl.w   loc_201312
	not.w   d1
	rts     
ConvColArray:
	rts     
	lea     ColHeightMap.l, a1
	lea     ColHeightMap.l, a2
	move.w  #$ff, d3
loc_2013AA:
	moveq   #$10, d5
	move.w  #$f, d2
loc_2013B0:
	moveq   #$0, d4
	move.w  #$f, d1
loc_2013B6:
	move.w  (a1)+, d0
	lsr.l   d5, d0
	addx.w  d4, d4
	dbra    d1, loc_2013B6
	move.w  d4, (a2)+
	suba.w  #$20, a1
	subq.w  #$1, d5
	dbra    d2, loc_2013B0
	adda.w  #$20, a1
	dbra    d3, loc_2013AA
	lea     ColHeightMap.l, a1
	lea     ColWidthMap.l, a2
	bsr.s   sub_2013EE
	lea     ColHeightMap.l, a1
	lea     ColHeightMap.l, a2
sub_2013EE:
	move.w  #$fff, d3
loc_2013F2:
	moveq   #$0, d2
	move.w  #$f, d1
	move.w  (a1)+, d0
	beq.s   loc_201420
	bmi.s   loc_20140A
loc_2013FE:
	lsr.w   #$1, d0
	bcc.s   loc_201404
	addq.b  #$1, d2
loc_201404:
	dbra    d1, loc_2013FE
	bra.s   loc_201422
loc_20140A:
	cmpi.w  #$ffff, d0
	beq.s   loc_20141C
loc_201410:
	lsl.w   #$1, d0
	bcc.s   loc_201416
	subq.b  #$1, d2
loc_201416:
	dbra    d1, loc_201410
	bra.s   loc_201422
loc_20141C:
	move.w  #$10, d0
loc_201420:
	move.w  d0, d2
loc_201422:
	move.b  d2, (a2)+
	dbra    d3, loc_2013F2
	rts     
	dc.w	$8182,$8384,$8586,$8D00
LevelStart:
	clr.w   demoMode.l
	cmpi.b  #$7f, timeStones.l
	bne.s   loc_201452
	tst.b   timeAttackMode.l
	bne.s   loc_201452
	move.b  #$1, goodFuture.l
loc_201452:
	move.b  #$0, levelStarted.l
	clr.b   vintRoutine.w
	clr.b   usePlayer2.l
	move.b  #$0, paused.w
	bset.b  #$0, plcLoadFlags.l
	bne.s   loc_2014B8
	clr.b   palFadeFlags.l
	clr.b   checkpoint.l
	move.l  #$1388, nextLifeScore.l
	bsr.w   ResetSavedObjFlags
	clr.b   spawnMode.l
	clr.b   goodFutureFlags.l
	clr.l   score.l
	move.b  #$3, lives.l
	tst.b   timeAttackMode.l
	beq.s   loc_2014B8
	move.b  #$1, lives.l
loc_2014B8:
	bset.b  #$7, gameMode.w
	bsr.w   ClearPLCs
	tst.b   specialStage.l
	bne.s   loc_2014DE
	btst.b  #$7, timeZone.l
	beq.s   loc_201514
	bset.b  #$0, palFadeFlags.l
	beq.s   loc_2014EA
loc_2014DE:
	bsr.w   FadeToWhite
	bclr.b  #$0, palFadeFlags.l
loc_2014EA:
	clr.b   timeWarpDir.w
	tst.w   levelRestart.l
	beq.w   loc_201584
	move.w  #$0, levelRestart.l
	cmpi.b  #$2, act.l
	bne.s   loc_201512
	bclr.b  #$7, timeZone.l
loc_201512:
	rts     
loc_201514:
	bset.b  #$0, palFadeFlags.l
	beq.s   loc_201522
	bsr.w   FadeToBlack
loc_201522:
	cmpi.w  #$2, levelRestart.l
	bne.s   loc_20153E
	move.w  #$0, levelRestart.l
	move.b  #$0, palFadeFlags.l
	bra.s   loc_201566
loc_20153E:
	tst.b   lives.l
	bne.s   loc_201584
	move.b  #$0, plcLoadFlags.l
	move.b  #$0, checkpoint.l
	move.b  #$0, spawnMode.l
	move.b  #$0, palFadeFlags.l
loc_201566:
	lea     palette.w, a1
	move.w  #$1f, d6
loc_20156E:
	move.l  #$0, (a1)+
	dbra    d6, loc_20156E
	move.b  #$c, vintRoutine.w
	bsr.w   VSync
	rts     
loc_201584:
	cmpi.w  #$800, demoDataIndex.w
	bne.s   loc_2015A2
	move.w  #$0, demoDataIndex.w
	clr.w   demoMode.l
	move.b  #$0, palFadeFlags.l
	rts     
loc_2015A2:
	moveq   #$0, d0
	btst.b  #$0, palClearFlags.l
	bne.s   loc_2015B8
	btst.b  #$7, timeZone.l
	beq.s   loc_2015BE
loc_2015B8:
	move.l  #$eee0eee, d0
loc_2015BE:
	lea     palette.w, a1
	move.w  #$1f, d6
loc_2015C6:
	move.l  d0, (a1)+
	dbra    d6, loc_2015C6
loc_2015CC:
	move.b  #$c, vintRoutine.w
	bsr.w   VSync
	bsr.w   ProcessPLCs
	bne.s   loc_2015CC
	tst.l   plcBuffer.w
	bsr.w   PlayLevelMusic
	moveq   #$0, d0
	lea     LevelDataIndex.l, a2
	moveq   #$0, d0
	move.b  (a2), d0
	beq.s   loc_2015F6
	bsr.w   LoadPLCImm
loc_2015F6:
	moveq   #$1, d0
	bsr.w   LoadPLCImm
	clr.b   powerup.l
	clr.l   flowerCount.l
	lea     objDrawQueue.w, a1
	moveq   #$0, d0
	move.w  #$ff, d1
loc_201612:
	move.l  d0, (a1)+
	dbra    d1, loc_201612
	lea     flowerPosBuf.l, a1
	moveq   #$0, d0
	move.w  #$27f, d1
loc_201624:
	move.l  d0, (a1)+
	dbra    d1, loc_201624
	lea     objects.w, a1
	moveq   #$0, d0
	move.w  #$7ff, d1
loc_201634:
	move.l  d0, (a1)+
	dbra    d1, loc_201634
	lea     unkBuffer2.l, a1
	moveq   #$0, d0
	move.w  #$3ff, d1
loc_201646:
	move.l  d0, (a1)+
	dbra    d1, loc_201646
	lea     miscVariables.w, a1
	moveq   #$0, d0
	move.w  #$15, d1
loc_201656:
	move.l  d0, (a1)+
	dbra    d1, loc_201656
	lea     cameraX.w, a1
	moveq   #$0, d0
	move.w  #$3f, d1
loc_201666:
	move.l  d0, (a1)+
	dbra    d1, loc_201666
	move.w  #$2700, sr
	move.l  #$216c00, demoDataPtr.w
	move.w  #$0, demoDataIndex.w
	bsr.w   ClearScreen
	lea     VDPCTRL.l, a6
	move.w  #$8b03, (a6)
	move.w  #$8230, (a6)
	move.w  #$8407, (a6)
	move.w  #$857c, (a6)
	move.w  #$9001, (a6)
	move.w  #$8004, (a6)
	move.w  #$8720, (a6)
	move.w  #$8adf, vdpReg0A.w
	move.w  vdpReg0A.w, (a6)
	move.w  #$1e, drownTimer.l
	move.w  #$2300, sr
	moveq   #$3, d0
	bsr.w   LoadPalette
	moveq   #$3, d0
	bsr.w   LoadFadePal
	bsr.w   sub_20281C
	bsr.w   sub_202998
	bset.b  #$2, scrollFlags.w
	bsr.w   LoadLevelData
	bsr.w   InitLevelDraw
	jsr     ConvColArray.l
	bsr.w   LoadLevelCollision
loc_2016E6:
	move.b  #$c, vintRoutine.w
	bsr.w   VSync
	bsr.w   ProcessPLCs
	bne.s   loc_2016E6
	tst.l   plcBuffer.w
	bne.s   loc_2016E6
	bsr.w   LoadPlayer
	move.b  #$1c, objHUDScoreSlot.w
	move.b  #$1c, objHUDLivesSlot.w
	move.b  #$1, $FFFFD0E8.w
	move.b  #$1c, objHUDRingsSlot.w
	move.b  #$1, $FFFFD169.w
	bsr.w   LoadLifeIcon
	move.b  #$19, objHUDIconSlot.w
	move.b  #$a, $FFFFD7E8.w
	bset.b  #$1, plcLoadFlags.l
	bne.s   loc_20174A
	move.b  #$3c, objTtlCardSlot.w
	move.b  #$1, ctrlLocked.w
	clr.b   sectionID.l
loc_20174A:
	move.w  #$0, playerCtrl.w
	move.w  #$0, p1CtrlData.w
	move.w  #$0, p2CtrlData.w
	move.w  #$0, boredTimer.w
	move.w  #$0, boredTimerP2.w
	move.b  #$0, unkLevelFlag.l
	moveq   #$0, d0
	tst.b   spawnMode.l
	bne.s   loc_20178C
	move.w  d0, rings.l
	move.l  d0, time.l
	move.b  d0, livesFlags.l
loc_20178C:
	move.b  d0, timeOver.l
	move.b  d0, shield.l
	move.b  d0, invincible.l
	move.b  d0, speedShoes.l
	move.b  d0, timeWarp.l
	move.w  d0, debugMode.l
	move.w  d0, levelRestart.l
	move.w  d0, levelFrames.l
	move.b  d0, spawnMode.l
	move.b  #$1, updateHUDScore.l
	move.b  #$1, updateHUDRings.l
	move.b  #$1, updateHUDTime.l
	move.b  #$1, updateHUDLives.l
	move.b  #$80, updateHUDRings.l
	move.b  #$80, updateHUDScore.l
	move.w  #$0, demoS1Index.w
	move.w  #$202f, palFadeInfo.w
	jsr     UpdateAnimTiles.l
	move.b  #$1, fadeEnableDisplay.l
	bclr.b  #$7, timeZone.l
	beq.s   loc_20181C
loc_201816:
	bsr.w   FadeFromWhite
	bra.s   loc_20182A
loc_20181C:
	bclr.b  #$0, palClearFlags.l
	bne.s   loc_201816
	bsr.w   FadeFromBlack
loc_20182A:
	bclr.b  #$7, gameMode.w
	move.b  #$1, levelStarted.l
Level_MainLoop:
	move.b  #$8, vintRoutine.w
	bsr.w   VSync
	tst.b   ctrlLocked.w
	bne.s   loc_201856
	btst.b  #$7, p1CtrlTap.w
	beq.s   loc_201856
	eori.b  #$1, paused.w
loc_201856:
	btst.b  #$0, paused.w
	beq.w   loc_2018C8
	bsr.w   PauseMusic
	move.b  p1CtrlTap.w, d0
	tst.b   timeAttackMode.l
	bne.s   loc_2018A6
	andi.b  #$70, d0
	cmpi.b  #$70, d0
	bne.s   Level_MainLoop
	subq.b  #$1, lives.l
	bpl.s   loc_201888
	clr.b   lives.l
loc_201888:
	move.w  #$e, d0
	jsr     SubCPUCmd.l
	bsr.w   ResetSavedObjFlags
	clr.b   spawnMode.l
	move.w  #$1, levelRestart.l
	bra.s   loc_2018B4
loc_2018A6:
	andi.b  #$70, d0
	beq.w   Level_MainLoop
	clr.b   lives.l
loc_2018B4:
	clr.b   paused.w
	clr.w   demoMode.l
	clr.b   checkpoint.l
	bra.w   LevelStart
loc_2018C8:
	bsr.w   UnpauseMusic
	addq.w  #$1, levelFrames.l
	jsr     SpawnObjects.l
	jsr     RunObjects.l
	cmpi.w  #$800, demoDataIndex.w
	beq.w   LevelStart
	tst.w   levelRestart.l
	bne.w   LevelStart
	tst.w   debugMode.l
	bne.s   loc_201910
	cmpi.b  #$6, $FFFFD024.w
	bcs.s   loc_201910
	move.w  cameraY.w, bottomBound.w
	move.w  cameraY.w, destBottomBound.w
	bra.s   loc_201914
loc_201910:
	bsr.w   sub_202998
loc_201914:
	jsr     DrawObjects.l
	tst.w   timeStopTimer.l
	bne.s   loc_201926
	bsr.w   PalCycle_Do
loc_201926:
	jsr     UpdateSectionArt.l
	bsr.w   ProcessPLCs
	bsr.w   UpdateGlobalAnims
	bra.w   Level_MainLoop
LoadPlayer:
	lea     objects.w, a1
	moveq   #$1, d0
	dc.b	$13,$40,$00,$00		; move.b d0, $0(a1) (raw: not reproducible by assembler / suspicious)
	tst.b   spawnMode.l
	beq.s   loc_201950
	move.w  #$78, $30(a1)
loc_201950:
	rts     
	lea     flowerCount.l, a1
	moveq   #$0, d0
	move.b  timeZone.l, d0
	bclr.l  #$7, d0
	move.b  (a1, d0.w), d0
	beq.s   loc_2019AA
	subq.b  #$1, d0
	lea     resObjectsEnd.w, a2
	moveq   #$0, d1
loc_201972:
	dc.b	$15,$7C,$00,$1F,$00,$00		; move.b #$1f, $0(a2) (raw: not reproducible by assembler / suspicious)
	move.w  d1, d2
	add.w   d2, d2
	add.w   d2, d2
	moveq   #$0, d3
	move.b  timeZone.l, d3
	bclr.l  #$7, d3
	lsl.w   #$8, d3
	add.w   d3, d2
	lea     flowerPosBuf.l, a3
	move.w  (a3, d2.w), $8(a2)
	move.w  $2(a3, d2.w), $c(a2)
	adda.w  #$40, a2
	addq.b  #$1, d1
	dbra    d0, loc_201972
loc_2019AA:
	rts     
LoadLevelCollision:
	moveq   #$0, d0
	move.b  zoneAct.l, d0
	lsl.w   #$2, d0
	move.l  LevelColIndex(pc, d0.w), collisionPtr.w
	rts     
LevelColIndex:
	dc.l	LevelCollision
	dc.l	LevelCollision
	dc.l	LevelCollision
	dc.l	LevelCollision
	dc.l	LevelCollision
	dc.l	LevelCollision
	dc.l	LevelCollision
	dc.l	LevelCollision
UpdateGlobalAnims:
	subq.b  #$1, logSpikeAnimTimer.l
	bpl.s   loc_2019FC
	move.b  #$b, logSpikeAnimTimer.l
	subq.b  #$1, logSpikeAnimFrame.l
	andi.b  #$7, logSpikeAnimFrame.l
loc_2019FC:
	subq.b  #$1, ringAnimTimer.l
	bpl.s   loc_201A1A
	move.b  #$7, ringAnimTimer.l
	addq.b  #$1, ringAnimFrame.l
	andi.b  #$3, ringAnimFrame.l
loc_201A1A:
	subq.b  #$1, unkAnimTimer.l
	bpl.s   loc_201A42
	move.b  #$7, unkAnimTimer.l
	addq.b  #$1, unkAnimFrame.l
	cmpi.b  #$6, unkAnimFrame.l
	bcs.s   loc_201A42
	move.b  #$0, unkAnimFrame.l
loc_201A42:
	tst.b   ringLossAnimTimer.l
	beq.s   loc_201A70
	moveq   #$0, d0
	move.b  ringLossAnimTimer.l, d0
	add.w   ringLossAnimAccum.l, d0
	move.w  d0, ringLossAnimAccum.l
	rol.w   #$7, d0
	andi.w  #$3, d0
	move.b  d0, ringLossAnimFrame.l
	subq.b  #$1, ringLossAnimTimer.l
loc_201A70:
	rts     
PlayLevelMusic:
	moveq   #$0, d0
	moveq   #$0, d1
	move.b  timeZone.l, d0
	bclr.l  #$7, d0
	tst.b   timeAttackMode.l
	bne.s   loc_201A94
	cmpi.b  #$2, d0
	bne.s   loc_201A94
	add.b   goodFuture.l, d0
loc_201A94:
	move.b  zoneAct.l, d1
	add.w   d1, d1
	add.w   d1, d1
	add.w   d0, d1
	moveq   #$0, d0
	move.b  MusicPlayCmds(pc, d1.w), d0
	jmp     SubCPUCmd.l
MusicPlayCmds:
	dc.w	$800F,$1110,$8012,$1413,$8015,$1716,$8018,$1A19
	dc.w	$801B,$1D1C,$801E,$201F,$8021,$6622,$303C,$000F
	dc.w	$4EB9,$0020,$5C38
LoadLifeIcon:
	move.l  #$74200002, d0
	moveq   #$0, d2
	move.b  timeZone.l, d2
	bclr.l  #$7, d2
	lsl.w   #$7, d2
	move.l  d0, $4(a6)
	lea     Art_LifeIcon.l, a1
	lea     (a1, d2.w), a3
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	rts     
PauseMusic:
	move.w  #$ab, d0
	jsr     PlayFMSound.l
	bset.b  #$7, paused.w
	bne.s   loc_201B7A
	move.b  timeZone.l, d0
	bclr.l  #$7, d0
	tst.b   d0
	beq.s   loc_201B60
loc_201B56:
	move.w  #$d5, d0
	jmp     SubCPUCmd.l
loc_201B60:
	tst.b   invincible.l
	bne.s   loc_201B56
	tst.b   speedShoes.l
	bne.s   loc_201B56
	move.w  #$90, d0
	jmp     SubCPUCmd.l
loc_201B7A:
	rts     
UnpauseMusic:
	bclr.b  #$7, paused.w
	beq.s   loc_201BB6
	move.b  timeZone.l, d0
	bclr.l  #$7, d0
	tst.b   d0
	beq.s   loc_201B9C
loc_201B92:
	move.w  #$d6, d0
	jmp     SubCPUCmd.l
loc_201B9C:
	tst.b   invincible.l
	bne.s   loc_201B92
	tst.b   speedShoes.l
	bne.s   loc_201B92
	move.w  #$91, d0
	jmp     SubCPUCmd.l
loc_201BB6:
	rts     
VInterrupt:
	if def(MDPORT)
	dcb.w	4,$4E71		; same size as the removed GATEARRAY write (keeps every address)
	else
	bset.b  #$0, GATEARRAY.l
	endif
	movem.l d0-d7/a0-a6, -(a7)
	tst.b   vintRoutine.w
	beq.s   VInt_Lag
	move.w  VDPCTRL.l, d0
	move.l  #$40000010, VDPCTRL.l
	move.l  vscrollScreen.w, VDPDATA.l
	btst.b  #$6, versionCache.l
	beq.s   loc_201BF4
	move.w  #$700, d0
loc_201BF0:
	dbra    d0, loc_201BF0
loc_201BF4:
	move.b  vintRoutine.w, d0
	move.b  #$0, vintRoutine.w
	andi.w  #$3e, d0
	move.w  VInt_Index(pc, d0.w), d0
	jsr     VInt_Index(pc, d0.w)
VInt_Finish:
	jsr     UpdateFMQueues.l
	tst.b   paused.w
	bne.s   VInt_Done
	bsr.w   RunBoredTimer
	bsr.w   RunTimeWarp
VInt_Done:
	addq.l  #$1, levelVIntCounter.l
	movem.l (a7)+, d0-d7/a0-a6
	rte     
VInt_Index:
	dc.w	VInt_Lag-VInt_Index
	dc.w	VInt_General-VInt_Index
	dc.w	VInt_S1Title-VInt_Index
	dc.w	VInt_Unk6-VInt_Index
	dc.w	VInt_Level-VInt_Index
	dc.w	VInt_S1SpecStg-VInt_Index
	dc.w	VInt_LevelLoad-VInt_Index
	dc.w	VInt_UnkE-VInt_Index
	dc.w	VInt_Pause-VInt_Index
	dc.w	VInt_PalFade-VInt_Index
	dc.w	VInt_S1SegaScr-VInt_Index
	dc.w	VInt_S1ContScr-VInt_Index
	dc.w	VInt_LevelLoad-VInt_Index
VInt_Lag:
	tst.b   levelStarted.l
	beq.w   VInt_Finish
	cmpi.b  #$2, zoneAct.l
	bne.w   VInt_Finish
	move.w  VDPCTRL.l, d0
	btst.b  #$6, versionCache.l
	beq.s   loc_201C72
	move.w  #$700, d0
loc_201C6E:
	dbra    d0, loc_201C6E
loc_201C72:
	move.w  #$1, hintFlag.w
	jsr     StopZ80.l
	tst.b   waterFullscreen.w
	bne.s   loc_201CAA
	lea     VDPCTRL.l, a5
	move.l  #$94009340, (a5)
	move.l  #$96fd9580, (a5)
	move.w  #$977f, (a5)
	move.w  #$c000, (a5)
	move.w  #$80, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	bra.s   loc_201CCE
loc_201CAA:
	lea     VDPCTRL.l, a5
	move.l  #$94009340, (a5)
	move.l  #$96fd9540, (a5)
	move.w  #$977f, (a5)
	move.w  #$c000, (a5)
	move.w  #$80, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
loc_201CCE:
	move.w  vdpReg0A.w, (a5)
	jsr     StartZ80.l
	bra.w   VInt_Finish
VInt_General:
	bsr.w   DoVIntUpdates
VInt_S1SegaScr:
	tst.w   vintTimer.w
	beq.w   loc_201CEC
	subq.w  #$1, vintTimer.w
loc_201CEC:
	rts     
VInt_S1Title:
	bsr.w   DoVIntUpdates
	bsr.w   DrawLevelBG
	bsr.w   DecompPLCFast
	tst.w   vintTimer.w
	beq.w   loc_201D06
	subq.w  #$1, vintTimer.w
loc_201D06:
	rts     
VInt_Unk6:
	bsr.w   DoVIntUpdates
	rts     
VInt_Pause:
	cmpi.b  #$10, gameMode.w
	beq.w   VInt_S1SpecStg
VInt_Level:
	jsr     StopZ80.l
	bsr.w   ReadControllers
	lea     VDPCTRL.l, a5
	move.l  #$94009340, (a5)
	move.l  #$96fd9580, (a5)
	move.w  #$977f, (a5)
	move.w  #$c000, (a5)
	move.w  #$80, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	lea     VDPCTRL.l, a5
	move.l  #$940193c0, (a5)
	move.l  #$96e69500, (a5)
	move.w  #$977f, (a5)
	move.w  #$7c00, (a5)
	move.w  #$83, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	lea     VDPCTRL.l, a5
	move.l  #$94019340, (a5)
	move.l  #$96fc9500, (a5)
	move.w  #$977f, (a5)
	move.w  #$7800, (a5)
	move.w  #$83, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	lea     objects.w, a0
	bsr.w   LoadSonicDynPLC
	tst.b   updateSonicArt.w
	beq.s   loc_201DC6
	lea     VDPCTRL.l, a5
	move.l  #$94019370, (a5)
	move.l  #$96e49500, (a5)
	move.w  #$977f, (a5)
	move.w  #$7000, (a5)
	move.w  #$83, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	move.b  #$0, updateSonicArt.w
loc_201DC6:
	jsr     UpdateAnimTiles.l
	jsr     StartZ80.l
	movem.l cameraX.w, d0-d7
	movem.l d0-d7, camXCopy.l
	movem.l scrollFlags.w, d0-d1
	movem.l d0-d1, scrollFlagsCopy.l
	bsr.w   DrawLevel
	bsr.w   DecompPLCSlow
	jmp     UpdateHUD.l
VInt_S1SpecStg:
	rts     
VInt_LevelLoad:
	jsr     StopZ80.l
	bsr.w   ReadControllers
	lea     VDPCTRL.l, a5
	move.l  #$94009340, (a5)
	move.l  #$96fd9580, (a5)
	move.w  #$977f, (a5)
	move.w  #$c000, (a5)
	move.w  #$80, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	lea     VDPCTRL.l, a5
	move.l  #$940193c0, (a5)
	move.l  #$96e69500, (a5)
	move.w  #$977f, (a5)
	move.w  #$7c00, (a5)
	move.w  #$83, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	lea     VDPCTRL.l, a5
	move.l  #$94019340, (a5)
	move.l  #$96fc9500, (a5)
	move.w  #$977f, (a5)
	move.w  #$7800, (a5)
	move.w  #$83, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	jsr     StartZ80.l
	movem.l cameraX.w, d0-d7
	movem.l d0-d7, camXCopy.l
	movem.l scrollFlags.w, d0-d1
	movem.l d0-d1, scrollFlagsCopy.l
	bsr.w   DrawLevel
	bra.w   DecompPLCFast
VInt_UnkE:
	bsr.w   DoVIntUpdates
	addq.b  #$1, miscVariables.w
	move.b  #$e, vintRoutine.w
	rts     
VInt_PalFade:
	bsr.w   DoVIntUpdates
	cmpi.b  #$1, fadeEnableDisplay.l
	bne.s   loc_201ED0
	addq.b  #$1, fadeEnableDisplay.l
	move.w  vdpReg01.w, d0
	ori.b   #$40, d0
	move.w  d0, VDPCTRL.l
loc_201ED0:
	move.w  vdpReg0A.w, (a5)
	bra.w   DecompPLCFast
VInt_S1ContScr:
	jsr     StopZ80.l
	bsr.w   ReadControllers
	lea     VDPCTRL.l, a5
	move.l  #$94009340, (a5)
	move.l  #$96fd9580, (a5)
	move.w  #$977f, (a5)
	move.w  #$c000, (a5)
	move.w  #$80, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	lea     VDPCTRL.l, a5
	move.l  #$94019340, (a5)
	move.l  #$96fc9500, (a5)
	move.w  #$977f, (a5)
	move.w  #$7800, (a5)
	move.w  #$83, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	lea     VDPCTRL.l, a5
	move.l  #$940193c0, (a5)
	move.l  #$96e69500, (a5)
	move.w  #$977f, (a5)
	move.w  #$7c00, (a5)
	move.w  #$83, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	jsr     StartZ80.l
	lea     objects.w, a0
	bsr.w   LoadSonicDynPLC
	tst.b   updateSonicArt.w
	beq.s   loc_201F8C
	lea     VDPCTRL.l, a5
	move.l  #$94019370, (a5)
	move.l  #$96e49500, (a5)
	move.w  #$977f, (a5)
	move.w  #$7000, (a5)
	move.w  #$83, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	move.b  #$0, updateSonicArt.w
loc_201F8C:
	tst.w   vintTimer.w
	beq.w   loc_201F98
	subq.w  #$1, vintTimer.w
loc_201F98:
	rts     
DoVIntUpdates:
	jsr     StopZ80.l
	bsr.w   ReadControllers
	tst.b   waterFullscreen.w
	bne.s   loc_201FD0
	lea     VDPCTRL.l, a5
	move.l  #$94009340, (a5)
	move.l  #$96fd9580, (a5)
	move.w  #$977f, (a5)
	move.w  #$c000, (a5)
	move.w  #$80, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	bra.s   loc_201FF4
loc_201FD0:
	lea     VDPCTRL.l, a5
	move.l  #$94009340, (a5)
	move.l  #$96fd9540, (a5)
	move.w  #$977f, (a5)
	move.w  #$c000, (a5)
	move.w  #$80, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
loc_201FF4:
	lea     VDPCTRL.l, a5
	move.l  #$94019340, (a5)
	move.l  #$96fc9500, (a5)
	move.w  #$977f, (a5)
	move.w  #$7800, (a5)
	move.w  #$83, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	lea     VDPCTRL.l, a5
	move.l  #$940193c0, (a5)
	move.l  #$96e69500, (a5)
	move.w  #$977f, (a5)
	move.w  #$7c00, (a5)
	move.w  #$83, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
	jmp     StartZ80.l
HInterrupt:
	rte     
RunTimeWarp:
	tst.b   $FFFFD02A.w
	bne.s   loc_202054
	tst.w   timeWarpTimer.w
	beq.s   loc_202054
	addq.w  #$1, timeWarpTimer.w
loc_202054:
	rts     
RunBoredTimer:
	tst.w   boredTimer.w
	beq.s   loc_202060
	addq.w  #$1, boredTimer.w
loc_202060:
	tst.w   boredTimerP2.w
	beq.s   loc_20206A
	addq.w  #$1, boredTimerP2.w
loc_20206A:
	rts     
	move.l  d1, -(a7)
	move.l  rngSeed.w, d1
	bne.s   loc_20207A
	move.l  #$2a6d365a, d1
loc_20207A:
	move.l  d1, d0
	asl.l   #$2, d1
	add.l   d0, d1
	asl.l   #$3, d1
	add.l   d0, d1
	move.w  d1, d0
	swap    d1
	add.w   d1, d0
	move.w  d0, d1
	swap    d1
	move.l  d1, rngSeed.w
	move.l  (a7)+, d1
	rts     
InitControllers:
	bsr.w   StopZ80
	moveq   #$40, d0
	move.b  d0, IOCTRL1.l
	move.b  d0, IOCTRL2.l
	move.b  d0, IOCTRL3.l
	bra.w   StartZ80
ReadControllers:
	lea     p1CtrlData.w, a0
	lea     IODATA1.l, a1
	bsr.s   ReadController
	addq.w  #$2, a1
ReadController:
	move.b  #$0, (a1)
	nop     
	nop     
	move.b  (a1), d0
	lsl.b   #$2, d0
	andi.b  #$c0, d0
	move.b  #$40, (a1)
	nop     
	nop     
	move.b  (a1), d1
	andi.b  #$3f, d1
	or.b    d1, d0
	not.b   d0
	move.b  (a0), d1
	eor.b   d0, d1
	move.b  d0, (a0)+
	and.b   d0, d1
	move.b  d1, (a0)+
	rts     
InitVDP:
	lea     VDPCTRL.l, a0
	lea     VDPDATA.l, a1
	lea     VDPInitRegs.l, a2
	moveq   #$12, d7
loc_202102:
	move.w  (a2)+, (a0)
	dbra    d7, loc_202102
	move.w  VDPInitReg1.l, d0
	move.w  d0, vdpReg01.w
	move.w  #$8adf, vdpReg0A.w
	moveq   #$0, d0
	move.l  #$c0000000, VDPCTRL.l
	move.w  #$3f, d7
loc_202128:
	move.w  d0, (a1)
	dbra    d7, loc_202128
	clr.l   vscrollScreen.w
	clr.l   hscrollScreen.w
	move.l  d1, -(a7)
	lea     VDPCTRL.l, a5
	move.w  #$8f01, (a5)
	move.l  #$94ff93ff, (a5)
	move.w  #$9780, (a5)
	move.l  #$40000080, (a5)
	move.w  #$0, VDPDATA.l
loc_20215A:
	move.w  (a5), d1
	btst.l  #$1, d1
	bne.s   loc_20215A
	move.w  #$8f02, (a5)
	move.l  (a7)+, d1
	rts     
VDPInitRegs:
	dc.w	$8004
VDPInitReg1:
	dc.w	$8134,$8230,$8328,$8407,$857C,$8600,$8700,$8800
	dc.w	$8900,$8A00,$8B00,$8C81,$8D3F,$8E00,$8F02,$9001
	dc.w	$9100,$9200
ClearScreen:
	lea     VDPCTRL.l, a5
	move.w  #$8f01, (a5)
	move.l  #$940f93ff, (a5)
	move.w  #$9780, (a5)
	move.l  #$40000083, (a5)
	move.w  #$0, VDPDATA.l
loc_2021B2:
	move.w  (a5), d1
	btst.l  #$1, d1
	bne.s   loc_2021B2
	move.w  #$8f02, (a5)
	lea     VDPCTRL.l, a5
	move.w  #$8f01, (a5)
	move.l  #$940f93ff, (a5)
	move.w  #$9780, (a5)
	move.l  #$60000083, (a5)
	move.w  #$0, VDPDATA.l
loc_2021E0:
	move.w  (a5), d1
	btst.l  #$1, d1
	bne.s   loc_2021E0
	move.w  #$8f02, (a5)
	clr.l   vscrollScreen.w
	clr.l   hscrollScreen.w
	lea     sprites.w, a1
	moveq   #$0, d0
	move.w  #$a0, d1
loc_2021FE:
	move.l  d0, (a1)+
	dbra    d1, loc_2021FE
	lea     hscroll.w, a1
	moveq   #$0, d0
	move.w  #$100, d1
loc_20220E:
	move.l  d0, (a1)+
	dbra    d1, loc_20220E
	rts     
StopZ80:
	move.w  sr, savedSR.w
	move.w  #$2700, sr
	move.w  #$100, Z80BUS.l
loc_202226:
	btst.b  #$0, Z80BUS.l
	bne.s   loc_202226
	rts     
StartZ80:
	move.w  #$0, Z80BUS.l
	move.w  savedSR.w, sr
	rts     
	move.w  #$100, Z80RESET.l
	jsr     StopZ80(pc)
	lea     Z80RAM.l, a1
	move.b  #$f3, (a1)+
	move.b  #$f3, (a1)+
	move.b  #$c3, (a1)+
	move.b  #$0, (a1)+
	move.b  #$0, (a1)+
	move.w  #$0, Z80RESET.l
	ror.b   #$8, d0
	move.w  #$100, Z80RESET.l
	jmp     StartZ80(pc)
	dc.w	$4E75
PlayFMSound:
	tst.b   fmSndQueue1.w
	bne.s   loc_20228A
	move.b  d0, fmSndQueue1.w
	rts     
loc_20228A:
	tst.b   fmSndQueue2.w
	bne.s   loc_202296
	move.b  d0, fmSndQueue2.w
	rts     
loc_202296:
	tst.b   fmSndQueue3.w
	bne.s   loc_2022A0
	move.b  d0, fmSndQueue3.w
loc_2022A0:
	rts     
UpdateFMQueues:
	jsr     StopZ80.l
	tst.b   fmSndQueue1.w
	beq.s   loc_2022BC
	move.b  fmSndQueue1.w, $a01c09.l
	move.b  #$0, fmSndQueue1.w
loc_2022BC:
	tst.b   fmSndQueue2.w
	beq.s   loc_2022D0
	move.b  fmSndQueue2.w, $a01c0a.l
	move.b  #$0, fmSndQueue2.w
loc_2022D0:
	tst.b   fmSndQueue3.w
	beq.s   loc_2022E4
	move.b  fmSndQueue3.w, $a01c0b.l
	move.b  #$0, fmSndQueue3.w
loc_2022E4:
	bra.w   StartZ80
	lea     VDPDATA.l, a6
	move.l  #$800000, d4
loc_2022F4:
	move.l  d0, $4(a6)
	move.w  d1, d3
loc_2022FA:
	move.w  (a1)+, (a6)
	dbra    d3, loc_2022FA
	add.l   d4, d0
	dbra    d2, loc_2022F4
	rts     
NemDec:
	movem.l d0-d7/a0-a1/a3-a5, -(a7)
	lea     NemPCD_WriteRowToVDP.l, a3
	lea     VDPDATA.l, a4
	bra.s   NemDecMain
NemDecToRAM:
	movem.l d0-d7/a0-a1/a3-a5, -(a7)
	lea     NemPCD_WriteRowToRAM.l, a3
NemDecMain:
	lea     nemBuffer.w, a1
	move.w  (a0)+, d2
	lsl.w   #$1, d2
	bcc.s   loc_202332
	adda.w  #$a, a3
loc_202332:
	lsl.w   #$2, d2
	movea.w d2, a5
	moveq   #$8, d3
	moveq   #$0, d2
	moveq   #$0, d4
	bsr.w   NemDec_BuildCodeTable
	move.b  (a0)+, d5
	asl.w   #$8, d5
	move.b  (a0)+, d5
	move.w  #$10, d6
	bsr.s   NemDec_ProcessCompressedData
	movem.l (a7)+, d0-d7/a0-a1/a3-a5
	rts     
NemDec_ProcessCompressedData:
	move.w  d6, d7
	subq.w  #$8, d7
	move.w  d5, d1
	lsr.w   d7, d1
	cmpi.b  #$fc, d1
	bcc.s   NemPCD_InlineData
	andi.w  #$ff, d1
	add.w   d1, d1
	move.b  (a1, d1.w), d0
	ext.w   d0
	sub.w   d0, d6
	cmpi.w  #$9, d6
	bcc.s   loc_20237A
	addq.w  #$8, d6
	asl.w   #$8, d5
	move.b  (a0)+, d5
loc_20237A:
	move.b  $1(a1, d1.w), d1
	move.w  d1, d0
	andi.w  #$f, d1
	andi.w  #$f0, d0
NemDec_GetRunLength:
	lsr.w   #$4, d0
NemDec_RunLoop:
	lsl.l   #$4, d4
	or.b    d1, d4
	subq.w  #$1, d3
	bne.s   NemPCD_WritePixel_Loop
	jmp     (a3)
NemPCD_NewRow:
	moveq   #$0, d4
	moveq   #$8, d3
NemPCD_WritePixel_Loop:
	dbra    d0, NemDec_RunLoop
	bra.s   NemDec_ProcessCompressedData
NemPCD_InlineData:
	subq.w  #$6, d6
	cmpi.w  #$9, d6
	bcc.s   loc_2023AC
	addq.w  #$8, d6
	asl.w   #$8, d5
	move.b  (a0)+, d5
loc_2023AC:
	subq.w  #$7, d6
	move.w  d5, d1
	lsr.w   d6, d1
	move.w  d1, d0
	andi.w  #$f, d1
	andi.w  #$70, d0
	cmpi.w  #$9, d6
	bcc.s   NemDec_GetRunLength
	addq.w  #$8, d6
	asl.w   #$8, d5
	move.b  (a0)+, d5
	bra.s   NemDec_GetRunLength
NemPCD_WriteRowToVDP:
	move.l  d4, (a4)
	subq.w  #$1, a5
	move.w  a5, d4
	bne.s   NemPCD_NewRow
	rts     
	eor.l   d4, d2
	move.l  d2, (a4)
	subq.w  #$1, a5
	move.w  a5, d4
	bne.s   NemPCD_NewRow
	rts     
NemPCD_WriteRowToRAM:
	move.l  d4, (a4)+
	subq.w  #$1, a5
	move.w  a5, d4
	bne.s   NemPCD_NewRow
	rts     
	eor.l   d4, d2
	move.l  d2, (a4)+
	subq.w  #$1, a5
	move.w  a5, d4
	bne.s   NemPCD_NewRow
	rts     
NemDec_BuildCodeTable:
	move.b  (a0)+, d0
NemBCT_ChkEnd:
	cmpi.b  #$ff, d0
	bne.s   NemBCT_NewPALIndex
	rts     
NemBCT_NewPALIndex:
	move.w  d0, d7
NemBCT_Loop:
	move.b  (a0)+, d0
	cmpi.b  #$80, d0
	bcc.s   NemBCT_ChkEnd
	move.b  d0, d1
	andi.w  #$f, d7
	andi.w  #$70, d1
	or.w    d1, d7
	andi.w  #$f, d0
	move.b  d0, d1
	lsl.w   #$8, d1
	or.w    d1, d7
	moveq   #$8, d1
	sub.w   d0, d1
	bne.s   NemBCT_ShortCode
	move.b  (a0)+, d0
	add.w   d0, d0
	move.w  d7, (a1, d0.w)
	bra.s   NemBCT_Loop
NemBCT_ShortCode:
	move.b  (a0)+, d0
	lsl.w   d1, d0
	add.w   d0, d0
	moveq   #$1, d5
	lsl.w   d1, d5
	subq.w  #$1, d5
NemBCT_ShortCode_Loop:
	move.w  d7, (a1, d0.w)
	addq.w  #$2, d0
	dbra    d5, NemBCT_ShortCode_Loop
	bra.s   NemBCT_Loop
LoadPLC:
	movem.l a1-a2, -(a7)
	lea     $20fade.l, a1
	add.w   d0, d0
	move.w  (a1, d0.w), d0
	lea     (a1, d0.w), a1
	lea     plcBuffer.w, a2
loc_202460:
	tst.l   (a2)
	beq.s   loc_202468
	addq.w  #$6, a2
	bra.s   loc_202460
loc_202468:
	move.w  (a1)+, d0
	bmi.s   loc_202474
loc_20246C:
	move.l  (a1)+, (a2)+
	move.w  (a1)+, (a2)+
	dbra    d0, loc_20246C
loc_202474:
	movem.l (a7)+, a1-a2
	rts     
InitPLC:
	movem.l a1-a2, -(a7)
	lea     $20fade.l, a1
	add.w   d0, d0
	move.w  (a1, d0.w), d0
	lea     (a1, d0.w), a1
	bsr.s   ClearPLCs
	lea     plcBuffer.w, a2
	move.w  (a1)+, d0
	bmi.s   loc_2024A0
loc_202498:
	move.l  (a1)+, (a2)+
	move.w  (a1)+, (a2)+
	dbra    d0, loc_202498
loc_2024A0:
	movem.l (a7)+, a1-a2
	rts     
ClearPLCs:
	lea     plcBuffer.w, a2
	moveq   #$1f, d0
loc_2024AC:
	clr.l   (a2)+
	dbra    d0, loc_2024AC
	rts     
ProcessPLCs:
	tst.l   plcBuffer.w
	beq.s   loc_202508
	tst.w   plcTileCount.w
	bne.s   loc_202508
	movea.l plcBuffer.w, a0
	lea     NemPCD_WriteRowToVDP.l, a3
	lea     nemBuffer.w, a1
	move.w  (a0)+, d2
	bpl.s   loc_2024D6
	adda.w  #$a, a3
loc_2024D6:
	andi.w  #$7fff, d2
	move.w  d2, plcTileCount.w
	bsr.w   NemDec_BuildCodeTable
	move.b  (a0)+, d5
	asl.w   #$8, d5
	move.b  (a0)+, d5
	moveq   #$10, d6
	moveq   #$0, d0
	move.l  a0, plcBuffer.w
	move.l  a3, plcNemWrite.w
	move.l  d0, plcRepeat.w
	move.l  d0, plcPixel.w
	move.l  d0, plcRow.w
	move.l  d5, plcRead.w
	move.l  d6, plcShift.w
loc_202508:
	rts     
DecompPLCFast:
	tst.w   plcTileCount.w
	beq.w   DecompPLC_Done
DecompPLCFast_Large:
	move.w  #$12, plcProcTileCnt.w
	moveq   #$0, d0
	move.w  $FFFFF684.w, d0
	addi.w  #$240, $FFFFF684.w
	bra.s   DecompPLC_Main
DecompPLCSlow:
	tst.w   plcTileCount.w
	beq.s   DecompPLC_Done
	tst.b   scrollLock.w
	bne.s   DecompPLCFast_Large
	move.w  #$3, plcProcTileCnt.w
	moveq   #$0, d0
	move.w  $FFFFF684.w, d0
	addi.w  #$60, $FFFFF684.w
DecompPLC_Main:
	lea     VDPCTRL.l, a4
	lsl.l   #$2, d0
	lsr.w   #$2, d0
	ori.w   #$4000, d0
	swap    d0
	move.l  d0, (a4)
	subq.w  #$4, a4
	movea.l plcBuffer.w, a0
	movea.l plcNemWrite.w, a3
	move.l  plcRepeat.w, d0
	move.l  plcPixel.w, d1
	move.l  plcRow.w, d2
	move.l  plcRead.w, d5
	move.l  plcShift.w, d6
	lea     nemBuffer.w, a1
loc_202578:
	movea.w #$8, a5
	bsr.w   NemPCD_NewRow
	subq.w  #$1, plcTileCount.w
	beq.s   DecompPLC_Pop
	subq.w  #$1, plcProcTileCnt.w
	bne.s   loc_202578
	move.l  a0, plcBuffer.w
	move.l  a3, plcNemWrite.w
	move.l  d0, plcRepeat.w
	move.l  d1, plcPixel.w
	move.l  d2, plcRow.w
	move.l  d5, plcRead.w
	move.l  d6, plcShift.w
DecompPLC_Done:
	rts     
DecompPLC_Pop:
	lea     plcBuffer.w, a0
	moveq   #$15, d0
loc_2025B0:
	move.l  oeTimeZones(a0), (a0)+
	dbra    d0, loc_2025B0
	rts     
LoadPLCImm:
	lea     $20fade.l, a1
	add.w   d0, d0
	move.w  (a1, d0.w), d0
	lea     (a1, d0.w), a1
	move.w  (a1)+, d1
loc_2025CC:
	movea.l (a1)+, a0
	moveq   #$0, d0
	move.w  (a1)+, d0
	lsl.l   #$2, d0
	lsr.w   #$2, d0
	ori.w   #$4000, d0
	swap    d0
	move.l  d0, VDPCTRL.l
	bsr.w   NemDec
	dbra    d1, loc_2025CC
	rts     
	movem.l d0-d7/a1-a5, -(a7)
	movea.w d0, a3
	move.b  (a0)+, d0
	ext.w   d0
	movea.w d0, a5
	move.b  (a0)+, d4
	lsl.b   #$3, d4
	movea.w (a0)+, a2
	adda.w  a3, a2
	movea.w (a0)+, a4
	adda.w  a3, a4
	move.b  (a0)+, d5
	asl.w   #$8, d5
	move.b  (a0)+, d5
	moveq   #$10, d6
EniDec_Loop:
	moveq   #$7, d0
	move.w  d6, d7
	sub.w   d0, d7
	move.w  d5, d1
	lsr.w   d7, d1
	andi.w  #$7f, d1
	move.w  d1, d2
	cmpi.w  #$40, d1
	bcc.s   loc_202626
	moveq   #$6, d0
	lsr.w   #$1, d2
loc_202626:
	bsr.w   EniDec_ChkGetNextByte
	andi.w  #$f, d2
	lsr.w   #$4, d1
	add.w   d1, d1
	jmp     EniDec_JmpTable(pc, d1.w)
EniDec_Sub0:
	move.w  a2, (a1)+
	addq.w  #$1, a2
	dbra    d2, EniDec_Sub0
	bra.s   EniDec_Loop
EniDec_Sub4:
	move.w  a4, (a1)+
	dbra    d2, EniDec_Sub4
	bra.s   EniDec_Loop
EniDec_Sub8:
	bsr.w   EniDec_GetInlineCopyVal
loc_20264C:
	move.w  d1, (a1)+
	dbra    d2, loc_20264C
	bra.s   EniDec_Loop
EniDec_SubA:
	bsr.w   EniDec_GetInlineCopyVal
loc_202658:
	move.w  d1, (a1)+
	addq.w  #$1, d1
	dbra    d2, loc_202658
	bra.s   EniDec_Loop
EniDec_SubC:
	bsr.w   EniDec_GetInlineCopyVal
loc_202666:
	move.w  d1, (a1)+
	subq.w  #$1, d1
	dbra    d2, loc_202666
	bra.s   EniDec_Loop
EniDec_SubE:
	cmpi.w  #$f, d2
	beq.s   EniDec_End
loc_202676:
	bsr.w   EniDec_GetInlineCopyVal
	move.w  d1, (a1)+
	dbra    d2, loc_202676
	bra.s   EniDec_Loop
EniDec_JmpTable:
	bra.s   EniDec_Sub0
loc_202684:
	bra.s   EniDec_Sub0
loc_202686:
	bra.s   EniDec_Sub4
loc_202688:
	bra.s   EniDec_Sub4
loc_20268A:
	bra.s   EniDec_Sub8
loc_20268C:
	bra.s   EniDec_SubA
loc_20268E:
	bra.s   EniDec_SubC
loc_202690:
	bra.s   EniDec_SubE
EniDec_End:
	subq.w  #$1, a0
	cmpi.w  #$10, d6
	bne.s   loc_20269C
	subq.w  #$1, a0
loc_20269C:
	move.w  a0, d0
	lsr.w   #$1, d0
	bcc.s   loc_2026A4
	addq.w  #$1, a0
loc_2026A4:
	movem.l (a7)+, d0-d7/a1-a5
	rts     
EniDec_GetInlineCopyVal:
	move.w  a3, d3
	move.b  d4, d1
	add.b   d1, d1
	bcc.s   loc_2026BC
	subq.w  #$1, d6
	btst.l  d6, d5
	beq.s   loc_2026BC
	ori.w   #$8000, d3
loc_2026BC:
	add.b   d1, d1
	bcc.s   loc_2026CA
	subq.w  #$1, d6
	btst.l  d6, d5
	beq.s   loc_2026CA
	addi.w  #$4000, d3
loc_2026CA:
	add.b   d1, d1
	bcc.s   loc_2026D8
	subq.w  #$1, d6
	btst.l  d6, d5
	beq.s   loc_2026D8
	addi.w  #$2000, d3
loc_2026D8:
	add.b   d1, d1
	bcc.s   loc_2026E6
	subq.w  #$1, d6
	btst.l  d6, d5
	beq.s   loc_2026E6
	ori.w   #$1000, d3
loc_2026E6:
	add.b   d1, d1
	bcc.s   loc_2026F4
	subq.w  #$1, d6
	btst.l  d6, d5
	beq.s   loc_2026F4
	ori.w   #$800, d3
loc_2026F4:
	move.w  d5, d1
	move.w  d6, d7
	sub.w   a5, d7
	bcc.s   loc_202724
	move.w  d7, d6
	addi.w  #$10, d6
	neg.w   d7
	lsl.w   d7, d1
	move.b  (a0), d5
	rol.b   d7, d5
	add.w   d7, d7
	and.w   dat_202738(pc, d7.w), d5
	add.w   d5, d1
loc_202712:
	move.w  a5, d0
	add.w   d0, d0
	and.w   dat_202738(pc, d0.w), d1
	add.w   d3, d1
	move.b  (a0)+, d5
	lsl.w   #$8, d5
	move.b  (a0)+, d5
	rts     
loc_202724:
	beq.s   loc_202736
	lsr.w   d7, d1
	move.w  a5, d0
	add.w   d0, d0
	and.w   dat_202738(pc, d0.w), d1
	add.w   d3, d1
	move.w  a5, d0
	bra.s   EniDec_ChkGetNextByte
loc_202736:
	moveq   #$10, d6
dat_202738:
	bra.s   loc_202712
	dc.w	$0001,$0003,$0007,$000F,$001F,$003F,$007F,$00FF
	dc.w	$01FF,$03FF,$07FF,$0FFF,$1FFF,$3FFF,$7FFF,$FFFF
EniDec_ChkGetNextByte:
	sub.w   d0, d6
	cmpi.w  #$9, d6
	bcc.s   loc_202768
	addq.w  #$8, d6
	asl.w   #$8, d5
	move.b  (a0)+, d5
loc_202768:
	rts     
	subq.l  #$2, a7
	move.b  (a0)+, $1(a7)
	move.b  (a0)+, (a7)
	move.w  (a7), d5
	moveq   #$f, d4
KosDec_Loop:
	lsr.w   #$1, d5
	move.w  sr, d6
	dbra    d4, loc_202788
	move.b  (a0)+, $1(a7)
	move.b  (a0)+, (a7)
	move.w  (a7), d5
	moveq   #$f, d4
loc_202788:
	move.w  d6, ccr
	bcc.s   KosDec_RLE
	move.b  (a0)+, (a1)+
	bra.s   KosDec_Loop
KosDec_RLE:
	moveq   #$0, d3
	lsr.w   #$1, d5
	move.w  sr, d6
	dbra    d4, loc_2027A4
	move.b  (a0)+, $1(a7)
	move.b  (a0)+, (a7)
	move.w  (a7), d5
	moveq   #$f, d4
loc_2027A4:
	move.w  d6, ccr
	bcs.s   KosDec_SeparateRLE
	lsr.w   #$1, d5
	dbra    d4, loc_2027B8
	move.b  (a0)+, $1(a7)
	move.b  (a0)+, (a7)
	move.w  (a7), d5
	moveq   #$f, d4
loc_2027B8:
	roxl.w  #$1, d3
	lsr.w   #$1, d5
	dbra    d4, loc_2027CA
	move.b  (a0)+, $1(a7)
	move.b  (a0)+, (a7)
	move.w  (a7), d5
	moveq   #$f, d4
loc_2027CA:
	roxl.w  #$1, d3
	addq.w  #$1, d3
	moveq   #$ff, d2
	move.b  (a0)+, d2
	bra.s   KosDec_RLELoop
KosDec_SeparateRLE:
	move.b  (a0)+, d0
	move.b  (a0)+, d1
	moveq   #$ff, d2
	move.b  d1, d2
	lsl.w   #$5, d2
	move.b  d0, d2
	andi.w  #$7, d1
	beq.s   KosDec_SeparateRLE2
	move.b  d1, d3
	addq.w  #$1, d3
KosDec_RLELoop:
	move.b  (a1, d2.w), d0
	move.b  d0, (a1)+
	dbra    d3, KosDec_RLELoop
	bra.s   KosDec_Loop
KosDec_SeparateRLE2:
	move.b  (a0)+, d1
	beq.s   KosDec_Done
	cmpi.b  #$1, d1
	beq.w   KosDec_Loop
	move.b  d1, d3
	bra.s   KosDec_RLELoop
KosDec_Done:
	addq.l  #$2, a7
	rts     
	lea     objects.w, a6
	tst.b   usePlayer2.l
	beq.s   loc_20281A
	lea     objPlayerSlot2.w, a6
loc_20281A:
	rts     
sub_20281C:
	lea     objects.w, a6
	moveq   #$0, d0
	move.b  d0, unusedF740.w
	move.b  d0, unusedF741.w
	move.b  d0, unusedF746.w
	move.b  d0, unusedF748.w
	move.b  d0, eventRoutine.w
	lea     CamBounds.l, a0
	move.w  (a0)+, d0
	move.w  d0, unusedF730.w
	move.l  (a0)+, d0
	move.l  d0, leftBound.w
	move.l  d0, destLeftBound.w
	move.l  (a0)+, d0
	move.l  d0, topBound.w
	move.l  d0, destTopBound.w
	move.w  leftBound.w, d0
	addi.w  #$240, d0
	move.w  d0, leftBound3.w
	move.w  #$1010, horizBlkCrossed.w
	move.w  (a0)+, d0
	move.w  d0, camYCenter.w
	move.w  #$a0, camXCenter.w
	bra.w   LevelSizeLoad_StartPos
CamBounds:
	dc.w	$0004,$0000,$2E97,$0000,$0510,$0060
loc_202884:
	dc.w	$0050,$03B0,$0EA0,$046C,$1750,$00BD,$0A00,$062C
	dc.w	$0BB0,$004C,$1570,$016C,$01B0,$072C,$1400,$02AC
LevelSizeLoad_StartPos:
	tst.b   spawnMode.l
	beq.s   loc_2028C4
	jsr     LoadCheckpointData.l
	moveq   #$0, d0
	moveq   #$0, d1
	move.w  $8(a6), d1
	move.w  $c(a6), d0
	bpl.s   loc_2028C2
	moveq   #$0, d0
loc_2028C2:
	bra.s   loc_202900
loc_2028C4:
	lea     loc_20293C.l, a1
	tst.w   demoMode.l
	bpl.s   loc_2028E6
	move.w  s1CreditsIndex.l, d0
	subq.w  #$1, d0
	lsl.w   #$2, d0
	lea     loc_202884.l, a1
	adda.w  d0, a1
	bra.s   loc_2028F0
loc_2028E6:
	move.w  demoMode.l, d0
	lsl.w   #$2, d0
	adda.w  d0, a1
loc_2028F0:
	moveq   #$0, d1
	move.w  (a1)+, d1
	move.w  d1, $8(a6)
	moveq   #$0, d0
	move.w  (a1), d0
	move.w  d0, $c(a6)
loc_202900:
	subi.w  #$a0, d1
	bcc.s   loc_202908
	moveq   #$0, d1
loc_202908:
	move.w  rightBound.w, d2
	cmp.w   d2, d1
	bcs.s   loc_202912
	move.w  d2, d1
loc_202912:
	move.w  d1, cameraX.w
	subi.w  #$60, d0
	bcc.s   loc_20291E
	moveq   #$0, d0
loc_20291E:
	cmp.w   bottomBound.w, d0
	blt.s   loc_202928
	move.w  bottomBound.w, d0
loc_202928:
	move.w  d0, cameraY.w
	bsr.w   InitLevelScroll
	lea     SpecChunks.l, a1
	move.l  (a1), specialChunks.w
	rts     
loc_20293C:
	dc.w	$0060,$03EC
SpecChunks:
	dc.w	$7F7F,$7F7F
InitLevelScroll:
	move.w  #$218, d0
	move.w  #$520, d2
	sub.w   cameraY.w, d2
	bcs.s   loc_20295A
	lsr.w   #$1, d2
	sub.w   d2, d0
	bpl.s   loc_20295A
	moveq   #$0, d0
loc_20295A:
	move.w  d0, cameraBgY.w
	move.w  #$0, $FFFFF70E.w
	move.w  d0, cameraBg2Y.w
	move.w  d0, cameraBg3Y.w
	lsr.w   #$4, d1
	move.w  d1, cameraBg3X.w
	lsr.w   #$1, d1
	move.w  d1, d2
	add.w   d2, d2
	add.w   d1, d2
	move.w  d2, cameraBg2X.w
	lsr.w   #$1, d1
	move.w  d1, d2
	add.w   d2, d2
	add.w   d1, d2
	move.w  d2, cameraBgX.w
	lea     deformBuffer.w, a2
	moveq   #$e, d2
loc_202990:
	clr.l   (a2)+
	dbra    d2, loc_202990
	rts     
sub_202998:
	lea     objects.w, a6
	tst.b   scrollLock.w
	beq.s   loc_2029A4
	rts     
loc_2029A4:
	clr.w   scrollFlags.w
	clr.w   scrollFlagsBg.w
	clr.w   scrollFlagsBg2.w
	clr.w   scrollFlagsBg3.w
	bsr.w   ScrollCamX
	bsr.w   ScrollCamY
	bsr.w   RunLevelEvents
	move.w  cameraY.w, vscrollScreen.w
	move.w  cameraBgY.w, $FFFFF618.w
	move.w  scrollXDiff.w, d4
	ext.l   d4
	asl.l   #$4, d4
	moveq   #$6, d6
	bsr.w   SetHorizScrollFlagsBG3
	move.w  scrollXDiff.w, d4
	ext.l   d4
	asl.l   #$3, d4
	move.l  d4, d3
	add.l   d3, d3
	add.l   d3, d4
	moveq   #$4, d6
	bsr.w   SetHorizScrollFlagsBG2
	lea     $FFFFA83C.w, a1
	move.w  scrollXDiff.w, d4
	ext.l   d4
	asl.l   #$2, d4
	move.l  d4, d3
	add.l   d3, d3
	add.l   d3, d4
	moveq   #$2, d6
	bsr.w   SetHorizScrollFlagsBG
	move.w  #$218, d0
	move.w  #$520, d1
	sub.w   cameraY.w, d1
	bcs.s   loc_202A1C
	lsr.w   #$1, d1
	sub.w   d1, d0
	bpl.s   loc_202A1C
	moveq   #$0, d0
loc_202A1C:
	bsr.w   SetVertiScrollFlagsBG2
	move.w  cameraBgY.w, $FFFFF618.w
	move.w  cameraBgY.w, cameraBg2Y.w
	move.w  cameraBgY.w, cameraBg3Y.w
	move.b  scrollFlagsBg3.w, d0
	or.b    scrollFlagsBg2.w, d0
	or.b    d0, scrollFlagsBg.w
	clr.b   scrollFlagsBg3.w
	clr.b   scrollFlagsBg2.w
	lea     deformBuffer.w, a2
	addi.l  #$c000, (a2)+
	addi.l  #$8000, (a2)+
	addi.l  #$6000, (a2)+
	addi.l  #$4000, (a2)+
	addi.l  #$3000, (a2)+
	addi.l  #$2000, (a2)+
	addi.l  #$1000, (a2)+
	addi.l  #$800, (a2)+
	addi.l  #$1000, (a2)+
	addi.l  #$2000, (a2)+
	addi.l  #$3000, (a2)+
	addi.l  #$4000, (a2)+
	addi.l  #$6000, (a2)+
	addi.l  #$8000, (a2)+
	addi.l  #$c000, (a2)+
	moveq   #$3f, d6
	moveq   #$0, d1
loc_202AA8:
	move.w  d1, d2
	mulu.w  #$400, d2
	addi.l  #$8000, d2
	add.l   d2, (a2)+
	addq.b  #$1, d1
	dbra    d6, loc_202AA8
	move.w  cameraX.w, d0
	neg.w   d0
	swap    d0
	move.w  cameraBgX.w, d0
	move.w  cameraX.w, d2
	sub.w   d0, d2
	ext.l   d2
	moveq   #$6, d1
	asl.l   d1, d2
	divs.w  #$1c, d2
	ext.l   d2
	moveq   #$a, d1
	asl.l   d1, d2
	move.w  cameraBgX.w, d3
	moveq   #$6, d6
	lea     $FFFFA94A.w, a1
loc_202AE8:
	move.w  d3, d0
	neg.w   d0
	move.w  d0, -(a1)
	swap    d3
	add.l   d2, d3
	swap    d3
	dbra    d6, loc_202AE8
	lea     $FFFFA94A.w, a1
	move.w  cameraBgX.w, d0
	neg.w   d0
	moveq   #$2, d6
loc_202B04:
	move.w  d0, (a1)+
	dbra    d6, loc_202B04
	move.w  cameraBg3X.w, d0
	neg.w   d0
	moveq   #$3, d6
loc_202B12:
	move.w  d0, (a1)+
	dbra    d6, loc_202B12
	lea     deformBuffer.w, a2
	moveq   #$e, d6
loc_202B1E:
	move.l  (a2)+, d1
	swap    d1
	add.w   cameraBgX.w, d1
	neg.w   d1
	moveq   #$0, d5
	lea     CloudSectSizes.l, a3
	move.b  (a3, d6.w), d5
loc_202B34:
	move.w  d1, (a1)+
	dbra    d5, loc_202B34
	dbra    d6, loc_202B1E
	move.w  cameraBgX.w, d0
	neg.w   d0
	moveq   #$5, d6
loc_202B46:
	move.w  d0, (a1)+
	dbra    d6, loc_202B46
	move.w  cameraBg3X.w, d0
	neg.w   d0
	moveq   #$3, d6
loc_202B54:
	move.w  d0, (a1)+
	dbra    d6, loc_202B54
	move.w  cameraBg2X.w, d0
	neg.w   d0
	moveq   #$7, d6
loc_202B62:
	move.w  d0, (a1)+
	dbra    d6, loc_202B62
	move.w  cameraBgX.w, d0
	neg.w   d0
	moveq   #$3, d6
loc_202B70:
	move.w  d0, (a1)+
	dbra    d6, loc_202B70
	move.w  cameraBgX.w, d0
	move.w  cameraX.w, d2
	sub.w   d0, d2
	ext.l   d2
	moveq   #$6, d1
	asl.l   d1, d2
	divs.w  #$28, d2
	ext.l   d2
	moveq   #$a, d1
	asl.l   d1, d2
	moveq   #$9, d6
	move.w  cameraBgX.w, d3
loc_202B96:
	move.w  d3, d0
	neg.w   d0
	move.w  d0, (a1)+
	swap    d3
	add.l   d2, d3
	swap    d3
	dbra    d6, loc_202B96
	move.w  cameraBgX.w, d0
	neg.w   d0
	moveq   #$7, d6
loc_202BAE:
	move.w  d0, (a1)+
	dbra    d6, loc_202BAE
	lea     hscroll.w, a1
	lea     $FFFFA93C.w, a2
	move.w  cameraBgY.w, d0
	move.w  d0, d2
	move.w  d0, d4
	andi.w  #$3f8, d0
	lsr.w   #$2, d0
	move.w  d0, d3
	lsr.w   #$1, d3
	moveq   #$57, d1
	moveq   #$1d, d5
	sub.w   d3, d1
	bcs.s   loc_202BFA
	cmpi.w  #$1b, d1
	bcs.s   loc_202BDE
	moveq   #$1c, d1
loc_202BDE:
	sub.w   d1, d5
	lea     (a2, d0.w), a2
	lea     loc_202C0E.l, a3
	lea     Data_23A746.l, a4
	addi.w  #$40, $FFFFF7D8.w
	bsr.w   sub_202C64
loc_202BFA:
	bra.w   loc_202C14
CloudSectSizes:
	btst.l  d0, d3
	btst.l  d0, d1
	btst.l  d0, d1
	btst.l  d0, d1
	btst.l  d1, d1
	btst.l  d1, d3
	btst.l  d1, d3
	btst.l  d0, d0
loc_202C0E:
	dc.b	$00,$38,$02,$50,$7F,$FF		; ori.b #$50, $7fff.w (raw: not reproducible by assembler / suspicious)
loc_202C14:
	move.w  d5, d1
	lsl.w   #$3, d1
	subq.w  #$1, d1
	lea     $FFFFA83C.w, a2
	move.b  $FFFFF7D8.w, d5
	sub.w   cameraBgY.w, d4
loc_202C26:
	move.l  (a2)+, d2
	swap    d2
	add.w   cameraBgX.w, d2
	neg.w   d2
	move.w  d2, d0
	move.w  #$5c0, d3
	sub.w   cameraY.w, d3
	cmp.w   d3, d4
	bcs.s   loc_202C58
	andi.w  #$7f, d5
	move.w  d5, d6
	add.w   d6, d6
	move.b  (a4, d6.w), d3
	ext.w   d3
	add.w   cameraX.w, d3
	neg.w   d3
	swap    d0
	move.w  d3, d0
	swap    d0
loc_202C58:
	move.l  d0, (a1)+
	addq.w  #$1, d4
	addq.w  #$1, d5
	dbra    d1, loc_202C26
	rts     
sub_202C64:
	cmp.w   (a3), d4
	bcc.s   loc_202C9A
loc_202C68:
	andi.w  #$7, d2
	addq.w  #$8, d4
	sub.w   d2, d4
	add.w   d2, d2
	move.w  (a2)+, d0
	jmp     dat_202C84(pc, d2.w)
loc_202C78:
	tst.w   d1
	bmi.s   loc_202C98
	cmp.w   (a3), d4
	bcc.s   loc_202CB4
loc_202C80:
	move.w  (a2)+, d0
	addq.w  #$8, d4
dat_202C84:
	dc.w	$22C0
	dc.w	$22C0
	dc.w	$22C0
	dc.w	$22C0
	dc.w	$22C0
	dc.w	$22C0
	dc.w	$22C0
	dc.w	$22C0
	dbra    d1, loc_202C78
loc_202C98:
	rts     
loc_202C9A:
	move.w  (a3)+, d3
	addi.w  #$18, d3
	sub.w   d4, d3
	bgt.s   loc_202CBE
	cmp.w   (a3), d4
	bcs.s   loc_202C68
	move.w  (a3)+, d3
	addi.w  #$18, d3
	sub.w   d4, d3
	ble.s   loc_202C68
	bra.s   loc_202CBE
loc_202CB4:
	move.w  (a3)+, d3
	addi.w  #$18, d3
	sub.w   d4, d3
	ble.s   loc_202C80
loc_202CBE:
	subq.w  #$1, d3
	move.w  d3, d6
	moveq   #$0, d2
	move.b  $FFFFF7D8.w, d2
loc_202CC8:
	andi.w  #$ff, d2
	move.b  (a4, d2.w), d0
	ext.w   d0
	add.w   cameraBgX.w, d0
	neg.w   d0
	move.l  d0, (a1)+
	addq.w  #$1, d4
	addq.w  #$1, d2
	dbra    d3, loc_202CC8
	lsr.w   #$3, d6
loc_202CE4:
	move.w  (a2)+, d0
	subq.w  #$1, d1
	dbra    d6, loc_202CE4
	bra.s   loc_202C78
ScrollCamX:
	move.w  cameraX.w, d4
	bsr.s   MoveScreenHoriz
	move.w  cameraX.w, d0
	andi.w  #$10, d0
	move.b  horizBlkCrossed.w, d1
	eor.b   d1, d0
	bne.s   loc_202D20
	eori.b  #$10, horizBlkCrossed.w
	move.w  cameraX.w, d0
	sub.w   d4, d0
	bpl.s   loc_202D1A
	bset.b  #$2, scrollFlags.w
	rts     
loc_202D1A:
	bset.b  #$3, scrollFlags.w
loc_202D20:
	rts     
MoveScreenHoriz:
	move.w  $8(a6), d0
	sub.w   cameraX.w, d0
	sub.w   camXCenter.w, d0
	beq.s   loc_202D34
	bcs.s   MoveScreenHoriz_CamBehind
	bra.s   MoveScreenHoriz_CamAhead
loc_202D34:
	clr.w   scrollXDiff.w
	rts     
MoveScreenHoriz_CamAhead:
	cmpi.w  #$10, d0
	blt.s   loc_202D44
	move.w  #$10, d0
loc_202D44:
	add.w   cameraX.w, d0
	cmp.w   rightBound.w, d0
	blt.s   MoveScreenHoriz_MoveCam
	move.w  rightBound.w, d0
MoveScreenHoriz_MoveCam:
	move.w  d0, d1
	sub.w   cameraX.w, d1
	asl.w   #$8, d1
	move.w  d0, cameraX.w
	move.w  d1, scrollXDiff.w
	rts     
MoveScreenHoriz_CamBehind:
	cmpi.w  #$fff0, d0
	bge.s   loc_202D6E
	move.w  #$fff0, d0
loc_202D6E:
	add.w   cameraX.w, d0
	cmp.w   leftBound.w, d0
	bgt.s   MoveScreenHoriz_MoveCam
	move.w  leftBound.w, d0
	bra.s   MoveScreenHoriz_MoveCam
	tst.w   d0
	bpl.s   loc_202D88
	move.w  #$fffe, d0
	bra.s   MoveScreenHoriz_CamBehind
loc_202D88:
	move.w  #$2, d0
	bra.s   MoveScreenHoriz_CamAhead
ScrollCamY:
	moveq   #$0, d1
	move.w  $c(a6), d0
	sub.w   cameraY.w, d0
	btst.b  #$2, $22(a6)
	beq.s   loc_202DA2
	subq.w  #$5, d0
loc_202DA2:
	btst.b  #$1, $22(a6)
	beq.s   loc_202DC2
	addi.w  #$20, d0
	sub.w   camYCenter.w, d0
	bcs.s   loc_202E0E
	subi.w  #$40, d0
	bcc.s   loc_202E0E
	tst.b   btmBoundShift.w
	bne.s   loc_202E20
	bra.s   loc_202DCE
loc_202DC2:
	sub.w   camYCenter.w, d0
	bne.s   loc_202DD4
	tst.b   btmBoundShift.w
	bne.s   loc_202E20
loc_202DCE:
	clr.w   scrollYDiff.w
	rts     
loc_202DD4:
	cmpi.w  #$60, camYCenter.w
	bne.s   loc_202DFC
	move.w  $14(a6), d1
	bpl.s   loc_202DE4
	neg.w   d1
loc_202DE4:
	cmpi.w  #$800, d1
	bcc.s   loc_202E0E
	move.w  #$600, d1
	cmpi.w  #$6, d0
	bgt.s   loc_202E6E
	cmpi.w  #$fffa, d0
	blt.s   loc_202E38
	bra.s   loc_202E26
loc_202DFC:
	move.w  #$200, d1
	cmpi.w  #$2, d0
	bgt.s   loc_202E6E
	cmpi.w  #$fffe, d0
	blt.s   loc_202E38
	bra.s   loc_202E26
loc_202E0E:
	move.w  #$1000, d1
	cmpi.w  #$10, d0
	bgt.s   loc_202E6E
	cmpi.w  #$fff0, d0
	blt.s   loc_202E38
	bra.s   loc_202E26
loc_202E20:
	moveq   #$0, d0
	move.b  d0, btmBoundShift.w
loc_202E26:
	moveq   #$0, d1
	move.w  d0, d1
	add.w   cameraY.w, d1
	tst.w   d0
	bpl.w   loc_202E78
	bra.w   loc_202E44
loc_202E38:
	neg.w   d1
	ext.l   d1
	asl.l   #$8, d1
	add.l   cameraY.w, d1
	swap    d1
loc_202E44:
	cmp.w   topBound.w, d1
	bgt.s   loc_202E9C
	cmpi.w  #$ff00, d1
	bgt.s   loc_202E68
	andi.w  #$7ff, d1
	andi.w  #$7ff, $c(a6)
	andi.w  #$7ff, cameraY.w
	andi.w  #$3ff, cameraBgY.w
	bra.s   loc_202E9C
loc_202E68:
	move.w  topBound.w, d1
	bra.s   loc_202E9C
loc_202E6E:
	ext.l   d1
	asl.l   #$8, d1
	add.l   cameraY.w, d1
	swap    d1
loc_202E78:
	cmp.w   bottomBound.w, d1
	blt.s   loc_202E9C
	subi.w  #$800, d1
	bcs.s   loc_202E98
	andi.w  #$7ff, $c(a6)
	subi.w  #$800, cameraY.w
	andi.w  #$3ff, cameraBgY.w
	bra.s   loc_202E9C
loc_202E98:
	move.w  bottomBound.w, d1
loc_202E9C:
	move.w  cameraY.w, d4
	swap    d1
	move.l  d1, d3
	sub.l   cameraY.w, d3
	ror.l   #$8, d3
	move.w  d3, scrollYDiff.w
	move.l  d1, cameraY.w
	move.w  cameraY.w, d0
	andi.w  #$10, d0
	move.b  vertiBlkCrossed.w, d1
	eor.b   d1, d0
	bne.s   loc_202EDE
	eori.b  #$10, vertiBlkCrossed.w
	move.w  cameraY.w, d0
	sub.w   d4, d0
	bpl.s   loc_202ED8
	bset.b  #$0, scrollFlags.w
	rts     
loc_202ED8:
	bset.b  #$1, scrollFlags.w
loc_202EDE:
	rts     
	move.l  cameraBgX.w, d2
	move.l  d2, d0
	add.l   d4, d0
	move.l  d0, cameraBgX.w
	move.l  d0, d1
	swap    d1
	andi.w  #$10, d1
	move.b  horizBlkCrossedBg.w, d3
	eor.b   d3, d1
	bne.s   loc_202F14
	eori.b  #$10, horizBlkCrossedBg.w
	sub.l   d2, d0
	bpl.s   loc_202F0E
	bset.b  #$2, scrollFlagsBg.w
	bra.s   loc_202F14
loc_202F0E:
	bset.b  #$3, scrollFlagsBg.w
loc_202F14:
	move.l  cameraBgY.w, d3
	move.l  d3, d0
	add.l   d5, d0
	move.l  d0, cameraBgY.w
	move.l  d0, d1
	swap    d1
	andi.w  #$10, d1
	move.b  vertiBlkCrossedBg.w, d2
	eor.b   d2, d1
	bne.s   loc_202F48
	eori.b  #$10, vertiBlkCrossedBg.w
	sub.l   d3, d0
	bpl.s   loc_202F42
	bset.b  #$0, scrollFlagsBg.w
	rts     
loc_202F42:
	bset.b  #$1, scrollFlagsBg.w
loc_202F48:
	rts     
	move.l  cameraBgY.w, d3
	move.l  d3, d0
	add.l   d5, d0
	move.l  d0, cameraBgY.w
	move.l  d0, d1
	swap    d1
	andi.w  #$10, d1
	move.b  vertiBlkCrossedBg.w, d2
	eor.b   d2, d1
	bne.s   loc_202F7E
	eori.b  #$10, vertiBlkCrossedBg.w
	sub.l   d3, d0
	bpl.s   loc_202F78
	bset.b  #$4, scrollFlagsBg.w
	rts     
loc_202F78:
	bset.b  #$5, scrollFlagsBg.w
loc_202F7E:
	rts     
SetVertiScrollFlagsBG2:
	move.w  cameraBgY.w, d3
	move.w  d0, cameraBgY.w
	move.w  d0, d1
	andi.w  #$10, d1
	move.b  vertiBlkCrossedBg.w, d2
	eor.b   d2, d1
	bne.s   loc_202FAE
	eori.b  #$10, vertiBlkCrossedBg.w
	sub.w   d3, d0
	bpl.s   loc_202FA8
	bset.b  #$0, scrollFlagsBg.w
	rts     
loc_202FA8:
	bset.b  #$1, scrollFlagsBg.w
loc_202FAE:
	rts     
SetHorizScrollFlagsBG:
	move.l  cameraBgX.w, d2
	move.l  d2, d0
	add.l   d4, d0
	move.l  d0, cameraBgX.w
	move.l  d0, d1
	swap    d1
	andi.w  #$10, d1
	move.b  horizBlkCrossedBg.w, d3
	eor.b   d3, d1
	bne.s   loc_202FE2
	eori.b  #$10, horizBlkCrossedBg.w
	sub.l   d2, d0
	bpl.s   loc_202FDC
	bset.b  d6, scrollFlagsBg.w
	bra.s   loc_202FE2
loc_202FDC:
	addq.b  #$1, d6
	bset.b  d6, scrollFlagsBg.w
loc_202FE2:
	rts     
SetHorizScrollFlagsBG2:
	move.l  cameraBg2X.w, d2
	move.l  d2, d0
	add.l   d4, d0
	move.l  d0, cameraBg2X.w
	move.l  d0, d1
	swap    d1
	andi.w  #$10, d1
	move.b  horizBlkCrossedBg2.w, d3
	eor.b   d3, d1
	bne.s   loc_203016
	eori.b  #$10, horizBlkCrossedBg2.w
	sub.l   d2, d0
	bpl.s   loc_203010
	bset.b  d6, scrollFlagsBg2.w
	bra.s   loc_203016
loc_203010:
	addq.b  #$1, d6
	bset.b  d6, scrollFlagsBg2.w
loc_203016:
	rts     
SetHorizScrollFlagsBG3:
	move.l  cameraBg3X.w, d2
	move.l  d2, d0
	add.l   d4, d0
	move.l  d0, cameraBg3X.w
	move.l  d0, d1
	swap    d1
	andi.w  #$10, d1
	move.b  horizBlkCrossedBg3.w, d3
	eor.b   d3, d1
	bne.s   loc_20304A
	eori.b  #$10, horizBlkCrossedBg3.w
	sub.l   d2, d0
	bpl.s   loc_203044
	bset.b  d6, scrollFlagsBg3.w
	bra.s   loc_20304A
loc_203044:
	addq.b  #$1, d6
	bset.b  d6, scrollFlagsBg3.w
loc_20304A:
	rts     
DrawLevelBG:
	lea     VDPCTRL.l, a5
	lea     VDPDATA.l, a6
	lea     scrollFlagsBg.w, a2
	lea     cameraBgX.w, a3
	lea     $FFFFA040.w, a4
	move.w  #$6000, d2
	bsr.w   DrawLevelBG1
	lea     scrollFlagsBg2.w, a2
	lea     cameraBg2X.w, a3
	bra.w   DrawLevelBG2
DrawLevel:
	lea     VDPCTRL.l, a5
	lea     VDPDATA.l, a6
	lea     scrollFlagsBgCopy.l, a2
	lea     camXBgCopy.l, a3
	lea     $FFFFA040.w, a4
	move.w  #$6000, d2
	bsr.w   DrawLevelBG1
	lea     scrollFlagsBg2Copy.l, a2
	lea     camXBg2Copy.l, a3
	bsr.w   DrawLevelBG2
	lea     scrollFlagsBg3Copy.l, a2
	lea     camXBg3Copy.l, a3
	bsr.w   sub_20321C
	lea     scrollFlagsCopy.l, a2
	lea     camXCopy.l, a3
	lea     levelLayout.w, a4
	move.w  #$4000, d2
	tst.b   (a2)
	beq.s   loc_203134
	bclr.b  #$0, (a2)
	beq.s   loc_2030EA
	moveq   #$f0, d4
	moveq   #$f0, d5
	bsr.w   GetBlockVDPCmd
	moveq   #$f0, d4
	moveq   #$f0, d5
	bsr.w   DrawBlockRow
loc_2030EA:
	bclr.b  #$1, (a2)
	beq.s   loc_203104
	move.w  #$e0, d4
	moveq   #$f0, d5
	bsr.w   GetBlockVDPCmd
	move.w  #$e0, d4
	moveq   #$f0, d5
	bsr.w   DrawBlockRow
loc_203104:
	bclr.b  #$2, (a2)
	beq.s   loc_20311A
	moveq   #$f0, d4
	moveq   #$f0, d5
	bsr.w   GetBlockVDPCmd
	moveq   #$f0, d4
	moveq   #$f0, d5
	bsr.w   DrawBlockCol
loc_20311A:
	bclr.b  #$3, (a2)
	beq.s   loc_203134
	moveq   #$f0, d4
	move.w  #$140, d5
	bsr.w   GetBlockVDPCmd
	moveq   #$f0, d4
	move.w  #$140, d5
	bsr.w   DrawBlockCol
loc_203134:
	rts     
DrawLevelBG1:
	lea     BGCameraSectIDs.l, a0
	adda.w  #$1, a0
	moveq   #$f0, d4
	bclr.b  #$0, (a2)
	bne.s   loc_203152
	bclr.b  #$1, (a2)
	beq.s   loc_20319C
	move.w  #$e0, d4
loc_203152:
	move.w  cameraBgY.w, d0
	add.w   d4, d0
	andi.w  #$fff0, d0
	asr.w   #$4, d0
	move.b  (a0, d0.w), d0
	ext.w   d0
	add.w   d0, d0
	movea.l dat_2031CC(pc, d0.w), a3
	beq.s   loc_203184
	moveq   #$f0, d5
	move.l  a0, -(a7)
	movem.l d4-d5, -(a7)
	bsr.w   GetBlockVDPCmd
	movem.l (a7)+, d4-d5
	bsr.w   DrawBlockRow
	movea.l (a7)+, a0
	bra.s   loc_20319C
loc_203184:
	moveq   #$0, d5
	move.l  a0, -(a7)
	movem.l d4-d5, -(a7)
	bsr.w   GetBlockVDPCmdAbsX
	movem.l (a7)+, d4-d5
	moveq   #$1f, d6
	bsr.w   DrawBlockRowAbsX
	movea.l (a7)+, a0
loc_20319C:
	tst.b   (a2)
	bne.s   loc_2031A2
	rts     
loc_2031A2:
	moveq   #$f0, d4
	moveq   #$f0, d5
	move.b  (a2), d0
	andi.b  #$a8, d0
	beq.s   loc_2031B6
	lsr.b   #$1, d0
	move.b  d0, (a2)
	move.w  #$140, d5
loc_2031B6:
	move.w  cameraBgY.w, d0
	andi.w  #$fff0, d0
	asr.w   #$4, d0
	suba.w  #$1, a0
	lea     (a0, d0.w), a0
	bra.w   loc_2031DC
dat_2031CC:
	dc.w	$00FF,$192E,$00FF,$192E,$00FF,$1936,$00FF,$193E
loc_2031DC:
	moveq   #$f, d6
	move.l  #$800000, d7
loc_2031E4:
	moveq   #$0, d0
	move.b  (a0)+, d0
	btst.b  d0, (a2)
	beq.s   loc_20320E
	add.w   d0, d0
	movea.l dat_2031CC(pc, d0.w), a3
	movem.l d4-d5/a0, -(a7)
	movem.l d4-d5, -(a7)
	bsr.w   GetBlockData
	movem.l (a7)+, d4-d5
	bsr.w   GetBlockVDPCmd
	bsr.w   DrawBlock
	movem.l (a7)+, d4-d5/a0
loc_20320E:
	addi.w  #$10, d4
	dbra    d6, loc_2031E4
	clr.b   (a2)
	rts     
DrawLevelBG2:
	rts     
sub_20321C:
	rts     
DrawBlockRow:
	moveq   #$15, d6
DrawBlockRow2:
	move.l  #$800000, d7
	move.l  d0, d1
loc_203228:
	movem.l d4-d5, -(a7)
	bsr.w   GetBlockData
	move.l  d1, d0
	bsr.w   DrawBlock
	addq.b  #$4, d1
	andi.b  #$7f, d1
	movem.l (a7)+, d4-d5
	addi.w  #$10, d5
	dbra    d6, loc_203228
	rts     
DrawBlockRowAbsX:
	move.l  #$800000, d7
	move.l  d0, d1
loc_203252:
	movem.l d4-d5, -(a7)
	bsr.w   GetBlockDataAbsX
	move.l  d1, d0
	bsr.w   DrawBlock
	addq.b  #$4, d1
	andi.b  #$7f, d1
	movem.l (a7)+, d4-d5
	addi.w  #$10, d5
	dbra    d6, loc_203252
	rts     
DrawBlockCol:
	moveq   #$f, d6
	move.l  #$800000, d7
	move.l  d0, d1
loc_20327E:
	movem.l d4-d5, -(a7)
	bsr.w   GetBlockData
	move.l  d1, d0
	bsr.w   DrawBlock
	addi.w  #$100, d1
	andi.w  #$fff, d1
	movem.l (a7)+, d4-d5
	addi.w  #$10, d4
	dbra    d6, loc_20327E
	rts     
DrawBlock:
	or.w    d2, d0
	swap    d0
	btst.b  #$4, (a0)
	bne.s   loc_2032DE
	btst.b  #$3, (a0)
	bne.s   loc_2032BE
	move.l  d0, (a5)
	move.l  (a1)+, (a6)
	add.l   d7, d0
	move.l  d0, (a5)
	move.l  (a1)+, (a6)
	rts     
loc_2032BE:
	move.l  d0, (a5)
	move.l  (a1)+, d4
	eori.l  #$8000800, d4
	swap    d4
	move.l  d4, (a6)
	add.l   d7, d0
	move.l  d0, (a5)
	move.l  (a1)+, d4
	eori.l  #$8000800, d4
	swap    d4
	move.l  d4, (a6)
	rts     
loc_2032DE:
	btst.b  #$3, (a0)
	bne.s   loc_203300
	move.l  d0, (a5)
	move.l  (a1)+, d5
	move.l  (a1)+, d4
	eori.l  #$10001000, d4
	move.l  d4, (a6)
	add.l   d7, d0
	move.l  d0, (a5)
	eori.l  #$10001000, d5
	move.l  d5, (a6)
	rts     
loc_203300:
	move.l  d0, (a5)
	move.l  (a1)+, d5
	move.l  (a1)+, d4
	eori.l  #$18001800, d4
	swap    d4
	move.l  d4, (a6)
	add.l   d7, d0
	move.l  d0, (a5)
	eori.l  #$18001800, d5
	swap    d5
	move.l  d5, (a6)
	rts     
GetBlockData:
	add.w   (a3), d5
GetBlockDataAbsX:
	add.w   $4(a3), d4
GetBlockDataAbsXY:
	lea     WORKRAMFILE.l, a1
	move.w  d4, d3
	lsr.w   #$1, d3
	andi.w  #$380, d3
	lsr.w   #$3, d5
	move.w  d5, d0
	lsr.w   #$5, d0
	andi.w  #$7f, d0
	add.w   d3, d0
	move.l  #$210000, d3
	move.b  (a4, d0.w), d3
	beq.s   loc_203370
	subq.b  #$1, d3
	andi.w  #$7f, d3
	ror.w   #$7, d3
	add.w   d4, d4
	andi.w  #$1e0, d4
	andi.w  #$1e, d5
	add.w   d4, d3
	add.w   d5, d3
	movea.l d3, a0
	move.w  (a0), d3
	andi.w  #$3ff, d3
	lsl.w   #$3, d3
	adda.w  d3, a1
	moveq   #$1, d0
loc_203370:
	rts     
	move.w  d4, d3
	lsr.w   #$1, d3
	andi.w  #$380, d3
	lsr.w   #$3, d5
	move.w  d5, d0
	lsr.w   #$5, d0
	andi.w  #$7f, d0
	add.w   d3, d0
	move.l  #$210000, d3
	move.b  (a4, d0.w), d3
	subq.b  #$1, d3
	andi.w  #$7f, d3
	ror.w   #$7, d3
	add.w   d4, d4
	andi.w  #$1e0, d4
	andi.w  #$1e, d5
	add.w   d4, d3
	add.w   d5, d3
	movea.l d3, a0
	rts     
PlaceBlockAtPos:
	move.l  a0, -(a7)
	lea     levelLayout.w, a4
	lea     VDPCTRL.l, a5
	lea     VDPDATA.l, a6
	move.w  #$4000, d2
	move.l  #$800000, d7
	movem.l d3-d5, -(a7)
	bsr.w   GetBlockDataAbsXY
	bne.s   loc_2033D6
	movem.l (a7)+, d3-d5
	bra.s   loc_203400
loc_2033D6:
	movem.l (a7)+, d3-d5
	move.w  d3, (a0)
	bsr.w   ChkBlockPosOnscreen
	bne.s   loc_203400
	movem.l d3-d5, -(a7)
	lea     WORKRAMFILE.l, a1
	andi.w  #$3ff, d3
	lsl.w   #$3, d3
	adda.w  d3, a1
	bsr.w   GetBlockVDPCmdAbsXY
	bsr.w   DrawBlock
	movem.l (a7)+, d3-d5
loc_203400:
	movea.l (a7)+, a0
	rts     
ChkBlockPosOnscreen:
	move.w  cameraY.w, d0
	move.w  d0, d1
	andi.w  #$fff0, d0
	subi.w  #$10, d0
	cmp.w   d0, d4
	bcs.s   loc_203444
	addi.w  #$f0, d1
	andi.w  #$fff0, d1
	cmp.w   d1, d4
	bgt.s   loc_203444
	move.w  cameraX.w, d0
	move.w  d0, d1
	andi.w  #$fff0, d0
	subi.w  #$10, d0
	cmp.w   d0, d5
	bcs.s   loc_203444
	addi.w  #$150, d1
	andi.w  #$fff0, d1
	cmp.w   d1, d5
	bgt.s   loc_203444
	moveq   #$0, d0
	rts     
loc_203444:
	moveq   #$1, d0
	rts     
GetBlockVDPCmd:
	add.w   (a3), d5
GetBlockVDPCmdAbsX:
	add.w   $4(a3), d4
GetBlockVDPCmdAbsXY:
	andi.w  #$f0, d4
	andi.w  #$1f0, d5
	lsl.w   #$4, d4
	lsr.w   #$2, d5
	add.w   d5, d4
	moveq   #$3, d0
	swap    d0
	move.w  d4, d0
	rts     
	add.w   $4(a3), d4
	add.w   (a3), d5
	andi.w  #$f0, d4
	andi.w  #$1f0, d5
	lsl.w   #$4, d4
	lsr.w   #$2, d5
	add.w   d5, d4
	moveq   #$2, d0
	swap    d0
	move.w  d4, d0
	rts     
InitLevelDraw:
	lea     VDPCTRL.l, a5
	lea     VDPDATA.l, a6
	lea     cameraX.w, a3
	lea     levelLayout.w, a4
	move.w  #$4000, d2
	bsr.s   InitLevelDrawFG
	lea     cameraBgX.w, a3
	lea     $FFFFA040.w, a4
	move.w  #$6000, d2
	bra.w   InitLevelDrawBG
InitLevelDrawFG:
	moveq   #$f0, d4
	moveq   #$f, d6
loc_2034AE:
	movem.l d4-d6, -(a7)
	moveq   #$0, d5
	move.w  d4, d1
	bsr.w   GetBlockVDPCmd
	move.w  d1, d4
	moveq   #$0, d5
	moveq   #$1f, d6
	bsr.w   DrawBlockRow2
	movem.l (a7)+, d4-d6
	addi.w  #$10, d4
	dbra    d6, loc_2034AE
	rts     
InitLevelDrawBG:
	moveq   #$f0, d4
	moveq   #$f, d6
loc_2034D6:
	movem.l d4-d6/a0, -(a7)
	lea     BGCameraSectIDs.l, a0
	adda.w  #$1, a0
	move.w  cameraBgY.w, d0
	add.w   d4, d0
	andi.w  #$3f0, d0
	bsr.w   DrawBGBlockRow
	movem.l (a7)+, d4-d6/a0
	addi.w  #$10, d4
	dbra    d6, loc_2034D6
	rts     
BGCameraSectIDs:
	dc.w	$0000,$0000,$0000,$0606,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0002,$0202
	dc.w	$0606,$0404,$0404,$0200,$0000,$0000,$0000,$0000
	dc.w	$0000
BGCameraSects:
	dc.w	$00FF,$F708,$00FF,$F708,$00FF,$F710,$00FF,$F718
DrawBGBlockRow:
	lsr.w   #$4, d0
	move.b  (a0, d0.w), d0
	add.w   d0, d0
	movea.l BGCameraSects(pc, d0.w), a3
	beq.s   loc_203564
	moveq   #$f0, d5
	movem.l d4-d5, -(a7)
	bsr.w   GetBlockVDPCmd
	movem.l (a7)+, d4-d5
	bsr.w   DrawBlockRow
	bra.s   loc_203578
loc_203564:
	moveq   #$0, d5
	movem.l d4-d5, -(a7)
	bsr.w   GetBlockVDPCmdAbsX
	movem.l (a7)+, d4-d5
	moveq   #$1f, d6
	bsr.w   DrawBlockRowAbsX
loc_203578:
	rts     
LoadLevelData:
	moveq   #$0, d0
	lea     LevelDataIndex.l, a2
	move.l  a2, -(a7)
	addq.l  #$4, a2
	move.l  (a2)+, d1
	andi.l  #$3fffff, d1
	movea.l d1, a0
	lea     WORKRAMFILE.l, a4
	bsr.w   NemDecToRAM
	movea.l (a2)+, a0
	bsr.w   LoadLevelLayout
	move.w  (a2)+, d0
	move.w  (a2), d0
	andi.w  #$ff, d0
	bsr.w   LoadFadePal
	movea.l (a7)+, a2
	addq.w  #$4, a2
	tst.b   spawnMode.l
	beq.s   loc_2035BE
	jmp     LoadSectionArt.l
loc_2035BE:
	btst.b  #$1, plcLoadFlags.l
	beq.s   loc_2035D2
	moveq   #$0, d0
	move.b  (a2), d0
	beq.s   loc_2035D2
	bsr.w   LoadPLC
loc_2035D2:
	rts     
LoadLevelLayout:
	lea     levelLayout.w, a3
	move.w  #$1ff, d1
	moveq   #$0, d0
loc_2035DE:
	move.l  d0, (a3)+
	dbra    d1, loc_2035DE
	lea     levelLayout.w, a3
	moveq   #$0, d1
	bsr.w   sub_2035F4
	lea     $FFFFA040.w, a3
	moveq   #$2, d1
sub_2035F4:
	moveq   #$0, d0
	add.w   d1, d0
	lea     LevelLayouts.l, a1
	move.w  (a1, d0.w), d0
	lea     (a1, d0.w), a1
	moveq   #$0, d1
	move.w  d1, d2
	move.b  (a1)+, d1
	move.b  (a1)+, d2
loc_20360E:
	move.w  d1, d0
	movea.l a3, a0
loc_203612:
	move.b  (a1)+, (a0)+
	dbra    d0, loc_203612
	lea     $80(a3), a3
	dbra    d2, loc_20360E
	rts     
RunLevelEvents:
	moveq   #$0, d0
	move.b  zoneAct.l, d0
	add.w   d0, d0
	move.w  dat_20369C(pc, d0.w), d0
	jsr     dat_20369C(pc, d0.w)
	cmpi.b  #$2b, $FFFFD01C.w
	bne.s   loc_203648
	move.w  cameraY.w, bottomBound.w
	move.w  cameraY.w, destBottomBound.w
loc_203648:
	moveq   #$4, d1
	move.w  destBottomBound.w, d0
	sub.w   bottomBound.w, d0
	beq.s   loc_203676
	bcc.s   loc_203678
	neg.w   d1
	move.w  cameraY.w, d0
	cmp.w   destBottomBound.w, d0
	bls.s   loc_20366C
	move.w  d0, bottomBound.w
	andi.w  #$fffe, bottomBound.w
loc_20366C:
	add.w   d1, bottomBound.w
	move.b  #$1, btmBoundShift.w
loc_203676:
	rts     
loc_203678:
	move.w  cameraY.w, d0
	addq.w  #$8, d0
	cmp.w   bottomBound.w, d0
	bcs.s   loc_203690
	btst.b  #$1, $FFFFD022.w
	beq.s   loc_203690
	add.w   d1, d1
	add.w   d1, d1
loc_203690:
	add.w   d1, bottomBound.w
	move.b  #$1, btmBoundShift.w
	rts     
dat_20369C:
	dc.w	loc_2036AA-dat_20369C
	dc.w	LevEvents_CCZ-dat_20369C
	dc.w	LevEvents_TTZ-dat_20369C
	dc.w	LevEvents_QQZ-dat_20369C
	dc.w	LevEvents_WWZ-dat_20369C
	dc.w	LevEvents_SSZ-dat_20369C
	dc.w	LevEvents_MMZ-dat_20369C
loc_2036AA:
	moveq   #$0, d0
	move.b  act.l, d0
	add.w   d0, d0
	move.w  dat_2036BC(pc, d0.w), d0
	jmp     dat_2036BC(pc, d0.w)
dat_2036BC:
	dc.w	LevEvents_PPZ1-dat_2036BC
	dc.w	LevEvents_PPZ2-dat_2036BC
	dc.w	LevEvents_PPZ3-dat_2036BC
LevEvents_PPZ1:
	cmpi.b  #$1, timeZone.l
	bne.s   LevEvents_PPZ2
	cmpi.w  #$1c16, $FFFFD008.w
	bcs.s   loc_2036E2
	cmpi.w  #$21c6, $FFFFD008.w
	bcc.s   loc_2036E2
	move.w  #$88, camYCenter.w
loc_2036E2:
	move.w  #$710, destBottomBound.w
	cmpi.w  #$840, cameraX.w
	bcs.s   loc_203720
	tst.b   updateHUDTime.l
	beq.s   loc_20370C
	cmpi.w  #$820, leftBound.w
	bcc.s   loc_20370C
	move.w  #$820, leftBound.w
	move.w  #$820, destLeftBound.w
loc_20370C:
	move.w  #$410, destBottomBound.w
	cmpi.w  #$e00, cameraX.w
	bcs.s   loc_203720
	move.w  #$310, destBottomBound.w
loc_203720:
	rts     
LevEvents_PPZ2:
	move.w  #$310, destBottomBound.w
	rts     
LevEvents_PPZ3:
	tst.b   bossFlags.w
	bne.s   loc_203742
	move.w  #$310, destBottomBound.w
	move.w  #$d70, d0
	move.w  #$310, d1
	bsr.w   CheckBossStart
loc_203742:
	rts     
LevEvents_CCZ:
	moveq   #$0, d0
	move.b  act.l, d0
	add.w   d0, d0
	move.w  LevEvents_CCZ_Index(pc, d0.w), d0
	jmp     LevEvents_CCZ_Index(pc, d0.w)
LevEvents_CCZ_Index:
	dc.w	LevEvents_CCZ12-LevEvents_CCZ_Index
	dc.w	LevEvents_CCZ12-LevEvents_CCZ_Index
	dc.w	LevEvents_CCZ3-LevEvents_CCZ_Index
LevEvents_CCZ12:
	move.w  #$510, destBottomBound.w
	rts     
LevEvents_CCZ3:
	tst.b   bossFlags.w
	bne.w   loc_203774
	move.w  #$510, destBottomBound.w
	rts     
loc_203774:
	move.w  #$60, d1
	bra.w   SetBossBounds
LevEvents_WWZ:
	btst.b  #$4, bossFlags.w
	bne.s   loc_20378C
	move.w  #$710, destBottomBound.w
	rts     
loc_20378C:
	move.w  #$ba0, d0
	move.w  #$1d0, d1
	bsr.w   CheckBossStart
	bne.w   loc_2037D8
	lea     objects.w, a1
	cmpi.w  #$298, $c(a1)
	ble.s   loc_2037BC
	cmpi.w  #$498, $c(a1)
	ble.s   loc_2037B6
	move.w  #$5d0, d0
	bra.s   loc_2037C0
loc_2037B6:
	move.w  #$3d0, d0
	bra.s   loc_2037C0
loc_2037BC:
	move.w  #$1d0, d0
loc_2037C0:
	move.w  d0, d1
	move.w  d0, destBottomBound.w
	sub.w   bottomBound.w, d0
	bge.s   loc_2037CE
	neg.w   d0
loc_2037CE:
	cmpi.w  #$2, d0
	bgt.s   loc_2037D8
	move.w  d1, bottomBound.w
loc_2037D8:
	rts     
LevEvents_QQZ:
	moveq   #$0, d0
	move.b  act.l, d0
	add.w   d0, d0
	move.w  LevEvents_QQZ_Index(pc, d0.w), d0
	jmp     LevEvents_QQZ_Index(pc, d0.w)
LevEvents_QQZ_Index:
	dc.w	LevEvents_QQZ12-LevEvents_QQZ_Index
	dc.w	LevEvents_QQZ12-LevEvents_QQZ_Index
	dc.w	LevEvents_QQZ3-LevEvents_QQZ_Index
LevEvents_QQZ12:
	move.w  #$310, destBottomBound.w
	rts     
LevEvents_QQZ3:
	move.w  #$e10, d0
	move.w  #$1f8, d1
	bsr.w   CheckBossStart
	bne.s   loc_203814
	tst.b   bossFlags.w
	bne.s   loc_203816
	move.w  #$320, destBottomBound.w
loc_203814:
	rts     
loc_203816:
	move.w  #$1f8, bottomBound.w
	move.w  #$1f8, destBottomBound.w
	rts     
LevEvents_MMZ:
	moveq   #$0, d0
	move.b  act.l, d0
	add.w   d0, d0
	move.w  LevEvents_MMZ_Index(pc, d0.w), d0
	jmp     LevEvents_MMZ_Index(pc, d0.w)
LevEvents_MMZ_Index:
	dc.w	LevEvents_MMZ12-LevEvents_MMZ_Index
	dc.w	LevEvents_MMZ12-LevEvents_MMZ_Index
	dc.w	LevEvents_MMZ3-LevEvents_MMZ_Index
LevEvents_MMZ12:
	move.w  #$710, destBottomBound.w
	rts     
LevEvents_MMZ3:
	tst.b   bossFlags.w
	bne.s   loc_203852
	move.w  #$310, destBottomBound.w
	rts     
loc_203852:
	move.w  #$10c, d0
	move.w  d0, topBound.w
	move.w  d0, destTopBound.w
	move.w  d0, bottomBound.w
	move.w  d0, destBottomBound.w
	rts     
LevEvents_TTZ:
	moveq   #$0, d0
	move.b  act.l, d0
	add.w   d0, d0
	move.w  LevEvents_TTZ_Index(pc, d0.w), d0
	jmp     LevEvents_TTZ_Index(pc, d0.w)
LevEvents_TTZ_Index:
	dc.w	LevEvents_TTZ1-LevEvents_TTZ_Index
	dc.w	LevEvents_TTZ2-LevEvents_TTZ_Index
	dc.w	LevEvents_TTZ3-LevEvents_TTZ_Index
LevEvents_TTZ1:
	move.w  #$510, destBottomBound.w
	rts     
LevEvents_TTZ2:
	cmpi.b  #$2b, $FFFFD01C.w
	beq.s   loc_2038AC
	cmpi.b  #$6, $FFFFD024.w
	bcc.s   loc_2038AC
	move.w  #$800, bottomBound.w
	move.w  #$800, destBottomBound.w
	cmpi.w  #$200, cameraX.w
	bcs.s   loc_2038B8
loc_2038AC:
	move.w  #$710, bottomBound.w
	move.w  #$710, destBottomBound.w
loc_2038B8:
	rts     
LevEvents_TTZ3:
	move.w  #$af8, d0
	move.w  #$4c0, d1
	bsr.w   CheckBossStart
	bne.s   loc_2038CE
	tst.b   bossFlags.w
	bne.s   loc_2038D0
loc_2038CE:
	rts     
loc_2038D0:
	move.w  #$4f0, bottomBound.w
	move.w  #$4f0, destBottomBound.w
	rts     
LevEvents_SSZ:
	moveq   #$0, d0
	move.b  act.l, d0
	add.w   d0, d0
	move.w  LevEvents_SSZ_Index(pc, d0.w), d0
	jmp     LevEvents_SSZ_Index(pc, d0.w)
LevEvents_SSZ_Index:
	dc.w	LevEvents_SSZ1-LevEvents_SSZ_Index
	dc.w	LevEvents_SSZ2-LevEvents_SSZ_Index
	dc.w	LevEvents_SSZ3-LevEvents_SSZ_Index
LevEvents_SSZ1:
	move.w  #$510, destBottomBound.w
	rts     
LevEvents_SSZ2:
	move.w  #$710, destBottomBound.w
	rts     
LevEvents_SSZ3:
	lea     objects.w, a1
	cmpi.w  #$930, $8(a1)
	bge.s   loc_20391A
	move.w  #$210, destBottomBound.w
	rts     
loc_20391A:
	cmpi.w  #$dc0, $8(a1)
	blt.s   loc_20392A
	move.w  #$210, destBottomBound.w
	rts     
loc_20392A:
	move.w  #$120, d0
	move.w  d0, d1
	move.w  d0, destBottomBound.w
	sub.w   bottomBound.w, d1
	bpl.s   loc_20393C
	neg.w   d1
loc_20393C:
	cmpi.w  #$4, d1
	bge.s   loc_203946
	move.w  d0, bottomBound.w
loc_203946:
	rts     
CheckBossStart:
	cmp.w   $FFFFD008.w, d0
	ble.s   SetBossBounds
	moveq   #$0, d0
	rts     
SetBossBounds:
	move.w  d1, destBottomBound.w
	sub.w   bottomBound.w, d1
	bpl.s   loc_20395E
	neg.w   d1
loc_20395E:
	cmpi.w  #$4, d1
	bge.s   loc_20396A
	move.w  destBottomBound.w, bottomBound.w
loc_20396A:
	move.w  $FFFFD008.w, d0
	subi.w  #$a0, d0
	cmp.w   leftBound.w, d0
	blt.s   loc_20398A
	cmp.w   rightBound.w, d0
	ble.s   loc_203982
	move.w  rightBound.w, d0
loc_203982:
	move.w  d0, leftBound.w
	move.w  d0, destLeftBound.w
loc_20398A:
	moveq   #$1, d0
	rts     
RunObjects:
	lea     objects.w, a0
	moveq   #$7f, d7
	moveq   #$0, d0
loc_203996:
	move.b  (a0), d0
	beq.s   loc_2039AC
	add.w   d0, d0
	add.w   d0, d0
	lea     ObjectIndex.l, a1
	movea.l -$4(a1, d0.w), a1
	jsr     (a1)
	moveq   #$0, d0
loc_2039AC:
	lea     $40(a0), a0
	dbra    d7, loc_203996
	rts     
ObjMoveGrv:
	move.l  oX(a0), d2
	move.l  oY(a0), d3
	move.w  oXVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, d2
	move.w  oYVel(a0), d0
	btst.b  #$3, $2c(a0)
	bne.s   loc_2039F4
	bpl.s   loc_2039E6
	btst.b  #$1, $2c(a0)
	beq.s   loc_2039E6
	cmpi.w  #$f800, oYVel(a0)
	bcs.s   loc_2039F4
loc_2039E6:
	btst.b  #$2, $2c(a0)
	bne.s   loc_2039F4
	addi.w  #$38, oYVel(a0)
loc_2039F4:
	tst.w   oYVel(a0)
	bmi.s   loc_203A08
	cmpi.w  #$1000, oYVel(a0)
	bcs.s   loc_203A08
	move.w  #$1000, oYVel(a0)
loc_203A08:
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, d3
	move.l  d2, oX(a0)
	move.l  d3, oY(a0)
	rts     
ObjMove:
	move.l  oX(a0), d2
	move.l  oY(a0), d3
	move.w  oXVel(a0), d0
	btst.b  #$3, oFlags(a0)
	beq.s   loc_203A54
	moveq   #$0, d1
	move.b  $3d(a0), d1
	lsl.w   #$6, d1
	addi.l  #$ffd000, d1
	movea.l d1, a1
	dc.b	$0C,$29,$00,$1E,$00,$00		; cmpi.b #$1e, $0(a1) (raw: not reproducible by assembler / suspicious)
	bne.s   loc_203A54
	move.w  #$ff00, d1
	btst.b  #$0, $22(a1)
	beq.s   loc_203A52
	neg.w   d1
loc_203A52:
	add.w   d1, d0
loc_203A54:
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, d2
	move.w  oYVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, d3
	move.l  d2, oX(a0)
	move.l  d3, oY(a0)
	rts     
DrawObject:
	bclr.b  #$7, oSprFlags(a0)
	move.b  oSprFlags(a0), d0
	andi.w  #$c, d0
	beq.w   loc_203ADE
	move.b  oWidth(a0), d0
	move.w  oX(a0), d3
	sub.w   cameraX.w, d3
	move.w  d3, d1
	add.w   d0, d1
	bmi.s   loc_203AFA
	move.w  d3, d1
	sub.w   d0, d1
	cmpi.w  #$140, d1
	bge.s   loc_203AFA
	move.b  oYRadius(a0), d0
	move.w  oY(a0), d3
	cmpi.w  #$100, cameraY.w
	bcc.s   loc_203AB8
	cmpi.w  #$800, d3
	bcs.s   loc_203ACA
	subi.w  #$800, d3
	bra.s   loc_203ACA
loc_203AB8:
	cmpi.w  #$700, cameraY.w
	bcs.s   loc_203ACA
	cmpi.w  #$100, d3
	bcc.s   loc_203ACA
	addi.w  #$800, d3
loc_203ACA:
	sub.w   cameraY.w, d3
	move.w  d3, d1
	add.w   d0, d1
	bmi.s   loc_203AFA
	move.w  d3, d1
	sub.w   d0, d1
	cmpi.w  #$e0, d1
	bge.s   loc_203AFA
loc_203ADE:
	lea     objDrawQueue.w, a1
	move.w  oPriority(a0), d0
	lsr.w   #$1, d0
	andi.w  #$380, d0
	adda.w  d0, a1
	cmpi.w  #$7e, (a1)
	bcc.s   loc_203AFA
	addq.w  #$2, (a1)
	adda.w  (a1), a1
	move.w  a0, (a1)
loc_203AFA:
	rts     
	lea     objDrawQueue.w, a2
	move.w  $18(a1), d0
	lsr.w   #$1, d0
	andi.w  #$380, d0
	adda.w  d0, a2
	cmpi.w  #$7e, (a2)
	bcc.s   loc_203B18
	addq.w  #$2, (a2)
	adda.w  (a2), a2
	move.w  a1, (a2)
loc_203B18:
	rts     
DeleteObject:
	movea.l a0, a1
	moveq   #$0, d1
	moveq   #$f, d0
loc_203B20:
	move.l  d1, (a1)+
	dbra    d0, loc_203B20
	rts     
ObjDrawCameras:
	dc.w	$0000,$0000,$00FF,$F700,$00FF,$F708,$00FF,$F718
DrawObjects:
	lea     sprites.w, a2
	moveq   #$0, d5
	lea     objDrawQueue.w, a4
	moveq   #$7, d7
loc_203B44:
	tst.w   (a4)
	beq.w   loc_203C04
	moveq   #$2, d6
loc_203B4C:
	movea.w (a4, d6.w), a0
	tst.b   (a0)
	beq.w   loc_203BFC
	move.b  oSprFlags(a0), d0
	move.b  d0, d4
	andi.w  #$c, d0
	beq.w   loc_203BB2
	movea.l ObjDrawCameras(pc, d0.w), a1
	moveq   #$0, d0
	move.b  oWidth(a0), d0
	move.w  oX(a0), d3
	sub.w   (a1), d3
	addi.w  #$80, d3
	moveq   #$0, d0
	move.b  oYRadius(a0), d0
	move.w  oY(a0), d2
	cmpi.w  #$100, $4(a1)
	bcc.s   loc_203B96
	cmpi.w  #$800, d2
	bcs.s   loc_203BA8
	subi.w  #$800, d2
	bra.s   loc_203BA8
loc_203B96:
	cmpi.w  #$700, $4(a1)
	bcs.s   loc_203BA8
	cmpi.w  #$100, d2
	bcc.s   loc_203BA8
	addi.w  #$800, d2
loc_203BA8:
	sub.w   $4(a1), d2
	addi.w  #$80, d2
	bra.s   loc_203BD4
loc_203BB2:
	move.w  oYScr(a0), d2
	move.w  oX(a0), d3
	bra.s   loc_203BD4
	move.w  oY(a0), d2
	sub.w   $4(a1), d2
	addi.w  #$80, d2
	cmpi.w  #$60, d2
	bcs.s   loc_203BFC
	cmpi.w  #$180, d2
	bcc.s   loc_203BFC
loc_203BD4:
	movea.l oMap(a0), a1
	moveq   #$0, d1
	btst.l  #$5, d4
	bne.s   loc_203BF2
	move.b  oMapFrame(a0), d1
	add.w   d1, d1
	adda.w  (a1, d1.w), a1
	moveq   #$0, d1
	move.b  (a1)+, d1
	subq.b  #$1, d1
	bmi.s   loc_203BF6
loc_203BF2:
	bsr.w   DrawSprite
loc_203BF6:
	bset.b  #$7, oSprFlags(a0)
loc_203BFC:
	addq.w  #$2, d6
	subq.w  #$2, (a4)
	bne.w   loc_203B4C
loc_203C04:
	lea     $80(a4), a4
	dbra    d7, loc_203B44
	move.b  d5, spriteCount.w
	cmpi.b  #$50, d5
	beq.s   loc_203C1E
	move.l  #$0, (a2)
	rts     
loc_203C1E:
	move.b  #$0, -$5(a2)
	rts     
DrawSprite:
	movea.w oTile(a0), a3
	btst.l  #$0, d4
	bne.s   DrawSprite_FlipX
	btst.l  #$1, d4
	bne.w   DrawSprite_FlipY
loc_203C38:
	cmpi.b  #$50, d5
	beq.s   loc_203C6A
	move.b  (a1)+, d0
	ext.w   d0
	add.w   d2, d0
	move.w  d0, (a2)+
	move.b  (a1)+, (a2)+
	addq.b  #$1, d5
	move.b  d5, (a2)+
	move.b  (a1)+, d0
	lsl.w   #$8, d0
	move.b  (a1)+, d0
	add.w   a3, d0
	move.w  d0, (a2)+
	move.b  (a1)+, d0
	ext.w   d0
	add.w   d3, d0
	andi.w  #$1ff, d0
	bne.s   loc_203C64
	addq.w  #$1, d0
loc_203C64:
	move.w  d0, (a2)+
	dbra    d1, loc_203C38
loc_203C6A:
	rts     
DrawSprite_FlipX:
	btst.l  #$1, d4
	bne.w   loc_203D00
loc_203C74:
	cmpi.b  #$50, d5
	beq.s   loc_203CB8
	move.b  (a1)+, d0
	ext.w   d0
	add.w   d2, d0
	move.w  d0, (a2)+
	move.b  (a1)+, d4
	move.b  d4, (a2)+
	addq.b  #$1, d5
	move.b  d5, (a2)+
	move.b  (a1)+, d0
	lsl.w   #$8, d0
	move.b  (a1)+, d0
	add.w   a3, d0
	eori.w  #$800, d0
	move.w  d0, (a2)+
	move.b  (a1)+, d0
	ext.w   d0
	neg.w   d0
	add.b   d4, d4
	andi.w  #$18, d4
	addq.w  #$8, d4
	sub.w   d4, d0
	add.w   d3, d0
	andi.w  #$1ff, d0
	bne.s   loc_203CB2
	addq.w  #$1, d0
loc_203CB2:
	move.w  d0, (a2)+
	dbra    d1, loc_203C74
loc_203CB8:
	rts     
DrawSprite_FlipY:
	cmpi.b  #$50, d5
	beq.s   loc_203CFE
	move.b  (a1)+, d0
	move.b  (a1), d4
	ext.w   d0
	neg.w   d0
	lsl.b   #$3, d4
	andi.w  #$18, d4
	addq.w  #$8, d4
	sub.w   d4, d0
	add.w   d2, d0
	move.w  d0, (a2)+
	move.b  (a1)+, (a2)+
	addq.b  #$1, d5
	move.b  d5, (a2)+
	move.b  (a1)+, d0
	lsl.w   #$8, d0
	move.b  (a1)+, d0
	add.w   a3, d0
	eori.w  #$1000, d0
	move.w  d0, (a2)+
	move.b  (a1)+, d0
	ext.w   d0
	add.w   d3, d0
	andi.w  #$1ff, d0
	bne.s   loc_203CF8
	addq.w  #$1, d0
loc_203CF8:
	move.w  d0, (a2)+
	dbra    d1, DrawSprite_FlipY
loc_203CFE:
	rts     
loc_203D00:
	cmpi.b  #$50, d5
	beq.s   loc_203D52
	move.b  (a1)+, d0
	move.b  (a1), d4
	ext.w   d0
	neg.w   d0
	lsl.b   #$3, d4
	andi.w  #$18, d4
	addq.w  #$8, d4
	sub.w   d4, d0
	add.w   d2, d0
	move.w  d0, (a2)+
	move.b  (a1)+, d4
	move.b  d4, (a2)+
	addq.b  #$1, d5
	move.b  d5, (a2)+
	move.b  (a1)+, d0
	lsl.w   #$8, d0
	move.b  (a1)+, d0
	add.w   a3, d0
	eori.w  #$1800, d0
	move.w  d0, (a2)+
	move.b  (a1)+, d0
	ext.w   d0
	neg.w   d0
	add.b   d4, d4
	andi.w  #$18, d4
	addq.w  #$8, d4
	sub.w   d4, d0
	add.w   d3, d0
	andi.w  #$1ff, d0
	bne.s   loc_203D4C
	addq.w  #$1, d0
loc_203D4C:
	move.w  d0, (a2)+
	dbra    d1, loc_203D00
loc_203D52:
	rts     
	move.w  oX(a0), d0
	sub.w   cameraX.w, d0
	bmi.s   loc_203D78
	cmpi.w  #$140, d0
	bge.s   loc_203D78
	move.w  oY(a0), d1
	sub.w   cameraY.w, d1
	bmi.s   loc_203D78
	cmpi.w  #$e0, d1
	bge.s   loc_203D78
	moveq   #$0, d0
	rts     
loc_203D78:
	moveq   #$1, d0
	rts     
	moveq   #$0, d1
	move.b  oWidth(a0), d1
	move.w  oX(a0), d0
	sub.w   cameraX.w, d0
	add.w   d1, d0
	bmi.s   loc_203DAC
	add.w   d1, d1
	sub.w   d1, d0
	cmpi.w  #$140, d0
	bge.s   loc_203DAC
	move.w  oY(a0), d1
	sub.w   cameraY.w, d1
	bmi.s   loc_203DAC
	cmpi.w  #$e0, d1
	bge.s   loc_203DAC
	moveq   #$0, d0
	rts     
loc_203DAC:
	moveq   #$1, d0
	rts     
ObjectIndex:
	dc.l	Obj01_203F0E
	dc.l	Obj01_203F0E
	dc.l	ObjPowerup
	dc.l	ObjNull
	dc.l	ObjNull
	dc.l	ObjTestBadnik
	dc.l	ObjNull
	dc.l	ObjNull
	dc.l	ObjNull
	dc.l	ObjSpring
	dc.l	ObjTunnelDoorSplash
	dc.l	ObjTunnelDoor_ChkCollision
	dc.l	ObjTunnelDoor
	dc.l	ObjSpinSplash
	dc.l	ObjMovingSpring
	dc.l	Obj10_209776
	dc.l	ObjLostRing
	dc.l	ObjFloatBlock
	dc.l	ObjCheckpoint
	dc.l	ObjBigRing
	dc.l	ObjCapsule
	dc.l	ObjGoalPost
	dc.l	Obj17_20D956
	dc.l	ObjExplosion
	dc.l	ObjMonitorTimepost
	dc.l	ObjMonitorItem
	dc.l	Obj1B_2090E2
	dc.l	ObjHUDPoints
	dc.l	Obj1D_20ADAC
	dc.l	Obj1E_20AF16
	dc.l	ObjFlower
	dc.l	Obj20_20BF76
	dc.l	Obj21_20C1A4
	dc.l	Obj22_20C2E2
	dc.l	Obj23_20C452
	dc.l	Obj24_20D008
	dc.l	Obj25_20D288
	dc.l	Obj26_20C7BE
	dc.l	Data_20C8E2
	dc.l	Obj28_20CD10
	dc.l	Obj29_20B29C
	dc.l	Obj2A_20B136
	dc.l	Obj2B_20B5D6
	dc.l	Obj2C_20BD2E
	dc.l	Obj2D_20B336
	dc.l	Obj2E_20B936
	dc.l	Obj2F_20B5DE
	dc.l	Obj30_20E340
	dc.l	Obj31_20DE5E
	dc.l	Obj32_20E09A
	dc.l	Obj33_20E572
	dc.l	ObjGameOver
	dc.l	ObjSpinTunnel
	dc.l	ObjNull
	dc.l	ObjRobotGenerator
	dc.l	ObjProjector
	dc.l	ObjAnimal
	dc.l	ObjResults
	dc.l	Obj3B_20F18C
	dc.l	Obj3C_20F2A8
ObjNull:
	move.b  #$0, (a0)
	rts     
ObjSonic_ChkBoredom:
	lea     boredTimer.w, a1
	cmpi.b  #$5, oAnim(a0)
	beq.s   loc_203EB8
	move.w  #$0, (a1)
	rts     
loc_203EB8:
	tst.w   (a1)
	bne.s   loc_203EC2
	move.b  #$1, $1(a1)
loc_203EC2:
	cmpi.w  #$2a30, (a1)
	bcs.s   loc_203F0C
	move.w  #$0, (a1)
	move.b  #$2b, oAnim(a0)
	ori.b   #$80, oTile(a0)
	move.b  #$0, oPriority(a0)
	move.b  #$1, lives.l
	move.w  #$fb00, oYVel(a0)
	move.w  #$100, oXVel(a0)
	btst.b  #$0, oFlags(a0)
	beq.s   loc_203EFE
	neg.w   oXVel(a0)
loc_203EFE:
	move.w  #$0, $14(a0)
	move.w  #$79, d0
	bra.w   SubCPUCmd
loc_203F0C:
	rts     
Obj01_203F0E:
	dc.w	$4A39,$00FF,$0F01,$6614,$B0FC,$D040,$670E,$4A39
	dc.w	$00FF,$1906,$6706,$4EF9,$0020,$75D6,$1028,$002A
	dc.w	$6724,$5200,$0828,$0002,$0022,$670C,$0C00,$002D
	dc.w	$6510,$103C,$002D,$600A,$0C00,$001E,$6504,$103C
	dc.w	$001E,$1140,$002A,$7000,$1028,$0024,$323B,$0006
	dc.w	$4EFB,$1002,$004C,$018C,$13FE,$1470,$14F8
ObjSonic_MakeTimeWarpStars:
	tst.b   objTimeStar1Slot.w
	bne.s   loc_203FAA
	move.b  #$1, timeWarp.l
	move.b  #$3, objTimeStar1Slot.w
	move.b  #$5, $FFFFD31C.w
	move.b  #$3, objTimeStar2Slot.w
	move.b  #$6, $FFFFD35C.w
	move.b  #$3, objTimeStar3Slot.w
	move.b  #$7, $FFFFD39C.w
	move.b  #$3, objTimeStar4Slot.w
	move.b  #$8, $FFFFD3DC.w
loc_203FAA:
	rts     
	dc.w	$4E75
	dc.w	$5428,$0024,$117C,$0013,$0016,$117C,$0009,$0017
	dc.w	$4A39,$00FF,$195B,$670C,$117C,$000A,$0016,$117C
	dc.w	$0005,$0017,$217C,$0022,$DF20,$0004,$317C,$0780
	dc.w	$0002,$117C,$0002,$0018,$117C,$0018,$0019,$117C
	dc.w	$0004,$0001,$31FC,$0600,$F760,$31FC,$000C,$F762
	dc.w	$31FC,$0080,$F764,$4E75,$4A39,$00FF,$1506,$665E
	dc.w	$1039,$00FF,$1505,$0200,$0001,$6652,$1428,$0016
	dc.w	$4882,$D468,$000C,$3628,$0008,$6100,$0046,$0C01
	dc.w	$002F,$663C,$0C68,$15C0,$0008,$6432,$4A28,$002C
	dc.w	$672C,$4EB9,$0020,$7B0A,$6624,$137C,$000E,$0000
	dc.w	$3368,$0008,$0008,$3368,$000C,$000C,$7001,$4A68
	dc.w	$0010,$6B02,$7000,$1340,$0001,$1340,$0022,$4E75
	dc.w	$4E75,$3002,$E248,$0240,$0380,$3203,$E049,$0241
	dc.w	$007F,$D041,$223C,$0021,$0000,$43F8,$A000,$1231
	dc.w	$0000,$0201,$007F,$4E75
	dc.w	$3238,$F7A0,$3028,$0014,$6A02,$4440,$0828,$0001
	dc.w	$002C,$6708,$0C68,$1B00,$0008,$6528,$0C40,$0600
	dc.w	$6522,$4A68,$0014,$6A0E,$5441,$0C41,$00E0,$6522
	dc.w	$323C,$00E0,$601C,$5541,$0C41,$0060,$6414,$323C
	dc.w	$0060,$600E,$0C41,$00A0,$6708,$6404,$5441,$6002
	dc.w	$5541,$31C1,$F7A0,$4E75
	dc.w	$61A6,$6100,$FF14,$4A79,$00FF,$1588,$6712,$0838
	dc.w	$0004,$F605,$670A,$13FC,$0001,$00FF,$1906,$4E75
	dc.w	$4A38,$F7CC,$6606,$31F8,$F604,$F602,$0828,$0000
	dc.w	$002C,$671C,$0C39,$0006,$00FF,$1506,$660C,$4278
	dc.w	$F786,$4239,$00FF,$1521,$601E,$6100,$02E6,$6018
	dc.w	$7000,$1028,$0022,$0240,$0006,$323B,$0052,$4EBB
	dc.w	$104E,$4EB9,$0020,$66F0,$6152,$6100,$0110,$6100
	dc.w	$0126,$1178,$F768,$0036,$1178,$F76A,$0037,$4A38
	dc.w	$F7C7,$670C,$4A28,$001C,$6606,$1168,$001D,$001C
	dc.w	$6100,$14A8,$4A28,$002C,$6B0E,$0C28,$002B,$001C
	dc.w	$6706,$4EB9,$0020,$7180,$6100,$1346,$4E75,$036A
	dc.w	$03C6,$0412,$0440,$8182,$8384,$8586,$0C78,$00D2
	dc.w	$F786,$641C,$3028,$0030,$6708,$5368,$0030,$E648
	dc.w	$640E,$0828,$0006,$002C,$6606,$4EB9,$0020,$3A6E
	dc.w	$4A39,$00FF,$151F,$673C,$4A68,$0032,$6736,$5368
	dc.w	$0032,$6630,$4A39,$00FF,$1520,$6620,$4A39,$00FF
	dc.w	$1958,$6618,$4A39,$00FF,$152E,$660A,$303C,$000E
	dc.w	$4EB9,$0020,$5C38,$4EB9,$0020,$1A72,$13FC,$0000
	dc.w	$00FF,$151F,$4A39,$00FF,$1520,$674E,$4A68,$0034
	dc.w	$6748,$5368,$0034,$6642,$31FC,$0600,$F760,$31FC
	dc.w	$000C,$F762,$31FC,$0080,$F764,$4A39,$00FF,$151F
	dc.w	$6620,$4A39,$00FF,$1958,$6618,$4A39,$00FF,$152E
	dc.w	$660A,$303C,$000E,$4EB9,$0020,$5C38,$4EB9,$0020
	dc.w	$1A72,$13FC,$0000,$00FF,$1520,$4E75
ObjSonic_RecordPos:
	move.w  sonicRecordIndex.w, d0
	lea     sonicRecordBuf.w, a1
	lea     (a1, d0.w), a1
	move.w  oX(a0), (a1)+
	move.w  oY(a0), (a1)+
	addq.b  #$4, $FFFFF7A9.w
	rts     
	cmpi.b  #$2, zoneAct.l
	beq.s   loc_204290
loc_20428E:
	rts     
loc_204290:
	cmpi.b  #$1, act.l
	bne.s   loc_2042A2
	cmpi.w  #$c8, oX(a0)
	bcs.s   loc_20428E
loc_2042A2:
	move.w  waterHeight.w, d0
	cmp.w   oY(a0), d0
	bge.s   loc_2042E6
	bset.b  #$6, oFlags(a0)
	bne.s   loc_20428E
	bsr.w   ResumeMusicS1
	move.b  #$21, objBubblesSlot.w
	move.b  #$81, $FFFFD1E8.w
	move.w  #$300, sonicTopSpeed.w
	move.w  #$6, sonicAcceleration.w
	move.w  #$40, sonicDeceleration.w
	asr.w   oXVel(a0)
	asr.w   oYVel(a0)
	asr.w   oYVel(a0)
	beq.s   loc_20428E
	bra.s   loc_20431E
loc_2042E6:
	tst.w   oYVel(a0)
	beq.s   loc_2042EE
	bpl.s   loc_20428E
loc_2042EE:
	bclr.b  #$6, oFlags(a0)
	beq.s   loc_20428E
	move.w  #$600, sonicTopSpeed.w
	move.w  #$c, sonicAcceleration.w
	move.w  #$80, sonicDeceleration.w
	asl.w   oYVel(a0)
	beq.w   loc_20428E
	cmpi.w  #$f000, oYVel(a0)
	bgt.s   loc_20431E
	move.w  #$f000, oYVel(a0)
loc_20431E:
	jsr     FindObjSlot.l
	bne.s   loc_204332
	dc.b	$13,$7C,$00,$0B,$00,$00		; move.b #$b, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
loc_204332:
	rts     
SaveTimeWarpData:
	move.b  spawnMode.l, warpSpawnMode.l
	move.w  oX(a0), warpX.l
	move.w  oY(a0), warpY.l
	move.w  $14(a0), warpGVel.l
	move.w  oXVel(a0), warpXVel.l
	move.w  oYVel(a0), warpYVel.l
	move.b  oFlags(a0), warpPlayerFlags.l
	bclr.b  #$3, warpPlayerFlags.l
	bclr.b  #$6, warpPlayerFlags.l
	move.b  waterRoutine.w, warpWaterRoutine.l
	move.w  bottomBound.w, warpBtmBound.l
	move.w  cameraX.w, warpCamX.l
	move.w  cameraY.w, warpCamY.l
	move.w  cameraBgX.w, warpCamBgX.l
	move.w  cameraBgY.w, warpCamBgY.l
	move.w  cameraBg2X.w, warpCamBg2X.l
	move.w  cameraBg2Y.w, warpCamBg2Y.l
	move.w  cameraBg3X.w, warpCamBg3X.l
	move.w  cameraBg3Y.w, warpCamBg3Y.l
	move.w  waterHeight2.w, warpWaterHeight.l
	move.b  waterRoutine.w, warpWaterRoutine.l
	move.b  waterFullscreen.w, warpWaterFull.l
	move.w  rings.l, warpRings.l
	move.b  livesFlags.l, warpLivesFlags.l
	move.l  time.l, d0
	cmpi.l  #$50000, d0
	bcs.s   loc_20440E
	move.l  #$50000, d0
loc_20440E:
	move.l  d0, warpTime.l
	move.b  miniSonic.l, warpMiniSonic.l
	rts     
ObjSonic_TimeWarp:
	cmpi.w  #$0, zoneAct.l
	bne.s   loc_204446
	tst.b   timeZone.l
	beq.s   loc_20443C
	cmpi.b  #$2, timeZone.l
	bne.s   loc_204446
loc_20443C:
	cmpi.w  #$900, oX(a0)
	bcs.w   loc_2044F6
loc_204446:
	tst.b   $2a(a0)
	bne.w   loc_204504
	tst.b   timeWarpDir.w
	beq.w   loc_204504
	move.w  #$600, d2
	moveq   #$0, d0
	move.w  $14(a0), d0
	bpl.s   loc_204464
	neg.w   d0
loc_204464:
	tst.w   timeWarpTimer.w
	bne.s   loc_204470
	move.w  #$1, timeWarpTimer.w
loc_204470:
	move.w  timeWarpTimer.w, d1
	cmpi.w  #$e6, d1
	bcs.s   loc_204486
	move.b  #$1, levelRestart.l
	bra.w   FadeOutMusic
loc_204486:
	cmpi.w  #$d2, d1
	bcs.s   loc_2044DA
	cmpi.b  #$2, spawnMode.l
	beq.s   loc_2044D8
	move.b  #$1, scrollLock.w
	move.b  timeZone.l, d0
	bne.s   loc_2044B0
	move.w  #$82, d0
	jsr     SubCPUCmd.l
	moveq   #$0, d0
loc_2044B0:
	add.b   timeWarpDir.w, d0
	bpl.s   loc_2044BA
	moveq   #$0, d0
	bra.s   loc_2044C2
loc_2044BA:
	cmpi.b  #$3, d0
	bcs.s   loc_2044C2
	moveq   #$2, d0
loc_2044C2:
	bset.l  #$7, d0
	move.b  d0, timeZone.l
	bsr.w   SaveTimeWarpData
	move.b  #$2, spawnMode.l
loc_2044D8:
	rts     
loc_2044DA:
	cmpi.w  #$5a, d1
	bcc.s   loc_2044F2
	cmp.w   d2, d0
	bcc.w   ObjSonic_MakeTimeWarpStars
	clr.w   timeWarpTimer.w
	clr.b   timeWarp.l
	rts     
loc_2044F2:
	cmp.w   d2, d0
	bcc.s   loc_204504
loc_2044F6:
	clr.w   timeWarpTimer.w
	clr.b   timeWarpDir.w
	clr.b   timeWarp.l
loc_204504:
	rts     
	bsr.w   ObjSonic_ChkBoredom
	cmpi.b  #$2b, oAnim(a0)
	bne.s   loc_204536
	tst.b   miniSonic.l
	beq.s   loc_204524
	cmpi.b  #$79, oMapFrame(a0)
	bne.s   loc_204560
	bra.s   loc_20452C
loc_204524:
	cmpi.b  #$17, oMapFrame(a0)
	bcs.s   loc_204560
loc_20452C:
	bsr.w   ObjSonic_LevelBound
	jmp     ObjMoveGrv.l
loc_204536:
	bsr.w   ObjSonic_Handle3DRamp
	bsr.w   ObjSonic_TimeWarp
	bsr.w   ObjSonic_CheckJump
	bsr.w   ObjSonic_SlopeResist
	bsr.w   ObjSonic_MoveGround
	bsr.w   ObjSonic_CheckRoll
	bsr.w   ObjSonic_LevelBound
	jsr     ObjMove.l
	bsr.w   Player_GroundCol
	bsr.w   ObjSonic_CheckFallOff
loc_204560:
	rts     
	tst.b   windTunnelFlag.w
	bne.s   loc_20457C
	cmpi.b  #$15, oAnim(a0)
	beq.s   loc_20457C
	tst.w   oYVel(a0)
	bmi.s   loc_20457C
	move.b  #$0, oAnim(a0)
loc_20457C:
	bsr.w   ObjSonic_Handle3DRamp
	bsr.w   ObjSonic_TimeWarp
	bsr.w   ObjSonic_JumpHeight
	bsr.w   ObjSonic_MoveAir
	bsr.w   ObjSonic_LevelBound
	jsr     ObjMoveGrv.l
	btst.b  #$6, oFlags(a0)
	beq.s   loc_2045A4
	subi.w  #$28, oYVel(a0)
loc_2045A4:
	bsr.w   ObjSonic_JumpAngle
	bsr.w   Player_LevelColInAir
	rts     
	bsr.w   ObjSonic_Handle3DRamp
	bsr.w   ObjSonic_TimeWarp
	bsr.w   ObjSonic_CheckJump
	bsr.w   ObjSonic_SlopeResistRoll
	bsr.w   ObjSonic_MoveRoll
	bsr.w   ObjSonic_LevelBound
	tst.b   $2a(a0)
	bne.s   loc_2045D2
	jsr     ObjMove.l
loc_2045D2:
	bsr.w   Player_GroundCol
	bsr.w   ObjSonic_CheckFallOff
	rts     
	bsr.w   ObjSonic_Handle3DRamp
	bsr.w   ObjSonic_TimeWarp
	bsr.w   ObjSonic_JumpHeight
	bsr.w   ObjSonic_MoveAir
	bsr.w   ObjSonic_LevelBound
	jsr     ObjMoveGrv.l
	btst.b  #$6, oFlags(a0)
	beq.s   loc_204604
	subi.w  #$28, oYVel(a0)
loc_204604:
	bsr.w   ObjSonic_JumpAngle
	bsr.w   Player_LevelColInAir
	rts     
ObjSonic_Handle3DRamp:
	cmpi.b  #$1, timeZone.l
	bne.s   loc_20467A
	tst.w   zoneAct.l
	bne.s   loc_20467A
	move.w  oY(a0), d0
	lsr.w   #$1, d0
	andi.w  #$380, d0
	move.b  oX(a0), d1
	andi.w  #$7f, d1
	add.w   d1, d0
	lea     levelLayout.w, a1
	move.b  (a1, d0.w), d1
	lea     loc_20467C.l, a2
loc_204642:
	move.b  (a2)+, d0
	bmi.s   loc_204652
	cmp.b   d0, d1
	bne.s   loc_204642
	bset.b  #$1, $2c(a0)
	rts     
loc_204652:
	bclr.b  #$1, $2c(a0)
	beq.s   loc_20467A
	tst.w   oYVel(a0)
	bpl.s   loc_20467A
	cmpi.w  #$f800, oYVel(a0)
	bcc.s   loc_20467A
	move.w  #$600, oXVel(a0)
	btst.b  #$0, oFlags(a0)
	beq.s   loc_20467A
	neg.w   oXVel(a0)
loc_20467A:
	rts     
loc_20467C:
	dc.w	$0607,$0849,$4CFF
ObjSonic_MoveGround:
	move.w  sonicTopSpeed.w, d6
	move.w  sonicAcceleration.w, d5
	move.w  sonicDeceleration.w, d4
	tst.b   waterSlideFlag.w
	bne.w   loc_2049AC
	tst.w   $3e(a0)
	bne.w   loc_20495C
	btst.b  #$2, playerCtrl.w
	beq.s   loc_2046AA
	bsr.w   ObjSonic_MoveGndLeft
loc_2046AA:
	btst.b  #$3, playerCtrl.w
	beq.s   loc_2046B6
	bsr.w   ObjSonic_MoveGndRight
loc_2046B6:
	move.b  oAngle(a0), d0
	addi.b  #$20, d0
	andi.b  #$c0, d0
	bne.w   loc_20495C
	tst.w   $14(a0)
	beq.s   loc_2046D6
	tst.b   $2a(a0)
	beq.w   loc_20495C
	bra.s   loc_2046E2
loc_2046D6:
	bclr.b  #$5, oFlags(a0)
	move.b  #$5, oAnim(a0)
loc_2046E2:
	btst.b  #$3, oFlags(a0)
	beq.s   loc_204734
	moveq   #$0, d0
	move.b  $3d(a0), d0
	lsl.w   #$6, d0
	lea     objects.w, a1
	lea     (a1, d0.w), a1
	tst.b   $22(a1)
	bmi.w   loc_20478C
	dc.b	$0C,$29,$00,$1E,$00,$00		; cmpi.b #$1e, $0(a1) (raw: not reproducible by assembler / suspicious)
	bne.s   loc_204714
	move.b  #$0, oAnim(a0)
	bra.w   loc_20495C
loc_204714:
	moveq   #$0, d1
	move.b  $19(a1), d1
	move.w  d1, d2
	add.w   d2, d2
	subq.w  #$4, d2
	add.w   oX(a0), d1
	sub.w   $8(a1), d1
	cmpi.w  #$4, d1
	blt.s   loc_204770
	cmp.w   d2, d1
	bge.s   loc_20475E
	bra.s   loc_20478C
loc_204734:
	jsr     ObjGetFloorDist.l
	cmpi.w  #$c, d1
	blt.s   loc_20478C
	move.w  #$ab, d0
	jsr     PlayFMSound.l
	move.b  #$0, $2a(a0)
	move.w  #$0, $14(a0)
	cmpi.b  #$3, $36(a0)
	bne.s   loc_204768
loc_20475E:
	btst.b  #$0, oFlags(a0)
	bne.s   loc_204778
	bra.s   loc_204782
loc_204768:
	cmpi.b  #$3, $37(a0)
	bne.s   loc_20478C
loc_204770:
	btst.b  #$0, oFlags(a0)
	bne.s   loc_204782
loc_204778:
	move.b  #$32, oAnim(a0)
	bra.w   loc_20495C
loc_204782:
	move.b  #$6, oAnim(a0)
	bra.w   loc_20495C
loc_20478C:
	move.b  lookMode.w, d0
	andi.b  #$f, d0
	beq.s   loc_2047A0
	addq.b  #$1, lookMode.w
	andi.b  #$cf, lookMode.w
loc_2047A0:
	btst.b  #$7, lookMode.w
	bne.w   loc_2048A4
	btst.b  #$6, lookMode.w
	bne.w   loc_2048C4
	btst.b  #$1, playerCtrl.w
	bne.w   loc_2048C4
	andi.b  #$f, lookMode.w
	beq.s   loc_2047D8
	btst.b  #$0, playerCtrlTap.w
	beq.s   loc_2047EC
	bset.b  #$7, lookMode.w
	bra.w   loc_204980
loc_2047D8:
	btst.b  #$0, playerCtrlTap.w
	beq.w   loc_2047EC
	move.b  #$1, lookMode.w
	bra.w   loc_204980
loc_2047EC:
	btst.b  #$0, playerCtrl.w
	beq.s   loc_204868
	move.b  #$7, oAnim(a0)
	tst.b   $2a(a0)
	beq.s   loc_20484A
	move.b  #$0, oAnim(a0)
	moveq   #$64, d0
	move.w  sonicTopSpeed.w, d1
	move.w  d1, d2
	asl.w   #$1, d1
	tst.b   speedShoes.l
	beq.s   loc_20481C
	asr.w   #$1, d2
	sub.w   d2, d1
loc_20481C:
	btst.b  #$0, oFlags(a0)
	beq.s   loc_204828
	neg.w   d0
	neg.w   d1
loc_204828:
	add.w   d0, $14(a0)
	move.w  $14(a0), d0
	btst.b  #$0, oFlags(a0)
	beq.s   loc_20483E
	cmp.w   d0, d1
	ble.s   loc_204844
	bra.s   loc_204842
loc_20483E:
	cmp.w   d1, d0
	ble.s   loc_204844
loc_204842:
	move.w  d1, d0
loc_204844:
	move.w  d0, $14(a0)
	rts     
loc_20484A:
	move.b  playerCtrlTap.w, d0
	andi.b  #$70, d0
	beq.s   loc_204864
	move.b  #$1, $2a(a0)
	move.w  #$9c, d0
	jsr     PlayFMSound.l
loc_204864:
	bra.w   loc_204980
loc_204868:
	cmpi.b  #$1e, $2a(a0)
	beq.s   loc_204888
	move.w  #$ab, d0
	jsr     PlayFMSound.l
	move.b  #$0, $2a(a0)
	move.w  #$0, $14(a0)
	bra.s   loc_2048C4
loc_204888:
	move.b  #$0, $2a(a0)
	move.w  #$91, d0
	jsr     PlayFMSound.l
	bra.w   loc_20495C
	bsr.w   ObjSonic_MoveGndLeft
	bra.w   loc_20495C
loc_2048A4:
	btst.b  #$0, playerCtrl.w
	beq.s   loc_2048C4
	move.b  #$7, oAnim(a0)
	cmpi.w  #$c8, camYCenter.w
	beq.w   loc_204980
	addq.w  #$2, camYCenter.w
	bra.w   loc_204980
loc_2048C4:
	btst.b  #$6, lookMode.w
	bne.w   loc_204940
	andi.b  #$f, lookMode.w
	beq.s   loc_2048E8
	btst.b  #$1, playerCtrlTap.w
	beq.s   loc_2048FA
	bset.b  #$6, lookMode.w
	bra.w   loc_204980
loc_2048E8:
	btst.b  #$1, playerCtrlTap.w
	beq.s   loc_2048FA
	move.b  #$1, lookMode.w
	bra.w   loc_204980
loc_2048FA:
	btst.b  #$1, playerCtrl.w
	beq.s   loc_20495C
	move.b  #$8, oAnim(a0)
	tst.b   $2a(a0)
	bne.s   loc_20493E
	move.b  playerCtrlTap.w, d0
	andi.b  #$70, d0
	beq.s   loc_20493E
	move.b  #$1, $2a(a0)
	move.w  #$16, $14(a0)
	btst.b  #$0, oFlags(a0)
	beq.s   loc_204930
	neg.w   $14(a0)
loc_204930:
	move.w  #$9c, d0
	jsr     PlayFMSound.l
	bsr.w   ObjSonic_StartRoll
loc_20493E:
	bra.s   loc_204980
loc_204940:
	btst.b  #$1, playerCtrl.w
	beq.s   loc_20495C
	move.b  #$8, oAnim(a0)
	cmpi.w  #$8, camYCenter.w
	beq.s   loc_204980
	subq.w  #$2, camYCenter.w
	bra.s   loc_204980
loc_20495C:
	cmpi.w  #$60, camYCenter.w
	bne.s   loc_204976
	move.b  lookMode.w, d0
	andi.b  #$f, d0
	bne.s   loc_204980
	move.b  #$0, lookMode.w
	bra.s   loc_204980
loc_204976:
	bcc.s   loc_20497C
	addq.w  #$4, camYCenter.w
loc_20497C:
	subq.w  #$2, camYCenter.w
loc_204980:
	move.b  playerCtrl.w, d0
	andi.b  #$c, d0
	bne.s   loc_2049AC
	move.w  $14(a0), d0
	beq.s   loc_2049AC
	bmi.s   loc_2049A0
	sub.w   d5, d0
	bcc.s   loc_20499A
	move.w  #$0, d0
loc_20499A:
	move.w  d0, $14(a0)
	bra.s   loc_2049AC
loc_2049A0:
	add.w   d5, d0
	bcc.s   loc_2049A8
	move.w  #$0, d0
loc_2049A8:
	move.w  d0, $14(a0)
loc_2049AC:
	move.b  oAngle(a0), d0
	jsr     CalcSine.l
	muls.w  $14(a0), d1
	asr.l   #$8, d1
	move.w  d1, oXVel(a0)
	muls.w  $14(a0), d0
	asr.l   #$8, d0
	move.w  d0, oYVel(a0)
ObjSonic_CheckWallCol:
	move.b  oAngle(a0), d0
	addi.b  #$40, d0
	bmi.s   loc_204A3A
	move.b  #$40, d1
	tst.w   $14(a0)
	beq.s   loc_204A3A
	bmi.s   loc_2049E2
	neg.w   d1
loc_2049E2:
	move.b  oAngle(a0), d0
	add.b   d1, d0
	move.w  d0, -(a7)
	bsr.w   Player_CalcRoomInFront
	move.w  (a7)+, d0
	tst.w   d1
	bpl.s   loc_204A3A
	asl.w   #$8, d1
	addi.b  #$20, d0
	andi.b  #$c0, d0
	beq.s   loc_204A36
	cmpi.b  #$40, d0
	beq.s   loc_204A24
	cmpi.b  #$80, d0
	beq.s   loc_204A1E
	add.w   d1, oXVel(a0)
	bset.b  #$5, oFlags(a0)
	move.w  #$0, $14(a0)
	rts     
loc_204A1E:
	sub.w   d1, oYVel(a0)
	rts     
loc_204A24:
	sub.w   d1, oXVel(a0)
	bset.b  #$5, oFlags(a0)
	move.w  #$0, $14(a0)
	rts     
loc_204A36:
	add.w   d1, oYVel(a0)
loc_204A3A:
	rts     
ObjSonic_MoveGndLeft:
	tst.b   $2a(a0)
	bne.s   loc_204AB0
	move.w  $14(a0), d0
	beq.s   loc_204A4A
	bpl.s   loc_204A7A
loc_204A4A:
	bset.b  #$0, oFlags(a0)
	bne.s   loc_204A5E
	bclr.b  #$5, oFlags(a0)
	move.b  #$1, oPrevAnim(a0)
loc_204A5E:
	move.w  d6, d1
	neg.w   d1
	cmp.w   d1, d0
	ble.s   loc_204A6E
	sub.w   d5, d0
	cmp.w   d1, d0
	bgt.s   loc_204A6E
	move.w  d1, d0
loc_204A6E:
	move.w  d0, $14(a0)
	move.b  #$0, oAnim(a0)
	rts     
loc_204A7A:
	sub.w   d4, d0
	bcc.s   loc_204A82
	move.w  #$ff80, d0
loc_204A82:
	move.w  d0, $14(a0)
	move.b  oAngle(a0), d0
	addi.b  #$20, d0
	andi.b  #$c0, d0
	bne.s   loc_204AB0
	cmpi.w  #$400, d0
	blt.s   loc_204AB0
	move.b  #$d, oAnim(a0)
	bclr.b  #$0, oFlags(a0)
	move.w  #$90, d0
	jsr     PlayFMSound.l
loc_204AB0:
	rts     
ObjSonic_MoveGndRight:
	tst.b   $2a(a0)
	bne.s   loc_204B20
	move.w  $14(a0), d0
	bmi.s   loc_204AEA
	bclr.b  #$0, oFlags(a0)
	beq.s   loc_204AD2
	bclr.b  #$5, oFlags(a0)
	move.b  #$1, oPrevAnim(a0)
loc_204AD2:
	cmp.w   d6, d0
	bge.s   loc_204ADE
	add.w   d5, d0
	cmp.w   d6, d0
	blt.s   loc_204ADE
	move.w  d6, d0
loc_204ADE:
	move.w  d0, $14(a0)
	move.b  #$0, oAnim(a0)
	rts     
loc_204AEA:
	add.w   d4, d0
	bcc.s   loc_204AF2
	move.w  #$80, d0
loc_204AF2:
	move.w  d0, $14(a0)
	move.b  oAngle(a0), d0
	addi.b  #$20, d0
	andi.b  #$c0, d0
	bne.s   loc_204B20
	cmpi.w  #$fc00, d0
	bgt.s   loc_204B20
	move.b  #$d, oAnim(a0)
	bset.b  #$0, oFlags(a0)
	move.w  #$90, d0
	jsr     PlayFMSound.l
loc_204B20:
	rts     
ObjSonic_MoveRoll:
	move.w  sonicTopSpeed.w, d6
	asl.w   #$1, d6
	move.w  sonicAcceleration.w, d5
	asr.w   #$1, d5
	move.w  sonicDeceleration.w, d4
	asr.w   #$2, d4
	tst.b   waterSlideFlag.w
	bne.w   loc_204C6C
	tst.w   $3e(a0)
	bne.s   loc_204B5A
	btst.b  #$2, playerCtrl.w
	beq.s   loc_204B4E
	bsr.w   ObjSonic_MoveRollLeft
loc_204B4E:
	btst.b  #$3, playerCtrl.w
	beq.s   loc_204B5A
	bsr.w   ObjSonic_MoveRollRight
loc_204B5A:
	tst.b   $2a(a0)
	beq.w   loc_204C04
	move.w  #$4b, d0
	move.w  sonicTopSpeed.w, d1
	move.w  d1, d2
	asl.w   #$1, d1
	tst.b   speedShoes.l
	beq.s   loc_204B7A
	asr.w   #$1, d2
	sub.w   d2, d1
loc_204B7A:
	btst.b  #$0, oFlags(a0)
	beq.s   loc_204B86
	neg.w   d0
	neg.w   d1
loc_204B86:
	add.w   d0, $14(a0)
	move.w  $14(a0), d0
	btst.b  #$0, oFlags(a0)
	beq.s   loc_204B9C
	cmp.w   d0, d1
	ble.s   loc_204BA2
	bra.s   loc_204BA0
loc_204B9C:
	cmp.w   d1, d0
	ble.s   loc_204BA2
loc_204BA0:
	move.w  d1, d0
loc_204BA2:
	move.w  d0, $14(a0)
	btst.b  #$1, playerCtrl.w
	beq.s   loc_204BD6
	rts     
loc_204BB0:
	move.w  #$ab, d0
	jsr     PlayFMSound.l
	move.b  #$0, $2a(a0)
	move.w  #$0, $14(a0)
	move.w  #$0, oXVel(a0)
	move.w  #$0, oYVel(a0)
	bra.w   loc_204C36
loc_204BD6:
	cmpi.b  #$2d, $2a(a0)
	bne.s   loc_204BB0
	move.b  #$0, $2a(a0)
	move.w  #$91, d0
	jsr     PlayFMSound.l
	btst.b  #$0, oFlags(a0)
	bne.s   loc_204BFC
	bsr.w   ObjSonic_MoveRollRight
	bra.s   loc_204C04
loc_204BFC:
	bsr.w   ObjSonic_MoveRollLeft
	bra.s   loc_204C04
	dc.w	$4E75
loc_204C04:
	move.w  $14(a0), d0
	beq.s   loc_204C26
	bmi.s   loc_204C1A
	sub.w   d5, d0
	bcc.s   loc_204C14
	move.w  #$0, d0
loc_204C14:
	move.w  d0, $14(a0)
	bra.s   loc_204C26
loc_204C1A:
	add.w   d5, d0
	bcc.s   loc_204C22
	move.w  #$0, d0
loc_204C22:
	move.w  d0, $14(a0)
loc_204C26:
	tst.w   $14(a0)
	bne.s   loc_204C6C
	move.w  #$ab, d0
	jsr     PlayFMSound.l
loc_204C36:
	bclr.b  #$2, oFlags(a0)
	tst.b   miniSonic.l
	beq.s   loc_204C56
	move.b  #$a, oYRadius(a0)
	move.b  #$5, oXRadius(a0)
	subq.w  #$2, oY(a0)
	bra.s   loc_204C66
loc_204C56:
	move.b  #$13, oYRadius(a0)
	move.b  #$9, oXRadius(a0)
	subq.w  #$5, oY(a0)
loc_204C66:
	move.b  #$5, oAnim(a0)
loc_204C6C:
	move.b  oAngle(a0), d0
	jsr     CalcSine.l
	muls.w  $14(a0), d0
	asr.l   #$8, d0
	move.w  d0, oYVel(a0)
	muls.w  $14(a0), d1
	asr.l   #$8, d1
	cmpi.w  #$1000, d1
	ble.s   loc_204C90
	move.w  #$1000, d1
loc_204C90:
	cmpi.w  #$f000, d1
	bge.s   loc_204C9A
	move.w  #$f000, d1
loc_204C9A:
	move.w  d1, oXVel(a0)
	bra.w   ObjSonic_CheckWallCol
ObjSonic_MoveRollLeft:
	move.w  $14(a0), d0
	beq.s   loc_204CAA
	bpl.s   loc_204CB8
loc_204CAA:
	bset.b  #$0, oFlags(a0)
	move.b  #$2, oAnim(a0)
	rts     
loc_204CB8:
	sub.w   d4, d0
	bcc.s   loc_204CC0
	move.w  #$ff80, d0
loc_204CC0:
	move.w  d0, $14(a0)
	rts     
ObjSonic_MoveRollRight:
	move.w  $14(a0), d0
	bmi.s   loc_204CDA
	bclr.b  #$0, oFlags(a0)
	move.b  #$2, oAnim(a0)
	rts     
loc_204CDA:
	add.w   d4, d0
	bcc.s   loc_204CE2
	move.w  #$80, d0
loc_204CE2:
	move.w  d0, $14(a0)
	rts     
ObjSonic_MoveAir:
	move.w  sonicTopSpeed.w, d6
	move.w  sonicAcceleration.w, d5
	asl.w   #$1, d5
	move.w  oXVel(a0), d0
	cmpi.b  #$1, timeZone.l
	bne.s   loc_204D22
	tst.w   zoneAct.l
	bne.s   loc_204D22
	cmpi.w  #$6c8, oX(a0)
	bcs.s   loc_204D1A
	cmpi.w  #$840, oX(a0)
	bcc.s   loc_204D1A
	rts     
loc_204D1A:
	btst.b  #$1, $2c(a0)
	bne.s   loc_204D52
loc_204D22:
	btst.b  #$2, playerCtrl.w
	beq.s   loc_204D3C
	bset.b  #$0, oFlags(a0)
	sub.w   d5, d0
	move.w  d6, d1
	neg.w   d1
	cmp.w   d1, d0
	bgt.s   loc_204D3C
	move.w  d1, d0
loc_204D3C:
	btst.b  #$3, playerCtrl.w
	beq.s   loc_204D52
	bclr.b  #$0, oFlags(a0)
	add.w   d5, d0
	cmp.w   d6, d0
	blt.s   loc_204D52
	move.w  d6, d0
loc_204D52:
	move.w  d0, oXVel(a0)
	cmpi.w  #$60, camYCenter.w
	beq.s   loc_204D68
	bcc.s   loc_204D64
	addq.w  #$4, camYCenter.w
loc_204D64:
	subq.w  #$2, camYCenter.w
loc_204D68:
	cmpi.w  #$fc00, oYVel(a0)
	bcs.s   loc_204D96
	move.w  oXVel(a0), d0
	move.w  d0, d1
	asr.w   #$5, d1
	beq.s   loc_204D96
	bmi.s   loc_204D8A
	sub.w   d1, d0
	bcc.s   loc_204D84
	move.w  #$0, d0
loc_204D84:
	move.w  d0, oXVel(a0)
	rts     
loc_204D8A:
	sub.w   d1, d0
	bcs.s   loc_204D92
	move.w  #$0, d0
loc_204D92:
	move.w  d0, oXVel(a0)
loc_204D96:
	rts     
	move.b  oAngle(a0), d0
	addi.b  #$20, d0
	andi.b  #$c0, d0
	bne.s   loc_204DC6
	bsr.w   Player_CheckCeiling
	tst.w   d1
	bpl.s   loc_204DC6
	move.w  #$0, $14(a0)
	move.w  #$0, oXVel(a0)
	move.w  #$0, oYVel(a0)
	move.b  #$b, oAnim(a0)
loc_204DC6:
	rts     
ObjSonic_LevelBound:
	move.l  oX(a0), d1
	move.w  oXVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, d1
	swap    d1
	move.w  leftBound.w, d0
	addi.w  #$10, d0
	cmp.w   d1, d0
	bhi.s   loc_204E1C
	move.w  rightBound.w, d0
	addi.w  #$130, d0
	tst.b   bossFight.w
	bne.s   loc_204DF6
	addi.w  #$38, d0
loc_204DF6:
	cmp.w   d1, d0
	bls.s   loc_204E1C
loc_204DFA:
	move.w  bottomBound.w, d0
	addi.w  #$e0, d0
	cmp.w   oY(a0), d0
	blt.s   loc_204E0A
	rts     
loc_204E0A:
	cmpi.b  #$2b, oAnim(a0)
	bne.w   KillPlayer
	move.b  #$6, oRoutine(a0)
	rts     
loc_204E1C:
	move.w  d0, oX(a0)
	move.w  #$0, oYScr(a0)
	move.w  #$0, oXVel(a0)
	move.w  #$0, $14(a0)
	bra.s   loc_204DFA
ObjSonic_CheckRoll:
	tst.b   waterSlideFlag.w
	bne.s   loc_204E5A
	move.w  $14(a0), d0
	bpl.s   loc_204E42
	neg.w   d0
loc_204E42:
	cmpi.w  #$80, d0
	bcs.s   loc_204E5A
	move.b  playerCtrl.w, d0
	andi.b  #$c, d0
	bne.s   loc_204E5A
	btst.b  #$1, playerCtrl.w
	bne.s   ObjSonic_StartRoll
loc_204E5A:
	rts     
ObjSonic_StartRoll:
	btst.b  #$2, oFlags(a0)
	beq.s   loc_204E66
	bra.s   loc_204E96
loc_204E66:
	bset.b  #$2, oFlags(a0)
	tst.b   miniSonic.l
	beq.s   loc_204E86
	move.b  #$8, oYRadius(a0)
	move.b  #$5, oXRadius(a0)
	addq.w  #$2, oY(a0)
	bra.s   loc_204E96
loc_204E86:
	move.b  #$e, oYRadius(a0)
	move.b  #$7, oXRadius(a0)
	addq.w  #$5, oY(a0)
loc_204E96:
	move.b  #$2, oAnim(a0)
	tst.w   $14(a0)
	bmi.s   loc_204EB0
	cmpi.w  #$200, $14(a0)
	bcc.s   loc_204EB0
	move.w  #$200, $14(a0)
loc_204EB0:
	rts     
ObjSonic_CheckJump:
	tst.b   $2a(a0)
	beq.s   loc_204EBA
	rts     
loc_204EBA:
	move.b  playerCtrl.w, d0
	andi.b  #$3, d0
	beq.s   loc_204ECC
	tst.w   $14(a0)
	beq.w   loc_204F92
loc_204ECC:
	move.b  playerCtrlTap.w, d0
	andi.b  #$70, d0
	beq.w   loc_204F92
	btst.b  #$3, oFlags(a0)
	beq.s   loc_204EE8
	jsr     ObjSonic_ChkFlipper.l
	beq.s   loc_204F18
loc_204EE8:
	moveq   #$0, d0
	move.b  oAngle(a0), d0
	addi.b  #$80, d0
	bsr.w   Player_CalcRoomOverHead
	cmpi.w  #$6, d1
	blt.w   loc_204F92
	move.w  #$680, d2
	btst.b  #$6, oFlags(a0)
	beq.s   loc_204F0E
	move.w  #$380, d2
loc_204F0E:
	moveq   #$0, d0
	move.b  oAngle(a0), d0
	subi.b  #$40, d0
loc_204F18:
	jsr     CalcSine.l
	muls.w  d2, d1
	asr.l   #$8, d1
	add.w   d1, oXVel(a0)
	muls.w  d2, d0
	asr.l   #$8, d0
	add.w   d0, oYVel(a0)
	bset.b  #$1, oFlags(a0)
	bclr.b  #$5, oFlags(a0)
	addq.l  #$4, a7
	move.b  #$1, $3c(a0)
	clr.b   $38(a0)
	clr.b   lookMode.w
	move.w  #$92, d0
	jsr     PlayFMSound.l
	btst.b  #$2, oFlags(a0)
	bne.s   loc_204F94
	tst.b   miniSonic.l
	beq.s   loc_204F76
	move.b  #$8, oYRadius(a0)
	move.b  #$5, oXRadius(a0)
	addq.w  #$2, oY(a0)
	bra.s   loc_204F86
loc_204F76:
	move.b  #$e, oYRadius(a0)
	move.b  #$7, oXRadius(a0)
	addq.w  #$5, oY(a0)
loc_204F86:
	bset.b  #$2, oFlags(a0)
	move.b  #$2, oAnim(a0)
loc_204F92:
	rts     
loc_204F94:
	bset.b  #$4, oFlags(a0)
	rts     
ObjSonic_JumpHeight:
	tst.b   $3c(a0)
	beq.s   loc_204FCE
	move.w  #$fc00, d1
	btst.b  #$6, oFlags(a0)
	beq.s   loc_204FB2
	move.w  #$fe00, d1
loc_204FB2:
	cmp.w   oYVel(a0), d1
	ble.s   loc_204FCC
	move.b  playerCtrl.w, d0
	andi.b  #$70, d0
	bne.s   loc_204FCC
	move.b  #$0, $2a(a0)
	move.w  d1, oYVel(a0)
loc_204FCC:
	rts     
loc_204FCE:
	cmpi.w  #$f040, oYVel(a0)
	bge.s   loc_204FDC
	move.w  #$f040, oYVel(a0)
loc_204FDC:
	rts     
ObjSonic_SlopeResist:
	tst.b   $2a(a0)
	bne.s   loc_205018
	move.b  oAngle(a0), d0
	addi.b  #$60, d0
	cmpi.b  #$c0, d0
	bcc.s   loc_205018
	move.b  oAngle(a0), d0
	jsr     CalcSine.l
	muls.w  #$20, d0
	asr.l   #$8, d0
	tst.w   $14(a0)
	beq.s   loc_205018
	bmi.s   loc_205014
	tst.w   d0
	beq.s   loc_205012
	add.w   d0, $14(a0)
loc_205012:
	rts     
loc_205014:
	add.w   d0, $14(a0)
loc_205018:
	rts     
ObjSonic_SlopeResistRoll:
	tst.b   $2a(a0)
	bne.s   loc_20505A
	move.b  oAngle(a0), d0
	addi.b  #$60, d0
	cmpi.b  #$c0, d0
	bcc.s   loc_20505A
	move.b  oAngle(a0), d0
	jsr     CalcSine.l
	muls.w  #$50, d0
	asr.l   #$8, d0
	tst.w   $14(a0)
	bmi.s   loc_205050
	tst.w   d0
	bpl.s   loc_20504A
	asr.l   #$2, d0
loc_20504A:
	add.w   d0, $14(a0)
	rts     
loc_205050:
	tst.w   d0
	bmi.s   loc_205056
	asr.l   #$2, d0
loc_205056:
	add.w   d0, $14(a0)
loc_20505A:
	rts     
ObjSonic_CheckFallOff:
	nop     
	tst.b   $38(a0)
	bne.s   loc_20509E
	tst.w   $3e(a0)
	bne.s   loc_2050A0
	move.b  oAngle(a0), d0
	addi.b  #$20, d0
	andi.b  #$c0, d0
	beq.s   loc_20509E
	move.w  $14(a0), d0
	bpl.s   loc_205080
	neg.w   d0
loc_205080:
	cmpi.w  #$280, d0
	bcc.s   loc_20509E
	clr.w   $14(a0)
	nop     
	nop     
	nop     
	nop     
	bset.b  #$1, oFlags(a0)
	move.w  #$1e, $3e(a0)
loc_20509E:
	rts     
loc_2050A0:
	subq.w  #$1, $3e(a0)
	rts     
ObjSonic_JumpAngle:
	btst.b  #$1, $2c(a0)
	bne.s   loc_2050C8
	move.b  oAngle(a0), d0
	beq.s   loc_2050C8
	bpl.s   loc_2050BE
	addq.b  #$2, d0
	bcc.s   loc_2050BC
	moveq   #$0, d0
loc_2050BC:
	bra.s   loc_2050C4
loc_2050BE:
	subq.b  #$2, d0
	bcc.s   loc_2050C4
	moveq   #$0, d0
loc_2050C4:
	move.b  d0, oAngle(a0)
loc_2050C8:
	rts     
Player_LevelColInAir:
	move.w  oXVel(a0), d1
	move.w  oYVel(a0), d2
	jsr     CalcAngle.l
	move.b  d0, debugAngle.l
	subi.b  #$20, d0
	move.b  d0, debugAngleShift.l
	andi.b  #$c0, d0
	move.b  d0, debugQuadrant.l
	cmpi.b  #$40, d0
	beq.w   Player_LvlColAir_Left
	cmpi.b  #$80, d0
	beq.w   Player_LvlColAir_Up
	cmpi.b  #$c0, d0
	beq.w   Player_LvlColAir_Right
	bsr.w   Player_GetLWallDist
	tst.w   d1
	bpl.s   loc_20511C
	sub.w   d1, oX(a0)
	move.w  #$0, oXVel(a0)
loc_20511C:
	bsr.w   Player_GetRWallDist
	tst.w   d1
	bpl.s   loc_20512E
	add.w   d1, oX(a0)
	move.w  #$0, oXVel(a0)
loc_20512E:
	bsr.w   sub_206E36
	move.b  d1, debugFloorDist.l
	tst.w   d1
	bpl.s   loc_2051AC
	move.b  oYVel(a0), d2
	addq.b  #$8, d2
	neg.b   d2
	cmp.b   d2, d1
	bge.s   loc_20514C
	cmp.b   d2, d0
	blt.s   loc_2051AC
loc_20514C:
	add.w   d1, oY(a0)
	move.b  d3, oAngle(a0)
	bsr.w   Player_ResetOnFloor
	move.b  #$0, oAnim(a0)
	move.b  d3, d0
	addi.b  #$20, d0
	andi.b  #$40, d0
	bne.s   loc_20518A
	move.b  d3, d0
	addi.b  #$10, d0
	andi.b  #$20, d0
	beq.s   loc_20517C
	asr.w   oYVel(a0)
	bra.s   loc_20519E
loc_20517C:
	move.w  #$0, oYVel(a0)
	move.w  oXVel(a0), $14(a0)
	rts     
loc_20518A:
	move.w  #$0, oXVel(a0)
	cmpi.w  #$fc0, oYVel(a0)
	ble.s   loc_20519E
	move.w  #$fc0, oYVel(a0)
loc_20519E:
	move.w  oYVel(a0), $14(a0)
	tst.b   d3
	bpl.s   loc_2051AC
	neg.w   $14(a0)
loc_2051AC:
	rts     
Player_LvlColAir_Left:
	bsr.w   Player_GetLWallDist
	tst.w   d1
	bpl.s   loc_2051C8
	sub.w   d1, oX(a0)
	move.w  #$0, oXVel(a0)
	move.w  oYVel(a0), $14(a0)
	rts     
loc_2051C8:
	bsr.w   Player_CheckCeiling
	tst.w   d1
	bpl.s   loc_2051E2
	sub.w   d1, oY(a0)
	tst.w   oYVel(a0)
	bpl.s   loc_2051E0
	move.w  #$0, oYVel(a0)
loc_2051E0:
	rts     
loc_2051E2:
	tst.w   oYVel(a0)
	bmi.s   loc_20520E
	bsr.w   sub_206E36
	tst.w   d1
	bpl.s   loc_20520E
	add.w   d1, oY(a0)
	move.b  d3, oAngle(a0)
	bsr.w   Player_ResetOnFloor
	move.b  #$0, oAnim(a0)
	move.w  #$0, oYVel(a0)
	move.w  oXVel(a0), $14(a0)
loc_20520E:
	rts     
Player_LvlColAir_Up:
	bsr.w   Player_GetLWallDist
	tst.w   d1
	bpl.s   loc_205222
	sub.w   d1, oX(a0)
	move.w  #$0, oXVel(a0)
loc_205222:
	bsr.w   Player_GetRWallDist
	tst.w   d1
	bpl.s   loc_205234
	add.w   d1, oX(a0)
	move.w  #$0, oXVel(a0)
loc_205234:
	bsr.w   Player_CheckCeiling
	tst.w   d1
	bpl.s   loc_20526A
	sub.w   d1, oY(a0)
	move.b  d3, d0
	addi.b  #$20, d0
	andi.b  #$40, d0
	bne.s   loc_205254
	move.w  #$0, oYVel(a0)
	rts     
loc_205254:
	move.b  d3, oAngle(a0)
	bsr.w   Player_ResetOnSteepSlope
	move.w  oYVel(a0), $14(a0)
	tst.b   d3
	bpl.s   loc_20526A
	neg.w   $14(a0)
loc_20526A:
	rts     
Player_LvlColAir_Right:
	bsr.w   Player_GetRWallDist
	tst.w   d1
	bpl.s   loc_205286
	add.w   d1, oX(a0)
	move.w  #$0, oXVel(a0)
	move.w  oYVel(a0), $14(a0)
	rts     
loc_205286:
	bsr.w   Player_CheckCeiling
	tst.w   d1
	bpl.s   loc_2052A0
	sub.w   d1, oY(a0)
	tst.w   oYVel(a0)
	bpl.s   loc_20529E
	move.w  #$0, oYVel(a0)
loc_20529E:
	rts     
loc_2052A0:
	tst.w   oYVel(a0)
	bmi.s   loc_2052CC
	bsr.w   sub_206E36
	tst.w   d1
	bpl.s   loc_2052CC
	add.w   d1, oY(a0)
	move.b  d3, oAngle(a0)
	bsr.w   Player_ResetOnFloor
	move.b  #$0, oAnim(a0)
	move.w  #$0, oYVel(a0)
	move.w  oXVel(a0), $14(a0)
loc_2052CC:
	rts     
Player_ResetOnFloor:
	btst.b  #$4, oFlags(a0)
	beq.s   loc_2052D8
	nop     
loc_2052D8:
	bclr.b  #$5, oFlags(a0)
	bclr.b  #$1, oFlags(a0)
	bclr.b  #$4, oFlags(a0)
	btst.b  #$2, oFlags(a0)
	beq.s   loc_205332
	bclr.b  #$2, oFlags(a0)
	tst.b   miniSonic.l
	beq.s   loc_205312
	move.b  #$a, oYRadius(a0)
	move.b  #$5, oXRadius(a0)
	subq.w  #$2, oY(a0)
	bra.s   loc_205322
loc_205312:
	move.b  #$13, oYRadius(a0)
	move.b  #$9, oXRadius(a0)
	subq.w  #$5, oY(a0)
loc_205322:
	move.b  #$0, oAnim(a0)
	move.w  #$ab, d0
	jsr     PlayFMSound.l
loc_205332:
	move.b  #$0, $3c(a0)
	move.w  #$0, scoreChain.w
	rts     
Player_ResetOnSteepSlope:
	bclr.b  #$5, oFlags(a0)
	bclr.b  #$1, oFlags(a0)
	bclr.b  #$4, oFlags(a0)
	move.b  #$0, $3c(a0)
	move.w  #$0, scoreChain.w
	rts     
	jsr     ObjMove.l
	addi.w  #$30, oYVel(a0)
	btst.b  #$6, oFlags(a0)
	beq.s   loc_20537A
	subi.w  #$20, oYVel(a0)
loc_20537A:
	jsr     ObjSonic_SpecialCol.l
	bsr.w   ObjSonic_HurtChkLand
	bsr.w   ObjSonic_LevelBound
	bsr.w   ObjSonic_RecordPos
	bsr.w   ObjSonic_Animate
	jmp     DrawObject.l
ObjSonic_HurtChkLand:
	move.w  bottomBound.w, d0
	addi.w  #$e0, d0
	cmp.w   oY(a0), d0
	bcs.w   KillPlayer
	bsr.w   Player_LevelColInAir
	btst.b  #$1, oFlags(a0)
	bne.s   loc_2053D0
	moveq   #$0, d0
	move.w  d0, oYVel(a0)
	move.w  d0, oXVel(a0)
	move.w  d0, $14(a0)
	move.b  #$0, oAnim(a0)
	subq.b  #$2, oRoutine(a0)
	move.w  #$78, $30(a0)
loc_2053D0:
	rts     
	bsr.w   ObjSonic_DeadChkGone
	jsr     ObjMoveGrv.l
	bsr.w   ObjSonic_RecordPos
	bsr.w   ObjSonic_Animate
	jmp     DrawObject.l
ObjSonic_DeadChkGone:
	move.w  bottomBound.w, d0
	addi.w  #$100, d0
	cmp.w   oY(a0), d0
	bcc.w   loc_205458
	move.w  #$ffc8, oYVel(a0)
	addq.b  #$2, oRoutine(a0)
	clr.b   updateHUDTime.l
	addq.b  #$1, updateHUDLives.l
	subq.b  #$1, lives.l
	bpl.s   loc_20541E
	clr.b   lives.l
loc_20541E:
	cmpi.b  #$2b, oAnim(a0)
	beq.s   loc_205438
	tst.b   timeAttackMode.l
	beq.s   loc_205438
	move.b  #$0, lives.l
	bra.s   loc_205452
loc_205438:
	jsr     FindObjSlot.l
	dc.b	$13,$7C,$00,$3B,$00,$00		; move.b #$3b, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  #$1e0, $3a(a0)
	tst.b   lives.l
	beq.s   loc_205458
loc_205452:
	move.w  #$3c, $3a(a0)
loc_205458:
	rts     
	tst.w   $3a(a0)
	beq.w   loc_2054DC
	subq.w  #$1, $3a(a0)
	bne.w   loc_2054DC
	move.w  #$1, levelRestart.l
	jsr     StopZ80.l
	move.b  #$1, $a01c3e.l
	jsr     StartZ80.l
	bsr.w   ResetSavedObjFlags
	clr.l   flowerCount.l
	tst.b   checkpoint.l
	bne.s   loc_2054AA
	cmpi.b  #$1, timeZone.l
	bne.s   loc_2054AA
	bclr.b  #$1, plcLoadFlags.l
loc_2054AA:
	move.w  #$e, d0
	tst.b   lives.l
	beq.s   loc_2054D8
	cmpi.b  #$1, timeZone.l
	bne.s   loc_2054D2
	tst.b   checkpoint.l
	beq.s   loc_2054D8
	move.b  #$1, spawnMode.l
	bra.s   loc_2054D8
loc_2054D2:
	clr.b   spawnMode.l
loc_2054D8:
	bra.w   SubCPUCmd
loc_2054DC:
	rts     
	cmpi.b  #$3, zoneAct.l
	beq.s   loc_205506
	cmpi.b  #$5, zoneAct.l
	beq.s   loc_205506
	cmpi.b  #$2, zoneAct.l
	beq.s   loc_205506
	tst.b   zoneAct.l
	bne.w   loc_2055C8
loc_205506:
	move.w  oY(a0), d0
	lsr.w   #$1, d0
	andi.w  #$380, d0
	move.b  oX(a0), d1
	andi.w  #$7f, d1
	add.w   d1, d0
	lea     levelLayout.w, a1
	move.b  (a1, d0.w), d1
	cmp.b   $FFFFF7AE.w, d1
	bne.s   loc_205544
	tst.b   zoneAct.l
	bne.w   loc_2055CA
	move.w  oY(a0), d0
	andi.w  #$ff, d0
	cmpi.w  #$90, d0
	bcc.w   loc_2055CA
	bra.s   loc_20554C
loc_205544:
	cmp.b   $FFFFF7AF.w, d1
	beq.w   loc_2055CA
loc_20554C:
	cmp.b   specialChunks.w, d1
	beq.s   loc_20557C
	cmp.b   $FFFFF7AD.w, d1
	beq.s   loc_205560
	bclr.b  #$6, oSprFlags(a0)
	rts     
loc_205560:
	cmpi.b  #$5, zoneAct.l
	beq.w   loc_2055E2
	btst.b  #$1, oFlags(a0)
	beq.s   loc_20557C
	bclr.b  #$6, oSprFlags(a0)
	rts     
loc_20557C:
	move.w  oX(a0), d2
	cmpi.b  #$2c, d2
	bcc.s   loc_20558E
	bclr.b  #$6, oSprFlags(a0)
	rts     
loc_20558E:
	cmpi.b  #$e0, d2
	bcs.s   loc_20559C
	bset.b  #$6, oSprFlags(a0)
	rts     
loc_20559C:
	btst.b  #$6, oSprFlags(a0)
	bne.s   loc_2055B8
	move.b  oAngle(a0), d1
	beq.s   loc_2055C8
	cmpi.b  #$80, d1
	bhi.s   loc_2055C8
	bset.b  #$6, oSprFlags(a0)
	rts     
loc_2055B8:
	move.b  oAngle(a0), d1
	cmpi.b  #$80, d1
	bls.s   loc_2055C8
	bclr.b  #$6, oSprFlags(a0)
loc_2055C8:
	rts     
loc_2055CA:
	btst.b  #$2, oFlags(a0)
	bne.s   loc_2055DC
	move.w  #$9c, d0
	jsr     PlayFMSound.l
loc_2055DC:
	jmp     ObjSonic_StartRoll.l
loc_2055E2:
	tst.w   oYVel(a0)
	bmi.s   loc_205626
	move.w  oY(a0), d1
	andi.w  #$ff, d1
	move.w  oX(a0), d0
	andi.w  #$ff, d0
	cmpi.w  #$80, d0
	bcc.s   loc_20561A
	cmpi.w  #$38, d1
	bcs.s   loc_205612
	cmpi.w  #$80, d1
	bcs.s   loc_205626
loc_20560A:
	bclr.b  #$6, oSprFlags(a0)
	rts     
loc_205612:
	bset.b  #$6, oSprFlags(a0)
	rts     
loc_20561A:
	cmpi.w  #$38, d1
	bcs.s   loc_20560A
	cmpi.w  #$80, d1
	bcc.s   loc_205612
loc_205626:
	rts     
ObjSonic_Animate:
	lea     Ani_Sonic.l, a1
	moveq   #$0, d0
	move.b  oAnim(a0), d0
	cmp.b   oPrevAnim(a0), d0
	beq.s   loc_20564A
	move.b  d0, oPrevAnim(a0)
	move.b  #$0, oAnimFrame(a0)
	move.b  #$0, oAnimTime(a0)
loc_20564A:
	bsr.w   ObjSonic_GetMiniAnim
	add.w   d0, d0
	adda.w  (a1, d0.w), a1
	move.b  (a1), d0
	bmi.s   loc_2056C2
	move.b  oFlags(a0), d1
	andi.b  #$1, d1
	andi.b  #$fc, oSprFlags(a0)
	or.b    d1, oSprFlags(a0)
	subq.b  #$1, oAnimTime(a0)
	bpl.s   loc_205690
	move.b  d0, oAnimTime(a0)
sub_205674:
	moveq   #$0, d1
	move.b  oAnimFrame(a0), d1
	move.b  $1(a1, d1.w), d0
	beq.s   loc_205688
	bpl.s   loc_205688
	cmpi.b  #$fd, d0
	bge.s   loc_205692
loc_205688:
	move.b  d0, oMapFrame(a0)
	addq.b  #$1, oAnimFrame(a0)
loc_205690:
	rts     
loc_205692:
	addq.b  #$1, d0
	bne.s   loc_2056A2
	move.b  #$0, oAnimFrame(a0)
	move.b  $1(a1), d0
	bra.s   loc_205688
loc_2056A2:
	addq.b  #$1, d0
	bne.s   loc_2056B6
	move.b  $2(a1, d1.w), d0
	sub.b   d0, oAnimFrame(a0)
	sub.b   d0, d1
	move.b  $1(a1, d1.w), d0
	bra.s   loc_205688
loc_2056B6:
	addq.b  #$1, d0
	bne.s   loc_2056C0
	move.b  $2(a1, d1.w), oAnim(a0)
loc_2056C0:
	rts     
loc_2056C2:
	subq.b  #$1, oAnimTime(a0)
	bpl.s   loc_205690
	addq.b  #$1, d0
	bne.w   loc_20577C
	tst.b   miniSonic.l
	bne.w   loc_205844
	moveq   #$0, d1
	move.b  oAngle(a0), d0
	move.b  oFlags(a0), d2
	andi.b  #$1, d2
	bne.s   loc_2056EA
	not.b   d0
loc_2056EA:
	btst.b  #$1, $2c(a0)
	bne.s   loc_2056F8
	addi.b  #$10, d0
	bra.s   loc_2056FA
loc_2056F8:
	addq.b  #$8, d0
loc_2056FA:
	bpl.s   loc_2056FE
	moveq   #$3, d1
loc_2056FE:
	andi.b  #$fc, oSprFlags(a0)
	eor.b   d1, d2
	or.b    d2, oSprFlags(a0)
	btst.b  #$5, oFlags(a0)
	bne.w   loc_2057F0
	move.w  $14(a0), d2
	bpl.s   loc_20571C
	neg.w   d2
loc_20571C:
	btst.b  #$1, $2c(a0)
	beq.s   loc_205734
	lsr.b   #$4, d0
	lsl.b   #$1, d0
	andi.b  #$e, d0
	lea     SonAni_Run3D.l, a1
	bra.s   loc_20575E
loc_205734:
	lsr.b   #$4, d0
	andi.b  #$6, d0
	lea     SonAni_Peelout.l, a1
	cmpi.w  #$a00, d2
	bcc.s   loc_20575E
	lea     SonAni_Run.l, a1
	cmpi.w  #$600, d2
	bcc.s   loc_20575E
	lea     SonAni_Walk.l, a1
	move.b  d0, d1
	lsr.b   #$1, d1
	add.b   d1, d0
loc_20575E:
	add.b   d0, d0
	move.b  d0, d3
	neg.w   d2
	addi.w  #$800, d2
	bpl.s   loc_20576C
	moveq   #$0, d2
loc_20576C:
	lsr.w   #$8, d2
	move.b  d2, oAnimTime(a0)
	bsr.w   sub_205674
	add.b   d3, oMapFrame(a0)
	rts     
loc_20577C:
	addq.b  #$1, d0
	bne.s   loc_2057EC
	move.w  $14(a0), d2
	bpl.s   loc_205788
	neg.w   d2
loc_205788:
	lea     SonAni_RollMini.l, a1
	tst.b   miniSonic.l
	bne.s   loc_2057C6
	lea     SonAni_RollFast.l, a1
	btst.b  #$1, $2c(a0)
	beq.s   loc_2057BA
	move.b  oAngle(a0), d0
	addi.b  #$10, d0
	andi.b  #$c0, d0
	beq.s   loc_2057C6
	lea     SonAni_Roll3D.l, a1
	bra.s   loc_2057C6
loc_2057BA:
	cmpi.w  #$600, d2
	bcc.s   loc_2057C6
	lea     SonAni_Roll.l, a1
loc_2057C6:
	neg.w   d2
	addi.w  #$400, d2
	bpl.s   loc_2057D0
	moveq   #$0, d2
loc_2057D0:
	lsr.w   #$8, d2
	move.b  d2, oAnimTime(a0)
	move.b  oFlags(a0), d1
	andi.b  #$1, d1
	andi.b  #$fc, oSprFlags(a0)
	or.b    d1, oSprFlags(a0)
	bra.w   sub_205674
loc_2057EC:
	addq.b  #$1, d0
	bne.s   loc_205830
loc_2057F0:
	move.w  $14(a0), d2
	bmi.s   loc_2057F8
	neg.w   d2
loc_2057F8:
	addi.w  #$800, d2
	bpl.s   loc_205800
	moveq   #$0, d2
loc_205800:
	lsr.w   #$6, d2
	move.b  d2, oAnimTime(a0)
	lea     SonAni_PushMini.l, a1
	tst.b   miniSonic.l
	bne.s   loc_20581A
	lea     SonAni_Push.l, a1
loc_20581A:
	move.b  oFlags(a0), d1
	andi.b  #$1, d1
	andi.b  #$fc, oSprFlags(a0)
	or.b    d1, oSprFlags(a0)
	bra.w   sub_205674
loc_205830:
	moveq   #$0, d1
	move.b  oAnimFrame(a0), d1
	move.b  $1(a1, d1.w), oMapFrame(a0)
	move.b  #$0, oAnimTime(a0)
	rts     
loc_205844:
	moveq   #$0, d1
	move.b  oAngle(a0), d0
	move.b  oFlags(a0), d2
	andi.b  #$1, d2
	bne.s   loc_205856
	not.b   d0
loc_205856:
	addi.b  #$10, d0
	bpl.s   loc_20585E
	moveq   #$0, d1
loc_20585E:
	andi.b  #$fc, oSprFlags(a0)
	or.b    d2, oSprFlags(a0)
	addi.b  #$30, d0
	cmpi.b  #$60, d0
	bcs.s   loc_20588C
	bset.b  #$2, oFlags(a0)
	move.b  #$a, oYRadius(a0)
	move.b  #$5, oXRadius(a0)
	move.b  #$ff, d0
	bra.w   loc_20577C
loc_20588C:
	move.w  $14(a0), d2
	bpl.s   loc_205894
	neg.w   d2
loc_205894:
	lea     SonAni_RunMini.l, a1
	cmpi.w  #$600, d2
	bcc.s   loc_2058A6
	lea     SonAni_WalkMini.l, a1
loc_2058A6:
	neg.w   d2
	addi.w  #$800, d2
	bpl.s   loc_2058B0
	moveq   #$0, d2
loc_2058B0:
	lsr.w   #$8, d2
	move.b  d2, oAnimTime(a0)
	bra.w   sub_205674
ObjSonic_GetMiniAnim:
	tst.b   miniSonic.l
	beq.s   loc_2058C6
	move.b  dat_2058C8(pc, d0.w), d0
loc_2058C6:
	rts     
dat_2058C8:
	dc.w	$2118,$2323,$271F,$2628,$2009,$0A0B,$0C24,$0E0F
	dc.w	$2811,$1213,$1415,$1617,$1819,$2525,$1C1D,$1E1F
	dc.w	$2021,$2223,$2425,$2627,$2829,$2A30,$2C2D,$2E2F
	dc.w	$0000,$0000,$0000,$0000,$3900,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
Ani_Sonic:
	dc.w	$0078,$0080,$0088,$0090,$0098,$00A0,$00B6,$00BC
	dc.w	$00C0,$00C4,$00C8,$00CC,$00D0,$00D4,$00DA,$00DE
	dc.w	$00E6,$00EE,$00F2,$00F8,$00FE,$0102,$010A,$010E
	dc.w	$0112,$0116,$0120,$0124,$0128,$012C,$0134,$0138
	dc.w	$014E,$0152,$0158,$015E,$0164,$0168,$016C,$0170
	dc.w	$0178,$017C,$0180,$0190,$01B8,$01BE,$01C6,$01CE
	dc.w	$01D4,$01DC,$01E4,$01EA,$01F6,$0202,$020A,$0212
	dc.w	$0216,$022C,$020A,$0212
SonAni_Walk:
	dc.w	$FF35,$3637,$3833,$34FF
SonAni_Run:
	dc.w	$FF4B,$4C4D,$4EFF,$FFFF
SonAni_Roll:
	dc.w	$FE2D,$2E2F,$3031,$FFFF
SonAni_RollFast:
	dc.w	$FE2D,$2E31,$2F30,$31FF
SonAni_Push:
	dc.w	$FD64,$6566,$67FF,$FFFF,$1701,$0101,$0101,$0101
	dc.w	$0101,$0101,$0103,$0202,$0203,$04FE,$0200,$0F6D
	dc.w	$6E83,$84FF,$3F05,$FF00,$3F60,$FF00,$3F33,$FF00
	dc.w	$3F34,$FF00,$3F35,$FF00,$3F36,$FF00,$075B,$5C7F
	dc.w	$FF00,$073C,$3FFF,$0761,$62B9,$63BA,$FF00,$0332
	dc.w	$9091,$9293,$FF00,$046B,$6CFF,$0F43,$4343,$FE01
	dc.w	$0F43,$44FE,$0100,$3F49,$FF00,$0B5F,$5F37,$38FD
	dc.w	$0000,$2068,$FF00,$2F69,$FF00,$036A,$FF00,$034E
	dc.w	$4F50,$5152,$00FE,$0100,$035D,$FF00,$075D,$5EFF
	dc.w	$7700,$FD00,$033C,$3D53,$3E54,$FF00,$033C,$FD00
	dc.w	$176F,$6F6F,$6F6F,$6F6F,$6F6F,$6F6F,$6F70,$7070
	dc.w	$7170,$71FE,$0200,$3F72,$FF00
SonAni_WalkMini:
	dc.w	$FF73,$7475,$74FF
SonAni_RunMini:
	dc.w	$FF76,$77FF,$FFFF
SonAni_RollMini:
	dc.w	$FE7C,$7D7E,$FFFF,$0778,$78FF,$0379,$FF00,$1F7A
	dc.w	$7BFF
SonAni_PushMini:
	dc.w	$FD73,$7475,$FFFF,$FF00,$3F6F,$FF00,$3F06,$FF00
	dc.w	$0307,$0707,$0707,$0909,$0808,$0801,$0A0A,$FD05
	dc.w	$0411,$1212,$1313,$1212,$1313,$1212,$1313,$1111
	dc.w	$1111,$1414,$1414,$1515,$1616,$1616,$1616,$1717
	dc.w	$1717,$1717,$A4A5,$FE02,$FC18,$19A6,$19FF,$FC1A
	dc.w	$1B1C,$1F1D,$1EFF,$FF0D,$0E0F,$100B,$0CFF,$FF61
	dc.w	$6263,$FF00,$1370,$6F70,$79FE,$0100
SonAni_Peelout:
	dc.w	$FF94,$9596,$97FF,$FFFF,$0F85,$8687,$88FF,$0301
	dc.w	$B5B5,$B6B6,$B7B7,$BBFD,$0500,$0301,$B5B5,$0101
	dc.w	$B8B8,$BBFD,$0500
SonAni_Run3D:
	dc.w	$FFA6,$A7A8,$A9FF,$FFFF
SonAni_Roll3D:
	dc.w	$FE20,$2123,$2425,$31FF,$01A4,$A5FF,$0179,$ABAC
	dc.w	$ABAC,$ABAC,$A9AA,$A9AA,$A9AA,$A7A8,$A7A8,$A7A8
	dc.w	$FD1A,$015D,$A7A8,$A7A8,$A7A8,$A9AA,$A9AA,$A9AA
	dc.w	$ABAC,$ABAC,$ABAC,$FD1A
LoadSonicDynPLC:
	tst.b   (a0)
	beq.w   loc_205BBC
	lea     sonicLastFrame.w, a2
	moveq   #$0, d0
	move.b  oMapFrame(a0), d0
	cmp.b   (a2), d0
	beq.s   loc_205BBC
	move.b  d0, (a2)
	lea     DPLC_Sonic.l, a2
	add.w   d0, d0
	adda.w  (a2, d0.w), a2
	moveq   #$0, d1
	move.w  (a2)+, d1
	subq.b  #$1, d1
	bmi.s   loc_205BBC
	lea     sonicArtBuf.w, a3
	move.b  #$1, updateSonicArt.w
loc_205B8E:
	moveq   #$0, d2
	move.b  (a2)+, d2
	move.w  d2, d0
	lsr.b   #$4, d0
	lsl.w   #$8, d2
	move.b  (a2)+, d2
	andi.w  #$fff, d2
	lsl.l   #$5, d2
	lea     Art_Sonic.l, a1
	adda.l  d2, a1
loc_205BA8:
	movem.l (a1)+, d2-d6/a4-a6
	movem.l d2-d6/a4-a6, (a3)
	lea     $20(a3), a3
	dbra    d0, loc_205BA8
	dbra    d1, loc_205B8E
loc_205BBC:
	rts     
ObjSonic_ChkFlipper:
	moveq   #$0, d0
	move.b  $3d(a0), d0
	lsl.w   #$6, d0
	addi.l  #$ffd000, d0
	movea.l d0, a1
	dc.b	$0C,$29,$00,$1E,$00,$00		; cmpi.b #$1e, $0(a1) (raw: not reproducible by assembler / suspicious)
	bne.s   loc_205C32
	move.w  #$98, d0
	jsr     PlayFMSound.l
	move.b  #$1, $1c(a1)
	move.w  $8(a1), d1
	move.w  $c(a1), d2
	addi.w  #$18, d2
	sub.w   oX(a0), d1
	sub.w   oY(a0), d2
	jsr     CalcAngle.l
	moveq   #$0, d2
	move.b  $19(a1), d2
	move.w  oX(a0), d3
	sub.w   $8(a1), d3
	add.w   d2, d3
	btst.b  #$0, $22(a1)
	bne.s   loc_205C20
	move.w  #$40, d1
	sub.w   d3, d1
	move.w  d1, d3
loc_205C20:
	move.w  #$f600, d2
	move.w  d2, d1
	ext.l   d1
	muls.w  d3, d1
	divs.w  #$40, d1
	add.w   d1, d2
	moveq   #$0, d1
loc_205C32:
	rts     
	if def(MDPORT)
	include	"MD Port/Sound Stub.asm"
	if *>$205C78
	fail "Sound stub is bigger than the original code (the level needs every address kept)"
	endif
	dcb.w	($205C78-*)/2,$4E71
	else
FadeOutMusic:
	move.w  #$e, d0
SubCPUCmd:
	cmpi.w  #$67, d0
	bne.s   loc_205C46
	move.b  #$1, bossMusic.l
loc_205C46:
	move.w  d0, GACOMCMDS.l
loc_205C4C:
	move.w  GACOMSTATS.l, d0
	beq.s   loc_205C4C
	cmp.w   GACOMSTATS.l, d0
	bne.s   loc_205C4C
	move.w  #$0, GACOMCMDS.l
loc_205C64:
	move.w  GACOMSTATS.l, d0
	bne.s   loc_205C64
	move.w  GACOMSTATS.l, d0
	bne.s   loc_205C64
	rts     
	dc.w	$0000
	endif
AnimateObject:
	moveq   #$0, d0
	move.b  oAnim(a0), d0
	cmp.b   oPrevAnim(a0), d0
	beq.s   loc_205C94
	move.b  d0, oPrevAnim(a0)
	move.b  #$0, oAnimFrame(a0)
	move.b  #$0, oAnimTime(a0)
loc_205C94:
	subq.b  #$1, oAnimTime(a0)
	bpl.s   loc_205CD4
	add.w   d0, d0
	adda.w  (a1, d0.w), a1
	move.b  (a1), oAnimTime(a0)
	moveq   #$0, d1
	move.b  oAnimFrame(a0), d1
	move.b  $1(a1, d1.w), d0
	bmi.s   loc_205CD6
loc_205CB0:
	move.b  d0, d1
	andi.b  #$1f, d0
	move.b  d0, oMapFrame(a0)
	move.b  oFlags(a0), d0
	rol.b   #$3, d1
	eor.b   d0, d1
	andi.b  #$3, d1
	andi.b  #$fc, oSprFlags(a0)
	or.b    d1, oSprFlags(a0)
	addq.b  #$1, oAnimFrame(a0)
loc_205CD4:
	rts     
loc_205CD6:
	addq.b  #$1, d0
	bne.s   loc_205CE6
	move.b  #$0, oAnimFrame(a0)
	move.b  $1(a1), d0
	bra.s   loc_205CB0
loc_205CE6:
	addq.b  #$1, d0
	bne.s   loc_205CFA
	move.b  $2(a1, d1.w), d0
	sub.b   d0, oAnimFrame(a0)
	sub.b   d0, d1
	move.b  $1(a1, d1.w), d0
	bra.s   loc_205CB0
loc_205CFA:
	addq.b  #$1, d0
	bne.s   loc_205D04
	move.b  $2(a1, d1.w), oAnim(a0)
loc_205D04:
	addq.b  #$1, d0
	bne.s   loc_205D0C
	addq.b  #$2, oRoutine(a0)
loc_205D0C:
	addq.b  #$1, d0
	bne.s   loc_205D1A
	move.b  #$0, oAnimFrame(a0)
	clr.b   oSolidType(a0)
loc_205D1A:
	addq.b  #$1, d0
	bne.s   loc_205D22
	addq.b  #$2, oSolidType(a0)
loc_205D22:
	rts     
ObjCheckpoint_SaveData:
	move.b  spawnMode.l, savedSpawnMode.l
	move.w  $FFFFD008.w, savedX.l
	move.w  $FFFFD00C.w, savedY.l
	move.b  waterRoutine.w, savedWaterRoutine.l
	move.w  bottomBound.w, savedBtmBound.l
	move.w  cameraX.w, savedCamX.l
	move.w  cameraY.w, savedCamY.l
	move.w  cameraBgX.w, savedCamBgX.l
	move.w  cameraBgY.w, savedCamBgY.l
	move.w  cameraBg2X.w, savedCamBg2X.l
	move.w  cameraBg2Y.w, savedCamBg2Y.l
	move.w  cameraBg3X.w, savedCamBg3X.l
	move.w  cameraBg3Y.w, savedCamBg3Y.l
	move.w  waterHeight2.w, savedWaterHeight.l
	move.b  waterRoutine.w, savedWaterRoutine.l
	move.b  waterFullscreen.w, savedWaterFull.l
	move.l  time.l, d0
	cmpi.l  #$50000, d0
	bcs.s   loc_205DBA
	move.l  #$50000, d0
loc_205DBA:
	move.l  d0, savedTime.l
	move.b  miniSonic.l, savedMiniSonic.l
	rts     
ObjCheckpoint:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_205DE6(pc, d0.w), d0
	jsr     dat_205DE6(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
dat_205DE6:
	dc.w	ObjCheckpoint_Init-dat_205DE6
	dc.w	ObjCheckpoint_Main-dat_205DE6
	dc.w	ObjCheckpoint_Ball-dat_205DE6
	dc.w	ObjCheckpoint_Animate-dat_205DE6
ObjCheckpoint_Init:
	addq.b  #$2, oRoutine(a0)
	move.l  #$23a84c, oMap(a0)
	move.w  #$6cb, oTile(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$18, oYRadius(a0)
	move.b  #$4, oPriority(a0)
	move.b  checkpoint.l, d0
	cmp.b   oSubtype(a0), d0
	bcs.s   loc_205E2C
	move.b  #$1, $2e(a0)
	bra.s   loc_205E32
loc_205E2C:
	move.b  #$e3, oColType(a0)
loc_205E32:
	jsr     FindObjSlot.l
	bne.s   loc_205EA4
	dc.b	$13,$7C,$00,$13,$00,$00		; move.b #$13, $0(a1) (raw: not reproducible by assembler / suspicious)
	addq.b  #$4, $24(a1)
	tst.b   $2e(a0)
	beq.s   loc_205E4E
	addq.b  #$2, $24(a1)
loc_205E4E:
	move.l  #$23a84c, $4(a1)
	move.w  #$6cb, $2(a1)
	move.b  #$4, $1(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	move.b  #$3, $18(a1)
	move.b  #$1, $1a(a1)
	move.l  a0, $30(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$20, $c(a1)
	move.w  oX(a0), $2a(a1)
	move.w  oY(a0), $2c(a1)
	subi.w  #$18, $2c(a1)
	rts     
loc_205EA4:
	jmp     DeleteObject.l
ObjCheckpoint_Main:
	tst.b   $2e(a0)
	bne.s   loc_205EDE
	tst.b   oColStatus(a0)
	beq.s   loc_205EDE
	clr.b   oColType(a0)
	move.b  #$1, $2e(a0)
	move.b  oSubtype(a0), checkpoint.l
	move.b  #$1, spawnMode.l
	bsr.w   ObjCheckpoint_SaveData
	move.w  #$ae, d0
	jmp     PlayFMSound.l
loc_205EDE:
	rts     
ObjCheckpoint_Ball:
	tst.b   $2e(a0)
	bne.s   loc_205EF6
	movea.l $30(a0), a1
	tst.b   $2e(a1)
	beq.s   loc_205F30
	move.b  #$1, $2e(a0)
loc_205EF6:
	addq.b  #$8, $34(a0)
	moveq   #$0, d0
	move.b  $34(a0), d0
	jsr     CalcSine.l
	muls.w  #$8, d0
	lsr.l   #$8, d0
	move.w  $2a(a0), oX(a0)
	add.w   d0, oX(a0)
	muls.w  #$fff8, d1
	lsr.l   #$8, d1
	move.w  $2c(a0), oY(a0)
	add.w   d1, oY(a0)
	tst.b   $34(a0)
	bne.s   loc_205F30
	addq.b  #$2, oRoutine(a0)
loc_205F30:
	rts     
ObjCheckpoint_Animate:
	lea     Ani_Checkpoint.l, a1
	bra.w   AnimateObject
ResumeMusicS1:
	rts     
ObjTestBadnik:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_205F4C(pc, d0.w), d0
	jmp     dat_205F4C(pc, d0.w)
dat_205F4C:
	dc.w	ObjTestBadnik_Init-dat_205F4C
	dc.w	ObjTestBadnik_Main-dat_205F4C
ObjTestBadnik_Init:
	btst.b  #$7, oFlags(a0)
	bne.w   DeleteObject
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.l  #$23a4c8, oMap(a0)
	move.w  #$541, oTile(a0)
	move.w  oX(a0), $30(a0)
	move.b  #$6, oColType(a0)
ObjTestBadnik_Main:
	move.w  $30(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.w   DeleteObject
	lea     Ani_Powerup.l, a1
	bsr.w   AnimateObject
	jmp     DrawObject.l
ObjExplosion_MakePoints:
	tst.b   oSolidType(a0)
	bne.s   loc_205FE2
	moveq   #$0, d1
	move.w  $3e(a0), d1
	lsr.b   #$1, d1
sub_205FC0:
	ori.b   #$80, d1
	jsr     FindObjSlot.l
	bne.s   loc_205FE2
	dc.b	$13,$7C,$00,$1C,$00,$00		; move.b #$1c, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  d1, $28(a1)
loc_205FE2:
	rts     
ObjExplosion:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_205FF2(pc, d0.w), d0
	jmp     dat_205FF2(pc, d0.w)
dat_205FF2:
	dc.w	ObjExplosion_Init-dat_205FF2
	dc.w	ObjExplosion_Main-dat_205FF2
	dc.w	ObjExplosion_Done-dat_205FF2
ObjExplosion_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.w  #$8680, oTile(a0)
	tst.b   oLayer(a0)
	beq.s   loc_20601A
	andi.b  #$7f, oTile(a0)
loc_20601A:
	move.l  #$23a6b4, oMap(a0)
	bsr.s   ObjExplosion_MakePoints
	move.b  #$0, oColType(a0)
	move.b  #$0, oAnimFrame(a0)
	move.b  #$0, oAnimTime(a0)
	move.w  #$0, oAnim(a0)
	tst.b   oSubtype(a0)
	beq.s   ObjExplosion_Main
	move.w  #$100, oAnim(a0)
ObjExplosion_Main:
	lea     Ani_Explosion.l, a1
	bsr.w   AnimateObject
	jmp     DrawObject.l
ObjExplosion_Done:
	tst.b   oSolidType(a0)
	beq.s   loc_206064
	jmp     DeleteObject.l
loc_206064:
	move.b  #$1f, oID(a0)
	move.b  #$0, oRoutine(a0)
	rts     
ObjFlower:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_206086(pc, d0.w), d0
	jsr     dat_206086(pc, d0.w)
	jmp     DrawObject.l
dat_206086:
	dc.w	ObjFlower_Init-dat_206086
	dc.w	ObjFlower_Seed-dat_206086
	dc.w	ObjFlower_Animate-dat_206086
	dc.w	ObjFlower_Growing-dat_206086
	dc.w	ObjFlower_Done-dat_206086
ObjFlower_Init:
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$0, oYRadius(a0)
	move.w  #$a6d7, oTile(a0)
	tst.b   oLayer(a0)
	beq.s   loc_2060B4
	andi.b  #$7f, oTile(a0)
loc_2060B4:
	move.l  #$2336d8, oMap(a0)
	tst.b   oSubtype(a0)
	bne.s   loc_2060DA
	bsr.w   ObjFlower_GetSavedFlags
	move.b  (a1), d0
	move.b  #$4, oRoutine(a0)
	move.b  #$3, oAnim(a0)
	btst.l  #$6, d0
	bne.s   ObjFlower_Animate
loc_2060DA:
	move.w  #$2, oAnim(a0)
	move.b  #$2, oRoutine(a0)
	move.w  #$6d7, oTile(a0)
ObjFlower_Seed:
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   loc_206138
	add.w   d1, oY(a0)
	tst.b   oSubtype(a0)
	bne.s   loc_206122
	bsr.w   ObjFlower_GetSavedFlags
	lea     flowerCount.l, a2
	move.b  (a2, d1.w), d0
	addq.b  #$1, (a2, d1.w)
	bsr.w   ObjFlower_GetPosBuffer
	move.w  oX(a0), (a1, d0.w)
	move.w  oY(a0), $2(a1, d0.w)
loc_206122:
	move.b  #$4, oRoutine(a0)
	move.b  #$1, oAnim(a0)
	move.b  #$30, oYRadius(a0)
	bra.w   ObjFlower_Animate
loc_206138:
	addq.w  #$2, oY(a0)
ObjFlower_Animate:
	lea     Ani_Flower.l, a1
	bra.w   AnimateObject
ObjFlower_GetSavedFlags:
	moveq   #$0, d0
	move.b  oSavedFlagsID(a0), d0
	move.w  d0, d1
	add.w   d1, d1
	add.w   d1, d0
	moveq   #$0, d1
	move.b  timeZone.l, d1
	bclr.l  #$7, d1
	add.w   d1, d0
	lea     savedObjFlags.l, a1
	lea     $2(a1, d0.w), a1
	rts     
ObjFlower_GetPosBuffer:
	andi.w  #$3f, d0
	add.w   d0, d0
	add.w   d0, d0
	moveq   #$0, d1
	move.b  timeZone.l, d1
	bclr.l  #$7, d1
	lsl.w   #$8, d1
	add.w   d1, d0
	lea     flowerPosBuf.l, a1
	rts     
ObjFlower_Growing:
	move.w  #$26d7, oTile(a0)
	move.b  #$2, oAnim(a0)
	bra.s   ObjFlower_Animate
ObjFlower_Done:
	move.b  #$3, oAnim(a0)
	move.b  #$4, oRoutine(a0)
	bra.s   ObjFlower_Animate
ObjSpinSplash:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_2061B6(pc, d0.w), d0
	jmp     dat_2061B6(pc, d0.w)
dat_2061B6:
	dc.w	ObjSpinSplash_Init-dat_2061B6
	dc.w	ObjSpinSplash_Main-dat_2061B6
	dc.w	ObjSpinSplash_Destroy-dat_2061B6
ObjSpinSplash_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.l  #$23a688, oMap(a0)
	move.w  #$3e4, oTile(a0)
	tst.b   timeZone.l
	bne.s   loc_2061E2
	move.w  #$39e, oTile(a0)
loc_2061E2:
	move.b  #$1, oPriority(a0)
ObjSpinSplash_Main:
	lea     Ani_TunnelWaterfall.l, a1
	bsr.w   AnimateObject
	jmp     DrawObject.l
ObjSpinSplash_Destroy:
	jmp     DeleteObject.l
ObjTunnelDoor:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjTunnelDoor_Index(pc, d0.w), d0
	jsr     ObjTunnelDoor_Index(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
ObjTunnelDoor_Index:
	dc.w	ObjTunnelDoor_Init-ObjTunnelDoor_Index
	dc.w	ObjTunnelDoor_Main-ObjTunnelDoor_Index
	dc.w	ObjTunnelDoor_Animate-ObjTunnelDoor_Index
	dc.w	ObjTunnelDoor_Reset-ObjTunnelDoor_Index
ObjTunnelDoor_ChkPlayer:
	tst.w   $12(a1)
	bpl.s   loc_206262
	bsr.w   ObjTunnelDoor_ChkCollision
	beq.s   loc_206262
	move.b  #$4, oRoutine(a0)
	tst.b   oSubtype(a0)
	bne.s   loc_206260
	jsr     FindObjSlot.l
	bne.s   loc_206260
	dc.b	$13,$7C,$00,$0B,$00,$00		; move.b #$b, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subq.w  #$4, $c(a1)
	move.w  #$a4, d0
	jmp     PlayFMSound.l
loc_206260:
	rts     
loc_206262:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     TopSolidObject.l
ObjTunnelDoor_Init:
	addq.b  #$2, oRoutine(a0)
	move.l  #$23a664, oMap(a0)
	move.b  #$1, oPriority(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$2c, oWidth(a0)
	cmpi.b  #$2, oSubtype(a0)
	bne.s   loc_20629C
	move.b  #$18, oWidth(a0)
loc_20629C:
	move.b  #$8, oYRadius(a0)
	moveq   #$c, d0
	jsr     SetObjectTileID.l
ObjTunnelDoor_Main:
	lea     objects.w, a1
	bsr.w   ObjTunnelDoor_ChkPlayer
	lea     objPlayerSlot2.w, a1
	bra.w   ObjTunnelDoor_ChkPlayer
ObjTunnelDoor_Animate:
	lea     Ani_TunnelDoor.l, a1
	bra.w   AnimateObject
ObjTunnelDoor_Reset:
	move.b  #$1, oPrevAnim(a0)
	move.b  #$0, oMapFrame(a0)
	subq.b  #$4, oRoutine(a0)
	rts     
ObjTunnelDoor_ChkCollision:
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	moveq   #$0, d1
	move.b  oWidth(a0), d1
	add.w   d1, d0
	bmi.s   loc_20630A
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   loc_20630A
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	moveq   #$0, d1
	move.b  oYRadius(a0), d1
	add.w   d1, d0
	bmi.s   loc_20630A
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   loc_20630A
	moveq   #$1, d0
	rts     
loc_20630A:
	moveq   #$0, d0
	rts     
ObjTunnelDoorSplash:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjTunnelDoorSplash_Index(pc, d0.w), d0
	jmp     ObjTunnelDoorSplash_Index(pc, d0.w)
ObjTunnelDoorSplash_Index:
	dc.w	ObjTunnelDoorSplash_Init-ObjTunnelDoorSplash_Index
	dc.w	ObjTunnelDoorSplash_Main-ObjTunnelDoorSplash_Index
	dc.w	ObjTunnelDoorSplash_Destroy-ObjTunnelDoorSplash_Index
ObjTunnelDoorSplash_Init:
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.l  #$23a5f2, oMap(a0)
	move.b  oSubtype(a0), oAnim(a0)
	moveq   #$d, d0
	jsr     SetObjectTileID.l
	move.w  #$a2, d0
	cmpi.b  #$2, oSubtype(a0)
	bcs.s   loc_206358
	move.w  #$a1, d0
loc_206358:
	jsr     PlayFMSound.l
ObjTunnelDoorSplash_Main:
	lea     Ani_TunnelDoorSplash.l, a1
	bsr.w   AnimateObject
	jmp     DrawObject.l
ObjTunnelDoorSplash_Destroy:
	jmp     DeleteObject.l
ObjPowerup:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjPowerup_Index(pc, d0.w), d1
	jmp     ObjPowerup_Index(pc, d1.w)
ObjPowerup_Index:
	dc.w	ObjPowerup_Init-ObjPowerup_Index
	dc.w	ObjPowerup_Shield-ObjPowerup_Index
	dc.w	ObjPowerup_InvStars-ObjPowerup_Index
	dc.w	ObjPowerup_TimeStars-ObjPowerup_Index
ObjPowerup_Init:
	addq.b  #$2, oRoutine(a0)
	move.l  #$23a4c8, oMap(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$10, oWidth(a0)
	move.w  #$544, oTile(a0)
	tst.b   oAnim(a0)
	beq.s   loc_2063C4
	addq.b  #$2, oRoutine(a0)
	cmpi.b  #$5, oAnim(a0)
	bcs.s   loc_2063C4
	addq.b  #$2, oRoutine(a0)
loc_2063C4:
	rts     
ObjPowerup_Shield:
	tst.b   shield.l
	beq.s   loc_206420
	tst.b   timeWarp.l
	bne.s   loc_20641E
	tst.b   invincible.l
	bne.s   loc_20641E
	move.w  $FFFFD008.w, oX(a0)
	move.w  $FFFFD00C.w, oY(a0)
	move.b  $FFFFD022.w, oFlags(a0)
	cmpi.b  #$6, zoneAct.l
	bne.s   loc_20640E
	ori.b   #$80, oTile(a0)
	tst.b   layer.l
	beq.s   loc_20640E
	andi.b  #$7f, oTile(a0)
loc_20640E:
	lea     Ani_Powerup.l, a1
	jsr     AnimateObject.l
	bra.w   ObjPowerup_ChkSaveRout
loc_20641E:
	rts     
loc_206420:
	jmp     DeleteObject.l
ObjPowerup_InvStars:
	tst.b   timeWarp.l
	beq.s   loc_206430
	rts     
loc_206430:
	tst.b   invincible.l
	bne.s   ObjPowerup_ShowStars
	jmp     DeleteObject.l
ObjPowerup_TimeStars:
	tst.b   timeWarp.l
	bne.s   ObjPowerup_ShowStars
	jmp     DeleteObject.l
ObjPowerup_ShowStars:
	cmpi.b  #$6, zoneAct.l
	bne.s   loc_20646A
	ori.b   #$80, oTile(a0)
	tst.b   layer.l
	beq.s   loc_20646A
	andi.b  #$7f, oTile(a0)
loc_20646A:
	move.w  sonicRecordIndex.w, d0
	move.b  oAnim(a0), d1
	subq.b  #$1, d1
	cmpi.b  #$4, d1
	bcs.s   loc_20647C
	subq.b  #$4, d1
loc_20647C:
	lsl.b   #$3, d1
	move.b  d1, d2
	add.b   d1, d1
	add.b   d2, d1
	addq.b  #$4, d1
	sub.b   d1, d0
	move.b  $30(a0), d1
	sub.b   d1, d0
	addq.b  #$4, d1
	cmpi.b  #$18, d1
	bcs.s   loc_206498
	moveq   #$0, d1
loc_206498:
	move.b  d1, $30(a0)
	lea     sonicRecordBuf.w, a1
	lea     (a1, d0.w), a1
	move.w  (a1)+, oX(a0)
	move.w  (a1)+, oY(a0)
	move.b  $FFFFD022.w, oFlags(a0)
	lea     Ani_Powerup.l, a1
	jsr     AnimateObject.l
ObjPowerup_ChkSaveRout:
	move.b  powerup.l, d0
	andi.b  #$f, d0
	cmpi.b  #$8, d0
	bcs.s   loc_2064D0
	rts     
loc_2064D0:
	cmp.b   oRoutine(a0), d0
	beq.s   loc_2064E6
	move.b  oRoutine(a0), powerup.l
	bset.b  #$7, powerup.l
loc_2064E6:
	jmp     DrawObject.l
LoadShieldArt:
	bclr.b  #$7, powerup.l
	beq.s   loc_20653A
	moveq   #$0, d0
	move.b  powerup.l, d0
	subq.b  #$2, d0
	add.w   d0, d0
	movea.l ShieldArtIndex(pc, d0.w), a1
	lea     aniArtBuffer.l, a2
	move.w  #$ff, d0
loc_206510:
	move.l  (a1)+, (a2)+
	dbra    d0, loc_206510
	lea     VDPCTRL.l, a5
	move.l  #$94029340, (a5)
	move.l  #$968c95c0, (a5)
	move.w  #$977f, (a5)
	move.w  #$6880, (a5)
	move.w  #$82, dmaCmdLow.w
	move.w  dmaCmdLow.w, (a5)
loc_20653A:
	rts     
ShieldArtIndex:
	dc.w	$0023,$114E,$0023,$15CE,$0023,$1A4E,$0023,$09A2
	dc.w	$0023,$05E2
ObjSpinTunnel:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjSpinTunnel_Index(pc, d0.w), d0
	jsr     ObjSpinTunnel_Index(pc, d0.w)
	tst.b   debugCheat.l
	beq.s   loc_20656C
	jsr     DrawObject.l
loc_20656C:
	jmp     CheckObjDespawn.l
ObjSpinTunnel_Index:
	dc.w	ObjSpinTunnel_Init-ObjSpinTunnel_Index
	dc.w	ObjSpinTunnel_Main-ObjSpinTunnel_Index
ObjSpinTunnel_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$544, oTile(a0)
	move.l  #$23a4c8, oMap(a0)
	move.b  oSubtype(a0), oMapFrame(a0)
	addq.b  #$1, oMapFrame(a0)
ObjSpinTunnel_Main:
	lea     objects.w, a1
	cmpi.b  #$2b, $1c(a1)
	beq.w   loc_206654
	cmpi.b  #$6, $24(a1)
	bcc.w   loc_206654
	bsr.w   ObjSpinTunnel_CheckInRange
	beq.w   loc_206654
	tst.b   oSubtype(a0)
	bne.s   loc_206606
	move.w  $10(a1), d0
	bpl.s   loc_2065C6
	neg.w   d0
loc_2065C6:
	move.w  #$a00, d1
	cmpi.b  #$5, zoneAct.l
	bne.s   loc_2065D8
	move.w  #$d00, d1
loc_2065D8:
	cmp.w   d1, d0
	bcc.s   loc_2065DE
	move.w  d1, d0
loc_2065DE:
	tst.w   $10(a1)
	bpl.s   loc_2065E6
	neg.w   d0
loc_2065E6:
	move.w  d0, $10(a1)
	move.w  d0, $14(a1)
	move.b  $26(a1), d0
	addi.b  #$20, d0
	andi.b  #$c0, d0
	cmpi.b  #$80, d0
	bne.s   loc_206636
	neg.w   $14(a1)
	bra.s   loc_206636
loc_206606:
	cmpi.b  #$2, oSubtype(a0)
	bcc.s   loc_206656
	move.w  $12(a1), d0
	bpl.s   loc_206616
	neg.w   d0
loc_206616:
	cmpi.w  #$d00, d0
	bcc.s   loc_206620
	move.w  #$d00, d0
loc_206620:
	tst.w   $12(a1)
	bpl.s   loc_206628
	neg.w   d0
loc_206628:
	move.w  d0, $12(a1)
	move.w  d0, $14(a1)
	bset.b  #$1, $22(a1)
loc_206636:
	bset.b  #$2, $22(a1)
	bne.s   loc_206654
	move.b  #$e, $16(a1)
	move.b  #$7, $17(a1)
	addq.w  #$5, $c(a1)
	move.b  #$2, $1c(a1)
loc_206654:
	rts     
loc_206656:
	move.b  p1CtrlData.w, d1
	cmpi.b  #$4, oSubtype(a0)
	beq.s   loc_2066A2
	cmpi.b  #$2, oSubtype(a0)
	bne.s   loc_206672
	tst.w   $12(a1)
	bpl.s   loc_206636
	bra.s   loc_206678
loc_206672:
	tst.w   $12(a1)
	bmi.s   loc_206636
loc_206678:
	move.w  #$d00, d0
	btst.l  #$3, d1
	bne.s   loc_20668A
	btst.l  #$2, d1
	beq.s   loc_206636
	neg.w   d0
loc_20668A:
	cmpi.b  #$2, oSubtype(a0)
	beq.s   loc_206698
	bset.b  #$1, $22(a1)
loc_206698:
	move.w  d0, $10(a1)
	move.w  d0, $14(a1)
	bra.s   loc_206636
loc_2066A2:
	tst.w   $10(a1)
	bmi.s   loc_206636
	btst.l  #$0, d1
	beq.w   loc_206636
	move.w  #$f600, d0
	bra.w   loc_206628
ObjSpinTunnel_CheckInRange:
	tst.b   debugMode.l
	bne.s   loc_2066EC
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	addi.w  #$28, d0
	bmi.s   loc_2066EC
	cmpi.w  #$50, d0
	bcc.s   loc_2066EC
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	addi.w  #$28, d0
	bmi.s   loc_2066EC
	cmpi.w  #$50, d0
	bcc.s   loc_2066EC
	moveq   #$1, d0
	rts     
loc_2066EC:
	moveq   #$0, d0
	rts     
ObjSonic_SpecialCol:
	cmpi.b  #$2b, oAnim(a0)
	beq.s   loc_2066FA
	bsr.s   sub_2066FC
loc_2066FA:
	rts     
sub_2066FC:
	move.w  oXVel(a0), d1
	move.w  oYVel(a0), d2
	jsr     CalcAngle.l
	subi.b  #$20, d0
	andi.b  #$c0, d0
	cmpi.b  #$40, d0
	beq.w   loc_2067E0
	cmpi.b  #$80, d0
	beq.w   loc_206766
	cmpi.b  #$c0, d0
	beq.w   loc_2067A2
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	move.b  oYRadius(a0), d0
	ext.w   d0
	add.w   d0, d2
	move.b  oXRadius(a0), d0
	ext.w   d0
	sub.w   d0, d3
	bsr.w   sub_20681E
	bne.s   loc_206764
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	move.b  oYRadius(a0), d0
	ext.w   d0
	add.w   d0, d2
	move.b  oXRadius(a0), d0
	ext.w   d0
	add.w   d0, d3
	bra.w   sub_20681E
loc_206764:
	rts     
loc_206766:
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	move.b  oYRadius(a0), d0
	ext.w   d0
	sub.w   d0, d2
	move.b  oXRadius(a0), d0
	ext.w   d0
	sub.w   d0, d3
	bsr.w   sub_20681E
	bne.s   loc_2067A0
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	move.b  oYRadius(a0), d0
	ext.w   d0
	sub.w   d0, d2
	move.b  oXRadius(a0), d0
	ext.w   d0
	add.w   d0, d3
	bra.w   sub_20681E
loc_2067A0:
	rts     
loc_2067A2:
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	move.b  oXRadius(a0), d0
	ext.w   d0
	add.w   d0, d3
	move.b  oYRadius(a0), d0
	subq.b  #$6, d0
	ext.w   d0
	sub.w   d0, d2
	bsr.w   sub_20681E
	bne.s   loc_2067DE
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	move.b  oXRadius(a0), d0
	ext.w   d0
	add.w   d0, d3
	move.b  oYRadius(a0), d0
	ext.w   d0
	add.w   d0, d2
	bra.w   sub_20681E
loc_2067DE:
	rts     
loc_2067E0:
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	move.b  oXRadius(a0), d0
	ext.w   d0
	sub.w   d0, d3
	move.b  oYRadius(a0), d0
	subq.b  #$6, d0
	ext.w   d0
	sub.w   d0, d2
	bsr.w   sub_20681E
	bne.s   loc_20681C
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	move.b  oXRadius(a0), d0
	ext.w   d0
	sub.w   d0, d3
	move.b  oYRadius(a0), d0
	ext.w   d0
	add.w   d0, d2
	bra.w   sub_20681E
loc_20681C:
	rts     
sub_20681E:
	jsr     GetLevelBlock.l
	move.w  (a1), d0
	move.w  d0, d4
	andi.w  #$7ff, d0
	beq.s   loc_206862
	moveq   #$0, d1
	move.b  timeZone.l, d1
	bclr.l  #$7, d1
	cmpi.b  #$2, d1
	bne.s   loc_206846
	add.b   goodFuture.l, d1
loc_206846:
	add.w   d1, d1
	move.w  dat_206866(pc, d1.w), d1
	lea     dat_206866(pc, d1.w), a1
	moveq   #$0, d6
	move.w  (a1)+, d6
	moveq   #$0, d1
loc_206856:
	cmp.w   (a1, d1.w), d0
	beq.s   loc_2068DA
	addq.w  #$2, d1
	dbra    d6, loc_206856
loc_206862:
	moveq   #$0, d0
	rts     
dat_206866:
	dc.w	$002A,$0008,$0052,$0030,$000F,$013C,$0146,$019B
	dc.w	$01AE,$0083,$0084,$0089,$008A,$0077,$0076,$0080
	dc.w	$007F,$007E,$007D,$007C,$0082,$0001,$0145,$0146
	dc.w	$000F,$013C,$0146,$0000,$0000,$0083,$0084,$0089
	dc.w	$008A,$0077,$0076,$0080,$007F,$007E,$007D,$007C
	dc.w	$0082,$000F,$013C,$0146,$0165,$0166,$0083,$0084
	dc.w	$0089,$008A,$0077,$0076,$0080,$007F,$007E,$007D
	dc.w	$007C,$0082
loc_2068DA:
	cmpi.b  #$4, oRoutine(a0)
	bne.s   loc_2068EC
	subq.b  #$2, oRoutine(a0)
	move.w  #$78, $30(a0)
loc_2068EC:
	move.b  #$0, $ff1950.l
	move.l  d1, -(a7)
	move.w  dat_206930(pc, d1.w), d0
	jsr     dat_206930(pc, d0.w)
	move.l  (a7)+, d1
	cmpi.w  #$3, d1
	bcs.s   loc_206920
	move.w  #$be, d0
	cmpi.b  #$4, d1
	beq.s   loc_20691A
	cmpi.b  #$6, d1
	beq.s   loc_20691A
	move.w  #$b5, d0
loc_20691A:
	jsr     PlayFMSound.l
loc_206920:
	tst.b   $ff1950.l
	beq.s   loc_20692C
	moveq   #$0, d0
	rts     
loc_20692C:
	moveq   #$1, d0
	rts     
dat_206930:
	dc.w	loc_206950-dat_206930
	dc.w	loc_206950-dat_206930
	dc.w	loc_206A00-dat_206930
	dc.w	loc_206A00-dat_206930
	dc.w	loc_206B96-dat_206930
	dc.w	loc_206A52-dat_206930
	dc.w	loc_206A64-dat_206930
	dc.w	loc_206A64-dat_206930
	dc.w	loc_206B72-dat_206930
	dc.w	loc_206ACA-dat_206930
	dc.w	loc_206ACA-dat_206930
	dc.w	loc_206ACA-dat_206930
	dc.w	loc_206AAE-dat_206930
	dc.w	loc_206A52-dat_206930
	dc.w	loc_206A52-dat_206930
	dc.w	loc_206A76-dat_206930
loc_206950:
	andi.w  #$fff0, d2
	tst.b   d1
	bne.s   loc_20695C
	addi.w  #$10, d2
loc_20695C:
	andi.w  #$fff0, d3
	btst.l  #$b, d4
	bne.s   loc_20696A
	addi.w  #$10, d3
loc_20696A:
	move.w  d3, d1
	movem.l d1-d2, -(a7)
	sub.w   oX(a0), d1
	sub.w   oY(a0), d2
	jsr     CalcAngle.l
	jsr     CalcSine.l
	muls.w  #$f900, d1
	asr.l   #$8, d1
	move.w  d1, oXVel(a0)
	muls.w  #$f900, d0
	asr.l   #$8, d0
	move.w  d0, oYVel(a0)
	bset.b  #$1, oFlags(a0)
	bclr.b  #$4, oFlags(a0)
	bclr.b  #$5, oFlags(a0)
	clr.b   $3c(a0)
	movem.l (a7)+, d1-d2
	move.w  d2, d4
	move.w  d1, d5
	jsr     FindObjSlot.l
	bne.s   loc_2069CC
	dc.b	$13,$7C,$00,$29,$00,$00		; move.b #$29, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  d5, $8(a1)
	move.w  d4, $c(a1)
loc_2069CC:
	move.w  #$0, d3
	jsr     PlaceBlockAtPos.l
	subi.w  #$10, d5
	jsr     PlaceBlockAtPos.l
	subi.w  #$10, d4
	jsr     PlaceBlockAtPos.l
	addi.w  #$10, d5
	jsr     PlaceBlockAtPos.l
	move.w  #$92, d0
	jsr     SubCPUCmd.l
	rts     
loc_206A00:
	andi.w  #$fff0, d2
	addq.w  #$8, d2
	andi.w  #$fff0, d3
	addq.w  #$8, d3
	move.w  d3, d1
	sub.w   oX(a0), d1
	sub.w   oY(a0), d2
	jsr     CalcAngle.l
	jsr     CalcSine.l
	muls.w  #$f900, d1
	asr.l   #$8, d1
	asr.l   #$1, d1
	move.w  d1, oXVel(a0)
	muls.w  #$f900, d0
	asr.l   #$8, d0
	asr.l   #$1, d0
	move.w  d0, oYVel(a0)
loc_206A3A:
	bset.b  #$1, oFlags(a0)
	bclr.b  #$4, oFlags(a0)
	bclr.b  #$5, oFlags(a0)
	clr.b   $3c(a0)
	rts     
loc_206A52:
	move.w  #$700, d0
	tst.w   oYVel(a0)
	bmi.s   loc_206A5E
	neg.w   d0
loc_206A5E:
	move.w  d0, oYVel(a0)
	bra.s   loc_206A3A
loc_206A64:
	move.w  #$700, d0
	tst.w   oXVel(a0)
	bmi.s   loc_206A70
	neg.w   d0
loc_206A70:
	move.w  d0, oXVel(a0)
	bra.s   loc_206A3A
loc_206A76:
	andi.w  #$fff0, d2
	addq.w  #$8, d2
	andi.w  #$fff0, d3
	addq.w  #$8, d3
	move.w  d3, d1
	sub.w   oX(a0), d1
	sub.w   oY(a0), d2
	jsr     CalcAngle.l
	jsr     CalcSine.l
	muls.w  #$f900, d1
	asr.l   #$8, d1
	move.w  d1, oXVel(a0)
	muls.w  #$f900, d0
	asr.l   #$8, d0
	move.w  d0, oYVel(a0)
	bra.s   loc_206A3A
loc_206AAE:
	move.w  d3, d1
	andi.w  #$f, d1
	cmpi.b  #$8, d1
	bcc.s   loc_206AC2
	btst.l  #$b, d4
	bne.s   loc_206A64
	bra.s   loc_206A52
loc_206AC2:
	btst.l  #$b, d4
	bne.s   loc_206A52
	bra.s   loc_206A64
loc_206ACA:
	subi.w  #$12, d1
	bmi.s   loc_206AFC
	move.w  dat_206B3C(pc, d1.w), d0
	lea     dat_206B3C(pc, d0.w), a1
	andi.w  #$f, d2
	andi.w  #$f, d3
	btst.l  #$b, d4
	bne.s   loc_206AEC
	neg.b   d3
	addi.b  #$f, d3
loc_206AEC:
	cmp.b   (a1, d3.w), d2
	bcc.s   loc_206AFC
	move.b  #$1, $ff1950.l
	rts     
loc_206AFC:
	move.w  oXVel(a0), d1
	move.w  oYVel(a0), d2
	jsr     CalcAngle.l
	addi.b  #$80, d0
	neg.b   d0
	subi.b  #$20, d0
	btst.l  #$b, d4
	beq.s   loc_206B1E
	addi.b  #$40, d0
loc_206B1E:
	jsr     CalcSine.l
	muls.w  #$f900, d1
	asr.l   #$8, d1
	move.w  d1, oXVel(a0)
	muls.w  #$f900, d0
	asr.l   #$8, d0
	move.w  d0, oYVel(a0)
	bra.w   loc_206A3A
dat_206B3C:
	dc.w	$0006,$0016,$0026,$0101,$0102,$0202,$0303,$0304
	dc.w	$0404,$0505,$0506,$0606,$0707,$0708,$0808,$0909
	dc.w	$090A,$0A0A,$0B0B,$0B0C,$0C0C,$0D0D,$0D0E,$0E0E
	dc.w	$0F0F,$0F10,$1010
loc_206B72:
	move.w  d3, d1
	andi.w  #$f, d1
	cmpi.b  #$8, d1
	bcc.s   loc_206B8A
	btst.l  #$b, d4
	bne.w   loc_206A64
	bra.w   loc_206ACA
loc_206B8A:
	btst.l  #$b, d4
	bne.w   loc_206A52
	bra.w   loc_206ACA
loc_206B96:
	move.w  d3, d1
	andi.w  #$f, d1
	cmpi.b  #$8, d1
	bcc.s   loc_206BAE
	btst.l  #$b, d4
	bne.w   loc_206A52
	bra.w   loc_206A76
loc_206BAE:
	btst.l  #$b, d4
	bne.w   loc_206A76
	bra.w   loc_206A52
	move.w  d2, d1
	andi.w  #$f, d1
	cmpi.b  #$8, d1
	bcc.s   loc_206BD2
	btst.l  #$c, d4
	bne.w   loc_206A64
	bra.w   loc_206A76
loc_206BD2:
	btst.l  #$c, d4
	bne.w   loc_206A76
	bra.w   loc_206A64
LoadTimeWarpData:
	move.w  warpX.l, $8(a6)
	move.w  warpY.l, $c(a6)
	move.b  warpPlayerFlags.l, $22(a6)
	move.w  warpGVel.l, $14(a6)
	move.w  warpXVel.l, $10(a6)
	move.w  warpYVel.l, $12(a6)
	move.w  warpRings.l, rings.l
	move.b  warpLivesFlags.l, livesFlags.l
	move.l  warpTime.l, time.l
	move.b  warpWaterRoutine.l, waterRoutine.w
	move.w  warpBtmBound.l, bottomBound.w
	move.w  warpBtmBound.l, destBottomBound.w
	move.w  warpCamX.l, cameraX.w
	move.w  warpCamY.l, cameraY.w
	move.w  warpCamBgX.l, cameraBgX.w
	move.w  warpCamBgY.l, cameraBgY.w
	move.w  warpCamBg2X.l, cameraBg2X.w
	move.w  warpCamBg2Y.l, cameraBg2Y.w
	move.w  warpCamBg3X.l, cameraBg3X.w
	move.w  warpCamBg3Y.l, cameraBg3Y.w
	cmpi.b  #$6, zoneAct.l
	bne.s   loc_206C98
	move.b  warpMiniSonic.l, miniSonic.l
loc_206C98:
	tst.b   spawnMode.l
	bpl.s   loc_206CAE
	move.w  warpX.l, d0
	subi.w  #$a0, d0
	move.w  d0, leftBound.w
loc_206CAE:
	rts     
LoadCheckpointData:
	lea     objects.w, a6
	cmpi.b  #$2, spawnMode.l
	beq.w   LoadTimeWarpData
	move.b  savedSpawnMode.l, spawnMode.l
	move.w  savedX.l, $8(a6)
	move.w  savedY.l, $c(a6)
	clr.w   rings.l
	clr.b   livesFlags.l
	move.l  savedTime.l, time.l
	move.b  #$3b, timeFrames.l
	subq.b  #$1, timeSeconds.l
	move.b  savedWaterRoutine.l, waterRoutine.w
	move.w  savedBtmBound.l, bottomBound.w
	move.w  savedBtmBound.l, destBottomBound.w
	move.w  savedCamX.l, cameraX.w
	move.w  savedCamY.l, cameraY.w
	move.w  savedCamBgX.l, cameraBgX.w
	move.w  savedCamBgY.l, cameraBgY.w
	move.w  savedCamBg2X.l, cameraBg2X.w
	move.w  savedCamBg2Y.l, cameraBg2Y.w
	move.w  savedCamBg3X.l, cameraBg3X.w
	move.w  savedCamBg3Y.l, cameraBg3Y.w
	cmpi.b  #$6, zoneAct.l
	bne.s   loc_206D6A
	move.b  savedMiniSonic.l, miniSonic.l
loc_206D6A:
	cmpi.b  #$2, zoneAct.l
	bne.s   loc_206D8C
	move.w  savedWaterHeight.l, waterHeight2.w
	move.b  savedWaterRoutine.l, waterRoutine.w
	move.b  savedWaterFull.l, waterFullscreen.w
loc_206D8C:
	tst.b   spawnMode.l
	bpl.s   loc_206DA2
	move.w  savedX.l, d0
	subi.w  #$a0, d0
	move.w  d0, leftBound.w
loc_206DA2:
	rts     
Player_CalcRoomInFront:
	move.l  oX(a0), d3
	move.l  oY(a0), d2
	move.w  oXVel(a0), d1
	ext.l   d1
	asl.l   #$8, d1
	add.l   d1, d3
	move.w  oYVel(a0), d1
	ext.l   d1
	asl.l   #$8, d1
	add.l   d1, d2
	swap    d2
	swap    d3
	move.b  d0, primaryAngle.w
	move.b  d0, secondaryAngle.w
	move.b  d0, d1
	addi.b  #$20, d0
	bpl.s   loc_206DE0
	move.b  d1, d0
	bpl.s   loc_206DDA
	subq.b  #$1, d0
loc_206DDA:
	addi.b  #$20, d0
	bra.s   loc_206DEA
loc_206DE0:
	move.b  d1, d0
	bpl.s   loc_206DE6
	addq.b  #$1, d0
loc_206DE6:
	addi.b  #$1f, d0
loc_206DEA:
	andi.b  #$c0, d0
	beq.w   Player_GetFloorDist_Part2
	cmpi.b  #$80, d0
	beq.w   Player_GetCeilDist_Part2
	andi.b  #$38, d1
	bne.s   loc_206E02
	addq.w  #$8, d2
loc_206E02:
	cmpi.b  #$40, d0
	beq.w   Player_GetLWallDist_Part2
	bra.w   Player_GetRWallDist_Part2
Player_CalcRoomOverHead:
	move.b  d0, primaryAngle.w
	move.b  d0, secondaryAngle.w
	addi.b  #$20, d0
	andi.b  #$c0, d0
	cmpi.b  #$40, d0
	beq.w   Player_CheckLCeil
	cmpi.b  #$80, d0
	beq.w   Player_CheckCeiling
	cmpi.b  #$c0, d0
	beq.w   Player_CheckRCeil
sub_206E36:
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oYRadius(a0), d0
	ext.w   d0
	add.w   d0, d2
	move.b  oXRadius(a0), d0
	ext.w   d0
	add.w   d0, d3
	lea     primaryAngle.w, a4
	movea.w #$10, a3
	move.w  #$0, d6
	moveq   #$d, d5
	jsr     FindLevelFloor.l
	move.w  d1, -(a7)
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oYRadius(a0), d0
	ext.w   d0
	add.w   d0, d2
	move.b  oXRadius(a0), d0
	ext.w   d0
	sub.w   d0, d3
	lea     secondaryAngle.w, a4
	movea.w #$10, a3
	move.w  #$0, d6
	moveq   #$d, d5
	jsr     FindLevelFloor.l
	move.w  (a7)+, d0
	move.b  #$0, d2
Player_ChooseAngle:
	move.b  secondaryAngle.w, d3
	cmp.w   d0, d1
	ble.s   loc_206EA8
	move.b  primaryAngle.w, d3
	exg.l   d0, d1
loc_206EA8:
	btst.l  #$0, d3
	beq.s   loc_206EB0
	move.b  d2, d3
loc_206EB0:
	rts     
	move.w  oY(a0), d2
	move.w  oX(a0), d3
Player_GetFloorDist_Part2:
	addi.w  #$a, d2
	lea     primaryAngle.w, a4
	movea.w #$10, a3
	move.w  #$0, d6
	moveq   #$e, d5
	jsr     FindLevelFloor.l
	move.b  #$0, d2
Player_GetPriAngle:
	move.b  primaryAngle.w, d3
	btst.l  #$0, d3
	beq.s   loc_206EE2
	move.b  d2, d3
loc_206EE2:
	rts     
ObjGetFloorDist:
	move.w  oX(a0), d3
ObjGetFloorDist2:
	move.w  oY(a0), d2
	moveq   #$0, d0
	move.b  oYRadius(a0), d0
	ext.w   d0
	add.w   d0, d2
	lea     primaryAngle.w, a4
	move.b  #$0, (a4)
	movea.w #$10, a3
	move.w  #$0, d6
	moveq   #$d, d5
	jsr     FindLevelFloor.l
	move.b  primaryAngle.w, d3
	btst.l  #$0, d3
	beq.s   loc_206F1C
	move.b  #$0, d3
loc_206F1C:
	rts     
Player_CheckRCeil:
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oXRadius(a0), d0
	ext.w   d0
	sub.w   d0, d2
	move.b  oYRadius(a0), d0
	ext.w   d0
	add.w   d0, d3
	lea     primaryAngle.w, a4
	movea.w #$10, a3
	move.w  #$0, d6
	moveq   #$e, d5
	jsr     FindLevelWall.l
	move.w  d1, -(a7)
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oXRadius(a0), d0
	ext.w   d0
	add.w   d0, d2
	move.b  oYRadius(a0), d0
	ext.w   d0
	add.w   d0, d3
	lea     secondaryAngle.w, a4
	movea.w #$10, a3
	move.w  #$0, d6
	moveq   #$e, d5
	jsr     FindLevelWall.l
	move.w  (a7)+, d0
	move.b  #$c0, d2
	bra.w   Player_ChooseAngle
Player_GetRWallDist:
	move.w  oY(a0), d2
	move.w  oX(a0), d3
Player_GetRWallDist_Part2:
	addi.w  #$a, d3
	lea     primaryAngle.w, a4
	movea.w #$10, a3
	move.w  #$0, d6
	moveq   #$e, d5
	jsr     FindLevelWall.l
	move.b  #$c0, d2
	bra.w   Player_GetPriAngle
ObjGetRWallDist:
	add.w   oX(a0), d3
	move.w  oY(a0), d2
	lea     primaryAngle.w, a4
	move.b  #$0, (a4)
	movea.w #$10, a3
	move.w  #$0, d6
	moveq   #$e, d5
	jsr     FindLevelWall.l
	move.b  primaryAngle.w, d3
	btst.l  #$0, d3
	beq.s   loc_206FDC
	move.b  #$c0, d3
loc_206FDC:
	rts     
Player_CheckCeiling:
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oYRadius(a0), d0
	ext.w   d0
	sub.w   d0, d2
	eori.w  #$f, d2
	move.b  oXRadius(a0), d0
	ext.w   d0
	add.w   d0, d3
	lea     primaryAngle.w, a4
	movea.w #$fff0, a3
	move.w  #$1000, d6
	moveq   #$e, d5
	jsr     FindLevelFloor.l
	move.w  d1, -(a7)
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oYRadius(a0), d0
	ext.w   d0
	sub.w   d0, d2
	eori.w  #$f, d2
	move.b  oXRadius(a0), d0
	ext.w   d0
	sub.w   d0, d3
	lea     secondaryAngle.w, a4
	movea.w #$fff0, a3
	move.w  #$1000, d6
	moveq   #$e, d5
	jsr     FindLevelFloor.l
	move.w  (a7)+, d0
	move.b  #$80, d2
	bra.w   Player_ChooseAngle
Player_GetCeilDist:
	move.w  oY(a0), d2
	move.w  oX(a0), d3
Player_GetCeilDist_Part2:
	subi.w  #$a, d2
	eori.w  #$f, d2
	lea     primaryAngle.w, a4
	movea.w #$fff0, a3
	move.w  #$1000, d6
	moveq   #$e, d5
	jsr     FindLevelFloor.l
	move.b  #$80, d2
	bra.w   Player_GetPriAngle
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oYRadius(a0), d0
	ext.w   d0
	sub.w   d0, d2
	eori.w  #$f, d2
	lea     primaryAngle.w, a4
	movea.w #$fff0, a3
	move.w  #$1000, d6
	moveq   #$e, d5
	jsr     FindLevelFloor.l
	move.b  primaryAngle.w, d3
	btst.l  #$0, d3
	beq.s   loc_2070B2
	move.b  #$80, d3
loc_2070B2:
	rts     
Player_CheckLCeil:
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oXRadius(a0), d0
	ext.w   d0
	sub.w   d0, d2
	move.b  oYRadius(a0), d0
	ext.w   d0
	sub.w   d0, d3
	eori.w  #$f, d3
	lea     primaryAngle.w, a4
	movea.w #$fff0, a3
	move.w  #$800, d6
	moveq   #$e, d5
	jsr     FindLevelWall.l
	move.w  d1, -(a7)
	move.w  oY(a0), d2
	move.w  oX(a0), d3
	moveq   #$0, d0
	move.b  oXRadius(a0), d0
	ext.w   d0
	add.w   d0, d2
	move.b  oYRadius(a0), d0
	ext.w   d0
	sub.w   d0, d3
	eori.w  #$f, d3
	lea     secondaryAngle.w, a4
	movea.w #$fff0, a3
	move.w  #$800, d6
	moveq   #$e, d5
	jsr     FindLevelWall.l
	move.w  (a7)+, d0
	move.b  #$40, d2
	bra.w   Player_ChooseAngle
Player_GetLWallDist:
	move.w  oY(a0), d2
	move.w  oX(a0), d3
Player_GetLWallDist_Part2:
	subi.w  #$a, d3
	eori.w  #$f, d3
	lea     primaryAngle.w, a4
	movea.w #$fff0, a3
	move.w  #$800, d6
	moveq   #$e, d5
	jsr     FindLevelWall.l
	move.b  #$40, d2
	bra.w   Player_GetPriAngle
ObjGetLWallDist:
	add.w   oX(a0), d3
	move.w  oY(a0), d2
	lea     primaryAngle.w, a4
	move.b  #$0, (a4)
	movea.w #$fff0, a3
	move.w  #$800, d6
	moveq   #$e, d5
	jsr     FindLevelWall.l
	move.b  primaryAngle.w, d3
	btst.l  #$0, d3
	beq.s   loc_20717E
	move.b  #$40, d3
loc_20717E:
	rts     
	btst.b  #$6, $2c(a0)
	bne.s   loc_2071CE
	nop     
	move.w  oX(a0), d2
	move.w  oY(a0), d3
	subq.w  #$8, d2
	moveq   #$0, d5
	move.b  oYRadius(a0), d5
	subq.b  #$3, d5
	sub.w   d5, d3
	cmpi.b  #$39, oMapFrame(a0)
	bne.s   loc_2071AC
	addi.w  #$c, d3
	moveq   #$a, d5
loc_2071AC:
	move.w  #$10, d4
	add.w   d5, d5
	lea     resObjectsEnd.w, a1
	move.w  #$5f, d6
loc_2071BA:
	tst.b   $1(a1)
	bpl.s   loc_2071C6
	move.b  $20(a1), d0
	bne.s   loc_2071D2
loc_2071C6:
	lea     $40(a1), a1
	dbra    d6, loc_2071BA
loc_2071CE:
	moveq   #$0, d0
	rts     
loc_2071D2:
	andi.w  #$3f, d0
	add.w   d0, d0
	lea     ObjColSizes.l, a2
	lea     -$2(a2, d0.w), a2
	moveq   #$0, d1
	move.b  (a2)+, d1
	move.w  $8(a1), d0
	sub.w   d1, d0
	sub.w   d2, d0
	bcc.s   loc_2071FA
	add.w   d1, d1
	add.w   d1, d0
	bcs.s   loc_207200
	bra.w   loc_2071C6
loc_2071FA:
	cmp.w   d4, d0
	bhi.w   loc_2071C6
loc_207200:
	moveq   #$0, d1
	move.b  (a2)+, d1
	move.w  $c(a1), d0
	sub.w   d1, d0
	sub.w   d3, d0
	bcc.s   loc_207218
	add.w   d1, d1
	add.w   d0, d1
	bcs.s   loc_20721E
	bra.w   loc_2071C6
loc_207218:
	cmp.w   d5, d0
	bhi.w   loc_2071C6
loc_20721E:
	move.b  $20(a1), d1
	andi.b  #$c0, d1
	beq.w   Player_TouchEnemy
	cmpi.b  #$c0, d1
	beq.w   Player_TouchSpecial
	tst.b   d1
	bmi.w   Player_TouchHazard
	move.b  $20(a1), d0
	andi.b  #$3f, d0
	cmpi.b  #$6, d0
	beq.s   Player_TouchMonitor
	cmpi.w  #$5a, $30(a0)
	bcc.w   loc_207254
	addq.b  #$2, $24(a1)
loc_207254:
	rts     
Player_TouchMonitor:
	tst.w   oYVel(a0)
	bpl.s   loc_207280
	move.w  oY(a0), d0
	subi.w  #$10, d0
	cmp.w   $c(a1), d0
	bcs.s   loc_207290
	neg.w   oYVel(a0)
	move.w  #$fe80, $12(a1)
	tst.b   $25(a1)
	bne.s   loc_207290
	addq.b  #$4, $25(a1)
	rts     
loc_207280:
	cmpi.b  #$2, oAnim(a0)
	bne.s   loc_207290
	neg.w   oYVel(a0)
	addq.b  #$2, $24(a1)
loc_207290:
	rts     
Player_TouchEnemy:
	tst.b   timeWarp.l
	bne.s   loc_2072AC
	tst.b   invincible.l
	bne.s   loc_2072AC
	cmpi.b  #$2, oAnim(a0)
	bne.w   Player_TouchHazard
loc_2072AC:
	tst.b   $21(a1)
	beq.s   loc_2072D6
	neg.w   oXVel(a0)
	neg.w   oYVel(a0)
	asr.w   oXVel(a0)
	asr.w   oYVel(a0)
	move.b  #$0, $20(a1)
	subq.b  #$1, $21(a1)
	bne.s   loc_2072D4
	bset.b  #$7, $22(a1)
loc_2072D4:
	rts     
loc_2072D6:
	bset.b  #$7, $22(a1)
	moveq   #$0, d0
	move.w  scoreChain.w, d0
	addq.w  #$2, scoreChain.w
	cmpi.w  #$6, d0
	bcs.s   loc_2072EE
	moveq   #$6, d0
loc_2072EE:
	move.w  d0, $3e(a1)
	move.w  EnemyPoints(pc, d0.w), d0
	cmpi.w  #$20, scoreChain.w
	bcs.s   loc_207308
	move.w  #$3e8, d0
	move.w  #$a, $3e(a1)
loc_207308:
	bsr.w   AddPoints
	move.w  #$96, d0
	jsr     PlayFMSound.l
	dc.b	$13,$7C,$00,$18,$00,$00		; move.b #$18, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.b  #$0, $24(a1)
	move.b  #$1, $28(a1)
	tst.w   oYVel(a0)
	bmi.s   loc_20733E
	move.w  oY(a0), d0
	cmp.w   $c(a1), d0
	bcc.s   loc_207346
	neg.w   oYVel(a0)
	rts     
loc_20733E:
	addi.w  #$100, oYVel(a0)
	rts     
loc_207346:
	subi.w  #$100, oYVel(a0)
	rts     
EnemyPoints:
	dc.w	$000A,$0014,$0032,$0064,$08E9,$0007,$0022
Player_TouchHazard:
	tst.b   timeWarp.l
	bne.s   loc_20736C
	tst.b   invincible.l
	beq.s   loc_207370
loc_20736C:
	moveq   #$ff, d0
	rts     
loc_207370:
	nop     
	tst.w   $30(a0)
	bne.s   loc_20736C
	movea.l a1, a2
HurtPlayer:
	tst.b   shield.l
	bne.s   loc_2073A6
	tst.w   rings.l
	beq.w   loc_207410
	jsr     FindObjSlot.l
	bne.s   loc_2073A6
	dc.b	$13,$7C,$00,$11,$00,$00		; move.b #$11, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
loc_2073A6:
	clr.b   $2a(a0)
	bclr.b  #$0, shield.l
	bne.s   loc_2073BC
	move.b  #$0, combineRing.l
loc_2073BC:
	move.b  #$4, oRoutine(a0)
	bsr.w   Player_ResetOnFloor
	bset.b  #$1, oFlags(a0)
	move.w  #$fc00, oYVel(a0)
	move.w  #$fe00, oXVel(a0)
	btst.b  #$6, oFlags(a0)
	beq.s   loc_2073EC
	move.w  #$fe00, oYVel(a0)
	move.w  #$ff00, oXVel(a0)
loc_2073EC:
	move.w  oX(a0), d0
	cmp.w   $8(a2), d0
	bcs.s   loc_2073FA
	neg.w   oXVel(a0)
loc_2073FA:
	move.w  #$0, $14(a0)
	move.b  #$1a, oAnim(a0)
	move.w  #$78, $30(a0)
	moveq   #$ff, d0
	rts     
loc_207410:
	tst.w   debugCheat.l
	bne.w   loc_2073A6
KillPlayer:
	tst.w   debugMode.l
	bne.s   loc_20746E
	move.b  #$0, invincible.l
	move.b  #$6, oRoutine(a0)
	bsr.w   Player_ResetOnFloor
	bset.b  #$1, oFlags(a0)
	move.w  #$f900, oYVel(a0)
	move.w  #$0, oXVel(a0)
	move.w  #$0, $14(a0)
	move.w  oY(a0), $38(a0)
	move.b  #$18, oAnim(a0)
	bset.b  #$7, oTile(a0)
	move.b  #$0, oPriority(a0)
	move.w  #$93, d0
	jsr     PlayFMSound.l
loc_20746E:
	moveq   #$ff, d0
	rts     
Player_TouchSpecial:
	move.b  $20(a1), d1
	andi.b  #$3f, d1
	cmpi.b  #$17, d1
	beq.w   loc_207502
	cmpi.b  #$1f, d1
	beq.w   loc_207502
	cmpi.b  #$23, d1
	beq.w   loc_207502
	cmpi.b  #$27, d1
	beq.w   loc_207502
	cmpi.b  #$3a, d1
	beq.w   loc_20754A
	cmpi.b  #$3b, d1
	beq.w   loc_20754A
	tst.b   bossFight.w
	beq.w   loc_207500
	cmpi.b  #$1, bossFight.w
	beq.s   loc_2074CA
	cmpi.b  #$4, bossFight.w
	beq.s   loc_2074EC
	cmpi.b  #$5, bossFight.w
	beq.s   loc_2074FA
loc_2074CA:
	cmpi.b  #$3c, d1
	blt.s   loc_207500
	cmpi.b  #$3f, d1
	bgt.s   loc_207500
	bsr.w   Player_TouchEnemy
	tst.b   $20(a1)
	bne.s   loc_2074E4
	addq.b  #$3, $21(a1)
loc_2074E4:
	clr.b   $20(a1)
	bra.w   loc_207502
loc_2074EC:
	cmpi.b  #$3f, d1
	beq.s   loc_20750E
	cmpi.b  #$3e, d1
	beq.s   loc_207508
	bra.s   loc_207500
loc_2074FA:
	cmpi.b  #$3d, d1
	beq.s   loc_207508
loc_207500:
	rts     
loc_207502:
	addq.b  #$1, $21(a1)
	rts     
loc_207508:
	bsr.w   Player_TouchHazard
	bra.s   loc_207502
loc_20750E:
	move.b  oFlags(a0), d0
	andi.b  #$14, d0
	beq.s   loc_207548
	bclr.b  #$2, oFlags(a0)
	bclr.b  #$4, oFlags(a0)
	clr.b   $20(a1)
	move.b  #$15, oAnim(a0)
	move.w  #$400, oYVel(a0)
	move.w  #$fe00, oXVel(a0)
	move.w  oX(a0), d0
	cmp.w   $8(a1), d0
	bcs.s   loc_207548
	neg.w   oXVel(a0)
loc_207548:
	rts     
loc_20754A:
	cmpi.b  #$2, oAnim(a0)
	bne.s   loc_207556
	addq.b  #$1, $21(a1)
loc_207556:
	rts     
ObjColSizes:
	dc.w	$1414,$100C,$0C10,$0410,$0C12,$1010,$0606,$180C
	dc.w	$0C10,$100C,$0808,$1410,$1408,$0E0E,$1818,$2810
	dc.w	$1018,$0810,$2070,$4020,$8020,$2020,$0808,$0404
	dc.w	$2008,$0C0C,$0804,$1804,$2804,$0408,$0418,$0428
	dc.w	$0420,$1818,$0C18,$4808,$080C,$1008,$2010,$2010
	dc.w	$0808,$1010,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$2824,$1211,$0000,$0000,$3010,$4010,$1038
	dc.w	$F604,$0200,$000F,$660C,$23FC,$0000,$4000,$0020
	dc.w	$7766,$6020,$06B9,$0000,$2000,$0020,$7766,$0CB9
	dc.w	$0008,$0000,$0020,$7766,$630A,$23FC,$0008,$0000
	dc.w	$0020,$7766,$2039,$0020,$7766,$0838,$0000,$F604
	dc.w	$6704,$91A8,$000C,$0838,$0001,$F604,$6704,$D1A8
	dc.w	$000C,$0838,$0002,$F604,$6704,$91A8,$0008,$0838
	dc.w	$0003,$F604,$6704,$D1A8,$0008,$3428,$000C,$1028
	dc.w	$0016,$4880,$D440,$3628,$0008,$4EB9,$0020,$0EF0
	dc.w	$33D1,$00FF,$194E,$45F9,$0020,$776A,$0838,$0006
	dc.w	$F605,$6718,$7200,$1239,$00FF,$1904,$5201,$B212
	dc.w	$6504,$123C,$0000,$13C1,$00FF,$1904,$0838,$0007
	dc.w	$F605,$6718,$7200,$1239,$00FF,$1904,$5301,$0C01
	dc.w	$00FF,$6602,$D212,$13C1,$00FF,$1904,$7200,$1239
	dc.w	$00FF,$1904,$C2FC,$000C,$2172,$1004,$0004,$3172
	dc.w	$1008,$0002,$1172,$1003,$0018,$1172,$100D,$001A
	dc.w	$13F2,$100C,$00FF,$1954,$1032,$100B,$0000,$0004
	dc.w	$1140,$0001,$117C,$0000,$001C,$0838,$0005,$F605
	dc.w	$6746,$6100,$041E,$6640,$7200,$1239,$00FF,$1904
	dc.w	$C2FC,$000C,$1372,$1002,$0000,$1372,$100A,$0028
	dc.w	$1372,$100C,$0029,$1372,$100D,$001A,$3368,$0008
	dc.w	$0008,$3368,$000C,$000C,$1028,$0001,$0200,$0003
	dc.w	$1340,$0001,$1340,$0022,$0838,$0004,$F605,$6728
	dc.w	$13FC,$0000,$00FF,$1906,$217C,$0022,$DF20,$0004
	dc.w	$317C,$0780,$0002,$117C,$0002,$0018,$117C,$0000
	dc.w	$001A,$117C,$0004,$0001,$4EF9,$0020,$3A6E,$0000
	dc.w	$4000,$0700,$0A01,$0020,$9698,$0520,$0000,$0000
	dc.w	$0A01,$0020,$9698,$0520,$0002,$0000,$0A01,$0020
	dc.w	$969E,$0520,$0400,$0000,$0A01,$0020,$969E,$0520
	dc.w	$0401,$0000,$3503,$0023,$A4C8,$0544,$0000,$0001
	dc.w	$3503,$0023,$A4C8,$0544,$0100,$0002,$3101,$0023
	dc.w	$BC54,$03FE,$0000,$0006,$3101,$0023,$BC54,$03FE
	dc.w	$0000,$0007,$3701,$0020,$EB54,$033E,$0000,$0000
	dc.w	$3903,$0020,$E932,$03DA,$0000,$0000,$3903,$0020
	dc.w	$E946,$03DA,$0100,$0003,$2D01,$0020,$B500,$2421
	dc.w	$0000,$0000,$2D01,$0020,$B4BE,$2421,$FF00,$0000
	dc.w	$2E01,$0020,$BBD0,$246A,$0000,$0000,$2E01,$0020
	dc.w	$BB5E,$246A,$FF00,$0000,$2401,$0023,$58CA,$23F2
	dc.w	$0000,$0000,$2401,$0023,$5A7A,$23F2,$FF00,$0000
	dc.w	$2001,$0020,$C184,$031E,$0000,$0000,$2101,$0020
	dc.w	$C2DA,$433E,$0200,$0000,$2201,$0020,$C442,$034E
	dc.w	$0100,$0000,$2301,$0020,$C7B0,$035E,$0500,$0000
	dc.w	$2601,$0020,$C8D4,$036E,$0000,$0000,$2701,$0020
	dc.w	$CC96,$0376,$0000,$0000,$2801,$0020,$CF3C,$038E
	dc.w	$0000,$0000,$2B01,$0020,$B5DC,$03AF,$0000,$0000
	dc.w	$2F01,$0020,$B926,$03BD,$0000,$0000,$2A01,$0020
	dc.w	$B27A,$435E,$0000,$0000,$2C01,$0020,$BEFC,$03BD
	dc.w	$0000,$0000,$1D01,$0020,$B0B8,$04CE,$0000,$0000
	dc.w	$1E01,$0020,$B0F8,$049D,$0000,$0000,$1E01,$0020
	dc.w	$B0F8,$049D,$0001,$0000,$0A01,$0020,$9698,$0520
	dc.w	$0000,$0000,$1904,$0020,$A546,$05A8,$0000,$0000
ResetSavedObjFlags:
	lea     savedObjFlags.l, a2
	move.w  #$101, (a2)+
	move.w  #$be, d0
loc_207906:
	clr.l   (a2)+
	dbra    d0, loc_207906
	rts     
SpawnObjects:
	moveq   #$0, d0
	move.b  objSpawnRoutine.w, d0
	move.w  dat_20791C(pc, d0.w), d0
	jmp     dat_20791C(pc, d0.w)
dat_20791C:
	dc.w	SpawnObjects_Init-dat_20791C
	dc.w	SpawnObjects_Main-dat_20791C
SpawnObjects_Init:
	addq.b  #$2, objSpawnRoutine.w
	lea     ObjectLayouts.l, a0
	movea.l a0, a1
	adda.w  (a0), a0
	move.l  a0, objChunkRight.w
	move.l  a0, objChunkLeft.w
	adda.w  $2(a1), a1
	move.l  a1, objChunkNullR.w
	move.l  a1, objChunkNullL.w
	lea     savedObjFlags.l, a2
	move.w  #$101, (a2)
	moveq   #$0, d2
	move.w  cameraX.w, d6
	subi.w  #$80, d6
	bcc.s   loc_20795A
	moveq   #$0, d6
loc_20795A:
	andi.w  #$ff80, d6
	movea.l objChunkRight.w, a0
loc_207962:
	cmp.w   (a0), d6
	bls.s   loc_207974
	tst.b   oMap(a0)
	bpl.s   loc_207970
	move.b  (a2), d2
	addq.b  #$1, (a2)
loc_207970:
	addq.w  #$8, a0
	bra.s   loc_207962
loc_207974:
	move.l  a0, objChunkRight.w
	movea.l objChunkLeft.w, a0
	subi.w  #$80, d6
	bcs.s   loc_207994
loc_207982:
	cmp.w   (a0), d6
	bls.s   loc_207994
	tst.b   oMap(a0)
	bpl.s   loc_207990
	addq.b  #$1, $1(a2)
loc_207990:
	addq.w  #$8, a0
	bra.s   loc_207982
loc_207994:
	move.l  a0, objChunkLeft.w
	move.w  #$ffff, objPrevChunk.w
SpawnObjects_Main:
	lea     savedObjFlags.l, a2
	moveq   #$0, d2
	move.w  cameraX.w, d6
	andi.w  #$ff80, d6
	cmp.w   objPrevChunk.w, d6
	beq.w   SpawnObjects_End
	bge.s   SpawnObjects_Forward
	nop     
	nop     
	nop     
	nop     
	move.w  d6, objPrevChunk.w
	movea.l objChunkLeft.w, a0
	subi.w  #$80, d6
	bcs.s   loc_207A00
loc_2079CE:
	cmp.w   -$8(a0), d6
	bge.s   loc_207A00
	subq.w  #$8, a0
	tst.b   oMap(a0)
	bpl.s   loc_2079E4
	subq.b  #$1, $1(a2)
	move.b  $1(a2), d2
loc_2079E4:
	bsr.w   SpawnObject
	bne.s   loc_2079EE
	subq.w  #$8, a0
	bra.s   loc_2079CE
loc_2079EE:
	tst.b   oMap(a0)
	bpl.s   loc_2079FE
	addq.b  #$1, $1(a2)
	bclr.b  #$7, $2(a2, d3.w)
loc_2079FE:
	addq.w  #$8, a0
loc_207A00:
	move.l  a0, objChunkLeft.w
	movea.l objChunkRight.w, a0
	addi.w  #$300, d6
loc_207A0C:
	cmp.w   -$8(a0), d6
	bgt.s   loc_207A1E
	tst.b   -$4(a0)
	bpl.s   loc_207A1A
	subq.b  #$1, (a2)
loc_207A1A:
	subq.w  #$8, a0
	bra.s   loc_207A0C
loc_207A1E:
	move.l  a0, objChunkRight.w
	rts     
SpawnObjects_Forward:
	nop     
	nop     
	nop     
	nop     
	move.w  d6, objPrevChunk.w
	movea.l objChunkRight.w, a0
	addi.w  #$280, d6
loc_207A38:
	cmp.w   (a0), d6
	bls.s   loc_207A5A
	tst.b   oMap(a0)
	bpl.s   loc_207A46
	move.b  (a2), d2
	addq.b  #$1, (a2)
loc_207A46:
	bsr.w   SpawnObject
	beq.s   loc_207A38
	tst.b   oMap(a0)
	bpl.s   loc_207A5A
	subq.b  #$1, (a2)
	bclr.b  #$7, $2(a2, d3.w)
loc_207A5A:
	move.l  a0, objChunkRight.w
	movea.l objChunkLeft.w, a0
	subi.w  #$300, d6
	bcs.s   loc_207A7A
loc_207A68:
	cmp.w   (a0), d6
	bls.s   loc_207A7A
	tst.b   oMap(a0)
	bpl.s   loc_207A76
	addq.b  #$1, $1(a2)
loc_207A76:
	addq.w  #$8, a0
	bra.s   loc_207A68
loc_207A7A:
	move.l  a0, objChunkLeft.w
SpawnObjects_End:
	rts     
CheckObjTimeZone:
	moveq   #$0, d0
	move.b  timeZone.l, d0
	bclr.l  #$7, d0
	move.w  d2, d3
	add.w   d3, d3
	add.w   d2, d3
	add.w   d0, d3
	move.b  oeTimeZones(a0), d1
	rol.b   #$3, d1
	andi.b  #$7, d1
	btst.l  d0, d1
	rts     
SpawnObject:
	bsr.s   CheckObjTimeZone
	beq.s   loc_207AB4
	tst.b   oMap(a0)
	bpl.s   loc_207ABA
	bset.b  #$7, $2(a2, d3.w)
	beq.s   loc_207ABA
loc_207AB4:
	addq.w  #$8, a0
	moveq   #$0, d0
	rts     
loc_207ABA:
	bsr.w   FindObjSlot
	bne.s   loc_207B08
	move.w  (a0)+, $8(a1)
	move.w  (a0)+, d0
	move.w  d0, d1
	andi.w  #$fff, d0
	move.w  d0, $c(a1)
	rol.w   #$2, d1
	andi.b  #$3, d1
	move.b  d1, $1(a1)
	move.b  d1, $22(a1)
	move.b  (a0)+, d0
	bpl.s   loc_207AEA
	andi.b  #$7f, d0
	move.b  d2, $23(a1)
loc_207AEA:
	dc.b	$13,$40,$00,$00		; move.b d0, $0(a1) (raw: not reproducible by assembler / suspicious)
	cmpi.b  #$31, d0
	bne.s   loc_207AFC
	nop     
	nop     
	nop     
	nop     
loc_207AFC:
	move.b  (a0)+, $28(a1)
	move.b  (a0)+, d0
	move.b  (a0)+, $29(a1)
	moveq   #$0, d0
loc_207B08:
	rts     
FindObjSlot:
	lea     resObjectsEnd.w, a1
	move.w  #$5f, d0
loc_207B12:
	tst.b   (a1)
	beq.s   loc_207B1E
	lea     $40(a1), a1
	dbra    d0, loc_207B12
loc_207B1E:
	rts     
FindNextObjSlot:
	movea.l a0, a1
	lea     $40(a1), a1
	move.w  #$f000, d0
	sub.w   a0, d0
	lsr.w   #$6, d0
	subq.w  #$2, d0
	bcs.s   loc_207B3E
loc_207B32:
	tst.b   (a1)
	beq.s   loc_207B3E
	lea     $40(a1), a1
	dbra    d0, loc_207B32
loc_207B3E:
	rts     
CheckObjDespawn:
	move.w  oX(a0), d0
CheckObjDespawn2:
	tst.b   oSprFlags(a0)
	bmi.s   DespawnObjTimeWarp
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bls.s   DespawnObjTimeWarp
DespawnObject:
	moveq   #$0, d0
	move.b  oSavedFlagsID(a0), d0
	beq.s   loc_207BA4
	lea     savedObjFlags.l, a1
	move.w  d0, d1
	add.w   d1, d1
	add.w   d1, d0
	moveq   #$0, d1
	move.b  timeZone.l, d1
	bclr.l  #$7, d1
	beq.s   loc_207B9C
	move.b  timeWarpDir.w, d2
	ext.w   d2
	neg.w   d2
	add.w   d2, d1
	bpl.s   loc_207B94
	moveq   #$0, d1
	bra.s   loc_207B9C
loc_207B94:
	cmpi.w  #$3, d1
	bcs.s   loc_207B9C
	moveq   #$2, d1
loc_207B9C:
	add.w   d1, d0
	bclr.b  #$7, $2(a1, d0.w)
loc_207BA4:
	jsr     DeleteObject.l
	moveq   #$1, d0
	rts     
DespawnObjTimeWarp:
	btst.b  #$7, timeZone.l
	bne.s   DespawnObject
	moveq   #$0, d0
	rts     
ObjectLayouts:
	incbin	"Level/Collision Chaos/Data/Objects (Act 1).bin"
GetOffObject:
	btst.b  #$3, oFlags(a0)
	beq.s   loc_208C6E
	btst.b  #$3, $22(a1)
	beq.s   loc_208C6E
	moveq   #$0, d0
	move.b  $3d(a1), d0
	lsl.w   #$6, d0
	addi.l  #$ffd000, d0
	cmpa.w  d0, a0
	bne.s   loc_208C6E
	tst.b   $2a(a1)
	beq.s   loc_208C30
	move.w  #$ab, d0
	jsr     PlayFMSound.l
loc_208C30:
	clr.b   $38(a1)
	bset.b  #$1, $22(a1)
	bclr.b  #$3, $22(a1)
	bclr.b  #$3, oFlags(a0)
	btst.b  #$6, $2c(a1)
	bne.s   loc_208C5C
	cmpi.b  #$17, $1c(a1)
	beq.s   loc_208C5C
	bclr.b  #$0, $2c(a1)
loc_208C5C:
	clr.b   $3d(a1)
	cmpi.b  #$2b, $1c(a1)
	bne.s   loc_208C6E
	bclr.b  #$1, $22(a1)
loc_208C6E:
	rts     
StandOnObject:
	cmpi.b  #$4, $24(a1)
	bne.s   loc_208C82
	subq.b  #$2, $24(a1)
	move.w  #$78, $30(a1)
loc_208C82:
	clr.b   oSolidType(a0)
	clr.b   $3c(a1)
	bset.b  #$3, oFlags(a0)
	bne.s   loc_208CE2
	cmpi.b  #$2b, $1c(a1)
	bne.s   loc_208CA4
	bclr.b  #$3, oFlags(a0)
	bra.w   GetOffObject
loc_208CA4:
	bclr.b  #$4, $22(a1)
	bclr.b  #$2, $22(a1)
	beq.s   loc_208CE2
	tst.b   miniSonic.l
	beq.s   loc_208CCC
	move.b  #$a, $16(a1)
	move.b  #$5, $17(a1)
	subq.w  #$2, $c(a1)
	bra.s   loc_208CDC
loc_208CCC:
	move.b  #$13, $16(a1)
	move.b  #$9, $17(a1)
	subq.w  #$5, $c(a1)
loc_208CDC:
	move.b  #$0, $1c(a1)
loc_208CE2:
	bset.b  #$3, $22(a1)
	beq.s   loc_208D04
	moveq   #$0, d0
	move.b  $3d(a1), d0
	lsl.w   #$6, d0
	addi.l  #$ffd000, d0
	cmpa.w  d0, a0
	beq.s   loc_208D3C
	movea.l d0, a2
	bclr.b  #$3, $22(a2)
loc_208D04:
	move.w  a0, d0
	subi.w  #$d000, d0
	lsr.w   #$6, d0
	andi.w  #$7f, d0
	move.b  d0, $3d(a1)
	move.b  #$0, $26(a1)
	move.w  #$0, $12(a1)
	cmpi.b  #$a, oID(a0)
	bne.s   loc_208D30
	cmpi.b  #$2, oRoutine(a0)
	beq.s   loc_208D36
loc_208D30:
	move.w  $10(a1), $14(a1)
loc_208D36:
	bclr.b  #$1, $22(a1)
loc_208D3C:
	rts     
BtmSolidObject:
	move.b  #$2, oSolidType(a0)
	bra.s   SolidObject
TopSolidObject:
	move.b  #$1, oSolidType(a0)
SolidObject:
	cmpi.b  #$17, $1c(a1)
	beq.w   loc_209000
	btst.b  #$6, $2c(a1)
	bne.w   loc_209000
	cmpi.b  #$6, $24(a1)
	bcc.w   loc_209000
	dc.b	$4A,$29,$00,$00		; tst.b $0(a1) (raw: not reproducible by assembler / suspicious)
	beq.w   loc_209000
	tst.b   oSprFlags(a0)
	bpl.w   loc_209000
	tst.b   debugMode.l
	bne.w   loc_209000
	move.b  oWidth(a0), d1
	ext.w   d1
	addi.w  #$a, d1
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	add.w   d1, d0
	bmi.w   loc_209000
	move.w  d1, d2
	add.w   d2, d2
	cmp.w   d2, d0
	bcc.w   loc_209000
	cmpi.b  #$2b, $1c(a1)
	bne.s   loc_208DBA
	btst.b  #$3, oFlags(a0)
	bne.s   loc_208DCC
	bra.w   loc_209000
loc_208DBA:
	cmpi.b  #$1, oSolidType(a0)
	bne.s   loc_208DCC
	tst.w   $12(a1)
	beq.s   loc_208DCC
	bmi.w   loc_209000
loc_208DCC:
	move.b  oYRadius(a0), d2
	ext.w   d2
	move.b  $16(a1), d3
	ext.w   d3
	add.w   d2, d3
	addq.w  #$2, d3
	move.w  $c(a1), d2
	sub.w   oY(a0), d2
	add.w   d3, d2
	bmi.w   loc_209000
	move.w  d3, d4
	add.w   d4, d4
	cmp.w   d4, d2
	bcc.w   loc_209000
	move.w  d0, d4
	cmp.w   d0, d1
	bcc.s   loc_208E02
	add.w   d1, d1
	sub.w   d1, d0
	move.w  d0, d4
	neg.w   d4
loc_208E02:
	move.w  d2, d5
	cmp.w   d2, d3
	bcc.s   loc_208E10
	add.w   d3, d3
	sub.w   d3, d2
	move.w  d2, d5
	neg.w   d5
loc_208E10:
	cmp.w   d4, d5
	bcs.w   loc_208EA4
	cmpi.b  #$1, oSolidType(a0)
	beq.w   loc_209000
	cmpi.b  #$a, oID(a0)
	bne.s   loc_208E32
	btst.b  #$1, $22(a1)
	bne.w   loc_209000
loc_208E32:
	cmpi.b  #$4, d5
	bls.w   loc_209000
	bsr.w   PushObject
	move.l  d0, -(a7)
	bsr.w   GetOffObject
	clr.b   oSolidType(a0)
	move.l  (a7)+, d0
	sub.w   d0, $8(a1)
	tst.w   d0
	bmi.s   loc_208E5C
	tst.w   $10(a1)
	beq.s   loc_208E8C
	bpl.s   loc_208E64
	bra.s   loc_208E8C
loc_208E5C:
	tst.w   $10(a1)
	beq.s   loc_208E8C
	bpl.s   loc_208E8C
loc_208E64:
	bsr.w   CheckWallCrush
	btst.b  #$1, $22(a1)
	bne.s   loc_208E82
	bset.b  #$5, $22(a1)
	bset.b  #$5, oFlags(a0)
	move.w  #$0, $14(a1)
loc_208E82:
	move.w  #$0, $10(a1)
	moveq   #$0, d0
	rts     
loc_208E8C:
	bsr.w   StopObjPush
	bsr.w   CheckWallCrush
	bclr.b  #$5, $22(a1)
	bclr.b  #$5, oFlags(a0)
	moveq   #$0, d0
	rts     
loc_208EA4:
	cmpi.b  #$19, oID(a0)
	bne.s   loc_208EB6
	btst.b  #$2, $22(a1)
	bne.w   loc_209000
loc_208EB6:
	move.b  oYRadius(a0), d0
	ext.w   d0
	move.b  $16(a1), d1
	ext.w   d1
	add.w   d0, d1
	tst.w   d2
	beq.s   loc_208ECC
	bmi.w   loc_208F9C
loc_208ECC:
	cmpi.b  #$2b, $1c(a1)
	beq.s   loc_208EDE
	tst.w   $12(a1)
	beq.s   loc_208EDE
	bmi.w   loc_209000
loc_208EDE:
	move.w  oY(a0), $c(a1)
	sub.w   d1, $c(a1)
	moveq   #$0, d1
	move.w  oXVel(a0), d1
	ext.l   d1
	asl.l   #$8, d1
	move.l  $8(a1), d0
	add.l   d1, d0
	move.l  d0, $8(a1)
	move.b  #$c0, d0
	tst.w   oXVel(a0)
	beq.s   loc_208F2A
	bpl.s   loc_208F0A
	neg.b   d0
loc_208F0A:
	movem.l a0-a1, -(a7)
	movea.l a1, a0
	jsr     Player_CalcRoomInFront.l
	movem.l (a7)+, a0-a1
	tst.w   d1
	bpl.s   loc_208F2A
	tst.w   oXVel(a0)
	bpl.s   loc_208F26
	neg.w   d1
loc_208F26:
	add.w   d1, $8(a1)
loc_208F2A:
	moveq   #$0, d1
	move.w  oYVel(a0), d1
	ext.l   d1
	asl.l   #$8, d1
	move.l  $c(a1), d0
	add.l   d1, d0
	move.l  d0, $c(a1)
	cmpi.b  #$a, oID(a0)
	beq.s   loc_208F94
	tst.w   oYVel(a0)
	bmi.s   loc_208F68
	movem.l a0-a1, -(a7)
	movea.l a1, a0
	jsr     sub_206E36.l
	movem.l (a7)+, a0-a1
	tst.w   d1
	bpl.s   loc_208F68
	add.w   d1, $c(a1)
	bra.w   loc_209000
loc_208F68:
	tst.w   oYVel(a0)
	bpl.s   loc_208F94
	movem.l a0-a1, -(a7)
	movea.l a1, a0
	jsr     Player_GetCeilDist.l
	movem.l (a7)+, a0-a1
	tst.w   d1
	bpl.s   loc_208F94
	movem.l a0-a1, -(a7)
	movea.l a1, a0
	jsr     KillPlayer.l
	movem.l (a7)+, a0-a1
	bra.s   loc_209000
loc_208F94:
	bsr.w   StandOnObject
	moveq   #$1, d0
	rts     
loc_208F9C:
	cmpi.b  #$1, oSolidType(a0)
	beq.s   loc_209000
	cmpi.b  #$9, oID(a0)
	beq.s   loc_209000
	cmpi.b  #$a, oID(a0)
	bne.s   loc_208FC6
	cmpi.b  #$2, oSolidType(a0)
	beq.s   loc_208FE6
	btst.b  #$1, oSprFlags(a0)
	bne.s   loc_208FE6
	bra.s   loc_209000
loc_208FC6:
	btst.b  #$1, $22(a1)
	bne.s   loc_208FE6
	tst.w   oYVel(a0)
	beq.s   loc_208FE6
	bmi.s   loc_208FE6
	movem.l a0-a1, -(a7)
	movea.l a1, a0
	jsr     KillPlayer.l
	movem.l (a7)+, a0-a1
loc_208FE6:
	sub.w   d2, $c(a1)
	move.w  #$0, $12(a1)
	bsr.w   StopObjPush
	bsr.w   GetOffObject
	clr.b   oSolidType(a0)
	moveq   #$1, d0
	rts     
loc_209000:
	bsr.w   StopObjPush
	bsr.w   GetOffObject
	clr.b   oSolidType(a0)
	moveq   #$0, d0
	rts     
CheckWallCrush:
	tst.w   oXVel(a0)
	beq.s   loc_20904E
	cmpi.b  #$a, oID(a0)
	beq.s   loc_20904E
	move.b  #$c0, d0
	tst.w   oXVel(a0)
	bpl.s   loc_20902A
	neg.b   d0
loc_20902A:
	movem.l a0-a1, -(a7)
	movea.l a1, a0
	jsr     Player_CalcRoomInFront.l
	movem.l (a7)+, a0-a1
	tst.w   d1
	bpl.s   loc_20904E
	movem.l a0-a1, -(a7)
	movea.l a1, a0
	jsr     KillPlayer.l
	movem.l (a7)+, a0-a1
loc_20904E:
	rts     
PushObject:
	cmpi.b  #$a, oID(a0)
	bne.s   loc_209060
	move.b  #$0, $20(a1)
	rts     
loc_209060:
	moveq   #$0, d1
	move.b  $20(a1), d1
	beq.s   loc_2090B4
	lsl.w   #$6, d1
	addi.l  #$ffd000, d1
	cmpa.w  d1, a0
	beq.s   loc_2090C4
	movea.l d1, a2
	tst.w   oXVel(a0)
	bne.s   loc_209082
	tst.w   $10(a2)
	beq.s   loc_2090C4
loc_209082:
	move.w  $8(a1), d1
	cmp.w   oX(a0), d1
	bcc.s   loc_209094
	cmp.w   $8(a2), d1
	bcs.s   loc_2090C4
	bra.s   loc_20909A
loc_209094:
	cmp.w   $8(a2), d1
	bcc.s   loc_2090C4
loc_20909A:
	cmpi.b  #$15, oID(a0)
	beq.s   loc_2090C4
	movem.l d0/a0-a1, -(a7)
	movea.l a1, a0
	jsr     KillPlayer.l
	movem.l (a7)+, d0/a0-a1
	rts     
loc_2090B4:
	move.w  a0, d1
	subi.w  #$d000, d1
	lsr.w   #$6, d1
	andi.w  #$7f, d1
	move.b  d1, $20(a1)
loc_2090C4:
	rts     
StopObjPush:
	moveq   #$0, d1
	move.b  $20(a1), d1
	beq.s   loc_2090E0
	lsl.w   #$6, d1
	addi.l  #$ffd000, d1
	cmpa.w  d1, a0
	bne.s   loc_2090E0
	move.b  #$0, $20(a1)
loc_2090E0:
	rts     
Obj1B_2090E2:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_2090FC(pc, d0.w), d0
	jsr     dat_2090FC(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
dat_2090FC:
	dc.w	ObjBoulder_Init-dat_2090FC
	dc.w	ObjBoulder_Main-dat_2090FC
ObjBoulder_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.l  #$20914c, oMap(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.b  #$0, oMapFrame(a0)
	moveq   #$b, d0
	jsr     SetObjectTileID.l
ObjBoulder_Main:
	tst.b   oSprFlags(a0)
	bpl.s   loc_20914A
	lea     objects.w, a1
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     SolidObject.l
loc_20914A:
	rts     
MapSpr_Boulder:
	dc.w	$0002,$02F8,$0200,$00EC,$F00F,$0003,$F400
ObjMovingSpring:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjMovingSpring_Index(pc, d0.w), d0
	jsr     ObjMovingSpring_Index(pc, d0.w)
	move.w  $36(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.w   DeleteObject
	rts     
ObjMovingSpring_Index:
	dc.w	ObjMovingSpring_Init-ObjMovingSpring_Index
	dc.w	ObjMovingSpring_AlignToGround-ObjMovingSpring_Index
	dc.w	ObjMovingSpring_Main-ObjMovingSpring_Index
ObjMovingSpring_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.l  #$209766, oMap(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$7, oYRadius(a0)
	move.w  oX(a0), $36(a0)
	move.w  #$180, oXVel(a0)
	moveq   #$e, d0
	jsr     SetObjectTileID.l
	jsr     FindObjSlot.l
	beq.s   loc_2091D4
	jmp     DeleteObject.l
loc_2091D4:
	dc.b	$13,$7C,$00,$0A,$00,$00		; move.b #$a, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$10, $c(a1)
	move.b  #$f0, $39(a1)
	move.w  a0, $34(a1)
	move.b  oSubtype(a0), $28(a1)
ObjMovingSpring_AlignToGround:
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   loc_209216
	add.w   d1, oY(a0)
	move.w  oY(a0), $32(a0)
	addq.b  #$2, oRoutine(a0)
	rts     
loc_209216:
	addq.w  #$1, oY(a0)
	rts     
ObjMovingSpring_Main:
	tst.w   timeStopTimer.l
	bne.s   loc_209252
	jsr     ObjGetFloorDist.l
	add.w   d1, oY(a0)
	move.w  $32(a0), d0
	sub.w   oY(a0), d0
	cmpi.w  #$c, d0
	bcs.s   loc_209240
	neg.w   oXVel(a0)
loc_209240:
	jsr     ObjMove.l
	lea     Ani_MovingSpring.l, a1
	jsr     AnimateObject.l
loc_209252:
	jmp     DrawObject.l
ObjSpring2:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjSpring2_Index(pc, d0.w), d0
	jmp     ObjSpring2_Index(pc, d0.w)
ObjSpring2_Index:
	dc.w	ObjSpring2_Init-ObjSpring2_Index
	dc.w	ObjSpring2_Main-ObjSpring2_Index
ObjSpring2_Init:
	move.l  #$209698, oMap(a0)
	move.w  #$8520, oTile(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.b  #$4, oPriority(a0)
	addq.b  #$2, oRoutine(a0)
ObjSpring2_Main:
	move.w  $FFFFD008.w, oX(a0)
	move.w  $FFFFD00C.w, oY(a0)
	jmp     DrawObject.l
ObjSpring:
	cmpi.b  #$5, oSolidType(a0)
	beq.s   ObjSpring2
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	beq.s   loc_2092BC
	tst.b   oSprFlags(a0)
	bpl.s   loc_2092C4
loc_2092BC:
	move.w  ObjSpring_Index(pc, d0.w), d1
	jsr     ObjSpring_Index(pc, d1.w)
loc_2092C4:
	bsr.w   DrawObject
	move.l  #$ffff0000, d1
	move.w  $34(a0), d1
	beq.s   loc_2092F6
	movea.l d1, a1
	move.w  $8(a1), oX(a0)
	move.w  $c(a1), oY(a0)
	move.b  $38(a0), d0
	ext.w   d0
	add.w   d0, oX(a0)
	move.b  $39(a0), d0
	ext.w   d0
	add.w   d0, oY(a0)
loc_2092F6:
	move.w  $36(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.w   DeleteObject
	rts     
ObjSpring_Index:
	dc.w	ObjSpring_Init-ObjSpring_Index
	dc.w	ObjSpring_Main_Up-ObjSpring_Index
	dc.w	ObjSpring_Anim_Up-ObjSpring_Index
	dc.w	ObjSpring_Reset_Up-ObjSpring_Index
	dc.w	ObjSpring_Main_Side-ObjSpring_Index
	dc.w	ObjSpring_Anim_Side-ObjSpring_Index
	dc.w	ObjSpring_Reset_Side-ObjSpring_Index
	dc.w	ObjSpring_Main_Down-ObjSpring_Index
	dc.w	ObjSpring_Anim_Down-ObjSpring_Index
	dc.w	ObjSpring_Reset_Down-ObjSpring_Index
	dc.w	ObjSpring_Main_Diag-ObjSpring_Index
	dc.w	ObjSpring_Anim_Diag-ObjSpring_Index
	dc.w	ObjSpring_Reset_Diag-ObjSpring_Index
ObjSpring_Init:
	addq.b  #$2, oRoutine(a0)
	move.l  #$209698, oMap(a0)
	move.w  #$520, oTile(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.w  oX(a0), $36(a0)
	move.b  #$4, oPriority(a0)
	move.b  oSubtype(a0), d0
	btst.l  #$2, d0
	beq.s   loc_209386
	move.b  #$8, oRoutine(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.l  #$20969e, oMap(a0)
	bra.s   loc_2093C8
loc_209386:
	btst.l  #$3, d0
	beq.s   loc_2093B4
	move.b  #$14, oRoutine(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.l  #$2096e8, oMap(a0)
	move.l  d0, -(a7)
	moveq   #$f, d0
	jsr     SetObjectTileID.l
	move.l  (a7)+, d0
	bra.s   loc_2093C8
loc_2093B4:
	btst.b  #$1, oSprFlags(a0)
	beq.s   loc_2093C8
	move.b  #$e, oRoutine(a0)
	bset.b  #$1, oFlags(a0)
loc_2093C8:
	btst.l  #$1, d0
	beq.s   loc_2093D4
	bset.b  #$5, oTile(a0)
loc_2093D4:
	andi.w  #$2, d0
	move.w  ObjSpring_Speeds(pc, d0.w), $30(a0)
	rts     
ObjSpring_Speeds:
	dc.w	$F000,$F600
ObjSpring_SolidObject:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     SolidObject.l
ObjSpring_Main_Up:
	tst.b   oSprFlags(a0)
	bpl.s   loc_209400
	lea     objects.w, a1
	bsr.s   ObjSpring_SolidObject
	bne.s   loc_209402
loc_209400:
	rts     
loc_209402:
	move.b  #$4, oRoutine(a0)
	addq.w  #$8, $c(a1)
	move.w  $30(a0), $12(a1)
	bset.b  #$1, $22(a1)
	bclr.b  #$3, $22(a1)
	move.b  #$10, $1c(a1)
	bclr.b  #$3, oFlags(a0)
	move.w  #$98, d0
	jmp     PlayFMSound.l
ObjSpring_Anim_Up:
	lea     Ani_Spring.l, a1
	bra.w   AnimateObject
ObjSpring_Reset_Up:
	bclr.b  #$3, oFlags(a0)
	move.b  #$1, oPrevAnim(a0)
	subq.b  #$4, oRoutine(a0)
	move.b  #$0, oMapFrame(a0)
	rts     
ObjSpring_SolidObject2:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     SolidObject.l
ObjSpring_Main_Side:
	tst.b   oSprFlags(a0)
	bpl.s   loc_209478
	lea     objects.w, a1
	bsr.s   ObjSpring_SolidObject2
	btst.b  #$5, oFlags(a0)
	bne.s   loc_20947A
loc_209478:
	rts     
loc_20947A:
	move.b  #$a, oRoutine(a0)
	move.w  $30(a0), $10(a1)
	addq.w  #$8, $8(a1)
	bset.b  #$0, $22(a1)
	btst.b  #$0, oFlags(a0)
	bne.s   loc_2094A8
	subi.w  #$10, $8(a1)
	neg.w   $10(a1)
	bclr.b  #$0, $22(a1)
loc_2094A8:
	move.w  #$f, $3e(a1)
	move.w  $10(a1), $14(a1)
	btst.b  #$2, $22(a1)
	bne.s   loc_2094C2
	move.b  #$0, $1c(a1)
loc_2094C2:
	clr.b   $26(a1)
	bclr.b  #$5, oFlags(a0)
	bclr.b  #$5, $22(a1)
	move.w  #$98, d0
	jmp     PlayFMSound.l
ObjSpring_Anim_Side:
	lea     Ani_Spring.l, a1
	bra.w   AnimateObject
ObjSpring_Reset_Side:
	move.b  #$1, oPrevAnim(a0)
	subq.b  #$4, oRoutine(a0)
	move.b  #$0, oMapFrame(a0)
	rts     
ObjSpring_SolidObject3:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     BtmSolidObject.l
ObjSpring_Main_Down:
	tst.b   oSprFlags(a0)
	bpl.s   loc_209514
	lea     objects.w, a1
	bsr.s   ObjSpring_SolidObject3
	bne.s   loc_209516
loc_209514:
	rts     
loc_209516:
	move.b  #$10, oRoutine(a0)
	subq.w  #$8, $c(a1)
	move.w  $30(a0), $12(a1)
	neg.w   $12(a1)
	bset.b  #$1, $22(a1)
	bclr.b  #$3, $22(a1)
	bclr.b  #$3, oFlags(a0)
	move.w  #$98, d0
	jsr     PlayFMSound.l
ObjSpring_Anim_Down:
	lea     Ani_Spring.l, a1
	bra.w   AnimateObject
ObjSpring_Reset_Down:
	move.b  #$1, oPrevAnim(a0)
	subq.b  #$4, oRoutine(a0)
	move.b  #$0, oMapFrame(a0)
	rts     
ObjSpring_Main_Diag:
	tst.b   oSprFlags(a0)
	bpl.s   loc_20957A
	lea     objects.w, a1
	bsr.w   ObjSpring_SolidObject
	bne.s   loc_20957C
	btst.b  #$5, oFlags(a0)
	bne.s   loc_20957C
loc_20957A:
	rts     
loc_20957C:
	move.b  #$16, oRoutine(a0)
	moveq   #$0, d0
	move.b  #$e0, d0
	jsr     CalcSine.l
	move.w  $30(a0), d2
	neg.w   d2
	mulu.w  d2, d0
	mulu.w  d2, d1
	lsr.l   #$8, d0
	lsr.l   #$8, d1
	move.w  d0, $12(a1)
	move.w  d1, $10(a1)
	addq.w  #$8, $c(a1)
	btst.b  #$1, oSprFlags(a0)
	beq.s   loc_2095BA
	subi.w  #$10, $c(a1)
	neg.w   $12(a1)
loc_2095BA:
	bclr.b  #$0, $22(a1)
	subq.w  #$8, $8(a1)
	btst.b  #$0, oFlags(a0)
	beq.s   loc_2095DC
	addi.w  #$10, $8(a1)
	bset.b  #$0, $22(a1)
	neg.w   $10(a1)
loc_2095DC:
	bset.b  #$1, $22(a1)
	bclr.b  #$3, $22(a1)
	bclr.b  #$5, $22(a1)
	bclr.b  #$3, oFlags(a0)
	bclr.b  #$5, oFlags(a0)
	move.w  #$98, d0
	jsr     PlayFMSound.l
ObjSpring_Anim_Diag:
	lea     Ani_Spring.l, a1
	bra.w   AnimateObject
ObjSpring_Reset_Diag:
	move.b  #$1, oPrevAnim(a0)
	subq.b  #$4, oRoutine(a0)
	move.b  #$0, oMapFrame(a0)
	rts     
	dc.w	$0004,$0010,$0000,$0000,$0202,$0202,$0202,$00FC
	dc.w	$0004,$0303,$0505,$0505,$0505,$03FC,$000C,$0017
	dc.w	$001D,$002D,$0033,$0039,$02F8,$0C00,$00F0,$000C
	dc.w	$0004,$F001,$000C,$0000,$F003,$E80C,$0000,$F0F0
	dc.w	$0500,$08F8,$000C,$000C,$F001,$F007,$0000,$F801
	dc.w	$F003,$0004,$F804,$F003,$0004,$10F8,$0900,$08F8
	dc.w	$F000,$0000,$F808,$0000,$03F8
Ani_Spring:
	dc.w	$0002,$0000,$0101,$0202,$0202,$0202,$01FC
MapSpr_Spring1:
	dc.w	$000C,$0018,$001E
MapSpr_Spring2:
	dc.w	$0028,$0034,$003A,$02F8,$0C00,$00F0,$000C,$0004
	dc.w	$F000,$0100,$0C00,$00F0,$03E0,$0C00,$00F0,$E806
	dc.w	$0008,$F800,$0C00,$0EF0,$02F0,$0300,$1200,$F003
	dc.w	$0016,$F800,$01F0,$0300,$12F8,$03F0,$0300,$1218
	dc.w	$F809,$001A,$00F0,$0300,$20F8
MapSpr_Spring3:
	dc.w	$0006,$002A,$004E,$0708,$0000,$00F0,$0000,$0001
	dc.w	$F008,$0000,$02F8,$F008,$0003,$F0F8,$0000,$06F0
	dc.w	$F809,$0007,$F808,$0400,$0D00,$0708,$0000,$00F0
	dc.w	$0000,$000F,$F008,$0000,$10F8,$F005,$0011,$F0F8
	dc.w	$0000,$0500,$0000,$0015,$F800,$0500,$1600,$0808
	dc.w	$0000,$00F0,$0000,$001A,$F008,$0000,$1BF8,$E008
	dc.w	$0003,$00E8,$0E00,$1C00,$F800,$0028,$F0F0,$0200
	dc.w	$29F8,$0001,$002C,$0000
Ani_MovingSpring:
	dc.w	$0002,$0800,$01FF
MapSpr_MovingSpring:
	dc.w	$0004,$000A,$01F8,$0500,$00F8,$01F8,$0500,$04F8
Obj10_209776:
	dc.w	$7000,$1028,$0024,$323B,$0006,$4EFB,$1002,$002A
	dc.w	$01DE,$0216,$026E,$027C,$1000,$1800,$2000,$0010
	dc.w	$0018,$0020,$1010,$1818,$2020,$F010,$E818,$E020
	dc.w	$1008,$1810,$F008,$E810,$45F9,$00FF,$1200,$7000
	dc.w	$1028,$0023,$3200,$D241,$D041,$7200,$1239,$00FF
	dc.w	$152E,$0881,$0007,$6718,$1438,$F784,$4882,$4442
	dc.w	$D242,$6A04,$7200,$6008,$0C41,$0003,$6502,$7202
	dc.w	$D041,$45F2,$0002,$1812,$1228,$0028,$7000,$1001
	dc.w	$0241,$0007,$0C41,$0007,$6602,$7206,$4841,$323C
	dc.w	$0001,$E808,$D040,$43F9,$0020,$978E,$1A31,$0000
	dc.w	$4885,$1C31,$0001,$4886,$2248,$3428,$0008,$3628
	dc.w	$000C,$47EA,$0001,$7000,$1039,$00FF,$152E,$0880
	dc.w	$0007,$6718,$1438,$F784,$4882,$4442,$D042,$6A04
	dc.w	$7000,$6008,$0C40,$0003,$6502,$7002,$1823,$E22C
	dc.w	$6500,$00C8,$51C8,$FFF6,$0892,$0007,$6044,$4841
	dc.w	$47EA,$0001,$7000,$1039,$00FF,$152E,$0880,$0007
	dc.w	$6718,$1438,$F784,$4882,$4442,$D042,$6A04,$7000
	dc.w	$6008,$0C40,$0003,$6502,$7002,$1823,$E22C,$6500
	dc.w	$008A,$51C8,$FFF6,$0892,$0007,$6100,$E27E,$6600
	dc.w	$0086,$137C,$0010,$0000,$137C,$0002,$0024,$3342
	dc.w	$0008,$3368,$0008,$0032,$3343,$000C,$237C,$0020
	dc.w	$9BF2,$0004,$337C,$A7AE,$0002,$137C,$0002,$0018
	dc.w	$0C39,$0006,$00FF,$1506,$661E,$137C,$0000,$0018
	dc.w	$1368,$0029,$0029,$4A29,$0029,$670C,$0229,$007F
	dc.w	$0002,$137C,$0002,$0018,$137C,$0004,$0001,$137C
	dc.w	$0047,$0020,$137C,$0008,$0019,$137C,$0008,$0016
	dc.w	$1368,$0023,$0023,$1341,$0034,$5241,$D445,$D646
	dc.w	$4841,$51C9,$FF3A,$7000,$1039,$00FF,$152E,$0880
	dc.w	$0007,$6718,$1438,$F784,$4882,$4442,$D042,$6A04
	dc.w	$7000,$6008,$0C40,$0003,$6502,$7002,$47EA,$0001
	dc.w	$0823,$0000,$6600,$A1BE,$51C8,$FFF6,$4A28,$0001
	dc.w	$6B1E,$3028,$0032,$0240,$FF80,$3238,$F700,$0441
	dc.w	$0080,$0241,$FF80,$9041,$0C40,$0280,$6200,$007C
	dc.w	$4A79,$00FF,$190E,$6608,$1179,$00FF,$1913,$001A
	dc.w	$6000,$A0D6
	dc.w	$5428,$0024,$117C,$0000,$0020,$117C,$0001,$0018
	dc.w	$6100,$0058,$45F9,$00FF,$1200,$7000,$1028,$0023
	dc.w	$3200,$D241,$D041,$7200,$1239,$00FF,$152E,$0881
	dc.w	$0007,$6718,$1438,$F784,$4882,$4442,$D242,$6A04
	dc.w	$7200,$6008,$0C41,$0003,$6502,$7202,$D041,$1228
	dc.w	$0034,$5301,$03F2,$0002
	dc.w	$43F9,$0020,$9BEA,$6100,$C27E,$6000,$A070,$6000
	dc.w	$A118
CollectRing:
	addq.w  #$1, rings.l
	ori.b   #$1, updateHUDRings.l
	move.w  #$95, d0
	cmpi.w  #$64, rings.l
	bcs.s   loc_209A54
	bset.b  #$1, livesFlags.l
	beq.s   loc_209A3E
	cmpi.w  #$c8, rings.l
	bcs.s   loc_209A54
	bset.b  #$2, livesFlags.l
	bne.s   loc_209A54
loc_209A3E:
	addq.b  #$1, lives.l
	addq.b  #$1, updateHUDLives.l
	move.w  #$7a, d0
	jmp     SubCPUCmd.l
loc_209A54:
	jmp     PlayFMSound.l
ObjLostRing:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjLostRing_Index(pc, d0.w), d1
	jmp     ObjLostRing_Index(pc, d1.w)
ObjLostRing_Index:
	dc.w	ObjLostRing_Init-ObjLostRing_Index
	dc.w	ObjLostRing_Main-ObjLostRing_Index
	dc.w	ObjLostRing_Collect-ObjLostRing_Index
	dc.w	ObjLostRing_Sparkle-ObjLostRing_Index
	dc.w	ObjLostRing_Destroy-ObjLostRing_Index
ObjLostRing_Init:
	movea.l a0, a1
	moveq   #$0, d5
	move.w  rings.l, d5
	moveq   #$20, d0
	cmp.w   d0, d5
	bcs.s   loc_209A84
	move.w  d0, d5
loc_209A84:
	subq.w  #$1, d5
	move.w  #$288, d4
	bra.s   loc_209A94
loc_209A8C:
	bsr.w   FindObjSlot
	bne.w   loc_209B4A
loc_209A94:
	dc.b	$13,$7C,$00,$11,$00,$00		; move.b #$11, $0(a1) (raw: not reproducible by assembler / suspicious)
	addq.b  #$2, $24(a1)
	move.b  #$8, $16(a1)
	move.b  #$8, $17(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.l  #$209bf2, $4(a1)
	move.b  oLayer(a0), $29(a1)
	move.w  #$a7ae, $2(a1)
	move.b  #$3, $18(a1)
	cmpi.b  #$6, zoneAct.l
	bne.s   loc_209AF2
	move.b  #$0, $18(a1)
	tst.b   oLayer(a0)
	beq.s   loc_209AF2
	move.b  #$3, $18(a1)
	andi.b  #$7f, $2(a1)
loc_209AF2:
	move.b  #$4, $1(a1)
	move.b  #$47, $20(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	move.b  #$ff, ringLossAnimTimer.l
	tst.w   d4
	bmi.s   loc_209B3A
	move.w  d4, d0
	jsr     CalcSine.l
	move.w  d4, d2
	lsr.w   #$8, d2
	asl.w   d2, d0
	asl.w   d2, d1
	move.w  d0, d2
	move.w  d1, d3
	addi.b  #$10, d4
	bcc.s   loc_209B3A
	subi.w  #$80, d4
	bcc.s   loc_209B3A
	move.w  #$288, d4
loc_209B3A:
	move.w  d2, $10(a1)
	move.w  d3, $12(a1)
	neg.w   d2
	neg.w   d4
	dbra    d5, loc_209A8C
loc_209B4A:
	move.w  #$0, rings.l
	move.b  #$80, updateHUDRings.l
	move.b  #$0, livesFlags.l
	move.w  #$94, d0
	jsr     PlayFMSound.l
ObjLostRing_Main:
	move.b  ringLossAnimFrame.l, oMapFrame(a0)
	bsr.w   ObjMove
	addi.w  #$18, oYVel(a0)
	bmi.s   loc_209BAA
	move.b  $ff190d.l, d0
	add.b   d7, d0
	andi.b  #$3, d0
	bne.s   loc_209BAA
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   loc_209BAA
	add.w   d1, oY(a0)
	move.w  oYVel(a0), d0
	asr.w   #$2, d0
	sub.w   d0, oYVel(a0)
	neg.w   oYVel(a0)
loc_209BAA:
	tst.b   ringLossAnimTimer.l
	beq.s   ObjLostRing_Destroy
	move.w  bottomBound.w, d0
	addi.w  #$e0, d0
	cmp.w   oY(a0), d0
	bcs.s   ObjLostRing_Destroy
	bra.w   DrawObject
ObjLostRing_Collect:
	addq.b  #$2, oRoutine(a0)
	move.b  #$0, oColType(a0)
	move.b  #$1, oPriority(a0)
	bsr.w   CollectRing
ObjLostRing_Sparkle:
	lea     Ani_Ring.l, a1
	bsr.w   AnimateObject
	bra.w   DrawObject
ObjLostRing_Destroy:
	bra.w   DeleteObject
Ani_Ring:
	dc.w	$0002,$0504,$0506,$07FC
MapSpr_Ring:
	dc.w	$0012,$0018,$001E,$0024,$002A,$0030,$0036,$003C
	dc.w	$0042,$01F8,$0500,$00F8,$01F8,$0500,$04F8,$01F8
	dc.w	$0100,$08FC,$01F8,$0508,$04F8,$01F8,$0500,$0AF8
	dc.w	$01F8,$0518,$0AF8,$01F8,$0510,$0AF8,$01F8,$0508
	dc.w	$0AF8,$0000,$0008,$003B,$0064,$0079,$0AE0,$0800
	dc.w	$00E8,$E008,$0003,$00E8,$0C00,$06E0,$E80C,$000A
	dc.w	$00F0,$0700,$0EE0,$F007,$0016,$1010,$0C00,$1EE0
	dc.w	$100C,$0022,$0018,$0800,$26E8,$1808,$0029,$0008
	dc.w	$E00C,$002C,$F0E8,$0800,$30E8,$E809,$0033,$00F0
	dc.w	$0700,$39E8,$F805,$0041,$0808,$0900,$4500,$1008
	dc.w	$004B,$E818,$0C00,$4EF0,$04E0,$0700,$52F4,$E003
	dc.w	$0852,$0400,$0700,$5AF4,$0003,$085A,$0408,$E00C
	dc.w	$082C,$F0E8,$0808,$3000,$E809,$0833,$E8F0,$0708
	dc.w	$3908,$F805,$0841,$E808,$0908,$45E8,$1008,$084B
	dc.w	$0018,$0C08,$4EF0,$0010,$001B,$0030,$0045,$005A
	dc.w	$006F,$0084,$008F,$02E0,$0F00,$0000,$000F,$1000
	dc.w	$0004,$E00F,$0010,$F0E0,$0700,$2010,$000F,$1010
	dc.w	$F000,$0710,$2010,$04E0,$0F00,$28E8,$E00B,$0038
	dc.w	$0800,$0F10,$28E8,$000B,$1038,$0804,$E00F,$0834
	dc.w	$E0E0,$0F00,$3400,$000F,$1834,$E000,$0F10,$3400
	dc.w	$04E0,$0B08,$38E0,$E00F,$0828,$F800,$0B18,$38E0
	dc.w	$000F,$1828,$F804,$E007,$0820,$E0E0,$0F08,$10F0
	dc.w	$0007,$1820,$E000,$0F18,$10F0,$02E0,$0F08,$00E0
	dc.w	$000F,$1800,$E004,$E00F,$0044,$E0E0,$0F08,$4400
	dc.w	$000F,$1044,$E000,$0F18,$4400
ObjFloatBlock:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_209DAA(pc, d0.w), d0
	jsr     dat_209DAA(pc, d0.w)
	move.w  oX(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.w   DeleteObject
	rts     
dat_209DAA:
	dc.w	ObjFloatBlock_Init-dat_209DAA
	dc.w	ObjFloatBlock_Main-dat_209DAA
	dc.w	ObjFloatBlock_Fall-dat_209DAA
	dc.w	ObjFloatBlock_Appear-dat_209DAA
	dc.w	ObjFloatBlock_Visible-dat_209DAA
	dc.w	ObjFloatBlock_Vanish-dat_209DAA
	dc.w	ObjFloatBlock_Reset-dat_209DAA
ObjFloatBlock_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.l  #$209ef2, oMap(a0)
	moveq   #$5, d0
	jsr     SetObjectTileID.l
	move.b  #$1, oPriority(a0)
	move.b  #$c, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.b  #$5, oMapFrame(a0)
ObjFloatBlock_Main:
	bsr.w   ObjFloatBlock_TopSolid
	tst.b   timeZone.l
	beq.s   loc_209E24
	cmpi.b  #$2, timeZone.l
	bne.s   loc_209E0A
	btst.b  #$3, oFlags(a0)
	bne.s   loc_209E2A
	bra.s   loc_209E24
loc_209E0A:
	move.b  #$0, oMapFrame(a0)
	btst.b  #$3, oFlags(a0)
	beq.s   loc_209E24
	move.b  #$6, oRoutine(a0)
	move.b  #$1, oAnim(a0)
loc_209E24:
	jmp     DrawObject.l
loc_209E2A:
	addq.b  #$2, oRoutine(a0)
ObjFloatBlock_Fall:
	bsr.w   ObjFloatBlock_TopSolid
	addq.w  #$2, oY(a0)
	move.w  cameraY.w, d0
	addi.w  #$e0, d0
	cmp.w   oY(a0), d0
	bcc.s   loc_209E4A
	jmp     DeleteObject.l
loc_209E4A:
	jmp     DrawObject.l
ObjFloatBlock_Appear:
	bsr.w   ObjFloatBlock_TopSolid
	btst.b  #$3, oFlags(a0)
	bne.s   loc_209E64
	move.b  #$2, oRoutine(a0)
	rts     
loc_209E64:
	lea     Ani_FloatBlock.l, a1
	bsr.w   AnimateObject
	jmp     DrawObject.l
ObjFloatBlock_Visible:
	move.b  #$0, oAnim(a0)
	bsr.w   ObjFloatBlock_TopSolid
	btst.b  #$3, oFlags(a0)
	bne.s   loc_209E92
	addq.b  #$2, oRoutine(a0)
	move.b  #$2, oAnim(a0)
	rts     
loc_209E92:
	lea     Ani_FloatBlock.l, a1
	bsr.w   AnimateObject
	jmp     DrawObject.l
ObjFloatBlock_Vanish:
	bsr.w   ObjFloatBlock_TopSolid
	lea     Ani_FloatBlock.l, a1
	bsr.w   AnimateObject
	jmp     DrawObject.l
ObjFloatBlock_Reset:
	move.b  #$2, oRoutine(a0)
	rts     
ObjFloatBlock_TopSolid:
	lea     objects.w, a1
	bsr.w   sub_209EC6
sub_209EC6:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     TopSolidObject.l
Ani_FloatBlock:
	dc.w	$0006,$000A,$0014,$0205,$FF00,$0201,$0502,$0503
	dc.w	$0504,$05FC,$0201,$0002,$0003,$0004,$00FC
MapSpr_FloatBlock:
	dc.w	$000C,$000E,$001E,$002E,$003A,$0046,$0000,$03F4
	dc.w	$0900,$00F4,$0400,$0000,$FC04,$0000,$0004,$03F4
	dc.w	$0908,$00F4,$0400,$0800,$F404,$0008,$00FC,$02F4
	dc.w	$0918,$00F4,$0400,$1800,$FC00,$02F4,$0910,$00F4
	dc.w	$0400,$1000,$FC00,$01F4,$0A00,$06F4
ObjTimeIcon:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_209F6C(pc, d0.w), d0
	jsr     dat_209F6C(pc, d0.w)
	tst.b   timeWarpDir.w
	beq.s   loc_209F6A
	cmpi.w  #$5a, timeWarpTimer.w
	bcs.s   loc_209F64
	btst.b  #$0, $ff1505.l
	bne.s   loc_209F6A
loc_209F64:
	jmp     DrawObject.l
loc_209F6A:
	rts     
dat_209F6C:
	dc.w	ObjTimeIcon_Init-dat_209F6C
	dc.w	ObjTimeIcon_Main-dat_209F6C
ObjTimeIcon_Init:
	addq.b  #$2, oRoutine(a0)
	move.l  #$20a546, oMap(a0)
	move.w  #$85a8, oTile(a0)
	move.w  #$c4, oX(a0)
	move.w  #$152, oYScr(a0)
ObjTimeIcon_Main:
	move.b  #$12, oMapFrame(a0)
	tst.b   timeWarpDir.w
	bmi.s   loc_209FA0
	move.b  #$13, oMapFrame(a0)
loc_209FA0:
	rts     
ObjTimePostTimeIcon:
	tst.b   timeAttackMode.l
	beq.s   loc_209FB0
	jmp     DeleteObject.l
loc_209FB0:
	cmpi.b  #$a, oSubtype(a0)
	beq.w   ObjTimeIcon
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_209FD4(pc, d0.w), d0
	jsr     dat_209FD4(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
dat_209FD4:
	dc.w	ObjTimePost_Init-dat_209FD4
	dc.w	ObjTimePost_Main-dat_209FD4
	dc.w	ObjTimePost_Spin-dat_209FD4
	dc.w	ObjTimePost_Done-dat_209FD4
ObjTimePost_Init:
	addq.b  #$2, oRoutine(a0)
	move.b  #$20, oYRadius(a0)
	move.b  #$e, oXRadius(a0)
	move.l  #$20a546, oMap(a0)
	move.w  #$5a8, oTile(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	cmpi.b  #$6, zoneAct.l
	bne.s   loc_20A022
	tst.b   oLayer(a0)
	bne.s   loc_20A022
	move.b  #$0, oPriority(a0)
	ori.b   #$80, oTile(a0)
loc_20A022:
	move.b  #$f, oWidth(a0)
	move.b  oSubtype(a0), oAnim(a0)
	bsr.w   ObjMonitor_GetSavedFlags
	bclr.b  #$7, $2(a2, d0.w)
	move.b  #$a, oMapFrame(a0)
	cmpi.b  #$8, oSubtype(a0)
	beq.s   loc_20A04A
	addq.b  #$2, oMapFrame(a0)
loc_20A04A:
	btst.b  #$0, $2(a2, d0.w)
	beq.s   loc_20A05E
	addq.b  #$1, oMapFrame(a0)
	move.b  #$6, oRoutine(a0)
	rts     
loc_20A05E:
	move.b  #$df, oColType(a0)
ObjTimePost_Main:
	tst.b   oColStatus(a0)
	beq.s   loc_20A0C4
	clr.b   oColStatus(a0)
	cmpi.b  #$6, zoneAct.l
	bne.s   loc_20A090
	tst.b   oLayer(a0)
	beq.s   loc_20A088
	tst.b   layer.l
	beq.s   loc_20A0C4
	bra.s   loc_20A090
loc_20A088:
	tst.b   layer.l
	bne.s   loc_20A0C4
loc_20A090:
	move.b  #$3c, $2a(a0)
	addq.b  #$2, oRoutine(a0)
	bsr.w   ObjMonitor_GetSavedFlags
	bset.b  #$0, $2(a2, d0.w)
	move.w  #$77, d0
	move.b  #$ff, timeWarpDir.w
	cmpi.b  #$8, oSubtype(a0)
	beq.s   loc_20A0BE
	move.b  #$1, timeWarpDir.w
	subq.w  #$1, d0
loc_20A0BE:
	jsr     SubCPUCmd.l
loc_20A0C4:
	rts     
ObjTimePost_Spin:
	subq.b  #$1, $2a(a0)
	beq.s   loc_20A0D6
	lea     Ani_Monitor.l, a1
	bra.w   AnimateObject
loc_20A0D6:
	addq.b  #$2, oRoutine(a0)
	move.b  #$b, oMapFrame(a0)
	cmpi.b  #$8, oSubtype(a0)
	beq.s   ObjTimePost_Done
	addq.b  #$2, oMapFrame(a0)
ObjTimePost_Done:
	rts     
ObjMonitor_GetSavedFlags:
	lea     savedObjFlags.l, a2
	moveq   #$0, d0
	move.b  oSavedFlagsID(a0), d0
	move.w  d0, d1
	add.w   d1, d1
	add.w   d1, d0
	moveq   #$0, d1
	move.b  timeZone.l, d1
	bclr.l  #$7, d1
	beq.s   loc_20A126
	move.b  timeWarpDir.w, d2
	ext.w   d2
	neg.w   d2
	add.w   d2, d1
	bpl.s   loc_20A11E
	moveq   #$0, d1
	bra.s   loc_20A126
loc_20A11E:
	cmpi.w  #$3, d1
	bcs.s   loc_20A126
	moveq   #$2, d1
loc_20A126:
	add.w   d1, d0
	rts     
ObjMonitor_Solid:
	cmpi.b  #$6, zoneAct.l
	bne.s   loc_20A14C
	tst.b   layer.l
	beq.s   loc_20A144
	tst.b   oLayer(a0)
	bne.s   loc_20A14C
	rts     
loc_20A144:
	tst.b   oLayer(a0)
	beq.s   loc_20A14C
	rts     
loc_20A14C:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     SolidObject.l
ObjMonitorTimepost:
	tst.b   oSubtype(a0)
	bne.s   ObjMonitor
	tst.b   timeAttackMode.l
	beq.s   ObjMonitor
	jmp     CheckObjDespawn.l
ObjMonitor:
	cmpi.b  #$8, oSubtype(a0)
	bcc.w   ObjTimePostTimeIcon
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20A186(pc, d0.w), d1
	jmp     dat_20A186(pc, d1.w)
dat_20A186:
	dc.w	ObjMonitor_Init-dat_20A186
	dc.w	ObjMonitor_Main-dat_20A186
	dc.w	ObjMonitor_Break-dat_20A186
	dc.w	ObjMonitor_Animate-dat_20A186
	dc.w	ObjMonitor_Draw-dat_20A186
ObjMonitor_Init:
	addq.b  #$2, oRoutine(a0)
	move.b  #$e, oYRadius(a0)
	move.b  #$e, oXRadius(a0)
	move.l  #$20a546, oMap(a0)
	move.w  #$5a8, oTile(a0)
	move.b  #$3, oPriority(a0)
	cmpi.b  #$6, zoneAct.l
	bne.s   loc_20A1D0
	tst.b   oLayer(a0)
	bne.s   loc_20A1D0
	ori.b   #$80, oTile(a0)
	move.b  #$0, oPriority(a0)
loc_20A1D0:
	move.b  #$4, oSprFlags(a0)
	move.b  #$f, oWidth(a0)
	bsr.w   ObjMonitor_GetSavedFlags
	bclr.b  #$7, $2(a2, d0.w)
	btst.b  #$0, $2(a2, d0.w)
	beq.s   loc_20A1FC
	move.b  #$8, oRoutine(a0)
	move.b  #$11, oMapFrame(a0)
	rts     
loc_20A1FC:
	move.b  #$46, oColType(a0)
	move.b  oSubtype(a0), oAnim(a0)
ObjMonitor_Main:
	tst.b   oSprFlags(a0)
	bpl.w   ObjMonitor_Draw
	move.b  oSolidType(a0), d0
	beq.s   loc_20A236
	bsr.w   ObjMoveGrv
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.w   ObjMonitor_Animate
	add.w   d1, oY(a0)
	clr.w   oYVel(a0)
	clr.b   oSolidType(a0)
	bra.w   ObjMonitor_Animate
loc_20A236:
	tst.b   oSprFlags(a0)
	bpl.s   ObjMonitor_Animate
	lea     objects.w, a1
	bsr.w   ObjMonitor_Solid
ObjMonitor_Animate:
	tst.w   timeStopTimer.l
	bne.s   ObjMonitor_Draw
	lea     Ani_Monitor.l, a1
	bsr.w   AnimateObject
ObjMonitor_Draw:
	bsr.w   DrawObject
	jmp     CheckObjDespawn.l
ObjMonitor_Break:
	move.w  #$96, d0
	jsr     PlayFMSound.l
	addq.b  #$4, oRoutine(a0)
	move.b  #$0, oColType(a0)
	bsr.w   FindObjSlot
	bne.s   loc_20A298
	dc.b	$13,$7C,$00,$1A,$00,$00		; move.b #$1a, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  oAnim(a0), $1c(a1)
	move.b  oLayer(a0), $29(a1)
loc_20A298:
	bsr.w   FindObjSlot
	bne.s   loc_20A2C2
	dc.b	$13,$7C,$00,$18,$00,$00		; move.b #$18, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  #$1, $25(a1)
	move.b  #$1, $28(a1)
	move.b  oLayer(a0), $29(a1)
loc_20A2C2:
	bsr.w   ObjMonitor_GetSavedFlags
	bset.b  #$0, $2(a2, d0.w)
	move.b  #$11, oMapFrame(a0)
	bra.w   DrawObject
ObjMonitorItem:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20A2E8(pc, d0.w), d1
	jsr     dat_20A2E8(pc, d1.w)
	bra.w   DrawObject
dat_20A2E8:
	dc.w	ObjMonitorItem_Init-dat_20A2E8
	dc.w	ObjMonitorItem_Main-dat_20A2E8
	dc.w	ObjMonitorItem_Delete-dat_20A2E8
ObjMonitorItem_Init:
	addq.b  #$2, oRoutine(a0)
	move.w  #$85a8, oTile(a0)
	tst.b   oLayer(a0)
	beq.s   loc_20A304
	andi.b  #$7f, oTile(a0)
loc_20A304:
	move.b  #$24, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$8, oWidth(a0)
	move.w  #$fd00, oYVel(a0)
	moveq   #$0, d0
	move.b  oAnim(a0), d0
	move.b  d0, oMapFrame(a0)
	movea.l #$20a546, a1
	add.b   d0, d0
	adda.w  (a1, d0.w), a1
	addq.w  #$1, a1
	move.l  a1, oMap(a0)
ObjMonitorItem_Main:
	tst.w   oYVel(a0)
	bpl.w   loc_20A34C
	bsr.w   ObjMove
	addi.w  #$18, oYVel(a0)
	rts     
loc_20A34C:
	addq.b  #$2, oRoutine(a0)
	move.w  #$1d, oAnimTime(a0)
	move.b  oAnim(a0), d0
	bne.s   loc_20A372
loc_20A35C:
	addq.b  #$1, lives.l
	addq.b  #$1, updateHUDLives.l
	move.w  #$7a, d0
	jmp     SubCPUCmd.l
loc_20A372:
	cmpi.b  #$1, d0
	bne.s   loc_20A3BE
	addi.w  #$a, rings.l
	ori.b   #$1, updateHUDRings.l
	cmpi.w  #$64, rings.l
	bcs.s   loc_20A3B4
	bset.b  #$1, livesFlags.l
	beq.w   loc_20A35C
	cmpi.w  #$c8, rings.l
	bcs.s   loc_20A3B4
	bset.b  #$2, livesFlags.l
	beq.w   loc_20A35C
loc_20A3B4:
	move.w  #$95, d0
	jmp     PlayFMSound.l
loc_20A3BE:
	cmpi.b  #$2, d0
	bne.s   loc_20A3DC
sub_20A3C4:
	move.b  #$1, shield.l
	move.b  #$3, objShieldSlot.w
	move.w  #$97, d0
	jmp     PlayFMSound.l
loc_20A3DC:
	cmpi.b  #$3, d0
	bne.s   loc_20A43E
sub_20A3E2:
	move.b  #$1, invincible.l
	move.w  #$4b0, $FFFFD032.w
	move.b  #$3, objInvStar1Slot.w
	move.b  #$1, $FFFFD21C.w
	move.b  #$3, objInvStar2Slot.w
	move.b  #$2, $FFFFD25C.w
	move.b  #$3, objInvStar3Slot.w
	move.b  #$3, $FFFFD29C.w
	move.b  #$3, objInvStar4Slot.w
	move.b  #$4, $FFFFD2DC.w
	tst.b   timeZone.l
	bne.s   loc_20A432
	move.w  #$82, d0
	jsr     SubCPUCmd.l
loc_20A432:
	move.w  #$6d, d0
	jmp     SubCPUCmd.l
	dc.w	$4E75
loc_20A43E:
	cmpi.b  #$4, d0
	bne.s   loc_20A480
loc_20A444:
	move.b  #$1, speedShoes.l
	move.w  #$4b0, $FFFFD034.w
	move.w  #$c00, sonicTopSpeed.w
	move.w  #$18, sonicAcceleration.w
	move.w  #$80, sonicDeceleration.w
	tst.b   timeZone.l
	bne.s   loc_20A476
	move.w  #$82, d0
	jsr     SubCPUCmd.l
loc_20A476:
	move.w  #$6c, d0
	jmp     SubCPUCmd.l
loc_20A480:
	cmpi.b  #$5, d0
	bne.s   loc_20A490
	move.w  #$12c, timeStopTimer.l
	rts     
loc_20A490:
	cmpi.b  #$6, d0
	bne.s   loc_20A4AA
	move.w  #$9d, d0
	jsr     PlayFMSound.l
	move.b  #$1, combineRing.l
	rts     
loc_20A4AA:
	bsr.w   sub_20A3C4
	bsr.w   sub_20A3E2
	bra.s   loc_20A444
ObjMonitorItem_Delete:
	subq.w  #$1, oAnimTime(a0)
	bmi.w   DeleteObject
	rts     
Ani_Monitor:
	dc.w	$0014,$0020,$002C,$0038,$0044,$0050,$005C,$0068
	dc.w	$0074,$007E,$0110,$0000,$0800,$0009,$0000,$FF00
	dc.w	$0110,$0101,$0801,$0109,$0101,$FF00,$0110,$0202
	dc.w	$0802,$0209,$0202,$FF00,$0110,$0303,$0803,$0309
	dc.w	$0303,$FF00,$0110,$0404,$0804,$0409,$0404,$FF00
	dc.w	$0110,$0505,$0805,$0509,$0505,$FF00,$0110,$0606
	dc.w	$0806,$0609,$0606,$FF00,$0110,$0707,$0807,$0709
	dc.w	$0707,$FF00,$010A,$0E0F,$0E0B,$0E0F,$0EFF,$010C
	dc.w	$0E0F,$0E0D,$0E0F,$0EFF
MapSpr_MonitorTime:
	dc.w	$0028,$003E,$0054,$006A,$0080,$0096,$00AC,$00C2
	dc.w	$00D8,$00EE,$0104,$011E,$0138,$0152,$016C,$0186
	dc.w	$01A0,$01B0,$01B6,$01BC,$04F6,$0500,$12F8,$F006
	dc.w	$0000,$F0F0,$0608,$0000,$080C,$0006,$F000,$04F6
	dc.w	$0500,$16F8,$F006,$0000,$F0F0,$0608,$0000,$080C
	dc.w	$0006,$F000,$04F6,$0500,$1AF8,$F006,$0000,$F0F0
	dc.w	$0608,$0000,$080C,$0006,$F000,$04F6,$0500,$1EF8
	dc.w	$F006,$0000,$F0F0,$0608,$0000,$080C,$0006,$F000
	dc.w	$04F6,$0500,$22F8,$F006,$0000,$F0F0,$0608,$0000
	dc.w	$080C,$0006,$F000,$04F6,$0500,$26F8,$F006,$0000
	dc.w	$F0F0,$0608,$0000,$080C,$0006,$F000,$04F6,$0500
	dc.w	$2AF8,$F006,$0000,$F0F0,$0608,$0000,$080C,$0006
	dc.w	$F000,$04F6,$0500,$2EF8,$F006,$0000,$F0F0,$0608
	dc.w	$0000,$080C,$0006,$F000,$04F6,$0500,$48F8,$F006
	dc.w	$0000,$F0F0,$0608,$0000,$080C,$0006,$F000,$04F6
	dc.w	$0508,$48F8,$F006,$0000,$F0F0,$0608,$0000,$080C
	dc.w	$0006,$F000,$05D8,$0D00,$32F0,$E803,$004C,$F8E8
	dc.w	$0308,$4C00,$0801,$0050,$F808,$0108,$5000,$05D8
	dc.w	$0D08,$32F0,$E803,$004C,$F8E8,$0308,$4C00,$0801
	dc.w	$0050,$F808,$0108,$5000,$05D8,$0D00,$3AF0,$E803
	dc.w	$004C,$F8E8,$0308,$4C00,$0801,$0050,$F808,$0108
	dc.w	$5000,$05D8,$0D08,$3AF0,$E803,$004C,$F8E8,$0308
	dc.w	$4C00,$0801,$0050,$F808,$0108,$5000,$05D8,$0500
	dc.w	$42F8,$E803,$004C,$F8E8,$0308,$4C00,$0801,$0050
	dc.w	$F808,$0108,$5000,$05D8,$0100,$46FC,$E803,$004C
	dc.w	$F8E8,$0308,$4C00,$0801,$0050,$F808,$0108,$5000
	dc.w	$03F0,$0600,$00F0,$F006,$0800,$0008,$0C00,$06F0
	dc.w	$0100,$0D00,$0AF0,$01F8,$0D00,$32F0,$01F8,$0D00
	dc.w	$3AF0
ObjPoints:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20A71C(pc, d0.w), d0
	jsr     dat_20A71C(pc, d0.w)
	jmp     DrawObject.l
dat_20A71C:
	dc.w	ObjPoints_Init-dat_20A71C
	dc.w	ObjPoints_Main-dat_20A71C
ObjPoints_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$6c6, oTile(a0)
	move.l  #$20a75c, oMap(a0)
	move.b  oSubtype(a0), oMapFrame(a0)
	andi.b  #$7f, oMapFrame(a0)
	move.b  #$18, $2a(a0)
ObjPoints_Main:
	subq.b  #$1, $2a(a0)
	bne.s   loc_20A756
	jmp     DeleteObject.l
loc_20A756:
	subq.w  #$2, oY(a0)
	rts     
MapSpr_Points:
	dc.w	$000C,$0018,$0024,$0030,$003C,$0042,$0200,$0000
	dc.w	$00F8,$0000,$0003,$0000,$0200,$0000,$01F8,$0000
	dc.w	$0003,$0000,$0200,$0000,$02F8,$0000,$0003,$0000
	dc.w	$0200,$0000,$04F8,$0000,$0003,$0000,$0100,$0000
	dc.w	$04FC,$0300,$0000,$00F4,$0000,$0003,$FC00,$0000
	dc.w	$0304
ObjHUDPoints:
	tst.b   oSubtype(a0)
	bmi.w   ObjPoints
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20A7C4(pc, d0.w), d0
	jmp     dat_20A7C4(pc, d0.w)
dat_20A7C4:
	dc.w	ObjHUD_Init-dat_20A7C4
	dc.w	ObjHUD_Main-dat_20A7C4
ObjHUD_Init:
	addq.b  #$2, oRoutine(a0)
	move.l  #$20a85e, oMap(a0)
	move.w  #$8568, oTile(a0)
	move.w  #$90, oX(a0)
	move.w  #$88, oYScr(a0)
	tst.b   oLayer(a0)
	beq.s   loc_20A7F4
	move.b  #$3, oMapFrame(a0)
	bra.s   ObjHUD_Main
loc_20A7F4:
	tst.w   debugCheat.l
	beq.s   loc_20A802
	move.b  #$2, oMapFrame(a0)
loc_20A802:
	tst.b   oSubtype(a0)
	beq.s   ObjHUD_Main
	move.w  #$148, oYScr(a0)
	move.b  #$1, oMapFrame(a0)
ObjHUD_Main:
	tst.b   oSubtype(a0)
	bne.s   loc_20A858
	tst.b   oLayer(a0)
	beq.s   loc_20A844
	tst.w   rings.l
	beq.s   loc_20A830
	bclr.b  #$5, oTile(a0)
	bra.s   loc_20A858
loc_20A830:
	move.b  $ff190d.l, d0
	andi.b  #$f, d0
	bne.s   loc_20A858
	eori.b  #$20, oTile(a0)
	bra.s   loc_20A858
loc_20A844:
	move.b  #$0, oMapFrame(a0)
	tst.w   debugCheat.l
	beq.s   loc_20A858
	move.b  #$2, oMapFrame(a0)
loc_20A858:
	jmp     DrawObject.l
MapSpr_HUD:
	dc.w	$0008,$0050,$0060,$0098,$0E00,$0100,$0000,$0005
	dc.w	$0002,$0800,$0100,$0618,$0001,$0008,$2000,$0900
	dc.w	$1B28,$000D,$0021,$4010,$0900,$0A00,$1001,$0008
	dc.w	$1810,$0100,$2928,$1000,$0018,$3010,$0500,$2B38
	dc.w	$1000,$0019,$4810,$0500,$2F50,$2009,$0033,$3000
	dc.w	$0300,$0500,$3900,$0800,$001A,$1004,$0100,$3D18
	dc.w	$0B00,$0100,$0000,$0005,$0002,$0800,$0100,$0618
	dc.w	$0001,$0008,$2000,$0900,$1B28,$0009,$0021,$4010
	dc.w	$0900,$0A00,$1001,$0008,$1810,$0500,$2B38,$1005
	dc.w	$002F,$4820,$0900,$3330,$0320,$0100,$1000,$2009
	dc.w	$0012,$0820,$0100,$0020
AddPoints:
	move.b  #$1, updateHUDScore.l
	lea     score.l, a3
	add.l   d0, (a3)
	move.l  #$f423f, d1
	cmp.l   (a3), d1
	bhi.s   loc_20A922
	move.l  d1, (a3)
loc_20A922:
	move.l  (a3), d0
	cmp.l   nextLifeScore.l, d0
	bcs.s   loc_20A94C
	addi.l  #$1388, nextLifeScore.l
	addq.b  #$1, lives.l
	addq.b  #$1, updateHUDLives.l
	move.w  #$7a, d0
	jmp     SubCPUCmd.l
loc_20A94C:
	rts     
UpdateHUD:
	tst.w   debugCheat.l
	beq.s   loc_20A9A4
	bsr.w   HUD_DrawPos
	move.l  #$73600002, d0
	moveq   #$0, d1
	move.b  savedObjFlags.l, d1
	move.w  $FFFFD00C.w, d2
	lsr.w   #$1, d2
	andi.w  #$380, d2
	move.b  $FFFFD008.w, d1
	andi.w  #$7f, d1
	add.w   d1, d2
	lea     levelLayout.w, a1
	moveq   #$0, d1
	move.b  (a1, d2.w), d1
	andi.w  #$7f, d1
	move.w  debugBlock.l, d1
	andi.w  #$7ff, d1
	lea     Hud_100.l, a2
	moveq   #$2, d6
	bsr.w   HUD_DrawNum
	bra.w   loc_20A9FE
loc_20A9A4:
	tst.b   updateHUDScore.l
	beq.s   loc_20A9C8
	bpl.s   loc_20A9B2
	bsr.w   HUD_ResetScore
loc_20A9B2:
	clr.b   updateHUDScore.l
	move.l  #$70600002, d0
	move.l  score.l, d1
	bsr.w   HUD_DrawScore
loc_20A9C8:
	tst.b   updateHUDRings.l
	beq.s   loc_20A9FE
	bpl.s   loc_20A9D6
	bsr.w   HUD_ResetRings
loc_20A9D6:
	clr.b   updateHUDRings.l
	move.l  #$73600002, d0
	moveq   #$0, d1
	move.w  rings.l, d1
	cmpi.w  #$3e8, d1
	bcs.s   loc_20A9FA
	move.w  #$3e7, d1
	move.w  d1, rings.l
loc_20A9FA:
	bsr.w   HUD_DrawRings
loc_20A9FE:
	tst.w   debugCheat.l
	bne.w   loc_20AAAA
	tst.b   updateHUDTime.l
	beq.w   loc_20AAAA
	tst.w   paused.w
	bne.w   loc_20AAAA
	lea     time.l, a1
	cmpi.l  #$93b3b, (a1)+
	beq.w   loc_20AB08
	tst.b   ctrlLocked.w
	bne.s   loc_20AA54
	addq.b  #$1, -(a1)
	cmpi.b  #$3c, (a1)
	bcs.s   loc_20AA54
	move.b  #$0, (a1)
	addq.b  #$1, -(a1)
	cmpi.b  #$3c, (a1)
	bcs.s   loc_20AA54
	move.b  #$0, (a1)
	addq.b  #$1, -(a1)
	cmpi.b  #$9, (a1)
	bcs.s   loc_20AA54
	move.b  #$9, (a1)
loc_20AA54:
	move.l  #$72200002, d0
	moveq   #$0, d1
	move.b  timeMinutes.l, d1
	bsr.w   HUD_DrawMins
	move.l  #$72600002, d0
	moveq   #$0, d1
	move.b  timeSeconds.l, d1
	bsr.w   HUD_DrawSecs
	move.l  #$72e00002, d0
	moveq   #$0, d1
	move.b  timeFrames.l, d1
	mulu.w  #$64, d1
	divu.w  #$3c, d1
	swap    d1
	move.w  #$0, d1
	swap    d1
	cmpi.l  #$93b3b, time.l
	bne.s   loc_20AAA6
	move.w  #$63, d1
loc_20AAA6:
	bsr.w   HUD_DrawSecs
loc_20AAAA:
	tst.b   updateHUDLives.l
	beq.s   loc_20AABC
	clr.b   updateHUDLives.l
	bsr.w   HUD_DrawLives
loc_20AABC:
	tst.b   updateHUDBonus.w
	beq.s   loc_20AB06
	clr.b   updateHUDBonus.w
	move.l  #$47800002, d0
	cmpi.w  #$502, zoneAct.l
	bne.s   loc_20AADC
	move.l  #$6d400001, d0
loc_20AADC:
	moveq   #$0, d1
	move.w  timeBonus.w, d1
	bsr.w   HUD_DrawBonus
	move.l  #$48c00002, d0
	cmpi.w  #$502, zoneAct.l
	bne.s   loc_20AAFC
	move.l  #$6e800001, d0
loc_20AAFC:
	moveq   #$0, d1
	move.w  ringBonus.w, d1
	bsr.w   HUD_DrawBonus
loc_20AB06:
	rts     
loc_20AB08:
	btst.b  #$7, timeZone.l
	bne.s   loc_20AB34
	clr.b   updateHUDTime.l
	move.l  #$0, time.l
	lea     objects.w, a0
	movea.l a0, a2
	bsr.w   KillPlayer
	move.b  #$1, timeOver.l
loc_20AB34:
	rts     
HUD_ResetRings:
	move.l  #$73600002, VDPCTRL.l
	lea     HUD_DrawRingsTiles(pc), a2
	move.w  #$2, d2
	bra.s   HUD_ResetNumber
HUD_ResetScore:
	lea     VDPDATA.l, a6
	bsr.w   HUD_DrawLives
	move.l  #$70600002, VDPCTRL.l
	lea     HUD_DrawScoreTiles(pc), a2
	move.w  #$6, d2
HUD_ResetNumber:
	lea     Art_HUDNumbers.l, a1
loc_20AB6C:
	move.w  #$f, d1
	move.b  (a2)+, d0
	bmi.s   loc_20AB88
	ext.w   d0
	lsl.w   #$5, d0
	lea     (a1, d0.w), a3
loc_20AB7C:
	move.l  (a3)+, (a6)
	dbra    d1, loc_20AB7C
loc_20AB82:
	dbra    d2, loc_20AB6C
	rts     
loc_20AB88:
	move.l  #$0, (a6)
	dbra    d1, loc_20AB88
	bra.s   loc_20AB82
HUD_DrawScoreTiles:
	dc.w	$FFFF,$FFFF,$FFFF,$0000
HUD_DrawRingsTiles:
	dc.w	$FFFF,$0000
HUD_DrawPos:
	move.l  #$70e00002, d0
	moveq   #$0, d1
	move.w  $FFFFD008.w, d1
	bsr.w   HUD_DrawHexNum
	move.l  #$72600002, d0
	move.w  $FFFFD00C.w, d1
	bra.w   HUD_DrawHexNum
HUD_DrawBonus:
	lea     Hud_10000.l, a2
	moveq   #$4, d6
	moveq   #$0, d4
	lea     Art_HUDNumbers.l, a1
loc_20ABCE:
	moveq   #$0, d2
	move.l  (a2)+, d3
loc_20ABD2:
	sub.l   d3, d1
	bcs.s   loc_20ABDA
	addq.w  #$1, d2
	bra.s   loc_20ABD2
loc_20ABDA:
	add.l   d3, d1
	tst.w   d2
	beq.s   loc_20ABE4
	move.w  #$1, d4
loc_20ABE4:
	move.l  d0, $4(a6)
	tst.w   d4
	bne.s   loc_20ABF0
	tst.w   d6
	bne.s   loc_20AC22
loc_20ABF0:
	lsl.w   #$6, d2
	lea     (a1, d2.w), a3
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
loc_20AC16:
	addi.l  #$400000, d0
	dbra    d6, loc_20ABCE
	rts     
loc_20AC22:
	moveq   #$f, d5
loc_20AC24:
	move.l  #$0, (a6)
	dbra    d5, loc_20AC24
	bra.s   loc_20AC16
HUD_DrawRings:
	lea     Hud_100.l, a2
	moveq   #$2, d6
	bra.s   HUD_DrawCounter
HUD_DrawScore:
	lea     Hud_100000.l, a2
	moveq   #$5, d6
HUD_DrawCounter:
	moveq   #$0, d4
	lea     Art_HUDNumbers.l, a1
loc_20AC4A:
	moveq   #$0, d2
	move.l  (a2)+, d3
loc_20AC4E:
	sub.l   d3, d1
	bcs.s   loc_20AC56
	addq.w  #$1, d2
	bra.s   loc_20AC4E
loc_20AC56:
	add.l   d3, d1
	tst.w   d2
	beq.s   loc_20AC60
	move.w  #$1, d4
loc_20AC60:
	tst.w   d4
	beq.s   loc_20AC8E
	lsl.w   #$6, d2
	move.l  d0, $4(a6)
	lea     (a1, d2.w), a3
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
loc_20AC8E:
	addi.l  #$400000, d0
	dbra    d6, loc_20AC4A
	rts     
	move.l  #$5f800003, VDPCTRL.l
	lea     VDPDATA.l, a6
	lea     Hud_10.l, a2
	moveq   #$1, d6
	moveq   #$0, d4
	lea     Art_HUDNumbers.l, a1
loc_20ACBA:
	moveq   #$0, d2
	move.l  (a2)+, d3
loc_20ACBE:
	sub.l   d3, d1
	bcs.s   loc_20ACC6
	addq.w  #$1, d2
	bra.s   loc_20ACBE
loc_20ACC6:
	add.l   d3, d1
	lsl.w   #$6, d2
	lea     (a1, d2.w), a3
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	dbra    d6, loc_20ACBA
	rts     
Hud_100000:
	dc.w	$0001,$86A0
Hud_10000:
	dc.w	$0000,$2710,$0000,$03E8
Hud_100:
	dc.w	$0000,$0064
Hud_10:
	dc.w	$0000,$000A
Hud_1:
	dc.w	$0000,$0001
Hud_1000h:
	dc.w	$0000,$1000,$0000,$0100,$0000,$0010,$0000,$0001
HUD_DrawHexNum:
	moveq   #$3, d6
	lea     Hud_1000h.l, a2
	bra.s   HUD_DrawNum
HUD_DrawLives:
	move.l  #$74a00002, d0
	moveq   #$0, d1
	move.b  lives.l, d1
	cmpi.b  #$9, d1
	bcs.s   loc_20AD3C
	moveq   #$9, d1
loc_20AD3C:
	lea     Hud_1.l, a2
	moveq   #$0, d6
	bra.s   HUD_DrawNum
HUD_DrawMins:
	lea     Hud_1.l, a2
	moveq   #$0, d6
	bra.s   HUD_DrawNum
HUD_DrawSecs:
	lea     Hud_10.l, a2
	moveq   #$1, d6
HUD_DrawNum:
	moveq   #$0, d4
	lea     Art_HUDNumbers.l, a1
loc_20AD60:
	moveq   #$0, d2
	move.l  (a2)+, d3
loc_20AD64:
	sub.l   d3, d1
	bcs.s   loc_20AD6C
	addq.w  #$1, d2
	bra.s   loc_20AD64
loc_20AD6C:
	add.l   d3, d1
	tst.w   d2
	beq.s   loc_20AD76
	move.w  #$1, d4
loc_20AD76:
	lsl.w   #$6, d2
	move.l  d0, $4(a6)
	lea     (a1, d2.w), a3
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	move.l  (a3)+, (a6)
	addi.l  #$400000, d0
	dbra    d6, loc_20AD60
	rts     
Obj1D_20ADAC:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20ADBA(pc, d0.w), d1
	jmp     dat_20ADBA(pc, d1.w)
dat_20ADBA:
	dc.w	loc_20ADBE-dat_20ADBA
	dc.w	loc_20AE38-dat_20ADBA
loc_20ADBE:
	addq.b  #$2, oRoutine(a0)
	move.l  #$20b0b8, oMap(a0)
	move.w  #$4ce, oTile(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$d7, oColType(a0)
	move.w  oX(a0), $32(a0)
	move.w  #$5, $34(a0)
	moveq   #$0, d0
	move.b  oSubtype(a0), d6
	btst.l  #$1, d6
	beq.s   loc_20AE10
	addi.w  #$40, d0
loc_20AE10:
	btst.l  #$0, d6
	beq.s   loc_20AE1A
	addi.w  #$20, d0
loc_20AE1A:
	move.w  d0, $30(a0)
	lsr.w   #$1, d0
	move.w  d0, $2e(a0)
	beq.s   loc_20AE38
	move.l  #$10000, $2a(a0)
	btst.l  #$6, d6
	bne.s   loc_20AE38
	neg.l   $2a(a0)
loc_20AE38:
	move.l  $2a(a0), d0
	beq.s   loc_20AE60
	lea     oX(a0), a1
	tst.w   oSubtype(a0)
	bmi.s   loc_20AE4C
	lea     oY(a0), a1
loc_20AE4C:
	add.l   d0, (a1)
	addi.w  #$ffff, $2e(a0)
	bne.s   loc_20AE60
	move.w  $30(a0), $2e(a0)
	neg.l   $2a(a0)
loc_20AE60:
	tst.b   oColStatus(a0)
	beq.w   loc_20AEFC
	tst.w   $34(a0)
	beq.s   loc_20AE7E
	subq.w  #$1, $34(a0)
	moveq   #$a, d0
	bsr.w   AddPoints
	moveq   #$0, d1
	bsr.w   sub_205FC0
loc_20AE7E:
	tst.b   oSprFlags(a0)
	bpl.s   loc_20AE8E
	move.w  #$7f, d0
	jsr     SubCPUCmd.l
loc_20AE8E:
	lea     objects.w, a1
	clr.b   oColStatus(a0)
	move.w  oX(a0), d1
	move.w  oY(a0), d2
	sub.w   $8(a1), d1
	sub.w   $c(a1), d2
	jsr     CalcAngle.l
	jsr     CalcSine.l
	muls.w  #$f900, d1
	asr.l   #$8, d1
	move.w  d1, $10(a1)
	muls.w  #$f900, d0
	asr.l   #$8, d0
	move.w  d0, $12(a1)
	bset.b  #$1, $22(a1)
	bclr.b  #$4, $22(a1)
	bclr.b  #$5, $22(a1)
	clr.b   $3c(a1)
	move.b  #$1, oAnim(a0)
	lea     savedObjFlags.l, a2
	moveq   #$0, d0
	move.b  oSavedFlagsID(a0), d0
	beq.s   loc_20AEFC
	cmpi.b  #$8a, $2(a2, d0.w)
	bcc.s   loc_20AEFC
	addq.b  #$1, $2(a2, d0.w)
loc_20AEFC:
	lea     loc_20B0A8.l, a1
	bsr.w   AnimateObject
	jsr     DrawObject.l
	move.w  $32(a0), d0
	jmp     CheckObjDespawn2.l
Obj1E_20AF16:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20AF24(pc, d0.w), d0
	jmp     dat_20AF24(pc, d0.w)
dat_20AF24:
	dc.w	loc_20AF28-dat_20AF24
	dc.w	loc_20AF52-dat_20AF24
loc_20AF28:
	addq.b  #$2, oRoutine(a0)
	move.l  #$20b0f8, oMap(a0)
	move.w  #$49d, oTile(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$10, oYRadius(a0)
loc_20AF52:
	tst.b   oAnim(a0)
	bne.s   loc_20AF60
	lea     objects.w, a1
	bsr.w   sub_20AF76
loc_20AF60:
	lea     loc_20B0EA.l, a1
	bsr.w   AnimateObject
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
sub_20AF76:
	cmpi.b  #$2b, $1c(a1)
	beq.w   loc_20B01E
	move.w  $8(a1), d0
	moveq   #$0, d1
	move.b  oWidth(a0), d1
	sub.w   oX(a0), d0
	add.w   d1, d0
	bmi.w   loc_20B01E
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.w   loc_20B01E
	move.w  $8(a1), d0
	moveq   #$0, d3
	move.b  oWidth(a0), d3
	move.w  oX(a0), d2
	sub.w   d3, d2
	sub.w   d2, d0
	btst.b  #$0, oFlags(a0)
	beq.s   loc_20AFBE
	move.w  #$40, d2
	sub.w   d0, d2
	move.w  d2, d0
loc_20AFBE:
	lea     loc_20B028.l, a3
	tst.w   $12(a1)
	bpl.s   loc_20AFD0
	lea     loc_20B068.l, a3
loc_20AFD0:
	move.b  (a3, d0.w), d0
	ext.w   d0
	add.w   oY(a0), d0
	move.w  d0, d1
	moveq   #$0, d3
	move.b  $16(a1), d3
	tst.w   $12(a1)
	bpl.s   loc_20AFEA
	neg.w   d3
loc_20AFEA:
	sub.w   d3, d1
	add.w   $c(a1), d3
	sub.w   d0, d3
	addq.w  #$8, d3
	bmi.s   loc_20B01E
	cmpi.w  #$10, d3
	bcc.s   loc_20B01E
	move.w  d1, $c(a1)
	tst.w   $12(a1)
	bmi.s   loc_20B00E
	jsr     StandOnObject.l
	bra.s   loc_20B01A
loc_20B00E:
	move.w  #$0, $12(a1)
	move.w  $10(a1), $14(a1)
loc_20B01A:
	moveq   #$1, d0
	rts     
loc_20B01E:
	jsr     GetOffObject.l
	moveq   #$0, d0
	rts     
loc_20B028:
	dc.w	$0E0D,$0C0B,$0B0A,$0A09,$0908,$0807,$0706,$0605
	dc.w	$0504,$0403,$0302,$0201,$0100,$00FF,$FFFE,$FEFD
	dc.w	$FDFC,$FCFB,$FBFA,$FAF9,$F9F8,$F8F7,$F7F6,$F6F5
	dc.w	$F5F5,$F4F4,$F4F4,$F4F4,$F5F5,$F6F6,$F7F8,$FAFC
loc_20B068:
	dc.w	$1213,$1414,$1414,$1414,$1413,$1313,$1313,$1313
	dc.w	$1212,$1212,$1212,$1111,$1111,$1111,$1010,$1010
	dc.w	$1010,$100F,$0F0F,$0F0F,$0E0E,$0E0E,$0E0E,$0D0D
	dc.w	$0D0D,$0D0D,$0C0C,$0C0C,$0B0B,$0A0A,$0908,$0604
loc_20B0A8:
	dc.w	$0004,$0008,$0F00,$FF00,$0401,$0201,$02FD,$0000
loc_20B0B8:
	dc.w	$0006,$000C,$0012,$01F0,$0F00,$00F0,$01F4,$0A00
	dc.w	$10F4,$06EC,$0400,$19F0,$F40A,$001B,$E80C,$0410
	dc.w	$19F0,$EC04,$0819,$00F4,$0A08,$1B00,$0C04,$1819
	dc.w	$0000
loc_20B0EA:
	dc.w	$0004,$0008,$0F00,$FF00,$0101,$0201,$FD00
loc_20B0F8:
	dc.w	$0006,$001C,$0028,$0404,$0D00,$00E0,$FC04,$0008
	dc.w	$F0F4,$0E00,$0A00,$0C08,$0016,$0000,$02F4,$0E00
	dc.w	$19E0,$F40E,$0025,$0000,$04EC,$0D10,$00E0,$FC04
	dc.w	$1008,$F0F4,$0E10,$0A00,$EC08,$1016,$0000
Obj2A_20B136:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20B154(pc, d0.w), d0
	jsr     dat_20B154(pc, d0.w)
	jsr     DrawObject.l
	move.w  $3e(a0), d0
	jmp     CheckObjDespawn2.l
dat_20B154:
	dc.w	loc_20B158-dat_20B154
	dc.w	loc_20B1C2-dat_20B154
loc_20B158:
	move.w  oX(a0), $3e(a0)
	addq.b  #$2, oRoutine(a0)
	move.l  #$20b27a, oMap(a0)
	move.w  #$435e, oTile(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$e7, oColType(a0)
	move.w  #$c0, $30(a0)
	move.w  #$60, $2e(a0)
	btst.b  #$7, oSubtype(a0)
	bne.s   loc_20B1AE
	move.w  #$a0, $30(a0)
	move.w  #$50, $2e(a0)
loc_20B1AE:
	move.l  #$10000, $2a(a0)
	btst.b  #$6, oSubtype(a0)
	bne.s   loc_20B1C2
	neg.l   $2a(a0)
loc_20B1C2:
	tst.b   oColStatus(a0)
	beq.w   loc_20B252
	tst.b   oSprFlags(a0)
	bpl.s   loc_20B1DA
	move.w  #$b5, d0
	jsr     PlayFMSound.l
loc_20B1DA:
	lea     objects.w, a1
	clr.b   oColStatus(a0)
	move.w  $8(a1), d5
	move.w  $c(a1), d6
	sub.w   oX(a0), d5
	sub.w   oY(a0), d6
	move.w  d6, d0
	subi.w  #$fff8, d0
	subi.w  #$10, d0
	bcc.s   loc_20B208
	move.w  #$0, $10(a1)
	bra.w   loc_20B252
loc_20B208:
	move.w  d5, d0
	subi.w  #$ffe8, d0
	subi.w  #$30, d0
	bcc.s   loc_20B224
	move.w  #$700, $12(a1)
	tst.w   d6
	bpl.s   loc_20B222
	neg.w   $12(a1)
loc_20B222:
	bra.s   loc_20B240
loc_20B224:
	move.w  #$4f3, $10(a1)
	tst.w   d5
	bpl.s   loc_20B232
	neg.w   $10(a1)
loc_20B232:
	move.w  #$4f3, $12(a1)
	tst.w   d6
	bpl.s   loc_20B240
	neg.w   $12(a1)
loc_20B240:
	bset.b  #$1, $22(a1)
	bclr.b  #$4, $22(a1)
	bclr.b  #$5, $22(a1)
loc_20B252:
	lea     oX(a0), a1
	tst.w   oSubtype(a0)
	bmi.s   loc_20B260
	lea     oY(a0), a1
loc_20B260:
	move.l  $2a(a0), d0
	add.l   d0, (a1)
	addi.w  #$ffff, $2e(a0)
	bne.s   loc_20B278
	move.w  $30(a0), $2e(a0)
	neg.l   $2a(a0)
loc_20B278:
	rts     
loc_20B27A:
	dc.w	$0002,$06F0,$0C00,$00E0,$F80D,$0004,$E008,$0C10
	dc.w	$00E0,$F00C,$0800,$00F8,$0D08,$0400,$080C,$1800
	dc.w	$0000
Obj29_20B29C:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20B2B0(pc, d0.w), d0
	jsr     dat_20B2B0(pc, d0.w)
	jmp     DrawObject.l
dat_20B2B0:
	dc.w	ObjMosqui_Init-dat_20B2B0
	dc.w	loc_20B302-dat_20B2B0
	dc.w	loc_20B30C-dat_20B2B0
ObjMosqui_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  #$638b, d0
	cmpi.b  #$2, act.l
	bne.s   loc_20B2EA
	move.w  #$642a, d0
loc_20B2EA:
	move.w  d0, oTile(a0)
	move.l  #$20b31c, oMap(a0)
	moveq   #$a, d0
	bsr.w   AddPoints
	moveq   #$0, d1
	bsr.w   sub_205FC0
loc_20B302:
	lea     dat_20B312(pc), a1
	jmp     AnimateObject.l
loc_20B30C:
	jmp     DeleteObject.l
dat_20B312:
	dc.w	$0002,$0200,$0000,$0101,$FC00
loc_20B31C:
	dc.w	$0004,$000F,$02F0,$0700,$00F0,$F007,$0800,$0002
	dc.w	$F007,$0008,$F0F0,$0708,$0800
Obj2D_20B336:
	move.b  oSubtype(a0), d0
	subq.b  #$1, d0
	bmi.s   loc_20B342
	bra.w   loc_20B55E
loc_20B342:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20B362(pc, d0.w), d0
	jsr     dat_20B362(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
dat_20B362:
	dc.w	loc_20B36C-dat_20B362
	dc.w	loc_20B3B0-dat_20B362
	dc.w	loc_20B3C4-dat_20B362
	dc.w	loc_20B3F2-dat_20B362
	dc.w	loc_20B452-dat_20B362
loc_20B36C:
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$0, oMapFrame(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.w  #$a421, oTile(a0)
	move.w  #$3d, $2a(a0)
	lea     dat_20B4BE(pc), a1
	tst.b   oSubtype(a0)
	bmi.s   loc_20B3AC
	lea     dat_20B500(pc), a1
	st.b    $3f(a0)
loc_20B3AC:
	move.l  a1, oMap(a0)
loc_20B3B0:
	addi.w  #$ffff, $2a(a0)
	bne.s   loc_20B3C2
	addq.b  #$2, oRoutine(a0)
	move.w  #$3d, $2a(a0)
loc_20B3C2:
	rts     
loc_20B3C4:
	addi.w  #$ffff, $2a(a0)
	bne.s   loc_20B3E0
	move.b  #$25, oColType(a0)
	addq.b  #$2, oRoutine(a0)
	addq.b  #$1, oAnim(a0)
	move.w  #$33, $2a(a0)
loc_20B3E0:
	lea     loc_20B4AA.l, a1
	jsr     AnimateObject.l
	jmp     DrawObject.l
loc_20B3F2:
	addi.w  #$ffff, $2a(a0)
	bne.s   loc_20B450
	move.b  #$26, oColType(a0)
	addq.b  #$2, oRoutine(a0)
	addq.b  #$1, oAnim(a0)
	move.l  #$8000, $30(a0)
	move.w  #$20, $2a(a0)
	move.l  #$ffff8000, $2c(a0)
	tst.b   oSubtype(a0)
	bpl.s   loc_20B432
	move.w  #$30, $2a(a0)
	move.l  #$ffffc000, $2c(a0)
loc_20B432:
	move.w  oX(a0), d0
	lea     objects.w, a1
	sub.w   $8(a1), d0
	bpl.s   loc_20B450
	neg.l   $2c(a0)
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$0, oFlags(a0)
loc_20B450:
	bra.s   loc_20B3E0
loc_20B452:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	move.l  $30(a0), d0
	add.l   d0, oY(a0)
	addi.w  #$ffff, $2a(a0)
	bne.s   loc_20B4A6
	move.w  #$41, $2a(a0)
	tst.b   oSubtype(a0)
	bpl.s   loc_20B47C
	move.w  #$61, $2a(a0)
loc_20B47C:
	neg.l   $30(a0)
	tst.b   $3f(a0)
	beq.s   loc_20B4A6
	jsr     FindObjSlot.l
	bne.s   loc_20B4A6
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler / suspicious)
	move.l  oX(a0), $8(a1)
	move.l  oY(a0), $c(a1)
	move.b  #$1, $28(a1)
loc_20B4A6:
	bra.w   loc_20B3E0
loc_20B4AA:
	dc.w	$0006,$000A,$000D,$1D00,$0101,$3102,$0204,$0304
	dc.w	$0504,$FF00
dat_20B4BE:
	dc.w	$0083,$0089,$008F,$000C,$0021,$0031,$04F6,$0C00
	dc.w	$2FF0,$FE00,$0004,$F0FE,$0400,$33F8,$0608,$0035
	dc.w	$F003,$F800,$000A,$F0F8,$0800,$38F8,$0008,$003B
	dc.w	$F003,$F600,$0011,$F0F6,$0400,$3EF8,$FE0C,$0040
	dc.w	$F000
dat_20B500:
	dc.w	$0041,$0047,$004D,$000C,$0021,$0031,$04F4,$0C00
	dc.w	$00F0,$FC00,$0004,$F0FC,$0400,$05F8,$0408,$0007
	dc.w	$F003,$F800,$000A,$F0F8,$0800,$0BF8,$0008,$000E
	dc.w	$F003,$F800,$0011,$F0F8,$0400,$12F8,$000C,$0014
	dc.w	$F001,$F409,$0018,$F401,$F40A,$001E,$F403,$F003
	dc.w	$0027,$F4F0,$0300,$2BFC,$F003,$0827,$0400
loc_20B55E:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20B572(pc, d0.w), d0
	jsr     dat_20B572(pc, d0.w)
	jmp     DrawObject.l
dat_20B572:
	dc.w	loc_20B578-dat_20B572
	dc.w	loc_20B5AE-dat_20B572
	dc.w	loc_20B5C8-dat_20B572
loc_20B578:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$6, oXRadius(a0)
	move.b  #$6, oWidth(a0)
	move.b  #$6, oYRadius(a0)
	move.w  #$a7ae, oTile(a0)
	move.l  #$209bf2, oMap(a0)
	move.w  #$b4, $2a(a0)
loc_20B5AE:
	addi.w  #$ffff, $2a(a0)
	beq.s   loc_20B5C8
	addi.l  #$10000, oY(a0)
	lea     dat_20B5CE(pc), a1
	jmp     AnimateObject.l
loc_20B5C8:
	jmp     DeleteObject.l
dat_20B5CE:
	dc.w	$0002,$0504,$0506,$07FF
Obj2B_20B5D6:
	dc.w	$4EF9,$0020,$3B1A,$0000
Obj2F_20B5DE:
	tst.b   oSubtype(a0)
	bmi.w   loc_20B5EA
	bra.w   loc_20B8B8
loc_20B5EA:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20B604(pc, d0.w), d0
	jsr     dat_20B604(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
dat_20B604:
	dc.w	loc_20B61A-dat_20B604
	dc.w	loc_20B65A-dat_20B604
	dc.w	loc_20B718-dat_20B604
	dc.w	loc_20B768-dat_20B604
	dc.w	loc_20B784-dat_20B604
	dc.w	loc_20B7A0-dat_20B604
	dc.w	loc_20B7CC-dat_20B604
	dc.w	loc_20B7F8-dat_20B604
	dc.w	loc_20B814-dat_20B604
	dc.w	loc_20B830-dat_20B604
	dc.w	loc_20B878-dat_20B604
loc_20B61A:
	cmpi.b  #$2, timeZone.l
	bne.w   loc_20B636
	tst.b   goodFuture.l
	beq.w   loc_20B636
	jmp     DeleteObject.l
loc_20B636:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$0, oPriority(a0)
	move.w  #$3af, oTile(a0)
	move.l  #$20b88e, oMap(a0)
	move.w  #$7, $30(a0)
loc_20B65A:
	tst.w   debugMode.l
	bne.w   loc_20B678
	lea     objects.w, a6
	lea     $3e(a0), a5
	bsr.w   sub_20B67A
	tst.b   $3e(a0)
	bne.w   loc_20B6FE
loc_20B678:
	rts     
sub_20B67A:
	tst.w   $12(a6)
	bmi.w   loc_20B6FC
	cmpi.b  #$4, $24(a6)
	beq.w   loc_20B6FC
	cmpi.b  #$6, $24(a6)
	beq.w   loc_20B6FC
	move.w  $c(a6), d0
	sub.w   oY(a0), d0
	subi.w  #$ffe8, d0
	subi.w  #$10, d0
	bcc.w   loc_20B6FC
	move.w  $8(a6), d0
	sub.w   oX(a0), d0
	subi.w  #$ffe8, d0
	subi.w  #$30, d0
	bcc.w   loc_20B6FC
	st.b    (a5)
	bset.b  #$0, $2c(a6)
	bset.b  #$2, $22(a6)
	move.b  #$e, $16(a6)
	move.b  #$7, $17(a6)
	move.b  #$2, $1c(a6)
	move.w  #$0, $10(a6)
	move.w  #$f800, $12(a6)
	move.w  oX(a0), $8(a6)
	move.w  oY(a0), d0
	addi.w  #$fff0, d0
	move.w  d0, $c(a6)
loc_20B6FC:
	rts     
loc_20B6FE:
	addq.b  #$2, oRoutine(a0)
	move.w  #$8, $2a(a0)
	move.b  #$1, oMapFrame(a0)
	move.w  #$d7, d0
	jmp     PlayFMSound.l
loc_20B718:
	addi.w  #$ffff, $2a(a0)
	bpl.w   loc_20B760
	addq.b  #$2, oRoutine(a0)
	move.b  #$2, oMapFrame(a0)
	move.w  #$6, $2a(a0)
	jsr     FindObjSlot.l
	bne.w   loc_20B762
	move.w  a1, $2c(a0)
	move.w  a0, $2e(a1)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	lea     objects.w, a6
	bset.b  #$6, $2c(a6)
loc_20B760:
	rts     
loc_20B762:
	jmp     DeleteObject.l
loc_20B768:
	addi.w  #$ffff, $2a(a0)
	bpl.w   loc_20B782
	addq.b  #$2, oRoutine(a0)
	move.w  #$2, $2a(a0)
	move.b  #$3, oMapFrame(a0)
loc_20B782:
	rts     
loc_20B784:
	addi.w  #$ffff, $2a(a0)
	bpl.w   loc_20B79E
	addq.b  #$2, oRoutine(a0)
	move.w  #$1e, $2a(a0)
	move.b  #$0, oMapFrame(a0)
loc_20B79E:
	rts     
loc_20B7A0:
	addi.w  #$ffff, $2a(a0)
	bpl.w   loc_20B7CA
	addq.b  #$2, oRoutine(a0)
	move.w  #$1e, $2a(a0)
	tst.w   $30(a0)
	beq.s   loc_20B7CA
	subq.w  #$1, $30(a0)
	moveq   #$a, d0
	bsr.w   AddPoints
	moveq   #$0, d1
	bra.w   sub_205FC0
loc_20B7CA:
	rts     
loc_20B7CC:
	addi.w  #$ffff, $2a(a0)
	bpl.w   loc_20B7F6
	addq.b  #$2, oRoutine(a0)
	move.w  #$1e, $2a(a0)
	tst.w   $30(a0)
	beq.s   loc_20B7F6
	subq.w  #$1, $30(a0)
	moveq   #$a, d0
	bsr.w   AddPoints
	moveq   #$0, d1
	bra.w   sub_205FC0
loc_20B7F6:
	rts     
loc_20B7F8:
	addi.w  #$ffff, $2a(a0)
	bpl.w   loc_20B812
	addq.b  #$2, oRoutine(a0)
	move.w  #$4, $2a(a0)
	move.b  #$3, oMapFrame(a0)
loc_20B812:
	rts     
loc_20B814:
	addi.w  #$ffff, $2a(a0)
	bpl.w   loc_20B82E
	addq.b  #$2, oRoutine(a0)
	move.w  #$6, $2a(a0)
	move.b  #$2, oMapFrame(a0)
loc_20B82E:
	rts     
loc_20B830:
	addi.w  #$ffff, $2a(a0)
	bpl.w   loc_20B876
	move.w  #$9f, d0
	jsr     PlayFMSound.l
	addq.b  #$2, oRoutine(a0)
	move.b  #$0, oMapFrame(a0)
	move.w  #$78, $2a(a0)
	movea.w $2c(a0), a1
	move.b  #$4, $24(a1)
	tst.b   $3e(a0)
	beq.w   loc_20B876
	sf.b    $3e(a0)
	bclr.b  #$0, $FFFFD02C.w
	bclr.b  #$6, $FFFFD02C.w
loc_20B876:
	rts     
loc_20B878:
	addi.w  #$ffff, $2a(a0)
	bpl.w   loc_20B88C
	move.b  #$2, oRoutine(a0)
	sf.b    $3e(a0)
loc_20B88C:
	rts     
loc_20B88E:
	dc.w	$0008,$0009,$0014,$001F,$0002,$F809,$C000,$E8F8
	dc.w	$09C8,$0000,$02E8,$0500,$06F0,$E805,$0806,$0002
	dc.w	$F000,$000A,$F8F0,$0008,$0A00
loc_20B8B8:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20B8C6(pc, d0.w), d0
	jmp     dat_20B8C6(pc, d0.w)
dat_20B8C6:
	dc.w	loc_20B8CC-dat_20B8C6
	dc.w	loc_20B8F6-dat_20B8C6
	dc.w	loc_20B91A-dat_20B8C6
loc_20B8CC:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$0, oPriority(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.w  #$43af, oTile(a0)
	move.l  #$20b926, oMap(a0)
loc_20B8F6:
	movea.w $2e(a0), a1
	dc.b	$0C,$29,$00,$2F,$00,$00		; cmpi.b #$2f, $0(a1) (raw: not reproducible by assembler / suspicious)
	beq.w   loc_20B90A
	jmp     DeleteObject.l
loc_20B90A:
	lea     dat_20B920(pc), a1
	jsr     AnimateObject.l
	jmp     DrawObject.l
loc_20B91A:
	jmp     DeleteObject.l
dat_20B920:
	dc.w	$0002,$0300,$01FF
loc_20B926:
	dc.w	$0004,$000F,$02F8,$0900,$00E8,$F809,$0800,$0000
Obj2E_20B936:
	move.b  oSubtype(a0), d0
	addi.b  #$ff, d0
	bmi.s   loc_20B944
	bra.w   loc_20BC42
loc_20B944:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20B96E(pc, d0.w), d0
	jsr     dat_20B96E(pc, d0.w)
	lea     dat_20BB56(pc), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
dat_20B96E:
	dc.w	loc_20B97A-dat_20B96E
	dc.w	loc_20B9B8-dat_20B96E
	dc.w	loc_20B9F2-dat_20B96E
	dc.w	loc_20BA42-dat_20B96E
	dc.w	loc_20BAD6-dat_20B96E
	dc.w	loc_20BAE0-dat_20B96E
loc_20B97A:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$84, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$6, oColType(a0)
	move.b  #$e, oWidth(a0)
	move.b  #$e, oYRadius(a0)
	move.w  #$a46a, oTile(a0)
	lea     dat_20BB5E(pc), a1
	tst.b   oSubtype(a0)
	bmi.s   loc_20B9B4
	lea     dat_20BBD0(pc), a1
	st.b    $3f(a0)
loc_20B9B4:
	move.l  a1, oMap(a0)
loc_20B9B8:
	addi.l  #$10000, oY(a0)
	jsr     ObjGetFloorDist.l
	subq.w  #$8, d1
	bgt.s   loc_20B9F0
	sub.w   d1, oY(a0)
	move.l  oY(a0), $32(a0)
	move.l  #$3000, $2e(a0)
	move.w  #$8, $36(a0)
	addq.b  #$2, oRoutine(a0)
	tst.l   $2a(a0)
	beq.s   loc_20B9F0
	addq.b  #$2, oRoutine(a0)
loc_20B9F0:
	rts     
loc_20B9F2:
	bsr.w   sub_20BB12
	lea     objects.w, a1
	move.w  oY(a0), d0
	sub.w   $c(a1), d0
	subi.w  #$ffb0, d0
	subi.w  #$a0, d0
	bcc.s   loc_20BA40
	move.w  oX(a0), d0
	sub.w   $8(a1), d0
	move.w  d0, d1
	subi.w  #$ffb0, d0
	subi.w  #$a0, d0
	bcc.s   loc_20BA40
	addq.b  #$2, oRoutine(a0)
	move.l  #$ffff4000, $2a(a0)
	tst.w   d1
	bmi.s   loc_20BA40
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	neg.l   $2a(a0)
loc_20BA40:
	rts     
loc_20BA42:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	move.l  $32(a0), oY(a0)
	moveq   #$0, d3
	move.b  oXRadius(a0), d3
	lea     ObjGetLWallDist.l, a1
	tst.l   $2a(a0)
	bmi.s   loc_20BA68
	lea     ObjGetRWallDist.l, a1
loc_20BA68:
	jsr     (a1)
	tst.w   d1
	bmi.s   loc_20BAC0
	jsr     ObjGetFloorDist.l
	cmpi.w  #$10, d1
	bge.s   loc_20BAC6
	subq.w  #$8, d1
	add.w   d1, oY(a0)
	move.l  oY(a0), $32(a0)
	bsr.w   sub_20BB12
	tst.b   $3f(a0)
	beq.s   loc_20BABE
	andi.w  #$7f, $36(a0)
	bne.s   loc_20BABE
	jsr     FindObjSlot.l
	bne.s   loc_20BABE
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler / suspicious)
	move.l  oX(a0), $8(a1)
	move.l  oY(a0), $c(a1)
	addi.w  #$10, $c(a1)
	move.b  #$1, $28(a1)
loc_20BABE:
	rts     
loc_20BAC0:
	addq.b  #$2, oRoutine(a0)
	rts     
loc_20BAC6:
	addq.b  #$4, oRoutine(a0)
	bsr.w   sub_20BB12
	move.l  oY(a0), $32(a0)
	rts     
loc_20BAD6:
	addi.l  #$ffff8000, oY(a0)
	rts     
loc_20BAE0:
	move.l  $2a(a0), d0
	add.l   d0, oX(a0)
	move.w  oX(a0), d3
	moveq   #$0, d4
	move.b  oWidth(a0), d4
	sub.w   d4, d3
	tst.l   $2a(a0)
	bpl.s   loc_20BAFE
	add.w   d4, d3
	add.w   d4, d3
loc_20BAFE:
	jsr     ObjGetFloorDist2.l
	cmpi.w  #$10, d1
	blt.s   loc_20BB10
	addi.b  #$f8, oRoutine(a0)
loc_20BB10:
	rts     
sub_20BB12:
	addq.w  #$1, $36(a0)
	move.l  $2e(a0), d0
	add.l   d0, oY(a0)
	move.w  $36(a0), d0
	andi.w  #$f, d0
	bne.s   loc_20BB2C
	neg.l   $2e(a0)
loc_20BB2C:
	rts     
	lea     objects.w, a1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	subi.w  #$ff00, d0
	subi.w  #$200, d0
	bcc.s   loc_20BB54
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	subi.w  #$ff00, d0
	subi.w  #$200, d0
loc_20BB54:
	rts     
dat_20BB56:
	dc.w	$0002,$0300,$0102,$FF00
dat_20BB5E:
	dc.w	$0006,$002A,$004E,$07F0,$0800,$00F8,$F80C,$0003
	dc.w	$F000,$0400,$24F0,$0000,$0026,$0000,$0100,$0A08
	dc.w	$0800,$000C,$F008,$0400,$27F8,$07F0,$0D00,$0FF0
	dc.w	$0004,$0024,$F000,$0000,$2900,$0000,$0018,$0808
	dc.w	$0000,$0CF0,$0804,$0027,$F808,$0000,$1908,$07F0
	dc.w	$0D00,$1AF0,$0004,$0024,$F000,$0000,$2A00,$0000
	dc.w	$0023,$0808,$0000,$0CF0,$0804,$0027,$F808,$0000
	dc.w	$1908
dat_20BBD0:
	dc.w	$0006,$002A,$004E,$07F0,$0800,$00F8,$F80C,$0003
	dc.w	$F000,$0400,$07F0,$0000,$0009,$0000,$0100,$0A08
	dc.w	$0800,$000C,$F008,$0400,$0DF8,$07F0,$0D00,$0FF0
	dc.w	$0004,$0007,$F000,$0000,$1700,$0000,$0018,$0808
	dc.w	$0000,$0CF0,$0804,$000D,$F808,$0000,$1908,$07F0
	dc.w	$0D00,$1AF0,$0004,$0007,$F000,$0000,$2200,$0000
	dc.w	$0023,$0808,$0000,$0CF0,$0804,$000D,$F808,$0000
	dc.w	$1908
loc_20BC42:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20BC56(pc, d0.w), d0
	jsr     dat_20BC56(pc, d0.w)
	jmp     DrawObject.l
dat_20BC56:
	dc.w	loc_20BC60-dat_20BC56
	dc.w	loc_20BC96-dat_20BC56
	dc.w	loc_20BCBE-dat_20BC56
	dc.w	loc_20BCD8-dat_20BC56
	dc.w	loc_20BCF4-dat_20BC56
loc_20BC60:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$2, oPriority(a0)
	move.b  #$8b, oColType(a0)
	move.b  #$6, oXRadius(a0)
	move.b  #$6, oWidth(a0)
	move.b  #$6, oYRadius(a0)
	move.w  #$495, oTile(a0)
	move.l  #$20bd1e, oMap(a0)
loc_20BC96:
	tst.b   oColStatus(a0)
	bne.s   loc_20BCF4
	addi.l  #$10000, oY(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   loc_20BCBC
	add.w   d1, oY(a0)
	move.w  #$78, $2a(a0)
	addq.b  #$2, oRoutine(a0)
loc_20BCBC:
	rts     
loc_20BCBE:
	tst.b   oColStatus(a0)
	bne.s   loc_20BCF4
	addi.w  #$ffff, $2a(a0)
	bne.s   loc_20BCD6
	move.w  #$78, $2a(a0)
	addq.b  #$2, oRoutine(a0)
loc_20BCD6:
	rts     
loc_20BCD8:
	tst.b   oColStatus(a0)
	bne.s   loc_20BCF4
	addi.w  #$ffff, $2a(a0)
	bne.s   loc_20BCEA
	addq.b  #$2, oRoutine(a0)
loc_20BCEA:
	lea     dat_20BD18(pc), a1
	jmp     AnimateObject.l
loc_20BCF4:
	move.b  #$18, oID(a0)
	move.b  #$0, oRoutine(a0)
	move.b  #$1, oSolidType(a0)
	tst.b   oSprFlags(a0)
	bpl.s   loc_20BD16
	move.w  #$9e, d0
	jsr     PlayFMSound.l
loc_20BD16:
	rts     
dat_20BD18:
	dc.w	$0002,$0100,$01FF
loc_20BD1E:
	dc.w	$0004,$000A,$01F8,$0500,$00F8,$01F8,$0500,$04F8
Obj2C_20BD2E:
	move.b  oSubtype(a0), d0
	bpl.s   loc_20BD38
	bra.w   loc_20BEA0
loc_20BD38:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20BD52(pc, d0.w), d0
	jsr     dat_20BD52(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
dat_20BD52:
	dc.w	loc_20BD56-dat_20BD52
	dc.w	loc_20BE16-dat_20BD52
loc_20BD56:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$8, oYRadius(a0)
	move.l  #$20be98, oMap(a0)
	move.w  #$3bd, oTile(a0)
	move.w  #$100, $2c(a0)
	move.b  oSubtype(a0), d0
	beq.s   loc_20BD90
	neg.w   $2c(a0)
loc_20BD90:
	jsr     FindNextObjSlot.l
	bne.w   loc_20BE10
	move.w  a0, $3e(a1)
	move.w  a1, $2e(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler / suspicious)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	jsr     FindNextObjSlot.l
	bne.w   loc_20BE10
	move.w  a0, $3e(a1)
	move.w  a1, $30(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler / suspicious)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	jsr     FindNextObjSlot.l
	bne.w   loc_20BE10
	move.w  a0, $3e(a1)
	move.w  a1, $32(a0)
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler / suspicious)
	move.b  #$ff, $28(a1)
	move.b  #$8, $19(a1)
	move.b  #$8, $16(a1)
	bra.s   loc_20BE16
loc_20BE10:
	jmp     DeleteObject.l
loc_20BE16:
	move.w  $2c(a0), d0
	add.w   d0, $2a(a0)
	move.w  $2a(a0), d0
	lsr.w   #$8, d0
	jsr     CalcSine.l
	swap    d0
	swap    d1
	clr.w   d0
	clr.w   d1
	asr.l   #$2, d0
	asr.l   #$2, d1
	move.l  d0, d4
	move.l  d1, d5
	asr.l   #$1, d0
	asr.l   #$1, d1
	move.l  d0, d2
	move.l  d1, d3
	asr.l   #$1, d0
	asr.l   #$1, d1
	movea.w $2e(a0), a1
	move.l  oY(a0), $2e(a1)
	move.l  oX(a0), $2a(a1)
	add.l   d0, $2e(a1)
	add.l   d1, $2a(a1)
	movea.w $30(a0), a1
	move.l  oY(a0), $2e(a1)
	move.l  oX(a0), $2a(a1)
	add.l   d2, $2e(a1)
	add.l   d3, $2a(a1)
	movea.w $32(a0), a1
	move.l  oY(a0), $2e(a1)
	move.l  oX(a0), $2a(a1)
	add.l   d0, $2e(a1)
	add.l   d1, $2a(a1)
	add.l   d2, $2e(a1)
	add.l   d3, $2a(a1)
	rts     
loc_20BE98:
	dc.w	$0002,$01F8,$0500,$00F8
loc_20BEA0:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20BEC6(pc, d0.w), d0
	jsr     dat_20BEC6(pc, d0.w)
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$2C,$00,$00		; cmpi.b #$2c, $0(a1) (raw: not reproducible by assembler / suspicious)
	beq.s   loc_20BEC0
	jmp     DeleteObject.l
loc_20BEC0:
	jmp     DrawObject.l
dat_20BEC6:
	dc.w	loc_20BECA-dat_20BEC6
	dc.w	loc_20BEEE-dat_20BEC6
loc_20BECA:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.l  #$20befc, oMap(a0)
	move.w  #$3bd, oTile(a0)
	move.b  #$8b, oColType(a0)
loc_20BEEE:
	move.w  $2a(a0), oX(a0)
	move.w  $2e(a0), oY(a0)
	rts     
loc_20BEFC:
	dc.w	$0002,$01F8,$0500,$04F8
LoadSectionArt:
	lea     SectionRanges(pc), a1
	moveq   #$0, d0
	moveq   #$0, d1
	move.w  cameraX.w, d0
loc_20BF10:
	cmp.w   (a1)+, d0
	bcs.s   loc_20BF18
	addq.b  #$2, d1
	bra.s   loc_20BF10
loc_20BF18:
	move.b  d1, sectionID.l
	move.w  SectionInitPLCs(pc, d1.w), d0
	jmp     LoadPLC.l
UpdateSectionArt:
	lea     SectionRanges(pc), a1
	moveq   #$0, d0
	moveq   #$0, d1
	move.w  cameraX.w, d0
loc_20BF34:
	cmp.w   (a1)+, d0
	bcs.s   loc_20BF3C
	addq.b  #$2, d1
	bra.s   loc_20BF34
loc_20BF3C:
	cmp.b   sectionID.l, d1
	bne.s   loc_20BF46
	rts     
loc_20BF46:
	move.b  d1, sectionID.l
	move.w  SectionUpdatePLCs(pc, d1.w), d0
	jmp     InitPLC.l
SectionRanges:
	dc.w	$04A0,$1000,$1800,$FFFF
SectionUpdatePLCs:
	dc.w	$0007,$0008,$0009,$000A
SectionInitPLCs:
	dc.w	$0002,$0004,$0005,$0006
SetObjectTileID:
	move.w  #$4f2, oTile(a0)
	rts     
Obj20_20BF76:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20BFD6(pc, d0.w), d0
	jsr     dat_20BFD6(pc, d0.w)
	jsr     DrawObject.l
	moveq   #$0, d1
	move.w  $34(a0), d1
	beq.s   loc_20BFB4
	movea.w d1, a1
	move.w  $8(a1), oX(a0)
	move.w  $c(a1), oY(a0)
	move.b  $38(a0), d0
	ext.w   d0
	add.w   d0, oX(a0)
	move.b  $39(a0), d0
	ext.w   d0
	add.w   d0, oY(a0)
loc_20BFB4:
	move.w  $36(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.s   loc_20BFD2
	rts     
loc_20BFD2:
	bra.w   loc_20CFDE
dat_20BFD6:
	dc.w	loc_20BFE6-dat_20BFD6
	dc.w	loc_20C044-dat_20BFD6
dat_20BFDA:
	dc.w	loc_20CFDE-dat_20BFD6
	dc.w	$0012
	cmpi.l  #$c10820c, d3
	move.b  d2, (a0)
loc_20BFE6:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$31e, d0
	cmpi.b  #$2, act.l
	bne.s   loc_20C002
	move.w  #$3fc, d0
loc_20C002:
	move.w  d0, oTile(a0)
	move.b  #$3, oPriority(a0)
	move.l  #$20c184, oMap(a0)
	move.w  oX(a0), $36(a0)
	move.w  oY(a0), $32(a0)
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	andi.b  #$3, d0
	move.b  d0, d1
	move.b  d0, oMapFrame(a0)
	add.b   d0, d0
	add.b   d1, d0
	lea     dat_20BFDA(pc, d0.w), a1
	move.b  (a1)+, oWidth(a0)
	move.b  (a1)+, oYRadius(a0)
	move.b  (a1)+, oColType(a0)
loc_20C044:
	jsr     dat_20C0AE(pc)
	tst.b   oMapFrame(a0)
	beq.s   loc_20C058
	lea     objects.w, a1
	jmp     SolidObject.l
loc_20C058:
	lea     objects.w, a1
	jsr     SolidObject.l
	beq.s   loc_20C0AC
	btst.b  #$3, oFlags(a0)
	beq.s   loc_20C0AC
	tst.b   timeWarp.l
	bne.s   loc_20C0AC
	tst.b   invincible.l
	bne.s   loc_20C0AC
	move.l  a0, -(a7)
	movea.l a0, a2
	lea     objects.w, a0
	cmpi.b  #$4, oRoutine(a0)
	bcc.s   loc_20C0AA
	tst.w   $30(a0)
	bne.s   loc_20C0AA
	move.l  oY(a0), d3
	move.w  oYVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	sub.l   d0, d3
	move.l  d3, oY(a0)
	jsr     HurtPlayer.l
loc_20C0AA:
	movea.l (a7)+, a0
loc_20C0AC:
	rts     
dat_20C0AE:
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	btst.l  #$2, d0
	beq.s   loc_20C0C8
	andi.b  #$3, d0
	add.w   d0, d0
	move.w  dat_20C0CA(pc, d0.w), d0
	jmp     dat_20C0CA(pc, d0.w)
loc_20C0C8:
	rts     
dat_20C0CA:
	dc.w	loc_20C0D2-dat_20C0CA
	dc.w	loc_20C0E6-dat_20C0CA
	dc.w	loc_20C0FC-dat_20C0CA
	dc.w	loc_20C112-dat_20C0CA
loc_20C0D2:
	jsr     dat_20C126(pc)
	moveq   #$0, d0
	move.b  $3b(a0), d0
	add.w   $32(a0), d0
	move.w  d0, oY(a0)
	rts     
loc_20C0E6:
	jsr     dat_20C126(pc)
	moveq   #$0, d0
	move.b  $3b(a0), d0
	neg.w   d0
	add.w   $32(a0), d0
	move.w  d0, oY(a0)
	rts     
loc_20C0FC:
	jsr     dat_20C126(pc)
	moveq   #$0, d0
	move.b  $3b(a0), d0
	neg.w   d0
	add.w   $36(a0), d0
	move.w  d0, oX(a0)
	rts     
loc_20C112:
	jsr     dat_20C126(pc)
	moveq   #$0, d0
	move.b  $3b(a0), d0
	add.w   $36(a0), d0
	move.w  d0, oX(a0)
	rts     
dat_20C126:
	tst.b   $3a(a0)
	beq.s   loc_20C144
	subq.b  #$1, $3a(a0)
	bne.s   loc_20C182
	btst.b  #$7, oSprFlags(a0)
	beq.s   loc_20C144
	move.w  #$b7, d0
	jsr     PlayFMSound.l
loc_20C144:
	tst.b   $3c(a0)
	beq.s   loc_20C164
	subq.b  #$8, $3b(a0)
	bcc.s   loc_20C182
	move.b  #$0, $3b(a0)
	move.b  #$0, $3c(a0)
	move.b  #$3c, $3a(a0)
	bra.s   loc_20C182
loc_20C164:
	addq.b  #$8, $3b(a0)
	cmpi.b  #$20, $3b(a0)
	bcs.s   loc_20C182
	move.b  #$20, $3b(a0)
	move.b  #$1, $3c(a0)
	move.b  #$3c, $3a(a0)
loc_20C182:
	rts     
loc_20C184:
	dc.w	$0008,$000E,$0014,$001A,$01F0,$0F00,$00F0,$01F0
	dc.w	$0F10,$00F0,$01F0,$0F00,$10F0,$01F0,$0F08,$10F0
Obj21_20C1A4:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20C1DA(pc, d0.w), d0
	jsr     dat_20C1DA(pc, d0.w)
	jsr     DrawObject.l
	move.w  $32(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.s   loc_20C1D6
	rts     
loc_20C1D6:
	bra.w   loc_20CFDE
dat_20C1DA:
	dc.w	loc_20C1DE-dat_20C1DA
	dc.w	loc_20C254-dat_20C1DA
loc_20C1DE:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$433e, oTile(a0)
	move.b  #$3, oPriority(a0)
	move.l  #$20c2da, oMap(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  oX(a0), $32(a0)
	move.w  oY(a0), $30(a0)
	cmpi.b  #$2, oSubtype(a0)
	bcs.s   loc_20C254
	jsr     FindNextObjSlot.l
	beq.s   loc_20C22A
	jmp     DeleteObject.l
loc_20C22A:
	dc.b	$13,$7C,$00,$0A,$00,$00		; move.b #$a, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  #$ea, $39(a1)
	move.w  a0, $34(a1)
	move.b  oSubtype(a0), d0
	andi.b  #$1, d0
	add.b   d0, d0
	move.b  d0, $28(a1)
loc_20C254:
	bsr.s   sub_20C2B8
	tst.b   timeZone.l
	beq.s   loc_20C28A
loc_20C25E:
	cmpi.b  #$1, oSubtype(a0)
	beq.s   loc_20C28A
	tst.b   $3a(a0)
	bne.s   loc_20C28C
	moveq   #$0, d0
	move.b  $3b(a0), d0
	add.b   d0, d0
	add.b   d0, d0
	lea     dat_20C2CA(pc, d0.w), a1
	move.b  (a1)+, $3a(a0)
	move.b  (a1)+, d0
	ext.w   d0
	move.w  d0, $38(a0)
	move.w  (a1)+, $36(a0)
loc_20C28A:
	rts     
loc_20C28C:
	move.w  $38(a0), d0
	add.w   d0, $36(a0)
	move.w  $36(a0), d0
	move.w  d0, oXVel(a0)
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, oX(a0)
	subq.b  #$1, $3a(a0)
	beq.s   loc_20C2AC
	rts     
loc_20C2AC:
	addq.b  #$1, $3b(a0)
	andi.b  #$3, $3b(a0)
	bra.s   loc_20C25E
sub_20C2B8:
	lea     objects.w, a1
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     SolidObject.l
dat_20C2CA:
	dc.w	$40F8,$0200,$40F8,$0000,$4008,$FE00,$4008,$0000
loc_20C2DA:
	dc.w	$0002,$01F0,$0F00,$00F0
Obj22_20C2E2:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20C318(pc, d0.w), d0
	jsr     dat_20C318(pc, d0.w)
	jsr     DrawObject.l
	move.w  $36(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.s   loc_20C314
	rts     
loc_20C314:
	bra.w   loc_20CFDE
dat_20C318:
	dc.w	loc_20C31C-dat_20C318
	dc.w	loc_20C3B8-dat_20C318
loc_20C31C:
	ori.b   #$4, oSprFlags(a0)
	move.w  #$39f, oTile(a0)
	move.b  #$3, oPriority(a0)
	move.l  #$20c442, oMap(a0)
	move.b  oSubtype(a0), d0
	lsr.b   #$2, d0
	move.b  d0, oMapFrame(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$e, oYRadius(a0)
	move.w  oX(a0), $36(a0)
	move.w  oY(a0), $32(a0)
	addq.b  #$2, oRoutine(a0)
	moveq   #$0, d0
	move.b  oSubtype(a0), d0
	andi.b  #$3, d0
	beq.s   loc_20C3B8
	moveq   #$20, d1
	cmpi.b  #$1, d0
	beq.s   loc_20C372
	moveq   #$a, d1
loc_20C372:
	jsr     FindNextObjSlot.l
	bne.s   loc_20C3B8
	dc.b	$13,$41,$00,$00		; move.b d1, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.w  a0, $34(a1)
	move.b  #$20, $38(a1)
	move.b  #$2, $28(a1)
	cmpi.b  #$20, d1
	beq.s   loc_20C3B8
	move.b  #$18, $38(a1)
	move.b  oSubtype(a0), d0
	andi.b  #$1, d0
	add.b   d0, d0
	ori.b   #$4, d0
	move.b  d0, $28(a1)
loc_20C3B8:
	jsr     dat_20C3CE(pc)
	lea     objects.w, a1
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     SolidObject.l
dat_20C3CE:
	btst.b  #$2, oSubtype(a0)
	bne.s   loc_20C3EA
	jsr     dat_20C400(pc)
	moveq   #$0, d0
	move.b  $3b(a0), d0
	add.w   $32(a0), d0
	move.w  d0, oY(a0)
	rts     
loc_20C3EA:
	jsr     dat_20C400(pc)
	moveq   #$0, d0
	move.b  $3b(a0), d0
	neg.w   d0
	add.w   $32(a0), d0
	move.w  d0, oY(a0)
	rts     
dat_20C400:
	lea     objects.w, a1
	move.w  oX(a0), d0
	move.b  oWidth(a0), d1
	ext.w   d1
	sub.w   d1, d0
	move.w  $8(a1), d1
	sub.w   d0, d1
	bcs.s   loc_20C42E
	cmpi.w  #$50, d1
	bcc.s   loc_20C420
	rts     
loc_20C420:
	subq.b  #$8, $3b(a0)
	bcc.s   loc_20C440
	move.b  #$0, $3b(a0)
	rts     
loc_20C42E:
	addq.b  #$8, $3b(a0)
	cmpi.b  #$20, $3b(a0)
	bcs.s   loc_20C440
	move.b  #$20, $3b(a0)
loc_20C440:
	rts     
loc_20C442:
	dc.w	$0004,$000A,$01F0,$0F00,$00F0,$01F0,$0F10,$00F0
Obj23_20C452:
	dc.w	$7000,$1028,$0024,$303B,$000C,$4EBB,$0008,$4EF9
	dc.w	$0020,$3A6E,$0004,$003A,$0028,$0004,$0001,$317C
	dc.w	$034E,$0002,$117C,$0003,$0018,$217C,$0020,$C7B0
	dc.w	$0004,$117C,$0020,$0019,$117C,$0010,$0016,$3168
	dc.w	$0008,$0032,$3168,$000C,$0030,$5428,$0024,$7000
	dc.w	$1028,$0028,$D000,$303B,$0036,$4EBB,$0032,$4EBA
	dc.w	$003E,$3028,$0032,$0240,$FF80,$3238,$F700,$0441
	dc.w	$0080,$0241,$FF80,$9041,$0C40,$0280,$6202,$4E75
	dc.w	$6000,$0B0A,$43F8,$D000,$4EF9,$0020,$8D46,$0052
	dc.w	$005E,$005E,$0114,$0114,$01D0,$01D0,$01D0,$4A28
	dc.w	$003F,$673A,$0828,$0003,$0022,$660C,$4A28,$003E
	dc.w	$672C,$5128,$003E,$600C,$0C28,$0040,$003E,$671E
	dc.w	$5028,$003E,$1028,$003E,$4EB9,$0020,$0782,$323C
	dc.w	$0400,$C1C1,$4840,$D068,$0030,$3140,$000C,$4E75
	dc.w	$117C,$0001,$003F,$4EBA,$FF9C,$4E75,$4A28,$0038
	dc.w	$663E,$117C,$0001,$003F,$43F9,$0020,$C5B4,$0C28
	dc.w	$0001,$0028,$6706,$43F9,$0020,$C5D4,$7000,$1028
	dc.w	$0039,$D000,$D000,$43F1,$0000,$1159,$0038,$1019
	dc.w	$4880,$3140,$0036,$3159,$0034,$4EBA,$FF58,$4E75
	dc.w	$3028,$0034,$3140,$0010,$48C0,$E180,$D1A8,$0008
	dc.w	$3028,$0036,$D168,$0034,$5328,$0038,$66DC,$5228
	dc.w	$0039,$0C28,$0008,$0039,$6692,$117C,$0002,$0039
	dc.w	$608A,$1C00,$0300,$08D0,$0300,$08D0,$0000,$3800
	dc.w	$FD00,$0830,$FD00,$0830,$0000,$3800,$0300,$08D0
	dc.w	$0300,$1C00,$FD00,$0830,$FD00,$0830,$0000,$3800
	dc.w	$0300,$08D0,$0300,$08D0,$0000,$3800,$FD00,$0830
	dc.w	$FD00,$4EBA,$FEE0,$4A28,$0038,$6638,$4228,$003F
	dc.w	$43F9,$0020,$C670,$0C28,$0003,$0028,$6706,$43F9
	dc.w	$0020,$C690,$7000,$1028,$0039,$D000,$D000,$43F1
	dc.w	$0000,$1159,$0038,$1019,$4880,$3140,$0036,$3159
	dc.w	$0034,$4E75,$3028,$0034,$48C0,$E180,$D1A8,$000C
	dc.w	$3028,$0036,$D168,$0034,$3028,$0034,$0240,$FF00
	dc.w	$3140,$0012,$5328,$0038,$66D8,$5228,$0039,$0C28
	dc.w	$0008,$0039,$668C,$117C,$0002,$0039,$6084,$2300
	dc.w	$FE00,$0840,$FE00,$0840,$0000,$4600,$0200,$08C0
	dc.w	$0200,$08C0,$0000,$4600,$FE00,$0840,$FE00,$2300
	dc.w	$0200,$08C0,$0200,$08C0,$0000,$4600,$FE00,$0840
	dc.w	$FE00,$0840,$0000,$4600,$0200,$08C0,$0200,$4EBA
	dc.w	$FE24,$7000,$1028,$003A,$303B,$0006,$4EFB,$0002
	dc.w	$0006,$003E,$00C8,$4A28,$0038,$6622,$117C,$0001
	dc.w	$003F,$6100,$0860,$3628,$0008,$3828,$000C,$4EB9
	dc.w	$0020,$8D46,$6706,$117C,$001E,$0038,$4E75,$5328
	dc.w	$0038,$66F8,$4228,$003F,$5428,$003A,$4E75,$4A28
	dc.w	$0038,$6640,$7000,$1028,$0028,$43F9,$0020,$C78C
	dc.w	$5B00,$6710,$43F9,$0020,$C798,$5300,$6706,$43F9
	dc.w	$0020,$C7A4,$7000,$1028,$0039,$D000,$D000,$43F1
	dc.w	$0000,$1159,$0038,$1019,$4880,$3140,$0036,$3159
	dc.w	$0034,$4E75,$3028,$0036,$D168,$0034,$3028,$0034
	dc.w	$3200,$0241,$FF00,$3141,$0012,$48C0,$E180,$D1A8
	dc.w	$000C,$5328,$0038,$66DA,$5228,$0039,$0C28,$0003
	dc.w	$0039,$668A,$4268,$0012,$117C,$0001,$003F,$3168
	dc.w	$000C,$0030,$5428,$003A,$4E75,$10F0,$0000,$3000
	dc.w	$FE00,$1010,$FE00,$10D0,$0000,$4500,$FD00,$1030
	dc.w	$FD00,$10C0,$0000,$5800,$FC00,$1040,$FC00,$0002
	dc.w	$02F0,$0F00,$00E0,$F00F,$0800,$0000
Obj26_20C7BE:
	dc.w	$7000,$1028,$0024,$303B,$002E,$4EBB,$002A,$4EB9
	dc.w	$0020,$3A6E,$3028,$0036,$0240,$FF80,$3238,$F700
	dc.w	$0441,$0080,$0241,$FF80,$9041,$0C40,$0280,$6202
	dc.w	$4E75,$6000,$07EC,$0008,$004E,$001E,$3C00,$0028
	dc.w	$0004,$0001,$317C,$0371,$0002,$117C,$0003,$0018
	dc.w	$217C,$0020,$C8D4,$0004,$117C,$001C,$0019,$117C
	dc.w	$0008,$0016,$3168,$0008,$0036,$3168,$000C,$0032
	dc.w	$7000,$1028,$0028,$0200,$000F,$117B,$00BE,$003A
	dc.w	$5428,$0024,$1028,$0028,$6A12,$6134,$7000,$1028
	dc.w	$003B,$D068,$0036,$3140,$0008,$6012,$6122,$7000
	dc.w	$1028,$003B,$4440,$D068,$0036,$3140,$0008,$43F8
	dc.w	$D000,$3628,$0008,$3828,$000C,$4EF9,$0020,$8D46
	dc.w	$6100,$06B6,$3029,$000C,$9068,$000C,$642C,$0428
	dc.w	$0010,$003B,$643E,$117C,$0000,$003B,$1028,$0028
	dc.w	$0200,$000F,$662E,$1028,$003C,$6628,$117C,$003C
	dc.w	$003A,$117C,$00FF,$003C,$4E75,$0628,$0010,$003B
	dc.w	$0C28,$0040,$003B,$650C,$117C,$0040,$003B,$117C
	dc.w	$0008,$003A,$4E75,$0002,$02F8,$0D00,$00E0,$F80D
	dc.w	$0800,$0000
Data_20C8E2:
	incbin	"Level/Collision Chaos/Data/Data_20C8E2.bin"
Obj28_20CD10:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20CD46(pc, d0.w), d0
	jsr     dat_20CD46(pc, d0.w)
	jsr     DrawObject.l
	move.w  $32(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.s   loc_20CD42
	rts     
loc_20CD42:
	bra.w   loc_20CFDE
dat_20CD46:
	dc.w	loc_20CDA2-dat_20CD46
	dc.w	loc_20CDF0-dat_20CD46
	dc.w	loc_20CE30-dat_20CD46
	dc.w	loc_20CE6A-dat_20CD46
sub_20CD4E:
	dc.w	loc_20D56E-dat_20CD46
	dc.w	$0007,$0001
	beq.s   loc_20CDA0
	tst.b   timeZone.l
	bne.s   loc_20CD8E
	moveq   #$8, d0
	cmpi.b  #$2, oMapFrame(a0)
	beq.s   loc_20CD8A
	moveq   #$5, d0
	cmpi.b  #$3, oMapFrame(a0)
	beq.s   loc_20CD8A
	cmpi.b  #$4, oMapFrame(a0)
	beq.s   loc_20CD8A
	cmpi.b  #$5, oMapFrame(a0)
	beq.s   loc_20CD8A
	cmpi.b  #$6, oMapFrame(a0)
	bne.s   loc_20CD8E
loc_20CD8A:
	move.b  d0, oYRadius(a0)
loc_20CD8E:
	lea     objects.w, a1
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     TopSolidObject.l
loc_20CDA0:
	rts     
loc_20CDA2:
	ori.b   #$4, oSprFlags(a0)
	move.w  #$36a, oTile(a0)
	move.b  #$3, oPriority(a0)
	move.l  #$20cf3c, oMap(a0)
	move.b  #$18, oWidth(a0)
	move.w  oX(a0), $32(a0)
	move.w  oY(a0), $30(a0)
	addq.b  #$2, oRoutine(a0)
	move.b  oSubtype(a0), d0
	move.b  d0, $3b(a0)
	cmpi.b  #$2, d0
	bcs.s   loc_20CDEE
	addq.b  #$2, oRoutine(a0)
	cmpi.b  #$6, d0
	bcs.s   loc_20CDEE
	addq.b  #$2, oRoutine(a0)
loc_20CDEE:
	rts     
loc_20CDF0:
	tst.b   $3a(a0)
	bne.s   loc_20CE04
	lea     objects.w, a1
	jsr     GetOffObject.l
	bra.w   loc_20CEC2
loc_20CE04:
	tst.b   timeZone.l
	beq.s   loc_20CE1C
	tst.b   aniArtTimers.w
	bne.s   loc_20CE1C
	bsr.w   sub_20CEB0
	subq.b  #$1, $3a(a0)
	beq.s   loc_20CE1E
loc_20CE1C:
	rts     
loc_20CE1E:
	addq.b  #$1, $3b(a0)
	cmpi.b  #$2, $3b(a0)
	bcs.s   loc_20CDF0
	addq.b  #$2, oRoutine(a0)
	rts     
loc_20CE30:
	bsr.w   sub_20CD4E
	tst.b   $3a(a0)
	bne.s   loc_20CE3E
	bra.w   loc_20CEC2
loc_20CE3E:
	tst.b   timeZone.l
	beq.s   loc_20CE56
	tst.b   aniArtTimers.w
	bne.s   loc_20CE56
	bsr.w   sub_20CEB0
	subq.b  #$1, $3a(a0)
	beq.s   loc_20CE58
loc_20CE56:
	rts     
loc_20CE58:
	addq.b  #$1, $3b(a0)
	cmpi.b  #$6, $3b(a0)
	bcs.s   loc_20CE30
	addq.b  #$2, oRoutine(a0)
	rts     
loc_20CE6A:
	tst.b   $3a(a0)
	bne.s   loc_20CE7E
	lea     objects.w, a1
	jsr     GetOffObject.l
	bra.w   loc_20CEC2
loc_20CE7E:
	tst.b   timeZone.l
	beq.s   loc_20CE96
	tst.b   aniArtTimers.w
	bne.s   loc_20CE96
	bsr.w   sub_20CEB0
	subq.b  #$1, $3a(a0)
	beq.s   loc_20CE98
loc_20CE96:
	rts     
loc_20CE98:
	addq.b  #$1, $3b(a0)
	cmpi.b  #$12, $3b(a0)
	bcs.s   loc_20CE6A
	clr.w   $3a(a0)
	move.b  #$2, oRoutine(a0)
	rts     
sub_20CEB0:
	move.w  $36(a0), d0
	move.w  d0, oYVel(a0)
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, oY(a0)
	rts     
loc_20CEC2:
	moveq   #$0, d0
	move.b  $3b(a0), d0
	add.b   d0, d0
	add.b   $3b(a0), d0
	lea     dat_20CEE6(pc, d0.w), a2
	move.b  (a2)+, $36(a0)
	move.b  (a2)+, oYRadius(a0)
	move.b  (a2)+, oMapFrame(a0)
	move.b  #$4, $3a(a0)
	bra.s   loc_20CF1C
dat_20CEE6:
	dc.w	$0108,$0005,$0801,$060C,$0208,$0B03,$080B,$0408
	dc.w	$0B05,$060B,$0605,$0807,$0108,$08FF,$0409,$FB04
	dc.w	$0AFA,$080A,$F808,$0AF8,$080A,$F808,$0AFA,$080A
	dc.w	$FB08,$0AFF,$040B
loc_20CF1C:
	moveq   #$0, d0
	move.b  oMapFrame(a0), d0
	move.b  dat_20CF2A(pc, d0.w), oPriority(a0)
	rts     
dat_20CF2A:
	btst.l  d2, d4
	btst.l  d1, d2
	dc.b	$02,$02,$03,$04		; andi.b #$4, d2 (raw: not reproducible by assembler / suspicious)
	btst.l  d2, d6
	dc.b	$06,$06,$43,$F8		; addi.b #$f8, d6 (raw: not reproducible by assembler / suspicious)
	add.b   d0, d0
	rts     
loc_20CF3C:
	dc.w	$0018,$0024,$0030,$003C,$0048,$0054,$0060,$006C
	dc.w	$0078,$0084,$0090,$0096,$02F0,$0900,$03E8,$F009
	dc.w	$0803,$0000,$02F4,$0900,$09E8,$F409,$0809,$0000
	dc.w	$02F8,$0900,$0FE8,$F809,$080F,$0000,$02FC,$0900
	dc.w	$15E8,$FC09,$0815,$0000,$02FC,$0900,$1BE8,$FC09
	dc.w	$081B,$0000,$02FC,$0910,$15E8,$FC09,$1815,$0000
	dc.w	$02FC,$0910,$0FE8,$FC09,$180F,$0000,$02FC,$0910
	dc.w	$09E8,$FC09,$1809,$0000,$0200,$0910,$03E8,$0009
	dc.w	$1803,$0000,$0200,$0810,$00E8,$0008,$1800,$0000
	dc.w	$00FC,$0010,$00E8,$02F8,$0800,$00E8,$F808,$0800
	dc.w	$0000
loc_20CFDE:
	moveq   #$0, d0
	move.b  oSavedFlagsID(a0), d0
	beq.s   loc_20D002
	lea     savedObjFlags.l, a1
	move.w  d0, d1
	add.w   d1, d1
	add.w   d1, d0
	moveq   #$0, d1
	move.b  timeZone.l, d1
	add.w   d1, d0
	bclr.b  #$7, $2(a1, d0.w)
loc_20D002:
	jmp     DeleteObject.l
Obj24_20D008:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20D022(pc, d0.w), d0
	jsr     dat_20D022(pc, d0.w)
	jmp     CheckObjDespawn.l
dat_20D022:
	dc.w	loc_20D030-dat_20D022
	dc.w	loc_20D082-dat_20D022
	dc.w	loc_20D0A4-dat_20D022
	dc.w	loc_20D10E-dat_20D022
	dc.w	loc_20D128-dat_20D022
	dc.w	loc_20D136-dat_20D022
	dc.w	loc_20D19E-dat_20D022
loc_20D030:
	move.l  #$2358ca, d1
	move.b  #$1, d0
	move.b  oSubtype(a0), $2e(a0)
	bpl.s   loc_20D04C
	move.l  #$235a7a, d1
	move.b  #$2, d0
loc_20D04C:
	move.b  d0, oMapFrame(a0)
	move.l  d1, oMap(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$14, oYRadius(a0)
	move.w  #$23f2, oTile(a0)
	move.w  #$100, oYVel(a0)
	move.b  #$6, oColType(a0)
	addq.b  #$2, oRoutine(a0)
loc_20D082:
	jsr     dat_20D1BC(pc)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   loc_20D094
	addq.b  #$2, oRoutine(a0)
loc_20D094:
	lea     dat_20D268(pc), a1
	jsr     AnimateObject.l
	jmp     DrawObject.l
loc_20D0A4:
	btst.b  #$7, oSprFlags(a0)
	beq.s   loc_20D0F2
	bclr.b  #$0, oSprFlags(a0)
	bclr.b  #$0, oFlags(a0)
	lea     objects.w, a1
	move.w  oX(a0), d0
	sub.w   $8(a1), d0
	bcc.s   loc_20D0D4
	neg.w   d0
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$0, oFlags(a0)
loc_20D0D4:
	tst.b   oSprFlags(a0)
	bpl.s   loc_20D0F2
	move.w  oY(a0), d1
	sub.w   $c(a1), d1
	bcc.s   loc_20D0E6
	neg.w   d1
loc_20D0E6:
	cmpi.w  #$20, d1
	bcc.s   loc_20D0F2
	cmpi.w  #$60, d0
	bcs.s   loc_20D0FA
loc_20D0F2:
	move.b  #$1, oAnim(a0)
	bra.s   loc_20D094
loc_20D0FA:
	move.b  #$2, oAnim(a0)
	jsr     dat_20D1D6(pc)
	move.w  #$78, $2c(a0)
	addq.b  #$2, oRoutine(a0)
loc_20D10E:
	subq.w  #$1, $2c(a0)
	beq.s   loc_20D118
	bra.w   loc_20D094
loc_20D118:
	move.b  #$3, oAnim(a0)
	move.w  #$3c, $2c(a0)
	addq.b  #$2, oRoutine(a0)
loc_20D128:
	subq.w  #$1, $2c(a0)
	beq.s   loc_20D132
	bra.w   loc_20D094
loc_20D132:
	addq.b  #$2, oRoutine(a0)
loc_20D136:
	move.w  #$100, d0
	tst.b   oSubtype(a0)
	bpl.s   loc_20D144
	move.w  #$80, d0
loc_20D144:
	move.b  #$0, oAnim(a0)
	btst.b  #$0, oFlags(a0)
	bne.s   loc_20D154
	neg.w   d0
loc_20D154:
	move.w  d0, oXVel(a0)
	jsr     dat_20D1BC(pc)
	jsr     Player_GetLWallDist.l
	tst.w   d1
	bmi.s   loc_20D18E
	jsr     Player_GetRWallDist.l
	tst.w   d1
	bmi.s   loc_20D18E
	jsr     ObjGetFloorDist.l
	tst.w   d1
	beq.s   loc_20D18A
	cmpi.w  #$7, d1
	bpl.s   loc_20D18E
	cmpi.w  #$fff9, d1
	bmi.s   loc_20D18E
	add.w   d1, oY(a0)
loc_20D18A:
	bra.w   loc_20D094
loc_20D18E:
	move.w  #$48, $2c(a0)
	move.w  #$3, oAnim(a0)
	addq.b  #$2, oRoutine(a0)
loc_20D19E:
	subq.w  #$1, $2c(a0)
	beq.s   loc_20D1A8
	bra.w   loc_20D094
loc_20D1A8:
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	subq.b  #$2, oRoutine(a0)
	bra.w   loc_20D094
dat_20D1BC:
	move.w  oXVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, oX(a0)
	move.w  oYVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, oY(a0)
	rts     
dat_20D1D6:
	tst.b   oSubtype(a0)
	bpl.s   loc_20D1DE
	rts     
loc_20D1DE:
	jsr     FindObjSlot.l
	bne.s   loc_20D222
	dc.b	$13,$7C,$00,$25,$00,$00		; move.b #$25, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  a0, $30(a1)
	move.w  #$40, $2c(a1)
	move.b  oSubtype(a0), $28(a1)
	move.b  oSprFlags(a0), $2e(a1)
	move.w  oY(a0), d0
	subq.w  #$4, d0
	move.w  d0, $c(a1)
	move.w  oX(a0), d0
	moveq   #$11, d1
	btst.b  #$0, oSprFlags(a0)
	bne.s   loc_20D21C
	neg.w   d1
loc_20D21C:
	add.w   d1, d0
	move.w  d0, $8(a1)
loc_20D222:
	jsr     FindObjSlot.l
	bne.s   loc_20D266
	dc.b	$13,$7C,$00,$25,$00,$00		; move.b #$25, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  a0, $30(a1)
	move.w  #$14, $2c(a1)
	move.b  oSubtype(a0), $28(a1)
	move.b  oSprFlags(a0), $2e(a1)
	move.w  oY(a0), d0
	subq.w  #$6, d0
	move.w  d0, $c(a1)
	move.w  oX(a0), d0
	moveq   #$9, d1
	btst.b  #$0, oSprFlags(a0)
	bne.s   loc_20D260
	neg.w   d1
loc_20D260:
	add.w   d1, d0
	move.w  d0, $8(a1)
loc_20D266:
	rts     
dat_20D268:
	dc.w	$000A,$0010,$0014,$0018,$001C,$0700,$0102,$03FF
	dc.w	$0705,$06FF,$0700,$04FF,$0707,$04FF,$0700,$FF00
Obj25_20D288:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20D2A6(pc, d0.w), d0
	jsr     dat_20D2A6(pc, d0.w)
	jsr     DrawObject.l
	move.w  $32(a0), d0
	jmp     CheckObjDespawn2.l
dat_20D2A6:
	dc.w	loc_20D2AC-dat_20D2A6
	dc.w	loc_20D2FC-dat_20D2A6
	dc.w	loc_20D330-dat_20D2A6
loc_20D2AC:
	move.b  #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.b  #$4, oXRadius(a0)
	move.b  #$4, oYRadius(a0)
	move.w  #$23f2, oTile(a0)
	move.l  #$20d3ec, oMap(a0)
	move.w  oX(a0), $32(a0)
	move.w  #$300, d1
	btst.b  #$0, $2e(a0)
	bne.s   loc_20D2F2
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$0, oFlags(a0)
	neg.w   d1
loc_20D2F2:
	move.w  d1, oXVel(a0)
	addq.b  #$2, oRoutine(a0)
	rts     
loc_20D2FC:
	subq.w  #$1, $2c(a0)
	bne.s   loc_20D312
	addq.b  #$2, oRoutine(a0)
	move.b  #$87, oColType(a0)
	move.b  #$3c, $34(a0)
loc_20D312:
	move.w  $30(a0), d0
	movea.w d0, a1
	dc.b	$0C,$29,$00,$24,$00,$00		; cmpi.b #$24, $0(a1) (raw: not reproducible by assembler / suspicious)
	beq.s   loc_20D326
	jmp     DeleteObject.l
loc_20D326:
	lea     dat_20D3D8(pc), a1
	jmp     AnimateObject.l
loc_20D330:
	jsr     dat_20D1BC(pc)
	move.w  $2a(a0), d0
	add.w   d0, oYVel(a0)
	cmpi.b  #$0, oMapFrame(a0)
	bne.s   loc_20D356
	btst.b  #$7, oSprFlags(a0)
	beq.s   loc_20D356
	move.w  #$b9, d0
	jsr     PlayFMSound.l
loc_20D356:
	lea     objects.w, a1
	bsr.s   sub_20D378
	beq.s   loc_20D360
	bsr.s   sub_20D3B8
loc_20D360:
	subq.b  #$1, $34(a0)
	bne.s   loc_20D36E
	addq.b  #$1, $34(a0)
	clr.b   oColType(a0)
loc_20D36E:
	lea     dat_20D3D8(pc), a1
	jmp     AnimateObject.l
sub_20D378:
	tst.b   invincible.l
	bne.s   loc_20D388
	btst.b  #$2, $22(a1)
	beq.s   loc_20D3B4
loc_20D388:
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	moveq   #$1c, d1
	add.w   d1, d0
	bmi.s   loc_20D3B4
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   loc_20D3B4
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	moveq   #$1c, d1
	add.w   d1, d0
	bmi.s   loc_20D3B4
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   loc_20D3B4
	moveq   #$1, d0
	rts     
loc_20D3B4:
	moveq   #$0, d0
	rts     
sub_20D3B8:
	clr.b   oColType(a0)
	move.b  #$1, oAnim(a0)
	move.w  $10(a1), d0
	add.w   d0, oXVel(a0)
	move.w  #$f800, oYVel(a0)
	move.w  #$40, $2a(a0)
	rts     
dat_20D3D8:
	dc.w	$0004,$000C,$0300,$0102,$0304,$05FF,$0000,$0102
	dc.w	$0304,$05FF
loc_20D3EC:
	dc.w	$000C,$0012,$0018,$001E,$0024,$002A,$01F8,$0500
	dc.w	$19F8,$01F8,$0500,$1DF8,$01F8,$0510,$19F8,$01F8
	dc.w	$0518,$19F8,$01F8,$0518,$1DF8,$01F8,$0508,$19F8
ObjCapsule:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20D448(pc, d0.w), d0
	jsr     dat_20D448(pc, d0.w)
	tst.b   oRoutine(a0)
	beq.s   loc_20D446
	cmpi.b  #$a, oRoutine(a0)
	beq.s   loc_20D440
	cmpi.b  #$6, oRoutine(a0)
	bcc.s   loc_20D446
loc_20D440:
	jmp     DrawObject.l
loc_20D446:
	rts     
dat_20D448:
	dc.w	ObjCapsule_Init-dat_20D448
	dc.w	ObjCapsule_Main-dat_20D448
	dc.w	ObjCapsule_Explode-dat_20D448
	dc.w	StartResults-dat_20D448
	dc.w	ResultsActive-dat_20D448
	dc.w	ObjCapsule_Seed-dat_20D448
ObjCapsule_Init:
	ori.b   #$4, oSprFlags(a0)
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oPriority(a0)
	move.l  #$23aa06, oMap(a0)
	move.w  #$2481, oTile(a0)
	move.b  #$20, oXRadius(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$18, oYRadius(a0)
ObjCapsule_Main:
	lea     Art_Projector.l, a1
	jsr     AnimateObject.l
	lea     objects.w, a6
	bsr.w   ObjCapsule_CheckHit
	beq.s   loc_20D4E6
	clr.b   updateHUDTime.l
	move.b  #$2, oMapFrame(a0)
	move.b  #$78, $2a(a0)
	addq.b  #$2, oRoutine(a0)
	move.w  $FFFFD008.w, d0
	move.b  $FFFFD017.w, d1
	ext.w   d1
	addi.w  #$20, d1
	sub.w   oX(a0), d0
	add.w   d1, d0
	bmi.s   loc_20D4DA
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   loc_20D4DA
	move.w  $FFFFD012.w, d0
	neg.w   d0
	asr.w   #$2, d0
	move.w  d0, $FFFFD012.w
	rts     
loc_20D4DA:
	move.w  $FFFFD010.w, d0
	neg.w   d0
	asr.w   #$2, d0
	move.w  d0, $FFFFD010.w
loc_20D4E6:
	rts     
ObjCapsule_Explode:
	subq.b  #$1, $2a(a0)
	bmi.s   loc_20D544
	move.b  $2a(a0), d0
	move.b  d0, d1
	andi.b  #$3, d1
	bne.s   loc_20D552
	lsr.w   #$2, d0
	andi.w  #$7, d0
	add.w   d0, d0
	lea     dat_20D554(pc, d0.w), a2
	jsr     FindObjSlot.l
	bne.s   loc_20D552
	move.w  #$9e, d0
	jsr     PlayFMSound.l
	dc.b	$13,$7C,$00,$18,$00,$00		; move.b #$18, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.b  #$1, $25(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  (a2), d0
	ext.w   d0
	add.w   d0, $8(a1)
	move.b  $1(a2), d0
	ext.w   d0
	add.w   d0, $c(a1)
	rts     
loc_20D544:
	bsr.w   ObjCapsule_SpawnSeeds
	addq.b  #$2, oRoutine(a0)
	move.b  #$3c, $2a(a0)
loc_20D552:
	rts     
dat_20D554:
	dc.w	$0000,$20F8,$E000,$E8F8,$1808,$F008,$1008,$F8F8
ObjCapsule_SpawnSeeds:
	moveq   #$0, d0
	move.b  $20fadc.l, d0
	move.l  d7, d6
loc_20D56E:
	jsr     LoadPalette.l
	move.l  d6, d7
	moveq   #$6, d6
	moveq   #$0, d1
loc_20D57A:
	jsr     FindObjSlot.l
	bne.s   loc_20D5C6
	dc.b	$13,$7C,$00,$15,$00,$00		; move.b #$15, $0(a1) (raw: not reproducible by assembler / suspicious)
	ori.b   #$4, $1(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  #$a, $24(a1)
	move.l  #$23aa06, $4(a1)
	move.w  #$2481, $2(a1)
	move.b  #$1, $1c(a1)
	move.w  #$fa00, $12(a1)
	move.w  dat_20D5C8(pc, d1.w), $10(a1)
	addq.w  #$2, d1
	dbra    d6, loc_20D57A
loc_20D5C6:
	rts     
dat_20D5C8:
	dc.w	$0000,$FF80,$0080,$FF00,$0100,$FE80,$0180,$FE00
	dc.w	$0200,$FD80,$0280
ObjCapsule_Seed:
	lea     Art_Projector.l, a1
	jsr     AnimateObject.l
	jsr     ObjMoveGrv.l
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   loc_20D60C
	move.b  #$1f, oID(a0)
	move.b  #$1, oSubtype(a0)
	move.b  #$0, oRoutine(a0)
loc_20D60C:
	rts     
ObjCapsule_CheckHit:
	btst.b  #$2, $22(a6)
	beq.s   loc_20D652
	move.b  $17(a6), d1
	ext.w   d1
	addi.w  #$20, d1
	move.w  $8(a6), d0
	sub.w   oX(a0), d0
	add.w   d1, d0
	bmi.s   loc_20D652
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   loc_20D652
	move.b  $16(a6), d1
	ext.w   d1
	addi.w  #$1c, d1
	move.w  $c(a6), d0
	sub.w   oY(a0), d0
	add.w   d1, d0
	bmi.s   loc_20D652
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   loc_20D652
	moveq   #$1, d0
	rts     
loc_20D652:
	moveq   #$0, d0
	rts     
ObjBigRingFlash:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20D66A(pc, d0.w), d0
	jsr     dat_20D66A(pc, d0.w)
	jmp     DrawObject.l
dat_20D66A:
	dc.w	ObjBigRingFlash_Init-dat_20D66A
	dc.w	ObjBigRingFlash_Animate-dat_20D66A
	dc.w	ObjBigRingFlash_Delete-dat_20D66A
ObjBigRingFlash_Init:
	ori.b   #$4, oSprFlags(a0)
	addq.b  #$2, oRoutine(a0)
	move.w  #$3ef, oTile(a0)
	move.l  #$20db3e, oMap(a0)
ObjBigRingFlash_Animate:
	lea     Ani_BigRingFlash.l, a1
	jmp     AnimateObject.l
ObjBigRingFlash_Delete:
	jmp     DeleteObject.l
ObjBigRing:
	tst.b   oSubtype(a0)
	bne.s   ObjBigRingFlash
	cmpi.w  #$32, rings.l
	bcc.s   loc_20D6B0
	jmp     CheckObjDespawn.l
loc_20D6B0:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20D6CE(pc, d0.w), d0
	jsr     dat_20D6CE(pc, d0.w)
	cmpi.b  #$4, oRoutine(a0)
	beq.s   loc_20D6CC
	jmp     DrawObject.l
loc_20D6CC:
	rts     
dat_20D6CE:
	dc.w	ObjBigRing_Init-dat_20D6CE
	dc.w	ObjBigRing_Main-dat_20D6CE
	dc.w	ObjBigRing_Animate-dat_20D6CE
ObjBigRing_Init:
	cmpi.b  #$7f, timeStones.l
	bne.s   loc_20D6E4
	jmp     DeleteObject.l
loc_20D6E4:
	tst.b   timeAttackMode.l
	beq.s   loc_20D6F2
	jmp     DeleteObject.l
loc_20D6F2:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$2488, oTile(a0)
	move.l  #$23a896, oMap(a0)
	move.b  #$20, oXRadius(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$20, oYRadius(a0)
ObjBigRing_Main:
	lea     objects.w, a1
	bsr.w   ObjBigRing_CheckTouch
	beq.s   ObjBigRing_Animate
	move.b  #$1, specialStage.l
	addq.b  #$2, oRoutine(a0)
	move.w  cameraX.w, d0
	addi.w  #$150, d0
	move.w  d0, $8(a1)
	bset.b  #$0, ctrlLocked.w
	move.w  #$808, playerCtrl.w
	move.w  #$0, $10(a1)
	move.w  #$0, $14(a1)
	move.b  #$1, scrollLock.w
	move.w  #$af, d0
	jsr     PlayFMSound.l
	jsr     FindObjSlot.l
	bne.s   ObjBigRing_Main
	dc.b	$13,$7C,$00,$14,$00,$00		; move.b #$14, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	move.b  #$1, $28(a1)
ObjBigRing_Animate:
	lea     Ani_BigRing.l, a1
	jmp     AnimateObject.l
ObjBigRing_CheckTouch:
	move.b  $17(a1), d1
	ext.w   d1
	addi.w  #$10, d1
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	add.w   d1, d0
	bmi.s   loc_20D7CE
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   loc_20D7CE
	move.b  $16(a1), d1
	ext.w   d1
	addi.w  #$20, d1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	add.w   d1, d0
	bmi.s   loc_20D7CE
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   loc_20D7CE
	moveq   #$1, d0
	rts     
loc_20D7CE:
	moveq   #$0, d0
	rts     
ObjGoalPost:
	lea     objects.w, a6
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20D7FA(pc, d0.w), d0
	jsr     dat_20D7FA(pc, d0.w)
	cmpi.b  #$2, act.l
	beq.s   loc_20D7F4
	jsr     DrawObject.l
loc_20D7F4:
	jmp     CheckObjDespawn.l
dat_20D7FA:
	dc.w	ObjGoalPost_Init-dat_20D7FA
	dc.w	ObjGoalPost_Main-dat_20D7FA
	dc.w	ObjGoalPost_Done-dat_20D7FA
ObjGoalPost_Init:
	cmpi.w  #$201, zoneAct.l
	bne.s   loc_20D830
	cmpi.b  #$1, timeZone.l
	bne.s   loc_20D830
	tst.b   oSubtype(a0)
	bne.s   loc_20D828
	move.b  #$1, oSubtype(a0)
	moveq   #$13, d0
	jmp     LoadPLC.l
loc_20D828:
	tst.l   plcBuffer.w
	beq.s   loc_20D830
	rts     
loc_20D830:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.l  #$23a954, oMap(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$20, oYRadius(a0)
	move.b  #$5, oMapFrame(a0)
	bsr.w   ObjGoalPost_SetBaseTile
ObjGoalPost_Main:
	move.w  $c(a6), d0
	sub.w   oY(a0), d0
	addi.w  #$80, d0
	bmi.s   loc_20D8A8
	cmpi.w  #$100, d0
	bcc.s   loc_20D8A8
	move.w  $8(a6), d0
	cmp.w   oX(a0), d0
	bcs.s   loc_20D8A8
	addq.b  #$2, oRoutine(a0)
	move.w  cameraX.w, leftBound.w
	move.w  cameraX.w, destLeftBound.w
	clr.w   timeWarpTimer.w
	clr.b   timeWarpDir.w
	clr.b   timeWarp.l
	moveq   #$12, d0
	jmp     LoadPLC.l
loc_20D8A8:
	rts     
ObjGoalPost_Done:
	rts     
ObjGoalPost_SetBaseTile:
	moveq   #$0, d0
	move.w  zoneAct.l, d0
	lsl.b   #$7, d0
	lsr.w   #$4, d0
	move.b  timeZone.l, d1
	cmpi.b  #$2, d1
	bne.s   loc_20D8CA
	add.b   goodFuture.l, d1
loc_20D8CA:
	add.b   d1, d1
	add.b   d1, d0
	move.w  dat_20D8E6(pc, d0.w), oTile(a0)
	cmpi.b  #$3, zoneAct.l
	beq.s   loc_20D8E4
	ori.w   #$8000, oTile(a0)
loc_20D8E4:
	rts     
dat_20D8E6:
	dc.w	$035A,$04F7,$04F7,$04F7,$0381,$04F7,$04F7,$04F7
	dc.w	$0300,$0300,$0300,$0300,$0300,$0300,$0300,$0300
	dc.w	$04F2,$04F2,$04F2,$04F2,$04F2,$04F2,$04F2,$04F2
	dc.w	$02BA,$02CC,$02B3,$02B1,$02BA,$02CC,$02B3,$02B1
	dc.w	$0254,$022C,$0294,$0238,$0278,$028A,$02BC,$0298
	dc.w	$03AE,$03AE,$03AE,$03AE,$03AE,$03AE,$03AE,$03AE
	dc.w	$0220,$0221,$024C,$0236,$023E,$024A,$025D,$0246
Obj17_20D956:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20D96A(pc, d0.w), d0
	jsr     dat_20D96A(pc, d0.w)
	jmp     DrawObject.l
dat_20D96A:
	dc.w	ObjSignpost_Init-dat_20D96A
	dc.w	ObjSignpost_Main-dat_20D96A
	dc.w	ObjSignpost_Spin-dat_20D96A
	dc.w	StartResults-dat_20D96A
	dc.w	ResultsActive-dat_20D96A
ObjSignpost_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$18, oXRadius(a0)
	move.b  #$18, oWidth(a0)
	move.b  #$20, oYRadius(a0)
	move.b  #$4, oPriority(a0)
	move.w  #$43c, oTile(a0)
	cmpi.b  #$3, zoneAct.l
	beq.s   loc_20D9AC
	ori.b   #$80, oTile(a0)
loc_20D9AC:
	move.l  #$23a954, oMap(a0)
ObjSignpost_Main:
	lea     objects.w, a6
	move.w  $c(a6), d0
	sub.w   oY(a0), d0
	addi.w  #$80, d0
	bmi.s   loc_20DA0E
	cmpi.w  #$100, d0
	bcc.s   loc_20DA0E
	move.w  oX(a0), d0
	cmp.w   $8(a6), d0
	bcc.s   loc_20DA0E
	move.w  cameraX.w, leftBound.w
	move.w  cameraX.w, destLeftBound.w
	clr.b   updateHUDTime.l
	move.b  #$78, $2a(a0)
	move.b  #$0, oMapFrame(a0)
	addq.b  #$2, oRoutine(a0)
	clr.b   speedShoes.l
	clr.b   invincible.l
	move.w  #$9d, d0
	jmp     PlayFMSound.l
loc_20DA0E:
	rts     
ObjSignpost_Spin:
	lea     Ani_Signpost.l, a1
	jsr     AnimateObject.l
	subq.b  #$1, $2a(a0)
	bne.s   loc_20DA32
	addq.b  #$2, oRoutine(a0)
	move.b  #$3, oMapFrame(a0)
	move.b  #$3c, $2a(a0)
loc_20DA32:
	rts     
StartResults:
	subq.b  #$1, $2a(a0)
	bne.w   loc_20DACE
	tst.b   timeZone.l
	bne.s   loc_20DA4E
	move.w  #$82, d0
	jsr     SubCPUCmd.l
loc_20DA4E:
	move.w  #$6b, d0
	jsr     SubCPUCmd.l
	bset.b  #$0, ctrlLocked.w
	move.w  #$808, playerCtrl.w
	cmpi.w  #$502, zoneAct.l
	bne.s   loc_20DA74
	move.w  #$0, playerCtrl.w
loc_20DA74:
	move.b  #$b4, $2a(a0)
	addq.b  #$2, oRoutine(a0)
	jsr     FindObjSlot.l
	dc.b	$13,$7C,$00,$3A,$00,$00		; move.b #$3a, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.b  #$10, $32(a1)
	move.b  #$1, updateHUDBonus.w
	moveq   #$0, d0
	move.b  timeMinutes.l, d0
	mulu.w  #$3c, d0
	moveq   #$0, d1
	move.b  timeSeconds.l, d1
	add.w   d1, d0
	divu.w  #$f, d0
	moveq   #$14, d1
	cmp.w   d1, d0
	bcs.s   loc_20DAB8
	move.w  d1, d0
loc_20DAB8:
	add.w   d0, d0
	move.w  dat_20DAD0(pc, d0.w), timeBonus.w
	move.w  rings.l, d0
	mulu.w  #$64, d0
	move.w  d0, ringBonus.w
loc_20DACE:
	rts     
dat_20DAD0:
	dc.w	$C350,$C350,$2710,$1388,$0FA0,$0FA0,$0BB8,$0BB8
	dc.w	$07D0,$07D0,$07D0,$07D0,$03E8,$03E8,$03E8,$03E8
	dc.w	$01F4,$01F4,$01F4,$01F4,$0000
ResultsActive:
	rts     
	move.w  #$7, d6
	lea     Pal_FlowerCapsule.l, a1
	lea     $FFFFFB20.w, a2
loc_20DB0A:
	move.l  (a1)+, (a2)+
	dbra    d6, loc_20DB0A
	rts     
Pal_FlowerCapsule:
	dc.w	$0A22,$0000,$0644,$0A66,$0C88,$0EAA,$0EEE,$0AE8
	dc.w	$08A6,$0664,$0442,$0220,$00EE,$00AA,$0044,$000E
Ani_BigRingFlash:
	dc.w	$0002,$0200,$0102,$0304,$0506,$07FC
MapSpr_BigRingFlash:
	dc.w	$0010,$0030,$0050,$0084,$00D6,$010A,$012A,$014A
	dc.w	$06E0,$0800,$0000,$E801,$0003,$00E8,$0A00,$0508
	dc.w	$000A,$1005,$0808,$0110,$0300,$1808,$1000,$0000
	dc.w	$06E0,$0200,$0EF0,$E00F,$0011,$F8E8,$0200,$2118
	dc.w	$0002,$1021,$1800,$0F10,$11F8,$0802,$100E,$F000
	dc.w	$0AE0,$0700,$24E8,$E00D,$002C,$F8F0,$0500,$34F8
	dc.w	$F005,$0034,$08E8,$0200,$0B18,$0002,$100B,$1800
	dc.w	$0500,$3408,$0005,$0034,$F810,$0D10,$2CF8,$0007
	dc.w	$1024,$E800,$10E0,$0008,$02E8,$E000,$0002,$10E8
	dc.w	$0600,$38E0,$E005,$082E,$F0E0,$0500,$2E00,$F005
	dc.w	$0034,$F0F0,$0500,$3400,$E806,$0838,$1000,$0610
	dc.w	$38E0,$1800,$1802,$E800,$0500,$34F0,$1005,$182E
	dc.w	$F000,$0500,$3400,$1005,$102E,$0018,$0010,$0210
	dc.w	$0006,$1838,$1000,$0AE8,$0208,$0BE0,$E00D,$082C
	dc.w	$E8F0,$0500,$34E8,$F005,$0034,$F8E0,$0708,$2408
	dc.w	$0002,$180B,$E000,$0500,$34E8,$0005,$0034,$F810
	dc.w	$0D18,$2CE8,$0007,$1824,$0800,$06E8,$0208,$21E0
	dc.w	$E00F,$0811,$E8E0,$0208,$0E08,$0002,$1821,$E000
	dc.w	$0F18,$11E8,$0802,$180E,$0800,$06E0,$0808,$00E8
	dc.w	$E801,$0803,$F8E8,$0A08,$05E0,$000A,$1805,$E008
	dc.w	$0118,$03F8,$1808,$1800,$E800,$11E0,$0400,$3E00
	dc.w	$E809,$0040,$00E8,$0000,$4618,$F804,$0047,$1000
	dc.w	$0410,$4710,$0809,$1040,$0010,$0010,$4618,$1804
	dc.w	$103E,$00E0,$0408,$3EF0,$E800,$0846,$E0E8,$0908
	dc.w	$40E8,$F804,$0847,$E000,$0418,$47E0,$1000,$1846
	dc.w	$E008,$0918,$40E8,$1804,$183E,$F0F8,$0500,$49F8
	dc.w	$804D,$8005,$1C16,$3B28,$F836,$3A46,$3C55,$1B64
	dc.w	$0B71,$0086,$0304,$163D,$8B04,$0C8C,$051A,$8D04
	dc.w	$0A18,$F9FF,$FEB5,$7267,$5939,$5EE5,$D4CB,$A81E
	dc.w	$D5E7,$AF79,$9B95,$9753,$2EB2,$EBF4,$C225,$5E44
	dc.w	$F8FE,$B5C0,$0393,$72E2,$37EE,$E27C,$55E7,$9539
	dc.w	$2BE2,$A725,$7997,$43A9,$701D,$CB81,$D7F5,$91EB
	dc.w	$2E91,$9749,$D4B9,$F197,$465D,$0CBA,$7C4B,$81D4
	dc.w	$455E,$2108,$55E0,$ABC0,$7FDB,$7F3B,$F901,$DD5D
	dc.w	$001C,$ABA7,$9FFD,$DD3E,$5F2A,$7C8E,$F57A,$00E5
	dc.w	$5FE0,$7CAD,$7355,$F15A,$E6AB,$CFC0,$DD1F,$1ABD
	dc.w	$0BFE,$EBE4,$14A5,$294A,$295F,$1574,$03BA,$BAEB
	dc.w	$5BD7,$35E6,$B9AD,$E875,$F2FD,$6BE5,$4001,$450A
	dc.w	$0A03,$F7A2,$94F9,$5294,$A000,$007F,$F4A5,$14A2
	dc.w	$8A14,$140F,$FE8B,$9E54,$F266,$E27C,$4EA7,$2727
	dc.w	$5EF2,$6E1F,$1ABD,$07C4,$B801,$DEAF,$42BD,$EEBD
	dc.w	$CEEA,$6798,$05C6,$5D23,$2E91,$E6BB,$CEB5,$DD19
	dc.w	$75F1,$579E,$54E4,$AEF2,$A725,$775D,$E5D1,$BAFF
	dc.w	$3600,$00EB,$26F2,$0001,$FF6F,$6AF3,$D7A8,$003F
	dc.w	$EC22,$55E4,$4444,$0000,$0000,$07FD,$8B9B,$9BAB
	dc.w	$CDC6,$E371,$BABC,$3757,$80BF,$6E6E,$0000,$02FF
	dc.w	$EC79,$2E00,$12E0,$3737,$393C,$9C9B,$81D4,$B80E
	dc.w	$AAE8,$F897,$00D5,$E9D5,$5FE0,$77AE,$6ABA,$D735
	dc.w	$5E7E,$06E8,$1DCB,$8007,$52E1,$3739,$3C9C,$9B81
	dc.w	$72E0,$0BD5,$E805,$EAF4,$077A,$BD00,$BD5E,$8EC0
Obj31_20DE5E:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20DE80(pc, d0.w), d0
	jsr     dat_20DE80(pc, d0.w)
	bsr.w   sub_20E300
	cmpi.w  #$4c0, $8(a1)
	bcc.w   loc_20E04A
	jmp     DrawObject.l
dat_20DE80:
	dc.w	loc_20DE8C-dat_20DE80
	dc.w	loc_20DEC2-dat_20DE80
	dc.w	loc_20DEF0-dat_20DE80
	dc.w	loc_20DF50-dat_20DE80
	dc.w	loc_20DFA4-dat_20DE80
	dc.w	loc_20E020-dat_20DE80
loc_20DE8C:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$3d0, oTile(a0)
	move.b  #$2, oPriority(a0)
	move.l  #$23bc54, oMap(a0)
	move.b  #$e, oMapFrame(a0)
	move.b  #$20, oYRadius(a0)
	move.b  #$3c, $3a(a0)
	move.b  #$0, oColType(a0)
loc_20DEC2:
	tst.b   $3a(a0)
	beq.s   loc_20DECE
	subq.b  #$1, $3a(a0)
	bne.s   loc_20DEEE
loc_20DECE:
	bsr.w   ObjAmyRose_XFlip
	move.w  #$fff0, $3e(a0)
	addq.b  #$2, oRoutine(a0)
	btst.b  #$7, oSprFlags(a0)
	beq.s   loc_20DEEE
	move.w  #$ca, d0
	jsr     PlayFMSound.l
loc_20DEEE:
	rts     
loc_20DEF0:
	bsr.w   ObjectMoveX
	move.w  $3e(a0), d0
	add.w   oXVel(a0), d0
	cmpi.w  #$fd00, d0
	bgt.s   loc_20DF06
	move.w  #$fd00, d0
loc_20DF06:
	move.w  d0, oXVel(a0)
	move.w  #$3e0, d0
	move.w  $34(a0), d1
	beq.s   loc_20DF1E
	movea.w d1, a2
	move.w  $8(a2), d0
	addi.w  #$20, d0
loc_20DF1E:
	cmp.w   oX(a0), d0
	bcs.s   loc_20DF48
	clr.w   oXVel(a0)
	clr.w   $3e(a0)
	st.b    $3d(a0)
	move.b  #$2, oAnim(a0)
	bsr.w   sub_20E00C
	clr.b   oColType(a0)
	move.w  oY(a0), $32(a0)
	addq.b  #$2, oRoutine(a0)
loc_20DF48:
	lea     dat_20E062(pc), a1
	bra.w   AnimateObjSimple
loc_20DF50:
	bsr.w   sub_20E300
	bsr.w   ObjAmyRose_SetFacing
	bsr.w   sub_20DF86
	addq.b  #$4, $3a(a0)
	bcc.s   loc_20DF7E
	addq.b  #$2, oRoutine(a0)
	move.w  #$fd40, oYVel(a0)
	move.w  #$b, $3e(a0)
	move.b  #$40, $3b(a0)
	move.b  #$50, $30(a0)
loc_20DF7E:
	lea     dat_20E062(pc), a1
	bra.w   AnimateObjSimple
sub_20DF86:
	moveq   #$0, d0
	move.b  $3a(a0), d0
	jsr     CalcSine.l
	add.w   d0, d0
	add.w   d0, d0
	ext.l   d0
	asl.l   #$8, d0
	add.l   $32(a0), d0
	move.l  d0, oY(a0)
	rts     
loc_20DFA4:
	lea     objects.w, a1
	bsr.w   ObjAmyRose_SetFacing
	tst.b   $3b(a0)
	beq.s   loc_20DFD2
	bsr.w   ObjectMove
	move.w  $3e(a0), d0
	add.w   d0, oYVel(a0)
	subq.b  #$1, $3b(a0)
	bne.s   loc_20E004
	clr.w   $3e(a0)
	clr.w   oYVel(a0)
	move.w  oY(a0), $32(a0)
loc_20DFD2:
	bsr.w   sub_20DF86
	addq.b  #$4, $3a(a0)
	move.w  oX(a0), d0
	sub.w   $8(a1), d0
	bcs.s   loc_20DFEA
	cmpi.b  #$a0, d0
	bcc.s   loc_20E004
loc_20DFEA:
	subq.b  #$1, $30(a0)
	bne.s   loc_20E004
	bsr.w   ObjAmyRose_XUnflip
	move.w  #$0, oXVel(a0)
	move.w  #$60, $3e(a0)
	addq.b  #$2, oRoutine(a0)
loc_20E004:
	lea     dat_20E062(pc), a1
	bra.w   AnimateObjSimple
sub_20E00C:
	jsr     FindObjSlot.l
	bne.s   loc_20E01E
	dc.b	$13,$7C,$00,$34,$00,$00		; move.b #$34, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  a0, $34(a1)
loc_20E01E:
	rts     
loc_20E020:
	bsr.w   ObjectMoveX
	move.w  $3e(a0), d0
	add.w   oXVel(a0), d0
	cmpi.w  #$400, d0
	bcs.s   loc_20E036
	move.w  #$400, d0
loc_20E036:
	move.w  d0, oXVel(a0)
	cmpi.w  #$528, oX(a0)
	bcc.s   loc_20E04A
	lea     dat_20E062(pc), a1
	bra.w   AnimateObjSimple
loc_20E04A:
	move.b  #$ff, amyCaptured.l
	lea     loc_20067C.l, a3
	bsr.w   ObjAmyRose_ResetPal
	jmp     DeleteObject.l
dat_20E062:
	dc.w	$0006,$000C,$0016,$0000,$0100,$FF00,$0601,$0701
	dc.w	$0801,$0901,$FF00,$0F01,$FF00
ObjectMove:
	bsr.s   ObjectMoveX
	move.w  oYVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, oY(a0)
	rts     
ObjectMoveX:
	move.w  oXVel(a0), d0
	ext.l   d0
	asl.l   #$8, d0
	add.l   d0, oX(a0)
	rts     
Obj32_20E09A:
	tst.b   timeAttackMode.l
	bne.w   loc_20E04A
	tst.b   amyCaptured.l
	bne.w   loc_20E04A
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20E0D0(pc, d0.w), d0
	jsr     dat_20E0D0(pc, d0.w)
	bsr.w   sub_20E300
	cmpi.w  #$4c0, $8(a1)
	bcc.w   loc_20E04A
	jmp     DrawObject.l
dat_20E0D0:
	dc.w	loc_20E0D6-dat_20E0D0
	dc.w	loc_20E128-dat_20E0D0
	dc.w	loc_20E1EE-dat_20E0D0
loc_20E0D6:
	tst.b   $3e(a0)
	bmi.s   loc_20E0E8
	moveq   #$b, d0
	jsr     LoadPLC.l
	st.b    $3e(a0)
loc_20E0E8:
	ori.b   #$4, oSprFlags(a0)
	move.w  #$235e, oTile(a0)
	move.b  #$1, oPriority(a0)
	move.l  #$23bdb2, oMap(a0)
	bsr.w   ObjAmyRose_LoadPal
	bsr.w   sub_20E300
	bsr.w   ObjAmyRose_SetFacing
	move.w  $8(a1), d0
	cmp.w   oX(a0), d0
	bcs.s   loc_20E11C
	addq.b  #$2, oRoutine(a0)
loc_20E11C:
	lea     Data_23BF08.l, a1
	bra.w   AnimateObjSimple
	dc.w	$4E75
loc_20E128:
	bsr.w   sub_20E300
	move.w  $34(a0), d0
	beq.s   loc_20E14E
	movea.w d0, a2
	tst.b   $3d(a2)
	beq.s   loc_20E14E
	move.b  #$4, oRoutine(a0)
	move.w  #$7d, d0
	jsr     SubCPUCmd.l
	bra.w   loc_20E1E0
loc_20E14E:
	bsr.w   ObjAmyRose_SetFacing
	btst.b  #$0, oFlags(a0)
	beq.s   loc_20E16E
	cmpi.w  #$80, oX(a0)
	bcc.s   loc_20E16E
	clr.b   oAnim(a0)
	clr.w   oXVel(a0)
	bra.w   loc_20E1E0
loc_20E16E:
	cmpi.w  #$3c0, oX(a0)
	bcc.s   loc_20E1B4
	move.w  #$ffe0, d0
	btst.b  #$0, oFlags(a0)
	bne.s   loc_20E184
	neg.w   d0
loc_20E184:
	add.w   oXVel(a0), d0
	move.w  d0, d1
	move.w  #$200, d2
	tst.w   d1
	bpl.s   loc_20E196
	neg.w   d1
	neg.w   d2
loc_20E196:
	cmpi.w  #$200, d1
	bcs.s   loc_20E19E
	move.w  d2, d0
loc_20E19E:
	move.w  d0, oXVel(a0)
	bsr.w   ObjectMoveX
	move.b  #$1, oAnim(a0)
	cmpi.w  #$3c0, oX(a0)
	bcs.s   loc_20E1E0
loc_20E1B4:
	clr.b   oAnim(a0)
	tst.w   $34(a0)
	bne.s   loc_20E1E0
	jsr     FindObjSlot.l
	bne.s   loc_20E1E0
	dc.b	$13,$7C,$00,$31,$00,$00		; move.b #$31, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  #$500, $8(a1)
	move.w  #$3e8, $c(a1)
	move.w  a0, $34(a1)
	move.w  a1, $34(a0)
loc_20E1E0:
	lea     Data_23BF08.l, a1
	bsr.w   AnimateObjSimple
	bra.w   loc_20E306
loc_20E1EE:
	movea.w $34(a0), a1
	dc.b	$0C,$29,$00,$31,$00,$00		; cmpi.b #$31, $0(a1) (raw: not reproducible by assembler / suspicious)
	bne.s   loc_20E230
	moveq   #$8, d0
	bsr.w   ObjAmyRose_XFlip
	btst.b  #$0, $22(a1)
	beq.s   loc_20E20E
	neg.w   d0
	bsr.w   ObjAmyRose_XUnflip
loc_20E20E:
	add.w   $8(a1), d0
	move.w  d0, oX(a0)
	move.w  $c(a1), d0
	addq.w  #$4, d0
	move.w  d0, oY(a0)
	move.b  #$2, oAnim(a0)
	lea     Data_23BF08.l, a1
	bra.w   AnimateObjSimple
loc_20E230:
	jmp     DeleteObject.l
ObjAmyRose_SetFacing:
	bsr.s   ObjAmyRose_XUnflip
	move.w  oX(a0), d0
	sub.w   $8(a1), d0
	bcs.s   loc_20E244
	bsr.s   ObjAmyRose_XFlip
loc_20E244:
	rts     
ObjAmyRose_XUnflip:
	bclr.b  #$0, oFlags(a0)
	bclr.b  #$0, oSprFlags(a0)
	rts     
ObjAmyRose_XFlip:
	bset.b  #$0, oFlags(a0)
	bset.b  #$0, oSprFlags(a0)
	rts     
AnimateObjSimple:
	moveq   #$0, d0
	move.b  oAnim(a0), d0
	cmp.b   oPrevAnim(a0), d0
	beq.s   loc_20E27A
	move.b  d0, oPrevAnim(a0)
	clr.b   oAnimFrame(a0)
	clr.b   oAnimTime(a0)
loc_20E27A:
	subq.b  #$1, oAnimTime(a0)
	bpl.s   loc_20E2C2
	add.w   d0, d0
	adda.w  (a1, d0.w), a1
loc_20E286:
	move.b  oAnimFrame(a0), d0
	lea     (a1, d0.w), a2
	move.b  (a2), d0
	bpl.s   loc_20E298
	clr.b   oAnimFrame(a0)
	bra.s   loc_20E286
loc_20E298:
	move.b  d0, d1
	andi.b  #$1f, d0
	move.b  d0, oMapFrame(a0)
	move.b  oFlags(a0), d0
	rol.b   #$3, d1
	eor.b   d0, d1
	andi.b  #$3, d1
	andi.b  #$fc, oSprFlags(a0)
	or.b    d1, oSprFlags(a0)
	move.b  $1(a2), oAnimTime(a0)
	addq.b  #$2, oAnimFrame(a0)
loc_20E2C2:
	rts     
ObjAmyRose_LoadPal:
	lea     Pal_AmyRose(pc), a3
ObjAmyRose_ResetPal:
	lea     $FFFFFB20.w, a4
	movem.l (a3)+, d0-d3
	movem.l d0-d3, (a4)
	movem.l (a3)+, d0-d3
	movem.l d0-d3, $10(a4)
	rts     
Pal_AmyRose:
	dc.w	$0000,$0000,$0628,$084A,$0E6E,$0EAE,$0EEE,$0AAA
	dc.w	$0888,$0444,$08AE,$006C,$00C2,$0080,$0806,$000E
sub_20E300:
	lea     objects.w, a1
	rts     
loc_20E306:
	addq.b  #$8, $3b(a0)
	bcc.s   loc_20E33E
	jsr     FindObjSlot.l
	bne.s   loc_20E33E
	dc.b	$13,$7C,$00,$33,$00,$00		; move.b #$33, $0(a1) (raw: not reproducible by assembler / suspicious)
	moveq   #$c, d1
	btst.b  #$0, oFlags(a0)
	beq.s   loc_20E328
	move.w  #$fff2, d1
loc_20E328:
	move.w  oX(a0), d0
	add.w   d1, d0
	move.w  d0, $8(a1)
	move.w  oY(a0), d0
	subi.w  #$c, d0
	move.w  d0, $c(a1)
loc_20E33E:
	rts     
Obj30_20E340:
	dc.w	$4A39,$00FF,$0F01,$6600,$0224,$7000,$1028,$0024
	dc.w	$303B,$000C,$4EBB,$0008,$4EF9,$0020,$3A6E,$006E
	dc.w	$00EE,$01FA,$0C28,$0001,$0028,$670A,$43F8,$D000
	dc.w	$4EF9,$0020,$8D4C,$43F8,$D000,$4EB9,$0020,$8D4C
	dc.w	$6748,$0828,$0003,$0022,$6740,$4A39,$00FF,$1521
	dc.w	$6638,$4A39,$00FF,$151F,$6630,$2F08,$2448,$41F8
	dc.w	$D000,$0C28,$0004,$0024,$641E,$4A68,$0030,$6618
	dc.w	$2628,$000C,$3028,$0012,$48C0,$E180,$9680,$2143
	dc.w	$000C,$4EB9,$0020,$737A,$205F,$4E75,$4A39,$00FF
	dc.w	$1577,$6600,$0198,$5428,$0024,$0028,$0004,$0001
	dc.w	$317C,$031E,$0002,$117C,$0003,$0018,$217C,$0023
	dc.w	$BE60,$0004,$117C,$0012,$0019,$117C,$0008,$0016
	dc.w	$0C28,$0001,$0028,$672E,$117C,$0020,$0016,$0C28
	dc.w	$0000,$0028,$6720,$117C,$0009,$001A,$117C,$0086
	dc.w	$0020,$117C,$000C,$0019,$0C28,$0002,$0028,$6706
	dc.w	$117C,$000E,$001A,$4A28,$003C,$6710,$4228,$0020
	dc.w	$5428,$0024,$6100,$00E0,$6000,$010E,$0C28,$0001
	dc.w	$0028,$6700,$FF10,$43F8,$D800,$303C,$005F,$0C29
	dc.w	$0031,$0000,$670A,$43E9,$0040,$51C8,$FFF2,$604C
	dc.w	$1228,$0019,$4881,$0641,$0010,$3029,$0008,$9068
	dc.w	$0008,$D041,$6B36,$3401,$D442,$B042,$642E,$1228
	dc.w	$0016,$4881,$0641,$0010,$3029,$000C,$9068,$000C
	dc.w	$D041,$6B18,$3401,$D442,$B042,$6410,$5428,$0024
	dc.w	$610E,$43F8,$D000,$4EF9,$0020,$8BFE,$6000,$FEA6
	dc.w	$7203,$117C,$0004,$001A,$7400,$0C28,$0000,$0028
	dc.w	$6718,$117C,$0008,$001A,$7404,$0C28,$0002,$0028
	dc.w	$6708,$117C,$000D,$001A,$7409,$4EB9,$0020,$7B0A
	dc.w	$661E,$137C,$0030,$0000,$3368,$0008,$0008,$3368
	dc.w	$000C,$000C,$1601,$D602,$1343,$001A,$1341,$003C
	dc.w	$5301,$66D6,$0828,$0007,$0001,$670A,$303C,$00A3
	dc.w	$4EB9,$0020,$227E,$7000,$1028,$003C,$E580,$45FB
	dc.w	$0018,$315A,$0010,$315A,$0012,$317C,$0060,$003E
	dc.w	$117C,$0078,$003A,$4E75,$0200,$FE00,$FF00,$FC00
	dc.w	$FF00,$FE00,$0200,$FC00,$6100,$FB22,$3028,$003E
	dc.w	$D168,$0012,$5328,$003A,$6702,$4E75,$4EF9,$0020
	dc.w	$3B1A
Obj33_20E572:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20E58C(pc, d0.w), d0
	jsr     dat_20E58C(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
dat_20E58C:
	dc.w	loc_20E590-dat_20E58C
	dc.w	ObjAmyHeart_Main-dat_20E58C
loc_20E590:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$35e, oTile(a0)
	move.l  #$23bdb2, oMap(a0)
	move.b  #$3, oPriority(a0)
	move.w  #$ffa0, oYVel(a0)
	move.b  #$a, oMapFrame(a0)
ObjAmyHeart_Main:
	tst.b   $3c(a0)
	bne.s   loc_20E5D8
	moveq   #$0, d0
	move.b  $3a(a0), d0
	add.b   d0, d0
	add.b   $3a(a0), d0
	jsr     CalcSine.l
	asr.w   #$2, d0
	move.w  d0, oXVel(a0)
loc_20E5D8:
	bsr.w   ObjectMove
	addq.b  #$1, $3a(a0)
	move.b  $3a(a0), d0
	cmpi.b  #$14, d0
	bne.s   loc_20E5EE
	addq.b  #$1, oMapFrame(a0)
loc_20E5EE:
	cmpi.b  #$6e, d0
	bne.s   loc_20E604
	addq.b  #$1, oMapFrame(a0)
	clr.w   oYVel(a0)
	clr.w   oXVel(a0)
	st.b    $3c(a0)
loc_20E604:
	cmpi.b  #$78, d0
	bne.s   loc_20E610
	jmp     DeleteObject.l
loc_20E610:
	rts     
ObjGameOver:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20E626(pc, d0.w), d0
	jsr     dat_20E626(pc, d0.w)
	jmp     DrawObject.l
dat_20E626:
	dc.w	loc_20E62A-dat_20E626
	dc.w	loc_20E648-dat_20E626
loc_20E62A:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.w  #$3d0, oTile(a0)
	move.l  #$23bc54, oMap(a0)
	move.b  #$3, oPriority(a0)
loc_20E648:
	move.w  $34(a0), d0
	movea.w d0, a1
	dc.b	$0C,$29,$00,$31,$00,$00		; cmpi.b #$31, $0(a1) (raw: not reproducible by assembler / suspicious)
	bne.s   loc_20E680
	move.w  $8(a1), d0
	subi.w  #$10, d0
	btst.b  #$0, $22(a1)
	beq.s   loc_20E66A
	addi.w  #$20, d0
loc_20E66A:
	move.w  d0, oX(a0)
	move.w  $c(a1), d0
	move.w  d0, oY(a0)
	lea     dat_20E686(pc), a1
	jmp     AnimateObject.l
loc_20E680:
	jmp     DeleteObject.l
dat_20E686:
	dc.w	$0002,$010C,$0E0D,$0EFF
ObjAnimal:
	jsr     CheckAnimalPrescence.l
	move.b  oSubtype(a0), d0
	andi.b  #$7f, d0
	bne.w   ObjGroundAnimal
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjFlyingAnimal_Index(pc, d0.w), d0
	jmp     ObjFlyingAnimal_Index(pc, d0.w)
ObjFlyingAnimal_Index:
	dc.w	loc_20E6B4-ObjFlyingAnimal_Index
	dc.w	ObjFlyingAnimal_Flying-ObjFlyingAnimal_Index
	dc.w	ObjFlyingAnimal_Hologram-ObjFlyingAnimal_Index
loc_20E6B4:
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.l  #$8080108, oYRadius(a0)
	move.l  #$20e932, oMap(a0)
	move.w  oX(a0), $2a(a0)
	move.w  oY(a0), $2c(a0)
	bsr.w   ObjAnimal_XFlip
	bsr.w   ObjAnimal_SetBaseTile
	tst.b   oSubtype(a0)
	bmi.s   loc_20E6FC
	move.b  #$1, oPriority(a0)
	ori.w   #$8000, oTile(a0)
	move.w  #$101, $2e(a0)
	rts     
loc_20E6FC:
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, oAnim(a0)
	move.b  #$3, oPriority(a0)
	rts     
ObjFlyingAnimal_Flying:
	moveq   #$1, d2
	moveq   #$1, d3
	bsr.w   ObjFlyingAnimal_Move
	move.b  $2e(a0), d0
	add.b   $2f(a0), d0
	move.b  d0, d1
	subq.b  #$1, d1
	subi.b  #$7f, d1
	bcs.s   loc_20E734
	move.b  $2e(a0), d0
	neg.b   $2f(a0)
	bsr.w   ObjAnimal_XFlip
loc_20E734:
	move.b  d0, $2e(a0)
	lea     Ani_FlyingAnimal(pc), a1
	jsr     AnimateObject.l
	jsr     DrawObject.l
	move.w  $2a(a0), d0
	jmp     CheckObjDespawn2.l
ObjFlyingAnimal_Hologram:
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$38,$00,$00		; cmpi.b #$38, $0(a1) (raw: not reproducible by assembler / suspicious)
	bne.w   ObjAnimal_Destroy
	tst.b   $3f(a1)
	bne.w   ObjAnimal_Destroy
	moveq   #$3, d2
	moveq   #$4, d3
	bsr.w   ObjFlyingAnimal_Move
	addq.b  #$4, $2e(a0)
	move.b  $2e(a0), d0
	andi.b  #$7f, d0
	beq.w   ObjAnimal_XFlip
	lea     Ani_FlyingAnimal(pc), a1
	jsr     AnimateObject.l
	jmp     DrawObject.l
ObjFlyingAnimal_Move:
	move.b  $2e(a0), d0
	jsr     CalcSine.l
	asr.w   d2, d1
	asr.w   d3, d0
	add.w   $2a(a0), d1
	add.w   $2c(a0), d0
	move.w  d1, oX(a0)
	move.w  d0, oY(a0)
	rts     
ObjGroundAnimal:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjGroundAnimal_Index(pc, d0.w), d0
	jmp     ObjGroundAnimal_Index(pc, d0.w)
ObjGroundAnimal_Index:
	dc.w	loc_20E7C8-ObjGroundAnimal_Index
	dc.w	ObjGroundAnimal_Main-ObjGroundAnimal_Index
	dc.w	ObjGroundAnimal_Main-ObjGroundAnimal_Index
	dc.w	loc_20E84E-ObjGroundAnimal_Index
	dc.w	loc_20E85C-ObjGroundAnimal_Index
loc_20E7C8:
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.l  #$c080408, oYRadius(a0)
	move.l  #$20e946, oMap(a0)
	bsr.w   ObjAnimal_SetBaseTile
	tst.b   oSubtype(a0)
	bmi.s   loc_20E7FE
	move.l  #$10000, $2c(a0)
	move.l  #$fffc0000, $30(a0)
	rts     
loc_20E7FE:
	move.b  #$8, oRoutine(a0)
	bra.w   ObjAnimal_XFlip
ObjGroundAnimal_Main:
	move.l  $2c(a0), d0
	add.l   d0, oX(a0)
	move.l  $30(a0), d0
	add.l   d0, oY(a0)
	addi.l  #$2000, $30(a0)
	smi.b   d0
	addq.b  #$1, d0
	move.b  d0, oMapFrame(a0)
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   loc_20E842
	addq.b  #$2, oRoutine(a0)
	add.w   d1, oY(a0)
	move.l  #$fffc0000, $30(a0)
loc_20E842:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
loc_20E84E:
	move.b  #$2, oRoutine(a0)
	neg.l   $2c(a0)
	bsr.s   ObjAnimal_XFlip
	bra.s   loc_20E842
loc_20E85C:
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$38,$00,$00		; cmpi.b #$38, $0(a1) (raw: not reproducible by assembler / suspicious)
	bne.w   ObjAnimal_Destroy
	tst.b   $3f(a1)
	bne.w   ObjAnimal_Destroy
	lea     Ani_GroundAnimal(pc), a1
	jsr     AnimateObject.l
	jmp     DrawObject.l
ObjAnimal_Destroy:
	jmp     DeleteObject.l
ObjAnimal_XFlip:
	bchg.b  #$0, oSprFlags(a0)
	bchg.b  #$0, oFlags(a0)
	rts     
ObjAnimal_SetBaseTile:
	lea     ObjAnimal_BaseTileList(pc), a1
	moveq   #$0, d0
	move.b  act.l, d0
	asl.w   #$2, d0
	add.b   timeZone.l, d0
	add.w   d0, d0
	move.w  (a1, d0.w), oTile(a0)
	rts     
Ani_FlyingAnimal:
	dc.w	$0004,$0008,$0300,$01FF
	dc.w	$0000,$0002,$0000,$0200,$0002,$0000,$0201,$0102
	dc.w	$0201,$0102,$0201,$0102,$0201,$0102,$0200,$0002
	dc.w	$0000,$0200,$0002,$0000,$0201,$0102,$0201,$0102
	dc.w	$0201,$0102,$0201,$0102,$02FF
Ani_GroundAnimal:
	dc.w	$0002
	dc.w	$0003,$0302,$0303,$0203,$0302,$0303,$0203,$0302
	dc.w	$0203,$0302,$0203,$0302,$0203,$0302,$0204,$0402
	dc.w	$0404,$0204,$0402,$0404,$0204,$0402,$0204,$0402
	dc.w	$0204,$0402,$0204,$0402,$02FF
MapSpr_FlyingAnimal:
	dc.w	$0006,$000C,$0012,$01F8,$0500,$00F8,$01F8,$0500
	dc.w	$04F8,$0000
loc_20E946:
	dc.w	$000A,$0010,$0016,$0017,$001D,$01F4,$0600,$0EF8
	dc.w	$01F4,$0600,$08F8,$0001,$F406,$0008,$F801,$FC09
	dc.w	$000E,$F800
ObjAnimal_BaseTileList:
	dc.w	$0797,$03DA,$03DA,$0000,$0797,$03DA,$03DA,$0000
	dc.w	$0000,$0000,$03DA
ObjRobotGenerator:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjRobotGenerator_Index(pc, d0.w), d0
	jsr     ObjRobotGenerator_Index(pc, d0.w)
	jsr     DrawObject.l
	cmpi.b  #$2, oRoutine(a0)
	bgt.s   loc_20E9A2
	jmp     CheckObjDespawn.l
loc_20E9A2:
	rts     
ObjRobotGenerator_Index:
	dc.w	ObjRobotGenerator_Init-ObjRobotGenerator_Index
	dc.w	ObjRobotGenerator_Main-ObjRobotGenerator_Index
	dc.w	ObjRobotGenerator_Exploding-ObjRobotGenerator_Index
	dc.w	ObjRobotGenerator_BreakDown-ObjRobotGenerator_Index
ObjRobotGenerator_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.b  #$22, oXRadius(a0)
	move.b  #$22, oWidth(a0)
	move.b  #$20, oYRadius(a0)
	lea     ObjRobotGenerator_BaseTileList(pc), a1
	moveq   #$0, d0
	move.b  act.l, d0
	asl.w   #$2, d0
	add.b   timeZone.l, d0
	add.w   d0, d0
	move.w  (a1, d0.w), oTile(a0)
	move.l  #$20eb54, oMap(a0)
	move.l  #$20ed92, $2c(a0)
	move.w  oY(a0), $30(a0)
	move.w  #$4, $2a(a0)
	move.w  #$1, $32(a0)
	moveq   #$0, d0
	tst.b   goodFuture.l
	bne.s   loc_20EA18
	addq.b  #$2, d0
loc_20EA18:
	tst.b   timeZone.l
	bne.s   loc_20EA22
	addq.b  #$1, d0
loc_20EA22:
	move.b  d0, oMapFrame(a0)
	tst.b   goodFuture.l
	bne.s   ObjRobotGenerator_Main
	tst.b   timeZone.l
	bne.s   ObjRobotGenerator_Main
	move.b  #$fa, oColType(a0)
	subi.w  #$10, oY(a0)
ObjRobotGenerator_Main:
	tst.b   goodFuture.l
	bne.s   loc_20EAAA
	tst.b   timeZone.l
	bne.s   loc_20EAAA
	bsr.w   ObjRobotGenerator_Float
	tst.b   oColStatus(a0)
	beq.s   loc_20EA96
	clr.w   oColType(a0)
	clr.w   $2a(a0)
	move.b  #$7, oMapFrame(a0)
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, goodFuture.l
	move.l  #$96, d0
	jsr     AddPoints.l
	lea     objects.w, a1
	jsr     SolidObject.l
	beq.s   loc_20EA94
	jsr     GetOffObject.l
loc_20EA94:
	rts     
loc_20EA96:
	lea     objects.w, a1
	jsr     SolidObject.l
	lea     Ani_RobotGenerator(pc), a1
	jmp     AnimateObject.l
loc_20EAAA:
	rts     
ObjRobotGenerator_Exploding:
	movea.l $2c(a0), a6
	move.b  (a6)+, d0
	bmi.s   loc_20EAFE
	addq.b  #$1, $2a(a0)
	cmp.b   $2a(a0), d0
	bne.s   loc_20EAFC
	move.b  (a6)+, d5
	move.b  (a6)+, d6
	move.l  a6, $2c(a0)
	ext.w   d5
	ext.w   d6
	jsr     FindObjSlot.l
	bne.s   loc_20EAFC
	dc.b	$13,$7C,$00,$18,$00,$00		; move.b #$18, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.b  #$1, $25(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	add.w   d5, $8(a1)
	add.w   d6, $c(a1)
	move.w  #$9e, d0
	jsr     PlayFMSound.l
loc_20EAFC:
	rts     
loc_20EAFE:
	addq.b  #$2, oRoutine(a0)
	move.b  #$8, $2a(a0)
	rts     
ObjRobotGenerator_BreakDown:
	subq.b  #$1, $2a(a0)
	bne.s   loc_20EB24
	subq.b  #$6, oRoutine(a0)
	move.w  $30(a0), oY(a0)
	move.w  #$d9, d0
	jmp     PlayFMSound.l
loc_20EB24:
	rts     
ObjRobotGenerator_Float:
	addq.w  #$1, $2a(a0)
	move.w  $2a(a0), d0
	andi.w  #$7, d0
	bne.s   loc_20EB3C
	move.w  $32(a0), d0
	add.w   d0, oY(a0)
loc_20EB3C:
	move.w  $2a(a0), d0
	andi.w  #$1f, d0
	bne.s   loc_20EB4A
	neg.w   $32(a0)
loc_20EB4A:
	rts     
Ani_RobotGenerator:
	dc.w	$0002,$0303,$0405,$06FF
MapSpr_RobotGenerator:
	dc.w	$0011,$0026,$003B,$0078,$00D3,$014C,$01C5,$0010
	dc.w	$0004,$1009,$0009,$E810,$0908,$0900,$1009,$0009
	dc.w	$D810,$0908,$0910,$0410,$0900,$11E8,$1009,$0811
	dc.w	$0010,$0900,$11D8,$1009,$0811,$100C,$E00A,$0000
	dc.w	$E8E0,$0A08,$0000,$080A,$1000,$E808,$0A18,$0000
	dc.w	$E00A,$0000,$D8E0,$0A08,$00F0,$080A,$1000,$D808
	dc.w	$0A18,$00F0,$E00A,$0000,$F8E0,$0A08,$0010,$080A
	dc.w	$1000,$F808,$0A18,$0010,$12E0,$0A00,$00E8,$E00A
	dc.w	$0800,$00F8,$0100,$0DFA,$F801,$180F,$FE08,$0A10
	dc.w	$00E8,$080A,$1800,$00E0,$0A00,$00D8,$E00A,$0800
	dc.w	$F0F8,$0100,$0DEA,$F801,$180F,$EE08,$0A10,$00D8
	dc.w	$080A,$1800,$F0E0,$0A00,$00F8,$E00A,$0800,$10F8
	dc.w	$0100,$0D0A,$F801,$180F,$0E08,$0A10,$00F8,$080A
	dc.w	$1800,$1018,$E004,$0009,$F8E0,$0A00,$00E8,$E00A
	dc.w	$0800,$00F8,$0100,$0FFA,$F801,$180D,$FE18,$0410
	dc.w	$09F8,$080A,$1000,$E808,$0A18,$0000,$E004,$0009
	dc.w	$E8E0,$0A00,$00D8,$E00A,$0800,$F0F8,$0100,$0FEA
	dc.w	$F801,$180D,$EE18,$0410,$09E8,$080A,$1000,$D808
	dc.w	$0A18,$00F0,$E004,$0009,$08E0,$0A00,$00F8,$E00A
	dc.w	$0800,$10F8,$0100,$0F0A,$F801,$180D,$0E18,$0410
	dc.w	$0908,$080A,$1000,$F808,$0A18,$0010,$18E0,$0400
	dc.w	$0BF8,$E00A,$0000,$E8E0,$0A08,$0000,$F801,$180F
	dc.w	$FAF8,$0100,$0DFE,$1804,$100B,$F808,$0A10,$00E8
	dc.w	$080A,$1800,$00E0,$0400,$0BE8,$E00A,$0000,$D8E0
	dc.w	$0A08,$00F0,$F801,$180F,$EAF8,$0100,$0DEE,$1804
	dc.w	$100B,$E808,$0A10,$00D8,$080A,$1800,$F0E0,$0400
	dc.w	$0B08,$E00A,$0000,$F8E0,$0A08,$0010,$F801,$180F
	dc.w	$0AF8,$0100,$0D0E,$1804,$100B,$0808,$0A10,$00F8
	dc.w	$080A,$1800,$1018,$E004,$0009,$F8E0,$0A00,$00E8
	dc.w	$E00A,$0800,$00F8,$0118,$0DFA,$F801,$000F,$FE18
	dc.w	$0410,$09F8,$080A,$1000,$E808,$0A18,$0000,$E004
	dc.w	$0009,$E8E0,$0A00,$00D8,$E00A,$0800,$F0F8,$0118
	dc.w	$0DEA,$F801,$000F,$EE18,$0410,$09E8,$080A,$1000
	dc.w	$D808,$0A18,$00F0,$E004,$0009,$08E0,$0A00,$00F8
	dc.w	$E00A,$0800,$10F8,$0118,$0D0A,$F801,$000F,$0E18
	dc.w	$0410,$0908,$080A,$1000,$F808,$0A18,$0010
ObjRobotGenerator_ExplosionLocs:
	dc.w	$0100,$0002,$D8EC,$031C,$0A04,$12EE,$05EE,$F606
	dc.w	$08F8,$08EE,$0E0A,$F60A,$0C1E,$F60F,$00EE,$1214
	dc.w	$F614,$F612,$1608,$1719,$0DF6,$1A17,$EA1C,$FDE7
	dc.w	$1E0A,$1420,$F602,$221E,$F823,$0DF6,$28F6,$0AFF
ObjRobotGenerator_BaseTileList:
	dc.w	$033E,$033E,$0000,$0000,$036A,$036A,$0000,$0000
	dc.w	$0000,$0000,$0000
ObjProjector:
	tst.b   oSubtype(a0)
	bne.w   ObjMetalSonicHologram
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjProjector_Index(pc, d0.w), d0
	jsr     ObjProjector_Index(pc, d0.w)
	jsr     DrawObject.l
	cmpi.b  #$2, oRoutine(a0)
	bgt.s   loc_20EE20
	jsr     CheckObjDespawn.l
	tst.b   (a0)
	bne.s   loc_20EE20
	move.w  #$4, d0
	jmp     LoadPLC.l
loc_20EE20:
	rts     
ObjProjector_Index:
	dc.w	ObjProjector_Init-ObjProjector_Index
	dc.w	ObjProjector_Main-ObjProjector_Index
	dc.w	ObjProjector_StartExploding-ObjProjector_Index
	dc.w	ObjProjector_Exploding-ObjProjector_Index
	dc.w	ObjProjector_Destroyed-ObjProjector_Index
ObjProjector_Destroy:
	jmp     DeleteObject.l
ObjProjector_Init:
	tst.b   projDestroyed.l
	bne.s   ObjProjector_Destroy
	move.w  #$5, d0
	jsr     LoadPLC.l
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.b  #$c, oXRadius(a0)
	move.b  #$c, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.b  #$fb, oColType(a0)
	move.w  #$33e, oTile(a0)
	move.l  #$20f0a8, oMap(a0)
	move.l  #$20f0ec, $2c(a0)
	jsr     FindObjSlot.l
	bne.w   ObjProjector_Destroy
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$15, $8(a1)
	subq.w  #$7, $c(a1)
	move.b  #$ff, $28(a1)
	move.w  a0, $3e(a1)
	jsr     FindObjSlot.l
	bne.w   ObjProjector_Destroy
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$58, $8(a1)
	subq.w  #$4, $c(a1)
	move.b  #$1, $28(a1)
	move.w  a0, $3e(a1)
	jsr     FindObjSlot.l
	bne.w   ObjProjector_Destroy
	dc.b	$13,$7C,$00,$39,$00,$00		; move.b #$39, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$58, $8(a1)
	addi.w  #$ffe8, $c(a1)
	move.b  #$80, $28(a1)
	move.w  a0, $3e(a1)
	jsr     FindObjSlot.l
	bne.w   ObjProjector_Destroy
	dc.b	$13,$7C,$00,$39,$00,$00		; move.b #$39, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$62, $8(a1)
	addi.w  #$0, $c(a1)
	move.b  #$81, $28(a1)
	move.w  a0, $3e(a1)
ObjProjector_Main:
	tst.b   oColStatus(a0)
	beq.s   loc_20EF54
	clr.w   oColType(a0)
	addq.b  #$2, oRoutine(a0)
loc_20EF54:
	lea     objects.w, a1
	jmp     SolidObject.l
ObjProjector_StartExploding:
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, oMapFrame(a0)
	st.b    $3f(a0)
	move.w  #$4, d0
	jsr     LoadPLC.l
	lea     objects.w, a1
	jsr     SolidObject.l
	beq.s   ObjProjector_Exploding
	jsr     GetOffObject.l
ObjProjector_Exploding:
	movea.l $2c(a0), a6
	move.b  (a6)+, d0
	bmi.s   loc_20EFDA
	addq.b  #$1, $2a(a0)
	cmp.b   $2a(a0), d0
	bne.s   loc_20EFD8
	move.b  (a6)+, d5
	move.b  (a6)+, d6
	move.l  a6, $2c(a0)
	ext.w   d5
	ext.w   d6
	jsr     FindObjSlot.l
	bne.s   loc_20EFD8
	dc.b	$13,$7C,$00,$18,$00,$00		; move.b #$18, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.b  #$1, $25(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	add.w   d5, $8(a1)
	add.w   d6, $c(a1)
	move.w  #$9e, d0
	jsr     PlayFMSound.l
loc_20EFD8:
	rts     
loc_20EFDA:
	addq.b  #$2, oRoutine(a0)
	move.w  #$3c, $2a(a0)
	rts     
ObjProjector_Destroyed:
	subq.w  #$1, $2a(a0)
	bne.s   locret_20E6E6
	st.b    projDestroyed.l
	bra.w   ObjProjector_Destroy
locret_20E6E6:
	rts     
ObjMetalSonicHologram:
	movea.w $3e(a0), a1
	dc.b	$0C,$29,$00,$38,$00,$00		; cmpi.b #$38, $0(a1) (raw: not reproducible by assembler / suspicious)
	bne.w   ObjProjector_Destroy
	tst.b   $3f(a1)
	bne.w   ObjProjector_Destroy
	tst.b   oRoutine(a0)
	bne.s   loc_20F054
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.w  #$33e, oTile(a0)
	move.l  #$20f0a8, oMap(a0)
	moveq   #$8, d0
	moveq   #$4, d1
	moveq   #$0, d2
	tst.b   oSubtype(a0)
	bmi.s   loc_20F044
	moveq   #$14, d0
	moveq   #$18, d1
	moveq   #$1, d2
loc_20F044:
	move.b  d0, oXRadius(a0)
	move.b  d0, oWidth(a0)
	move.b  d1, oYRadius(a0)
	move.b  d2, oAnim(a0)
loc_20F054:
	lea     Ani_MetalSonicHologram(pc), a1
	jsr     AnimateObject.l
	jmp     DrawObject.l
Ani_MetalSonicHologram:
	dc.w	$0004,$000A,$0002,$0103,$01FF
	dc.w	$0004,$0401,$0404,$0104,$0401,$0404,$0104,$0401
	dc.w	$0104,$0401,$0104,$0401,$0104,$0401,$0105,$0501
	dc.w	$0505,$0105,$0501,$0505,$0105,$0501,$0105,$0501
	dc.w	$0105,$0501,$0105,$0501,$01FF
MapSpr_Projector:
	incbin	"Level/Collision Chaos/Data/MapSpr_Projector.bin"
ObjProjector_ExplosionLocs:
	dc.w	$0100,$0005,$EEF6,$0AF6,$0A0F,$00EE,$14F6,$1216
	dc.w	$0817,$190D,$F61C,$FDE7,$1E0A,$1420,$F602,$230D
	dc.w	$F628,$F60A,$FF00
DestroyOnGoodFuture:
	tst.b   goodFuture.l
	beq.s   loc_20F158
	cmpi.b  #$1, timeZone.l
	bne.s   loc_20F12A
	tst.b   oSubtype(a0)
	beq.s   loc_20F158
loc_20F12A:
	move.w  oX(a0), d5
	move.w  oY(a0), d6
	jsr     DeleteObject.l
	move.w  d5, oX(a0)
	move.w  d6, oY(a0)
	move.b  #$18, oID(a0)
	tst.b   oSprFlags(a0)
	bpl.s   loc_20F156
	move.w  #$9e, d0
	jsr     PlayFMSound.l
loc_20F156:
	addq.l  #$4, a7
loc_20F158:
	rts     
CheckAnimalPrescence:
	tst.b   oSubtype(a0)
	bmi.s   loc_20F18A
	cmpi.b  #$2, timeZone.l
	bge.s   loc_20F17A
	tst.b   projDestroyed.l
	bne.s   loc_20F18A
	addq.l  #$4, a7
	jmp     CheckObjDespawn.l
loc_20F17A:
	tst.b   goodFuture.l
	bne.s   loc_20F18A
	addq.l  #$4, a7
	jmp     DeleteObject.l
loc_20F18A:
	rts     
Obj3B_20F18C:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20F19A(pc, d0.w), d0
	jmp     dat_20F19A(pc, d0.w)
dat_20F19A:
	dc.w	ObjGameOver_Init-dat_20F19A
	dc.w	ObjGameOver_Main-dat_20F19A
ObjGameOver_Init:
	move.w  #$82, d0
	jsr     SubCPUCmd.l
	addq.b  #$2, oRoutine(a0)
	move.w  #$e0, oYScr(a0)
	move.w  #$80, oX(a0)
	move.w  #$120, $2a(a0)
	move.w  #$8544, oTile(a0)
	move.l  #$20f270, oMap(a0)
	move.b  #$8, powerup.l
	bclr.b  #$0, timeOver.l
	beq.s   loc_20F1F6
	tst.b   lives.l
	beq.s   loc_20F1FE
	move.l  #$20f274, oMap(a0)
	addq.b  #$2, powerup.l
	bra.s   loc_20F1FE
loc_20F1F6:
	tst.b   lives.l
	bne.s   loc_20F20E
loc_20F1FE:
	bset.b  #$7, powerup.l
	jsr     FindObjSlot.l
	beq.s   loc_20F214
loc_20F20E:
	jmp     DeleteObject.l
loc_20F214:
	dc.b	$13,$7C,$00,$3B,$00,$00		; move.b #$3b, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.b  oRoutine(a0), $24(a1)
	move.w  oTile(a0), $2(a1)
	move.l  oMap(a0), $4(a1)
	move.b  #$1, $1a(a1)
	move.w  #$e0, $a(a1)
	move.w  #$1c0, $8(a1)
	move.w  #$120, $2a(a1)
	tst.b   lives.l
	bne.s   ObjGameOver_Main
	move.w  #$6e, d0
	jmp     SubCPUCmd.l
ObjGameOver_Main:
	moveq   #$8, d0
	move.w  $2a(a0), d1
	cmp.w   oX(a0), d1
	beq.s   loc_20F26A
	bge.s   loc_20F266
	neg.w   d0
loc_20F266:
	add.w   d0, oX(a0)
loc_20F26A:
	jmp     DrawObject.l
MapSpr_GameOver:
	dc.w	$0008,$0014
MapSpr_TimeOver:
	dc.w	$001C,$0028,$02F8,$0D00,$00B8,$F80D,$0008,$D800
	dc.w	$02F8,$0D00,$1008,$F80D,$0018,$2800,$02F8,$0D00
	dc.w	$00BC,$F809,$0008,$DC00,$02F8,$0D00,$0E04,$F80D
	dc.w	$0016,$2400
Obj3C_20F2A8:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20F2B6(pc, d0.w), d0
	jmp     dat_20F2B6(pc, d0.w)
dat_20F2B6:
	dc.w	ObjTitleCard_Init-dat_20F2B6
	dc.w	ObjTitleCard_SlideInVert-dat_20F2B6
	dc.w	ObjTitleCard_SlideInHoriz-dat_20F2B6
	dc.w	ObjTitleCard_SlideOutVert-dat_20F2B6
	dc.w	ObjTitleCard_SlideOutHoriz-dat_20F2B6
	dc.w	ObjTitleCard_WaitPLC-dat_20F2B6
ObjTitleCard_Init:
	move.b  #$2, oRoutine(a0)
	move.w  #$118, oX(a0)
	move.w  #$30, oYScr(a0)
	move.w  #$30, $30(a0)
	move.w  #$f0, $2e(a0)
	move.b  #$5a, oAnimTime(a0)
	move.w  #$8360, oTile(a0)
	move.l  #$20f9b4, oMap(a0)
	move.b  #$4, oPriority(a0)
	moveq   #$0, d1
	moveq   #$7, d6
	lea     ObjTitleCard_Data.l, a2
loc_20F304:
	jsr     FindObjSlot.l
	dc.b	$13,$7C,$00,$3C,$00,$00		; move.b #$3c, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.b  #$4, $24(a1)
	move.w  #$8360, $2(a1)
	move.l  #$20f9b4, $4(a1)
	move.w  d1, d2
	lsl.w   #$3, d2
	move.w  (a2, d2.w), $a(a1)
	move.w  $2(a2, d2.w), $8(a1)
	move.w  $2(a2, d2.w), $2c(a1)
	move.w  $4(a2, d2.w), $2a(a1)
	move.b  $6(a2, d2.w), $1a(a1)
	cmpi.b  #$5, d1
	bne.s   loc_20F356
	move.b  act.l, d3
	add.b   d3, $1a(a1)
loc_20F356:
	move.b  $7(a2, d2.w), $1e(a1)
	addq.b  #$1, d1
	dbra    d6, loc_20F304
	rts     
ObjTitleCard_SlideInVert:
	moveq   #$8, d0
	move.w  $2e(a0), d1
	cmp.w   oYScr(a0), d1
	beq.s   loc_20F37E
	bge.s   loc_20F374
	neg.w   d0
loc_20F374:
	add.w   d0, oYScr(a0)
	jmp     DrawObject.l
loc_20F37E:
	addq.b  #$4, oRoutine(a0)
	jmp     DrawObject.l
ObjTitleCard_SlideInHoriz:
	moveq   #$8, d0
	move.w  $2a(a0), d1
	cmp.w   oX(a0), d1
	beq.s   loc_20F3A2
	bge.s   loc_20F398
	neg.w   d0
loc_20F398:
	add.w   d0, oX(a0)
	jmp     DrawObject.l
loc_20F3A2:
	addq.b  #$4, oRoutine(a0)
	jmp     DrawObject.l
ObjTitleCard_SlideOutVert:
	tst.b   oAnimTime(a0)
	beq.s   loc_20F3BC
	subq.b  #$1, oAnimTime(a0)
	jmp     DrawObject.l
loc_20F3BC:
	moveq   #$10, d0
	move.w  $30(a0), d1
	cmp.w   oYScr(a0), d1
	beq.s   loc_20F3D6
	bge.s   loc_20F3CC
	neg.w   d0
loc_20F3CC:
	add.w   d0, oYScr(a0)
	jmp     DrawObject.l
loc_20F3D6:
	addq.b  #$4, oRoutine(a0)
	move.b  #$1, scrollLock.w
	moveq   #$2, d0
	jmp     LoadPLC.l
ObjTitleCard_SlideOutHoriz:
	tst.b   oAnimTime(a0)
	beq.s   loc_20F3F8
	subq.b  #$1, oAnimTime(a0)
	jmp     DrawObject.l
loc_20F3F8:
	moveq   #$10, d0
	move.w  $2c(a0), d1
	cmp.w   oX(a0), d1
	beq.s   loc_20F412
	bge.s   loc_20F408
	neg.w   d0
loc_20F408:
	add.w   d0, oX(a0)
	jmp     DrawObject.l
loc_20F412:
	jmp     DeleteObject.l
ObjTitleCard_WaitPLC:
	tst.l   plcBuffer.w
	bne.s   loc_20F42C
	clr.b   scrollLock.w
	clr.b   ctrlLocked.w
	jmp     DeleteObject.l
loc_20F42C:
	rts     
ObjResults:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  dat_20F43C(pc, d0.w), d0
	jmp     dat_20F43C(pc, d0.w)
dat_20F43C:
	dc.w	ObjResults_Init-dat_20F43C
	dc.w	ObjResults_WaitPLC-dat_20F43C
	dc.w	ObjResults_Move-dat_20F43C
	dc.w	ObjResults_Bonus-dat_20F43C
	dc.w	ObjResults_NextLevel-dat_20F43C
ObjResults_Init:
	subq.b  #$1, $32(a0)
	beq.s   loc_20F44E
	rts     
loc_20F44E:
	moveq   #$10, d0
	jsr     LoadPLC.l
	addq.b  #$2, oRoutine(a0)
ObjResults_WaitPLC:
	tst.l   plcBuffer.w
	bne.s   loc_20F47C
	cmpi.w  #$502, zoneAct.l
	beq.s   loc_20F47E
	lea     objects.w, a6
	move.w  cameraX.w, d0
	addi.w  #$150, d0
	cmp.w   $8(a6), d0
	bcs.s   loc_20F47E
loc_20F47C:
	rts     
loc_20F47E:
	lea     ObjResults_InitData.l, a2
	moveq   #$2, d6
	moveq   #$0, d1
	movea.l a0, a1
	move.w  #$168, $32(a0)
	bra.s   loc_20F498
loc_20F492:
	jsr     FindObjSlot.l
loc_20F498:
	move.w  #$168, $32(a1)
	dc.b	$13,$7C,$00,$3A,$00,$00		; move.b #$3a, $0(a1) (raw: not reproducible by assembler / suspicious)
	move.b  #$4, $24(a1)
	move.w  #$83c4, $2(a1)
	cmpi.w  #$502, zoneAct.l
	bne.s   loc_20F4DA
	move.w  #$82f2, $2(a1)
	move.l  #$20f710, $4(a1)
	tst.b   goodFuture.l
	beq.s   loc_20F4F2
	move.l  #$20f724, $4(a1)
	bra.s   loc_20F4F2
loc_20F4DA:
	move.l  #$20f706, $4(a1)
	tst.b   goodFuture.l
	beq.s   loc_20F4F2
	move.l  #$20f71a, $4(a1)
loc_20F4F2:
	move.w  d1, d2
	lsl.w   #$3, d2
	move.w  (a2, d2.w), $a(a1)
	move.w  $2(a2, d2.w), $8(a1)
	move.w  $4(a2, d2.w), $2a(a1)
	move.b  $7(a2, d2.w), $1a(a1)
	cmpi.b  #$2, d1
	bne.s   loc_20F51E
	move.b  act.l, d2
	add.b   d2, $1a(a1)
loc_20F51E:
	addq.b  #$1, d1
	dbra    d6, loc_20F492
	rts     
ObjResults_Move:
	tst.w   $32(a0)
	beq.s   loc_20F530
	subq.w  #$1, $32(a0)
loc_20F530:
	moveq   #$8, d0
	move.w  $2a(a0), d1
	cmp.w   oX(a0), d1
	beq.s   loc_20F554
	bge.s   loc_20F540
	neg.w   d0
loc_20F540:
	add.w   d0, oX(a0)
loc_20F544:
	cmpi.w  #$160, $32(a0)
	bcc.s   loc_20F552
	jmp     DrawObject.l
loc_20F552:
	rts     
loc_20F554:
	tst.b   oMapFrame(a0)
	bne.s   loc_20F544
	addq.b  #$2, oRoutine(a0)
	bra.s   loc_20F544
ObjResults_Bonus:
	move.b  #$1, updateHUDBonus.w
	moveq   #$0, d0
	tst.w   timeBonus.w
	bne.s   loc_20F59E
	tst.w   ringBonus.w
	bne.s   loc_20F5AE
	subq.w  #$1, $32(a0)
	bpl.s   loc_20F57E
	addq.b  #$2, oRoutine(a0)
loc_20F57E:
	cmpi.w  #$1e, $32(a0)
	bne.s   loc_20F598
	tst.b   specialStage.l
	beq.s   loc_20F598
	move.w  #$c8, d0
	jsr     PlayFMSound.l
loc_20F598:
	jmp     DrawObject.l
loc_20F59E:
	addi.w  #$a, d0
	subi.w  #$64, timeBonus.w
	tst.w   ringBonus.w
	beq.s   loc_20F5B8
loc_20F5AE:
	addi.w  #$a, d0
	subi.w  #$64, ringBonus.w
loc_20F5B8:
	move.l  d0, d1
	tst.w   timeBonus.w
	bne.s   loc_20F5EA
	tst.w   ringBonus.w
	bne.s   loc_20F5EA
	jsr     StopZ80.l
	move.b  #$9a, $a01c09.l
	jsr     StartZ80.l
	cmpi.w  #$2d, $32(a0)
	bcc.s   loc_20F606
	move.w  #$2d, $32(a0)
	bra.s   loc_20F606
loc_20F5EA:
	tst.w   $32(a0)
	beq.s   loc_20F5F4
	subq.w  #$1, $32(a0)
loc_20F5F4:
	btst.b  #$0, $32(a0)
	bne.s   loc_20F606
	move.w  #$bd, d0
	jsr     PlayFMSound.l
loc_20F606:
	move.l  d1, d0
	jsr     AddPoints.l
	jmp     DrawObject.l
ObjResults_NextLevel:
	move.w  #$2, levelRestart.l
	move.b  #$0, spawnMode.l
	clr.w   sectionID.l
	clr.l   flowerCount.l
	clr.b   unkLevelFlag.l
	clr.b   projDestroyed.l
	clr.b   checkpoint.l
	tst.b   timeAttackMode.l
	beq.s   loc_20F652
	bclr.b  #$0, plcLoadFlags.l
loc_20F652:
	bclr.b  #$1, plcLoadFlags.l
	move.b  #$1, timeZone.l
	move.w  zoneAct.l, d0
	addq.b  #$1, d0
	cmpi.b  #$2, d0
	bne.s   loc_20F678
	move.b  #$2, timeZone.l
loc_20F678:
	cmpi.b  #$3, d0
	bne.s   loc_20F68A
	move.b  #$0, d0
	addi.w  #$100, d0
	move.b  #$0, d0
loc_20F68A:
	move.w  d0, zoneAct.l
	jsr     ResetSavedObjFlags.l
	jsr     FadeOutMusic.l
	jsr     DrawObject.l
	move.b  act.l, d0
	subq.b  #$1, d0
	bpl.s   loc_20F6B4
	clr.b   goodFutureFlags.l
	rts     
loc_20F6B4:
	tst.b   timeAttackMode.l
	bne.s   loc_20F6EC
	cmpi.b  #$7f, timeStones.l
	beq.s   loc_20F6E4
	tst.b   goodFuture.l
	beq.s   loc_20F6EC
	clr.b   goodFuture.l
	bset.b  d0, goodFutureFlags.l
	cmpi.b  #$3, goodFutureFlags.l
	bne.s   loc_20F6EC
loc_20F6E4:
	move.b  #$1, goodFuture.l
loc_20F6EC:
	rts     
ObjResults_InitData:
	dc.w	$00CC,$0000,$0120,$0000,$0110,$0200,$00F0,$0001
	dc.w	$00CC,$0000,$0120,$0002
ObjResults_InitDataEnd:
	dc.w	$0028,$01DE,$0052,$0086,$00BA
MapSpr_ResultsBadSSZ3:
	dc.w	$001E,$021C,$0048,$007C,$00B0
MapSpr_ResultsGood:
	dc.w	$00DA,$01CA,$0122,$015A,$0192
MapSpr_ResultsGoodSSZ3:
	incbin	"Level/Collision Chaos/Data/MapSpr_ResultsGoodSSZ3.bin"
ObjTitleCard_Data:
	incbin	"Level/Collision Chaos/Data/ObjTitleCard_Data.bin"
MapSpr_TitleCard:
	incbin	"Level/Collision Chaos/Data/MapSpr_TitleCard.bin"
UpdateAnimTiles:
	jmp     LoadShieldArt.l
LevelDataIndex:
	dc.l	$3000000|Art_LevelTiles
	dc.l	$2000000|LevelBlocks
	dc.l	LevelChunks
	dc.b	0
	dc.b	$81

LevelPaletteID:
	dc.b	4
	dc.b	4

PLCLists:
	dc.w	PLC_Level-PLCLists
	dc.w	PLC_Std-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Level-PLCLists
	dc.w	PLC_Cam2_Full-PLCLists
	dc.w	PLC_Cam3_Full-PLCLists
	dc.w	PLC_Cam4_Full-PLCLists
	dc.w	PLC_Cam5_Full-PLCLists
	dc.w	PLC_Cam1_Incr-PLCLists
	dc.w	PLC_Cam2_Incr-PLCLists
	dc.w	PLC_Cam3_Incr-PLCLists
	dc.w	PLC_Cam4_Incr-PLCLists
	dc.w	PLC_Cam5_Incr-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Results-PLCLists
	dc.w	PLC_Cam1_Full-PLCLists
	dc.w	PLC_Signpost-PLCLists

PLC_Level:
	dc.w	$1
	dc.l	Art_LevelTiles
	dc.w	$0
	dc.l	Art_Checkpoint
	dc.w	$D960

PLC_Std:
	dc.w	$E
	dc.l	Art_GoalPost
	dc.w	$6000
	dc.l	Art_TitleCard
	dc.w	$6C00
	dc.l	Art_23398C
	dc.w	$7A00
	dc.l	Art_2360D6
	dc.w	$8D40
	dc.l	Art_2363EC
	dc.w	$92A0
	dc.l	Art_23479A
	dc.w	$93A0
	dc.l	Art_234A00
	dc.w	$99C0
	dc.l	Art_DiagonalSpring
	dc.w	$9E40
	dc.l	Art_Springs
	dc.w	$A400
	dc.l	Art_HUD
	dc.w	$AD00
	dc.l	Art_MonitorTimePosts
	dc.w	$B500
	dc.l	Art_Explosions
	dc.w	$D000
	dc.l	Art_Points
	dc.w	$D8C0
	dc.l	Art_233732
	dc.w	$DAE0
	dc.l	Art_Rings
	dc.w	$F5C0

PLC_Cam1_Full:
	dc.w	$2
	dc.w	$23
	dc.w	$57F0
	dc.w	$63C0

	dc.b	$00,$23,$4E,$AC,$67,$C0,$00,$23,$4C,$14,$69,$C0
PLC_Cam2_Full:
	dc.w	$B
	dc.w	$23
	dc.w	$4D3A
	dc.w	$63C0
	dc.w	$23
	dc.w	$4EAC
	dc.w	$67C0
	dc.w	$23
	dc.w	$4C14
	dc.w	$69C0
	dc.w	$23
	dc.w	$6702
	dc.w	$6BC0

	dc.b	$00,$23,$50,$4A,$6E,$20,$00,$23,$50,$C6,$6F,$20,$00,$23,$4F,$90,$73,$E0,$00,$23,$65,$C6,$75,$E0,$00,$23,$68,$A2,$77,$A0,$00,$23,$6A,$C6,$7B,$40,$00,$23,$54,$52,$7E,$40,$00,$23,$5B,$D6,$84,$20
PLC_Cam3_Full:
	dc.w	$A
	dc.w	$23
	dc.w	$4D3A
	dc.w	$63C0
	dc.w	$23
	dc.w	$697A
	dc.w	$67C0
	dc.w	$23
	dc.w	$6702
	dc.w	$6BC0
	dc.w	$23
	dc.w	$504A

	dc.b	$6E,$20,$00,$23,$50,$C6,$6F,$20,$00,$23,$4F,$90,$73,$E0,$00,$23,$65,$C6,$75,$E0,$00,$23,$68,$A2,$77,$A0,$00,$23,$6A,$C6,$7B,$40,$00,$23,$54,$52,$7E,$40,$00,$23,$5B,$D6,$84,$20
PLC_Cam4_Full:
	dc.w	$B
	dc.w	$23
	dc.w	$4D3A
	dc.w	$63C0
	dc.w	$23
	dc.w	$4EAC
	dc.w	$67C0
	dc.w	$23
	dc.w	$4C14
	dc.w	$69C0
	dc.w	$23
	dc.w	$6702
	dc.w	$6BC0

	dc.b	$00,$23,$50,$4A,$6E,$20,$00,$23,$50,$C6,$6F,$20,$00,$23,$4F,$90,$73,$E0,$00,$23,$65,$C6,$75,$E0,$00,$23,$68,$A2,$77,$A0,$00,$23,$6A,$C6,$7B,$40,$00,$23,$54,$52,$7E,$40,$00,$23,$5B,$D6,$84,$20
PLC_Cam5_Full:
	dc.w	$0
	dc.w	$23

	dc.b	$57,$F0,$63,$C0
PLC_Cam1_Incr:
	dc.w	$B
	dc.w	$23
	dc.w	$4D3A
	dc.w	$63C0
	dc.w	$23
	dc.w	$4EAC
	dc.w	$67C0
	dc.w	$23
	dc.w	$4C14
	dc.w	$69C0
	dc.w	$23
	dc.w	$6702
	dc.w	$6BC0

	dc.b	$00,$23,$50,$4A,$6E,$20,$00,$23,$50,$C6,$6F,$20,$00,$23,$4F,$90,$73,$E0,$00,$23,$65,$C6,$75,$E0,$00,$23,$68,$A2,$77,$A0,$00,$23,$6A,$C6,$7B,$40,$00,$23,$54,$52,$7E,$40,$00,$23,$5B,$D6,$84,$20
PLC_Cam2_Incr:
	dc.w	$0
	dc.w	$23

	dc.b	$69,$7A,$67,$C0
PLC_Cam3_Incr:
	dc.w	$1
	dc.w	$23
	dc.w	$4EAC

	dc.b	$67,$C0,$00,$23,$4C,$14,$69,$C0
PLC_Cam4_Incr:
	dc.w	$1
	dc.w	$23
	dc.w	$B486

	dc.b	$6B,$C0,$00,$23,$AA,$D8,$7A,$00
PLC_Cam5_Incr:
	dc.w	$0
	dc.w	$23

	dc.b	$60,$D6,$8D,$40
PLC_Results:
	dc.w	$0
	dc.w	$23

	dc.b	$00,$98,$78,$80
PLC_Signpost:
	dc.w	$2
	dc.w	$22
	dc.w	$FABC
	dc.w	$8780

	incbin	"Level/Collision Chaos/Data/Padding (Act 1 Present).bin"
LevelChunks:
	incbin	"Level/Collision Chaos/Data/Chunks (Act 1 Present).bin"
LevelDemo:
	incbin	"Level/Collision Chaos/Data/Demo (Act 1 Present).bin"
ColAngleMap:
	incbin	"Level/_Data/Collision Angles.bin"
ColHeightMap:
	incbin	"Level/_Data/Collision Height Map.bin"
ColWidthMap:
	incbin	"Level/_Data/Collision Width Map.bin"
LevelCollision:
	incbin	"Level/Collision Chaos/Data/Collision (Act 1 Present).bin"
LevelLayouts:
	dc.w	.FG-LevelLayouts, .BG-LevelLayouts, .Null-LevelLayouts
	dc.w	.FG2-LevelLayouts, .Null4-LevelLayouts, .Null2-LevelLayouts
	dc.w	.FG3-LevelLayouts, .Null4-LevelLayouts, .Null4-LevelLayouts
	dc.w	.Unused-LevelLayouts, .Unused-LevelLayouts, .Unused-LevelLayouts
	dc.w	.FG-LevelLayouts, .BG-LevelLayouts, .Null-LevelLayouts
	dc.w	.FG2-LevelLayouts, .Null4-LevelLayouts, .Null2-LevelLayouts
	dc.w	.FG3-LevelLayouts, .Null4-LevelLayouts, .Null4-LevelLayouts
	dc.w	.Unused-LevelLayouts, .Unused-LevelLayouts, .Unused-LevelLayouts
	dc.w	.FG-LevelLayouts, .BG-LevelLayouts, .Null-LevelLayouts
	dc.w	.FG2-LevelLayouts, .Null4-LevelLayouts, .Null2-LevelLayouts
	dc.w	.FG3-LevelLayouts, .Null4-LevelLayouts, .Null4-LevelLayouts
	dc.w	.Unused-LevelLayouts, .Unused-LevelLayouts, .Unused-LevelLayouts
.FG:
	incbin	"Level/Collision Chaos/Data/Layout (FG, Act 1 Present).bin"
.BG:
	incbin	"Level/Collision Chaos/Data/Layout (BG, Act 1 Present).bin"
.Null:
	dc.b	$00,$00,$00,$00
.FG2:
	incbin	"Level/Collision Chaos/Data/Layout (FG2, Act 1 Present).bin"
.Null2:
	dc.b	$00,$00,$00,$00
.FG3:
	incbin	"Level/Collision Chaos/Data/Layout (FG3, Act 1 Present).bin"
.Null4:
	dc.b	$00,$00,$00,$00
.Unused:
	incbin	"Level/Collision Chaos/Data/Layout (Unused, Act 1 Present).bin"
Art_Sonic:
	incbin	"Level/Collision Chaos/Data/Art (Sonic).bin"
DPLC_Sonic:
	incbin	"Level/Collision Chaos/Data/DPLC (Sonic).bin"
Art_Points:
	incbin	"Level/Collision Chaos/Data/Art_Points.nem"
Art_FlowerCapsule:
	incbin	"Level/Collision Chaos/Data/Art_FlowerCapsule.nem"
Art_BigRing:
	incbin	"Level/Collision Chaos/Data/Art_BigRing.nem"
Art_GoalPost:
	incbin	"Level/Collision Chaos/Data/Art_GoalPost.nem"
Art_Signpost:
	incbin	"Level/Collision Chaos/Data/Art_Signpost.nem"
Art_Results:
	incbin	"Level/Collision Chaos/Data/Art_Results.nem"
Art_TimeOver:
	incbin	"Level/Collision Chaos/Data/Art_TimeOver.nem"
Art_GameOver:
	incbin	"Level/Collision Chaos/Data/Art_GameOver.nem"
Art_TitleCard:
	incbin	"Level/Collision Chaos/Data/Art_TitleCard.nem"
Art_Shield:
	incbin	"Level/Collision Chaos/Data/Art_Shield.nem"
Art_InvStars:
	incbin	"Level/Collision Chaos/Data/Art_InvStars.nem"
Art_TimeStars:
	incbin	"Level/Collision Chaos/Data/Art_TimeStars.nem"
Art_DiagonalSpring:
	incbin	"Level/Collision Chaos/Data/Art_DiagonalSpring.nem"
Art_Springs:
	incbin	"Level/Collision Chaos/Data/Art_Springs.nem"
Art_MonitorTimePosts:
	incbin	"Level/Collision Chaos/Data/Art_MonitorTimePosts.nem"
Art_Explosions:
	incbin	"Level/Collision Chaos/Data/Art_Explosions.nem"
Art_Rings:
	incbin	"Level/Collision Chaos/Data/Art_Rings.nem"
Art_LifeIcon:
	incbin	"Level/Collision Chaos/Data/Art_LifeIcon.nem"
Art_HUDNumbers:
	incbin	"Level/Collision Chaos/Data/Art_HUDNumbers.nem"
Art_HUD:
	incbin	"Level/Collision Chaos/Data/Art_HUD.nem"
Art_Checkpoint:
	incbin	"Level/Collision Chaos/Data/Art_Checkpoint.nem"
Ani_Flower:
	dc.w	$0008,$000C,$0012,$0018,$0300,$01FF,$0302,$0302
	dc.w	$03FC,$0105,$0504,$06FC,$1306,$07FF
MapSpr_Flower:
	incbin	"Level/Collision Chaos/Data/MapSpr_Flower.bin"
Art_233732:
	incbin	"Level/Collision Chaos/Data/Art_233732.nem"
Art_23398C:
	incbin	"Level/Collision Chaos/Data/Art_23398C.nem"
Art_23479A:
	incbin	"Level/Collision Chaos/Data/Art_23479A.nem"
Art_234A00:
	incbin	"Level/Collision Chaos/Data/Art_234A00.nem"
Art_234C14:
	incbin	"Level/Collision Chaos/Data/Art_234C14.nem"
Art_234D3A:
	incbin	"Level/Collision Chaos/Data/Art_234D3A.nem"
	dc.w	$8010,$8005,$1415,$1525,$1233,$0245,$1354,$0867
	dc.w	$7C73,$0081,$0518,$1407,$8205,$1B15,$1C57,$7D83
	dc.w	$0406,$1301,$8406,$3B85,$163C,$8605,$1A16,$3A87
	dc.w	$040B,$1519,$563D,$FFFF,$8EC6,$E1F7,$F30C,$29B3
	dc.w	$0E1C,$3B0B,$191C,$1C61,$A1D0,$0411,$4C07,$0E1D
	dc.w	$85C3,$5CEF,$BFD3,$7298,$8FC2,$B4EE,$A65F,$C7FC
	dc.w	$A000,$1FAE,$23FA,$DE53,$F4CF,$CADE,$FF6A,$D68A
	dc.w	$2F3F,$D0CF,$0B53,$6D0A,$37C6,$F8D5,$74F2,$D3A6
	dc.w	$A7F9,$FFCB,$F7C5,$9598,$F7FE,$D051,$457E,$53D0
	dc.w	$00FA,$61C7,$9FB6,$DD39,$FB1A,$EB33,$C664,$D9F9
	dc.w	$D0E8,$6AC3,$6962,$314B,$ABEA,$96BF,$4EBF,$4F17
	dc.w	$3C7F,$56BE,$7F0A,$5919,$AFB5,$FFB1,$041A,$FBDB
	dc.w	$45C5,$C5D0,$CBB3,$530E,$C048,$A336,$59C0,$1228
	dc.w	$CD97,$5B00,$48A3,$364E,$C048,$A336,$869F,$5D89
	dc.w	$1451,$4000
	dc.w	$8010,$8003,$0414,$0B25,$1B34,$0A55,$1A65,$1C72
	dc.w	$0081,$0303,$177C,$363C,$8803,$0216,$3B36,$3D78
	dc.w	$FA8E,$040C,$18FB,$8F06,$3AFF,$AF2F,$E7B1,$F73E
	dc.w	$754F,$EE35,$1E5E,$6B35,$91D6,$4600,$0000,$0000
	dc.w	$017D,$FEA7,$EBBF,$FFBF,$F775,$FF10,$27BB,$54A2
	dc.w	$AEDD,$28E9,$474A,$3EB2,$2B73,$F431,$3BFB,$DF85
	dc.w	$7BB5,$4A2A,$EDD2,$8E94,$74A3,$EB22,$B73F,$4313
	dc.w	$BFBD,$F800,$5FD7,$D7FF,$FFFD,$FF10,$2BDD,$AD2A
	dc.w	$5A5A,$51D2,$8FAB,$56E3,$DA77,$95E1,$5EED,$6952
	dc.w	$D2D2,$8E94,$7D5A,$B71E,$D3BC,$AF00,$0FAF,$EC5F
	dc.w	$EFDC,$53F7,$D5FC,$100D,$AE27,$A673,$39F3,$5807
	dc.w	$1713,$D339,$9CF9,$AC00,$0E00
	dc.w	$0008,$8103,$0077,$7C86,$0409,$151D,$777D,$8704
	dc.w	$0A75,$1788,$0408,$140D,$240C,$551E,$7302,$8903
	dc.w	$0115,$1C25,$1673,$03FF,$CFE3,$5A26,$B6D1,$35B6
	dc.w	$89AD,$B44D,$6DA2,$6B7F,$63FB,$9FD0,$FF27,$F226
	dc.w	$26B4,$7227,$F4E3,$915F,$A616,$FDC0,$63FB,$3F80
	dc.w	$3F91,$208F,$D01F,$D8FD,$4B3B,$EE2C,$6D5E,$E9B2
	dc.w	$0820,$FC1F,$52CE,$FB8B,$1B57,$BA6C,$8208,$3F07
	dc.w	$D4B3,$BEE2,$C6D5,$EE9B,$2082,$0FC0
Art_2350C6:
	incbin	"Level/Collision Chaos/Data/Art_2350C6.nem"
Art_235452:
	incbin	"Level/Collision Chaos/Data/Art_235452.nem"
	dc.w	$8010,$8004,$0715,$1624,$0835,$1845,$1257,$7C66
	dc.w	$3873,$0081,$0301,$2779,$551B,$7635,$8606,$3987
	dc.w	$063A,$163B,$8805,$1316,$3D45,$1977,$7D89,$0302
	dc.w	$2517,$8E14,$0A8F,$0406,$3778,$7634,$FF85,$C1E1
	dc.w	$8707,$E275,$22E4,$0C28,$5867,$6183,$0401,$13E9
	dc.w	$BA9C,$8F0C,$383F,$13A9,$1720,$6142,$C33B,$0C18
	dc.w	$200B,$2920,$1CC8,$8B34,$3000,$0006,$0B91,$058B
	dc.w	$9620,$3991,$1668,$6000,$000C,$1722,$27D7,$E9BA
	dc.w	$9BFD,$D3F2,$2376,$D7E6,$9F7E,$E9F9,$11BB,$6BF3
	dc.w	$4FB9,$BFEB,$EDE6,$3F9F,$AEB1,$A5BC,$E6F9,$BFEB
	dc.w	$EDE6,$3F9F,$AEB1,$A5BC,$E6E3,$F717,$7F14,$67BA
	dc.w	$DD78,$A39B,$80FF,$B8BB,$F8A3,$3DD6,$EBC5,$1CDC
	dc.w	$00FE,$A953,$73DC,$D537,$3DCD,$7A80,$025E,$A953
	dc.w	$73DC,$D537,$3DCD,$7A84,$8000
Data_2358CA:
	incbin	"Level/Collision Chaos/Data/Data_2358CA.bin"
Data_235A7A:
	incbin	"Level/Collision Chaos/Data/Data_235A7A.bin"
Art_235BD6:
	incbin	"Level/Collision Chaos/Data/Art_235BD6.nem"
Art_2360D6:
	incbin	"Level/Collision Chaos/Data/Art_2360D6.nem"
Art_2363EC:
	incbin	"Level/Collision Chaos/Data/Art_2363EC.nem"
Art_2365C6:
	incbin	"Level/Collision Chaos/Data/Art_2365C6.nem"
Art_236702:
	incbin	"Level/Collision Chaos/Data/Art_236702.nem"
	dc.w	$8008,$8003,$0114,$0724,$0535,$1846,$3858,$FB68
	dc.w	$FA76,$3981,$0404,$1636,$263C,$8204,$0A16,$3783
	dc.w	$0300,$263D,$8404,$0885,$040B,$8604,$0916,$3B87
	dc.w	$063A,$8C04,$0615,$1A27,$7C8F,$0519,$FFE3,$E2E9
	dc.w	$E5D8,$A196,$2DE7,$2675,$40A3,$CF2A,$0A63,$2BB3
	dc.w	$E7DC,$0404,$6A82,$7ACA,$C3C2,$D590,$986D,$C6EB
	dc.w	$AFD1,$7C7F,$92FA,$5692,$85B8,$DA98,$B4FD,$CBA3
	dc.w	$D372,$E842,$ECB9,$C7B9,$7604,$2076,$F505,$3781
	dc.w	$B841,$9A63,$B8DD,$9FF4,$5A5F,$98BF,$A0F3,$F5DC
	dc.w	$180B,$4965,$1608,$4C40,$20F7,$0411,$BF56,$5290
	dc.w	$C6D8,$A58A,$7959,$1D85,$1141,$7F2A,$852D,$EF09
	dc.w	$F5B7,$DC73,$C5BD,$D1B9,$B59B,$33C7,$509F,$6314
	dc.w	$E2E3,$BE97,$F2BF,$97B9,$5F24,$7E51,$141A,$118B
	dc.w	$8E93,$1052,$E3EA,$3970
Art_RobotGenWithered:
	incbin	"Level/Collision Chaos/Data/Art_RobotGenWithered.nem"
Art_236AC6:
	incbin	"Level/Collision Chaos/Data/Art_236AC6.nem"
LevelBlocks:
	incbin	"Level/Collision Chaos/Data/Blocks (Act 1 Present).nem"
Art_LevelTiles:
	incbin	"Level/Collision Chaos/Data/Tiles (Act 1 Present).nem"
Ani_Powerup:
	incbin	"Level/Collision Chaos/Data/Ani_Powerup.bin"
MapSpr_Powerup:
	incbin	"Level/Collision Chaos/Data/MapSpr_Powerup.bin"
Ani_TunnelDoorSplash:
	dc.w	$0006,$000E,$0014,$0300,$0403,$0102,$FC00,$0300
	dc.w	$0102,$FC00,$0306,$05FC
MapSpr_TunnelDoorSplash:
	incbin	"Level/Collision Chaos/Data/MapSpr_TunnelDoorSplash.bin"
Ani_TunnelDoor:
	dc.w	$0002,$0000,$0001,$0101,$0101,$0101,$01FC
MapSpr_TunnelDoor:
	dc.w	$0010,$0004,$02D0,$0300,$00E4,$F001,$0004,$E400
	dc.w	$02F8,$0C00,$06E8,$F804,$000A,$0800
Ani_TunnelWaterfall:
	dc.w	$0002,$0300,$0102,$FC00
MapSpr_TunnelWaterfall:
	dc.w	$0006,$000C,$0012,$01F0,$0F00,$00F0,$01F4,$0A00
	dc.w	$10F4,$01F8,$0500,$19F8
Ani_Explosion:
	dc.w	$0004,$000C,$0300,$0506,$0304,$FC00,$0300,$0102
	dc.w	$0304,$FC00
MapSpr_Explosion:
	incbin	"Level/Collision Chaos/Data/MapSpr_Explosion.bin"
Data_23A746:
	incbin	"Level/Collision Chaos/Data/Data_23A746.bin"
Ani_Checkpoint:
	dc.w	$0002,$0302,$03FF
MapSpr_Checkpoint:
	incbin	"Level/Collision Chaos/Data/MapSpr_Checkpoint.bin"
Ani_BigRing:
	dc.w	$0002,$0700,$0102,$03FF
MapSpr_BigRing:
	incbin	"Level/Collision Chaos/Data/MapSpr_BigRing.bin"
Ani_Signpost:
	dc.w	$0002,$0100,$0102,$0403,$0301,$0204,$FF00
MapSpr_GoalSignpost:
	incbin	"Level/Collision Chaos/Data/MapSpr_GoalSignpost.bin"
Art_Projector:
	dc.w	$0004,$002C,$0100,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0001,$0000,$0100,$0001,$FF00,$0203,$0405
	dc.w	$0607,$08FF
loc_23AA06:
	dc.w	$0012,$0050,$008E,$00AE,$00B4,$00BA,$00C0,$00C6
	dc.w	$00CC,$0CE0,$0100,$00F8,$E001,$0800,$00F0,$0800
	dc.w	$02E8,$F008,$0005,$00F8,$0D00,$08E0,$F80D,$0010
	dc.w	$0008,$0D00,$18E0,$080D,$0818,$0018,$0C00,$20E0
	dc.w	$180C,$0820,$0020,$0700,$54F0,$2007,$0854,$0000
	dc.w	$0CE0,$0100,$24F8,$E001,$0824,$00F0,$0800,$26E8
	dc.w	$F008,$0029,$00F8,$0D00,$2CE0,$F80D,$0034,$0008
	dc.w	$0D00,$3CE0,$080D,$083C,$0018,$0C00,$20E0,$180C
	dc.w	$0820,$0020,$0700,$54F0,$2007,$0854,$0000,$0608
	dc.w	$0D00,$44E0,$080D,$004C,$0018,$0C00,$20E0,$180C
	dc.w	$0820,$0020,$0700,$54F0,$2007,$0854,$0000,$01F8
	dc.w	$0500,$5CF8,$01F8,$0500,$60F8,$01F8,$0500,$64F8
	dc.w	$01F8,$0508,$64F8,$01F8,$0508,$60F8,$01F8,$0508
	dc.w	$5CF8
Art_23AAD8:
	incbin	"Level/Collision Chaos/Data/Art_23AAD8.nem"
Art_23B486:
	incbin	"Level/Collision Chaos/Data/Art_23B486.nem"
Data_23BC54:
	incbin	"Level/Collision Chaos/Data/Data_23BC54.bin"
Data_23BDB2:
	incbin	"Level/Collision Chaos/Data/Data_23BDB2.bin"
Data_23BF08:
	incbin	"Level/Collision Chaos/Data/Data_23BF08.bin"
Data_23FE68:
	incbin	"Level/Collision Chaos/Data/Data_23FE68.bin"
