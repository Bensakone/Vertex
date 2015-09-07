*************************************************************************
***									***
***	MGmacros.i							***
***	==========							***
***									***
***	Macro Include File for Amiga Hardware Assembly Programming	***
***	by Maverick and Great J of Red Chrome				***
***	(Originally based on MMacros.i by Maverick)			***
***									***
***	This macro include file is copyrighted by Maverick and	***
***	Great J. It may only be distributed in its original and	***
***	unmodified form. The macros may not be used in commercial	***
***	purposes without written permission from the authors.		***
***	The authors can not be made responsible for any damage the	***
***	usage of the macros may cause.					***
***	The playroutines are copyrighted by Mahoney & Kaktus, but	***
***	they have been slightly modified by the authors of this file.	***
***									***
***	ฉ Copyright 1992/1993 Maverick & Great J***
***	All Rights Reserved						***
***									***
***									***
***	MMacros.i v1.0 Created by TK 280992				***
***									***
***	Edited:								***
***	061092	- added NoisetrackerV2.0 replay routine			***
***	121092	- added playroutine (so many sources needed it...)	***
***	121092	- replayroutine is now NoisetrackerV2.0 		***
***	201092	- Protracker1.1B Cia playroutine added			***
***									***
***									***
***	Edited by Great J:	=> MGmacros.i v0.01			***
***	050193	v0.01	- NoisetrackerV1.0 replay routine removed.	***
***			- Duplicate of NoisetrackerV2.0 replay routine	***
***			  removed. (macro used instead.)		***
***			- Better outlook in examples/autodocs		***
***	060193	v0.02	- BSS-Stack utility macros added.		***
***									***
***	Edited by Maverick:						***
***	200193	v0.03	- Some modifications in BSS-Stack(tm) utility:	***
***			  - Names were changed to dw and dl instead of 	***
***			    word and long (I like shorter names...) but	***
***			    you can use the old names if you like...	***
***			  - Macro accepts now nine variable names in 	***
***			    line, not only one!				***
***	Edited by Great J:						***
***	270193	v0.04	- long / word ported to dl / dw. They now work	***
***			  with 9 args, too. (I like compatibility...)	***
***			- PT 1.1b replay routine fixed a bit:		***
***			  - a '_' removed before LVOCloseLibrary.	***
***			  - GfxName renamed to mt_GfxName.		***
***			    (ALL sources used the name already...)	***
***									***
***	Edited by Maverick & Great J:					***
***	280293	v0.05	- cleaned up a bit:				***
***			  - Protracker replay removed.			***
***			  - long & word removed.			***
***			  - playroutine removed.			***
***			  - some labels localized.			***
***			  - some labels renamed in SinCosTable.		***
***									***
***	Edited by Great J:						***
***	010393	v0.06	- calculated the cpu time usage in ticks for	***
***			  most of the macro routines. In Wait-type of	***
***			  macros time is the shortest possible time.	***
***									***
***	Edited by Maverick:						***
***	060493	v0.07	- Added macros NoisetrackerV2.0_V and		***
***			  NoisetrackerV2.0_Variables			***
***			  - playroutine and variables are now separated	***
***			    in two diffenrent hunks => OS friendly!	***
***			- playroutines modified a bit:			***
***			  - all clr.X's to HW registers were changed	***
***			    to move.X #0,dest				***
***									***
***	Edited by Maverick:						***
***	300593	v0.08	- Added JoyButton macro				***
***									***
***	Edited by Maverick & Great J:					***
***	130693	v0.09	- Docs & Copyright notices edited		***
***									***
***									***
***									***
***************************************************************************


* DOCUMENTATION FOR THE MACROS:
* -----------------------------

* MACRO:	TICKS:	  PURPOSE:

* NastyON	16	- Set dmacon bit 10 (CPU cycles stolen by the blitter).
* NastyOFF	16	- Clear dmacon bit 10 (No CPU cycles stolen).
* WaitB		28	- Wait blitter done.
* WaitRMB	24	- Wait until right mouse button pressed.
* LeftMouse	24	- Test left mouse button. If pressed, Z=1.
* RightMouse	24	- Test right mouse button. If pressed, Z=1.
* JoyButton	24	- Test joystick button
* Alloc_Stack		- Memory allocation macro for bss-stack.
* SinCosTable		- Sine & Cosine tables.
* NoiseTrackerV2.0	- NoiseTracker v2.0 playroutine.
* DW			- Define new word size stack variable. E.g. "dw foo".
*			  Max. 9 names		
* DL			- Define new long size stack variable. E.g. "dl foo".
*			  Max. 9 names

* THE MACROS:
* -----------

