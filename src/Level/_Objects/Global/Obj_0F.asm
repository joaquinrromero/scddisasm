; Object $0F - ObjMovingSpring (from R11A, old ID $0F)
ObjMovingSpring:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjMovingSpring_Index(pc, d0.w), d0
	jsr     ObjMovingSpring_Index(pc, d0.w)
	move.w  $36(a0), d0
	andi.w  #$ff80, d0
	move.w  cameraX.w, d1
	subi.w  #$80, d1
	andi.w  #$ff80, d1
	sub.w   d1, d0
	cmpi.w  #$280, d0
	bhi.w   DeleteObject
	rts     
ObjMovingSpring_Index:
	dc.w	ObjMovingSpring_Init-ObjMovingSpring_Index
	dc.w	ObjMovingSpring_AlignToGround-ObjMovingSpring_Index
	dc.w	ObjMovingSpring_Main-ObjMovingSpring_Index
ObjMovingSpring_Init:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.l  #$209c7c, oMap(a0)
	move.b  #$8, oWidth(a0)
	move.b  #$7, oYRadius(a0)
	move.w  oX(a0), $36(a0)
	move.w  #$180, oXVel(a0)
	moveq   #$e, d0
	jsr     SetObjectTileID.l
	jsr     FindObjSlot.l
	beq.s   P0F_loc_2096EA
	jmp     DeleteObject.l
P0F_loc_2096EA:
	dc.b	$13,$7C,$00,$0A,$00,$00		; move.b #$a, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$10, $c(a1)
	move.b  #$f0, $39(a1)
	move.w  a0, $34(a1)
	move.b  oSubtype(a0), $28(a1)
ObjMovingSpring_AlignToGround:
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P0F_loc_20972C
	add.w   d1, oY(a0)
	move.w  oY(a0), $32(a0)
	addq.b  #$2, oRoutine(a0)
	rts     
P0F_loc_20972C:
	addq.w  #$1, oY(a0)
	rts     
ObjMovingSpring_Main:
	tst.w   timeStopTimer.l
	bne.s   P0F_loc_209768
	jsr     ObjGetFloorDist.l
	add.w   d1, oY(a0)
	move.w  $32(a0), d0
	sub.w   oY(a0), d0
	cmpi.w  #$c, d0
	bcs.s   P0F_loc_209756
	neg.w   oXVel(a0)
P0F_loc_209756:
	jsr     ObjMove.l
	lea     Ani_MovingSpring.l, a1
	jsr     AnimateObject.l
P0F_loc_209768:
	jmp     DrawObject.l
