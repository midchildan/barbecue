// barbecue - a simple processor based on RISC-V
// Copyright © 2017 Team Barbecue
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
// OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// This file implements the main routine for solving the sliding puzzle.

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "board.h"
#include "puzzle.h"
#include "utils.h"

void print_moves(mstack_t* moves);

int main(void) {
  load_board(&g_board);
  init_board(&g_board);

  if (g_board.is_goal) {
    return EXIT_SUCCESS;
  }

  mstack_t answer = {.moves = {MOVE_INVALID}, .len = 0};
  int max_cost = heuristic(&g_board);
  while (max_cost < MAX_DEPTH) {
    int min_cost = solve(&g_board, max_cost, &answer);
    if (min_cost == 0) {
      print_moves(&answer);
      return EXIT_SUCCESS;
    }
    max_cost = min_cost;
  }

  return EXIT_FAILURE;
}

#ifdef BBQ_FPGA

#define SEG_ADDR 0x30000000
#define SEG_SLEEP_TIMES 100000

#define SEG_U 0x3e
#define SEG_P 0x67
#define SEG_D 0x3d
#define SEG_O 0x1d
#define SEG_R 0x77
#define SEG_I 0x30
#define SEG_L 0x0e
#define SEG_E 0x4f

static inline void write_7seg(int digit, uint32_t ctrl) {
  *((volatile uint32_t*)(SEG_ADDR + digit)) = ctrl;
}

static inline void sleep(int times) {
  for (int i = 0; i < times; i++) {
    asm volatile ("nop");
  }
}

void print_moves(mstack_t* moves) {
  while (!stack_empty(moves)) {
    move_t m = stack_pop(moves);

    switch(m) {
      case MOVE_UP:
        write_7seg(1, SEG_U);
        write_7seg(0, SEG_P);
        sleep(SEG_SLEEP_TIMES);
        break;
      case MOVE_DOWN:
        write_7seg(1, SEG_D);
        write_7seg(0, SEG_O);
        sleep(SEG_SLEEP_TIMES);
        break;
      case MOVE_RIGHT:
        write_7seg(1, SEG_R);
        write_7seg(0, SEG_I);
        sleep(SEG_SLEEP_TIMES);
        break;
      case MOVE_LEFT:
        write_7seg(1, SEG_L);
        write_7seg(0, SEG_E);
        sleep(SEG_SLEEP_TIMES);
        break;
      default:
        break;
    }

    write_7seg(1, 0);
    write_7seg(0, 0);
    sleep(SEG_SLEEP_TIMES);
  }
}

#else

void print_moves(mstack_t* moves) {
  while (!stack_empty(moves)) {
    move_t m = stack_pop(moves);

    char direction;
    switch (m) {
      case MOVE_UP:
        direction = 'U';
        break;
      case MOVE_DOWN:
        direction = 'D';
        break;
      case MOVE_RIGHT:
        direction = 'R';
        break;
      case MOVE_LEFT:
        direction = 'L';
        break;
      default:
        direction = '?';
    }

    putchar(direction);
  }
  putchar('\n');
}

#endif
