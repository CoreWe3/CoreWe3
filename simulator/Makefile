CCFLAGS = -std=c++11 -Ofast -Wall -march=native
CFLAGS = -std=c11 -Ofast -Wall -march=native

CC = g++
C = gcc
DIR = ./bin/

.PHONY: all

all: $(DIR)assembler $(DIR)disassembler $(DIR)simulator $(DIR)simulator_n $(DIR)simulator_c $(DIR)bfi

isa_class.o: isa_class.cpp isa_class.h isa.h
	$(CC) isa_class.cpp $(CCFLAGS) -c -o $@

ram.o: ram.cpp ram.h isa.h
	$(CC) ram.cpp $(CCFLAGS) -c -o $@

ram_c.o: ram_c.cpp ram.h isa.h
	$(CC) ram_c.cpp $(CCFLAGS) -c -o $@

fadd.o: ../FPU/fadd.c
	$(C) ../FPU/fadd.c $(CFLAGS) -c -o $@

fmul.o: ../FPU/fmul.c
	$(C) ../FPU/fmul.c $(CFLAGS) -c -o $@

finv.o: ../FPU/finv.c
	$(C) ../FPU/finv.c $(CFLAGS) -c -o $@

fabs.o: ../FPU/fabs.c
	$(C) ../FPU/fabs.c $(CFLAGS) -c -o $@

fcmp.o: ../FPU/fcmp.c
	$(C) ../FPU/fcmp.c $(CFLAGS) -c -o $@

fsqrt.o: ../FPU/fsqrt.c
	$(C) ../FPU/fsqrt.c $(CFLAGS) -c -o $@

ftoi.o: ../FPU/ftoi.c
	$(C) ../FPU/ftoi.c $(CFLAGS) -c -o $@

itof.o: ../FPU/itof.c
	$(C) ../FPU/itof.c $(CFLAGS) -c -o $@

floor.o: ../FPU/floor.c
	$(C) ../FPU/floor.c $(CFLAGS) -c -o $@

fpu.o: fpu.cpp fpu.h
	$(CC) fpu.cpp $(CCFLAGS) -c -o $@

fpu_n.o: fpu_n.cpp fpu.h
	$(CC) fpu_n.cpp $(CCFLAGS) -c -o $@

$(DIR)assembler: assembler.cpp isa_class.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) assembler.cpp isa_class.o $(CCFLAGS) -o $@

$(DIR)disassembler: disassembler.cpp isa_class.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) disassembler.cpp isa_class.o $(CCFLAGS) -o $@

$(DIR)simulator: simulator.cpp isa_class.o fpu.o fadd.o fmul.o fabs.o fcmp.o finv.o fsqrt.o ftoi.o itof.o ram.o floor.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) $^ $(CCFLAGS) -o $@

$(DIR)simulator_c: simulator_c.cpp isa_class.o fpu.o fadd.o fmul.o fabs.o fcmp.o finv.o fsqrt.o ftoi.o itof.o ram_c.o floor.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) $^ $(CCFLAGS) -o $@

$(DIR)simulator_n: simulator.cpp isa_class.o fpu_n.o ram.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) $^ $(CCFLAGS) -o $@

$(DIR)bfi: bfi.cpp isa_class.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) bfi.cpp isa_class.o $(CCFLAGS) -o $@


clean:
	$(RM) isa_class.o
	$(RM) fpu.o
	$(RM) fpu_n.o
	$(RM) ftoi.o
	$(RM) itof.o
	$(RM) fadd.o
	$(RM) fmul.o
	$(RM) fsqrt.o
	$(RM) fabs.o
	$(RM) finv.o
	$(RM) fcmp.o
	$(RM) ram.o
	$(RM) ram_c.o
	$(RM) floor.o
	$(RM) $(addprefix $(DIR), assembler)
	$(RM) $(addprefix $(DIR), disassembler)
	$(RM) $(addprefix $(DIR), simulator)
	$(RM) $(addprefix $(DIR), simulator_n)
	$(RM) $(addprefix $(DIR), simulator_c)
	$(RM) $(addprefix $(DIR), bfi)

#A lot of thanks to nullpohead.
