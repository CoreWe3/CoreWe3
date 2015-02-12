ROOT = $(shell git rev-parse --show-toplevel)
AS = $(ROOT)/simulator/bin/assembler
SIM = $(ROOT)/simulator/bin/simulator

all: fib_loop.b

.PHONY: simulator all clean

simulator:
	cd $(ROOT)/simulator && $(MAKE)

%.o: %.s simulator
	$(AS) -f $@ -i $<

%.b: %.o
	python convert01.py < $< > $@
#	./hex.sh < $<

%: %.o simulator input
	$(SIM) -f $< -o output -i input
	hexdump output
#	python endian_convert.py < $< > $@

%: %.s


clean:
	rm -rf *.o *.b
