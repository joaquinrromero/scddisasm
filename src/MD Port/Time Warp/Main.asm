; -------------------------------------------------------------------------
; Sonic CD Disassembly - Mega Drive port
; -------------------------------------------------------------------------
; Time warp cutscene, ported as a regular game mode of the unified ROM
; (from "Time Warp Cutscene/Main.asm"). Entry point: TimeWarpCutscene
; -------------------------------------------------------------------------
; Differences from the Sega CD version:
;  - No MMD header / no separate file: it is plain code in the ROM.
;  - Its RAM variables live in a hole of the level's RAM map ($FFFFB000-
;    $FFFFBFFF) that the level never uses, so nothing of the level is touched.
;  - Controller data lives in RAM instead of a Gate Array comm register.
;  - No Sub CPU (no IRQ2, no commands).
;  - Nemesis/Enigma decompression is shared with the level (identical code).
;  - Everything that clashed with the level's symbols got a TW/tw prefix.
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Object variables structure
; -------------------------------------------------------------------------

twoSize		EQU	$40
	rsreset
twoID		rs.w	1			; ID
twoFlags		rs.b	1			; Flags
twoRoutine	rs.b	1			; Routine
twoTile		rs.w	1			; Base tile ID
twoMap		rs.l	1			; Mappings
twoAnim		rs.b	1			; Animation ID
twoAnimFrame	rs.b	1			; Animation frame
twoAnimTime	rs.b	1			; Animation time
twoAnimTime2	rs.b	1			; Animation time (copy)
twoTimer		rs.w	1			; Timer
twoX		rs.l	1			; X position
twoY		rs.l	1			; Y position
twoXVel		rs.l	1			; X velocity
twoYVel		rs.l	1			; Y velocity

; -------------------------------------------------------------------------
; Variables
; -------------------------------------------------------------------------

	rsset	$FFFFB000
VARSSTART	rs.b	0

twSpritesBuf	rs.b	0
twSprites		rs.b	80*8			; Sprite buffer
		rs.b	$80

sonicObject	rs.b	twoSize			; Sonic object
sonicTrailObj1	rs.b	twoSize			; Sonic trail object 1
sonicTrailObj2	rs.b	twoSize			; Sonic trail object 2
sonicTrailObj3	rs.b	twoSize			; Sonic trail object 3

sparkleObjs	rs.b	0
sparkleObjsF	rs.b	0
sparkleObjF1	rs.b	twoSize			; Front sparkle object 1
sparkleObjF2	rs.b	twoSize			; Front sparkle object 2
sparkleObjF3	rs.b	twoSize			; Front sparkle object 3
SPARKLEOBJFCNT	EQU	(__rs-sparkleObjsF)/twoSize

sparkleObjsB	rs.b	0
sparkleObjB1	rs.b	twoSize			; Back sparkle object 1
sparkleObjB2	rs.b	twoSize			; Back sparkle object 2
sparkleObjB3	rs.b	twoSize			; Back sparkle object 3
sparkleObjB4	rs.b	twoSize			; Back sparkle object 4
sparkleObjB5	rs.b	twoSize			; Back sparkle object 5
sparkleObjB6	rs.b	twoSize			; Back sparkle object 6
sparkleObjB7	rs.b	twoSize			; Back sparkle object 7
sparkleObjB8	rs.b	twoSize			; Back sparkle object 8
sparkleObjB9	rs.b	twoSize			; Back sparkle object 9
sparkleObjB10	rs.b	twoSize			; Back sparkle object 10
sparkleObjB11	rs.b	twoSize			; Back sparkle object 11
sparkleObjB12	rs.b	twoSize			; Back sparkle object 12
sparkleObjB13	rs.b	twoSize			; Back sparkle object 13
sparkleObjB14	rs.b	twoSize			; Back sparkle object 14
sparkleObjB15	rs.b	twoSize			; Back sparkle object 15
sparkleObjB16	rs.b	twoSize			; Back sparkle object 16
sparkleObjB17	rs.b	twoSize			; Back sparkle object 17
sparkleObjB18	rs.b	twoSize			; Back sparkle object 18
sparkleObjB19	rs.b	twoSize			; Back sparkle object 19
sparkleObjB20	rs.b	twoSize			; Back sparkle object 20
sparkleObjB21	rs.b	twoSize			; Back sparkle object 21
sparkleObjB22	rs.b	twoSize			; Back sparkle object 22
sparkleObjB23	rs.b	twoSize			; Back sparkle object 23
sparkleObjB24	rs.b	twoSize			; Back sparkle object 24
sparkleObjB25	rs.b	twoSize			; Back sparkle object 25
SPARKLEOBJBCNT	EQU	(__rs-sparkleObjsB)/twoSize
SPARKLEOBJCNT	EQU	(__rs-sparkleObjs)/twoSize

