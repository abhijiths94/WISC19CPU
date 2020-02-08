  module cache_fill_FSM(clk, wen, rst_n, miss_detected, miss_address, memory_data, memory_data_valid, fsm_en_mem_arb,
						fsm_busy, cache_array_data, cache_count, write_data_array, write_tag_array, memory_address, write_valid_bit);

	input clk, rst_n, wen;
	input miss_detected; 			// active high when tag match logic detects a miss
	input memory_data_valid; 		// active high indicates valid data returning on memory bus
	input [15:0] memory_data; 		// data returned by memory (after  delay)
	input [15:0] miss_address; 		// address that missed the cache
	input fsm_en_mem_arb;
	
	output reg fsm_busy; 			// asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
	output reg write_data_array; 	// write enable to cache data array to signal when filling with memory_data
	output reg write_tag_array, write_valid_bit; 	// write enable to cache tag array to signal when all words are filled in to data array
	output reg [15:0] memory_address; // address to read from memory
	output reg [15:0] cache_array_data;  // data written to cache
	  // addr to write in cache		
	output reg [2:0] cache_count;  // addr to write in cache		

	/* Regs  */
	reg state,nxt_state;			//to hold state of FSM
	reg [2:0] addr_in, addr_out, count_in, count_out;
	reg [2:0] cache_memory_addr;
	
	wire ovfl1, ovfl2;
	reg inc;
	wire addr_valid_n;
	
	//dffs
	dff state_reg(.q(state), .d(nxt_state), .wen(wen), .clk(clk), .rst(rst_n));						// FSM state
	
	//addr counter
	dff3_bit addr_counter(.q(addr_out), .d(addr_in), .wen(fsm_en_mem_arb & ~ovfl1 ), .clk(clk), .rst(rst_n | !state));			// Byte counter 
	Ripple_Carry_3_bit RC_addr(.s(addr_in), .ovflw(ovfl1), .c_out(), .a(addr_out), .b({2'b0, inc}), .c_in(1'b0));  // Byte counter adder  /*TODO */
	
	
	dff3_bit cache_counter(.q(count_out), .d(count_in), .wen(fsm_en_mem_arb), .clk(clk), .rst(rst_n));			// Byte counter 
	Ripple_Carry_3_bit RC_addr2(.s(count_in), .ovflw(ovfl2), .c_out(), .a(count_out), .b({2'b0,write_data_array}), .c_in(1'b0));  // Byte counter adder  /*TODO */
	
	dff ov_ff (.q(addr_valid_n), .d(ovfl1), .wen(1'b1), .clk(clk), .rst(rst_n));
	
	assign memory_address =  ~addr_valid_n ? {miss_address[15:4],cache_memory_addr, 1'b0} : 16'bz; 
	
	
	always@(*) begin
		case (state)
			1: 	begin	//wait state
				
					fsm_busy = 1'h1;
		
					inc = /*ovfl1 ? 0 : */1;
					cache_array_data = memory_data_valid ? memory_data : 1'b0;
					cache_memory_addr = addr_out ;
					cache_count = count_out;
					write_data_array = memory_data_valid ? 1'b1 : 1'b0;
					
					nxt_state = (ovfl2 == 1) ? 0 : 1;
					write_tag_array = (ovfl2 == 1) ? 1 : 0;
					write_valid_bit = write_tag_array;
				end
				
			0:  //idle state '0'
				begin	
					fsm_busy = /* miss_detected ? 1'b1 : */ 1'b0;
					write_data_array 	= 0;
					write_tag_array  	= 0;
					write_valid_bit  	= 0;

					cache_array_data 	= 16'h0;
					cache_memory_addr	= 3'h0;
					cache_count 		= 3'h0;
					inc = 0;

					nxt_state 	= (miss_detected ? 1'b1 : 1'b0);
				end

		endcase
	end
endmodule

 
module Ripple_Carry_3_bit(s,ovflw,c_out,a,b,c_in);

	//input 1
	input [2:0]a;	//4 bit input a	
	wire a0=a[0];
	wire a1=a[1];
	wire a2=a[2];
	//input 2 4 bit input b
	input [2:0]b;
	wire b0=b[0];	
	wire b1=b[1];
	wire b2=b[2];
	//carry input
	input c_in;
	//sum
	output c_out;
	output [2:0]s;
	//carry_out
	output ovflw;

	//wires for carry
	wire c1,c2;	
	
	//use the full adder to make ripple carry adder
	fulladder FA0(s[0],c1,a0,b0,c_in),FA1(s[1],c2,a1,b1,c1),FA2(s[2],cout,a2,b2,c2);
	assign ovflw=cout;
	
endmodule
