// UC Berkeley CS150
// Lab 3, Fall 2014
// Module: ALUdecoder
// Desc:   Sets the ALU operation
// Inputs: opcode: the top 6 bits of the instruction
//         funct: the funct, in the case of r-type instructions
//         add_rshift_type: selects whether an ADD vs SUB, or an SRA vs SRL
// Outputs: ALUop: Selects the ALU's operation
//

`include "Opcode.vh"
`include "ALUop.vh"

module ALUdec(
  input [6:0]       opcode,
  input [2:0]       funct,
  input             add_rshift_type,
  output reg [3:0]  ALUop
);
    always @(*) 
    begin
        case (opcode)
            `OPC_LUI: ALUop = `ALU_LUI;
            `OPC_AUIPC: ALUop =`ALU_LUI;
            `OPC_BRANCH: 
            begin
                case (funct)
                    `FNC_BEQ: ALUop = `ALU_SUB;
                    `FNC_BNE: ALUop = `ALU_XOR;
                    `FNC_BLT: ALUop = `ALU_SLT;
                    `FNC_BGE: ALUop = `ALU_SLT;
                    `FNC_BLTU: ALUop = `ALU_SLTU;
                    `FNC_BGEU: ALUop = `ALU_SLTU;
                    default: ALUop = `ALU_XXX;
                endcase
            end
            `OPC_STORE: ALUop = `ALU_ADD;
            `OPC_LOAD: ALUop = `ALU_ADD;
            `OPC_ARI_RTYPE: 
            begin
                case (funct)
                    `FNC_ADD_SUB: 
                    begin
                        case(add_rshift_type) 
                            `FNC2_ADD: ALUop = `ALU_ADD;
                            `FNC2_SUB: ALUop = `ALU_SUB;
                            default: ALUop = `ALU_XXX;
                        endcase
                    end
                    `FNC_SLL: ALUop = `ALU_SLL;
                    `FNC_SLT: ALUop = `ALU_SLT;
                    `FNC_SLTU: ALUop = `ALU_SLTU;
                    `FNC_XOR: ALUop = `ALU_XOR;
                    `FNC_OR: ALUop = `ALU_OR;
                    `FNC_AND: ALUop = `ALU_AND;
                    `FNC_SRL_SRA: 
                    begin
                        case(add_rshift_type) 
                            `FNC2_SRL: ALUop = `ALU_SRL;
                            `FNC2_SRA: ALUop = `ALU_SRA;
                            default: ALUop = `ALU_XXX;
                        endcase
                    end
                    default: ALUop = `ALU_XXX;
                endcase
            end
            `OPC_ARI_ITYPE: 
               case (funct)
                 `FNC_ADD_SUB: ALUop = `ALU_ADD;
                 `FNC_SLT: ALUop = `ALU_SLT;
                 `FNC_SLTU: ALUop = `ALU_SLTU;
                 `FNC_XOR: ALUop = `ALU_XOR;
                 `FNC_AND: ALUop=`ALU_AND;
                 `FNC_OR: ALUop = `ALU_OR;
                 `FNC_SLL: ALUop = `ALU_SLL;
                 `FNC_SRL_SRA: 
                 begin
                    case(add_rshift_type)
                      `FNC2_SRL: ALUop = `ALU_SRL;
                      `FNC2_SRA: ALUop = `ALU_SRA;
                      default: ALUop = `ALU_XXX;
                    endcase // case (add_rshift_type)
                 end
                 default: ALUop = `ALU_XXX;
               endcase // case (funct)
	        
          `OPC_JALR: ALUop = `ALU_ADD;
          `OPC_JAL: ALUop = `ALU_ADD;
          default: ALUop = `ALU_XXX;
        endcase
    end
  // Implement your ALU decoder here, then delete this comment

endmodule