twPalette		rs.w	$40			; Palette buffer
twFadePalette	rs.w	$40			; Fade twPalette buffer
twSpriteCount	rs.b	1			; Sprite count
fadedOut	rs.b	1			; Faded out flag
timer		rs.w	1			; Timer
vintCounter	rs.w	1			; V-INT counter
twSavedSR		rs.w	1			; Saved status register
curSpriteSlot	rs.l	1			; Current sprite slot
twRngSeed		rs.l	1			; RNG seed
twPalCycleTimer	rs.w	1			; Palette cycle timer (was inside the code in the CD version)
twPalCycleIndex	rs.w	1			; Palette cycle index (must follow the timer)
vscrollBG	rs.w	1			; Background vertical scroll value (was inside the code)
curSonicTrailObj	rs.w	1			; Current Sonic trail object slot (was inside the code)
enableDisplay	rs.b	1			; Enable display flag (was inside the code)
		rs.b	1
ctrlData	rs.w	1			; Controller data
VARSLEN		EQU	__rs-VARSSTART		; Size of variables area

ctrlHold	EQU	ctrlData		; Controller held buttons data
ctrlTap		EQU	ctrlData+1		; Controller tapped buttons data

	if __rs>$FFFFC000				; Must not reach the port's other variables / the level's sonicArtBuf
		fail	"Time warp variables don't fit in the free RAM hole"
	endif

; -------------------------------------------------------------------------
; Program start
; -------------------------------------------------------------------------

TimeWarpCutscene:
	move.l	#TWVInterrupt,_LEVEL6+2.w		; Set V-INT address
	
	lea	VARSSTART.w,a0			; Clear variables
	move.w	#VARSLEN/4-1,d7

.ClearVars:
	move.l	#0,(a0)+
	dbf	d7,.ClearVars
	
	move	#$2500,sr				; Enable interrupts (the Sega CD IPX called us with them on; InitMD
							; keeps them off while it clears VRAM and restores them afterwards)
	lea	VDPRegs(pc),a0			; Initialize Mega Drive hardware
	bsr.w	InitMD
	move.w	#-1,twPalCycleTimer.w		; Palette cycle timer starts at -1
	
	move.l	#$74000003,VDPCTRL		; Reset horizontal scroll data
	move.l	#0,VDPDATA
	
	move.l	#$40000000,VDPCTRL		; Load time warp art
	lea	Art_TimeWarp(pc),a0
	jsr	NemDec
	
	lea	Map_TimeWarpBg(pc),a1		; Load background tilemap
	move.l	#$60000003,d0
	move.w	#$27,d1
	move.w	#$1B,d2
	bsr.w	DrawTilemapH64
	lea	Map_TimeWarpBg(pc),a1
	move.l	#$6E000003,d0
	move.w	#$27,d1
	move.w	#3,d2
	bsr.w	DrawTilemapH64
	
	lea	Pal_TimeWarp(pc),a0		; Load twPalette
	lea	twPalette.w,a1
	moveq	#(Pal_TimeWarp_End-Pal_TimeWarp)/4-1,d7

.LoadPal:
	move.l	(a0)+,(a1)+
	dbf	d7,.LoadPal
	
	move.w	#90,timer.w			; Wait 90 frames (PCM music takes a while to fade out)

.Delay:
	tst.w	timer.w
	bne.s	.Delay
	
	move.w	#240,timer.w			; Set timer
	move.b	#1,enableDisplay		; Set to enable display
	
	bsr.w	TWStopZ80				; Play sound
	move.b	#FM_D8,FMDrvQueue2
	bsr.w	TWStartZ80
	
	bsr.w	PrepFadeFromWhite		; Prepare fade from white
	bsr.w	TWVSync				; TWVSync
	
	bset	#6,ipxVDPReg1+1			; Enable display
	move.w	ipxVDPReg1,VDPCTRL
	
	bsr.w	TWFadeFromWhite			; Fade from white

; -------------------------------------------------------------------------

MainLoop:
	bsr.w	TWPaletteCycle			; Cycle twPalette
	bsr.w	TWRunObjects			; Run objects
	bsr.w	TWVSync				; TWVSync
	
	btst	#7,ctrlTap			; Has the start button been pressed?
	bne.s	.Exit				; If so, branch
	tst.w	timer.w				; Has the timer run out, branch?
	bne.s	MainLoop			; If not, loop

.Exit:	
	bsr.w	TWFadeToWhite			; Fade to white
	
	move	#$2700,sr			; Give the V-INT back to the level
	move.l	#JmpTo_VInt,_LEVEL6+2.w
	rts
	
; -------------------------------------------------------------------------
; Run twPalette cycle
; -------------------------------------------------------------------------

