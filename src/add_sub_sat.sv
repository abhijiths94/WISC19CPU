module add_sub_sat(opcode_bit, A, B, S_out, overflow, negative);

wire cntrl;
assign cntrl = 1'b0;
wire [15:0]S;
output [15:0]S_out;
output negative;
input [15:0]A;
input [15:0]B;
wire Cout;
wire C1,C2,C3,C4;
wire C1_third,C2_third,C3_third,C4_third;
input opcode_bit;
wire [15:0]B_comp;
output overflow;

assign B_comp = (opcode_bit) ? ~B : B;
Carry_Look_Ahead_Adder_Megh CLA1(
    S[3:0],	//SUM
    C1,	//Carry out to be used for overflow calculation
    C1_third,
	A[3:0],
	B_comp[3:0],	//4 bit INPUTS
    opcode_bit,			//Carry INPUT
    cntrl			//control input for 4 bit saturation
	);

Carry_Look_Ahead_Adder_Megh CLA2(
    S[7:4],	//SUM
    C2,	//Carry out to be used for overflow calculation
    C2_third,		//carry for overflow calc, ignore if not final
	A[7:4],
	B_comp[7:4],	//4 bit INPUTS
    C1,			//Carry INPUT
    cntrl			//control input for 4 bit saturation
	);
	

Carry_Look_Ahead_Adder_Megh CLA3(
    S[11:8],	//SUM
    C3,	//Carry out to be used for overflow calculation
    C3_third,		//carry for overflow calc, ignore if not final
	A[11:8],
	B_comp[11:8],	//4 bit INPUTS
    C2,			//Carry INPUT
    cntrl			//control input for 4 bit saturation
	);

Carry_Look_Ahead_Adder_Megh CLA4(
    S[15:12],	//SUM
    Cout,	//Carry out to be used for overflow calculation
    C4_third,		//carry for overflow calc, ignore if not final
	A[15:12],
	B_comp[15:12],	//4 bit INPUTS
    C3,			//Carry INPUT
    cntrl			//control input for 4 bit saturation
	);
assign overflow = (C4_third^Cout);	
assign S_out = (overflow) ? (A[15] ? 16'h8000 : 16'h7FFF) : S;
assign negative = S_out[15];
	
endmodule
