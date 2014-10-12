CFLAGS = -O2 -g -Wall
TARGET = $(basename $(wildcard *cpp))
SRCS = $(wildcard *.cpp)
CC = clang++


.PHONY: all
	
all: $(TARGET)

%:%.c
	$(CC) $(addsuffix .c, $(basename $<)) $(CFLAGS) -o $@

clean:
	$(RM) $(TARGET)

#A lot of thanks to nullpohead.
