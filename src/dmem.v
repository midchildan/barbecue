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


// The data memory stores data that the datapath can process.
module dmem #(
  parameter NWORDS = (1 << XLEN) / XLEN
)(
  input clk,
  input [XLEN-1:0] addr,
  input [XLEN-1:0] wdata,
  input we,

  output reg [XLEN-1:0] rdata
);

  `include "constants.vh"

  reg [XLEN-1:0] mem [NWORDS-1:0];
  wire [XLEN-1:0] addr_word = addr[XLEN-1:2];
  wire [$clog2(NWORDS)-1:0] mem_idx = addr_word[$clog2(NWORDS)-1:0];

  initial begin
    $readmemh("dmem.dat", mem);
  end

  always @(posedge clk) begin
    if (we) begin
      mem[addr] <= wdata;
    end else begin
      rdata <= mem[mem_idx];
    end
  end

endmodule
