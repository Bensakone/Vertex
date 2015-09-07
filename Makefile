AS=$(HOME)/src/vasm/vasmm68k_mot

Vertex2015: SOURCE/Vertex_1_04.s Makefile
	$(AS) -IINCLUDE -IEXTERN -ISND -ldots -kick1hunks -Fhunkexe -o $@ $<
