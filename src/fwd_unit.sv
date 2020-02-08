module fwd_unit(EXMEM_Mem_Read, EXMEM_MemWrite, EXMEM_RegWrite, MEMWB_RegWrite, EXMEM_RegRd, IDEX_RegRs, IDEX_RegRt, MEMWB_RegRd, fwd_mux_a, fwd_mux_b, MEM2MEM_fwd_mux);


/* TODO: MEM2MEM */

/****************************************************************************												*		
* This module implements forwarding unit 				 					*
*****************************************************************************
* EX2EX forwarding 															*
*																			*
* if (EX/MEM.RegWrite  and 													*
* (EX/MEM.RegisterRd ≠  0) and (EX/MEM.RegisterRd = ID/EX.RegisterRs)) 		*	
* ForwardA = 01                                                             *
																			*
* if (EX/MEM.RegWrite                                                       *
* and (EX/MEM.RegisterRd ≠  0) and (EX/MEM.RegisterRd = ID/EX.RegisterRt))  *
* ForwardB = 01								                                *
*****************************************************************************
* MEM2EX forwarding 														*
*																			*
* if (MEM/WB.RegWrite  and 													*
* 		(MEM/WB.RegisterRd ≠  0) 	 										*
*		and not(EX/MEM.RegWrite and (EX/MEM.RegisterRd ≠  0))				*
*		and (EX/MEM.RegisterRd ≠  ID/EX.RegisterRs)							*				*
*		and (MEM/WB.RegisterRd = ID/EX.RegisterRs))							*
* ForwardA = 10                                                             *
																			*
* if (MEM/WB.RegWrite  		                                                *
* 		and (MEM/WB.RegisterRd ≠  0) 										*
*		and not(EX/MEM.RegWrite and (EX/MEM.RegisterRd ≠  0))				*
*		and (EX/MEM.RegisterRd ≠  ID/EX.RegisterRt)							*
		and (MEM/WB.RegisterRd = ID/EX.RegisterRt))      					*
* ForwardB = 10                                                             *
*****************************************************************************
* MEM2MEM forwarding 														*
*																			*
* if (EX/MEM.MemWrite and MEM/WB.RegWrite  and 													*
* 		(MEM/WB.RegisterRd ≠  0 and 
		(MEM/WB.RegisterRd = EX/MEM.RegisterRt))							*
* MEM2MEM_Forward = 10                                                      *
*																			*
*                                                           				*
*****************************************************************************/

input EXMEM_Mem_Read, EXMEM_MemWrite, EXMEM_RegWrite, MEMWB_RegWrite;
input [3:0] EXMEM_RegRd, IDEX_RegRs, IDEX_RegRt, MEMWB_RegRd;
output [1:0] fwd_mux_a, fwd_mux_b;
output MEM2MEM_fwd_mux;

localparam NO_FWD 	= 2'b00;
localparam EX2EX	= 2'b01;
localparam MEM2EX	= 2'b10;

wire ex2ex_a, ex2ex_b, mem2ex_a, mem2ex_b, mem2mem;

//assign ex2ex_a = EXMEM_RegWrite ? ( EXMEM_RegRd != 0 ? (EXMEM_RegRd == IDEX_RegRs ? 1 : 0 ): 0 ) : 0 ;
//assign ex2ex_b = EXMEM_RegWrite ? ( EXMEM_RegRd != 0 ? (EXMEM_RegRd == IDEX_RegRt ? 1 : 0 ): 0 ) : 0 ;

assign ex2ex_a = EXMEM_RegWrite & (EXMEM_RegRd!= 0) & (EXMEM_RegRd == IDEX_RegRs) ;
assign ex2ex_b = ~EXMEM_Mem_Read & EXMEM_RegWrite & (EXMEM_RegRd!= 0) & (EXMEM_RegRd == IDEX_RegRt) ;

//assign mem2ex_a = MEMWB_RegWrite ? (MEMWB_RegRd != 0 ? (!(EXMEM_RegWrite ? (EXMEM_RegRd != 0 ? 1: 0) : 0)? (EXMEM_RegRd != IDEX_RegRs ? (MEMWB_RegRd == IDEX_RegRs? 1:0 ):0) : 0): 0): 0 ;
//assign mem2ex_b = MEMWB_RegWrite ? (MEMWB_RegRd != 0 ? (!(EXMEM_RegWrite ? (EXMEM_RegRd != 0 ? 1: 0) : 0)? (EXMEM_RegRd != IDEX_RegRt ? (MEMWB_RegRd == IDEX_RegRt? 1:0 ):0) : 0): 0): 0 ;

assign mem2ex_a = MEMWB_RegWrite & (MEMWB_RegRd != 0) & !(EXMEM_RegWrite & (EXMEM_RegRd != 0) & (EXMEM_RegRd == IDEX_RegRs)) & (MEMWB_RegRd == IDEX_RegRs); 
assign mem2ex_b = MEMWB_RegWrite & (MEMWB_RegRd != 0) & !(EXMEM_RegWrite & (EXMEM_RegRd != 0) & (EXMEM_RegRd == IDEX_RegRt)) & (MEMWB_RegRd == IDEX_RegRt); 


assign MEM2MEM_fwd_mux = EXMEM_MemWrite & MEMWB_RegWrite & (MEMWB_RegRd != 0) & (MEMWB_RegRd == EXMEM_RegRd);

assign fwd_mux_a = ex2ex_a ? EX2EX : (mem2ex_a ? MEM2EX : NO_FWD);
assign fwd_mux_b = ex2ex_b ? EX2EX : (mem2ex_b ? MEM2EX : NO_FWD);


endmodule