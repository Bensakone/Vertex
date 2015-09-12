
all: vasm/vasmm68k_mot vlink/vlink

vasm.tar.gz:
	wget http://sun.hasenbraten.de/vasm/release/vasm.tar.gz

vasm: vasm.tar.gz
	tar axf $<

vasm/vasmm68k_mot: vasm
	make -C vasm CPU=m68k SYNTAX=mot

vlink.tar.gz:
	wget http://sun.hasenbraten.de/vlink/release/vlink.tar.gz

vlink: vlink.tar.gz
	tar axf $<

vlink/vlink: vlink
	mkdir -p vlink/objects
	make -C vlink CPU=m68k
