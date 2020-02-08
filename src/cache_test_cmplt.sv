module cache_test_cmplt();


reg clk, rst;
reg EXMEM_Mem_Write;

wire [15:0] data_out, mem_data_in, input_address, d_cache_miss_detected;
wire en_d_cache, en_i_cache, data_valid;

/*Icache signals */
reg [15:0] pc_out;

wire i_cache_write_data_array, i_cache_write_tag_array, i_cache_valid_bit, i_cache_miss_detected, i_data_valid, i_fsm_busy;
wire [2:0] i_fsm_cache_addr;
wire [15:0] i_cache_data, inst, i_cache_memory_address;



memory4c main_mem(.data_out(data_out) , .data_in(mem_data_in), .addr(input_address), .enable(en_i_cache | en_d_cache | (~ d_cache_miss_detected & EXMEM_Mem_Write)), .wr(~ d_cache_miss_detected & EXMEM_Mem_Write), .clk(clk), .rst(rst), .data_valid(data_valid));

mem_arb mem_arb_blk(.i_cache_busy(i_fsm_busy), .d_cache_busy(d_fsm_busy), .en_i_cache(en_i_cache), .en_d_cache(en_d_cache));

assign input_address = en_d_cache ? d_cache_memory_address : en_i_cache ? i_cache_memory_address : EXMEM_alu_out;

assign i_data_valid = en_i_cache ? data_valid : 0;
assign d_data_valid = en_d_cache ? data_valid : 0;


DataCache icache(.clk(clk), .rst(rst), .addressIn(pc_out), .DataIn(i_cache_data), .data_write(i_cache_write_data_array), .tag_write(i_cache_write_tag_array), 
			.valid_bit(i_cache_valid_bit), .offset_write_fsm(i_fsm_cache_addr), .mem_write(1'b0), .mem_read(1'b1),
                 	.DataOut(inst), .miss_detected(i_cache_miss_detected));
					
cache_fill_FSM icache_fsm(.clk(clk), .wen(1'b1), .rst_n(rst), .miss_detected(i_cache_miss_detected), .miss_address(pc_out), .memory_data(data_out), .memory_data_valid(i_data_valid), .fsm_en_mem_arb(en_i_cache),
	                  .fsm_busy(i_fsm_busy), .cache_array_data(i_cache_data), .cache_count(i_fsm_cache_addr), .write_data_array(i_cache_write_data_array), 
			  .write_tag_array(i_cache_write_tag_array), .memory_address(i_cache_memory_address), .write_valid_bit(i_cache_valid_bit));


DataCache dcache(.clk(clk), .rst(rst), .addressIn(EXMEM_alu_out), .DataIn(d_cache_data_in), .data_write(d_cache_write_data_array), .tag_write(d_cache_write_tag_array), 
			.valid_bit(d_cache_valid_bit), .offset_write_fsm(d_fsm_cache_addr), .mem_write(EXMEM_Mem_Write), .mem_read(EXMEM_Mem_Read),
                 	.DataOut(MEM_out), .miss_detected(d_cache_miss_detected));

cache_fill_FSM dcache_fsm(.clk(clk), .wen(1'b1), .rst_n(rst), .miss_detected(d_cache_miss_detected), .miss_address(EXMEM_alu_out), .memory_data(data_out), .memory_data_valid(d_data_valid), .fsm_en_mem_arb(en_d_cache),
	                  .fsm_busy(d_fsm_busy), .cache_array_data(d_cache_data), .cache_count(d_fsm_cache_addr), .write_data_array(d_cache_write_data_array), 
			  .write_tag_array(d_cache_write_tag_array), .memory_address(d_cache_memory_address), .write_valid_bit(d_cache_valid_bit));

					

DataCache DC(.clk(clk), .rst(rst_n), .addressIn(miss_address), .DataIn(cache_data_in), 
						.data_write(write_data_array), .tag_write(write_tag_array), .valid_bit(write_valid_bit), .offset_write_fsm(cache_count), .d_cache_write(d_cache_write),
                        .DataOut(DataOut), .miss_detected(miss_detected));
						

endmodule