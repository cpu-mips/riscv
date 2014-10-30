`include "ALUop.vh"
`include "Opcode.vh"

module HazardController(input [6:0]OpcodeW, input [6:0] OpcodeX, input[6:0] rd, input[6:0] rs1, input[6:0] rs2, input isZero, output CWE2, output reg noop, output reg ForwardA, output reg ForwardB, output reg PCDelay)

always @ (*) begin
   if (OpcodeW == `OPC_ARI_RTYPE || OpcodeW == `OPC_ARI_ITYPE) begin
      ForwardA = (rd==rs1)?1:0;
      ForwardB = (rd==rs2)?1:0;
      CWE2=0;
      PCDelay = 0;
   end else if (OpcodeW == `OPC_LOAD) begin
      if (rd==rs1 || rd==rs2) begin
	 CWE2 = 0;
	 PCDelay = 1;
      end
      else begin 
	 CWE2=1;
	 PCDelay = 0;
      end
      ForwardA=0;
      ForwardB=0;
   end else begin
      ForwardA=0;
      ForwardB=0;
      CWE2=1;
   end   
   if (OpcodeX == `OPC_BRANCH) begin
      if (!isZero) noop = 1;
      else noop=0;
   end else begin
      noop=0;
   end
   
end // always @ (*)
endmodule















endmodule
