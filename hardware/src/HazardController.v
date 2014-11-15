`include "ALUop.vh"
`include "Opcode.vh"

module HazardController(input stall, input [6:0]OpcodeW, input [6:0] OpcodeX, 
	input [4:0] rd, input[4:0] rs1, input[4:0] rs2, input diverge, input [13:0] PC_X,
        input [13:0] PC_W, output reg CWE2, output reg  ForwardA, output reg ForwardB, 
        output reg delayW, output reg delayX);

always @(*) begin
    //if (stall == 0) begin
    case (OpcodeW) 
       `OPC_ARI_RTYPE: begin
	  ForwardA = (rd == rs1 && rd != 0 && PC_X != PC_W)?1:0;
	  ForwardB = (rd == rs2 &&  rd != 0 && PC_X != PC_W)?1:0;
	  delayW = 0;
	  CWE2 = 1;    
       end
       `OPC_ARI_ITYPE: begin
	  ForwardA = (rd == rs1 && rd != 0 && PC_X != PC_W)?1:0;
	  ForwardB = (rd == rs2 && rd != 0 && PC_X != PC_W)?1:0;
	  delayW = 0;
	  CWE2 = 1;
       end 
      `OPC_LUI: begin
          ForwardA = (rd == rs1 && rd != 0 && PC_X != PC_W)?1:0;
          ForwardB = (rd == rs2 && rd != 0 && PC_X != PC_W)?1:0;
          delayW = 0;
          CWE2 = 1;
      end
      `OPC_AUIPC: begin
          ForwardA = (rd == rs1 && rd != 0 && PC_X != PC_W)?1:0; 
          ForwardB = (rd == rs2 && rd != 0 && PC_X != PC_W)?1:0;
          delayW = 0;
          CWE2 = 1;
      end
      `OPC_JAL: begin
          ForwardA = (rd == rs1 && rd != 0 && PC_X != PC_W)?1:0;
          ForwardB = (rd == rs2 && rd != 0 && PC_X != PC_W)?1:0;
          delayW = 0;
          CWE2 = 1;
      end
      `OPC_JALR: begin
          ForwardA = (rd == rs1 && rd != 0 && PC_X != PC_W)?1:0;
          ForwardB = (rd == rs2 && rd != 0 && PC_X != PC_W)?1:0;
          delayW = 0;
          CWE2 = 1;
      end
      `OPC_LOAD: begin
	  ForwardA = 0;
	  ForwardB = 0;
	  delayW = ((rd == rs1 || rd == rs2) && rd != 0) ? 1:0;
	  CWE2 = ((rd == rs1 || rd == rs2) && rd != 0) ? 0:1;  
      end
      default:begin
	  ForwardA = 0;
	  ForwardB = 0;
	  delayW = 0;
	  CWE2 = 1;
      end
    endcase // case (OpcodeW)
    case (OpcodeX)
       `OPC_BRANCH: begin
	    //delayX = (diverge)?1:0;
	    delayX = 0;
	 end
	 default: begin
	    delayX = 0;
         end
       endcase // case (OpcodeX)
    //end // if (stall == 0)
    /*else begin
      ForwardA = 0;
       ForwardB = 0;
       delayW = 1;
       delayX = 1;
    end // else: !if(stall == 0)*/
end // always @ (*)
   
   endmodule // HazardController

