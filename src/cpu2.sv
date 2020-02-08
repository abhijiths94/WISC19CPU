
module cpu(clk, rst_n, hlt, pc_out);

input clk, rst_n;
output hlt;
output [15:0] pc_out;

wire [15:0] inst, data1, data2;
wire [2:0] cond;			// condition field set by branch instructions
wire [15:0] imm;			// 9 bit immediate value
wire [2:0] Flag;			// flags set by ALU
wire [15:0] alu_out;		// output of alu
wire enable;					// control line to indiacte if memory read is required (LW)
wire WriteReg;				// Control line to indicate if write back to register is required
wire [15:0] mem_stage_out; 	// output from the memory stage (ALU/MEM output) to the write back stage

wire [15:0] alu_in1, alu_in2;

wire [15:0] data_mem;
wire PCS_en, ID_hlt, EX_hlt, MEM_hlt;

wire rst = ~rst_n;
wire [15:0] inst_out;
wire [15:0] pc_out_two;

wire [15:0]data_temp1,data_temp2;
wire [15:0]WB_out,MEMWB_alu_out, MEMWB_data_mem;
wire MEMWB_memtoreg;

wire [15:0] PC_two, PC_decoder_branch, IDEX_pc_out_two;
wire [3:0] MEMWB_RegRd;
wire en, PC_Write, IFID_Write, Flush, MEMWB_regwrite, RegDst, ALUSrc, Branch, MemRead, MemWrite, RegWrite, MemToReg;
wire [3:0] IFID_Rs, IFID_Rt, IFID_Rd;

/* Stall signals */
wire fetch_stage_stall, IFID_stall;

/* IDEX signal declaration */
wire IDEX_RegDst, IDEX_ALUSrc, IDEX_MemRead, Control_Select, IDEX_memtoreg, IDEX_regwrite, IDEX_memwrite;
wire [3:0] IDEX_rt, IDEX_rs, IDEX_rd, IDEX_opcode;
wire [15:0] IDEX_data1, IDEX_data2, IDEX_imm;

wire EXMEM_memtoreg, EXMEM_RegWrite, EXMEM_Mem_Write, EXMEM_Mem_Read, MEM2MEM_fwd_mux;
wire [15:0] EXMEM_alu_out, rt_to_mem, EXMEM_Rt, MEM_out;
wire [1:0] fwd_mux_a, fwd_mux_b;
wire [3:0] dest_reg_out, EXMEM_RegRd;

/* I Cache wires */
wire i_cache_miss_detected, i_cache_write_data_array, i_cache_write_tag_array, i_cache_valid_bit, en_i_cache, i_fsm_busy;
wire [15:0] i_cache_data, i_cache_memory_address;

wire[2:0] i_fsm_cache_addr;

/* D Cache wires */
wire d_cache_miss_detected, d_cache_write_data_array, d_cache_write_tag_array, d_cache_valid_bit, en_d_cache, d_fsm_busy;
wire [15:0] d_cache_data, d_cache_memory_address, d_cache_data_in;

wire[2:0] d_fsm_cache_addr;


wire data_valid, i_data_valid, d_data_valid;
wire [15:0] data_out, input_address, mem_data_in;


/************************* MAIN MEMORY **************************/

memory4c main_mem(.data_out(data_out) , .data_in(mem_data_in), .addr(input_address), .enable(en_i_cache | en_d_cache | (~ d_cache_miss_detected & EXMEM_Mem_Write)), .wr(~ d_cache_miss_detected & EXMEM_Mem_Write), .clk(clk), .rst(rst), .data_valid(data_valid));

mem_arb mem_arb_blk(.i_cache_busy(i_fsm_busy), .d_cache_busy(d_fsm_busy), .en_i_cache(en_i_cache), .en_d_cache(en_d_cache));

assign input_address = en_d_cache ? d_cache_memory_address : en_i_cache ? i_cache_memory_address : EXMEM_alu_out;

assign i_data_valid = en_i_cache ? data_valid : 0;
assign d_data_valid = en_d_cache ? data_valid : 0;

/************************* FETCH STAGE **************************/

assign fetch_stage_stall = i_fsm_busy | i_cache_miss_detected | d_fsm_busy | d_cache_miss_detected ? ~(i_fsm_busy | i_cache_miss_detected | d_fsm_busy | d_cache_miss_detected) : PC_Write;

Fetch_stage Fetch(.clk(clk), .rst(rst) , .sel(en), .wen(fetch_stage_stall), .PC_decoder_branch(PC_decoder_branch), .hlt(hlt), .PC_two(PC_two), .PC_out(pc_out));
//memory1c inst_mem(.data_out(inst), .data_in(16'h0), .addr(PC_out), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(rst));

DataCache icache(.clk(clk), .rst(rst), .addressIn(pc_out), .DataIn(i_cache_data), .data_write(i_cache_write_data_array), .tag_write(i_cache_write_tag_array), 
			.valid_bit(i_cache_valid_bit), .offset_write_fsm(i_fsm_cache_addr), .mem_write(1'b0), .mem_read(1'b1),
                 	.DataOut(inst), .miss_detected(i_cache_miss_detected));


