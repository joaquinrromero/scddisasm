; Object $AD - Obj2F_20F900 (from R61A, old ID $2F)
Obj2F_20F900:
	tst.b   oSubtype(a0)
	bne.w   ObjMetalSonicHologram
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  PAD_dat_20F93A(pc, d0.w), d0
	jsr     PAD_dat_20F93A(pc, d0.w)
	jsr     DrawObject.l
	cmpi.b  #$2, oRoutine(a0)
	bgt.s   PAD_loc_20F938
	jsr     CheckObjDespawn.l
	tst.b   (a0)
	bne.s   PAD_loc_20F938
	move.w  #$4, d0
	jmp     LoadPLC.l
PAD_loc_20F938:
	rts     
PAD_dat_20F93A:
	dc.w	ObjProjector_Init-PAD_dat_20F93A
	dc.w	ObjProjector_Main-PAD_dat_20F93A
	dc.w	ObjProjector_StartExploding-PAD_dat_20F93A
	dc.w	ObjProjector_Exploding-PAD_dat_20F93A
	dc.w	ObjProjector_Destroyed-PAD_dat_20F93A
