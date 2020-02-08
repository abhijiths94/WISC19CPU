module Register( clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, Bitline1, Bitline2);

input clk, rst, WriteReg, ReadEnable1, ReadEnable2;
input [15:0] D;
inout [15:0] Bitline1, Bitline2;

BitCell  BC[15:0]( .clk(clk), .rst(rst), .D(D), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1), .Bitline2(Bitline2));

endmodule

module Register_0( ReadEnable1, ReadEnable2, Bitline1, Bitline2);

input ReadEnable1, ReadEnable2;
inout [15:0] Bitline1, Bitline2;

BitCell_0  BC[15:0]( .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1), .Bitline2(Bitline2));
endmodule
