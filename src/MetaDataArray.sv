//Tag Array of 128  blocks
//Each block will have 1 byte
//BlockEnable is one-hot
//WriteEnable is one on writes and zero on reads

module MetaDataArray(input clk, input rst, input [7:0] DataIn, input Write, input [127:0] BlockEnable, output [7:0] DataOut1, output [7:0] DataOut2);
	wire [6:0] DataOut1_temp, DataOut2_temp;
	wire DataOut_LRU;
	
	MBlock Mblk1[63:0]( .clk(clk), .rst(rst), .Din(DataIn[7:1]), .WriteEnable(Write), .Enable(BlockEnable[63:0]), .Dout(DataOut1_temp));
	MBlock Mblk2[63:0]( .clk(clk), .rst(rst), .Din(DataIn[7:1]), .WriteEnable(Write), .Enable(BlockEnable[127:64]), .Dout(DataOut2_temp));
	LRUBlock Lblk[63:0] ( .clk(clk), .rst(rst), .Din(DataIn[0]), .WriteEnable(Write), .Enable(BlockEnable[127:64] | BlockEnable[63:0]), .Dout(DataOut_LRU));
	
	assign DataOut1 = {DataOut1_temp,DataOut_LRU};
	assign DataOut2 = {DataOut2_temp,DataOut_LRU};
	
endmodule

module LRUBlock( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	MCell mc( .clk(clk), .rst(rst), .Din(Din), .WriteEnable(WriteEnable), .Enable(Enable), .Dout(Dout));
endmodule

module MBlock( input clk,  input rst, input [6:0] Din, input WriteEnable, input Enable, output [6:0] Dout);
	MCell mc[6:0]( .clk(clk), .rst(rst), .Din(Din[6:0]), .WriteEnable(WriteEnable), .Enable(Enable), .Dout(Dout[6:0]));
endmodule

module MCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	wire q;
	assign Dout = (Enable & ~WriteEnable) ? q:'bz;
	dff dffm(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule

