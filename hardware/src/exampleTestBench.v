`timescale 1ns/1ps

module exampleTestBench();
   reg Clock, Reset;
   parameter HalfCycle = 10;
   parameter Cycle = 2*HalfCycle;
   initial Clock = 0;
   always #(HalfCycle) Clock <= ~Clock;

   assign stall = 0;
   assign serial_rx = 0;
   assign serial_tx=0;
   
   Riscv150 CPU (.clk(Clock),
		 .rst(Reset),
		 .stall(stall),
		 .FPGA_SERIAL_RX(serial_rx),
		 .FPGA_SERIAL_TX(serial_tx));
   
  initial begin
     Reset = 1;
     #(Cycle);
     Reset = 0;
     #(Cycle);
     repeat(200) begin
	#(Cycle);
     end
  end
endmodule // asmtestbench
