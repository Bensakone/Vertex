***************************************************************************
***									***
***	VERTEX v1.04	The 1st vectordemo by Red Chrome ever!		***
***	------------------------------------------------------		***
***	Copyright (C) 1993 by Maverick & Great J of Red Chrome		***
***									***
***	The routines in this source code are FreeWare. They may be	***
***	used for any purposes as long as proper credits are given	***
***	to the authors of this demo, that are Maverick & Great J.	***
***									***
***	Officially Released at the Assembly '93 - the Second Phase	***
***	(a pre-release version was compiled for some special persons)	***
***									***
***	Coding, Mathemathics & Design by				***
***		MAVERICK & GREAT J					***
***									***
***	Soundtrack 'Resolution' by					***
***		DIZZY							***
***									***
***	Red Chrome are							***
***		Maverick	Coding		***
***		Great J		Coding		***
***		Excelsior	Composing	***
***		Dizzy		Composing	***
***		Deadlock	PR & Swapping	***
***									***
***	Red Chrome Public Relations Management				***
***		RED CHROME						***
***		PO BOX 70						***
***		SF-85801 HAAPAJÄRVI					***
***		FINLAND							***
***									***
***									***
***	Edited too many times for a history to be added...		***
***	...until now, when we have finally reached v1.00!		***
***									***
***	Edited:								***
***	190793	v1.00	- Finished most of the coding.			***
***	200793	v1.01	- Debug options added in final mouseloop, too.	***
***			- Part 13 - The End Text bug fixed.		***
***			  Now works fine on ECS Agnus / 1Mb Chip.	***
***			- "clr.w FadeValue(a4)" also added in part 13.	***
***			- Added the Output message writer after quit.	***
***	240793	v1.02	- All drawline routines for linevectors		***
***			  changed to drawline by Great J.		***
***			- Drawline_BPV removed as unnecessary routine.	***
***			- Added RMOUSE_PAUSE debug option.		***
***			- Tested on system with no fast memory at all.	***
***			  Result: part 1 (bordered planevector), part 6	***
***			  (field of dots) and part 8 (willesball) went	***
***			  occasionally to another frame, but it was	***
***			  rather rare and it didn't bother. Most parts	***
***			  weren't even close to another frame.		***
***	290793	v1.03	- Changed music from Corporation to Resolution.	***
*** R1	A '93	v1.04	- Minor modifications before releasing.		***
***									***
***************************************************************************

	include "custom.i"
	include "cia.i"
	include "libs.i"
	include "MGmacros.i"

;;; Debug options
RASTERTIME	= 0		; show rastertime in every part
DEBUG		= 0		; go to next part with left/right mouse button
RMOUSE_PAUSE	= 0		; right mouse button pauses (not with DEBUG!)

;;; BSS Stack (tm) Variable Definitions
	dl	VBR
	dl	oldcopper,oldvbi,oldciab
	dw	olddma,oldintena
	dw	oldcra,oldcrb

	dw	Part

	dl	Buffer,Active,planebuffer,clearbuffer

	dw	boing,boingval

	dl	ObjCoords,ObjConnect,ObjFace
	dw	ObjPointNo,ObjLineNo,ObjFaceNo

	dw	timer,rotation,obenumber,timer2,quitflag

	dw	Xangle,Yangle,Zangle
	dw	Xcos,Xsin,Ycos,Ysin,Zcos,Zsin
	dw	Distance

	dw	FadeValue
	dw	minY,maxY,minX,maxX
	dl	xadd,xaddOLD
	dw	modulo,blitsize,moduloOLD,blitsizeOLD
	dw	minYOLD

	dl	scrollpointer
	dw	ScrollOdotus
	dw	timer_wille,ColNum,coltimer
	dw	x_sin_pointer,y_sin_pointer,anus_ptr

	dw	Joka,flag,counter
	dl	FunnyPointer
	dw	framepointer
	dw	MorphValue
	dl	aloitus
	dl	Ystart

	dl	BitPlaneAdd
	dw	PrintSpeed
	dw	Line,Col
	dw	mandelcx,mandelcy
	dw	mandelwait1,mandelwait2
	dw	mandelstart

	dl	End_Text_Ptr

;;; Kaiken pahan alku ja juuri
Main:	bra.s	.ver
	dc.b	"$VER: Vertex 1.03 (29.07.1993) by Red Chrome",0,0
.ver
	lea	Bss_Stack,a4
	move.l	ExecBase,a6
	bsr	GetVBR
	move.l	a5,VBR(a4)
	lea	gfxname(pc),a1
	moveq	#0,d0
	jsr	Exec_OpenLibrary(a6)
	tst.l	d0
	beq.s	.no_gfx_lib_but_so_what
	move.l 	d0,a1
	move.l 	Gfx_copinit(a1),oldcopper(a4)
	jsr	Exec_CloseLibrary(a6)

.no_gfx_lib_but_so_what
	lea	custom,a6
	move.w	dmaconr(a6),olddma(a4)
	move.w	intenar(a6),oldintena(a4)

	lea	ciab,a3
	move.b	cra(a3),oldcra(a4)
	move.b	crb(a3),oldcrb(a4)

	move.l	Exec_intvector_vbi(a5),oldvbi(a4)
	move.l	Exec_intvector_ciab(a5),oldciab(a4)

	move.w	#%0000000000101111,dmacon(a6)
	move.w	#%1000010111010000,dmacon(a6)

	move.w	#%0011111111111111,intena(a6)

	move.b	#$37,tahi(a3)
	move.b	#$6a,talo(a3)
	move.b	#%00011111,icr(a3)
	move.b	#%10000001,icr(a3)
	move.b	#%10010101,cra(a3)

	bsr.w	mt_init

	lea	ciab_music_irq(pc),a0
	move.l	a0,Exec_intvector_ciab(a5)

	move.w	#%1110000000000000,intena(a6)

;;; Run all the parts.
.parts:
	;; The rules for each part subroutine:
	;; - can trust a4=bss vars, a5=vbr, a6=custom on entry
	;; - does not have to restore the above
	;; - must set everything up for themselves
	;; - must set quitflag=-1 to move on
	move.w	Part(a4),d0	; part number
	add.w	#1,Part(a4)
	lsl.w	#2,d0
	lea	SetList,a0
	add.w	d0,a0
	tst.l	(a0)
	beq	.CleanUp
	move.l	(a0),a0

	clr.w	quitflag(a4)

	movem.l	d0-a6,-(sp)
	jsr	(a0)
	movem.l	(sp)+,d0-a6

.MainLoop
	;; FIXME: this loop is quite silly
	cmp.w	#-1,quitflag(a4)
	beq.w	.GoOn

	IF	DEBUG = 1
	LeftMouse
	bne.b	.MainLoop
	ELSE
	LeftMouse
	beq.w	.CleanUp
	bra.s	.MainLoop
	ENDC
.GoOn

	bra	.parts

;;; CLEAN UP ALL THE MESS
.CleanUp:
	move.w	#$7fff,intena(a6)

	bsr.w	mt_end

	lea	custom,a6
	move.l	oldcopper(a4),cop1lch(a6)
	move.l	oldvbi(a4),Exec_intvector_vbi(a5)
	move.l	oldciab(a4),Exec_intvector_ciab(a5)

	lea	ciab,a3
	move.b	#$9f,icr(a3)
	move.b	oldcra(a4),cra(a3)
	move.b	oldcrb(a4),crb(a3)

	move.w	olddma(a4),d0
	or.w	#$8000,d0
	move.w	d0,dmacon(a6)

	move.w	oldintena(a4),d0
	or.w	#$C000,d0
	move.w	d0,intena(a6)

	moveq	#0,d0
	rts				;-)  And it all ended up so happily...

;;; Parts to show
SetList:
	dc.l	Part_OpenYourEyesNow
	dc.l	Part_IcosahedralLineVector
	dc.l	Part_LoveKnowItAndFear
	dc.l	Part_VertexMultiplane
	dc.l	Part_VectorGridMunuainen
	dc.l	Part_FieldOfDots
	dc.l	Part_FakePlasma
	dc.l	Part_WillesBall
	dc.l	Part_MandelWriter
	dc.l	Part_SlimeVector
	dc.l	Part_DickPic
	dc.l	Part_Glenz
	dc.l	Part_TheEnd
	dc.l	0		; end

;;; Get Vector Base Register
	;; In:	a6=execbase
	;; Out:	a5=vbr (0 for 68000)
GetVBR:	sub.l	a5,a5
	btst	#0,297(a6)
	beq.s	.vanilla68k
	lea.l	.supervisor_getvbr(pc),a5
	jsr	Exec_Supervisor(a6)
.vanilla68k:
	rts

.supervisor_getvbr:
	machine	mc68010
	movec	vbr,a5
	machine	mc68000
	rte

;;; CIAB musansoittokeskeytys - tosin ei cia-playerillä...
ciab_music_irq:
	move.l	d0,-(sp)
	bsr.w	mt_music
	move.b	icr+ciab,d0
	move.w	#$2000,intreq+custom
	move.l	(sp)+,d0
	rte

;;; Kaikki vblank-keskeytykset ja rutiinit eri osioihin

;;; BORDERED PLANEVECTOR 'OPEN YOUR EYES, NOW!'
Part_OpenYourEyesNow:
	lea	vbi_BPV(pc),a0
	move.l	a0,Exec_intvector_vbi(a5)

	lea	CopperList_BPV,a0
	move.l  a0,cop1lch(a6)

	bsr	DefineObject_Open

	move.w	#1,obenumber(a4)
	move.w	#0,FadeValue(a4)

	lea	plane1,a0
	move.l	a0,Active(a4)
	lea	plane2,a0
	move.l	a0,Buffer(a4)

	move.w	#%1000000000100000,intena(a6)

	rts

vbi_BPV:
	movem.l d0-a6,-(sp)

	lea	Bss_Stack,a4

	IF	RMOUSE_PAUSE = 1
	RightMouse
	beq.w	.rmpause
	ENDC

	bsr	SwapBuffers
	move.l	Active(a4),a0
	lea	Planes_BPV,a1
	moveq	#40,d0
	moveq	#2-1,d1
	bsr	SetPlanes

	move.l	Buffer(a4),d0
	add.l	#50*40*2,d0
	moveq	#0,d1
	move.w	#64*150*2+20,d2
	bsr	ClearScreen

	cmp.w	#-1,obenumber(a4)
	beq.w	.final_fade

	cmp.w	#4,obenumber(a4)
	bne.s	.no_delay
	addq.w	#1,timer(a4)
	cmp.w	#30,timer(a4)
	bls.w	.ylistys
.no_delay

	cmp.w	#-2,rotation(a4)
	beq.w	.no_rot2

	lea	CopColors_BPV,a0
	lea	Colors_BPV(pc),a1
	moveq	#4,d0
	moveq	#4,d7
	bsr	FadeIn

	cmp.w	#-1,rotation(a4)	; obj close => no more rotation
	beq.w	.no_rot

	cmp.w	#1,obenumber(a4)	; different rotations for
	bne.s	.not1			; all objects

	addq.w	#8,Xangle(a4)
	cmp.w	#720,Xangle(a4)
	blt.s	.ok11
	sub.w	#720,Xangle(a4)
	move.w	#-1,rotation(a4)
.ok11	addq.w	#8,Yangle(a4)
	cmp.w	#720,Yangle(a4)
	blt.s	.ok21
	sub.w	#720,Yangle(a4)
.ok21	addq.w	#8,Zangle(a4)
	cmp.w	#720,Zangle(a4)
	blt.s	.ok31
	sub.w	#720,Zangle(a4)
.ok31
	bra.w	.rot_end
.not1

	cmp.w	#2,obenumber(a4)
	bne.s	.not2

	add.w	#8,Xangle(a4)
	cmp.w	#720,Xangle(a4)
	blt.s	.ok12
	sub.w	#720,Xangle(a4)
	move.w	#-1,rotation(a4)
.ok12	add.w	#8,Yangle(a4)
	cmp.w	#720,Yangle(a4)
	blt.s	.ok22
	sub.w	#720,Yangle(a4)
.ok22	add.w	#4,Zangle(a4)
	cmp.w	#720,Zangle(a4)
	blt.s	.ok32
	sub.w	#720,Zangle(a4)
.ok32
	bra.w	.rot_end
.not2

	cmp.w	#3,obenumber(a4)
	bne.s	.not3

	add.w	#8,Xangle(a4)
	cmp.w	#720,Xangle(a4)
	blt.s	.ok13
	sub.w	#720,Xangle(a4)
	move.w	#-1,rotation(a4)
.ok13	add.w	#4,Yangle(a4)
	cmp.w	#720,Yangle(a4)
	blt.s	.ok23
	sub.w	#720,Yangle(a4)
.ok23	add.w	#8,Zangle(a4)
	cmp.w	#720,Zangle(a4)
	blt.s	.ok33
	sub.w	#720,Zangle(a4)
.ok33
	bra.s	.rot_end
.not3

	cmp.w	#4,obenumber(a4)
	bne.s	.not4

	add.w	#4,Xangle(a4)
	cmp.w	#720,Xangle(a4)
	blt.s	.ok14
	sub.w	#720,Xangle(a4)
	move.w	#-1,rotation(a4)
.ok14	add.w	#4,Yangle(a4)
	cmp.w	#720,Yangle(a4)
	blt.s	.ok24
	sub.w	#720,Yangle(a4)
.ok24	add.w	#8,Zangle(a4)
	cmp.w	#720,Zangle(a4)
	blt.s	.ok34
	sub.w	#720,Zangle(a4)
.ok34
	;	bra.s	.rot_end
.not4

.rot_end
.no_rot

	add.w	#135,Distance(a4)
	cmp.w	#-820,Distance(a4)
	ble.s	.ok0
	move.w	#-820,Distance(a4)
	move.w	#-2,rotation(a4)	; obj close enough -flag
.ok0

	bra.w	.ylistys

.no_rot2
	sub.w	#35,Distance(a4)	; next obj?
	cmp.w	#-1200,Distance(a4)
	bge.s	.okII

	move.w	#-7000,Distance(a4)
	clr.w	rotation(a4)

	addq.w	#1,obenumber(a4)

	cmp.w	#2,obenumber(a4)
	bne.s	.no2
	bsr	DefineObject_Your
.no2
	cmp.w	#3,obenumber(a4)
	bne.s	.no3
	bsr	DefineObject_Eyes
.no3
	cmp.w	#4,obenumber(a4)
	bne.s	.jaha
	bsr	DefineObject_Now
	bra.s	.jaha

.okII	cmp.w	#4,obenumber(a4)
	bne.s	.jaha

	lea	CopColors_BPV,a0
	lea	Colors_BPV(pc),a1
	moveq	#17,d0
	moveq	#4,d7
	bsr	FlashOut

	tst.w	FadeValue(a4)
	bne.w	.ylistys
	move.w	#-1,obenumber(a4)
	move.w	#$7f,FadeValue(a4)

	bra.s	.ylistys

.jaha	lea	CopColors_BPV,a0
	lea	Colors_BPV(pc),a1
	moveq	#10,d0
	moveq	#4,d7
	bsr	FadeOut

.ylistys

	NastyOFF
	sub.l	a3,a3
	sub.l	a5,a5

	bsr.w	CalcVecPoints
	NastyON

	bsr.w	DrawVectors_BPV

	move.l	Buffer(a4),d0
	add.l	#40*204*2-40,d0
	moveq	#40,d1
	move.w	#64*150*1+20,d2
	bsr	Fill

	bra.s	.overandout

.final_fade
	addq.w	#1,timer2(a4)
	cmp.w	#30,timer2(a4)
	bls.w	.overandout

	lea	CopColors_BPV,a0
	lea	Colors_BPV2(pc),a1
	moveq	#2,d0
	moveq	#4,d7
	bsr	FadeOut

	tst.w	FadeValue(a4)
	bne.s	.overandout
	move.w	#-1,quitflag(a4)	; TÄSSÄ TÄSSÄ TÄSSÄ TÄSSÄ!!!!!!
.overandout

	IF	RASTERTIME	= 1
	move.w	#$005,c0+custom
	ENDC
.rmpause
.end	move.w	#$20,intreq+custom
	movem.l (sp)+,d0-a6
	rte



DrawVectors_BPV:
	move.l	ObjConnect(a4),a2
	move.w	ObjLineNo(a4),d7
	lea	TempCoordsTable,a3
	move.l	Buffer(a4),a0
	lea	(a0),a5
	WaitB
	move.w	#$8000,bltadat(a6)
	move.w	#$ffff,bltbdat(a6)
	move.l	#-1,bltafwm(a6)
	move.w	#40*2,bltcmod(a6)
	move.w	#40*2,bltdmod(a6)
.drawloop
	lea	(a5),a0
	lea	(a3),a1
	add.w	(a2)+,a1
	move.w	(a1),d0
	move.w	2(a1),d1
	lea	(a3),a1
	add.w	(a2)+,a1
	move.w	(a1),d2
	move.w	2(a1),d3
	movem.l	d0-d5,-(sp)
	bsr.w	drawline_f_BPV
	movem.l	(sp)+,d0-d5
	lea	40(a5),a0
	bsr	DrawLine_MinMax
	dbf	d7,.drawloop
	rts

drawline_f_BPV:
	cmp.w	d1,d3
	bhi.s	.next1
	exg	d0,d2
	exg	d1,d3
.next1
	cmp.w	d3,d1
	bne.s	.next2
	rts
.next2
	moveq	#0,d5
	move.w	d3,d4
	sub.w	d1,d4
	add.w	d4,d4
	sub.w	d0,d2
	bge.s	.x2gXangle
	neg.w	d2
	addq.w	#2,d5
.x2gXangle	cmp.w	d4,d2
	blo.s	.allok
	subq.w	#1,d3
.allok
	sub.w	d1,d3
	mulu	#40*2,d1
	move.w	d0,d4
	asr.w	#3,d4
	add.w	d4,d1
	add.l	a0,d1

	move.w	d3,d4
	sub.w	d2,d4
	bge.s	.dygdx
	exg	d2,d3
	addq.w	#1,d5
.dygdx
	move.b	.oktantit_f(pc,d5),d5
	add.w	d2,d2
	and.w	#$000f,d0
	ror.w	#4,d0
	or.w	#%0000101101011010,d0

	WaitB

	move.w	d2,bltbmod(a6)
	sub.w	d3,d2
	bge.s	.signnl
	or.b	#%01000000,d5
.signnl	move.w	d2,bltaptl(a6)
	sub.w	d3,d2
	move.w	d2,bltamod(a6)
	move.w	d0,bltcon0(a6)
	move.w	d5,bltcon1(a6)
	move.l	d1,bltcpth(a6)
	move.l	d1,bltdpth(a6)
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,bltsize(a6)
	rts

.oktantit_f:
	dc.b 0+3
	dc.b 16+3
	dc.b 8+3
	dc.b 20+3


;;; A BOUNCH OF LINEVECTORS
Part_IcosahedralLineVector:
	move.w	#%0000000000100000,intena(a6)

	lea	plane1,a0
	move.l	a0,Active(a4)
	lea	plane2,a0
	move.l	a0,Buffer(a4)

	bsr	DefineObject_Line

	clr.w	minYOLD(a4)
	clr.w	xaddOLD(a4)
	clr.w	moduloOLD(a4)
	move.w	#255*2*64+20,blitsizeOLD(a4)

	clr.w	minY(a4)
	clr.w	xadd(a4)
	clr.w	modulo(a4)
	move.w	#255*2*64+20,blitsize(a4)

	lea	bpl3+17920,a0			; memory for scroller
	lea	Planes_Line,a1
	moveq	#44,d0
	moveq	#1-1,d1
	bsr.w	SetPlanes

	lea	bpl3+17920,a0			; memory for scroller
	lea	Planes_Wille2,a1
	moveq	#44,d0
	moveq	#1-1,d1
	bsr.w	SetPlanes

	lea	vbi_Line(pc),a0
	move.l	VBR(a4),a5
	move.l	a0,Exec_intvector_vbi(a5)
	lea	CopperList_Line,a0
	move.l  a0,cop1lch(a6)

	lea	text(pc),a0
	move.l	a0,scrollpointer(a4)
	move.w	#10,ScrollOdotus(a4)

	move.w	#%1000000000100000,intena(a6)

	rts

vbi_Line:
	movem.l d0-a6,-(sp)

	lea	Bss_Stack,a4
	lea	custom,a6
	
	IF	RMOUSE_PAUSE = 1
	RightMouse
	beq.w	.rmpause
	ENDC

	NastyON
	bsr.w	SwapBuffers

	move.l	Active(a4),a0
	lea	Planes2,a1
	moveq	#40,d0
	moveq	#2-1,d1
	bsr.w	SetPlanes

	move.l	Buffer(a4),d0
	moveq	#0,d1
	move.w	minYOLD(a4),d1
	mulu	#40*2,d1
	add.l	d1,d0
	add.l	xaddOLD(a4),d0
	move.w	moduloOLD(a4),d1
	move.w	blitsizeOLD(a4),d2
	bsr	ClearScreen

	move.w	minY(a4),minYOLD(a4)
	move.l	xadd(a4),xaddOLD(a4)
	move.w	modulo(a4),moduloOLD(a4)
	move.w	blitsize(a4),blitsizeOLD(a4)

	bsr.w	SetAngles
.yli

	move.w	#255,minY(a4)
	clr.w	maxY(a4)
	move.w	#320,minX(a4)
	clr.w	maxX(a4)

	addq.w	#1,timer(a4)

	cmp.w	#50*20,timer(a4)
	ble.w	.jump4

	bsr	DefineObject_Wille
	move.w	#127,FadeValue(a4)
	move.w	#6,ColNum(a4)

	lea	vbi_Wille(pc),a0
	move.l	VBR(a4),a5
	move.l	a0,Exec_intvector_vbi(a5)
	lea	CopperList_Wille,a0
	move.l  a0,cop1lch(a6)


	move.w	x_sin_pointer(a4),d0
	lea	x_sine(pc),a3
	move.w	(a3,d0.w),d0
	cmp.w	#$1234,d0
	bne.s	.ok1
	moveq.l	#0,d0
	clr.w	x_sin_pointer(a4)
.ok1
	move.w	d0,a3

	move.w	y_sin_pointer(a4),d0
	lea	y_sine(pc),a5
	move.w	(a5,d0.w),d0
	cmp.w	#$1234,d0
	bne.s	.ok2
	moveq.l	#0,d0
	clr.w	y_sin_pointer(a4)
.ok2
	move.w	d0,a5

	addq.w	#2,x_sin_pointer(a4)
	addq.w	#2,y_sin_pointer(a4)

	bsr	CalcVecPoints_Wille

	bsr.w	VisiblePlanes_Wille

	NastyON

	bsr	DrawSurfaces_Wille
	bsr.w	FillScreen_Wille
	WaitB

	bra.w	.joopajoopajoopajoo

.jump4
	cmp.w	#50*15,timer(a4)
	blo.s	.jump3
	lea	CopColor_LineC2,a0
	lea	Color_Line(pc),a1
	moveq	#1,d0
	moveq	#1,d7
	bsr	FadeOut

	bra	.jump
.jump3	cmp.w	#50*8,timer(a4)
	blo.s	.jump2
	bra	.jump

.jump2	cmp.w	#50*7,timer(a4)
	blo.s	.jump1
	lea	CopColor_LineC2,a0
	lea	Color_Line(pc),a1
	moveq	#1,d0
	moveq	#1,d7
	bsr	FadeOut
	bra.w	.jump

.jump1	lea	CopColor_LineC1,a0
	lea	Color_Line(pc),a1
	moveq	#1,d0
	moveq	#3,d7
	bsr	FadeIn

.jump

	move.w	x_sin_pointer(a4),d0
	lea	x_sine(pc),a3
	move.w	(a3,d0.w),d0
	cmp.w	#$1234,d0
	bne.w	.ok111
	moveq.l	#0,d0
	clr.w	x_sin_pointer(a4)
.ok111
	move.w	d0,a3

	move.w	y_sin_pointer(a4),d0
	lea	y_sine(pc),a5
	move.w	(a5,d0.w),d0
	cmp.w	#$1234,d0
	bne.s	.ok222
	moveq.l	#0,d0
	clr.w	y_sin_pointer(a4)
.ok222
	move.w	d0,a5

	addq.w	#2,x_sin_pointer(a4)
	addq.w	#2,y_sin_pointer(a4)

	bsr	CalcVecPoints


	bsr.w	VisiblePlanes

	NastyON

	bsr	DrawSurfaces
	bsr.w	FillScreen_Line
	WaitB


	add.w	#50,Distance(a4)
	cmp.w	#-1000,Distance(a4)
	blt.s	.yli2
	move.w	#-1000,Distance(a4)
.yli2
	
.joopajoopajoopajoo

	bsr	Scroller

	IF	RASTERTIME = 1
	move.w	#$005,c0(a6)		; rasteriaika 	( <= terävää! ;-)
	ENDC
.rmpause

.loppu

	move.w	#$20,intreq(a6)
	movem.l (sp)+,d0-a6
	rte



vbi_Wille:
	movem.l d0-a6,-(sp)

	lea	Bss_Stack,a4
	lea	custom,a6
	
	IF	RMOUSE_PAUSE = 1
	RightMouse
	beq.w	.rmpause
	ENDC

	NastyOFF

	bsr.w	SwapBuffers

	move.l	Active(a4),a0
	lea	Planes_Wille,a1
	moveq	#40,d0
	moveq	#3-1,d1
	bsr.w	SetPlanes

	move.l	Buffer(a4),d0
	moveq	#0,d1
	move.w	minYOLD(a4),d1

	tst.w	timer(a4)
	beq.s	.aarrgghh

	mulu	#40*2,d1
	clr.w	timer(a4)
	bra.s	.ooh
