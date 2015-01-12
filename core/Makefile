SOURCE = $(wildcard *.vhd) $(wildcard fpu/*.vhd)
CODE = file/test.s
TARGET = core.bit
PRJ = core.prj
SCRIPTS = core.xst core.ucf core.ut file/code.bin

all: configure

.PHONY: configure bit all clean

configure: bit $(CODE:.s=)
	scp $(TARGET) troublesome:~/cpu_core/remote/remote.bit
	scp $(CODE:.s=) troublesome:~/code
	ssh troublesome ". ~/CAD/ise.sh && \
	cd ~/cpu_core/remote/ && \
	impact -batch exec.cmd"

bit: $(TARGET)

$(TARGET): $(SOURCE) $(SCRIPTS) $(PRJ)
	./ise_cmd.sh

$(CODE:.s=): $(CODE)
	cd file && $(MAKE) $(basename $(notdir $<))


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
	cd file && $(MAKE) clean
