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


// The register file is a collection of registers used to stage data between
// memory and the rest of the datapath.
module regfile (
  input clk,
  input[REG_ADDR_LEN-1:0] ra1, ra2, wa,
  input we,
  input [XLEN-1:0] wdata,

  output[XLEN-1:0] rd1,
  output[XLEN-1:0] rd2
);

  `include "constants.vh"

  reg [XLEN-1:0] regs[XLEN-1:0];

  assign rd1 = (ra1 != 0) ? regs[ra1] : 0;
  assign rd2 = (ra2 != 0) ? regs[ra2] : 0;

  always @(posedge clk) begin
    if (we && wa != 0) begin
      regs[wa] <= wdata;
    end
  end

endmodule
