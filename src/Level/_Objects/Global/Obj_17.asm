; Object $17 - Obj17_20D7C2 (from R11A, old ID $17)
P17_Obj17_20D7C2:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P17_dat_20D7D6(pc, d0.w), d0
	jsr     P17_dat_20D7D6(pc, d0.w)
	jmp     DrawObject.l
P17_dat_20D7D6:
	dc.w	ObjSignpost_Init-P17_dat_20D7D6
	dc.w	ObjSignpost_Main-P17_dat_20D7D6
	dc.w	ObjSignpost_Spin-P17_dat_20D7D6
	dc.w	StartResults-P17_dat_20D7D6
	dc.w	ResultsActive-P17_dat_20D7D6
