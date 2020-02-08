module reg_dst_mux(RegDst, r_inp, i_inp, dest_reg_out);

/************************************************************	
* This module implements a 2:1 mux used in selecting the 	*
* output register based on thetype of instruction			*
*************************************************************
*		RegDst	|	output									*
*************************************************************
*		0		|	I-format instr							*
*		1		|	R-format instr                          *
*************************************************************/
input RegDst;
input [3:0] r_inp, i_inp;
output [3:0] dest_reg_out;

assign dest_reg_out = RegDst ? r_inp : i_inp;

endmodule