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


`timescale 1ns / 1ps

module simulation #(
  parameter PC_START    = `D_XLEN'h0,
  parameter STACK_ADDR  = ~(`D_XLEN'h0),
  parameter IMEM_NWORDS = (1 << 14),
  parameter DMEM_NWORDS = (1 << 14)
)(
  input clk,
  input reset
);

  `include "constants.vh"

  // barbecue

  /* verilator  lint_off UNOPTFLAT */
  wire error;
  /* verilator  lint_on UNOPTFLAT */
  wire test_passed;
  wire console_we;
  wire [XLEN-1:0] console_wdata;
  reg enable_logger = 1'b0;

  bbq #(
    .PC_START(PC_START),
    .STACK_ADDR(STACK_ADDR),
    .IMEM_NWORDS(IMEM_NWORDS),
    .DMEM_NWORDS(DMEM_NWORDS)
  ) bbq (
    // input
    .clk(clk),
    .reset(reset),

    // output
    .console_we(console_we),
    .console_wdata(console_wdata),
    .test_passed(test_passed),
    .error(error)
  );

  always @(posedge clk) begin
    if (enable_logger && console_we) begin
      $display("%t console: %s", $time, console_wdata);
    end else if (console_we) begin
      $write("%s", console_wdata[7:0]);
    end
  end

  wire sim_fail    = ~reset && error && ~test_passed;
  wire sim_success = ~reset && error && test_passed;

  always @(posedge clk) begin
    if (sim_success) begin
      $finish;
    end else if (sim_fail) begin
      $fatal;
    end
  end


  // debug

`ifndef VERILATOR
  initial begin
    if ($test$plusargs("vcd")) begin
      $dumpfile("bbq.vcd");
      $dumpvars(0, bbq);
    end
  end
`endif

  initial begin
    if ($test$plusargs("verbose")) begin
      enable_logger = 1'b1;
    end
  end

  top_logger top_logger (
    // input
    .clk(clk),
    .en(enable_logger),
    .reset(reset),
    .error(error)
  );

  pc_logger pc_logger (
    // input
    .clk(clk),
    .en(enable_logger),
    .pc(bbq.datapath.pc),
    .sel(bbq.datapath.pc_mux.sel),
    .next_base(bbq.datapath.pc_mux.base),
    .next_offset(bbq.datapath.pc_mux.offset),
    .branch(bbq.datapath.pc_mux.branch)
  );

  inst_logger inst_logger (
    // input
    .clk(clk),
    .en(enable_logger),
    .inst(bbq.datapath.inst)
  );

  alu_logger alu_logger (
    // input
    .clk(clk),
    .en(enable_logger),
    .opcode(bbq.datapath.alu.op),
    .srca_sel(bbq.datapath.alu_src_mux.srca_sel),
    .srcb_sel(bbq.datapath.alu_src_mux.srcb_sel),
    .srca(bbq.datapath.alu.srca),
    .srcb(bbq.datapath.alu.srcb),
    .out(bbq.datapath.alu.out)
  );

  regfile_logger regfile_logger (
    // input
    .clk(clk),
    .en(enable_logger),
    .ra1(bbq.datapath.regfile.ra1),
    .ra2(bbq.datapath.regfile.ra2),
    .wa(bbq.datapath.regfile.wa),
    .we(bbq.datapath.regfile.we),
    .rd1(bbq.datapath.regfile.rd1),
    .rd2(bbq.datapath.regfile.rd2),
    .wdata(bbq.datapath.regfile.wdata)
  );

  imem_logger imem_logger (
    // input
    .clk(clk),
    .en(enable_logger),
    .addr(bbq.imem.addr),
    .rdata(bbq.imem.rdata)
  );

  dmem_logger dmem_logger (
    // input
    .clk(clk),
    .en(enable_logger),
    .we(bbq.dmem.we),
    .addr(bbq.dmem.addr),
    .rdata(bbq.dmem.rdata),
    .wdata(bbq.dmem.wdata),
    .wmask(bbq.dmem.wmask)
  );

endmodule // module simulation


// loggers

module top_logger (
  input clk,
  input en,
  input reset,
  input error
);

  always @(posedge clk) begin
    if (en) begin
      $display("%t top: reset=%b error=%b", $time, reset, error);
    end
  end

endmodule // module top_logger

