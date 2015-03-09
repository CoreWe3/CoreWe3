ROOT = $(shell git rev-parse --show-toplevel)
AS = $(ROOT)/simulator/bin/assembler
SIM = $(ROOT)/simulator/bin/simulator
MINCAML = $(ROOT)/mincaml_compiler/min-caml
BOOT = $(ROOT)/lib/asm/boot.s
MLFILES = $(wildcard *.ml)
ASFILES = $(wildcard *.s)

all:

.PHONY: all clean

%: %.s
	cd $(ROOT)/simulator && $(MAKE)
	$(AS) -f $@ -i $<
	touch input
	$(SIM) -f $@ -o $(@:=.slog) -i input
	cat eof >> $@

%.b: %.s
	cd $(ROOT)/simulator && $(MAKE)
	$(AS) -f $(@:.b=) -i $<
	python convert01.py < $(@:.b=) > $@
	#./hex.sh < $<

%.S:%.ml
	#cd $(ROOT)/mincaml_compiler && ./to_cw3 && $(MAKE)
	cd $(ROOT)/mincaml_compiler && $(MAKE)
	$(MINCAML) $(@:.S=)
	mv $(@:.S=.s) $@

%.s: %.S
	cat $(BOOT) $< > $@

clean:
	rm -rf $(MLFILES:.ml=) $(MLFILES:.ml=.s) $(MLFILES:.ml=.slog) $(MLFILES:.ml=.S)\
	 $(ASFILES:.s=.o) $(ASFILES:.s=.b) $(ASFILES:.s=) $(ASFILES:.s=.slog) \
