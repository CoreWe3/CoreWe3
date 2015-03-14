ROOT = $(shell git rev-parse --show-toplevel)
vpath % file
SOURCE = $(wildcard *.vhd) $(wildcard $(ROOT)/FPU/*.vhd)
SCRIPTS = core.xst core.ucf core.ut
BOOTLOADER = file/bootloader.b
CODE = min-rt

all: conf_rt

.PHONY: conf_rt configure bit all clean

conf_rt: min-rt core.bit
	scp $^ troublesome:~
	ssh troublesome "./config.sh min-rt"

configure: $(CODE) core.bit
	$(ROOT)/file/fpga.sh -h -i $< -l $(notdir $(CODE:=.flog)) core.bit
	#../file/fpga.sh core.bit

core.bit: $(SOURCE) $(SCRIPTS) $(BOOTLOADER)
	./ise_cmd.sh

%: %.s
	cd file && $(MAKE) $@
%: %.ml
	cd file && $(MAKE) $@

clean:
	rm -rf *.flog core.bit ise/*
	cd file && $(MAKE) clean
