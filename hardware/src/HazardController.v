//-----------------------------------------------------------------------------
//  Module: HazardController
//  Desc: Controller block to identifyand prevent  hazards in the processor
//  Inputs Interface:
//    OpcodeW: The opcode for the instruction currently in the write stage
//    OpcodeX: The opcode for the instruction currently in the executer stage
//    rd: The destination register for the instruction in write stage
//    rs1: The first source register for the instruction in execute stage 
//        (indices 15-19)
//    rs2: The second source register for the instruction in the execute stage
//        (indices 20-24)
//    isZero: Signal taken from the ALU, this indicates if the result is 0. 
//            This will be used for determining course of action for a branch
//  Output Interface:
//    CWE2: Write enable signal for the instruction in the execute stage, if 
//          we need to insert in a noop in the execute stage because of a load 
//          hazard, we can use CWE2 to do so.
//    noop: Control signal to indicate if a noop needs to be inserted
//    ForwardA, ForwardB: Control signal to indicate if the output of ALU needs 
//           to be short circuited back into the input
//   PCDelay: Reset the PC back to PC instead of PC+4
//-----------------------------------------------------------------------------
`include "ALUop.vh"
`include "Opcode.vh"

module HazardController(input [6:0]OpcodeW, input [6:0] OpcodeX, input[6:0] rd, input[6:0] rs1, input[6:0] rs2, input isZero, output reg CWE2, output reg noop, output reg ForwardA, output reg ForwardB, output reg PCDelay);

always @ (*) begin
   if (OpcodeW == `OPC_ARI_RTYPE || OpcodeW == `OPC_ARI_ITYPE) begin
      ForwardA = (rd==rs1)?1:0;
      ForwardB = (rd==rs2)?1:0;
      if (OpcodeX!=`OPC_BRANCH) begin
	 CWE2=1;
	 PCDelay = 0;
	 noop=0;
      end   
   end else if (OpcodeW == `OPC_LOAD) begin
      CWE2=(rd==rs1 || rd==rs2)?0:1;
      noop=(rd==rs1 || rd==rs2)?1:0;
      PCDelay=(rd==rs1 || rd==rs2)?1:0;
      ForwardA=0;
      ForwardB=0;
   end
   if (OpcodeX == `OPC_BRANCH) begin
      if (OpcodeW !== `OPC_LOAD) noop = (isZero)?0:1;
      if (OpcodeW !== `OPC_LOAD) CWE2=1;
      if (OpcodeW !== `OPC_LOAD ) PCDelay=0;
       if (OpcodeW !== `OPC_ARI_RTYPE && OpcodeW !== `OPC_ARI_ITYPE && OpcodeW !== `OPC_LOAD) begin
	    ForwardA = 0;
	    ForwardB = 0;
       end
   end
   if (OpcodeW !== `OPC_LOAD && OpcodeW !== `OPC_ARI_RTYPE && OpcodeW !== `OPC_ARI_ITYPE && OpcodeX !== `OPC_BRANCH) begin
      PCDelay = 0;
      CWE2=1;
      ForwardA=0;
      ForwardB=0;
      noop=0;
   end
   
end
endmodule
