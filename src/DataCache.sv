module DataCache(input clk, input rst, input [15:0] addressIn, input [15:0] DataIn, 
		 input data_write, input tag_write, input valid_bit, input [2:0] offset_write_fsm, input mem_write, input mem_read,
                 output [15:0] DataOut, output miss_detected);
						
						
  wire [1:0] hit;
  //wire [15:0] DataOut_temp2, DataOut_temp1;
  wire [5:0] tag = addressIn[15:10];
  
  
  wire [7:0] M_DataIn; // check
  wire [7:0] M_DataOut1, M_DataOut2;
  //wire [15:0] DataOut_temp;
  wire [127:0] BlockEnable_tag, BlockEnable_data;
  wire [63:0] BlockEnable_read;
  wire [7:0] WordEnable;
  reg block_in_use;
  
  wire LRU_bit = tag_write ? ~block_in_use : LRU_bit;
  
  /*
  If miss: hit = 2'b00
  If hit with tag0, hit = 2'b10
  If hit with tag1, hit = 2'b11
  */
  
  assign M_DataIn = tag_write ? {tag, valid_bit, LRU_bit} : 8'bz;
  assign hit = data_write ? hit : ((M_DataOut1[1] && (tag == M_DataOut1[7:2])) ? 2'b10 : ((M_DataOut2[1] && (tag == M_DataOut2[7:2]))) ? 2'b11 : 2'b00);  //Possible latch 
  //assign hit = data_write ? 2'b00 : ((M_DataOut1[1] && (tag == M_DataOut1[7:2])) ? 2'b10 : ((M_DataOut2[1] && (tag == M_DataOut2[7:2]))) ? 2'b11 : 2'b00);
  assign miss_detected = ~hit[1] & (mem_write | mem_read);
  
  wire [2:0] offset_load_store = addressIn[3:1];
  wire [7:0] word_en_load_store, word_en_write;
  
  assign WordEnable = (data_write) ? word_en_write : word_en_load_store;
  
  //assign DataOut = tag_write ? (LRU_bit ? DataOut_temp1 : DataOut_temp2) : (hit[1] ? (hit[0] ? DataOut_temp2 : DataOut_temp1) : 16'bz);
  
  decoder_3_8 DE1 (.sel(offset_load_store), .enable(1'b1), .out_val(word_en_load_store));
  decoder_3_8 DE2 (.sel(offset_write_fsm), .enable(1'b1), .out_val(word_en_write));
  
  assign BlockEnable_tag = data_write ? (!block_in_use ? {{64{1'b0}},BlockEnable_read} : {BlockEnable_read ,{64{1'b0}}} ) : ({BlockEnable_read, BlockEnable_read});
  
  assign BlockEnable_data = data_write ? (!block_in_use ? {{64{1'b0}},BlockEnable_read} : {BlockEnable_read ,{64{1'b0}}} ) : 
										(hit[1] ? (hit[0] ? ({BlockEnable_read ,{64{1'b0}}}) : ({{64{1'b0}},BlockEnable_read})) : 128'bz);
  
  blockenable BE (.sel(addressIn[9:4]), .blockenable(BlockEnable_read));
  
  DataArray_2 DA (.clk(clk), .rst(rst), .DataIn(DataIn), .Write(data_write | mem_write), .BlockEnable(BlockEnable_data), .WordEnable(WordEnable), .DataOut(DataOut));
  
  MetaDataArray MDA (.clk(clk), .rst(rst), .DataIn(M_DataIn), .Write(tag_write), .BlockEnable(BlockEnable_tag), .DataOut1(M_DataOut1), .DataOut2(M_DataOut2));
  
  always @* begin
	case (hit[1])
		1'b0 : block_in_use = tag_write ? block_in_use : M_DataOut1[0]; // miss
		1'b1 : block_in_use = hit[0]; // hit
	endcase
  end
  
endmodule

module blockenable (input [5:0] sel, output [63:0] blockenable);
  
  wire [7:0] out0, out1, out2, out3, out4, out5, out6, out7, out8;
  
  assign blockenable = {out8, out7, out6, out5, out4, out3, out2, out1};
  
  decoder_3_8 d0 (sel[5:3], 1'b1, out0);
  decoder_3_8 d1 (sel[2:0], out0[0], out1);
  decoder_3_8 d2 (sel[2:0], out0[1], out2);
  decoder_3_8 d3 (sel[2:0], out0[2], out3);
  decoder_3_8 d4 (sel[2:0], out0[3], out4);
  decoder_3_8 d5 (sel[2:0], out0[4], out5);
  decoder_3_8 d6 (sel[2:0], out0[5], out6);
  decoder_3_8 d7 (sel[2:0], out0[6], out7);
  decoder_3_8 d8 (sel[2:0], out0[7], out8);
  
endmodule

module decoder_3_8 (input [2:0] sel, input enable, output [7:0] out_val);
  
  reg [7:0] out;
  assign out_val = enable ? out : 8'b0;
  
  always @* begin
    case (sel)
      3'b000: out = 8'b00000001;
      3'b001: out = 8'b00000010;
      3'b010: out = 8'b00000100;
      3'b011: out = 8'b00001000;
      3'b100: out = 8'b00010000;
      3'b101: out = 8'b00100000;
      3'b110: out = 8'b01000000;
      3'b111: out = 8'b10000000;
    endcase
  end
  
  
  
  
  
endmodule