WaitB:		MACRO
.wb\@:		btst	#14,dmaconr(a6)
		bne.s	.wb\@
		ENDM

NastyOFF: 	MACRO
		move.w	#%0000010000000000,dmacon(a6)
		ENDM

NastyON: 	MACRO
		move.w	#%1000010000000000,dmacon(a6)
		ENDM

WaitRMB: 	MACRO
.wr\@:		btst	#10,$16(a6)
		bne.s	.wr\@
		ENDM

LeftMouse:	MACRO
		btst	#6,$bfe001
		ENDM

RightMouse:	MACRO
		btst	#10,$16(a6)
		ENDM

JoyButton:	MACRO
		btst	#7,$bfe001
		ENDM

; macros dw & dl by Maverick in January 1993 (Based on the idea by Great J)

BSS_STACK_SIZE	SET 0
STAGP	SET 0

dw:	MACRO
	IFNE	\?1
STAGP	SET STAGP-2
\1	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+2
	ENDC
	IFNE	\?2
STAGP	SET STAGP-2
\2	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+2
	ENDC
	IFNE	\?3
STAGP	SET STAGP-2
\3	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+2
	ENDC
	IFNE	\?4
STAGP	SET STAGP-2
\4	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+2
	ENDC
	IFNE	\?5
STAGP	SET STAGP-2
\5	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+2
	ENDC
	IFNE	\?6
STAGP	SET STAGP-2
\6	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+2
	ENDC
	IFNE	\?7
STAGP	SET STAGP-2
\7	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+2
	ENDC
	IFNE	\?8
STAGP	SET STAGP-2
\8	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+2
	ENDC
	IFNE	\?9
STAGP	SET STAGP-2
\9	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+2
	ENDC
	ENDM

dl:	MACRO
	IFNE	\?1
STAGP	SET STAGP-4
\1	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+4
	ENDC
	IFNE	\?2
STAGP	SET STAGP-4
\2	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+4
	ENDC
	IFNE	\?3
STAGP	SET STAGP-4
\3	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+4
	ENDC
	IFNE	\?4
STAGP	SET STAGP-4
\4	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+4
	ENDC
	IFNE	\?5
STAGP	SET STAGP-4
\5	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+4
	ENDC
	IFNE	\?6
STAGP	SET STAGP-4
\6	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+4
	ENDC
	IFNE	\?7
STAGP	SET STAGP-4
\7	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+4
	ENDC
	IFNE	\?8
STAGP	SET STAGP-4
\8	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+4
	ENDC
	IFNE	\?9
STAGP	SET STAGP-4
\9	SET STAGP
BSS_STACK_SIZE	SET BSS_STACK_SIZE+4
	ENDC
	ENDM

Alloc_Stack: 	MACRO
Stakki:		ds.b	BSS_STACK_SIZE
Bss_Stack:
		ENDM

; 1024:llไ kerrotut sini- & cosinitaulukot by Great J

SinCosTable: MACRO
SinTable:

		* sin	0 - 89
	dc.w	0000,0018,0036,0054,0071,0089,0107,0125,0143,0160
	dc.w	0178,0195,0213,0230,0248,0265,0282,0299,0316,0333
	dc.w	0350,0367,0384,0400,0416,0433,0449,0465,0481,0496
	dc.w	0512,0527,0543,0558,0573,0587,0602,0616,0630,0644
	dc.w	0658,0672,0685,0698,0711,0724,0737,0749,0761,0773
	dc.w	0784,0796,0807,0818,0828,0839,0849,0859,0868,0878
	dc.w	0887,0896,0904,0912,0920,0928,0935,0943,0949,0956
	dc.w	0962,0968,0974,0979,0984,0989,0994,0998,1002,1005
	dc.w	1008,1011,1014,1016,1018,1020,1022,1023,1023,1024

