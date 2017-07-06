CFLAGS = '-g'

.PHONY: all

all: puzzle

puzzle: main.o puzzle.o

puzzle.o: puzzle.c puzzle.h

main.o: main.c puzzle.h

clean:
	$(RM) puzzle main.o puzzle.o
