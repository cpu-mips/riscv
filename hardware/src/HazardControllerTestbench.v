//  Module: ALUTestbench
//  Desc:   Hazard Controller testbench for the MIPS150 Processor
//  Feel free to edit this testbench to add additional functionality
//  
//  Note that this testbench only tests correct operation of the Hazard Controller,
//  it doesn't check that you're mux-ing the correct values into the inputs
//  of the Hazard Controller. 

// If #1 is in the initial block of your testbench, time advances by
// 1ns rather than 1ps
`timescale 1ns / 1ps

`include "Opcode.vh"

module HazardControllerTestbench();

    parameter Halfcycle = 5; //half period is 5ns
    
    localparam Cycle = 2*Halfcycle;
    
    reg Clock;
    
    // Clock Signal generation:
    initial Clock = 0; 
    always #(Halfcycle) Clock = ~Clock;
    
    // Register and wires to test the HazardController
    reg [6:0] OpcodeX;
    reg [6:0]  OpcodeW;
   reg [4:0]   rd;
   reg [4:0]   rs1;
   reg [4:0]   rs2;
   reg 	       diverge;
   reg [13:0] pc_x, pc_w;
   wire 	       CWE2;
   wire 	       noop;
   wire 	       ForwardA;
   wire 	       ForwardB;
   wire 	       delayW;
   reg 	       refCWE2;
   reg 	       refnoop;
   reg 	       refForwardA;
   reg 	       refForwardB;
   reg 	       refdelayW;
   
    

    // Signed operations; these are useful
    // for signed operations
    //wire signed [31:0] B_signed;
   // assign B_signed = $signed(B);

    //wire signed_comp, unsigned_comp;
   // assign signed_comp = ($signed(A) < $signed(B));
   // assign unsigned_comp = A < B;

    // Task for checking output
    task checkOutput;
        if ( CWE2 !== refCWE2 || noop !== refnoop || ForwardA !== refForwardA || ForwardB !== refForwardB || delayW !== refdelayW ) begin
            $display("FAIL: Incorrect result for opcodeX %b, opcodeW %b, rd %b, rs1 %b, rs2 %b", OpcodeX, OpcodeW, rd, rs1, rs2);
            $display("\t Is CWE2: 0x%b, noop: 0x%b, forwardA: 0x%b, forwardB: 0x%b, delayW: 0x%b", CWE2, noop, ForwardA, ForwardB, delayW);

	   $display("\t Should be CWE2: 0x%b, noop: 0x%b, forwardA: 0x%b, forwardB: 0x%b, delayW: 0x%b", refCWE2, refnoop, refForwardA,refForwardB, refdelayW);
            $finish();
        end
        else begin
            $display("PASS: Result for opcodeX %b, opcodeW %b, rd %b, rs1 %b, rs2 %b", OpcodeX, OpcodeW, rd, rs1, rs2);
            $display("\t Is CWE2: 0x%b, noop: 0x%b, forwardA: 0x%b, forwardB: 0x%b, delayW: 0x%b", CWE2, noop, ForwardA, ForwardB, delayW);
        end
    endtask

    //This is where the modules being tested are instantiated. 

    HazardController DUT(.OpcodeW(OpcodeW),
        .OpcodeX(OpcodeX),
        .rd(rd),
        .rs1(rs1),
	.rs2(rs2),
	.diverge(diverge),
	.PC_X(pc_x),
	.PC_W(pc_w),
        .CWE2(CWE2),
        .noop(noop),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB),
        .delayW(delayW));

    integer i;
    localparam loops = 3; // number of times to run the tests for
   localparam A = 4'd1;
   localparam B = 4'd2;
   localparam C = 4'd3;
   localparam D = 4'd0;
   localparam pc1 = 14'd10;
   localparam pc2 = 14'd11;
   localparam pc3 = 14'd12;
    // Testing logic:
    initial begin
	#1;
	OpcodeW=`OPC_ARI_RTYPE;
	OpcodeX=`OPC_ARI_ITYPE;
	rd = A;
	rs1 = A;
	rs2 = B;
	diverge = 1;
	pc_x = pc1;
	pc_w = pc2;
        refForwardA = 1;
	refForwardB = 0;
	refnoop = 0;
	refCWE2=1;
	refdelayW = 0;
	#1;
	checkOutput();
       	OpcodeW=`OPC_ARI_RTYPE;
	OpcodeX=`OPC_ARI_ITYPE;
	rd = D;
	rs1 = D;
	rs2 = B;
	pc_x = pc1;
	pc_w = pc2;
	diverge = 1;
        refForwardA = 0;
	refForwardB = 0;
	refnoop = 0;
	refCWE2=1;
	refdelayW = 0;
	#1;
	checkOutput();
	OpcodeW = `OPC_ARI_RTYPE;
	OpcodeX = `OPC_ARI_ITYPE;
	rd = A;
	rs1 = A;
	rs2 = B;
	pc_x = pc1;
	pc_w = pc1;
	diverge = 1;
	refForwardA = 0;
	refForwardB = 0;
	refnoop = 0;
	refCWE2 = 1;
	refdelayW = 0;
	#1;
	checkOutput();	
	OpcodeW=`OPC_ARI_ITYPE;
	OpcodeX=`OPC_ARI_RTYPE;
	rd = A;
	rs1 = A;
	rs2 = A;
	pc_x = pc1;
	pc_w = pc2;
	diverge = 1;
	refForwardA = 1;
	refForwardB = 1;
	refnoop = 0;
	refCWE2=1;
	refdelayW = 0;
	#1;
	checkOutput();
	OpcodeW=`OPC_ARI_RTYPE;
	OpcodeX=`OPC_BRANCH;
	rd = A;
	rs1 = A;
	rs2 = C;
	diverge = 1;
	refForwardA = 1;
	refForwardB = 0;
	refnoop = 1;
	refCWE2=0;
	refdelayW = 0;
	#1;
	checkOutput();
	OpcodeW=`OPC_ARI_RTYPE;
	OpcodeX=`OPC_BRANCH;
	rd = A;
	rs1 = C;
	rs2 = B;
	diverge = 1;
	refForwardA = 0;
	refForwardB = 0;
	refnoop = 1;
	refCWE2=0;
	refdelayW = 0;
	#1;
	checkOutput();
	OpcodeW=`OPC_ARI_RTYPE;
	OpcodeX=`OPC_BRANCH;
	rd = A;
	rs1 = C;
	rs2 = B;
	diverge = 0;
	refForwardA = 0;
	refForwardB = 0;
	refnoop = 0;
	refCWE2=0;
	refdelayW = 0;
	#1;
	checkOutput();
	OpcodeW = `OPC_LOAD;
	OpcodeX = `OPC_ARI_RTYPE;
	rd = A;
	rs1=A;
	rs2=B;
        diverge=0;
	refForwardA=0;
	refForwardB=0;
	refnoop = 1;
	refCWE2 = 0;
	refdelayW=1;
	#1;
	checkOutput();
	OpcodeW = `OPC_LOAD;
	OpcodeX = `OPC_BRANCH;
	rd = A;
	rs1=A;
	rs2=B;
	diverge=1;
	refForwardA=0;
	refForwardB=0;
       refnoop = 1;
       refCWE2 = 0;
       refdelayW=1;
       #1;
       checkOutput();
       OpcodeW = `OPC_LOAD;
       OpcodeX = `OPC_ARI_RTYPE;
       rd = A;
       rs1=B;
       rs2=C;
       diverge=1;
       refForwardA=0;
       refForwardB=0;
       refnoop = 0;
       refCWE2 = 1;
       refdelayW=0;
       #1;
       checkOutput();
       OpcodeW = `OPC_LOAD;
       OpcodeX = `OPC_BRANCH;
       rd = A;
       rs1=C;
       rs2=B;
       diverge=0;
       refForwardA=0;
       refForwardB=0;
       refnoop = 0;
       refCWE2 = 0;
       refdelayW=0;
       #1;
       checkOutput();
        rd = A;
       rs1=C;
       rs2=B;
       diverge=1;
       refForwardA=0;
       refForwardB=0;
       refnoop = 1;
       refCWE2 = 0;
       refdelayW=0;
       #1;
       checkOutput();
        $display("\n\nALL TESTS PASSED!");
        $finish();
    end

  endmodule