CosTable:

		* sin	90 - 179
		* cos	0 - 89
	dc.w	1024,1024,1023,1023,1022,1020,1018,1016,1014,1011
	dc.w	1008,1005,1002,0998,0994,0989,0984,0979,0978,0968
	dc.w	0962,0956,0949,0943,0935,0928,0920,0912,0904,0896
	dc.w	0887,0878,0868,0859,0849,0839,0828,0818,0807,0796
	dc.w	0784,0773,0761,0749,0737,0724,0711,0698,0685,0672
	dc.w	0658,0644,0630,0616,0602,0587,0573,0558,0543,0527
	dc.w	0512,0496,0481,0465,0449,0433,0416,0400,0384,0367
	dc.w	0350,0333,0316,0299,0282,0265,0248,0230,0213,0195
	dc.w	0178,0160,0143,0125,0107,0089,0071,0054,0036,0018

		* sin	180 - 269
		* cos	90 - 179
	dc.w	 0000,-0018,-0036,-0054,-0071,-0089,-0107,-0125,-0143,-0160
	dc.w	-0178,-0195,-0213,-0230,-0248,-0265,-0282,-0299,-0316,-0333
	dc.w	-0350,-0367,-0384,-0400,-0416,-0433,-0449,-0465,-0481,-0496
	dc.w	-0512,-0527,-0543,-0558,-0573,-0587,-0602,-0616,-0630,-0644
	dc.w	-0658,-0672,-0685,-0698,-0711,-0724,-0737,-0749,-0761,-0773
	dc.w	-0784,-0796,-0807,-0818,-0828,-0839,-0849,-0859,-0868,-0878
	dc.w	-0887,-0896,-0904,-0912,-0920,-0928,-0935,-0943,-0949,-0956
	dc.w	-0962,-0968,-0974,-0979,-0984,-0989,-0994,-0998,-1002,-1005
	dc.w	-1008,-1011,-1014,-1016,-1018,-1020,-1022,-1023,-1023,-1024

		* sin	270 - 359
		* cos	180 - 269
	dc.w	-1024,-1024,-1023,-1023,-1022,-1020,-1018,-1016,-1014,-1011
	dc.w	-1008,-1005,-1002,-0998,-0994,-0989,-0984,-0979,-0978,-0968
	dc.w	-0962,-0956,-0949,-0943,-0935,-0928,-0920,-0912,-0904,-0896
	dc.w	-0887,-0878,-0868,-0859,-0849,-0839,-0828,-0818,-0807,-0796
	dc.w	-0784,-0773,-0761,-0749,-0737,-0724,-0711,-0698,-0685,-0672
	dc.w	-0658,-0644,-0630,-0616,-0602,-0587,-0573,-0558,-0543,-0527
	dc.w	-0512,-0496,-0481,-0465,-0449,-0433,-0416,-0400,-0384,-0367
	dc.w	-0350,-0333,-0316,-0299,-0282,-0265,-0248,-0230,-0213,-0195
	dc.w	-0178,-0160,-0143,-0125,-0107,-0089,-0071,-0054,-0036,-0018

		* sin	360 -
		* cos	270 - 359
	dc.w	0000,0018,0036,0054,0071,0089,0107,0125,0143,0160
	dc.w	0178,0195,0213,0230,0248,0265,0282,0299,0316,0333
	dc.w	0350,0367,0384,0400,0416,0433,0449,0465,0481,0496
	dc.w	0512,0527,0543,0558,0573,0587,0602,0616,0630,0644
	dc.w	0658,0672,0685,0698,0711,0724,0737,0749,0761,0773
	dc.w	0784,0796,0807,0818,0828,0839,0849,0859,0868,0878
	dc.w	0887,0896,0904,0912,0920,0928,0935,0943,0949,0956
	dc.w	0962,0968,0974,0979,0984,0989,0994,0998,1002,1005
	dc.w	1008,1011,1014,1016,1018,1020,1022,1023,1023,1024

		* cos	360
	dc.w	0000

	ENDM

NoisetrackerV2.0: MACRO

;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
;ญ   NoisetrackerV2.0 Normal replay   ญ
;ญ     Uses registers d0-d3/a0-a5     ญ
;ญ Mahoney & Kaktus - (C) E.A.S. 1990 ญ
;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
mt_init:movem.l	d0-d2/a0-a2,-(a7)
	lea	mt_data,a0
	lea	$3b8(a0),a1
	moveq	#$7f,d0
	moveq	#0,d2
	moveq	#0,d1
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	mt_lop
	move.l	d1,d2
mt_lop:	dbf	d0,mt_lop2
	addq.b	#1,d2

	asl.l	#8,d2
	asl.l	#2,d2
	lea	4(a1,d2.l),a2
	lea	mt_samplestarts(pc),a1
	add.w	#42,a0
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#2,$bfe001
	move.b	#6,mt_speed
	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	movem.l	(a7)+,d0-d2/a0-a2
	rts

mt_end:	move.w	#0,$dff0a8
	move.w	#0,$dff0b8
	move.w	#0,$dff0c8
	move.w	#0,$dff0d8
	move.w	#$f,$dff096
	rts


