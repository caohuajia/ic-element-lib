// DESCRIPTION: Verilator: Verilog example module
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2003 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0
// ======================================================================

// This is intended to be a complex example of several features, please also
// see the simpler examples/make_hello_c.

`define data_width      6
`define fifo_depth      64


module top
  (
   // Declare some signals so we can see how I/O works
   input              clk,
   input              reset,

   // output wire [1:0]  out_small,
   // output wire [39:0] out_quad,
   // output wire [69:0] out_wide,
   // input [1:0]        in_small,
   // input [39:0]       in_quad,
   // input [69:0]       in_wide

   input endend
   );


   reg                              in_vld;
   reg [`data_width-1:0]                      in_data;
   reg                              read;
   reg                              out_vld;
   reg [`data_width-1:0]                      out_data;
   reg                              full;
   reg                              empty;

   reg [10:0]                      counter;

   initial begin
      in_vld            = 1;
      in_data           = 6;
      // read              = 1;
      full              = 0;

      counter           = 0;
   end

   always @(posedge clk) begin
      if(~reset)begin
         counter <= counter + 1;
         in_data <= counter[`data_width-1:0];
      end
      
      // if(counter >= 100)begin
      //    $finish;
      // end
   end   
   
   assign   read = counter[1];

   always @(posedge clk) begin
      if(full)begin
         $finish;
      end
   end

   fifo  #(
      .DEPTH(`fifo_depth),
      .WIDTH(`data_width)
   ) 
   u_fifo
   (
      .clk(clk),
      .reset(reset),

      .in_vld_i(in_vld),
      .in_data_i(in_data),

      .read_i(read),

      .out_vld_o(out_vld),
      .out_data_o(out_data),

      .full_o(full),
      .empty_o(empty),


      .endend(endend)
   );

   // Print some stuff as an example
   initial begin
      if ($test$plusargs("trace") != 0) begin
         $display("[%0t] Tracing to logs/vlt_dump.vcd...\n", $time);
         $dumpfile("logs/vlt_dump.vcd");
         $dumpvars();
      end
      $display("[%0t] Model running...\n", $time);
   end

endmodule