.aarrgghh
	mulu	#40*3,d1
.ooh
	add.l	d1,d0
	add.l	xaddOLD(a4),d0
	move.w	moduloOLD(a4),d1
	move.w	blitsizeOLD(a4),d2
	bsr	ClearScreen

	move.w	minY(a4),minYOLD(a4)
	move.l	xadd(a4),xaddOLD(a4)
	move.w	modulo(a4),moduloOLD(a4)
	move.w	blitsize(a4),blitsizeOLD(a4)

	bsr.w	SetAngles

	addq.w	#1,timer_wille(a4)
	cmp.w	#50*9,timer_wille(a4)
	bls.s	.oko
	sub.w	#50,Distance(a4)
	cmp.w	#-10000,Distance(a4)
	bge.s	.disok
	move.w	#-10000,Distance(a4)
.disok
	lea	CopColor_Wille,a0
	lea	Color_Wille(pc),a1
	moveq	#1,d0
	moveq	#7,d7
	bsr	FadeOut

	bra.s	.joop
.oko
	bsr	ColorChange_Wille
.joop


.yli

	move.w	#255,minY(a4)
	clr.w	maxY(a4)
	move.w	#320,minX(a4)
	clr.w	maxX(a4)


	move.w	x_sin_pointer(a4),d0
	lea	x_sine(pc),a3
	move.w	(a3,d0.w),d0
	cmp.w	#$1234,d0
	bne.s	.ok1
	moveq.l	#0,d0
	clr.w	x_sin_pointer(a4)
.ok1
	move.w	d0,a3

	move.w	y_sin_pointer(a4),d0
	lea	y_sine(pc),a5
	move.w	(a5,d0.w),d0
	cmp.w	#$1234,d0
	bne.s	.ok2
	moveq.l	#0,d0
	clr.w	y_sin_pointer(a4)
.ok2
	move.w	d0,a5

	addq.w	#2,x_sin_pointer(a4)
	addq.w	#2,y_sin_pointer(a4)



	bsr	CalcVecPoints_Wille
	bsr.w	VisiblePlanes_Wille

	NastyON				; more (bi?)cycles to the BLITTER

	bsr	DrawSurfaces_Wille
	bsr.w	FillScreen_Wille
	WaitB

	bsr	Scroller

	IF	RASTERTIME = 1
	move.w	#$005,c0(a6)
	ENDC
.rmpause

.loppu
	move.w	#$20,intreq(a6)
	movem.l (sp)+,d0-d7/a0-a6
	rte


ColorChange_Wille:
	subq.w	#1,coltimer(a4)
	bpl.s	.end

	move.w	#30,coltimer(a4)

	lea	CopColor_Wille+2,a0

	move.w	ColNum(a4),d7
	beq.s	.end

	subq.w	#1,d7

.loop	sub.w	#$100,(a0)
	addq.l	#4,a0
	dbf	d7,.loop

	subq.w	#1,ColNum(a4)

.end	rts




VisiblePlanes_Wille:
	move.l	ObjFace(a4),a0
	lea	FaceVisibleTable,a1
	lea	TempZTable,a2

	move.w	ObjFaceNo(a4),d7
.loop
	move.w	(a0)+,d0		; kolme tason z-koordinaattia
	move.w	(a0)+,d1
	move.w	(a0)+,d2

	move.w	(a2,d0.w),d0
	add.w	(a2,d1.w),d0
	add.w	(a2,d2.w),d0

	cmp.w	#7,d0
	bgt.s	.ok
	moveq	#-1,d0
	bra.s	.not_visible
.ok

	cmp.w	#20*3,d0
	bhi.s	.1
	moveq	#1,d0
	bra.s	.not_visible
.1
	cmp.w	#30*3,d0
	bhi.s	.2
	moveq	#2,d0
	bra.s	.not_visible
.2
	cmp.w	#40*3,d0
	bhi.s	.3
	moveq	#3,d0
	bra.s	.not_visible
.3
	cmp.w	#50*3,d0
	bhi.s	.4
	moveq	#4,d0
	bra.s	.not_visible
.4
	cmp.w	#60*3,d0
	bhi.s	.5
	moveq	#5,d0
	bra.s	.not_visible
.5
	cmp.w	#70*3,d0
	bhi.s	.6
	moveq	#6,d0
	bra.s	.not_visible
.6
	moveq	#7,d0


.not_visible
	move.w	d0,(a1)+		; -95...95

	dbf	d7,.loop

	rts




DrawSurfaces_Wille:
	WaitB
	move.w	#$8000,bltadat(a6)
	move.w	#$ffff,bltbdat(a6)
	move.l	#-1,bltafwm(a6)
	move.w	#40*3,bltcmod(a6)
	move.w	#40*3,bltdmod(a6)

	move.l	ObjConnect(a4),a1	; objectin tiedot
	lea	TempCoordsTable,a2	; lasketut xy
	lea	FaceVisibleTable,a3	; tasojen näkyvyys

	move.w	(a1)+,d7		; tasojen määrä
.loop1:	move.w	(a1)+,d6		; viivojen määrä tasossa
	move.w	(a1)+,a5		; väri
	move.w	(a3)+,d0		; piirretäänkö?
	bmi.w	.DoNotDraw

	move.w	d0,a5

.loop2:	move.l	Buffer(a4),a0
	move.w	a5,d0
	btst	#0,d0
	beq.s	.yli1
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_Wille
.yli1
	move.w	a5,d0
	btst	#1,d0
	beq.s	.yli2
	add.l	#40,a0
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_Wille
.yli2
	move.w	a5,d0
	btst	#2,d0
	beq.s	.yli3
	move.l	Buffer(a4),a0
	add.l	#80,a0
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_Wille
.yli3
	addq.l	#4,a1
	dbf	d6,.loop2
	bra.s	.jump1
.DoNotDraw:
	addq.w	#1,d6
	asl.w	#2,d6
	add.w	d6,a1
.jump1:	dbf	d7,.loop1
	rts

FillScreen_Wille:
	subq.w	#1,minY(a4)
	sub.w	#16,minX(a4)	; minX
	add.w	#16,maxX(a4)	; maxX
	addq.w	#1,maxY(a4)

	move.w	maxX(a4),d1	; maxX
	lsr.w	#3,d1
	bclr	#0,d1		; parilliseksi
	move.w	d1,d4		; talteen
	move.w	minX(a4),d0	; minX
	lsr.w	#3,d0
	bclr	#0,d0		; parilliseksi
	sub.w	d0,d1		; koko d1
	move.w	#1*40,d3
	sub.w	d1,d3		; modulo d3
	
	move.w	maxY(a4),d2	; maxY
	sub.w	minY(a4),d2	; korkeus riveinä
;	asl.w	#1,d2		; korkeus*2 (planejen määrä)
	mulu	#3,d2
	asl.w	#6,d2		; oikeisiin bitteihin
	asr.w	#1,d1
	or.w	d1,d2		; bltsize

	move.l	Buffer(a4),a0
	move.w	maxY(a4),d0	; maxY
	mulu	#40*3,d0
	ext.l	d4
	add.l	d0,a0
	add.l	d4,a0		; startaddress a0

	move.w	d3,modulo(a4)
	move.w	d2,blitsize(a4)
	move.w	minX(a4),d0	; minX
	lsr.l	#3,d0
	bclr	#0,d0		; parilliseksi
	ext.l	d0
	move.l	d0,xadd(a4)

	rts		;-)




***	DrawLine v1.0 by Great J of Red Chrome
***	Input:	d0=x1, d1=y1, d2=x2, d3=y2, a0=bitplane, a6=custom
***	Uses:	d4,d5

drawline_Wille:
	cmp.w	d0,d2
	bhi.s	.Left2Right
	bne.s	.MakeLeft2Right
	cmp.w	d1,d3
	beq.w	.end
.MakeLeft2Right
	exg	d0,d2
	exg	d1,d3
.Left2Right

	; d0<d2

	cmp.w	minX(a4),d0
	bhi.s	.d0_not_MinX
	move.w	d0,minX(a4)
.d0_not_MinX
	cmp.w	maxX(a4),d2
	blo.s	.d2_not_MaxX
	move.w	d2,maxX(a4)
.d2_not_MaxX

	cmp.w	minY(a4),d1
	bhi.s	.d1_not_MinY
	move.w	d1,minY(a4)
.d1_not_MinY
	cmp.w	maxY(a4),d1
	blo.s	.d1_not_MaxY
	move.w	d1,maxY(a4)
.d1_not_MaxY

	cmp.w	minY(a4),d3
	bhi.s	.d3_not_MinY
	move.w	d3,minY(a4)
.d3_not_MinY
	cmp.w	maxY(a4),d3
	blo.s	.d3_not_MaxY
	move.w	d3,maxY(a4)
.d3_not_MaxY

	moveq	#0,d4
	sub.w	d0,d2		; DeltaX	(Left2Right => pakosta posit.)
	sub.w	d1,d3		; DeltaY
	bge.s	.Up2Down	; positiivinen => ylhäältä alas
	neg.w	d3		; negatiivinen => alhaalta ylös
	moveq	#2,d4		; oktantti alhaalta ylös -vaastaavaksi
.Up2Down
	cmp.w	d2,d3
	bge.s	.DeltaOk	; d2 = DeltaP, d3 = DeltaS
	exg	d2,d3
	addq.w	#1,d4		; oktantti kk:ta vastaavaksi ( nyt |kk| < 1 )
.DeltaOk
	add.w	d2,d2		; 2DeltaP

	mulu	#40*3,d1

;	move.w	d1,d5
;	lsl.w	#3,d1
;	lsl.w	#5,d5
;	add.w	d5,d1
;	ext.l	d1

	move.w	d0,d5
	asr.w	#3,d0
	add.w	d0,d1
	add.l	a0,d1		; d0 = viivan alkuosoite

	move.b	.octant(pc,d4.w),d4
	and.w	#$f,d5		; d5 = lähtöpikselin tarkka paikka (X)
	ror.w	#4,d5
	or.w	#$bea,d5	; mintermi & kanavat
	swap	d5
	move.w	d4,d5

	move.w	d3,d4
	lsl.w	#6,d4
	add.w	#$42,d4

	WaitB

	move.w	d2,bltbmod(a6)
	sub.w	d3,d2		; 2DeltaP - DeltaS
	bge.s	.SignBitOk
	or.w	#$40,d5		; Set Sign Bit
.SignBitOk
	move.w	d2,bltaptl(a6)
	sub.w	d3,d2		; (2DeltaP - DeltaS) - DeltaS =2(DeltaP-DeltaS)
	move.w	d2,bltamod(a6)
	move.l	d1,bltcpth(a6)
	move.l	d1,bltdpth(a6)
	move.l	d5,bltcon0(a6)
	move.w	d4,bltsize(a6)

.end	rts



;  Line Mode Bit -------+
;  1 Pixel / Line Bit -+|
;  3 Octant Bits ----+ ||
;                    | ||
.octant		;   OOOPL
	dc.b	%00000001	; 
	dc.b	%00010001	; 
	dc.b	%00000101	; 
	dc.b	%00011001	; 




Scroller:
	subq.w	#1,ScrollOdotus(a4)
	bgt.b	.sl
.here:	moveq	#0,d0
	move.l	scrollpointer(a4),a0
	move.b	(a0),d0
	bne.s	.yli

	move.w	#-1,quitflag(a4)	; poistumiskomento


	lea	text(pc),a0
	move.l	a0,scrollpointer(a4)
	bra.s	.here
.yli:
	addq.l	#1,scrollpointer(a4)
	ext.w	d0
	sub.b	#32,d0
	bgt.s	.NoMess
	moveq	#0,d0
.NoMess:
	add.w	d0,d0
	move.w	ScrollTable(pc,d0.w),d0
	lea	fonts,a1
	add.w	d0,a1
	move.w	#8,ScrollOdotus(a4)

	lea	bpl3+17920+40,a0		; memory for scroller
	moveq	#23-1,d7
.cloop:	move.b	(a1),(a0)
	add.w	#100,a1
	add.w	#44,a0
	dbf	d7,.cloop
; shift right
.sl:
	move.l	#23*44,d0
	lea	bpl3+17920,a0
	add.l	a0,d0
	WaitB
	move.l	#$7FFFFFFF,bltafwm(a6)
	move.w	#0,bltamod(a6)
	move.w	#0,bltdmod(a6)
	move.l	d0,bltapth(a6)
	move.l	d0,bltdpth(a6)	
	move.l	#$19f00002,bltcon0(a6)
	move.w	#24*1*64+22,bltsize(a6)
	rts

ScrollTable:
	dc.w	92	; space
	dc.w	86	; !
	dc.w	92	; "
	dc.w	92	; #
	dc.w	92	; $
	dc.w	92	; %
	dc.w	92	; &
	dc.w	82	; '
	dc.w	88	; (
	dc.w	90	; )
	dc.w	92	; *
	dc.w	92	; +
	dc.w	78	; ,
	dc.w	80	; -
	dc.w	76	; .
	dc.w	92	; /
	dc.w	56	; 0
	dc.w	58	; 1
	dc.w	60	; 2
	dc.w	62	; 3
	dc.w	64	; 4
	dc.w	66	; 5
	dc.w	68	; 6
	dc.w	70	; 7
	dc.w	72	; 8
	dc.w	74	; 9
	dc.w	92	; :
	dc.w	92	; ;
	dc.w	92	; <
	dc.w	92	; =
	dc.w	92	; >
	dc.w	84	; ?
	dc.w	92	; @
	dc.w	0	; A
	dc.w	2	; B
	dc.w	4	; C
	dc.w	6	; D
	dc.w	8	; E
	dc.w	10	; F
	dc.w	12	; G
	dc.w	14	; H
	dc.w	16	; I
	dc.w	18	; J
	dc.w	20	; K
	dc.w	22	; L
	dc.w	24	; M
	dc.w	26	; N
	dc.w	28	; O
	dc.w	30	; P
	dc.w	32	; Q
	dc.w	34	; R
	dc.w	36	; S
	dc.w	38	; T
	dc.w	40	; U
	dc.w	42	; V
	dc.w	44	; W
	dc.w	46	; X
	dc.w	48	; Y
	dc.w	50	; Z
	dc.w	52	; [	= Ä
	dc.w	92	; \
	dc.w	54	; ]	= Ö
	dc.w	92	; ^
	dc.w	92	; _
	dc.w	92	; 
	; Written by Maverick !!!!

	;	Maverix taulukoiden teossa - no huh-huh!
	;		- Great J


	;	Ja kenenköhän takia? Kuka asetti fontit EI ascii
	;	järjestykseen? Ilmeisesti edellinen kommentoija...
	;		- Maverick the taulukoiden vihaaja

text:	
	dc.b	"    "
	DC.B	"AN ICOSAHEDRAL LINEVECTOR - NOPE, IT'S  T H E  "
	DC.B	"ICOSAHEDRAL LINEVECTOR...    ANYWAY, "
	DC.B	"IT'S CANNON FODDER, SO LET'S MOVE TO SOMETHING ELSE..."
	dc.b	"                                         "


	dc.b	0
	even


SetAngles:
	addq.w	#2,Xangle(a4)
	cmp.w	#720,Xangle(a4)
	blt.s	.jump1
	sub.w	#720,Xangle(a4)
.jump1:	addq.w	#4,Yangle(a4)
	cmp.w	#720,Yangle(a4)
	blt.s	.jump2
	sub.w	#720,Yangle(a4)
.jump2:	add.w	#6,Zangle(a4)
	cmp.w	#720,Zangle(a4)
	blt.s	.jump3
	sub.w	#720,Zangle(a4)
.jump3:
	rts				;-)

VisiblePlanes:
	move.l	ObjFace(a4),a0
	lea	FaceVisibleTable,a1	;	8-)	( <= it's my face...
	lea	TempCoordsTable,a2	;		     clearly visible...
	move.w	ObjFaceNo(a4),d7	;			- J'boy	)
.loop:
	move.w	(a0)+,d0
	move.w	0(a2,d0.w),d1
	move.w	2(a2,d0.w),d2
	move.w	(a0)+,d0
	move.w	0(a2,d0.w),d3
	move.w	2(a2,d0.w),d4
	move.w	(a0)+,d0
	move.w	0(a2,d0.w),d5
	move.w	2(a2,d0.w),d6
	sub.w	d1,d3
	sub.w	d1,d5
	sub.w	d2,d4
	sub.w	d2,d6
	muls	d3,d6
	muls	d4,d5
	sub.w	d6,d5
	move.w	d5,(a1)+
	dbf	d7,.loop
	rts

DrawSurfaces:
	WaitB
	move.w	#$8000,bltadat(a6)
	move.w	#$ffff,bltbdat(a6)
	move.l	#-1,bltafwm(a6)
	move.w	#40*2,bltcmod(a6)
	move.w	#40*2,bltdmod(a6)

	move.l	ObjConnect(a4),a1	; objectin tiedot
	lea	TempCoordsTable,a2		; lasketut xy
	lea	FaceVisibleTable,a3	; tasojen näkyvyys

	move.w	(a1)+,d7		; tasojen määrä
.loop1:	move.w	(a1)+,d6		; viivojen määrä tasossa
	move.w	(a1)+,a5		; väri
	cmp.w	#0,(a3)+		; piirretäänkö?
	bge.w	.DoNotDraw		; eipä ole näkyvissä
.loop2:
	move.l	Buffer(a4),a0
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	DrawLine_MinMax
	addq.l	#4,a1
	dbf	d6,.loop2
	bra.s	.jump1
.DoNotDraw:
	move.l	Buffer(a4),a0
	lea	40(a0),a0
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	DrawLine_MinMax

	addq.l	#4,a1
	dbf	d6,.DoNotDraw
.jump1:	dbf	d7,.loop1
	rts

FillScreen_Line:
	subq.w	#1,minY(a4)
	sub.w	#16,minX(a4)	; minX
	add.w	#16,maxX(a4)	; maxX
	
	move.w	maxX(a4),d1	; maxX
	lsr.w	#3,d1
	bclr	#0,d1		; parilliseksi
	move.w	d1,d4		; talteen
	move.w	minX(a4),d0	; minX
	lsr.w	#3,d0
	bclr	#0,d0		; parilliseksi
	sub.w	d0,d1		; koko d1
	move.w	#40,d3
	sub.w	d1,d3		; modulo d3
	
	move.w	maxY(a4),d2	; maxY
	sub.w	minY(a4),d2	; korkeus riveinä

;	asl.w	#2,d2		; korkeus*2 (planejen määrä)
	mulu	#3*64,d2
;	asl.w	#6,d2		; oikeisiin bitteihin

	asr.w	#1,d1
	or.w	d1,d2		; bltsize

	move.l	Buffer(a4),a0
	move.w	maxY(a4),d0	; maxY
	mulu	#40*3,d0
	ext.l	d4
	add.l	d0,a0
	add.l	d4,a0		; startaddress a0

	move.w	d3,modulo(a4)
	move.w	d2,blitsize(a4)
	move.w	minX(a4),d0	; minX
	lsr.l	#3,d0
	bclr	#0,d0		; parilliseksi
	ext.l	d0
	move.l	d0,xadd(a4)

	rts		;-)


***	DrawLine v1.0 by Great J of Red Chrome
***	Input:	d0=x1, d1=y1, d2=x2, d3=y2, a0=bitplane, a6=custom
***	Uses:	d4,d5
DrawLine_MinMax:
	cmp.w	d0,d2
	bhi.s	.Left2Right
	bne.s	.MakeLeft2Right
	cmp.w	d1,d3
	bne.s	.MakeLeft2Right
	rts
.MakeLeft2Right
	exg	d0,d2
	exg	d1,d3
.Left2Right

	;; d0 < d2
	cmp.w	minX(a4),d0
	bhi.s	.d0_not_MinX
	move.w	d0,minX(a4)
.d0_not_MinX
	cmp.w	maxX(a4),d2
	blo.s	.d2_not_MaxX
	move.w	d2,maxX(a4)
.d2_not_MaxX

	cmp.w	d1,d3
	bhi.s	.d1_smaller

	;; d1 > d3
	cmp.w	maxY(a4),d1
	blo.s	.d1_not_MaxY
	move.w	d1,maxY(a4)
.d1_not_MaxY

	cmp.w	minY(a4),d3
	bhi.s	.d3_not_MinY
	move.w	d3,minY(a4)
.d3_not_MinY
	bra.s	DrawLine_Left2Right

	;; d1 < d3
.d1_smaller
	cmp.w	minY(a4),d1
	bhi.s	.d1_not_MinY
	move.w	d1,minY(a4)
.d1_not_MinY

	cmp.w	maxY(a4),d3
	blo.s	DrawLine_Left2Right
	move.w	d3,maxY(a4)
	bra.s	DrawLine_Left2Right

DrawLine:
	cmp.w	d0,d2
	bhi.s	DrawLine_Left2Right
	bne.s	.MakeLeft2Right
	cmp.w	d1,d3
	bne.s	.MakeLeft2Right
	rts
.MakeLeft2Right
	exg	d0,d2
	exg	d1,d3

DrawLine_Left2Right:
	moveq	#0,d4
	sub.w	d0,d2		; DeltaX	(Left2Right => pakosta posit.)
	sub.w	d1,d3		; DeltaY
	bge.s	.Up2Down	; positiivinen => ylhäältä alas
	neg.w	d3		; negatiivinen => alhaalta ylös
	moveq	#2,d4		; oktantti alhaalta ylös -vaastaavaksi
.Up2Down
	cmp.w	d2,d3
	bge.s	.DeltaOk	; d2 = DeltaP, d3 = DeltaS
	exg	d2,d3
	addq.w	#1,d4		; oktantti kk:ta vastaavaksi ( nyt |kk| < 1 )
.DeltaOk
	add.w	d2,d2		; 2DeltaP

	mulu	#40*2,d1

;	move.w	d1,d5
;	lsl.w	#3,d1
;	lsl.w	#5,d5
;	add.w	d5,d1
;	ext.l	d1

	move.w	d0,d5
	asr.w	#3,d0
	add.w	d0,d1
	add.l	a0,d1		; d0 = viivan alkuosoite

	move.b	.octant(pc,d4.w),d4
	and.w	#$f,d5		; d5 = lähtöpikselin tarkka paikka (X)
	ror.w	#4,d5
	or.w	#$bea,d5	; mintermi & kanavat
	swap	d5
	move.w	d4,d5

	move.w	d3,d4
	lsl.w	#6,d4
	add.w	#$42,d4

	WaitB

	move.w	d2,bltbmod(a6)
	sub.w	d3,d2		; 2DeltaP - DeltaS
	bge.s	.SignBitOk
	or.w	#$40,d5		; Set Sign Bit
.SignBitOk
	move.w	d2,bltaptl(a6)
	sub.w	d3,d2		; (2DeltaP - DeltaS) - DeltaS =2(DeltaP-DeltaS)
	move.w	d2,bltamod(a6)
	move.l	d1,bltcpth(a6)
	move.l	d1,bltdpth(a6)
	move.l	d5,bltcon0(a6)
	move.w	d4,bltsize(a6)

	rts



;  Line Mode Bit -------+
;  1 Pixel / Line Bit -+|
;  3 Octant Bits ----+ ||
;                    | ||
.octant		;   OOOPL
	dc.b	%00000001	; 
	dc.b	%00010001	; 
	dc.b	%00000101	; 
	dc.b	%00011001	; 


;;; FUNNY (?) TEXT
Part_LoveKnowItAndFear:
	move.w	#%0000000000100000,intena(a6)

	lea	vbi_FunnyText(pc),a0
	move.l	a0,Exec_intvector_vbi(a5)
	lea	CopperList_FunnyText,a0
	move.l  a0,cop1lch(a6)

	move.w	#9,Joka(a4)
	move.w	#127,FadeValue(a4)
	move.l	#-44*28,FunnyPointer(a4)

	move.l	#plane1,d0
	moveq	#0,d1
	move.w	#64*44*1+40,d2
	bsr	ClearScreen

	move.w	#%1000000000100000,intena(a6)

	rts

vbi_FunnyText:
	movem.l	d0-d7/a0-a6,-(sp)

	lea	custom,a6
	lea	Bss_Stack,a4

	IF	RMOUSE_PAUSE = 1
	RightMouse
	beq.w	.rmpause
	ENDC

	cmp.w	#-1,flag(a4)
	bne.s	.hyppy

	move.w	#204,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#80-28,d3
	lea	FunnyText,a0
	add.l	#44*28*5,a0
	lea	plane1,a1
	move.w	#64*44*1+14,d6
	bsr	BlitBob


	lea	plane1,a0
	lea	Planes_FunnyText,a1
	moveq	#80,d0
	moveq	#1-1,d1
	bsr.w	SetPlanes

	addq.w	#1,timer(a4)
	cmp.w	#50*1,timer(a4)
	blo.s	.braend

	lea	CopColors_FunnyText,a0
	lea	Colors_FunnyText(pc),a1
	moveq	#5,d0
	moveq	#1,d7
	bsr	FadeOut

	tst.w	FadeValue(a4)
	bne.s	.braend
	move.w	#-1,quitflag(a4)


.braend
	bra	.end


.hyppy	addq.w	#1,Joka(a4)
	cmp.w	#10,Joka(a4)
	bne.s	.hiiop
	clr.w	Joka(a4)
	move.w	#$fff,c0(a6)
	add.l	#44*28,FunnyPointer(a4)
	cmp.l	#44*28*5,FunnyPointer(a4)
	bne.s	.hiiop
	clr.l	FunnyPointer(a4)
	addq.w	#1,counter(a4)
	cmp.w	#2,counter(a4)
	bne.s	.hiiop
	move.w	#-1,flag(a4)

