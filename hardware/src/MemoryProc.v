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
    wire [1:0] = offset;

    assign offset = Address[1:0];
    assign Proc_Mem = mem_reg;

    always@(*)
    begin
        case(Opcode)
            `OPC_LOAD:
            begin
                case (Funct3)
                    `FNC_LB:
                        case (offset)
                            00:mem_reg = $signed(Mem[7:0]);
                            01:mem_reg = $signed(Mem[15:8]);
                            10:mem_reg = $signed(Mem[23:16]);
                            11:mem_reg = $signed(Mem[31:24]);
                            default: mem_reg = 32'bx;
                        endcase
                    `FNC_LH:
                        case (offset)
                            00:mem_reg = $signed(Mem[15:0]);
                            10:mem_reg = $signed(Mem[31:16]);
                            default: mem_reg = 32'bx;
                        endcase
                    `FNC_LBU:
                        case (offset)
                            00:mem_reg = Mem[7:0];
                            01:mem_reg = Mem[15:8];
                            10:mem_reg = Mem[23:16];
                            11:mem_reg = Mem[31:24];
                            default: mem_reg = 32'bx;
                        endcase
                    `FNC_LHU:
                        case (offset)
                            00:mem_reg = Mem[15:0];
                            10:mem_reg = Mem[31:16];
                            default: mem_reg = 32'bx;
                        endcase
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
