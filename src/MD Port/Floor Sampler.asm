; -------------------------------------------------------------------------
; Sonic CD Disassembly - Mega Drive port
; -------------------------------------------------------------------------
; h2v2 floor sampler: reads GenGfxTraceTblMD output and writes a rendered
; 256×96 4bpp tile image into stageImage (Work RAM).
;
; Resolution: 128 sample columns × 48 sample rows.
; Each sample expands to a 2×2 pixel block → full 256×96 output.
; Renders every other frame (15fps floor update; display shows last frame).
;
; stageImage layout — COLUMN-MAJOR tiles (DrawStageMap / COPYIMG order):
;   32 columns × 12 rows × 32 bytes = 12 288 bytes
;   Tile[col][row] byte offset = (col*12 + row)*32
;   Tile internal: 8 pixel rows × 4 bytes, 4bpp, high nibble = left pixel
;
; Sample (sx 0..127, sy 0..47) → pixel (px,py) = (sx*2, sy*2):
;   tile_col = sx>>2,  tile_row = sy>>2
;   pix_x_in_tile = (sx&3)*2  (0,2,4,6),  pix_y_in_tile = (sy&3)*2  (0,2,4,6)
;   byte_in_tile  = pix_y_in_tile*4 + (pix_x_in_tile>>1)
;                 = (sy&3)*8 + (sx&3)
;   row0_addr     = stageImage + col*384 + row_byte_off
;   row_byte_off  = (sy>>2)*32 + (sy&3)*8
;   row1_addr     = row0_addr + 4
;   Both bytes    = (color<<4)|color  (2×1 h-doubling)
;
; Trace table (TRACETBLMD, 96 entries × 8 bytes):
;   Entry N: Xs(w) Ys(w) Dx(w) Dy(w) — 11.5 fp, signed
;   Rows 0-2 blanked; h2v2 reads rows 3,5,7,...,95 (every 2nd, skip +8 bytes)
;   Per-sample step = Dx*2, Dy*2
;
; stamp_remap.bin (pointed to by floorRemapPtr):
;   128×128 big-endian words, word[stamp_col*128 + stamp_row] = variant index
;
; stamps_4bpp.bin (pointed to by floorStampPtr):
;   Variant × 512 bytes, 32×32 4bpp row-major, high nibble = left pixel
;   Variant 0 = transparent
;
; -------------------------------------------------------------------------
; Register map for inner loop:
;   d0.l  Xs (current X position, 11.5 fp, sign-extended to 32-bit)
;   d1.l  Ys (current Y position)
;   d2.l  Dx*2 (step per h2 sample column)
;   d3.l  Dy*2
;   d4    inner loop counter  127..0
;   d5.l  scratch
;   d6.l  scratch
;   d7    outer loop counter  47..0
;   a0    floorRemapPtr (ROM base of stamp_remap word table)
;   a1    stageImage write ptr — row0 byte of current sample
;   a2    stageImage write ptr — row1 byte (= a1 + 4)
;   a3    floorStampPtr (ROM base of stamps_4bpp)
;   a4    stageImage base
;   a5    trace table read ptr
;   a6    scratch variant ptr in ROM
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; SampleFloor
; -------------------------------------------------------------------------

SampleFloor:
	eori.b	#1,floorAltFrame.w
	btst	#0,floorAltFrame.w
	bne.w	.Exit

	movea.l	floorStampPtr.w,a3
	beq.w	.Exit
	movea.l	floorRemapPtr.w,a0
	beq.w	.Exit

	lea	stageImage.w,a4
	lea	TRACETBLMD+24,a5		; skip 3 blanked rows (3*8=24 bytes)

	moveq	#48-1,d7

.RowLoop:
	move.w	(a5)+,d0			; Xs
	move.w	(a5)+,d1			; Ys
	move.w	(a5)+,d2			; Dx
	move.w	(a5)+,d3			; Dy
	addq.l	#8,a5				; skip adjacent odd-row entry
	ext.l	d0
	ext.l	d1
	ext.l	d2
	ext.l	d3
	add.l	d2,d2				; Dx *= 2  (h2)
	add.l	d3,d3				; Dy *= 2

	; row_byte_off = (sy>>2)*32 + (sy&3)*8,  sy = 47-d7
	moveq	#47,d5
	sub.w	d7,d5				; d5 = sy
	move.w	d5,d6
	lsr.w	#2,d5
	lsl.w	#5,d5				; (sy>>2)*32
	andi.w	#3,d6
	lsl.w	#3,d6				; (sy&3)*8
	add.w	d6,d5				; d5 = row_byte_off

	movea.l	a4,a1
	adda.w	d5,a1
	movea.l	a1,a2
	addq.l	#4,a2				; a2 = row1 ptr (row0 + 4)

	moveq	#128-1,d4

