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


// This module contains a few performance counters.
module csr (
  input clk,
  input reset,
  input [CSR_CMD_LEN-1:0] cmd,
  input [CSR_ADDR_LEN-1:0] addr,
  input [XLEN-1:0] wdata,

  output reg [XLEN-1:0] rdata
);

  `include "constants.vh"

  reg [CSR_COUNTER_LEN-1:0] cycle_cnt;
  reg [CSR_COUNTER_LEN-1:0] time_cnt;
  reg [CSR_COUNTER_LEN-1:0] instret;
  reg [XLEN-1:0] to_write;
  reg we;

  always @(*) begin
    case (cmd)
      CSR_WRITE: begin
        we = 1'b1;
        to_write = wdata;
      end
      CSR_SET: begin
        we = 1'b1;
        to_write = rdata | wdata;
      end
      CSR_CLEAR: begin
        we = 1'b1;
        to_write = rdata & ~wdata;
      end
      default: begin
        we = 1'b0;
        to_write = wdata;
      end
    endcase
  end

  always @(*) begin
    case (addr)
      CSR_ADDR_CYCLE: rdata = cycle_cnt[0 +: XLEN];
      CSR_ADDR_TIME: rdata = time_cnt[0 +: XLEN];
      CSR_ADDR_INSTRET: rdata = instret[0 +: XLEN];
      CSR_ADDR_CYCLEH: rdata = cycle_cnt[XLEN +: XLEN];
      CSR_ADDR_TIMEH: rdata = time_cnt[XLEN +: XLEN];
      CSR_ADDR_INSTRETH: rdata = instret[XLEN +: XLEN];
      default: rdata = 0;
    endcase
  end

  always @(posedge clk) begin
    if (reset) begin
      cycle_cnt <= 0;
      time_cnt <= 0;
      instret <= 0;
    end else begin
      cycle_cnt <= cycle_cnt + 1;
      time_cnt <= time_cnt + 1;
      instret <= instret + 1;
      if (we) begin
        case (addr)
          CSR_ADDR_CYCLE: cycle_cnt[0 +: XLEN] <= to_write;
          CSR_ADDR_TIME: time_cnt[0 +: XLEN] <= to_write;
          CSR_ADDR_INSTRET: instret[0 +: XLEN] <= to_write;
          CSR_ADDR_CYCLEH: cycle_cnt[XLEN +: XLEN] <= to_write;
          CSR_ADDR_TIMEH: time_cnt[XLEN +: XLEN] <= to_write;
          CSR_ADDR_INSTRETH: instret[XLEN +: XLEN] <= to_write;
          default: ;
        endcase
      end // if (we)
    end // if (reset)
  end // always @(posedge clk)

endmodule
