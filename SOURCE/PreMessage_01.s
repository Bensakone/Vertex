***************************************************************************
***	Message for the Startup of pre-release version of Vertex	***
***	Great J in July 1993						***
***************************************************************************

	incdir	INC:
	include	exec/exec_lib.i
	include	libraries/dos_lib.i


Main:	movem.l	d1-a6,-(sp)

	move.l	4.w,a6			; open dos.library
	lea	dosname(pc),a1
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)
	tst.l	d0
	beq.s	.no_dos
	move.l	d0,a5

	jsr	_LVOOutput(a5)
	move.l	d0,d1
	beq.b	.close_dos

	lea	startupmessage(pc),a3
	move.l	a3,d2
.dw_search_end
	tst.b	(a3)+
	bne.b	.dw_search_end
	subq.l	#1,a3
	move.l	a3,d3
	sub.l	d2,d3
	jsr	_LVOWrite(a5)

.close_dos
	move.l	a5,a1
	jsr	_LVOCloseLibrary(a6)
.no_dos
	movem.l	(sp)+,d1-a6

	moveq.l	#0,d0			; no errors
	rts

dosname:	dc.b	"dos.library",0
startupmessage:
	dc.b	12,10
	dc.b	"   Well, NOW you've really got your hands onto something extremely rare...",10,10

	dc.b	"   VERTEX v1.04 Copyright (C) 1993 by RED CHROME",10
	dc.b	"   =============================================",10,10

	dc.b	"   Released at the Assembly '93 - the Second Phase",10,10
	
	dc.b	"   The unpacked version of Vertex requires a total of 468Kb memory",10
	dc.b	"   (58Kb Public & 410Kb Graphics), so it should run fine on standard",10
	dc.b	"   512Kb Amigas, too. The demo has been divided to several hunks to",10
	dc.b	"   minimize the need of Graphics memory and maximize the runability",10
	dc.b	"   also with fragmented memory.",10,10

	dc.b	"   The demo has been tested on various machines and systems and it",10
	dc.b	"   has proved NOT to be well compatible. If you're using an AGA",10
	dc.b	"   chipset, then reboot now and switch to OCS/ECS (if you are really",10
	dc.b	"   interested anymore...). Sorry! The demo should run fine on all",10
	dc.b	"   other machines...",10,10

	dc.b	"   By the way, if you for some weird reason want to put this demo on your",10
	dc.b	"   pack, there's a crunched version on this disk, too. Feel free to use it."
	dc.b	10,10,0

