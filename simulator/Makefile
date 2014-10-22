CFLAGS = -O3 -Wall
TARGET = $(basename $(wildcard *cpp))
SRCS = $(wildcard *.cpp)
CC = clang++
DIR = ./bin/

.PHONY: all

all: $(TARGET)

%:%.cpp isa.h
	@if [ ! -d $(DIR) ]; then mkdir $(DIR); fi
	$(CC) $(addsuffix .cpp, $(basename $<)) $(CFLAGS) -o $(DIR)$@


clean:
	$(RM) $(addprefix $(DIR), $(TARGET))

#A lot of thanks to nullpohead.
