`include "ALUop.vh"
`include "Opcode.vh"

module ImmController(input [6:0] Opcode, input [2:0] funct3, input [6:0] funct7, input [19:0] immA, input [11:0] immB, input [6:0] immC, input [4:0] immD, output [19:0] imm)

always @ (*)begin
   if (Opcode == `OPC_LUI || Opcode == `OPC_AUIPC)
     imm = immA;
   else if (Opcode == `OPC_JAL) imm = {immA[19],immA[7:0],immA[8],immA[18:9]};
   else if (Opcode == `OPC_BRANCH) imm = {8'b0,immC[6],immD[0],immC[5:0],immD[4:1]}
   else if (Opcode == `OPC_JALR || Opcode == `OPC_LOAD || Opcode == `OPC_ARI_ITYPE) imm = {8'b0, immB};
   else if (Opcode == `OPC_STORE) imm ={8'b0,immC, immD};
   
end
endmodule
