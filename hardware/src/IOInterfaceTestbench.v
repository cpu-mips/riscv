//  Module: IOInterfaceTestbench
//  Desc:   IOInterface testbench for the RISCv Processor
// If #1 is in the initial block of your testbench, time advances by
// 1ns rather than 1ps
`timescale 1ns / 1ps

`include "Opcode.vh"

module IOInterfaceTestbench();

    parameter Halfcycle = 5; //half period is 5ns
    
    localparam Cycle = 2*Halfcycle;
    
    reg Clock;
    
    // Clock Signal generation:
    initial Clock = 0; 
    always #(Halfcycle) Clock = ~Clock;
    
    // Register and wires to test the adder
    reg [31:0] rd2, Addr;
    reg [3:0] io_trans;
    reg io_recv, din_valid, dout_ready;
    reg [7:0] din, REFout;

    wire Reset, uart_to_io, io_to_uart, din_ready, dou_valid;
    wire  [7:0] dout, DUTout;

    assign Reset = 1'b0;


    // Task for checking output
    task checkOutput;
        if ( REFout !== DUTout ) begin
            $display("FAIL: Incorrect result for Addr:0x%h, Input:%b", Addr, din);
            $display("\tDUTout:%h, REFout:%b", DUTout, REFout);
            $finish();
        end
        else begin
            $display("PASS: Correct result for Addr:0x%h, Input:%b", Addr, rd2);
            $display("\tDUTout:%h, REFout:%b", DUTout, REFout);
        end
    endtask

    IOInterface DUT(
        .rd2(rd2),
        .Addr(Addr),
        .IO_trans(io_trans),
        .IO_recv(io_recv),
        .Clock(Clock),
        .FPGA_Sin(uart_to_io),
        .FPGA_Sout(io_to_uart), 
        .Received(DUTout)
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

        //Checking receive
        rd2 = 32'bx;
        io_trans = 4'bxxx0;
        io_recv = 1'b1;
        din = 8'b10101010;
        din_valid = 1'b1;
        Addr = 32'h80000004;
        REFout = din;
        #(Cycle);
        din_valid = 1'b0;
        checkOutput();

        //Checking transmit
        rd2 = 32'hxxxxxxff;
        io_trans = 4'bxx1;
        io_recv = 1'b0;
        dout_ready = 1'b1;
        Addr = 32'h80000008;
        REFout = dout;
        #(Cycle)
        dout_ready = 1'b0;
        checkOutput();

        $display("\n\nALL TESTS PASSED!");
        $finish();
    end

  endmodule
