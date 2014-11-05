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

`include "Opcode.vh"

module MemoryProc(
    input [31:0] Mem,
    input [6:0] Opcode,
    input [2:0] Funct3,
    input [31:0] Address,
    output [31:0] Proc_Mem);

    reg [31:0] mem_reg;

    assign Proc_Mem = mem_reg;

    always@(*)
    begin
        case(Opcode)
            `OPC_LOAD:
            begin
                case (Funct3)
                    `FNC_LB:mem_reg = $signed(Mem[7:0]);
                    `FNC_LH:mem_reg = $signed(Mem[15:0]);
                    `FNC_LBU:mem_reg = Mem[7:0];
                    `FNC_LHU:mem_reg = Mem[15:0];
                    default:mem_reg = Mem;
                endcase
            end
            default:
            begin
                mem_reg = Mem;
            end
        endcase
    end

endmodule
