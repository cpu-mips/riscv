//-----------------------------------------------------------------------------
//  Module: ImmController
//  Desc: Controller block to assemble the necessary immediate fields depending on opcode 
//  Inputs Interface:
//    Opcode: The opcode fetched from the instruction, indices 0-6
//    funct3: Indices 12-14 of instruction
//    funct7: Indices 25-31 of instruction
//    immA: This immediate field for a U-type (and UJ-type) field
//    immB: Immediate for an I-type operation, indices 20-31
//    immC: Immediate for S-type and SB-type operations, indices 25-31
//    immD: Second part of immediate for S and SB type instructions, indices 7-11
//  Output Interface:
//    imm: The immediate data
//-----------------------------------------------------------------------------
`include "ALUop.vh"
`include "Opcode.vh"

module ImmController(input [6:0] Opcode, input [19:0] immA, input [11:0] immB, input [6:0] immC, input [4:0] immD, output reg [31:0] imm);
   

always @ (*) begin
   case(Opcode)
     `OPC_LUI: 
       imm = $signed(immA);
     `OPC_AUIPC:
       imm = $signed(immA);
     `OPC_JAL:
       imm = $signed({immA[19],immA[7:0],immA[8],immA[18:9]});
     `OPC_BRANCH: begin
	//if (funct3 == `FNC_BLTU || funct3 == `FNC_BGEU)
	  //imm = {immC[6],immD[0],immC[5:0],immD[4:1]};
	//else
	  imm = $signed({immC[6],immD[0],immC[5:0],immD[4:1]});
     end
     `OPC_JALR:
        imm = $signed(immB);
     `OPC_LOAD: begin
	//if (funct3 == `FNC_LBU || funct3 == `FNC_LHU)
	  //imm = immB;
	//else
	  imm = $signed(immB);
     end
     `OPC_ARI_ITYPE: begin
       //if (funct3 == `FNC_SLTU)
	 //imm = immB;
       //else
	 imm = $signed(immB);
	
     end
     `OPC_STORE:
       imm =$signed({immC, immD});
     default: imm = 32'b0;
   endcase
end
endmodule
