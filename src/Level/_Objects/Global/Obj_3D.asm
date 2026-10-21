; Object $3D - Obj3D_20B586 (from R11A, old ID $3D)
Obj3D_20B586:
	jsr     DestroyOnGoodFuture.l
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjMosqui_Index(pc, d0.w), d0
	jsr     ObjMosqui_Index(pc, d0.w)
	jsr     DrawObject.l
	move.w  $2a(a0), d0
	jmp     CheckObjDespawn2.l
