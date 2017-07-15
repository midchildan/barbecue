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


`timescale 1ns / 1ps

module testbench ();

  `include "constants.vh"

  reg clk = 1'b0;
  reg reset = 1'b1;

  always #5 clk = ~clk;

  initial begin
    reset <= 1'b1;
    repeat (3) @(posedge clk);
    reset <= 1'b0;
  end

  simulation #(
    .PC_START(`D_XLEN'h0),
    .STACK_ADDR(~(`D_XLEN'h0))
  ) simulation (
    .clk(clk),
    .reset(reset)
  );

endmodule
