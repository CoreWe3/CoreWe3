SOURCE = $(wildcard *.vhd) $(wildcard ../FPU/*.vhd)
TARGET = core.bit
PRJ = core.prj
SCRIPTS = core.xst core.ucf core.ut
BOOTLOADER = file/bootloader.b
CODE = file/test

all: configure

.PHONY: configure bit all clean

configure: $(CODE) $(TARGET)
	../file/fpga.sh -h -i $(CODE) -l fpga.log $(TARGET)

bit: $(TARGET)

$(TARGET): $(SOURCE) $(SCRIPTS) $(PRJ) $(BOOTLOADER)
	./ise_cmd.sh

$(PRJ): $(SOURCE)
	echo $(SOURCE) | \
	awk 'BEGIN {RS = " "} ;\
	{print "vhdl work " $$0}' > $@

%:%.s
	cd file && $(MAKE) $(notdir $@)
%.b:%.s
	cd file && $(MAKE) $(notdir $@)
%.o:%.s

clean:
	rm -rf _ngo/ _xmsgs/ *.xise *.bgn *.drc *.lso *.ncd *.bld *.ngc \
	*.xrpt *.ngd *.ngr *.pad *.par *.pcf *.ptwx \
	*.srp *.twr *.twx *.unroutes *.xpi *.xwbt *.map *.mrp \
	*.ngm *.csv *.xml *.html *.log xlnx_auto_0_xdb/ dump.xst/ \
	*_map* *_pad* work/ "file graph"
	cd file && $(MAKE) clean
