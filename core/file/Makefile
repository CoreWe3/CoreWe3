ROOT = $(shell git rev-parse --show-toplevel)
ASM = $(ROOT)/simulator/bin/assembler
SIM = $(ROOT)/core/debug
WORK = $(ROOT)/simulator/bin
BUILDER = $(ROOT)/lib/cw3c.sh
COMPILER = $(ROOT)/compiler/min-caml
ADDRWIDTH = 12
MLSOURCE = $(wildcard *.ml)
SSOURCE = $(wildcard *.s) $(MLSOURCE:.ml=.s)
TARGET = $(SSOURCE:.s=)
DEBUG = $(TARGET:=.bin)

all: $(TARGET) $(DEBUG)

%.s: %.ml $(COMPILER)
	$(BUILDER) $< && \
	cp $(WORK)/_$@ $@

%.bin: %
	./textbin.py $(ADDRWIDTH) < $< > $@ && \
	cp $@ $(SIM)

$(TARGET): $(SSOURCE) $(ASM)
	$(ASM) $@ < $@.s && \
	cat eof >> $@

$(COMPILER):
	cd $(ROOT)/mincaml_compiler && $(MAKE)

$(ASM):
	cd $(ROOT)/simulator && $(MAKE)

.PHONY: all clean

clean:
	rm -rf $(DEBUG) $(TARGET) $(MLSOURCE:.ml=.s)