.hiiop
	move.w	#208,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#80-28,d3
	lea	FunnyText,a0
	add.l	FunnyPointer(a4),a0
	lea	plane1,a1
	move.w	#64*44*1+14,d6
	bsr	BlitBob

	lea	plane1,a0
	lea	Planes_FunnyText,a1
	moveq	#80,d0
	moveq	#1-1,d1
	bsr.w	SetPlanes

.rmpause
.end
	move.w	#$20,intreq(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rte

*	d0 = x coordinate
*	d1 = y coordinate
*	d2 = A mod
*	d3 = D mod
*	a0 = bob
*	a1 = bitplanestart
*	d6 = blitsize
*	uses d4-d5 as work registers
*	Code by Maverick 141092

;	Jees, mulla ei ole tähän osaa eikä arpaa
;		- J'boy		(elikkäs Great J)

BlitBob:
	mulu	#1*80,d1
	move.w	d0,d4
	lsr.w	#3,d4
	add.w	d4,d1
	add.l	a1,d1		; bitplanepointer

	moveq	#$f,d4
	and.w	d0,d4
	ror.w	#4,d4
	move.w	d4,d5
	or.w	#$9f0,d4
	
	WaitB
	move.l	#-1,bltafwm(a6)
	move.w	d2,bltamod(a6)
	move.w	d3,bltdmod(a6)
	move.l	a0,bltapth(a6)
	move.l	d1,bltdpth(a6)
	move.w	d4,bltcon0(a6)
	move.w	#0,bltcon1(a6)
	move.w	d6,bltsize(a6)
	rts


;;; VERTEX MULTIPLANE
;;; ***	älä koske tai tulee turpiin!!!
Part_VertexMultiplane:
	move.w	#%0000000000100000,intena(a6)

	clr.w	timer(a4)

	clr.w	FadeValue(a4)

	clr.w	Xangle(a4)
	clr.w	Yangle(a4)
	clr.w	Zangle(a4)

	bsr	DefineObject_Vertex

	bsr	SetOrders_MLV

	move.w	#-2*20,anus_ptr(a4)

	clr.w	framepointer(a4)
	lea	vbi_Vertex(pc),a0
	move.l	VBR(a4),a5
	move.l	a0,Exec_intvector_vbi(a5)
	lea	CopperList_Vertex,a0
	move.l  a0,cop1lch(a6)

	move.w	#%1000000000100000,intena(a6)

	rts

vbi_Vertex:
	movem.l d0-a6,-(sp)

	lea	Bss_Stack,a4

	IF	RMOUSE_PAUSE = 1
	RightMouse
	beq.w	.rmpause
	ENDC

	lea	Planes_Vertex,a1
	bsr.w	SetPlanes_MLV

	move.l	planebuffer(a4),d0
	moveq	#0,d1
	move.w	#64*256+20,d2
	bsr	ClearScreen


	addq.w	#1,timer(a4)

.phase0	cmp.w	#50*2,timer(a4)
	bhi.s	.phase1

	lea	CopColors_Vertex,a0
	lea	Colors_Vertex(pc),a1
	moveq	#3,d0
	moveq	#16,d7
	bsr	FadeIn

	bra.w	.no_anus

.phase1	cmp.w	#50*2+360,timer(a4)
	bhi.w	.phase2

	addq.w	#2,Yangle(a4)
	cmp.w	#2*17,Yangle(a4)
	bhi.s	.5

	sub.w	#2*1,Zangle(a4)			; 0...5
	bra.s	.phase1end

.5	cmp.w	#2*24,Yangle(a4)
	bhi.s	.10

	sub.w	#2*3,Zangle(a4)			; 5...15
	bra.s	.phase1end

.10	cmp.w	#2*33,Yangle(a4)
	bhi.s	.20

	sub.w	#2*5,Zangle(a4)			; 15...35
	bra.s	.phase1end

.20	cmp.w	#2*360-2*33,Yangle(a4)
	bhi.s	.20b

	sub.w	#2*8,Zangle(a4)			; 35...360-35
	bra.s	.phase1end

.20b	cmp.w	#2*360-2*24,Yangle(a4)
	bhi.s	.l10

	sub.w	#2*5,Zangle(a4)			; 360-35...360-15
	bra.s	.phase1end

.l10	cmp.w	#2*360-2*17,Yangle(a4)
	bhi.s	.l5

	sub.w	#2*3,Zangle(a4)			; 360-15...360-5
	bra.s	.phase1end

.l5	cmp.w	#2*360,Yangle(a4)
	bhi.s	.phase1end

	sub.w	#2*1,Zangle(a4)			; 360-5...360
	bra.w	.phase1end


	;				mitäköhän fittiä nuo nrot tuolla
	;				laidalla meinaavat?
	;				ei aavistustakaan, vaikka ihan
	;				itse tämän 'hackin' naputtelinkin...
	;					- J'boy


.phase1end
	cmp.w	#2*360,Yangle(a4)
	blt.s	.Yok0
	sub.w	#2*360,Yangle(a4)
.Yok0
	cmp.w	#0,Zangle(a4)
	bge.s	.Zok1
	add.w	#2*360,Zangle(a4)
.Zok1
	bra.s	.endp

.phase2	cmp.w	#50*2+360+4*50,timer(a4)
	bhi.w	.phase3

;	move.w	#0,Zangle(a4)

	move.w	timer(a4),d0
	btst	#0,d0
	beq.s	.Xok1

	add.w	#2,Yangle(a4)
	cmp.w	#2*90,Yangle(a4)
	blt.s	.Yok1
	move.w	#2*90,Yangle(a4)
.Yok1

	add.w	#2,Xangle(a4)
	cmp.w	#2*90,Xangle(a4)
	blt.s	.Xok1
	move.w	#2*90,Xangle(a4)
.Xok1
	bra.s	.endp

.phase3	lea	CopColors_Vertex,a0
	lea	Colors_Vertex(pc),a1
	moveq	#1,d0
	moveq	#16,d7
	bsr	FadeOut

	sub.w	#50,Distance(a4)
	cmp.w	#-10000,Distance(a4)
	bgt.s	.endp
	move.w	#-10000,Distance(a4)

	move.w	#-1,quitflag(a4)

.endp	cmp.w	#50*6,timer(a4)
	bls.s	.no_anus

	lea	ObjCoords_Vertex+4,a0
	bsr	Do_Anus
.no_anus




	NastyOFF
	sub.l	a3,a3
	sub.l	a5,a5
	bsr	CalcVecPoints8
	NastyON
	bsr	mlv_piirraviivat

	move.l	planebuffer(a4),d0
	add.l	#40*256,d0
	move.w	#0,d1
	move.w	#64*256+20,d2

	bsr	Fill

	IF	RASTERTIME = 1
	move.w	#$005,c0+custom
	ENDC
.rmpause

	move.w	#$20,intreq+custom
	movem.l (sp)+,d0-a6
	rte




Do_Anus:
	lea	anus,a1
	add.w	anus_ptr(a4),a1
	move.w	ObjPointNo(a4),d7
.anus_loop
	move.w	(a1)+,(a0)
	addq.l	#6,a0
	dbf	d7,.anus_loop

	addq.w	#4,anus_ptr(a4)
	cmp.w	#198,anus_ptr(a4)
	ble.s	.ok1
	clr.w	anus_ptr(a4)
.ok1

	rts




mlv_piirraviivat:
	move.l	ObjConnect(a4),a2
	move.w	ObjLineNo(a4),d7
	WaitB
	move.l	planebuffer(a4),a0
	move.w	#$8000,bltadat(a6)
	move.w	#$ffff,bltbdat(a6)
	move.l	#-1,bltafwm(a6)
	move.w	#40,bltcmod(a6)
	move.w	#40,bltdmod(a6)
drawloop:
	lea	TempCoordsTable,a1
	add.w	(a2)+,a1
	move.w	(a1),d0
	move.w	2(a1),d1
	lea	TempCoordsTable,a1
	add.w	(a2)+,a1
	move.w	(a1),d2
	move.w	2(a1),d3
	bsr	drawline1
	dbf	d7,drawloop
	rts




;	filled
drawline1:
	cmp.w	d1,d3
	bhi.w	.next1
	exg	d0,d2
	exg	d1,d3
.next1:
	cmp.w	d3,d1
	bne.s	.next2
	rts
.next2:
	moveq	#0,d5
	move.w	d3,d4
	sub.w	d1,d4
	add.w	d4,d4
	sub.w	d0,d2
	bge.s	.x2gx1
	neg.w	d2
	addq.w	#2,d5
.x2gx1:	cmp.w	d4,d2
	blo.s	.allok
	subq.w	#1,d3
.allok:
	sub.w	d1,d3
	mulu	#40,d1
	move.w	d0,d4
	asr.w	#3,d4
	add.w	d4,d1
	add.l	a0,d1

	move.w	d3,d4
	sub.w	d2,d4
	bge.s	.dygdx
	exg	d2,d3
	addq.w	#1,d5
.dygdx:
	move.b	.oktantit(pc,d5),d5
	add.w	d2,d2
	and.w	#$000f,d0
	ror.w	#4,d0
	or.w	#%0000101101011010,d0

	WaitB

	move.w	d2,bltbmod(a6)
	sub.w	d3,d2
	bge.s	.signnl
	or.b	#%01000000,d5
.signnl:
	move.w	d2,bltaptl(a6)
	sub.w	d3,d2
	move.w	d2,bltamod(a6)
	move.w	d0,bltcon0(a6)
	move.w	d5,bltcon1(a6)
	move.l	d1,bltcpth(a6)
	move.l	d1,bltdpth(a6)
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,bltsize(a6)
	rts

.oktantit:
	dc.b 0+3
	dc.b 16+3
	dc.b 8+3
	dc.b 20+3



DefineObject_Vertex:
	move.l	#ObjCoords_Vertex,ObjCoords(a4)
	move.l	#ObjConnect_Vertex,ObjConnect(a4)

	move.w	#50-1,ObjLineNo(a4)
	move.w	#50-1,ObjPointNo(a4)
	move.w	#-2000,Distance(a4)
	rts


;;; VECTORGRID WITH MORPH TO A MUNUAINEN
Part_VectorGridMunuainen:
	move.w	#%0000000000100000,intena(a6)

	move.w	#0,FadeValue(a4)

	bsr	SetOrders_MLV
	bsr	DefineObject_Grid

	lea	plane1,a0
	move.l	a0,d0
	moveq	#0,d1
	move.w	#64*255*4+20,d2
	bsr	ClearScreen

	lea	vbi_Grid(pc),a0
	move.l	VBR(a4),a5
	move.l	a0,Exec_intvector_vbi(a5)
	lea	CopperList_Grid,a0
	move.l  a0,cop1lch(a6)
	clr.w	timer(a4)

	move.w	#%1000000000100000,intena(a6)

	rts

vbi_Grid:
	movem.l d0-a6,-(sp)
	lea	Bss_Stack,a4

	IF	RMOUSE_PAUSE = 1
	RightMouse
	beq.w	.rmpause
	ENDC

	lea	Planes_Grid,a1
	bsr.w	SetPlanes_MLV

	move.l	planebuffer(a4),d0
	moveq	#0,d1
	move.w	#64*256+20,d2
	bsr	ClearScreen

	bsr	SetAngles_Grid

	NastyOFF
	sub.l	a3,a3
	sub.l	a5,a5
	bsr	CalcVecPoints8
	NastyON

	bsr	DrawVectors_Grid

	addq.w	#1,timer(a4)
	cmp.w	#50*9,timer(a4)
	bgt.s	.new_form
	beq.s	.set_new

	lea	CopColors_Grid,a0
	lea	Colors_Grid(pc),a1
	moveq	#15,d0
	moveq	#16,d7
	bsr	FadeIn

	cmp.w	#50*2,timer(a4)
	blo.s	.lnro_ok

	move.w	timer(a4),d0
	btst	#0,d0
	beq.s	.lnro_ok

	addq.w	#1,ObjLineNo(a4)
	cmp.w	#84-1,ObjLineNo(a4)
	bls.s	.lnro_ok

	move.w	#84-1,ObjLineNo(a4)

.lnro_ok
	lea	ObjCoords_Grid+4,a0
	bsr	Do_Anus
	bra.s	.end

.set_new
	move.l	#ObjCoords_Morph,ObjCoords(a4)
.new_form
	bsr	Morph_Grid2Ball

	cmp.w	#50*14,timer(a4)
	blt.s	.end

	lea	CopColors_Grid,a0
	lea	Colors_Grid(pc),a1
	moveq	#1,d0
	moveq	#16,d7
	bsr	FadeOut
	sub.w	#40,Distance(a4)
	cmp.w	#-7000,Distance(a4)
	bgt.s	.end
	move.w	#-7000,Distance(a4)

	move.w	#-1,quitflag(a4)
.end

	IF	RASTERTIME	= 1
	move.w	#$005,c0+custom
	ENDC
.rmpause

	move.w	#$20,intreq+custom
	movem.l (sp)+,d0-a6
	rte




***	set planes & plane buffer	(tarttee a1:een coplist-osoitteen)

	;	(ripperin) Onni On - Pätkä Kommentoitua Sorsaa
	;		- J'boy

	;	Jack the Ripperin unelma - Pätkä tuoretta Suolta
	; 	 ( Maverick after watching Bad Taste )


	;	Rippers are sort of Cannibals in the Race of Coders.
	;		- Great J

	;	Progress. Is it progress cannibal using fork and knive?
	;		- Maverick after a very good dinner

	;	Coplist? A weird name for a woman. Can I have the telephone-
	;	number too? 
	;		- Maverick
	
	;	Taitaa naikkosessa olla dekkariainesta, nimestä päätellen...
	;		- J

	;	Ja valitettavasti poikakaverin nimi taitaa olla Dick Tracy...
	;	Chekkaa muutama osio eteenpäin.
	;		- Ö
	

SetPlanes_MLV:
	lea	ActiveOrder_MLV,a0

	cmp.w	#5-1,framepointer(a4)		; viisi framea (4+1)
	bls.s	.frame_ok
	clr.w	framepointer(a4)
.frame_ok

	moveq	#4*4,d0				; 4 activea / frame (long)
	mulu	framepointer(a4),d0		; monesko frame
	add.w	d0,a0				; lisätään taulukkopointteriin
	moveq	#2,d1

	moveq	#4-1,d7				; asetetaan 4 planea

.loop	move.w	(a0)+,(a1,d1.w)			; asetetaan copperilistan
	addq.w	#4,d1				; bpl-pointerit
	move.w	(a0)+,(a1,d1.w)			; ylempi ja alempi word
	addq.w	#4,d1

	dbf	d7,.loop

	moveq	#4,d0				; 1 active / frame (long)
	mulu	framepointer(a4),d0		; monesko frame

	lea	BufferOrder_MLV,a0		; taulukkopointteri
	move.l	(a0,d0.w),planebuffer(a4)	; asetetaan planebuffer

	addq.w	#1,framepointer(a4)
	rts



Morph_Grid2Ball:		; oikeammin Grid 2 Munuainen
	lea	ObjCoords_Grid,a0
	lea	ObjCoords_Ball,a1
	lea	ObjCoords_Morph,a2

	move.w	MorphValue(a4),d2

	addq.w	#1,MorphValue(a4)
	cmp.w	#63,MorphValue(a4)
	bgt.s	.end
	blt.s	.still_morphing

	move.w	#64,MorphValue(a4)
	move.l	#ObjConnect_Ball,ObjConnect(a4)
	move.w	#84-6-1,ObjLineNo(a4)
	bra.s	.end

.still_morphing

	move.w	#49*3-1,d7
.loop
	move.w	(a0)+,d0		; source
	move.w	(a1)+,d1		; dest
	sub.w	d0,d1			; delta
	muls	d2,d1
	asr.l	#6,d1
	add.w	d0,d1
	move.w	d1,(a2)+		; temp for use (25 degrees for Finnish)

	dbf	d7,.loop

.end	rts


***	change the angles	; I saw an angel one day. He was trying to
				; hitchike back to heaven..
				;	- Maverick

				; It must have been my Guardian Angel...
				;	- J'boy

				; Yours left you too? Mine went back to heaven
				; after I got my driver's license...
				;	- Maverick "It's an easy bend"


SetAngles_Grid:

	addq.w	#4,Xangle(a4)
	cmp.w	#720,Xangle(a4)
	blt.s	.Xok
	sub.w	#720,Xangle(a4)
.Xok
	addq.w	#4,Yangle(a4)
	cmp.w	#720,Yangle(a4)
	blt.s	.Yok
	sub.w	#720,Yangle(a4)

.Yok	addq.w	#2,Zangle(a4)
	cmp.w	#720,Zangle(a4)
	blt.s	.Zok
	sub.w	#720,Zangle(a4)
.Zok

	rts


***	draw vectors to buffer

DrawVectors_Grid:
	move.l	planebuffer(a4),a0
	lea	TempCoordsTable,a1
	move.l	ObjConnect(a4),a2
	move.w	ObjLineNo(a4),d7
		WaitB			; the new style of coding
	move.w	#$8000,bltadat(a6)
	move.w	#$ffff,bltbdat(a6)
	move.l	#-1,bltafwm(a6)
	move.w	#40,bltcmod(a6)
	move.w	#40,bltdmod(a6)
.drawloop
	move.w	(a2)+,d6
	move.w	(a1,d6.w),d0
	move.w	2(a1,d6.w),d1
	move.w	(a2)+,d6
	move.w	(a1,d6.w),d2
	move.w	2(a1,d6.w),d3
	bsr	drawline_Grid
	dbf	d7,.drawloop
	rts


***	DrawLine v1.0 by Great J of Red Chrome
***	Input:	d0=x1, d1=y1, d2=x2, d3=y2, a0=bitplane, a6=custom
***	Uses:	d4,d5

drawline_Grid:
	cmp.w	d0,d2
	bhi.s	.Left2Right
	bne.s	.MakeLeft2Right
	cmp.w	d1,d3
	beq.s	.end
.MakeLeft2Right
	exg	d0,d2
	exg	d1,d3
.Left2Right
	moveq	#0,d4
	sub.w	d0,d2		; DeltaX	(Left2Right => pakosta posit.)
	sub.w	d1,d3		; DeltaY
	bge.s	.Up2Down	; positiivinen => ylhäältä alas
	neg.w	d3		; negatiivinen => alhaalta ylös
	moveq	#2,d4		; oktantti alhaalta ylös -vaastaavaksi
.Up2Down
	cmp.w	d2,d3
	bge.s	.DeltaOk	; d2 = DeltaP, d3 = DeltaS
	exg	d2,d3
	addq.w	#1,d4		; oktantti kk:ta vastaavaksi ( nyt |kk| < 1 )
.DeltaOk
	add.w	d2,d2		; 2DeltaP

;	mulu	#40,d1

	move.w	d1,d5
	lsl.w	#3,d1
	lsl.w	#5,d5
	add.w	d5,d1
	ext.l	d1

	move.w	d0,d5
	asr.w	#3,d0
	add.w	d0,d1
	add.l	a0,d1		; d0 = viivan alkuosoite

	move.b	.octant(pc,d4.w),d4
	and.w	#$f,d5		; d5 = lähtöpikselin tarkka paikka (X)
	ror.w	#4,d5
	or.w	#$bea,d5	; mintermi & kanavat
	swap	d5
	move.w	d4,d5

	move.w	d3,d4
	lsl.w	#6,d4
	add.w	#$42,d4

	WaitB

	move.w	d2,bltbmod(a6)
	sub.w	d3,d2		; 2DeltaP - DeltaS
	bge.s	.SignBitOk
	or.w	#$40,d5		; Set Sign Bit
.SignBitOk
	move.w	d2,bltaptl(a6)
	sub.w	d3,d2		; (2DeltaP - DeltaS) - DeltaS =2(DeltaP-DeltaS)
	move.w	d2,bltamod(a6)
	move.l	d1,bltcpth(a6)
	move.l	d1,bltdpth(a6)
	move.l	d5,bltcon0(a6)
	move.w	d4,bltsize(a6)

.end	rts



;  Line Mode Bit -------+
;  1 Pixel / Line Bit -+|
;  3 Octant Bits ----+ ||
;                    | ||
.octant		;   OOOPL
	dc.b	%00000001	; 
	dc.b	%00010001	; 
	dc.b	%00000101	; 
	dc.b	%00011001	; 


***	set the orders for actives and buffer
***	'väännä se rautalangasta' tyyliä käytti menestyksellisesti J'boy


	;	I use macro assembler instead.
	;		- Maverick "I'm not very good of this, could you do
	;			it for me?"

SetOrders_MLV:
	lea	BufferOrder_MLV,a0

	lea	mlv_plane5,a1		; buffer order, frames 1 to 8
	move.l	a1,(a0)+
	move.l	a1,planebuffer(a4)
	lea	mlv_plane4,a1
	move.l	a1,(a0)+
	lea	mlv_plane3,a1
	move.l	a1,(a0)+
	lea	mlv_plane2,a1
	move.l	a1,(a0)+
	lea	mlv_plane1,a1
	move.l	a1,(a0)+

	lea	ActiveOrder_MLV,a0

	lea	mlv_plane4,a1		; active order, 5
	move.l	a1,(a0)+
	lea	mlv_plane3,a1
	move.l	a1,(a0)+
	lea	mlv_plane2,a1
	move.l	a1,(a0)+
	lea	mlv_plane1,a1
	move.l	a1,(a0)+

	lea	mlv_plane3,a1		; active order, 4
	move.l	a1,(a0)+
	lea	mlv_plane2,a1
	move.l	a1,(a0)+
	lea	mlv_plane1,a1
	move.l	a1,(a0)+
	lea	mlv_plane5,a1
	move.l	a1,(a0)+

	lea	mlv_plane2,a1		; active order, 3
	move.l	a1,(a0)+
	lea	mlv_plane1,a1
	move.l	a1,(a0)+
	lea	mlv_plane5,a1
	move.l	a1,(a0)+
	lea	mlv_plane4,a1
	move.l	a1,(a0)+

	lea	mlv_plane1,a1		; active order, 2
	move.l	a1,(a0)+
	lea	mlv_plane5,a1
	move.l	a1,(a0)+
	lea	mlv_plane4,a1
	move.l	a1,(a0)+
	lea	mlv_plane3,a1
	move.l	a1,(a0)+

	lea	mlv_plane5,a1		; active order, 1
	move.l	a1,(a0)+
	lea	mlv_plane4,a1
	move.l	a1,(a0)+
	lea	mlv_plane3,a1
	move.l	a1,(a0)+
	lea	mlv_plane2,a1
	move.l	a1,(a0)

	rts

***	define the grid-object

	; behind the bars

DefineObject_Grid:
	move.l	#ObjCoords_Grid,ObjCoords(a4)
	move.l	#ObjConnect_Grid,ObjConnect(a4)

	move.w	#49-1,ObjPointNo(a4)
	move.w	#1-1,ObjLineNo(a4)
	move.w	#-1200,Distance(a4)
	rts


;;; FIELD OF DOTS
Part_FieldOfDots:
	move.w	#%0000000000100000,intena(a6)

	bsr	CreateObject

	lea	bpl1,a0
	move.l	a0,Active(a4)

	lea	bpl2,a0
	move.l	a0,Buffer(a4)
	move.l	a0,d0
	moveq	#20,d1
	move.w	#64*270*2+22,d2
	bsr	ClearScreen

	lea	bpl3,a0
	move.l	a0,clearbuffer(a4)
	move.l	a0,d0
	moveq	#20,d1
	move.w	#64*270*2+22,d2
	bsr	ClearScreen

	move.w	#2000,Distance(a4)
	move.w	#CLOSER,flag(a4)

	clr.w	Yangle(a4)

	clr.w	timer(a4)
	clr.w	FadeValue(a4)

	lea	vbi_Field(pc),a0
	move.l	VBR(a4),a5
	move.l	a0,Exec_intvector_vbi(a5)
	lea	CopperList_Field,a0
	move.l  a0,cop1lch(a6)

	move.w	#%1000000000100000,intena(a6)

	rts

QUIT	= -1
STAY	= 1
CLOSER	= 2
FARTHER	= 3


vbi_Field:
	movem.l d0-a6,-(sp)

	lea	Bss_Stack,a4
	lea	custom,a6

	IF	RMOUSE_PAUSE = 1
	RightMouse
	beq.w	.rmpause
	ENDC

	bsr.w	RotateBuffers_Field

	move.l	clearbuffer(a4),d0
	moveq	#20,d1
	move.w	#64*270*2+22,d2
	bsr	ClearScreen

	bsr	StarField

	cmp.w	#STAY,flag(a4)
	bne.s	.nope1

	addq.w	#1,timer(a4)
	cmp.w	#7*50,timer(a4)
	bls.s	.end
	move.w	#FARTHER,flag(a4)

.nope1	cmp.w	#CLOSER,flag(a4)
	bne.s	.nope2

	lea	CopColors_Field,a0
	lea	Colors_Field(pc),a1
	moveq	#1,d0
	moveq	#3,d7
	bsr	FadeIn

	sub.w	#10,Distance(a4)
	cmp.w	#75,Distance(a4)
	bhi.s	.nope2
	move.w	#75,Distance(a4)
	move.w	#STAY,flag(a4)

.nope2	cmp.w	#FARTHER,flag(a4)
	bne.s	.end

	lea	CopColors_Field,a0
	lea	Colors_Field(pc),a1
	moveq	#2,d0
	moveq	#3,d7
	bsr	FadeOut

	add.w	#10,Distance(a4)
	cmp.w	#1750,Distance(a4)
	bls.s	.end
	move.w	#QUIT,flag(a4)
	move.w	#-1,quitflag(a4)
