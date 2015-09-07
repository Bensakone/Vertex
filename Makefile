AS=$(HOME)/src/vasm/vasmm68k_mot
FSUAE=fs-uae

Vertex2015: SOURCE/Vertex_1_04.s Makefile
	$(AS) -IINCLUDE -IEXTERN -ISND -ldots -kick1hunks -Fhunkexe -o $@ $<

run: Vertex2015
	cp Vertex2015 run
	$(FSUAE) fs-uae.config

.PHONY: run
