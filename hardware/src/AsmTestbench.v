`timescale 1ns/1ps

module asmtestbench();

    reg Clock, Reset;
    wire FPGA_SERIAL_RX, FPGA_SERIAL_TX;

    reg   [7:0] DataIn;
    reg         DataInValid;
    wire        DataInReady;
    wire  [7:0] DataOut;
    wire        DataOutValid;
    reg         DataOutReady;

    `ifdef RISCV_CLK_50
        parameter HalfCycle = 10;
    `endif `ifdef RISCV_CLK_100
        parameter HalfCycle = 5;
    `endif
    parameter Cycle = 2*HalfCycle;

    initial Clock = 0;
    always #(HalfCycle) Clock <= ~Clock;

    // Instantiate your Riscv CPU here and connect the FPGA_SERIAL_TX wires
    // to the UART we use for testing

   assign stall = 0;
   
    // Instantiate the UART
    UART          uart( .Clock(           Clock),
                        .Reset(           Reset),
                        .DataIn(          DataIn),
                        .DataInValid(     DataInValid),
                        .DataInReady(     DataInReady),
                        .DataOut(         DataOut),
                        .DataOutValid(    DataOutValid),
                        .DataOutReady(    DataOutReady),
                        .SIn(             FPGA_SERIAL_TX),
                        .SOut(            FPGA_SERIAL_RX));
   Riscv150 CPU(.clk(Clock),
		  .rst(Reset),
		  .stall(stall),
		  .FPGA_SERIAL_RX(FPGA_SERIAL_RX),
		  .FPGA_SERIAL_TX(FPGA_SERIAL_TX));
   
    initial begin
        // Reset. Has to be long enough to not be eaten by the debouncer.
        Reset = 0;
        DataIn = 8'h7a;
        DataInValid = 0;
        DataOutReady = 0;
        #(100*Cycle)

        Reset = 1;
        #(30*Cycle)
        Reset = 0;

	#(200*Cycle)

        $finish();
    end

endmodule
