module cache_test();

	reg clk, rst_n, wen;
	reg memory_data_valid; 		// active high indicates valid data returning on memory bus
	reg [15:0] memory_data; 		// data returned by memory (after  delay)
	reg [15:0] miss_address; 		// address that missed the cache
	
	reg fsm_busy; 			// asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
	reg write_data_array; 	// write enable to cache data array to signal when filling with memory_data
	reg write_tag_array, write_valid_bit; 	// write enable to cache tag array to signal when all words are filled in to data array
	reg [15:0] memory_address; // address to read from memory
	reg [15:0] cache_array_data;  // data written to cache
	reg [2:0] cache_memory_addr, cache_count;  // addr to write in cache		
    wire [15:0] DataOut;	
	wire miss_detected;
	reg d_cache_write;
	reg en;
	reg [15:0] store_data;
	
	wire [15:0] cache_data_in;
		
	/*
	InstructionCache IC(.clk(clk), .rst(rst_n), .addressIn(miss_address), .DataIn(cache_array_data), 
						.data_write(write_data_array), .tag_write(write_tag_array), .valid_bit(write_valid_bit), .offset_write(cache_memory_addr),
                        .DataOut(DataOut), .miss_detected(miss_detected));
	*/
					
	DataCache DC(.clk(clk), .rst(rst_n), .addressIn(miss_address), .DataIn(cache_data_in), 
						.data_write(write_data_array), .tag_write(write_tag_array), .valid_bit(write_valid_bit), .offset_write_fsm(cache_count), .d_cache_write(d_cache_write),
                        .DataOut(DataOut), .miss_detected(miss_detected));
						
	cache_fill_FSM FSM (clk, wen, rst_n, miss_detected, miss_address, memory_data, memory_data_valid,
						fsm_busy, cache_array_data, cache_memory_addr, cache_count, write_data_array, write_tag_array, memory_address, write_valid_bit);
						
	reg [127:0] data = {16'h1111, 16'h2222, 16'h3333, 16'h4444, 16'h5555, 16'h6666, 16'h7777, 16'h8888};
	reg [1:0] cnt;
	
	assign cache_data_in = write_data_array ? cache_array_data : store_data ;
	
	initial begin
		clk = 0;
		rst_n = 1;
		wen = 1'b1;
		en = 0;
		d_cache_write = 1;
		store_data = 16'hDEAD;
		
		
		
		#10;
		
		rst_n = 0;
		miss_address  = 16'h1234;
		
		@(negedge fsm_busy )
		
		#100;
		
		d_cache_write = 0;
		miss_address = 16'h1234;		//hit0
		
		#20;
		
		miss_address = 16'h2230;
		data = {16'h1111, 16'h2222, 16'h3333, 16'h4444, 16'h5555, 16'h6666, 16'h7777, 16'h8888};
		
		@(negedge fsm_busy )
		
		#100;
		
		miss_address = 16'h2235;		//hit1
		
		#20;
		
		miss_address = 16'h1375;
		data = {16'h1111, 16'h2222, 16'h3333, 16'h4444, 16'h5555, 16'h6666, 16'h7777, 16'h8888};
		
		@(negedge fsm_busy )
		
		#100;
		
		miss_address = 16'h2239;		//hit0
		
		#20
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
	
	always@(*) begin
	if(cnt_smpl)
		en = 1;
	end
	
	always@(posedge clk)
	begin
		if(en)
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
			memory_data = en ?  data[127:112] : 16'h0000;
		end
	end
	
	always
		#5 clk  = ~clk;

endmodule
