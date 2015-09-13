;;; Relevant library routines

	IFND	__LIBS_I__
__LIBS_I__	= 1

ExecBase		= 4

Exec_intvector_vbi	= $006c		; $54 + 4 * 6
Exec_intvector_ciab	= $0078		; $54 + 4 * 9

Exec_Supervisor		= -$01e
Exec_OldOpenLibrary	= -$198
Exec_CloseLibrary	= -$19e
Exec_OpenLibrary	= -$228

Gfx_copinit		= $0026

	ENDC
