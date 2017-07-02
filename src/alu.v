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


// The ALU performs arithmetic operations.
module alu (
  input [ALU_OP_LEN-1:0] op,
  input [XLEN-1:0] srca,
  input [XLEN-1:0] srcb,

  output reg [XLEN-1:0] out
);

  `include "constants.vh"

  localparam SHAMT_WIDTH = 5;

  wire [SHAMT_WIDTH-1:0] shamt;
  assign shamt = srcb[SHAMT_WIDTH-1:0];

  always @(*) begin
    case (op)
      ALU_ADD : out = srca + srcb;
      ALU_SLL : out = srca << shamt;
      ALU_XOR : out = srca ^ srcb;
      ALU_OR : out = srca | srcb;
      ALU_AND : out = srca & srcb;
      ALU_SRL : out = srca >> shamt;
      ALU_SEQ : out = {31'b0, srca == srcb};
      ALU_SNE : out = {31'b0, srca != srcb};
      ALU_SUB : out = srca - srcb;
      ALU_SRA : out = $signed(srca) >>> shamt;
      ALU_SLT : out = {31'b0, $signed(srca) < $signed(srcb)};
      ALU_SGE : out = {31'b0, $signed(srca) >= $signed(srcb)};
      ALU_SLTU : out = {31'b0, srca < srcb};
      ALU_SGEU : out = {31'b0, srca >= srcb};
      default : out = 0;
    endcase
  end

endmodule
