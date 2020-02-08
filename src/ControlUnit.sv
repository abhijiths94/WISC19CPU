module ControlUnit(input [3:0] Opcode, input branch_in, output RegDst,
                   output ALUSrc, output Branch, output MemRead,
                   output MemWrite, output RegWrite, output MemToReg, output Flush);

 

  reg regdst = 0;
  reg alusrc = 0;
  reg branch = 0;
  reg memread = 0;
  reg memwrite = 0;
  reg regwrite = 0;
  reg memtoreg = 0;
 
  assign RegDst = regdst;
  assign Flush = branch_in;
  assign ALUSrc = alusrc;
  assign Branch = branch;
  assign MemRead = memread;
  assign MemWrite = memwrite;
  assign RegWrite = regwrite;
  assign MemToReg = memtoreg;

  always @* begin
  
	regdst = 0;
	alusrc = 0;
	branch = 0;
	memread = 0;
	memwrite = 0;
	regwrite = 0;
	memtoreg = 0;
  
    case (Opcode)
      4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0111, 4'b1110: begin
        // ADD, SUB, XOR, RED, PCS
        regdst=1;
        regwrite=1;
      end
      4'b0100, 4'b0101, 4'b0110: begin
        // SLL, SRA, ROR
        alusrc=1;
        regwrite=1;
      end

      4'b1000: begin
        alusrc=1;
        memread=1;
        regwrite=1;
        memtoreg=1;
      end
	  
      4'b1001: begin
        alusrc=1;
        memwrite=1;
      end

      4'b1010, 4'b1011: begin
        //LLB, LHB
        regdst=1;
        alusrc=1;
        regwrite=1;
      end

      4'b1100, 4'b1101:
        // B, BR
        branch=1;
		
      default: begin
        regdst = 1'bz;
        alusrc = 1'bz;
        branch = 1'bz;
        memread = 1'bz;
        memwrite = 1'bz;
        regwrite = 1'bz;
        memtoreg = 1'bz;
      end

    endcase

  end

 

endmodule