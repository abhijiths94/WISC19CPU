module alu_xor( output [15:0] XOR_out,	//XOR output
	input [15:0] A,B	//16 bit INPUTS	
	);
assign XOR_out = A^B;

endmodule
