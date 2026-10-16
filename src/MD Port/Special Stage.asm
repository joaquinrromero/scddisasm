; -------------------------------------------------------------------------
; Sonic CD Disassembly - Mega Drive port
; -------------------------------------------------------------------------
; Standalone Mega Drive ROM: Special Stage 1 (no floor yet: the Sega CD
; graphics chip has no Mega Drive equivalent)
; -------------------------------------------------------------------------
; Build from the "src" folder (see build_md_ss.sh).
; The special stage Sub CPU logic is assembled in this same file through
; "Special Stage/Sub.asm" with SSMDPORT defined.
; -------------------------------------------------------------------------

SSMDPORT	EQU	1				; Special stage Mega Drive port build flag

; -------------------------------------------------------------------------
; Work RAM map (all of it sign-extended so absolute short addressing works)
;
;   $FF0000-$FF7FFF  Stamp map (32KB, collision data for the floor)
;   $FFFF8000        "Gate array" block (plain RAM now; comm flags/registers)
;   $FFFF8100        Special stage logic variables and objects (ex Sub CPU)
;   $FFFFA600        Sprite buffer / Sonic art buffer handed to the display code
;   $FFFFAC00        Display program variables (ex Main CPU)
;   $FFFFC800        IPX-style global variables
;   $FFFFD900        Writable data that used to sit inside the Main CPU program
;                    image (palette cycle indices, scroll state...): ROM can't
;                    hold it
;   (stack grows down from $FFFFFFFF)
; -------------------------------------------------------------------------

SSPERSIST	EQU	$FFFFFF00			; Survives restarts: magic word + stage ID
TRACETBLMD	EQU	$FFFFE000			; Floor trace table (96 rows * 8 bytes)
SSMAINVARS2	EQU	$FFFFAC00			; Display program variables
SSMAINVARS	EQU	$FFFFC800			; IPX-style global variables
SSRWDATA	EQU	$FFFFD900			; Writable data that lived inside the Main CPU program image

	include	"_Include/Common.inc"
	include	"_Include/Main CPU.inc"			; Hardware definitions and macros
	include	"_Include/Main CPU Variables.inc"
	include	"_Include/Sound.inc"
	include	"Special Stage/_Common.inc"
	include	"Special Stage/_Global Variables.inc"

; -------------------------------------------------------------------------
; Vector table
; -------------------------------------------------------------------------

Vectors:
	dc.l	SSPERSIST&$FFFFFF			; Initial stack pointer (below the persistent block)
	dc.l	EntryPoint				; Reset
	dc.l	ErrorTrap				; Bus error
	dc.l	ErrorTrap				; Address error
	dc.l	ErrorTrap				; Illegal instruction
	dc.l	ErrorTrap				; Division by zero
	dc.l	ErrorTrap				; CHK exception
	dc.l	ErrorTrap				; TRAPV exception
	dc.l	ErrorTrap				; Privilege violation
	dc.l	ErrorTrap				; TRACE exception
	dc.l	ErrorTrap				; Line-A emulator
	dc.l	ErrorTrap				; Line-F emulator
	rept	12					; Reserved
		dc.l	ErrorTrap
	endr
	dc.l	ErrorTrap				; Spurious interrupt
	dc.l	ErrorTrap				; IRQ level 1
	dc.l	ErrorTrap				; IRQ level 2
	dc.l	ErrorTrap				; IRQ level 3
	dc.l	ErrorTrap				; IRQ level 4 (H-INT)
	dc.l	ErrorTrap				; IRQ level 5
	dc.l	VInterrupt				; IRQ level 6 (V-INT)
	dc.l	ErrorTrap				; IRQ level 7
	rept	16					; TRAP #00-#15
		dc.l	ErrorTrap
	endr
	rept	16					; Reserved
		dc.l	ErrorTrap
	endr

