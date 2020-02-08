module MEM_WB_buffer(input memtoreg_in,
					 input regwrite_in,
					 input [15:0]aluout_in,
					 input [15:0]datamemory_in,
					 input [3:0]MEMWB_rd_or_rt_in,
					 input clk,
					 input rst,
					 input stall,
					 output memtoreg,
					 output regwrite,
					 output [15:0]MEMWB_aluout,
					 output [15:0]datamemory,
					 output [3:0]MEMWB_rd_or_rt);

dff control_signals1 (.q(memtoreg), .d(memtoreg_in), .wen(stall), .clk(clk), .rst(rst));
dff control_signals2 (.q(regwrite), .d(regwrite_in), .wen(stall), .clk(clk), .rst(rst));

dff16_bit mem_alu_out_reg (.q(MEMWB_aluout), .d(aluout_in), .wen(stall), .clk(clk), .rst(rst));
dff16_bit data_memory_reg (.q(datamemory), .d(datamemory_in), .wen(stall), .clk(clk), .rst(rst));
dff4_bit rd_or_rt_out_reg (.q(MEMWB_rd_or_rt), .d(MEMWB_rd_or_rt_in), .wen(stall), .clk(clk), .rst(rst));

endmodule