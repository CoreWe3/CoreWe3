ASM = ../../simulator/bin/assembler
SIM = ~/cpu_core/core_main_tb
WORK = ../../simulator/bin
BUILDER = ../../lib/cw3c.sh
MLSOURCE = $(wildcard *.ml)
SSOURCE = $(wildcard *.s) $(MLSOURCE:.ml=.s)
TARGET = $(SSOURCE:.s=) $(MLSOURCE:.ml=)
DEBUG = $(TARGET:=.bin)

all: $(TARGET) $(DEBUG)

%.s: %.ml
	$(BUILDER) $< && \
	cp $(WORK)/_$@ $@

$(DEBUG): $(TARGET)
	./textbin.py < $(@:.bin=) > $@ && \
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
