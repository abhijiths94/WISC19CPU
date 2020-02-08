module WriteDecoder_4_16(RegId, WriteReg, Wordline);

input [3:0] RegId;
input WriteReg;
output [15:0] Wordline;

assign Wordline = WriteReg ? (1<<RegId) : 0;

endmodule