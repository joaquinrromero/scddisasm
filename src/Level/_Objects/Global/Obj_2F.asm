; Object $2F - ObjAmyRose (from R11A, old ID $2F)
ObjAmyRose:
	tst.b   timeAttackMode.l
	bne.s   P2F_loc_20E8C6
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjAmyRose_Index(pc, d0.w), d0
	jsr     ObjAmyRose_Index(pc, d0.w)
	bsr.w   ObjAmyRose_MakeHearts
	jsr     DrawObject.l
	jsr     CheckObjDespawn.l
	cmpi.b  #$2f, oID(a0)
	beq.s   P2F_loc_20E8D0
P2F_loc_20E8C6:
	lea     Pal_LevelEnd.l, a3
	bsr.w   ObjAmyRose_ResetPal
P2F_loc_20E8D0:
	rts     
ObjAmyRose_Index:
	dc.w	ObjAmyRose_Init-ObjAmyRose_Index
	dc.w	ObjAmyRose_Main-ObjAmyRose_Index
	dc.w	ObjAmyRose_HoldSonic-ObjAmyRose_Index
	dc.w	ObjAmyRose_FollowSonic-ObjAmyRose_Index
	dc.w	ObjAmyRose_WaitLand-ObjAmyRose_Index
ObjAmyRose_MakeHearts:
	moveq   #$6, d0
	btst.b  #$0, $3e(a0)
	beq.s   P2F_loc_20EE1C
	moveq   #$10, d0
P2F_loc_20EE1C:
	add.b   d0, $3b(a0)
	bcc.s   P2F_loc_20EE5E
	jsr     FindObjSlot.l
	bne.s   P2F_loc_20EE5E
	dc.b	$13,$7C,$00,$30,$00,$00		; move.b #$30, $0(a1) (raw: not reproducible by assembler)
	moveq   #$8, d1
	btst.b  #$0, oFlags(a0)
	beq.s   P2F_loc_20EE3E
	move.w  #$fff6, d1
P2F_loc_20EE3E:
	btst.b  #$0, $3e(a0)
	beq.s   P2F_loc_20EE48
	neg.w   d1
P2F_loc_20EE48:
	move.w  oX(a0), d0
	add.w   d1, d0
	move.w  d0, $8(a1)
	move.w  oY(a0), d0
	subi.w  #$c, d0
	move.w  d0, $c(a1)
P2F_loc_20EE5E:
	rts     
ObjAmyRose_ResetPal:
	lea     $FFFFFB20.w, a4
	movem.l (a3)+, d0-d3
	movem.l d0-d3, (a4)
	movem.l (a3)+, d0-d3
	movem.l d0-d3, $10(a4)
	rts     
ObjAmyRose_Init:
	ori.b   #$4, oSprFlags(a0)
	move.w  #$2370, oTile(a0)
	move.b  #$1, oPriority(a0)
	move.l  #$23fd1c, oMap(a0)
	move.b  #$c, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  oX(a0), $36(a0)
	bsr.w   ObjAmyRose_LoadPal
P2F_loc_20E90C:
	jsr     ObjGetFloorDist.l
	tst.w   d1
	beq.s   P2F_loc_20E91E
	add.w   d1, oY(a0)
	bra.w   P2F_loc_20E90C
P2F_loc_20E91E:
	lea     objects.w, a1
	bsr.w   ObjAmyRose_SetFacing
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	bcc.s   P2F_loc_20E932
	neg.w   d0
P2F_loc_20E932:
	cmpi.w  #$70, d0
	bcc.s   P2F_loc_20E93C
	addq.b  #$2, oRoutine(a0)
P2F_loc_20E93C:
	move.b  #$5, oAnim(a0)
	lea     Ani_AmyRose.l, a1
	bra.w   AnimateObjSimple
