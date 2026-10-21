; Object $95 - ObjProjector (from R51A, old ID $2C)
ObjProjector:
	tst.b   oSubtype(a0)
	bne.w   ObjMetalSonicHologram
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjProjector_Index(pc, d0.w), d0
	jsr     ObjProjector_Index(pc, d0.w)
	jsr     DrawObject.l
	cmpi.b  #$2, oRoutine(a0)
	bgt.s   P95_loc_20F35C
	jsr     CheckObjDespawn.l
	tst.b   (a0)
	bne.s   P95_loc_20F35C
	move.w  #$7, d0
	jmp     LoadPLC.l
P95_loc_20F35C:
	rts     
ObjProjector_Index:
	dc.w	P95_loc_20F36E-ObjProjector_Index
P95_loc_20F360:
	dc.w	ObjProjector_Main-ObjProjector_Index
	dc.w	ObjProjector_StartExploding-ObjProjector_Index
	dc.w	ObjProjector_Exploding-ObjProjector_Index
	dc.w	ObjProjector_Destroyed-ObjProjector_Index
ObjProjector_Main:
	tst.b   oColStatus(a0)
	beq.s   P95_loc_20F48E
	clr.w   oColType(a0)
	addq.b  #$2, oRoutine(a0)
P95_loc_20F48E:
	lea     objects.w, a1
	jmp     SolidObject.l
ObjProjector_StartExploding:
	addq.b  #$2, oRoutine(a0)
	move.b  #$1, oMapFrame(a0)
	st.b    $3f(a0)
	move.w  #$7, d0
	jsr     LoadPLC.l
	lea     objects.w, a1
	jsr     SolidObject.l
	beq.s   ObjProjector_Exploding
	jsr     GetOffObject.l
ObjProjector_Exploding:
	movea.l $2c(a0), a6
	move.b  (a6)+, d0
ObjProjector_Destroyed:
	subq.w  #$1, $2a(a0)
	bne.s   P95_locret_20E6E6
	st.b    projDestroyed.l
	bra.w   ObjProjector_Destroy
P95_locret_20E6E6:
	rts     
ObjProjector_Destroy:
	jmp     DeleteObject.l
P95_loc_20F36E:
	tst.b   projDestroyed.l
	bne.s   ObjProjector_Destroy
	move.w  #$8, d0
	jsr     LoadPLC.l
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$4, oPriority(a0)
	move.b  #$c, oXRadius(a0)
	move.b  #$c, oWidth(a0)
	move.b  #$c, oYRadius(a0)
	move.b  #$fb, oColType(a0)
	move.w  #$3b6, oTile(a0)
	move.l  #$20f5e2, oMap(a0)
	move.l  #$20f626, $2c(a0)
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
	dc.b	$13,$7C,$00,$2D,$00,$00		; move.b #$2d, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$58, $8(a1)
	addi.w  #$ffe8, $c(a1)
	move.b  #$80, $28(a1)
	move.w  a0, $3e(a1)
	jsr     FindObjSlot.l
	bne.w   ObjProjector_Destroy
	dc.b	$13,$7C,$00,$2D,$00,$00		; move.b #$2d, $0(a1) (raw: not reproducible by assembler)
	move.w  oX(a0), $8(a1)
	move.w  oY(a0), $c(a1)
	subi.w  #$64, $8(a1)
	addq.w  #$4, $c(a1)
	move.b  #$81, $28(a1)
	move.w  a0, $3e(a1)
