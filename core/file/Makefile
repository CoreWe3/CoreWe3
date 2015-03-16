ROOT = $(shell git rev-parse --show-toplevel)
AS = $(ROOT)/simulator/bin/assembler
SIM = $(ROOT)/simulator/bin/simulator
MINCAML = $(ROOT)/mincaml_compiler/min-caml
MCFLAGS = -inline 64
MLFILES = $(wildcard *.ml)
ASFILES = $(wildcard *.s)

# vpath %.ml $(ROOT)/raytracer-ocaml

all: min-rt

.PHONY: all clean

# min-rt2.ml: min-rt.ml
#  	chmod 744 $(ROO)/raytracer-ocaml/preprocess.py
#  	$(ROOT)/raytracer-ocaml/preprocess.py $< > $@

min-rt.s: min-rt2.S
	cat $(ROOT)/lib/asm/rt_boot.s $(ROOT)/lib/asm/libmincaml.S $< > $@

min-rt: min-rt.s
	cd $(ROOT)/simulator && $(MAKE)
	$(AS) -f $@ -i $<
	$(SIM) -f $@ -o $(@:=.slog) -i $(ROOT)/raytracer-ocaml/sld_bin/contest.sld
	cat eof >> $@

%: %.s
	cd $(ROOT)/simulator && $(MAKE)
	$(AS) -f $@ -i $<
	touch input
	$(SIM) -f $@ -o $(@:=.slog) -i input
	cat eof >> $@
	cp $@ isim

%.b: %.s
	cd $(ROOT)/simulator && $(MAKE)
	$(AS) -f $(@:.b=) -i $<
	python convert01.py < $(@:.b=) > $@
	#./hex.sh < $<

%.S:%.ml
	cd $(ROOT)/mincaml_compiler && $(MAKE)
	cat $(ROOT)/lib/mincaml/libmincaml.ml $< > $(@:.S=_.ml)
	$(MINCAML) $(MCFLAGS) $(@:.S=_)
	mv $(@:.S=_.s) $@
	rm $(@:.S=_.ml)

%.s: %.S
	cat $(ROOT)/lib/asm/boot.s $< > $@

clean:
	rm -rf $(MLFILES:.ml=) $(MLFILES:.ml=.s) $(MLFILES:.ml=.slog) $(MLFILES:.ml=.S)\
	$(ASFILES:.s=.b) $(ASFILES:.s=) $(ASFILES:.s=.slog) \
