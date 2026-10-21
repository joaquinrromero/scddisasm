; Object $A0 - Obj25_20E40E (from R71A, old ID $25)
PA0_Obj25_20E40E:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjMosqui_Index(pc, d0.w), d0
	jsr     ObjMosqui_Index(pc, d0.w)
	jsr     DrawObject.l
	move.w  $2a(a0), d0
	jmp     CheckObjDespawn2.l
