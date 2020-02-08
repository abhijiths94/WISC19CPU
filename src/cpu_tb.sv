module cpu_tb();

reg clk, rst;
wire hlt;
wire [15:0] pc_out;


cpu cpu_dut(.clk(clk), .rst_n(!rst), .hlt(hlt), .pc_out(pc_out));

initial
begin
	clk = 0;
	rst = 1;
	#20;
	rst = 0;
	
	#350;
	
	/* Assert reset to check reset functionality */ 
	rst = 1;
	#20;
	rst = 0;
	
	#4000;
	
	$stop;
	
end

always
	#5 clk = ~clk;

endmodule