AS=toolchain/vasm/vasmm68k_mot
LD=toolchain/vlink/vlink
FSUAE=fs-uae
ASFLAGS=-IINCLUDE -IEXTERN -ISND -ldots -kick1hunks -Fhunk
LDFLAGS=-bamigahunk
OBJS=SOURCE/Vertex_1_04.o SOURCE/nt_replay.o

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $^

Vertex2015: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

run: Vertex2015
	cp Vertex2015 run
	$(FSUAE) fs-uae.config

clean:
	rm -f Vertex2015 run/Vertex2015

toolchain:
	make -C $@

.PHONY: run clean toolchain
