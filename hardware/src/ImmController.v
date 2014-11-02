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

module ImmController(input [6:0] Opcode, input [2:0] funct3, input [6:0] funct7, input [19:0] immA, input [11:0] immB, input [6:0] immC, input [4:0] immD, output reg [19:0] imm);
   

always @ (*) begin
   if (Opcode == `OPC_LUI || Opcode == `OPC_AUIPC)
     imm = immA;
   else if (Opcode == `OPC_JAL) imm = {immA[19],immA[7:0],immA[8],immA[18:9]};
   else if (Opcode == `OPC_BRANCH) imm = {8'b0,immC[6],immD[0],immC[5:0],immD[4:1]};
   
   else if (Opcode == `OPC_JALR || Opcode == `OPC_LOAD || Opcode == `OPC_ARI_ITYPE) imm = {8'b0, immB};
   else if (Opcode == `OPC_STORE) imm ={8'b0,immC, immD};
   
end
endmodule
