module ID_EX_buffer(input clk,
					input rst,
					input hlt,
					input stall, /// flush -> nop -> clear to zero --------------->
					input memtoreg_in,
					input regwrite_in,
					input memread_in,
					input memwrite_in,
					input [3:0]ALUOp_in,
					input RegDst_in,
					input ALUSrc_in,
					input [15:0] pc_out_two,
					input PCS_en_in,
					input [15:0]register_1,
					input [15:0]register_2,
					input [15:0]sign_ext,
					input [3:0]reg_rs,	//rs
					input [3:0]reg_rt,	//rt
					input [3:0]reg_rd,
					
					
					output memtoreg,
					output regwrite,
					output memread,
					output memwrite,
					output [3:0]ALUOp,
					output RegDst,
					output ALUSrc,
					output PCS_en,
					output [15:0] pc_out_two_out,
					output [15:0]register_1_out,
					output [15:0]register_2_out,
					output [3:0]rs,
					output [3:0]rt,
					output [3:0]rd,
					output [15:0]sign_ext_out,
					output IDEX_hlt
					);
					


dff ID_EX_RegWrite(.q(regwrite), .d(regwrite_in), .wen(stall), .clk(clk), .rst(rst));
dff ID_EX_MEMtoreg(.q(memtoreg), .d(memtoreg_in), .wen(stall), .clk(clk), .rst(rst));

dff ID_EX_PCS_en(.q(PCS_en), .d(PCS_en_in), .wen(stall), .clk(clk), .rst(rst));
dff ID_EX_hlt(.q(IDEX_hlt), .d(hlt), .wen(stall), .clk(clk), .rst(rst));

dff2_bit ID_EX_EXreg(.q({RegDst,ALUSrc}), .d({RegDst_in,ALUSrc_in}), .wen(stall), .clk(clk), .rst(rst));
dff2_bit ID_EX_MEMreg(.q({memread,memwrite}), .d({memread_in,memwrite_in}), .wen(stall), .clk(clk), .rst(rst));
dff4_bit aluop_reg(.q(ALUOp), .d(ALUOp_in), .wen(stall), .clk(clk), .rst(rst));

dff16_bit pc_out_2(.q(pc_out_two_out), .d(pc_out_two), .wen(stall), .clk(clk), .rst(rst));
dff16_bit Readdata2(.q(register_2_out), .d(register_2), .wen(stall), .clk(clk), .rst(rst));
dff16_bit Readdata1(.q(register_1_out), .d(register_1), .wen(stall), .clk(clk), .rst(rst));

dff4_bit rs_reg(.q(rs), .d(reg_rs), .wen(stall), .clk(clk), .rst(rst));
dff4_bit rt_reg(.q(rt), .d(reg_rt), .wen(stall), .clk(clk), .rst(rst));
dff4_bit rd_reg(.q(rd), .d(reg_rd), .wen(stall), .clk(clk), .rst(rst));

dff16_bit signextend_reg(.q(sign_ext_out), .d(sign_ext), .wen(stall), .clk(clk), .rst(rst));

endmodule