AS = ../../simulator/bin/assembler
SOURCE = $(wildcard *.s)
TARGET = $(SOURCE:.s=.tbin) $(SOURCE:.s=.cw3)

all: $(TARGET)

%.tbin: %.hex
	./hex2tbin.pl < $< > $@

%.hex: %.cw3
	./cw32hex.pl < $< > $@

%.cw3: %.s $(AS)
	$(AS) $(basename $<) < $< && \
	./swap.pl < $(basename $<) > $@ && \
	cat eof >> $@ && \
	rm $(basename $<)

$(AS):
	cd ../../simulator && \
	make && \
	cd ../core/file/

.PHONY: all clean

clean:
	rm -rf $(TARGET) $(basename $(SORCE))
