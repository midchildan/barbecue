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


// opcodes
localparam RV_LOAD     = 7'b0000011,
           RV_STORE    = 7'b0100011,
           RV_MADD     = 7'b1000011,
           RV_BRANCH   = 7'b1100011,
           RV_LOAD_FP  = 7'b0000111,
           RV_STORE_FP = 7'b0100111,
           RV_MSUB     = 7'b1000111,
           RV_JALR     = 7'b1100111,
           RV_CUSTOM_0 = 7'b0001011,
           RV_CUSTOM_1 = 7'b0101011,
           RV_NMSUB    = 7'b1001011,
           RV_MISC_MEM = 7'b0001111,
           RV_AMO      = 7'b0101111,
           RV_NMADD    = 7'b1001111,
           RV_JAL      = 7'b1101111,
           RV_OP_IMM   = 7'b0010011,
           RV_OP       = 7'b0110011,
           RV_OP_FP    = 7'b1010011,
           RV_SYSTEM   = 7'b1110011,
           RV_AUIPC    = 7'b0010111,
           RV_LUI      = 7'b0110111,
           RV_CUSTOM_2 = 7'b1011011,
           RV_CUSTOM_3 = 7'b1111011;

// funct3 arithmetic
localparam RV_FUNCT3_ADD_SUB = 0,
           RV_FUNCT3_SLL = 1,
           RV_FUNCT3_SLT = 2,
           RV_FUNCT3_SLTU = 3,
           RV_FUNCT3_XOR = 4,
           RV_FUNCT3_SRA_SRL = 5,
           RV_FUNCT3_OR = 6,
           RV_FUNCT3_AND = 7;

// funct3 branch
localparam RV_FUNCT3_BEQ = 0,
           RV_FUNCT3_BNE = 1,
           RV_FUNCT3_BLT = 4,
           RV_FUNCT3_BGE = 5,
           RV_FUNCT3_BLTU = 6,
           RV_FUNCT3_BGEU = 7;

// funct3 MISC-MEM FUNCT3
localparam RV_FUNCT3_FENCE = 0,
           RV_FUNCT3_FENCE_I = 1;

// funct3 SYSTEM
localparam RV_FUNCT3_PRIV = 0,
           RV_FUNCT3_CSRRW = 1,
           RV_FUNCT3_CSRRS = 2,
           RV_FUNCT3_CSRRC = 3,
           RV_FUNCT3_CSRRWI = 5,
           RV_FUNCT3_CSRRSI = 6,
           RV_FUNCT3_CSRRCI = 7;

// funct12 PRIV
localparam RV_FUNCT12_ECALL = 12'b000000000000,
           RV_FUNCT12_EBREAK = 12'b000000000001,
           RV_FUNCT12_ERET = 12'b000100000000,
           RV_FUNCT12_WFI = 12'b000100000010;

// RVM encodings
localparam RV_FUNCT7_MUL_DIV = 7'd1,
           RV_FUNCT3_MUL = 3'd0,
           RV_FUNCT3_MULH = 3'd1,
           RV_FUNCT3_MULHSU = 3'd2,
           RV_FUNCT3_MULHU = 3'd3,
           RV_FUNCT3_DIV = 3'd4,
           RV_FUNCT3_DIVU = 3'd5,
           RV_FUNCT3_REM = 3'd6,
           RV_FUNCT3_REMU = 3'd7;
