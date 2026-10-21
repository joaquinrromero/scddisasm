; Object $49 - Obj49_20F7F6 (from R42C, old ID $49)
P49_Obj49_20F7F6:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  P49_dat_20F804(pc, d0.w), d0
	jmp     P49_dat_20F804(pc, d0.w)
P49_dat_20F804:
	dc.w	P49_loc_20F810-P49_dat_20F804
	dc.w	P49_loc_20F848-P49_dat_20F804
	dc.w	P49_loc_20F864-P49_dat_20F804
	dc.w	P49_loc_20F87C-P49_dat_20F804
	dc.w	P49_loc_20F8FE-P49_dat_20F804
	dc.w	P49_loc_20F914-P49_dat_20F804
P49_loc_20F810:
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$20, oXRadius(a0)
	move.b  #$20, oWidth(a0)
	move.w  #$4310, oTile(a0)
	move.l  #$20f958, oMap(a0)
	move.w  oY(a0), $2a(a0)
	move.b  #$21, oYRadius(a0)
	rts     
P49_loc_20F848:
	move.w  $FFFFD00C.w, d0
	subi.w  #$e0, d0
	cmp.w   $2a(a0), d0
	ble.s   P49_loc_20F85E
	addq.b  #$2, oRoutine(a0)
	move.w  d0, oY(a0)
P49_loc_20F85E:
	jmp     CheckObjDespawn.l
P49_loc_20F864:
	addq.b  #$2, oRoutine(a0)
	move.b  #$21, oYRadius(a0)
	bclr.b  #$0, oMapFrame(a0)
	clr.l   $2c(a0)
	clr.w   oYVel(a0)
P49_loc_20F87C:
	move.l  $2c(a0), d0
	add.l   d0, oY(a0)
	addi.l  #$400, $2c(a0)
	cmpi.l  #$10000, $2c(a0)
	ble.s   P49_loc_20F89E
	move.l  #$10000, $2c(a0)
P49_loc_20F89E:
	tst.b   oSprFlags(a0)
	bmi.s   P49_loc_20F8BE
	move.w  oY(a0), d0
	sub.w   $FFFFD00C.w, d0
	bpl.s   P49_loc_20F8B0
	neg.w   d0
P49_loc_20F8B0:
	cmpi.w  #$e0, d0
	ble.s   P49_loc_20F8BE
	move.b  #$2, oRoutine(a0)
	bra.s   P49_loc_20F8F2
P49_loc_20F8BE:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	beq.s   P49_loc_20F8F2
	move.b  #$8, oRoutine(a0)
	lea     objects.w, a1
	jsr     GetOffObject.l
	move.b  #$1f, oYRadius(a0)
	addq.w  #$2, oY(a0)
	addq.w  #$4, $c(a1)
	move.w  #$bf, d0
	jsr     PlayFMSound.l
P49_loc_20F8F2:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P49_loc_20F8FE:
	addq.b  #$2, oRoutine(a0)
	bset.b  #$0, oMapFrame(a0)
	move.b  #$1f, oYRadius(a0)
	move.w  #$fe00, oYVel(a0)
P49_loc_20F914:
	move.w  oY(a0), d0
	cmp.w   $2a(a0), d0
	bgt.s   P49_loc_20F926
	move.b  #$2, oRoutine(a0)
	bra.s   P49_loc_20F944
P49_loc_20F926:
	lea     objects.w, a1
	jsr     TopSolidObject.l
	bne.s   P49_loc_20F944
	move.b  #$4, oRoutine(a0)
	lea     objects.w, a1
	subq.w  #$2, oY(a0)
	subq.w  #$4, $c(a1)
P49_loc_20F944:
	jsr     DrawObject.l
	subi.l  #$20000, oY(a0)
	jmp     CheckObjDespawn.l
P49_loc_20F958:
	dc.w	$0004,$002D,$08E0,$0D00,$00E0,$E00D,$0800,$00F0
	dc.w	$0F00,$08E0,$F00F,$0808,$0010,$0510,$70E0,$1005
	dc.w	$1870,$F010,$0510,$7000,$1005,$1870,$1008,$DE0D
	dc.w	$0018,$E0DE,$0D08,$1800,$EE0F,$0008,$E0EE,$0F08
	dc.w	$0800,$0E05,$1074,$E00E,$0518,$74F0,$0E05,$1074
	dc.w	$000E,$0518,$7410
