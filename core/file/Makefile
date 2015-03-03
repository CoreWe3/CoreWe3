ROOT = $(shell git rev-parse --show-toplevel)
AS = $(ROOT)/simulator/bin/assembler
SIM = $(ROOT)/simulator/bin/simulator
MINCAML = $(ROOT)/mincaml_compiler/min-caml
BOOT = $(ROOT)/lib/asm/boot.s
MLFILES = $(wildcard *.ml)
ASFILES = $(wildcard *.s)

.PHONY: all clean

%.o: %.s
	cd $(ROOT)/simulator && $(MAKE)
	$(AS) -f $@ -i $<

%.b: %.o
	python convert01.py < $< > $@
	#./hex.sh < $<

%: %.o
	cd $(ROOT)/simulator && $(MAKE)
	touch input
	$(SIM) -f $< -o $(@:=.slog) -i input
	hd $(@:=.slog)
	cat $< eof > $@

%.S:%.ml
	#cd $(ROOT)/mincaml_compiler && ./to_cw3 && $(MAKE)
	cd $(ROOT)/mincaml_compiler && $(MAKE)
	$(MINCAML) $(@:.S=)
	mv $(@:.S=.s) $@

%.s: %.S
	cat $(BOOT) $< > $@

%: %.s

clean:
	rm -rf $(MLFILES:.ml=) $(MLFILES:.ml=.s) $(MLFILES:.ml=.slog) \
	 $(ASFILES:.s=.o) $(ASFILES:.s=.b) $(ASFILES:.s=) $(ASFILES:.s=.slog) \
	input output
