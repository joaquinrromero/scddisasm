; Object $0D - ObjTunnelDoor (from R11A, old ID $0D)
ObjTunnelDoor:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjTunnelDoor_Index(pc, d0.w), d0
	jsr     ObjTunnelDoor_Index(pc, d0.w)
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
ObjTunnelDoor_Index:
	dc.w	ObjTunnelDoor_Init-ObjTunnelDoor_Index
	dc.w	ObjTunnelDoor_Main-ObjTunnelDoor_Index
	dc.w	ObjTunnelDoor_Animate-ObjTunnelDoor_Index
	dc.w	ObjTunnelDoor_Reset-ObjTunnelDoor_Index
ObjTunnelDoor_Init:
	addq.b  #$2, oRoutine(a0)
	move.l  #$23f038, oMap(a0)
	move.b  #$1, oPriority(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$2c, oWidth(a0)
	cmpi.b  #$2, oSubtype(a0)
	bne.s   P0D_loc_20632C
	move.b  #$18, oWidth(a0)
P0D_loc_20632C:
	move.b  #$8, oYRadius(a0)
	moveq   #$c, d0
	jsr     SetObjectTileID.l
ObjTunnelDoor_Main:
	lea     objects.w, a1
	bsr.w   ObjTunnelDoor_ChkPlayer
	lea     objPlayerSlot2.w, a1
	bra.w   ObjTunnelDoor_ChkPlayer
ObjTunnelDoor_Animate:
	lea     Ani_TunnelDoor.l, a1
	bra.w   AnimateObject
ObjTunnelDoor_Reset:
	move.b  #$1, oPrevAnim(a0)
	move.b  #$0, oMapFrame(a0)
	subq.b  #$4, oRoutine(a0)
	rts     
ObjTunnelDoor_ChkPlayer:
	tst.w   $12(a1)
	bpl.s   P0D_loc_2062F2
	bsr.w   ObjTunnelDoor_ChkCollision
	beq.s   P0D_loc_2062F2
	move.b  #$4, oRoutine(a0)
	tst.b   oSubtype(a0)
	bne.s   P0D_loc_2062F0
	jsr     FindObjSlot.l
	bne.s   P0D_loc_2062F0
	dc.b	$13,$7C,$00,$0B,$00,$00		; move.b #$b, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subq.w  #$4, $c(a1)
	move.w  #$a4, d0
	jmp     PlayFMSound.l
P0D_loc_2062F0:
	rts     
P0D_loc_2062F2:
	move.w  oX(a0), d3
	move.w  oY(a0), d4
	jmp     TopSolidObject.l
ObjTunnelDoor_ChkCollision:
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	moveq   #$0, d1
	move.b  oWidth(a0), d1
	add.w   d1, d0
	bmi.s   P0D_loc_20639A
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P0D_loc_20639A
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	moveq   #$0, d1
	move.b  oYRadius(a0), d1
	add.w   d1, d0
	bmi.s   P0D_loc_20639A
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P0D_loc_20639A
	moveq   #$1, d0
	rts     
P0D_loc_20639A:
	moveq   #$0, d0
	rts     
