; Object $31 - Obj31_208A0C (from R11A, old ID $31)
P31_Obj31_208A0C:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P31_dat_208A20(pc, d0.w), d0
	jsr     P31_dat_208A20(pc, d0.w)
	jmp     CheckObjDespawn.l
P31_dat_208A20:
	dc.w	ObjSonicHole_Init-P31_dat_208A20
	dc.w	ObjSonicHole_Main-P31_dat_208A20
	dc.w	ObjSonicHole_Display-P31_dat_208A20
