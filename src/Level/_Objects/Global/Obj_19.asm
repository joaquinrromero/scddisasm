; Object $19 - ObjMonitorTimepost (from R11A, old ID $19)
ObjMonitorTimepost:
	tst.b   oSubtype(a0)
	bne.s   ObjMonitor
	tst.b   timeAttackMode.l
	beq.s   ObjMonitor
	jmp     CheckObjDespawn.l
