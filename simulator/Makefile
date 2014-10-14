CFLAGS = -O2 -g -Wall
TARGET = $(basename $(wildcard *cpp))
SRCS = $(wildcard *.cpp)
CC = clang++


.PHONY: all

all: $(TARGET)

%:%.cpp
	$(CC) $(addsuffix .cpp, $(basename $<)) $(CFLAGS) -o $@

clean:
	$(RM) $(TARGET)

#A lot of thanks to nullpohead.
