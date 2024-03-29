//  Module: IOInterfaceTestbench
//  Desc:   IOInterface testbench for the RISCv Processor
// If #1 is in the initial block of your testbench, time advances by
// 1ns rather than 1ps
`timescale 1ns / 1ps

`include "Opcode.vh"

module IOInterfaceTestbench();

    parameter Halfcycle = 5; //half period is 5ns
    
    localparam Cycle = 2*Halfcycle;
    
    reg Clock, rst, stall;

    reg [7:0] cycles, instructions;
    
    // Clock Signal generation:
    initial Clock = 1'b0; 
    initial stall = 1'b0;
    initial cycles = 8'b0;
    initial instructions = 8'b0;

    always #(Halfcycle) Clock = ~Clock;
    
    // Register and wires to test the adder
    reg [31:0] rd2, Addr;
    reg [3:0] io_trans;
    reg io_recv, din_valid, dout_ready, Reset;
    reg [7:0] din, REFout, DUTout;

    wire uart_to_io, io_to_uart, din_ready, dout_valid;
    wire [31:0] recieve_out;
    wire  [7:0] dout;

    always @(posedge Clock)
    begin
        if (Reset)
        begin
            cycles = 8'b0;
            instructions = 8'b0;
        end
        else
        begin
            cycles = cycles + 1;
            if (~stall)
            begin
                instructions = instructions + 1;
            end
        end
    end

    // Task for checking output
    task checkOutput;
        input [31:0] ipt;
        if ( REFout !== DUTout ) begin
            $display("FAIL: Incorrect result for Addr:0x%h, Input:0x%h", Addr, ipt);
            $display("\tDUTout:%b, REFout:%b", DUTout, REFout);
            $finish();
        end
        else begin
            $display("PASS: Correct result for Addr:0x%h, Input:0x%h", Addr, ipt);
            $display("\tDUTout:%b, REFout:%b", DUTout, REFout);
        end
    endtask

    IOInterface DUT(
        .rd2(rd2),
        .Addr(Addr),
        .IO_trans(io_trans),
        .IO_recv(io_recv),
        .Clock(Clock),
        .Reset(Reset),
        .Stall(stall),
        .FPGA_Sin(uart_to_io),
        .FPGA_Sout(io_to_uart), 
        .Received(recieve_out)
    );

    UART uart(
        .Clock(Clock),
        .Reset(Reset),
        .DataIn(din),
        .DataInValid(din_valid),
        .DataInReady(din_ready),
        .DataOut(dout),
        .DataOutValid(dout_valid),
        .DataOutReady(dout_ready),
        .SIn(io_to_uart),
        .SOut(uart_to_io)
    );

    // Testing logic:
    initial begin
        ///////////////////////////////
        // Hard coded tests go here
        ///////////////////////////////

        Reset = 1'b1;
        #(2 * Cycle)
        Reset = 1'b0;

        //Checking receive
        rd2 = 32'bx;
        io_trans = 4'bxxx0;
        io_recv = 1'b1;
        din = 8'b10101010;
        din_valid = 1'b1; Addr = 32'h80000000; REFout = din;
        #(2 * Cycle)
        while (1'b0 == recieve_out[1])
        begin
            #(Cycle);
        end
        Addr = 32'h80000004;
        #(2 * Cycle);
        DUTout = recieve_out[7:0];
        checkOutput({24'b0, din});

        //Checking transmit
        rd2 = 32'hffffffff;
        io_trans = 4'b001;
        io_recv = 1'b0;
        Addr = 32'h80000008;
        REFout = rd2;
        #(2 * Cycle)
        Addr = 32'h80000000;
        io_recv = 1'b1;
        io_trans = 4'b000;
        #(2 * Cycle);
        while (1'b0 == recieve_out[0])
        begin
            #(Cycle);
        end
        DUTout = dout;
        checkOutput(rd2);

        //Checking Counters
        Addr = 32'h80000010;
        #(1 * Cycle);
        REFout = cycles - 1;
        DUTout = recieve_out;
        checkOutput(Addr);

        stall = 1'b1;
        #(5 * Cycle);
        stall = 1'b0;

        Addr = 32'h80000014;
        #(1 * Cycle);
        REFout = instructions - 1;
        DUTout = recieve_out;
        checkOutput(Addr);

        Addr = 32'h80000018;
        Reset = 1;
        #(1 * Cycle);
        Reset = 0;
        Addr = 32'h80000010;
        #(5 * Cycle);
        REFout = cycles - 1;
        DUTout = recieve_out;
        checkOutput(Addr);
        $display("\n\nALL TESTS PASSED!");
        $finish();
    end

  endmodule