mt_music:
	movem.l	d0-d3/a0-a5,-(a7)
	lea	mt_data,a0
	addq.b	#1,mt_counter
	move.b	mt_counter(pc),d0
	cmp.b	mt_speed(pc),d0
	blt	mt_nonew
	clr.b	mt_counter

	lea	mt_data,a0
	lea	$c(a0),a3
	lea	$3b8(a0),a2
	lea	$43c(a0),a0

	moveq	#0,d0
	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a2,d0.w),d1
	lsl.w	#8,d1
	lsl.w	#2,d1
	add.w	mt_pattpos(pc),d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(pc),a4
	bsr	mt_playvoice
	addq.l	#4,d1
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a4
	bsr	mt_playvoice
	addq.l	#4,d1
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a4
	bsr	mt_playvoice
	addq.l	#4,d1
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a4
	bsr	mt_playvoice

	move.w	mt_dmacon(pc),d0
	beq.s	mt_nodma

	bsr	mt_wait
	or.w	#$8000,d0
	move.w	d0,$dff096
	bsr	mt_wait
mt_nodma:
	lea	mt_voice1(pc),a4
	lea	$dff000,a3
	move.l	$a(a4),$a0(a3)
	move.w	$e(a4),$a4(a3)
	move.l	$a+$1c(a4),$b0(a3)
	move.w	$e+$1c(a4),$b4(a3)
	move.l	$a+$38(a4),$c0(a3)
	move.w	$e+$38(a4),$c4(a3)
	move.l	$a+$54(a4),$d0(a3)
	move.w	$e+$54(a4),$d4(a3)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_exit
mt_next:clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	-2(a2),d0
	cmp.b	mt_songpos(pc),d0
	bne.s	mt_exit
	move.b	-1(a2),mt_songpos
mt_exit:tst.b	mt_break
	bne.s	mt_next
	movem.l	(a7)+,d0-d3/a0-a5
	rts

mt_wait:moveq	#3,d3
mt_wai2:move.b	$dff006,d2
mt_wai3:cmp.b	$dff006,d2
	beq.s	mt_wai3
	dbf	d3,mt_wai2
	moveq	#8,d2
mt_wai4:dbf	d2,mt_wai4
	rts

mt_nonew:
	lea	mt_voice1(pc),a4
	lea	$dff0a0,a5
	bsr	mt_com
	lea	mt_voice2(pc),a4
	lea	$dff0b0,a5
	bsr	mt_com
	lea	mt_voice3(pc),a4
	lea	$dff0c0,a5
	bsr	mt_com
	lea	mt_voice4(pc),a4
	lea	$dff0d0,a5
	bsr	mt_com
	bra.s	mt_exit

mt_mulu:
	dc.w $000,$01e,$03c,$05a,$078,$096,$0b4,$0d2,$0f0,$10e,$12c,$14a
	dc.w $168,$186,$1a4,$1c2,$1e0,$1fe,$21c,$23a,$258,$276,$294,$2b2
	dc.w $2d0,$2ee,$30c,$32a,$348,$366,$384,$3a2

mt_playvoice:
	move.l	(a0,d1.l),(a4)
	moveq	#0,d2
	move.b	2(a4),d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$f0,d0
	or.b	d0,d2
	beq.s	mt_oldinstr

	lea	mt_samplestarts-4(pc),a1
	asl.w	#2,d2
	move.l	(a1,d2.l),4(a4)
	lsr.w	#1,d2
	move.w	mt_mulu(pc,d2.w),d2
	move.w	(a3,d2.w),8(a4)
	move.w	2(a3,d2.w),$12(a4)
	moveq	#0,d3
	move.w	4(a3,d2.w),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	4(a4),d0
	asl.w	#1,d3
	add.l	d3,d0
	move.l	d0,$a(a4)
	move.w	4(a3,d2.w),d0
	add.w	6(a3,d2.w),d0
	move.w	d0,8(a4)
	bra.s	mt_hejaSverige
mt_noloop:
	move.l	4(a4),d0
	add.l	d3,d0
	move.l	d0,$a(a4)
mt_hejaSverige:
	move.w	6(a3,d2.w),$e(a4)
	moveq	#0,d0
	move.b	$13(a4),d0
	move.w	d0,8(a5)

mt_oldinstr:
	move.w	(a4),d0
	and.w	#$fff,d0
	beq	mt_com2
	tst.w	8(a4)
	beq.s	mt_stopsound
	tst.b	$12(a4)
	bne.s	mt_stopsound
	move.b	2(a4),d0
	and.b	#$f,d0
	cmp.b	#5,d0
	beq.s	mt_setport
	cmp.b	#3,d0
	beq.s	mt_setport

	move.w	(a4),$10(a4)
	and.w	#$fff,$10(a4)
	move.w	$1a(a4),$dff096
	clr.b	$19(a4)

	move.l	4(a4),(a5)
	move.w	8(a4),4(a5)
	move.w	$10(a4),6(a5)

	move.w	$1a(a4),d0	;dmaset
	or.w	d0,mt_dmacon
	bra	mt_com2

mt_stopsound:
	move.w	$1a(a4),$dff096
	bra	mt_com2

