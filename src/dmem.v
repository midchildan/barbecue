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
  parameter NWORDS = (1 << XLEN) / (XLEN / 8)
)(
  input clk,
  input [XLEN-1:0] addr,
  input [XLEN-1:0] wdata,
  input [XLEN-1:0] wmask,
  input we,

  output [XLEN-1:0] rdata
);

  `include "constants.vh"

  localparam SHAMT_WIDTH = 5;

  reg [XLEN-1:0] mem [NWORDS-1:0];

  wire [XLEN-1:0] mem_idx = addr >> 2;
  wire [SHAMT_WIDTH-1:0] shamt = {addr[1:0], 3'b0};
  wire [XLEN-1:0] wdata_shifted = (wdata & wmask) << shamt;
  wire [XLEN-1:0] rdata_masked = mem[mem_idx] & ~(wmask << shamt);
  wire [XLEN-1:0] to_store = wdata_shifted | rdata_masked;

  assign rdata = mem[mem_idx];

  always @(posedge clk) begin
    if (we) begin
      mem[mem_idx] <= to_store;
    end
  end

  initial begin
    $readmemh("dmem.dat", mem);
  end

endmodule
