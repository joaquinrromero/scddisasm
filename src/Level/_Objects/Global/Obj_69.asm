; Object $69 - Obj37_20EA5A (from R42A, old ID $37)
P69_Obj37_20EA5A:
	tst.b   oRoutine(a0)
	bne.s   P69_loc_20EA96
	addq.b  #$2, oRoutine(a0)
	ori.b   #$4, oSprFlags(a0)
	move.b  #$3, oPriority(a0)
	move.b  #$a9, oColType(a0)
	move.b  #$10, oXRadius(a0)
	move.b  #$10, oWidth(a0)
	move.b  #$10, oYRadius(a0)
	move.w  #$370, oTile(a0)
	move.l  #$20eaa2, oMap(a0)
P69_loc_20EA96:
	jsr     DrawObject.l
	jmp     CheckObjDespawn.l
P69_loc_20EAA2:
	dc.w	$0002,$01F0,$0F00,$00F0
