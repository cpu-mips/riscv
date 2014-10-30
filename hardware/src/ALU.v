// UC Berkeley CS150
// Lab 4, Fall 2014
// Module: ALU.v
// Desc:   32-bit ALU for the MIPS150 Processor
// Inputs: 
//    A: 32-bit value
//    B: 32-bit value
//    ALUop: Selects the ALU's operation 
// 						
// Outputs:
//    Out: The chosen function mapped to A and B.

`include "Opcode.vh"
`include "ALUop.vh"

module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALUop,
    output reg [31:0] Out,
    output reg Zero
);

    // Implement your ALU here, then delete this comment
   assign Zero = (Out == 32'b0)? 1:0;
   
   always @ (*) begin
        case(ALUop)
	  `ALU_ADD:
	    Out = A+B;
	  `ALU_SUB:
	    Out=A-B;
	  `ALU_AND:
	    Out=A&B;
	  `ALU_OR:
	    Out=A|B;
	  `ALU_XOR:
	    Out = A^B;
	  `ALU_SLT:
	    Out = ($signed(A)<$signed(B))?1:0;
	  `ALU_SLTU:
	    Out = (A<B)?1:0;
	  `ALU_SLL:
	    Out = A<<B[4:0];
	  `ALU_SRL:
	    Out = A>>B[4:0];
	  `ALU_SRA:
	    Out = $signed(A)>>>B[4:0];
	  `ALU_COPY_B:
	    Out=B;
	  `ALU_XXX: ;
	  default: ;
	 endcase
	 end 
endmodule
