module alu_red_tb;
    // Inputs
    reg [15:0] A;
    reg [15:0] B;
 
    // Outputs
    wire [15:0] S;
    wire Cout;
	reg [15:0]out;
	reg [7:0]inter;

    // Instantiate the Device Under Test (iDUT)
    alu_red iDUT(.S_RED(S),
			   .A(A),
			   .B(B)
				);
	assign inter = (A[7:0]+A[15:8])+(B[7:0]+B[15:8]);
	assign out = {{8{inter[7]}},inter[7:0]};
    initial begin
    // Initialize Inputs
    A = 0;  B = 0;  
    // Wait 100 ns for global reset to finish
    #100;
       
    // Add stimulus here
    A=16'h3524;B=16'h5e81;
    
    end 
 
 endmodule

