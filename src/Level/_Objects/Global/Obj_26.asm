; Object $26 - Obj26_20C128 (from R11A, old ID $26)
P26_Obj26_20C128:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P26_dat_20C136(pc, d0.w), d0
	jmp     P26_dat_20C136(pc, d0.w)
P26_dat_20C136:
	dc.w	ObjSpikes_Init-P26_dat_20C136
	dc.w	ObjSpikes_Main-P26_dat_20C136
