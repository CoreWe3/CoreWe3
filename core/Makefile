ROOT = $(shell git rev-parse --show-toplevel)
SOURCE = $(wildcard *.vhd) $(wildcard $(ROOT)/FPU/*.vhd)
SCRIPTS = core.xst core.ucf core.ut
BOOTLOADER = file/bootloader.b
CODE = file/test

all: configure

.PHONY: rt configure bit all clean

rt: file/min-rt core.bit
	scp $^ troublesome:~
	ssh troublesome "./config.sh min-rt"

configure: $(CODE) core.bit
	$(ROOT)/file/fpga.sh -h -i $< -l $(notdir $(CODE:=.flog)) core.bit
	#../file/fpga.sh core.bit

%: %.s
	cd file && $(MAKE) $(notdir $@)
%: %.ml
	cd file && $(MAKE) $(notdir $@)

core.bit: $(SOURCE) $(SCRIPTS) $(BOOTLOADER)
	./ise_cmd.sh

clean:
	rm -rf *.flog core.bit ise/*
	cd file && $(MAKE) clean
