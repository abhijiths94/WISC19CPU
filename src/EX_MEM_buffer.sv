module EX_MEM_buffer(input memtoreg_in,
					 input regwrite_in,
					 input memread_in,
					 input memwrite_in,
					 input [15:0]aluout_in,
					 input [15:0]EX_MEM_rt_to_mem_in,
					 input [3:0]EX_MEM_rd_or_rt_in,
					 input clk,
					 input rst,
					 input stall,
					 output memtoreg,
					 output regwrite,
					 output memread,
					 output memwrite,
					 output [15:0]aluout,
					 output [15:0]EX_MEM_rt_to_mem,
					 output [3:0]EX_MEM_rd_or_rt);

dff4_bit control_signals(.q({memtoreg,regwrite,memread,memwrite}), .d({memtoreg_in,regwrite_in,memread_in,memwrite_in}), .wen(stall), .clk(clk), .rst(rst));
dff16_bit ALU_reg(.q(aluout), .d(aluout_in), .wen(stall), .clk(clk), .rst(rst));
dff4_bit rd_rt_reg(.q(EX_MEM_rd_or_rt), .d(EX_MEM_rd_or_rt_in), .wen(stall), .clk(clk), .rst(rst));
dff16_bit rt_to_mem(.q(EX_MEM_rt_to_mem), .d(EX_MEM_rt_to_mem_in), .wen(stall), .clk(clk), .rst(rst));

endmodule