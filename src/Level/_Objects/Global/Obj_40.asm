; Object $40 - Obj40_20BAA8 (from R11A, old ID $40)
P40_Obj40_20BAA8:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P40_dat_20BACC(pc, d0.w), d0
	jsr     P40_dat_20BACC(pc, d0.w)
	jsr     DrawObject.l
	move.w  $2a(a0), d0
	jmp     CheckObjDespawn2.l
P40_dat_20BACC:
	dc.w	ObTagaTaga_Init-P40_dat_20BACC
	dc.w	ObjTagaTaga_Init2-P40_dat_20BACC
	dc.w	ObjTagaTaga_Animate-P40_dat_20BACC
	dc.w	ObjTagaTaga_Jump-P40_dat_20BACC
	dc.w	ObjTagaTaga_Main-P40_dat_20BACC
