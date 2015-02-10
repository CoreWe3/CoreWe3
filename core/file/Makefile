ROOT = $(shell git rev-parse --show-toplevel)
AS = $(ROOT)/simulator/bin/assembler
SOURCES = test.s

all: test.b

.PHONY: assembler all clean

assembler:
	cd $(ROOT)/simulator && $(MAKE)

%.o: %.s assembler
	$(AS) -f $@ -i $<

%.b: %.o
	python convert01.py < $< > $@

claen:
	rm -rf *.o