ObjAmyRose_Main:
	lea     objects.w, a1
	bsr.w   ObjAmyRose_SetFacing
	btst.b  #$6, $3e(a0)
	bne.w   P2F_loc_20EA2A
	btst.b  #$2, $3e(a0)
	bne.w   P2F_loc_20E98E
	tst.w   $10(a1)
	bne.s   P2F_loc_20E9A6
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	bcc.s   P2F_loc_20E97A
	neg.w   d0
P2F_loc_20E97A:
	cmpi.w  #$a, d0
	bcc.s   P2F_loc_20E9A6
P2F_loc_20E980:
	bset.b  #$2, $3e(a0)
	clr.w   oXVel(a0)
	bra.w   P2F_loc_20EA36
P2F_loc_20E98E:
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	bcc.s   P2F_loc_20E99A
	neg.w   d0
P2F_loc_20E99A:
	cmpi.w  #$20, d0
	bcs.s   P2F_loc_20E980
	bclr.b  #$2, $3e(a0)
P2F_loc_20E9A6:
	move.w  #$fff0, d0
	btst.b  #$0, oFlags(a0)
	bne.s   P2F_loc_20E9B4
	neg.w   d0
P2F_loc_20E9B4:
	add.w   oXVel(a0), d0
	move.w  d0, d1
	move.w  #$200, d2
	tst.w   d1
	bpl.s   P2F_loc_20E9C6
	neg.w   d1
	neg.w   d2
P2F_loc_20E9C6:
	cmpi.w  #$200, d1
	bcs.s   P2F_loc_20E9CE
	move.w  d2, d0
P2F_loc_20E9CE:
	move.w  d0, oXVel(a0)
	tst.w   oXVel(a0)
	bpl.s   P2F_loc_20E9EA
	move.w  $36(a0), d0
	subi.w  #$130, d0
	cmp.w   oX(a0), d0
	bcs.s   P2F_loc_20E9FC
	bra.w   P2F_loc_20EA2A
P2F_loc_20E9EA:
	move.w  $36(a0), d0
	addi.w  #$90, d0
	cmp.w   oX(a0), d0
	bcc.s   P2F_loc_20E9FC
	bra.w   P2F_loc_20EA2A
P2F_loc_20E9FC:
	jsr     ObjGetFloorDist.l
	cmpi.w  #$7, d1
	bpl.s   P2F_loc_20EA2A
	cmpi.w  #$fff9, d1
	bmi.s   P2F_loc_20EA2A
	add.w   d1, oY(a0)
	bsr.w   ObjectMoveX
	bsr.w   ObjAmyRose_CheckGrabSonic
	move.b  #$2, oAnim(a0)
	lea     Ani_AmyRose.l, a1
	bra.w   AnimateObjSimple
P2F_loc_20EA2A:
	clr.w   oXVel(a0)
	btst.b  #$7, $3e(a0)
	bne.s   P2F_loc_20EA50
P2F_loc_20EA36:
	jsr     ObjGetFloorDist.l
	add.w   d1, oY(a0)
	move.b  #$1, oAnim(a0)
	lea     Ani_AmyRose.l, a1
	bra.w   AnimateObjSimple
P2F_loc_20EA50:
	btst.b  #$6, $3e(a0)
	bne.s   P2F_loc_20EA86
	cmpi.b  #$3, $3f(a0)
	bcs.s   P2F_loc_20EA7A
	addq.b  #$4, $3a(a0)
	bcc.s   P2F_loc_20EA6A
	clr.b   $3f(a0)
P2F_loc_20EA6A:
	move.b  #$4, oAnim(a0)
	lea     Ani_AmyRose.l, a1
	bra.w   AnimateObjSimple
P2F_loc_20EA7A:
	move.w  #$fd00, oYVel(a0)
	bset.b  #$6, $3e(a0)
P2F_loc_20EA86:
	bsr.w   ObjectMoveY
	addi.w  #$40, oYVel(a0)
	move.b  #$6, oMapFrame(a0)
	tst.w   oYVel(a0)
	bmi.s   P2F_loc_20EAA2
	move.b  #$4, oMapFrame(a0)
