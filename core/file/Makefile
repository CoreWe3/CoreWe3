ROOT = $(shell git rev-parse --show-toplevel)
AS = $(ROOT)/simulator/bin/assembler
SIM = $(ROOT)/simulator/bin/simulator
MINCAML = $(ROOT)/mincaml_compiler/min-caml
MLFILES = $(wildcard *.ml)
ASFILES = $(wildcard *.s)

all: $(ASFILES:.s=.b) $(ASFILES:.s=)

.PHONY: simulator all clean

simulator:
	cd $(ROOT)/simulator && $(MAKE)

compiler:
	cd $(ROOT)/mincaml_compiler && ./to_cw3 && $(MAKE)

%.o: %.s simulator
	$(AS) -f $@ -i $<

%.b: %.o
	python convert01.py < $< > $@
	#./hex.sh < $<

%: %.o simulator
	touch input
	$(SIM) -f $< -o output -i input
	hd output
	cat $< eof > $@

%.s:%.ml compiler
	$(MINCAML) $(@:.s=)

%: %.s
%: %.o
%.o: %.s


clean:
	rm -rf $(ASFILES:.s=.o) $(ASFILES:.s=.b) $(ASFILES:.s=) input output
