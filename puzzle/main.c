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


// This file implements the main routine for solving the sliding puzzle on the
// host.

#include <stdio.h>
#include <stdlib.h>

#include "puzzle.h"

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

int main(void) {
  board_t board;
  for (int i = 0; i < SIZE; i++) {
    for (int j = 0; j < SIZE; j++) {
      scanf("%d", &board.board[i][j]);
    }
  }
  init_board(&board);

  if (board.is_goal) {
    return EXIT_SUCCESS;
  }

  mstack_t answer = {.moves = {0}, .len = 0};
  int max_cost = heuristic(&board);
  while (max_cost < MAX_DEPTH) {
    int min_cost = solve(&board, max_cost, &answer);
    if (min_cost == 0) {
      print_moves(&answer);
      return EXIT_SUCCESS;
    }
    max_cost = min_cost;
  }

  return EXIT_FAILURE;
}