TWPaletteCycle:
	lea	twPalCycleTimer.w,a1		; Increment timer
	addq.w	#1,(a1)
	btst	#0,1(a1)			; Is this an even frame?
	bne.s	.End				; If not, branch
	
	move.w	twPalCycleIndex-twPalCycleTimer(a1),d0		; Get and increment cycle index
	addq.w	#1,twPalCycleIndex-twPalCycleTimer(a1)
	cmpi.w	#$E,twPalCycleIndex-twPalCycleTimer(a1)
	bcs.s	.SetColors
	move.w	#0,twPalCycleIndex-twPalCycleTimer(a1)

.SetColors:
	add.w	d0,d0				; Get cycle data
	lea	.Cycle(pc,d0.w),a1
	
	lea	twPalette+($11*2).w,a2		; Write colors
	rept	14/2
		move.l	(a1)+,(a2)+
	endr
	
	bset	#1,ipxVSync			; Update CRAM

.End:
	rts

; -------------------------------------------------------------------------

.Cycle:
	dc.w	$0E0, $2E2, $4E4, $6E6, $8E8, $AEA, $CEC
	dc.w	$EEE, $CEC, $AEA, $8E8, $6E6, $4E4, $2E2
	dc.w	$0E0, $2E2, $4E4, $6E6, $8E8, $AEA, $CEC
	dc.w	$EEE, $CEC, $AEA, $8E8, $6E6, $4E4, $2E2

; -------------------------------------------------------------------------
; V-BLANK interrupt
; -------------------------------------------------------------------------

TWVInterrupt:
	movem.l	d0-a6,-(sp)			; Save registers
	
	bclr	#0,ipxVSync			; Clear TWVSync flag
	beq.w	.NoUpdates			; If it wasn't set, branch
	
	bsr.w	TWStopZ80				; Stop the Z80
	move.w	VDPCTRL,d0			; Reset V-BLANK flag
	
	bclr	#0,enableDisplay		; Clear display enable flag
	beq.s	.UpdateCRAM			; If it wasn't set, branch
	bset	#6,ipxVDPReg1+1			; Enable display
	move.w	ipxVDPReg1,VDPCTRL

.UpdateCRAM:
	bclr	#1,ipxVSync			; Clear CRAM update flag
	beq.s	.UpdateVSRAM			; If it wasn't set, branch
	DMA68K	twPalette,$0000,$80,CRAM		; Copy twPalette data

.UpdateVSRAM:
	VDPCMD	move.l,2,VSRAM,WRITE,VDPCTRL	; Update VSRAM
	move.w	vscrollBG,VDPDATA
	subq.w	#4,vscrollBG			; Scroll up
	
	DMA68K	twSprites,$F000,$280,VRAM		; Copy sprite data

	jsr	TWReadController(pc)		; Read controller
	bsr.w	TWStartZ80			; Start the Z80

.NoUpdates:
	tst.w	timer.w				; Is the timer running?
	beq.s	.NoTimer			; If not, branch
	subq.w	#1,timer.w			; Decrement timer

.NoTimer:
	addq.w	#1,vintCounter.w		; Increment counter
	
	movem.l	(sp)+,d0-a6			; Restore registers
	rte

; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Run objects
; -------------------------------------------------------------------------

TWRunObjects:
	move.w	vintCounter.w,d0		; Only spawn a new trailing Sonic sprite every 4 frames
	andi.w	#3,d0
	bne.s	.SpawnSparkle
	
	move.w	curSonicTrailObj,d0		; Spawn a new trailing Sonic sprite
	addq.w	#1,curSonicTrailObj
	andi.w	#3,curSonicTrailObj
	mulu.w	#twoSize,d0
	lea	sonicObject.w,a0
	move.w	#1,(a0,d0.w)

.SpawnSparkle:
	move.w	vintCounter.w,d0		; Only spawn a new sparkle every 4 frames
	andi.w	#3,d0
	bne.s	.ResetSprites
	
	bsr.w	FindSparkleObjSlot		; Spawn a new sparkle
	move.w	#2,(a1)

.ResetSprites:
	move.b	#0,twSpriteCount.w		; Reset twSprites
	move.l	#twSprites&$FFFFFF,curSpriteSlot.w
	
	lea	sparkleObjsF.w,a0		; Run sparkle objects in front of Sonic
	moveq	#SPARKLEOBJFCNT-1,d7

.FrontSparkles:
	move.w	d7,-(sp)
	bsr.s	RunSparkleObject
	move.w	(sp)+,d7
	adda.w	#twoSize,a0
	dbf	d7,.FrontSparkles
	
	lea	sonicObject.w,a0		; Run Sonic object
	bsr.w	RunSonicObject
	
	lea	sonicTrailObj1.w,a0		; Run Sonic's trailing sprite objects
	bsr.w	RunSonicTrailObj
	lea	sonicTrailObj2.w,a0
	bsr.w	RunSonicTrailObj
	lea	sonicTrailObj3.w,a0
	bsr.w	RunSonicTrailObj
	
	; BUG: Should be sparkleObjsB. As a result of this, the sparkles
	; in front of Sonic are run and drawn twice, while 3 sparkles meant to
	; appear behind Sonic never show up.
	lea	sparkleObjsF.w,a0		; Run sparkle objects behind Sonic
	moveq	#SPARKLEOBJBCNT-1,d7

