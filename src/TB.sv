module Testbench();

wire clk, rst_n, hlt;
wire [15:0] pc_out;

cpu c (.clk(clk), .rst_n(rst_n), .hlt(hlt), .pc_out(pc_out));

endmodule