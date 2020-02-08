module fwd_mux(inp_rf, inp_ex2ex, inp3_mem2ex, sel, alu_inp);

/************************************************************												*		
* This module implements a 3:1 mux used in forwarding data 	*
*************************************************************
*		sel		|	output									*
*************************************************************
*		00		|	inp_rf									*
*		01		|	inp_ex2ex                               *
*		10		|	inp3_mem2ex                             *
*				|                                           *
*************************************************************/

input [1:0] sel;
input [15:0] inp_rf, inp_ex2ex, inp3_mem2ex;
output [15:0] alu_inp;

localparam NO_FWD 	= 2'b00;
localparam EX2EX	= 2'b01;
localparam MEM2EX	= 2'b10;

assign alu_inp = (sel == EX2EX) ? inp_ex2ex : (sel == MEM2EX) ? inp3_mem2ex : inp_rf;

endmodule
