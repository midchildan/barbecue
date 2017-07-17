CFLAGS = --std=gnu99 -MMD -g
OBJS = main.o puzzle.o

.PHONY: all clean

all: puzzle

puzzle: $(OBJS)

puzzle.o: puzzle.c

main.o: main.c

clean:
	$(RM) puzzle $(OBJS) *.d

-include *.d