.ColLoop:
	; -----------------------------------------------------------------------
	; Compute stamp_remap word address
	;   pixel_X = (Xs>>5) & $FFF,  pixel_Y = (Ys>>5) & $FFF
	;   word_index = (pixel_X>>5)*128 + (pixel_Y>>5)
	;   byte_offset = word_index*2
	; -----------------------------------------------------------------------
	move.l	d0,d5
	asr.l	#5,d5
	andi.l	#$0FFF,d5			; pixel_X

	move.l	d1,d6
	asr.l	#5,d6
	andi.l	#$0FFF,d6			; pixel_Y

	lsr.l	#5,d5				; stamp_col
	lsr.l	#5,d6				; stamp_row
	lsl.l	#7,d5				; *128
	add.l	d6,d5
	add.l	d5,d5				; *2 = byte offset
	move.w	(a0,d5.l),d5			; d5 = variant index

	; -----------------------------------------------------------------------
	; Sample stamp pixel
	;   u = (Xs>>5)&31,  v = (Ys>>5)&31
	;   byte_in_variant = v*16 + (u>>1)
	;   nibble: high if u even (bit5 of Xs = 0), low if u odd (bit5 of Xs = 1)
	; -----------------------------------------------------------------------
	; Save variant (d5) while computing byte_in_variant
	move.w	d5,-(sp)			; save variant index

	; u = (d0>>5)&31
	move.l	d0,d6
	asr.l	#5,d6
	andi.w	#31,d6				; d6 = u

	; v = (d1>>5)&31  (compute into d5 without corrupting d1)
	move.l	d1,d5
	asr.l	#5,d5
	andi.w	#31,d5				; d5 = v

	; byte_in_variant = v*16 + (u>>1)
	lsl.w	#4,d5				; v*16
	lsr.w	#1,d6				; u>>1
	add.w	d6,d5				; d5 = byte_in_variant

	; Fetch pixel byte from stamps_4bpp ROM
	move.w	(sp)+,d6			; d6 = variant index
	lsl.l	#8,d6				; variant * 256
	add.l	d6,d6				; variant * 512
	movea.l	a3,a6
	adda.l	d6,a6				; a6 = variant base
	move.b	(a6,d5.w),d6			; d6 = two-pixel byte

	; Extract nibble (u parity from bit 5 of Xs accumulator d0)
	btst	#5,d0
	bne.s	.OddU
	lsr.b	#4,d6				; even u → high nibble
	bra.s	.GotColor
.OddU:
	andi.b	#$0F,d6				; odd u → low nibble
.GotColor:
	; d6.b = color (0..15)

	; -----------------------------------------------------------------------
	; Write 2×2 block
	; -----------------------------------------------------------------------
	move.b	d6,d5
	lsl.b	#4,d5
	or.b	d6,d5				; d5.b = (color<<4)|color
	move.b	d5,(a1)				; row 0
	move.b	d5,(a2)				; row 1

	; -----------------------------------------------------------------------
	; Advance write pointers
	; -----------------------------------------------------------------------
	; Within a tile column: a1/a2 increment by 1 per sample.
	; After nibble_x=3 (last sample in tile col), jump to next tile column.
	; Tile column stride = IMGHTILE*$20 = 384 bytes.
	; After incrementing by 1, add 383 more to jump column.
	;
	; nibble_x = sx&3 = (127-d4)&3.  When d4&3 == 0, current sx ends a tile col.
	addq.l	#1,a1
	addq.l	#1,a2
	move.w	d4,d5
	andi.w	#3,d5
	bne.s	.NoColJump
	; Last nibble of tile column: jump to next column.
	; We already did +1 (to byte offset 4), need +380 more to reach
	; next col start (384 bytes from this col start, -4 = 380).
	adda.w	#380,a1
	adda.w	#380,a2
.NoColJump:

	add.l	d2,d0				; Xs += Dx*2
	add.l	d3,d1				; Ys += Dy*2
	dbf	d4,.ColLoop

	dbf	d7,.RowLoop

.Exit:
	rts

; -------------------------------------------------------------------------
; LoadFloorData  -  point floorStampPtr/floorRemapPtr at this stage's data
; -------------------------------------------------------------------------
; Called at the end of LoadStamps (SSMDPORT mode) after stage ID is set.
; Input:  specStageID.w = stage number (1-based, 1..8)
; Output: floorStampPtr.w, floorRemapPtr.w (0 if no data for this stage)
;         floorAltFrame.w = 0 (force render on next call)
; Trashes: d0, a0
; -------------------------------------------------------------------------

LoadFloorData:
	move.b	specStageID.w,d0
	beq.s	.NoData
	subq.b	#1,d0				; 0-based index
	cmpi.b	#7,d0
	bhi.s	.NoData
	ext.w	d0
	lsl.w	#3,d0				; *8 (each table entry = 2 longwords)
	lea	.PtrTable(pc),a0
	move.l	(a0,d0.w),floorStampPtr.w
	move.l	4(a0,d0.w),floorRemapPtr.w
	clr.b	floorAltFrame.w
	rts
.NoData:
	clr.l	floorStampPtr.w
	clr.l	floorRemapPtr.w
	rts

; Pairs: (stamps_4bpp ptr, stamp_remap ptr) for stages 1..8
.PtrTable:
	dc.l	FloorStamps_St1, FloorRemap_St1	; Stage 1
	dc.l	FloorStamps_St2, FloorRemap_St2	; Stage 2
	dc.l	0, 0				; Stage 3 (TODO: Stamps 2.kos)
	dc.l	FloorStamps_St4, FloorRemap_St4	; Stage 4
	dc.l	FloorStamps_St5, FloorRemap_St5	; Stage 5
	dc.l	FloorStamps_St6, FloorRemap_St6	; Stage 6
	dc.l	FloorStamps_St7, FloorRemap_St7	; Stage 7
	dc.l	FloorStamps_St8, FloorRemap_St8	; Stage 8
