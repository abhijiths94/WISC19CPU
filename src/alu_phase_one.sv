module alu_phase_one(input clk, input rst_n, input wen, input [15:0]A,
					 input [15:0]B,
					 input [3:0]opcode,
					 output [15:0]ALU_OUT_FINAL,
					 output [2:0]FLAGS);

reg [15:0]ALU_OUT;
wire [15:0]add_sub_out;
wire [15:0]xor_out;
wire [15:0]red_out;
wire [15:0]shift_out;
wire [15:0]paddsb_out;
//flag bits NZV
reg overflow = 0;
reg negative = 0;
reg zero = 0;
reg rotate;
reg right;
reg opcode_bit;
wire overflow_adder;
wire neg_adder;

add_sub_sat AS1(opcode_bit, A, B, add_sub_out, overflow_adder, neg_adder);

alu_xor X1( xor_out,	//XOR output
			A,B	//16 bit INPUTS	
			);
	
alu_red RED1(red_out,
			 A,
			 B
				);

alu_shifter SHIFT1(shift_out, B[3:0], rotate, right, A);

alu_paddsb PADD1(A,
				 B,
				 paddsb_out);

/* NVZ Flags 
dff D1(FLAGS[0], zero, wen, clk, rst_n);
dff D2(FLAGS[1], overflow, wen, clk, rst_n);
dff D3(FLAGS[2], negative, wen, clk, rst_n);
*/

assign FLAGS = {negative, overflow, zero};

/* TODO : Move to another block as per rules */
always @(*)
begin
    case (opcode)
      4'b0000  : 	//ADD
	  begin
	  opcode_bit = 0; ALU_OUT = add_sub_out; overflow = overflow_adder; negative = neg_adder;
	  zero = (~(|ALU_OUT));
      end
	  4'b0001  : //SUB
	  begin
	  opcode_bit = 1; ALU_OUT = add_sub_out; overflow = overflow_adder; negative = neg_adder; zero = (~(|ALU_OUT));
      end
	  4'b0010  : begin	//XOR
	  ALU_OUT = xor_out;
	  zero = (~(|ALU_OUT));
	  end
	  4'b0011  : begin  //RED
	  ALU_OUT = red_out;
	  end
	  4'b0100  : 	//SLL
	  begin
	  rotate = 0; right = 0; ALU_OUT = shift_out; zero = (~(|ALU_OUT));
	  end		
	  4'b0101  : 	//SRA
	  begin
	  rotate = 0; right = 1; ALU_OUT = shift_out;zero = (~(|ALU_OUT));
	  end
	  4'b0110  : 	//ROR
	  begin
	  rotate = 1; right = 0; ALU_OUT = shift_out;zero = (~(|ALU_OUT));
	  end
	  4'b0111  : begin		//PADSB
	  ALU_OUT = paddsb_out;
	  end
	  4'b1000  : //LW
	  begin
	  opcode_bit = 0; ALU_OUT = add_sub_out; 
	  end
	  4'b1001  : 	//SW
	  begin	
	  opcode_bit = 0; ALU_OUT = add_sub_out; 
	  end
	  4'b1010:	//LLB
	  begin
	  ALU_OUT = {A[15:8],B[7:0]};
	  end
	  4'b1011:	//LHB
	  begin
	  ALU_OUT = {B[15:8],A[7:0]};
	  end
	  4'b1100:	//B
	  begin
	  ALU_OUT = A;	//DOESNT MATTER
	  end
	  4'b1101:	//BR
	  begin
	  ALU_OUT = A;
	  end
	  4'b1110:	//PCS
	  begin
	  opcode_bit = 0; ALU_OUT = add_sub_out;
	  end
	  4'b1111:  //HLT ??
	  begin
	  end
	  default : 
	  begin
	  ALU_OUT = 0; overflow = 1'b0; negative = 1'b0; zero=1'b0;
	  end
    endcase
end
  
assign ALU_OUT_FINAL = ALU_OUT;
endmodule
