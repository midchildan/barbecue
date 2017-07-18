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
  input reset,
  input [XLEN-1:0] inst,

  output reg [ALU_OP_LEN-1:0] alu_op,
  output reg [SRCA_SEL_LEN-1:0] alu_srca,
  output reg [SRCB_SEL_LEN-1:0] alu_srcb,
  output wire [MEM_TYPE_LEN-1:0] dmem_type,
  output reg dmem_we,
  output reg reg_we,
  output reg [WB_SEL_LEN-1:0] wb_sel,
  output reg [CSR_CMD_LEN-1:0] csr_cmd,
  output reg [CSR_SEL_LEN-1:0] csr_sel,
  output reg [PC_SEL_LEN-1:0] pc_sel,
  output reg error = 1'b0
);

  `include "constants.vh"
  `include "rv_constants.vh"

  wire [6:0] opcode = inst[6:0];
  wire [2:0] funct3 = inst[14:12];
  wire [6:0] funct7 = inst[31:25];
  wire [REG_ADDR_LEN-1:0] rs1_addr = inst[19:15];

  reg [ALU_OP_LEN-1:0] alu_op_arith;

  always @(*) begin
    alu_op = ALU_ADD;
    alu_srca = SRCA_RS1;
    alu_srcb = SRCB_IMM_I;
    dmem_we = 1'b0;
    reg_we = 1'b0;
    wb_sel = WB_ALU;
    csr_sel = CSR_SEL_RS1;
    csr_cmd = CSR_READ;
    pc_sel = PC_PLUS_FOUR;
    if (reset) begin
      error = 1'b0;
    end

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
      RV_SYSTEM: begin
        // Only a few CSR instructions are implemented for RV_SYSTEM
        wb_sel = WB_CSR;
        reg_we = 1'b1;
        case (funct3)
          RV_FUNCT3_CSRRW: begin
            csr_cmd = CSR_WRITE;
          end
          RV_FUNCT3_CSRRS: begin
            csr_cmd = CSR_SET;
          end
          RV_FUNCT3_CSRRC: begin
            csr_cmd = CSR_CLEAR;
          end
          RV_FUNCT3_CSRRWI: begin
            csr_cmd = CSR_WRITE;
            csr_sel = CSR_SEL_IMM;
          end
          RV_FUNCT3_CSRRSI: begin
            csr_cmd = CSR_SET;
            csr_sel = CSR_SEL_IMM;
          end
          RV_FUNCT3_CSRRCI: begin
            csr_cmd = CSR_CLEAR;
            csr_sel = CSR_SEL_IMM;
          end
          default: error = 1'b1;
        endcase
        if (rs1_addr == 0) csr_cmd = CSR_READ;
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
