module Fetch_stage(clk, rst, hlt , sel, wen, PC_decoder_branch, PC_two, PC_out);

input clk, rst, hlt, sel, wen;
input [15:0] PC_decoder_branch;
output [15:0] PC_out;
output [15:0] PC_two;

wire [15:0] nxt_inst_addr;

/* Pass the current value of PC to the Instruction memory , inst_addr*/
dff PC [15:0] (.q(PC_out), .d(nxt_inst_addr), .wen(wen), .clk(clk), .rst(rst));

/* PC + 2*/
PC_adder PC_add1(.add_in(PC_out), .offset(16'h2), .Sum(PC_two));

wire [15:0] PC_inter = sel ? PC_decoder_branch : PC_two;

assign nxt_inst_addr = hlt ? PC_out : PC_inter;

endmodule
