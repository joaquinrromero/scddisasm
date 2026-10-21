; Object $2A - Obj3DRamp (from R11A, old ID $2A)
Obj3DRamp:
	lea     objects.w, a6
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	tst.b   oLayer(a0)
	bne.w   Obj3DFall
	move.w  Obj3DRamp_Index(pc, d0.w), d0
	jsr     Obj3DRamp_Index(pc, d0.w)
	jsr     DrawObject.l
	move.w  $2a(a0), d0
	bra.w   CheckObjDespawn2
Obj3DRamp_Index:
	dc.w	Obj3DRamp_Init-Obj3DRamp_Index
	dc.w	Obj3DRamp_Main-Obj3DRamp_Index
Obj3DRamp_Init:
	addq.b  #$2, oRoutine(a0)
	move.b  #$4, oSprFlags(a0)
	move.b  #$1, oPriority(a0)
	move.l  #$21fdbc, oMap(a0)
	move.w  #$441, oTile(a0)
	move.b  #$20, oWidth(a0)
	move.b  #$20, oYRadius(a0)
	move.w  oX(a0), $2a(a0)
	tst.b   oSubtype(a0)
	beq.s   Obj3DRamp_Main
	bset.b  #$0, oSprFlags(a0)
	bset.b  #$0, oFlags(a0)
Obj3DRamp_Main:
	tst.b   $2e(a0)
	beq.s   P2A_loc_20DF5C
	move.b  #$1, oAnim(a0)
	btst.b  #$1, $2c(a6)
	bne.s   P2A_loc_20DF4E
	addq.b  #$1, oAnim(a0)
P2A_loc_20DF4E:
	lea     Ani_3DRamp.l, a1
	jsr     AnimateObject.l
	bra.s   P2A_loc_20DF6C
P2A_loc_20DF5C:
	move.b  #$0, oMapFrame(a0)
	moveq   #$0, d1
	btst.b  #$1, $2c(a6)
	beq.s   P2A_loc_20DFB8
P2A_loc_20DF6C:
	move.w  $8(a6), d0
	andi.w  #$ff, d0
	tst.b   oSubtype(a0)
	beq.s   P2A_loc_20DF82
	move.w  d0, d1
	move.w  #$ff, d0
	sub.w   d1, d0
P2A_loc_20DF82:
	cmpi.w  #$c0, d0
	bcs.s   P2A_loc_20DF96
	cmpi.w  #$f0, d0
	bcc.s   P2A_loc_20DF94
	move.w  #$bf, d0
	bra.s   P2A_loc_20DF96
P2A_loc_20DF94:
	moveq   #$0, d0
P2A_loc_20DF96:
	ext.l   d0
	move.w  d0, d1
	tst.b   $2e(a0)
	bne.s   P2A_loc_20DFA8
	divu.w  #$30, d0
	move.b  d0, oMapFrame(a0)
P2A_loc_20DFA8:
	lsr.w   #$2, d1
	move.w  d1, d2
	lsr.w   #$1, d2
	add.w   d2, d1
	tst.b   oSubtype(a0)
	beq.s   P2A_loc_20DFB8
	neg.w   d1
P2A_loc_20DFB8:
	add.w   $2a(a0), d1
	move.w  d1, oX(a0)
	tst.b   $2e(a0)
	beq.s   P2A_loc_20DFCC
	subq.b  #$1, $2e(a0)
	bra.s   P2A_loc_20DFD4
P2A_loc_20DFCC:
	btst.b  #$1, $22(a6)
	bne.s   P2A_loc_20E02C
P2A_loc_20DFD4:
	move.b  oWidth(a0), d1
	ext.w   d1
	move.w  $8(a6), d0
	sub.w   oX(a0), d0
	add.w   d1, d0
	bmi.s   P2A_loc_20E02C
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P2A_loc_20E02C
	move.b  oYRadius(a0), d1
	ext.w   d1
	move.w  $c(a6), d0
	sub.w   oY(a0), d0
	add.w   d1, d0
	bmi.s   P2A_loc_20E02C
	add.w   d1, d1
	cmp.w   d1, d0
	bcc.s   P2A_loc_20E02C
	cmpi.b  #$2b, $1c(a6)
	beq.s   P2A_loc_20E02C
	tst.b   $2e(a0)
	bne.s   P2A_loc_20E018
	move.b  #$3c, $2e(a0)
P2A_loc_20E018:
	tst.w   $12(a6)
	bpl.s   P2A_loc_20E026
	move.w  #$f400, $12(a6)
	rts     
P2A_loc_20E026:
	move.w  #$c00, $12(a6)
P2A_loc_20E02C:
	rts     
