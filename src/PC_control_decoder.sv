module PC_control_decoder( C, I, F, PC_in, Branch, BR_addr, PC_out, en);

input [2:0] C, F;
input [8:0] I;
input [15:0] PC_in;
input Branch;      // indicate what type of instruction it is - b/br
input [15:0] BR_addr;    // branch register contents 
output reg en;
output [15:0] PC_out;

wire [15:0] out1, out2, out3, I_ext;

/********************************************************
*********************************************************
*	000	Not Equal (Z = 0)								*
*	001	Equal (Z = 1)                                   *
*	010	Greater Than (Z = N = 0)                        *
*	011	Less Than (N = 1)                               *
*	100	Greater Than or Equal (Z = 1 or Z = N = 0)      *
*	101	Less Than or Equal (N = 1 or Z = 1)             *
*	110	Overflow (V = 1)                                *
*	111	Unconditional                                   *
*********************************************************
*********************************************************/

/******************
*	flags = NVZ	  *
*******************/

/* PC + 2 + I << 1*/
assign I_ext = {{6{I[8]}}, I[8:0] ,1'b0};
PC_adder PC_add2(.add_in(PC_in), .offset(I_ext), .Sum(out1));

always@*
begin
case(C)
3'b000: en = (F[0]==0) ? 1: 0;
3'b001: en = (F[0]==1) ? 1: 0;
3'b010: en = (F[0]==0) ? ((F[2]==0) ? 1 : 0) : 0;
3'b011: en = (F[0]==0) ? ((F[2]==1) ? 1 : 0) : 0;
3'b100: en = (F[0]==1) ? 1 : ((F[2]==0) ? 1 : 0);
3'b101: en = (F[0]==1) ? 1 : ((F[2]==1) ? 1 : 0);
3'b110: en = (F[1]==1) ? 1: 0;
3'b111: en = 1;
default: en = 0;
endcase
end

assign PC_out = (Branch == 1) ? BR_addr : out1; 

endmodule