SOURCE = $(wildcard *.vhd) $(wildcard fpu/*.vhd)
TARGET = core.bit
PRJ = core.prj
SCRIPTS = core.xst core.ucf core.ut

all: configure

.PHONY: configure bit all clean

configure: bit
	impact -batch config.cmd

bit: $(TARGET)

$(TARGET): $(SOURCE) $(SCRIPTS) $(PRJ)
	./ise_cmd.sh

$(PRJ): $(SOURCE)
	echo $(SOURCE) | \
	awk 'BEGIN {RS = " "} ;\
	{print "vhdl work " $$0}' > $@

clean:
	rm -rf _ngo/ _xmsgs/ *.bgn *.drc *.lso *.ncd *.bld *.ngc \
	*.xrpt *.ngd *.ngr *.pad *.par *.pcf *.prj *.ptwx \
	*.srp *.twr *.twx *.unroutes *.xpi *.xwbt *.map *.mrp \
	*.ngm *.csv *.xml *.html *.log xlnx_auto_0_xdb/ dump.xst/ \
	*_map* *_pad* work/ "file graph"
