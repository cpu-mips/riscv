//  Module: MemControlTestbench
//  Desc:   MemControl testbench for the RISCv Processor
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
    
    // Register and wires to test the adder
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [31:0] A, pc, rd;
    reg haz_ena;
    reg [3:0] REFImem_enable, REFDmem_enable, REFIo_trans;
    reg [31:0] REFrd2_out;
    reg REFIo_recv, REFdmem_en;

    wire [3:0] DUTImem_enable, DUTDmem_enable, DUTIo_trans;
    wire [31:0] DUTrd2_out;
    wire DUTIo_recv, DUTdmem_en;

    // Task for checking output
    task checkOutput;
        if ( REFImem_enable !== DUTImem_enable || 
             REFDmem_enable !== DUTDmem_enable ||
             REFIo_trans !== DUTIo_trans ||
             REFIo_recv !== DUTIo_recv ||
             REFdmem_en !== DUTdmem_en) begin
            $display("FAIL: Incorrect result for A 0x%h, opcode %b, Funct %b", A, opcode, funct3);
            $display("\tDUTrd2_out:%b REFrd2_out:%b", DUTrd2_out, REFrd2_out);
            $display("\tDUTImem_enable:%b, REFImem_enable:%b DUTDmem_enable:%b REFDmem_enable:%b DUTdmem_en:%b REFdmem_en:%b", DUTImem_enable, REFImem_enable, DUTDmem_enable, REFDmem_enable, DUTdmem_en, REFdmem_en);
            $display("\tDUTIo_trans:%b, REFIo_trans:%b DUTIo_recv:%b REFIo_recv:%b", DUTIo_trans, REFIo_trans, DUTIo_recv, REFIo_recv);
            $finish();
        end
        else begin
            $display("PASS: Correct result for A 0x%h, opcode %b, Funct %b", A, opcode, funct3);
            $display("\tDUTrd2_out:%b REFrd2_out:%b", DUTrd2_out, REFrd2_out);
            $display("\tDUTImem_enable:%b, REFImem_enable:%b DUTDmem_enable:%b REFDmem_enable:%b DUTdmem_en:%b REFdmem_en:%b", DUTImem_enable, REFImem_enable, DUTDmem_enable, REFDmem_enable, DUTdmem_en, REFdmem_en);
            $display("\tDUTIo_trans:%b, REFIo_trans:%b DUTIo_recv:%b REFIo_recv:%b", DUTIo_trans, REFIo_trans, DUTIo_recv, REFIo_recv);
        end
    endtask

    MemControl DUT(
        .opcode(opcode),
        .funct3(funct3),
        .addr(A),
        .rd2(rd),
        .pc(pc),
        .haz_ena(haz_ena),
        .dmem_en(DUTdmem_en),
        .dmem_wr_en(DUTDmem_enable),
        .imem_wr_en(DUTImem_enable),
        .io_trans(DUTIo_trans),
        .io_recv(DUTIo_recv),
        .mem_in(DUTrd2_out)
    );

    // Testing logic:
    initial begin
        ///////////////////////////////
        // Hard coded tests go here
        ///////////////////////////////

        haz_ena = 1'b1;
        pc = 32'h00000000;
        rd = 32'h0000007a;

        //Checking unsigned vs signed for negatives
        A = 32'h8xxxxxxx;
        opcode = `OPC_LOAD;
        funct3 = `FNC_LB;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFdmem_en = 1'b0;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'b1;
        REFrd2_out = 32'hxxxxxxxx;
        #1;
        checkOutput();

        A = 32'h1xxxxxxx;
        opcode = `OPC_LOAD;
        funct3 = `FNC_LH;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFdmem_en = 1'b1;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'b0;
        REFrd2_out = 32'hxxxxxxxx;
        #1;
        checkOutput();

        A = 32'h8xxxxxxx;
        opcode = `OPC_LOAD;
        funct3 = `FNC_LW;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFdmem_en = 1'b0;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'b1;
        REFrd2_out = 32'hxxxxxxxx;
        #1;
        checkOutput();

        A = 32'h1xxxxxxx;
        opcode = `OPC_LOAD;
        funct3 = `FNC_LBU;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFdmem_en = 1'b1;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'b0;
        REFrd2_out = 32'hxxxxxxxx;
        #1;
        checkOutput();

        A = 32'h1xxxxxxx;
        opcode = `OPC_LOAD;
        funct3 = `FNC_LHU;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFdmem_en = 1'b1;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'b0;
        REFrd2_out = 32'hxxxxxxxx;
        #1;
        checkOutput();

        A = 32'h80000010;
        opcode = `OPC_LOAD;
        funct3 = `FNC_LW;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFdmem_en = 1'b0;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'b1;
        REFrd2_out = 32'hxxxxxxxx;
        #1;
        checkOutput();

        A = 32'h80000014;
        opcode = `OPC_LOAD;
        funct3 = `FNC_LW;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFdmem_en = 1'b0;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'b1;
        REFrd2_out = 32'hxxxxxxxx;
        #1;
        checkOutput();

        A = 32'h80000018;
        opcode = `OPC_STORE;
        funct3 = `FNC_SW;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFdmem_en = 1'b0;
        REFIo_trans = 4'b1111;
        REFIo_recv = 1'b0;
        REFrd2_out = 32'hxxxxxxxx;
        #1;
        checkOutput();

        A = 32'h80000004;
        opcode = `OPC_STORE;
        funct3 = `FNC_SB;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFdmem_en = 1'b0;
        REFIo_trans = 4'b0001;
        REFIo_recv = 1'b0;
        REFrd2_out = 32'h0000007a;
        #1;
        checkOutput();

        A = 32'h1xxxxxx3;
        opcode = `OPC_STORE;
        funct3 = `FNC_SB;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b1000;
        REFdmem_en = 1'b0;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'b0;
        REFrd2_out = 32'h7a000000;
        #1;
        checkOutput();

        A = 32'h1xxxxxx2;
        opcode = `OPC_STORE;
        funct3 = `FNC_SH;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b1100;
        REFdmem_en = 1'b0;
        REFIo_trans = 4'b0000;
        REFIo_recv = 1'b0;
        REFrd2_out = 32'h007a0000;
        #1;
        checkOutput();

        pc = 32'h40000000;

        A = 32'h3xxxxxxx;
        opcode = `OPC_STORE;
        funct3 = `FNC_SW;
        REFImem_enable = 4'b1111;
        REFDmem_enable = 4'b1111;
        REFdmem_en = 1'b0;
        REFIo_trans = 4'b0;
        REFIo_recv = 1'b0;
        REFrd2_out = 32'h0000007a;
        #1;
        checkOutput();

        pc = 32'h00000000;
        haz_ena = 1'b0;

        A = 32'h8xxxxxx4;
        opcode = `OPC_STORE;
        funct3 = `FNC_SB;
        REFImem_enable = 4'b0;
        REFDmem_enable = 4'b0;
        REFdmem_en = 1'b0;
        REFIo_trans = 4'b0000;
        REFIo_recv = 1'b0;
        REFrd2_out = 32'hxxxxxxxx;
        #1;
        checkOutput();
        $display("\n\nALL TESTS PASSED!");
        $finish();
    end

  endmodule
