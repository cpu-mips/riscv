//-----------------------------------------------------------------------------
//  Module: MemoryProc.v
//  Desc: Handles memory coming out of Dmem or the UART 
//  Inputs Interface:
//    Mem: Memory output (asynchronous)
//    Opcode: Current stage opcode (asynchronous)
//    Funct3: Current stage Funct3 (asynchronous)
//  Output Interface:
//    Proc_Mem: Memory after masking
//-----------------------------------------------------------------------------

module MemoryProc(
    input [31:0] Mem,
    input [6:0] Opcode,
    input [2:0] Funct3,
    output [31:0] Proc_Mem);

endmodule
