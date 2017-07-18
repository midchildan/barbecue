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


module seven_seg (
  input clk,
  input reset,
  input we,
  input [SEG_ADDR_LEN-1:0] addr,
  input [XLEN-1:0] wdata,

  output reg [SEG_CTRL_LEN-1:0] ctrl
);

  `include "constants.vh"
  `include "fpga_constants.vh"

  localparam CLK_DIVIDER_WIDTH = 10;

  reg [XLEN-1:0] display [0:SEG_DIGITS-1];

  integer i;
  reg clk_slow = 1'b0;
  reg [CLK_DIVIDER_WIDTH-1:0] clk_cnt = 0;

  always @(posedge clk) begin
    if (reset) begin
      clk_slow <= 1'b0;
      clk_cnt <= 0;
    end else begin
      clk_cnt <= clk_cnt + 1;
      if (clk_cnt == 0) begin
        clk_slow <= ~clk_slow;
      end
    end
  end

  always @(posedge clk) begin
    if (reset) begin
      for (i = 0; i < SEG_DIGITS; i = i + 1) begin
        display[i] = `D_XLEN'h0;
      end
    end else begin
      if (we) begin
        display[addr] = wdata;
      end
    end
  end

  reg [SEG_ADDR_LEN-1:0] seg_sel = 0;

  always @(posedge clk_slow) begin
    seg_sel = seg_sel + 1;
    ctrl = {~(1 << seg_sel), 1'b1, ~(display[seg_sel][6:0])};
  end

endmodule
