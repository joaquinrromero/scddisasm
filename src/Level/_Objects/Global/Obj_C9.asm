; Object $C9 - Obj2A_20D1A0 (from R81A, old ID $2A)
Obj2A_20D1A0:
	tst.b   oSubtype(a0)
	bne.w   loc_20D30C
	tst.b   oLayer(a0)
	beq.s   PC9_loc_20D1D4
	movea.w $2a(a0), a1
	dc.b	$0C,$29,$00,$2A,$00,$00		; cmpi.b #$2a, $0(a1) (raw: not reproducible by assembler)
	bne.w   ObjMetalSonicHologram
	move.w  $2e(a0), d0
	cmp.w   $2e(a1), d0
	bne.w   ObjMetalSonicHologram
	move.w  $30(a0), d0
	cmp.w   $30(a1), d0
	bne.w   ObjMetalSonicHologram
PC9_loc_20D1D4:
	moveq   #$0, d0
	move.b  oRoutine(a0), d0
	move.w  ObjProjector_Index(pc, d0.w), d0
	jsr     ObjProjector_Index(pc, d0.w)
	jsr     DrawObject.l
	tst.b   oLayer(a0)
	bmi.s   PC9_loc_20D1F8
	move.w  $2e(a0), d0
	jmp     CheckObjDespawn2.l
PC9_loc_20D1F8:
	rts     
