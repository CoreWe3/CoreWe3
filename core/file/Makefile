ROOT = $(shell git rev-parse --show-toplevel)
AS = $(ROOT)/simulator/bin/assembler
SIM = $(ROOT)/simulator/bin/simulator
ASFILES = $(wildcard *.s)

all:

.PHONY: simulator all clean

simulator:
	cd $(ROOT)/simulator && $(MAKE)

%.o: %.s simulator
	$(AS) -f $@ -i $<

%.b: %.o
	python convert01.py < $< > $@
#	./hex.sh < $<

%: %.o simulator
	touch input
	$(SIM) -f $< -o output -i input
	./hex.sh output
	cat $< eof > $@

%: %.s
%: %.o
%.o: %.s


clean:
	rm -rf $(ASFILES:.s=.o) $(ASFILES:.s=.b) $(ASFILES:.s=) input output