; -------------------------------------------------------------------------
; ROM header
; -------------------------------------------------------------------------

	dc.b	"SEGA MEGA DRIVE "			; Hardware ID
	dc.b	"(C)SCDM 2026.OCT"			; Release date
	dc.b	"SONIC CD MD PORT - SPECIAL STAGE "
	dcb.b	$150-*,$20				; Domestic name
	dc.b	"SONIC CD MD PORT - SPECIAL STAGE "
	dcb.b	$180-*,$20				; Overseas name
	dc.b	"GM 00000000-00"			; Serial number
	dc.w	0					; Checksum (fixed by build_md_ss.sh)
	dc.b	"J"					; I/O support (3-button pad)
	dcb.b	$1A0-*,$20
	dc.l	0					; ROM start
	dc.l	ROMEnd-1				; ROM end
	dc.l	$FF0000,$FFFFFF				; RAM start/end
	dcb.b	$1F0-*,$20				; No SRAM, no modem, no notes
	dc.b	"JUE"					; Region
	dcb.b	$200-*,$20

; -------------------------------------------------------------------------
; Error trap
; -------------------------------------------------------------------------

ErrorTrap:
	bra.s	ErrorTrap

; -------------------------------------------------------------------------
; Entry point
; -------------------------------------------------------------------------
; NOTE: nothing before the RAM clear may use the stack (no bsr/jsr).
; -------------------------------------------------------------------------

EntryPoint:
	move	#$2700,sr				; Interrupts off

	move.b	VERSION,d0				; TMSS handshake (only on consoles that have it)
	andi.b	#$0F,d0
	beq.s	.NoTMSS
	move.l	#'SEGA',TMSSSEGA

.NoTMSS:
	move.w	VDPCTRL,d0				; Clear any pending VDP command

	; Z80: stop it, reset it, and park it on a harmless "di / jp 0" loop
	move.w	#$100,Z80BUS
	move.w	#$100,Z80RESET
.WaitZ80:
	btst	#0,Z80BUS
	bne.s	.WaitZ80
	lea	Z80RAM,a0
	move.b	#$F3,(a0)+				; di
	move.b	#$F3,(a0)+				; di
	move.b	#$C3,(a0)+				; jp $0000
	move.b	#0,(a0)+
	move.b	#0,(a0)+
	move.w	#0,Z80RESET				; Z80 reset on
	moveq	#$7F,d0					; Short delay
	dbf	d0,*
	move.w	#0,Z80BUS				; Give the bus back
	move.w	#$100,Z80RESET				; Z80 reset off (it now runs the loop)

	; Silence the PSG
	lea	PSGCTRL,a0
	move.b	#$9F,(a0)
	move.b	#$BF,(a0)
	move.b	#$DF,(a0)
	move.b	#$FF,(a0)

	; Clear all Work RAM
	moveq	#0,d0
	lea	SSPERSIST,a6				; (the top $100 bytes survive restarts)
	move.w	#(WORKRAMS-$100)/4-1,d6
.ClearRAM:
	move.l	d0,-(a6)
	dbf	d6,.ClearRAM

	; VDP registers
	lea	SSVDPRegs(pc),a0
	move.w	#$8000,d0
	moveq	#SSVDPRegsEnd-SSVDPRegs-1,d7
.SetupVDP:
	move.b	(a0)+,d0
	move.w	d0,VDPCTRL
	addi.w	#$100,d0
	dbf	d7,.SetupVDP

	; Controller ports
	moveq	#$40,d0
	move.b	d0,IOCTRL1
	move.b	d0,IOCTRL2
	move.b	d0,IOCTRL3
	move.b	#$C0,IODATA1

	; Clear VRAM, CRAM and VSRAM
	move.l	#$40000000,VDPCTRL
	lea	VDPDATA,a0
	moveq	#0,d0
	move.w	#$10000/16-1,d7
.ClearVRAM:
	rept	16/4
		move.l	d0,(a0)
	endr
	dbf	d7,.ClearVRAM

	move.l	#$C0000000,VDPCTRL
	moveq	#$80/4-1,d7
.ClearCRAM:
	move.l	d0,(a0)
	dbf	d7,.ClearCRAM

	move.l	#$40000010,VDPCTRL
	moveq	#$50/4-1,d7
