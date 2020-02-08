module DecodeValues(input rst, input [15:0] Instr, output [2:0] cond,
                    output [3:0] rd, output [3:0] rs, output [3:0] rt,
                    output [15:0] imm, output [8:0] imm_branch, output [1:0] branch_sel, 
					output hlt, output PCS_en);
  reg [2:0] c ;
  reg [3:0] r1, r2, r3;
  reg [8:0] ib;
  reg [1:0] b;
  reg [15:0] i;
  reg pcs_en;
  reg h = 1'b0;

  assign cond = c;
  assign rd = r1;
  assign rs = r2;
  assign rt = r3;
  assign imm = i;
  assign hlt = h;
  assign branch_sel = b;
  assign PCS_en = pcs_en;
  assign imm_branch = ib;
  
  
  
  always @* begin
    
    case (rst)
      1'b1: begin
        h = 0;
        b = 0;
		pcs_en = 0;
      end
      default : begin
        h = h;
        b = b;
		pcs_en = pcs_en;
      end
    endcase

    case (Instr[15:12])
      4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0111 : begin
        // ADD, SUB, XOR, RED, PADDSB
        r1 = Instr[11:8];
        r2 = Instr[7:4];
        r3 = Instr[3:0];
        b = 2'b00;
	    pcs_en = 1'b0;
		c = 3'bz;
      end
      
      4'b0100, 4'b0101, 4'b0110 : begin // SLL, SRA, ROR
        r3 = Instr[11:8];
        r2 = Instr[7:4];
        i = {{12{1'b0}}, Instr[3:0]};
        b = 2'b00;
        pcs_en = 1'b0;
		c = 3'bz;
      end

      4'b1000, 4'b1001 : begin // LW, SW
        r1 = 0;
        r3 = Instr[11:8];
        r2 = Instr[7:4];
        i = {{11{Instr[3]}}, Instr[3:0] << 1};
        b = 2'b00;
        pcs_en = 1'b0;
		c = 3'bz;
      end

      4'b1010 : begin // LLB
        r1 = Instr[11:8];
        r2 = Instr[11:8];
		r3 = 0;
        i = {{8'b0}, Instr[7:0]};
        b = 2'b00;
        pcs_en = 1'b0;
		c = 3'bz;
      end

      4'b1011 : begin // LHB
        r1 = Instr[11:8];
        r2 = Instr[11:8];
		r3 = 0;
        i = {Instr[7:0], {8'b0}};
        b = 2'b00;
        pcs_en = 1'b0;
		c = 3'bz;
      end

      4'b1100 : begin // B
        r1 = 0;
        r2 = 0;
        r3 = 0;
        
        c = Instr[11:9];
        ib = Instr[8:0];
        b = 2'b01;
        pcs_en = 1'b0;
      end

      4'b1101 : begin // BR
        c = Instr[11:9];
        r2 = Instr[7:4];
        ib = Instr[8:0];
        b = 2'b11;
        pcs_en = 1'b0;
      end

      4'b1110 : begin // PCS
        r1 = Instr[11:8];
        b = 2'b00;
        pcs_en = 1'b1;
		c = 3'bz;
      end
      4'b1111 : begin  //halt
        h = 1;
        b = 2'b00;
        pcs_en = 1'b0;
		c = 3'bz;
      end

      default: begin // undefined scenario
        r1 = 4'bz;
        r2 = 4'bz;
        r3 = 4'bz;

        c = 3'bz;
        ib = 9'bz;
        b = 2'bz;
        i = 16'bz;
        pcs_en = 1'bz;
      end
    endcase

  end
endmodule
