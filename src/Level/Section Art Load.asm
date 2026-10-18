; -------------------------------------------------------------------------
; Sonic CD Disassembly
; -------------------------------------------------------------------------
; Section art load functions
; -------------------------------------------------------------------------

LoadSectionArt:
	movea.l	zSectionRanges.w,a1
	moveq	#0,d0
	moveq	#0,d1
	move.w	cameraX.w,d0

.Loop:
	cmp.w	(a1)+,d0
	bcs.s	.LoadPLC
	addq.b	#2,d1
	bra.s	.Loop

.LoadPLC:
	move.b	d1,sectionID
	movea.l	zSectionInitPLCs.w,a1
	move.w	(a1,d1.w),d0
	jmp	LoadPLC

; -------------------------------------------------------------------------

UpdateSectionArt:
	movea.l	zSectionRanges.w,a1
	moveq	#0,d0
	moveq	#0,d1
	move.w	cameraX.w,d0

.Loop:
	cmp.w	(a1)+,d0
	bcs.s	.FoundRange
	addq.b	#2,d1
	bra.s	.Loop

.FoundRange:
	cmp.b	sectionID,d1
	bne.s	.LoadPLC
	rts

.LoadPLC:
	move.b	d1,sectionID
	movea.l	zSectionUpdatePLCs.w,a1
	move.w	(a1,d1.w),d0
	jmp	InitPLC

; -------------------------------------------------------------------------
