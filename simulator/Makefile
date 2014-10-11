CFLAGS = -O2 -g -Wall -std=gnu99
TARGET = $(basename $(wildcard *c))
SRCS = $(wildcard *.c)
CC = clang


.PHONY: all
	
all: $(TARGET)

%:%.c
	$(CC) $(addsuffix .c, $(basename $<)) $(CFLAGS) -o $@

clean:
	$(RM) $(TARGET)

#A lot of thanks to nullpohead.
