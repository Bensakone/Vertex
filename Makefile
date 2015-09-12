AS=toolchain/vasm/vasmm68k_mot
LD=toolchain/vlink/vlink
FSUAE=fs-uae

Vertex2015: SOURCE/Vertex_1_04.s Makefile
	$(AS) -IINCLUDE -IEXTERN -ISND -ldots -kick1hunks -Fhunkexe -o $@ $<

run: Vertex2015
	cp Vertex2015 run
	$(FSUAE) fs-uae.config

clean:
	rm -f Vertex2015 run/Vertex2015

toolchain:
	make -C $@

.PHONY: run clean toolchain
