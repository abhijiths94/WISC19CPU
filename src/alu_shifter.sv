/*
IF rotate is 1 then it will do ROR
IF rotate is 0 then it will do right shift or left shift depending on the right input,
if right is 1 then it will do arithmetic right shift, else it will do left shift
*/
module alu_shifter(res, amt, rotate, right, src);
input [3:0]amt;
input right;
input rotate;
input [15:0]src;		//input value to be shifted
output [15:0]res;		// shifted output
wire [15:0]res1,res2,res3;
//first rotate or shift; it checks if rotate is 1, if rotate is 1 then it goes to the rotate instruction
//if not it goes to shift instruction, it performs the rot/shift instructions according to the number of bits it is supposed to rotate by
assign res1 = (rotate) ? ((amt[0]) ? {src[0],src[15:1]} : {src[15:0]} ):
						  (right) ? ((amt[0]) ? {src[15],src[15:1]} : {src[15:0]} ) :
						  ((amt[0]) ? {src[14:0],1'b0} : {src[15:0]} );
//second rotate
assign res2 = (rotate) ? ((amt[1]) ? {res1[1:0],res1[15:2]} : {res1[15:0]} ): 
						 (right) ? ((amt[1]) ? {{2{src[15]}},res1[15:2]} : {res1[15:0]} ) : 
						 ((amt[1]) ? {res1[13:0],2'b00} : {res1[15:0]} );
//third rotate
assign res3 = (rotate) ? ((amt[2]) ? {res2[3:0],res2[15:4]} : {res2[15:0]} ): 
						 (right) ?  ((amt[2]) ? {{4{src[15]}},res2[15:4]} : {res2[15:0]} ):
						 ((amt[2]) ? {res2[11:0],4'b000} : {res2[15:0]} );
//fourth rotate
assign res = (rotate) ? ((amt[3]) ? {res3[7:0],res3[15:8]} : {res3[15:0]} ): 
						(right) ? ((amt[3]) ? {{8{src[15]}},res3[15:8]} : {res3[15:0]} ) :
						((amt[3]) ? {res3[7:0],8'b00000000} : {res3[15:0]} );
endmodule

