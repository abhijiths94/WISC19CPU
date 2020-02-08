module cache_fsm_tb();
						
	reg clk, rst_n, wen;
	reg miss_detected; 			// active high when tag match logic detects a miss
	reg memory_data_valid; 		// active high indicates valid data returning on memory bus
	reg [15:0] memory_data; 		// data returned by memory (after  delay)
	reg [15:0] miss_address; 		// address that missed the cache
	
	reg fsm_busy; 			// asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
	reg write_data_array; 	// write enable to cache data array to signal when filling with memory_data
	reg write_tag_array, write_valid_bit; 	// write enable to cache tag array to signal when all words are filled in to data array
	reg [15:0] memory_address; // address to read from memory
	reg [15:0] cache_array_data;  // data written to cache
	reg [2:0] cache_memory_addr;  // addr to write in cache		
	
	cache_fill_FSM iDUT(clk, wen, rst_n, miss_detected, miss_address, memory_data, memory_data_valid,
						fsm_busy, cache_array_data, cache_memory_addr, write_data_array, write_tag_array, memory_address, write_valid_bit);
						
	reg [127:0] data = {16'h1111, 16'h2222, 16'h3333, 16'h4444, 16'h5555, 16'h6666, 16'h7777, 16'h8888};
	reg [1:0] cnt;
	
	initial begin
		clk = 0;

		rst_n = 1;
		wen = 1'b1;
		miss_detected = 0;
		miss_address  = 16'h1234;
		
		#10;
		
		rst_n = 0;
		
		//miss detected 
		miss_detected = 1;
		
		@(negedge fsm_busy);
		miss_detected = 0;
		#10;
		$stop;
		
		
		
	end
	
	always@(posedge clk)
	begin
		if(rst_n)
			cnt = 0;
			
		if(fsm_busy)
		begin
			cnt = cnt + 1;
		end
		
	end
	
	wire cnt_smpl = &cnt;
	
	always@(posedge clk)
	begin
		if(cnt_smpl)
		begin
			data <= data << 16;
			memory_data_valid = 1;
		end
		else
		begin
			memory_data_valid = 0;
		end
	end
	
	always@(posedge clk)
	begin
		if(rst_n)
			memory_data = 0;
			
		if(fsm_busy)
		begin
			memory_data = cnt_smpl ?  data[127:112] : 16'h0000;
		end
	end
	
	always
		#5 clk  = ~clk;

endmodule
