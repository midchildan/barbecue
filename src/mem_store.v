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


// This module processes data retreived from the register before storing it to
// memory.
module mem_store (
  input [XLEN-1:0] addr,
  input [XLEN-1:0] data,
  input [MEM_TYPE_LEN-1:0] store_type,

  output [XLEN-1:0] to_store
);

  `include "constants.vh"

  reg [XLEN-1:0] masked_data;

  always @(*) begin
    case (store_type)
      MEM_B: masked_data = data & `D_XLEN'hFF;
      MEM_H: masked_data = data & `D_XLEN'hFFFF;
      MEM_W: masked_data = data & `D_XLEN'hFFFFFF;
      default: masked_data = data;
    endcase
  end

  assign to_store = masked_data << {addr[1:0], 3'b0};
endmodule
