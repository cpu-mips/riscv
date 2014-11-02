//  Module: AdderTestbench
//  Desc:   32-bit Adder testbench for the RISCv Processor
// If #1 is in the initial block of your testbench, time advances by
// 1ns rather than 1ps
`timescale 1ns / 1ps

module AdderTestbench();

    parameter Halfcycle = 5; //half period is 5ns
    
    localparam Cycle = 2*Halfcycle;
    
    reg Clock;
    
    // Clock Signal generation:
    initial Clock = 0; 
    always #(Halfcycle) Clock = ~Clock;
    
    // Register and wires to test the adder
    reg [31:0] A, B;
    wire [31:0] DUTout;
    wire [31:0] REFout; 

    reg [30:0] rand_31;
    reg [14:0] rand_15;

    assign REFout = A + B;

    // Task for checking output
    task checkOutput;
        if ( REFout !== DUTout ) begin
            $display("FAIL: Incorrect result for A 0x%h, B 0x%h", A, B);
            $display("\tA: 0x%h, B: 0x%h, DUTout: 0x%h, REFout: 0x%h", A, B, DUTout, REFout);
            $finish();
        end
        else begin
            $display("PASS: Correct result for A 0x%h, B 0x%h", A, B);
            $display("\tA: 0x%h, B: 0x%h, DUTout: 0x%h, REFout: 0x%h", A, B, DUTout, REFout);
        end
    endtask

    Adder DUT(
        .a(A),
        .b(B),
        .c(DUTout));

    integer i;
    localparam loops = 25; // number of times to run the tests for

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
            #1;
            checkOutput();

        end
        ///////////////////////////////
        // Hard coded tests go here
        ///////////////////////////////

        A = 32'hf000ffff;
        B = 32'hf;
        #1;
        checkOutput();

        A = 12; 
        B = 0;
        #1;
        checkOutput;

        A = 0; 
        B = 12;
        #1;
        checkOutput;

        $display("\n\nALL TESTS PASSED!");
        $finish();
    end

  endmodule
