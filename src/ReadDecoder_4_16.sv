module ReadDecoder_4_16(RegId, Wordline);

input [3:0] RegId;
output wire [15:0] Wordline;

assign Wordline = (1<<RegId);
endmodule
