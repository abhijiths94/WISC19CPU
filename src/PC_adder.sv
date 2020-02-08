module PC_adder(add_in, offset, Sum);

input [15:0] add_in, offset;
output [15:0] Sum;

wire s1,s2,s3;

fulladder_4bit fa_1(.Sum(Sum[3:0]), .Ovfl(s1), .A(add_in[3:0]), .B(offset[3:0]), .C_in(1'b0));
fulladder_4bit fa_2(.Sum(Sum[7:4]), .Ovfl(s2), .A(add_in[7:4]), .B(offset[7:4]), .C_in(s1));
fulladder_4bit fa_3(.Sum(Sum[11:8]), .Ovfl(s3), .A(add_in[11:8]), .B(offset[11:8]), .C_in(s2));
fulladder_4bit fa_4(.Sum(Sum[15:12]), .Ovfl(), .A(add_in[15:12]), .B(offset[15:12]), .C_in(s3));

endmodule
