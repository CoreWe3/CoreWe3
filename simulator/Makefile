CFLAGS = -std=c++11 -O3 -Wall
CC = clang++
DIR = ./bin/

.PHONY: all

all: $(DIR)assembler $(DIR)disassembler $(DIR)simulator $(DIR)bfi

isa_class.o: isa_class.cpp isa_class.h isa.h
	$(CC) isa_class.cpp $(CFLAGS) -c

fpu.o: fpu.cpp fpu.h
	$(CC) fpu.cpp $(CFLAGS) -c

$(DIR)assembler: assembler.cpp isa_class.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) assembler.cpp isa_class.o $(CFLAGS) -o $@

$(DIR)disassembler: disassembler.cpp isa_class.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) disassembler.cpp isa_class.o $(CFLAGS) -o $@

$(DIR)simulator: simulator.cpp isa_class.o fpu.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) simulator.cpp isa_class.o fpu.o $(CFLAGS) -o $@

$(DIR)bfi: bfi.cpp isa_class.o
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) bfi.cpp isa_class.o $(CFLAGS) -o $@


clean:
	$(RM) isa_class.o
	$(RM) fpu.o
	$(RM) $(addprefix $(DIR), assembler)
	$(RM) $(addprefix $(DIR), disassembler)
	$(RM) $(addprefix $(DIR), simulator)
	$(RM) $(addprefix $(DIR), bfi)

#A lot of thanks to nullpohead.