.end

	IF	RASTERTIME = 1
	move.w	#$005,c0+custom
	ENDC
.rmpause

.loppu	move.w	#$20,intreq+custom
	movem.l (sp)+,d0-d7/a0-a6
	rte


	;	I want my Star Trek!!!!!!!!!!!!
	;		- Maverick


	;	MyGodItWasNotMyDadWhoTapedSomeA-StudioOverIt!!!!
	;	... Or are you talking about the TV-series...?
	;		- Great J the Son of A-Studio Freak

	;	I am talking about the TV-series... By the way, it was
	;	your Dad who taped some A-Studio over my Memphis Belle!
	;		- Mr. Spock


***************************************************************************
***	Star Field - Next Generation v1.2				***
***	A 3D Field of Dots in 2BPL Rotated Around Y-Axis		***
***	in February 1993 by GREAT J of RED CHROME			***
***									***
***	Currently maximum amount of dots is about 150			***
***************************************************************************


WIDTH	= 12		; koko pisteinä, leveys*pituus
HEIGHT	= 12		;  (ok, ok! on siinä 'height' - en jaksa muuttaa...)
_XSTART	= -55		; aloitusnurkan koordinaatit
_YSTART	= -55
_XADD	= 10		; pisteiden välit
_YADD	= 10
XVAIHE	= 12		; vaihe-erot, huom! parilliset!
YVAIHE	= 16
YASTE	= 3		; pyöritysnopeus asteina
SPEED	= 2		; wave-nopeus


*****	tehdään objekti taulukkoon annettujen tietojen perusteella

CreateObject:
	lea	xval,a0
	lea	zval,a1

	move.w	#HEIGHT-1,d7
	move.w	#_YSTART,d4
.cols
	move.w	#WIDTH-1,d6
	move.w	#_XSTART,d5
.rows
	move.w	d5,(a0)+
	add.w	#_XADD,d5

	move.w	d4,(a1)+

	dbf	d6,.rows

	add.w	#_YADD,d4

	dbf	d7,.cols

	rts


*****	päärutiini, piirretään ja lasketaan pisteet

StarField:

*****	lasketaan kulman sini- ja cosinikertoimet valmiiksi

	lea	SinTable(pc),a0
	lea	CosTable(pc),a1

	move.w	Yangle(a4),d0

	move.w	(a0,d0.w),Ysin(a4)	; sin Y
	move.w	(a1,d0.w),Ycos(a4)		; cos Y


*****	varsinainen piirtolooppi alkaa

	move.w	Distance(a4),a5
	move.w	a5,a6
	add.w	#15,a5
	add.w	#30,a6

	move.l	Buffer(a4),a3

	lea	xval,a0
	lea	yval,a1
	lea	zval,a2

	add.l	aloitus(a4),a1

	moveq	#10,d6

	move.w	#WIDTH-1,d7
.xloop
	swap	d7
	move.w	#HEIGHT-1,d7
.zloop
	move.w	(a0)+,d0
	move.w	(a2)+,d2
	move.w	(a1),d1

	add.w	#XVAIHE,a1


	move.w	d0,d4
	muls	Ycos(a4),d0
	move.w	d2,d5
	muls	Ycos(a4),d2

	muls	Ysin(a4),d5
	add.l	d5,d0

	muls	Ysin(a4),d4
	sub.l	d4,d2

	asr.l	d6,d2

	add.w	a5,d2

;	asr.l	#5,d0
;	asr.l	#5,d0

;	asl.l	#7,d0

	asr.l	#3,d0
	divs	d2,d0

	add.w	#180+20*8,d0
	cmp.w	#20*8,d0
	blo.s	.out

	cmp.w	#24*8+320,d0
	bhi.s	.out

	asl.w	#7,d1
	ext.l	d1
	divs	d2,d1

	add.w	#127,d1
	bmi.s	.out

	cmp.w	#256,d1
	bhi.s	.out

	lsl.w	#7,d1

	move.b	d0,d3

	lsr.w	#3,d0
	sub.w	d0,d1

	cmp.w	Distance(a4),d2
	ble.s	.close

	bset	d3,(a3,d1.w)
	sub.w	#128,d1
	bset	d3,(a3,d1.w)

	cmp.w	a6,d2
	ble.s	.med

.close	bset	d3,64(a3,d1.w)
	bset	d3,-64(a3,d1.w)
.med
.out
	dbf	d7,.zloop

	sub.l	#HEIGHT*XVAIHE-YVAIHE,a1

	swap	d7

	dbf	d7,.xloop


*****	muutokset kulmaan ja taulukon aloituskohtaan

	IF	YASTE > 0
	add.w	#2*YASTE,Yangle(a4)
	cmp.w	#360*2,Yangle(a4)
	blo.s	.yok
	move.w	#0,Yangle(a4)
.yok
	ENDC

	IF	SPEED > 0
	addq.l	#2*SPEED,aloitus(a4)
	cmp.l	#2*200,aloitus(a4)
	blo.s	.ok1
	move.l	#0,aloitus(a4)
.ok1
	ENDC

	rts


RotateBuffers_Field:
	move.l	Buffer(a4),d0
	move.l	clearbuffer(a4),d1
	move.l	Active(a4),d2

	move.l	d0,Active(a4)
	move.l	d2,clearbuffer(a4)
	move.l	d1,Buffer(a4)

	lea	Planes_Field,a1

	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#64,d0
	
	move.w	d0,14(a1)
	swap	d0
	move.w	d0,10(a1)

	rts


	;	I love this part! It looks like shit, it's coded like shit and
	;	it is definitely pure shit. And it was me who invented the
	;	idea of adding that "It looks like it's calculating realtime"
	;	part. Hopefully no-one ever finds out the truth....
	;		- Maverick "The plasma freak"

	;	C'mon! You wanted some plasma and I made some plasma!
	;	It's just as simple as that! And no - and I mean it NO
	;	OTHER plasma effect runs in less than five rasterlines.
	;	In fact, that your "It looks like it's calculating realtime"
	;	-effect takes almost as much time as the effect itself!
	;		- Great J "the Real 'Do It Yourself' Plasma Creator"


	;	Yeah, you are absolutely right! No other plasma looks as much
	;	fake memory-picture plasma as yours does!
	;		- Maverick "I love Jani's fake plasmas"

	;	However, the rastertime - outlook ratio is absolutely
	;	unbeatable!
	;		- J


;;; 5BPL FAKED MEMORYPICTURE COLORSCOLL PLASMA EFFECT IN 5 RASTERLINES
Part_FakePlasma:
	move.w	#%0000000000100000,intena(a6)

	lea	vbi_Plasma(pc),a0
	move.l	a0,Exec_intvector_vbi(a5)
	lea	CopperList_Plasma,a0
	move.l  a0,cop1lch(a6)

	clr.w	timer(a4)
	move.w	#$7f,FadeValue(a4)

	lea	plasma,a0
	lea	Planes_Plasma,a1
	moveq	#40,d0
	moveq	#5-1,d1
	bsr	SetPlanes

	move.w	#%1000000000100000,intena(a6)

	rts

vbi_Plasma:
	movem.l d0-a6,-(sp)

	lea	Bss_Stack,a4
	lea	custom,a6

	IF	RMOUSE_PAUSE = 1
	RightMouse
	beq.w	.rmpause
	ENDC

	addq.w	#1,timer(a4)

	lea	CopColors_Plasma,a0
	lea	Colors_Plasma,a1
	moveq	#4,d0
	moveq	#31,d7

	cmp.w	#14*50,timer(a4)
	bhi.s	.fade_away

	bsr	FadeSet
	bra.w	.over

.fade_away
	bsr	FadeOut
	tst.w	FadeValue(a4)
	bne.s	.over
	move.w	#-1,quitflag(a4)
.over

	move.w	timer(a4),d0
	btst	#0,d0
	bne.s	.end
	
	bsr	CycleColors

	add.w	#$100,wait_Plasma
	cmp.w	#$d511,wait_Plasma
	bne.s	.end
	sub.w	#$100,wait_Plasma

.rmpause
.end	move.w	#$20,intreq(a6)
	movem.l (sp)+,d0-a6
	rte


; Simple (=Dumb, but FAAAST) Cycle Routine v0.02
; December 25th 1992 by Great J of Red Chrome

; Huomasitko? Täysin feikki-efekti ja on ihan kivan näköinen!

; Huomasitko? Täysin vakavalla naamalla noinkin suurin vale!
;	- M

; No voi saatana! Revi se sitten mäkeen!
;	- Arvaa kenen kommentti

; No way! The simple and dump routines are the greatest!

CycleColors:
	lea	Colors_Plasma,a0
	move.w	(a0),d0

	move.w	2(a0),(a0)
	move.w	4(a0),2(a0)
	move.w	6(a0),4(a0)
	move.w	8(a0),6(a0)
	move.w	10(a0),8(a0)
	move.w	12(a0),10(a0)
	move.w	14(a0),12(a0)
	move.w	16(a0),14(a0)
	move.w	18(a0),16(a0)
	move.w	20(a0),18(a0)
	move.w	22(a0),20(a0)
	move.w	24(a0),22(a0)
	move.w	26(a0),24(a0)
	move.w	28(a0),26(a0)
	move.w	30(a0),28(a0)
	move.w	32(a0),30(a0)
	move.w	34(a0),32(a0)
	move.w	36(a0),34(a0)
	move.w	38(a0),36(a0)
	move.w	40(a0),38(a0)
	move.w	42(a0),40(a0)
	move.w	44(a0),42(a0)
	move.w	46(a0),44(a0)
	move.w	48(a0),46(a0)
	move.w	50(a0),48(a0)
	move.w	52(a0),50(a0)
	move.w	54(a0),52(a0)
	move.w	56(a0),54(a0)
	move.w	58(a0),56(a0)
	move.w	60(a0),58(a0)
	move.w	d0,60(a0)

	rts


;;; FILLED VECTOR ICOS & WILLESBALL
;;; Willesball is dedicated to our good friend, Wille Wahe
Part_WillesBall:
	move.w	#%0000000000100000,intena(a6)

	bsr.w	DefineObject_FillIcos

	clr.w	minYOLD(a4)
	clr.w	xaddOLD(a4)
	clr.w	moduloOLD(a4)
	move.w	#256*3*64+20,blitsizeOLD(a4)

	clr.w	minY(a4)
	clr.w	xadd(a4)
	clr.w	modulo(a4)
	move.w	#256*3*64+20,blitsize(a4)

	lea	plane1,a0
	move.l	a0,Active(a4)
	lea	plane2,a0
	move.l	a0,Buffer(a4)

	lea	vbi_FillIcos(pc),a0
	move.l	VBR(a4),a5
	move.l	a0,Exec_intvector_vbi(a5)
	lea	CopperList_FillIcos,a0
	move.l  a0,cop1lch(a6)
	clr.w	Zangle(a4)
	clr.w	Yangle(a4)
	clr.w	Xangle(a4)
	clr.w	timer(a4)

	move.w	#%1000000000100000,intena(a6)

	rts

vbi_FillIcos:
	movem.l d0-d7/a0-a6,-(sp)

	lea	Bss_Stack,a4
	lea	custom,a6
	
	IF	RMOUSE_PAUSE = 1
	RightMouse
	beq.w	.rmpause
	ENDC

	NastyOFF		; more cycles to the CPU

	bsr.w	SwapBuffers	; tuplapuskurointi

	move.l	Active(a4),a0
	lea	Planes_FillIcos,a1
	moveq	#40,d0
	moveq	#3-1,d1
	bsr.w	SetPlanes

	move.l	Buffer(a4),d0
	moveq	#0,d1
	move.w	minYOLD(a4),d1
	mulu	#40*3,d1
	add.l	d1,d0
	add.l	xaddOLD(a4),d0
	move.w	moduloOLD(a4),d1
	move.w	blitsizeOLD(a4),d2
	bsr	ClearScreen

	move.w	minY(a4),minYOLD(a4)
	move.l	xadd(a4),xaddOLD(a4)
	move.w	modulo(a4),moduloOLD(a4)
	move.w	blitsize(a4),blitsizeOLD(a4)

	bsr.w	SetAngles_FillIcos

	move.w	#255,minY(a4)
	clr.w	maxY(a4)
	move.w	#320,minX(a4)
	clr.w	maxX(a4)


	addq.w	#1,timer(a4)

	cmp.w	#50*4+25,timer(a4)
	bls.s	.fade_in

	cmp.w	#50*6,timer(a4)
	bhi.s	.cont

	cmp.w	#50*5,timer(a4)
	bhi.s	.in

	lea	CopColors_FillIcos,a0
	lea	Colors_FillIcos(pc),a1
	moveq	#7,d0
	moveq	#7,d7
	bsr	FlashOut
	
	bra.w	.cont
.in

	lea	CopColors_FillIcos,a0
	lea	Colors_FillIcos(pc),a1
	moveq	#7,d0
	moveq	#7,d7
	bsr	FlashIn
	bra	.cont

.fade_in
	lea	CopColors_FillIcos,a0
	lea	Colors_FillIcos(pc),a1
	moveq	#3,d0
	moveq	#7,d7
	bsr	FadeIn

.cont

	move.w	x_sin_pointer(a4),d0
	lea	x_sine(pc),a3
	move.w	(a3,d0.w),d0
	cmp.w	#$1234,d0
	bne.s	.ok1
	moveq.l	#0,d0
	clr.w	x_sin_pointer(a4)
.ok1
	move.w	d0,a3

	move.w	y_sin_pointer(a4),d0
	lea	y_sine(pc),a5
	move.w	(a5,d0.w),d0
	cmp.w	#$1234,d0
	bne.s	.ok2
	moveq.l	#0,d0
	clr.w	y_sin_pointer(a4)
.ok2
	move.w	d0,a5

	addq.w	#2,x_sin_pointer(a4)
	addq.w	#2,y_sin_pointer(a4)


	cmp.w	#50*5,timer(a4)
	beq.s	.set_new
	bhi.s	.new

	bsr.w	CalcVecPoints
	bsr.w	VisiblePlanes_FillIcos

	NastyON

	bsr	DrawSurfaces_FillIcos

	bra.s	.end

.set_new
	bsr	DefineObject_Wille
.new
	bsr.w	CalcVecPoints_Wille
	bsr.w	VisiblePlanes_Wille

	NastyON
	bsr	DrawSurfaces_FWille

.end

	bsr.w	FillScreen_3bpl
	WaitB


	cmp.w	#16*50,timer(a4)
	bls.s	.not_yet_quit

	lea	CopColors_FillIcos,a0
	lea	Colors_FillIcos(pc),a1
	moveq	#3,d0
	moveq	#7,d7
	bsr	FadeOut

	cmp.w	#0,FadeValue(a4)
	bne.s	.not_yet_quit
	move.w	#-1,quitflag(a4)

.not_yet_quit



	add.w	#100,Distance(a4)
	cmp.w	#-1100,Distance(a4)
	blt.s	.yli2
	move.w	#-1100,Distance(a4)
.yli2
	
	IF	RASTERTIME = 1
	move.w	#$005,c0(a6)	; Ehdotus. Lisätään yhden framen kesto
				; 2/50 sekuntiin. Näin me kaikki koodarit
				; saamme hienompia demoja aikaiseksi ja
				; ne pyörivät edelleen yhdessä framessa...
	ENDC
.rmpause

	move.w	#$20,intreq(a6)
	movem.l (sp)+,d0-d7/a0-a6
	rte



DefineObject_FillIcos:
	move.w	#12-1,ObjPointNo(a4)
	move.w	#20-1,ObjFaceNo(a4)
	move.l	#ObjCoords_FillIcos,ObjCoords(a4)
	move.l	#ObjFaceV_FillIcos,ObjFace(a4)
	move.l	#ObjFaceS_FillIcos,ObjConnect(a4)
	move.w	#-6000,Distance(a4)
	rts


DefineObject_FWille:
	move.l	#ObjFaceV_FWille,ObjFace(a4)
	move.l	#ObjFaceS_FWille,ObjConnect(a4)
	rts



SetAngles_FillIcos:
	addq.w	#2,Xangle(a4)
	cmp.w	#720,Xangle(a4)
	blt.s	.jump1
	sub.w	#720,Xangle(a4)
.jump1:	addq.w	#4,Yangle(a4)
	cmp.w	#720,Yangle(a4)
	blt.s	.jump2
	sub.w	#720,Yangle(a4)
.jump2:	addq.w	#6,Zangle(a4)
	cmp.w	#720,Zangle(a4)
	blt.s	.jump3
	sub.w	#720,Zangle(a4)
.jump3:
	rts				;-)


VisiblePlanes_FillIcos:
	move.l	ObjFace(a4),a0
	lea	FaceVisibleTable,a1
	lea	TempCoordsTable,a2
	move.w	ObjFaceNo(a4),d7
.loop:
	move.w	(a0)+,d0
	move.w	0(a2,d0.w),d1
	move.w	2(a2,d0.w),d2
	move.w	(a0)+,d0
	move.w	0(a2,d0.w),d3
	move.w	2(a2,d0.w),d4
	move.w	(a0)+,d0
	move.w	0(a2,d0.w),d5
	move.w	2(a2,d0.w),d6
	sub.w	d1,d3
	sub.w	d1,d5
	sub.w	d2,d4
	sub.w	d2,d6
	muls	d3,d6
	muls	d4,d5
	sub.w	d6,d5
	move.w	d5,(a1)+
	dbf	d7,.loop
	rts


DrawSurfaces_FWille:
	WaitB
	move.w	#$8000,bltadat(a6)
	move.w	#$ffff,bltbdat(a6)
	move.l	#-1,bltafwm(a6)
	move.w	#40*3,bltcmod(a6)
	move.w	#40*3,bltdmod(a6)

	move.l	ObjConnect(a4),a1	; objectin tiedot
	lea	TempCoordsTable,a2	; lasketut xy
	lea	FaceVisibleTable,a3	; tasojen näkyvyys

	move.w	(a1)+,d7		; tasojen määrä
.loop1:	move.w	(a1)+,d6		; viivojen määrä tasossa
	move.w	(a1)+,a5		; väri
	move.w	(a3)+,d0		; piirretäänkö?
	bmi.w	.DoNotDraw

	move.w	d0,a5

.loop2:	move.l	Buffer(a4),a0
	move.w	a5,d0
	btst	#0,d0
	beq.s	.yli1
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_FillIcos
.yli1
	move.w	a5,d0
	btst	#1,d0
	beq.s	.yli2
	add.l	#40,a0
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_FillIcos
.yli2
	move.w	a5,d0
	btst	#2,d0
	beq.s	.yli3
	move.l	Buffer(a4),a0
	add.l	#80,a0
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_FillIcos
.yli3
	addq.l	#4,a1
	dbf	d6,.loop2
	bra.s	.jump1
.DoNotDraw:
	addq.w	#1,d6
	asl.w	#2,d6
	add.w	d6,a1
.jump1:	dbf	d7,.loop1
	rts


DrawSurfaces_FillIcos:
	WaitB
	move.w	#$8000,bltadat(a6)
	move.w	#$ffff,bltbdat(a6)
	move.l	#-1,bltafwm(a6)
	move.w	#40*3,bltcmod(a6)
	move.w	#40*3,bltdmod(a6)

	move.l	ObjConnect(a4),a1
	lea	TempCoordsTable,a2
	lea	FaceVisibleTable,a3

	move.w	(a1)+,d7		; tasojen määrä
.loop1:	move.w	(a1)+,d6		; viivojen määrä tasossa
	move.w	(a1)+,a5		; väri
	cmp.w	#0,(a3)+		; piirretäänkö?
	bge.w	.DoNotDraw		; eipä ole näkyvissä
.loop2:	move.l	Buffer(a4),a0
	move.w	a5,d0
	btst	#0,d0
	beq.s	.yli1
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_FillIcos
.yli1
	move.w	a5,d0
	btst	#1,d0
	beq.s	.yli2
	add.l	#40,a0
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_FillIcos
.yli2
	addq.l	#4,a1
	dbf	d6,.loop2
	bra.s	.jump1
.DoNotDraw:
	addq.w	#1,d6
	asl.w	#2,d6
	add.w	d6,a1
.jump1:	dbf	d7,.loop1
	rts

FillScreen_3bpl:
	subq.w	#1,minY(a4)
	sub.w	#16,minX(a4)	; minX
	add.w	#16,maxX(a4)	; maxX
	
	move.w	maxX(a4),d1	; maxX
	lsr.w	#3,d1
	bclr	#0,d1		; parilliseksi
	move.w	d1,d4		; talteen
	move.w	minX(a4),d0	; minX
	lsr.w	#3,d0
	bclr	#0,d0		; parilliseksi
	sub.w	d0,d1		; koko d1
	move.w	#40,d3
	sub.w	d1,d3		; modulo d3
	
	move.w	maxY(a4),d2	; maxY
	sub.w	minY(a4),d2	; korkeus riveinä
;	asl.w	#1,d2		; korkeus*2 (planejen määrä)
	mulu	#3,d2
	asl.w	#6,d2		; oikeisiin bitteihin
	asr.w	#1,d1
	or.w	d1,d2		; bltsize

	move.l	Buffer(a4),a0
	move.w	maxY(a4),d0	; maxY
	mulu	#40*3,d0
	ext.l	d4
	add.l	d0,a0
	add.l	d4,a0		; startaddress a0

	WaitB
	move.l	a0,bltapth(a6)
	move.l	a0,bltdpth(a6)
	move.w	d3,bltamod(a6)
	move.w	d3,bltdmod(a6)
	move.w	#%0000000000010010,bltcon1(a6)
	move.w	#%0000100111110000,bltcon0(a6)
	move.l	#-1,bltafwm(a6)
	move.w	d2,bltsize(a6)

	move.w	d3,modulo(a4)
	move.w	d2,blitsize(a4)
	move.w	minX(a4),d0	; minX
	lsr.l	#3,d0
	bclr	#0,d0		; parilliseksi
	ext.l	d0
	move.l	d0,xadd(a4)

	rts		;-)

drawline_FillIcos:
	cmp.w	d1,d3
	bhi.s	.next1
	exg	d0,d2
	exg	d1,d3
.next1:
	cmp.w	minY(a4),d1
	bhi.s	.eipienempiy
	move.w	d1,minY(a4)
.eipienempiy:
	cmp.w	maxY(a4),d3
	blo.s	.eisuurempiy
	move.w	d3,maxY(a4)
.eisuurempiy:
	cmp.w	minX(a4),d0
	bhi.s	.eipienempix1
	move.w	d0,minX(a4)
.eipienempix1:
	cmp.w	minX(a4),d2
	bhi.s	.eipienempix2
	move.w	d2,minX(a4)
.eipienempix2:
	cmp.w	maxX(a4),d0
	blo.s	.eisuurempix1
	move.w	d0,maxX(a4)
.eisuurempix1:
	cmp.w	maxX(a4),d2
	blo.s	.eisuurempix2
	move.w	d2,maxX(a4)
.eisuurempix2:
	cmp.w	d3,d1
	bne.s	.next2
	rts
.next2:
	moveq	#0,d5
	move.w	d3,d4
	sub.w	d1,d4
	add.w	d4,d4
	sub.w	d0,d2
	bge.s	.x2gx1
	neg.w	d2
	addq.w	#2,d5
.x2gx1:	cmp.w	d4,d2
	blo.s	.allok
	subq.w	#1,d3
.allok:
	sub.w	d1,d3
	mulu	#40*3,d1
	move.w	d0,d4
	asr.w	#3,d4
	add.w	d4,d1
	add.l	a0,d1

	move.w	d3,d4
	sub.w	d2,d4
	bge.s	.dygdx
	exg	d2,d3
	addq.w	#1,d5
.dygdx:
	move.b	.oktantit(pc,d5),d5
	add.w	d2,d2
	and.w	#$000f,d0
	ror.w	#4,d0
	or.w	#%0000101101011010,d0

	WaitB

	move.w	d2,bltbmod(a6)
	sub.w	d3,d2
	bge.s	.signnl
	or.b	#%01000000,d5
.signnl:
	move.w	d2,bltaptl(a6)
	sub.w	d3,d2
	move.w	d2,bltamod(a6)
	move.w	d0,bltcon0(a6)
	move.w	d5,bltcon1(a6)
	move.l	d1,bltcpth(a6)
	move.l	d1,bltdpth(a6)
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,bltsize(a6)
	rts

.oktantit:
	dc.b 0+3
	dc.b 16+3
	dc.b 8+3
	dc.b 20+3


;;; MANDELWRITER
Part_MandelWriter:
	move.w	#%0000000000100000,intena(a6)

	move.b	#$2c,mandelwait1(a4)
	move.b	#$2d,mandelwait2(a4)
	move.l	#80,BitPlaneAdd(a4)

	move.w	#127,FadeValue(a4)

	lea	plane2,a0
	move.l	a0,d0
	moveq	#0,d1
	move.w	#64*3*256+20,d2
	bsr	ClearScreen

	add.l	#256*40*3,d0
	move.w	#64*2*256+20,d2
	bsr	ClearScreen

	lea	Planes_Mandel,a1
	moveq	#40,d0
	moveq	#5-1,d1
	bsr.w	SetPlanes

	lea	writertext(pc),a0
	move.l	a0,scrollpointer(a4)

	move.w	#10,PrintSpeed(a4)

	lea	plane1,a0
	move.l	a0,Active(a4)

	move.l	a0,d0
	moveq	#0,d1
	move.w	#64*256+40,d2
	bsr	ClearScreen

	lea	vbi_Writer(pc),a0
	move.l	VBR(a4),a5
	move.l	a0,Exec_intvector_vbi(a5)

	lea	CopperList_Mandel,a0
	move.l  a0,cop1lch(a6)

	clr.w	timer(a4)

	move.w	#%1000000000100000,intena(a6)

	bsr	Mandelbrot

	rts

