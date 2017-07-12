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


// The PC muxer chooses the next address to fetch the instruction from.
module pc_mux (
  input [XLEN-1:0] pc_in,
  input [PC_SEL_LEN-1:0] sel,
  input branch,
  input [XLEN-1:0] imm_i,
  input [XLEN-1:0] imm_b,
  input [XLEN-1:0] imm_j,
  input [XLEN-1:0] rs1_data,

  output [XLEN-1:0] pc_out
);

  `include "constants.vh"

  reg [XLEN-1:0] base;
  reg [XLEN-1:0] offset;

  always @(*) begin
    base = pc_in;
    offset = `D_XLEN'h4;

    case (sel)
      PC_JAL: begin
        base = pc_in;
        offset = imm_j;
      end
      PC_JALR: begin
        base = rs1_data;
        offset = imm_i & ~(`D_XLEN'b1);
      end
      PC_BRANCH: begin
        if (branch) begin
          base = pc_in;
          offset = imm_b;
        end
      end
    endcase
  end

  assign pc_out = base + offset;

endmodule
