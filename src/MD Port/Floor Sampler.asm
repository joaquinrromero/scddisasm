; -------------------------------------------------------------------------
; Sonic CD Disassembly - Mega Drive port
; -------------------------------------------------------------------------
; Banded floor sampler: reads the GenGfxTraceTblMD output and renders the 256x96
; 4bpp floor image band by band into stageImage (Work RAM).
; -------------------------------------------------------------------------
; Why bands: the whole image is $3000 bytes and does not fit in RAM next to
; everything else (see "RAM Map.inc"). The image is split into FLOORBANDS
; bands of 32/FLOORBANDS tile columns; a band is contiguous in the image
; (columns are $180 bytes), so it is a single DMA to VRAM.
;
; Scheduling: the main loop spends most of its time in VSync waiting for the
; next V-BLANK. VSync calls SampleFloorSlice in that wait loop, which renders
; FLOORSLICEROWS sample rows and returns, so the floor is drawn in the idle time
; and the game logic keeps its own 3-V-BLANK rhythm. There are FLOORBUFS band
; buffers in RAM: the sampler fills one while the other waits for its DMA.
; The V-INT (Main.asm: CopyFloorBand) copies every finished band into the
; HIDDEN VRAM image buffer, and once the last band of a picture is in, the two
; VRAM buffers swap (ShowFloorBuf). The trace table is generated once at the
; start of each picture, so all its bands share the same camera.
;
; Resolution (RAM Map.inc: FLOORHDIV): each sample covers FLOORHDIV dots
; horizontally and 2 rows vertically. FLOORHDIV=4 is h4v2: 64 x 48 = 3072
; samples per picture; 2 is h2v2.
;
; stageImage layout (one band): COLUMN-MAJOR tiles, FLOORBANDCOLS columns of
; 12 tiles ($180 bytes per column), each tile 8 rows x 4 bytes, 4bpp, high
; nibble = left pixel:
;   Tile[col][row] byte offset = col*$180 + row*32
;
; Sample (band-local sample j in 0..FLOORSPR-1, sample row sy in 0..47):
;   tile_col      = j / FLOORSPT          tile_row = sy>>2
;   byte in tile  = (sy&3)*8 + (j%FLOORSPT)*(FLOORHDIV/2)   (second pixel row +4)
;   h4: a word  (color*$1111) per pixel row;  h2: a byte (color*$11)
;
; Trace table (TRACETBLMD, 96 rows * 8 bytes): Xs Ys Dx Dy, signed words.
;   Xs/Ys are in 1/8 px, Dx/Dy is the step per dot in 1/2048 px. Rows 0-2 are
;   blank. Sample row sy reads trace row 2*sy+1 (rows 1,3,5..95).
;   Position of global sample n of a row, in 1/2048 px:
;       X = (Xs<<8) + n*FLOORHDIV*Dx        (same for Y)
;   n = band*FLOORSPR + j. The map is not repeated: outside 0..4095 px the
;   sample is transparent.
;
; stamp_remap.bin (floorRemapPtr): 128x128 big-endian words, row-major,
;   word[(Y>>5)*128 + (X>>5)] = variant index
; stamps_4bpp.bin (floorStampPtr): variants x 512 bytes, 32x32 4bpp row-major,
;   high nibble = left pixel. Variant 0 = transparent.
; -------------------------------------------------------------------------
; Register map for the inner loop:
;   d0.l  X (1/2048 px)            a0  floorRemapPtr (stamp_remap)
;   d1.l  Y                        a1  band write ptr, pixel row 0 of the tile row
;   d2.l  X step per sample        a2  band write ptr, pixel row 1 (a1 + 4)
;   d3.l  Y step per sample        a3  floorStampPtr (stamps_4bpp)
;   d4.w  tile columns left        a4  FloorColorWords (h4 only)
;   d5/d6 scratch                  a5  trace table read ptr
;   d7.w  remap offset of the      a6  base of the stamp variant in ROM
;         stamp a6 points to
; Stack: 0(sp).w = sample row sy, 2(sp).w = FLOORHDIV*FLOORSPR*band,
;        4(sp).w = rows left in this slice, 6(sp).w = byte offset of the RAM band buffer
;
; Speed-ups over the straightforward version (the output is bit-identical):
;  - the bounds test reuses the swapped words that the remap index needs;
;  - consecutive samples usually fall in the same 32x32 stamp (~93%), so the
;    variant base (a6) is only recomputed when the remap offset changes;
;  - one iteration handles a whole tile column (FLOORSPT samples), so there is
;    no per-sample column test.
; NOTE: "adda.l d5,a6" adds a longword whose top byte holds leftovers from the
; swapped words. That is harmless because the 68000 ignores address bits 24-31.
; -------------------------------------------------------------------------

