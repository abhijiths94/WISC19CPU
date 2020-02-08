module IF_ID_buffer(input wen,
					input flush,
					input [15:0]IF_ID_PCplus2,
					input [15:0]IF_ID_instruction,
					input clk,
					input rst,
					output [15:0]IF_ID_PCplus2_out,
					output [15:0]IF_ID_buffer_out);
					
					
dff16_bit Instr_flop ( .q(IF_ID_buffer_out), .d(IF_ID_instruction), .wen(wen), .clk(clk), .rst(flush | rst));
dff16_bit PC_flop ( .q(IF_ID_PCplus2_out), .d(IF_ID_PCplus2), .wen(wen), .clk(clk), .rst(flush | rst));

endmodule
