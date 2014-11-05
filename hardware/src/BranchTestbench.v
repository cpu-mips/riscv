//  Module: ControlTestbench
//  Desc:   Control testbench for the RISCv Processor
// If #1 is in the initial block of your testbench, time advances by
// 1ns rather than 1ps
`timescale 1ns / 1ps

`include "Opcode.vh"

module BranchTestbench();

    parameter Halfcycle = 5; //half period is 5ns
    
    localparam Cycle = 2*Halfcycle;
    
    reg Clock;
    
    // Clock Signal generation:
    initial Clock = 0; 
    always #(Halfcycle) Clock = ~Clock;
    
    // Register and wires to test the adder
    reg [2:0] funct3;
    reg [31:0] A, B, rand31;
    reg [14:0] rand15;
    reg REFout;

    wire [6:0] opcode;
    wire [3:0] alu_op;
    wire [31:0] out;
    wire zero;
    wire DUTout;

    assign opcode = `OPC_BRANCH;


    // Task for checking output
    task checkOutput;
        if ( REFout !== DUTout ) begin
            $display("FAIL: Incorrect result for A 0x%h, B 0x%h, Opcode %b, Funct %b", A, B, opcode, funct3);
            $display("\tDUTout:%h, REFout:%b", DUTout, REFout);
            $finish();
        end
        else begin
            $display("FAIL: Incorrect result for A 0x%h, B 0x%h, Opcode %b, Funct %b", A, B, opcode, funct3);
            $display("\tDUTout:%h, REFout:%b", DUTout, REFout);
        end
    endtask

    ALUdec alu_dec(
        .opcode(opcode),
        .funct(funct3),
        .add_rshift_type(1'bx),
        .ALUop(alu_op)
    );

    ALU alu(
        .A(A),
        .B(B),
        .ALUop(alu_op),
        .Out(out),
        .Zero(zero) 
    );

    BranchControl DUT(
        .Opcode(opcode),
        .Funct3(funct3),
        .ALUOut(out),
        .Zero(zero),
        .Diverge(DUTout)

    );

    integer i;
    localparam loops = 7; // number of times to run the tests for

    // Testing logic:
    initial begin
        for(i = 0; i < loops; i = i + 1)
        begin
            /////////////////////////////////////////////
            // Put your random tests inside of this loop
            // and hard-coded tests outside of the loop
            // (see comment below)
            // //////////////////////////////////////////
            #1;
            // Make both A and B negative to check signed operations
            rand_31 = {$random} & 31'h7FFFFFFF;
            rand_15 = {$random} & 15'h7FFF;
            A = {1'b1, rand_31};
            // Hard-wire 16 1's in front of B for sign extension
            B = {16'hFFFF, 1'b1, rand_15};
            //Arithmetic right shift register(signed)

            funct3 = `FNC_BEQ;
            REFout = if (A == B) 1 ? 0;
            #1;
            checkOutput();

            funct3 = `FNC_BNE;
            REFout = if (A == B) 0 ? 1;
            #1;
            checkOutput();

            funct3 = `FNC_BLT;
            REFout = if ($signed(A) < $signed(B)) 1 ? 0;
            #1;
            checkOutput();

            funct3 = `FNC_BGE;
            REFout = if ($signed(A) < $signed(B)) 0 ? 1;
            #1;
            checkOutput();

            funct3 = `FNC_BLTU;
            REFout = if (A < B) 1 ? 0;
            #1;
            checkOutput();

            funct3 = `FNC_BGEU;
            REFout = if (A < B) 0 ? 1;
            #1;
            checkOutput();
        end
        ///////////////////////////////
        // Hard coded tests go here
        ///////////////////////////////

        //Checking unsigned vs signed for negatives
        A = 32'hf000ffff;
        B = 32'hf;
        funct3 = `FNC_BLT;
        REFout = 1'b1;
        #1;
        checkOutput();

        A = 32'hf000ffff;
        B = 32'hf;
        funct3 = `FNC_BLTU;
        REFout = 1'b0;
        #1;
        checkOutput;

        A = 32'hf000ffff;
        B = 32'hf;
        funct3 = `FNC_BGE;
        REFout = 1'b0;
        #1;
        checkOutput;

        A = 32'hf000ffff;
        B = 32'hf;
        funct3 = `FNC_BGEU;
        REFout = 1'b1;
        #1;
        checkOutput;

        //Checking equal case
        A = 0; 
        B = 0;
        funct3 = `FNC_BGE;
        REFout = 1'b1;
        #1;
        checkOutput;

        A = 0; 
        B = 0;
        funct3 = `FNC_SLT;
        REFout = 1'b0;
        #1;
        checkOutput;
        
        $display("\n\nALL TESTS PASSED!");
        $finish();
    end

  endmodule
