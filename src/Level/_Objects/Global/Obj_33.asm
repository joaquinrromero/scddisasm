; Object $33 - Obj33_20896E (from R11A, old ID $33)
P33_Obj33_20896E:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P33_dat_208988(pc, d0.w), d0
	jsr     P33_dat_208988(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P33_dat_208988:
	dc.w	ObjLogShadow_Init-P33_dat_208988
	dc.w	ObjLogShadow_Main-P33_dat_208988
