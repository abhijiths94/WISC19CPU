module BitCell( clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2, Bitline1, Bitline2);

input clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2;
wire dff_out;
inout Bitline1, Bitline2;

dff d_ff(.q(dff_out), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));

assign Bitline1 = ReadEnable1 ? dff_out : 16'bz;
assign Bitline2 = ReadEnable2 ? dff_out : 16'bz;


endmodule

module BitCell_0( ReadEnable1, ReadEnable2, Bitline1, Bitline2);

input ReadEnable1, ReadEnable2;
inout Bitline1, Bitline2;

assign Bitline1 = ReadEnable1 ? 1'b0 : 1'bz;
assign Bitline2 = ReadEnable2 ? 1'b0 : 1'bz;


endmodule
