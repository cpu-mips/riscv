//-----------------------------------------------------------------------------
//  Module: MemControl.v
//  Desc: Memory Control module  
//  Inputs Interface:
//    Opcode: Opcode for instruction (asynchronous)
//    Funct3: Funct3 field for instruction (asynchronous)
//    A: Memory address (asynchronous)
//  Output Interface:
//    Dmem_enable: Enable for dmem write
//    Imem_enable: Enable for imem write
//    Uart_trans: Transmit signal for UART
//    Uart_recv: Receive signal for UART
//-----------------------------------------------------------------------------

module MemControl(
    input [6:0] Opcode,
    input [2:0] Funct3,
    input [31:0] A,
    output [3:0] Dmem_enable,
    output [3:0] Imem_enable,
    output [3:0] Uart_trans,
    output Uart_recv);

endmodule
