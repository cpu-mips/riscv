//  Module: ALUTestbench
//  Desc:   32-bit ALU testbench for the MIPS150 Processor
//  Feel free to edit this testbench to add additional functionality
//  
//  Note that this testbench only tests correct operation of the ALU,
//  it doesn't check that you're mux-ing the correct values into the inputs
//  of the ALU. 

// If #1 is in the initial block of your testbench, time advances by
// 1ns rather than 1ps
`timescale 1ns / 1ps

`include "Opcode.vh"

module ImmControllerTestbench();

    parameter Halfcycle = 5; //half period is 5ns
    
    localparam Cycle = 2*Halfcycle;
    
    reg Clock;
    
    // Clock Signal generation:
    initial Clock = 0; 
    always #(Halfcycle) Clock = ~Clock;
    
    // Register and wires to test the ALU
    reg [2:0] funct3;
   reg [6:0]  Opcode;
   reg [19:0] immA;
   reg [11:0] immB;
   reg [6:0]  immC;
   reg [4:0]  immD;
   wire [31:0] imm;
   reg [31:0] refimm;
   
   

    // Task for checking output
    task checkOutput;
        if (imm !== refimm ) begin
            $display("FAIL: Incorrect result for opcode %b, funct3: %b", Opcode, funct3);
            $display("\tIs Imm: %b",imm);
	   $display("\tShould Be: Imm %b", refimm);
            $finish();
        end
        else begin
            $display("PASS: Result for opcode %b, funct3: %b", Opcode, funct3);
            $display("\tIs Imm: %b",imm);
        end
    endtask

    //This is where the modules being tested are instantiated. 

    ImmController DUT( .Opcode(Opcode),
        .funct3(funct3),
        .immA(immA),
	.immB(immB),
        .immC(immC),
        .immD(immD),
        .imm(imm));

    integer i;
    localparam loops = 3; // number of times to run the tests for

    // Testing logic:
    initial begin
        for(i = 0; i < loops; i = i + 1)
          begin
	     #1;
	     immA = $random;
	     immB = $random;
	     immC = $random;
	     immD = $random;
             Opcode = `OPC_LUI;
	     refimm = $signed(immA);
	     #1;
	     checkOutput();
	     Opcode = `OPC_AUIPC;
	     refimm = $signed(immA);
	     #1;
	     checkOutput();
	     Opcode = `OPC_JAL;
	     refimm = $signed({immA[19],immA[7:0],immA[8],immA[18:9]});
	     #1;
	     checkOutput();
	     Opcode = `OPC_JALR;
	     refimm = $signed(immB);
	     #1;
	     checkOutput();
	     Opcode = `OPC_BRANCH;
	     funct3 = `FNC_BLTU;
	     refimm = {immC[6],immD[0],immC[5:0],immD[4:1]};
	     #1;
	     checkOutput();
	     Opcode = `OPC_BRANCH;
	     funct3 = `FNC_BLT;
	     refimm = $signed({immC[6],immD[0],immC[5:0],immD[4:1]});
	     #1;
	     checkOutput();
	     Opcode = `OPC_LOAD;
	     funct3 = `FNC_LBU;
	     refimm =immB;
	     #1;
	     checkOutput();
	      Opcode = `OPC_LOAD;
	     funct3 = `FNC_LB;
	     refimm =$signed(immB);
	     #1;
	     checkOutput();
	     Opcode = `OPC_ARI_ITYPE;
	     funct3 = `FNC_SLTU;
	     refimm = immB;
	     #1;
	     checkOutput();
	      Opcode = `OPC_ARI_ITYPE;
	     funct3 = `FNC_SLT;
	     refimm = $signed(immB);
	     #1;
	     checkOutput();
	     Opcode = `OPC_STORE;
	     refimm = $signed({immC, immD});
	     #1;
	     checkOutput();
	     

        end
        ///////////////////////////////
        // Hard coded tests go here
        ///////////////////////////////

        

        $display("\n\nALL TESTS PASSED!");
        $finish();
    end

  endmodule