.BackSparkles:
	move.w	d7,-(sp)
	bsr.s	RunSparkleObject
	move.w	(sp)+,d7
	adda.w	#twoSize,a0
	dbf	d7,.BackSparkles
	
	movea.l	curSpriteSlot.w,a0		; Mark last sprite slot
	move.l	#0,(a0)

TWRunObjects_End:	
	rts

; -------------------------------------------------------------------------
; Run a sparkle object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointert to object slot
; -------------------------------------------------------------------------

RunSparkleObject:
	move.w	(a0),d0				; Is this object spawned?
	beq.s	TWRunObjects_End			; If not, branch
	
	jsr	ObjSparkle			; Run sparkle object
	btst	#0,twoFlags(a0)			; Is it marked for deletion?
	beq.s	TWDrawObject			; If not, draw it instead
	
	movea.l	a0,a1				; Delete it
	moveq	#0,d1
	moveq	#twoSize/4-1,d2

.Delete:
	move.l	d1,(a1)+
	dbf	d2,.Delete
	if (twoSize&2)<>0
		move.w	d1,(a1)+
	endif
	if (twoSize&1)<>0
		move.b	d1,(a1)+
	endif
	rts
	
; -------------------------------------------------------------------------
; Draw object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

TWDrawObject:
	movea.l	twoMap(a0),a2			; Get animation
	moveq	#0,d0
	move.b	twoAnim(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	movea.l	(a2,d0.w),a2
	
	move.b	(a2)+,d1			; Get number of frames
	move.b	(a2)+,d2			; Get animation speed

	btst	#1,twoFlags(a0)			; Should we animate?
	bne.s	.GetSprite			; If not, branch

	subq.b	#1,twoAnimTime(a0)		; Decrement animation time
	bpl.s	.GetSprite			; If it hasn't run out, branch
	move.b	d2,twoAnimTime(a0)		; Reset animation time

	addq.b	#1,twoAnimFrame(a0)		; Increment animation frame
	cmp.b	twoAnimFrame(a0),d1		; Has it gone past the last frame?
	bhi.s	.GetSprite			; If not, branch
	move.b	#0,twoAnimFrame(a0)		; Restart animation

.GetSprite:
	btst	#2,twoFlags(a0)			; Should this sprite be drawn?
	bne.s	TWRunObjects_End			; If not, branch
	
	move.w	twoX(a0),d4			; Get sprite position
	move.w	twoY(a0),d3
	
	moveq	#0,d0				; Get sprite data
	move.b	twoAnimFrame(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	movea.l	(a2,d0.w),a3

	moveq	#0,d7				; Get number of sprite pieces
	move.b	(a3)+,d7
	bmi.s	TWRunObjects_End			; If there are none, branch
	
	movea.l	curSpriteSlot.w,a4		; Get current sprite slot
	move.w	twoTile(a0),d5			; Get base tile ID

.DrawPieces:
	cmpi.b	#$50,twSpriteCount.w		; Is the sprite table full?
	bcc.s	.Done				; If so, branch
	
	move.b	(a3)+,d0			; Set Y position
	ext.w	d0
	add.w	d3,d0
	move.w	d0,(a4)+
	
	move.b	(a3)+,(a4)+			; Set size
	addq.b	#1,twSpriteCount.w		; Increment sprite count
	move.b	twSpriteCount.w,(a4)+		; Set link
	
	move.b	(a3)+,d0			; Set tile ID
	lsl.w	#8,d0
	move.b	(a3)+,d0
	add.w	d5,d0
	move.w	d0,(a4)+
	
	move.b	(a3)+,d0			; Get X position
	ext.w	d0
	add.w	d4,d0
	andi.w	#$1FF,d0			; Is it 0?
	bne.s	.SetX				; If not, branch
	addq.w	#1,d0				; If so, force it to not be 0

.SetX:
	move.w	d0,(a4)+			; Set X position
	dbf	d7,.DrawPieces			; Loop until pieces are drawn

.Done:
	move.l	a4,curSpriteSlot.w		; Update current sprite slot
	rts
	
; -------------------------------------------------------------------------
; Find sparkle object slot
; -------------------------------------------------------------------------
; RETURNS:
;	eq/ne - Not found/found
;	a1.l  - Found slot
; -------------------------------------------------------------------------

FindSparkleObjSlot:
	lea	sparkleObjs.w,a1		; Sparkle object slots
	moveq	#SPARKLEOBJCNT-1,d7		; Number of slots

.Find:
	tst.w	(a1)				; Is this slot occupied?
	beq.s	.End				; If not, branch
	adda.w	#twoSize,a1			; Next slot
	dbf	d7,.Find			; Loop until finished

.End:
	rts
	
; -------------------------------------------------------------------------
; Set object animation
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.b - Animation ID
;	a0.l - Pointer to object slot
; -------------------------------------------------------------------------

SetObjAnim:
	move.b	d0,twoAnim(a0)			; Set animation ID
	
	moveq	#0,d0				; Reset animation frame
	move.b	d0,twoAnimFrame(a0)

	movea.l	twoMap(a0),a6			; Get animation
	move.b	twoAnim(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	movea.l	(a6,d0.w),a6

	move.b	(a6)+,d0			; Skip over number of frames
	move.b	(a6),twoAnimTime(a0)		; Get animation speed
	move.b	(a6)+,twoAnimTime2(a0)
	rts

; -------------------------------------------------------------------------
; Run Sonic object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointert to object slot
; -------------------------------------------------------------------------

RunSonicObject:
	tst.w	twoID(a0)				; Is this object spawned?
	beq.s	.End				; If not, branch
	bsr.s	TWObjSonic			; Run object
	bsr.w	TWDrawObject			; Draw object

.End:	
	rts

; -------------------------------------------------------------------------
; Run Sonic trail object
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointert to object slot
; -------------------------------------------------------------------------

RunSonicTrailObj:
	tst.w	twoID(a0)				; Is this object spawned?
	beq.s	.End				; If not, branch
	bsr.s	TWObjSonic			; Run object
	move.l	sonicObject+twoAnim.w,twoAnim(a0)	; Sync animation
	bsr.w	TWDrawObject			; Draw object

.End:	
	rts

; -------------------------------------------------------------------------

	include	"MD Port/Time Warp/Sonic Object.asm"
	include	"MD Port/Time Warp/Sparkle Object.asm"

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

VDPRegs:
	dc.b	%00000100			; No H-INT
	dc.b	%00110100			; V-INT, DMA, mode 5
	dc.b	$C000/$400			; Plane A location
	dc.b	0				; Window location
	dc.b	$E000/$2000			; Plane B location
	dc.b	$F000/$200			; Sprite table location
	dc.b	0				; Reserved
	dc.b	0				; BG color line 0 color 0
	dc.b	0				; Reserved
	dc.b	0				; Reserved
	dc.b	0				; H-INT counter 0
	dc.b	%00000000			; Scroll by screen
	dc.b	%10000001			; H40
	dc.b	$F400/$400			; Horizontal scroll table lcation
	dc.b	0				; Reserved
	dc.b	2				; Auto increment by 2
	dc.b	%00000001			; 64x32 tile plane size
	dc.b	0				; Window horizontal position 0
	dc.b	0				; Window vertical position 0
VDPRegsEnd:
	even
	
Pal_TimeWarp:
	incbin	"Time Warp Cutscene/Data/Palette.bin"
Pal_TimeWarp_End:
	even
	
Art_TimeWarp:
	incbin	"Time Warp Cutscene/Data/Art.nem"
	even
	
Map_TimeWarpBg:
	incbin	"Time Warp Cutscene/Data/Background Mappings.bin"
	even

; -------------------------------------------------------------------------
; Fade to black
; -------------------------------------------------------------------------

TWFadeToBlack:
	move.b	#1,fadedOut.w			; Set faded out flag

	moveq	#8-1,d6				; Red channel
	moveq	#0,d0
	moveq	#1+0,d1

.FadeRed:
	bsr.s	.FadeColorChannel		; Fade channel
	addq.w	#2,d0				; Increase fade intensity
	dbf	d6,.FadeRed			; Loop until channel is faded

	moveq	#8-1,d6				; Green channel
	moveq	#0,d0
	moveq	#1+4,d1

.FadeGreen:
	bsr.s	.FadeColorChannel		; Fade channel
	addq.w	#2,d0				; Increase fade intensity
	dbf	d6,.FadeGreen			; Loop until channel is faded

	moveq	#8-1,d6				; Blue channel
	moveq	#0,d0
	moveq	#1+8,d1

.FadeBlue:
	bsr.s	.FadeColorChannel		; Fade channel
	addq.w	#2,d0				; Increase fade intensity
	dbf	d6,.FadeBlue			; Loop until channel is faded
	rts

; -------------------------------------------------------------------------
; Fade color channel to black
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Fade intensity
;	d1.w - Color bit offset
; -------------------------------------------------------------------------

.FadeColorChannel:
	lea	twPalette.w,a1			; Palette
	moveq	#$40-1,d7			; Fade entire twPalette

.ColorLoop:
	move.w	(a1),d2				; Get color
	rol.w	#1,d2				; Rotate to color channel
	ror.w	d1,d2

	move.w	d2,d3				; Split channel out
	andi.w	#$E,d2
	andi.w	#$EEE0,d3

	sub.w	d0,d2				; Apply fade intensity
	bcc.s	.Combine			; If it hasn't underflowed, branch
	moveq	#0,d2				; Cap color

.Combine:
	or.w	d3,d2				; Combine colors
	ror.w	#1,d2				; Rotate color channel back
	rol.w	d1,d2
	
	move.w	d2,(a1)+			; Update color data
	dbf	d7,.ColorLoop			; Loop until all colors are updated

	bset	#1,ipxVSync			; Update CRAM
	bra.w	TWVSync				; TWVSync

; -------------------------------------------------------------------------
; Prepare fade from black
; -------------------------------------------------------------------------

PrepFadeFromBlack:
	lea	twPalette.w,a1			; Palette
	lea	twFadePalette.w,a2		; Fade twPalette buffer

	moveq	#0,d1				; Black
	moveq	#($40*2)/4-1,d7			; Transfer entire twPalette

.Transfer:
	move.l	(a1),(a2)+			; Transfer to fade buffer
	move.l	d1,(a1)+			; Fill twPalette with black
	dbf	d7,.Transfer			; Loop until entire twPalette is processed

	bset	#1,ipxVSync			; Update CRAM
	rts

; -------------------------------------------------------------------------
; Fade from black
; -------------------------------------------------------------------------

TWFadeFromBlack:
	move.w	#8-1,d6				; Blue channel
	moveq	#0,d0
	moveq	#1+8,d1

.FadeBlue:
	bsr.w	.FadeColorChannel		; Fade channel
	addq.w	#2,d0				; Increase fade intensity
	dbf	d6,.FadeBlue			; Loop until channel is faded

	move.w	#8-1,d6				; Green channel
	moveq	#0,d0
	moveq	#1+4,d1

.FadeGreen:
	bsr.w	.FadeColorChannel		; Fade channel
	addq.w	#2,d0				; Increase fade intensity
	dbf	d6,.FadeGreen			; Loop until channel is faded
	
	move.w	#8-1,d6				; Red channel
	moveq	#0,d0
	moveq	#1+0,d1

.FadeRed:
	bsr.w	.FadeColorChannel		; Fade channel
	addq.w	#2,d0				; Increase fade intensity
	dbf	d6,.FadeRed			; Loop until channel is faded

	move.b	#0,fadedOut.w			; Clear faded out flag
	rts

; -------------------------------------------------------------------------
; Fade color channel from black
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Fade intensity
;	d1.w - Color bit offset
; -------------------------------------------------------------------------

.FadeColorChannel:
	lea	twPalette.w,a1			; Palette
	lea	twFadePalette.w,a2		; Fade twPalette buffer
	moveq	#$40-1,d7			; Fade entire twPalette

.ColorLoop:
	move.w	(a2)+,d2			; Get target color
	move.w	(a1),d3				; Get current color
	rol.w	#1,d2				; Rotate to color channel
	rol.w	#1,d3
	ror.w	d1,d2
	ror.w	d1,d3

	andi.w	#$E,d2				; Use channel from target color
	andi.w	#$EEE0,d3			; Retain other channels from current color

	cmp.w	d0,d2				; Cap channel at fade intensity
	bls.s	.Combine
	move.w	d0,d2

.Combine:
	or.w	d3,d2				; Combine colors
	rol.w	d1,d2				; Rotate color channel back
	ror.w	#1,d2
	
	move.w	d2,(a1)+			; Update color data
	dbf	d7,.ColorLoop			; Loop until all colors are updated

	bset	#1,ipxVSync			; Update CRAM
	bra.w	TWVSync				; TWVSync

; -------------------------------------------------------------------------
; Fade to white
; -------------------------------------------------------------------------

TWFadeToWhite:
	move.b	#1,fadedOut.w			; Set faded out flag

	moveq	#8-1,d6				; Red channel
	moveq	#1+0,d1

.FadeRed:
	bsr.s	.FadeColorChannel		; Fade channel
	dbf	d6,.FadeRed			; Loop until channel is faded

	moveq	#8-1,d6				; Green channel
	moveq	#1+4,d1

.FadeGreen:
	bsr.s	.FadeColorChannel		; Fade channel
	dbf	d6,.FadeGreen			; Loop until channel is faded

	moveq	#8-1,d6				; Blue channel
	moveq	#1+8,d1

.FadeBlue:
	bsr.s	.FadeColorChannel		; Fade channel
	dbf	d6,.FadeBlue			; Loop until channel is faded
	rts

; -------------------------------------------------------------------------
; Fade color channel to white
; -------------------------------------------------------------------------
; PARAMETERS:
;	d1.w - Color bit offset
; -------------------------------------------------------------------------

.FadeColorChannel:
	lea	twPalette.w,a1			; Palette
	moveq	#$40-1,d7			; Fade entire twPalette

.ColorLoop:
	move.w	(a1),d2				; Get color
	rol.w	#1,d2				; Rotate to color channel
	ror.w	d1,d2

	move.w	d2,d3				; Split channel out
	andi.w	#$E,d2
	andi.w	#$EEE0,d3

	addq.w	#2,d2				; Fade towards white
	cmpi.w	#$E,d2				; Cap at white
	bls.s	.Combine
	moveq	#$E,d2

.Combine:
	or.w	d3,d2				; Combine colors
	ror.w	#1,d2				; Rotate color channel back
	rol.w	d1,d2
	
	move.w	d2,(a1)+			; Update color data
	dbf	d7,.ColorLoop			; Loop until all colors are updated

	bset	#1,ipxVSync			; Update CRAM
	bra.w	TWVSync				; TWVSync

; -------------------------------------------------------------------------
; Prepare fade from white
; -------------------------------------------------------------------------

PrepFadeFromWhite:
	lea	twPalette.w,a1			; Palette
	lea	twFadePalette.w,a2		; Fade twPalette buffer

	move.l	#$EEE0EEE,d1			; White
	moveq	#($40*2)/4-1,d7			; Transfer entire twPalette

.Transfer:
	move.l	(a1),(a2)+			; Transfer to fade buffer
	move.l	d1,(a1)+			; Fill twPalette with bwhitelack
	dbf	d7,.Transfer			; Loop until entire twPalette is processed

	bset	#1,ipxVSync			; Update CRAM
	rts

; -------------------------------------------------------------------------
; Fade from white
; -------------------------------------------------------------------------

TWFadeFromWhite:
	moveq	#8-1,d6				; Red channel
	moveq	#$E,d0
	moveq	#1+0,d1

.FadeRed:
	bsr.w	.FadeColorChannel		; Fade channel
	subq.w	#2,d0				; Decrease fade intensity
	dbf	d6,.FadeRed			; Loop until channel is faded

	moveq	#8-1,d6				; Green channel
	moveq	#$E,d0
	moveq	#1+4,d1

.FadeGreen:
	bsr.w	.FadeColorChannel		; Fade channel
	subq.w	#2,d0				; Decrease fade intensity
	dbf	d6,.FadeGreen			; Loop until channel is faded
	
	moveq	#8-1,d6				; Blue channel
	moveq	#$E,d0
	moveq	#1+8,d1

.FadeBlue:
	bsr.w	.FadeColorChannel		; Fade channel
	subq.w	#2,d0				; Decrease fade intensity
	dbf	d6,.FadeBlue			; Loop until channel is faded

	move.b	#0,fadedOut.w			; Clear faded out flag
	rts

; -------------------------------------------------------------------------
; Fade color channel from white
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Fade intensity
;	d1.w - Color bit offset
; -------------------------------------------------------------------------

.FadeColorChannel:
	lea	twPalette.w,a1			; Palette
	lea	twFadePalette.w,a2		; Fade twPalette buffer
	moveq	#$40-1,d7			; Fade entire twPalette

.ColorLoop:
	move.w	(a2)+,d2			; Get target color
	move.w	(a1),d3				; Get current color
	rol.w	#1,d2				; Rotate to color channel
	rol.w	#1,d3
	ror.w	d1,d2
	ror.w	d1,d3

	andi.w	#$E,d2				; Use channel from target color
	andi.w	#$EEE0,d3			; Retain other channels from current color

	cmp.w	d0,d2				; Cap channel at fade intensity
	bcc.s	.Combine
	move.w	d0,d2

.Combine:
	or.w	d3,d2				; Combine colors
	rol.w	d1,d2				; Rotate color channel back
	ror.w	#1,d2
	
	move.w	d2,(a1)+			; Update color data
	dbf	d7,.ColorLoop			; Loop until all colors are updated

	bset	#1,ipxVSync			; Update CRAM
	bra.w	TWVSync				; TWVSync
	
; -------------------------------------------------------------------------
; Draw a tilemap (for 64 tile wide planes)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.w - Width
;	d2.w - Height
;	a0.l - Pointer to tilemap
; -------------------------------------------------------------------------

DrawTilemapH64:
	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port
	move.l	#$800000,d4			; Row delta

.DrawRow:
	move.l	d0,(a2)				; Set VDP command
	move.w	d1,d3				; Get width

.DrawTile:
	move.w	(a1)+,(a3)			; Draw tile
	dbf	d3,.DrawTile			; Loop until row is drawn

	add.l	d4,d0				; Next row
	dbf	d2,.DrawRow			; Loop until map is drawn
	rts

; -------------------------------------------------------------------------
; Draw a tilemap (for 128 tile wide planes)
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.l - VDP command
;	d1.w - Width
;	d2.w - Height
;	a0.l - Pointer to tilemap
; -------------------------------------------------------------------------

DrawTilemapH128:
	lea	VDPCTRL,a2			; VDP control port
	lea	VDPDATA,a3			; VDP data port
	move.l	#$1000000,d4			; Row delta

.DrawRow:
	move.l	d0,(a2)				; Set VDP command
	move.w	d1,d3				; Get width

.DrawTile:
	move.w	(a1)+,(a3)			; Draw tile
	dbf	d3,.DrawTile			; Loop until row is drawn

	add.l	d4,d0				; Next row
	dbf	d2,.DrawRow			; Loop until map is drawn
	rts

; -------------------------------------------------------------------------
; Get a random number
; -------------------------------------------------------------------------
; RETURNS:
;	d0.l - TWRandom number
; -------------------------------------------------------------------------

TWRandom:
	move.l	twRngSeed.w,d1			; Get RNG seed
	bne.s	.GotSeed			; If it's set, branch
	move.l	#$2A6D365A,d1			; Reset RNG seed otherwise

.GotSeed:
	move.l	d1,d0				; Get random number
	asl.l	#2,d1
	add.l	d0,d1
	asl.l	#3,d1
	add.l	d0,d1
	move.w	d1,d0
	swap	d1
	add.w	d1,d0
	move.w	d0,d1
	swap	d1
	move.l	d1,twRngSeed.w			; Update RNG seed
	rts
	
; -------------------------------------------------------------------------
; Initialize the Mega Drive hardware
; -------------------------------------------------------------------------
; PARAMETERS:
;	a0.l - Pointer to VDP register data table
; -------------------------------------------------------------------------

InitMD:
	move.w	#$8000,d0			; Set up VDP registers
	moveq	#VDPRegsEnd-VDPRegs-1,d7

.SetVDPRegs:
	move.b	(a0)+,d0
	move.w	d0,VDPCTRL
	addi.w	#$100,d0
	dbf	d7,.SetVDPRegs
	
	moveq	#$40,d0				; Set up controller ports
	move.b	d0,IOCTRL1
	move.b	d0,IOCTRL2
	move.b	d0,IOCTRL3
	move.b	#$C0,IODATA1
	
	bsr.w	TWStopZ80				; Stop the Z80
	
	VDPCMD	move.l,0,VRAM,WRITE,VDPCTRL	; Clear VRAM
	lea	VDPDATA,a0
	moveq	#0,d0
	move.w	#$FFF,d7

.ClearVRAM:
	move.l	d0,(a0)
	move.l	d0,(a0)
	move.l	d0,(a0)
	move.l	d0,(a0)
	dbf	d7,.ClearVRAM
	
	VDPCMD	move.l,0,VSRAM,WRITE,VDPCTRL	; Clear VSRAM
	move.l	#0,VDPDATA
	
	bsr.w	TWStartZ80			; Start the Z80
	move.w	#$8134,ipxVDPReg1		; Reset IPX VDP register 1 cache
	rts

; -------------------------------------------------------------------------
; Stop the Z80
; -------------------------------------------------------------------------

TWStopZ80:
	move	sr,twSavedSR.w			; Save status register
	move	#$2700,sr			; Disable interrupts
	Z80STOP					; Stop the Z80
	rts

; -------------------------------------------------------------------------
; Start the Z80
; -------------------------------------------------------------------------

TWStartZ80:
	Z80START				; Start the Z80
	move	twSavedSR.w,sr			; Restore status register
	rts

; -------------------------------------------------------------------------
; Read controller data
; -------------------------------------------------------------------------

TWReadController:
	lea	ctrlData,a5			; Controller data buffer
	lea	IODATA1,a6			; Controller port 1
	
	move.b	#0,(a6)				; TH = 0
	tst.w	(a5)				; Delay
	move.b	(a6),d0				; Read start and A buttons
	lsl.b	#2,d0
	andi.b	#$C0,d0
	
	move.b	#$40,(a6)			; TH = 1
	tst.w	(a5)				; Delay
	move.b	(a6),d1				; Read B, C, and D-pad buttons
	andi.b	#$3F,d1
	
	or.b	d1,d0				; Combine button data
	not.b	d0				; Flip bits
	move.b	d0,d1				; Make copy
	
	move.b	(a5),d2				; Mask out tapped button
	eor.b	d2,d0
	move.b	d1,(a5)+			; Store pressed buttons
	and.b	d1,d0				; Store tapped buttons
	move.b	d0,(a5)+
	rts

; -------------------------------------------------------------------------
; TWVSync
; -------------------------------------------------------------------------

TWVSync:
	bset	#0,ipxVSync			; Set TWVSync flag
	move	#$2500,sr			; Enable interrupts

.Wait:
	btst	#0,ipxVSync			; Has the V-INT handler run?
	bne.s	.Wait				; If not, wait
	rts
