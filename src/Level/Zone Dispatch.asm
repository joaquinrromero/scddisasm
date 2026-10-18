; -------------------------------------------------------------------------
; Sonic CD Disassembly - Mega Drive port
; -------------------------------------------------------------------------
; Per-time-zone dispatch. The engine is assembled once; everything that
; differs between Past/Present/Future is reached through the zone variables.
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Load the zone variables for the current time zone
; -------------------------------------------------------------------------

LoadZoneVars:
	moveq	#0,d0
	move.b	timeZone,d0			; Get time zone (past, present, future)
	andi.w	#$7F,d0				; (bit 7 only means that we are time warping)
	cmpi.w	#TIME_FUTURE,d0			; Are we in the future?
	bne.s	.GetZone				; If not, branch
	tst.b	goodFuture				; Is it the good future?
	bne.s	.GetZone				; If so, branch (index 2)
	moveq	#3,d0					; Bad future (index 3)

.GetZone:
	moveq	#0,d1
	move.b	act,d1					; Act (0-2): each act has its own block of four time zones
	lsl.w	#2,d1
	add.w	d1,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	ZoneTable,a0
	movea.l	(a0,d0.w),a0			; Get this zone's pointer block
	lea	zoneVars.w,a1
	moveq	#(zoneVarsEnd-zoneVars)/4-1,d0
.Copy:
	move.l	(a0)+,(a1)+
	dbf	d0,.Copy
	rts

; -------------------------------------------------------------------------
; Zone code entry points (jump through the zone variable, keep all registers)
; -------------------------------------------------------------------------

ZoneLevelSizeLoad:
	move.l	zLevelSizeLoad.w,-(sp)
	rts

ZoneLevelScroll:
	move.l	zLevelScroll.w,-(sp)
	rts

ZoneDrawLevel:
	move.l	zDrawLevel.w,-(sp)
	rts

ZoneInitLevelDraw:
	move.l	zInitLevelDraw.w,-(sp)
	rts

ZoneDrawLevelBG:
	move.l	zDrawLevelBG.w,-(sp)
	rts

ZonePaletteCycle:
	move.l	zPaletteCycle.w,-(sp)
	rts

; -------------------------------------------------------------------------
