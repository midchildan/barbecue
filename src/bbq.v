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


module bbq #(
  parameter IMEM_NWORDS = (1 << XLEN) / XLEN,
  parameter DMEM_NWORDS = (1 << XLEN) / XLEN
)(
  input clk,
  input reset,

  output reg [XLEN-1:0] console_wdata,
  output reg console_we,
  output reg test_passed = 1'b0,
  output error
);

  `include "constants.vh"

  localparam CONSOLE_ADDR   = `D_XLEN'h1000_0000;
  localparam TEST_STAT_ADDR = `D_XLEN'h2000_0000;

  wire [XLEN-1:0] imem_addr;
  wire [XLEN-1:0] imem_rdata;
  wire [XLEN-1:0] dmem_addr;
  wire [XLEN-1:0] dmem_rdata;
  wire [XLEN-1:0] dmem_io_wdata;
  wire dmem_io_we;
  reg [XLEN-1:0] dmem_wdata;
  reg dmem_we;

  datapath datapath (
    // input
    .clk(clk),
    .reset(reset),
    .imem_rdata(imem_rdata),
    .dmem_rdata(dmem_rdata),

    // output
    .imem_addr(imem_addr),
    .dmem_addr(dmem_addr),
    .dmem_wdata(dmem_io_wdata),
    .dmem_we(dmem_io_we),
    .error(error)
  );

  wire is_console = dmem_io_we && (dmem_addr == CONSOLE_ADDR);
  wire is_test_res = dmem_io_we && (dmem_addr == TEST_STAT_ADDR) && (dmem_io_wdata == 123456789);

  always @(*) begin
    dmem_we = 1'b0;
    dmem_wdata = `D_XLEN'b0;
    console_we = 1'b0;
    console_wdata = `D_XLEN'b0;

    if (is_console) begin
      console_we = 1'b1;
      console_wdata = dmem_io_wdata;
    end else if (is_test_res) begin
      test_passed = 1'b1;
    end else begin
      dmem_we = dmem_io_we;
      dmem_wdata = dmem_io_wdata;
    end
  end

  imem #(
    .NWORDS(IMEM_NWORDS)
  ) imem (
    // input
    .addr(imem_addr),

    // output
    .rdata(imem_rdata)
  );

  dmem #(
    .NWORDS(DMEM_NWORDS)
  ) dmem (
    // input
    .clk(clk),
    .addr(dmem_addr),
    .wdata(dmem_wdata),
    .we(dmem_we),

    // output
    .rdata(dmem_rdata)
  );

endmodule