vbi_Writer:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	custom,a6
	lea	Bss_Stack,a4

	IF	RMOUSE_PAUSE = 1
	RightMouse
	beq.w	.rmpause
	ENDC

	addq.w	#1,timer(a4)
	cmp.w	#60*50,timer(a4)
	blo.s	.patch_680x0

	cmp.w	#-2,mandelstart(a4)
	bne.s	.mandel_not_finished

	lea	CopColors_Mandel,a0
	lea	Colors_Mandel(pc),a1
	moveq	#2,d0
	moveq	#32,d7
	bsr	FadeOut

	tst.w	FadeValue(a4)
	bne.s	.mandel_not_finished
	move.w	#-1,quitflag(a4)

.mandel_not_finished
.patch_680x0

	lea	MedResWait,a1
	move.b	mandelwait1(a4),(a1)
	move.b	mandelwait2(a4),4(a1)

	move.l	Active(a4),a0
	add.l	BitPlaneAdd(a4),a0

	lea	Planes_Writer,a1
	moveq	#80,d0
	moveq	#1-1,d1
	bsr.w	SetPlanes

	bsr	Writer


	IF	RASTERTIME = 1
	move.w	#$005,c0(a6)	; raster tid
	ENDC
.rmpause

	move.w	#$20,intreq(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rte


	; It is reeeel stupid, but we've written thousands of bytes
	; of this sort of comments in this source, and no
	; helpful comments at all. Maybe these are supposed to
	; make the possible ripper freak out...
	;	- J'boy



LF		= 10
MB		= 11


Writer:
	subq.w	#4,PrintSpeed(a4)
	bgt.w	.do_not_print_anything_yet_just_wait

	move.w	#8,PrintSpeed(a4)


.here:	moveq	#0,d0
	move.l	scrollpointer(a4),a0
	move.b	(a0),d0
	bne.s	.yli
	bra.w	.end
	lea	writertext(pc),a0
	move.l	a0,scrollpointer(a4)
	bra.s	.here
.yli:
	cmp.b	#MB,d0			; ascii 10
	bne.s	.no_mandel_yet
	addq.l	#1,scrollpointer(a4)
	move.w	#-1,mandelstart(a4)
	bra.s	.here

.no_mandel_yet
	cmp.b	#LF,d0			; ascii 11
	bne.s	.yli2
	addq.l	#1,scrollpointer(a4)
	add.w	#16,Line(a4)		; seuraava rivi
	cmp.w	#15*16,Line(a4)
	bne.s	.jump
	clr.w	Line(a4)
.jump
	clr.w	Col(a4)
	bra.s	.end

.yli2
	addq.l	#1,scrollpointer(a4)
	ext.w	d0
	sub.b	#32,d0
	bgt.s	.NoMess
	moveq	#0,d0
.NoMess:
	add.w	d0,d0
	lea	WriterFonts,a1
	add.w	d0,a1


	move.l	Active(a4),a0
	add.w	#3*80,a0
	move.w	Line(a4),d0
	mulu	#80,d0
	add.l	d0,a0
	move.w	Col(a4),d0
	add.w	d0,a0	

	addq.w	#2,Col(a4)		; next column
	cmp.w	#41*2,Col(a4)		; x*2 merkkiä
	bne.s	.yli3
	clr.w	Col(a4)

	subq.l	#1,scrollpointer(a4)
	add.w	#16,Line(a4)		; seuraava rivi
	cmp.w	#15*16,Line(a4)
	blo.s	.jump2
	clr.w	Line(a4)
.jump2
	bra.s	.end
.yli3


	moveq	#14-1,d7		; fontin copy prosessorilla
.cloop:	move.w	(a1),(a0)
	add.w	#120,a1
	add.w	#80,a0
	dbf	d7,.cloop

.end
.do_not_print_anything_yet_just_wait

	rts




writertext:
	;	"                                        "

	DC.B	" FAST GREETINGS TO...                   ",MB
	DC.B	"     ZUUNI, LOPEZ, LORIMAR, MESSENGER   "
	DC.B	"                                        "
	DC.B	" AND TO SOME NOT SO ALIASED PERSONS...  "
	DC.B	"     WILLE, MARKKU, TARU, HANNA, KAISA,",LF
	DC.B	"     HEKSU, KIMMO, TIMO MARKUS OOO      "
	DC.B	"                                        "
	DC.B	" AND, OFCOURSE, TO EACH AND ALL OF YOU",LF
	DC.B	" WHO VISITED THE ASSEMBLY 93 WITHOUT",LF
	DC.B	" FORGETTING THE ORGANIZERS TO WHOM",LF
	DC.B	" FLIES A BIG THAAAANNNXXX!!!",LF
	DC.B	"                                        "
	DC.B	" A THING IS NOT NECESSARILY TRUE",LF
	DC.B	" BECAUSE A MAN DIES FOR IT.",LF
	DC.B	"     OSCAR WILDE",LF

	dc.b	0
	even



***	from a very lousy & stupid code adapted by Great J
***	almost completely rewritten, original author unknown


STARTX	= -1600		; -1400
STARTY	= -8000		; -8000
INCX	= 4		; 4
INCY	= 4		; 4
COLORI	= 32		; 32
MANDELMODULO	= $10000000	; for 3 bit integer 13 bit fractional


Mandelbrot:
	tst.w	mandelstart(a4)
	beq.s	Mandelbrot

	lea	plane2,a0
	moveq	#0,d4
	move.w 	#$8000,d5
	move.l	#MANDELMODULO,a5

	move.w 	#STARTY,d1	; alku y
	move.w 	#256,mandelcy(a4)	; korkeus

new_line:
	move.w 	#STARTX,d0	; alku x
	move.w 	#320,mandelcx(a4)	; leveys

new_x_position:
	move.w	d0,d2		; a=xc
	move.w	d1,d3		; b=yc

***	etsitään mandelbrotin luku

.loop	move.w	d2,d6
	move.w	d3,d7
	muls	d6,d6		; a^2
	muls	d7,d7		; b^2

	add.l	d7,d6		; a^2+b^2
	cmp.l	a5,d6		; modulo<2
	bhs.b	.plot		; ahaa! löytyi!

	addq.w	#1,d4		; incr. colore
	cmp.w	#COLORI-1,d4
	bhs.b	.plot

	muls	d2,d3		; b=xc*yc
	add.l	d7,d7
	sub.l	d7,d6		; a^2-b^2
	lsl.l	#3,d6
	lsl.l	#4,d3
	swap	d6
	move.w	d6,d2
	swap	d3
	add.w	d0,d2		; a=a+xc
	add.w	d1,d3		; b=b+yc
	bra.s	.loop


.plot	bclr	#0,d4
	beq.s	.not_p1
	or.w	d5,(a0)

.not_p1	bclr	#1,d4
	beq.s	.not_p2
	or.w	d5,40(a0)

.not_p2	bclr	#2,d4
	beq.s	.not_p3
	or.w	d5,80(a0)

.not_p3	bclr	#3,d4
	beq.s	.not_p4
	or.w	d5,120(a0)

.not_p4	bclr	#4,d4
	beq.s	.not_p5
	or.w	d5,160(a0)

.not_p5	ror.w	#1,d5
	bhs.s	.not_new_word
	addq.w	#2,a0

	LeftMouse
	beq.b	.exit

.not_new_word
	addq.w	#INCX,d0	; inc. x

	subq.w	#1,mandelcx(a4)
	bne.w	new_x_position

	addq.w	#INCY,d1	; inc. y
	add.w	#40*4,a0


	cmp.w	#256,mandelcy(a4)
	beq.s	.ok2

	cmp.b	#$ff,mandelwait1(a4)
	beq.s	.magic_line
	addq.b	#1,mandelwait1(a4)
	bra.s	.ok1
.magic_line
	cmp.b	#$2a,mandelwait2(a4)
	beq.s	.ok2
.ok1	addq.b	#1,mandelwait2(a4)

	add.l	#80,BitPlaneAdd(a4)
.ok2

	subq.w	#1,mandelcy(a4)
	bne.w	new_line

	move.w	#-2,mandelstart(a4)

.exit
;	LeftMouse
;	bne.b	.exit

	rts


;;; SLIME
Part_SlimeVector:
	move.w	#%0000000000100000,intena(a6)

	lea	plane1,a0
	move.l	a0,Active(a4)

	move.l	a0,d0
	moveq.l	#0,d1
	move.w	#64*256*3+20,d2
	bsr	ClearScreen

	lea	plane2,a0
	move.l	a0,Buffer(a4)
	move.l	a0,d0
	bsr	ClearScreen

	bsr.w	DefineObject_Slime

	clr.w	minYOLD(a4)
	clr.w	xaddOLD(a4)
	clr.w	moduloOLD(a4)
	move.w	#256*3*64+20,blitsizeOLD(a4)

	clr.w	minY(a4)
	clr.w	xadd(a4)
	clr.w	modulo(a4)
	move.w	#256*3*64+20,blitsize(a4)


	move.w	#2*315,Xangle(a4)
	move.w	#2*45,Yangle(a4)
	move.w	#2*225,Zangle(a4)

	clr.w	anus_ptr(a4)
	clr.w	FadeValue(a4)

	lea	Sine,a0
.aloop	move.w	(a0),d0
	cmp.w	#$1234,d0
	beq.s	.lop
	asr.w	#1,d0
	move.w	d0,d1
	asl.w	#4,d0
	or.w	d1,d0
	move.w	d0,(a0)+
	bra	.aloop
.lop

	lea	Sine,a0
	lea	CSpace,a1
	move.l	#$2a11fffe,d0
	move.w	#bplcon1,d1
	move.w	#256-1,d7
.bloop
	move.l	d0,(a1)+		; odotus
	move.w	d1,(a1)+		; bplcon1
	move.w	(a0)+,d2		; sine
	cmp.w	#$1234,d2
	bne.s	.yli2
	lea	Sine,a0
	move.w	(a0)+,d2
.yli2
	move.w	d2,(a1)+
	add.l	#$1000000,d0

	dbf	d7,.bloop

	move.l	#-2,(a1)


	lea	vbi_Slime(pc),a0
	move.l	VBR(a4),a5
	move.l	a0,Exec_intvector_vbi(a5)
	lea	CopperList_Slime,a0
	move.l  a0,cop1lch(a6)

	clr.w	timer(a4)

	move.w	#%1000000000100000,intena(a6)

	rts

vbi_Slime:
	movem.l d0-d7/a0-a6,-(sp)

	lea	Bss_Stack,a4
	lea	custom,a6
	
	IF	RMOUSE_PAUSE = 1
	RightMouse
	beq.w	.rmpause
	ENDC

	NastyOFF		; more cycles to the CPU

	bsr.w	SwapBuffers	; tuplapuskurointi

	move.l	Active(a4),a0
	lea	Planes_Slime,a1
	moveq	#40,d0
	moveq	#3-1,d1
	bsr.w	SetPlanes

	move.l	Buffer(a4),d0
	moveq	#0,d1
	move.w	minYOLD(a4),d1
	mulu	#40*3,d1
	add.l	d1,d0
	add.l	xaddOLD(a4),d0
	move.w	moduloOLD(a4),d1
	move.w	blitsizeOLD(a4),d2
	bsr	ClearScreen

	move.w	minY(a4),minYOLD(a4)
	move.l	xadd(a4),xaddOLD(a4)
	move.w	modulo(a4),moduloOLD(a4)
	move.w	blitsize(a4),blitsizeOLD(a4)


	addq.w	#1,timer(a4)
	cmp.w	#50*6,timer(a4)
	bls.s	.ok1

	bsr.w	SetAngles_Slime
	bra.s	.ok2

.ok1
	lea	CopColors_Slime,a0
	lea	Colors_Slime(pc),a1
	moveq	#3,d0
	moveq	#8,d7
	bsr	FadeIn

.ok2

	move.w	#255,minY(a4)
	clr.w	maxY(a4)
	move.w	#320,minX(a4)
	clr.w	maxX(a4)

	sub.w	a3,a3
	sub.w	a5,a5

	bsr.w	CalcVecPoints
	bsr.w	VisiblePlanes

	NastyON			; more cycles to the BLITTER

	bsr	DrawSurfaces_Slime
	bsr.w	FillScreen_Slime
	WaitB

	bsr	Do_Anus_Slime

	bsr	Varistys

	lea	Sine,a0
	addq.l	#2,Ystart(a4)
	add.l	Ystart(a4),a0
	move.w	(a0),d0
	cmp.w	#$1234,d0
	bne.s	.jump
	move.l	#$0,Ystart(a4)

.jump


	cmp.w	#50*16,timer(a4)
	bls.s	.loppu

	sub.w	#70,Distance(a4)
	cmp.w	#-9000,Distance(a4)
	bgt.s	.zok
	move.w	#-9000,Distance(a4)
	move.w	#-1,quitflag(a4)
.zok

	lea	CopColors_Slime,a0
	lea	Colors_Slime(pc),a1
	moveq	#2,d0
	moveq	#8,d7
	bsr	FadeOut

.loppu
	IF	RASTERTIME = 1
	move.w	#$005,c0(a6)	; rasteriaika
	ENDC
.rmpause

	move.w	#$20,intreq(a6)
	movem.l (sp)+,d0-d7/a0-a6
	rte

	;	Neat slime, Mave!
	;	Did you invent it on one of those hangover-mornings...?
	;		- J'boy


	;	Well, I do NOT suffer hangovers. I'm over you normal scum
	;	and I got the perfect resistance to alcohol. Actually
	;	the idea was invented after a long period of bad flu.
	;		- M

	;	'...you normal scum...'? Are you insulting me? First of
	;	all, I've never had a real hangover (except for mental
	;	ones...) after boozing. Besides I'm the one of us
	;	whose stomach has suffered more of drinking, anyway.
	;	(How the hell you spell stomachgks?)
	;	'Bout the effect... The Idea just somehow popped into
	;	your mind when you were removing those green and slimy
	;	pieces (just like the vector one) from between the keys
	;	on your keyboard...?
	;		- J'boy

	;	Let's quit this subject. It's making me feel sick...
	;	Blurp...



DefineObject_Slime:
	move.w	#8-1,ObjPointNo(a4)
	move.w	#6-1,ObjFaceNo(a4)
	move.l	#ObjCoords_Slime,ObjCoords(a4)
	move.l	#ObjFaceV_Slime,ObjFace(a4)
	move.l	#ObjFaceS_Slime,ObjConnect(a4)
	move.w	#-1700,Distance(a4)
	rts


Do_Anus_Slime:
	lea	ObjCoords_Slime,a0
	lea	anus,a1
	lea	ztable_Slime,a2

	add.w	anus_ptr(a4),a1

	addq.l	#4,a0

	moveq	#8-1,d7
.anus_loop
	move.w	(a1)+,d0
	add.w	(a2)+,d0
	move.w	d0,(a0)
	addq.l	#6,a0
	dbf	d7,.anus_loop

	addq.w	#4,anus_ptr(a4)
	cmp.w	#198,anus_ptr(a4)
	blt.s	.ok1
	clr.w	anus_ptr(a4)
.ok1

	rts



Varistys:
	lea	Sine,a0
	add.l	Ystart(a4),a0
	lea	CSpace,a1
	move.l	#$2a11fffe,d0

	move.w	#bplcon1,d1
	move.w	#256-1,d7
.loop
	move.l	d0,(a1)+		; odotus
	move.w	d1,(a1)+		; bplcon1
	move.w	(a0)+,d2		; sine
	cmp.w	#$1234,d2
	bne.s	.yli2
	lea	Sine,a0
;	clr.l	Ystart(a4)
;	add.l	Ystart(a4),a0
	move.w	(a0)+,d2
.yli2
	move.w	d2,(a1)+
	add.l	#$1000000,d0
	cmp.l	#$ff11fffe,d0
	bne.w	.hyp
	move.l	#$ffe1fffe,(a1)+
	move.l	#$0011fffe,d0
.hyp
	dbf	d7,.loop


	move.l	#-2,(a1)

	rts


SetAngles_Slime:
	addq.w	#6,Xangle(a4)
	cmp.w	#720,Xangle(a4)
	blt.s	.jump1
	sub.w	#720,Xangle(a4)
.jump1:	addq.w	#4,Yangle(a4)
	cmp.w	#720,Yangle(a4)
	blt.s	.jump2
	sub.w	#720,Yangle(a4)
.jump2:	addq.w	#4,Zangle(a4)
	cmp.w	#720,Zangle(a4)
	blt.s	.jump3
	sub.w	#720,Zangle(a4)
.jump3:
	rts				;-)


DrawSurfaces_Slime:
	WaitB
	move.w	#$8000,bltadat(a6)
	move.w	#$ffff,bltbdat(a6)
	move.l	#-1,bltafwm(a6)
	move.w	#120,bltcmod(a6)
	move.w	#120,bltdmod(a6)

	move.l	ObjConnect(a4),a1	; objectin tiedot
	lea	TempCoordsTable,a2	; lasketut xy
	lea	FaceVisibleTable,a3	; tasojen näkyvyys

	move.w	(a1)+,d7		; tasojen määrä
.loop1:	move.w	(a1)+,d6		; viivojen määrä tasossa
	move.w	(a1)+,a5		; väri
	cmp.w	#0,(a3)+		; piirretäänkö?
	bge.w	.DoNotDraw		; eipä ole näkyvissä
.loop2:	move.l	Buffer(a4),a0
	move.w	a5,d0
	btst	#0,d0
	beq.s	.yli1
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_FillIcos
.yli1
	move.w	a5,d0
	btst	#1,d0
	beq.s	.yli2
	add.l	#40,a0
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_FillIcos
.yli2
	move.w	a5,d0
	btst	#2,d0
	beq.s	.yli3
	move.l	Buffer(a4),a0
	add.l	#80,a0
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_FillIcos
.yli3
	addq.l	#4,a1
	dbf	d6,.loop2
	bra.s	.jump1
.DoNotDraw:
	addq.w	#1,d6		;dbf:n takia +1
	asl.w	#2,d6		;viivojen maara * 4 (x.w,y.w)
	add.w	d6,a1		;hyppy tämän tason viiva datan yli
.jump1:	dbf	d7,.loop1
	rts

FillScreen_Slime:
	subq.w	#1,minY(a4)
	sub.w	#16,minX(a4)	; minX
	add.w	#16,maxX(a4)	; maxX
	
	move.w	maxX(a4),d1	; maxX
	lsr.w	#3,d1
	bclr	#0,d1		; parilliseksi
	move.w	d1,d4		; talteen
	move.w	minX(a4),d0	; minX
	lsr.w	#3,d0
	bclr	#0,d0		; parilliseksi
	sub.w	d0,d1		; koko d1
	move.w	#40,d3
	sub.w	d1,d3		; modulo d3
	
	move.w	maxY(a4),d2	; maxY
	sub.w	minY(a4),d2	; korkeus riveinä
;	asl.w	#1,d2		; korkeus*2 (planejen määrä)
	mulu	#3,d2
	asl.w	#6,d2		; oikeisiin bitteihin
	asr.w	#1,d1
	or.w	d1,d2		; bltsize

	move.l	Buffer(a4),a0
	move.w	maxY(a4),d0	; maxY
	mulu	#40*3,d0
	ext.l	d4
	add.l	d0,a0
	add.l	d4,a0		; startaddress a0

	WaitB
	move.l	a0,bltapth(a6)
	move.l	a0,bltdpth(a6)
	move.w	d3,bltamod(a6)
	move.w	d3,bltdmod(a6)
	move.w	#%0000000000010010,bltcon1(a6)
	move.w	#%0000100111110000,bltcon0(a6)
	move.l	#-1,bltafwm(a6)
	move.w	d2,bltsize(a6)

	move.w	d3,modulo(a4)
	move.w	d2,blitsize(a4)
	move.w	minX(a4),d0	; minX
	lsr.l	#3,d0
	bclr	#0,d0		; parilliseksi
	ext.l	d0
	move.l	d0,xadd(a4)

	rts		;-)


;;; DICK
Part_DickPic:
	move.w	#%0000000000100000,intena(a6)

	move.w	#127,FadeValue(a4)

	lea	vbi_Dick(pc),a0
	move.l	a0,Exec_intvector_vbi(a5)
	lea	CopperList_Dick,a0
	move.l  a0,cop1lch(a6)

	clr.w	timer(a4)

	move.w	#%1000000000100000,intena(a6)

	rts

vbi_Dick:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	custom,a6
	lea	Bss_Stack,a4

	IF	RMOUSE_PAUSE = 1
	RightMouse
	beq.w	.rmpause
	ENDC

	lea	mutka,a0

	move.w	boing(a4),d0
	cmp.w	#$1234,(a0,d0.w)
	bne.s	.simo_goes_boing

	bra.s	.exit


.simo_goes_boing

	move.w	(a0,d0.w),d0
	move.w	d0,boingval(a4)
	muls	#40*4,d0
	lea	Dick,a0
	add.l	d0,a0
	add.l	#40*4*3,a0

	lea	Planes_Dick,a1
	moveq	#40,d0
	moveq	#4-1,d1
	bsr.w	SetPlanes


	bsr	dick_on_dick_off

	addq.w	#2,boing(a4)

.exit


	addq.w	#1,timer(a4)
	cmp.w	#50*6,timer(a4)
	bls.s	.ok1

	lea	CopColors_Dick,a0
	lea	Colors_Dick(pc),a1
	moveq	#4,d0
	moveq	#16,d7
	bsr	FadeOut

	cmp.w	#0,FadeValue(a4)
	bne.s	.ok1
	move.w	#-1,quitflag(a4)

.ok1
	IF	RASTERTIME = 1
	move.w	#$f00,c0+custom
	ENDC
.rmpause

	move.w	#$20,intreq(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rte


	; dickpic by Great J !!!


dick_on_dick_off:

;	bra	.exita

	lea	D_on,a0

	moveq	#$2a,d0
	sub.w	boingval(a4),d0

	cmp.w	#$2a,d0
	ble.s	.neg

	cmp.w	#$ff,d0
	bls.s	.1a

	and.w	#$ff,d0
	lsl.w	#8,d0
	or.w	#$0011,d0
	move.w	#$ffe1,(a0)
	move.w	d0,4(a0)

	bra.s	.exita

.neg	move.w	#$2a01,(a0)
	move.w	#$2a11,4(a0)
	bra.s	.exita

.1a	lsl.w	#8,d0
	or.w	#$0001,d0
	move.w	d0,(a0)
	add.w	#$0010,d0
	move.w	d0,4(a0)

.exita


	lea	D_off,a0

	move.w	#$2a+223,d0
	sub.w	boingval(a4),d0

	cmp.w	#$ff,d0
	bls.s	.1

	and.w	#$ff,d0
	lsl.w	#8,d0
	or.w	#$0011,d0
	move.w	#$ffe1,(a0)
	move.w	d0,4(a0)

	bra.s	.exit

.1	lsl.w	#8,d0
	or.w	#$0011,d0
	move.w	d0,(a0)
	move.w	d0,4(a0)

.exit
	rts


mutka:
        dc.w      220,220,220,219,219,218,218,217
        dc.w      216,215,214,213,211,210,208,207
        dc.w      205,203,201,199,196,194,191,189
        dc.w      186,183,180,177,174,171,168,164
        dc.w      161,157,153,150,146,142,138,134
        dc.w      130,125,121,117,112,108,103,98
        dc.w      94,89,84,79,74,69,64,59
        dc.w      54,49,44,39,33,28,23,18
        dc.w      12,7,2,-3,-9,-14
        dc.w      -20,-16,-12,-9,-5,-1,2,5
        dc.w      8,12,15,18,21,24,27,29
        dc.w      32,34,37,39,41,42,44,45
        dc.w      47,48,48,49,50,50,50,50
        dc.w      50,49,48,48,47,45,44,42
        dc.w      41,39,37,34,32,29,27,24
        dc.w      21,18,15,12,8,5,2,-1
        dc.w      -5,-9,-12,-16,-20
        dc.w      -20,-17,-14,-11,-9,-6,-4,-1
        dc.w      1,3,5,7,8,10,11,12
        dc.w      13,14,15,15,15,15,15,14
        dc.w      13,12,11,10,8,7,5,3
        dc.w      1,-1,-4,-6,-9,-11,-14,-17
        dc.w      -20,-17,-15,-13,-11,-9,-7,-6
        dc.w      -5,-5,-5,-5,-5,-6,-7,-9
        dc.w      -11,-13,-15,-17
        dc.w      -20,-18,-17,-15,-15,-15,-15,-15
        dc.w      -17,-18
	dc.w	-20,-20,-20,-20,-20,-20,-20,-20
	dc.w	-20,-20,-20,-20,-20,-20,-20,-20
	dc.w	-20,-20,-20,-20,-20,-20,-20,-20
	dc.w	-20,-20,-20,-20,-20,-20,-20,-20
	dc.w	-20,-20,-20,-20,-20,-20,-20,-20
	dc.w	-20,-20,-20,-20,-20,-20,-20,-20
	dc.w	-20,-20,-20,-20,-20,-20,-20,-20
	dc.w	-20,-20,-20,-20,-20,-20,-20,-20




        dc.w      -20,-20,-20,-20,-20,-21,-22,-23
        dc.w      -23,-24,-26,-27,-28,-30,-31,-33
        dc.w      -35,-37,-39,-41,-44,-46,-49,-51
        dc.w      -54,-57,-60,-63,-66,-70,-73,-76
        dc.w      -80,-84,-87,-91,-95,-99,-103,-107
        dc.w      -112,-116,-120,-125,-130,-134,-139,-144
        dc.w      -148,-153,-158,-163,-168,-173,-178,-184
        dc.w      -189,-194,-199,-205,-210,-215,-221,-226
        dc.w      -232,-237,-243,-248,-254,-259



	dc.w	$1234



	; Tekikö Jumala maailmaa luodessaan taulukoita?
	; 	- Maverick


	; Oli miten oli, niin veikkaisin, että ohjelmointikieli
	; niin suuressa projectissa oli C.
	;	- Great J

	; PS.	Miten olisi structuurien laita?


	; Structuurit eivät ole taulukoita, vaan ... tota noin... structuureja.
	; Siinä on se suuri ero! 
	; Tuskinpa maailmaa sentään C:llä luotiin... vaikka niin olisikin
	; tehty, niin osa ihmisestä ilmeisesti ohjelmoitiin Basicilla.
	;	- Maverick "I still hate (s)tables"
	
	; Jaha.
	;	- J'boy

	; Ilmeisesti todistit juuri sen Basicilla ohjelmointi väitteeni...
	;	- Maverick 


