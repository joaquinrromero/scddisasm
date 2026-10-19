; -------------------------------------------------------------------------
; Sonic CD Disassembly - Mega Drive port
; -------------------------------------------------------------------------
; Checks that every RAM region still fits in the space "RAM Map.inc"
; reserved for it. Include this after all the program files.
; -------------------------------------------------------------------------

	if VARSLEN>RSV_SUBVARS
		inform	3,"RAM map: special stage variables (VARSLEN) outgrew RSV_SUBVARS"
	endif
	if (SUBBUFEND-RAM_SUBBUF)>RSV_SUBBUF
		inform	3,"RAM map: the sprite/art hand-off buffers outgrew RSV_SUBBUF"
	endif
	if (FLOORVARSEND-RAM_FLOORVARS)>RSV_FLOORVARS
		inform	3,"RAM map: the floor sampler variables outgrew RSV_FLOORVARS"
	endif
	if (MainVarsEnd-MainVarsStart)>RSV_MAINVARS2
		inform	3,"RAM map: display program variables (MainVarsStart..MainVarsEnd) outgrew RSV_MAINVARS2"
	endif
	if MAINVARSSZ>RSV_MAINVARS
		inform	3,"RAM map: global variables (MAINVARSSZ) outgrew RSV_MAINVARS"
	endif
	if SSRWDATAUSED>RSV_RWDATA
		inform	3,"RAM map: writable data (SSRWDATAUSED) outgrew RSV_RWDATA"
	endif
	if IMGLENGTH<>IMGBYTES
		inform	3,"RAM map: IMGBYTES does not match IMGLENGTH"
	endif
