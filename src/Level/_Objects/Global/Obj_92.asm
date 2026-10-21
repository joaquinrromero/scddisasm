; Object $92 - Obj20_20D15E (from R51A, old ID $20)
P92_Obj20_20D15E:
	tst.b   oSubtype(a0)
	bmi.w   loc_20D304
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjMosqui_Index(pc, d0.w), d0
	jsr     ObjMosqui_Index(pc, d0.w)
	jsr     DrawObject.l
	move.w  $2a(a0), d0
	jmp     CheckObjDespawn2.l
