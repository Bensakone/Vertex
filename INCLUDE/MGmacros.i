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
***	© Copyright 1992/1993 Maverick & Great J***
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

; 1024:llä kerrotut sini- & cosinitaulukot by Great J

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