;;; JELLO GLENZ
Part_Glenz:
	move.w	#%0000000000100000,intena(a6)

	lea	plane1,a0
	move.l	a0,Active(a4)
	move.l	a0,d0
	moveq	#0,d1
	move.w	#64*2*256+40,d2
	bsr	ClearScreen

	add.l	#40*256*2,d0
	bsr	ClearScreen

	lea	plane2,a0
	move.l	a0,Buffer(a4)

	move.l	a0,d0
	moveq	#0,d1
	move.w	#64*2*256+40,d2
	bsr	ClearScreen

	add.l	#40*256*2,d0
	bsr	ClearScreen

	move.w	#-2*20,anus_ptr(a4)

	bsr.w	DefineObject_Glenz

	clr.w	minYOLD(a4)
	clr.w	xaddOLD(a4)
	clr.w	moduloOLD(a4)
	move.w	#255*4*64+20,blitsizeOLD(a4)

	clr.w	minY(a4)
	clr.w	xadd(a4)
	clr.w	modulo(a4)
	move.w	#255*4*64+20,blitsize(a4)

	clr.w	x_sin_pointer(a4)
	clr.w	y_sin_pointer(a4)

	clr.w	Zangle(a4)
	clr.w	Yangle(a4)
	clr.w	Xangle(a4)

	clr.w	FadeValue(a4)

	lea	vbi_Glenz(pc),a0
	move.l	VBR(a4),a5
	move.l	a0,Exec_intvector_vbi(a5)
	lea	CopperList_Glenz,a0
	move.l  a0,cop1lch(a6)
	clr.w	timer(a4)

	move.w	#%1000000000100000,intena(a6)

	rts

vbi_Glenz:
	movem.l d0-d7/a0-a6,-(sp)

	lea	Bss_Stack,a4
	lea	custom,a6
	
	IF	RMOUSE_PAUSE = 1
	RightMouse
	beq.w	.rmpause
	ENDC

	NastyON

	bsr.w	SwapBuffers

	move.l	Active(a4),a0
	lea	Planes_Glenz,a1
	moveq	#40,d0
	moveq	#4-1,d1
	bsr.w	SetPlanes

	move.l	Buffer(a4),d0
	moveq	#0,d1
	move.w	minYOLD(a4),d1
	mulu	#40*4,d1
	add.l	d1,d0
	add.l	xaddOLD(a4),d0
	move.w	moduloOLD(a4),d1
	move.w	blitsizeOLD(a4),d2
	bsr	ClearScreen

	move.w	minY(a4),minYOLD(a4)
	move.l	xadd(a4),xaddOLD(a4)
	move.w	modulo(a4),moduloOLD(a4)
	move.w	blitsize(a4),blitsizeOLD(a4)


	bsr.w	SetAngles_Glenz

	move.w	#255,minY(a4)
	clr.w	maxY(a4)
	move.w	#320,minX(a4)
	clr.w	maxX(a4)

	move.w	x_sin_pointer(a4),d0
	lea	x_sine(pc),a3
	move.w	(a3,d0.w),d0
	cmp.w	#$1234,d0
	bne.s	.ok1
	moveq.l	#0,d0
	clr.w	x_sin_pointer(a4)
.ok1
	move.w	d0,a3

	move.w	y_sin_pointer(a4),d0
	lea	y_sine(pc),a5
	move.w	(a5,d0.w),d0
	cmp.w	#$1234,d0
	bne.s	.ok2
	moveq.l	#0,d0
	clr.w	y_sin_pointer(a4)
.ok2
	move.w	d0,a5

	bsr.w	CalcVecPoints
	bsr.w	VisiblePlanes

	NastyON

	bsr	DrawSurfaces_Glenz
	bsr.w	FillScreen_Glenz
	WaitB


	addq.w	#1,timer(a4)

	cmp.w	#50*5+47,timer(a4)
	bhi.s	.phase2

	lea	CopColors_Glenz,a0
	lea	Colors_Glenz(pc),a1	; PC-relative code
	moveq	#4,d0
	moveq	#9,d7
	bsr	FadeIn

	addq.w	#2,x_sin_pointer(a4)
	addq.w	#2,y_sin_pointer(a4)

	add.w	#50,Distance(a4)
	cmp.w	#-1700,Distance(a4)
	blt.s	.yli2
	move.w	#-1700,Distance(a4)
.yli2
	bra.s	.endp

.phase2	cmp.w	#50*19,timer(a4)
	blt.s	.phase3

	sub.w	#50,Distance(a4)
	cmp.w	#-9000,Distance(a4)
	bgt.s	.yli3
	move.w	#-9000,Distance(a4)
	move.w	#-1,quitflag(a4)
.yli3

	lea	CopColors_Glenz,a0
	lea	Colors_Glenz(pc),a1
	moveq	#1,d0
	moveq	#9,d7
	bsr	FadeOut

	

.phase3	cmp.w	#50*7,timer(a4)
	bls.s	.no_anus
	bsr	Do_Anus_Glenz		; osiltaan koodi on K-18
.no_anus				; joo, varsinkin stack-jutut.
.endp					; (push & pull)

	IF	RASTERTIME = 1
	move.w	#$005,c0(a6)		; rasteriajasta puheen ollen...
	ENDC				; on alle kahdeksanvuotiaiden
					; logout-aika.
.rmpause

	move.w	#$20,intreq(a6)
	movem.l (sp)+,d0-d7/a0-a6
	rte



DefineObject_Glenz:
	move.w	#12-1,ObjPointNo(a4)
	move.w	#20-1,ObjFaceNo(a4)
	move.l	#ObjCoords_Glenz,ObjCoords(a4)
	move.l	#ObjFaceV_Glenz,ObjFace(a4)
	move.l	#ObjFaceS_Glenz,ObjConnect(a4)
	move.w	#-6000,Distance(a4)
	rts

Do_Anus_Glenz:
	lea	ObjCoords_Glenz,a0
	lea	anus,a1
	lea	ztable_Glenz,a2

	add.w	anus_ptr(a4),a1

	addq.l	#4,a0

	moveq	#12-1,d7
.anus_loop
	move.w	(a1)+,d0
	add.w	(a2)+,d0
	move.w	d0,(a0)
	addq.l	#6,a0
	dbf	d7,.anus_loop

	addq.w	#8,anus_ptr(a4)
	cmp.w	#198,anus_ptr(a4)
	blt.s	.ok1
	clr.w	anus_ptr(a4)
.ok1

	rts


SetAngles_Glenz:
	addq.w	#2,Xangle(a4)
	cmp.w	#720,Xangle(a4)
	blt.s	.jump1
	sub.w	#720,Xangle(a4)
.jump1:	addq.w	#2,Yangle(a4)
	cmp.w	#720,Yangle(a4)
	blt.s	.jump2
	sub.w	#720,Yangle(a4)
.jump2:	addq.w	#4,Zangle(a4)
	cmp.w	#720,Zangle(a4)
	blt.s	.jump3
	sub.w	#720,Zangle(a4)
.jump3:
	rts				;-)

DrawSurfaces_Glenz:
	WaitB
	move.w	#$8000,bltadat(a6)
	move.w	#$ffff,bltbdat(a6)
	move.l	#-1,bltafwm(a6)
	move.w	#40*4,bltcmod(a6)
	move.w	#40*4,bltdmod(a6)

	move.l	ObjConnect(a4),a1	; objectin tiedot
	lea	TempCoordsTable,a2	; lasketut xy
	lea	FaceVisibleTable,a3	; tasojen näkyvyys

	move.w	(a1)+,d7		; tasojen määrä
.loop1:	move.w	(a1)+,d6		; viivojen määrä tasossa
	move.w	(a1)+,a5		; väri
	cmp.w	#0,(a3)+		; piirretäänkö?
	bge.w	.DoNotDraw		; eipä ole näkyvissä
.loop2:
	move.w	a5,d0
	btst	#0,d0
	beq.s	.yli1
	move.l	Buffer(a4),a0
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_Glenz
.yli1
	move.w	a5,d0
	btst	#1,d0
	beq.s	.yli2
	move.l	Buffer(a4),a0
	add.l	#40,a0
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_Glenz
.yli2

	addq.l	#4,a1
	dbf	d6,.loop2
	bra.s	.jump1
.DoNotDraw:
	move.w	a5,d0
	btst	#0,d0
	beq.s	.yli11
	move.l	Buffer(a4),a0
	add.l	#80,a0
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_Glenz
.yli11
	move.w	a5,d0
	btst	#1,d0
	beq.s	.yli22
	move.l	Buffer(a4),a0
	add.l	#120,a0
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_Glenz
.yli22
	addq.l	#4,a1
	dbf	d6,.DoNotDraw
.jump1:	dbf	d7,.loop1
	rts

FillScreen_Glenz:
	subq.w	#1,minY(a4)
	sub.w	#16,minX(a4)	; minX
	add.w	#16,maxX(a4)	; maxX
	
	move.w	maxX(a4),d1	; maxX
	lsr.w	#3,d1
	bclr	#0,d1		; parilliseksi
	move.w	d1,d4		; talteen
	move.w	minX(a4),d0	; minX
	lsr.w	#3,d0
	bclr	#0,d0		; parilliseksi
	sub.w	d0,d1		; koko d1
	move.w	#40,d3
	sub.w	d1,d3		; modulo d3
	
	move.w	maxY(a4),d2	; maxY
	sub.w	minY(a4),d2	; korkeus riveinä

;	asl.w	#2,d2		; korkeus*2 (planejen määrä)
;	mulu	#4,d2
	asl.w	#6+2,d2		; oikeisiin bitteihin

	asr.w	#1,d1
	or.w	d1,d2		; bltsize

	move.l	Buffer(a4),a0
	move.w	maxY(a4),d0	; maxY
	mulu	#40*4,d0
	ext.l	d4
	add.l	d0,a0
	add.l	d4,a0		; startaddress a0

	WaitB
	move.l	a0,bltapth(a6)
	move.l	a0,bltdpth(a6)
	move.w	d3,bltamod(a6)
	move.w	d3,bltdmod(a6)
	move.w	#%0000000000010010,bltcon1(a6)
	move.w	#%0000100111110000,bltcon0(a6)
	move.l	#-1,bltafwm(a6)
	move.w	d2,bltsize(a6)

	move.w	d3,modulo(a4)
	move.w	d2,blitsize(a4)
	move.w	minX(a4),d0	; minX
	lsr.l	#3,d0
	bclr	#0,d0		; parilliseksi
	ext.l	d0
	move.l	d0,xadd(a4)

	rts		;-)


;	filled
drawline_Glenz:
	cmp.w	d1,d3
	bhi.s	.next1
	exg	d0,d2
	exg	d1,d3
.next1:
	cmp.w	minY(a4),d1
	bhi.s	.eipienempiy
	move.w	d1,minY(a4)
.eipienempiy
	cmp.w	maxY(a4),d3
	blo.s	.eisuurempiy
	move.w	d3,maxY(a4)
.eisuurempiy
	cmp.w	minX(a4),d0
	bhi.s	.eipienempix1
	move.w	d0,minX(a4)
.eipienempix1
	cmp.w	minX(a4),d2
	bhi.s	.eipienempix2
	move.w	d2,minX(a4)
.eipienempix2
	cmp.w	maxX(a4),d0
	blo.s	.eisuurempix1
	move.w	d0,maxX(a4)
.eisuurempix1
	cmp.w	maxX(a4),d2
	blo.s	.eisuurempix2
	move.w	d2,maxX(a4)
.eisuurempix2
	cmp.w	d3,d1
	bne.s	.next2
	rts
.next2:
	moveq	#0,d5
	move.w	d3,d4
	sub.w	d1,d4
	add.w	d4,d4
	sub.w	d0,d2
	bge.s	.x2gx1
	neg.w	d2
	addq.w	#2,d5
.x2gx1:	cmp.w	d4,d2
	blo.s	.allok
	subq.w	#1,d3
.allok:
	sub.w	d1,d3
	mulu	#40*4,d1
	move.w	d0,d4
	asr.w	#3,d4
	add.w	d4,d1
	add.l	a0,d1

	move.w	d3,d4
	sub.w	d2,d4
	bge.s	.dygdx
	exg	d2,d3
	addq.w	#1,d5
.dygdx:
	move.b	.oktantit(pc,d5),d5
	add.w	d2,d2
	and.w	#$000f,d0
	ror.w	#4,d0
	or.w	#%0000101101011010,d0

	WaitB

	move.w	d2,bltbmod(a6)
	sub.w	d3,d2
	bge.s	.signnl
	or.b	#%01000000,d5
.signnl:
	move.w	d2,bltaptl(a6)
	sub.w	d3,d2
	move.w	d2,bltamod(a6)
	move.w	d0,bltcon0(a6)
	move.w	d5,bltcon1(a6)
	move.l	d1,bltcpth(a6)
	move.l	d1,bltdpth(a6)
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,bltsize(a6)
	rts

.oktantit:
	dc.b 0+3
	dc.b 16+3
	dc.b 8+3
	dc.b 20+3


	; it's a hack! it's a plane! No, it's Superman!!


	; Muuten tiesittekö, että DC herätti Supermanin takaisin henkiin?
	; He myös myönsivät Teriksen tappamisen olleen mainoskikka.
	; Mainoskikka joka puri hiton hyvin... kuolinnumerot ovat jo kuumaa
	; kamaa...


	; Big Deal! olisit jättänyt meikäläisen "it's a hack"-kommentin
	; rauhaan!
	;	-J


;;; THE END TEXT
Part_TheEnd:
	move.w	#%0000000000100000,intena(a6)

	lea	End_Text_Pic,a0		; kuva public memoryssa
	lea	bpl3+3840,a1
	move.w	#26800/4-1,d7
.cloopc
	move.l	(a0)+,(a1)+
	dbf	d7,.cloopc

	lea	plane1,a0
;	add.w	#40*10*3,a0		; removed in v1.01
	move.l	a0,Active(a4)
	lea	plane2,a0
;	add.w	#40*10*3,a0		; removed in v1.01
	move.l	a0,Buffer(a4)

	bsr	DefineObject_The_End

	clr.w	minYOLD(a4)
	clr.w	xaddOLD(a4)
	clr.w	moduloOLD(a4)
	move.w	#256*3*64+20,blitsizeOLD(a4)

	clr.w	minY(a4)
	clr.w	xadd(a4)
	clr.w	modulo(a4)
	move.w	#256*3*64+20,blitsize(a4)

	lea	vbi_The_End(pc),a0
	move.l	VBR(a4),a5
	move.l	a0,Exec_intvector_vbi(a5)
	lea	CopperList_The_End,a0
	move.l  a0,cop1lch(a6)

	move.w	#0,vposw(a6)

;	move.l	#-207*80,End_Text_Ptr(a4)	; changed in v1.01
	move.l	#-203*80,End_Text_Ptr(a4)	; (a bug fix)

	clr.w	FadeValue(a4)			; added in v1.01

	clr.w	timer(a4)

	clr.w	Xangle(a4)
	clr.w	Yangle(a4)
	clr.w	Zangle(a4)

	move.w	#%1000000000100000,intena(a6)

	rts

vbi_The_End:
	movem.l d0-d7/a0-a6,-(sp)

	lea	Bss_Stack,a4
	lea	custom,a6
	
	IF	RMOUSE_PAUSE = 1
	RightMouse
	beq.w	.rmpause
	ENDC

	bsr.w	SwapBuffers

	move.l	Active(a4),a0
	lea	Planes_RGB_Plates,a1
	moveq	#40,d0
	moveq	#3-1,d1
	bsr.w	SetPlanes

	move.l	Buffer(a4),d0
	addq.l	#6,d0
	moveq	#6,d1
	move.w	#230*3*64+17,d2
	bsr.w	ClearScreen

	cmp.w	#-2,timer(a4)
	beq.w	.final_end

	cmp.w	#-1,timer(a4)
	bne.s	.tim_ok

	addq.w	#1,quitflag(a4)
	cmp.w	#6*50,quitflag(a4)
	blo.w	.final_end
	move.w	#-1,quitflag(a4)
	move.w	#-2,timer(a4)
	bra.w	.final_end
.tim_ok
	addq.w	#1,timer(a4)

	cmp.w	#50*3,timer(a4)
	blo.s	.fade_in

	move.w	timer(a4),d0
	btst	#0,d0
	beq.s	.not_yet_up

;	cmp.l	#277*80,End_Text_Ptr(a4)	; changed in v1.01
	cmp.l	#281*80,End_Text_Ptr(a4)	; (a bug fix)
	bgt.s	.all_up_enuff

	add.l	#80,End_Text_Ptr(a4)

	lea	ColOn,a0
	cmp.b	#$29,(a0)
	bls.s	.up_enuff
	subq.b	#1,(a0)
.up_enuff

;	cmp.l	#70*80,End_Text_Ptr(a4)		; changed in v1.01
	cmp.l	#77*80,End_Text_Ptr(a4)		; (a bug fix)
	blt.s	.not_yet_up

	lea	LoResOn1,a0
	subq.b	#1,4(a0)
	cmp.b	#$2a,4(a0)
	blo.s	.ok1
	subq.b	#1,(a0)
.ok1

	lea	LoResOn2,a0
	subq.b	#1,4(a0)
	cmp.b	#$2b,4(a0)
	blo.s	.ok2
	subq.b	#1,(a0)
.ok2


	bra.s	.no_fade

.fade_in
	lea	CopColors_EndText,a0
	lea	Colors_EndText,a1
	moveq	#3,d0
	moveq	#1,d7
	bsr	FadeIn
.no_fade
.not_yet_up
.all_up_enuff

;	move.w	timer(a4),d0
;	btst	#0,d0
;	beq.s	.no_flicker

;	lea	End_Text_Pic,a0
	lea	bpl3+3840,a0
	add.l	End_Text_Ptr(a4),a0
	lea	Planes_Hires,a1
	moveq	#80,d0
	moveq	#1-1,d1
	bsr.w	SetPlanes

.no_flicker		; mikä sittemmin osoittautui toimimattomaksi...snif
	move.w	minY(a4),minYOLD(a4)		; joop, Mave, that's life
	move.l	xadd(a4),xaddOLD(a4)		; in a small village...
	move.w	modulo(a4),moduloOLD(a4)	; no_flickerin epäilijät
	move.w	blitsize(a4),blitsizeOLD(a4)	; voivat tilata meiltä
						; toimivan sourcen...

	cmp.w	#23*50-20,timer(a4)
	bls.s	.not_yet

	bsr	MoveObjects_RGB_Plates
	bsr.w	SetAngles_RGB_Plates
.not_yet

	move.w	#255,minY(a4)
	clr.w	maxY(a4)
	move.w	#320,minX(a4)
	clr.w	maxX(a4)

	move.w	#8-1,ObjPointNo(a4)
	move.w	#1-1,ObjFaceNo(a4)
	move.l	#ObjCoords_RGB_Plate1,ObjCoords(a4)
	move.l	#ObjFaceV_RGB_Plate,ObjFace(a4)
	move.l	#ObjFaceS_RGB_Plate1,ObjConnect(a4)

	sub.w	a3,a3
	move.w	#-20,a5			; changed in v1.01

	bsr.w	CalcVecPoints8
	NastyON
	bsr	DrawSurfaces_RGB_Plates
	moveq	#0,d0
	bsr.w	FillScreen_RGB_Plates

	move.w	#8-1,ObjPointNo(a4)
	move.w	#1-1,ObjFaceNo(a4)
	move.l	#ObjCoords_RGB_Plate2,ObjCoords(a4)
	move.l	#ObjFaceV_RGB_Plate,ObjFace(a4)
	move.l	#ObjFaceS_RGB_Plate2,ObjConnect(a4)

	sub.w	a3,a3
	move.w	#-20,a5			; changed in v1.01

	bsr.w	CalcVecPoints8
	NastyON
	bsr	DrawSurfaces_RGB_Plates
	
	moveq	#40,d0
	bsr.w	FillScreen_RGB_Plates

	move.w	#8-1,ObjPointNo(a4)
	move.w	#1-1,ObjFaceNo(a4)
	move.l	#ObjCoords_RGB_Plate3,ObjCoords(a4)
	move.l	#ObjFaceV_RGB_Plate,ObjFace(a4)
	move.l	#ObjFaceS_RGB_Plate3,ObjConnect(a4)

	sub.w	a3,a3
	move.w	#-20,a5			; changed in v1.01

	bsr.w	CalcVecPoints8
	NastyON
	bsr	DrawSurfaces_RGB_Plates
	moveq	#80,d0
	bsr.w	FillScreen_RGB_Plates


	cmp.w	#37*50,timer(a4)
	bls.w	.not_yet2

	cmp.w	#39*50+45,timer(a4)
	bhi.w	.not_yet2


	sub.w	#100,Distance(a4)
	cmp.w	#-9000,Distance(a4)
	bhi.w	.ylitse_muiden
	add.w	#100,Distance(a4)
.ylitse_muiden

	lea	CopColors_Plates,a0
	lea	Colors_Plates(pc),a1
	moveq	#1,d0
	moveq	#8,d7
	bsr	FadeOut

.not_yet2

	

.no_away

	cmp.w	#41*50,timer(a4)		; TÄSSÄ TÄSSÄ TÄSSÄ
	blo.s	.no_mgj_fade_yet
	beq.s	.set_fadeval


	lea	LoResOn2,a0
	cmp.b	#$fe,4(a0)
	bhs.s	.no_mgj_fade_more

	addq.b	#2,(a0)
	addq.b	#2,4(a0)

	lea	ColOn,a0
	addq.b	#2,(a0)

	lea	LoResOn1,a0
	addq.b	#2,(a0)
	addq.b	#2,4(a0)

	lea	CopColors_EndText,a0
	lea	Colors_EndText,a1
	moveq	#2,d0
	moveq	#1,d7
	bsr	FadeOut

	tst.w	FadeValue(a4)
	bne.s	.not_final_quit_flaggie_set_yet

	move.w	#-1,timer(a4)		; TÄSSÄ TÄSSÄ TÄSSÄ
.not_final_quit_flaggie_set_yet

	sub.l	#2*80,End_Text_Ptr(a4)

	bra.s	.no_mgj_fade_yet

.set_fadeval
	move.w	#127,FadeValue(a4)

	lea	LoResOn1,a0
	subq.b	#2,(a0)
	subq.b	#2,4(a0)

.no_mgj_fade_yet
.no_mgj_fade_more
.final_end
.rmpause
	move.w	#$20,intreq(a6)
	movem.l (sp)+,d0-d7/a0-a6
	rte

MoveObjects_RGB_Plates:
	lea	ObjCoords_RGB_Plate1,a0
	moveq	#8-1,d7

	cmp.w	#30,4(a0)
	bge.s	.yli
.loop	addq.w	#1,4(a0)
	addq.w	#6,a0
	dbf	d7,.loop

.yli	lea	ObjCoords_RGB_Plate2,a0
	moveq	#8-1,d7
	cmp.w	#30,4(a0)
	bge.s	.yli2

.loop2	;addq.w	#1,4(a0)
	addq.w	#6,a0
	dbf	d7,.loop2

.yli2	lea	ObjCoords_RGB_Plate3,a0
	moveq	#8-1,d7

	cmp.w	#-30,4(a0)
	blt.s	.yli3

.loop3	add.w	#-1,4(a0)
	addq.w	#6,a0
	dbf	d7,.loop3
.yli3
	rts



SetAngles_RGB_Plates:
	addq.w	#6,Xangle(a4)
	cmp.w	#720,Xangle(a4)
	blt.s	.jump1
	sub.w	#720,Xangle(a4)
.jump1:	
	addq.w	#4,Yangle(a4)
	cmp.w	#720,Yangle(a4)
	blt.s	.jump2
	sub.w	#720,Yangle(a4)
.jump2:	
	addq.w	#4,Zangle(a4)
	cmp.w	#720,Zangle(a4)
	blt.s	.jump3
	sub.w	#720,Zangle(a4)
