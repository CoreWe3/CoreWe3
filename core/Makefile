SOURCE = $(wildcard *.vhd) $(wildcard ../FPU/*.vhd)
SCRIPTS = core.xst core.ucf core.ut
BOOTLOADER = file/bootloader.b
CODE = file/newton

all: configure

.PHONY: configure bit all clean

configure: $(CODE) core.bit
	../file/fpga.sh -h -i $(CODE) -l $(notdir $(CODE:=.flog)) core.bit
	#../file/fpga.sh core.bit

core.bit: $(SOURCE) $(SCRIPTS) $(BOOTLOADER)
	./ise_cmd.sh

%.s:%.ml
	cd file && $(MAKE) $(notdir $@)
%:%.s
	cd file && $(MAKE) $(notdir $@)
%.b:%.s
	cd file && $(MAKE) $(notdir $@)
%.o:%.s

clean:
	rm -rf *.flog core.bit ise/*
	cd file && $(MAKE) clean