P2F_loc_20EAA2:
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P2F_loc_20EABA
	clr.w   oYVel(a0)
	bclr.b  #$6, $3e(a0)
	addq.b  #$1, $3f(a0)
P2F_loc_20EABA:
	rts     
ObjAmyRose_HoldSonic:
	lea     objects.w, a1
	bset.b  #$0, $2c(a1)
	move.b  #$5, $1c(a1)
	bsr.w   ObjAmyRose_SlowSonic
	bsr.w   ObjAmyRose_SetFacing
	moveq   #$c, d0
	btst.b  #$0, $22(a1)
	bne.s   P2F_loc_20EAE0
	neg.w   d0
P2F_loc_20EAE0:
	add.w   $8(a1), d0
	move.w  d0, oX(a0)
	move.w  $c(a1), oY(a0)
	move.w  p1CtrlData.w, playerCtrl.w
	bsr.w   Player_Jump
	btst.b  #$0, $2c(a1)
	beq.s   P2F_loc_20EB1C
	cmpi.l  #$93200, time.l
	bcc.s   P2F_loc_20EB2A
	move.b  #$3, oAnim(a0)
	lea     Ani_AmyRose.l, a1
	bra.w   AnimateObjSimple
P2F_loc_20EB1C:
	bclr.b  #$0, $3e(a0)
	move.b  #$6, oRoutine(a0)
	rts     
P2F_loc_20EB2A:
	bsr.w   Player_Jump2
	bclr.b  #$0, $3e(a0)
	move.b  #$2, oRoutine(a0)
	rts     
ObjAmyRose_FollowSonic:
	move.b  #$6, oMapFrame(a0)
	move.w  #$80, d0
	btst.b  #$0, oFlags(a0)
	bne.s   P2F_loc_20EB50
	neg.w   d0
P2F_loc_20EB50:
	move.w  d0, oXVel(a0)
	move.w  oX(a0), d0
	sub.w   $36(a0), d0
	bcc.s   P2F_loc_20EB60
	neg.w   d0
P2F_loc_20EB60:
	cmpi.w  #$80, d0
	bcs.s   P2F_loc_20EB6A
	clr.w   oXVel(a0)
P2F_loc_20EB6A:
	move.w  #$fd00, oYVel(a0)
	addq.b  #$2, oRoutine(a0)
ObjAmyRose_WaitLand:
	bsr.w   ObjectMove
	addi.w  #$40, oYVel(a0)
	tst.w   oYVel(a0)
	bmi.s   P2F_loc_20EB8A
	move.b  #$7, oMapFrame(a0)
P2F_loc_20EB8A:
	jsr     ObjGetFloorDist.l
	tst.w   d1
	bpl.s   P2F_loc_20EBAA
	clr.w   oXVel(a0)
	clr.w   oYVel(a0)
	addi.b  #$10, $3a(a0)
	bcc.s   P2F_loc_20EBAA
	move.b  #$2, oRoutine(a0)
P2F_loc_20EBAA:
	rts     
ObjAmyRose_LoadPal:
	lea     Pal_AmyRose(pc), a3
ObjAmyRose_SetFacing:
	bsr.s   ObjAmyRose_XUnflip
	move.w  oX(a0), d0
	sub.w   $8(a1), d0
	bcs.s   P2F_loc_20EE6E
	bsr.s   ObjAmyRose_XFlip
P2F_loc_20EE6E:
	rts     
ObjAmyRose_CheckGrabSonic:
	tst.w   oXVel(a0)
	bpl.s   P2F_loc_20EC84
	move.w  $36(a0), d0
	subi.w  #$130, d0
	cmp.w   oX(a0), d0
	bcs.s   P2F_loc_20EC96
	bra.w   P2F_loc_20ED5A
P2F_loc_20EC84:
	move.w  $36(a0), d0
	addi.w  #$90, d0
	cmp.w   oX(a0), d0
	bcc.s   P2F_loc_20EC96
	bra.w   P2F_loc_20ED5A
