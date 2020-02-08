module WriteBack_Stage (input [15:0] MEMWB_data_mem, input [15:0] MEMWB_alu_out, input MEMWB_memtoreg, output [15:0] WB_out);

	assign WB_out = MEMWB_memtoreg ? MEMWB_data_mem : MEMWB_alu_out;

endmodule