module pc_logger (
  input clk,
  input en,
  input [XLEN-1:0] pc,
  input [PC_SEL_LEN-1:0] sel,
  input [XLEN-1:0] next_base,
  input [XLEN-1:0] next_offset,
  input branch
);

  `include "constants.vh"

  localparam SEL_STR_LEN = 8*6;

  reg [SEL_STR_LEN-1:0] sel_str;

  always @(*) begin
    case (sel)
      PC_PLUS_FOUR: sel_str = "four";
      PC_BRANCH:    sel_str = "branch";
      PC_JAL:       sel_str = "jal";
      PC_JALR:      sel_str = "jalr";
      default:      sel_str = "ERR";
    endcase
  end

  always @(posedge clk) begin
    if (en) begin
      $display("%t pc: pc=0x%x sel=%s next_base=0x%x next_offset=0x%x branch=%b",
               $time, pc, sel_str, next_base, next_offset, branch);
    end
  end

endmodule // module pc_logger

module inst_logger (
  input clk,
  input en,
  input [XLEN-1:0] inst
);

  `include "constants.vh"
  `include "rv_constants.vh"

  localparam OP_STR_LEN = 8*6;
  localparam ARITH_STR_LEN = 8*4;

  wire [6:0] opcode = inst[6:0];
  wire [2:0] funct3 = inst[14:12];
  wire [6:0] funct7 = inst[31:25];

  reg [OP_STR_LEN-1:0] inst_str;
  reg [ARITH_STR_LEN-1:0] arith_str;

  always @(*) begin
    inst_str = "ERR";

    case (opcode)
      RV_LOAD: inst_str = "load";
      RV_STORE: inst_str = "store";
      RV_BRANCH: begin
        case (funct3)
          RV_FUNCT3_BEQ:  inst_str = "beq";
          RV_FUNCT3_BNE:  inst_str = "bne";
          RV_FUNCT3_BLT:  inst_str = "blt";
          RV_FUNCT3_BLTU: inst_str = "bltu";
          RV_FUNCT3_BGE:  inst_str = "bge";
          RV_FUNCT3_BGEU: inst_str = "bgeu";
          default:        inst_str = "ERR";
        endcase
      end
      RV_JAL: inst_str = "jal";
      RV_JALR: begin
        inst_str = "jalr";
        if (funct3 != 0) begin
          inst_str = "ERR";
        end
      end
      RV_OP_IMM: inst_str = {arith_str, "i"};
      RV_OP: inst_str = arith_str;
      RV_SYSTEM: begin
        case (funct3)
          RV_FUNCT3_CSRRW:  inst_str = "csrrw";
          RV_FUNCT3_CSRRS:  inst_str = "csrrs";
          RV_FUNCT3_CSRRC:  inst_str = "csrrc";
          RV_FUNCT3_CSRRWI: inst_str = "csrrwi";
          RV_FUNCT3_CSRRSI: inst_str = "csrrsi";
          RV_FUNCT3_CSRRCI: inst_str = "csrrci";
          default:          inst_str = "ERR";
        endcase
      end
      RV_AUIPC: inst_str = "auipc";
      RV_LUI: inst_str = "lui";
    endcase // case (opcode)

    case (inst)
      RV_NOP:     inst_str = "nop";
      RV_INVALID: inst_str = "invalid";
    endcase

  end // always @(*)

  always @(*) begin
    case (funct3)
      RV_FUNCT3_ADD_SUB: begin
        if ((opcode == RV_OP) && (funct7[5] != 0)) begin
          arith_str = "sub";
        end else begin
          arith_str = "add";
        end
      end
      RV_FUNCT3_SLL:  arith_str = "sll";
      RV_FUNCT3_SLT:  arith_str = "slt";
      RV_FUNCT3_SLTU: arith_str = "sltu";
      RV_FUNCT3_XOR:  arith_str = "xor";
      RV_FUNCT3_OR:   arith_str = "or";
      RV_FUNCT3_AND:  arith_str = "and";
      RV_FUNCT3_SRA_SRL: begin
        if (funct7[5] != 0) arith_str = "sra";
        else arith_str = "srl";
      end
      default: arith_str = "add";
    endcase
  end

  always @(posedge clk) begin
    if (en) begin
      $display("%t inst: op=%s rdata=0x%x bits=%b", $time, inst_str, inst, inst);
    end
  end

endmodule // module inst_logger

module alu_logger (
  input clk,
  input en,
  input [ALU_OP_LEN-1:0] opcode,
  input [SRCA_SEL_LEN-1:0] srca_sel,
  input [SRCB_SEL_LEN-1:0] srcb_sel,
  input [XLEN-1:0] srca,
  input [XLEN-1:0] srcb,
  input [XLEN-1:0] out
);

  `include "constants.vh"

  localparam OP_STR_LEN = 8*4;
  localparam SRCA_SEL_STR_LEN = 8*4;
  localparam SRCB_SEL_STR_LEN = 8*5;

  reg [OP_STR_LEN-1:0] op_str;

  always @(*) begin
    case (opcode)
      ALU_ADD:  op_str = "add";
      ALU_SLL:  op_str = "sll";
      ALU_XOR:  op_str = "xor";
      ALU_OR:   op_str = "or";
      ALU_AND:  op_str = "and";
      ALU_SRL:  op_str = "srl";
      ALU_SEQ:  op_str = "seq";
      ALU_SNE:  op_str = "sne";
      ALU_SUB:  op_str = "sub";
      ALU_SRA:  op_str = "sra";
      ALU_SLT:  op_str = "slt";
      ALU_SGE:  op_str = "sge";
      ALU_SLTU: op_str = "sltu";
      ALU_SGEU: op_str = "sgeu";
      default:  op_str = "ERR";
    endcase
  end

  reg [SRCA_SEL_STR_LEN-1:0] srca_sel_str;
  reg [SRCB_SEL_STR_LEN-1:0] srcb_sel_str;

  always @(*) begin
    case (srca_sel)
      SRCA_RS1:  srca_sel_str = "rs1";
      SRCA_PC:   srca_sel_str = "pc";
      SRCA_ZERO: srca_sel_str = "zero";
      default:   srca_sel_str = "ERR";
    endcase
  end

  always @(*) begin
    case (srcb_sel)
      SRCB_RS2:   srcb_sel_str = "rs2";
      SRCB_IMM_I: srcb_sel_str = "imm_i";
      SRCB_IMM_S: srcb_sel_str = "imm_s";
      SRCB_IMM_U: srcb_sel_str = "imm_u";
      SRCB_IMM_J: srcb_sel_str = "imm_j";
      SRCB_FOUR:  srcb_sel_str = "four";
      SRCB_ZERO:  srcb_sel_str = "zero";
      default:    srcb_sel_str = "ERR";
    endcase
  end

  always @(posedge clk) begin
    if (en) begin
      $display("%t alu: opcode=%s srca_sel=%s srca=%d srcb_sel=%s srcb=%d out=%d",
               $time, op_str, srca_sel_str, srca, srcb_sel_str, srcb, out);
    end
  end

