module RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1_out, SrcData2_out);
  
input clk, rst, WriteReg;
input [3:0] SrcReg1, SrcReg2, DstReg;
input [15:0] DstData;
inout [15:0] SrcData1_out, SrcData2_out;

wire [15:0] SrcData1, SrcData2;


wire [15:0] read_decode_a, read_decode_b, write_decode;

ReadDecoder_4_16 RDA(.RegId(SrcReg1), .Wordline(read_decode_a));
ReadDecoder_4_16 RDB(.RegId(SrcReg2), .Wordline(read_decode_b));
WriteDecoder_4_16 WD(.RegId(DstReg), .WriteReg(WriteReg), .Wordline(write_decode));

Register_0 REGS_0( .ReadEnable1(read_decode_a[0]), .ReadEnable2(read_decode_b[0]), .Bitline1(SrcData1), .Bitline2(SrcData2));

Register REGS_1( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[1]), .ReadEnable1(read_decode_a[1]), .ReadEnable2(read_decode_b[1]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register REGS_2( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[2]), .ReadEnable1(read_decode_a[2]), .ReadEnable2(read_decode_b[2]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register REGS_3( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[3]), .ReadEnable1(read_decode_a[3]), .ReadEnable2(read_decode_b[3]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register REGS_4( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[4]), .ReadEnable1(read_decode_a[4]), .ReadEnable2(read_decode_b[4]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register REGS_5( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[5]), .ReadEnable1(read_decode_a[5]), .ReadEnable2(read_decode_b[5]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register REGS_6( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[6]), .ReadEnable1(read_decode_a[6]), .ReadEnable2(read_decode_b[6]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register REGS_7( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[7]), .ReadEnable1(read_decode_a[7]), .ReadEnable2(read_decode_b[7]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register REGS_8( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[8]), .ReadEnable1(read_decode_a[8]), .ReadEnable2(read_decode_b[8]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register REGS_9( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[9]), .ReadEnable1(read_decode_a[9]), .ReadEnable2(read_decode_b[9]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register REGS_10( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[10]), .ReadEnable1(read_decode_a[10]), .ReadEnable2(read_decode_b[10]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register REGS_11( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[11]), .ReadEnable1(read_decode_a[11]), .ReadEnable2(read_decode_b[11]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register REGS_12( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[12]), .ReadEnable1(read_decode_a[12]), .ReadEnable2(read_decode_b[12]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register REGS_13( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[13]), .ReadEnable1(read_decode_a[13]), .ReadEnable2(read_decode_b[13]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register REGS_14( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[14]), .ReadEnable1(read_decode_a[14]), .ReadEnable2(read_decode_b[14]), .Bitline1(SrcData1), .Bitline2(SrcData2));
Register REGS_15( .clk(clk), .rst(rst), .D(DstData), .WriteReg(write_decode[15]), .ReadEnable1(read_decode_a[15]), .ReadEnable2(read_decode_b[15]), .Bitline1(SrcData1), .Bitline2(SrcData2));


assign SrcData1_out = (SrcReg1 == DstReg) & WriteReg ? DstData : SrcData1;
assign SrcData2_out = (SrcReg2 == DstReg) & WriteReg ? DstData : SrcData2;

endmodule
