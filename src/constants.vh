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


`define D_XLEN 32
`define D_ALU_OP_LEN 4
`define D_SRCA_SEL_LEN 2
`define D_SRCB_SEL_LEN 3
`define D_PC_SEL_LEN 3
`define D_REG_ADDR_LEN 5
`define D_WB_SEL_LEN 1
`define D_MEM_TYPE_LEN 3

localparam XLEN = `D_XLEN;
localparam REG_ADDR_LEN = `D_REG_ADDR_LEN;

localparam PC_SEL_LEN   = `D_PC_SEL_LEN,
           PC_PLUS_FOUR = `D_PC_SEL_LEN'd0,
           PC_BRANCH    = `D_PC_SEL_LEN'd1,
           PC_JAL       = `D_PC_SEL_LEN'd2,
           PC_JALR      = `D_PC_SEL_LEN'd3;

localparam ALU_OP_LEN = `D_ALU_OP_LEN,
           ALU_ADD    = `D_ALU_OP_LEN'd0,
           ALU_SLL    = `D_ALU_OP_LEN'd1,
           ALU_XOR    = `D_ALU_OP_LEN'd2,
           ALU_OR     = `D_ALU_OP_LEN'd3,
           ALU_AND    = `D_ALU_OP_LEN'd4,
           ALU_SRL    = `D_ALU_OP_LEN'd5,
           ALU_SEQ    = `D_ALU_OP_LEN'd6,
           ALU_SNE    = `D_ALU_OP_LEN'd7,
           ALU_SUB    = `D_ALU_OP_LEN'd8,
           ALU_SRA    = `D_ALU_OP_LEN'd9,
           ALU_SLT    = `D_ALU_OP_LEN'd10,
           ALU_SGE    = `D_ALU_OP_LEN'd11,
           ALU_SLTU   = `D_ALU_OP_LEN'd12,
           ALU_SGEU   = `D_ALU_OP_LEN'd13;

localparam SRCA_SEL_LEN = `D_SRCA_SEL_LEN,
           SRCA_RS1     = `D_SRCA_SEL_LEN'd0,
           SRCA_PC      = `D_SRCA_SEL_LEN'd1,
           SRCA_ZERO    = `D_SRCA_SEL_LEN'd2;

localparam SRCB_SEL_LEN = `D_SRCB_SEL_LEN,
           SRCB_RS2     = `D_SRCB_SEL_LEN'd0,
           SRCB_IMM_I   = `D_SRCB_SEL_LEN'd1,
           SRCB_IMM_S   = `D_SRCB_SEL_LEN'd2,
           SRCB_IMM_U   = `D_SRCB_SEL_LEN'd3,
           SRCB_IMM_J   = `D_SRCB_SEL_LEN'd4,
           SRCB_FOUR    = `D_SRCB_SEL_LEN'd5,
           SRCB_ZERO    = `D_SRCB_SEL_LEN'd6;

localparam MEM_TYPE_LEN = `D_MEM_TYPE_LEN,
           MEM_B        = `D_MEM_TYPE_LEN'b000,
           MEM_H        = `D_MEM_TYPE_LEN'b001,
           MEM_W        = `D_MEM_TYPE_LEN'b010,
           MEM_D        = `D_MEM_TYPE_LEN'b011,
           MEM_BU       = `D_MEM_TYPE_LEN'd100,
           MEM_HU       = `D_MEM_TYPE_LEN'd101,
           MEM_WU       = `D_MEM_TYPE_LEN'd110;

localparam WB_SEL_LEN = `D_WB_SEL_LEN,
           WB_ALU     = `D_WB_SEL_LEN'd0,
           WB_MEM     = `D_WB_SEL_LEN'd1;

localparam RV_NOP = `D_XLEN'b0010011;
