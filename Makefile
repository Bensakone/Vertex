AS=toolchain/vasm/vasmm68k_mot
LD=toolchain/vlink/vlink
FSUAE=fs-uae
ASFLAGS=-IINCLUDE -IEXTERN -ISND -ldots -kick1hunks -Fhunk
LDFLAGS=-bamigahunk
OBJS=SOURCE/Vertex_1_04.o SOURCE/nt_replay.o

# Debugging options. For example, 'make PART=4 RASTERTIME=1'
ifdef PART
	ASFLAGS+=-DPART=$(PART)
endif
ifdef RASTERTIME
	ASFLAGS+=-DRASTERTIME=$(RASTERTIME)
endif

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

Vertex2015: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

# Magic to cause rebuild on flags changes
OPTDEPS=$(AS) $(ASFLAGS) $(LD) $(LDFLAGS)
$(OBJS): .optdeps
.optdeps: force
	@echo "$(OPTDEPS)" | cmp -s - $@ || echo "$(OPTDEPS)" > $@

run: Vertex2015
	cp Vertex2015 run
	$(FSUAE) fs-uae.config

clean:
	rm -f Vertex2015 run/Vertex2015 $(OBJS) .optdeps

toolchain:
	make -C $@

.PHONY: run clean toolchain force