; One sample: look up the texel at (d0,d1), write it, advance (d0,d1)
SAMPLEPX macro
	move.l	d1,d5
	swap	d5					; d5.w = Y>>5 (stamp row); >= 128 means outside the map
	cmpi.w	#128,d5					; (negative values show up as >= $8000)
	bcc.s	.Blank\@
	move.l	d0,d6
	swap	d6					; d6.w = X>>5 (stamp col)
	cmpi.w	#128,d6
	bcc.s	.Blank\@

	; stamp_remap is ROW-MAJOR like the original stamp map: word[(Y>>5)*128 + (X>>5)]
	lsl.w	#7,d5
	add.w	d6,d5
	add.w	d5,d5					; byte offset (<= 32766)
	cmp.w	d7,d5					; Same stamp as the previous sample?
	beq.s	.SameStamp\@
	move.w	d5,d7
	move.w	(a0,d5.w),d5				; d5 = variant index
	lsl.l	#8,d5
	add.l	d5,d5					; variant * 512
	movea.l	a3,a6
	adda.l	d5,a6					; a6 = variant base

.SameStamp\@:
	; byte_in_variant = v*16 + (u>>1),  u = (X>>11)&31,  v = (Y>>11)&31
	move.w	d1,d5
	lsr.w	#7,d5
	andi.w	#$01F0,d5				; v*16
	move.w	d0,d6
	rol.w	#4,d6
	andi.w	#$000F,d6				; u>>1
	add.w	d6,d5
	move.b	(a6,d5.w),d6				; two-pixel byte

	btst	#11,d0					; u parity
	bne.s	.OddU\@
	lsr.b	#4,d6					; even u -> high nibble
	bra.s	.GotColor\@
.OddU\@:
	andi.b	#$0F,d6					; odd u -> low nibble
.GotColor\@:
	if FLOORHDIV=4
	add.w	d6,d6					; (d6 is 0..15 with the upper bits clear)
	move.w	(a4,d6.w),d5				; color * $1111
	else
	move.b	d6,d5
	lsl.b	#4,d5
	or.b	d6,d5					; (color<<4)|color
	endif
	bra.s	.Write\@

.Blank\@:
	moveq	#0,d5

.Write\@:
	if FLOORHDIV=4
	move.w	d5,(a1)+				; pixel row 0: 4 dots
	move.w	d5,(a2)+				; pixel row 1
	else
	move.b	d5,(a1)+
	move.b	d5,(a2)+
	endif
	add.l	d2,d0
	add.l	d3,d1
	endm

; -------------------------------------------------------------------------
; SampleFloorSlice - render a few sample rows of the floor
; -------------------------------------------------------------------------
; Called from the VSync wait loop, so it keeps every register intact.
; -------------------------------------------------------------------------

SampleFloorSlice:
	movem.l	d0-d7/a0-a6,-(sp)
	moveq	#FLOORSLICEROWS,d6
	bsr.s	FloorWork
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; -------------------------------------------------------------------------
; SampleFloorBand - render the rest of the current band (tests and tools)
; -------------------------------------------------------------------------

SampleFloorBand:
	moveq	#48,d6					; (enough rows to finish any band)

; -------------------------------------------------------------------------
; FloorWork - render up to d6.w sample rows of the current band
; -------------------------------------------------------------------------
; Moves on to the next band (and buffer) when a band is finished. Does
; nothing while there is no floor data or the buffer it needs is still
; waiting for its DMA. Trashes all registers.
; -------------------------------------------------------------------------

FloorWork:
	tst.l	floorStampPtr.w				; No floor data for this stage?
	beq.w	.Exit
	tst.l	floorRemapPtr.w
	beq.w	.Exit
	moveq	#0,d0
	move.b	floorFill.w,d0				; RAM band buffer we render into
	lea	floorReady.w,a0
	tst.b	(a0,d0.w)				; Still waiting for its DMA?
	bne.w	.Exit

	tst.b	floorRow.w				; Starting a new picture?
	bne.s	.HaveTable
	tst.b	floorBand.w
	bne.s	.HaveTable
	move.w	d6,-(sp)
	jsr	GenGfxTraceTblMD			; Yes: snapshot the camera into the trace table
	move.w	(sp)+,d6

.HaveTable:
	movea.l	floorStampPtr.w,a3
	movea.l	floorRemapPtr.w,a0
	if FLOORHDIV=4
	lea	FloorColorWords(pc),a4
	endif

	moveq	#0,d0					; Offset of the RAM band buffer we render into
	move.b	floorFill.w,d0
	mulu.w	#FLOORBANDLEN,d0
	move.w	d0,-(sp)				; 6(sp)
	move.w	d6,-(sp)				; 4(sp) rows left in this slice
	moveq	#0,d0					; Samples to skip to reach this band's first one
	move.b	floorBand.w,d0
	mulu.w	#FLOORHDIV*FLOORSPR,d0			; (FLOORHDIV * FLOORSPR * band), used as Dx/Dy multiplier
	move.w	d0,-(sp)				; 2(sp)
	moveq	#0,d0
	move.b	floorRow.w,d0
	move.w	d0,-(sp)				; 0(sp) = sy

