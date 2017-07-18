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

module top #(
  parameter PC_START = `D_XLEN'h0,
  parameter STACK_ADDR  = ~(`D_XLEN'h0),
  parameter IMEM_NWORDS = (1 << 14),
  parameter DMEM_NWORDS = (1 << 14)
)(
  input clk,
  input reset,

  output ld0,
  output ld1,
  output [SEG_CTRL_LEN-1:0] seven_seg_ctrl
);

  `include "constants.vh"
  `include "fpga_constants.vh"

  wire error;
  wire test_passed;
  wire seven_seg_we;
  wire [XLEN-1:0] seven_seg_addr;
  wire [XLEN-1:0] seven_seg_wdata;

  assign ld0 = ~error;
  assign ld1 = test_passed;

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
    .console_we(),
    .console_wdata(),
    .test_passed(test_passed),
    .seven_seg_we(seven_seg_we),
    .seven_seg_addr(seven_seg_addr),
    .seven_seg_wdata(seven_seg_wdata),
    .error(error)
  );

  seven_seg seven_seg (
    // input
    .clk(clk),
    .reset(reset),
    .we(seven_seg_we),
    .addr(seven_seg_addr[3:2]),
    .wdata(seven_seg_wdata),

    // output
    .ctrl(seven_seg_ctrl)
  );

endmodule
