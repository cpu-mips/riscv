`include "ALUop.vh"
`include "Opcode.vh"

module HazardController(input [6:0]OpcodeW, input [6:0] OpcodeX, 
	input [4:0] rd, input[4:0] rs1, input[4:0] rs2, input diverge, input [31:0] PC_X,
        input [31:0] PC_W, output noop, output CWE2, output reg ForwardA, output 
	reg ForwardB, output reg delayW);
reg noopX, noopW, CWE2_temp;
assign noop = noopX | noopW;
assign CWE2 = (OpcodeX == `OPC_BRANCH || OpcodeX == `OPC_STORE) ? 0:CWE2_temp;
always @(*) begin
    case (OpcodeW) 
       `OPC_ARI_RTYPE: begin
	  ForwardA = (rd == rs1 && rd != 0 && PC_X != PC_W)?1:0;
	  ForwardB = (rd == rs2 &&  rd != 0 && PC_X != PC_W)?1:0;
	  delayW = 0;
	  CWE2_temp = 1; 
          noopW = 0;   
       end
       `OPC_ARI_ITYPE: begin
	  ForwardA = (rd == rs1 && rd != 0 && PC_X != PC_W)?1:0;
	  ForwardB = (rd == rs2 && rd != 0 && PC_X != PC_W)?1:0;
	  delayW = 0;
	  CWE2_temp = 1;
          noopW = 0;
       end 
      `OPC_LUI: begin
          ForwardA = (rd == rs1 && rd != 0 && PC_X != PC_W)?1:0;
          ForwardB = (rd == rs2 && rd != 0 && PC_X != PC_W)?1:0;
          delayW = 0;
          CWE2_temp = 1;
	  noopW = 0;
      end
      `OPC_AUIPC: begin
          ForwardA = (rd == rs1 && rd != 0 && PC_X != PC_W)?1:0; 
          ForwardB = (rd == rs2 && rd != 0 && PC_X != PC_W)?1:0;
          delayW = 0;
          CWE2_temp = 1;
          noopW = 0;
      end
      `OPC_JAL: begin
          ForwardA = (rd == rs1 && rd != 0 && PC_X != PC_W)?1:0;
          ForwardB = (rd == rs2 && rd != 0 && PC_X != PC_W)?1:0;
          delayW = 0;
          CWE2_temp = 1;
          noopW = 0;
      end
      `OPC_JALR: begin
          ForwardA = (rd == rs1 && rd != 0 && PC_X != PC_W)?1:0;
          ForwardB = (rd == rs2 && rd != 0 && PC_X != PC_W)?1:0;
          delayW = 0;
          CWE2_temp = 1;
          noopW = 0;
      end
      `OPC_LOAD: begin
	  ForwardA = 0;
	  ForwardB = 0;
	  delayW = ((rd == rs1 || rd == rs2) && rd != 0) ? 1:0;
	  CWE2_temp = ((rd == rs1 || rd == rs2) && rd != 0) ? 0:1;
          noopW = ((rd == rs1 || rd == rs2) && rd != 0) ? 1:0;  
      end
      default:begin
	  ForwardA = 0;
	  ForwardB = 0;
	  delayW = 0;
	  CWE2_temp = 1;
          noopW = 0;
      end
    endcase // case (OpcodeW)
    case (OpcodeX)
       `OPC_BRANCH: begin
            noopX = (diverge)?1:0;
	 end
       `OPC_JALR: begin
            noopX = 1;
        end
       `OPC_JAL: begin
	    noopX = 1;
	end
	 default: begin
	    noopX = 0;
         end
       endcase // case (OpcodeX)
end // always @ (*)
   
   endmodule // HazardController

