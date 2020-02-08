module fulladder_4bit(Sum, Ovfl, A, B, C_in);

output 	[3:0]Sum;
output 	Ovfl;
input	[3:0] A, B;

input	C_in; 
wire	c_out0, c_out1, c_out2;

//module fulladder(sum, c_out, a, b, c_in);
fulladder fa0(.sum(Sum[0]), .c_out(c_out0), .a(A[0]), .b(B[0]), .c_in(C_in));
fulladder fa1(.sum(Sum[1]), .c_out(c_out1), .a(A[1]), .b(B[1]), .c_in(c_out0));
fulladder fa2(.sum(Sum[2]), .c_out(c_out2), .a(A[2]), .b(B[2]), .c_in(c_out1));
fulladder fa3(.sum(Sum[3]), .c_out(Ovfl),   .a(A[3]), .b(B[3]), .c_in(c_out2));

endmodule
