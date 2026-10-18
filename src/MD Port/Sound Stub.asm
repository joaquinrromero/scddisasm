; -------------------------------------------------------------------------
; Sonic CD Disassembly - Mega Drive port
; -------------------------------------------------------------------------
; Sub CPU command stub (replaces the contents of Level/Sub CPU.asm)
; -------------------------------------------------------------------------
; A plain Mega Drive has no Sub CPU, no CD audio and no PCM chip, so every
; command the level used to send (music, PCM fades, PCM-driven SFX) is
; swallowed here for now.
;
; PHASE 2: translate the SCMD_* IDs below into Sonic 1 SMPS sound IDs and
; queue them in the Sonic 1 Z80 driver. SCMD_* IDs seen in the Palmtree
; Panic Act 1 level code:
;   Music : R1AMUS R1CMUS R1DMUS PASTMUS SHOESMUS INVINCMUS RESULTMUS
;           GMOVERMUS BOSSMUS
;   Fades : FADECDA FADEPCM PAUSECDA UNPAUSECDA PAUSEPCM UNPAUSEPCM
;   SFX   : YESSFX PASTSFX FUTURESFX GIVEUPSFX GIGGLESFX BREAKSFX
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Fade out music
; -------------------------------------------------------------------------

FadeOutMusic:
	move.w	#SCMD_FADECDA,d0		; Fade out CD music

; -------------------------------------------------------------------------
; Send a command to the (non-existent) Sub CPU
; -------------------------------------------------------------------------
; PARAMETERS:
;	d0.w - Command ID
; -------------------------------------------------------------------------

SubCPUCmd:
	cmpi.w	#SCMD_BOSSMUS,d0		; Is this the command to play the boss music?
	bne.s	.End				; If not, branch
	move.b	#1,bossMusic			; Mark boss music as being played (level code reads this)

.End:
	rts

; -------------------------------------------------------------------------