cache_fill_FSM icache_fsm(.clk(clk), .wen(1'b1), .rst_n(rst), .miss_detected(i_cache_miss_detected), .miss_address(pc_out), .memory_data(data_out), .memory_data_valid(i_data_valid), .fsm_en_mem_arb(en_i_cache),
	                  .fsm_busy(i_fsm_busy), .cache_array_data(i_cache_data), .cache_count(i_fsm_cache_addr), .write_data_array(i_cache_write_data_array), 
			  .write_tag_array(i_cache_write_tag_array), .memory_address(i_cache_memory_address), .write_valid_bit(i_cache_valid_bit));




/************************* IFID BUFFER **************************/
assign IFID_stall = i_fsm_busy | i_cache_miss_detected | d_fsm_busy | d_cache_miss_detected ? ~(i_fsm_busy | i_cache_miss_detected | d_fsm_busy | d_cache_miss_detected) : IFID_Write;
IF_ID_buffer IFID_buf( .wen(IFID_stall), .flush(Flush), .IF_ID_PCplus2(PC_two), .IF_ID_instruction(inst), .clk(clk),
					  .rst(rst), .IF_ID_PCplus2_out(pc_out_two), .IF_ID_buffer_out(inst_out));
				

				
/************************* DECODE STAGE **************************/
					  
Decode_stage Decode (.clk(clk), .rst(rst), .Instr(inst_out), .MEMWB_dst_data(WB_out), .Flags(Flag), .IFID_PC_two(pc_out_two), .MEMWB_RegWrite(MEMWB_regwrite), .MEMWB_rt_d(MEMWB_RegRd),
                      .i_cache_stall(IFID_stall),
					 .data1(data1), .data2(data2), .imm(imm), .hlt(ID_hlt), .RegDst(RegDst), .ALUSrc(ALUSrc), .Branch(Branch), .MemRead(MemRead), .MemWrite(MemWrite), .RegWrite(RegWrite), 
					 .MemToReg(MemToReg), .PCS_en(PCS_en), .nxt_pc_addr(PC_decoder_branch), .en(en), .Flush(Flush), .rd(IFID_Rd), .rs(IFID_Rs), .rt(IFID_Rt));



/************************* DATA HAZARD DETECTION **************************/

DataHazardDetection DHD (.IDEX_MemRead( EXMEM_Mem_Read), .IFID_MemWrite(IDEX_memwrite), .IDEX_Rt(EXMEM_RegRd), .IFID_Rt(IDEX_rt), .IFID_Rs(IDEX_rs), .IFID_Write(IFID_Write), .Control_Select(Control_Select), .PC_Write(PC_Write));




/************************* THIS IS FOR 'PCS': Store pc value in data1 and 16'h2 in data2 to store the alu output (next pc value) in the specified register  **************************/

//assign data1 = PCS_en ? pc_out : data_temp1;
//assign data2 = PCS_en ? 16'h2 : data_temp2;


/************************* IDEX BUFFER **************************/

assign IDEX_stall =  d_fsm_busy | d_cache_miss_detected ? ~(d_fsm_busy | d_cache_miss_detected) : Control_Select;
ID_EX_buffer IDEX_buf(	.clk(clk), .rst(rst), .hlt(ID_hlt), .stall(IDEX_stall), .memtoreg_in(MemToReg), .regwrite_in(RegWrite), .memread_in(MemRead), .memwrite_in(MemWrite), 
						.ALUOp_in(inst_out[15:12]), .RegDst_in(RegDst), .ALUSrc_in(ALUSrc), .pc_out_two(pc_out_two), .PCS_en_in(PCS_en), .register_1(data1), .register_2(data2), .sign_ext(imm), .reg_rs(IFID_Rs), .reg_rt(IFID_Rt), .reg_rd(IFID_Rd),
						.memtoreg(IDEX_memtoreg),  .regwrite(IDEX_regwrite), .memread(IDEX_MemRead), .memwrite(IDEX_memwrite), .ALUOp(IDEX_opcode), .RegDst(IDEX_RegDst), .ALUSrc(IDEX_ALUSrc), .PCS_en(IDEX_PCS_en), .pc_out_two_out(IDEX_pc_out_two),
						.register_1_out(IDEX_data1), .register_2_out(IDEX_data2), .rs(IDEX_rs), .rt(IDEX_rt), .rd(IDEX_rd), .sign_ext_out(IDEX_imm), .IDEX_hlt(EX_hlt));



/************************* EXECUTE STAGE **************************/



Execute_stage Execute ( .clk(clk), .rst(rst), .pc_out(IDEX_pc_out_two), .ALUOp(IDEX_opcode), .RegDst(IDEX_RegDst), .ALUSrc(IDEX_ALUSrc), .PCS_en(IDEX_PCS_en), .rs_data(IDEX_data1), .rt_data(IDEX_data2), .rt(IDEX_rt), .rd(IDEX_rd), .sign_ext_out(IDEX_imm), 
						.ex2ex_inp(EXMEM_alu_out), .mem2ex_inp(WB_out),  .fwd_mux_a_sel(fwd_mux_a), .fwd_mux_b_sel(fwd_mux_b),
						.alu_out(alu_out), .rt_to_mem(rt_to_mem), .dest_reg_out(dest_reg_out), .Flag(Flag));



/************************* EXMEM BUFFER **************************/
dff hlt_ff1(.q(MEM_hlt), .d(EX_hlt), .wen(1'b1), .clk(clk), .rst(rst));
assign EXMEM_stall = d_fsm_busy | d_cache_miss_detected ? ~(d_fsm_busy | d_cache_miss_detected) :  1'b1;
EX_MEM_buffer EXMEM_buf(.memtoreg_in(IDEX_memtoreg), .regwrite_in(IDEX_regwrite), .memread_in(IDEX_MemRead), .memwrite_in(IDEX_memwrite), .aluout_in(alu_out), .EX_MEM_rt_to_mem_in(rt_to_mem), 
						.EX_MEM_rd_or_rt_in(dest_reg_out), .clk(clk), .rst(rst), .stall(EXMEM_stall), 
						.memtoreg(EXMEM_memtoreg), .regwrite(EXMEM_RegWrite), .memread(EXMEM_Mem_Read), .memwrite(EXMEM_Mem_Write), .aluout(EXMEM_alu_out), .EX_MEM_rt_to_mem(EXMEM_Rt), .EX_MEM_rd_or_rt(EXMEM_RegRd));



/************************* MEMORY STAGE **************************/
Mem_stage RAM ( .MEM2MEM_fwd_mux(MEM2MEM_fwd_mux), .WB_out(WB_out), .EXMEM_Rt(EXMEM_Rt), .mem_data_in(mem_data_in));

assign d_cache_data_in = d_cache_write_data_array ? d_cache_data : mem_data_in;

DataCache dcache(.clk(clk), .rst(rst), .addressIn(EXMEM_alu_out), .DataIn(d_cache_data_in), .data_write(d_cache_write_data_array), .tag_write(d_cache_write_tag_array), 
			.valid_bit(d_cache_valid_bit), .offset_write_fsm(d_fsm_cache_addr), .mem_write(EXMEM_Mem_Write), .mem_read(EXMEM_Mem_Read),
                 	.DataOut(MEM_out), .miss_detected(d_cache_miss_detected));

cache_fill_FSM dcache_fsm(.clk(clk), .wen(1'b1), .rst_n(rst), .miss_detected(d_cache_miss_detected), .miss_address(EXMEM_alu_out), .memory_data(data_out), .memory_data_valid(d_data_valid), .fsm_en_mem_arb(en_d_cache),
	                  .fsm_busy(d_fsm_busy), .cache_array_data(d_cache_data), .cache_count(d_fsm_cache_addr), .write_data_array(d_cache_write_data_array), 
			  .write_tag_array(d_cache_write_tag_array), .memory_address(d_cache_memory_address), .write_valid_bit(d_cache_valid_bit));

/************************* MEMWB BUFFER **************************/
dff hlt_ff2 (.q(hlt), .d(MEM_hlt), .wen(1'b1), .clk(clk), .rst(rst));
assign MEMWB_stall = (d_fsm_busy | d_cache_miss_detected) ? ~(d_fsm_busy | d_cache_miss_detected) :  1'b1;
MEM_WB_buffer MEMWB_buf (.memtoreg_in(EXMEM_memtoreg), .regwrite_in(EXMEM_RegWrite), .aluout_in(EXMEM_alu_out), .datamemory_in(MEM_out), .MEMWB_rd_or_rt_in(EXMEM_RegRd), .clk(clk), .rst(rst), .stall(MEMWB_stall),
			  .memtoreg(MEMWB_memtoreg), .regwrite(MEMWB_regwrite), .MEMWB_aluout(MEMWB_alu_out), .datamemory(MEMWB_data_mem), .MEMWB_rd_or_rt(MEMWB_RegRd));



/************************* FORWARDING UNIT **************************/

fwd_unit FU (.EXMEM_Mem_Read(EXMEM_Mem_Read), .EXMEM_MemWrite(EXMEM_Mem_Write), .EXMEM_RegWrite(EXMEM_RegWrite), .MEMWB_RegWrite(MEMWB_regwrite), .EXMEM_RegRd(EXMEM_RegRd), .IDEX_RegRs(IDEX_rs), .IDEX_RegRt(IDEX_rt), .MEMWB_RegRd(MEMWB_RegRd), 
			 .fwd_mux_a(fwd_mux_a), .fwd_mux_b(fwd_mux_b), .MEM2MEM_fwd_mux(MEM2MEM_fwd_mux));



/************************* WRITE-BACK STAGE (TODO)**************************/

WriteBack_Stage WriteBack (.MEMWB_data_mem(MEMWB_data_mem), .MEMWB_alu_out(MEMWB_alu_out), .MEMWB_memtoreg(MEMWB_memtoreg), 
						   .WB_out(WB_out));


endmodule
