AS = ../../simulator/bin/assembler


%.bin: %.hex
	./hex2bin.pl < $< > $@

%.hex: %.s $(AS)
	$(AS) $(basename $<) < $< && \
	./bin2hex.pl < $(basename $<) > $@
../../simulator/assembler:
	cd ../../simulator && \
	make && \
	cd ../core/file/