.jump3:
	rts				;-(

DrawSurfaces_RGB_Plates:
	WaitB
	move.w	#$8000,bltadat(a6)
	move.w	#$ffff,bltbdat(a6)
	move.l	#-1,bltafwm(a6)
	move.w	#40*3,bltcmod(a6)
	move.w	#40*3,bltdmod(a6)

	move.l	ObjConnect(a4),a1	; objectin tiedot
	lea	TempCoordsTable,a2		; lasketut xy
	lea	FaceVisibleTable,a3	; tasojen näkyvyys

	move.w	(a1)+,d7		; tasojen määrä
.loop1:	move.w	(a1)+,d6		; viivojen määrä tasossa
	move.w	(a1)+,a5		; väri
.loop2:	move.l	Buffer(a4),a0
	move.w	a5,d0
	btst	#0,d0
	beq.s	.yli1
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_RGB_Plates
.yli1
	move.w	a5,d0
	btst	#1,d0
	beq.s	.yli2
	add.l	#40,a0
	move.w	(a1),d3
	move.w	(a2,d3.w),d0
	move.w	2(a2,d3.w),d1
	move.w	2(a1),d3
	move.w	(a2,d3.w),d2
	move.w	2(a2,d3.w),d3
	bsr.w	drawline_RGB_Plates
.yli2
	move.w	a5,d0
	btst	#2,d0
	beq.s	.yli3
	move.l	Buffer(a4),a0
	add.l	#80,a0
	move.w	(a1),d3			; lisäys, josta löytyy Rx1
	move.w	(a2,d3.w),d0		; Rx1
	move.w	2(a2,d3.w),d1		; Ry1
	move.w	2(a1),d3			; lisäys, josta löytyy Rx2
	move.w	(a2,d3.w),d2		; Rx2
	move.w	2(a2,d3.w),d3		; Ry2
	bsr.w	drawline_RGB_Plates
.yli3
	addq.l	#4,a1
	dbf	d6,.loop2
	bra.s	.jump1
.DoNotDraw:
	addq.w	#1,d6		;dbf:n takia +1
	asl.w	#2,d6		;viivojen maara * 4 (x.w,y.w)
	add.w	d6,a1		;hyppy tämän tason viiva datan yli
.jump1:	dbf	d7,.loop1
	rts

FillScreen_RGB_Plates:

	move.l	Buffer(a4),a0
	add.l	d0,a0


	addq.w	#1,maxY(a4)
	subq.w	#1,minY(a4)
	sub.w	#16,minX(a4)	; minX
	add.w	#16,maxX(a4)	; maxX
	
	move.w	maxX(a4),d1	; maxX
	lsr.w	#3,d1
	bclr	#0,d1		; parilliseksi
	move.w	d1,d4		; talteen
	move.w	minX(a4),d0	; minX
	lsr.w	#3,d0
	bclr	#0,d0		; parilliseksi
	sub.w	d0,d1		; koko d1
	moveq	#40*3,d3
	sub.w	d1,d3		; modulo d3
	
	move.w	maxY(a4),d2	; maxY
	sub.w	minY(a4),d2	; korkeus riveinä
;	asl.w	#1,d2		; korkeus*2 (planejen määrä)
;	mulu	#3,d2
	asl.w	#6,d2		; oikeisiin bitteihin
	asr.w	#1,d1
	or.w	d1,d2		; bltsize

	move.w	maxY(a4),d0	; maxY
	mulu	#40*3,d0
	ext.l	d4
	add.l	d0,a0
	add.l	d4,a0		; startaddress a0

	WaitB
	move.l	a0,bltapth(a6)
	move.l	a0,bltdpth(a6)
	move.w	d3,bltamod(a6)
	move.w	d3,bltdmod(a6)
	move.w	#%0000000000010010,bltcon1(a6)
	move.w	#%0000100111110000,bltcon0(a6)
	move.l	#-1,bltafwm(a6)
	move.w	d2,bltsize(a6)

	move.w	d3,modulo(a4)
	move.w	d2,blitsize(a4)
	move.w	minX(a4),d0	; minX
	lsr.l	#3,d0
	bclr	#0,d0		; parilliseksi
	ext.l	d0
	move.l	d0,xadd(a4)

	rts		;-)

drawline_RGB_Plates:
	cmp.w	d1,d3
	bhi.s	.next1
	exg	d0,d2
	exg	d1,d3	; ylhäältä alas
.next1:
	cmp.w	minY(a4),d1
	bhi.s	.eipienempiy
	move.w	d1,minY(a4)
.eipienempiy:
	cmp.w	maxY(a4),d3
	blo.s	.eisuurempiy
	move.w	d3,maxY(a4)
.eisuurempiy:
	cmp.w	minX(a4),d0
	bhi.s	.eipienempix1
	move.w	d0,minX(a4)
.eipienempix1:
	cmp.w	minX(a4),d2
	bhi.s	.eipienempix2
	move.w	d2,minX(a4)
.eipienempix2:
	cmp.w	maxX(a4),d0
	blo.s	.eisuurempix1
	move.w	d0,maxX(a4)
.eisuurempix1:
	cmp.w	maxX(a4),d2
	blo.s	.eisuurempix2
	move.w	d2,maxX(a4)
.eisuurempix2:
	cmp.w	d3,d1
	bne.s	.next2
	rts
.next2:
	moveq	#0,d5
	move.w	d3,d4
	sub.w	d1,d4
	add.w	d4,d4
	sub.w	d0,d2
	bge.s	.x2gx1
	neg.w	d2
	addq.w	#2,d5
.x2gx1:	cmp.w	d4,d2
	blo.s	.allok
	subq.w	#1,d3
.allok:
	sub.w	d1,d3
	mulu	#120,d1
	move.w	d0,d4
	asr.w	#3,d4
	add.w	d4,d1
	add.l	a0,d1

	move.w	d3,d4
	sub.w	d2,d4
	bge.s	.dygdx
	exg	d2,d3
	addq.w	#1,d5
.dygdx:
	move.b	.oktantit(pc,d5),d5
	add.w	d2,d2
	and.w	#$000f,d0
	ror.w	#4,d0
	or.w	#%0000101101011010,d0

	WaitB

	move.w	d2,bltbmod(a6)
	sub.w	d3,d2
	bge.s	.signnl
	or.b	#%01000000,d5
.signnl:
	move.w	d2,bltaptl(a6)
	sub.w	d3,d2
	move.w	d2,bltamod(a6)
	move.w	d0,bltcon0(a6)
	move.w	d5,bltcon1(a6)
	move.l	d1,bltcpth(a6)
	move.l	d1,bltdpth(a6)
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,bltsize(a6)
	rts

.oktantit:
	dc.b 0+3
	dc.b 16+3
	dc.b 8+3
	dc.b 20+3

DefineObject_The_End
	move.w	#12-1,ObjPointNo(a4)
	move.w	#1-1,ObjFaceNo(a4)
	move.l	#ObjCoords_RGB_Plate1,ObjCoords(a4)
	move.l	#ObjFaceV_RGB_Plate,ObjFace(a4)
	move.l	#ObjFaceS_RGB_Plate1,ObjConnect(a4)
	move.w	#-900,Distance(a4)
	rts

;;; END OF ALL PARTS, SOME SMALL BUT IMPORTANT ROUTINES LEFT

gfxname:	dc.b 'graphics.library',0,0

***************************************************************************
***	FadeSet/FadeIn/FadeOut/FlashSet/FlashIn/FlashOut v1.03		***
***	Copyright (C) 1992-1993,2015 by Great J of Red Chrome		***
***									***
***	Inputs:	a0 = pointer to colors in coplist (CopColors_<name>)	***
***		a1 = pointer to a list of colors (Colors_<name>)	***
***		d0 = speed (units of 1/127, usually 1..20)		***
***		d7 = number of colors					***
***									***
***	Also two BSS Stack (TM) variables needed:			***
***	dw	FadeValue (in range 0..127)				***
***									***
***	Example:							***
***	lea	CopColors_<name>,a0
***	lea	Colors_<name>,a1
***	moveq	#5,d0
***	moveq	#16,d7
***	bsr	FadeIn
***									***
***************************************************************************

;;; FlashIn: white (FadeValue 0) -> actual colors (FadeValue 127)
FlashIn:
	lea	FlashCurve(pc),a2
	bra.s	flash_fade_in

;;; FadeIn: black (FadeValue 0) -> actual colors (FadeValue 127)
FadeIn:
	lea	FadeCurve(pc),a2

flash_fade_in:
	move.w	FadeValue(a4),d3
	cmp.w	#$7f,d3		; stop if already at max
	bne	.do
	rts
.do
	add.w	d0,d3		; d0 determines fade/flash in speed
	cmp.w	#$7f,d3		; keep in range
	ble	.ok
	move.w	#$7f,d3
.ok	move.w	d3,FadeValue(a4)

	lsr.w	#3,d3
	bra.s	set_colors

;;; FlashOut: actual colors (FadeValue 127) -> white (FadeValue 0)
FlashOut:
	lea	FlashCurve(pc),a2
	bra.s	flash_fade_out

;;; FadeOut: actual colors (FadeValue 127) -> black (FadeValue = 0)
FadeOut:
	lea	FadeCurve(pc),a2

flash_fade_out:
	move.w	FadeValue(a4),d3
	cmp.w	#0,d3		; stop if already at min
	bne	.do
	rts

.do	sub.w	d0,d3		; d0 determines fade/flash out speed
	bge	.ok
	move.w	#0,d3
.ok	move.w	d3,FadeValue(a4)

	lsr.w	#3,d3		; to range [0..15]
	bra.s	set_colors

;;; FlashSet: initialize colors according to FadeValue in flash scale
FlashSet:
	lea	FlashCurve(pc),a2
	bra.s	flash_fade_set

;;; FlashSet: initialize colors according to FadeValue in fade scale
FadeSet:
	lea	FadeCurve(pc),a2

flash_fade_set:
	move.w	FadeValue(a4),d3
	cmp.w	#$7f,d3		; enforce range
	ble	.ok
	move.w	#$7f,d3
	move.w	d3,FadeValue(a4)

.ok	lsr.w	#3,d3		; to range [0..15]

	;; d3=fadevalue [0..15]
	;; d7=number of colors
	;; a0=colors in coplist
	;; a1=original colors
	;; a2=curve
set_colors:
	subq	#1,d7
	and.l	#$f,d3
	add.l	d3,a2			; column in the fade table!
.colors
	move.w	(a1)+,d3		; get the original color values

	;; multiply each color component by 16 to index the fade table row
	move.w	d3,d0
	and.w	#%000000001111,d0	; blue
	lsl.w	#4,d0
	move.b	(a2,d0.w),d0

	move.w	d3,d1
	and.w	#%000011110000,d1	; green
	move.b	(a2,d1.w),d1
	lsl.w	#4,d1
	or.w	d1,d0

	move.w	d3,d1
	and.w	#%111100000000,d1	; red
	lsr.w	#4,d1
	move.b	(a2,d1.w),d1
	lsl.w	#8,d1
	or.w	d1,d0

	move.w	d0,2(a0)		; save new rgb-values to copperlist
	addq.l	#4,a0			; next copperlist position

	dbf	d7,.colors

	rts

FadeCurve:
	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1
	dc.b	0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2
	dc.b	0,0,0,1,1,1,1,1,2,2,2,2,2,3,3,3
	dc.b	0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4
	dc.b	0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5
	dc.b	0,0,1,1,2,2,2,3,3,4,4,4,5,5,6,6
	dc.b	0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7
	dc.b	0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8
	dc.b	0,1,1,2,2,3,4,4,5,5,6,7,7,8,8,9
	dc.b	0,1,1,2,3,3,4,5,5,6,7,7,8,9,9,10
	dc.b	0,1,1,2,3,4,4,5,6,7,7,8,9,10,10,11
	dc.b	0,1,2,2,3,4,5,6,6,7,8,9,10,10,11,12
	dc.b	0,1,2,3,3,4,5,6,7,8,9,10,10,11,12,13
	dc.b	0,1,2,3,4,5,6,7,7,8,9,10,11,12,13,14
	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

FlashCurve:
	dc.b	15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
	dc.b	15,14,13,12,11,10,9,8,8,7,6,5,4,3,2,1
	dc.b	15,14,13,12,12,11,10,9,8,7,6,5,5,4,3,2
	dc.b	15,14,13,13,12,11,10,9,9,8,7,6,5,5,4,3
	dc.b	15,14,14,13,12,11,11,10,9,8,8,7,6,5,5,4
	dc.b	15,14,14,13,12,12,11,10,10,9,8,8,7,6,6,5
	dc.b	15,14,14,13,13,12,11,11,10,10,9,8,8,7,7,6
	dc.b	15,14,14,13,13,12,12,11,11,10,10,9,9,8,8,7
	dc.b	15,15,14,14,13,13,12,12,11,11,10,10,9,9,8,8
	dc.b	15,15,14,14,13,13,13,12,12,11,11,11,10,10,9,9
	dc.b	15,15,14,14,14,13,13,13,12,12,12,11,11,11,10,10
	dc.b	15,15,14,14,14,14,13,13,13,13,12,12,12,12,11,11
	dc.b	15,15,15,14,14,14,14,14,13,13,13,13,13,12,12,12
	dc.b	15,15,15,15,14,14,14,14,14,14,14,14,13,13,13,13
	dc.b	15,15,15,15,15,15,15,15,14,14,14,14,14,14,14,14
	dc.b	15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15

CalcVecPoints:
	lea	CosTable(pc),a0
	lea	SinTable(pc),a1

	move.w	Xangle(a4),d0
	move.w	(a0,d0.w),Xcos(a4)
	move.w	(a1,d0.w),Xsin(a4)

	move.w	Yangle(a4),d0
	move.w	(a0,d0.w),Ycos(a4)
	move.w	(a1,d0.w),Ysin(a4)

	move.w	Zangle(a4),d0
	move.w	(a0,d0.w),Zcos(a4)
	move.w	(a1,d0.w),Zsin(a4)

	move.l	ObjCoords(a4),a0
	lea	TempCoordsTable,a1
	move.w	Distance(a4),a2
	moveq	#10,d6
	move.w	ObjPointNo(a4),d7
.calc_loop
	movem.w	(a0)+,d0/d1/d2
	move.w	d0,d3		; x
	move.w	d1,d4		; y
	move.w	d2,d5		; z

	muls	Zcos(a4),d0
	muls	Zsin(a4),d1
	add.l	d1,d0
	asr.l	d6,d0		; Vx

	muls	Zcos(a4),d4
	muls	Zsin(a4),d3
	sub.l	d3,d4
	asr.l	d6,d4
	move.w	d4,d1		; Vy

	muls	Xcos(a4),d2
	muls	Xsin(a4),d4
	sub.l	d4,d2
	asr.l	d6,d2		; Vz

	move.w	d0,d3
	move.w	d1,d4

	muls	Xcos(a4),d1
	muls	Xsin(a4),d5
	add.l	d5,d1		; Ly

	move.w	d2,d5

	muls	Ycos(a4),d0
	muls	Ysin(a4),d5
	sub.l	d5,d0		; Lx

	muls	Ycos(a4),d2
	muls	Ysin(a4),d3
	add.l	d3,d2
	asr.l	d6,d2		; Lz
	add.w	a2,d2		; + Distance

	divs	d2,d0
	divs	d2,d1

	add.w	#320/2,d0	; Rx
	add.w	#256/2,d1	; Ry

	add.w	a3,d0
	add.w	a5,d1

	move.w	d0,(a1)+
	move.w	d1,(a1)+

	dbf	d7,.calc_loop
	rts

CalcVecPoints8:
	lea	CosTable(pc),a0
	lea	SinTable(pc),a1

	move.w	Xangle(a4),d0
	move.w	(a0,d0.w),Xcos(a4)
	move.w	(a1,d0.w),Xsin(a4)

	move.w	Yangle(a4),d0
	move.w	(a0,d0.w),Ycos(a4)
	move.w	(a1,d0.w),Ysin(a4)

	move.w	Zangle(a4),d0
	move.w	(a0,d0.w),Zcos(a4)
	move.w	(a1,d0.w),Zsin(a4)

	move.l	ObjCoords(a4),a0
	lea	TempCoordsTable,a1
	move.w	Distance(a4),a2
	moveq	#10,d6
	move.w	ObjPointNo(a4),d7
.calc_loop
	movem.w	(a0)+,d0/d1/d2
	move.w	d0,d3		; x
	move.w	d1,d4		; y
	move.w	d2,d5		; z

	muls	Zcos(a4),d0
	muls	Zsin(a4),d1
	add.l	d1,d0
	asr.l	d6,d0		; Vx

	muls	Zcos(a4),d4
	muls	Zsin(a4),d3
	sub.l	d3,d4
	asr.l	d6,d4
	move.w	d4,d1		; Vy

	muls	Xcos(a4),d2
	muls	Xsin(a4),d4
	sub.l	d4,d2
	asr.l	d6,d2		; Vz

	move.w	d0,d3
	move.w	d1,d4

	muls	Xcos(a4),d1
	muls	Xsin(a4),d5
	add.l	d5,d1		; Ly

	move.w	d2,d5

	muls	Ycos(a4),d0
	muls	Ysin(a4),d5
	sub.l	d5,d0		; Lx

	muls	Ycos(a4),d2
	muls	Ysin(a4),d3
	add.l	d3,d2
	asr.l	#8,d2		; Lz
	add.w	a2,d2		; + Distance

	divs	d2,d0
	divs	d2,d1

	add.w	#320/2,d0	; Rx
	add.w	#256/2,d1	; Ry


	add.w	a3,d0
	add.w	a5,d1



	move.w	d0,(a1)+
	move.w	d1,(a1)+

	dbf	d7,.calc_loop
	rts



CalcVecPoints_Wille:
	lea	CosTable(pc),a0
	lea	SinTable(pc),a1

	move.w	Xangle(a4),d0
	move.w	(a0,d0.w),Xcos(a4)
	move.w	(a1,d0.w),Xsin(a4)

	move.w	Yangle(a4),d0
	move.w	(a0,d0.w),Ycos(a4)
	move.w	(a1,d0.w),Ysin(a4)

	move.w	Zangle(a4),d0
	move.w	(a0,d0.w),Zcos(a4)
	move.w	(a1,d0.w),Zsin(a4)

	lea	TempZTable,a6
	move.l	ObjCoords(a4),a0
	lea	TempCoordsTable,a1
	move.w	Distance(a4),a2
	moveq	#10,d6
	move.w	ObjPointNo(a4),d7
.calc_loop
	movem.w	(a0)+,d0/d1/d2
	move.w	d0,d3		; x
	move.w	d1,d4		; y
	move.w	d2,d5		; z

	muls	Zcos(a4),d0
	muls	Zsin(a4),d1
	add.l	d1,d0
	asr.l	d6,d0		; Vx

	muls	Zcos(a4),d4
	muls	Zsin(a4),d3
	sub.l	d3,d4
	asr.l	d6,d4
	move.w	d4,d1		; Vy

	muls	Xcos(a4),d2
	muls	Xsin(a4),d4
	sub.l	d4,d2
	asr.l	d6,d2		; Vz

	move.w	d0,d3
	move.w	d1,d4

	muls	Xcos(a4),d1
	muls	Xsin(a4),d5
	add.l	d5,d1		; Ly

	move.w	d2,d5

	muls	Ycos(a4),d0
	muls	Ysin(a4),d5
	sub.l	d5,d0		; Lx

	muls	Ycos(a4),d2
	muls	Ysin(a4),d3
	add.l	d3,d2
	asr.l	d6,d2		; Lz

	move.w	d2,(a6)+	; z-arvo talteen

	add.w	a2,d2		; + Distance

	divs	d2,d0
	divs	d2,d1

	add.w	#320/2,d0	; Rx
	add.w	#256/2,d1	; Ry


	add.w	a3,d0		; objectin liikutus x
	add.w	a5,d1		; objectin liikutus y

	move.w	d0,(a1)+
	move.w	d1,(a1)+

	dbf	d7,.calc_loop

	lea	custom,a6	

	rts






***************************************************************************
***			  SwapBuffers					***
***             Vaihtaa bufferin ja activen osoiteet			***
***************************************************************************
SwapBuffers:
	move.l	Buffer(a4),d0
	move.l	Active(a4),Buffer(a4)
	move.l	d0,Active(a4)
	rts

***************************************************************************
***									***
***		SetPlanes						***
***									***
***	Routine to set new display window memory poin-			***
***	ters to the copperlist.						***
***									***
***	a0 = pointer to the bit plane					***
***	a1 = pointer to the copperlist					***
***									***
***	d0 = bit plane size in rows*bytes				***
***	d1 = how many bitplanes-1 (1-6)					***
***									***
***	Registers d2-d4 are used as work registers.			***
***									***
***	Example:							***
***									***
***	move.l	plaYangle(a4),a0					***
***	lea	Planes,a1						***
***	move.l	#PF_SIZE,d0						***
***	moveq	#4-1,d1							***
***	bsr	SetPlanes						***
***		etc...							***
***									***
***	190892	Version 1.0						***
***		- Converted from the Stone-Age version.			***
***		- New features added					***
***	050992  Version 1.1						***
***		- Code simplified					***
***		- Routine is now faster and shorter			***
***									***
***	280992  Version 1.2						***
***		- Major bug was repaired: d2 was added			***
***		  only by word, not by longword as it 			***
***		  should... (Thanks Great J!)				***
***									***
***************************************************************************

SetPlanes:
	move.l	a0,d2		; only dataregisters can be swapped
	moveq	#6,d3
	moveq	#2,d4

.SetPlanesLoop:
	move.w	d2,(a1,d3.w)	;set bitmappointer to copperlist
	swap	d2
	move.w	d2,(a1,d4.w)
	swap	d2
	add.l	d0,d2
	addq.w	#8,d3
	addq.w	#8,d4
	
	dbf	d1,.SetPlanesLoop
	rts


; d0=pointer,d1=modulo,d2=size
Fill:
	WaitB
	move.l	d0,bltapth(a6)
	move.l	d0,bltdpth(a6)
	move.w	d1,bltamod(a6)
	move.w	d1,bltdmod(a6)
	move.w	#%0000000000010010,bltcon1(a6)
	move.w	#%0000100111110000,bltcon0(a6)
	move.l	#-1,bltafwm(a6)
	move.w	d2,bltsize(a6)
	rts


; d0=pointer,d1=modulo,d2=size
ClearScreen:
	WaitB
	move.l	#$01000000,bltcon0(a6)
	move.l	#-1,bltafwm(a6)
	move.l	d0,bltdpth(a6)
	move.w	d1,bltdmod(a6)
	move.w	d2,bltsize(a6)
	rts


	; tässä kohtaa oli readnappis-rutiini, mutta sille ei löytynyt
	; minkäänlaista käyttöä, joten tuhosimme sen.

	; eikös olekin paskamaista, tämä elämä?
	; tässäkin sourcessa puhutaan enemmän siitä poisjätetyistä
	; rutiineista kuin siinä olevista...

	; philosophy by J


;; aseta objektin tiedot

DefineObject_Open:
	move.w	#360,Xangle(a4)
	move.w	#360,Yangle(a4)
	move.w	#360,Zangle(a4)

	move.l	#ObjCoords_Open,ObjCoords(a4)
	move.l	#ObjConnect_Open,ObjConnect(a4)

	move.w	#40-1,ObjPointNo(a4)
	move.w	#40-1,ObjLineNo(a4)
	move.w	#-7000,Distance(a4)
	rts

DefineObject_Your:
	move.w	#360,Xangle(a4)
	move.w	#360,Yangle(a4)
	move.w	#360+180,Zangle(a4)

	move.l	#ObjCoords_Your,ObjCoords(a4)
	move.l	#ObjConnect_Your,ObjConnect(a4)

	move.w	#41-1,ObjPointNo(a4)
	move.w	#41-1,ObjLineNo(a4)
	rts

DefineObject_Eyes:
	move.w	#360,Xangle(a4)
	move.w	#360+180,Yangle(a4)
	move.w	#360,Zangle(a4)

	move.l	#ObjCoords_Eyes,ObjCoords(a4)
	move.l	#ObjConnect_Eyes,ObjConnect(a4)

	move.w	#48-1,ObjPointNo(a4)
	move.w	#48-1,ObjLineNo(a4)
	rts

DefineObject_Now:
	move.w	#360+180,Xangle(a4)
	move.w	#360+180,Yangle(a4)
	move.w	#360,Zangle(a4)

	move.l	#ObjCoords_Now,ObjCoords(a4)
	move.l	#ObjConnect_Now,ObjConnect(a4)

	move.w	#40-1,ObjPointNo(a4)
	move.w	#40-1,ObjLineNo(a4)
	rts


DefineObject_Line:
	move.w	#12-1,ObjPointNo(a4)
	move.w	#20-1,ObjFaceNo(a4)
	move.l	#ObjCoords_Line,ObjCoords(a4)
	move.l	#ObjFaceV_Line,ObjFace(a4)
	move.l	#ObjFaceS_Line,ObjConnect(a4)
	move.w	#-10000,Distance(a4)
	rts


DefineObject_Wille:
	move.w	#12-1,ObjPointNo(a4)
	move.w	#20-1,ObjFaceNo(a4)
	move.l	#ObjCoords_Wille,ObjCoords(a4)
	move.l	#ObjFaceV_Wille,ObjFace(a4)
	move.l	#ObjFaceS_Wille,ObjConnect(a4)
	rts



	SinCosTable		; macro

x_sine: dc.w      0,2,3,5,6,8,9,11
        dc.w      12,13,15,16,17,18,19,20
        dc.w      21,22,23,23,24,24,25,25
        dc.w      25,25,25,25,25,24,24,23
        dc.w      23,22,21,20,19,18,17,16
        dc.w      15,13,12,11,9,8,6,5
        dc.w      3,2,0,-1,-3,-4,-6,-7
        dc.w      -9,-10,-12,-13,-14,-15,-17,-18
        dc.w      -19,-20,-21,-21,-22,-23,-23,-24
        dc.w      -24,-24,-24,-25,-24,-24,-24,-24
        dc.w      -23,-23,-22,-21,-21,-20,-19,-18
        dc.w      -17,-15,-14,-13,-12,-10,-9,-7
        dc.w      -6,-4,-3,-1
        dc.w	$1234

;**** End of Shine! sinus wave generation

	; ei kellään olis shineä parempaa sinecreatoria?
	; tarvittais ja kiireellä.
	; palkkio.

	;  - the coders at RCR

