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


// This module processes data recieved from memory before storing it to the
// register.
module mem_load (
  input [XLEN-1:0] addr,
  input [XLEN-1:0] data,
  input [MEM_TYPE_LEN-1:0] load_type,

  output [XLEN-1:0] to_load
);

  `include "constants.vh"

  wire [XLEN-1:0] shifted_data = data >> {addr[1:0], 3'b0};
  wire [XLEN-1:0] b_data = (shifted_data & `D_XLEN'hFF);
  wire [XLEN-1:0] h_data = (shifted_data & `D_XLEN'hFFFF);
  wire [XLEN-1:0] b_extend = ({{`D_XLEN{shifted_data[7]}}} & ~(`D_XLEN'hFF));
  wire [XLEN-1:0] h_extend = ({{`D_XLEN{shifted_data[15]}}} & ~(`D_XLEN'hFFFF));

  always @(*) begin
    case (load_type)
      MEM_B: to_load = b_data | b_extend;
      MEM_H: to_load = h_data | h_extend;
      MEM_BU: to_load = b_data;
      MEM_HU: to_load = h_data;
      default : to_load = shifted_data;
    endcase
  end
endmodule
