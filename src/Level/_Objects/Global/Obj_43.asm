; Object $43 - Obj43_20E410 (from R81A, old ID $43)
P43_Obj43_20E410:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjRobotGenerator_Index(pc, d0.w), d0
	jsr     ObjRobotGenerator_Index(pc, d0.w)
	jsr     DrawObject.l
	cmpi.b  #$2, oRoutine(a0)
	bgt.s   P43_loc_20E432
	jmp     CheckObjDespawn.l
P43_loc_20E432:
	rts     
