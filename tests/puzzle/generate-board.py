#!/usr/bin/env python3

# barbecue - a simple processor based on RISC-V
# Copyright © 2017 Team Barbecue
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import argparse
import random
import sys
from sys import argv, stderr


class Board:
    HEADER_TEMPLATE = ''' #pragma once

board_t g_board = {{
  .board = {}
}}; '''

    def __init__(self, width):
        self.board = list(range(width * width))
        self.empty_row = width - 1
        self.inversions = 0
        self.width = width

    def shuffle(self):
        random.shuffle(self.board)
        self.inversions = self.__calc_inversions()
        self.empty_row = self.board.index(0) // self.width

        if self.is_solvable():
            return

        if self.empty_row == 0:
            swp = self.board[-1]
            self.board[-1] = self.board[-2]
            self.board[-2] = swp
        else:
            swp = self.board[0]
            self.board[0] = self.board[1]
            self.board[1] = swp

        self.inversions = self.__calc_inversions()

    def manhattan_distance(self):
        distance = 0
        for i in range(self.width):
            for j in range(self.width):
                d_row = abs(self.board[i * self.width + j] // self.width - i)
                d_col = abs(self.board[i * self.width + j] % self.width - j)
                distance += d_row + d_col
        return distance

    def get_header(self):
        width = self.width
        size = len(self.board)
        board = [str(i) for i in self.board]
        board2d = [board[i:i + width] for i in range(0, size, width)]

        to_carray = lambda arr: '{{ {} }}'.format(','.join(arr))

        rows = [to_carray(row) for row in board2d]
        board_carray = to_carray(rows)
        return self.HEADER_TEMPLATE.format(board_carray)

    def is_solvable(self):
        if self.width % 2 == 1:
            return (self.inversions % 2 == 0)
        else:
            return ((self.inversions + self.width - self.empty_row) % 2 == 0)

    def __calc_inversions(self):
        inversions = 0
        goal = list(range(1, len(self.board)))

        for tile in self.board:
            if tile == 0:
                continue
            inversions += goal.index(tile)
            goal.remove(tile)

        return inversions


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--header", action="store_true", help="generate c header file")
    parser.add_argument("--verbose", action="store_true")
    parser.add_argument("width", type=int, help="board width")
    args = parser.parse_args()

    width = args.width
    board = Board(width)
    board.shuffle()

    if args.verbose:
        print('inversion count: {}'.format(board.inversions), file=stderr)
        print('manhattan distance: {}'.format(board.manhattan_distance()), file=stderr)

    if args.header:
        print(board.get_header())
    else:
        for i in range(width):
            start = i * width
            end = (i + 1) * width
            row = (str(i) for i in board.board[start:end])
            print(' '.join(row))


if __name__ == "__main__":
    main()
