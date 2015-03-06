CFLAGS = -std=c++11 -O3 -Wall
CC = clang++
C = clang
DIR = ./bin/

.PHONY: all

all: $(DIR)assembler $(DIR)disassembler $(DIR)simulator $(DIR)simulator_n $(DIR)bfi

isa_class.o: isa_class.cpp isa_class.h isa.h
	$(CC) isa_class.cpp $(CFLAGS) -c -o $@

fadd.o: ../FPU/fadd.c
	$(C) ../FPU/fadd.c $(CFLAG) -c -o $@

fmul.o: ../FPU/fmul.c
	$(C) ../FPU/fmul.c $(CFLAG) -c -o $@

finv.o: ../FPU/finv.c
	$(C) ../FPU/finv.c $(CFLAG) -c -o $@

fcmp.o: ../FPU/fcmp.c
	$(C) ../FPU/fcmp.c $(CFLAG) -c -o $@

fsqrt.o: ../FPU/fsqrt.c
	$(C) ../FPU/fsqrt.c $(CFLAG) -c -o $@

ftoi.o: ../FPU/ftoi.c
	$(C) ../FPU/ftoi.c $(CFLAG) -c -o $@

itof.o: ../FPU/itof.c
	$(C) ../FPU/itof.c $(CFLAG) -c -o $@

fpu.o: fpu.cpp fpu.h fpu_c.h
	$(CC) fpu.cpp $(CFLAGS) -c -o $@

fpu_n.o: fpu_n.cpp fpu.h
	$(CC) fpu_n.cpp $(CFLAGS) -c -o $@

$(DIR)assembler: assembler.cpp isa_class.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) assembler.cpp isa_class.o $(CFLAGS) -o $@

$(DIR)disassembler: disassembler.cpp isa_class.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) disassembler.cpp isa_class.o $(CFLAGS) -o $@

$(DIR)simulator: simulator.cpp isa_class.o fpu.o fadd.o fmul.o fcmp.o finv.o fsqrt.o ftoi.o itof.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) simulator.cpp isa_class.o fpu.o fadd.o fmul.o fcmp.o finv.o fsqrt.o ftoi.o itof.o $(CFLAGS) -o $@

$(DIR)simulator_n: simulator.cpp isa_class.o fpu_n.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) simulator.cpp isa_class.o fpu_n.o $(CFLAGS) -o $@

$(DIR)bfi: bfi.cpp isa_class.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) bfi.cpp isa_class.o $(CFLAGS) -o $@


clean:
	$(RM) isa_class.o
	$(RM) fpu.o
	$(RM) fpu_n.o
	$(RM) fadd.o
	$(RM) fmul.o
	$(RM) finv.o
	$(RM) fcmp.o
	$(RM) $(addprefix $(DIR), assembler)
	$(RM) $(addprefix $(DIR), disassembler)
	$(RM) $(addprefix $(DIR), simulator)
	$(RM) $(addprefix $(DIR), simulator_n)
	$(RM) $(addprefix $(DIR), bfi)

#A lot of thanks to nullpohead.
