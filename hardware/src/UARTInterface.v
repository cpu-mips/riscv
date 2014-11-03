//-----------------------------------------------------------------------------
//  Module: UARTInterface.v
//  Desc: Handles Communication with UART  
//  Inputs Interface:
//    A: Input address (asynchronous)
//    Uart_trans: Signal for UART transmission (asynchronous)
//    Uart_recv: Signal for UART receiving
//  Output Interface:
//    Received: Received UART signal
//-----------------------------------------------------------------------------

module UARTInterface(
    input [31:0] A,
    input [3:0] Uart_trans,
    input Uart_recv,
    output [31:0] Received);

endmodule