.RowLoop:
	move.w	(sp),d5					; Trace row 2*sy+1 (rows 1,3,5..95)
	lsl.w	#4,d5
	lea	TRACETBLMD+8,a5
	adda.w	d5,a5
	move.w	(a5)+,d0				; Xs  (1/8 px)
	move.w	(a5)+,d1				; Ys  (1/8 px)
	move.w	(a5)+,d2				; Dx  (step per dot, 1/2048 px)
	move.w	(a5)+,d3				; Dy
	ext.l	d0
	ext.l	d1
	lsl.l	#8,d0					; accumulators in 1/2048 px (like the gate array)
	lsl.l	#8,d1

	move.w	2(sp),d6				; Move to this band's first sample: + Dx/Dy * (FLOORHDIV*FLOORSPR*band)
	beq.s	.NoBandOfs
	move.w	d2,d5
	muls.w	d6,d5
	add.l	d5,d0
	move.w	d3,d5
	muls.w	d6,d5
	add.l	d5,d1

.NoBandOfs:
	ext.l	d2
	ext.l	d3
	if FLOORHDIV=4
	lsl.l	#2,d2					; step per sample = 4 dots * Dx
	lsl.l	#2,d3
	else
	add.l	d2,d2					; step per sample = 2 dots * Dx
	add.l	d3,d3
	endif

	; row_byte_off = (sy>>2)*32 + (sy&3)*8
	move.w	(sp),d5					; d5 = sy
	move.w	d5,d6
	lsr.w	#2,d5
	lsl.w	#5,d5					; (sy>>2)*32
	andi.w	#3,d6
	lsl.w	#3,d6					; (sy&3)*8
	add.w	d6,d5					; d5 = row_byte_off
	add.w	6(sp),d5				; + RAM band buffer offset

	lea	stageImage.w,a1
	adda.w	d5,a1
	movea.l	a1,a2
	addq.l	#4,a2					; a2 = pixel row 1 (row 0 + 4)

	moveq	#-1,d7					; No stamp selected yet in this row
	moveq	#FLOORBANDCOLS-1,d4

.ColLoop:
	rept	FLOORSPT				; The samples of one tile column
	SAMPLEPX
	endr
	adda.w	#380,a1					; next tile column ($180 - 4)
	adda.w	#380,a2
	dbf	d4,.ColLoop

	addq.w	#1,(sp)					; next sample row
	cmpi.w	#48,(sp)
	bcc.s	.BandDone
	subq.w	#1,4(sp)				; rows left in this slice
	bne.w	.RowLoop

	move.w	(sp),d0					; Slice over: remember where to continue
	move.b	d0,floorRow.w
	addq.l	#8,sp
	rts

.BandDone:
	addq.l	#8,sp					; free the loop variables
	clr.b	floorRow.w

	moveq	#0,d0					; Hand the finished band to the V-INT
	move.b	floorBand.w,d0
	addq.b	#1,d0					; (band+1)
	moveq	#0,d1
	move.b	floorFill.w,d1
	lea	floorReady.w,a0
	move.b	d0,(a0,d1.w)
	eori.b	#1,floorFill.w				; The other buffer takes the next band

	cmpi.b	#FLOORBANDS,d0				; Next band; after the last one a new picture starts
	bcs.s	.SaveBand
	moveq	#0,d0
.SaveBand:
	move.b	d0,floorBand.w

.Exit:
	rts

; -------------------------------------------------------------------------
; Color word table: nibble -> nibble*$1111 (four dots of the same color)
; -------------------------------------------------------------------------

	if FLOORHDIV=4
FloorColorWords:
	dc.w	$0000,$1111,$2222,$3333,$4444,$5555,$6666,$7777
	dc.w	$8888,$9999,$AAAA,$BBBB,$CCCC,$DDDD,$EEEE,$FFFF
	endif

; -------------------------------------------------------------------------
; ShowFloorBuf  -  V-INT: show the VRAM image buffer that is complete
; -------------------------------------------------------------------------

ShowFloorBuf:
	tst.b	floorShowSel.w
	bne.s	.Buffer2
	jmp	ShowStageBuf1				; Buffer 1 (VRAM IMGVRAM)

.Buffer2:
	jmp	ShowStageBuf2				; Buffer 2 (VRAM IMGVRAM+IMGLENGTH)

