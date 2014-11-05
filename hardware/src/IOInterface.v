//-----------------------------------------------------------------------------
//  Module: IOInterface.v
//  Desc: Handles Communication with IO  
//  Inputs Interface:
//    A: Input address (asynchronous)
//    IO_trans: Signal for IO transmission (asynchronous)
//    IO_recv: Signal for IO receiving
//  Output Interface:
//    Received: Received IO signal
//-----------------------------------------------------------------------------

module IOInterface(
    input [31:0] rd2,
    input [31:0] Addr,
    input [3:0] IO_trans,
    input IO_recv,
    input Clock,
    input FPGA_Sin,
    output FPGA_Sout,
    output [31:0] Received);

endmodule