mt_setport:
	move.w	(a4),d2
	and.w	#$fff,d2
	move.w	d2,$16(a4)
	move.w	$10(a4),d0
	clr.b	$14(a4)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge	mt_com2
	move.b	#1,$14(a4)
	bra	mt_com2
mt_clrport:
	clr.w	$16(a4)
	rts

mt_port:move.b	3(a4),d0
	beq.s	mt_port2
	move.b	d0,$15(a4)
	clr.b	3(a4)
mt_port2:
	tst.w	$16(a4)
	beq.s	mt_rts
	moveq	#0,d0
	move.b	$15(a4),d0
	tst.b	$14(a4)
	bne.s	mt_sub
	add.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
mt_portok:
	move.w	$10(a4),6(a5)
mt_rts:	rts

mt_sub:	sub.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	blt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
	move.w	$10(a4),6(a5)
	rts

mt_sin:
	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_vib:	move.b	$3(a4),d0
	beq.s	mt_vib2
	move.b	d0,$18(a4)

mt_vib2:move.b	$19(a4),d0
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	mt_sin(pc,d0.w),d2
	move.b	$18(a4),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	$10(a4),d0
	tst.b	$19(a4)
	bmi.s	mt_vibsub
	add.w	d2,d0
	bra.s	mt_vib3
mt_vibsub:
	sub.w	d2,d0
mt_vib3:move.w	d0,6(a5)
	move.b	$18(a4),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,$19(a4)
	rts


mt_arplist:
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

mt_arp:	moveq	#0,d0
	move.b	mt_counter(pc),d0
	move.b	mt_arplist(pc,d0.w),d0
	beq.s	mt_arp0
	cmp.b	#2,d0
	beq.s	mt_arp2
mt_arp1:moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	bra.s	mt_arpdo
mt_arp2:moveq	#0,d0
	move.b	3(a4),d0
	and.b	#$f,d0
mt_arpdo:
	asl.w	#1,d0
	move.w	$10(a4),d1
	and.w	#$fff,d1
	lea	mt_periods(pc),a0
	moveq	#$24,d2
mt_arp3:cmp.w	(a0)+,d1
	bge.s	mt_arpfound
	dbf	d2,mt_arp3
mt_arp0:move.w	$10(a4),6(a5)
	rts
mt_arpfound:
	move.w	-2(a0,d0.w),6(a5)
	rts

mt_normper:
	move.w	$10(a4),6(a5)
	rts

mt_com:	move.w	2(a4),d0
	and.w	#$fff,d0
	beq.s	mt_normper
	move.b	2(a4),d0
	and.b	#$f,d0
	tst.b	d0
	beq.s	mt_arp
	cmp.b	#1,d0
	beq.s	mt_portup
	cmp.b	#2,d0
	beq.s	mt_portdown
	cmp.b	#3,d0
	beq	mt_port
	cmp.b	#4,d0
	beq	mt_vib
	cmp.b	#5,d0
	beq.s	mt_volport
	cmp.b	#6,d0
	beq.s	mt_volvib
	move.w	$10(a4),6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$71,d0
	bpl.s	mt_portup2
	move.w	#$71,$10(a4)
mt_portup2:
	move.w	$10(a4),6(a5)
	rts

