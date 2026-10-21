; Object $32 - Obj32_208702 (from R11B, old ID $32)
P32_Obj32_208702:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P32_dat_20871C(pc, d0.w), d0
	jsr     P32_dat_20871C(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P32_dat_20871C:
	dc.w	P32_loc_208720-P32_dat_20871C
	dc.w	ObjLogShadow_Main-P32_dat_20871C
P32_loc_208720:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.l  #$208788, oMap(a0)
	move.b  oSubtype(a0), oMapFrame(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$18, oYRadius(a0)
	bsr.w   ObjScenery_SetBaseTile
