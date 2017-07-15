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


// The datapath is where data flows through and is processed.
module datapath #(
  parameter ENABLE_COUNTERS = 1,
  parameter PC_START        = `D_XLEN'h0,
  parameter STACK_ADDR      = ~(`D_XLEN'h0)
)(
  input clk,
  input reset,
  input [XLEN-1:0] imem_rdata,
  input [XLEN-1:0] dmem_rdata,

  output [XLEN-1:0] imem_addr,
  output [XLEN-1:0] dmem_addr,
  output [XLEN-1:0] dmem_wdata,
  output reg [XLEN-1:0] dmem_wmask,
  output dmem_we,
  output error
);

  `include "constants.vh"

  wire branch;
  wire [PC_SEL_LEN-1:0] pc_sel;
  wire [XLEN-1:0] pc_next;
  reg [XLEN-1:0] pc;
  reg [XLEN-1:0] inst;

  wire [XLEN-1:0] imm_i = {{21{inst[31]}}, inst[30:20]};
  wire [XLEN-1:0] imm_s = {{21{inst[31]}}, inst[30:25], inst[11:7]};
  wire [XLEN-1:0] imm_b = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
  wire [XLEN-1:0] imm_u = {inst[31:12], 12'b0};
  wire [XLEN-1:0] imm_j = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};

  wire [XLEN-1:0] rs1_data;
  wire [XLEN-1:0] rs2_data;
  wire [ALU_OP_LEN-1:0] alu_op;
  wire [SRCA_SEL_LEN-1:0] srca_sel;
  wire [SRCB_SEL_LEN-1:0] srcb_sel;

  wire [MEM_TYPE_LEN-1:0] dmem_type;

  wire reg_we;
  wire [WB_SEL_LEN-1:0] wb_sel;
  reg [XLEN-1:0] reg_wdata;

  wire [CSR_CMD_LEN-1:0] csr_cmd;
  wire [CSR_SEL_LEN-1:0] csr_sel;
  wire [XLEN-1:0] csr_rdata;


  control control (
    // input
    .reset(reset),
    .inst(inst),

    // output
    .alu_op(alu_op),
    .alu_srca(srca_sel),
    .alu_srcb(srcb_sel),
    .dmem_type(dmem_type),
    .dmem_we(dmem_we),
    .reg_we(reg_we),
    .wb_sel(wb_sel),
    .csr_cmd(csr_cmd),
    .csr_sel(csr_sel),
    .pc_sel(pc_sel),
    .error(error)
  );

  pc_mux pc_mux (
    // input
    .pc_in(pc),
    .sel(pc_sel),
    .branch(branch),
    .imm_i(imm_i),
    .imm_b(imm_b),
    .imm_j(imm_j),
    .rs1_data(rs1_data),

    //output
    .pc_out(pc_next)
  );


  // Instruction Fetch

  assign imem_addr = pc;

  always @(*) begin
    if (reset) inst = RV_NOP;
    else if (error) inst = RV_INVALID;
    else inst = imem_rdata;
  end

  always @(posedge clk) begin
    if (reset) pc <= PC_START;
    else if (~error) pc <= pc_next;
  end


  // Execute

  wire [REG_ADDR_LEN-1:0] rs1_addr = inst[19:15];
  wire [REG_ADDR_LEN-1:0] rs2_addr = inst[24:20];
  wire [REG_ADDR_LEN-1:0] rd_addr = inst[11:7];

  regfile #(
    .STACK_ADDR(STACK_ADDR)
  ) regfile (
    // input
    .clk(clk),
    .reset(reset),
    .ra1(rs1_addr),
    .ra2(rs2_addr),
    .wa(rd_addr),
    .we(reg_we),
    .wdata(reg_wdata),

    // output
    .rd1(rs1_data),
    .rd2(rs2_data)
  );

  wire [XLEN-1:0] alu_srca;
  wire [XLEN-1:0] alu_srcb;

  alu_src_mux alu_src_mux (
    // input
    .srca_sel(srca_sel),
    .srcb_sel(srcb_sel),
    .rs1(rs1_data),
    .rs2(rs2_data),
    .pc(pc),
    .imm_i(imm_i),
    .imm_s(imm_s),
    .imm_u(imm_u),
    .imm_j(imm_j),

    // output
    .srca(alu_srca),
    .srcb(alu_srcb)
  );

  wire [XLEN-1:0] alu_out;
  assign branch = alu_out[0];

  alu alu (
    // input
    .op(alu_op),
    .srca(alu_srca),
    .srcb(alu_srcb),

    // output
    .out(alu_out)
  );


  // Memory

  wire [XLEN-1:0] load_data;
  wire [XLEN-1:0] store_mask;

  mem_load mem_load (
    // input
    .addr(alu_out),
    .data(dmem_rdata),
    .load_type(dmem_type),

    // output
    .to_load(load_data)
  );

  assign dmem_addr = alu_out;
  assign dmem_wdata = rs2_data;

  always @(*) begin
    case (dmem_type)
      MEM_B:   dmem_wmask = `D_XLEN'hFF;
      MEM_H:   dmem_wmask = `D_XLEN'hFFFF;
      default: dmem_wmask = ~(`D_XLEN'h0);
    endcase
  end


  // Write Back

  always @(*) begin
    case (wb_sel)
      WB_MEM: reg_wdata = load_data;
      WB_CSR: reg_wdata = csr_rdata;
      default: reg_wdata = alu_out;
    endcase
  end

  generate
  if (ENABLE_COUNTERS) begin
    wire [CSR_ADDR_LEN-1:0] csr_addr = inst[31:20];
    wire [XLEN-1:0] csr_imm = {{(XLEN - 5){1'b0}}, inst[19:15]};
    wire [XLEN-1:0] csr_wdata = (csr_sel == CSR_SEL_IMM) ? csr_imm : rs1_data;

    csr csr (
      // input
      .clk(clk),
      .reset(reset),
      .cmd(csr_cmd),
      .addr(csr_addr),
      .wdata(csr_wdata),

      // output
      .rdata(csr_rdata)
    );
  end else begin
    assign csr_rdata = 0;
  end
  endgenerate

endmodule