P2F_loc_20EC96:
	cmpi.l  #$93200, time.l
	bcc.w   P2F_loc_20ED5A
	lea     objects.w, a1
	tst.b   debugMode.l
	bne.w   P2F_loc_20ED5A
	btst.b  #$0, $22(a1)
	bne.s   P2F_loc_20ECC4
	move.w  $8(a1), d0
	sub.w   oX(a0), d0
	bra.s   P2F_loc_20ECCC
P2F_loc_20ECC4:
	move.w  oX(a0), d0
	sub.w   $8(a1), d0
P2F_loc_20ECCC:
	bcs.w   P2F_loc_20ED5A
	cmpi.w  #$c, d0
	bcs.w   P2F_loc_20ED5A
	cmpi.w  #$18, d0
	bcc.s   P2F_loc_20ED5A
	moveq   #$8, d1
	move.w  $c(a1), d0
	sub.w   oY(a0), d0
	add.w   d1, d0
	bmi.s   P2F_loc_20ED5A
	move.w  d1, d2
	add.w   d2, d2
	cmp.w   d2, d0
	bcc.s   P2F_loc_20ED5A
	move.w  $10(a1), d0
	bpl.s   P2F_loc_20ECFC
	neg.w   d0
P2F_loc_20ECFC:
	btst.b  #$1, $22(a1)
	bne.s   P2F_loc_20ED5C
	btst.b  #$2, $22(a1)
	bne.s   P2F_loc_20ED5C
	tst.b   $30(a1)
	bne.s   P2F_loc_20ED5C
	cmpi.w  #$680, d0
	bcc.s   P2F_loc_20ED5C
	tst.b   shield.l
	bne.s   P2F_loc_20ED5C
	tst.b   timeWarp.l
	bne.s   P2F_loc_20ED5C
	tst.b   invincible.l
	bne.s   P2F_loc_20ED5C
	bclr.b  #$2, $22(a1)
	ori.b   #$81, $3e(a0)
	clr.w   oYVel(a0)
	clr.w   oXVel(a0)
	move.b  #$7, oMapFrame(a0)
	move.b  #$4, oRoutine(a0)
	move.w  #$7c, d0
	jsr     SubCPUCmd.l
P2F_loc_20ED5A:
	rts     
P2F_loc_20ED5C:
	move.b  #$6, oRoutine(a0)
	rts     
	lea     objects.w, a1
	move.w  oX(a0), d0
	sub.w   $8(a1), d0
	bcc.s   P2F_loc_20ED74
	neg.w   d0
P2F_loc_20ED74:
	cmpi.w  #$34, d0
	rts     
	lea     objects.w, a1
	move.w  oX(a0), d0
	sub.w   $8(a1), d0
	bcc.s   P2F_loc_20ED8A
	neg.w   d0
P2F_loc_20ED8A:
	cmpi.w  #$7c, d0
	rts     
ObjAmyRose_SlowSonic:
	tst.w   oXVel(a0)
	beq.s   P2F_loc_20EBE6
	movem.l a0-a1, -(a7)
	exg.l   a0, a1
	bsr.w   ObjectMoveX
	jsr     ObjGetFloorDist.l
	add.w   d1, oY(a0)
	movem.l (a7)+, a0-a1
	tst.w   $10(a1)
	bmi.s   P2F_loc_20EBDA
	subi.w  #$40, $10(a1)
	bpl.s   P2F_loc_20EBE6
	bra.s   P2F_loc_20EBE2
P2F_loc_20EBDA:
	addi.w  #$40, $10(a1)
	bmi.s   P2F_loc_20EBE6
P2F_loc_20EBE2:
	clr.w   $10(a1)
P2F_loc_20EBE6:
	rts     
ObjAmyRose_XUnflip:
	bclr.b  #$0, oFlags(a0)
	bclr.b  #$0, oSprFlags(a0)
	rts     
ObjAmyRose_XFlip:
	bset.b  #$0, oFlags(a0)
	bset.b  #$0, oSprFlags(a0)
	rts     