endmodule // module alu_logger

module regfile_logger (
  input clk,
  input en,
  input [REG_ADDR_LEN-1:0] ra1, ra2, wa,
  input we,
  input [XLEN-1:0] rd1,
  input [XLEN-1:0] rd2,
  input [XLEN-1:0] wdata
);

  `include "constants.vh"

  always @(posedge clk) begin
    if (en) begin
      $display("%t regfile: ra1=%d ra2=%d wa=%d we=%d rd1=%d rd2=%d wdata=%d",
               $time, ra1, ra2, wa, we, rd1, rd2, wdata);
    end
  end
endmodule // module regfile_logger

module imem_logger (
  input clk,
  input en,
  input [XLEN-1:0] addr,
  input [XLEN-1:0] rdata
);

  `include "constants.vh"

  always @(posedge clk) begin
    if (en) begin
      $display("%t imem: addr=0x%x rdata=0x%x bits=%b", $time, addr, rdata, rdata);
    end
  end

endmodule // module imem_logger

module dmem_logger (
  input clk,
  input en,
  input we,
  input [XLEN-1:0] addr,
  input [XLEN-1:0] rdata,
  input [XLEN-1:0] wdata,
  input [XLEN-1:0] wmask
);

  `include "constants.vh"

  always @(posedge clk) begin
    if (en) begin
      $display("%t dmem: we=%b addr=0x%x rdata=0x%x wdata=0x%x wmask=0x%x",
               $time, we, addr, rdata, wdata, wmask);
    end
  end

endmodule // module dmem_logger
