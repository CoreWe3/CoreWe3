CFLAGS = -O3 -Wall
TARGET = $(basename $(wildcard *cpp))
SRCS = $(wildcard *.cpp)
CC = clang++
DIR = ./bin

.PHONY: all

all: $(TARGET)

%:%.cpp isa.h
	$(CC) $(addsuffix .cpp, $(basename $<)) $(CFLAGS) -o $(DIR)/$@


clean:
	$(RM) $(DIR)/$(TARGET)

#A lot of thanks to nullpohead.
