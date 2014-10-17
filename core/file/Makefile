
%.bin: %.hex
	./hex2bin.pl < $< > $@
%.hex: %.s ../../simulator/assembler
	../../simulator/assembler $(basename $<) < $< && \
	./bin2hex.pl < $(basename $<) > $@
../../simulator/assembler:
	cd ../../simulator && \
	LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/:`echo $LD_LIBRARY_PATH` make && \
	cd ../core/file/
