ASM = ../../simulator/bin/assembler
SIM = ~/cpu_core/core_main_tb
WORK = ../../simulator/bin
BUILDER = ../../lib/cw3c.sh
ADDRWIDTH = 10
MLSOURCE = $(wildcard *.ml)
SSOURCE = $(wildcard *.s) $(MLSOURCE:.ml=.s)
TARGET = $(SSOURCE:.s=)
DEBUG = $(TARGET:=.bin)

all: $(TARGET) $(DEBUG)

%.s: %.ml
	$(BUILDER) $< && \
	cp $(WORK)/_$@ $@

$(DEBUG): $(TARGET)
	./textbin.py $(ADDRWIDTH) < $(@:.bin=) > $@ && \
	cp $@ $(SIM)

$(SSOURCE:.s=): $(SSOURCE) $(ASM)
	$(ASM) $@ < $@.s && \
	cat eof >> $@

$(ASM):
	cd ../../simulator && \
	make && \
	cd ../core/file/

.PHONY: all clean

clean:
	rm -rf $(DEBUG) $(TARGET) $(MLSOURCE:.ml=.s)
