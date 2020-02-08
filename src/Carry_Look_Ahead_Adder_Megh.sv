
module Carry_Look_Ahead_Adder_Megh(
    output [3:0] S_out,	//SUM
    output Cout,	//Carry out to be used for overflow calculation
    output C3,
	input [3:0] A,
input [3:0]B,	//4 bit INPUTS
    input Cin,			//Carry INPUT
    input cntrl			//control input for 4 bit saturation
	);
    wire [3:0] G,P,C;
	wire [3:0] S;
    assign G = A & B; //Generate
    assign P = A ^ B; //Propagate
    assign C[0] = Cin;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) |  (P[2] & P[1] & P[0] & C[0]);
	assign C3 = C[3];
    assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) |(P[3] & P[2] & P[1] & P[0] & C[0]);
    assign S = P ^ C;
	assign S_out = (cntrl) ? ((C[3]^Cout) ? (A[3] ? 4'b1000 : 4'b0111) : S):S;
	endmodule