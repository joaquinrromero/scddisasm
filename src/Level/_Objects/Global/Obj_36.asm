; Object $36 - Obj36_20F8A4 (from R11A, old ID $36)
P36_Obj36_20F8A4:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P36_dat_20F8B2(pc, d0.w), d0
	jmp     P36_dat_20F8B2(pc, d0.w)
P36_dat_20F8B2:
	dc.w	ObjBreakableWall_Init-P36_dat_20F8B2
	dc.w	ObjBreakableWall_Main-P36_dat_20F8B2
	dc.w	ObjBreakableWall_Fall-P36_dat_20F8B2
