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


// The control unit takes an instruction, decodes it, and sends control signals
// to the datapath.
module control (
  input [XLEN-1:0] inst,

  output reg [ALU_OP_LEN-1:0] alu_op,
  output reg [SRCA_SEL_LEN-1:0] alu_srca,
  output reg [SRCB_SEL_LEN-1:0] alu_srcb,
  output reg [MEM_TYPE_LEN-1:0] dmem_type,
  output reg dmem_we,
  output reg reg_we,
  output reg [WB_SEL_LEN-1:0] wb_sel,
  output reg [PC_SEL_LEN-1:0] pc_sel,
  output reg error
);

  `include "constants.vh"

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

  wire [6:0] opcode = inst[6:0];
  wire [2:0] funct3 = inst[14:12];
  wire [6:0] funct7 = inst[31:25];

  reg [ALU_OP_LEN-1:0] alu_op_arith;

  always @(*) begin
    alu_op = ALU_ADD;
    alu_srca = SRCA_RS1;
    alu_srcb = SRCB_IMM_I;
    dmem_we = 1'b0;
    reg_we = 1'b0;
    wb_sel = WB_ALU;
    pc_sel = PC_PLUS_FOUR;
    error = 1'b0;

    case (opcode)
      RV_LOAD: begin
        reg_we = 1'b1;
        wb_sel = WB_MEM;
      end
      RV_STORE: begin
        alu_srcb = SRCB_IMM_S;
        dmem_we = 1'b1;
      end
      RV_BRANCH: begin
        alu_srcb = SRCB_RS2;
        pc_sel = PC_BRANCH;
        case (funct3)
          RV_FUNCT3_BEQ: alu_op = ALU_SEQ;
          RV_FUNCT3_BNE: alu_op = ALU_SNE;
          RV_FUNCT3_BLT: alu_op = ALU_SLT;
          RV_FUNCT3_BLTU: alu_op = ALU_SLTU;
          RV_FUNCT3_BGE: alu_op = ALU_SGE;
          RV_FUNCT3_BGEU: alu_op = ALU_SGEU;
          default: begin
            error = 1'b1;
          end
        endcase
      end
      RV_JAL: begin
        pc_sel = PC_JAL;
        alu_srca = SRCA_PC;
        alu_srcb = SRCB_FOUR;
        reg_we = 1'b1;
      end
      RV_JALR: begin
        if (funct3 != 0) begin
          error = 1'b1;
        end
        pc_sel = PC_JALR;
        alu_srca = SRCA_PC;
        alu_srcb = SRCB_FOUR;
        reg_we = 1'b1;
      end
      RV_OP_IMM: begin
        alu_op = alu_op_arith;
        reg_we = 1'b1;
      end
      RV_OP: begin
        alu_op = alu_op_arith;
        alu_srcb = SRCB_RS2;
        reg_we = 1'b1;
      end
      RV_AUIPC: begin
        alu_srca = SRCA_PC;
        alu_srcb = SRCB_IMM_U;
        reg_we = 1'b1;
      end
      RV_LUI: begin
        alu_srca = SRCA_ZERO;
        alu_srcb = SRCB_IMM_U;
        reg_we = 1'b1;
      end
      default: begin
        error = 1'b1;
      end
    endcase
  end

  always @(*) begin
    case (funct3)
      RV_FUNCT3_ADD_SUB: begin
        if ((opcode == RV_OP) && (funct7[5] != 0)) begin
          alu_op_arith = ALU_SUB;
        end else begin
          alu_op_arith = ALU_ADD;
        end
      end
      RV_FUNCT3_SLL: alu_op_arith = ALU_SLL;
      RV_FUNCT3_SLT: alu_op_arith = ALU_SLT;
      RV_FUNCT3_SLTU: alu_op_arith = ALU_SLTU;
      RV_FUNCT3_XOR: alu_op_arith = ALU_XOR;
      RV_FUNCT3_OR: alu_op_arith = ALU_OR;
      RV_FUNCT3_AND: alu_op_arith = ALU_AND;
      RV_FUNCT3_SRA_SRL: begin
        if (funct7[5] != 0) alu_op_arith = ALU_SRA;
        else alu_op_arith = ALU_SRL;
      end
      default: alu_op_arith = ALU_ADD;
    endcase
  end

  assign dmem_type = funct3;

endmodule
