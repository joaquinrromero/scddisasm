; Object $28 - Obj28_20BC18 (from R12A, old ID $28)
P28_Obj28_20BC18:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P28_dat_20BC2C(pc, d0.w), d0
	jsr     P28_dat_20BC2C(pc, d0.w)
	jmp     CheckObjDespawn.l
P28_dat_20BC2C:
	dc.w	ObjSpringBoard_Init-P28_dat_20BC2C
	dc.w	ObjSpringBoard_NormalMain-P28_dat_20BC2C
	dc.w	ObjSpringBoard_FlipMain-P28_dat_20BC2C
	dc.w	ObjSpringBoard_NormalMain2-P28_dat_20BC2C
	dc.w	ObjSpringBoard_FlipMain2-P28_dat_20BC2C
	dc.w	ObjSpringBoard_NormalFling-P28_dat_20BC2C
	dc.w	ObjSpringBoard_FlipFling-P28_dat_20BC2C
