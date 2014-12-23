ROOT = $(shell git rev-parse --show-toplevel)
ASM = $(ROOT)/simulator/bin/assembler
SIMULATOR = $(ROOT)/simulator/bin/simulator
SIM = ~/cpu_core/core_main_tb
WORK = $(ROOT)/simulator/bin
BUILDER = $(ROOT)/lib/cw3c.sh
COMPILER = $(ROOT)/compiler/min-caml
RAYTR = $(ROOT)/raytracer-ocaml
ADDRWIDTH = 14
MLSOURCE = newton.ml mandelbrot.ml graph.ml
SSOURCE = fib.s fib_rec.s loopback.s stack_test.s memtest.s aaa.s test.s
TARGET = $(SSOURCE:.s=) $(MLSOURCE:.ml=) min-rt2
DEBUG = $(TARGET:=.bin)

all: $(TARGET) $(DEBUG)

min-rt2: min-rt2.ml
	$(BUILDER) min-rt2.ml --boot $(ROOT)/lib/asm/rt_boot.s && \
	cp $(WORK)/$@ . && \
	cat eof >> $@

min-rt2.ml:
	$(RAYTR)/preprocess.py $(RAYTR)/min-rt.ml > min-rt2.ml

%.s: %.ml $(COMPILER)
	$(BUILDER) $< && \
	cp $(WORK)/_$@ $@

%.bin: %
	./textbin.py $(ADDRWIDTH) < $< > $@ && \
	cp $@ $(SIM)

%: %.s $(ASM)
	$(ASM) $@ < $< && \
	cat eof >> $@

$(COMPILER):
	cd $(ROOT)/mincaml_compiler && $(MAKE)

$(ASM):
	cd $(ROOT)/simulator && $(MAKE)

.PHONY: all clean

clean:
	rm -rf $(DEBUG) $(TARGET) $(MLSOURCE:.ml=.s)
