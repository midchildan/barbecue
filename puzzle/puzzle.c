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


// This file implements a solver for the sliding puzzle

#include "puzzle.h"

#include <limits.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#define INF (INT_MAX / 2)

// Private Functions

static inline bool is_illegal(int empty_x, int empty_y) {
  bool x_ok = 0 <= empty_x && empty_x < SIZE;
  bool y_ok = 0 <= empty_y && empty_y < SIZE;
  return !(x_ok && y_ok);
}

static inline int total_cost(const board_t* board) {
  return board->depth + board->estimated_cost;
}

static bool apply_move(board_t* board, move_t move) {
  int dx, dy;
  switch (move) {
    case MOVE_UP:
      dx = 0;
      dy = 1;
      break;
    case MOVE_DOWN:
      dx = 0;
      dy = -1;
      break;
    case MOVE_RIGHT:
      dx = -1;
      dy = 0;
      break;
    case MOVE_LEFT:
      dx = 1;
      dy = 0;
      break;
    default:
      return false;
  }

  int x = board->empty_tile[0];
  int y = board->empty_tile[1];
  int dst_x = x + dx;
  int dst_y = y + dy;
  if (is_illegal(dst_x, dst_y)) {
    return false;
  }

  int swap_val = board->board[dst_y][dst_x];
  board->board[y][x] = swap_val;
  board->board[dst_y][dst_x] = 0;
  board->empty_tile[0] = dst_x;
  board->empty_tile[1] = dst_y;

  board->estimated_cost = heuristic(board);
  board->depth += 1;

  if (board->estimated_cost == 0) {
    board->is_goal = true;
  }

  return true;
}

static int search_moves(const board_t* board, move_t move, int max_cost,
                        mstack_t* solution) {
  board_t curr_board;
  memcpy(&curr_board, board, sizeof(curr_board));

  if (!apply_move(&curr_board, move)) {
    return INF;
  }

  bool found = false;
  int min_cost = INF;
  int curr_cost = total_cost(&curr_board);

  if (curr_board.is_goal) {
    found = true;
  } else if (curr_cost > max_cost) {
    return curr_cost;
  } else {
    for (move_t m = MOVE_FIRST; m < MOVE_SIZE; m++) {
      int cost = search_moves(&curr_board, m, max_cost, solution);
      if (cost == 0) {
        found = true;
        break;
      } else if (cost < min_cost) {
        min_cost = cost;
      }
    }
  }

  if (!found) {
    return min_cost;
  }

  if (!stack_push(solution, move)) {
    return INF;
  }

  return 0;
}

// Stack

inline bool stack_empty(const mstack_t* stack) { return stack->len == 0; }

inline move_t stack_peek(const mstack_t* stack) {
  return stack->moves[stack->len - 1];
}

inline move_t stack_pop(mstack_t* stack) {
  move_t move = stack_peek(stack);
  if (stack_empty(stack)) {
    return MOVE_INVALID;
  }
  stack->len -= 1;
  return move;
}

inline bool stack_push(mstack_t* stack, move_t move) {
  size_t len = stack->len + 1;
  if (len > MAX_DEPTH) {
    return false;
  }

  stack->moves[len - 1] = move;
  stack->len = len;
  return true;
}

// Search

void init_board(board_t* board) {
  board->depth = 0;
  board->estimated_cost = heuristic(board);
  if (board->estimated_cost == 0) {
    board->is_goal = true;
  } else {
    board->is_goal = false;
  }

  for (int i = 0; i < SIZE; i++) {
    for (int j = 0; j < SIZE; j++) {
      if (board->board[i][j] == 0) {
        board->empty_tile[0] = j;
        board->empty_tile[1] = i;
        return;
      }
    }
  }
}

int heuristic(const board_t* board) {
  int manhattan = 0;

  for (int i = 0; i < SIZE; i++) {
    for (int j = 0; j < SIZE; j++) {
      int val = board->board[i][j];
      if (val == 0) {
        continue;
      }

      int dest_x = (val - 1) % SIZE;
      int dest_y = (val - 1) / SIZE;
      manhattan += abs(dest_x - j) + abs(dest_y - i);
    }
  }

  return manhattan;
}

int solve(const board_t* board, int max_cost, mstack_t* solution) {
  int min_cost = INF;

  for (move_t m = MOVE_FIRST; m < MOVE_SIZE; m++) {
    int cost = search_moves(board, m, max_cost, solution);
    if (cost == 0) {
      min_cost = 0;
      break;
    } else if (cost < min_cost) {
      min_cost = cost;
    }
  }

  return min_cost;
}
