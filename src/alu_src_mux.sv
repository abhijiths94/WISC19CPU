module alu_src_mux(ALUSrc, rf_inp, sign_ext_inp, alu_inp);

/************************************************************												*		
* This module implements a 2:1 mux used in selecting between*
* register file input and sign extended input data 	using 	*
* ALUSrc signal												*
*************************************************************
*		ALUSrc	|	output									*
*************************************************************
*		0		|	rf_inp									*
*		1		|	sign_ext_inp                            *
*************************************************************/
input ALUSrc;
input [15:0] rf_inp, sign_ext_inp;
output [15:0] alu_inp;

assign alu_inp = ALUSrc ? sign_ext_inp : rf_inp;

endmodule