y_sine:	dc.w      0,1,2,3,4,5,6,7
        dc.w      8,9,10,11,12,13,14,15
        dc.w      16,16,17,18,19,19,20,21
        dc.w      21,22,22,23,23,23,24,24
        dc.w      24,25,25,25,25,25,25,25
        dc.w      25,25,25,24,24,24,23,23
        dc.w      23,22,22,21,21,20,19,19
        dc.w      18,17,16,16,15,14,13,12
        dc.w      11,10,9,8,7,6,5,4
        dc.w      3,2,1,0,-1,-2,-3,-4
        dc.w      -5,-6,-7,-8,-9,-10,-11,-12
        dc.w      -12,-13,-14,-15,-16,-17,-17,-18
        dc.w      -19,-19,-20,-21,-21,-22,-22,-23
        dc.w      -23,-23,-24,-24,-24,-24,-24,-24
        dc.w      -24,-24,-24,-24,-24,-24,-24,-24
        dc.w      -23,-23,-23,-22,-22,-21,-21,-20
        dc.w      -19,-19,-18,-17,-17,-16,-15,-14
        dc.w      -13,-12,-12,-11,-10,-9,-8,-7
        dc.w      -6,-5,-4,-3,-2,-1,0
        dc.w	$1234


***************************************************************************
***		ColorLists for everything...				***
***************************************************************************

Colors_BPV:
	dc.w	$000,$009,$04e,$04e
Colors_BPV2:
	dc.w	$fff,$fff,$fff,$fff

Color_Line:
	dc.w	$f00,$f00,$f00

Color_Wille:
	dc.w	$900,$a00,$b00,$c00,$d00,$e00,$f00

Colors_FunnyText:
	dc.w	$0FFF

Colors_Grid:
	dc.w	$00,$66,$66,$66,$66,$99,$99,$99
	dc.w	$99,$99,$99,$cc,$cc,$cc,$cc,$ff

Colors_Vertex:
	dc.w	$000
	blk.w	4,$006
	blk.w	6,$009
	blk.w	4,$00c
	dc.w	$f

Colors_Field:
	dc.w	$def,$9ab,$567


Colors_FillIcos:
	dc.w	$769,$87a,$98b,$a9c,$bad,$cbe,$dcf

Colors_Glenz:
	dc.w	$d00,$b00,$900,$0d0,$0b0,$090,$00d,$00b,$009

Colors_Mandel:
	dc.w	$0000,$000f,$000e,$000d,$000c,$000b,$000a,$0009
	dc.w	$0008,$0007,$0106,$0205,$0304,$0403,$0502,$0611
	dc.w	$0720,$0831,$0942,$0a53,$0b64,$0c75,$0d86,$0c97
	dc.w	$0ba8,$0a9a,$098b,$0879,$0767,$0555,$0343,$0131

Colors_Slime:
	dc.w $000, $0a4,$0b5,$0c6,$0d7,$0e8,$0f9,$0d7

Colors_Dick:
	dc.w	$0000,$0FA8,$0F00,$0FF0,$0DD0,$0480,$0730,$0841
	dc.w	$0941,$0A52,$0310,$0421,$0521,$0632,$0FFF,$0C08


Colors_Plates:
	dc.w	$000,$f00,$0f0,$ff0,$00f,$f0f,$0ff,$fff

***************************************************************************
*** ;;	TYLSIÄ COPPERILISTOJA						***
***************************************************************************

	SECTION	coplist_etc,DATA_C

CopperList_BPV:
	dc.w	dmacon,$20	; sprite dNa off
	dc.w	bplcon0,$100,bplcon1,0,bpl1mod,40,bpl2mod,40
	dc.w	diwstrt,$2a70,diwstop,$2ac0,ddfstrt,$38,ddfstop,$d0
CopColors_BPV:
	dc.w	c0,$0,c1,$0,c2,$0,c3,$0
	dc.w	$2811,$fffe
	dc.w	bplcon0,$2200
Planes_BPV:
	dc.w	bpl1pth,0,bpl1ptl,0,bpl2pth,0,bpl2ptl,0
	dc.w	$ffff,$fffe


CopperList_Line:
	dc.w	dmacon,$20,bplcon0,$100,bplcon1,0
	dc.w	bpl1mod,40,bpl2mod,40,diwstrt,$2a70,diwstop,$2ac0
	dc.w	ddfstrt,$38,ddfstop,$d0

	dc.w	c0,$000
	dc.w	c1,$fff

	dc.w	$2a11,$fffe
	dc.w	bpl1mod,4,bpl2mod,4

	dc.w	bplcon0,$1200
Planes_Line:
	dc.w	bpl1pth,0,bpl1ptl,0

	dc.w	$4211,$fffe

	dc.w	bplcon0,$2200
	dc.w	bpl1mod,40,bpl2mod,40

Planes2:
	dc.w	bpl1pth,0,bpl1ptl,0,bpl2pth,0,bpl2ptl,0
	dc.w	bpl3pth,0,bpl3ptl,0,bpl4pth,0,bpl4ptl,0

	dc.w	c0,$000
CopColor_LineC1:
	dc.w	c1,$000
CopColor_LineC2:
	dc.w	c2,$000
	dc.w	c3,$000
	dc.w	$ffff,$fffe


CopperList_Wille:
	dc.w	dmacon,$20,bplcon0,$100,bplcon1,0
	dc.w	diwstrt,$2a70,diwstop,$2ac0,ddfstrt,$38,ddfstop,$d0
	dc.w	c0,$000,c1,$fff

	dc.w	$2a11,$fffe
	dc.w	bpl1mod,4,bpl2mod,4

	dc.w	bplcon0,$1200
Planes_Wille2:
	dc.w	bpl1pth,0,bpl1ptl,0

	dc.w	$4211,$fffe

	dc.w	bpl1mod,40*2,bpl2mod,40*2

;	dc.w $2a11,$fffe

	dc.w	bplcon0,$3200
Planes_Wille:
	dc.w	bpl1pth,0,bpl1ptl,0,bpl2pth,0,bpl2ptl,0
	dc.w	bpl3pth,0,bpl3ptl,0

	dc.w	c0,$000
CopColor_Wille:
	dc.w	c1,$f00
	dc.w	c2,$f00,c3,$f00,c4,$f00,c5,$f00,c6,$f00,c7,$f00

	dc.w	$ffff,$fffe



CopperList_FunnyText:
	dc.w	dmacon,$20
	dc.w	$008e,$2081,$0090,$36c1	;display window start&stop
	dc.w	$0092,$003c,$0094,$00d4	;data fetch	
	dc.w	$0108,$0000	;modulo for even planes
	dc.w	$010a,$0000 	;modulo for odd planes 
	dc.w	$0102,$0000
	dc.w	$0104,$0000		
	dc.w	c0,$0000
CopColors_FunnyText:
	dc.w	c1,$0FFF
	dc.w	$9411,$fffe	; tärkeä odotus
Planes_FunnyText:
	dc.w	bpl1pth,0	; bitplane pointers
	dc.w	bpl1ptl,0
	
	dc.w	$0100,$9200	; hires 90210 (Beverly Hills)
	dc.w	$c011,$fffe
	dc.w 	bplcon0,$100

	dc.w	$ffff,$fffe


CopperList_Grid:
	dc.w	dmacon,%0000000000100000
	dc.w	bplcon0,%0000000100000000
	dc.w	bplcon1,$00
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	dc.w	diwstrt,$2a70
	dc.w	diwstop,$2ac0
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0

CopColors_Grid:
	dc.w	c0,0,c1,0,c2,0,c4,0,c8,0,c3,0,c5,0
	dc.w	c6,0,c9,0,c10,0,c12,0,c7,0,c11,0,c13,0,c14,0,c15,0

	dc.w	$2811,$fffe
	dc.w	bplcon0,%0100000100000000
Planes_Grid:
	dc.w	bpl1pth,0
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w	$ffff,$fffe



CopperList_Vertex:
	dc.w	dmacon,$20
	dc.w	bplcon0,$100
	dc.w	bplcon1,0
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	dc.w	diwstrt,$2a70
	dc.w	diwstop,$2ac0
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0

CopColors_Vertex:
	dc.w	c0,0,c1,0,c2,0,c4,0,c8,0,c3,0,c5,0,c6,0,c9,0
	dc.w	c10,0,c12,0,c7,0,c11,0,c13,0,c14,0,c15,0

	dc.w	$2a11,$fffe
	dc.w	bplcon0,%0100000100000000
Planes_Vertex:
	dc.w	bpl1pth,0
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

	dc.w $ffff,$fffe



CopperList_Field:
	dc.w	dmacon,$20
	dc.w	bplcon0,$100
	dc.w	bplcon1,0
	dc.w	bpl1mod,24+64-4
	dc.w	bpl2mod,24+64-4
	dc.w	diwstrt,$1c71
	dc.w	diwstop,$34c9
	dc.w	ddfstrt,$30
	dc.w	ddfstop,$d8
	dc.w	c0,$000

CopColors_Field:
	dc.w	c1,0
	dc.w	c2,0
	dc.w	c3,0

	dc.w	$2a11,$fffe
	dc.w	bplcon0,%0010000100000000
Planes_Field:
	dc.w	bpl1pth,0
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	$ffff,$fffe


CopperList_Plasma:
	dc.w	dmacon,$20
	dc.w	bplcon0,$100
	dc.w	bplcon1,$00
	dc.w	bpl1mod,40*4
	dc.w	bpl2mod,40*4
	dc.w	diwstrt,$2a70
	dc.w	diwstop,$2ac0
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0

	dc.w	c0,0
CopColors_Plasma:
	dc.w	c1,0
	dc.w	c2,0
	dc.w	c3,0
	dc.w	c4,0
	dc.w	c5,0
	dc.w	c6,0
	dc.w	c7,0
	dc.w	c8,0
	dc.w	c9,0
	dc.w	c10,0
	dc.w	c11,0
	dc.w	c12,0
	dc.w	c13,0
	dc.w	c14,0
	dc.w	c15,0
	dc.w	c16,0
	dc.w	c17,0
	dc.w	c18,0
	dc.w	c19,0
	dc.w	c20,0
	dc.w	c21,0
	dc.w	c22,0
	dc.w	c23,0
	dc.w	c24,0
	dc.w	c25,0
	dc.w	c26,0
	dc.w	c27,0
	dc.w	c28,0
	dc.w	c29,0
	dc.w	c30,0
	dc.w	c31,0

	dc.w	$6411,$fffe
	dc.w	bplcon0,%0101000100000000
Planes_Plasma:
	dc.w	bpl1pth,0
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0
	dc.w	bpl5pth,0
	dc.w	bpl5ptl,0

wait_Plasma:
	dc.w	$6611,$fffe

	dc.w	c0,0
	dc.w	c1,0
	dc.w	c2,0
	dc.w	c3,0
	dc.w	c4,0
	dc.w	c5,0
	dc.w	c6,0
	dc.w	c7,0
	dc.w	c8,0
	dc.w	c9,0
	dc.w	c10,0
	dc.w	c11,0
	dc.w	c12,0
	dc.w	c13,0
	dc.w	c14,0
	dc.w	c15,0
	dc.w	c16,0
	dc.w	c17,0
	dc.w	c18,0
	dc.w	c19,0
	dc.w	c20,0
	dc.w	c21,0
	dc.w	c22,0
	dc.w	c23,0
	dc.w	c24,0
	dc.w	c25,0
	dc.w	c26,0
	dc.w	c27,0
	dc.w	c28,0
	dc.w	c29,0
	dc.w	c30,0
	dc.w	c31,0

	dc.w	$d511,$fffe
	dc.w	bplcon0,%0000000100000000

	dc.w	-2


CopperList_FillIcos:
	dc.w	dmacon,$20
	dc.w	bplcon0,$100
	dc.w	bplcon1,0
	dc.w	bpl1mod,40*2
	dc.w	bpl2mod,40*2
	dc.w	diwstrt,$2a70
	dc.w	diwstop,$2ac0
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0


	dc.w	c0,0
CopColors_FillIcos:
	dc.w	c1,0
	dc.w	c2,0
	dc.w	c3,0
	dc.w	c4,0
	dc.w	c5,0
	dc.w	c6,0
	dc.w	c7,0

	dc.w	$2a11,$fffe
	dc.w	bplcon0,$3200
Planes_FillIcos:
	dc.w	bpl1pth,0
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0

	dc.w	-2


CopperList_Glenz:
	dc.w	dmacon,$20
	dc.w	bplcon0,$100
	dc.w	bplcon1,0
	dc.w	bpl1mod,40*3
	dc.w	bpl2mod,40*3
	dc.w	diwstrt,$2a70
	dc.w	diwstop,$2ac0
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0


	dc.w	c0,$000		; 0000

	dc.w	c1,$000		; 0001
	dc.w	c2,$000		; 0010
	dc.w	c3,$000		; 0011

	dc.w	c4,$000		; 0100
	dc.w	c8,$000		; 1000
	dc.w	c12,$000	; 1100

CopColors_Glenz:
	dc.w	c5,$d00		; 0101
	dc.w	c9,$b00		; 1001
	dc.w	c13,$900	; 1101

	dc.w	c6,$0d0		; 0110
	dc.w	c10,$0b0	; 1010
	dc.w	c14,$090	; 1110

	dc.w	c7,$00d		; 0111
	dc.w	c11,$00b	; 1011
	dc.w	c15,$009	; 1111


	dc.w	$2a11,$fffe
	dc.w	bplcon0,$4200
Planes_Glenz:
	dc.w	bpl1pth,0
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0
	dc.w	$ffff,$fffe



CopperList_Mandel:
	dc.w	bplcon0,0
	dc.w	bplcon1,0
	dc.w	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	bpl1mod,40*4
	dc.w	bpl2mod,40*4

CopColors_Mandel:
	dc.w	c0,$0000,c1,$000f,c2,$000e,c3,$000d
	dc.w	c4,$000c,c5,$000b,c6,$000a,c7,$0009
	dc.w	c8,$0008,c9,$0007,c10,$0106,c11,$0205
	dc.w	c12,$0304,c13,$0403,c14,$0502,c15,$0611
	dc.w	c16,$0720,c17,$0831,c18,$0942,c19,$0a53
	dc.w	c20,$0b64,c21,$0c75,c22,$0d86,c23,$0c97
	dc.w	c24,$0ba8,c25,$0a9a,c26,$098b,c27,$0879
	dc.w	c28,$0767,c29,$0555,c30,$0343,c31,$0131

	dc.w	$2a11,$fffe
	dc.w	bplcon0,$5000

Planes_Mandel:
	dc.w	bpl1pth,0
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0
	dc.w	bpl5pth,0
	dc.w	bpl5ptl,0

MedResWait:
	dc.w	$2ae1,$fffe
	dc.w	$2b11,$fffe	; lisää joka mandelrivi yhdellä!

	dc.w 	bplcon0,$9200
	dc.w	bplcon1,0
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	dc.w 	diwstrt,$2c81
	dc.w	diwstop,$2cc1
	dc.w 	ddfstrt,$3c
	dc.w	ddfstop,$d4

	dc.w	c1,$096

Planes_Writer:
	dc.w	bpl1pth,0
	dc.w	bpl1ptl,0

	dc.w	$ffff,$fffe



CopperList_Slime:
	dc.w	dmacon,$20
	dc.w	bplcon0,$100
	dc.w	bplcon1,0
	dc.w	bpl1mod,40*2
	dc.w	bpl2mod,40*2
	dc.w	diwstrt,$2a70
	dc.w	diwstop,$2ac0
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0

CopColors_Slime:
	dc.w	c0,$0
	dc.w	c1,$0
	dc.w	c2,$0
	dc.w	c3,$0
	dc.w	c4,$0
	dc.w	c5,$0
	dc.w	c6,$0
	dc.w	c7,$0

	dc.w	$2a11,$fffe
	dc.w	bplcon0,$3200
Planes_Slime:
	dc.w	bpl1pth,0
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0

CSpace:	ds.w	256*8

	dc.l	-2



CopperList_Dick:
	dc.w 	dmacon,$20
	dc.w 	bplcon0,0
	dc.w 	bplcon1,0
	dc.w 	bpl1mod,3*40
	dc.w 	bpl2mod,3*40
	dc.w 	diwstrt,$2c81
	dc.w 	diwstop,$2cc1
	dc.w 	ddfstrt,$38
	dc.w 	ddfstop,$d0

	dc.w	c0,0, c1,0, c2,0, c3,0, c4,0, c5,0, c6,0, c7,0
	dc.w	c8,0, c9,0, c10,0, c11,0, c12,0, c13,0, c14,0, c15,0

	dc.w	$2a11,$fffe
	dc.w	bplcon0,$4200

Planes_Dick:
	dc.w	bpl1pth,0
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0
	dc.w	bpl4pth,0
	dc.w	bpl4ptl,0

D_on:	dc.w	$2a01,$fffe
	dc.w	$2a11,$fffe

CopColors_Dick:
	dc.w	$0180,$0000
	dc.w	$0182,$0FA8
	dc.w	$0184,$0F00
	dc.w	$0186,$0FF0
	dc.w	$0188,$0DD0
	dc.w	$018A,$0480
	dc.w	$018C,$0730
	dc.w	$018E,$0841
	dc.w	$0190,$0941
	dc.w	$0192,$0A52
	dc.w	$0194,$0310
	dc.w	$0196,$0421
	dc.w	$0198,$0521
	dc.w	$019A,$0632
	dc.w	$019C,$0FFF
	dc.w	$019E,$0C08

D_off:	dc.w	$ff11,$fffe
	dc.w	$0011,$fffe

	dc.w	bplcon0,0

	dc.w	-2


CopperList_The_End:
	dc.w	dmacon,$20
	dc.w	bplcon0,0
	dc.w	bplcon1,0
	dc.w	diwstrt,$2081
	dc.w	diwstop,$36c1
	dc.w	ddfstrt,$003c
	dc.w	ddfstop,$00d4
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
;	dc.w	bplcon2,0

	dc.w	$2511,$fffe		; added in v1.01
					; apparently an ECS (1 Mb) Agnus
					; requires a WAIT in the beginning.
					; I've got one, but the last part
					; was finished at Maverix's place...

;	dc.w	bplcon0,$9200
	dc.w	bplcon0,%1001000000000100	; hires, interlace, 1bpl
	
Planes_Hires:
	dc.w	bpl1pth,0
	dc.w	bpl1ptl,0
	
	dc.w	c1,0000

ColOn:	dc.w	$ef11,$fffe	; ef

	dc.w	c0,$0000
CopColors_EndText:
	dc.w	c1,$0FFF

LoResOn1:
	dc.w	$ffe1,$fffe
	dc.w	$2a11,$fffe
	dc.w	c0,$000
	dc.w	c1,$000

	dc.w	bplcon0,0
	dc.w	bplcon1,0
	dc.w	bpl1mod,40*2
	dc.w	bpl2mod,40*2
	dc.w	ddfstrt,$38
	dc.w	ddfstop,$d0
	dc.w	diwstrt,$2a70
	dc.w	diwstop,$2ac0

CopColors_Plates:
	dc.w	c0,$000
	dc.w	c1,$f00,c2,$0f0,c3,$ff0
	dc.w	c4,$00f
	dc.w	c5,$f0f,c6,$0ff,c7,$fff

LoResOn2:
	dc.w	$ffe1,$fffe
	dc.w	$2b11,$fffe

	dc.w	bplcon0,$3000

Planes_RGB_Plates:
	dc.w	bpl1pth,0
	dc.w	bpl1ptl,0
	dc.w	bpl2pth,0
	dc.w	bpl2ptl,0
	dc.w	bpl3pth,0
	dc.w	bpl3ptl,0

	dc.l	-2

Colors_EndText:
	dc.w	$0FFF


***************************************************************************
***	;; INCBIN-CHIPPIDATA						***
***************************************************************************

	public	mt_data
mt_data:	incbin	"mod.RESOLUTION2"

	ds.b	100	; älä poista tätä vaikka vaikuttaakin typerältä...!
fonts:		incbin	"TheEndpienifontti.raw"
FunnyText:	incbin	"FunnyText2.raw"

plasma:		incbin	"RCR.plasma.raw"
WriterFonts:	incbin	"MandelWriterFont.raw"
Dick:		incbin	"dick.raw"

	; kaikki includet saat meiltä ja halvalla lähtee...

	; In God we trust, others pay cash!

***************************************************************************
***	;; TILANVARAUKSET, CHIP JA MUUT					***
***************************************************************************

	SECTION	bss_chip,BSS_C

bpl1:
plane1:
mlv_plane1:	ds.b	40*256
mlv_plane2:	ds.b	40*256
mlv_plane3:	ds.b	40*256
mlv_plane4:	ds.b	3840

bpl2:		ds.b	40*256-3840

plane2:
mlv_plane5:	ds.b	40*256
		ds.b	40*256
		ds.b	7680
	
bpl3:		ds.b	40*256-7680
		ds.b	40*256
		ds.b	21760


	SECTION	tables,BSS_P


TempCoordsTable:	ds.w	51*2	; x,y...
TempZTable:		ds.w	30*2
FaceVisibleTable:	ds.w	50	; tason näkyvyys
BufferOrder_MLV:	ds.l	5*1	; viisi framea. joka frame yhtä
ActiveOrder_MLV:	ds.l	5*4	; planea muutetaan ja neljää
					; näytetään. niiden järjestys
					; talletetaan näihin.

	Alloc_Stack	; Alloc_Stack (tm) is a memory allocation
			; routine for BSS-Stack (tm) Variables


	SECTION dfdata,data_p

End_Text_Pic:	incbin	"VertexEndText22.raw"
	; ei mahtunut chippiin

***	Tätä colors pöytää editoidaan

Colors_Plasma:
	dc.w	$00A5,$00B4,$00C3,$00E1,$00F0,$01F0,$03D0,$05B0
	dc.w	$0790,$0970,$0A50,$0B40,$0C30,$0E10,$0F00,$0F01
	dc.w	$0D03,$0B05,$0907,$0709,$050A,$040B,$030C,$020D
	dc.w	$010E,$000F,$001F,$003D,$005B,$0079,$0097


;	Kauhukammio-osio alkaa: taulukot!

;	Jos Jumala olisi luonut ihmisen lentämään, olisi ihmisellä siivet.
;	Mutta jos jumala olisi suunnitellut ihmisestä taulukoiden tekijää,
;	niin ihminen omaisi sisäisen taululaskentaohjelman...

;	Ja aivoissa olisi valmiina macro "dc.w":tä varten. Vasen käsi olisi
;	korvattu jollain, mikä soveltuisi taulukoiden näpyttelyyn..
;		- Maverick



;	If man was not created to code, God would have made
;	his fingers shorter. But the Graphic User Interfaces
;	would nowadays really be something out of this world.
;		- Great J


;	Who said: "It's always the Rastertime!". He was wrong. Dead wrong.
;	He should've said: "It's always the Optimizing!".
;		- Great J


;	You should use add quick instead... Familiar, eh? 
;		- Maverick

	include	"OpenYourEyesNow.3do"	; objecteja, meiltä löytyy...
	include	"Line&Wille.3DO"
	include	"VertexObjRestOf.3DO"

; objektin x-,y-,z-koordinaatit
ObjCoords_RGB_Plate1:
	dc.w	-50,50,0	; 0
	dc.w	50,50,0		; 4
	dc.w	50,-50,0	; 8
	dc.w	-50,-50,0	; 12
	dc.w	-30,30,0	; 16
	dc.w	30,30,0		; 20
	dc.w	30,-30,0	; 24
	dc.w	-30,-30,0	; 28

ObjCoords_RGB_Plate2:
	dc.w	-50,50,0	; 16
	dc.w	50,50,0		; 20
	dc.w	50,-50,0	; 24
	dc.w	-50,-50,0	; 28
	dc.w	-30,30,0	; 16
	dc.w	30,30,0		; 20
	dc.w	30,-30,0	; 24
	dc.w	-30,-30,0	; 28

ObjCoords_RGB_Plate3:
	dc.w	-50,50,0	; 32
	dc.w	50,50,0		; 36
	dc.w	50,-50,0	; 40
	dc.w	-50,-50,0	; 44
	dc.w	-30,30,0	; 16
	dc.w	30,30,0		; 20
	dc.w	30,-30,0	; 24
	dc.w	-30,-30,0	; 28


ObjFaceV_RGB_Plate:
	dc.w 8,4,0
	dc.w 28,16,20
	dc.w 28,12,16
	dc.w 20,4,8
	dc.w 24,8,12
	dc.w 16,0,4	;
	dc.w 16,12,0
	dc.w 4,16,0
	dc.w 4,8,12
	dc.w 4,8,12


ObjFaceS_RGB_Plate1:
	dc.w 	1-1
	dc.w 	8-1
	dc.w 	1
	dc.w 	0
	dc.w	4
	dc.w 	4,8,8,12,12,0
	dc.w	16,20,20,24,24,28,28,16

ObjFaceS_RGB_Plate2:
	dc.w 	1-1
	dc.w 	8-1
	dc.w 	2
	dc.w 	0
	dc.w 	4
	dc.w 	4,8,8,12,12,0
	dc.w	16,20,20,24,24,28,28,16

ObjFaceS_RGB_Plate3:
	dc.w 	1-1
	dc.w	8-1
	dc.w 	4
	dc.w 	0
	dc.w 	4
	dc.w 	4,8,8,12,12,0
	dc.w	16,20,20,24,24,28,28,16


***************************************************************************
***	END OF FILE:	Vertex_1_03.s					***
***			The source code for Vertex-demo by Red Chrome	***
***************************************************************************
