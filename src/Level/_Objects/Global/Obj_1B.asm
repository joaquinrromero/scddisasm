; Object $1B - Obj1B_2095F8 (from R11A, old ID $1B)
Obj1B_2095F8:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P1B_dat_209612(pc, d0.w), d0
	jsr     P1B_dat_209612(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P1B_dat_209612:
	dc.w	ObjBoulder_Init-P1B_dat_209612
	dc.w	ObjBoulder_Main-P1B_dat_209612
