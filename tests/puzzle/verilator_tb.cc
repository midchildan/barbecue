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

// Testbench for the puzzle program using verilator

#include <memory>

#include <verilated.h>

#include "Vverilator.h"

static constexpr int kStartupWaitTime = 3 * 2;  // 3 clocks
static vluint64_t main_time = 0;

double sc_time_stamp() { return main_time; }

int main(int argc, char *argv[]) {
  Verilated::commandArgs(argc, argv);

  auto tb = std::make_unique<Vverilator>();
  tb->clk = 0;
  tb->reset = 1;

  for (int i = 0; i < kStartupWaitTime; i++) {
    tb->eval();
    tb->clk = !tb->clk;
    main_time++;
  }

  tb->reset = 0;

  while (!Verilated::gotFinish()) {
    tb->eval();
    tb->clk = !tb->clk;
    main_time++;
  }

  tb->final();

  return 0;
}
