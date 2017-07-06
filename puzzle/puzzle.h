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


// This file defines functions for solving the sliding puzzle

#pragma once

#include <stdbool.h>
#include <stddef.h>

#define SIZE 3
#define MAX_DEPTH 32

typedef struct {
  bool is_goal;
  int depth;
  int estimated_cost;
  int empty_tile[2];
  int board[SIZE][SIZE];
} board_t;

typedef enum {
  MOVE_INVALID = 0,
  MOVE_FIRST = 1,

  MOVE_UP = 1,
  MOVE_DOWN,
  MOVE_RIGHT,
  MOVE_LEFT,

  MOVE_SIZE
} move_t;

typedef struct {
  move_t moves[MAX_DEPTH];
  size_t len;
} mstack_t;

bool stack_empty(const mstack_t* stack);
move_t stack_peek(const mstack_t* stack);
move_t stack_pop(mstack_t* stack);
bool stack_push(mstack_t* stack, move_t move);

void init_board(board_t* board);
int heuristic(const board_t* board);
int solve(const board_t* board, int max_cost, mstack_t* solution);
