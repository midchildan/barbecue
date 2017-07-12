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


// The ALU source muxer chooses which input to feed the ALU.
module alu_src_mux (
  input [SRCA_SEL_LEN-1:0] srca_sel,
  input [SRCB_SEL_LEN-1:0] srcb_sel,
  input [XLEN-1:0] rs1,
  input [XLEN-1:0] rs2,
  input [XLEN-1:0] pc,
  input [XLEN-1:0] imm_i,
  input [XLEN-1:0] imm_s,
  input [XLEN-1:0] imm_u,
  input [XLEN-1:0] imm_j,

  output reg [XLEN-1:0] srca,
  output reg [XLEN-1:0] srcb
);

  `include "constants.vh"

  always @(*) begin
    case (srca_sel)
      SRCA_RS1: srca = rs1;
      SRCA_PC: srca = pc;
      default: srca = 0;
    endcase
  end

  always @(*) begin
    case (srcb_sel)
      SRCB_RS2: srcb = rs2;
      SRCB_IMM_I: srcb = imm_i;
      SRCB_IMM_S: srcb = imm_s;
      SRCB_IMM_U: srcb = imm_u;
      SRCB_IMM_J: srcb = imm_j;
      SRCB_FOUR: srcb = 4;
      default: srcb = 0;
    endcase
  end

endmodule
