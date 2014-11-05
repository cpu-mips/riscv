//-----------------------------------------------------------------------------
//  Module: IOInterface.v
//  Desc: Handles Communication with IO  
//  Inputs Interface:
//    A: Input address (asynchronous)
//    io_trans: Signal for IO transmission (asynchronous)
//    io_recv: Signal for IO receiving
//  Output Interface:
//    Received: Received IO signal
//-----------------------------------------------------------------------------

module IOInterface(
    input [31:0] A,
    input [3:0] io_trans,
    input io_recv,
    output [31:0] Received);

endmodule
