CFLAGS = --std=c99 -g

.PHONY: all clean

all: puzzle

puzzle: main.o puzzle.o

puzzle.o: puzzle.c puzzle.h

main.o: main.c board.h print.h puzzle.h

clean:
	$(RM) puzzle main.o puzzle.o
