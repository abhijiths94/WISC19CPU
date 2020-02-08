module Mem_stage(MEM2MEM_fwd_mux, WB_out, EXMEM_Rt, mem_data_in);

input MEM2MEM_fwd_mux;
input [15:0] EXMEM_Rt, WB_out;
output [15:0] mem_data_in;

//Mem_Read -> lw
//Mem_Write -> sw

assign mem_data_in =  MEM2MEM_fwd_mux ? WB_out : EXMEM_Rt;

//memory1c_ram RAM(.data_out(mem_out), .data_in(data_in), .addr(alu_out), .enable(Mem_Read | Mem_Write), .wr(Mem_Write), .clk(clk), .rst(rst));


endmodule

