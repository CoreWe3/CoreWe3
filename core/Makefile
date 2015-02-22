SOURCE = $(wildcard *.vhd) $(wildcard fpu/*.vhd)
TARGET = core.bit
PRJ = core.prj
SCRIPTS = core.xst core.ucf core.ut
BOOTLOADER = file/bootloader.b
CODE = file/loopback

all: configure code

.PHONY: configure bit all clean code

configure: bit code
	../file/fpga.sh -h -i $(CODE) $(TARGET)

bit: $(TARGET)

code:
	cd file && $(MAKE) $(notdir $(CODE))

$(TARGET): $(SOURCE) $(SCRIPTS) $(PRJ) $(BOOTLOADER)
	./ise_cmd.sh

$(PRJ): $(SOURCE)
	echo $(SOURCE) | \
	awk 'BEGIN {RS = " "} ;\
	{print "vhdl work " $$0}' > $@

clean:
	rm -rf _ngo/ _xmsgs/ *.xise *.bgn *.drc *.lso *.ncd *.bld *.ngc \
	*.xrpt *.ngd *.ngr *.pad *.par *.pcf *.prj *.ptwx \
	*.srp *.twr *.twx *.unroutes *.xpi *.xwbt *.map *.mrp \
	*.ngm *.csv *.xml *.html *.log xlnx_auto_0_xdb/ dump.xst/ \
	*_map* *_pad* work/ "file graph"
