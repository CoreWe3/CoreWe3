AS = ../../simulator/bin/assembler
SIM = $(HOME)/cpu_core/core_main_tb/
SOURCE = $(wildcard *.s)
TARGET = $(SOURCE:.s=.tbin) $(SOURCE:.s=.cw3)

all: $(TARGET)

%.tbin: %.hex
	./hex2tbin.pl < $< > $@ && \
	cp $@ $(SIM)

%.hex: %.cw3
	./cw32hex.pl < $< > $@

%.cw3: %.s $(AS)
	$(AS) $(<:.s=.bin) < $< && \
	./swap.pl < $(<:.s=.bin) > $@ && \
	cat eof >> $@

$(AS):
	cd ../../simulator && \
	make && \
	cd ../core/file/

.PHONY: all clean

clean:
	rm -rf *.cw3 *.tbin *.bin *.hex
