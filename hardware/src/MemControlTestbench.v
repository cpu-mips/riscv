//  Module: BranchTestbench
//  Desc:   Branch testbench for the RISCv Processor
// If #1 is in the initial block of your testbench, time advances by
// 1ns rather than 1ps
`timescale 1ns / 1ps

`include "Opcode.vh"

module MemControlTestbench();

    parameter Halfcycle = 5; //half period is 5ns
    
    localparam Cycle = 2*Halfcycle;
    
    reg Clock;
    
    // Clock Signal generation:
    initial Clock = 0; 
    always #(Halfcycle) Clock = ~Clock;
    
    // Register and wires to test the adder
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [31:0] A;
    reg [3:0] REFImem_enable, REFDmem_enable, REFIo_trans;
    reg REFIo_recv;

    wire [3:0] DUTImem_enable, DUTDmem_enable, DUTIo_trans;
    wire DUTIo_recv;

    // Task for checking output
    task checkOutput;
        if ( REFImem_enable !== DUTImem_enable && 
             REFDmem_enable !== DUTDmem_enable &&
             REFIo_trans !== DUTIo_trans &&
             REFIo_recv !== DUTIo_recv) begin
            $display("FAIL: Incorrect result for A 0x%h, opcode %b, Funct %b", A, opcode, funct3);
            $display("\tDUTImem_enable:%b, REFImem_enable:%b DUTDmem_enable:%b REFDmem_enable:%b", DUTImem_enable, REFImem_enable, DUTDmem_enable, REFDmem_enable);
            $display("\tDUTIo_trans:%b, REFIo_trans:%b DUTIo_recv:%b REFIo_recv:%b", DUTIo_trans, REFIo_trans, DUTIo_recv, REFIo_recv);
            $finish();
        end
        else begin
            $display("PASS: Correct result for A 0x%h, opcode %b, Funct %b", A, opcode, funct3);
            $display("\tDUTImem_enable:%b, REFImem_enable:%b DUTDmem_enable:%b REFDmem_enable:%b", DUTImem_enable, REFImem_enable, DUTDmem_enable, REFDmem_enable);
            $display("\tDUTIo_trans:%b, REFIo_trans:%b DUTIo_recv:%b REFIo_recv:%b", DUTIo_trans, REFIo_trans, DUTIo_recv, REFIo_recv);
        end
    endtask

    MemControl DUT(
        .opcode(opcode),
        .Funct3(funct3),
        .A(A),
        .Dmem_enable(DUTDmem_enable),
        .Imem_enable(DUTImem_enable),
        .Io_trans(DUTIo_trans),
        .Io_recv(DUTIo_recv)
    );

    // Testing logic:
    initial begin
        ///////////////////////////////
        // Hard coded tests go here
        ///////////////////////////////

        //Checking unsigned vs signed for negatives
        A = 32'h8xxxxxxx;
        opcode = `OPC_LOAD;
        funct3 = `FNC_LB;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'b1;
        #1;
        checkOutput();

        A = 32'h1xxxxxxx;
        opcode = `OPC_LOAD;
        funct3 = `FNC_LH;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'b0;
        #1;
        checkOutput();

        A = 32'h8xxxxxxx;
        opcode = `OPC_LOAD;
        funct3 = `FNC_LW;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'b1;
        #1;
        checkOutput();

        A = 32'h1xxxxxxx;
        opcode = `OPC_LOAD;
        funct3 = `FNC_LBU;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'b0;
        #1;
        checkOutput();

        A = 32'h1xxxxxxx;
        opcode = `OPC_LOAD;
        funct3 = `FNC_LHU;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'b0;
        #1;
        checkOutput();

        A = 32'h8xxxxxx4;
        opcode = `OPC_STORE;
        funct3 = `FNC_SB;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFIo_trans = 4'b1111;
        REFIo_recv = 1'bx;
        #1;
        checkOutput();

        A = 32'1xxxxxxx3;
        opcode = `OPC_STORE;
        funct3 = `FNC_SB;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b1000;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'bx;
        #1;
        checkOutput();

        A = 32'h1xxxxxx2;
        opcode = `OPC_STORE;
        funct3 = `FNC_SH;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b1100;
        REFIo_trans = 4'b0000;
        REFIo_recv = 1'bx;
        #1;
        checkOutput();

        A = 32'3xxxxxxxx;
        opcode = `OPC_STORE;
        funct3 = `FNC_SW;
        REFImem_enable = 4'b1111;
        REFDmem_enable = 4'b1111;
        REFIo_trans = 4'b0;
        REFIo_recv = 4'bx;
        #1;
        checkOutput();

        $display("\n\nALL TESTS PASSED!");
        $finish();
    end

  endmodule
