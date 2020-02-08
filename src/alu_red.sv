module alu_red(output [15:0]red,
			   input [15:0]A,
			   input [15:0]B
				);

    wire opcode_bit;
    wire cntrl;
    assign cntrl = 0;
    assign opcode_bit = 0;
    wire [7:0] AB1_sum, AB2_sum;		//intermediates for calculating RED 
    wire C1,C2,C3,C4,C5, C6, C7;			//carry outs for each CLA
    wire C1_third,C2_third,C3_third,C4_third, C5_third, C6_third , C7_third;
    
    
    wire [11:0] red_out;
    
    Carry_Look_Ahead_Adder_Megh AB11(
        AB1_sum[3:0],
        C1,
        C1_third,
        A[3:0],
        B[3:0],
        1'b0,
        cntrl
    );
    
    Carry_Look_Ahead_Adder_Megh AB12(
        AB1_sum[7:4],
        C2,
        C2_third,
        A[7:4],
        B[7:4],
        C1,
        cntrl
    );
    
    wire [8:0] AB1;
    
    assign AB1 = {C2, AB1_sum};
    
    Carry_Look_Ahead_Adder_Megh AB21(
        AB2_sum[3:0],
        C3,
        C3_third,
        A[11:8],
        B[11:8],
        1'b0,
        cntrl
    );
    
    Carry_Look_Ahead_Adder_Megh AB22(
        AB2_sum[7:4],
        C4,
        C4_third,
        A[15:12],
        B[15:12],
        C3,
        cntrl
    );
    
    wire [8:0] AB2;
    
    assign AB2 = {C4, AB2_sum};
    
    //////////////////////////////////
    
    Carry_Look_Ahead_Adder_Megh RED1(
        red_out[3:0],
        C5,
        C5_third,
        AB1[3:0],
        AB2[3:0],
        1'b0,
        cntrl
    );
    
    Carry_Look_Ahead_Adder_Megh RED2(
        red_out[7:4],
        C6,
        C6_third,
        AB1[7:4],
        AB2[7:4],
        C5,
        cntrl
    );
    
    Carry_Look_Ahead_Adder_Megh RED3(
        red_out[11:8],
        C7,
        C7_third,
        {4{AB1[8]}},
        {4{AB2[8]}},
        C6,
        cntrl
    );
    
    assign red[11:0] = red_out;
    assign red[15:12] = {4{C7}};

endmodule
