SOURCE = $(wildcard *.vhd) $(wildcard fpu/*.vhd)
TARGET = core.bit
PRJ = core.prj
SCRIPTS = core.xst core.ucf core.ut
CODE = file/test_without_hazard.b

all: configure

.PHONY: configure bit all clean code

configure: bit
	scp $(TARGET) troublesome:~/
	ssh troublesome '~/Xilinx/14.4/ISE_DS/ISE/bin/lin64/impact -batch config.cmd'

bit: $(TARGET)

code:
	cd file && $(MAKE) $(notdir $(CODE))

$(CODE): code

$(TARGET): $(SOURCE) $(SCRIPTS) $(PRJ) $(CODE)
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