mt_portdown:
	moveq	#0,d0
	move.b	3(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$358,d0
	bmi.s	mt_portdown2
	move.w	#$358,$10(a4)
mt_portdown2:
	move.w	$10(a4),6(a5)
	rts

mt_volvib:
	 bsr	mt_vib2
	 bra.s	mt_volslide
mt_volport:
	 bsr	mt_port2

mt_volslide:
	moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	beq.s	mt_vol3
	add.b	d0,$13(a4)
	cmp.b	#$40,$13(a4)
	bmi.s	mt_vol2
	move.b	#$40,$13(a4)
mt_vol2:moveq	#0,d0
	move.b	$13(a4),d0
	move.w	d0,8(a5)
	rts

mt_vol3:move.b	3(a4),d0
	and.b	#$f,d0
	sub.b	d0,$13(a4)
	bpl.s	mt_vol4
	clr.b	$13(a4)
mt_vol4:moveq	#0,d0
	move.b	$13(a4),d0
	move.w	d0,8(a5)
	rts

mt_com2:move.b	$2(a4),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_filter
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_songjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_filter:
	move.b	3(a4),d0
	and.b	#1,d0
	asl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_pattbreak:
	move.b	#1,mt_break
	rts

mt_songjmp:
	move.b	#1,mt_break
	move.b	3(a4),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos
	rts

mt_setvol:
	cmp.b	#$40,3(a4)
	bls.s	mt_sv2
	move.b	#$40,3(a4)
mt_sv2:	moveq	#0,d0
	move.b	3(a4),d0
	move.b	d0,$13(a4)
	move.w	d0,8(a5)
	rts

mt_setspeed:
	moveq	#0,d0
	move.b	3(a4),d0
	cmp.b	#$1f,d0
	bls.s	mt_sp2
	moveq	#$1f,d0
mt_sp2:	tst.w	d0
	bne.s	mt_sp3
	moveq	#1,d0
mt_sp3:	move.b	d0,mt_speed
	rts

mt_periods:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
	dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
	dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
	dc.w $007f,$0078,$0071,$0000

mt_speed:	dc.b	6
mt_counter:	dc.b	0
mt_pattpos:	dc.w	0
mt_songpos:	dc.b	0
mt_break:	dc.b	0
mt_dmacon:	dc.w	0
mt_samplestarts:blk.l	$1f,0
mt_voice1:	blk.w	13,0
		dc.w	1
mt_voice2:	blk.w	13,0
		dc.w	2
mt_voice3:	blk.w	13,0
		dc.w	4
mt_voice4:	blk.w	13,0
		dc.w	8
	ENDM




NoisetrackerV2.0_V: MACRO

;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
;ญ   NoisetrackerV2.0 Normal replay   ญ
;ญ     Uses registers d0-d3/a0-a5     ญ
;ญ Mahoney & Kaktus - (C) E.A.S. 1990 ญ
;ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
mt_init:movem.l	d0-d2/a0-a2,-(a7)
	lea	mt_data,a0
	lea	$3b8(a0),a1
	moveq	#$7f,d0
	moveq	#0,d2
	moveq	#0,d1
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	ble.s	mt_lop
	move.l	d1,d2
mt_lop:	dbf	d0,mt_lop2
	addq.b	#1,d2

	asl.l	#8,d2
	asl.l	#2,d2
	lea	4(a1,d2.l),a2
	lea	mt_samplestarts,a1
	add.w	#42,a0
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#2,$bfe001
	move.b	#6,mt_speed
	moveq	#0,d0
	lea	$dff000,a0
	move.w	d0,$a8(a0)
	move.w	d0,$b8(a0)
	move.w	d0,$c8(a0)
	move.w	d0,$d8(a0)
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	movem.l	(a7)+,d0-d2/a0-a2
	rts

mt_end:	move.w	#0,$dff0a8
	move.w	#0,$dff0b8
	move.w	#0,$dff0c8
	move.w	#0,$dff0d8
	move.w	#$f,$dff096
	rts


mt_music:
	movem.l	d0-d3/a0-a5,-(a7)
	lea	mt_data,a0
	addq.b	#1,mt_counter
	move.b	mt_counter,d0
	cmp.b	mt_speed,d0
	blt	mt_nonew
	clr.b	mt_counter

	lea	mt_data,a0
	lea	$c(a0),a3
	lea	$3b8(a0),a2
	lea	$43c(a0),a0

	moveq	#0,d0
	moveq	#0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	lsl.w	#8,d1
	lsl.w	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1,a4
	bsr	mt_playvoice
	addq.l	#4,d1
	lea	$dff0b0,a5
	lea	mt_voice2,a4
	bsr	mt_playvoice
	addq.l	#4,d1
	lea	$dff0c0,a5
	lea	mt_voice3,a4
	bsr	mt_playvoice
	addq.l	#4,d1
	lea	$dff0d0,a5
	lea	mt_voice4,a4
	bsr	mt_playvoice

	move.w	mt_dmacon,d0
	beq.s	mt_nodma

	bsr	mt_wait
	or.w	#$8000,d0
	move.w	d0,$dff096
	bsr	mt_wait
mt_nodma:
	lea	mt_voice1,a4
	lea	$dff000,a3
	move.l	$a(a4),$a0(a3)
	move.w	$e(a4),$a4(a3)
	move.l	$a+$1c(a4),$b0(a3)
	move.w	$e+$1c(a4),$b4(a3)
	move.l	$a+$38(a4),$c0(a3)
	move.w	$e+$38(a4),$c4(a3)
	move.l	$a+$54(a4),$d0(a3)
	move.w	$e+$54(a4),$d4(a3)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_exit
mt_next:clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	-2(a2),d0
	cmp.b	mt_songpos,d0
	bne.s	mt_exit
	move.b	-1(a2),mt_songpos
mt_exit:tst.b	mt_break
	bne.s	mt_next
	movem.l	(a7)+,d0-d3/a0-a5
	rts

mt_wait:moveq	#3,d3
mt_wai2:move.b	$dff006,d2
mt_wai3:cmp.b	$dff006,d2
	beq.s	mt_wai3
	dbf	d3,mt_wai2
	moveq	#8,d2
mt_wai4:dbf	d2,mt_wai4
	rts

mt_nonew:
	lea	mt_voice1,a4
	lea	$dff0a0,a5
	bsr	mt_com
	lea	mt_voice2,a4
	lea	$dff0b0,a5
	bsr	mt_com
	lea	mt_voice3,a4
	lea	$dff0c0,a5
	bsr	mt_com
	lea	mt_voice4,a4
	lea	$dff0d0,a5
	bsr	mt_com
	bra.s	mt_exit

mt_mulu:
	dc.w $000,$01e,$03c,$05a,$078,$096,$0b4,$0d2,$0f0,$10e,$12c,$14a
	dc.w $168,$186,$1a4,$1c2,$1e0,$1fe,$21c,$23a,$258,$276,$294,$2b2
	dc.w $2d0,$2ee,$30c,$32a,$348,$366,$384,$3a2

mt_playvoice:
	move.l	(a0,d1.l),(a4)
	moveq	#0,d2
	move.b	2(a4),d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$f0,d0
	or.b	d0,d2
	beq.s	mt_oldinstr

	lea	mt_samplestarts-4,a1
	asl.w	#2,d2
	move.l	(a1,d2.l),4(a4)
	lsr.w	#1,d2
	move.w	mt_mulu(pc,d2.w),d2
	move.w	(a3,d2.w),8(a4)
	move.w	2(a3,d2.w),$12(a4)
	moveq	#0,d3
	move.w	4(a3,d2.w),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	4(a4),d0
	asl.w	#1,d3
	add.l	d3,d0
	move.l	d0,$a(a4)
	move.w	4(a3,d2.w),d0
	add.w	6(a3,d2.w),d0
	move.w	d0,8(a4)
	bra.s	mt_hejaSverige
mt_noloop:
	move.l	4(a4),d0
	add.l	d3,d0
	move.l	d0,$a(a4)
mt_hejaSverige:
	move.w	6(a3,d2.w),$e(a4)
	moveq	#0,d0
	move.b	$13(a4),d0
	move.w	d0,8(a5)

mt_oldinstr:
	move.w	(a4),d0
	and.w	#$fff,d0
	beq	mt_com2
	tst.w	8(a4)
	beq.s	mt_stopsound
	tst.b	$12(a4)
	bne.s	mt_stopsound
	move.b	2(a4),d0
	and.b	#$f,d0
	cmp.b	#5,d0
	beq.s	mt_setport
	cmp.b	#3,d0
	beq.s	mt_setport

	move.w	(a4),$10(a4)
	and.w	#$fff,$10(a4)
	move.w	$1a(a4),$dff096
	clr.b	$19(a4)

	move.l	4(a4),(a5)
	move.w	8(a4),4(a5)
	move.w	$10(a4),6(a5)

	move.w	$1a(a4),d0	;dmaset
	or.w	d0,mt_dmacon
	bra	mt_com2

mt_stopsound:
	move.w	$1a(a4),$dff096
	bra	mt_com2

mt_setport:
	move.w	(a4),d2
	and.w	#$fff,d2
	move.w	d2,$16(a4)
	move.w	$10(a4),d0
	clr.b	$14(a4)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge	mt_com2
	move.b	#1,$14(a4)
	bra	mt_com2
mt_clrport:
	clr.w	$16(a4)
	rts

mt_port:move.b	3(a4),d0
	beq.s	mt_port2
	move.b	d0,$15(a4)
	clr.b	3(a4)
mt_port2:
	tst.w	$16(a4)
	beq.s	mt_rts
	moveq	#0,d0
	move.b	$15(a4),d0
	tst.b	$14(a4)
	bne.s	mt_sub
	add.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
mt_portok:
	move.w	$10(a4),6(a5)
mt_rts:	rts

mt_sub:	sub.w	d0,$10(a4)
	move.w	$16(a4),d0
	cmp.w	$10(a4),d0
	blt.s	mt_portok
	move.w	$16(a4),$10(a4)
	clr.w	$16(a4)
	move.w	$10(a4),6(a5)
	rts

mt_sin:
	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_vib:	move.b	$3(a4),d0
	beq.s	mt_vib2
	move.b	d0,$18(a4)

mt_vib2:move.b	$19(a4),d0
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	mt_sin(pc,d0.w),d2
	move.b	$18(a4),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w	$10(a4),d0
	tst.b	$19(a4)
	bmi.s	mt_vibsub
	add.w	d2,d0
	bra.s	mt_vib3
mt_vibsub:
	sub.w	d2,d0
mt_vib3:move.w	d0,6(a5)
	move.b	$18(a4),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,$19(a4)
	rts


mt_arplist:
	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

mt_arp:	moveq	#0,d0
	move.b	mt_counter,d0
	move.b	mt_arplist(pc,d0.w),d0
	beq.s	mt_arp0
	cmp.b	#2,d0
	beq.s	mt_arp2
mt_arp1:moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	bra.s	mt_arpdo
mt_arp2:moveq	#0,d0
	move.b	3(a4),d0
	and.b	#$f,d0
mt_arpdo:
	asl.w	#1,d0
	move.w	$10(a4),d1
	and.w	#$fff,d1
	lea	mt_periods(pc),a0
	moveq	#$24,d2
mt_arp3:cmp.w	(a0)+,d1
	bge.s	mt_arpfound
	dbf	d2,mt_arp3
mt_arp0:move.w	$10(a4),6(a5)
	rts
mt_arpfound:
	move.w	-2(a0,d0.w),6(a5)
	rts

mt_normper:
	move.w	$10(a4),6(a5)
	rts

mt_com:	move.w	2(a4),d0
	and.w	#$fff,d0
	beq.s	mt_normper
	move.b	2(a4),d0
	and.b	#$f,d0
	tst.b	d0
	beq.s	mt_arp
	cmp.b	#1,d0
	beq.s	mt_portup
	cmp.b	#2,d0
	beq.s	mt_portdown
	cmp.b	#3,d0
	beq	mt_port
	cmp.b	#4,d0
	beq	mt_vib
	cmp.b	#5,d0
	beq.s	mt_volport
	cmp.b	#6,d0
	beq.s	mt_volvib
	move.w	$10(a4),6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_portup:
	moveq	#0,d0
	move.b	3(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$71,d0
	bpl.s	mt_portup2
	move.w	#$71,$10(a4)
mt_portup2:
	move.w	$10(a4),6(a5)
	rts

mt_portdown:
	moveq	#0,d0
	move.b	3(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	cmp.w	#$358,d0
	bmi.s	mt_portdown2
	move.w	#$358,$10(a4)
mt_portdown2:
	move.w	$10(a4),6(a5)
	rts

mt_volvib:
	 bsr	mt_vib2
	 bra.s	mt_volslide
mt_volport:
	 bsr	mt_port2

mt_volslide:
	moveq	#0,d0
	move.b	3(a4),d0
	lsr.b	#4,d0
	beq.s	mt_vol3
	add.b	d0,$13(a4)
	cmp.b	#$40,$13(a4)
	bmi.s	mt_vol2
	move.b	#$40,$13(a4)
mt_vol2:moveq	#0,d0
	move.b	$13(a4),d0
	move.w	d0,8(a5)
	rts

mt_vol3:move.b	3(a4),d0
	and.b	#$f,d0
	sub.b	d0,$13(a4)
	bpl.s	mt_vol4
	clr.b	$13(a4)
mt_vol4:moveq	#0,d0
	move.b	$13(a4),d0
	move.w	d0,8(a5)
	rts

mt_com2:move.b	$2(a4),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_filter
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_songjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_filter:
	move.b	3(a4),d0
	and.b	#1,d0
	asl.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_pattbreak:
	move.b	#1,mt_break
	rts

mt_songjmp:
	move.b	#1,mt_break
	move.b	3(a4),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos
	rts

mt_setvol:
	cmp.b	#$40,3(a4)
	bls.s	mt_sv2
	move.b	#$40,3(a4)
mt_sv2:	moveq	#0,d0
	move.b	3(a4),d0
	move.b	d0,$13(a4)
	move.w	d0,8(a5)
	rts

mt_setspeed:
	moveq	#0,d0
	move.b	3(a4),d0
	cmp.b	#$1f,d0
	bls.s	mt_sp2
	moveq	#$1f,d0
mt_sp2:	tst.w	d0
	bne.s	mt_sp3
	moveq	#1,d0
mt_sp3:	move.b	d0,mt_speed
	rts

mt_periods:
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
	dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
	dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
	dc.w $007f,$0078,$0071,$0000

	ENDM

NoisetrackerV2.0_Variables: MACRO


mt_speed:	dc.b	6
mt_counter:	dc.b	0
mt_pattpos:	dc.w	0
mt_songpos:	dc.b	0
mt_break:	dc.b	0
mt_dmacon:	dc.w	0
mt_samplestarts:blk.l	$1f,0
mt_voice1:	blk.w	13,0
		dc.w	1
mt_voice2:	blk.w	13,0
		dc.w	2
mt_voice3:	blk.w	13,0
		dc.w	4
mt_voice4:	blk.w	13,0
		dc.w	8
	ENDM