.ClearVSRAM:
	move.l	d0,(a0)
	dbf	d7,.ClearVSRAM

	movea.l	(Vectors).l,sp				; Reset the stack pointer

	jsr	SSRWInit					; Initial values of the writable data
	cmpi.w	#$5353,SSPERSIST.w			; Did A+Start pick a stage?
	bne.s	.NoPersist
	move.b	SSPERSIST+2.w,d0
	andi.b	#7,d0
	move.b	d0,specStageID.w

.NoPersist:
	bsr.w	Start					; Run the special stage (returns when it is over)
	bra.w	EntryPoint				; Then start again

; -------------------------------------------------------------------------
; A+Start: go to the next special stage (called from the controller read,
; which runs inside the V-INT handler, so never returns)
; -------------------------------------------------------------------------

SSNextStage:
	move	#$2700,sr				; Interrupts off
	moveq	#0,d0
	move.b	specStageID.w,d0			; Next stage ID, wrapping after stage 8
	addq.b	#1,d0
	andi.b	#7,d0
	move.b	d0,SSPERSIST+2.w
	move.w	#$5353,SSPERSIST.w
	jmp	EntryPoint				; Restart with the new stage

; -------------------------------------------------------------------------
; VDP register values for the very first setup (the display program sets
; its own later, with the screen still off)
; -------------------------------------------------------------------------

SSVDPRegs:
	dc.b	%00000100				; No H-INT
	dc.b	%00110100				; V-INT, DMA, mode 5
	dc.b	$C000/$400				; Plane A location
	dc.b	0					; Window location
	dc.b	$E000/$2000				; Plane B location
	dc.b	$D400/$200				; Sprite table location
	dc.b	0					; Reserved
	dc.b	$20					; BG color line 2 color 0
	dc.b	0					; Reserved
	dc.b	0					; Reserved
	dc.b	0					; H-INT counter 0
	dc.b	%00000010				; Scroll by row
	dc.b	%00000000				; H32
	dc.b	$D000/$400				; Horizontal scroll table location
	dc.b	0					; Reserved
	dc.b	2					; Auto increment by 2
	dc.b	%00000001				; 64x32 tile plane size
	dc.b	0					; Window horizontal position
	dc.b	0					; Window vertical position
SSVDPRegsEnd:
	even

; -------------------------------------------------------------------------
; Stage image placeholder
; -------------------------------------------------------------------------
; The original V-INT copies a 12KB rendered image of the floor to VRAM every
; frame. The floor can't be rendered on a Mega Drive yet, so the same DMA
; reads blank tiles from here instead. (16KB aligned so the DMA source never
; crosses a 128KB boundary.)
; -------------------------------------------------------------------------

	ALIGN	$4000
stageImage:
	dcb.b	IMGLENGTH, 0

; -------------------------------------------------------------------------
; Display program (Main CPU program, unchanged apart from the Sub CPU
; handshake): background, HUD, palette cycling, results screen, etc.
; -------------------------------------------------------------------------

	include	"Special Stage/Main.asm"

; -------------------------------------------------------------------------
; Initial values for the writable data that used to sit inside the program
; image (everything else in it starts at zero)
; -------------------------------------------------------------------------

SSRWInit:
	move.b	#20,timeStonePalDelay			; Time stone palette load delay
	move.w	#$100,ss1BGScrollShift			; Stage 1 background scroll shift
	rts

; -------------------------------------------------------------------------
; Stage data (palettes, background art/maps, demos): lives in ROM now
; -------------------------------------------------------------------------

	include	"Special Stage/Stage Data.asm"

; -------------------------------------------------------------------------
; Special stage logic (Sub CPU program, Mega Drive version)
; -------------------------------------------------------------------------

	include	"Special Stage/Sub.asm"

	include	"MD Port/Trace Table.asm"

	ALIGN	$20000, $FF				; Pad ROM to a multiple of 128KB
ROMEnd:
