
module DataHazardDetection (input IDEX_MemRead, input IFID_MemWrite, input [3:0] IDEX_Rt, input [3:0] IFID_Rt, input [3:0] IFID_Rs,
							output IFID_Write, output Control_Select, output PC_Write);

	wire temp1 = (IDEX_Rt == IFID_Rs) ? 1 : 0;
	wire temp2 = (IDEX_Rt == IFID_Rt) ? 1 : 0;
	
	wire condition = ~IFID_MemWrite & IDEX_MemRead & (temp1 | temp2);
	
	assign IFID_Write = condition ? 0 : 1;
	assign Control_Select = condition ? 0 : 1;
	assign PC_Write = condition ? 0 : 1;
	
endmodule