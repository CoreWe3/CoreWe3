CFLAGS = -O3 -Wall
TARGET = $(basename $(wildcard *cpp))
SRCS = $(wildcard *.cpp)
CC = clang++


.PHONY: all

all: $(TARGET)

%:%.cpp isa.h
	$(CC) $(addsuffix .cpp, $(basename $<)) $(CFLAGS) -o $@


clean:
	$(RM) $(TARGET)

#A lot of thanks to nullpohead.
