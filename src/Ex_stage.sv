module Execute_stage(clk, rst, pc_out, ALUOp, RegDst, ALUSrc, PCS_en, rs_data, rt_data, rt, rd, sign_ext_out, ex2ex_inp, mem2ex_inp, fwd_mux_a_sel, fwd_mux_b_sel,
					alu_out, rt_to_mem, dest_reg_out, Flag );
					
input clk, rst;
input RegDst, ALUSrc, PCS_en;
input [1:0] fwd_mux_a_sel, fwd_mux_b_sel;
input [15:0] rs_data, rt_data, sign_ext_out, ex2ex_inp, mem2ex_inp, pc_out;
input [3:0] rt, rd, ALUOp;

output [15:0] alu_out, rt_to_mem;
output [3:0]  dest_reg_out;
output [2:0] Flag;

wire [15:0] alu_inp_1, alu_inp_2, alu_inp_2_temp, alu_inp_mux_1, alu_inp_mux_2;

assign alu_inp_1 = PCS_en ? pc_out : alu_inp_mux_1;
assign alu_inp_2 = PCS_en ? 16'h0 : alu_inp_2_temp;

fwd_mux fwd_mux_a(.inp_rf(rs_data), .inp_ex2ex(ex2ex_inp), .inp3_mem2ex(mem2ex_inp), .sel(fwd_mux_a_sel), .alu_inp(alu_inp_mux_1));

fwd_mux fwd_mux_b(.inp_rf(rt_data), .inp_ex2ex(ex2ex_inp), .inp3_mem2ex(mem2ex_inp), .sel(fwd_mux_b_sel), .alu_inp(alu_inp_mux_2));

alu_phase_one alu (	.clk(clk), .rst_n(rst), .wen(1'b1), .A(alu_inp_1), .B(alu_inp_2), .opcode(ALUOp), 
					.ALU_OUT_FINAL(alu_out), .FLAGS(Flag));
					 


reg_dst_mux regdst_mux (.RegDst(RegDst), .r_inp(rd), .i_inp(rt), .dest_reg_out(dest_reg_out));

alu_src_mux alusrc_mux (.ALUSrc(ALUSrc), .rf_inp(alu_inp_mux_2), .sign_ext_inp(sign_ext_out), .alu_inp(alu_inp_2_temp));

assign rt_to_mem = alu_inp_mux_2;

endmodule


