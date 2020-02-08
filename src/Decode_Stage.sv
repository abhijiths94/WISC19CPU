module Decode_stage (input clk, input rst, input [15:0] Instr, input [15:0] MEMWB_dst_data, input [2:0] Flags, input [15:0] IFID_PC_two, input MEMWB_RegWrite, input [3:0] MEMWB_rt_d, input i_cache_stall,
					 output [15:0] data1, output [15:0] data2, output [15:0] imm,
					 output hlt, output RegDst, output ALUSrc, output Branch,
					 output MemRead, output MemWrite, output RegWrite, output MemToReg,
					 output PCS_en, output [15:0] nxt_pc_addr, output en, output Flush,
					 output [3:0] rd, output [3:0] rs, output [3:0] rt);

  
  wire [2:0] cond;
  wire [8:0] imm_branch;
  wire [1:0] branch_sel;

  ControlUnit CU  (.Opcode(Instr[15:12]), .RegDst(RegDst), .branch_in(branch_sel[0] & en & i_cache_stall),
                   .ALUSrc(ALUSrc), .Branch(Branch), .MemRead(MemRead),
                   .MemWrite(MemWrite), .RegWrite(RegWrite), .MemToReg(MemToReg), .Flush(Flush));
  
  PC_control_decoder PC_cntrl( .C(cond), .I(imm_branch), .F(Flags), .PC_in(IFID_PC_two), .Branch(branch_sel[1]), .BR_addr(data1), .PC_out(nxt_pc_addr), .en(en));

  DecodeValues DV (.rst(rst), .Instr(Instr), .cond(cond), .rd(rd),
                   .rs(rs), .rt(rt), .imm(imm), .imm_branch(imm_branch),
                   .branch_sel(branch_sel), .hlt(hlt), .PCS_en(PCS_en));

  RegisterFile RF (.clk(clk), .rst(rst), .SrcReg1(rs), .SrcReg2(rt),
                   .DstReg(MEMWB_rt_d), .WriteReg(MEMWB_RegWrite), .DstData(MEMWB_dst_data),
                   .SrcData1_out(data1), .SrcData2_out(data2));

endmodule
