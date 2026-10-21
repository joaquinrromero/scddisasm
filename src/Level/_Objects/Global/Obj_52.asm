; Object $52 - ObjProjector (from R41B, old ID $52)
ObjProjector:
	tst.b   oSubtype(a0)
	bne.w   ObjMetalSonicHologram
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjProjector_Index(pc, d0.w), d0
	jsr     ObjProjector_Index(pc, d0.w)
	jsr     DrawObject.l
	cmpi.b  #$2, oRoutine(a0)
	bgt.s   P52_loc_20F4BA
	jmp     CheckObjDespawn.l
P52_loc_20F4BA:
	rts     
ObjProjector_Index:
	dc.w	P52_loc_20F4CC-ObjProjector_Index
	dc.w	ObjProjector_Main-ObjProjector_Index
	dc.w	ObjProjector_StartExploding-ObjProjector_Index
	dc.w	ObjProjector_Exploding-ObjProjector_Index
	dc.w	ObjProjector_Destroyed-ObjProjector_Index
ObjProjector_Main:
	tst.b   oColStatus(a0)
	beq.s   P52_loc_20F5E4
	clr.w   oColType(a0)
	addq.b  #$2, oRoutine(a0)
P52_loc_20F5E4:
	lea     objects.w, a1
	jmp     SolidObject.l
ObjProjector_StartExploding:
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, oMapFrame(a0)
	st.b    $3f(a0)
	lea     objects.w, a1
	jsr     SolidObject.l
	beq.s   ObjProjector_Exploding
	jsr     GetOffObject.l
ObjProjector_Exploding:
	movea.l $2c(a0), a6
	move.b  (a6)+, d0
	bmi.s   P52_loc_20F660
	addq.b  #$1, $2a(a0)
	cmp.b   $2a(a0), d0
	bne.s   P52_loc_20F65E
	move.b  (a6)+, d5
	move.b  (a6)+, d6
	move.l  a6, $2c(a0)
	ext.w   d5
	ext.w   d6
	jsr     FindObjSlot.l
	bne.s   P52_loc_20F65E
	dc.b	$13,$7C,$00,$18,$00,$00		; move.b #$18, $0(a1) (raw: not reproducible by assembler)
	move.b  #$1, $25(a1)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	add.w   d5, $8(a1)
	add.w   d6, $c(a1)
	move.w  #$9e, d0
	jsr     PlayFMSound.l
P52_loc_20F65E:
	rts     
P52_loc_20F660:
	addq.b  #$2, oRoutine(a0)
	move.w  #$3c, $2a(a0)
	rts     
ObjProjector_Destroyed:
	subq.w  #$1, $2a(a0)
	bne.s   P52_locret_20E6E6
	st.b    projDestroyed.l
	bra.w   ObjProjector_Destroy
P52_locret_20E6E6:
	rts     
ObjProjector_Destroy:
	jmp     DeleteObject.l
P52_loc_20F4CC:
	tst.b   projDestroyed.l
	bne.s   ObjProjector_Destroy
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.b  #$c, oXRadius(a0)
	move.b  #$c, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.b  #$fb, oColType(a0)
	move.w  #$3b0, oTile(a0)
	move.l  #$20f72e, oMap(a0)
	move.l  #$20f772, $2c(a0)
	jsr     FindObjSlot.l
	bne.w   ObjProjector_Destroy
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$15, $8(a1)
	subq.w  #$7, $c(a1)
	move.b  #$ff, $28(a1)
	move.w  a0, $3e(a1)
	jsr     FindObjSlot.l
	bne.w   ObjProjector_Destroy
	dc.b	$13,$68,$00,$00,$00,$00		; move.b oID(a0), $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$58, $8(a1)
	subq.w  #$4, $c(a1)
	move.b  #$1, $28(a1)
	move.w  a0, $3e(a1)
	jsr     FindObjSlot.l
	bne.w   ObjProjector_Destroy
	dc.b	$13,$7C,$00,$2F,$00,$00		; move.b #$2f, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$4c, $8(a1)
	addi.w  #$ffe4, $c(a1)
	move.b  #$80, $28(a1)
	move.w  a0, $3e(a1)
	jsr     FindObjSlot.l
	bne.w   ObjProjector_Destroy
	dc.b	$13,$7C,$00,$2F,$00,$00		; move.b #$2f, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$54, $8(a1)
	addi.w  #$ffef, $c(a1)
	move.b  #$81, $28(a1)
	move.w  a0, $3e(a1)
