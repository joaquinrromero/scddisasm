; Object $8A - ObjAnimal (from R61A, old ID $29)
ObjAnimal:
	jsr     CheckAnimalPrescence.l
	move.b  oSubtype(a0), d0
	andi.b  #$7f, d0
	bne.w   ObjGroundAnimal
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjFlyingAnimal_Index(pc, d0.w), d0
	jmp     ObjFlyingAnimal_Index(pc, d0.w)
