AS = ../../simulator/bin/assembler

%.tbin: %.hex
	./hex2tbin.pl < $< > $@

%.hex: %.bin
	./bin2hex.pl < $< > $@

%.bin: %.s $(AS)
	$(AS) $(basename $<) < $< && \
	./swap.pl < $(basename $<) > $@

$(AS):
	cd ../../simulator && \
	make && \
	cd ../core/file/