; -------------------------------------------------------------------------
; CopyFloorBand  -  V-INT: DMA the oldest finished band into the hidden VRAM
; image buffer. When it was the last band of the picture, the buffers swap
; (the new picture is shown from the next ShowFloorBuf on).
; -------------------------------------------------------------------------

CopyFloorBand:
	moveq	#0,d4
	move.b	floorDmaSel.w,d4			; RAM band buffer to copy next
	lea	floorReady.w,a0
	moveq	#0,d0
	move.b	(a0,d4.w),d0				; (band+1), 0 = nothing to copy
	beq.w	.End
	clr.b	(a0,d4.w)
	subq.b	#1,d0					; d0 = band
	move.w	d0,d3					; (keep for the swap test)

	mulu.w	#FLOORBANDLEN,d0			; VRAM dest = IMGVRAM + hidden*IMGLENGTH + band*FLOORBANDLEN
	addi.w	#IMGVRAM,d0
	tst.b	floorHidSel.w
	beq.s	.Dest
	addi.w	#IMGLENGTH,d0

.Dest:
	; VDP command words for the destination (d0 = VRAM address)
	move.l	d0,d1
	andi.l	#$3FFF,d1
	swap	d1					; (addr & $3FFF) << 16
	andi.w	#$C000,d0
	rol.w	#2,d0					; (addr & $C000) >> 14
	andi.l	#3,d0
	or.l	d0,d1					; d1 = write command without the VRAM/DMA bits
	move.l	d1,d2
	ori.l	#$40000080,d1				; VRAM DMA command
	ori.l	#$40000000,d2				; VRAM write command

	; Source = stageImage + buffer*FLOORBANDLEN (in Work RAM: DMA source bits 23-17 = $7F)
	move.w	d4,d5
	mulu.w	#FLOORBANDLEN,d5
	lea	stageImage.w,a5
	adda.w	d5,a5
	move.l	a5,d5
	lsr.l	#1,d5					; source address in words

	lea	VDPCTRL,a6
	move.l	#$93009400|(((FLOORBANDLEN/2)&$FF00)>>8)|(((FLOORBANDLEN/2)&$FF)<<16),(a6)
	move.w	d5,d6
	andi.w	#$00FF,d6
	ori.w	#$9500,d6
	move.w	d6,(a6)					; DMA source low
	move.w	d5,d6
	lsr.w	#8,d6
	ori.w	#$9600,d6
	move.w	d6,(a6)					; DMA source mid
	move.w	#$977F,(a6)				; DMA source high ($FF0000 area)
	move.l	d1,-(sp)				; (the last command word is written from RAM)
	move.w	(sp)+,(a6)
	move.w	(sp)+,(a6)				; DMA starts

	move.l	d2,(a6)					; Manually write the first word (same as DMA68K2)
	move.w	(a5),VDPDATA

	eori.b	#1,floorDmaSel.w			; The other RAM buffer holds the next band

	cmpi.b	#FLOORBANDS-1,d3			; Was this the last band of the picture?
	bne.s	.End
	move.b	floorHidSel.w,floorShowSel.w		; The finished buffer becomes the visible one
	eori.b	#1,floorHidSel.w			; and the other one is built next

.End:
	rts

; -------------------------------------------------------------------------
; LoadFloorData  -  point floorStampPtr/floorRemapPtr at this stage's data
; -------------------------------------------------------------------------
; Called at the end of LoadStamps (SSMDPORT mode) after stage ID is set.
; Input:  specStageID.w = stage ID, 0-BASED like the rest of the code (0 = stage 1 ... 7 = stage 8)
; Output: floorStampPtr.w, floorRemapPtr.w (0 if no data for this stage)
;         band/buffer state reset: the first picture starts with band 0 / row 0
;         and is built in VRAM buffer 2 while the (blank) buffer 1 is shown
; Trashes: d0, a0
; -------------------------------------------------------------------------

LoadFloorData:
	clr.b	floorBand.w
	clr.b	floorRow.w
	clr.b	floorFill.w
	clr.b	floorDmaSel.w
	clr.b	floorReady.w
	clr.b	floorReady+1.w
	clr.b	floorShowSel.w				; Show buffer 1 (blank) ...
	move.b	#1,floorHidSel.w			; ... while buffer 2 is built

	moveq	#0,d0
	move.b	specStageID.w,d0
	cmpi.b	#7,d0
	bhi.s	.NoData
	ext.w	d0
	lsl.w	#3,d0					; *8 (each table entry = 2 longwords)
	lea	.PtrTable(pc),a0
	move.l	(a0,d0.w),floorStampPtr.w
	move.l	4(a0,d0.w),floorRemapPtr.w
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
