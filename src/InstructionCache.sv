module InstructionCache(input clk, input rst, input [15:0] addressIn, input [15:0] DataIn, 
						input data_write, input tag_write, input valid_bit, input [2:0] offset_write_fsm,
                        output [15:0] DataOut, output miss_detected);
						
						
  wire [1:0] hit;
  wire [15:0] DataOut_temp2, DataOut_temp1;
  wire [5:0] tag = addressIn[15:10];
  
  
  wire [7:0] M_DataIn; // check
  wire [7:0] M_DataOut1, M_DataOut2;
  wire [15:0] DataOut_temp;
  wire [127:0] BlockEnable;
  wire [63:0] BlockEnable_read;
  wire [7:0] WordEnable;
  
  reg LRU_bit;
  
  /*
  If miss: hit = 2'b00
  If hit with tag0, hit = 2'b10
  If hit with tag1, hit = 2'b11
  */
  
  assign M_DataIn = tag_write ? {tag, valid_bit, LRU_bit} : 8'bz;
  assign hit = rst ? 2'b11 : (data_write ? hit : ((M_DataOut1[1] && (tag == M_DataOut1[7:2])) ? 2'b10 : ((M_DataOut2[1] && (tag == M_DataOut2[7:2]))) ? 2'b11 : 2'b00));
  //assign hit = data_write ? 2'b00 : ((M_DataOut1[1] && (tag == M_DataOut1[7:2])) ? 2'b10 : ((M_DataOut2[1] && (tag == M_DataOut2[7:2]))) ? 2'b11 : 2'b00);

  assign miss_detected = ~hit[1];
  
  wire [2:0] offset_read = addressIn[3:1];
  wire [7:0] word_en_read, word_en_write;
  
  assign WordEnable = data_write ? word_en_write : word_en_read;
  
  assign DataOut = tag_write ? (LRU_bit ? DataOut_temp1 : DataOut_temp2) : (hit[1] ? (hit[0] ? DataOut_temp2 : DataOut_temp1) : 16'bz);
  
  decoder_3_8 DE1 (.sel(offset_read), .enable(1'b1), .out_val(word_en_read));
  decoder_3_8 DE2 (.sel(offset_write_fsm), .enable(1'b1), .out_val(word_en_write));
  
  assign BlockEnable = data_write ? (LRU_bit ? {{64{1'b0}},BlockEnable_read} : {BlockEnable_read ,{64{1'b0}}} ) : ({BlockEnable_read, BlockEnable_read});
  
  blockenable BE (.sel(addressIn[9:4]), .blockenable(BlockEnable_read));
  
  DataArray DA (.clk(clk), .rst(rst), .DataIn(DataIn), .Write(data_write), .BlockEnable(BlockEnable), .WordEnable(WordEnable), .DataOut1(DataOut_temp1), .DataOut2(DataOut_temp2));
  
  MetaDataArray MDA (.clk(clk), .rst(rst), .DataIn(M_DataIn), .Write(tag_write), .BlockEnable(BlockEnable), .DataOut1(M_DataOut1), .DataOut2(M_DataOut2));
  
  /*
  always @* begin
	case (rst)
		1'b0: begin
			h = 2'b11;
		end
		1'b1: begin
			h = h;
		end
  end
  */
  
  always @* begin
	case (hit[1])
		1'b0 : LRU_bit = tag_write ? ~LRU_bit : M_DataOut1[0]; // miss
		1'b1 : LRU_bit = ~hit[0]; // hit
	endcase
  end
  
endmodule

module blockenable (input [5:0] sel, output [63:0] blockenable);
  
  wire [7:0] out0, out1, out2, out3, out4, out5, out6, out7, out8;
  
  assign blockenable = {out1, out2, out3, out4, out5, out6, out7, out8};
  
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
