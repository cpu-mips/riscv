`include "ALUop.vh"
`include "Opcode.vh"

module HazardController(input stall, input [6:0]OpcodeW, input [6:0] OpcodeX, 
	input [4:0] rd, input[4:0] rs1, input[4:0] rs2, input diverge, 
	output reg CWE2, output reg  ForwardA, output reg ForwardB, output reg delayW, output reg delayX);

always @(*) begin
    if (stall == 0) begin
    case (OpcodeW) 
       OP_ARI_RTYPE: begin
	  ForwardA = (rd == rs1 && rd != 0)?1:0;
	  ForwardB = (rd == rs2 && rd != 0)?1:0;
	  delayW = 0;
	  CWE2 = 1;    
       end
       `OP_ARI_ITYPE: begin
	  ForwardA = (rd == rs1 && rd != 0)?1:0;
	  ForwardB = 0;
	  delayW = 0;
	  CWE2 = 1;
       end 
      `OPC_LOAD: begin
	  ForwardA = 0;
	  ForwardB = 0;
	  delayW = ((rd == rs1 || rs == rs2) && rd != 0) ? 1:0;
	  CWE2 = ((rd == rs1 || rs == rs2) && rd != 0) ? 0:1;  
      end
      default:begin
	  ForwardA = 0;
	  ForwardB = 0;
	  delayW = 0;
	  CWE2 = 1;
      end
    endcase // case (OpcodeW)
    case (OpcodeX)
       OPC_BRANCH: begin
	    delayX = (diverge)?1:0;
	 end
	 default: delayX = 0;
       endcase // case (OpcodeX)
    end // if (stall == 0)
    else begin
      ForwardA = 0;
       ForwardB = 0;
       delayW = 1;
       delayX = 1;
    end // else: !if(stall == 0)
   endmodule // HazardController

